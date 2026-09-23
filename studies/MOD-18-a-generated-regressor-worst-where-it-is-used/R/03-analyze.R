## Bias, plug-in and propagated coverage and the widening ratio by percentile; decision.
source("R/00-model.R")
g <- build_grid(); tr <- truth()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(1:3, function(j) {
  e <- z[[paste0("est", j)]] - tr[j]; sp <- z[[paste0("se_plug", j)]]; sq <- z[[paste0("se_prop", j)]]
  data.frame(cell = z$cell[1], percentile = Q[j], truth = tr[j], bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), emp_sd = stats::sd(e),
             cov_plug = mean(abs(e) <= 1.96 * sp), cov_prop = mean(abs(e) <= 1.96 * sq), mean_se_plug = mean(sp), widening = mean(sq / sp)) }))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
big <- summ[summ$n_p >= 1000, ]
holds <- all(big$widening <= 1.05) && all(summ$cov_plug >= 0.93)
tails <- aggregate(widening ~ n_p + drift + I(percentile == 0.5), data = summ, FUN = mean)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the plug-in interval is adequate): %s.** Widening ratio (propagated over plug-in SE) %.3f to %.3f with cohorts of at least 1000, %.3f to %.3f with 300; plug-in coverage %.3f to %.3f.",
          if (holds) "HOLDS" else "FAILS", min(big$widening), max(big$widening), min(summ$widening[summ$n_p == 300]), max(summ$widening[summ$n_p == 300]),
          min(summ$cov_plug), max(summ$cov_plug)), "",
  "| cohort | drift | percentile | truth | bias | empirical SD | plug-in SE | plug-in coverage | propagated coverage | widening |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %.1f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$n_p, summ$drift, summ$percentile, summ$truth, summ$bias, summ$emp_sd,
          summ$mean_se_plug, summ$cov_plug, summ$cov_prop, summ$widening), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
