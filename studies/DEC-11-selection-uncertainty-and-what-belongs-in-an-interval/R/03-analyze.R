## Coverage by selection rule and sample size; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$rule), drop = TRUE), function(z) { e <- z$est - z$truth; cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], rule = z$rule[1], n_rep = nrow(z), bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)),
             emp_sd = stats::sd(z$est), mean_se = mean(z$se), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / nrow(z)),
             mean_selected = mean(z$n_sel), all_true_selected = mean(z$hit)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
sg <- summ[summ$rule == "significance", ]
confirmed <- any(sg$coverage + 1.96 * sg$cov_mcse < 0.93)
bt <- summ[summ$rule == "significance_boot", ]
md <- c("# Decision", "",
  sprintf("**Refuting sentence (selection is so unstable that the naive interval is about right): %s.** Naive coverage after significance selection %s (n per arm %s).",
          if (confirmed) "FAILS" else "HOLDS", paste(sprintf("%.3f", sg$coverage), collapse = ", "), paste(sg$n, collapse = ", ")), "",
  "| n per arm | true modifiers | rule | coverage | bias | mean SE / empirical SD | mean selected | all true selected |",
  "|---:|---:|---|---:|---:|---:|---:|---:|",
  sprintf("| %d | %d | %s | %.3f | %.3f | %.2f | %.2f | %.2f |", summ$n, summ$n_mod, summ$rule, summ$coverage, summ$bias,
          summ$mean_se / summ$emp_sd, summ$mean_selected, summ$all_true_selected), "",
  sprintf("Whole-procedure bootstrap after significance selection: coverage %.3f to %.3f.", min(bt$coverage), max(bt$coverage)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
