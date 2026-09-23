## Control test size and power; bias and coverage of naive and calibrated contrasts; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { n <- nrow(z); en <- z$naive - z$truth; ec <- z$calibrated - z$truth
  data.frame(cell = z$cell[1], bias_naive = mean(en), bias_cal = mean(ec), mcse_cal = stats::sd(ec) / sqrt(n), rmse_naive = sqrt(mean(en^2)), rmse_cal = sqrt(mean(ec^2)),
             cov_naive = mean(abs(en) <= 1.96 * z$se_naive), cov_cal = mean(abs(ec) <= 1.96 * z$se_cal), control_flag = mean(abs(z$control / z$se_control) > 1.96)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
sh <- summ[summ$shift > 0, ]; bad <- sh[!(sh$g_n == G_Y & sh$beta == 0), ]
fails <- any(abs(bad$bias_cal) > 0.1 & abs(bad$bias_cal) > 3 * bad$mcse_cal)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (calibration transfers with its operating characteristics intact): %s.** With the control's prognostic dependence unequal to the primary's or with modification, calibrated bias %.3f to %.3f; with them equal and no modification %.3f.",
          if (fails) "FAILS" else "HOLDS", min(bad$bias_cal), max(bad$bias_cal), sh$bias_cal[sh$g_n == G_Y & sh$beta == 0]), "",
  sprintf("Control test flag rate without a population shift %.3f to %.3f; with a shift %.3f to %.3f.",
          min(summ$control_flag[summ$shift == 0]), max(summ$control_flag[summ$shift == 0]), min(sh$control_flag), max(sh$control_flag)), "",
  "| control prognostic strength | modification | shift | naive bias | calibrated bias | naive coverage | calibrated coverage | control flagged |", "|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.1f | %.1f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$g_n, summ$beta, summ$shift, summ$bias_naive, summ$bias_cal, summ$cov_naive, summ$cov_cal, summ$control_flag), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
