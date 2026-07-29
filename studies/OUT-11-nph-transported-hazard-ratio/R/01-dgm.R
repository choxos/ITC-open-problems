## ---------------------------------------------------------------------------
## Data-generating mechanism, and the exact target-population truth.
##
## THE PARAMETERISATION IS THE ONE THE FIRST DESIGN GOT WRONG.
##
## The first draft put the treatment on the Weibull shape and log-scale
## directly: shape a_k = nu0 exp(phi_k), log-scale lambda_j + d_k + gamma_k x.
## A pre-run critique showed by algebra that the resulting log hazard ratio is
##
##   log HR_k(t, x) = log(a_k/a_0) - a_k(d_k + gamma_k x)
##                    - (a_k - a_0) lambda_j + (a_k - a_0) log t,
##
## which contains the STUDY BASELINE lambda_j whenever the shapes differ. The
## treatment contrast would therefore have varied across studies purely
## mechanically, manufacturing treatment-by-study inconsistency that none of the
## fitted models allows and that is not the phenomenon under study. Verified:
## the log HR moved from -0.696 to -0.972 across baselines of log(8) to log(18),
## a spread of -0.2764, matching the predicted (a_0 - a_B)(lambda_2 - lambda_1)
## to four decimals.
##
## The fix, also from that critique, is to build the treatment arm as a
## STUDY-INVARIANT multiplier on the study's own placebo hazard:
##
##   h_jk(t, x) = h_j0(t) * exp( beta_k + kappa_k * g(t) + gamma_k * x )
##
## so the contrast is exactly beta_k + kappa_k g(t) + gamma_k x with no lambda_j
## in it, by construction. Two further properties make this better than a patch:
##
##   * kappa_k ISOLATES non-proportionality. At t = t0, g(t0) = 0, so the log
##     hazard ratio is beta_k + gamma_k x whatever kappa_k is. The first design
##     could not vary non-proportionality without also moving the average effect
##     and the effect-modifier strength, because both were multiplied by the
##     treatment-specific shape.
##   * kappa_k = 0 gives exact conditional proportional hazards, so the
##     proportional cell is a special case of the same mechanism.
##
## g(t) is chosen per family so the result stays in that family in closed form,
## which keeps the truth exact:
##   Weibull  g(t) = log(t / t0)      -> Weibull, shape a0 + kappa
##   Gompertz g(t) = (t - t0) / t0    -> Gompertz, rate xi + kappa / t0
##
## Every "true" quantity is computed by quadrature, never simulated. A truth
## estimated from a large sample carries Monte Carlo error into every reported
## bias. `verify_truth()` checks the quadrature against brute force and runs at
## analysis time rather than once by hand.
## ---------------------------------------------------------------------------

T0 <- 12          # reference time at which the log hazard ratio is beta_k

## --- conditional survival, by family -------------------------------------------
## Each returns the Weibull/Gompertz parameters of arm k in study j at covariate
## x, so simulation uses the standard r*() and the truth uses the closed form.
## Nothing here is approximate.

## Weibull placebo h_j0(t) = (a0/s_j)(t/s_j)^(a0-1);
## multiplier exp(beta + kappa log(t/t0) + gamma x) gives Weibull(a0 + kappa, .)
weib_pars <- function(x, a0, s_j, beta, kappa, gamma) {
  nu <- a0 + kappa
  stopifnot(all(nu > 0))
  scale <- ((nu * T0^kappa * s_j^a0 * exp(-beta - gamma * x)) / a0)^(1 / nu)
  list(shape = nu, scale = scale)
}
weib_S <- function(t, x, a0, s_j, beta, kappa, gamma) {
  p <- weib_pars(x, a0, s_j, beta, kappa, gamma)
  exp(-(t / p$scale)^p$shape)
}
weib_h <- function(t, x, a0, s_j, beta, kappa, gamma) {
  p <- weib_pars(x, a0, s_j, beta, kappa, gamma)
  (p$shape / p$scale) * (t / p$scale)^(p$shape - 1)
}

## Gompertz placebo h_j0(t) = b_j exp(xi t);
## multiplier exp(beta + kappa (t-t0)/t0 + gamma x) gives Gompertz(xi + kappa/t0, .)
gomp_pars <- function(x, xi, b_j, beta, kappa, gamma) {
  rate  <- xi + kappa / T0
  scale <- b_j * exp(beta - kappa + gamma * x)
  list(rate = rate, scale = scale)
}
gomp_S <- function(t, x, xi, b_j, beta, kappa, gamma) {
  p <- gomp_pars(x, xi, b_j, beta, kappa, gamma)
  if (abs(p$rate) < 1e-10) return(exp(-p$scale * t))
  exp(-p$scale / p$rate * (exp(p$rate * t) - 1))
}
gomp_h <- function(t, x, xi, b_j, beta, kappa, gamma) {
  p <- gomp_pars(x, xi, b_j, beta, kappa, gamma)
  p$scale * exp(p$rate * t)
}

