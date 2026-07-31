## ---------------------------------------------------------------------------
## The methods, including the two published ports and the one that can win.
##
## DESIGN.md section 5 registers six. Five are here; ML-NMR is separate because
## it needs Stan and its cost dominates, which is the reason the grid is
## restricted rather than fully crossed.
##
##   maic_fixed        status quo: target moments treated as constants
##   maic_entropy      the Sheng, Sun and Huang asymptotic variance
##   maic_perturb      the Chen, Chen and Yu perturbation interval
##   maic_oracle       fixed moments with the TRUE target correlation supplied
##   stc               conditional outcome model, marginalized by simulation
##
## THE COMPARATOR THAT CAN WIN IS `maic_entropy`, and round 1 of critique made
## the win condition say something the study can actually learn.
##
## It used to read: if the entropy port restores nominal coverage on the logit
## scale across the grid, the catalog is right, "the study's prediction 2 is
## wrong", and the study says so. Three things were wrong with that. Prediction 2
## has since been withdrawn outright, so no result can refute it. The catalog's
## claim is two-part, that porting works AND that what is left over is
## reconstructed-correlation uncertainty, and coverage on a filtered subset speaks
## to neither part separately. And a single filtered arm cannot vindicate a whole
## method family.
##
## WHAT THE ENTROPY ARM CAN SETTLE is narrower and is worth registering because it
## is decidable. Prediction 1 says the reported moments do not identify
## Delta(F_T), because the estimand depends on the whole target covariate law and
## the moments do not pin that law down. If that is right, then NO variance
## indexed by the reported moments can be correct, and adding the moment term must
## leave a coverage deficit that does not close. So:
##
##   `maic_entropy` reaches the registered coverage band across the grid
##     -> the moment term is sufficient IN THESE CONDITIONS, prediction 1's
##        practical bite is bounded by the conditions the grid covers, and the
##        study reports that as a negative result about its own prediction.
##   it closes part of the gap left by `maic_fixed` but not all of it
##     -> the split between the closed and the residual part is the study's
##        actual contribution, and `maic_oracle` says how much of the residual is
##        correlation rather than identification.
##
## Neither branch settles the catalog's porting claim in general, and the analysis
## must not report it as if it did.
##
## WHICH VARIANTS ARE COMPARABLE, AND WHICH IS NOT. An earlier version of this
## header said all four share one weight fit and one sandwich and so differ "in
## the variance they report and in nothing else", and round 1 of critique pointed
## at `maic_perturb` defined forty lines below, which is none of those things.
##
## Three of them do share everything but the variance. `maic_fixed`,
## `maic_entropy` and `maic_oracle` come off ONE call to `estimator_gradient`,
## carry the SAME point estimate, and differ only in which terms enter V. The
## correlation matrix an analyst assumes enters `Omega_normal` alone and never
## `fit_weights`, whose targets are means and raw second moments, so even the
## oracle arm leaves the weight fit untouched. For these three the paired contrast
## is a clean comparison of intervals: coverage differences cannot come from the
## point estimate because there is only one.
##
## `maic_perturb` IS DIFFERENT AND MUST NOT BE READ THAT WAY. It resamples the
## source, refits per draw, and reports empirical percentile limits, so its
## interval is not centered on `theta` and has no standard error at all. Against
## the other three it is a comparison of PROCEDURES, not of variance formulas, and
## its interval width and coverage are confounded with the resampling. The
## analysis reports it in the same table but not in the same paired test.
##
##   source("R/05-estimators.R")
## ---------------------------------------------------------------------------

source("R/04-maic.R")

## PROBE P5 SET THIS, and P4 is why it had to. The perturbation arm is 96% to
## 98% of the study's cost, so this constant is the entire budget lever, and 200
## was typed. Measured against an independent B = 3200 reference, the 90th
## percentile resampling error is 0.1414 at B = 50 against an across-replicate
## SE spread of 0.1774: the resampling noise is already inside the variation the
## SE has anyway, so buying more resamples buys nothing a coverage number can
## see. Registered at the smallest sufficient value, which cuts the study by 75%.
N_PERTURB <- 50L

