## ---------------------------------------------------------------------------
## One replicate: the complete four-model lattice, the check statistics it
## supports, and the target-population estimands each model implies.
## ---------------------------------------------------------------------------

## Guard against the failure mode found while building this study: with
## `class_interactions = "common"` a `x:.trt` term in the regression formula is
## silently demoted to the class level, so the "split" fit is the shared fit
## under another name and the check can never fire.
assert_split <- function(f, xvar) {
  cn <- colnames(beta_draws(f))
  want <- sprintf("beta[.trt%s:%s]", TRT_ACTIVE, xvar)
  if (!all(want %in% cn))
    stop(sprintf("split fit for %s has no treatment-specific coefficients; got: %s",
                 xvar, paste(cn, collapse = ", ")))
  invisible(TRUE)
}

one_replicate <- function(scen, rep_id, prior_reg = PRIOR_REG) {
  dat <- make_network_data(scen)
  net <- build_network(dat)

  fits <- lapply(FIT_SPLITS, function(s) fit_one(net, s, prior_reg))
  if (any(vapply(fits, is.null, TRUE)))
    return(list(cell = scen$cell, rep = rep_id, ok = FALSE,
                reason = "sampler failed or returned no draws"))

  ## A replicate is NOT dropped because the sampler struggled. The first version
  ## of this file did drop them, and the first cell of the first run showed why
  ## that is wrong: all six exclusions were diagnostic failures and five of the
  ## six involved a split model, while the shared-interaction model never failed
  ## once. Dropping on that criterion removes exactly the replicates where the
  ## relaxed model is weakly identified, which is the phenomenon under study, and
  ## leaves a sample enriched for the cases where relaxing happened to go well.
  ##
  ## The diagnostics are recorded per fit instead. How often the relaxed model
  ## fails to converge is a result about the procedure, not a nuisance to filter
  ## out, and 05-analyze.R repeats the primary analysis on the clean subset so the
  ## effect of including them is visible rather than assumed.
  valid <- vapply(fits, function(f) isTRUE(attr(f, "valid")), TRUE)

  for (x in XN) assert_split(fits[[paste0("split_", x)]], x)
  for (x in XN) assert_split(fits$split_all, x)

  ## The prior this replicate was actually fitted under, so contraction is
  ## divided by the right thing in every arm and not by the config default.
  prior_sd <- prior_reg$scale
  stopifnot(is.numeric(prior_sd), length(prior_sd) == 1L, prior_sd > 0)

  ## the check, one covariate at a time, exactly as published
  checks <- setNames(lapply(XN, function(x)
    check_stats(fits[[paste0("split_", x)]], fits$common, x, prior_sd)), XN)
  ## the same covariate read off the fully relaxed model, so a strategy that
  ## relaxes everything at once is scored on the same footing
  check_all <- setNames(lapply(XN, function(x)
    check_stats(fits$split_all, fits$common, x, prior_sd)), XN)
  if (any(vapply(checks, is.null, TRUE)) || any(vapply(check_all, is.null, TRUE)))
    return(list(cell = scen$cell, rep = rep_id, ok = FALSE,
                reason = "check statistics unavailable"))

  targets    <- lapply(TARGET_SHIFT, target_frame)
  truth_by_s <- lapply(TARGET_SHIFT, function(s) truth_at(scen$drift, s))

  ## every model in the lattice, so "relax exactly what flagged" is a strategy
  ## the analysis can score rather than approximate
  est <- lapply(fits, estimands, targets = targets, truth_by_s = truth_by_s)

  ## `multinma` does not assume the aggregate covariates are independent: it
  ## reconstructs their joint distribution from a copula whose correlation matrix
  ## is ESTIMATED from the individual-level studies. With one such study that
  ## estimate carries error, so the distance from the truth is recorded rather
  ## than assumed away. The protocol promises this number; here is where it comes
  ## from.
  cor_hat <- net$int_cor
  list(cell = scen$cell, rep = rep_id, ok = TRUE, scen = scen,
       valid = valid,
       checks = checks, check_all = check_all, est = est,
       cor_err = if (is.null(cor_hat)) NA_real_ else
         max(abs(cor_hat[upper.tri(cor_hat)] - SIGMA_X[upper.tri(SIGMA_X)])),
       n_agd_by_trt = dat$n_agd_by_trt,
       truth = lapply(truth_by_s, function(t)
         list(rd_CA = t$rd_CA, lor_CA = t$lor_CA, p_ref = t$p_ref)),
       diag = lapply(fits, function(f) attr(f, "diag")))
}

## --- flatten one replicate to rows -------------------------------------------
## The dataset identity is (cell, rep). Every model and every target displacement
## for that dataset carries it, so a validation fold can never split one
## simulated dataset across training and test.

check_rows <- function(r) {
  if (!isTRUE(r$ok)) return(NULL)
  do.call(rbind, lapply(XN, function(x) {
    c1 <- r$checks[[x]]; ca <- r$check_all[[x]]
    data.frame(cell = r$cell, rep = r$rep, xvar = x,
               ## the true interaction contrast for THIS covariate: the drift for
               ## x1, exactly zero for x2
               contrast_true = if (x == "x1") r$scen$drift else 0,
               diff_mean = c1$diff_mean, diff_sd = c1$diff_sd,
               diff_lo = c1$diff_lo, diff_hi = c1$diff_hi,
               p_direction = c1$p_direction, p_exceeds_eps = c1$p_exceeds_eps,
               post_flag = c1$post_flag,
               ddic = c1$ddic, dic_split = c1$dic_split, dic_common = c1$dic_common,
               pd_split = c1$pd_split, pd_common = c1$pd_common,
               prior_sd = c1$prior_sd,
               contraction_A = c1$contraction[["A"]],
               contraction_C = c1$contraction[["C"]],
               post_sd_A = c1$post_sd[["A"]], post_sd_C = c1$post_sd[["C"]],
               post_mean_A = c1$post_mean[["A"]], post_mean_C = c1$post_mean[["C"]],
               all_post_flag = ca$post_flag, all_ddic = ca$ddic,
               stringsAsFactors = FALSE)
  }))
}

est_rows <- function(r) {
  if (!isTRUE(r$ok)) return(NULL)
  do.call(rbind, lapply(names(r$est), function(m)
    do.call(rbind, lapply(seq_along(TARGET_SHIFT), function(i) {
      e <- r$est[[m]][[i]]; tr <- r$truth[[i]]
      data.frame(cell = r$cell, rep = r$rep, model = m, shift = TARGET_SHIFT[i],
                 rd_CA = e$rd_CA, rd_CA_true = tr$rd_CA, err_rd = e$err_rd,
                 lor_CA = e$lor_CA, lor_CA_true = tr$lor_CA, err_lor = e$err_lor,
                 risk_A = e$risk[["A"]], risk_C = e$risk[["C"]],
                 sd_lor_A = e$lor_sd[["A"]], sd_lor_C = e$lor_sd[["C"]],
                 stringsAsFactors = FALSE)
    }))))
}

diag_rows <- function(r) {
  if (!isTRUE(r$ok)) return(NULL)
  do.call(rbind, lapply(names(r$diag), function(m)
    data.frame(cell = r$cell, rep = r$rep, model = m,
               max_rhat = r$diag[[m]]$max_rhat, min_ess = r$diag[[m]]$min_ess,
               divergent = r$diag[[m]]$divergent,
               valid = unname(r$valid[[m]]),
               cor_err = r$cor_err, stringsAsFactors = FALSE)))
}
