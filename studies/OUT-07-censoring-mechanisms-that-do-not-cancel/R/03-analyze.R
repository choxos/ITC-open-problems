## Bias and coverage of the contrast, cancellation on the diagonal, sensitivity; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { e <- z$naive - z$truth; ei <- z$ipcw - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(n), coverage = mean(abs(e) <= 1.96 * z$naive_se, na.rm = TRUE),
             bias_ipcw = mean(ei), mcse_ipcw = stats::sd(ei) / sqrt(n), wrong_sign = mean(sign(z$naive) != sign(z$truth)),
             fragile = mean(z$fragile), delta_true_med = stats::median(z$delta_true, na.rm = TRUE),
             delta_true_in_range = mean(z$delta_true >= 0.5 & z$delta_true <= 2, na.rm = TRUE)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
un <- summ[summ$design == "unanchored", ]; off <- un[un$alpha_s != un$alpha_t, ]; diag <- un[un$alpha_s == un$alpha_t, ]
fails <- any(abs(off$bias) > 3 * off$mcse & abs(off$bias) > 0.25)
an <- summ[summ$design == "anchored", ]
md <- c("# Decision", "",
  sprintf("**Refuting sentence (informative censoring biases both sides alike, so the contrast is protected): %s.** Unanchored, mechanisms differing: bias %.3f to %.3f months (truth %.3f). Mechanisms equal: bias %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(off$bias), max(off$bias), un$truth[1], min(diag$bias), max(diag$bias)), "",
  sprintf("Anchored: bias %.3f to %.3f months (truth %.3f).", min(an$bias), max(an$bias), an$truth[1]), "",
  sprintf("Source-side IPCW with a baseline proxy: largest |bias| %.3f against %.3f naive.", max(abs(summ$bias_ipcw)), max(abs(summ$bias))), "",
  "| design | alpha source | alpha comparator | prevalence | bias | coverage | wrong sign | bias, source IPCW | fragile over delta 0.5 to 2 | median delta reproducing truth | that delta in [0.5, 2] |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %d | %.1f | %.3f | %.3f | %.3f | %.3f | %.2f | %.2f | %.2f |", summ$design, summ$alpha_s, summ$alpha_t, summ$prev, summ$bias, summ$coverage,
          summ$wrong_sign, summ$bias_ipcw, summ$fragile, summ$delta_true_med, summ$delta_true_in_range), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
