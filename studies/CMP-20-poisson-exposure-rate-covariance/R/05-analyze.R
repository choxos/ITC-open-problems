## ---------------------------------------------------------------------------
## Performance with Monte Carlo standard errors, the identity check, the controls
## and the registered decision (protocol.md section 5).
##
##   Rscript R/05-analyze.R
##
## Writes results/summary.csv, results/identity.csv, results/controls.csv and
## results/decision.md.
## ---------------------------------------------------------------------------

source("R/01-dgm.R")
RUN_DIR <- "results/run"

fs <- list.files(RUN_DIR, "^cell-[0-9]+[.]rds$", full.names = TRUE)
if (!length(fs)) stop("no run output")
d <- do.call(rbind, lapply(fs, readRDS))
g <- build_grid()
d <- merge(d, g, by = "cell")

## Per cell and method. MCSEs follow Morris, White and Crowther (2019).
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  ok <- z$ok & is.finite(z$lo)
  e <- z$est[ok] - z$truth[ok]; n <- sum(ok)
  cov <- mean(z$lo[ok] <= z$truth[ok] & z$truth[ok] <= z$hi[ok])
  data.frame(cell = z$cell[1], method = z$method[1], n_ok = n, n_fail = nrow(z) - n,
             bias = mean(e), bias_mcse = stats::sd(e) / sqrt(n),
             emp_se = stats::sd(z$est[ok]),
             mod_se = if (all(is.na(z$se))) NA else mean(z$se[ok]),
             coverage = cov, cov_mcse = sqrt(cov * (1 - cov) / n),
             width = mean(z$hi[ok] - z$lo[ok]),
             realized_pred = mean(z$realized_bias),
             arm_C_bias = mean(z$arm_rate_C, na.rm = TRUE),
             arm_B_bias = mean(z$arm_rate_B, na.rm = TRUE))
}))
summ <- merge(summ, g, by = "cell")
summ$predicted <- vapply(seq_len(nrow(summ)), function(i) predicted_bias(summ[i, ]), 0)

## Each aggregate arm's absolute marginal log rate in study 2's own population:
## true value, so the per-arm bias is the stored estimate minus this.
arm_truth <- function(cell, arm) {
  b <- b_from_cv(cell$cv_lam); k <- if (arm == "C") b else b + cell$gamma
  MU[["agd"]] + (if (arm == "B") D_B else 0) + k * MEAN_AGD + k^2 * SD_X^2 / 2
}
summ$arm_C_bias <- summ$arm_C_bias -
  vapply(seq_len(nrow(summ)), function(i) arm_truth(summ[i, ], "C"), 0)
summ$arm_B_bias <- summ$arm_B_bias -
  vapply(seq_len(nrow(summ)), function(i) arm_truth(summ[i, ], "B"), 0)
summ$pred_arm_C <- vapply(seq_len(nrow(summ)), function(i) log(cell_laws(summ[i, ])$C$factor), 0)
summ$pred_arm_B <- vapply(seq_len(nrow(summ)), function(i) log(cell_laws(summ[i, ])$T$factor), 0)
write.csv(summ, "results/summary.csv", row.names = FALSE)

## ---- identity check ------------------------------------------------------------
u <- summ[summ$method == "unweighted" & summ$arm == "main", ]
fit <- stats::lm(bias ~ predicted, data = u, weights = 1 / u$bias_mcse^2)
id <- data.frame(slope = coef(fit)[["predicted"]],
                 slope_se = sqrt(diag(vcov(fit)))[["predicted"]],
                 intercept = coef(fit)[["(Intercept)"]],
                 max_abs_resid_over_mcse = max(abs(u$bias - u$predicted) / u$bias_mcse),
                 n_cells = nrow(u))
write.csv(id, "results/identity.csv", row.names = FALSE)

## ---- controls --------------------------------------------------------------------
within3 <- function(b, s) abs(b) <= 3 * s
nul <- summ[summ$arm == "main" & summ$rho0 == 0 & summ$drho == 0 & summ$method == "unweighted", ]
c_null <- all(within3(nul$bias, nul$bias_mcse)) &&
          all(nul$coverage >= 0.93 & nul$coverage <= 0.97)
sn <- summ[summ$arm == "control_gamma0" & summ$method == "unweighted", ]
big <- abs(sn$pred_arm_C) > 0.02
c_second <- all(abs(sn$arm_C_bias[big]) > 3 * sn$bias_mcse[big]) &&
            all(within3(sn$bias, sn$bias_mcse))
pm <- summ[summ$arm == "main" & summ$rho0 == -0.6 & summ$drho == 0.4, ]
pm <- pm[pm$cv_t == max(pm$cv_t) & pm$cv_lam == max(pm$cv_lam), ]
pu <- pm[pm$method == "unweighted", ]; pw <- pm[pm$method == "weighted", ]
c_pos <- nrow(pu) > 0 && all(abs(pu$bias) > 3 * pu$bias_mcse) &&
         all(within3(pw$bias, pw$bias_mcse)) && all(pw$coverage >= 0.93 & pw$coverage <= 0.97)
ctl <- data.frame(control = c("null", "second null", "positive"),
                  passed = c(c_null, c_second, c_pos),
                  cells = c(nrow(nul), nrow(sn), nrow(pu)))
write.csv(ctl, "results/controls.csv", row.names = FALSE)

## ---- decision --------------------------------------------------------------------
pl <- u[u$cv_t %in% PLAUSIBLE$cv_t & u$cv_lam %in% PLAUSIBLE$cv_lam & u$drho >= 0.2, ]
fires <- (pl$bias - 1.96 * pl$bias_mcse > BIAS_MATERIAL) | (pl$coverage < COVER_LOW)
calm  <- (abs(pl$bias) < BIAS_MATERIAL) & pl$coverage >= 0.90 & pl$coverage <= 0.98
verdict <- if (any(fires)) "CONFIRMED MATERIAL" else if (all(calm)) "REFUTED" else "BORDERLINE"

## The differential covariance product at which bias crosses the threshold, from
## the identity: log((1 + x1) / (1 + x0)) = 0.05.
u$x0 <- u$rho0 * u$cv_t * vapply(seq_len(nrow(u)), function(i) cell_laws(u[i, ])$C$cv_lam, 0)
u$x1 <- (u$rho0 + u$drho) * u$cv_t * vapply(seq_len(nrow(u)), function(i) cell_laws(u[i, ])$T$cv_lam, 0)
u$dx <- u$x1 - u$x0

md <- c("# Decision", "", sprintf("**Registered rule (protocol.md section 5): %s.**", verdict), "",
  sprintf("Plausible cells with differential >= 0.2: %d. Firing: %d (%.0f%%). Largest bias %.4f, lowest coverage %.3f.",
          nrow(pl), sum(fires), 100 * mean(fires), max(pl$bias), min(pl$coverage)), "",
  sprintf("Identity check: slope %.3f (SE %.3f), intercept %.4f, over %d cells; largest |observed - predicted| is %.1f MCSE.",
          id$slope, id$slope_se, id$intercept, id$n_cells, id$max_abs_resid_over_mcse), "",
  "| control | passed | cells |", "|---|:--:|---:|",
  sprintf("| %s | %s | %d |", ctl$control, ifelse(ctl$passed, "yes", "**no**"), ctl$cells), "")
writeLines(md, "results/decision.md")
cat(md, sep = "\n")
