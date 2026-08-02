## ---------------------------------------------------------------------------
## The data-generating mechanism, and the control the whole study rests on.
##
## THE CONTROL, STATED PLAINLY. Every cell must publish the SAME marginal means
## and standard deviations, so that the only thing differing between two cells is
## the joint law behind identical published summaries. Section 4 of DESIGN.md
## calls this the design's central control and P2 verifies it, but the
## construction here makes it exact rather than approximate:
##
##   draw U from a copula, then set x = qnorm(U).
##
## The probability integral transform gives every coordinate an exactly standard
## normal marginal whatever the copula does, so the reported mean and standard
## deviation are 0 and 1 in every cell BY CONSTRUCTION and not by calibration.
## Only the dependence differs. A study that had to tune the marginals to match
## would be one arithmetic slip away from confounding every comparison.
##
## COPULA FAMILIES ARE MATCHED ON PEARSON CORRELATION, NOT ON THEIR OWN
## PARAMETER. A Clayton copula at theta = 2 and a Gumbel at theta = 2 do not
## induce the same correlation, so comparing them at equal parameters would
## confound tail dependence with correlation and prediction 4 could not be read.
## `copula_param()` root-finds the parameter that delivers a requested Pearson
## correlation of the transformed variables, which is the quantity the borrowed
## correlation matrix actually carries.
##
##   source("R/01-dgm.R")
## ---------------------------------------------------------------------------

source("R/00-config.R")

suppressPackageStartupMessages(library(copula))

## --- the copula, calibrated to a requested Pearson correlation ---------------

build_copula <- function(family, theta, d) switch(family,
  gaussian = normalCopula(theta, dim = d, dispstr = "ex"),
  clayton  = claytonCopula(theta, dim = d),
  gumbel   = gumbelCopula(theta, dim = d),
  stop("unregistered copula family: ", family))

## The probability integral transform, with the uniforms clamped off the closed
## interval's endpoints. At strong dependence an Archimedean sampler returns
## values that round to exactly 0 or 1 in double precision, and `qnorm` maps
## those to infinities that then poison a correlation into NA. The clamp is at
## the smallest representable step from each endpoint, so it changes the law by
## far less than the Monte Carlo error of any quantity computed from it, and it
## fails loudly rather than silently: a sample that needed heavy clamping would
## show up as a marginal that P2 rejects.
U_EPS <- 1e-12
.qnorm_u <- function(u) stats::qnorm(pmin(pmax(u, U_EPS), 1 - U_EPS))

## Pearson correlation of qnorm(U) under a given family and parameter, by Monte
## Carlo at a fixed seed so the calibration is deterministic and reproducible.
.pearson_of <- function(family, theta, d, n = 100000L, seed = 4001L) {
  set.seed(seed)
  x <- .qnorm_u(rCopula(n, build_copula(family, theta, d)))
  r <- stats::cor(x)
  mean(r[upper.tri(r)])
}

.param_cache <- new.env(parent = emptyenv())

## The parameter delivering a requested Pearson correlation. Gaussian is exact:
## a Gaussian copula with normal marginals IS a multivariate normal, so the
## parameter equals the correlation and no search is needed. Clayton and Gumbel
## are searched, and both are one-sided families, so a requested correlation of
## zero is the independence copula for all three and those cells coincide across
## families by construction.
copula_param <- function(family, rho, d) {
  if (rho == 0) return(switch(family, gaussian = 0, clayton = 1e-8, gumbel = 1))
  if (family == "gaussian") return(rho)
  key <- sprintf("%s|%.4f|%d", family, rho, d)
  z <- .param_cache[[key]]
  if (!is.null(z)) return(z)
  lo <- switch(family, clayton = 1e-4, gumbel = 1 + 1e-4)
  hi <- switch(family, clayton = 30,   gumbel = 15)
  f <- function(th) .pearson_of(family, th, d) - rho
  fh <- f(hi)
  if (!is.finite(fh))
    stop(sprintf("%s at theta = %g in %d dimensions gives a correlation that is ",
                 family, hi, d),
         "not finite; the sampler is returning degenerate uniforms")
  if (fh < 0)
    stop(sprintf("%s cannot reach Pearson correlation %.2f in %d dimensions; ",
                 family, rho, d),
         "the grid asks for dependence this family does not support")
  z <- stats::uniroot(f, c(lo, hi), tol = 1e-6)$root
  .param_cache[[key]] <- z
  z
}

