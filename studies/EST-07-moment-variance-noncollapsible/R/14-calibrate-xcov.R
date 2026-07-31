## ---------------------------------------------------------------------------
## The cross-covariance every published method omits, calibrated per target cell.
##
## PROBE P6 (R/13) MEASURED IT AND IT DID NOT CLEAR THE FLOOR. On the identity
## link with the target sharing the source's modification in full (k = 1), the
## omitted term -2 Cov(theta_AC, theta_BC) is about 7.7% of the true variance of
## the anchored contrast against a registered floor of 7.9%, and it does NOT
## shrink as the target grows: 0.0773 at nT = 150 and 0.0753 at nT = 600. Both
## sides of the ratio scale with 1/nT, so it stays.
##
## That leaves the study two honest options and only one good one. It can say
## nothing about absolute coverage in the affected cells, or it can carry the term
## and separate the two mechanisms. This file carries it.
##
## WHAT IT BUYS. Coverage failure in this study can now come from two places: the
## reported moments not identifying Delta(F_T), which is prediction 1 and the
## point of the study; and this covariance, which no published method carries and
## which has nothing to do with identification. Without an arm that supplies it,
## the two are confounded and the primary comparison cannot attribute a deficit to
## either. `maic_xcov` supplies it from an oracle, so the difference between it
## and `maic_entropy` IS the cross term and the difference between it and nominal
## coverage is what remains for identification to explain.
##
## THE FACTORIZATION THAT MAKES THIS CHEAP, and it is exact rather than an
## approximation. Both m_hat and theta_BC are computed from the TARGET sample
## alone, so Cov(m_hat, theta_BC) does not depend on nS or on the correlation the
## analyst assumes; it depends only on (link, nT, k, shape, modifier_span). The
## contraction against the estimator gradient J does depend on the source, so J
## stays per-replicate and only the covariance vector is calibrated here. The
## registered grid's 116 cells therefore need far fewer calibration runs than one
## per cell, and no cell shares a covariance it should not.
##
##   Rscript R/14-calibrate-xcov.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

## Replicates per calibrated combination. The covariance is a Monte Carlo
## quantity, so its error enters every interval that uses it; N is set so that the
## SE of the resulting share is comfortably under the floor it is judged against
## rather than at it. P6 measured an MCSE of about 0.019 at 400 replicates on the
## worst cell, so 2000 brings it to roughly 0.008.
N_XCOV_REP <- 2000L

## The target-side combinations the registered grid actually visits. Derived from
## the grid rather than from the full crossing of LEVELS, so a cell the floor
## dropped is not calibrated and a cell it kept cannot be missed.
xcov_combos <- function() {
  p <- load_probes()
  if (is.null(p$P2_grid))
    stop("P2 has not run, so the registered grid does not exist yet")
  g <- p$P2_grid[[1]]
  keys <- c("link", "nT", "k", "shape", "modifier_span")
  miss <- setdiff(keys, names(g))
  if (length(miss))
    stop("the registered grid has no column(s): ", paste(miss, collapse = ", "))
  unique(g[, keys])
}

## --- one combination ---------------------------------------------------------
##
## Returns the covariance VECTOR Cov(m_hat, theta_BC), not a contracted scalar,
## because the contraction needs a gradient this function does not have and must
## not guess at.
xcov_one <- function(link, nT, k, shape, modifier_span, n_rep = N_XCOV_REP) {
  ms <- NULL
  tb <- rep(NA_real_, n_rep)
  for (r in seq_len(n_rep)) {
    ## A SEED STREAM OF ITS OWN. This calibration must not reuse the replicate
    ## seeds of the production run, or every interval would be correlated with the
    ## constant it is corrected by.
    set.seed(77000000L + r)
    ## nS is irrelevant to this quantity and is set to the smallest registered
    ## level so the source draw is as cheap as it can be. The source is drawn at
    ## all only because `sample_replicate()` produces both arms together.
    rd <- try(sample_replicate(min(LEVELS$nS), nT, k, link, shape,
                              rho_true = 0.3, modifier_span = modifier_span),
              silent = TRUE)
    if (inherits(rd, "try-error")) next
    tr <- rd$target_reported
    if (is.null(ms)) ms <- matrix(NA_real_, n_rep, length(tr$m))
    ms[r, ] <- tr$m
    tb[r] <- tr$theta_BC
  }
  if (is.null(ms)) return(NULL)
  keep <- is.finite(tb) & apply(is.finite(ms), 1, all)
  if (sum(keep) < 200L) return(NULL)
  cv <- as.vector(stats::cov(ms[keep, , drop = FALSE], tb[keep]))
  se <- apply(ms[keep, , drop = FALSE], 2, stats::sd) * stats::sd(tb[keep]) /
        sqrt(sum(keep))
  list(cov = cv, se = se, n_ok = sum(keep))
}

## `xcov_key()` and `xcov_lookup()` live in R/05-estimators.R, which this file
## sources. They are defined THERE rather than here because the estimators are
## their consumer and this file is only their producer: defining them here and
## sourcing this file from R/05 would make the dependency circular.

main <- function() {
  combos <- xcov_combos()
  cat(sprintf("calibrating %d target-side combinations at %d replicates each\n",
              nrow(combos), N_XCOV_REP))
  store <- list()
  for (i in seq_len(nrow(combos))) {
    z <- combos[i, ]
    r <- xcov_one(z$link, z$nT, z$k, z$shape, z$modifier_span)
    key <- xcov_key(z$link, z$nT, z$k, z$shape, z$modifier_span)
    if (is.null(r)) {
      cat(sprintf("  [%3d/%3d] %-40s FAILED\n", i, nrow(combos), key))
      next
    }
    store[[key]] <- r
    cat(sprintf("  [%3d/%3d] %-40s |cov| max %.3e\n", i, nrow(combos), key,
                max(abs(r$cov))))
    flush.console()
  }
  if (length(store) != nrow(combos))
    stop("calibration is incomplete: ", length(store), " of ", nrow(combos),
         " combinations succeeded, and every registered cell needs one")
  saveRDS(store, "results/xcov.rds")
  cat(sprintf("written: results/xcov.rds (%d combinations)\n", length(store)))
}

if (!interactive() && Sys.getenv("XCOV_NOMAIN") == "") main()
