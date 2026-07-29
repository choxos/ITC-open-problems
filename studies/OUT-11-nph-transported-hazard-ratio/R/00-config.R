## ---------------------------------------------------------------------------
## Every number the design depends on, in one place, fixed before the run.
##
## A pre-run critique returned "the DGM is still not numerically locked" as a
## fatal finding, and it was right: the previous protocol registered only the
## kappa and gamma grids and left the treatment effects, baselines, study means,
## sample sizes, allocation and censoring rates unset. A preregistration that
## cannot be executed from its own text is not a preregistration. This file is
## the executable version, and the protocol quotes it rather than paraphrasing.
##
## Two conventions matter and are stated rather than left to be inferred:
##
##   * kappa and gamma belong to SPECIFIC treatments. kappa_A is a DESIGN FACTOR
##     as of version 4 (see KAPPA_A_LEVELS below); it is zero in most cells and
##     0.30 in the two ipd-nph cells. gamma is SHARED between A and B, which is
##     the anchored shared-effect-modifier assumption that MAIC, STC and ML-NMR
##     all require. It therefore holds by construction here, and this study is
##     about the survival-model dimension, not about effect-modifier
##     identification (that is IDN-05).
##
##   * The B-versus-A conditional contrast is
##     beta_B - beta_A + (kappa_B - kappa_A) g(t), with NO covariate term,
##     because gamma cancels. Movement of the reported hazard ratio at
##     kappa_B = kappa_A is therefore pure risk-set selection.
##
##   * The covariate is a PURE EFFECT MODIFIER, not a prognostic factor, and an
##     earlier version of this comment said otherwise. Verified: placebo
##     survival at t = 12 is 0.4356 at x = -2, 0 and +2, because gamma_PBO = 0.
##     A useful consequence is that the aggregate study's placebo arm identifies
##     the target baseline cumulative hazard directly, with no deconvolution.
## ---------------------------------------------------------------------------

## --- times ------------------------------------------------------------------
TAU      <- 18    # RMST horizon. Fixed numerically, identical in every cell and
                  # every censoring regime, so the truth cannot move with follow-up.
T_STAR   <- 12    # milestone survival time (secondary)
T_ADMIN  <- 36    # administrative cutoff in the reference regime
T_GRID   <- c(6, 12, 18)   # time grid for calibration-over-time outcomes

## --- network ----------------------------------------------------------------
## Two studies. The IPD study compares PBO with A; the aggregate study compares
## PBO with B and defines the target population. Every one of the six estimators
## can use both studies in full, so the evidence set is identical across methods
## by construction rather than by assertion. A previous draft used three
## aggregate studies, which no pairwise MAIC or STC can consume without becoming
## a different method; a critique called that out and it is fixed by shrinking
## the network rather than by asserting equivalence.
N_IPD_ARM <- 250  # per arm in the IPD study (PBO, A)
N_AGD_ARM <- 200  # per arm in the aggregate study (PBO, B)
ALLOC     <- 0.5  # equal randomization in both studies

MU_IPD <- 0.00    # covariate mean, IPD study
MU_TGT <- 0.60    # covariate mean, aggregate study = the target population
SD_X   <- 1.00    # covariate SD, both studies and the target law

## Study baselines differ, which is the situation population adjustment exists
## for, and which the rebuilt parameterization tolerates: the treatment contrast
## is invariant to them (verify_invariance(), 4.4e-16).
S_IPD <- 12; S_TGT <- 14        # Weibull scale, per study
B_IPD <- 1/25; B_TGT <- 1/30    # Gompertz level, per study
A0    <- 1.2                    # Weibull shape, placebo
XI    <- 0.05                   # Gompertz rate, placebo

## --- treatment effects ------------------------------------------------------
BETA_A  <- -0.25   # log HR of A versus PBO at t = T0, all cells
GAMMA   <- 0.30    # shared A and B effect modification; 0 in the marginal-PH control

