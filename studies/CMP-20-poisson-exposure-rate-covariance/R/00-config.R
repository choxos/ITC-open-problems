## ---------------------------------------------------------------------------
## CMP-20: registered constants.
##
## The aggregate Poisson likelihood used by ML-NMR multiplies an arm's total
## exposure by the mean modeled rate over the arm's reported covariate law. The
## true expected count is n E[T lambda(x)], which equals that product only when
## exposure T and the individual rate lambda(x) are uncorrelated. The
## multiplicative error is exactly 1 + rho CV(T) CV(lambda) per arm, so in a
## contrast the part common to both arms cancels into the study intercept and the
## differential part lands on the treatment effect. DESIGN.md section 2.
##
##   source("R/00-config.R")
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260922L

## --- the grid (DESIGN.md section 4) -----------------------------------------
LEVELS <- list(
  rho0     = c(0, -0.2, -0.4, -0.6),  # within control-arm corr(T, lambda)
  drho     = c(0, 0.2, 0.4),          # treated-arm corr minus control-arm corr
  cv_t     = c(0.3, 0.6, 1.0),        # coefficient of variation of exposure
  cv_lam   = c(0.2, 0.4, 0.8),        # CV of the covariate-explained control rate
  n_arm    = c(250L, 1000L)           # participants per arm, both studies
)

## Effect modification is held at a single moderate value in every cell rather
## than crossed: it makes the treated arm's rate dispersion differ from the
## control arm's, which is the realistic case, and it gives the target estimand
## a population dependence so this is a population-adjustment problem at all.
## The second null control (DESIGN.md section 8) needs equal dispersions, so it
## is run as its own small arm at GAMMA = 0; see CONTROL_GAMMA0.
GAMMA <- 0.2

## --- populations -----------------------------------------------------------
## Study 1 supplies individual data on A versus C. Study 2 supplies arm totals
## (events, exposure) and covariate moments on B versus C. The covariate is
## normal in both, shifted in study 2, so the transported effect differs from the
## effect in study 2's own population.
MEAN_IPD <- 0.0
MEAN_AGD <- 0.5
SD_X     <- 1.0
## The target is study 1's population: B's effect transported into A's trial.
MEAN_TARGET <- MEAN_IPD

## --- the rate model --------------------------------------------------------
## log lambda_a(x) = mu_s + b x + d_a + GAMMA x 1[a active]
MU      <- c(ipd = log(0.8), agd = log(1.0))  # events per unit exposure at x = 0
D_A     <- -0.30
D_B     <- -0.40
## Mean exposure is fixed at 1 in every arm of every cell, so a difference
## between cells is the covariance and not the amount of person-time
## (DESIGN.md section 4).
MEAN_T  <- 1.0

## --- decision (DESIGN.md section 7) ----------------------------------------
BIAS_MATERIAL  <- 0.05   # on the log rate ratio
COVER_LOW      <- 0.90   # coverage below this fires
NOMINAL        <- 0.95
## "Plausible dispersions" is fixed here, before the run, as the lower two levels
## of each dispersion factor. CV(T) of 0.3 to 0.6 spans follow-up variation from
## modest dropout to staggered accrual; CV(lambda) of 0.2 to 0.4 is the
## covariate-explained part of rate heterogeneity only, since unexplained
## heterogeneity does not enter the covariance.
PLAUSIBLE <- list(cv_t = c(0.3, 0.6), cv_lam = c(0.2, 0.4))

## --- the sensitivity arm (DESIGN.md section 5) ------------------------------
## What an analyst declares with published data only: a range for each arm's
## exposure-rate correlation and a bound on the difference between arms.
SENS_RHO_RANGE  <- c(-0.6, 0)
SENS_DRHO_BOUND <- 0.4

## --- replication -----------------------------------------------------------
## DESIGN.md asked for 2000 from a coverage MCSE of 0.005. P4 prices 2000 at
## about 34 core-hours on a machine whose load average is near 100, so 1000 is
## registered: coverage MCSE 0.0069 at 0.95 and at most 0.016 anywhere, bias
## MCSE at most about 0.004 at the empirical SDs P4's pilot shows. The decision
## thresholds (bias 0.05, coverage 0.90) sit many MCSE from where either would be
## decided inside noise.
N_SIM <- 1000L

build_grid <- function() {
  g <- expand.grid(rho0 = LEVELS$rho0, drho = LEVELS$drho, cv_t = LEVELS$cv_t,
                   cv_lam = LEVELS$cv_lam, n_arm = LEVELS$n_arm,
                   KEEP.OUT.ATTRS = FALSE)
  g$gamma <- GAMMA
  ## The second null control: equal correlations and equal dispersions in both
  ## arms, which needs GAMMA = 0. One cell per (rho0, cv_t, cv_lam) at the larger
  ## arm size, rho0 != 0 so each arm is biased while the contrast is not.
  ctl <- expand.grid(rho0 = LEVELS$rho0[LEVELS$rho0 != 0], drho = 0,
                     cv_t = LEVELS$cv_t, cv_lam = LEVELS$cv_lam, n_arm = 1000L,
                     KEEP.OUT.ATTRS = FALSE)
  ctl$gamma <- 0
  g$arm <- "main"; ctl$arm <- "control_gamma0"
  g <- rbind(g, ctl)
  g$cell <- seq_len(nrow(g))
  g
}
