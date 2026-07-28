## ---------------------------------------------------------------------------
## The four ML-NMR fits per replicate (the complete model lattice for two
## covariates), and the quantities the check reads.
##
## `class_interactions` is a single global switch, so on its own it cannot
## express the published procedure, which relaxes ONE covariate at a time. The
## split is carried by the regression formula, using multinma's `.trt` and
## `.trtclass` specials: a covariate interacted with `.trtclass` is shared across
## the class, one interacted with `.trt` is treatment-specific.
##
## This only works with `class_interactions = "independent"`. Under the default
## "common", an `x:.trt` term in the formula is silently collapsed to the class
## level and the fit is identical to the shared model, with the same parameter
## names and a DIC that differs only by Monte Carlo error. An analyst following
## the published recipe by editing the formula alone would see no evidence
## against sharing in any dataset, because no split model was ever fitted. Every
## fit here therefore passes `class_interactions = "independent"` and lets the
## formula decide, and 03-replicate.R asserts that a split fit really did produce
## treatment-specific coefficients before any check statistic is computed.
## ---------------------------------------------------------------------------

regression_formula <- function(split) {
  shared <- setdiff(XN, split)
  terms <- paste(XN, collapse = " + ")            # prognostic main effects
  if (length(split))
    terms <- paste0(terms, " + (", paste(split, collapse = " + "), "):.trt")
  if (length(shared))
    terms <- paste0(terms, " + (", paste(shared, collapse = " + "), "):.trtclass")
  as.formula(paste("~", terms))
}

fit_one <- function(net, split, prior_reg = PRIOR_REG) {
  f <- try(nma(net,
               trt_effects = "fixed",
               regression = regression_formula(split),
               class_interactions = "independent",
               prior_intercept = PRIOR_INTERCEPT,
               prior_trt = PRIOR_TRT,
               prior_reg = prior_reg,
               chains = N_CHAIN, iter = N_ITER, warmup = N_WARMUP,
               cores = 1, refresh = 0), silent = TRUE)
  if (inherits(f, "try-error")) return(NULL)
  ## multinma returns an object that looks like a fit when Stan never started, so
  ## success is established by asking for draws, and then by the sampler
  ## diagnostics prespecified in 00-config.R.
  d <- tryCatch(fit_diagnostics(f), error = function(e) NULL)
  if (is.null(d)) return(NULL)
  attr(f, "diag") <- d
  attr(f, "valid") <- d$max_rhat <= FIT_OK_RHAT && d$min_ess >= FIT_OK_ESS &&
    d$divergent <= FIT_OK_DIVERGENT
  f
}

fit_diagnostics <- function(f) {
  su <- rstan::summary(f$stanfit, pars = c("d", "beta"))$summary
  if (!nrow(su)) stop("no draws")
  sp <- rstan::get_sampler_params(f$stanfit, inc_warmup = FALSE)
  list(max_rhat = max(su[, "Rhat"], na.rm = TRUE),
       min_ess  = min(su[, "n_eff"], na.rm = TRUE),
       divergent = sum(vapply(sp, function(x) sum(x[, "divergent__"]), numeric(1))))
}

## --- what the check reads -----------------------------------------------------

beta_draws <- function(f) {
  m <- as.matrix(f$stanfit)
  m[, grep("^beta\\[", colnames(m)), drop = FALSE]
}

## For a split covariate the treatment-specific coefficients are named
## `beta[.trt<K>:<x>]`; for a shared one, `beta[<x>:.trtclassactive]`.
trt_interaction_draws <- function(f, xvar) {
  b <- beta_draws(f); cn <- colnames(b)
  idx <- vapply(TRT_ACTIVE, function(k) {
    hit <- which(cn == sprintf("beta[.trt%s:%s]", k, xvar))
    if (length(hit) == 1L) hit else NA_integer_
  }, integer(1))
  if (anyNA(idx)) return(NULL)
  out <- b[, idx, drop = FALSE]; colnames(out) <- TRT_ACTIVE; out
}

