## The diagnostics, exactly as an analyst would be able to compute them.
##
## Two rules govern this file and both matter for whether the study is a fair
## test.
##
## 1. NOTHING HERE USES A QUANTITY THE ANALYST DOES NOT HAVE, except where the
##    name begins `orc_`. Those are oracles, reported as ceilings so that a
##    diagnostic's failure can be attributed either to the statistic or to the
##    information not being in the data. The distinction is the whole point of the
##    catalog entry: a diagnostic computed from the fitted data is not logically
##    barred from predicting error, so a study has to separate "this statistic is
##    the wrong function of the available information" from "the information is
##    not there".
##
## 2. Two of the routinely reported quantities are included even though algebra
##    settles them in advance, because a reader who has seen them side by side in
##    a submission deserves to see the demonstration:
##
##    ESS / n = 1 / (1 + CV^2(w)) exactly, since
##      (sum w)^2 / sum w^2 = n / (1 + s^2 / wbar^2) with s^2 the population
##      variance of the weights. So effective sample size, effective sample size
##      as a percentage, and the coefficient of variation of the weights are one
##      statistic written three ways. Area under the ROC curve is invariant to
##      strictly monotone transformation, so within a fixed source size the three
##      have identical discrimination, necessarily and not empirically.
##
##    The post-weighting standardized difference on the MATCHED moments is zero at
##      the solution of the calibration equations, because those equations set it
##      to zero. It is reported in submissions as evidence that the adjustment
##      worked. It cannot discriminate anything.

## Weighted mean, with the weight vector normalized internally so the scale of w
## never matters.
wmean <- function(x, w) sum(w * x) / sum(w)

## Kish effective sample size.
ess_of <- function(w) sum(w)^2 / sum(w^2)

## Diagnostics available before any weight is fitted: they are properties of the
## source covariate distribution and the published baseline table alone, which is
## what makes them usable at the protocol stage rather than after the fact.
pre_fit_diagnostics <- function(X, mu_T) {
  xs <- colMeans(X[, MATCHED, drop = FALSE])
  sds <- apply(X[, MATCHED, drop = FALSE], 2, stats::sd)
  d <- mu_T[MATCHED] - xs
  S <- stats::cov(X[, MATCHED, drop = FALSE])
  c(smd_pre = max(abs(d / sds)),
    maha = sqrt(as.numeric(crossprod(d, solve(S, d)))))
}

## The source-estimated treatment-by-covariate interactions over ALL measured
## covariates, including the one the adjustment set leaves out. This is estimable
## from the individual data whatever the analyst chose to match on, and it is what
## makes the last diagnostic below possible.
source_interactions <- function(X, A, Y) {
  d <- data.frame(Y = Y, A = A, X)
  names(d)[-(1:2)] <- X_NAMES
  fit <- stats::lm(stats::as.formula(
    paste("Y ~ A * (", paste(X_NAMES, collapse = " + "), ")")), data = d)
  b <- stats::coef(fit)
  g <- b[paste0("A:", X_NAMES)]
  names(g) <- X_NAMES
  ifelse(is.na(g), 0, g)
}

