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
## was typed.
##
## THREE ANSWERS CAME OUT OF SIZING IT, AND THE FIRST TWO WERE WRONG.
##
## 50, from a probe that watched the VARIANCE of the draws converge. After the
## arm was rewritten to report percentile limits, that variance generated no
## interval anywhere in the study, so the constant was chosen by watching an
## unused quantity settle.
##
## 25, from a probe that watched COVERAGE converge while the interval was so
## badly over-wide that coverage could not move: 0.9933 against a nominal 0.95.
## A criterion evaluated on a saturated quantity passes everything.
##
## 800, once the interval was correct and the criterion had signal. Measured over
## 800 replicates against an independent B = 3200 reference, with the limits at
## every B read from nested subsamples of one draw set so the comparison is
## paired:
##
##     B     coverage   width bias
##    50       0.9225      -8.31%
##   100       0.9363      -4.46%
##   200       0.9463      -1.81%
##   400       0.9500      -1.15%
##   800       0.9537      -0.56%      reference 0.9550
##
## An empirical quantile from few draws is biased INWARD, so a small B does not
## merely add noise, it narrows every interval systematically. At the previously
## registered 50 the arm would have undercovered by more than three points purely
## from its own resampling budget, and the study would have reported that as a
## property of the method.
##
## This is sixteen times the old value on the arm that dominates the cost, and it
## is what the registered tolerances require. The budget in R/10 is measured at
## this value rather than extrapolated from the old one.
N_PERTURB <- 800L

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
## THE KEY CARRIES THE ARM AND THE BASELINE SHIFT. Both change the target
## quantity the moments covary with: anchored differences a two-arm effect,
## unanchored a single arm, and the shift moves the outcome distribution. A key
## missing either would hand one setting the other's covariance.
xcov_key <- function(link, nT, k, shape, modifier_span, anchored, baseline_shift)
  paste(link, nT, k, shape, modifier_span, isTRUE(anchored), baseline_shift,
        sep = "|")

## The lookup the estimators use. It STOPS rather than returning zero when a
## combination is missing: a silently absent correction is exactly the omission
## this file exists to fix, and it would look like a passing run.
xcov_lookup <- function(store, link, nT, k, shape, modifier_span, anchored,
                        baseline_shift) {
  key <- xcov_key(link, nT, k, shape, modifier_span, anchored, baseline_shift)
  z <- store[[key]]
  if (is.null(z))
    stop("no calibrated cross-covariance for ", key,
         "; run Rscript R/14-calibrate-xcov.R")
  z$cov
}

## The target population's correlation among the REPORTED covariates, computed
## once per distinct population and cached for the life of the process.
##
## It cannot be read off `rho_true`, which is the correlation of the latent
## Gaussian: dichotomization attenuates it and the lognormal map bends it. It is
## therefore measured from a large draw of the same law the sampler uses, which
## is the only way to be sure the number describes the population the replicates
## actually come from.
.cor_cache <- new.env(parent = emptyenv())
COR_CAL_N <- 400000L

target_pop_cor <- function(rep_data) {
  h <- rep_data$hidden
  cols <- rep_data$source$reported
  key <- paste(h$shape, h$modifier_span, h$rho_true, length(cols), sep = "|")
  z <- .cor_cache[[key]]
  if (is.null(z)) {
    ## A FIXED SEED, restored afterwards, so this calibration never consumes the
    ## replicate's random stream. Consuming it would break the common random
    ## numbers the whole design rests on.
    old_seed <- if (exists(".Random.seed", .GlobalEnv))
                  get(".Random.seed", .GlobalEnv) else NULL
    set.seed(414141L)
    p_all <- length(h$pars$beta_em)
    pm <- population_means(OVERLAP_SMD, p_all, h$shape)
    x <- covariate_law(h$shape, COR_CAL_N, pm$target,
                       rep(1, p_all), h$rho_true)
    z <- stats::cor(x[, cols, drop = FALSE])
    if (!is.null(old_seed)) assign(".Random.seed", old_seed, .GlobalEnv)
    .cor_cache[[key]] <- z
  }
  z
}

