## Coverage and width of the new submission's bias-adjusted interval by prior, the
## recovered systematic variance, controls; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
lost <- sum(is.na(d$coverage)) / length(METHODS); d <- d[!is.na(d$coverage), ]
d$oracle_hw <- stats::qnorm(0.975) * sqrt(SE_NEW^2 + d$tau^2)
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) data.frame(cell = z$cell[1], method = z$method[1], n_ok = nrow(z),
  coverage = mean(z$coverage), cov_mcse = stats::sd(z$coverage) / sqrt(nrow(z)), width_vs_oracle = mean(z$halfwidth / z$oracle_hw),
  tau2_bias = mean(z$tau2_hat - z$tau^2), tau2_mcse = stats::sd(z$tau2_hat) / sqrt(nrow(z)), prob_zero = mean(z$tau2_hat <= 1e-10),
  excess = mean(z$excess), excess_mcse = stats::sd(z$excess) / sqrt(nrow(z)), reml_ok = mean(z$reml_ok))))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, match(summ$method, METHODS)), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)

pr <- summ[summ$K == 15 & summ$sig_m == 0, ]; cv <- function(m, t) pr$coverage[pr$method == m & pr$tau == t]
raw_wide <- all(vapply(c(0, 0.1), function(t) cv("raw", t) > 0.975, TRUE))
reml_ok <- all(vapply(c(0.1, 0.3), function(t) cv("reml", t) >= 0.925 && cv("reml", t) <= 0.975, TRUE))
raw_ok <- all(vapply(c(0, 0.1, 0.3), function(t) cv("raw", t) >= 0.925 && cv("raw", t) <= 0.975, TRUE))
verdict <- if (raw_wide && reml_ok) "CONFIRMED: the raw discrepancy prior over-covers and the decomposed prior is near nominal" else
  if (raw_ok) "REFUTED: the raw discrepancy distribution is an adequate prior at K = 15" else "MIXED: see the table"
over <- any(vapply(c(0.1, 0.3), function(t) cv("naive", t) <= 0.925, TRUE))
nul <- summ[summ$tau == 0 & summ$sig_m == 0 & summ$method == "shared", ]
null_ok <- all(abs(nul$excess) <= 3 * nul$excess_mcse)
## Mismatch effect net of truncation: REML tau2 bias with mismatch minus without, same tau and K.
rm <- summ[summ$method == "reml" & summ$tau > 0, ]
pos <- merge(rm[rm$sig_m == 0.1, c("tau", "K", "tau2_bias")], rm[rm$sig_m == 0, c("tau", "K", "tau2_bias")], by = c("tau", "K"))
pos$tau2_bias <- pos$tau2_bias.x - pos$tau2_bias.y; pos_ok <- all(pos$tau2_bias >= 0.005)
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary (K = 15, no mismatch): %s.**", verdict), "",
  sprintf("Coverage by true systematic SD 0, 0.1, 0.3: raw %s; naive %s; shared %s; REML predictive %s. Registered: raw above 0.975 at 0 and 0.1, REML 0.925 to 0.975 at 0.1 and 0.3; refuted if raw 0.925 to 0.975 at all three.",
          paste(f3(sapply(c(0, 0.1, 0.3), function(t) cv("raw", t))), collapse = ", "), paste(f3(sapply(c(0, 0.1, 0.3), function(t) cv("naive", t))), collapse = ", "),
          paste(f3(sapply(c(0, 0.1, 0.3), function(t) cv("shared", t))), collapse = ", "), paste(f3(sapply(c(0, 0.1, 0.3), function(t) cv("reml", t))), collapse = ", ")), "",
  sprintf("Secondary: subtracting both reported variances over-corrects (coverage at most 0.925 at systematic SD 0.1 or 0.3): %s.", over), "",
  sprintf("Null control (no systematic bias, no mismatch: var(D) minus the true sampling variance within 3 MCSE of 0): %s; %s.", null_ok,
          paste(sprintf("K = %d: %.4f (MCSE %.4f)", nul$K, nul$excess, nul$excess_mcse), collapse = "; ")), "",
  sprintf("Positive control (systematic SD 0.1 and 0.3: REML tau2 bias with mismatch SD 0.1 minus without, at least 0.005; expected 0.01): %s; %s.", pos_ok,
          paste(sprintf("tau %.1f K %d: %.4f", pos$tau, pos$K, pos$tau2_bias), collapse = ", ")), "",
  sprintf("Replicates lost: %d; REML fell back to DL in %d fits.", lost, sum(!d$reml_ok[d$method == "reml"])), "",
  "| systematic SD | mismatch SD | K | prior | coverage (MCSE) | half-width / oracle | tau2 bias (MCSE) | P(tau2 = 0) |", "|---:|---:|---:|---|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %d | %s | %.3f (%.3f) | %.3f | %.4f (%.4f) | %.3f |", summ$tau, summ$sig_m, summ$K, summ$method, summ$coverage, summ$cov_mcse,
          summ$width_vs_oracle, summ$tau2_bias, summ$tau2_mcse, summ$prob_zero), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