## THE CALIBRATED CROSS-COVARIANCE, loaded once. R/14 writes it; probe P6 is why
## it exists. It is an ORACLE input in the same sense as the true correlation: no
## analyst could compute it from a published baseline table, and the arm that uses
## it exists to attribute a coverage deficit, not to be recommended.
##
## Loaded lazily and cached, so a run that never asks for the arm never needs the
## file, and a run that does asks the filesystem once rather than once per
## replicate.
.xcov_cache <- new.env(parent = emptyenv())
xcov_store <- function() {
  if (is.null(.xcov_cache$store)) {
    if (!file.exists("results/xcov.rds"))
      stop("results/xcov.rds is missing; run Rscript R/14-calibrate-xcov.R")
    .xcov_cache$store <- readRDS("results/xcov.rds")
  }
  .xcov_cache$store
}

## The key a replicate uses to find its own calibrated covariance. Kept in one
## function so the writer and the reader cannot disagree about it.
xcov_key <- function(link, nT, k, shape, modifier_span)
  paste(link, nT, k, shape, modifier_span, sep = "|")

## The lookup the estimators use. It STOPS rather than returning zero when a
## combination is missing: a silently absent correction is exactly the omission
## this file exists to fix, and it would look like a passing run.
xcov_lookup <- function(store, link, nT, k, shape, modifier_span) {
  key <- xcov_key(link, nT, k, shape, modifier_span)
  z <- store[[key]]
  if (is.null(z))
    stop("no calibrated cross-covariance for ", key,
         "; run Rscript R/14-calibrate-xcov.R")
  z$cov
}

## The correlation matrix the analyst plugs in. `borrowed` is what `cpaic` does
## and what an applied analyst has available; `true` is the oracle arm that
## isolates the correlation component from the moment component; `independence`
## is the other thing people do when no correlation is available at all.
assumed_R <- function(setting, rep_data, p) {
  switch(setting,
    true         = { r <- rep_data$hidden$rho_true
                     m <- matrix(r, p, p); diag(m) <- 1; m },
    borrowed     = stats::cor(rep_data$source$x),
    independence = diag(p),
    stop("unregistered correlation setting: ", setting))
}

