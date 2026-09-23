## Coverage by variance estimator, sign of the omitted term, trimming estimand.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d[is.finite(d$est), ], g, by = "cell")
ses <- c("se_fixed", "se_ess", "se_stack", "se_stack_hc1")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  e <- z$est - z$target; n <- nrow(z)
  cv <- sapply(ses, function(s) if (all(is.na(z[[s]]))) NA else mean(abs(e) <= 1.96 * z[[s]]))
  data.frame(cell = z$cell[1], n_ok = n, bias_target = mean(e), bias_induced = mean(z$est - z$induced),
             mcse = stats::sd(e) / sqrt(n), emp_sd = stats::sd(z$est), gap = z$induced[1] - z$target[1],
             t(sapply(ses, function(s) mean(z[[s]]))), t(setNames(cv, paste0("cov_", ses))),
             ratio_stack_fixed = mean(z$se_stack / z$se_fixed), ratio_mcse = stats::sd(z$se_stack / z$se_fixed) / sqrt(n),
             ess = mean(z$ess))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
u <- summ[summ$trim == "none", ]
inb <- function(x) sum(x >= 0.93 & x <= 0.97, na.rm = TRUE)
refute <- inb(u$cov_se_ess) >= inb(u$cov_se_stack)
up <- sum(u$ratio_stack_fixed - 3 * u$ratio_mcse > 1, na.rm = TRUE)
dn <- sum(u$ratio_stack_fixed + 3 * u$ratio_mcse < 1, na.rm = TRUE)
tr <- summ[summ$trim != "none", ]
closer <- mean(abs(tr$bias_induced) < abs(tr$bias_target))
ctl <- u[u$shift == 0.2 & u$em == 0, ]
cov_cols <- paste0("cov_", ses)
c_ok <- all(as.matrix(ctl[, cov_cols]) >= 0.93 & as.matrix(ctl[, cov_cols]) <= 0.97) && all(abs(ctl$bias_target) <= 3 * ctl$mcse)
md <- c("# Decision", "",
  sprintf("**(a) Refuting sentence (ESS-based variance adequate): %s.** Untrimmed cells with coverage in [0.93, 0.97]: fixed %d, ESS-based %d, stacked %d, stacked HC1 %d, of %d.",
          if (refute) "HOLDS" else "FAILS", inb(u$cov_se_fixed), inb(u$cov_se_ess), inb(u$cov_se_stack), inb(u$cov_se_stack_hc1), nrow(u)), "",
  sprintf("Coverage ranges: fixed %.3f to %.3f; ESS-based %.3f to %.3f; stacked %.3f to %.3f; stacked HC1 %.3f to %.3f.",
          min(u$cov_se_fixed), max(u$cov_se_fixed), min(u$cov_se_ess), max(u$cov_se_ess),
          min(u$cov_se_stack), max(u$cov_se_stack), min(u$cov_se_stack_hc1), max(u$cov_se_stack_hc1)), "",
  sprintf("**Sign of the omitted term:** stacked SE above fixed beyond 3 MCSE in %d cells, below in %d, of %d. Sign claim %s.",
          up, dn, nrow(u), if (up > 0 && dn > 0) "CONFIRMED" else "NOT CONFIRMED"), "",
  sprintf("**(b) Trimming:** declared-to-induced truth gap %.3f to %.3f; bias smaller against the induced truth in %.0f%% of trimmed cells.",
          min(tr$gap), max(tr$gap), 100 * closer), "",
  sprintf("Control (shift 0.2, no modification, untrimmed): %s.", c_ok), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
