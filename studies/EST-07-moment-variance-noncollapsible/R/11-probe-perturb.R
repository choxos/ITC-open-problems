## ---------------------------------------------------------------------------
## PROBE P5: how many resamples the perturbation INTERVAL actually needs.
##
## P4 measured that the perturbation arm is 96% to 98% of this study's cost, so
## `N_PERTURB` is the entire budget lever, and 200 was typed rather than derived.
##
## THIS PROBE HAS BEEN REWRITTEN TWICE AND BOTH REWRITES WERE FORCED.
##
## The first version used its own largest grid point as the reference, which makes
## that point's error zero by construction and folds the reference's resampling
## noise into every other point. It returned a borderline answer, 0.1581 against a
## 0.1504 yardstick, and a borderline answer from a self-referential comparison is
## not an answer to a question worth a factor of four in budget.
##
## THE SECOND VERSION MEASURED A QUANTITY THE STUDY NO LONGER REPORTS. Round 1 of
## critique found that `maic_perturb` was not the cited algorithm and it was
## rewritten to resample the source and take EMPIRICAL PERCENTILE limits. This
## probe was not rewritten with it, so it went on measuring the convergence of
## `perturbation_var()`, the variance of the draws, which after that fix generates
## no interval anywhere in the study. A constant chosen by watching an unused
## variance converge is not chosen.
##
## WHAT IS MEASURED NOW: the percentile LIMITS, in the units the whole study is
## calibrated in. Everything else here is judged by how much it can move coverage;
## `MIN_COVERAGE_SHIFT` is the smallest shift worth claiming and the grid floor is
## solved from it. So the question for B is the same question: does going from B
## resamples to a reference number of them move COVERAGE by as much as the study
## is willing to interpret? If not, the extra resamples buy nothing that any
## reported number can see.
##
## THE DESIGN THAT MAKES THIS AFFORDABLE. The limits at every B come from NESTED
## SUBSAMPLES of one reference draw set per replicate: draw REF_B once, then read
## the first B of them for each smaller B. So the whole B grid costs one reference
## run rather than the sum of the grid, every B sees the same resamples, and the
## coverage comparison is PAIRED at the replicate level. The paired difference is
## far better resolved than either coverage separately, which is what lets a few
## hundred replicates answer a question about a 0.01 shift.
##
## WHAT COULD CHANGE: `N_PERTURB`, and therefore the whole budget.
##
##   Rscript R/11-probe-perturb.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

B_GRID   <- c(25L, 50L, 100L, 200L, 400L)
REF_B    <- 3200L   # the reference, and the draw set every smaller B reads from
N_REP_P5 <- 300L    # replicates; the criterion is on a PAIRED difference
WIDTH_TOL <- 0.01   # tolerated systematic width bias from too few draws
P5_CELL  <- list(nS = 2000L, nT = 300L, k = 0.25, link = "logit",
                 shape = "mvnorm", rho = 0.3)

## `limits_from_draws()` is defined in R/05-estimators.R and used BOTH by
## `maic_all()` to build the reported interval and by this probe to size it. One
## definition, two callers: the probe cannot drift from the estimator it sizes,
## which a copied construction here would have allowed and an earlier draft did.