## --- the four MAIC variants, from one fit -----------------------------------
maic_all <- function(rep_data, link, corr_setting, level = 0.95) {
  s <- rep_data$source; tr <- rep_data$target_reported
  z <- stats::qnorm(1 - (1 - level) / 2)
  p_cov <- ncol(s$x)

  eg <- estimator_gradient(rep_data, link)
  if (!isTRUE(eg$ok))
    return(data.frame(method = character(), est = numeric(), se = numeric(),
                      lower = numeric(), upper = numeric(),
                      stringsAsFactors = FALSE))

  ## The anchored indirect estimate is the same for every variant.
  theta <- eg$theta_AC - tr$theta_BC
  sp <- eg$parts
  aI <- as.vector(crossprod(sp$cvec, eg$Ainv))

  ## The retained source variance: weight estimation plus outcome variance,
  ## conditional on the reported moments. Every variant carries this term.
  V_S <- as.numeric(aI %*% sp$B %*% aI) / sp$n

  ## The target-moment term the ports add, under each correlation assumption.
  R_use <- assumed_R(corr_setting, rep_data, p_cov)
  Om <- Omega_normal(tr$mean, tr$sd, R_use, binary = tr$binary)
  V_T <- as.numeric(eg$J %*% Om %*% eg$J) / tr$nT

  ## The target trial's own B-versus-C effect carries sampling error too, and it
  ## is independent of the source, so it adds. Omitting it would make every
  ## interval too narrow for a reason that has nothing to do with this study.
  V_BC <- var_theta_BC(rep_data, link)

  mk <- function(name, v) {
    se <- if (is.finite(v) && v > 0) sqrt(v) else NA_real_
    data.frame(method = name, est = theta, se = se,
               lower = theta - z * se, upper = theta + z * se,
               ess = eg$ess, stringsAsFactors = FALSE)
  }

  out <- rbind(
    ## STATUS QUO: the reported moments are constants, so no V_T at all.
    mk("maic_fixed",   V_S + V_BC),
    ## THE PORT the catalog says is all that is needed.
    mk("maic_entropy", V_S + V_BC + V_T),
    ## THE ORACLE: the same correction with the TRUE correlation, which isolates
    ## the correlation component from the moment component.
    mk("maic_oracle",  V_S + V_BC +
         as.numeric(eg$J %*% Omega_normal(
           tr$mean, tr$sd, assumed_R("true", rep_data, p_cov),
           binary = tr$binary) %*% eg$J) / tr$nT))

  ## THE CROSS-COVARIANCE ARM. Probe P6 found that -2 Cov(theta_AC, theta_BC) is
  ## about 7.7% of the true variance on the identity link at k = 1, against a
  ## registered floor of 7.9%, and that it does not shrink with nT. Every
  ## published method omits it, so without this arm a coverage deficit cannot be
  ## attributed: it could be the moments failing to identify Delta(F_T), which is
  ## what the study is about, or it could be this, which is not.
  ##
  ## The arm carries the same terms as `maic_entropy` PLUS the cross term, with
  ## the covariance supplied from calibration and the gradient from this
  ## replicate's own fit. The difference between the two arms is therefore exactly
  ## the cross term, and whatever `maic_xcov` still fails to cover is what
  ## identification has to explain.
  h <- rep_data$hidden
  cv <- xcov_lookup(xcov_store(), link, tr$nT, h$k, h$shape, h$modifier_span)
  V_X <- -2 * as.numeric(crossprod(eg$J, cv))
  ## The cross term can be negative, and a negative one large enough to drive the
  ## total non-positive would mean the calibration or the gradient is wrong rather
  ## than that the variance is. `mk()` already returns NA for a non-positive
  ## variance, so such a cell reports no interval instead of an imaginary one, and
  ## the analysis must count those rather than drop them.
  out <- rbind(out, mk("maic_xcov", V_S + V_BC + V_T + V_X))

  ## THE SECOND PORT, by resampling rather than by a formula, and reported as the
  ## cited algorithm reports it: EMPIRICAL PERCENTILE limits on the resampled
  ## anchored contrast. It does not use the estimator gradient at all, which is
  ## what makes it an independent route rather than a restatement of the first.
  dr <- perturbation_draws(rep_data, link, R_use, N_PERTURB)
  ## The construction lives in `draw_anchored()`/`limits_from_draws()` so that P5,
  ## which sizes `N_PERTURB`, builds its intervals with THIS code rather than a
  ## copy of it.
  lu <- limits_from_draws(draw_anchored(dr, tr$theta_BC, V_BC), level)
  if (all(is.finite(lu))) {
    out <- rbind(out, data.frame(
      method = "maic_perturb", est = theta,
      ## A PERCENTILE INTERVAL HAS NO SINGLE STANDARD ERROR, and reporting the
      ## draw SD here would put a number in the column that does not generate
      ## the interval beside it. The analysis compares interval WIDTH across
      ## methods, which is defined for all of them; `se` is NA for this row and
      ## any summary that averages it must say so.
      se = NA_real_, lower = lu[1], upper = lu[2],
      ess = eg$ess, stringsAsFactors = FALSE))
  }
  out
}

