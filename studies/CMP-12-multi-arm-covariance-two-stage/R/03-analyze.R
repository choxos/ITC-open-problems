## Coverage, width, covariance recovery, sign test, dropping; decision.
## Writes results/summary.csv, results/covariance.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid()
runs <- lapply(list.files("results/run", full.names = TRUE), readRDS)
d <- do.call(rbind, lapply(runs, `[[`, "r"))
raw <- do.call(rbind, lapply(runs, `[[`, "raw"))

summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method, d$contrast), drop = TRUE), function(z) {
  e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], contrast = z$contrast[1], bias = mean(e),
             mcse = stats::sd(e) / sqrt(n), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n),
             width = mean(2 * 1.96 * z$se), emp_sd = stats::sd(z$est))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)

## Covariance recovery: Monte Carlo covariance of (d_AB, d_AC) against the mean
## estimated covariance under each method, recomputed from the stored variances of
## the trial-alone contrasts: Var(BC) = Var(AB) + Var(AC) - 2 Cov.
cv <- do.call(rbind, lapply(split(raw, raw$cell), function(z) {
  mc <- stats::cov(z$AB, z$AC)
  ## bootstrap MCSE of the Monte Carlo covariance
  b <- replicate(200, { i <- sample.int(nrow(z), replace = TRUE); stats::cov(z$AB[i], z$AC[i]) })
  dz <- d[d$cell == z$cell[1] & grepl("_trial$", d$method), ]
  est_cov <- sapply(c("split_trial", "fixed_trial", "stacked_trial"), function(m) {
    w <- dz[dz$method == m, ]
    vab <- w$se[w$contrast == "AB"]^2; vac <- w$se[w$contrast == "AC"]^2; vbc <- w$se[w$contrast == "BC"]^2
    mean((vab + vac - vbc) / 2)
  })
  data.frame(cell = z$cell[1], cov_mc = mc, cov_mc_se = stats::sd(b), t(est_cov))
}))
cv <- merge(g, cv, by = "cell")
write.csv(cv, "results/covariance.csv", row.names = FALSE)

pc <- summ[summ$em == 0.6 & summ$shift == 0.8 & summ$contrast == "BC" & summ$method %in% c("split", "stacked", "split_trial", "stacked_trial"), ]
st <- summ[summ$method == "split_trial" & summ$contrast == "BC", ]
over <- sum(st$coverage - 3 * st$cov_mcse > 0.95); under <- sum(st$coverage + 3 * st$cov_mcse < 0.95)
dr <- merge(summ[summ$method == "drop" & summ$contrast == "AB", c("cell", "width")],
            summ[summ$method == "stacked" & summ$contrast == "AB", c("cell", "width")], by = "cell", suffixes = c("_drop", "_stacked"))
wr <- dr$width_drop / dr$width_stacked
term2 <- (cv$stacked_trial - cv$fixed_trial) / cv$cov_mc
md <- c("# Decision", "",
  "**Primary: coverage of d_BC at modification 0.6, shift 0.8.**", "",
  "| alignment | shared-arm ratio | method | coverage | MCSE |", "|---|---:|---|---:|---:|",
  sprintf("| %s | %.1f | %s | %.3f | %.3f |", pc$align, pc$nA_ratio, pc$method, pc$coverage, pc$cov_mcse), "",
  sprintf("**Sign test (DESIGN.md prediction 2): %s.** Split trial-alone d_BC coverage above 0.95 beyond 3 MCSE in %d cells, below in %d, of %d.",
          if (over > 0 && under > 0) "CONFIRMED" else "WITHDRAWN (one-sided)", over, under, nrow(st)), "",
  sprintf("Covariance recovery (estimated / Monte Carlo): stacked %.2f to %.2f; weights-fixed %.2f to %.2f. Shared-weighting term (stacked minus fixed) as a share of the Monte Carlo covariance: %.3f to %.3f.",
          min(cv$stacked_trial / cv$cov_mc), max(cv$stacked_trial / cv$cov_mc),
          min(cv$fixed_trial / cv$cov_mc), max(cv$fixed_trial / cv$cov_mc), min(term2), max(term2)), "",
  sprintf("Dropping the trial: network d_AB interval width over stacked, %.2f to %.2f (median %.2f); above the 1.10 materiality in %d of %d cells.",
          min(wr), max(wr), stats::median(wr), sum(wr > 1.10), length(wr)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
