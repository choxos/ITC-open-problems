## Bias, coverage and RMSE of the expected-utility difference; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method, d$utility), drop = TRUE), function(z) { e <- z$est - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], method = z$method[1], utility = z$utility[1], truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             rmse = sqrt(mean(e^2)), coverage = mean(abs(e) <= 1.96 * z$se), se_ratio = mean(z$se) / stats::sd(z$est), n = n) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
po <- summ[summ$method == "po", ]
b <- function(v, u) po$bias[po$violation == v & po$utility == u]
al <- abs(c(b("bottom", "bottom_heavy"), b("top", "top_heavy"))); mis <- abs(c(b("bottom", "top_heavy"), b("top", "bottom_heavy")))
confirmed <- all(al >= 2 * mis & al >= 0.02)
nul <- po[po$violation == "po", ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Proportional-odds bias when the violation and the utility increments are at the same end: %s; at opposite ends: %s.",
          if (confirmed) "CONFIRMED" else "NOT CONFIRMED", paste(f3(c(b("bottom", "bottom_heavy"), b("top", "top_heavy"))), collapse = ", "), paste(f3(c(b("bottom", "top_heavy"), b("top", "bottom_heavy"))), collapse = ", ")), "",
  sprintf("Null control (proportional odds true: bias within 3 MCSE and coverage 0.93 to 0.97 for the proportional-odds fit): %s.", all(abs(nul$bias) <= 3 * nul$mcse & nul$coverage >= 0.93 & nul$coverage <= 0.97)), "",
  "| violation | utility | method | truth | bias | MCSE | RMSE | coverage | SE ratio |", "|---|---|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.2f |", summ$violation, summ$utility, summ$method, summ$truth, summ$bias, summ$mcse, summ$rmse, summ$coverage, summ$se_ratio), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