## One interface, so every downstream function is family-agnostic and the family
## is a design factor rather than a fork in the code.
arm_S <- function(t, x, arm) switch(arm$family,
  weibull  = weib_S(t, x, arm$a0, arm$s_j, arm$beta, arm$kappa, arm$gamma),
  gompertz = gomp_S(t, x, arm$xi, arm$b_j, arm$beta, arm$kappa, arm$gamma))
arm_h <- function(t, x, arm) switch(arm$family,
  weibull  = weib_h(t, x, arm$a0, arm$s_j, arm$beta, arm$kappa, arm$gamma),
  gompertz = gomp_h(t, x, arm$xi, arm$b_j, arm$beta, arm$kappa, arm$gamma))

## --- the target population ------------------------------------------------------
## Gauss-Hermite over a NORMAL target law. That the target is normal is an
## ASSUMPTION, not something means and standard deviations imply; a critique
## noted the first draft left it unstated. Inside this study the quadrature law
## and the generating law are the same normal by construction, so the truth and
## the estimators target the same population. In an application they need not be,
## and that is a limitation rather than a property of the method.
gh_nodes <- function(n = 64) {
  i <- seq_len(n - 1); J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- sqrt(i / 2); J[cbind(i + 1, i)] <- sqrt(i / 2)
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = sqrt(pi) * (e$vectors[1, o])^2)
}
GH <- gh_nodes(64)
E_x <- function(g, mu, sd) {
  xs <- mu + sqrt(2) * sd * GH$x
  sum(GH$w * g(xs)) / sqrt(pi)
}

gl_nodes <- function(n = 128) {
  i <- seq_len(n - 1); b <- i / sqrt(4 * i^2 - 1); J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- b; J[cbind(i + 1, i)] <- b
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = 2 * (e$vectors[1, o])^2)
}
GL <- gl_nodes(128)

## --- marginal (target-standardized) quantities ----------------------------------

## S_bar(t) = E_x[S(t|x)]: population-average survival, NOT survival at the
## average covariate. Confusing the two is the standard error in this area.
surv_marg <- function(t, mu, sd, arm)
  vapply(t, function(u) E_x(function(x) arm_S(u, x, arm), mu, sd), numeric(1))

## The MARGINAL hazard is -d/dt log S_bar(t) = E[h(t|x) S(t|x)] / E[S(t|x)],
## which weights each covariate value by the probability of still being at risk.
## It is NOT the average of the conditional hazards. That risk-set weighting is
## exactly why a marginal hazard ratio is time-varying even when the conditional
## model is proportional, which is the distinction the catalog entry's auditors
## insisted on and which an earlier draft of this file blurred.
haz_marg <- function(t, mu, sd, arm)
  vapply(t, function(u) {
    num <- E_x(function(x) arm_h(u, x, arm) * arm_S(u, x, arm), mu, sd)
    den <- E_x(function(x) arm_S(u, x, arm), mu, sd)
    num / den
  }, numeric(1))

rmst_marg <- function(tau, mu, sd, arm) {
  tt <- tau / 2 * (GL$x + 1)
  sum(GL$w * surv_marg(tt, mu, sd, arm)) * tau / 2
}

## --- the estimands ---------------------------------------------------------------
truth_at <- function(arm_ref, arm_cmp, mu, sd, tau, t_star, hr_grid) {
  r0 <- rmst_marg(tau, mu, sd, arm_ref); r1 <- rmst_marg(tau, mu, sd, arm_cmp)
  s0 <- surv_marg(t_star, mu, sd, arm_ref); s1 <- surv_marg(t_star, mu, sd, arm_cmp)
  h0 <- haz_marg(hr_grid, mu, sd, arm_ref); h1 <- haz_marg(hr_grid, mu, sd, arm_cmp)
  hr <- h1 / h0
  s  <- sign(log(hr)); k <- which(diff(s) != 0)
  list(rmst_ref = r0, rmst_cmp = r1, rmst_diff = r1 - r0,
       surv_ref = s0, surv_cmp = s1, surv_diff = s1 - s0,
       hr_t = hr, hr_grid = hr_grid,
       cross_time = if (length(k)) hr_grid[k[1]] else NA_real_,
       hr_min = min(hr), hr_max = max(hr))
}

