## The design.
##
## Revised after an adversarial review of the proposed design found four fatal
## problems. Each change is recorded in protocol.md with its reason; the two that
## reshaped the study are here.
##
## THE GROUND TRUTH IS A CONSEQUENCE, NOT A GEOMETRY. The proposed design defined
## "prior-driven" by a weak-direction variance share W_c, thresholded at a
## likelihood-to-prior precision ratio of 0.25, and evaluated diagnostics against
## it. For a contrast aligned with one eigen-direction, contraction is exactly
## lambda / (1 + lambda), so lambda = 0.25 is contraction = 0.20, which was also
## the prespecified contraction threshold. Measuring contraction's sensitivity
## against that reference would have measured an algebraic identity and reported
## it as diagnostic accuracy.
##
## So the reference is now what actually goes wrong: an interval that misses the
## truth, and a confident decision in the wrong direction. No diagnostic's
## definition determines either. W_c is kept as a descriptive covariate and is
## never used as a gold standard.
##
## SCOPE IS NARROWER THAN PROPOSED. The review established that this design has
## treatment-specific parameters rather than component effects, and no
## within-versus-between discrepancy at all, so it cannot speak to CMP-14's
## component setting or to IDN-06's ecological conflation. IDN-06 is dropped.

MASTER_SEED <- 20260729L
N_REP <- 2000L

LEVELS <- list(
  ## What evidence exists about treatment C, whose interaction is the weak one.
  ##
  ## `agd-flat` and `agd-narrow` are POSITIVE CONTROLS. They are engineered so
  ## the likelihood carries almost no information about the interaction, and any
  ## failure there is a demonstration that the machinery works, not evidence that
  ## the situation is common. The review was right that presenting them as
  ## evidence of practical prevalence would be building the conclusion in.
  geometry = c("within-ipd", "agd-wide", "agd-narrow", "agd-flat", "disconnected"),
  n_arm = c(100L, 400L),
  ## Whether the truth agrees with the zero-centered prior. At 0 the prior is
  ## right by luck and a prior-driven answer is accidentally correct, which is
  ## exactly when a diagnostic must not be credited for silence.
  gamma_C = c(0, 0.40),
  prior = c("tight", "regular", "weak"),
  ## Target population. At 0 the interaction cancels out of the decision
  ## contrast; at 0.75 it carries it.
  mu_target = c(0, 0.75)
)

build_scenarios <- function() {
  g <- expand.grid(geometry = LEVELS$geometry, n_arm = LEVELS$n_arm,
                   gamma_C = LEVELS$gamma_C, prior = LEVELS$prior,
                   mu_target = LEVELS$mu_target,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[order(g$geometry, g$n_arm, g$gamma_C, g$prior, g$mu_target), ]
  g$scenario <- seq_len(nrow(g))
  g$positive_control <- g$geometry %in% c("agd-flat", "agd-narrow")
  rownames(g) <- NULL
  g
}

## What counts as harm, per replicate and per contrast.
##
## `miss`  the 95% credible interval does not contain the true value.
## `wrong` the posterior puts at least 95% of its mass on the wrong side of zero.
##
## Both are consequences an analyst would care about and neither is definable
## from any diagnostic's formula.
HARM <- list(level = 0.95, confident = 0.95)

## A scenario is harmful when coverage falls materially below nominal. This is
## the unit the primary measure is computed over.
HARM_CELL <- list(coverage_below = 0.90)

## The prespecified conclusions.
##
## Symmetric, after the review found the proposed pair heavily favored a positive
## verdict: "real" needed one successful comparison anywhere while "not real"
## needed every comparison to be negligible.
DECISION <- list(
  diagnostics_work =
    "Macro-averaged sensitivity of the composite warning across harmful scenarios
     is at least 0.80, and its false-warning rate across scenarios with coverage
     at or above 0.94 is at most 0.20, both with Monte Carlo 95% intervals
     excluding the threshold.",

  diagnostics_fail =
    "Macro-averaged sensitivity is at most 0.50, or the false-warning rate is at
     least 0.50, with Monte Carlo 95% intervals excluding those thresholds.",

  diagnostics_partial =
    "Neither of the above: the composite discriminates but not well enough to be
     relied on unattended. Report the per-diagnostic operating characteristics
     and the region in which each works.",

  uninformative_if =
    "Fewer than four harmful scenarios exist outside the positive controls, so
     sensitivity is estimated only where the failure was engineered; or the exact
     posterior disagrees with the Stan fit of the same model beyond Monte Carlo
     error on the validation subset, meaning the Gaussian reduction is wrong."
)
