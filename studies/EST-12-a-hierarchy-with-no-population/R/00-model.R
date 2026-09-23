## ---------------------------------------------------------------------------
## EST-12: treatment hierarchies move with the target population.
##
## Star network: treatments B..F each compared with A in M trials; trial covariate
## means xbar ~ U(-1, 1); trial estimates of t versus A: delta_t + beta_t xbar + e,
## SE 0.1. Effects delta = SPACING * (0, 1, 2, 3, 4) (B best when negative is
## good), modification beta_t = SPREAD * (2, 1, 0, -1, -2) / 2.
## Analysis: fixed-effect meta-regression per treatment (delta_t, beta_t), then
## P-scores at each target covariate mean in TARGETS. True ranking at each target
## from the true effects.
## Two rank movements, on the same scale (mean absolute rank change per
## treatment): across targets within a replicate, and across two independent
## replicates at the same target.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261025L
SE <- 0.1; N_SIM <- 1000L; K <- 5L
LEVELS <- list(spread = c(0, 0.2, 0.4), spacing = c(-0.05, -0.15), M = c(2L, 5L), width = c(0.5, 1))
build_grid <- function() {
  g <- expand.grid(spread = LEVELS$spread, spacing = LEVELS$spacing, M = LEVELS$M, width = LEVELS$width, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
targets <- function(cell) c(-cell$width, 0, cell$width)
truth_eff <- function(cell, x) cell$spacing * (0:(K - 1)) + cell$spread * c(2, 1, 0, -1, -2) / 2 * x

draw <- function(cell) do.call(rbind, lapply(seq_len(K), function(t) { xb <- stats::runif(cell$M, -1, 1)
  data.frame(trt = t, xbar = xb, est = cell$spacing * (t - 1) + cell$spread * c(2, 1, 0, -1, -2)[t] / 2 * xb + stats::rnorm(cell$M, 0, SE)) }))

## P-score for effects (lower is better) against A and each other, from estimates
## and their covariance (independent treatments, so pairwise variance adds).
pscore <- function(m, v) { k <- length(m); sapply(seq_len(k), function(i) mean(c(stats::pnorm((0 - m[i]) / sqrt(v[i])),
  sapply(setdiff(seq_len(k), i), function(j) stats::pnorm((m[j] - m[i]) / sqrt(v[i] + v[j]))))) ) }

fit_ranks <- function(cell, d) {
  fits <- lapply(split(d, d$trt), function(z) { X <- cbind(1, z$xbar); V <- solve(crossprod(X)) * SE^2; b <- drop(V %*% crossprod(X, z$est) / SE^2); list(b = b, V = V) })
  sapply(targets(cell), function(x) { a <- c(1, x); m <- sapply(fits, function(f) sum(a * f$b)); v <- sapply(fits, function(f) drop(t(a) %*% f$V %*% a))
    rank(-pscore(m, v), ties.method = "average") })
}
true_ranks <- function(cell) sapply(targets(cell), function(x) rank(truth_eff(cell, x), ties.method = "average"))

one_rep <- function(cell) {
  r1 <- fit_ranks(cell, draw(cell)); r2 <- fit_ranks(cell, draw(cell)); tr <- true_ranks(cell)
  c(across_targets = mean(abs(r1[, 1] - r1[, 3])), across_replicates = mean(abs(r1[, 2] - r2[, 2])),
    true_across_targets = mean(abs(tr[, 1] - tr[, 3])), wrong_best_mid = as.numeric(which.min(r1[, 2]) != which.min(tr[, 2])),
    wrong_best_edge = as.numeric(which.min(r1[, 3]) != which.min(tr[, 3])))
}
