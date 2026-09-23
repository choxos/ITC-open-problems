## ---------------------------------------------------------------------------
## QBA-26: a leave-one-covariate-out benchmark against omitted composite structure.
##
## Unanchored: individual data on arm A (n = 400) in the source; the target
## reports covariate means. Measured x1..x4 ~ N(0, 1) independent, target means
## 0.3, outcome coefficients GX = (0.6, 0.4, 0.3, 0.2). Unmeasured u1..uq with
## pairwise correlation rho (one latent factor), each shifted by 0.3 in the
## target, outcome coefficient s * 0.6 each. Binary outcome
## logit p = -1 + x GX + u GU. Estimand: A's marginal log odds in the target.
## MAIC balances the measured means; its residual bias comes from the u.
## Benchmark: the largest change in the MAIC estimate from dropping one measured
## covariate. Scaled benchmark: times sqrt(q (1 + (q - 1) rho_m)) with rho_m the
## measured covariates' average correlation (0 here), the assumption that the
## unmeasured resemble the measured; the same with the true rho (oracle); and
## times q, the scaling for omitted variables whose shifts point the same way.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261023L
N <- 400L; GX <- c(0.6, 0.4, 0.3, 0.2); SHIFT <- 0.3; N_SIM <- 1000L
LEVELS <- list(q = c(1L, 3L, 6L), rho = c(0, 0.3, 0.6), s = c(0.5, 1, 2))
build_grid <- function() {
  g <- expand.grid(q = LEVELS$q, rho = LEVELS$rho, s = LEVELS$s, KEEP.OUT.ATTRS = FALSE)
  g <- g[!(g$q == 1 & g$rho > 0), ]; g$cell <- seq_len(nrow(g)); g
}
ru <- function(n, q, rho) { f <- stats::rnorm(n); sqrt(rho) * f + sqrt(1 - rho) * matrix(stats::rnorm(n * q), n, q) }
lin <- function(x, u, cell) as.vector(-1 + x %*% GX + u %*% rep(cell$s * 0.6, cell$q))

## Truth and the MAIC limit by large-sample Monte Carlo: the limit tilts x to its
## target means and leaves u at its source law.
truths <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(9); n <- 1e6; x <- matrix(stats::rnorm(n * 4), n, 4) + SHIFT; u <- ru(n, cell$q, cell$rho)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  t <- stats::qlogis(mean(stats::plogis(lin(x, u + SHIFT, cell)))); l <- stats::qlogis(mean(stats::plogis(lin(x, u, cell))))
  c(truth = t, limit = l, bias = l - t)
}

draw <- function(cell) { x <- matrix(stats::rnorm(N * 4), N, 4); u <- ru(N, cell$q, cell$rho)
  list(x = x, y = stats::rbinom(N, 1, stats::plogis(lin(x, u, cell)))) }

maic <- function(x, y, keep) { X <- sweep(x[, keep, drop = FALSE], 2, SHIFT)
  o <- stats::optim(rep(0, ncol(X)), function(a) sum(exp(X %*% a)), function(a) colSums(X * as.vector(exp(X %*% a))), method = "BFGS")
  w <- as.vector(exp(X %*% o$par)); stats::qlogis(sum(w * y) / sum(w)) }

fit_all <- function(cell, d) {
  full <- maic(d$x, d$y, 1:4)
  drops <- sapply(1:4, function(j) full - maic(d$x, d$y, setdiff(1:4, j)))
  bm <- max(abs(drops))
  c(est = full, benchmark = bm, scaled = bm * sqrt(cell$q), scaled_oracle = bm * sqrt(cell$q * (1 + (cell$q - 1) * cell$rho)),
    scaled_linear = bm * cell$q)
}
