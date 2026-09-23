## Observed against predicted bias, coverage, the comparator; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", pattern = "^cell", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { ok <- !is.na(z$est)
  e <- z$est[ok] - z$truth[ok]; dp <- e - z$pred[ok]; n <- sum(ok); cv <- abs(e) <= 1.96 * z$se[ok]
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, fail_rate = mean(!ok), bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             pred = mean(z$pred[ok]), obs_minus_pred = mean(dp), mcse_diff = stats::sd(dp) / sqrt(n), coverage = mean(cv), mcse_cov = sqrt(mean(cv) * (1 - mean(cv)) / n),
             emp_sd = stats::sd(z$est[ok]), mean_se = mean(z$se[ok]), rmse = sqrt(mean(e^2)), mcse_rmse = stats::sd(e^2) / (2 * sqrt(mean(e^2)) * sqrt(n))) }))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, summ$method), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)

cs <- summ[summ$method == "cstc", ]; un <- summ[summ$method == "unadjusted", ]
off <- abs(cs$obs_minus_pred) > pmax(3 * cs$mcse_diff, 0.02)
null_ok <- with(cs[cs$name == "null", ], coverage >= 0.925 & coverage <= 0.975)
pos_ok <- cs$coverage[cs$name == "positive"] < 0.80
dep <- cs[cs$name %in% c("synergy_strong", "drift_strong", "target_strong"), ]
shift <- c(synergy_strong = 0.3, drift_strong = 0.3, target_strong = 0.3)[dep$name]
disclose <- dep$name[abs(dep$bias) >= 0.1 | dep$coverage < 0.90]
un_wins <- cs$name[un$rmse < cs$rmse - 2 * sqrt(un$mcse_rmse^2 + cs$mcse_rmse^2)]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "",
  sprintf("**Registered primary: %s.** Refuting sentence (the two-stage bridge's behavior under each departure is the known linear pass-through of each edge's bias): observed minus predicted bias within max(3 MCSE, 0.02) in %d of %d cells%s.",
          if (!any(off)) "REFUTING SENTENCE HOLDS; the module reproduces known mechanisms and its value is the committed artifacts" else "REFUTING SENTENCE FAILS",
          sum(!off), nrow(cs), if (any(off)) paste0("; outside in: ", paste(cs$name[off], collapse = ", ")) else ""), "",
  sprintf("Null control (no departure, cSTC coverage within 0.925 to 0.975): %s (%s, MCSE %s).", if (null_ok) "passes" else "FAILS", f3(cs$coverage[cs$name == "null"]), f3(cs$mcse_cov[cs$name == "null"])), "",
  sprintf("Positive control (strong synergy, strong drift, poor overlap; cSTC coverage below 0.80): %s (%s).", if (pos_ok) "passes" else "FAILS: the module's worst scenario did not break the estimator", f3(cs$coverage[cs$name == "positive"])), "",
  sprintf("Pass-through at matched severity 0.3 (cSTC bias / shift): %s.", paste(sprintf("%s %s", dep$name, f3(dep$bias / -shift)), collapse = "; ")), "",
  sprintf("Departures to disclose (strong level: |bias| >= 0.1 or coverage < 0.90): %s.", if (length(disclose)) paste(disclose, collapse = ", ") else "none"), "",
  sprintf("Comparator (unadjusted bridge) RMSE below cSTC by more than 2 MCSE in: %s.", if (length(un_wins)) paste(un_wins, collapse = ", ") else "no cell"), "",
  "| cell | method | truth | failed | bias (MCSE) | predicted | observed - predicted (MCSE) | coverage (MCSE) | empirical SD | mean SE | RMSE |",
  "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %.3f | %.3f | %.3f (%.3f) | %.3f | %.3f (%.3f) | %.3f (%.3f) | %.3f | %.3f | %.3f |", summ$name, summ$method, summ$truth, summ$fail_rate,
          summ$bias, summ$mcse, summ$pred, summ$obs_minus_pred, summ$mcse_diff, summ$coverage, summ$mcse_cov, summ$emp_sd, summ$mean_se, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