## KAPPA_A IS A DESIGN FACTOR, AND IN VERSION 3 IT WAS FIXED AT ZERO.
##
## A round-three critique found that kappa_A = 0 in every cell put ALL the
## non-proportionality on the aggregate side of the network, which is the side
## neither MAIC weighting nor STC regression ever touches: both act on the IPD
## study, and both consume the same shared aggregate-side fit for B. So the
## MAIC-versus-STC comparison was never exercised under crossing hazards, which
## is exactly the comparison the catalog entry asks for. That was correct and it
## was not visible from the protocol text alone.
##
## Because gamma is shared, the B-versus-A contrast is
## beta_B - beta_A + (kappa_B - kappa_A) g(t), still with NO covariate term, so
## the property that made the mechanism clean survives. Note that kappa_A =
## kappa_B gives a PROPORTIONAL target contrast built from two NON-proportional
## arms, which is a cell worth having and which version 3 could not express.
KAPPA_A_LEVELS <- c(0, 0.30)
KAPPA_A <- 0.00    # default for the cells that do not vary it

## beta_B is NOT a free design number: it is SOLVED per cell so that the true
## target-population RMST difference lands on a registered margin relative to
## the decision threshold (see 04-calibrate.R). A critique showed that the
## previous design's true gains were 1.155, 1.817 and 2.359 months against a
## 0.5-month decision boundary, so every cell was 0.65 to 1.86 months clear of
## it and no estimation error of the size being tolerated could ever change a
## recommendation. Fixing the margin rather than the coefficient is what makes
## the decision rule able to fire.
DELTA_THRESHOLD <- 0.50          # months of RMST gain that justify the cost
MARGIN_LEVELS   <- c(recommend = 0.75, decline = 0.35)   # true Delta_RMST(TAU)

KAPPA_B_LEVELS <- c(0, 0.15, 0.30)

## --- censoring --------------------------------------------------------------
## Independent exponential at a per-study rate plus an administrative cutoff.
## Touches no survival function, so the true estimand is invariant to it by
## construction: that is what makes censoring a manipulation of a nuisance.
##
## E3 (the expensive benchmark) uses THREE conditions, registered in E3_CENS
## below; E1 and E2 (analytic and cheap) use all four, crossed independently.
## Which experiment sees which regime is registered here rather than being left
## to the runtime, because a critique found the four regimes appearing in the
## analysis sections while the cell matrix and the runtime estimate silently
## assumed one.
CENS_REGIMES <- data.frame(
  label     = c("reference", "moderate", "heavy", "short-followup"),
  rate_ipd  = c(0.010, 0.050, 0.100, 0.020),
  rate_agd  = c(0.010, 0.050, 0.100, 0.020),
  t_admin   = c(36,    36,    36,    18),
  stringsAsFactors = FALSE
)
## The benchmark's censoring factor is BETWEEN-STUDY differential follow-up,
## which is what "differential censoring" means in the OUT-11 entry. Arm-
## differential censoring within a comparison is declared out of scope.
##
## THREE CONDITIONS, NOT TWO, AND THE THIRD IS THE MIRROR OF THE SECOND.
##
## Version 4 registered only `balanced` and `differential`, the latter putting
## the heavier censoring on the AGGREGATE study. Checked against E1's full 4x4
## grid, those two conditions span 0.6199 months of the 1.3805 the grid contains,
## which is 45%, and they span it in ONE DIRECTION ONLY: both sit at or above the
## balanced case. E1's minimum, where the IPD study is the heavily censored one,
## was never reachable.
##
## That is a real hole rather than a coverage quibble. With one sign only, every
## estimator's differential-follow-up bias points the same way, and an estimator
## with an offsetting bias reads as accurate. It is the same failure the margin
## cells exist to prevent for the decision rule, one level down. Adding the
## mirror takes coverage to 87% and makes the two departures from balanced
## nearly symmetric, +0.6199 and -0.5794.
E3_CENS <- data.frame(
  label     = c("balanced", "differential", "differential-reversed"),
  rate_ipd  = c(0.010, 0.020, 0.100),
  rate_agd  = c(0.010, 0.100, 0.020),
  t_admin   = c(36,    36,    36),
  stringsAsFactors = FALSE
)

