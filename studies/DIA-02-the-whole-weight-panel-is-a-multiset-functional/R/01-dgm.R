## ---------------------------------------------------------------------------
## The data-generating mechanism, and the manipulation the study rests on.
##
## THE MANIPULATION, stated plainly. Both support arms remove the SAME AMOUNT of
## source mass, using the same threshold on a standard normal coordinate. They
## differ only in WHICH coordinate:
##
##   high_modification   the hole sits in x1, the coordinate that carries effect
##                       modification, so the unsupported region is exactly where
##                       the treatment effect differs most from its average
##   low_modification    the hole sits in x2, a purely prognostic coordinate, so
##                       the unsupported region is irrelevant to the contrast
##
## Because the two holes are the same size on exchangeable standard normal
## coordinates, the amount of extrapolation the weights must do is nearly the
## same, and so is the weight multiset. The decision relevance is not remotely the
## same. That is the counterexample the proposition needs, and it is built out of
## a symmetry rather than out of a contrived configuration, which is what the
## refuting sentence in the design says should be impossible.
##
##   source("R/01-dgm.R")
## ---------------------------------------------------------------------------

source("R/00-config.R")

## --- the populations --------------------------------------------------------
##
## Target: standard multivariate normal, independent coordinates. Source: shifted
## by the overlap knob, with a wedge of its own support removed.
##
## The shift is what conventional overlap diagnostics are built to see. The wedge
## is what they are not.
OVERLAP_SHIFT <- c(good = 0.25, moderate = 0.60)

## The hole threshold, on the standard normal scale. Registered rather than tuned:
## it is the quantile in `HOLE_QUANTILE` of a standard normal, so the two arms
## remove the same nominal share of source mass by construction.
hole_cut <- function() stats::qnorm(1 - HOLE_QUANTILE)

## Which coordinate carries the hole. Coordinate 1 modifies the effect; every
## other coordinate is prognostic only, so a hole in coordinate 2 is matched in
## size and unmatched in relevance.
hole_coord <- function(hole) switch(hole,
  none = NA_integer_, high_modification = 1L, low_modification = 2L,
  stop("unregistered hole: ", hole))

## Draw a source sample with a wedge removed. Rejection sampling, so the retained
## sample is exactly the shifted normal conditioned on being outside the wedge and
## no reweighting sneaks in through the draw itself.
draw_source <- function(n, d, overlap, hole) {
  shift <- OVERLAP_SHIFT[[overlap]]
  j <- hole_coord(hole)
  cut <- hole_cut()
  out <- matrix(0, 0, d)
  guard <- 0L
  while (nrow(out) < n) {
    m <- max(2L * (n - nrow(out)), 256L)
    x <- matrix(stats::rnorm(m * d), m, d)
    x <- sweep(x, 2, rep(shift, d), "+")
    if (!is.na(j)) x <- x[x[, j] < cut, , drop = FALSE]
    out <- rbind(out, x)
    guard <- guard + 1L
    if (guard > 200L) stop("source rejection sampling failed to fill")
  }
  out[seq_len(n), , drop = FALSE]
}

draw_target <- function(n, d) matrix(stats::rnorm(n * d), n, d)

## --- the outcome ------------------------------------------------------------
##
## Binary, logit scale, so the marginal estimand is non-collapsible and the error
## a hole causes cannot be dismissed as a linear-scale artifact. Coordinate 1
## modifies; every coordinate is prognostic.
conditional_p <- function(x, arm, modification) {
  em <- EM_STRENGTH[[modification]]
  eta <- ALPHA + BETA_PROG * rowSums(x) + arm * (TAU0 + em * x[, 1])
  1 / (1 + exp(-eta))
}

draw_outcome <- function(p) stats::rbinom(length(p), 1, p)

## --- the estimand -----------------------------------------------------------
##
## The target-population marginal risk difference. Computed on the target sample
## the replicate drew, which is the finite-target version, and on a large
## independent draw for the superpopulation version. The classifier analysis
## scores error against the superpopulation value, because that is what an
## analyst is trying to estimate.
truth_marginal <- function(xt, modification) {
  mean(conditional_p(xt, 1L, modification)) -
  mean(conditional_p(xt, 0L, modification))
}

TRUTH_N <- 400000L
.truth_cache <- new.env(parent = emptyenv())

truth_superpopulation <- function(d, modification) {
  key <- paste(d, modification, sep = "|")
  z <- .truth_cache[[key]]
  if (is.null(z)) {
    old <- if (exists(".Random.seed", .GlobalEnv))
             get(".Random.seed", .GlobalEnv) else NULL
    set.seed(20260801L + d)
    z <- truth_marginal(draw_target(TRUTH_N, d), modification)
    if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
    .truth_cache[[key]] <- z
  }
  z
}

## --- the decision relevance of a hole ---------------------------------------
##
## The share of the target's effect-modification mass that falls in the
## unsupported region. This is the number that separates the two arms and it is
## measured rather than asserted: a hole is "high modification" only if it
## actually contains a large share, and P2 checks that.
hole_modification_share <- function(xt, hole, modification) {
  j <- hole_coord(hole)
  if (is.na(j)) return(0)
  inside <- xt[, j] >= hole_cut()
  em <- EM_STRENGTH[[modification]]
  ## Effect-modification mass is |em * x1|, the amount by which the conditional
  ## effect departs from its value at the origin.
  mass <- abs(em * xt[, 1])
  if (sum(mass) <= 0) return(0)
  sum(mass[inside]) / sum(mass)
}
