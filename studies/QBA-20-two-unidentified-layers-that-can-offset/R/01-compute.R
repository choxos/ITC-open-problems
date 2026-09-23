## The analysis favors A (target log OR ANALYST < 0); a bias below ANALYST means the
## truth is above 0 and the decision reverses.
## Envelopes, decision reversal and masking over the elicited box at three scales,
## under independent and dependent elicitation. Writes results/summary.csv, results/grid.csv.
source("R/00-model.R")
set.seed(20261128)
ax <- seq(-1, 1, length.out = 21)
res <- do.call(rbind, lapply(c(0.5, 1, 1.5), function(k) {
  r <- RANGE * k
  one <- c(vapply(ax, function(a) bias(a * r[["mu_u"]], 0, 0), 0), vapply(ax, function(a) bias(0, a * r[["d_m"]], 0), 0), vapply(ax, function(a) bias(0, 0, a * r[["d_i"]]), 0))
  G <- expand.grid(a = ax, b = ax, c = ax)
  G$bias <- mapply(function(a, b, c) bias(a * r[["mu_u"]], b * r[["d_m"]], c * r[["d_i"]]), G$a, G$b, G$c)
  G$pop <- vapply(G$a, function(a) bias(a * r[["mu_u"]], 0, 0), 0); G$bridge <- G$bias - G$pop
  ## Elicited distributions on the box: independent uniform, and a Gaussian copula with
  ## correlation +0.5 or -0.5 between the population layer and each bridge parameter.
  el <- lapply(c(independent = 0, positive = 0.5, negative = -0.5), function(rho) {
    S <- matrix(c(1, rho, rho, rho, 1, 0, rho, 0, 1), 3); z <- MASS::mvrnorm(4000, rep(0, 3), S); u <- 2 * stats::pnorm(z) - 1
    b <- mapply(function(a, bb, c) bias(a * r[["mu_u"]], bb * r[["d_m"]], c * r[["d_i"]]), u[, 1], u[, 2], u[, 3])
    c(outside = mean(b < min(one) | b > max(one)), reversal = mean(b < ANALYST)) })
  G$scale <- k
  list(summary = data.frame(scale = k, analyst = ANALYST, one_lo = min(one), one_hi = max(one), di_alone = max(abs(one[43:63])),
    joint_lo = min(G$bias), joint_hi = max(G$bias), one_robust = min(one) > ANALYST, joint_robust = min(G$bias) > ANALYST,
    box_reversal = mean(G$bias < ANALYST), box_outside = mean(G$bias < min(one) | G$bias > max(one)),
    masking = mean(abs(G$pop) >= 0.1 & abs(G$bridge) >= 0.1 & abs(G$bias) < 0.05),
    el_outside_ind = el$independent[["outside"]], el_outside_pos = el$positive[["outside"]], el_outside_neg = el$negative[["outside"]],
    el_rev_ind = el$independent[["reversal"]], el_rev_pos = el$positive[["reversal"]], el_rev_neg = el$negative[["reversal"]]), grid = G)
}))
write.csv(do.call(rbind, res[, "summary"]), "results/summary.csv", row.names = FALSE)
write.csv(do.call(rbind, res[, "grid"]), "results/grid.csv", row.names = FALSE)
print(do.call(rbind, res[, "summary"]))