main <- function() {
  p <- load_probes()
  stopifnot("P4 must run first" = !is.null(p) && is.finite(p$SEC_PER_REP[[1]]))
  ## Installs `QUAD_ORDER` and the other probe constants as globals. The truth
  ## this probe scores coverage against needs the registered integration order,
  ## and without this it is still the placeholder that stops the run.
  probes_done()
  if (is.null(p$P2_min_shift))
    stop("P2 has not run, so there is no registered coverage shift to judge B against")
  shift_tol <- p$P2_min_shift[[1]]

  cl <- P5_CELL
  ## The truth this coverage is against: the anchored superpopulation estimand of
  ## the cell, which does not depend on the replicate.
  pars   <- make_pars(cl$k)
  pars_T <- pars; pars_T$beta_em <- cl$k * pars$beta_em
  pm     <- population_means()
  truth  <- truth_anchored_superpop(pars, pars_T, cl$link, cl$shape,
                                    mu = pm$target, sigma = rep(1, N_COVARIATE),
                                    rho = cl$rho, order = QUAD_ORDER)

  cat(sprintf("=== P5: coverage of the percentile interval against B ===\n"))
  cat(sprintf("cell: %s nS=%d nT=%d k=%.2f, truth %.5f\n\n",
              cl$link, cl$nS, cl$nT, cl$k, truth))

  set.seed(MASTER_SEED)
  cov_mat <- matrix(NA, N_REP_P5, length(B_GRID) + 1L)
  wid_mat <- matrix(NA_real_, N_REP_P5, length(B_GRID) + 1L)
  for (r in seq_len(N_REP_P5)) {
    d <- try(sample_replicate(cl$nS, cl$nT, cl$k, cl$link, cl$shape, cl$rho),
             silent = TRUE)
    if (inherits(d, "try-error")) next
    R_use <- assumed_R("borrowed", d, ncol(d$source$x))
    ## ONE reference draw set; every B reads a prefix of it.
    dr <- try(perturbation_draws(d, cl$link, R_use, REF_B), silent = TRUE)
    if (inherits(dr, "try-error")) next
    tr <- d$target_reported
    for (j in seq_along(B_GRID)) {
      lu <- limits_from_draws(
        draw_anchored(dr[seq_len(B_GRID[j])], tr$theta_BC, tr$var_theta_BC))
      cov_mat[r, j] <- truth >= lu[1] && truth <= lu[2]
      wid_mat[r, j] <- lu[2] - lu[1]
    }
    lu <- limits_from_draws(draw_anchored(dr, tr$theta_BC, tr$var_theta_BC))
    cov_mat[r, length(B_GRID) + 1L] <- truth >= lu[1] && truth <= lu[2]
    wid_mat[r, length(B_GRID) + 1L] <- lu[2] - lu[1]
    if (r %% 25 == 0) { cat(sprintf("  replicate %d/%d\n", r, N_REP_P5))
                        flush.console() }
  }

  keep <- stats::complete.cases(cov_mat)
  n_ok <- sum(keep)
  if (n_ok < 100L) stop("P5 retained only ", n_ok, " replicates; too few to size B")
  cm <- cov_mat[keep, , drop = FALSE]
  wm <- wid_mat[keep, , drop = FALSE]
  ref_col <- length(B_GRID) + 1L

  ## The PAIRED coverage difference against the reference, and its Monte Carlo
  ## error. Paired because the same replicates and the same draws feed both, which
  ## is the whole point of the nested design.
  tab <- do.call(rbind, lapply(seq_along(B_GRID), function(j) {
    dif <- cm[, j] - cm[, ref_col]
    data.frame(B = B_GRID[j],
               coverage = mean(cm[, j]),
               mean_width = mean(wm[, j]),
               cov_diff = mean(dif),
               diff_mcse = stats::sd(dif) / sqrt(n_ok))
  }))

  cat(sprintf("\nreplicates retained: %d;  reference B = %d, coverage %.4f\n\n",
              n_ok, REF_B, mean(cm[, ref_col])))
  print(tab, row.names = FALSE, digits = 4)

  ## TWO CRITERIA, AND THE SECOND IS THERE BECAUSE THE FIRST SATURATED.
  ##
  ## Coverage alone is not enough. On the first run of this probe the
  ## perturbation interval covered 0.9933, so far above nominal that changing B
  ## could not move coverage at all, and B = 25 "passed" because the quantity
  ## being tested was pinned. (That run also exposed why it was pinned: the
  ## interval was adding the target trial's standard deviation to each limit
  ## instead of convolving its variance, making every interval too wide. That is
  ## fixed in R/05, but the lesson about the criterion stands.)
  ##
  ## So a B must ALSO have converged in WIDTH. Width is a reported performance
  ## measure, and an empirical quantile from few draws is biased inward, which
  ## makes a small B narrow the interval systematically rather than noisily. The
  ## tolerance is 1% of the reference width, well below any width difference
  ## between methods the study would claim.
  ref_w <- mean(wm[, ref_col])
  tab$width_bias <- (tab$mean_width - ref_w) / ref_w
  ok_cov <- abs(tab$cov_diff) + tab$diff_mcse < shift_tol
  ok_wid <- abs(tab$width_bias) < WIDTH_TOL
  ok <- ok_cov & ok_wid
  cat(sprintf("\njudged against a %.3f coverage shift and a %.0f%% width bias:\n",
              shift_tol, 100 * WIDTH_TOL))
  for (i in seq_along(B_GRID))
    cat(sprintf("  B = %4d : %-3s  coverage %.4f (%s)  width bias %+.4f (%s)\n",
                B_GRID[i], ifelse(ok[i], "yes", "no"),
                abs(tab$cov_diff[i]) + tab$diff_mcse[i],
                ifelse(ok_cov[i], "ok", "no"),
                tab$width_bias[i], ifelse(ok_wid[i], "ok", "no")))

  smallest <- if (any(ok)) min(B_GRID[ok]) else NA_integer_
  cat(sprintf("\nsmallest sufficient B: %s\n",
              ifelse(is.na(smallest), "none in the grid", smallest)))

  p$N_PERTURB_NEEDED <- list(smallest)
  p$P5_table <- list(tab)
  p$P5_ref_coverage <- list(mean(cm[, ref_col]))
  p$P5_ref_width <- list(ref_w)
  p$P5_width_tol <- list(WIDTH_TOL)
  p$P5_n_ok <- list(n_ok)
  ## Retained under its old name so the exporter and the protocol keep a single
  ## spread figure to quote; it is now the spread of the WIDTH, which is the
  ## quantity the percentile interval actually has.
  p$P5_spread <- list(stats::sd(wm[, ref_col]) / mean(wm[, ref_col]))
  saveRDS(p, PROBE_FILE)
  cat(sprintf("\nwritten: %s\n", PROBE_FILE))
}

if (!interactive() && Sys.getenv("P5_NOMAIN") == "") main()
