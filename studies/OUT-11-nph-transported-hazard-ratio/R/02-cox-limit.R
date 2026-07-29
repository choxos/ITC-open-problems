## ---------------------------------------------------------------------------
## The value a fitted constant hazard ratio converges to, computed rather than
## simulated.
##
## A pre-run critique made the point that killed the first design's centrepiece.
## The first design proposed to hold the survival functions fixed, vary only the
## censoring distribution, and report that the transported hazard ratio moves.
## That is not an empirical question: it is a theorem. Struthers and Kalbfleisch
## (Biometrika 1986, doi:10.2307/2336212) and Xu and O'Quigley (Biostatistics
## 2000, doi:10.1093/biostatistics/1.4.423) show that under a misspecified
## proportional-hazards model the maximum partial-likelihood estimator converges
## to a least-false parameter that is a censoring- and event-weighted average of
## the time-varying log-hazard contrast. So the hazard ratio MUST move when the
## censoring changes, and the first design's promise that "if it does not move,
## the entry's warning is weaker" was false: non-movement is asymptotically
## impossible under non-proportional hazards.
##
## Both citations were checked against CrossRef before being relied on.
##
## What remains worth doing is SIZING the effect, not testing it, and that is
## what this file is for. For a two-sample Cox fit the least-false parameter
## beta* solves the score equation in the limit,
##
##   int f1(t) dt = int [ r1(t) e^b / (r0(t) + r1(t) e^b) ] (f0(t) + f1(t)) dt,
##
## with r_k(t) = pi_k S_k(t) G_k(t) the probability of being at risk in arm k and
## f_k(t) = r_k(t) h_k(t) the observed event rate. Everything on the right is
## known from the data-generating mechanism and the censoring law, so beta* is a
## root-find rather than a simulation, and the censoring dependence is exact.
##
## Using the MARGINAL S and h gives the target-standardized constant hazard
## ratio, which is the quantity an analyst reports.
## ---------------------------------------------------------------------------

## Censoring survival: independent exponential at `rate`, plus a hard
## administrative cutoff. G(t) = P(C > t).
cens_S <- function(t, rate, t_admin) ifelse(t >= t_admin, 0, exp(-rate * t))

## The least-false constant log hazard ratio for comparing `arm_cmp` with
## `arm_ref` in the target population, under a given censoring regime.
##
##   mu, sd     target covariate law
##   tau_int    upper limit of the score integral; must exceed t_admin
##   alloc      randomization fraction to the comparator arm
## THE CORE SOLVER, taking survival and hazard on a grid rather than arm
## specifications, so that the projection applied to a FITTED curve is literally
## the same functional as the one applied to the known truth.
##
## Section 4 registers "one prespecified Cox projection functional applied to
## every method's fitted target survival curves, so the constant summaries being
## compared are the same functional of different fits". Round 6 found that no
## code applied it to any fit: cox_limit was only ever called on analytic arms in
## E1, E2 and the verifiers. Splitting the solver out is what makes the
## registered sentence true rather than aspirational.
cox_solve <- function(tt, S0, h0, S1, h1, G, alloc = 0.5) {
  r0 <- (1 - alloc) * S0 * G;  r1 <- alloc * S1 * G
  f0 <- r0 * h0;               f1 <- r1 * h1
  trap <- function(y) sum(diff(tt) * (head(y, -1) + tail(y, -1)) / 2)
  lhs <- trap(f1)
  ## Where nobody remains at risk the two risk sets are both zero and the weight
  ## is 0/0. The analytic caller never sees this because it stops just short of
  ## the administrative cutoff, but a fitted curve is naturally evaluated ON the
  ## cutoff, and the resulting NaN propagated through the whole score and
  ## returned NA for every ML-NMR fit. The contribution there is zero either way,
  ## since f0 + f1 vanishes with the risk sets.
  score <- function(b) {
    den <- r0 + r1 * exp(b)
    w <- ifelse(den > 0, r1 * exp(b) / den, 0)
    lhs - trap(w * (f0 + f1))
  }
  if (!is.finite(score(-6)) || !is.finite(score(6))) return(NA_real_)
  if (score(-6) * score(6) > 0) return(NA_real_)
  uniroot(score, c(-6, 6), tol = 1e-10)$root
}

