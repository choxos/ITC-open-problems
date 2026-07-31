## ---------------------------------------------------------------------------
## PROBE P6: the covariance every method omits, measured instead of assumed away.
##
## WHY THIS PROBE EXISTS. Round 1 of critique: the reported target moments and the
## target trial's own B-versus-C effect are computed from THE SAME PARTICIPANTS.
## `sample_replicate()` draws one `xt`, summarizes it into `target_reported$m`,
## and estimates `theta_BC` from outcomes on those same rows. So the two are
## dependent, and the anchored contrast
##
##   theta = theta_AC(m_hat) - theta_BC_hat
##
## has variance V_S + V_T + V_BC - 2 Cov(theta_AC, theta_BC_hat), where the last
## term is nonzero for exactly the reason this study is about: theta_AC depends on
## the target law, and under effect modification so does theta_BC.
##
## Every method here adds V_T and V_BC and drops the cross term. That is what the
## published estimators do, so it is faithful; but the study reports coverage, and
## a term the methods omit shows up in coverage whether or not it is faithful. If
## it is large, the intervals are wrong for a reason that has nothing to do with
## the research question and the primary comparison is confounded.
##
## SO IT IS MEASURED. The study already owns a threshold for "large enough to
## change a coverage claim": `MIN_OMITTED_SHARE`, solved in R/02 from the smallest
## coverage shift worth claiming. The same threshold judges this term. Below it,
## the omission cannot move a coverage number by as much as the study is willing
## to interpret, and the protocol says so with a number attached. At or above it,
## the cross term must be carried by every method before the primary comparison
## means anything, and this probe is what says which.
##
## THE PROBE CAN FAIL, and its failure is informative rather than fatal: it would
## say the anchored variance needs a term no published method supplies, which is
## itself a finding about the catalog entry.
##
##   Rscript R/13-probe-crosscov.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

## Cells: the grid's middle plus the corners that stress the mechanism. `k` sets
## how much effect modification the target shares, and the cross term is driven by
## modification, so k must vary; nT sets the scale of both sides of the
## covariance, so it must vary too. The links are all three, because the whole
## point of the study is that curvature changes what the target law does.
CROSSCOV_CELLS <- local({
  g <- expand.grid(link = LINKS, k = c(0, 0.25, 1), nT = c(150L, 600L),
                   stringsAsFactors = FALSE)
  g$shape <- GRID_MIDDLE$shape
  g$nS <- GRID_MIDDLE$nS
  g
})

N_CROSSCOV_REP <- 400L