## The variance of the target trial's own anchored effect, on the reported
## scale. Binomial arms give the closed form; the identity link uses the sample
## variance. This is a property of the target trial and is shared by every
## method, so it is computed once.
## ROUND 1: THIS ASSUMED EQUAL ARMS AT p = 0.5 AND WAS FOURFOLD TOO SMALL.
## Measured against simulation it understated the variance by 1.6 times on the
## identity link, 3.7 on logit and 4.25 on cloglog. Every method shares the term,
## so every interval was too narrow for a reason unrelated to target-moment
## uncertainty, which would have made all of them undercover and invalidated both
## the primary comparison and the identity falsifier.
##
## It is now computed from the realized target arms by `arm_contrast_var()` and
## carried on the replicate, which is what a published trial reports.
var_theta_BC <- function(rep_data, link) {
  v <- rep_data$target_reported$var_theta_BC
  if (is.null(v)) stop("the replicate carries no target-trial variance; ",
                       "R/03-sample.R must supply it")
  v
}

## --- the perturbation interval ----------------------------------------------
##
## Chen, Chen and Yu resample the reported moments from their sampling
## distribution and refit, so the target-summary uncertainty enters through the
## refit rather than through a gradient. That is the point of including it: it
## does NOT use the estimator gradient, so if prediction 2 is right about the
## gradient this method should behave differently from the entropy port.
## ROUND 1: THE FIRST VERSION WAS NOT THE CITED ALGORITHM. It held the source
## data fixed, perturbed only the target moments, took the variance of the
## resulting estimates and formed a normal interval, then reported that variance
## plus the target-trial term while OMITTING the source sandwich variance that
## every other method carries. So it was neither the published procedure nor a
## coherent variance for the estimator, and P4 and P5 measured the cost and the
## resampling error of something the study does not use.
##
## The cited algorithm does three things this now does: it RESAMPLES THE SOURCE
## OBSERVATIONS, perturbs the target summaries, and refits; and it takes
## EMPIRICAL PERCENTILE limits rather than a normal approximation. Resampling the
## source is what makes the source contribution enter the interval, so no
## separate sandwich term is added and none is missing.
perturbation_draws <- function(rep_data, link, R_use, n_perturb) {
  tr <- rep_data$target_reported
  s <- rep_data$source
  n <- nrow(s$h)
  Om <- Omega_normal(tr$mean, tr$sd, R_use, binary = tr$binary) / tr$nT
  L <- tryCatch(chol(Om + diag(1e-10, nrow(Om))), error = function(e) NULL)
  if (is.null(L)) return(rep(NA_real_, n_perturb))
  vapply(seq_len(n_perturb), function(b) {
    ## Both sources of variability, in the same draw.
    idx <- sample.int(n, n, replace = TRUE)
    m_b <- as.vector(tr$m + crossprod(L, rnorm(nrow(Om))))
    fw <- tryCatch(fit_weights(s$h[idx, , drop = FALSE], m_b),
                   error = function(e) NULL)
    if (is.null(fw) || fw$conv != CONVERGENCE$optim_code) return(NA_real_)
    sp <- tryCatch(sandwich_parts(s$h[idx, , drop = FALSE], s$A[idx], s$Y[idx],
                                  fw$w, m_b, link),
                   error = function(e) NULL)
    if (is.null(sp) || !is.finite(sp$theta_AC)) return(NA_real_)
    sp$theta_AC
  }, 0)
}

## Kept for the probes, which report a variance rather than an interval.
perturbation_var <- function(rep_data, link, R_use, n_perturb) {
  stats::var(perturbation_draws(rep_data, link, R_use, n_perturb), na.rm = TRUE)
}

