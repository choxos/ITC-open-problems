## Bias and coverage of the bridge with and without design adjustment; decision.
source("R/00-model.R")
g <- build_grid(); tr <- truth()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { a <- is.finite(z$adj)
  data.frame(cell = z$cell[1], bias_exch = mean(z$exch) - tr, mcse_exch = stats::sd(z$exch) / sqrt(nrow(z)), cov_exch = mean(abs(z$exch - tr) <= 1.96 * z$se_exch),
             adj_possible = mean(a), bias_adj = if (any(a)) mean(z$adj[a]) - tr else NA, cov_adj = if (any(a)) mean(abs(z$adj[a] - tr) <= 1.96 * z$se_adj[a]) else NA) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
no_ov <- summ[summ$overlap == 0 & summ$eta > 0, ]; dr <- summ[summ$drift > 0 & summ$overlap > 0, ]
fails <- any(abs(no_ov$bias_exch) > 0.1) || any(abs(dr$bias_adj) > 0.1, na.rm = TRUE)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (design covariates separate the baseline's two roles, so the bridge is recovered): %s.** Without overlap of the design covariate across the gap, adjustment was possible in %.0f%% of analyses and the bridge carried the nuisance (bias %.3f to %.3f). With overlap and prognostic drift, the adjusted bridge was biased %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", 100 * max(no_ov$adj_possible), min(no_ov$bias_exch), max(no_ov$bias_exch), min(dr$bias_adj), max(dr$bias_adj)), "",
  "| nuisance | overlap | drift | trials per subnetwork | bias, exchangeable | coverage | adjustment possible | bias, adjusted | coverage |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.2f | %.1f | %d | %.3f | %.3f | %.2f | %s | %s |", summ$eta, summ$overlap, summ$drift, summ$K, summ$bias_exch, summ$cov_exch, summ$adj_possible,
          ifelse(is.na(summ$bias_adj), "-", sprintf("%.3f", summ$bias_adj)), ifelse(is.na(summ$cov_adj), "-", sprintf("%.3f", summ$cov_adj))), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
