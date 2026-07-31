## ---------------------------------------------------------------------------
## PROBE P5: how many resamples the perturbation interval actually needs.
##
## P4 measured that the perturbation arm is 96% to 98% of this study's cost, so
## `N_PERTURB` is its entire budget lever, and 200 was typed rather than derived.
## Halving it halves the study. That makes it exactly the kind of constant this
## programme has repeatedly found asserted and never measured, and the rule that
## produced the P4 paragraph applies to the number P4 exposed.
##
## WHAT IS MEASURED. The perturbation variance is itself a Monte Carlo estimate,
## so it has a resampling error that falls as 1/sqrt(B). What matters is not that
## it converges, which it must, but whether its remaining error at a given B is
## small against the quantity it feeds: the total interval width. A resampling
## error that moves the SE by less than the replicate-to-replicate spread of that
## SE is invisible in coverage, and buying it is buying nothing.
##
## WHAT COULD CHANGE: `N_PERTURB`, and therefore the whole budget.
##
##   Rscript R/11-probe-perturb.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

## THE REFERENCE IS INDEPENDENT OF THE GRID, deliberately. The first version of
## this probe used its largest grid point as the reference, which makes that
## point's error exactly zero by construction and, worse, folds the reference's
## own resampling noise into every other point's measured error. The answer was
## borderline under that construction, 0.1581 against a 0.1504 yardstick at
## B = 100, and a borderline answer from a self-referential comparison is not an
## answer to a question worth a factor of two in budget.
B_GRID    <- c(25L, 50L, 100L, 200L, 400L)
N_REP_P5  <- 30L    # replicates, to see the across-replicate spread of the SE
REF_B     <- 3200L  # an independent reference, not a member of B_GRID

main <- function() {
  p <- load_probes()
  stopifnot("P4 must run first" = !is.null(p) && is.finite(p$SEC_PER_REP[[1]]))

  ## The dearest configuration in the grid, so the answer is conservative: if a
  ## smaller B suffices here it suffices everywhere cheaper.
  set.seed(MASTER_SEED)
  res <- do.call(rbind, lapply(seq_len(N_REP_P5), function(r) {
    d <- sample_replicate(2000L, 300L, 0.25, "logit", "mvnorm", 0.3)
    R_use <- assumed_R("borrowed", d, ncol(d$source$x))
    v <- vapply(B_GRID, function(B) perturbation_var(d, "logit", R_use, B), 0)
    ## The reference is computed on the SAME replicate, so the comparison is
    ## within-replicate and the across-replicate spread does not contaminate it.
    v_ref <- perturbation_var(d, "logit", R_use, REF_B)
    data.frame(rep = r, B = B_GRID, se = sqrt(v), se_ref = sqrt(v_ref))
  }))

  ref <- unique(res[, c("rep", "se_ref")])
  res$rel_err <- abs(res$se - res$se_ref) / res$se_ref

  ## The yardstick: how much the reference SE itself varies from replicate to
  ## replicate. A resampling error well inside that spread cannot change a
  ## coverage conclusion, because the replicate-to-replicate variation already
  ## swamps it.
  spread <- stats::sd(ref$se_ref) / mean(ref$se_ref)

  tab <- do.call(rbind, lapply(B_GRID, function(B) {
    z <- res[res$B == B, ]
    data.frame(B = B, mean_se = mean(z$se),
               median_rel_err = stats::median(z$rel_err),
               p90_rel_err = stats::quantile(z$rel_err, 0.9, names = FALSE))
  }))

  cat("=== P5: resampling error against the replicate-to-replicate spread ===\n\n")
  print(tab, row.names = FALSE, digits = 4)
  cat(sprintf("\nacross-replicate spread of the reference SE: %.4f\n", spread))

  ok <- tab$p90_rel_err < spread
  cat("\nresampling error is inside that spread at:\n")
  for (i in seq_along(B_GRID))
    cat(sprintf("  B = %3d : %s (90th percentile relative error %.4f)\n",
                B_GRID[i], ifelse(ok[i], "yes", "no"), tab$p90_rel_err[i]))

  smallest <- if (any(ok)) min(B_GRID[ok]) else NA_integer_
  cat(sprintf("\nsmallest sufficient B: %s\n",
              ifelse(is.na(smallest), "none in the grid", smallest)))
  if (!is.na(smallest) && smallest < 200L)
    cat(sprintf("registered 200 can fall to %d, cutting the study's cost by %.0f%%\n",
                smallest, 100 * (1 - smallest / 200)))

  p$N_PERTURB_NEEDED <- list(smallest)
  p$P5_table <- list(tab)
  p$P5_spread <- list(spread)
  saveRDS(p, PROBE_FILE)
  cat(sprintf("\nwritten: %s\n", PROBE_FILE))
}

if (!interactive() && Sys.getenv("P5_NOMAIN") == "") main()