## --- one cell -----------------------------------------------------------------
##
## The covariance is estimated ACROSS REPLICATES, which is the only place it is
## visible: within a replicate there is one m_hat and one theta_BC and no
## covariance to see. So this probe pays for a Monte Carlo estimate, and its own
## error is reported beside the estimate rather than assumed small.
crosscov_cell <- function(link, k, nT, nS, shape, n_rep = N_CROSSCOV_REP) {
  ms <- NULL
  tb <- rep(NA_real_, n_rep)
  est <- rep(NA_real_, n_rep)
  Js <- NULL
  n_J <- 0L
  for (r in seq_len(n_rep)) {
    ## ONE PASS. The covariance, the gradient and the estimate all come off the
    ## same draw, so the replicate is simulated once. An earlier version made a
    ## second pass to recover the estimates and paid for every draw twice.
    set.seed(20260730L + r)
    rd <- try(sample_replicate(nS, nT, k, link, shape, rho_true = 0.3),
              silent = TRUE)
    if (inherits(rd, "try-error")) next
    tr <- rd$target_reported
    if (is.null(ms)) ms <- matrix(NA_real_, n_rep, length(tr$m))
    ms[r, ] <- tr$m
    tb[r] <- tr$theta_BC
    ## The gradient the cross term is contracted against, and the point estimate,
    ## from ONE fit. Calling `maic_all()` here would be the obvious thing and is
    ## wrong on cost: it runs `N_PERTURB` weight refits per replicate to build a
    ## percentile interval this probe never looks at. The anchored point estimate
    ## is shared by every MAIC variant and is `theta_AC - theta_BC`, so it comes
    ## off the gradient fit for free.
    eg <- try(estimator_gradient(rd, link), silent = TRUE)
    if (!inherits(eg, "try-error") && isTRUE(eg$ok)) {
      est[r] <- eg$theta_AC - tr$theta_BC
      ## Averaged rather than taken from one draw, so a single unlucky fit
      ## cannot set the answer.
      Js <- if (is.null(Js)) eg$J else Js + eg$J
      n_J <- n_J + 1L
    }
  }
  keep <- is.finite(tb) & is.finite(est) & !is.null(ms) &
          apply(is.finite(ms), 1, all)
  n_ok <- sum(keep)
  na_row <- data.frame(link = link, k = k, nT = nT, n_ok = n_ok,
                       cross = NA_real_, total = NA_real_, share = NA_real_,
                       mcse = NA_real_, stringsAsFactors = FALSE)
  if (n_ok < 50L || is.null(Js) || n_J == 0L) return(na_row)
  J <- Js / n_J

  ## Cov(m_hat, theta_BC), then the contraction. The factor of two is the cross
  ## term in Var(a - b); the SIGN IS KEPT, because a cross term that inflates the
  ## true variance and one that shrinks it are different problems. The share is
  ## taken on the absolute value only after the sign has been recorded.
  cv <- as.vector(stats::cov(ms[keep, , drop = FALSE], tb[keep]))
  cross <- -2 * as.numeric(crossprod(J, cv))

  ## The denominator is the REALIZED variance of the anchored estimate across
  ## replicates, which is the true total including the cross term. So the share is
  ## the fraction of the true variance that every method omits, which is the
  ## quantity `MIN_OMITTED_SHARE` was solved for.
  total <- stats::var(est[keep])
  if (!is.finite(total) || total <= 0) return(na_row)

  ## Monte Carlo error on the covariance, propagated to the share, so that a cell
  ## reported below the floor is below it by more than the probe's own noise.
  se_cv <- apply(ms[keep, , drop = FALSE], 2, stats::sd) * stats::sd(tb[keep]) /
           sqrt(n_ok)
  mcse <- 2 * sqrt(sum((J * se_cv)^2)) / total

  data.frame(link = link, k = k, nT = nT, n_ok = n_ok,
             cross = cross, total = total, share = abs(cross) / total,
             mcse = mcse, stringsAsFactors = FALSE)
}

main <- function() {
  cat(sprintf("P6: cross-covariance over %d cells, %d replicates each\n",
              nrow(CROSSCOV_CELLS), N_CROSSCOV_REP))
  res <- do.call(rbind, lapply(seq_len(nrow(CROSSCOV_CELLS)), function(i) {
    z <- CROSSCOV_CELLS[i, ]
    out <- crosscov_cell(z$link, z$k, z$nT, z$nS, z$shape)
    cat(sprintf("  %-8s k=%.2f nT=%3d  share %s (mcse %s)\n", z$link, z$k, z$nT,
                formatC(out$share, format = "f", digits = 4),
                formatC(out$mcse, format = "f", digits = 4)))
    out
  }))

  ## THE VERDICT, against the floor the study already owns. The comparison uses
  ## the share PLUS its Monte Carlo error, so a cell is only cleared when it is
  ## below the floor by more than the probe can resolve.
  ## The floor comes from the PROBE STORE, where R/02 registered it, not from a
  ## fresh call to `omitted_share_for_shift()`. Recomputing it here would let this
  ## probe and the grid drift onto different floors without anything noticing.
  p0 <- load_probes()
  if (is.null(p0$P2_min_share))
    stop("P2 has not run, so there is no registered floor to judge P6 against")
  floor_ <- p0$P2_min_share[[1]]
  worst <- max(res$share + res$mcse, na.rm = TRUE)
  ok <- worst < floor_
  cat(sprintf("\nworst share + mcse: %.4f against floor %.4f -> %s\n",
              worst, floor_,
              if (ok) "below the floor; the omission cannot move a coverage claim"
              else "AT OR ABOVE THE FLOOR; the cross term must be carried"))

  p <- p0
  p$P6_table <- list(res)
  p$P6_ok <- list(ok)
  p$P6_worst_share <- list(worst)
  saveRDS(p, "results/probes.rds")
  cat("written: results/probes.rds\n")
}

if (!interactive() && Sys.getenv("PROBE_NOMAIN") == "") main()
