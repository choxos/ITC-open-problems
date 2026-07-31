## ---------------------------------------------------------------------------
## EST-07: everything the protocol will register, in executable form.
##
## THE CODE COMES FIRST HERE, DELIBERATELY. CMP-14 shipped six protocol versions
## containing procedures no code could perform, because the document was written
## first and the code chased it. The order is inverted: this file and the ones
## beside it are written and probed, and the protocol quotes them. Nothing is
## registered until probes P1 to P4 in DESIGN.md section 10 have run.
##
## Constants that DESIGN.md fixes are marked `design`. Constants a probe must set
## are marked `probe` and hold a placeholder that `R/01-probe-*.R` overwrites;
## `probes_done()` refuses to let the run start while any placeholder survives,
## so a forgotten probe stops the study rather than silently registering a guess.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260730L

## --- the estimand -----------------------------------------------------------
##
## The target-superpopulation marginal effect is a functional of the target
## covariate LAW, not of its moments:
##
##   Delta(F_T) = g( int mu_1(x) dF_T ) - g( int mu_0(x) dF_T ).
##
## Under an identity link with additive effect this collapses to a function of
## the mean alone, which is MIS-03's case and why matching means was exact there.
## Under a curved link it does not, and the whole study is about what follows.
LINKS <- c("identity", "logit", "cloglog")   # design: identity is the falsifier

## The two estimands, computed on EVERY replicate. A design carrying only one
## cannot separate "the interval is too narrow" from "the interval is for a
## different estimand", which is the distinction the catalog entry itself draws.
ESTIMANDS <- c("superpopulation", "finite_target")

## --- design factors, DESIGN.md section 4 ------------------------------------
LEVELS <- list(
  ## The two non-collapsible scales MAIC is actually used for, plus the
  ## collapsible one that serves as the headline's falsifier. `cloglog` is the
  ## Weibull PH arm's link on the cumulative-hazard scale.
  link = LINKS,

  ## Sampling error in the reported moments scales as 1/nT.
  nT = c(100L, 300L, 1000L),

  ## THE SOURCE SIZE IS A FACTOR, and pinning it was a design error that PROBE P2
  ## caught before any replicate ran.
  ##
  ## The design reasoned that MIS-03 found the magnitude tracks the source-to-
  ## target RATIO, so varying nT alone would span it. It does not: the omitted
  ## variance is fixed by nT while the RETAINED source variance is fixed by nS,
  ## so with nS pinned at 500 the source term dominates everywhere. Measured on
  ## the study's own primary arm, logit at nT = 100 with k = 0:
  ##
  ##     nS =   500  ->  2.6% of total variance   (below P2's 4% floor)
  ##     nS =  2000  ->  9.5%
  ##     nS =  8000  -> 29.8%
  ##     nS = 20000  -> 50.9%
  ##
  ## At the registered nS the primary arm could not have detected its own
  ## headline: a 44% error in a term worth 2.6% of the variance moves coverage by
  ## far less than the 0.005 Monte Carlo SE the design budgets for.
  ##
  ## THIS IS THE PILOT MISTAKE MIS-03 DOCUMENTED AND THIS DESIGN REPEATED.
  ## MIS-03's own configuration says: "A pilot holding nS = 500 found the omission
  ## was 1% to 7% of total variance and concluded nothing was wrong; raising nS to
  ## 2000 took the same quantity to 23%." Reading that as a statement about the
  ## ratio rather than about the source size is what pinned it here.
  nS = c(500L, 2000L, 8000L),

  ## MIS-03's alignment parameter. 0.25 is its registered cancellation point.
  ## MIS-03 had NO interior k, which is exactly what left its recommendation
  ## silent between 1/4 and 1/2; 0.5 is that interior point.
  k = c(0, 0.25, 0.5, 1.0),

  ## Non-normality is untested in MIS-03 and is the assumption its correction is
  ## derived under.
  shape = c("mvnorm", "lognormal", "mixed"),

  ## The reconstructed-correlation component. `cpaic` borrows from the source
  ## exactly the way the middle level does.
  corr_assumed = c("true", "borrowed", "independence"),

  ## MIS-03 has effect modification exactly in the span of the matched moments,
  ## so it is a variance result under correct identification and says nothing
  ## about bias. `outside` puts one modifier out of that span.
  modifier_span = c("inside", "outside")
)

## The first four are fully crossed within each link; the last three are crossed
## with k and nT at the middle level of the others. The realized cell count is
## PROBE P2's output and is asserted, never typed.
GRID_MIDDLE <- list(nT = 300L, nS = 2000L, k = 0.25, shape = "mvnorm",
                    corr_assumed = "true", modifier_span = "inside")

