## Winner distribution against bridge error; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], bridge_bias = mean(z$bridge) - D_CA,
  mcse = stats::sd(z$bridge) / sqrt(nrow(z)), t(setNames(tabulate(z$winner, 3) / nrow(z), names(fitters))))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
pv <- sapply(split(d, d$gz), function(z) suppressWarnings(stats::chisq.test(table(z$eta, z$winner))$p.value))
sens <- all(pv > 0.01)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (predictive criteria rank models correctly with respect to the bridge): %s.** The leave-one-out winner's distribution did not depend on the bridge error (chi-square p = %s by covariate-effect level), while the cross-gap bias ranged from %.3f to %.3f.",
          if (sens) "FAILS" else "HOLDS", paste(sprintf("%.2f", pv), collapse = ", "), min(summ$bridge_bias), max(summ$bridge_bias)), "",
  "| nuisance | covariate slope | cross-gap bias (every candidate) | common wins | random wins | meta-regression wins |", "|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %.3f | %.3f | %.3f | %.3f |", summ$eta, summ$gz, summ$bridge_bias, summ$common, summ$random, summ$metareg), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
