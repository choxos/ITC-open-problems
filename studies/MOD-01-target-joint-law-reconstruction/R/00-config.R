## ---------------------------------------------------------------------------
## MOD-01: registered constants.
##
## The proposition is that standardization needs the target JOINT covariate law,
## publications report marginals, and the reconstruction of the joint law from
## marginals materially affects the standardized contrast. The refuting sentence
## is that the reconstruction is immaterial because the contrast depends on the
## joint law only through quantities the marginals already fix.
##
## DESIGN.md section 2 shows the refuting sentence is exactly true in two places:
## on a collapsible scale with linear modification, and wherever the prognostic
## coefficients have mixed signs so that positive covariances cancel. Both are
## registered arms rather than afterthoughts, because a study that varied
## correlation without varying the sign pattern would report a monotone
## relationship that section 2 says does not exist.
##
## Nothing here is a placeholder for a number a probe will supply. Where a probe
## sets a constant it is named `PROBE_PLACEHOLDER` and `probes_done()` stops any
## run that reaches production without it.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260802L

## --- the grid ---------------------------------------------------------------
##
## Every cell publishes the SAME marginal means and standard deviations. That is
## the design's central control: two cells with identical published summaries and
## different truths. Section 4 states it, `R/01-dgm.R` achieves it by construction
## through the probability integral transform, and P2 verifies it numerically
## rather than assuming the construction worked.
LEVELS <- list(
  ## The off-diagonal that published marginals do not fix.
  rho          = c(0, 0.3, 0.6),
  ## Section 2 prediction 2, and the falsifier for the study's own headline.
  gamma_sign   = c("positive", "mixed"),
  ## Tail dependence, invisible to the correlation matrix. Calibrated so that all
  ## three families deliver the SAME Pearson correlation, or the copula effect
  ## would be confounded with a correlation difference.
  copula       = c("gaussian", "clayton", "gumbel"),
  ## Prediction 4: nonlinear modification adds terms the second moment misses.
  modification = c("linear", "nonlinear"),
  ## Prediction 3, and the null control: on a collapsible scale with linear
  ## modification the reconstruction is exactly irrelevant.
  scale        = c("logOR", "riskdiff"),
  ## How far standardization has to extrapolate.
  overlap      = c("good", "poor"),
  ## The off-diagonal count grows quadratically, so dimension is not cosmetic.
  dim          = c(2L, 5L)
)

## The middle of the grid, for probes that vary one factor at a time.
GRID_MIDDLE <- list(rho = 0.6, gamma_sign = "positive", copula = "gaussian",
                    modification = "nonlinear", scale = "logOR",
                    overlap = "good", dim = 5L)

## --- the outcome model ------------------------------------------------------
##
## Conditional logistic model eta = alpha + gamma' x + tau(x) A. The IPD trial
## fits it correctly: MOD-02 owns misspecification, and standardizing a wrong
## model over a right law is a different failure with a different fix.
ALPHA      <- -0.4    # baseline log odds at the covariate origin
TAU0       <-  0.5    # conditional effect at the origin
GAMMA_MAG  <-  0.5    # magnitude of every prognostic coefficient
EM_LINEAR  <-  0.4    # coefficient on x1 in the linear-modification arm
EM_QUAD    <-  0.3    # coefficient on x1^2 in the nonlinear arm

## Sign patterns. `positive` makes every covariance add; `mixed` alternates, so
## section 2's cancellation is exercised rather than assumed.
gamma_vec <- function(d, sign_pattern) {
  s <- switch(sign_pattern,
    positive = rep(1, d),
    mixed    = rep(c(1, -1), length.out = d),
    stop("unregistered gamma_sign: ", sign_pattern))
  GAMMA_MAG * s
}

## --- the two populations ----------------------------------------------------
##
## Anchored two-trial geometry. The IPD trial supplies patient records; the
## aggregate trial supplies published marginals and IS the target. Only the
## standardization step needs the joint law, so that is the step the study is
## about: the common-comparator edge involves no reconstruction and is not
## simulated.
OVERLAP_SHIFT <- c(good = 0.30, poor = 0.80)   # IPD mean minus target mean
N_IPD         <- 500L
N_AGD         <- 500L                          # only its summaries are used

## --- materiality ------------------------------------------------------------
##
## Registered from the decision context and not from the spread of the estimates.
## A standardized log odds ratio wrong by more than this would move a
## reimbursement recommendation at the margin.
MATERIAL_LOGOR <- 0.05

## --- replication, derived rather than inherited -----------------------------
##
## DESIGN.md section 6 wrote n_sim = 2000 without a derivation. Measured, that is
## about four times more than either registered outcome needs, and the study
## costs 275 core-hours at it. Since the machine this runs on is shared and
## already oversubscribed, the number is derived from the precision the decision
## rule actually requires, and the derivation is here so it can be checked.
##
## The replicate-to-replicate standard deviation of the standardized log odds
## ratio, measured at the worst corner in P1, is about 0.08. Two requirements:
##
##   bias      MCSE = 0.08 / sqrt(N_REP)      <= MATERIAL_LOGOR / 10 = 0.005
##                                            -> N_REP >= 256
##   coverage  MCSE = sqrt(.95 * .05 / N_REP) <= 0.01
##                                            -> N_REP >= 475
##
## 500 satisfies both, giving a bias MCSE of 0.0036 and a coverage MCSE of
## 0.0097. Going to 2000 would buy a bias MCSE of 0.0018, which is 3.6% of a
## threshold the study compares against at 100%, and would cost three more days.
NOMINAL <- 0.95
BIAS_SD_WORST     <- 0.08     # measured in P1 at d=5, rho=0.6, nonlinear, logOR
COVERAGE_MCSE_MAX <- 0.01
N_REP <- as.integer(ceiling(max(
  (BIAS_SD_WORST / (MATERIAL_LOGOR / 10))^2,
  NOMINAL * (1 - NOMINAL) / COVERAGE_MCSE_MAX^2)))

## The declared correlation range the reconstruction interval is built over. This
## is what an analyst asserts when they do not know the target's dependence, and
## its width is a registered input rather than something tuned to make the
## interval cover.
RECON_RHO_RANGE <- c(-0.3, 0.7)

PROBE_PLACEHOLDER <- NA_real_
QUAD_ORDER  <- PROBE_PLACEHOLDER   # probe P1
TRUTH_N     <- PROBE_PLACEHOLDER   # probe P1
PROBE_FILE  <- "results/probes.rds"

load_probes <- function(path = PROBE_FILE)
  if (file.exists(path)) readRDS(path) else NULL

probes_done <- function(need = c("QUAD_ORDER", "TRUTH_N"), path = PROBE_FILE) {
  p <- load_probes(path)
  missing <- need[!need %in% names(p)]
  if (!is.null(p)) {
    present <- need[need %in% names(p)]
    bad <- present[!vapply(p[present], function(z) is.finite(z[[1]]), TRUE)]
    missing <- c(missing, bad)
  }
  if (length(missing))
    stop("these probe outputs have not been computed, so the run would register ",
         "a guess:\n  ", paste(missing, collapse = "\n  "))
  for (nm in need) assign(nm, p[[nm]][[1]], envir = globalenv())
  invisible(p)
}