## --- estimation settings ----------------------------------------------------
## Two chains. An earlier version of this file said four, on the reasoning that
## chains run in parallel so four cost the same wall clock. That was asserted,
## not measured, and measuring it showed otherwise: 166.9 s against 74.1 s per
## fit on this machine, because four chains oversubscribe four performance
## cores.
##
## The four-chain choice also rested on the wrong diagnostic. It was made to
## satisfy an ESS floor applied to the GLOBAL minimum over every monitored
## parameter, which runs 25 to 646 and is dominated by weakly identified spline
## nuisance coefficients the study never uses. The registered policy binds on
## the DERIVED estimand, whose ESS was measured above 2000 even at two chains.
N_CHAINS <- 2
N_ITER   <- 1000
## N_INT is NOT set here by citing another study's number. A critique noted that
## the previous draft cited IDN-05's finding that 64 -> 256 integration points
## flipped 8.3% of verdicts and then chose 32, which is below the order IDN-05
## found insufficient. The order is instead MEASURED on this study's own network
## by R/probe-integration.R, comparing the target-standardized RMST difference
## across orders PAIRED WITHIN REPLICATE so the comparison is not swamped by the
## Monte Carlo error of separate MCMC runs.
##
## Measured, pooled over every paired replicate the study has paid for:
##   128 - 64 : +0.0398  SE 0.0174  n=4  t = 2.3
##   256 - 64 : +0.0656  SE 0.0072  n=3  t = 9.1  -> 64 is biased low, decisively
##   256 - 128: +0.0198  SE 0.0129  n=5  t = 1.5  -> not separable from noise
##
## The package default is 64 and it is not adequate for this estimand.
##
## THE ORDER IS 256, AND VERSION 4'S CHOICE OF 128 RESTED ON A COST FIGURE THAT
## WAS WRONG. That version argued "256 in production is about 185 hours, so it
## was never affordable", from a single flexible fit timed at 597 s. That timing
## was taken while another job was running on the same four cores, which nobody
## had checked for. Re-measured at the exact production configuration on a
## verified-quiet machine, a replicate costs 442 s at 256 points against 256.9 s
## at 128: a ratio of 1.72, not the 4.6 the old figure implied. Production at
## 256 is affordable. R/10-budget.R computes the run from the measured unit
## cost and the registered matrix; no hour figure is written here, because a
## hand-typed total that did not follow from its unit costs has produced two
## separate fatal findings in this protocol.
##
## The accuracy argument then decides it. The increments halve with each
## doubling (+0.040 from 64 to 128, +0.020 from 128 to 256), which is what a
## converging quadrature sequence looks like and implies roughly 0.02 months
## still missing at 128. That is the SAME SIZE as the entire measured bias of
## the flexible estimator rows (-0.043 to -0.046 months in the pilot), so at 128
## this study could not distinguish "the flexible methods are nearly unbiased"
## from "their bias is the size of my integration error". At 256 the residual is
## halved again and a registered 512-point arm bounds what is left, which is
## something IDN-05 explicitly could not do for its own 256-point reference.
N_INT <- 256L

## Replicate and bootstrap counts are set from MEASURED cost. THE BUDGET ITSELF
## IS NOT WRITTEN HERE. It is computed in R/10-budget.R from timings measured by
## R/11-measure-production.R and asserted against the protocol by
## review/verify-protocol.py, because a hand-written total that did not follow
## from the unit costs beside it has now produced two separate fatal findings.
##
## Two lessons are worth keeping in the file rather than only in the change log.
##
## FIRST, the arithmetic was wrong in the direction that favored the cheaper
## option. A previous comment claimed "14 cells x 40 reps, 500 resamples ->
## 6.4 h of bootstrap", which implies about 62 resamples per replicate, not 500.
## That understated figure was the number used to argue the counts down.
##
## SECOND, and worse, every timing this study had taken was inflated by machine
## contention nobody had checked for. An earlier probe was still running during
## the "production" measurement and was not noticed, because the process is
## named `R`, not `Rscript`, and the check used to confirm a quiet machine
## grepped for the latter. Re-measured on a verified-quiet machine, a bootstrap
## resample costs 0.467 s rather than 0.711 s, and a flexible fit at 256
## integration points costs 255 s rather than 597 s. The 597 s figure was the
## sole basis for the claim that 256 in production would cost "about 185 hours"
## and was therefore unaffordable, which is how the integration order came to be
## registered at 128.
##
## 40 replicates and 500 resamples are chosen. A previous version chose 25 and
## 250 on wall-clock grounds; that trade was withdrawn once the instruction was
## to prioritize robustness over schedule. 500 resamples is also the point below
## which a percentile interval's endpoints carry visible resampling noise, which
## matters because CI COVERAGE is a registered primary outcome, not a diagnostic.
##
## Pooled over all 14 cell-by-censoring conditions at 40 replicates, the
## coverage rule certifies a genuinely calibrated estimator 95.3% of the time
## against 73.3% at 25 replicates. That is the concrete cost of the cut.
##
## R/07-run.R checkpoints per REPLICATE, not per cell: this machine terminates
## long-running background jobs and a per-cell checkpoint would discard hours of
## finished work each time.
N_BOOT <- 500          # full-pipeline bootstrap resamples, frequentist rows
N_REP  <- 40           # replicates per cell in E3
N_CORES_BOOT <- 4      # the frequentist pass parallelizes; the Stan pass does not

