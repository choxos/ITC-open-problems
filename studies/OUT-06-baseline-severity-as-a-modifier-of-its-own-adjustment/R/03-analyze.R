## Performance, representation differences, controls and the registered decision.
## Writes results/summary.csv, results/differences.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d, g, by = "cell")
ms <- c("naive", "maic", "gcomp")

summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  do.call(rbind, lapply(c(paste0(ms, "_end"), paste0(ms, "_chg")), function(m) {
    e <- z[[m]] - z$truth
    data.frame(cell = z$cell[1], method = m, bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)),
               emp_se = stats::sd(z[[m]]))
  }))
}))
summ <- merge(summ, g, by = "cell")
dif <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  do.call(rbind, lapply(ms, function(m) {
    x <- z[[paste0(m, "_end")]] - z[[paste0(m, "_chg")]]
    data.frame(cell = z$cell[1], method = m, diff = mean(x), mcse = stats::sd(x) / sqrt(length(x)),
               max_abs = max(abs(x)))
  }))
}))
dif <- merge(dif, g, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
write.csv(dif, "results/differences.csv", row.names = FALSE)

adj <- dif[dif$method != "naive", ]
adj_ok <- all(abs(adj$diff) <= 3 * pmax(adj$mcse, 1e-12))
nu <- dif[dif$method == "naive" & dif$design == "unanchored", ]
fit <- stats::lm(diff ~ shift + I(beta * shift), data = nu)
cf <- summary(fit)$coefficients
slope_ok <- abs(cf["shift", 1] - 1) <= 3 * cf["shift", 2]
inter_ok <- abs(cf["I(beta * shift)", 1]) <= 3 * cf["I(beta * shift)", 2]
verdict <- if (adj_ok && slope_ok && inter_ok) "REFUTED (no product structure)" else
  if (any(abs(adj$diff) > 3 * adj$mcse)) "CONFIRMED OR OTHER: an adjusted method diverges" else "INCONCLUSIVE"
nul <- summ[summ$shift == 0, ]
c_null <- all(abs(nul$bias) <= 3 * nul$mcse)
pos <- summ[summ$design == "unanchored" & summ$shift == 1 & summ$method %in% c("naive_end", "naive_chg"), ]
pos$pred <- ifelse(pos$method == "naive_end", (pos$b + pos$beta), (pos$b + pos$beta - 1)) * pos$shift
c_pos <- all(abs(pos$bias) > 3 * pos$mcse) && all(abs(pos$bias - pos$pred) <= 3 * pos$mcse)

md <- c("# Decision", "", sprintf("**Registered rule: %s.**", verdict), "",
  sprintf("Adjusted methods (MAIC, G-computation): largest |endpoint - change| mean difference %.4f; all within 3 MCSE of zero: %s. Largest per-replicate absolute difference, unanchored adjusted: %.2e.",
          max(abs(adj$diff)), adj_ok, max(adj$max_abs[adj$design == "unanchored"])), "",
  sprintf("Naive unanchored: difference = %.4f (SE %.4f) x shift + %.4f (SE %.4f) x beta x shift.",
          cf["shift", 1], cf["shift", 2], cf["I(beta * shift)", 1], cf["I(beta * shift)", 2]), "",
  sprintf("Null control (shift 0, all methods unbiased within 3 MCSE): %s. Positive control (naive unanchored at shift 1 biased as predicted): %s.",
          c_null, c_pos), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
