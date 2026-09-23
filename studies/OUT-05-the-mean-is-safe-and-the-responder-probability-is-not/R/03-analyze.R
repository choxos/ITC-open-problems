## Bias and RMSE of the mean and responder contrasts by method and cell; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { n <- nrow(z)
  f <- function(e) c(mean(e), stats::sd(e) / sqrt(n), sqrt(mean(e^2)))
  m <- f(z$est_mean - z$t_mean); a <- f(z$est_near - z$t_near); b <- f(z$est_tail - z$t_tail)
  data.frame(cell = z$cell[1], method = z$method[1], n = n, truth_mean = z$t_mean[1], truth_near = z$t_near[1], truth_tail = z$t_tail[1],
             bias_mean = m[1], mcse_mean = m[2], rmse_mean = m[3], bias_near = a[1], mcse_near = a[2], rmse_near = a[3],
             bias_tail = b[1], mcse_tail = b[2], rmse_tail = b[3]) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
np <- summ[summ$method == "normal_pooled", ]
mean_safe <- np[np$floor_mass == 0, ]; resp <- np[np$ratio == 2, ]
dis <- all(abs(mean_safe$bias_mean) <= 3 * mean_safe$mcse_mean) &&
  all((abs(resp$bias_near) > 3 * resp$mcse_near & abs(resp$bias_near) > 0.02) | (abs(resp$bias_tail) > 3 * resp$mcse_tail & abs(resp$bias_tail) > 0.02))
fails <- any(pmax(abs(resp$bias_near), abs(resp$bias_tail)) > 0.03)
fl <- summ[summ$method == "normal_arm_sd" & summ$floor_mass == 0.25, ]
md <- c("# Decision", "",
  sprintf("**Dissociation (pooled normal residual: mean contrast unbiased without a floor, responder contrast biased beyond 3 MCSE and 0.02 at SD ratio 2): %s.**", if (dis) "CONFIRMED" else "NOT CONFIRMED"), "",
  sprintf("**Refuting sentence (pooled-normal responder probabilities close enough): %s.** Largest responder bias at SD ratio 2: %.3f.", if (fails) "FAILS" else "HOLDS",
          max(pmax(abs(resp$bias_near), abs(resp$bias_tail)))), "",
  sprintf("Floor 0.25, linear model: mean-contrast bias %s (target shift %s).", paste(sprintf("%.3f", fl$bias_mean), collapse = ", "), paste(fl$m, collapse = ", ")), "",
  "| SD ratio | skew | floor | shift | method | bias mean | bias near | bias tail | RMSE near | RMSE tail |", "|---:|---|---:|---:|---|---:|---:|---:|---:|---:|",
  sprintf("| %g | %s | %.2f | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$ratio, summ$skew, summ$floor_mass, summ$m, summ$method,
          summ$bias_mean, summ$bias_near, summ$bias_tail, summ$rmse_near, summ$rmse_tail), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