## --- the sensitivity program, registered as a runnable table -----------------
##
## Round 6 found the fourth instance of this study's recurring defect: a
## procedure registered in prose that the code could not perform. The protocol
## named three sensitivity arms, gave them a budget line, and said each runs on
## "the same prespecified subset of two primary cells" without ever saying WHICH
## two; R/07-run.R had no sensitivity pass; and the knot count and prior scales
## the arms are supposed to vary were hardcoded inside the fitting functions. An
## arm that names no cells, has no driver and cannot reach the settings it varies
## is a sentence, not a design.
##
## The two cells, named. Both are `primary` Weibull cells at the `balanced`
## censoring regime, chosen before any E3 result exists and for a stated reason:
## they are the ENDPOINTS of the registered non-proportionality range, so an arm
## that moves the answer in neither of them has been tested where the modeling
## choice bites hardest and where it does not bite at all.
##   kappa_B = 0.30 : the most non-proportional target contrast in the design,
##                    where spline flexibility, integration order and the
##                    auxiliary priors all have the most to do.
##   kappa_B = 0    : the proportional target contrast at the same margin, which
##                    is the null case for every one of the three arms. A shift
##                    here is a shift that has nothing to do with
##                    non-proportionality, so it separates "the setting matters"
##                    from "the setting matters for the thing being studied".
## `balanced` fixes the censoring so the arms vary one thing at a time.
SENS_CELLS <- data.frame(
  arm = "primary", family = "weibull", kappa_a = 0, kappa_b = c(0.30, 0),
  gamma = GAMMA, margin = "recommend", cens = "balanced",
  stringsAsFactors = FALSE)
N_SENS_PER_CELL <- 25L      # replicates per cell per SETTING
N_SENS <- nrow(SENS_CELLS) * N_SENS_PER_CELL   # = 50 fits per setting

## The settings themselves, one row per FIT SET. This is the table the budget
## multiplies and the table R/07-run.R iterates, so the count of fit sets is the
## same number in both places by construction. Round 6 found the budget pricing
## "halved and doubled" and "2 and 5 knots" at one fit set each when each is
## plainly two, understating the sensitivity program by more than twelve hours.
##
##   `stan`  : the setting changes the ML-NMR fits, so the Stan pass reruns.
##   `freq`  : the setting changes the Royston-Parmar rows, so the bootstrap
##             reruns too. Only the knot arm does; the protocol registers the
##             complexity arm "for both bases", and the frequentist half of it
##             had no budget line at all.
##   `cost`  : which measured unit price applies. The 512 arm is the only one
##             that is not priced at the production replicate cost.
SENS_SETTINGS <- data.frame(
  arm     = c("integration", "prior", "prior", "knots", "knots"),
  setting = c("n_int_512", "scales_halved", "scales_doubled",
              "knots_2", "knots_5"),
  n_int   = c(512L, N_INT, N_INT, N_INT, N_INT),
  prior_mult = c(1, 0.5, 2, 1, 1),
  n_knots = c(3L, 3L, 3L, 2L, 5L),
  stan    = TRUE,
  freq    = c(FALSE, FALSE, FALSE, TRUE, TRUE),
  cost    = c("int512", "prod", "prod", "prod", "prod"),
  stringsAsFactors = FALSE)

## The production values the arms perturb, kept here so that "halved and doubled"
## and "2 and 5" have a referent in code rather than only in prose.
## Resamples of the stored bootstrap draws used to put a standard error on each
## percentile-interval endpoint (protocol section 7.2, "the inner Monte Carlo
## error of a 500-resample percentile interval is reported rather than assumed
## negligible"). Involves no model fitting, so this is cheap; 200 is enough for a
## standard error on a standard error and is registered rather than chosen at the
## call site.
N_MCSE_REP <- 200L

