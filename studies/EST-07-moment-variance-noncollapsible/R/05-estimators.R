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
## THE COMPARATOR THAT CAN WIN IS `maic_entropy`. If it restores nominal coverage
## on the logit scale across the grid, the catalog is right that this is a
## porting exercise, the study's prediction 2 is wrong, and the study says so.
## That outcome is registered here rather than discovered later.
##
## All four MAIC variants share one weight fit and one sandwich, so they differ
## in the variance they report and in nothing else. A difference between them
## cannot come from a different point estimate, which is what makes the paired
## comparison in DESIGN.md section 6 a comparison of intervals.
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

  ## THE SECOND PORT, by resampling rather than by a formula, and reported as the
  ## cited algorithm reports it: EMPIRICAL PERCENTILE limits on the resampled
  ## anchored contrast. It does not use the estimator gradient at all, which is
  ## what makes it an independent route rather than a restatement of the first.
  dr <- perturbation_draws(rep_data, link, R_use, N_PERTURB)
  dr <- dr[is.finite(dr)] - tr$theta_BC
  if (length(dr) >= 20L) {
    ## The target trial's own sampling error is not in the resampling, so it is
    ## added on the interval scale; the source contribution already is, because
    ## the source is resampled.
    half <- z * sqrt(V_BC)
    qs <- stats::quantile(dr, c((1 - level) / 2, 1 - (1 - level) / 2),
                          names = FALSE)
    out <- rbind(out, data.frame(
      method = "maic_perturb", est = theta,
      ## A PERCENTILE INTERVAL HAS NO SINGLE STANDARD ERROR, and reporting the
      ## draw SD here would put a number in the column that does not generate
      ## the interval beside it. The analysis compares interval WIDTH across
      ## methods, which is defined for all of them; `se` is NA for this row and
      ## any summary that averages it must say so.
      se = NA_real_, lower = qs[1] - half, upper = qs[2] + half,
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
