## ---------------------------------------------------------------------------
## IDN-05: the power and calibration of the split-interaction check on the
## shared effect modifier assumption.
##
## Everything the design commits to lives here. Nothing below is chosen after
## seeing a result.
##
## This file is the SECOND version. The first was submitted for adversarial
## critique before any replicate was run, and six findings were confirmed
## numerically and applied. The most consequential: with three active treatments
## rotated over the aggregate studies, every six-study network gave an
## aggregate-only treatment exactly ONE study, so the fully relaxed model
## estimated four coefficients for that treatment from one contrast. Those fits
## would have reported the prior, not the check. critique/ holds the critique and
## the response.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(multinma)
  library(dplyr)
})

## --- true individual-level model -------------------------------------------
## logit p = mu_j + beta'x + 1{active} (d_k + delta_jk + gamma_k'x)

K_COV   <- 2L                      # x1 drifts, x2 is truly shared
MU_SD   <- 0.15                    # between-study intercept variation
BETA    <- rep(0.40, K_COV)        # prognostic effects
D_ACT   <- 0.70                    # main effect, same for A and C
G0      <- 0.30                    # shared interaction level
RHO     <- 0.25                    # covariate correlation
SIGMA_X <- {s <- matrix(RHO, K_COV, K_COV); diag(s) <- 1; s}
P_REF   <- 0.30                    # marginal placebo risk, held FIXED in every
                                   # target population (see MU_REF below)

## Two covariates, not three. With K covariates the model lattice has 2^K
## members; at K = 2 the four fits below ARE the complete lattice, so
## "check then relax exactly what flagged" is a strategy the study can score
## rather than approximate by always jumping to the fully relaxed model.

## --- drift is the contrast, not half of it ------------------------------------
## The quantity that matters is the difference between the two treatments'
## interactions, and it is what DRIFT names directly. The first version of this
## design called the per-treatment deviation "drift", so every reported number
## was half the contrast it appeared to describe.
##   gamma_A[x1] = G0 + DRIFT/2,  gamma_C[x1] = G0 - DRIFT/2,  gamma_A - gamma_C = DRIFT
## x2 is shared exactly: gamma_A[x2] = gamma_C[x2] = G0.
gamma_true <- function(drift) {
  g <- matrix(G0, nrow = 2, ncol = K_COV,
              dimnames = list(c("A", "C"), paste0("x", seq_len(K_COV))))
  g["A", "x1"] <- G0 + drift / 2
  g["C", "x1"] <- G0 - drift / 2
  g
}

## --- network -----------------------------------------------------------------
TRT_REF    <- "PBO"
TRT_ACTIVE <- c("A", "C")          # one class: the restriction binds across these
IPD_ACTIVE <- "A"                  # individual-level studies always compare PBO with A
N_IPD_ARM  <- 250L
N_AGD_ARM  <- 200L

## Aggregate studies alternate starting with C, so the aggregate-only treatment
## never has fewer studies than the one that also has individual data. With the
## smallest network this gives C three aggregate studies for the three
## coefficients the fully relaxed model gives it, which is exact identification
## with no redundancy; the largest network gives six. Identification is thin by
## design at the small end, because that is the regime the problem is about, and
## prior-posterior contraction is recorded for every coefficient so a fit that
## reported the prior can be told apart from one that reported the data.
agd_allocation <- function(J, n_ipd) {
  n <- J - n_ipd
  rev(TRT_ACTIVE)[((seq_len(n) - 1L) %% length(TRT_ACTIVE)) + 1L]
}

## --- design factors ---------------------------------------------------------
FACTORS <- list(
  drift     = c(0, 0.30, 0.60, 1.20),  # gamma_A - gamma_C on the log-odds scale
  n_studies = c(6L, 12L),
  spread    = c(0.25, 0.60),           # SD of study covariate means: the
                                       # ecological information about interactions
  tau_re    = c(0, 0.15)               # between-study SD of the treatment effect
)
N_IPD <- 1L    # one individual-level study: the situation population adjustment
               # exists for, and fixed rather than varied so that a factor could
               # be spent on treatment-effect heterogeneity instead

## Treatment-effect heterogeneity is here because the pre-run critique named its
## absence as the design's largest omission, and the arithmetic supports that:
## the between-study ecological signal about a treatment's interaction has SD
## about drift x spread, which is 0.075 at drift 0.30 and spread 0.25. A random
## effect of SD 0.15 is twice that, so it can manufacture apparent drift under
## the null and hide real drift. Excluding it would have made every number in
## this study a best case without saying so.