PRIOR_REG_SD <- 2.5    # covariate interaction, normal(0, PRIOR_REG_SD)
PRIOR_AUX_SD <- 1.0    # auxiliary parameters, half_normal(PRIOR_AUX_SD)
PRIOR_AUX_REG_SD <- 2.5  # auxiliary regression, normal(0, PRIOR_AUX_REG_SD)
N_KNOTS <- 3L          # internal knots, M-spline and Royston-Parmar alike

## --- E1 and E2, registered here rather than left as function defaults --------
## A round-three critique found that E1's gamma grid and variance ablation, and
## the whole of E2, existed only as hard-coded defaults inside 04-calibrate.R.
## A preregistration that cannot be executed from its own text is not one, and
## the same objection had already been upheld against the E3 parameters in
## round two. These are the executable versions.

## E1: the computed decomposition. Deterministic; no replicates, no seed.
E1_KAPPA_B <- c(0, 0.15, 0.30)
E1_GAMMA   <- c(0, 0.15, 0.30, 0.50)
E1_FAMILY  <- c("weibull", "gompertz")
E1_SD_ABLATION <- c(1.0, 0.5, 1e-6)   # covariate spread, collapsed to zero last
## E1 uses all four regimes in CENS_REGIMES.

## E2: finite-sample scatter of the ANCHORED transported hazard ratio around the
## E1 limit. Two independent two-arm studies, an unadjusted Cox fit in each, and
## a Bucher difference. No population adjustment and no Bayesian machinery, so it
## costs milliseconds per replicate and can afford many.
##
## Version 4 simulated ONE study comparing B against A directly, which is not the
## quantity OUT-11 is about and which round four identified as a fatal. Least-
## false Cox coefficients are not transitive under non-proportional hazards, so
## the direct coefficient and the anchored difference are different numbers.
##
## kappa_A is crossed here as of version 5. With kappa_A fixed at zero the A leg
## was always proportional, so E2 never measured the sampling behavior of a
## least-false coefficient on the side of the network MAIC and STC act on, which
## is the same defect round three found in the E3 cell matrix.
E2_FAMILY   <- "weibull"
E2_GAMMA    <- GAMMA
E2_KAPPA_B  <- c(0, 0.15, 0.30)
E2_KAPPA_A  <- c(0, 0.30)
E2_MARGIN   <- "recommend"    # beta_B solved to the same registered margin as E3
E2_N_A_ARM  <- N_IPD_ARM      # leg A is the IPD study: 250 per arm
E2_N_B_ARM  <- N_AGD_ARM      # leg B is the aggregate study: 200 per arm
N_REP_E2    <- 2000           # replicates per cell per leg per regime
## E2 crosses the two studies' regimes independently over all four in
## CENS_REGIMES, giving a 4 x 4 grid, exactly as E1 does.

## THE COX PROJECTION'S REFERENCE CENSORING REGIME.
##
## Section 4 registers "one PRESPECIFIED Cox projection functional applied to
## every method's fitted target survival curves, so the constant summaries being
## compared are the same functional of different fits". A least-false Cox
## coefficient depends on the censoring that produced it, which is E1's entire
## subject, so the functional is only prespecified if the regime is fixed. It is
## therefore pinned to the balanced regime for every method and every cell, and
## the constant it returns is a comparable summary rather than one that moves
## with the cell's own follow-up.
COX_PROJ_RATE    <- E3_CENS$rate_agd[E3_CENS$label == "balanced"]
COX_PROJ_TADMIN  <- E3_CENS$t_admin[E3_CENS$label == "balanced"]
## The grid the projection integrates over. 200 points reproduces the analytic
## limit to 9e-5 and 2,000 to 1e-5; the frequentist rows already carry 200.
COX_PROJ_NGRID   <- 200L

