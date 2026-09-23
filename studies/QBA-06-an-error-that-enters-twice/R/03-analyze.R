## Bias and RMSE of each method by assay scenario; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
ms <- c("maic_naive", "maic_prev_only", "maic_corrected", "stc_naive", "stc_outcome_only", "stc_corrected")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(ms, function(m) { e <- z[[m]] - z$truth; e <- e[is.finite(e)]
  data.frame(cell = z$cell[1], method = m, bias = mean(e), mcse = stats::sd(e) / sqrt(length(e)), rmse = sqrt(mean(e^2)), n = length(e)) }))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
b <- function(m) summ[summ$method == m, ]
oo <- b("stc_outcome_only"); sc <- b("stc_corrected"); mn <- b("maic_naive"); mc <- b("maic_corrected")
fails <- any(abs(oo$bias) > 3 * oo$mcse & abs(oo$bias) > 0.03)
same <- mn[mn$assay %in% c("same_good", "same_poor"), ]
md <- c("# Decision", "",
  sprintf("**Refuting sentence (correcting the outcome model is sufficient): %s.** Outcome-only correction: bias %.3f to %.3f; full correction %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(oo$bias), max(oo$bias), min(sc$bias), max(sc$bias)), "",
  sprintf("MAIC on the misclassified covariate with identical assays in both studies: bias %s (beyond 3 MCSE in %d of %d cells).",
          paste(sprintf("%.3f", same$bias), collapse = ", "), sum(abs(same$bias) > 3 * same$mcse), nrow(same)), "",
  sprintf("MAIC with latent-prevalence weights: bias %.3f to %.3f.", min(mc$bias), max(mc$bias)), "",
  "| assay | modification | method | bias | MCSE | RMSE |", "|---|---:|---|---:|---:|---:|",
  sprintf("| %s | %.1f | %s | %.3f | %.3f | %.3f |", summ$assay, summ$b, summ$method, summ$bias, summ$mcse, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:7], sep = "\n")
