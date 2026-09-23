## The identity, the 2 x 2 bias table, interval coverage; decision.
source("R/00-model.R")
g <- build_grid()
fs <- list.files("results/run", pattern = "^cell", full.names = TRUE)
d <- merge(do.call(rbind, lapply(fs, readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { n <- nrow(z)
  data.frame(cell = z$cell[1], truth = z$truth[1], n = n, bias_maic = mean(z$itc_maic - z$truth), mcse_maic = stats::sd(z$itc_maic) / sqrt(n),
             bias_dr = mean(z$itc_dr - z$truth), max_abs_identity = max(abs(z$dr_minus_maic)), bias_aug = mean(z$est_aug - z$truth), mcse_aug = stats::sd(z$est_aug) / sqrt(n),
             emp_sd_dr = stats::sd(z$itc_dr), pkg_se = mean(z$se_pkg), pkg_cov = mean(z$lo_pkg <= z$truth & z$truth <= z$hi_pkg),
             aug_cov = mean(abs(z$est_aug - z$truth) <= 1.96 * z$se_aug), ess = mean(z$ess)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
bf <- list.files("results/run", pattern = "^boot", full.names = TRUE)
bt <- if (length(bf)) do.call(rbind, lapply(bf, function(f) { z <- readRDS(f); data.frame(cell = z$cell[1], n = nrow(z), coverage = mean(z$lo <= z$truth & z$truth <= z$hi, na.rm = TRUE)) })) else NULL
if (!is.null(bt)) write.csv(merge(g, bt, by = "cell"), "results/bootstrap.csv", row.names = FALSE)
off <- summ[summ$weights == "wrong" & summ$outcome == "right", ]
identity <- max(summ$max_abs_identity) < 1e-10
dr_fail <- any(abs(off$bias_dr) > 3 * off$mcse_maic & abs(off$bias_aug) <= 3 * off$mcse_aug)
ci_fail <- any(summ$pkg_cov < 0.90)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the implementation is correct and its behavior matches the augmented-weighting literature): %s.**", if (identity || dr_fail || ci_fail) "FAILS" else "HOLDS"), "",
  sprintf("1. drMAIC's doubly robust estimate equals its MAIC estimate in every replicate (largest absolute difference %.1e): %s.", max(summ$max_abs_identity), identity), "",
  sprintf("2. Weights wrong, outcome model right: drMAIC DR bias %s; correctly augmented estimator %s.",
          paste(sprintf("%.3f (MCSE %.3f)", off$bias_dr, off$mcse_maic), collapse = ", "), paste(sprintf("%.3f (MCSE %.3f)", off$bias_aug, off$mcse_aug), collapse = ", ")), "",
  sprintf("3. drMAIC analytic interval: mean SE %.3f to %.3f against an empirical SD of %.3f to %.3f; coverage %.3f to %.3f.",
          min(summ$pkg_se), max(summ$pkg_se), min(summ$emp_sd_dr), max(summ$emp_sd_dr), min(summ$pkg_cov), max(summ$pkg_cov)), "",
  if (!is.null(bt)) sprintf("4. drMAIC percentile bootstrap interval (%d resamples): coverage %s.", R_PKG, paste(sprintf("%.3f (n = %d)", bt$coverage, bt$n), collapse = ", ")) else "", "",
  "| weights | outcome model | target x1 mean | truth | bias MAIC | bias drMAIC DR | bias correct augmentation | drMAIC SE | empirical SD | drMAIC coverage | augmentation coverage | ESS |",
  "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %.1f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.0f |", summ$weights, summ$outcome, summ$m1_t, summ$truth, summ$bias_maic, summ$bias_dr,
          summ$bias_aug, summ$pkg_se, summ$emp_sd_dr, summ$pkg_cov, summ$aug_cov, summ$ess), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
