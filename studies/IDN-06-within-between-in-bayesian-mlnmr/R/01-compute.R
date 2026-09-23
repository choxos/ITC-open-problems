## Exact coverage, width and direct share for every cell and model. Writes results/summary.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid(); r <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) evaluate(g[i, ])))
write.csv(r, "results/summary.csv", row.names = FALSE)
sh <- r[r$model == "shared" & r$D > 0 & r$E == 0, ]; sp <- r[r$model == "separate" & r$D > 0 & r$E == 0 & r$S >= 2, ]
confirmed <- any(sh$coverage < 0.90) && all(sp$coverage >= 0.935 & sp$coverage <= 0.965)
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Shared-model coverage for the aggregate-only interaction at nonzero discordance: %s to %s; separate model with two or more aggregate trials: %s to %s.",
          if (confirmed) "CONFIRMED" else "NOT CONFIRMED AS REGISTERED", f3(min(sh$coverage)), f3(max(sh$coverage)), f3(min(sp$coverage)), f3(max(sp$coverage))), "",
  "| aggregate trials | covariate-mean spread | discordance | ecological term | model | bias | posterior SD | coverage | direct share |", "|---:|---:|---:|---:|---|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %.2f | %.1f | %s | %.3f | %.3f | %.3f | %.3f |", r$S, r$spread, r$D, r$E, r$model, r$bias, r$sd_post, r$coverage, r$data_share), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