## --- held fixed, DESIGN.md section 4 ----------------------------------------
N_COVARIATE <- 3L          # design: three covariates, one the primary modifier
OVERLAP_SMD <- 0.4         # design: the moderate level of Phillippo et al. 2020
ANCHORED    <- TRUE        # design: anchored throughout

## --- replicates and Monte Carlo error ---------------------------------------
##
## Coverage MCSE at c = 0.95 is sqrt(0.95 * 0.05 / n_sim). The design's TARGET is
## 0.005, because the effects MIS-03 measured span 92.1% to 96.2% and a 0.005
## MCSE resolves that range into distinguishable levels.
##
## ROUND 1 OF CRITIQUE: both numbers were typed, and one of them was then quoted
## as if it were achieved. The target is a design input; the replicate count
## follows from it; and the MCSE the study ACTUALLY HAS is what 2000 replicates
## deliver, which is 0.00487 rather than 0.005. Quoting the target as the achieved
## error is small here and is the same defect as the cell floor, where a number
## was derived wrongly and its sentence went on asserting the derivation.
##
## So the chain runs in code: target -> count -> achieved.
COVERAGE_MCSE_TARGET <- 0.005

## The count the target implies, rounded UP to a round number so the achieved
## error is at least as good as the target rather than nearly as good.
N_REP <- local({
  need <- NOMINAL_FOR_MCSE <- 0.95
  n <- need * (1 - need) / COVERAGE_MCSE_TARGET^2       # 1900
  as.integer(ceiling(n / 500) * 500)                    # 2000
})

## What that count actually delivers. This, not the target, is the number any
## claim about resolving a coverage difference must be judged against.
COVERAGE_MCSE_AT_N <- sqrt(0.95 * 0.05 / N_REP)

## Common random numbers across the assumed-correlation arm and the
## fixed-versus-corrected variance arms, since those differ only in an analysis
## choice applied to identical data. MCSE is therefore CLUSTERED ON THE REPLICATE
## BLOCK, which is the correction OUT-11 needed and did not have until round 6
## found it.
CRN_BLOCKS <- c("corr_assumed", "variance_method")

## The tolerance below which the estimand's dependence on the target law counts
## as vanishing, used by probe P7's null control. Set at the numerical noise floor
## of a central difference on this estimand rather than at a substantive level:
## the identity link is collapsible, so the gradient there is zero exactly and any
## departure is arithmetic.
NULL_TOL <- 1e-8

## --- decision rule, DESIGN.md section 7 -------------------------------------
NOMINAL     <- 0.95
COVER_BAND  <- c(0.935, 0.965)   # design: two-sided, both ends are failures
## CMP-14 registered its band one-sided and counted 76 over-covering scenarios as
## successes for two rounds before a reviewer found it.

## --- probe outputs, which no one may type -----------------------------------
##
## Each holds NA until its probe writes it. `probes_done()` is called by the run
## script and by the exporter.
PROBE_PLACEHOLDER <- NA_real_
QUAD_ORDER     <- PROBE_PLACEHOLDER   # probe P1: order stable to 1e-4
QUAD_TOL       <- 1e-4                # design: the stability target itself
N_CELLS        <- PROBE_PLACEHOLDER   # probe P2: realized cell count
P3_MAX_REL_ERR <- PROBE_PLACEHOLDER   # probe P3: agreement with the closed form
SEC_PER_REP    <- PROBE_PLACEHOLDER   # probe P4: measured unit cost

PROBE_FILE <- "results/probes.rds"

## Reading the probe outputs back is the only way they enter the run. A probe
## that has not run leaves NA here, and every caller stops.
load_probes <- function(path = PROBE_FILE) {
  if (!file.exists(path)) return(NULL)
  readRDS(path)
}

probes_done <- function(need = c("QUAD_ORDER", "N_CELLS", "P3_MAX_REL_ERR",
                                 "SEC_PER_REP"), path = PROBE_FILE) {
  p <- load_probes(path)
  missing <- need[!need %in% names(p)]
  if (!is.null(p)) {
    bad <- need[need %in% names(p)][
      !vapply(p[need[need %in% names(p)]], function(z) is.finite(z[[1]]), TRUE)]
    missing <- c(missing, bad)
  }
  if (length(missing))
    stop("these probe outputs have not been computed, so the run would ",
         "register a guess:\n  ", paste(missing, collapse = "\n  "),
         "\nRun R/01-probe-quadrature.R, R/02-probe-grid.R, ",
         "R/03-probe-closed-form.R and R/10-budget.R.")
  ## Install them under their registered names, so downstream code reads a
  ## constant rather than reaching into a list.
  for (nm in need) assign(nm, p[[nm]][[1]], envir = globalenv())
  invisible(p)
}
