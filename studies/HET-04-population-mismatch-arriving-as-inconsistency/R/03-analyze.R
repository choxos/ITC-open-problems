## Flag rates of the unadjusted and adjusted splits; false positives and masking; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], w = mean(z$w), mismatch = z$beta[1] * z$gap[1],
  flag_unadj = mean(z$p_unadj < ALPHA), iota_adj = mean(z$iota_adj, na.rm = TRUE), se_adj = mean(z$se_adj, na.rm = TRUE),
  flag_adj = mean(z$p_adj < ALPHA, na.rm = TRUE))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
fp <- summ[summ$iota == 0 & summ$beta > 0 & summ$gap > 0, ]
mask <- summ[abs(summ$iota + summ$beta * summ$gap) < 1e-9 & summ$iota != 0, ]
fails <- any(fp$flag_unadj > 0.20)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (population differences between the study sets are small enough that the unadjusted split is approximately valid): %s.** With no inconsistency, the unadjusted split flagged %.3f to %.3f of analyses where populations differed; the adjusted split %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(fp$flag_unadj), max(fp$flag_unadj), min(fp$flag_adj), max(fp$flag_adj)), "",
  sprintf("Exact masking (inconsistency cancelled by the mismatch): unadjusted flag %s; adjusted %s.",
          paste(sprintf("%.3f", mask$flag_unadj), collapse = ", "), paste(sprintf("%.3f", mask$flag_adj), collapse = ", ")), "",
  "| gap | beta | iota | studies | mismatch | mean w | unadjusted flag | adjusted estimate | adjusted SE | adjusted flag |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %+.1f | %d | %.2f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$gap, summ$beta, summ$iota, summ$M, summ$mismatch, summ$w,
          summ$flag_unadj, summ$iota_adj, summ$se_adj, summ$flag_adj), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
