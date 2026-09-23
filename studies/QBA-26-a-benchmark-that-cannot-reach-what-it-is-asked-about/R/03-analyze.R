## Benchmark coverage of the true residual bias by rule and cell; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
rules <- c(plain = "benchmark", sqrt_q = "scaled", oracle = "scaled_oracle", linear = "scaled_linear")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { b <- abs(z$bias_true[1])
  data.frame(cell = z$cell[1], true_bias = z$bias_true[1], est_bias = mean(z$est - z$truth), median_benchmark = stats::median(z$benchmark),
             ratio = b / stats::median(z$benchmark), t(sapply(rules, function(k) mean(b <= z[[k]])))) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
k <- summ[summ$q >= 3 & summ$s <= 1, ]
fails <- all(k$plain < 0.5)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the strongest measured covariate bounds plausible unmeasured structure): %s.** With three or six omitted variables each no stronger than the strongest measured one, the plain benchmark covered the true residual bias in %.2f to %.2f of analyses.",
          if (fails) "FAILS" else "HOLDS", min(k$plain), max(k$plain)), "",
  "| q | rho | s | true residual bias | median benchmark | ratio | plain | times sqrt(q) | oracle | times q |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %.1f | %.3f | %.3f | %.1f | %.2f | %.2f | %.2f | %.2f |", summ$q, summ$rho, summ$s, summ$true_bias, summ$median_benchmark, summ$ratio,
          summ$plain, summ$sqrt_q, summ$oracle, summ$linear), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
