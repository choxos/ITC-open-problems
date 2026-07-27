## The design, and the decision rule, written before any result exists.

MASTER_SEED <- 20260805L
N_REP <- 4000L
N_T <- 400L                              # target trial, per arm

LEVELS <- list(
  ## Coefficient on X4 in the A versus C modifier function. X4 is measured in the
  ## source and never enters any adjustment set, so a non-zero value is an omitted
  ## effect modifier: the commonest reason a population adjustment is wrong, and
  ## the one an analyst has some hope of catching, because the source data can
  ## estimate the interaction and a baseline table may report the mean.
  omit = c(0, 0.35),

  ## Coefficient on the X1 X2 term. Source and target differ in that correlation
  ## (0.30 against 0.70), and matching marginal means and standard deviations does
  ## not match a cross-moment. This bias is therefore invisible to every balance
  ## diagnostic in routine use, and no baseline table reports the correlation that
  ## would make it visible.
  joint = c(0, 0.45),

  ## Standardized displacement of the target covariate means from the source.
  ## 0.25 is the kind of difference a trial-eligibility change produces, 1.25 is
  ## the kind that prompts a comment in an appraisal.
  ##
  ## 0 is included after a pilot showed why it has to be. The conventional
  ## baseline-imbalance cut is 0.25 standardized units, so a design whose mildest
  ## cell already sits at 0.25 makes that rule fire on essentially everything and
  ## its specificity unmeasurable. A panel has to be given cells where it should
  ## stay silent, or "it warns too often" is a property of the design.
  overlap = c(0, 0.25, 0.75, 1.25),

  ## Source participants per arm.
  n_arm = c(150L, 400L),

  ## Correlation of X4 with the adjustment set. At 0 nothing about matching X1 to
  ## X3 moves X4, so an omitted modifier is fully omitted; at 0.5 the weights move
  ## it part of the way by proxy, which is the situation analysts are implicitly
  ## relying on when they argue an unmatched covariate is "captured" by the ones
  ## they did match.
  rho4 = c(0, 0.5),

  ## Ratio of the target covariate standard deviations to the source ones.
  ##
  ## This factor exists to break the confounding that would otherwise make the
  ## study unfalsifiable. Matching second moments to a target that is 25% more
  ## dispersed forces heavy tail weighting and destroys effective sample size,
  ## while adding NO bias at all, because the modifier function is linear in the
  ## adjustment set and its mean is matched exactly either way. Without a factor
  ## like this, every cell with a small effective sample size would also be a cell
  ## with poor mean overlap, and effective sample size would look like a bias
  ## diagnostic purely because the design never separated the two.
  sd_target = c(1.00, 1.25)
)

## The deployment distribution.
##
## Sensitivity, specificity and calibration are not properties of a diagnostic.
## They are properties of a diagnostic under a distribution of analyses, which is
## the audit's objection to the catalog entry as originally worded and the reason
## the field has no numbers: nobody has written the distribution down. So it is
## written down here, as an explicit product-form judgment, and every headline
## number is reported twice: once under these weights and once with all cells
## weighted equally. A conclusion that survives only one of the two is reported as
## not surviving.
##
## These weights are a judgment about applied practice, not an estimate from data.
## Nothing in this program measured them.
DEPLOY <- list(
  omit = c(`0` = 0.65, `0.35` = 0.35),
  joint = c(`0` = 0.70, `0.45` = 0.30),
  overlap = c(`0` = 0.25, `0.25` = 0.35, `0.75` = 0.25, `1.25` = 0.15),
  n_arm = c(`150` = 0.45, `400` = 0.55),
  rho4 = c(`0` = 0.40, `0.5` = 0.60),
  sd_target = c(`1` = 0.65, `1.25` = 0.35)
)

