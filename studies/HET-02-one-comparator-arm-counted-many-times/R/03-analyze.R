## Coverage and SE of the correct and naive analyses; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], sd_right = stats::sd(z$right), se_right = mean(z$se_right),
  cov_right = mean(abs(z$right - D_AC) <= 1.96 * z$se_right), sd_naive = stats::sd(z$naive), se_naive = mean(z$se_naive),
  cov_naive = mean(abs(z$naive - D_AC) <= 1.96 * z$se_naive), sign_disagree = mean(sign(z$right) != sign(z$naive)), mean_abs_diff = mean(abs(z$right - z$naive)))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
m2 <- summ[summ$M >= 2, ]; fails <- any(m2$cov_naive < 0.90)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the shared-arm correlation changes precision slightly and conclusions not at all): %s.** Naive coverage with two or more pseudo-contrasts %.3f to %.3f; correct %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(m2$cov_naive), max(m2$cov_naive), min(summ$cov_right), max(summ$cov_right)), "",
  "| single-arm studies | C-arm size | SD, correct | SE, correct | coverage, correct | SD, naive | SE, naive | coverage, naive | sign disagreement | mean absolute difference |",
  "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %d | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$M, summ$n_c, summ$sd_right, summ$se_right, summ$cov_right, summ$sd_naive,
          summ$se_naive, summ$cov_naive, summ$sign_disagree, summ$mean_abs_diff), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
