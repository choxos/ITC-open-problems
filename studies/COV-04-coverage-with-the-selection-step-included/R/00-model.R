## ---------------------------------------------------------------------------
## COV-04: coverage of shrinkage and selection priors on interactions in STC.
##
## Source trial A versus C, N per arm, eight independent N(0, 1) covariates.
## y = 0.5 sum x + A (-0.5 + sum_m beta_m x_m) + e, e ~ N(0, 1): one strong
## modifier (0.5) or three moderate (0.25). Target covariate means 0.5.
## Estimand: A versus C in the target, -0.5 + 0.5 sum_m beta_m.
## Model: y ~ main effects (flat prior) + A + A:x_j, residual SD plugged in from
## the full least-squares fit. Priors on the eight interactions:
##   flat           ordinary least squares, all interactions
##   eb_ridge       N(0, tau^2) with tau^2 set by maximizing the marginal likelihood
##   hier_normal    N(0, tau^2) with tau integrated over a grid (half-Cauchy(0, 0.5))
##   spike_slab     each interaction in or out (prior 0.5), slab N(0, 0.5^2);
##                  exact model averaging over the 256 inclusion patterns
##   median_model   interactions with posterior inclusion above 0.5, then the
##                  conditional posterior given that model (selection)
## Intervals: central 95% posterior intervals for the target effect (normal or
## normal mixtures).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261104L; P <- 8L; M_T <- 0.5; N_SIM <- 1000L
LEVELS <- list(n = c(100L, 300L), pattern = c("one_strong", "three_moderate"))
build_grid <- function() { g <- expand.grid(n = LEVELS$n, pattern = LEVELS$pattern, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
betas <- function(cell) if (cell$pattern == "one_strong") c(0.5, rep(0, P - 1)) else c(rep(0.25, 3), rep(0, P - 3))
truth <- function(cell) -0.5 + M_T * sum(betas(cell))

draw <- function(cell) { n <- 2 * cell$n; X <- matrix(stats::rnorm(n * P), n); A <- rep(0:1, each = cell$n)
  y <- 0.5 * rowSums(X) + A * (-0.5 + X %*% betas(cell)) + stats::rnorm(n); list(X = X, A = A, y = as.vector(y)) }

## Posterior of all coefficients with flat priors on the first q columns and
## N(0, v_j) priors on the rest (v = Inf means flat); returns mean and covariance.
post <- function(Z, y, s2, v) { prec <- crossprod(Z) / s2; diag(prec) <- diag(prec) + ifelse(is.finite(v), 1 / v, 0)
  S <- solve(prec); list(m = drop(S %*% crossprod(Z, y) / s2), S = S) }
logml <- function(Z0, Zi, y, s2, v) { ## marginal likelihood of y integrating the interaction coefficients (flat main effects profiled)
  if (ncol(Zi) == 0) { r <- y - Z0 %*% qr.solve(Z0, y); return(-sum(r^2) / (2 * s2)) }
  Z <- cbind(Z0, Zi); p <- post(Z, y, s2, c(rep(Inf, ncol(Z0)), rep(v, ncol(Zi))))
  r <- y - Z %*% p$m; pen <- sum(p$m[-(1:ncol(Z0))]^2) / v
  -sum(r^2) / (2 * s2) - pen / 2 - 0.5 * ncol(Zi) * log(v) + 0.5 * as.numeric(determinant(p$S, logarithm = TRUE)$modulus) -
    0.5 * as.numeric(determinant(post(Z0, y, s2, rep(Inf, ncol(Z0)))$S, logarithm = TRUE)$modulus) }
PATS <- as.matrix(expand.grid(rep(list(0:1), P)))
fit_all <- function(cell, d) {
  Z0 <- cbind(1, d$X, d$A); Zi <- d$X * d$A; Z <- cbind(Z0, Zi); q <- ncol(Z0)
  s2 <- sum(stats::lm.fit(Z, d$y)$residuals^2) / (nrow(Z) - ncol(Z))
  a <- c(rep(0, q - 1), 1, rep(M_T, P))                                          # target effect: A coefficient + M_T * interactions
  ci_norm <- function(p) { m <- sum(a * p$m); s <- sqrt(drop(t(a) %*% p$S %*% a)); c(m, m - 1.96 * s, m + 1.96 * s) }
  out <- list(flat = ci_norm(post(Z, d$y, s2, rep(Inf, ncol(Z)))))
  taus <- exp(seq(log(0.01), log(2), length.out = 40))
  lm_t <- sapply(taus, function(t) logml(Z0, Zi, d$y, s2, t^2))
  tb <- taus[which.max(lm_t)]; out$eb_ridge <- ci_norm(post(Z, d$y, s2, c(rep(Inf, q), rep(tb^2, P))))
  ## Normal mixtures: mean and quantiles by sampling from the mixture (4000 draws).
  mixture <- function(wts, comps) { k <- sample.int(length(wts), 4000, replace = TRUE, prob = wts)
    ms <- sapply(comps, `[`, 1); ss <- sapply(comps, `[`, 2); dr <- stats::rnorm(4000, ms[k], ss[k]); c(mean(dr), stats::quantile(dr, c(0.025, 0.975))) }
  lw <- lm_t + stats::dcauchy(taus, 0, 0.5, log = TRUE) + log(taus); w <- exp(lw - max(lw))
  comps <- lapply(taus, function(t) { p <- post(Z, d$y, s2, c(rep(Inf, q), rep(t^2, P))); c(sum(a * p$m), sqrt(drop(t(a) %*% p$S %*% a))) })
  out$hier_normal <- mixture(w, comps)
  lmp <- apply(PATS, 1, function(g) logml(Z0, Zi[, g == 1, drop = FALSE], d$y, s2, 0.25)); wp <- exp(lmp - max(lmp)); wp <- wp / sum(wp)
  compsp <- lapply(seq_len(nrow(PATS)), function(r) { g <- PATS[r, ]; Zg <- cbind(Z0, Zi[, g == 1, drop = FALSE]); p <- post(Zg, d$y, s2, c(rep(Inf, q), rep(0.25, sum(g))))
    ag <- c(rep(0, q - 1), 1, rep(M_T, sum(g))); c(sum(ag * p$m), sqrt(drop(t(ag) %*% p$S %*% ag))) })
  out$spike_slab <- mixture(wp, compsp)
  pip <- colSums(PATS * wp); g <- as.integer(pip > 0.5); r <- which(apply(PATS, 1, function(x) all(x == g)))
  out$median_model <- c(compsp[[r]][1], compsp[[r]][1] - 1.96 * compsp[[r]][2], compsp[[r]][1] + 1.96 * compsp[[r]][2])
  do.call(rbind, lapply(names(out), function(k) data.frame(method = k, est = out[[k]][1], lo = out[[k]][2], hi = out[[k]][3], n_sel = sum(g))))
}
