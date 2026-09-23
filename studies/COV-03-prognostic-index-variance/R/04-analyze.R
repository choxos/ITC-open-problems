## Performance, mechanism check, controls, decision (protocol.md section 6).
## Writes results/summary.csv and results/decision.md.
source("R/01-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  ok <- is.finite(z$est) & is.finite(z$se); e <- z$est[ok] - z$truth[ok]; n <- sum(ok)
  cov <- mean(abs(e) <= 1.96 * z$se[ok])
  data.frame(cell = z$cell[1], method = z$method[1], n_ok = n, n_fail = nrow(z) - n,
             bias = mean(e), mcse = stats::sd(e) / sqrt(n), emp_se = stats::sd(z$est[ok]),
             mod_se = mean(z$se[ok]), rmse = sqrt(mean(e^2)), coverage = cov,
             cov_mcse = sqrt(cov * (1 - cov) / n), ess = mean(z$ess[ok]))
}))
summ <- merge(summ, g, by = "cell")
summ$exact_unadj <- ifelse(summ$design == "anchored",
  vapply(seq_len(nrow(summ)), function(i) bucher_bias(summ[i, ]), 0),
  vapply(seq_len(nrow(summ)), function(i) unanchored_naive_bias(summ[i, ]), 0))
write.csv(summ, "results/summary.csv", row.names = FALSE)

u <- summ[summ$method == "unadjusted" & summ$design == "anchored" & summ$em == "none", ]
f <- stats::lm(bias ~ exact_unadj, data = u, weights = 1 / u$mcse^2)
sl <- c(coef(f)[["exact_unadj"]], sqrt(diag(vcov(f)))[["exact_unadj"]])

prim <- summ[summ$design == "anchored" & summ$em == "none" & summ$ratio != 1 & summ$var_T >= 1, ]
mm <- prim[prim$method == "maic_means", ]
biased <- mm$cell[(abs(mm$bias) - 1.96 * mm$mcse) > BIAS_MATERIAL]
fixed <- vapply(biased, function(cid) {
  z <- prim[prim$cell == cid & prim$method %in% c("maic_meanvar", "maic_index"), ]
  any(abs(z$bias) < BIAS_MATERIAL)
}, TRUE)
verdict <- if (length(biased) && all(fixed)) "CONFIRMED" else
  if (all(abs(mm$bias) < BIAS_MATERIAL)) "REFUTED" else "MECHANISM NOT SUPPORTED"

nul <- summ[summ$ratio == 1 & summ$shift == 0, ]
c_null <- all(abs(nul$bias) <= 3 * nul$mcse, na.rm = TRUE)
pz <- summ[summ$method == "unadjusted" & summ$design == "anchored" & summ$em == "none" &
           summ$var_T == 4 & summ$ratio != 1, ]
c_pos <- all(abs(pz$bias) > 3 * pz$mcse)
dc <- u[u$ratio == 1 & u$shift > 0, ]

tab <- aggregate(cbind(bias, rmse, coverage, ess) ~ method, data = prim, na.action = stats::na.pass,
                 FUN = function(x) mean(abs(x), na.rm = TRUE))
md <- c("# Decision", "", sprintf("**Registered rule (protocol.md section 6): %s.**", verdict), "",
  sprintf("Primary cells: 12. MAIC means biased beyond 0.05 (95%% MC interval) in %d; in each of those a variance-balancing arm is under 0.05: %s.",
          length(biased), if (length(fixed)) all(fixed) else NA), "",
  "Mean over primary cells (bias as mean absolute bias):", "",
  "| method | mean abs bias | mean RMSE | mean coverage | mean ESS |", "|---|---:|---:|---:|---:|",
  sprintf("| %s | %.4f | %.4f | %.3f | %.0f |", tab$method, tab$bias, tab$rmse, tab$coverage, tab$ess), "",
  sprintf("Mechanism check: unadjusted anchored bias on exact population bias, slope %.3f (SE %.3f), over %d cells.", sl[1], sl[2], nrow(u)), "",
  sprintf("Design's claim (ratio 1, shift > 0): observed unadjusted bias %s against exact %s.",
          paste(sprintf("%.4f", dc$bias), collapse = ", "), paste(sprintf("%.4f", dc$exact_unadj), collapse = ", ")), "",
  sprintf("Controls: null %s; positive %s.", c_null, c_pos), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
