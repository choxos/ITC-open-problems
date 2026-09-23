## Rank agreement of the diagonal influence with refitted references; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], n = nrow(z),
  rho_importance = mean(z$rho_importance, na.rm = TRUE), rho_importance_lt09 = mean(z$rho_importance < 0.9, na.rm = TRUE),
  rho_change = mean(z$rho_change, na.rm = TRUE), top_disagree = mean(!z$top_agree), zero_studies = sum(z$n_zero), zero_but_moves = sum(z$zero_but_moves),
  exact_diff = if (all(is.na(z$exact_diff))) NA else max(z$exact_diff, na.rm = TRUE), tau_hat = mean(z$tau_hat))))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
unfit <- any(summ$rho_importance < 0.9 | summ$top_disagree > 0.10)
pr <- summ[summ$multi == "three-arm" & summ$tau == 0.3, ]
md <- c("# Decision", "", sprintf("**Registered rule: %s.** Primary cells (three-arm studies, tau 0.3): mean Spearman with variance importance %s; top study misidentified in %s.",
          if (unfit) "NOT FIT FOR RANKING" else "ADEQUATE FOR RANKING", paste(sprintf("%.2f", pr$rho_importance), collapse = ", "), paste(sprintf("%.0f%%", 100 * pr$top_disagree), collapse = ", ")), "",
  sprintf("P1 exactness (two-arm networks, diagonal influence against the correct model's hat row at the same tau-hat): largest difference %.1e.", max(summ$exact_diff, na.rm = TRUE)), "",
  "| studies | design | true tau | mean Spearman vs importance | share below 0.9 | mean Spearman vs estimate change | top study disagrees | zero-influence studies | of which the estimate moves on removal |",
  "|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %.1f | %.2f | %.2f | %.2f | %.2f | %d | %d |", summ$K, summ$multi, summ$tau, summ$rho_importance, summ$rho_importance_lt09, summ$rho_change, summ$top_disagree, summ$zero_studies, summ$zero_but_moves), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
