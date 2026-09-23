## ---------------------------------------------------------------------------
## MOD-02: parametric and flexible outcome models for transporting a treatment
## effect, under adversarial response surfaces.
##
## Source trial A versus C, 300 per arm, x1, x2 ~ N(0, 1) independent. Binary outcome
##   logit p = -0.6 + 0.5 x1 + 0.3 x2 + PROG(x) + a (-0.6 + 0.3 x1 + MOD(x)),
## with one adversarial feature at a time:
##   none   PROG = MOD = 0
##   A      PROG = 0.8 * I(x1 > 1)                  (threshold prognostic)
##   B      MOD  = 0.8 * max(x1 - 0.5, 0)           (hinge effect modification)
##   C      MOD  = 0.4 * x1 * x2                    (covariate-by-covariate modification)
## Target: x1 ~ N(MU, 1), x2 ~ N(MU / 2, 1), MU = 0.5, 1, 1.5 (good, moderate, poor
## overlap), known through its marginals (normal, independent: correct here).
## Estimand: target marginal log odds ratio, A versus C.
## Methods, each marginalized over the target by G-computation, with delta-method
## SEs from the coefficient covariance (the Bayesian covariance for GAMs):
##   stc         logistic, linear main effects and treatment interactions
##   gam_full    smooth prognostic terms and smooth treatment interactions (mgcv, REML)
##   gam_struct  smooth prognostic terms, linear treatment interactions
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(mgcv))
MASTER_SEED <- 20261204L; N_ARM <- 300L; N_SIM <- 500L
build_grid <- function() { g <- expand.grid(surface = c("none", "A", "B", "C"), mu = c(0.5, 1, 1.5), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
eta <- function(x1, x2, a, s) { prog <- if (s == "A") 0.8 * (x1 > 1) else 0
  mod <- switch(s, B = 0.8 * pmax(x1 - 0.5, 0), C = 0.4 * x1 * x2, 0)
  -0.6 + 0.5 * x1 + 0.3 * x2 + prog + a * (-0.6 + 0.3 * x1 + mod) }
truth <- function(cell) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; set.seed(99)
  x1 <- stats::rnorm(2e6, cell$mu); x2 <- stats::rnorm(2e6, cell$mu / 2); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  stats::qlogis(mean(stats::plogis(eta(x1, x2, 1, cell$surface)))) - stats::qlogis(mean(stats::plogis(eta(x1, x2, 0, cell$surface)))) }
target_pts <- function(mu) { u <- stats::qnorm(stats::ppoints(60)); g <- expand.grid(x1 = mu + u, x2 = mu / 2 + u); g }
draw <- function(cell) { x1 <- stats::rnorm(2 * N_ARM); x2 <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM)
  data.frame(x1 = x1, x2 = x2, A = A, y = stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(x1, x2, A, cell$surface)))) }

## G-computation of the marginal log OR over target points Z, with a delta-method SE,
## from a linear predictor matrix function lp(Z, a) and coefficients b, covariance V.
gcomp <- function(M1, M0, b, V) { p1 <- stats::plogis(drop(M1 %*% b)); p0 <- stats::plogis(drop(M0 %*% b)); q1 <- mean(p1); q0 <- mean(p0)
  g <- colMeans(M1 * (p1 * (1 - p1))) / (q1 * (1 - q1)) - colMeans(M0 * (p0 * (1 - p0))) / (q0 * (1 - q0))
  c(est = stats::qlogis(q1) - stats::qlogis(q0), se = sqrt(drop(t(g) %*% V %*% g))) }
fit_all <- function(d, mu) {
  Z <- target_pts(mu); Z1 <- transform(Z, A = 1); Z0 <- transform(Z, A = 0)
  f1 <- stats::glm(y ~ (x1 + x2) * A, family = stats::binomial(), data = d)
  mm <- function(z) stats::model.matrix(~ (x1 + x2) * A, z)
  out <- list(stc = gcomp(mm(Z1), mm(Z0), stats::coef(f1), stats::vcov(f1)))
  d$Af <- factor(d$A); Z1$Af <- factor(1, levels = 0:1); Z0$Af <- factor(0, levels = 0:1)
  f2 <- mgcv::gam(y ~ Af + s(x1, k = 8) + s(x2, k = 8) + s(x1, by = Af, k = 8) + s(x2, by = Af, k = 8), family = stats::binomial(), data = d, method = "REML")
  out$gam_full <- gcomp(stats::predict(f2, Z1, type = "lpmatrix"), stats::predict(f2, Z0, type = "lpmatrix"), stats::coef(f2), f2$Vp)
  f3 <- mgcv::gam(y ~ A + s(x1, k = 8) + s(x2, k = 8) + A:x1 + A:x2, family = stats::binomial(), data = d, method = "REML")
  out$gam_struct <- gcomp(stats::predict(f3, Z1, type = "lpmatrix"), stats::predict(f3, Z0, type = "lpmatrix"), stats::coef(f3), f3$Vp)
  do.call(rbind, lapply(names(out), function(m) data.frame(method = m, est = out[[m]][["est"]], se = out[[m]][["se"]])))
}
one_rep <- function(cell) fit_all(draw(cell), cell$mu)