## --- the two populations ----------------------------------------------------
##
## The aggregate trial's population is the target and is centered at the origin.
## The IPD trial is the same joint law shifted, so overlap is a location
## difference and not a change of dependence.
##
## THE IPD TRIAL SHARES THE TARGET'S DEPENDENCE STRUCTURE, DELIBERATELY. That
## makes the method that borrows a correlation matrix from the IPD trial exactly
## right about correlation and wrong only about the copula family, which is what
## isolates prediction 4. It also makes that method OPTIMISTIC relative to
## practice, where the two trials' dependence would differ as well, and the study
## says so rather than reporting a borrowed matrix as if it were realistic.
## ONE COVARIATE HAS NO JOINT LAW TO RECONSTRUCT, so it is handled before any
## copula is built. This is not a convenience: it is the design's second null
## control. With d = 1 the joint law IS the marginal, every reconstruction
## coincides with the truth by definition, and any disagreement between methods
## is an implementation fault rather than a finding. The copula constructors
## reject dim = 1, so without this branch the control could not be run at all.
draw_target <- function(n, d, rho, family) {
  if (d == 1L) return(matrix(stats::rnorm(n), n, 1L))
  th <- copula_param(family, rho, d)
  .qnorm_u(rCopula(n, build_copula(family, th, d)))
}

draw_ipd <- function(n, d, rho, family, overlap) {
  x <- draw_target(n, d, rho, family)
  sweep(x, 2, rep(OVERLAP_SHIFT[[overlap]], d), "+")
}

## --- the outcome ------------------------------------------------------------

tau_of <- function(x, modification) {
  z <- TAU0 + EM_LINEAR * x[, 1]
  if (identical(modification, "nonlinear")) z <- z + EM_QUAD * x[, 1]^2
  z
}

linpred <- function(x, arm, gamma, modification)
  ALPHA + as.vector(x %*% gamma) + arm * tau_of(x, modification)

prob_of <- function(x, arm, gamma, modification)
  stats::plogis(linpred(x, arm, gamma, modification))

draw_outcome <- function(p) stats::rbinom(length(p), 1, p)

## --- the estimand -----------------------------------------------------------
##
## The marginal contrast in the AGGREGATE study's population, computed from the
## true outcome model averaged over a law, never from the conditional
## coefficient. Deriving it from the coefficient is the very error the closed
## part of this catalog entry is about, so the code cannot take that shortcut
## even as a convenience.
##
## `scale` is registered because it is the null control: on the risk-difference
## scale with linear modification the marginal contrast is a linear functional of
## the covariate law, so it depends on the marginals alone and the reconstruction
## is EXACTLY irrelevant. That is algebra, not an empirical finding, and a run
## that shows otherwise has a harness fault.
marginal_contrast <- function(x, gamma, modification, scale) {
  p1 <- mean(prob_of(x, 1L, gamma, modification))
  p0 <- mean(prob_of(x, 0L, gamma, modification))
  switch(scale,
    logOR    = log(p1 / (1 - p1)) - log(p0 / (1 - p0)),
    riskdiff = p1 - p0,
    stop("unregistered scale: ", scale))
}

.truth_cache <- new.env(parent = emptyenv())

## Truth by Monte Carlo at a size P1 sets, not by quadrature. In five dimensions
## with an Archimedean copula a product rule is not affordable and a sparse rule
## has no error bound here, so the honest instrument is a large sample whose own
## error P1 measures against the material threshold and reports.
truth_target <- function(d, rho, family, gamma, modification, scale, n = TRUTH_N) {
  key <- sprintf("%d|%.3f|%s|%s|%s|%s", d, rho, family,
                 paste(sign(gamma), collapse = ""), modification, scale)
  z <- .truth_cache[[key]]
  if (!is.null(z)) return(z)
  old <- if (exists(".Random.seed", .GlobalEnv))
           get(".Random.seed", .GlobalEnv) else NULL
  set.seed(MASTER_SEED + d)
  z <- marginal_contrast(draw_target(n, d, rho, family), gamma, modification, scale)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  .truth_cache[[key]] <- z
  z
}

## --- what section 2 predicts ------------------------------------------------
##
## The prognostic-index variance under a correlation matrix, which is the single
## scalar section 2 says the copula enters through. Reported so the registered
## mechanism check can regress observed bias on it rather than on a narrative.
prognostic_var <- function(gamma, Sigma) as.vector(t(gamma) %*% Sigma %*% gamma)

## The analytically computable bound of section 2 consequence 1: the error an
## independence reconstruction makes is a weighted sum of the true covariances
## with weights given by products of prognostic coefficients. An analyst who
## knows the sign pattern of gamma and a plausible correlation range can evaluate
## this from published data, which is why its performance is a registered outcome
## rather than a remark.
independence_gap <- function(gamma, Sigma) {
  S0 <- diag(diag(Sigma), nrow = nrow(Sigma))
  prognostic_var(gamma, Sigma) - prognostic_var(gamma, S0)
}