## --- simulation -------------------------------------------------------------------
## Censoring is independent, exponential with a per-study rate, plus a common
## administrative cutoff. It touches nothing in any survival function, so the
## true estimand is invariant to it by construction, which is what makes the
## censoring factor a manipulation of a nuisance.
sim_arm <- function(n, x, arm, cens_rate, t_admin) {
  tt <- switch(arm$family,
    weibull  = { p <- weib_pars(x, arm$a0, arm$s_j, arm$beta, arm$kappa, arm$gamma)
                 rweibull(n, shape = p$shape, scale = p$scale) },
    gompertz = { p <- gomp_pars(x, arm$xi, arm$b_j, arm$beta, arm$kappa, arm$gamma)
                 u <- runif(n)
                 if (abs(p$rate) < 1e-10) -log(u) / p$scale
                 else log1p(-p$rate * log(u) / p$scale) / p$rate })
  cen <- if (cens_rate > 0) rexp(n, rate = cens_rate) else rep(Inf, n)
  cen <- pmin(cen, t_admin)
  data.frame(time = pmin(tt, cen), status = as.integer(tt <= cen), x1 = x)
}

## --- verification -----------------------------------------------------------------
## Three properties, all checked rather than asserted, because the first design
## failed the first of them and nothing downstream would have noticed.

## 1. The treatment contrast does not depend on the study baseline.
verify_invariance <- function(tol = 1e-10) {
  worst <- 0
  for (fam in c("weibull", "gompertz")) {
    for (kap in c(-0.3, 0, 0.3)) {
      lhr <- vapply(c(8, 12, 18), function(base) {
        ref <- cmp <- list(family = fam, a0 = 1.2, s_j = base, xi = 0.05,
                           b_j = 1 / base, beta = 0, kappa = 0, gamma = 0)
        cmp$beta <- -0.35; cmp$kappa <- kap; cmp$gamma <- 0.30
        log(arm_h(6, 0.5, cmp) / arm_h(6, 0.5, ref))
      }, numeric(1))
      worst <- max(worst, diff(range(lhr)))
    }
  }
  if (worst > tol) stop(sprintf("contrast depends on study baseline by %.3g", worst))
  worst
}

## 2. kappa isolates time-dependence: at t = T0 the log HR is beta + gamma x
##    whatever kappa is.
verify_kappa_isolates <- function(tol = 1e-10) {
  worst <- 0
  for (fam in c("weibull", "gompertz")) {
    lhr <- vapply(c(-0.3, 0, 0.3, 0.6), function(kap) {
      ref <- list(family = fam, a0 = 1.2, s_j = 12, xi = 0.05, b_j = 1/12,
                  beta = 0, kappa = 0, gamma = 0)
      cmp <- modifyList(ref, list(beta = -0.35, kappa = kap, gamma = 0.30))
      log(arm_h(T0, 0.5, cmp) / arm_h(T0, 0.5, ref))
    }, numeric(1))
    worst <- max(worst, diff(range(lhr)))
  }
  if (worst > tol) stop(sprintf("kappa moves the log HR at T0 by %.3g", worst))
  worst
}

## 3. The quadrature truth agrees with brute-force simulation.
verify_truth <- function(n_sim = 2e6, tol_rmst = 6e-3, tol_surv = 4e-3) {
  set.seed(20260728)
  mu <- 0.35; sd <- 1.0; tau <- 24; t_star <- 12
  out <- c()
  for (fam in c("weibull", "gompertz")) {
    ref <- list(family = fam, a0 = 1.2, s_j = 12, xi = 0.05, b_j = 1/25,
                beta = 0, kappa = 0, gamma = 0)
    cmp <- modifyList(ref, list(beta = -0.35, kappa = 0.30, gamma = 0.30))
    for (nm in c("ref", "cmp")) {
      arm <- get(nm)
      x <- rnorm(n_sim, mu, sd)
      d <- sim_arm(n_sim, x, arm, cens_rate = 0, t_admin = Inf)
      out <- c(out, setNames(
        c(abs(mean(pmin(d$time, tau)) - rmst_marg(tau, mu, sd, arm)),
          abs(mean(d$time > t_star) - surv_marg(t_star, mu, sd, arm))),
        paste0(fam, "_", nm, c("_rmst", "_surv"))))
    }
  }
  bad <- (grepl("rmst", names(out)) & out > tol_rmst) |
         (grepl("surv", names(out)) & out > tol_surv)
  if (any(bad))
    stop(sprintf("quadrature truth disagrees with simulation: %s",
                 paste(sprintf("%s=%.5f", names(out)[bad], out[bad]), collapse = ", ")))
  out
}
