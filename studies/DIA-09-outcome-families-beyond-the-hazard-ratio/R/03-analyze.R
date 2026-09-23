## Bias and coverage of the CIF difference, A's CIF and the cause-1 log HR; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
## The cause-1 log HR estimate is at the target's reported covariate mean; its truth
## uses the population mean, the same up to that mean's sampling error.
est <- list(diff = c("maic", "stc", "stc_recal"), A = c("maic_A", "stc_A", "stc_recal_A"), hr = "log_hr1")
tr <- c(diff = "truth_diff", A = "truth_A", hr = "truth_hr")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(names(est), function(k) do.call(rbind, lapply(est[[k]], function(m) {
  e <- z[[m]] - z[[tr[[k]]]]; se <- z[[paste0(m, "_se")]]; ok <- is.finite(e) & is.finite(se)
  cv <- mean(abs(e[ok]) <= 1.96 * se[ok])
  data.frame(cell = z$cell[1], estimand = k, method = m, n_ok = sum(ok), bias = mean(e[ok]), mcse = stats::sd(e[ok]) / sqrt(sum(ok)),
             coverage = cv, truth = z[[tr[[k]]]][1]) }))))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
hr <- summ[summ$estimand == "hr", ]
Ab <- summ[summ$estimand == "A" & summ$method %in% c("maic_A", "stc_A") & summ$k_t != 1, ]
conf <- all(abs(hr$bias) <= 3 * hr$mcse) && all(abs(Ab$bias) > 3 * Ab$mcse & abs(Ab$bias) > 0.05)
rc <- summ[summ$method %in% c("stc_recal", "stc_recal_A"), ]
ctl <- summ[summ$k_t == 1, ]
md <- c("# Decision", "",
  sprintf("**Consequence 1 (cause-specific HR right, cumulative incidence wrong): %s.** Cause-1 log HR bias within 3 MCSE in %d of %d cells (max |bias| %.3f). A's CIF bias with the source's competing hazard, K_T != 1: %.3f to %.3f; beyond 3 MCSE and 0.05 in %d of %d method-cells.",
          if (conf) "CONFIRMED" else "NOT CONFIRMED", sum(abs(hr$bias) <= 3 * hr$mcse), nrow(hr), max(abs(hr$bias)), min(Ab$bias), max(Ab$bias),
          sum(abs(Ab$bias) > 3 * Ab$mcse & abs(Ab$bias) > 0.05), nrow(Ab)), "",
  sprintf("Recalibrated competing hazard: |bias| at most %.3f; coverage %.3f to %.3f.", max(abs(rc$bias)), min(rc$coverage), max(rc$coverage)), "",
  sprintf("Control (K_T = 1): every method |bias| at most %.3f, within 3 MCSE in %d of %d.", max(abs(ctl$bias)), sum(abs(ctl$bias) <= 3 * ctl$mcse), nrow(ctl)), "",
  "| K_T | b | target mean | estimand | method | truth | bias | coverage |", "|---:|---:|---:|---|---|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %.1f | %s | %s | %.3f | %.3f | %.3f |", summ$k_t, summ$b, summ$m_t, summ$estimand, summ$method, summ$truth, summ$bias, summ$coverage), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