## The interval a given set of draws produces. Defined once and used BOTH by
## `maic_all()` to build the reported interval and by P5 to size the number of
## draws, so the probe cannot drift from the estimator it sizes.
##
## ROUND 1, SECOND ERROR IN THIS CONSTRUCTION. The first repair moved the arm to
## empirical percentile limits, correctly, and then added the target trial's own
## uncertainty by widening each limit by z * sqrt(V_BC). That adds STANDARD
## DEVIATIONS where variances have to combine: the resulting half-width behaves
## like sqrt(V_AC) + sqrt(V_BC) instead of sqrt(V_AC + V_BC), and the triangle
## inequality makes it strictly too wide whenever both terms are positive. P5
## measured the damage: coverage 0.9933 against a nominal 0.95, and a mean width
## of 1.33 where the entropy arm reports 1.02.
##
## The fix puts the target trial's noise INSIDE the resampling, which is where an
## independent external estimate belongs: each draw subtracts its own
## theta_BC draw, so the percentile limits are taken on the anchored contrast and
## the two variances combine by convolution rather than by addition of widths.
## `draw_anchored()` does that, and this function then does nothing but take
## quantiles, which is why it can no longer get the combination wrong.
draw_anchored <- function(dr, theta_BC, V_BC) {
  d <- dr[is.finite(dr)]
  if (!length(d)) return(numeric(0))
  se_BC <- if (is.finite(V_BC) && V_BC > 0) sqrt(V_BC) else 0
  d - (theta_BC + stats::rnorm(length(d), 0, se_BC))
}

limits_from_draws <- function(anch, level = 0.95) {
  if (length(anch) < 20L) return(c(NA_real_, NA_real_))
  stats::quantile(anch, c((1 - level) / 2, 1 - (1 - level) / 2), names = FALSE)
}

## --- STC --------------------------------------------------------------------
##
## A conditional outcome model fitted in the source and marginalized over the
## target law. The catalog lists it and MIS-03 omitted it. Its failure mode is
## different: it never forms weights, so it cannot fail on overlap, but it
## carries the target moments into a model rather than into a weight and is
## exposed to the same non-collapsibility.
stc_estimate <- function(rep_data, link, level = 0.95, n_sim = 2000L) {
  s <- rep_data$source; tr <- rep_data$target_reported
  z <- stats::qnorm(1 - (1 - level) / 2)
  fam <- switch(link, identity = stats::gaussian(),
                logit = stats::binomial(),
                cloglog = stats::binomial(link = "cloglog"),
                stop("unregistered link: ", link))
  df <- data.frame(Y = s$Y, A = s$A, s$x)
  fit <- tryCatch(stats::glm(Y ~ A * ., data = df, family = fam),
                  error = function(e) NULL)
  if (is.null(fit) || !fit$converged)
    return(data.frame(method = character(), est = numeric(), se = numeric(),
                      lower = numeric(), upper = numeric(),
                      stringsAsFactors = FALSE))
  ## Marginalize over a target law reconstructed from the reported moments,
  ## which is the same input MAIC uses and the same reconstruction.
  p_cov <- ncol(s$x)
  R_use <- assumed_R("borrowed", rep_data, p_cov)
  S <- diag(tr$sd) %*% R_use %*% diag(tr$sd)
  xs <- MASS::mvrnorm(n_sim, tr$mean, S)
  nd <- data.frame(xs); names(nd) <- names(df)[-(1:2)]
  m1 <- mean(stats::predict(fit, cbind(A = 1, nd), type = "response"))
  m0 <- mean(stats::predict(fit, cbind(A = 0, nd), type = "response"))
  est <- delta_from_arm_means(m0, m1, link) - tr$theta_BC
  ## A sandwich on the marginalized contrast is not available in closed form, so
  ## the reported SE is the model-based delta method plus the target arm term,
  ## which is what an applied STC reports and therefore what is under test.
  se <- sqrt(stats::vcov(fit)["A", "A"] + var_theta_BC(rep_data, link))
  data.frame(method = "stc", est = est, se = se,
             lower = est - z * se, upper = est + z * se,
             ess = NA_real_, stringsAsFactors = FALSE)
}

## --- everything for one replicate -------------------------------------------
estimate_all <- function(rep_data, link, corr_setting) {
  rbind(maic_all(rep_data, link, corr_setting),
        stc_estimate(rep_data, link))
}
