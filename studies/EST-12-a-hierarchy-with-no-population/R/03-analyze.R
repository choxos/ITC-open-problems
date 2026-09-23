## Rank movement across targets against sampling movement; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], across_targets = mean(z$across_targets),
  mcse_t = stats::sd(z$across_targets) / sqrt(nrow(z)), true_across = z$true_across_targets[1], across_replicates = mean(z$across_replicates),
  mcse_r = stats::sd(z$across_replicates) / sqrt(nrow(z)), wrong_best_mid = mean(z$wrong_best_mid), wrong_best_edge = mean(z$wrong_best_edge))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
mv <- summ[summ$true_across > 0, ]; st <- summ[summ$true_across == 0, ]
fails <- all(mv$across_targets > mv$across_replicates + 3 * sqrt(mv$mcse_t^2 + mv$mcse_r^2))
md <- c("# Decision", "",
  sprintf("**Refuting sentence (rank movement across plausible targets is small relative to sampling movement): %s.** Where the true ranking changes across targets (%d cells), estimated movement across targets %.2f to %.2f places per treatment against %.2f to %.2f across replicates.",
          if (fails) "FAILS" else "HOLDS", nrow(mv), min(mv$across_targets), max(mv$across_targets), min(mv$across_replicates), max(mv$across_replicates)), "",
  sprintf("Where the true ranking does not change (%d cells), estimated movement across targets was %.2f to %.2f: target-specific hierarchies moved through the uncertainty in the estimated slopes.",
          nrow(st), min(st$across_targets), max(st$across_targets)), "",
  "| spread | spacing | trials | target width | across targets | true | across replicates | wrong best, middle target | wrong best, edge target |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.2f | %d | %.1f | %.2f | %.2f | %.2f | %.3f | %.3f |", summ$spread, summ$spacing, summ$M, summ$width, summ$across_targets, summ$true_across,
          summ$across_replicates, summ$wrong_best_mid, summ$wrong_best_edge), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
