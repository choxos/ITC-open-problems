## Bias and coverage for the rate ratio and A's absolute rate; decision.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  e1 <- z$log_rr - z$true_log_rr; e2 <- z$log_rate_A - z$true_log_rate_A
  ok1 <- is.finite(e1) & is.finite(z$se_rr); ok2 <- is.finite(e2) & is.finite(z$se_rate_A)
  data.frame(cell = z$cell[1], method = z$method[1], n = nrow(z),
             bias_rr = mean(e1[ok1]), mcse_rr = stats::sd(e1[ok1]) / sqrt(sum(ok1)),
             cover_rr = mean(abs(e1[ok1]) <= 1.96 * z$se_rr[ok1]),
             bias_rate = mean(e2[ok2]), mcse_rate = stats::sd(e2[ok2]) / sqrt(sum(ok2)),
             cover_rate = mean(abs(e2[ok2]) <= 1.96 * z$se_rate_A[ok2]))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
A <- summ[summ$part == "A" & is.finite(summ$theta), ]
pois <- A[A$method == "poisson", ]; sand <- A[A$method == "poisson_sandwich", ]
f1 <- all(abs(pois$bias_rr) <= 3 * pois$mcse_rr) && all(pois$cover_rr < 0.93) && all(sand$cover_rr >= 0.93)
B <- summ[summ$part == "B", ]
dif <- B[B$pi_s != B$pi_t, ]; same <- B[B$pi_s == B$pi_t, ]
f2 <- all(abs(dif$bias_rate[dif$method %in% c("poisson", "negbin", "zip")]) > 3 * dif$mcse_rate[dif$method %in% c("poisson", "negbin", "zip")])
b0 <- dif[dif$b == 0 & dif$method %in% c("poisson_sandwich", "negbin"), ]
rr_protected <- all(abs(b0$bias_rr) <= 3 * b0$mcse_rr)
cal <- dif[dif$method == "zip_calibrated", ]
md <- c("# Decision", "",
  sprintf("**Failure one (overdispersion breaks the interval, not the estimate): %s.** Poisson rate-ratio bias within 3 MCSE and model-based coverage below 0.93 in overdispersed cells, sandwich coverage at least 0.93: Poisson coverage %s; sandwich %s.",
          if (f1) "CONFIRMED" else "NOT CONFIRMED", paste(sprintf("%.3f", pois$cover_rr), collapse = ", "), paste(sprintf("%.3f", sand$cover_rr), collapse = ", ")), "",
  sprintf("**Failure two (a differing structural-zero fraction biases the transported absolute rate): %s.** Absolute log-rate bias for Poisson, negative binomial and zero-inflated fits: %.3f to %.3f.",
          if (f2) "CONFIRMED" else "NOT CONFIRMED", min(dif$bias_rate[dif$method %in% c("poisson", "negbin", "zip")]), max(dif$bias_rate[dif$method %in% c("poisson", "negbin", "zip")])), "",
  sprintf("Rate ratio without effect modification (b = 0) when the zero fraction differs: bias within 3 MCSE in all: %s (max |bias| %.3f). With b = 0.4: max |bias| %.3f.",
          rr_protected, max(abs(b0$bias_rr)), max(abs(dif$bias_rr[dif$b == 0.4 & dif$method %in% c("poisson_sandwich", "negbin")]))), "",
  sprintf("Zero part recalibrated to the target's reported zero proportion: absolute-rate bias %.3f to %.3f; rate-ratio bias %.3f to %.3f.",
          min(cal$bias_rate), max(cal$bias_rate), min(cal$bias_rr), max(cal$bias_rr)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
