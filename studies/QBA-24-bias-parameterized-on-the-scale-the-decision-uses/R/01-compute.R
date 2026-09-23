## Delta RMST by shape, event level and gamma; linear-reinterpretation error; decision.
source("R/00-model.R")
g <- expand.grid(shape = SHAPES, s_tau = S_TAUS, gamma = GAMMAS, stringsAsFactors = FALSE)
g$rmst0 <- mapply(function(sh, s) rmst(sh, s, 0), g$shape, g$s_tau)
g$delta <- mapply(rmst, g$shape, g$s_tau, g$gamma) - g$rmst0
g$slope <- mapply(slope0, g$shape, g$s_tau)
g$linear <- g$gamma * g$slope; g$lin_error <- g$linear / g$delta - 1
g$hr <- exp(g$gamma)
write.csv(g, "results/delta.csv", row.names = FALSE)
spread <- do.call(rbind, lapply(split(g, list(g$s_tau, g$gamma)), function(z) data.frame(s_tau = z$s_tau[1], hr = z$hr[1],
  min_delta = min(z$delta), max_delta = max(z$delta), ratio = max(abs(z$delta)) / min(abs(z$delta)))))
write.csv(spread, "results/spread.csv", row.names = FALSE)
fails <- any(spread$ratio > 1.25) || any(abs(g$lin_error[g$hr == 2]) > 0.2)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (a hazard-scale bias maps approximately proportionally onto RMST): %s.** At matched survival by 24 months the same hazard bias changed RMST by up to %.2f times as much for one baseline shape as another; linear reinterpretation erred by %.0f%% to %.0f%% at a hazard ratio of 2.",
          if (fails) "FAILS" else "HOLDS", max(spread$ratio), 100 * min(g$lin_error[g$hr == 2]), 100 * max(g$lin_error[g$hr == 2])), "",
  "| shape | S(24) | bias HR | RMST at 0 | change in RMST | linear prediction | linear error |", "|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %.2f | %.2f | %.3f | %.3f | %.1f%% |", g$shape, g$s_tau, g$hr, g$rmst0, g$delta, g$linear, 100 * g$lin_error), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