cox_limit <- function(arm_ref, arm_cmp, mu, sd, cens_rate, t_admin,
                      alloc = 0.5, tau_int = NULL, n_grid = 2000) {
  if (is.null(tau_int)) tau_int <- t_admin
  tt <- seq(1e-6, tau_int * (1 - 1e-9), length.out = n_grid)
  cox_solve(tt,
            surv_marg(tt, mu, sd, arm_ref), haz_marg(tt, mu, sd, arm_ref),
            surv_marg(tt, mu, sd, arm_cmp), haz_marg(tt, mu, sd, arm_cmp),
            cens_S(tt, cens_rate, t_admin), alloc)
}

## THE SAME FUNCTIONAL, APPLIED TO FITTED CURVES.
##
## Takes each method's estimated target-population survival for the reference and
## comparator arms on a common grid, recovers the hazards by differentiating the
## log-cumulative hazard, and solves the identical score equation under the
## registered censoring survival. Every method is therefore summarized by one
## constant, computed the same way, from whatever curves it produced.
##
## Differentiation is on log H rather than on S because H is monotone increasing
## and unbounded, so the finite difference is stable where S flattens; h = H'
## follows as exp(logH) times the derivative of logH.
cox_project <- function(tt, S_ref, S_cmp, cens_rate, t_admin, alloc = 0.5) {
  haz_of <- function(S) {
    S <- pmin(pmax(S, 1e-12), 1 - 1e-12)
    lh <- log(-log(S))
    d <- c(diff(lh) / diff(tt), NA)
    d[length(d)] <- d[length(d) - 1L]
    pmax(exp(lh) * d, 0)
  }
  ok <- is.finite(S_ref) & is.finite(S_cmp) & tt > 0
  if (sum(ok) < 10) return(NA_real_)
  tt <- tt[ok]; S_ref <- S_ref[ok]; S_cmp <- S_cmp[ok]
  cox_solve(tt, S_ref, haz_of(S_ref), S_cmp, haz_of(S_cmp),
            cens_S(tt, cens_rate, t_admin), alloc)
}

## How far the reported constant hazard ratio moves across a set of censoring
## regimes while the truth is held exactly fixed. This is the sized version of
## what the first design proposed to discover.
cox_limit_across_censoring <- function(arm_ref, arm_cmp, mu, sd, regimes,
                                       alloc = 0.5) {
  out <- do.call(rbind, lapply(seq_len(nrow(regimes)), function(i) {
    b <- cox_limit(arm_ref, arm_cmp, mu, sd,
                   regimes$cens_rate[i], regimes$t_admin[i], alloc)
    data.frame(regime = regimes$label[i], cens_rate = regimes$cens_rate[i],
               t_admin = regimes$t_admin[i], log_hr = b, hr = exp(b))
  }))
  out$hr_ratio_to_first <- out$hr / out$hr[1]
  out
}

## Verification: the analytic limit must agree with a very large simulated Cox
## fit. Run at analysis time. The tolerance is set by the SIMULATION's Monte
## Carlo error, not the quadrature's.
verify_cox_limit <- function(n = 4e5, tol = 0.02) {
  stopifnot(requireNamespace("survival", quietly = TRUE))
  set.seed(9)
  mu <- 0.35; sd <- 1.0
  ref <- list(family = "weibull", a0 = 1.2, s_j = 12, xi = 0.05, b_j = 1/25,
              beta = 0, kappa = 0, gamma = 0)
  cmp <- modifyList(ref, list(beta = -0.35, kappa = 0.30, gamma = 0.30))
  worst <- 0
  for (cr in c(0.01, 0.08)) {
    a <- cox_limit(ref, cmp, mu, sd, cens_rate = cr, t_admin = 24)
    x0 <- rnorm(n, mu, sd); x1 <- rnorm(n, mu, sd)
    d0 <- sim_arm(n, x0, ref, cr, 24); d1 <- sim_arm(n, x1, cmp, cr, 24)
    d  <- rbind(cbind(d0, z = 0), cbind(d1, z = 1))
    ## marginal (unadjusted) Cox, which is the transported-HR analogue
    b <- unname(coef(survival::coxph(survival::Surv(time, status) ~ z, data = d)))
    worst <- max(worst, abs(a - b))
  }
  if (worst > tol)
    stop(sprintf("analytic Cox limit disagrees with simulation by %.4f", worst))
  worst
}
