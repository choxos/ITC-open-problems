## ---------------------------------------------------------------------------
## ADJ-15: target moments released under differential privacy.
##
## The target trial releases covariate means (and optionally second moments) with
## Laplace noise of known scale. MAIC to the noisy moments estimates the effect in
## the wrong population by g'(m_noisy - m), g = d Delta / d m, so the variance to
## add is g' Sigma_noise g with Sigma_noise known exactly: 2 b^2 per released
## statistic, b = sensitivity / epsilon_j. The truth is the effect at the target
## trial's own (non-private) moments, so sampling error of those moments is not
## part of this study (MIS-03 and EST-07 own it).
##
## Budget: epsilon split equally over the p released statistics (sequential
## composition). Covariates are clipped to [-CLIP, CLIP], so the sensitivity of a
## mean over N_T records is 2 CLIP / N_T and of a second moment CLIP^2 / N_T.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261003L
CLIP <- 3; P <- 2L
N_SRC <- 200L                     # per arm, source trial
DELTA <- -0.4; GAMMA <- 0.5; B1 <- 0.4
MU_T <- c(0.5, 0.5); SD_T <- 0.8  # target covariate law before clipping
N_SIM <- 1000L
LEVELS <- list(n_t = c(40L, 150L, 500L), eps = c(0.5, 1, 4, Inf),
               release = c("means", "means_sds"), em = c("linear", "quadratic"))

build_grid <- function() {
  g <- expand.grid(n_t = LEVELS$n_t, eps = LEVELS$eps, release = LEVELS$release, em = LEVELS$em,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
B2 <- function(cell) if (cell$em == "quadratic") 0.3 else 0

clip <- function(x) pmin(pmax(x, -CLIP), CLIP)
## A versus C conditional effect: DELTA + B1 x1 + B2 x1^2.
draw_source <- function(cell) {
  X <- clip(matrix(stats::rnorm(2 * N_SRC * P), ncol = P)); A <- rep(0:1, each = N_SRC)
  y <- GAMMA * rowSums(X) + A * (DELTA + B1 * X[, 1] + B2(cell) * X[, 1]^2) + stats::rnorm(2 * N_SRC)
  list(X = X, A = A, y = y)
}
draw_target_moments <- function(cell) {
  XT <- clip(sweep(matrix(stats::rnorm(cell$n_t * P, 0, SD_T), ncol = P), 2, MU_T, "+"))
  list(m1 = colMeans(XT), m2 = colMeans(XT^2))
}
truth <- function(cell, tm) DELTA + B1 * tm$m1[1] + B2(cell) * tm$m2[1]

laplace <- function(n, b) b * (stats::rexp(n) - stats::rexp(n))

release <- function(cell, tm) {
  p <- if (cell$release == "means") P else 2 * P
  if (is.infinite(cell$eps)) return(list(m1 = tm$m1, m2 = tm$m2, b1 = 0, b2 = 0))
  e <- cell$eps / p
  b1 <- 2 * CLIP / (cell$n_t * e); b2 <- CLIP^2 / (cell$n_t * e)
  list(m1 = tm$m1 + laplace(P, b1),
       m2 = if (cell$release == "means_sds") tm$m2 + laplace(P, b2) else NA,
       b1 = b1, b2 = b2)
}

tilt <- function(H, target) {
  Hc <- sweep(H, 2, target)
  f <- function(a) { z <- Hc %*% a; mx <- max(z); log(sum(exp(z - mx))) + mx }
  gr <- function(a) { z <- Hc %*% a; w <- exp(z - max(z)); colSums(Hc * as.vector(w)) / sum(w) }
  o <- stats::optim(rep(0, ncol(Hc)), f, gr, method = "BFGS", control = list(reltol = 1e-14))
  z <- Hc %*% o$par; w <- as.vector(exp(z - max(z)))
  list(w = w, ok = max(abs(colSums(Hc * w) / sum(w))) < 1e-4)
}

maic_est <- function(s, target, use_m2) {
  H <- if (use_m2) cbind(s$X, s$X^2) else s$X
  tw <- tilt(H, target); w <- tw$w
  m1 <- sum(w * s$A * s$y) / sum(w * s$A); m0 <- sum(w * (1 - s$A) * s$y) / sum(w * (1 - s$A))
  v <- sum(w^2 * s$A * (s$y - m1)^2) / sum(w * s$A)^2 + sum(w^2 * (1 - s$A) * (s$y - m0)^2) / sum(w * (1 - s$A))^2
  c(est = m1 - m0, var = v, ok = tw$ok)
}

fit_all <- function(cell, s, tm) {
  use_m2 <- cell$release == "means_sds"
  exact_t <- if (use_m2) c(tm$m1, tm$m2) else tm$m1
  r <- release(cell, tm)
  noisy_t <- if (use_m2) c(r$m1, pmax(r$m2, r$m1^2 + 1e-3)) else r$m1
  np <- maic_est(s, exact_t, use_m2)
  pr <- maic_est(s, noisy_t, use_m2)
  ## Propagation: gradient of the estimate in the released statistics by central
  ## differences, times the known noise variance 2 b^2 per statistic.
  h <- 1e-3; k <- length(noisy_t)
  gr <- vapply(seq_len(k), function(j) {
    e <- replace(rep(0, k), j, h)
    (maic_est(s, noisy_t + e, use_m2)[["est"]] - maic_est(s, noisy_t - e, use_m2)[["est"]]) / (2 * h)
  }, 0)
  nv <- c(rep(2 * r$b1^2, P), if (use_m2) rep(2 * r$b2^2, P))
  prop_var <- pr[["var"]] + sum(gr^2 * nv)
  z <- stats::qnorm(0.975)
  data.frame(method = c("non_private", "private_ignored", "private_propagated"),
             est = c(np[["est"]], pr[["est"]], pr[["est"]]),
             se = sqrt(c(np[["var"]], pr[["var"]], prop_var)),
             ok = c(np[["ok"]], pr[["ok"]], pr[["ok"]]))
}