## With two active treatments there is exactly ONE interaction contrast per
## covariate, so no selection over covariates happens before the interval is
## read. That removes one route to miscalibration; it does not deliver nominal
## frequentist coverage, and this study measures that the interval rule fires on
## about 9% of replicates under the global null rather than 5%. An earlier draft
## of this comment, and of the manuscript, asserted nominal coverage; two
## reviewers pointed out that the study's own type I error contradicts it.
##
## Three readings are recorded: against exactly zero, against a margin set by
## what would matter, and the model-fit comparison.
##
## `prior_sd` MUST be the standard deviation of the prior this fit actually used.
## It was previously read from the config constant, so the prior-sensitivity arm,
## which fits under normal(0, 1), had its contraction divided by 2.5. That
## inverted the reported direction of the effect: tightening a prior cannot raise
## 1 - sd(posterior)/sd(prior). A reviewer derived the error from the published
## numbers without seeing this file.
check_stats <- function(fit_split, fit_common, xvar, prior_sd = PRIOR_REG_SD) {
  g <- trt_interaction_draws(fit_split, xvar)
  if (is.null(g)) return(NULL)
  z  <- g[, "A"] - g[, "C"]
  ci <- quantile(z, c((1 - POST_LEVEL) / 2, 1 - (1 - POST_LEVEL) / 2))

  d_split  <- dic(fit_split)
  d_common <- dic(fit_common)

  list(
    xvar = xvar,
    diff_mean = mean(z), diff_sd = sd(z),
    diff_lo = unname(ci[1]), diff_hi = unname(ci[2]),
    ## a directional probability in [0.5, 1]; NOT P(difference is nonzero),
    ## which is exactly 1 under a continuous posterior and cannot score anything
    p_direction = max(mean(z > 0), mean(z < 0)),
    ## the margin rule: is the drift big enough to matter, rather than nonzero
    p_exceeds_eps = mean(abs(z) > EPS),
    post_flag = as.integer(ci[1] > 0 | ci[2] < 0),
    ddic = d_split$dic - d_common$dic,
    dic_split = d_split$dic, dic_common = d_common$dic,
    pd_split = d_split$pd, pd_common = d_common$pd,
    ## how much the data said about each treatment's interaction. A coefficient
    ## the network cannot identify has contraction near zero and a credible
    ## interval that is the prior's. Recorded alongside the prior it is measured
    ## against, so the denominator can never be inferred wrongly downstream.
    prior_sd = prior_sd,
    contraction = setNames(1 - apply(g, 2, sd) / prior_sd, TRT_ACTIVE),
    post_sd = setNames(apply(g, 2, sd), TRT_ACTIVE),
    post_mean = setNames(colMeans(g), TRT_ACTIVE))
}

## --- the estimand -------------------------------------------------------------
## The baseline is supplied on the AGGREGATE response scale, as the true marginal
## reference risk in the target. It is exactly known here, so no baseline
## estimation error contaminates the measurement; that is a simplification in the
## check's favour and is declared as one. It also sidesteps multinma's
## individual-level baseline, which is defined at the CENTRED covariate origin
## rather than at x = 0. Validated in the pilot: the predicted reference risk
## reproduces the exact truth to four decimals.
estimands <- function(f, targets, truth_by_s) {
  lapply(seq_along(TARGET_SHIFT), function(i) {
    tg <- targets[[i]]; tr <- truth_by_s[[i]]

    re <- as.data.frame(relative_effects(f, newdata = tg, study = study)$summary)
    lor    <- setNames(re$mean, as.character(re$.trtb))
    lor_sd <- setNames(re$sd,   as.character(re$.trtb))

    pr <- as.data.frame(
      predict(f, newdata = tg, study = study, type = "response", level = "aggregate",
              baseline = distr(qnorm, tr$p_ref, 1e-7), baseline_type = "response",
              baseline_level = "aggregate", baseline_trt = TRT_REF)$summary)
    risk    <- setNames(pr$mean, as.character(pr$.trt))
    risk_sd <- setNames(pr$sd,   as.character(pr$.trt))

    list(shift = TARGET_SHIFT[i],
         lor = lor[TRT_ACTIVE], lor_sd = lor_sd[TRT_ACTIVE],
         lor_CA = unname(lor[["C"]] - lor[["A"]]),
         risk = risk, risk_sd = risk_sd[TRT_ACTIVE],
         rd_CA = unname(risk[["C"]] - risk[["A"]]),
         err_rd  = unname(risk[["C"]] - risk[["A"]]) - tr$rd_CA,
         err_lor = unname(lor[["C"]] - lor[["A"]]) - tr$lor_CA)
  })
}