## Diagnostics for one fitted method.
##
## `w` is the weight vector (all ones for the unweighted methods). `resid_x4` is
## the residual imbalance on the unmatched covariate under that method's own
## adjustment, which is not the same quantity for weighting and for regression:
## a weighted estimator leaves the weighted source mean of X4, while an outcome
## regression evaluated at the target's matched means implicitly carries the
## source conditional mean of X4 given the matched covariates.
diagnostics_for <- function(method, rep_data, w, resid, ghat, extra = list(),
                            h_used = NULL, m_used = NULL) {
  s <- rep_data$source
  X <- s$X
  n <- nrow(X)
  mu_T <- rep_data$target$mean
  ## The balance statistic is computed on whatever this fit calibrated. For an
  ## unweighted estimator there are no calibration constraints, so the comparison
  ## defaults to the full moment set a MAIC would have matched.
  h <- if (is.null(h_used)) h_of(X) else h_used
  m <- if (is.null(m_used)) rep_data$m_T else m_used
  sdh <- pmax(apply(h, 2, stats::sd), 1e-8)

  ess <- ess_of(w)
  out <- c(
    ## Reported everywhere. A variance statistic.
    ess = ess,
    ess_pct = ess / n,
    cv_w = stats::sd(w) * sqrt((n - 1) / n) / mean(w),
    ## Tail concentration, which is NOT a monotone function of the above.
    max_w = max(w) / sum(w),
    ## Zero at the solution, by construction.
    smd_matched = max(abs(colSums(w * h) / sum(w) - m) / sdh),
    ## Residual imbalance on the measured covariate that was not adjusted for.
    ## Computable only if the target publication reports that covariate.
    smd_unmatched = abs(resid[[4]]) / max(stats::sd(X[, 4]), 1e-8),
    ## Residual imbalance converted into the units of the estimand by the
    ## source-estimated interactions: an estimate of the bias itself rather than a
    ## proxy for it. This is the study's constructive proposal.
    ##
    ## The sum runs over EVERY measured covariate, not only the unmatched one.
    ## For a weighted or regression estimator the adjusted covariates contribute
    ## nothing because their residual imbalance is zero, so the sum reduces to the
    ## unmatched term; for the unadjusted comparison every covariate contributes,
    ## which is the whole reason its estimate is off. An earlier version summed
    ## only the unmatched term for every method, which understated the estimable
    ## bias of the unadjusted comparison by most of it.
    bias_hat = abs(sum(ghat * resid))
  )
  out <- c(out, pre_fit_diagnostics(X, mu_T))
  for (nm in names(extra)) out[[nm]] <- extra[[nm]]
  out
}

## Residual covariate imbalance under each adjustment: the vector of gaps between
## the target mean and whatever mean the estimator actually carries, for every
## measured covariate.
##
## For weighting, the estimator carries the weighted source distribution, so the
## residual is the target mean minus the weighted source mean. The adjusted
## covariates come out at zero, which is the point.
##
## For an outcome regression evaluated at the target's matched means, the adjusted
## covariates are set to the target means exactly, so their residuals are zero by
## construction; the influence of the unadjusted covariate enters through the
## source regression of X4 on the adjusted ones, so its residual is the target
## mean minus the source conditional mean at the target's matched means.
##
## For no adjustment at all, every residual is the raw difference in means.
residual_imbalance <- function(method, X, w, mu_T) {
  if (method %in% c("maic", "maic_mean"))
    return(mu_T - apply(X, 2, wmean, w = w))
  if (method == "unadj") return(mu_T - colMeans(X))
  d <- data.frame(X4 = X[, 4], X[, MATCHED, drop = FALSE])
  names(d)[-1] <- X_NAMES[MATCHED]
  fit <- stats::lm(X4 ~ ., data = d)
  nd <- as.data.frame(as.list(mu_T[MATCHED]))
  names(nd) <- X_NAMES[MATCHED]
  r <- numeric(P)
  r[4] <- mu_T[4] - unname(stats::predict(fit, nd))
  r
}

## Oracles. Not diagnostics; ceilings.
##
## `orc_cross` is the gap on E[X1 X2] between the target and the adjusted source,
## scaled by the true coefficient on that term. No baseline table reports a
## correlation, so this quantity is unavailable in practice by an information
## limit rather than a statistical one, and reporting it says how much of the
## damage was undiagnosable in principle.
oracle_cross <- function(method, X, w, mu_T, joint, target_cross) {
  if (joint == 0) return(0)
  adj_cross <- if (method %in% c("maic", "maic_mean")) wmean(X[, 1] * X[, 2], w) else {
    ## A regression evaluated at the target's matched means carries the source
    ## cross-moment implied by the source covariance at that mean vector.
    S <- stats::cov(X[, MATCHED, drop = FALSE])
    if (method == "unadj") mean(X[, 1] * X[, 2]) else S[1, 2] + mu_T[1] * mu_T[2]
  }
  abs(joint * (target_cross - adj_cross))
}