## The correlation matrix the analyst plugs in. `borrowed` is what `cpaic` does
## and what an applied analyst has available; `true` is the oracle arm that
## isolates the correlation component from the moment component; `independence`
## is the other thing people do when no correlation is available at all.
assumed_R <- function(setting, rep_data, p) {
  switch(setting,
    ## THE TARGET'S ACTUAL CORRELATION, not the latent parameter that generated
    ## it. Round 1 of critique: this used to build a compound-symmetric matrix
    ## from `rho_true`, which is the correlation of the GAUSSIAN the covariates
    ## are drawn from and survives to the covariates themselves only under
    ## `mvnorm`. Dichotomization attenuates it: measured realized correlations
    ## under `mixed` are 0.238 and 0.236 on the pairs involving the binary
    ## covariate against a supplied 0.30, and the lognormal map moves it too.
    ##
    ## So the arm that exists to ISOLATE the correlation component was injecting
    ## a correlation the target population does not have, which is the opposite
    ## of an oracle.
    ##
    ## It now supplies the target POPULATION correlation of the reported
    ## covariates. The realized correlation of this replicate's own target sample
    ## would also be "true" in a sense, but it carries sampling noise of order
    ## (1 - r^2)/sqrt(nT), which at nT = 300 is about 0.055, and feeding a noisy
    ## correlation into `Omega_normal` would make the oracle's own correction
    ## noisy. The oracle exists to show what the correction achieves when the
    ## correlation is known exactly, so it gets the exact value.
    true         = target_pop_cor(rep_data),
    ## Over the REPORTED covariates only. An analyst borrows the correlation of
    ## the covariates the target published, because those are the ones whose
    ## moments are being matched; a correlation involving an unreported covariate
    ## has nothing to multiply.
    borrowed     = stats::cor(rep_data$source$x[, rep_data$source$reported,
                                                drop = FALSE]),
    independence = diag(p),
    stop("unregistered correlation setting: ", setting))
}

