## ---------------------------------------------------------------------------
## DIA-02: registered constants.
##
## The proposition is that the reported overlap panel is a function of the weight
## MULTISET alone, so it cannot see where in covariate space the support sits. The
## refuting sentence is that in realistic covariate laws concentration and
## geometry move together tightly enough that the panel is an adequate proxy, and
## that a counterexample needs configurations that do not occur.
##
## THE STUDY'S OWN FALSIFIER RUNS FIRST. If matched-multiset pairs with materially
## different geometry cannot be constructed in a realistic law, the refuting
## sentence stands and there is no study. That is probe P2, and it decides whether
## anything else is worth running.
##
## Nothing here is a placeholder for a number a probe will supply. Where a probe
## sets a constant it is named `PROBE_PLACEHOLDER` and `probes_done()` stops any
## run that reaches production without it.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260801L

## --- the covariate law and the source/target populations --------------------
##
## Dimension is a registered factor: how localized a support hole can be depends
## on it, and a hole in three dimensions is a different object from one in eight.
LEVELS <- list(
  dim              = c(3L, 8L),
  ## Where the source density is thin relative to the target. `none` is the null
  ## control; the contrast between the other two is the whole study, because they
  ## differ in decision relevance and not in how much mass is missing.
  hole             = c("none", "low_modification", "high_modification"),
  ## The conventional axis, crossed so the manipulation is not confounded with it.
  overlap          = c("good", "moderate"),
  ## Section 2 consequence 3: balance is reported on the moments that were
  ## matched, which is tautological. Leaving one modifier's second moment
  ## unmatched is what gives the cheap candidate something to see.
  omitted_moment   = c("none", "one_modifier_second_moment"),
  modification     = c("moderate", "strong")
)

## The middle of the grid, for probes that vary one factor at a time.
GRID_MIDDLE <- list(dim = 3L, overlap = "good",
                    omitted_moment = "none", modification = "moderate")

## SOURCE SIZE IS SET FROM THE THRESHOLD, not typed. `MATERIAL_ERROR` is a
## decision quantity: a marginal risk difference wrong by more than 0.03 changes
## which treatment a payer reimburses. It must not move to suit the data, so the
## study has to be powerful enough to resolve it.
##
## At 1000 source records it is not. Measured with NO support hole and good
## overlap, the estimator's own error has median 0.0224 and 95th percentile
## 0.0640, and exceeds 0.03 on 0.368 of replicates. The null control, which
## requires every diagnostic to be at chance where there is no hole to detect,
## fails there for a reason that has nothing to do with geometry: the threshold
## sits below the sampling noise. That is the same defect IDN-05 documented, where
## a 0.03 absolute-risk threshold proved unreachable by any procedure in a
## six-study network, and it is worth naming twice because it is easy to read a
## floor as a finding.
##
## Measured floor by source size (250 replicates each, no hole, good overlap):
##
##      n      median      p95   P(error > 0.03)
##   1000      0.0224   0.0640   0.368
##   4000      0.0131   0.0329   0.084
##  16000      0.0061   0.0179   0.000
##
## 16000 is registered: it is the smallest of these at which the null control can
## pass, so any material error the study reports is attributable to the support
## hole rather than to its own noise.
N_SOURCE <- 16000L
N_TARGET <- 4000L   # target records, used for truth and never shown to a method

## --- the outcome model ------------------------------------------------------
##
## Binary outcome on a logit scale, so the estimand is non-collapsible and the
## error a support hole causes is not an artifact of a linear scale.
ALPHA     <- -0.5    # baseline log odds
TAU0      <-  0.4    # treatment effect at the covariate origin
BETA_PROG <-  0.35   # prognostic coefficient, applied to every covariate
EM_STRENGTH <- c(moderate = 0.5, strong = 1.0)

## --- material error ---------------------------------------------------------
##
## The derived estimand for the classifier analysis. Set from the decision context
## rather than from the spread of the estimates, so it does not move with the
## results: a marginal risk difference wrong by more than this would change which
## treatment a payer reimburses at the margin.
MATERIAL_ERROR <- 0.03

## --- how a hole is defined --------------------------------------------------
##
## The support-hole location is the region of target covariate space where the
## source density is below this quantile of its own distribution. Registered
## rather than tuned, because a hole defined post hoc to be where the errors are
## would make every diagnostic look good.
HOLE_QUANTILE <- 0.10

## The share of the target's effect-modification mass a hole must contain to count
## as sitting in a high-modification region. This is what makes the two hole
## placements differ in decision relevance rather than in size.
HIGH_MOD_SHARE <- 0.25

## --- the matched-multiset tolerance -----------------------------------------
##
## Exact equality of the weight multiset across support arms is not attainable
## while also moving the geometry, so the design registers how close is close
## enough: every panel member must agree between arms to within this relative
## tolerance. THE ANALYSIS REPORTS THE RESIDUAL, and if the panel differs by more
## than this the manipulation has failed and the study says so rather than
## proceeding to score classifiers on a comparison that did not happen.
PANEL_MATCH_TOL <- 0.02

## --- replication ------------------------------------------------------------
N_REP <- 2000L
NOMINAL <- 0.95

PROBE_PLACEHOLDER <- NA_real_
QUAD_ORDER <- PROBE_PLACEHOLDER   # probe P1
PROBE_FILE <- "results/probes.rds"

load_probes <- function(path = PROBE_FILE)
  if (file.exists(path)) readRDS(path) else NULL

probes_done <- function(need = c("QUAD_ORDER"), path = PROBE_FILE) {
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
