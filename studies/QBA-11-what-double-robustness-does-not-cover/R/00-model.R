## ---------------------------------------------------------------------------
## QBA-11: which failures double robustness covers.
##
## Unanchored: individual data on arm A in the source (n = 300); the target
## publishes covariate means and SDs. Continuous outcome
##   y = 1 + 0.5 x1 + 0.5 x2 + KAPPA (x1^2 - 1) + GAMMA u + e,
## x1, x2 ~ N(0, 1) in the source; in the target x1 ~ N(MU1_T, 0.7^2),
## x2 ~ N(0.3, 1). u is an omitted binary covariate, prevalence P_S in the source
## and P_T in the target, independent of x. Estimand: mean of Y(A) in the target;
## B's published mean is subtracted in practice and adds only noise.
##
## Nuisance models. Weighting: exponential tilting on means only (wrong: the
## density ratio needs x1^2 because the variances differ) or on means and second
## moments (correct). Outcome: linear in x (wrong: omits x1^2) or with x1^2
## (correct). Every consistent estimator converges to the observed-data functional
## Delta*(gamma), which differs from the truth by GAMMA (P_S - P_T).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261014L
N <- 300L; KAPPA <- 0.4; SD1_T <- 0.7; MU2_T <- 0.3; P_T <- 0.3
N_SIM <- 2000L
LEVELS <- list(gamma = c(0, 0.25, 0.5, 1), imbalance = c(0.1, 0.3), mu1_t = c(0.5, 1.0))
## Declared sensitivity region: gamma' in [0, 1], imbalance' in [0, 0.3].
G_MAX <- 1; D_MAX <- 0.3

build_grid <- function() {
  g <- expand.grid(gamma = LEVELS$gamma, imbalance = LEVELS$imbalance, mu1_t = LEVELS$mu1_t, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
truth <- function(cell) 1 + 0.5 * cell$mu1_t + 0.5 * MU2_T + KAPPA * (SD1_T^2 + cell$mu1_t^2 - 1) + cell$gamma * P_T
functional <- function(cell) truth(cell) + cell$gamma * cell$imbalance     # Delta*(gamma)

draw <- function(cell) {
  x1 <- stats::rnorm(N); x2 <- stats::rnorm(N); u <- stats::rbinom(N, 1, P_T + cell$imbalance)
  data.frame(x1 = x1, x2 = x2, y = 1 + 0.5 * x1 + 0.5 * x2 + KAPPA * (x1^2 - 1) + cell$gamma * u + stats::rnorm(N))
}

tilt <- function(X, m) { Xc <- sweep(X, 2, m)
  o <- stats::optim(rep(0, ncol(X)), function(a) sum(exp(Xc %*% a)), function(a) colSums(Xc * as.vector(exp(Xc %*% a))),
                    method = "BFGS", control = list(maxit = 500))
  w <- as.vector(exp(Xc %*% o$par)); w / sum(w) }

fit_all <- function(cell, d) {
  m1 <- cell$mu1_t; s1 <- SD1_T^2 + m1^2
  w_wrong <- tilt(cbind(d$x1, d$x2), c(m1, MU2_T))
  w_right <- tilt(cbind(d$x1, d$x2, d$x1^2, d$x2^2), c(m1, MU2_T, s1, 1 + MU2_T^2))
  f_wrong <- stats::lm(y ~ x1 + x2, data = d); f_right <- stats::lm(y ~ x1 + x2 + I(x1^2), data = d)
  tgt_wrong <- sum(stats::coef(f_wrong) * c(1, m1, MU2_T))
  tgt_right <- sum(stats::coef(f_right) * c(1, m1, MU2_T, s1))
  aug <- function(w, f, tgt) tgt + sum(w * (d$y - stats::fitted(f)))
  c(maic_wrong = sum(w_wrong * d$y), maic_right = sum(w_right * d$y),
    or_wrong = tgt_wrong, or_right = tgt_right,
    dr_both_right = aug(w_right, f_right, tgt_right), dr_w_wrong = aug(w_wrong, f_right, tgt_right),
    dr_o_wrong = aug(w_right, f_wrong, tgt_wrong), dr_both_wrong = aug(w_wrong, f_wrong, tgt_wrong),
    ess_right = 1 / sum(w_right^2) / N)
}
