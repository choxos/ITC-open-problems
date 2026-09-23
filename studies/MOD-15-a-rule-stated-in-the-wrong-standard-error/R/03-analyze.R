## The registered decision from results/summary.csv.
s <- read.csv("results/summary.csv")
h <- s[s$policy == "half_sA", ]
p0 <- h$pass[h$delta == 0]
cc <- h$cond_cover_pass[h$delta <= 0.2 & h$pass > 0]
fails <- all(p0 < 0.5) || any(cc < 0.90)
cfg <- unique(s[, c("K", "disp")])
best <- sapply(seq_len(nrow(cfg)), function(i) {
  z <- s[s$K == cfg$K[i] & s$disp == cfg$disp[i] & s$delta <= 0.2, ]
  a <- aggregate(rmse ~ policy, z, max)   # worst RMSE over delta in [0, 0.2]
  a$policy[which.min(a$rmse)] })
tab <- table(best)
nv <- s[s$policy == "never_pool", c("cell", "rmse")]; ap <- s[s$policy == "always_pool", c("cell", "rmse")]
gain <- merge(nv, ap, by = "cell", suffixes = c("_never", "_always"))
gain <- merge(gain, unique(s[, c("cell", "K", "disp", "delta")]), by = "cell")
g0 <- gain[gain$delta == 0, ]
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the rule's operating characteristics are adequate): %s.** Pass probability under equality %.3f to %.3f; coverage of the pooled interval given a pass, at ecological bias up to 0.2, as low as %.3f.",
          if (fails) "FAILS" else "HOLDS", min(p0), max(p0), min(cc)), "",
  "Policy with the lowest worst-case RMSE over ecological bias 0 to 0.2, by configuration:", "",
  paste(sprintf("%s: %d", names(tab), as.integer(tab)), collapse = "; "), "",
  sprintf("What pooling can gain: at no bias, always pooling cuts RMSE by %.0f%% to %.0f%% relative to never pooling; the half-SE rule's RMSE is within %.1f%% of never pooling in every configuration.",
          100 * min(1 - g0$rmse_always / g0$rmse_never), 100 * max(1 - g0$rmse_always / g0$rmse_never),
          100 * max(abs(h$rmse / s$rmse[s$policy == "never_pool"][match(h$cell, s$cell[s$policy == "never_pool"])] - 1))), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
