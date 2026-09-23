## Bias, SE ratio and coverage per method, surface and overlap; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n), emp_sd = stats::sd(z$est),
             se_ratio = mean(z$se) / stats::sd(z$est), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n), rmse = sqrt(mean(e^2))) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pc <- summ[summ$surface == "B" & summ$mu == 1.5, ]; s0 <- pc[pc$method == "stc", ]; fl <- pc[pc$method != "stc", ]
wins <- abs(s0$bias) >= 0.05 & abs(fl$bias) <= 0.5 * abs(s0$bias) & fl$coverage >= 0.935 & fl$coverage <= 0.965
verdict <- if (any(wins)) paste("FLEXIBILITY ESTABLISHED by", paste(fl$method[wins], collapse = " and ")) else "REFUTING SENTENCE HOLDS: no flexible arm removed the bias with valid coverage"
nul <- summ[summ$surface == "none", ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Surface B (hinge modification), poor overlap: bias STC %s; %s.", verdict, f3(s0$bias),
          paste(sprintf("%s %s (coverage %s)", fl$method, f3(fl$bias), f3(fl$coverage)), collapse = "; ")), "",
  sprintf("Null control (linear surface: every method unbiased within 3 MCSE with coverage 0.93 to 0.97): %s.", all(abs(nul$bias) <= 3 * nul$mcse & nul$coverage >= 0.93 & nul$coverage <= 0.97)), "",
  sprintf("Replicates dropped: %d.", sum(N_SIM - summ$n)), "",
  "| surface | target mean | method | truth | bias | MCSE | empirical SD | SE ratio | coverage | RMSE |", "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.2f | %.3f | %.3f |", summ$surface, summ$mu, summ$method, summ$truth, summ$bias, summ$mcse, summ$emp_sd, summ$se_ratio, summ$coverage, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:7], sep = "\n")
