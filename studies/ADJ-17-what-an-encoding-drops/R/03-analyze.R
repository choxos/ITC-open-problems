## Bias and coverage by representation; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - z$truth
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), coverage = mean(abs(e) <= 1.96 * z$se),
             rmse = sqrt(mean(e^2)), recon = mean(z$recon)) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pr <- summ[summ$method == "pca" & summ$dir == "low" & summ$k == 5, ]
confirmed <- any(abs(pr$bias) >= 0.1 & pr$recon >= 0.8)
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Five principal components, modifier on a low-variance direction: bias %s with %s of covariate variance reconstructed; coverage %s.",
          if (confirmed) "CONFIRMED" else "NOT CONFIRMED", paste(f3(pr$bias), collapse = ", "), paste(f3(pr$recon), collapse = ", "), paste(f3(pr$coverage), collapse = ", ")), "",
  "| modifier direction | components | target shift | method | truth | bias | coverage | RMSE | variance reconstructed |", "|---|---:|---:|---|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %.1f | %s | %.2f | %.3f | %.3f | %.3f | %.3f |", summ$dir, summ$k, summ$shift, summ$method, summ$truth, summ$bias, summ$coverage, summ$rmse, summ$recon), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