build_scenarios <- function() {
  g <- expand.grid(omit = LEVELS$omit, joint = LEVELS$joint,
                   overlap = LEVELS$overlap, n_arm = LEVELS$n_arm,
                   rho4 = LEVELS$rho4, sd_target = LEVELS$sd_target,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[order(g$omit, g$joint, g$overlap, g$n_arm, g$rho4, g$sd_target), ]
  g$n_T <- N_T
  g$scenario <- seq_len(nrow(g))
  ## A cell is correctly specified when neither bias channel is switched on. Any
  ## error there is noise plus chance arm imbalance, and a diagnostic that fires
  ## in these cells is producing a false alarm on a sound analysis.
  g$well_specified <- g$omit == 0 & g$joint == 0
  ## The omitted-modifier channel is diagnosable in principle: the source data can
  ## estimate the interaction and a baseline table can report the mean. The
  ## cross-moment channel is not, because no baseline table reports a correlation.
  ## The verdict is required to hold in the diagnosable cells too, so that a
  ## failure engineered to be invisible cannot on its own condemn the panel.
  g$diagnosable <- g$joint == 0
  g$w_deploy <- with(g, DEPLOY$omit[as.character(omit)] *
                       DEPLOY$joint[as.character(joint)] *
                       DEPLOY$overlap[as.character(overlap)] *
                       DEPLOY$n_arm[as.character(n_arm)] *
                       DEPLOY$rho4[as.character(rho4)] *
                       DEPLOY$sd_target[as.character(sd_target)])
  stopifnot(abs(sum(g$w_deploy) - 1) < 1e-8)
  rownames(g) <- NULL
  g
}

## What counts as an error worth catching.
##
## The estimand is on the scale of an outcome with unit standard deviation, and
## the true transported effect ranges from about 0.5 to about 1.2 across the
## design, so 0.20 is a fifth of a standard deviation and of the same order as the
## smallest difference an appraisal would treat as meaningful. It is not defined
## from any diagnostic, which is the requirement: study 3 of this program had to
## discard a reference that turned out to be algebraically identical to one of the
## statistics being scored.
MATERIAL <- 0.20

## The primary reference is the error in the TRANSPORTED SOURCE EFFECT, not in the
## anchored contrast. The anchored contrast additionally carries the target trial's
## own sampling error, which no source-side diagnostic has any information about
## and which would depress every discrimination measure by a common amount. Using
## the source-side error gives the diagnostics the most favorable version of the
## question. The anchored version is reported as a secondary measure.
##
## `confident` is used for the decision-relevant secondary: a 95% interval that
## excludes the truth, and a claim of superiority on the wrong side of zero.
HARM <- list(level = 0.95, confident = 0.95)

## The routinely reported panel, in the sense of what appears in a submission or
## in the maicplus and TSD 18 output.
ROUTINE <- c("ess", "ess_pct", "cv_w", "max_w", "smd_matched", "smd_pre", "maha")

## The proposals: an imbalance check on the covariates that were measured but not
## matched, and the same imbalance converted into the units of the estimand.
PROPOSED <- c("smd_unmatched", "bias_hat")

## Thresholds, fixed before the run and split by where they came from.
##
## PUBLISHED, USED AS STATED, NOT TOUCHED. Absolute effective sample size below
## 30 to 35 is the cut an ISPOR Europe 2024 simulation identified as the point
## below which bias appeared in unanchored MAIC. Effective sample size below 50%
## of the original is the reduction figure appraisal commentary uses. A
## standardized baseline difference above 0.10, and above 0.25, are the two
## conventional balance cuts. A single weight above 10% of the total is the
## concentration rule of thumb. None of these was adjusted.
##
## NO PUBLISHED CONVENTION, SET A PRIORI AND DISCLOSED. The Mahalanobis distance
## of the target mean from the source has no conventional cut; 1.00, meaning one
## standardized unit, was chosen after a pilot showed that 2.00 fired on 0.4% of
## replicates and could not be evaluated at all. `bias_hat` is this study's own
## proposal, so its cut is half the material-error threshold: warn when the
## estimated bias is at least half of what would matter. Both are disclosed as
## chosen rather than inherited, and neither is the primary rule.
THRESH_SOURCE <- c(ess = "published", ess30 = "published", ess_pct = "published",
                   cv_w = "implied by ess_pct", max_w = "rule of thumb",
                   smd_matched = "conventional", smd_pre = "conventional",
                   maha = "no convention; set a priori from a pilot",
                   smd_unmatched = "conventional",
                   bias_hat = "this study's proposal; half of MATERIAL")

## The prespecified conclusions.
##
## PRIMARY: the sensitivity and specificity of the published ESS < 35 rule for
## material error in MAIC, under the deployment distribution. That rule is the one
## an ISPOR Europe 2024 simulation put forward and the one appraisal commentary
## uses, so it is the claim with a reader waiting for it. Area under the ROC curve
## is the leading secondary, because a single operating point cannot distinguish
## a statistic that carries no information from a threshold placed in the wrong
## spot; study 3 of this program had to withdraw a claim for exactly that reason.
DECISION <- list(
  diagnostics_work =
    "ESS < 35 reaches sensitivity at least 0.80 with specificity at least 0.50,
     under BOTH the deployment weights and equal cell weights, with 95% Monte
     Carlo intervals excluding those thresholds; or some other routinely reported
     diagnostic does so at a threshold fixed before the run. The same must hold
     in the diagnosable stratum on its own.",

  diagnostics_fail =
    "The upper 95% Monte Carlo limit on the sensitivity of ESS < 35 is below 0.80
     under both weightings, and no other routinely reported diagnostic meets the
     sensitivity and specificity pair at its prespecified threshold, and the
     failure is present in the diagnosable stratum and not only where the bias was
     engineered to be invisible.",

  diagnostics_partial =
    "Neither. Report where each member of the panel works and where it does not,
     and which operating point, if any, is defensible.",

  uninformative_if =
    "Material error occurs on fewer than 5% or more than 95% of fitted MAIC
     replicates under the deployment weights, so sensitivity and specificity are
     estimated at a prevalence where neither is stable; or MAIC fails the
     calibration tolerance on more than 5% of replicates, so the analyzed set is
     not the designed set and the dropouts are the hardest cells; or the verdict
     differs between the deployment and equal weightings."
)

## Three mechanistic claims, also prespecified, because a verdict of "the panel
## does not work" is not an explanation and the catalog entry asks for one.
MECHANISM <- list(
  variance_not_bias =
    "Effective sample size discriminates the outcome-noise component of realized
     error better than the transport component, by at least 0.10 in area under the
     ROC curve. If this holds, the statistic that appraisals read as a bias
     warning is a variance statistic.",

  threshold_not_transportable =
    "Across the cells in which ESS < 35 fires on most replicates, the cell-level
     rate of material error spans at least 0.30 from lowest to highest. A
     calibrated threshold would carry roughly the same risk wherever it fires; a
     wide span means the same number means different things in different analyses,
     which is what a non-transportable threshold is. The unit is the cell the rule
     flags rather than a fixed numeric band, because a band chosen after seeing
     which cells fall in it would be tuned, and at these error rates a ratio
     between strata saturates and would understate a real spread.",

  panel_is_one_statistic =
    "Within a fixed source size, effective sample size, effective sample size as a
     percentage and the coefficient of variation of the weights have identical
     areas under the ROC curve to within Monte Carlo error, and the post-weighting
     standardized difference on matched moments has none. Algebra says both must
     hold; the run is a check on the implementation, not a test.",

  bias_hat_helps =
    "In the stratum where the bias is diagnosable at all, meaning the cross-moment
     channel is switched off, converting the unmatched covariate's residual
     imbalance into the units of the estimand with the source-estimated
     interaction reaches an area under the ROC curve against the TRANSPORT
     component at least 0.10 above the best routinely reported diagnostic.
     Restricting to that stratum and to that component is stated in advance and
     is not a post hoc rescue: no statistic computable from a baseline table can
     see the cross-moment channel, and no covariate statistic can see outcome
     noise, so scoring the proposal against error it cannot observe would test the
     information available rather than the statistic."
)
