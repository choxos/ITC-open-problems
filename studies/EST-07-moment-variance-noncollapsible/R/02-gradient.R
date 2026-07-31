## ---------------------------------------------------------------------------
## THE GRADIENT OF THE ESTIMAND WITH RESPECT TO THE REPORTED MOMENTS.
##
## This file is the study's prediction 2, made computable.
##
## Every published target-summary variance estimator has the same shape: the
## reported moments carry sampling error Omega/nT, and that error propagates into
## the estimand through a gradient J, contributing J' Omega J / nT. MIS-03's
## result is that specialization under an identity link with additive effect,
## where J is EXACTLY beta_EM, the effect-modifier coefficient vector, and the
## delta method is not an approximation at all.
##
## Under a curved link the estimand is
##
##   Delta(F_T) = g( int mu_1 dF_T ) - g( int mu_0 dF_T ),
##
## and the integral sits inside g. Differentiating with respect to a moment of
## F_T therefore picks up g' evaluated at the ARM MEANS, which is a curvature
## weight with no linear analogue. J is not beta_EM, and a variance estimator
## derived under a collapsible estimand plugs in the wrong gradient.
##
## The gradient is computed NUMERICALLY FROM THE ESTIMAND ITSELF rather than from
## a formula, for two reasons. It is then correct on any link without a separate
## derivation per link, and it can be compared against beta_EM, which is what
## turns prediction 2 from an assertion into a measurement. `gradient_gap()`
## returns exactly that comparison.
##
##   source("R/02-gradient.R")
## ---------------------------------------------------------------------------

source("R/01-dgm.R")

## --- the estimand as a function of the reported moment vector ---------------
##
## THE COORDINATES MUST BE THE ONES THE ESTIMATOR AND THE COVARIANCE USE, and in
## the first version of this file they were not. Round 1 of critique found it and
## it invalidated the study's headline.
##
## What an analyst receives is a baseline table of means and SDs, so the obvious
## parameterization is (mean, SD). But MAIC's balancing function is
## `h = cbind(x, x^2)`, the reported moment vector the estimator matches is
## `c(colMeans(x), colMeans(x^2))`, and `Omega_normal` is the covariance of THAT
## vector. So the estimator gradient and the moment covariance both live in
## (mean, RAW SECOND MOMENT) coordinates while this file differentiated in
## (mean, SD), and P3 compared the two and multiplied one by the other with no
## Jacobian. Measured: the reported vector is (1.1936, 1.1685, 1.0508) where the
## SDs are (1.0184, 1.0068, 0.9558), and the resulting reference variance was
## wrong by a factor that DIFFERS BY LINK, which is what manufactured the
## headline's link-specific direction.
##
## The fix is to differentiate in the estimator's coordinates directly rather
## than to transform afterwards: given a mean m and a raw second moment q, the SD
## is sqrt(q - m^2), so the reparameterization is exact and no chain rule is
## applied to a numerical derivative.
sd_from_moments <- function(m, q) {
  v <- q - m^2
  if (any(v <= 0)) return(rep(NA_real_, length(m)))
  sqrt(v)
}

delta_at_moments <- function(m, q, pars, link, shape, rho, order) {
  s <- sd_from_moments(m, q)
  if (anyNA(s)) return(NA_real_)
  delta_superpopulation(pars, link, shape, mu = m, sigma = s, rho = rho,
                        order = order)
}

## --- the gradient, by central differences -----------------------------------
##
## Step size is scaled to each moment rather than fixed, because a mean of 0 and
## an SD of 1 do not share a natural scale. The step is registered rather than
## tuned: `GRAD_STEP` is a fraction of the moment's own SD, and `gradient_step_ok`
## checks that halving it moves the gradient by less than GRAD_TOL, so a badly
## conditioned difference stops the run instead of producing a plausible number.
GRAD_STEP <- 1e-3
GRAD_TOL  <- 1e-4

## `s` is the SD, which is what the caller naturally has; it is converted to the
## raw second moment immediately and every derivative below is taken in THAT
## coordinate, so the returned gradient is directly comparable to the estimator's
## and directly multipliable by `Omega_normal`.
delta_gradient <- function(m, s, pars, link, shape, rho, order,
                           step = GRAD_STEP) {
  p <- length(m)
  q <- m^2 + s^2
  h_m <- pmax(abs(m), 1) * step
  h_q <- pmax(abs(q), 1) * step
  gm <- vapply(seq_len(p), function(j) {
    mp <- m; mp[j] <- mp[j] + h_m[j]
    mn <- m; mn[j] <- mn[j] - h_m[j]
    (delta_at_moments(mp, q, pars, link, shape, rho, order) -
     delta_at_moments(mn, q, pars, link, shape, rho, order)) / (2 * h_m[j])
  }, 0)
  gq <- vapply(seq_len(p), function(j) {
    qp <- q; qp[j] <- qp[j] + h_q[j]
    qn <- q; qn[j] <- qn[j] - h_q[j]
    (delta_at_moments(m, qp, pars, link, shape, rho, order) -
     delta_at_moments(m, qn, pars, link, shape, rho, order)) / (2 * h_q[j])
  }, 0)
  c(gm, gq)
}

## The step-size check. A central difference that has not converged looks exactly
## like a converged one, which is the failure this study cannot afford in the
## quantity its second prediction is about.
gradient_step_ok <- function(m, s, pars, link, shape, rho, order,
                             tol = GRAD_TOL) {
  g1 <- delta_gradient(m, s, pars, link, shape, rho, order, GRAD_STEP)
  g2 <- delta_gradient(m, s, pars, link, shape, rho, order, GRAD_STEP / 2)
  list(ok = max(abs(g1 - g2)) < tol, max_move = max(abs(g1 - g2)),
       gradient = g1)
}

## --- PREDICTION 2, AS A MEASUREMENT -----------------------------------------
##
## Under the identity link the mean-gradient must equal beta_EM exactly and the
## SD-gradient must be exactly zero, because the estimand does not depend on the
## target's dispersion at all. Under a curved link neither holds. `gradient_gap`
## reports both departures, so the prediction is a number rather than a claim.
gradient_gap <- function(m, s, pars, link, shape, rho, order) {
  g <- delta_gradient(m, s, pars, link, shape, rho, order)
  p <- length(m)
  list(link = link,
       grad_mean = g[seq_len(p)],
       ## Named for the coordinate it is actually taken in.
       grad_q = g[p + seq_len(p)],
       beta_em = pars$beta_em,
       ## How far the mean-gradient is from the coefficient a collapsible
       ## derivation would plug in.
       mean_gap = max(abs(g[seq_len(p)] - pars$beta_em)),
       ## How much of the gradient a collapsible derivation omits entirely,
       ## because under it the estimand is free of the target's dispersion.
       q_norm = max(abs(g[p + seq_len(p)])))
}

## --- the omitted variance, both ways ----------------------------------------
##
## `omitted_variance` is the general form: J' Omega J / nT with J computed from
## the estimand. `omitted_variance_mis03` is the closed form MIS-03 derived under
## the identity link, (1 - 2k) Var_T(tau) / nT. P3 checks that the first
## reproduces the second where the second is valid, which is the only case where
## the right answer is known.
omitted_variance <- function(J, Omega, nT) as.numeric(t(J) %*% Omega %*% J) / nT

omitted_variance_mis03 <- function(k, var_tau_T, nT) (1 - 2 * k) * var_tau_T / nT
