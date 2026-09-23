## Bias per reconstruction and the range across reconstructions; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - z$truth
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = nrow(z), bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), emp_sd = stats::sd(z$est), rmse = sqrt(mean(e^2))) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
rng <- do.call(rbind, lapply(split(d, list(d$cell, d$rep), drop = TRUE), function(z) data.frame(cell = z$cell[1], range = diff(range(z$est)),
  range_normal = diff(range(z$est[z$method %in% c("default", "rho_target", "rho_zero")])), range_margin = abs(z$est[z$method == "gamma"] - z$est[z$method == "default"]))))
rs <- merge(g, aggregate(cbind(range, range_normal, range_margin) ~ cell, rng, mean), by = "cell"); write.csv(rs, "results/range.csv", row.names = FALSE)
pc <- rs[rs$target_copula == "clayton", ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Mean range of the estimate across the five reconstructions, Clayton target: %s (threshold 0.05).",
          if (any(pc$range >= 0.05)) "RECONSTRUCTION SENSITIVITY MATERIAL" else "REFUTED FOR RECONSTRUCTION", paste(f3(pc$range), collapse = ", ")), "",
  "| target copula | source correlation | mean range (all) | correlation choices only | margin family only |", "|---|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %.3f | %.3f | %.3f |", rs$target_copula, rs$source_rho, rs$range, rs$range_normal, rs$range_margin), "",
  "| target copula | source correlation | reconstruction | truth | bias | MCSE | empirical SD | RMSE |", "|---|---:|---|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$target_copula, summ$source_rho, summ$method, summ$truth, summ$bias, summ$mcse, summ$emp_sd, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
