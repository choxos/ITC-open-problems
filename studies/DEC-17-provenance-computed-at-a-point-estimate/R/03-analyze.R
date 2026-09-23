## Leading-contributor changes and share movement over the tau interval; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1],
  lead_cmp_changes = mean(z$lead_cmp_changes), lead_study_changes = mean(z$lead_study_changes),
  mean_max_move = mean(z$max_study_move), p90_max_move = stats::quantile(z$max_study_move, 0.9),
  mean_hat_vs_true = mean(z$hat_vs_true), lead_hat_wrong = mean(!z$lead_hat_is_true),
  tau_hat_zero = mean(z$tau_hat == 0), ci_hi_at_cap = mean(z$ci_hi >= 1))))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pr <- summ[summ$net == "loop" & summ$K == 4 & summ$spread == "5:1", ]
verdict <- if (any(pr$lead_cmp_changes >= 0.10)) "CONFIRMED" else "REFUTED"
eq_ok <- all(d$max_study_move[d$spread == "equal"] < 1e-10)
pos <- pr[pr$tau == 0.25, ]
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Loop network, 4 studies, 5:1 variance spread: leading contributing comparison changes across the profile-likelihood tau interval in %s of networks (true tau 0, 0.1, 0.25).",
          verdict, paste(sprintf("%.3f", pr$lead_cmp_changes), collapse = ", ")), "",
  sprintf("Second null control (equal within-study variances: shares invariant to tau): %s.", eq_ok), "",
  sprintf("Positive control (loop, 4 studies, 5:1, tau 0.25: mean largest share movement at least 0.05): %s (%.3f).", pos$mean_max_move >= 0.05, pos$mean_max_move), "",
  "| network | studies | spread | true tau | leading comparison changes | leading study changes | mean largest share movement | 90th percentile | share error at tau-hat vs true tau | leading study at tau-hat wrong | tau-hat zero | interval reaches cap |",
  "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %s | %.2f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$net, summ$K, summ$spread, summ$tau, summ$lead_cmp_changes, summ$lead_study_changes,
          summ$mean_max_move, summ$p90_max_move, summ$mean_hat_vs_true, summ$lead_hat_wrong, summ$tau_hat_zero, summ$ci_hi_at_cap), "")
writeLines(md, "results/decision.md"); cat(md[1:7], sep = "\n")