## --- the four MAIC variants, from one fit -----------------------------------
maic_all <- function(rep_data, link, corr_setting, level = 0.95) {
  s <- rep_data$source; tr <- rep_data$target_reported
  z <- stats::qnorm(1 - (1 - level) / 2)
  ## The moment dimension is the number of REPORTED covariates, not the number
  ## the source happens to hold. Under the `outside` arm they differ by one, and
  ## using the wrong one silently builds a correlation matrix of the wrong size.
  p_cov <- tr$n_reported

  eg <- estimator_gradient(rep_data, link)
  if (!isTRUE(eg$ok))
    return(data.frame(method = character(), est = numeric(), se = numeric(),
                      lower = numeric(), upper = numeric(),
                      stringsAsFactors = FALSE))

  ## ANCHORED OR NOT. Both contrasts come off the SAME weight fit and the same
  ## sandwich; they differ in which arms they combine and in what the target
  ## contributes. Anchored differences the target's two-arm B-versus-C effect;
  ## unanchored differences its treated arm alone, which carries far less
  ## variance and is why the moment term is a larger share of a smaller total
  ## without an anchor. It is also where the target's baseline risk stops
  ## cancelling, so the unanchored arm buys visibility at the cost of a bias the
  ## anchored one does not have.
  anchored <- !isFALSE(rep_data$hidden$anchored)
  sp <- eg$parts
  if (anchored) {
    theta   <- eg$theta_AC - tr$theta_BC
    aI      <- eg$aI
    Jm      <- eg$J
    V_targ  <- tr$var_theta_BC
  } else {
    theta   <- eg$theta_A - tr$g_mu_B
    aI      <- eg$aI_un
    Jm      <- eg$J_un
    V_targ  <- tr$var_g_mu_B
  }

  ## The retained source variance: weight estimation plus outcome variance,
  ## conditional on the reported moments. Every variant carries this term.
  V_S <- as.numeric(aI %*% sp$B %*% aI) / sp$n

  ## The target-moment term the ports add, under each correlation assumption.
  R_use <- assumed_R(corr_setting, rep_data, p_cov)
  Om <- Omega_normal(tr$mean, tr$sd, R_use, binary = tr$binary)
  V_T <- as.numeric(Jm %*% Om %*% Jm) / tr$nT

  ## The target trial's own contribution carries sampling error too, and it is
  ## independent of the source, so it adds. Omitting it would make every interval
  ## too narrow for a reason that has nothing to do with this study.
  V_BC <- V_targ
  if (is.null(V_BC) || !is.finite(V_BC))
    stop("the replicate carries no target-trial variance for the ",
         if (anchored) "anchored" else "unanchored", " contrast")

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
         as.numeric(Jm %*% Omega_normal(
           tr$mean, tr$sd, assumed_R("true", rep_data, p_cov),
           binary = tr$binary) %*% Jm) / tr$nT))

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
  cv <- xcov_lookup(xcov_store(), link, tr$nT, h$k, h$shape,
                    h$modifier_span, h$anchored, h$baseline_shift)
  V_X <- -2 * as.numeric(crossprod(Jm, cv))
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
  lu <- limits_from_draws(
    draw_anchored(dr, if (anchored) tr$theta_BC else tr$g_mu_B, V_BC), level)
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
perturbation_draws <- function(rep_data, link, R_use, n_perturb,
                              anchored = !isFALSE(rep_data$hidden$anchored)) {
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
    ## The same draw serves both contrasts; which one is read off depends on the
    ## arm, exactly as in `maic_all()`.
    val <- if (anchored) sp$theta_AC else sp$theta_A
    if (is.null(sp) || !is.finite(val)) return(NA_real_)
    val
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
## `noise` MAY BE SUPPLIED, and P5 must supply it.
##
## Round 4 of critique: P5 sizes B by reading nested prefixes of ONE reference
## draw set, so that every B sees the same resamples and the coverage comparison
## is paired. This function drew the target trial's noise fresh on each call, so
## the prefixes did not in fact share it and each B re-randomized part of its own
## interval. The pairing the design rests on was not happening.
##
## Passing the noise in makes the nesting real: P5 draws it once at the reference
## size and hands prefixes of it alongside prefixes of the resamples. Production
## leaves it NULL and gets a fresh draw per replicate, which is correct there.
draw_anchored <- function(dr, theta_BC, V_BC, noise = NULL) {
  keep <- is.finite(dr)
  d <- dr[keep]
  if (!length(d)) return(numeric(0))
  se_BC <- if (is.finite(V_BC) && V_BC > 0) sqrt(V_BC) else 0
  z <- if (is.null(noise)) stats::rnorm(length(d), 0, se_BC)
       else noise[keep][seq_along(d)] * se_BC
  d - (theta_BC + z)
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
  ## STC FITS ON THE REPORTED COVARIATES ONLY. The model has to be marginalized
  ## over a target law reconstructed from published summaries, so a term the
  ## analyst cannot integrate out cannot be in the model. Under the `outside` arm
  ## that leaves one modifier unmodeled, which is exactly the exposure the arm
  ## exists to create; fitting on all four and then marginalizing over three
  ## would be a mismatch no analyst could commit.
  xr <- s$x[, s$reported, drop = FALSE]
  df <- data.frame(Y = s$Y, A = s$A, xr)
  fit <- tryCatch(stats::glm(Y ~ A * ., data = df, family = fam),
                  error = function(e) NULL)
  if (is.null(fit) || !fit$converged)
    return(data.frame(method = character(), est = numeric(), se = numeric(),
                      lower = numeric(), upper = numeric(),
                      stringsAsFactors = FALSE))
  ## Marginalize over a target law reconstructed from the reported moments,
  ## which is the same input MAIC uses and the same reconstruction.
  p_cov <- tr$n_reported
  R_use <- assumed_R("borrowed", rep_data, p_cov)
  S <- diag(tr$sd) %*% R_use %*% diag(tr$sd)
  xs <- MASS::mvrnorm(n_sim, tr$mean, S)
  nd <- data.frame(xs); names(nd) <- names(df)[-(1:2)]
  m1 <- mean(stats::predict(fit, cbind(A = 1, nd), type = "response"))
  m0 <- mean(stats::predict(fit, cbind(A = 0, nd), type = "response"))
  ## STC differences the same target quantity its MAIC counterpart does.
  lf <- link_fns(link)
  anchored <- !isFALSE(rep_data$hidden$anchored)
  est <- if (anchored) delta_from_arm_means(m0, m1, link) - tr$theta_BC
         else lf$g(m1) - tr$g_mu_B
  ## THE INTERVAL MUST BE FOR THE ESTIMATOR THAT IS REPORTED, and for three
  ## rounds it was not. `vcov(fit)["A", "A"]` is the variance of the CONDITIONAL
  ## coefficient on treatment. The estimate above is a MARGINALIZED contrast:
  ## predictions are averaged over a reconstructed target law and only then put
  ## through the link. On a curved link those are different quantities, which is
  ## the same non-collapsibility the whole study is about, so reporting one as the
  ## other is the study's own subject appearing as a bug.
  ##
  ## The marginalized contrast is a smooth function of the fitted coefficients, so
  ## a delta method over the FULL coefficient vector is correct to first order and
  ## needs no closed form: the gradient is taken numerically through the same
  ## marginalization the point estimate uses, and the target law is held fixed so
  ## the derivative is of the estimator and not of the reconstruction.
  marg <- function(bet) {
    f2 <- fit; f2$coefficients <- bet
    m1b <- mean(stats::predict(f2, cbind(A = 1, nd), type = "response"))
    m0b <- mean(stats::predict(f2, cbind(A = 0, nd), type = "response"))
    if (anchored) delta_from_arm_means(m0b, m1b, link) else lf$g(m1b)
  }
  ## CHECKED AGAINST A BOOTSTRAP rather than asserted. Resampling the source 400
  ## times and remarginalizing gives a model-component variance of 0.00344 where
  ## this delta method gives 0.00387, a 12% gap against a bootstrap whose own
  ## precision at that size is about 7%. At the registered `n_sim` the two are
  ## closer still; the difference at small `n_sim` is the marginalization's own
  ## Monte Carlo error, which the coefficient delta method cannot see and which
  ## shrinks as the reconstruction is drawn more finely.
  ##
  ## The delta method is kept because it is what an applied STC reports, and what
  ## applied methods report is what this study is testing.
  bet <- stats::coef(fit)
  V <- stats::vcov(fit)
  ok_b <- is.finite(bet) & !is.na(bet)
  g_num <- rep(0, length(bet))
  h <- pmax(abs(bet), 1) * 1e-4
  for (j in which(ok_b)) {
    bp <- bet; bp[j] <- bp[j] + h[j]
    bm <- bet; bm[j] <- bm[j] - h[j]
    g_num[j] <- (marg(bp) - marg(bm)) / (2 * h[j])
  }
  g_num[!ok_b] <- 0
  V[!ok_b, ] <- 0; V[, !ok_b] <- 0
  v_model <- as.numeric(t(g_num) %*% V %*% g_num)
  se <- sqrt(v_model + if (anchored) tr$var_theta_BC else tr$var_g_mu_B)
  data.frame(method = "stc", est = est, se = se,
             lower = est - z * se, upper = est + z * se,
             ess = NA_real_, stringsAsFactors = FALSE)
}

## --- everything for one replicate -------------------------------------------
estimate_all <- function(rep_data, link, corr_setting) {
  rbind(maic_all(rep_data, link, corr_setting),
        stc_estimate(rep_data, link))
}
