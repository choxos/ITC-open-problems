## Bias and RMSE by method and ascertainment mechanism; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(c("naive", "midpoint", "interval"), function(m) { e <- z[[m]] - z$truth
  data.frame(cell = z$cell[1], method = m, truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), rmse = sqrt(mean(e^2))) }))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
ic <- summ[summ$method == "interval", ]; mis <- ic[ic$se_b <= 0.85, ]; inf <- ic[ic$se_b == 1, ]
fails <- any(abs(mis$bias) > 0.25 & abs(mis$bias) > 3 * mis$mcse)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the interval-censored likelihood covers the practically important case): %s.** Interval-censored bias with missed detections (sensitivity 0.85 or 0.7): %.2f to %.2f months; with perfect detection: %.2f to %.2f.",
          if (fails) "FAILS" else "HOLDS", min(mis$bias), max(mis$bias), min(inf$bias), max(inf$bias)), "",
  "| detection sensitivity | visiting | true difference | method | bias | MCSE | RMSE |", "|---:|---|---:|---|---:|---:|---:|",
  sprintf("| %.2f | %s | %.2f | %s | %.3f | %.3f | %.3f |", summ$se_b, summ$visiting, summ$truth, summ$method, summ$bias, summ$mcse, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
