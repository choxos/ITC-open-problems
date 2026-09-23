## Bias and coverage of the combination's RMST difference; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { z <- z[is.finite(z$est), ]; e <- z$est - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n), coverage = mean(abs(e) <= 1.96 * z$se),
             se_ratio = mean(z$se) / stats::sd(z$est), rmse = sqrt(mean(e^2))) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pc <- summ[summ$profile == "different" & summ$fa != summ$fb, ]; c0 <- pc[pc$method == "constant", ]; p0 <- pc[pc$method == "piecewise", ]
verdict <- if (c0$coverage < 0.90 && p0$coverage >= 0.93) "EXTENSION ESTABLISHED" else if (all(summ$coverage[summ$method == "constant"] >= 0.93)) "REFUTING SENTENCE HOLDS" else "NEITHER MODEL NOMINAL WHERE IT MATTERS"
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Different profiles, follow-up 1.5 and 3 years: constant bias %s, coverage %s; piecewise bias %s, coverage %s.",
          verdict, f3(c0$bias), f3(c0$coverage), f3(p0$bias), f3(p0$coverage)), "",
  "| profiles | follow-up A | follow-up B | method | truth | bias | MCSE | coverage | SE ratio | RMSE |", "|---|---:|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.2f | %.3f |", summ$profile, summ$fa, summ$fb, summ$method, summ$truth, summ$bias, summ$mcse, summ$coverage, summ$se_ratio, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
