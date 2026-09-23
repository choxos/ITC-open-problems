## Every topology x IPD placement x modification x target shift. Writes results/summary.csv.
source("R/00-model.R")
cfg <- expand.grid(G = c(0.05, 0.1, 0.2), M = c(0.5, 1), t = names(TOPOLOGIES), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
out <- do.call(rbind, lapply(seq_len(nrow(cfg)), function(j) { c0 <- cfg[j, ]
  do.call(rbind, lapply(0:nrow(TOPOLOGIES[[c0$t]]), function(i) evaluate(c0$t, i, c0$G, c0$M))) }))
write.csv(out, "results/summary.csv", row.names = FALSE)
rg <- do.call(rbind, lapply(split(out[out$ipd_edge != "none", ], list(out$G[out$ipd_edge != "none"], out$M_T[out$ipd_edge != "none"])), function(z)
  data.frame(G = z$G[1], M_T = z$M_T[1], truth = z$truth[1], err_min = min(z$decision_error), err_max = max(z$decision_error), cov_min = min(z$coverage), cov_max = max(z$coverage))))
write.csv(rg, "results/ranges.csv", row.names = FALSE)
fails <- any(rg$err_max - rg$err_min > 0.10)
md <- c("# Decision", "", sprintf("**Refuting sentence (performance depends on topology only through total information): %s.** Range of decision error across topology and placement at 1200 patients, per scenario: %s.",
          if (fails) "FAILS" else "HOLDS", paste(sprintf("G %.2f, target %.1f: %.3f to %.3f", rg$G, rg$M_T, rg$err_min, rg$err_max), collapse = "; ")), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