DESIGN <- expand.grid(FACTORS, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
DESIGN$cell <- seq_len(nrow(DESIGN))

## --- amendment, cells 33 to 40: the decision boundary --------------------------
## A second pre-run critique arrived while cells 9 to 16 were running and found
## that the drift grid skips the region a check has to discriminate in. In units
## of EPS, the contrast that makes the target estimate exactly material at
## displacement 1, the registered levels are 0, 1.96, 3.92 and 7.84. There is
## nothing between the null and twice the boundary, so the design as registered
## measures the floor and the ceiling and not the part in between.
##
## Eight cells are added at drift 0.15, one EPS, crossing the other three factors.
## They are appended rather than interleaved so that cells 1 to 32 keep their
## numbering, their random streams and their already-computed results. The
## amendment is recorded here, in the protocol, and in the manuscript, with the
## reason and the timing, and no result from these cells was seen before they were
## specified.
EXT <- expand.grid(drift = 0.15, n_studies = FACTORS$n_studies,
                   spread = FACTORS$spread, tau_re = FACTORS$tau_re,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
EXT$cell <- nrow(DESIGN) + seq_len(nrow(EXT))
DESIGN <- rbind(DESIGN, EXT[, names(DESIGN)])
BOUNDARY_CELLS <- EXT$cell

N_REP <- 50L
## 50 rather than the 200 first planned. The estimator is a Bayesian ML-NMR fitted
## four times per replicate, and this machine (Apple M2, four performance cores,
## one of them occupied by a system process) sustains 2.6x speedup at three
## workers and less at four. Measured throughput is 8.1 s per replicate, so the
## design as registered costs about four hours at this size. Precision follows the
## level at which each quantity is reported. The primary quantity is pooled over
## all 32 cells at one displacement, about 1500 observations, with Monte Carlo
## standard error near 0.011. Type I error pools the 8 null cells over both
## covariates, 720 observations, standard error 0.008. Power is reported by
## stratum, four cells pooled, standard error 0.032. Per CELL the standard error
## is 0.065, which is why no per-cell difference below about 0.13 is claimed and
## why nothing in this study is read off a single cell.

## Cells are enumerated with `drift` varying fastest. Study 4 of this program
## published a calibration analysis confounded by exactly this, because an
## odd/even cell split lined up with a factor. Every held-out fold in this study
## is defined by a FACTOR LEVEL, never by a cell index, and all four target
## displacements from one simulated dataset stay in the same fold.

## --- target populations ------------------------------------------------------
## The check reads only the fitted network, so its output cannot depend on the
## population an analyst later transports to. One set of fits is therefore scored
## at every displacement, and that invariance is the mechanism under test.
TARGET_SHIFT <- c(0, 0.5, 1.0, 1.5)   # SDs along the drifting covariate

target_mean <- function(s) c(s, rep(0, K_COV - 1L))

## Displacing the target along x1 moves the treatment contrast AND, because x1 is
## prognostic, the placebo risk: from 0.32 to 0.45 in the first version of this
## design. Risk differences are then compared across displacements at different
## points on the logistic curve, which confounds effect-modifier extrapolation
## with a changing scale. The reference intercept is therefore solved separately
## for each displacement to hold the marginal placebo risk at P_REF exactly.
MU_REF <- NULL   # filled by 01-dgm.R, one value per TARGET_SHIFT

## --- fitting -----------------------------------------------------------------
## chains = 2 is not a tuning choice. With chains = 1, multinma 0.9.1.9002 fails
## to initialise the Stan sampler (nint_vec dimension mismatch, raised while
## setting up the integration-convergence check) and returns an object that looks
## like a fit until dic() is called on it.
N_INT    <- 64L
N_CHAIN  <- 2L
N_ITER   <- 1000L
N_WARMUP <- 500L
PRIOR_INTERCEPT <- normal(0, 10)
PRIOR_TRT       <- normal(0, 10)
PRIOR_REG       <- normal(0, 2.5)
PRIOR_REG_SD    <- 2.5
PRIOR_REG_ALT   <- normal(0, 1)    # prior-sensitivity arm, run on a prespecified
PRIOR_SENS_CELLS <- NULL           # subset (set in 00b below)

## A fit is used only if it satisfies all of these. "Returned an object" is not a
## criterion; multinma returns one when Stan never started.
FIT_OK_RHAT <- 1.05
FIT_OK_ESS  <- 100
FIT_OK_DIVERGENT <- 0

## The complete lattice for K = 2.
FIT_SPLITS <- list(common = character(0), split_x1 = "x1", split_x2 = "x2",
                   split_all = c("x1", "x2"))

## --- what counts as an error -------------------------------------------------
MATERIAL <- 0.03                   # absolute risk, on the C versus A contrast

## --- operational readings of the check ---------------------------------------
## With two active treatments there is exactly one interaction contrast per
## covariate, gamma_A[x] - gamma_C[x], so no pair is selected and the credible
## interval keeps its nominal meaning. The first version of this design had three
## treatments and read the widest of three pairwise differences, which is a
## selected contrast whose 95% interval is not a 95% interval.
DIC_CUTS  <- c(2, 5, 10)
DIC_MAIN  <- 5
POST_LEVEL <- 0.95
## A rule with a margin, as well as one against exactly zero. EPS is the
## interaction contrast that produces a material error at displacement 1, so the
## margin is set by what would matter rather than by taste; 01-dgm.R computes it
## and 04-run.R records it.
EPS <- NULL

## --- prespecified verdict rule ------------------------------------------------
## PRIMARY. The question a committee asks is what a pass licenses, so the primary
## quantity is P(material error | the check passed), not P(pass and material
## error). The first version used the joint probability, which moves with the
## prevalence of error rather than with the check's information, and it required
## sensitivity 0.80 in every one of 128 stratum-by-displacement combinations,
## which no finite simulation can pass even when the truth is exactly 0.80.
##
## The check earns the reassurance it is read as giving if the upper 95%
## confidence bound on P(material error | passed), pooled over the deployment
## distribution at displacement 1.0, is below 0.10.
VERDICT_PASS_RISK <- 0.10

## SECONDARY, on the diagnostic's own terms: power to detect the interaction
## violation it is designed to detect, and type I error under the global null.
## These are reported per stratum with Monte Carlo intervals, not thresholded.
VERDICT_MIN_PREVALENCE <- 0.05

## --- prespecified mechanism claims -------------------------------------------
MECHANISM <- list(
  M1_decoupling = list(
    claim = paste("The check's output is identical at every target displacement",
                  "(a bookkeeping identity: the difference must be exactly 0,",
                  "and any departure is a coding error), while",
                  "P(material error | passed) rises by at least 0.20 from",
                  "displacement 0 to displacement 1.5."),
    conditional_rise = 0.20),
  M2_identification = list(
    claim = paste("Prior-posterior contraction for the interaction of the",
                  "aggregate-only treatment C is at least 0.20 lower than for",
                  "the individual-level treatment A, and the gap widens as the",
                  "network shrinks."),
    gap = 0.20),
  M3_type1 = list(
    claim = paste("Under the global null (drift 0), the DIC rule at cut 5 and",
                  "the 95% posterior rule have materially different type I",
                  "error, differing by at least 0.05."),
    gap = 0.05),
  M4_disagreement = list(
    claim = paste("The DIC rule and the posterior rule disagree in at least 10%",
                  "of replicates, so 'compare posteriors and model fit' is not",
                  "one procedure."),
    rate = 0.10)
)

## --- strategies compared ------------------------------------------------------
## check_then_relax relaxes EXACTLY the covariates that flagged, which the
## complete lattice makes available.
STRATEGIES <- c("always_common", "always_relaxed", "check_then_relax")

## Net benefit needs an action, and the action here is to distrust the adjusted
## estimate and commission individual data. The threshold is the probability of
## material error at which that cost is worth paying, swept over a range rather
## than fixed, since nothing in the literature sets it.
NB_THRESHOLDS <- seq(0.05, 0.60, by = 0.05)

## --- deployment weights -------------------------------------------------------
## A declared judgment, not a measurement. Primary results are reported WITHIN
## strata; these weights are used only where a single number is unavoidable.
## The boundary cells are an amendment and are excluded from the deployment
## mixture, which was registered over the original four drift levels. They are
## reported on their own.
DEPLOY <- list(
  drift     = c("0" = 0.40, "0.3" = 0.30, "0.6" = 0.20, "1.2" = 0.10),
  n_studies = c("6" = 0.55, "12" = 0.45),
  spread    = c("0.25" = 0.50, "0.6" = 0.50),
  tau_re    = c("0" = 0.35, "0.15" = 0.65)
)

deploy_weight <- function(d) {
  w <- rep(1, nrow(d))
  for (f in names(DEPLOY)) w <- w * DEPLOY[[f]][as.character(d[[f]])]
  w / sum(w)
}

## --- reproducibility ----------------------------------------------------------
SEED_BASE <- 20260727L
