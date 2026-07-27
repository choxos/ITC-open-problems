## The design.
##
## Fixed here rather than in the run script so the scenario grid, the replicate
## count and the master seed are one object that the protocol quotes and the
## analysis reads back.

MASTER_SEED <- 20260727L

## 5000 replicates.
##
## The primary measure is the coverage error of the status-quo interval. At
## nominal coverage the Monte Carlo SE is sqrt(0.95 * 0.05 / 5000) = 0.0031, or
## 0.31 percentage points, so a 2-point coverage error is more than six Monte
## Carlo SEs from nominal and a 1-point error is more than three.
##
## The secondary measure is the paired coverage difference between the status quo
## and each correction. Methods share the replicate and the point estimate and
## differ only in interval width, so the comparison is McNemar-paired and its
## Monte Carlo SE is governed by the discordance rate rather than by 0.95 * 0.05.
## At a 2% discordance rate that SE is sqrt(0.02 / 5000) = 0.20 points.
##
## The earlier design proposed 2000 replicates against a 2-point decision
## threshold. A pilot showed the effect in its confirmatory cells is under one
## point, which that pairing could not have resolved: the study would have
## reported "no material effect" as an artifact of its own precision.
N_REP <- 5000L

LEVELS <- list(
  ## Source trial size. THE factor the original design omitted, and the one the
  ## answer turns on. The omitted target-moment variance is J' Omega J / nT while
  ## the retained source variance is of order 1 / ESS_S, so what governs whether
  ## the omission matters is the ratio of source to target information, not nT
  ## alone. A pilot holding nS = 500 found the omission was 1% to 7% of total
  ## variance and concluded nothing was wrong; raising nS to 2000 took the same
  ## quantity to 23%. Pinning nS answers a question about one arbitrary source
  ## size and reports it as a question about population adjustment.
  nS = c(500L, 2000L),

  ## Target trial and target-summary size. The range the catalog problem poses.
  nT = c(200L, 500L, 2000L),

  ## Overlap, as the standardized mean difference on every covariate between
  ## source and target. Population-limit ESS fractions are near 1.00, 0.65 and
  ## 0.25, spanning the strong, moderate and poor regimes of Chandler and
  ## Proskorovsky (2024).
  d = c(0, 0.4, 0.8),

  ## Effect-modification strength, as the standard deviation of the treatment
  ## effect across individuals IN THE TARGET population. Calibrated per cell
  ## rather than fixed as coefficients: see `sd_g_base`. Zero is the negative
  ## control, under which reported target moments carry no information about the
  ## transported effect and every method must be nominal.
  em_sd = c(0, 0.45, 0.90),

  ## Alignment between the two trials' effect modification. 0 means only the
  ## source treatment is modified, so the omitted term is a pure positive
  ## variance; 1 means both are modified identically, so the omitted covariance
  ## is negative and the status-quo interval is too wide rather than too narrow;
  ## 0.5 is between. Without the intermediate level the sign of the result is
  ## fixed by the mechanism.
  kappa = c(0, 0.5, 1),

  ## Target covariate correlation. The source is always 0.30. At 0.30 the
  ## analyst's borrowed correlation is right; at 0.60 it is wrong, which is the
  ## only thing that separates the reconstruction method from the method given
  ## the real moment covariance.
  rho_T = c(0.30, 0.60)
)

RHO_S <- 0.30

## Build the grid.
##
## kappa is meaningless when there is no effect modification, so those cells are
## collapsed to a single kappa rather than run three times with identical data.
build_scenarios <- function() {
  full <- expand.grid(
    nS = LEVELS$nS, nT = LEVELS$nT, d = LEVELS$d,
    em_sd = LEVELS$em_sd, kappa = LEVELS$kappa, rho_T = LEVELS$rho_T,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  full <- full[!(full$em_sd == 0 & full$kappa != 0), ]
  full$rho_S <- RHO_S
  full <- full[order(full$nS, full$nT, full$d, full$em_sd, full$kappa, full$rho_T), ]
  full$scenario <- seq_len(nrow(full))
  rownames(full) <- NULL
  full
}

## The confirmatory question, prespecified.
##
## The original design named four cells and asked whether coverage left a 93% to
## 97% band there. A pilot showed it cannot: in those cells the omitted variance
## is under 2% of the total, which moves coverage by less than half a point. A
## rule that no achievable result can trigger is not a rule, and reporting "the
## problem is not material" from it would be reporting the design's own choice of
## residual variance.
##
## So the question is not "is there a cell where this bites" but "where is the
## boundary". The primary analysis maps coverage error over the grid and locates
## the region in which it exceeds two percentage points. The claims below are
## what the study commits to in advance about that map.
DECISION <- list(
  ## The problem is real and material somewhere in the realistic range.
  material_somewhere =
    "At least one scenario with em_sd <= 0.45 has status-quo coverage outside
     0.93 to 0.97 with its Monte Carlo 95% interval excluding 0.95, and the
     joint-score interval in that same scenario covers within 0.93 to 0.97.",

  ## The problem is real but not at ordinary effect-modification strength.
  material_only_when_strong =
    "Every scenario with em_sd <= 0.45 has status-quo coverage inside 0.93 to
     0.97, while at least one scenario with em_sd = 0.90 falls outside it.",

  ## The problem does not bite anywhere in the range examined.
  not_material =
    "Every scenario in the grid has status-quo coverage inside 0.93 to 0.97 and
     every paired coverage difference from the joint-score method is under 0.01
     in absolute value with its Monte Carlo 95% interval inside -0.02 to 0.02.",

  ## Gates. If these fail the run says nothing about target moments, because the
  ## failure is somewhere else.
  uninformative_if =
    "Any confirmatory method converges on fewer than 98% of replicates; or raw
     and bias-eliminated coverage differ by more than 0.02, meaning the point
     estimate rather than the interval is at fault; or the joint-score reference
     itself misses 0.93 to 0.97, meaning the variance decomposition is wrong; or
     any em_sd = 0 negative control is outside 0.93 to 0.97."
)

## What counts as a usable replicate. Declared here so a failure is a recorded
## outcome and not a silent drop.
CONVERGENCE <- list(
  optim_code = 0L,           # BFGS reported convergence
  max_imbalance = 1e-4,      # residual standardized moment imbalance
  min_ess = 5                # weights concentrated on fewer than this: unusable
)
