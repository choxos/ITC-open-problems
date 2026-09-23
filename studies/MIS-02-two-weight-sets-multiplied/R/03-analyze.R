## Bias, SE ratio, coverage per method and cell; weight ESS; controls; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - z$truth; n <- nrow(z)
  cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], n_rep = n, truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             emp_sd = stats::sd(z$est), mean_se = mean(z$se), se_ratio = mean(z$se) / stats::sd(z$est), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n),
             ess_part = mean(z$ess_part), ess_prod = mean(z$ess_prod), cor_w = mean(z$cor_w, na.rm = TRUE), cens_share = mean(z$cens_share),
             boot_fail = mean(z$boot_fail)) }))
summ <- merge(g, summ, by = "cell")
## ESS of the censoring factor among uncensored patients is not stored per replicate; the
## product's ESS is compared with the participation factor's.
write.csv(summ, "results/summary.csv", row.names = FALSE)
pc <- summ[summ$cens == 0.6 & summ$mu_t == 1.2 & summ$kappa > 0 & summ$ctrl == "none", ]
tb <- pc[pc$method == "tada", ]
verdict <- if (tb$coverage >= 0.93 && tb$coverage <= 0.97 && tb$se_ratio >= 0.9 && tb$se_ratio <= 1.1) "HOLDS: bootstrap TADA calibrated in the hardest cell" else
  if (abs(tb$bias) > 3 * tb$mcse || (tb$se_ratio >= 0.9 && tb$se_ratio <= 1.1)) "FAILS BY BIAS OR DEGENERACY: the variance estimator is not the binding problem" else
  "FAILS BY VARIANCE: the bootstrap SE is off"
nc <- summ[summ$ctrl == "no_censoring", ]; ic <- summ[summ$ctrl == "independent" & summ$method == "part_km", ]
null_ok <- abs(nc$bias[nc$method == "tada"] - nc$bias[nc$method == "part_km"]) < 1e-8
ind_ok <- abs(ic$bias) <= 3 * ic$mcse
main <- summ[summ$ctrl == "none" & summ$method == "tada", ]
pos <- main[main$cens == 0.6 & main$mu_t == 1.2 & main$kappa > 0, ]
md <- c("# Decision", "", sprintf("**Registered primary: %s.** TADA with bootstrap SE at 60%% censoring before the horizon, poor overlap, positively correlated weights: bias %.3f (MCSE %.3f), SE ratio %.2f, coverage %.3f (MCSE %.3f).",
          verdict, tb$bias, tb$mcse, tb$se_ratio, tb$coverage, tb$cov_mcse), "",
  sprintf("Null control (no censoring: TADA equals the participation-weighted Kaplan-Meier): %s.", null_ok), "",
  sprintf("Second null control (censoring independent of covariates: participation-weighted Kaplan-Meier unbiased within 3 MCSE): %s (bias %.3f, MCSE %.3f).", ind_ok, ic$bias, ic$mcse), "",
  sprintf("Positive control (product ESS below 0.8 times the participation ESS in the hardest positively correlated cell): %s (%.0f against %.0f).", pos$ess_prod < 0.8 * pos$ess_part, pos$ess_prod, pos$ess_part), "",
  sprintf("Replicates dropped per cell: %s.", paste(N_SIM - tapply(summ$n_rep, summ$cell, max), collapse = ", ")), "",
  "| censored before 24 | target x1 mean | kappa | control | method | bias | MCSE | emp SD | SE ratio | coverage | ESS participation | ESS product | cor(w) |",
  "|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.1f | %.1f | %s | %s | %.3f | %.3f | %.3f | %.2f | %.3f | %.0f | %.0f | %.2f |", summ$cens, summ$mu_t, summ$kappa, summ$ctrl, summ$method,
          summ$bias, summ$mcse, summ$emp_sd, summ$se_ratio, summ$coverage, summ$ess_part, summ$ess_prod, summ$cor_w), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
