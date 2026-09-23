## Coverage with and without propagation, the privacy-sampling crossover, and the
## released-moment trade-off. Writes results/summary.csv and results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
## Moments made infeasible by the noise (outside the source's hull, or second
## moments below squared means) leave no estimate; performance is over the
## feasible replicates and the infeasible share is reported beside it.
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  inf <- mean(!(z$ok == 1 & is.finite(z$est) & is.finite(z$se))); z <- z[z$ok == 1 & is.finite(z$est) & is.finite(z$se), ]
  e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], infeasible = inf, n_ok = n, bias = mean(e),
             mcse = stats::sd(e) / sqrt(n), rmse = sqrt(mean(e^2)), coverage = cv,
             cov_mcse = sqrt(cv * (1 - cv) / n), width = mean(2 * 1.96 * z$se))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
ig <- summ[summ$method == "private_ignored" & is.finite(summ$eps), ]
pr <- summ[summ$method == "private_propagated" & is.finite(summ$eps), ]
np <- summ[summ$method == "non_private", ]
refute <- all(ig$coverage[ig$eps >= 1 & ig$n_t >= 150] >= 0.93)
rm_ <- merge(summ[summ$method == "private_propagated" & summ$release == "means", c("n_t", "eps", "em", "rmse")],
             summ[summ$method == "private_propagated" & summ$release == "means_sds", c("n_t", "eps", "em", "rmse")],
             by = c("n_t", "eps", "em"), suffixes = c("_means", "_sds"))
md <- c("# Decision", "",
  sprintf("**Refuting sentence (noise negligible at usable budgets, epsilon >= 1 and target n >= 150): %s.**",
          if (refute) "HOLDS" else "FAILS"), "",
  "| target n | epsilon | released | modification | infeasible | coverage ignored | coverage propagated | coverage non-private |",
  "|---:|---:|---|---|---:|---:|---:|---:|",
  sprintf("| %d | %s | %s | %s | %.3f | %.3f | %.3f | %.3f |", ig$n_t, ig$eps, ig$release, ig$em, ig$infeasible, ig$coverage,
          pr$coverage[match(ig$cell, pr$cell)], np$coverage[match(ig$cell, np$cell)]), "",
  "RMSE, propagated, means only against means and second moments:", "",
  "| target n | epsilon | modification | means | means and second moments |", "|---:|---:|---|---:|---:|",
  sprintf("| %d | %s | %s | %.3f | %.3f |", rm_$n_t, rm_$eps, rm_$em, rm_$rmse_means, rm_$rmse_sds), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
