## Feasibility, ESS and precision of the MAIC route against STC along the sweep; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$target <- mapply(target_logodds, d$p, d$rho)
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$p), drop = TRUE), function(z) { ok <- is.finite(z$maic)
  data.frame(cell = z$cell[1], rho = z$rho[1], p = z$p[1], target = z$target[1], feasible = mean(z$feasible), ess = mean(z$ess, na.rm = TRUE),
             bias_stc = mean(z$stc - z$target), bias_maic = mean(z$maic[ok] - z$target[ok]), se_stc = mean(z$se_stc), se_maic = mean(z$se_maic[ok]),
             emp_sd_stc = stats::sd(z$stc), emp_sd_maic = stats::sd(z$maic[ok]),
             cov_stc = mean(abs(z$stc - z$target) <= 1.96 * z$se_stc), cov_maic = mean(abs(z$maic[ok] - z$target[ok]) <= 1.96 * z$se_maic[ok])) }))
write.csv(summ, "results/summary.csv", row.names = FALSE)
holds <- all(summ$feasible >= 0.95) && all(summ$se_maic <= 1.25 * summ$se_stc)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the MAIC extension is feasible and its precision loss comparable to STC's): %s.** Feasible share %.3f to %.3f; ESS %.0f to %.0f of %d; MAIC SE / STC SE %.2f to %.2f.",
          if (holds) "HOLDS" else "FAILS", min(summ$feasible), max(summ$feasible), min(summ$ess), max(summ$ess), N, min(summ$se_maic / summ$se_stc), max(summ$se_maic / summ$se_stc)), "",
  "| rho | assumed prevalence | target | feasible | ESS | bias STC | bias MAIC | SE STC | SE MAIC | coverage STC | coverage MAIC |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %.3f | %.3f | %.0f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$rho, summ$p, summ$target, summ$feasible, summ$ess, summ$bias_stc, summ$bias_maic,
          summ$se_stc, summ$se_maic, summ$cov_stc, summ$cov_maic), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
