## Performance, mechanism checks, controls, decision.
## Writes results/summary.csv and results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- d[!is.na(d$method), ]
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  e <- z$est - z$truth; n <- nrow(z)
  cov <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], n = n, bias = mean(e),
             mcse = stats::sd(e) / sqrt(n), emp_se = stats::sd(z$est), mod_se = mean(z$se),
             rmse = sqrt(mean(e^2)), coverage = cov, cov_mcse = sqrt(cov * (1 - cov) / n),
             ess_A = mean(z$ess_A), ess_C = mean(z$ess_C), u_diff = mean(z$u_diff))
}))
summ <- merge(summ, g, by = "cell")
pr <- t(vapply(seq_len(nrow(summ)), function(i) predicted(summ[i, ]), numeric(2)))
summ$predicted <- ifelse(summ$method == "separate", pr[, "separate"],
                   ifelse(summ$method %in% c("pooled", "two_stage"), pr[, "pooled"], NA))
write.csv(summ, "results/summary.csv", row.names = FALSE)

imp <- summ[summ$kappa != "random", ]
slope <- function(m) {
  z <- imp[imp$method == m, ]
  f <- stats::lm(bias ~ predicted, data = z, weights = 1 / z$mcse^2)
  c(coef(f)[["predicted"]], sqrt(diag(vcov(f)))[["predicted"]])
}
sp <- slope("pooled"); ss <- slope("separate")

sep <- imp[imp$method == "separate", ]
shared <- sep[sep$corr %in% c("shared0", "shared05") & sep$gu > 0 & sep$kappa != "0", ]
refuted <- all(abs(shared$bias) <= 3 * shared$mcse)
c_null <- all(abs(imp$bias[imp$kappa == "0" & imp$method %in% c("pooled", "separate")]) <=
              3 * imp$mcse[imp$kappa == "0" & imp$method %in% c("pooled", "separate")])
z0 <- sep[sep$gu == 0, ]; c_null2 <- all(abs(z0$bias) <= 3 * z0$mcse)
pz <- sep[sep$kappa == "0.2" & sep$gu == 0.5 & sep$corr %in% c("S05_T0", "S0_T05"), ]
c_pos <- all(abs(pz$bias) > 3 * pz$mcse & sign(pz$bias) == sign(pz$predicted))

rnd <- summ[summ$kappa == "random", ]
rr <- merge(rnd[rnd$method == "separate", c("cell", "rmse")], rnd[rnd$method == "pooled", c("cell", "rmse")],
            by = "cell", suffixes = c("_sep", "_pool"))
bw <- merge(imp[imp$method == "separate", c("cell", "bias")], imp[imp$method == "pooled", c("cell", "bias")],
            by = "cell", suffixes = c("_sep", "_pool"))
dg <- stats::cor(sep$u_diff, sep$bias)

md <- c("# Decision", "",
  sprintf("**DESIGN.md's product claim: %s.** Shared-correlation cells with gu > 0 and imposed imbalance: %d; arm-separate bias within 3 MCSE of zero in all: %s (largest |bias| %.4f).",
          if (refuted) "REFUTED" else "NOT REFUTED", nrow(shared), refuted, max(abs(shared$bias))), "",
  sprintf("Mechanism slopes (bias on predicted): pooled %.3f (SE %.3f); arm-separate %.3f (SE %.3f).", sp[1], sp[2], ss[1], ss[2]), "",
  sprintf("Imposed-imbalance cells where arm-separate has smaller |bias| than pooled: %d of %d.",
          sum(abs(bw$bias_sep) < abs(bw$bias_pool)), nrow(bw)), "",
  sprintf("Random-imbalance cells: RMSE ratio arm-separate / pooled, median %.3f, range %.3f to %.3f.",
          stats::median(rr$rmse_sep / rr$rmse_pool), min(rr$rmse_sep / rr$rmse_pool), max(rr$rmse_sep / rr$rmse_pool)), "",
  sprintf("Candidate diagnostic (weighted U difference) against arm-separate bias, imposed cells: correlation %.3f.", dg), "",
  sprintf("Controls: null (kappa 0) %s; second null (gu 0) %s; positive %s.", c_null, c_null2, c_pos), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
