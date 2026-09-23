## Bias by method against prediction, decision.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
ms <- c("naive", "midpoint", "interval")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(ms, function(m) {
  e <- z[[m]] - z$truth; e <- e[is.finite(e)]
  data.frame(cell = z$cell[1], method = m, bias = mean(e), mcse = stats::sd(e) / sqrt(length(e)),
             rmse = sqrt(mean(e^2)), predicted = z$predicted[1], n_ok = length(e)) }))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
nv <- summ[summ$method == "naive", ]
f <- stats::lm(bias ~ predicted, data = nv, weights = 1 / nv$mcse^2)
dd <- nv[abs(nv$d1 - nv$d2) >= 2, ]
material <- all(abs(dd$bias) - 1.96 * dd$mcse > 0.25)
fix <- summ[summ$method != "naive", ]
md <- c("# Decision", "",
  sprintf("**Materiality (naive |bias| > 0.25 months beyond MC error wherever the grids differ by 2 months or more): %s** (%d cells; naive bias %.2f to %.2f months).",
          if (material) "CONFIRMED" else "NOT CONFIRMED", nrow(dd), min(dd$bias), max(dd$bias)), "",
  sprintf("Naive bias on the prediction (d/2) F(tau): slope %.3f (SE %.3f) over %d cells.",
          coef(f)[["predicted"]], sqrt(diag(vcov(f)))[["predicted"]], nrow(nv)), "",
  sprintf("Midpoint: max |bias| %.3f; within 3 MCSE in %d of %d cells. Interval-censored Weibull: max |bias| %.3f; within 3 MCSE in %d of %d cells.",
          max(abs(fix$bias[fix$method == "midpoint"])), sum(abs(fix$bias[fix$method == "midpoint"]) <= 3 * fix$mcse[fix$method == "midpoint"]), sum(fix$method == "midpoint"),
          max(abs(fix$bias[fix$method == "interval"])), sum(abs(fix$bias[fix$method == "interval"]) <= 3 * fix$mcse[fix$method == "interval"]), sum(fix$method == "interval")), "",
  sprintf("Control (equal grids, d1 = d2): naive within 3 MCSE in %d of %d cells.",
          sum(abs(nv$bias[nv$d1 == nv$d2]) <= 3 * nv$mcse[nv$d1 == nv$d2]), sum(nv$d1 == nv$d2)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
