## Estimation and mismatch terms; method ranking under the native and the declared metric; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { cc <- z[1, c("m_d", "g_b")]
  nt <- native_truth(z$method[1], cc); dt <- Delta(cc$m_d, cc$g_b)
  data.frame(cell = z$cell[1], method = z$method[1], native = nt, declared = dt, mismatch = nt - dt,
             bias_native = mean(z$est) - nt, rmse_native = sqrt(mean((z$est - nt)^2)), bias_declared = mean(z$est) - dt,
             rmse_declared = sqrt(mean((z$est - dt)^2)), mcse = stats::sd(z$est) / sqrt(nrow(z)), n = nrow(z)) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
best <- do.call(rbind, lapply(split(summ, summ$cell), function(z) data.frame(cell = z$cell[1], m_d = z$m_d[1], g_b = z$g_b[1],
  best_native = z$method[which.min(z$rmse_native)], best_declared = z$method[which.min(z$rmse_declared)],
  rho = stats::cor(z$rmse_native, z$rmse_declared, method = "spearman"))))
best$flip <- best$best_native != best$best_declared
write.csv(best, "results/ranking.csv", row.names = FALSE)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** The best method under the native metric differs from the best under the declared metric in %d of %d cells.",
          if (mean(best$flip) >= 0.25) "CONFIRMED" else "REFUTED", sum(best$flip), nrow(best)), "",
  "| declared target mean | B's modification | best (native) | best (declared) | Spearman |", "|---:|---:|---|---|---:|",
  sprintf("| %.1f | %.1f | %s | %s | %.2f |", best$m_d, best$g_b, best$best_native, best$best_declared, best$rho), "",
  "| declared target mean | B's modification | method | native truth | declared truth | mismatch | RMSE native | RMSE declared | bias declared |", "|---:|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$m_d, summ$g_b, summ$method, summ$native, summ$declared, summ$mismatch, summ$rmse_native, summ$rmse_declared, summ$bias_declared), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