## --- the divergence criterion, measured before the run rather than after ------
##
## THE SAME DEFECT THE ESS CRITERION HAD, SURVIVING IN THE OTHER HALF OF THE SAME
## RULE. Section 7.2 already records that the first sampler policy was
## "unmeetable", that probe fits returned Rhat 1.011 to 1.015 and minimum ESS 229
## to 355, and that "essentially every fit in the run would have been declared a
## failure, which is a policy that reports nothing except its own threshold". The
## ESS half was fixed by binding on the derived estimand. The `divergent == 0`
## half was left untouched, and it is now the binding constraint.
##
## Measured on one PRODUCTION replicate before the Stan pass started, at the
## registered settings, on the first cell:
##
##   arm         after escalation   divergences   Rhat     ESS bulk / tail
##   MLNMR-PH    adapt_delta 0.99     8 / 2000   1.0007      1696 / 1258
##   MLNMR-flex  adapt_delta 0.99     3 / 2000   1.0002      2015 / 1569
##
## Both arms failed the policy. Both failed on divergences ALONE; every other
## criterion passed with room to spare, and both had already been refit once at
## doubled iterations and adapt_delta 0.99. A criterion that rejects a fit with
## Rhat 1.0007 and 1,696 effective draws on the registered estimand is not
## measuring whether the estimand is trustworthy.
##
## Two consequences, both registered rather than discovered mid-run:
##   1. The criterion becomes a RATE, at a level the measurement above justifies
##      and which is stated before the run rather than tuned to it.
##   2. The refit escalation fires on essentially every fit, not on 20%, so the
##      Stan pass costs about twice its booked figure. R/10-budget.R carries the
##      revised assumption and R/19-realized-cost.R reports the realized rate.
##
## The analysis is repeated on the ZERO-DIVERGENCE subset regardless, so a reader
## who does not accept the rate can see whether it changes anything.
DIVERGENT_RATE_MAX <- 0.01     # 1% of post-warmup draws
REFIT_RATE_ASSUMED <- 1.00     # measured 2 of 2; was assumed 0.20

SEED <- 20260728

## --- helpers ----------------------------------------------------------------
## Build an arm specification for a given study and treatment.
make_arm <- function(family, study = c("ipd", "tgt"),
                     beta = 0, kappa = 0, gamma = 0) {
  study <- match.arg(study)
  list(family = family,
       a0  = A0,
       s_j = if (study == "ipd") S_IPD else S_TGT,
       xi  = XI,
       b_j = if (study == "ipd") B_IPD else B_TGT,
       beta = beta, kappa = kappa, gamma = gamma)
}

## THE PLACEBO ARM HAS NO COVARIATE EFFECT, AND IT MUST BE BUILT THROUGH THIS
## FUNCTION RATHER THAN BY PASSING gamma = 0 BY HAND.
##
## The registered mechanism makes the covariate a PURE EFFECT MODIFIER: it acts
## only in interaction with treatment, so placebo survival does not depend on x
## at all. `sim_network` implements that, with `gamma = switch(trt, PBO = 0,
## gamma)`, and the protocol verifies it by showing placebo survival at t = 12 is
## 0.4356 at x = -2, 0 and +2.
##
## Round 6 found that EVERY ANALYTIC CALCULATION IN THE STUDY VIOLATED IT.
## E1, E2, cell_properties, the graft bound and the anchoring diagnostic each
## built the placebo arm as `make_arm(..., beta = 0, kappa = 0, gamma = gamma)`,
## which makes the covariate prognostic under placebo and therefore removes it
## from every active-versus-placebo conditional contrast. Eighteen sites across
## six files, all of them a plausible-looking argument list.
##
## The cost was not cosmetic. Placebo RMST(18) in the target population is
## 10.5162 under the registered mechanism and 9.5966 under the accidental one,
## and the second number was being used as "truth" for the flexible ML-NMR arm's
## target-standardized placebo curve. That produced a reported absolute-scale
## bias of +1.028 months at 3.6 Monte Carlo standard errors, then a large-sample
## diagnostic at four times the arm sizes to decide whether it was structural.
## Against the registered truth the same fitted value is high by 0.109 months,
## which is the size of the errors on the two active arms beside it. The
## estimator was right and the yardstick was wrong.
##
## `truth_delta` is unaffected, because the estimand is B minus A and no placebo
## enters it, so every solved beta_B and every registered margin stands.
placebo_arm <- function(family, study = c("ipd", "tgt"))
  make_arm(family, study, beta = 0, kappa = 0, gamma = 0)
