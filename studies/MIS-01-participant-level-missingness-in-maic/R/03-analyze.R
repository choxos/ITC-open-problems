## Bias and coverage by mechanism, rate and method; decision.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], n = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             rmse = sqrt(mean(e^2)), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
cc <- summ[summ$method == "complete_case", ]
cc$zero_pred <- cc$mech %in% c("MCAR", "MAR_x2", "MNAR_x1") | (cc$mech %in% c("MAR_u", "MAR_y") & cc$bu == 0)
unb <- cc[cc$zero_pred, ]; bia <- cc[!cc$zero_pred, ]
mech_ok <- all(abs(unb$bias) <= 3 * unb$mcse) && all(abs(bia$bias[bia$rate == 0.15]) > 3 * bia$mcse[bia$rate == 0.15])
mar <- summ[summ$mech %in% c("MCAR", "MAR_x2", "MAR_u", "MAR_u_armA", "MAR_y") & summ$method != "complete_case", ]
mn <- summ[summ$mech == "MNAR_x1", ]
md <- c("# Decision", "",
  sprintf("**Mechanism, not rate, decides complete-case bias: %s.** Cells predicted unbiased: %d, all within 3 MCSE: %s. Cells predicted biased at 15%% missingness: %d, all beyond 3 MCSE: %s.",
          if (mech_ok) "CONFIRMED" else "NOT CONFIRMED", nrow(unb), all(abs(unb$bias) <= 3 * unb$mcse),
          sum(bia$rate == 0.15), all(abs(bia$bias[bia$rate == 0.15]) > 3 * bia$mcse[bia$rate == 0.15])), "",
  "Bias (coverage) by mechanism at 30% missingness:", "",
  "| mechanism | u modifies | complete case | IPW | MI congenial | MI generic |", "|---|---:|---:|---:|---:|---:|")
for (m in LEVELS$mech) for (b in LEVELS$bu) {
  z <- summ[summ$mech == m & summ$bu == b & summ$rate == 0.3, ]
  f <- function(k) { r <- z[z$method == k, ]; sprintf("%.3f (%.3f)", r$bias, r$coverage) }
  md <- c(md, sprintf("| %s | %.1f | %s | %s | %s | %s |", m, b, f("complete_case"), f("ipw"), f("mi_congenial"), f("mi_generic")))
}
md <- c(md, "", sprintf("Under MAR mechanisms, IPW and MI bias within 3 MCSE in %d of %d method-cells.",
  sum(abs(mar$bias) <= 3 * mar$mcse), nrow(mar)),
  sprintf("Under MNAR on the missing covariate: complete case max |bias| %.3f; IPW and MI max |bias| %.3f.",
          max(abs(mn$bias[mn$method == "complete_case"])), max(abs(mn$bias[mn$method != "complete_case"]))), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
