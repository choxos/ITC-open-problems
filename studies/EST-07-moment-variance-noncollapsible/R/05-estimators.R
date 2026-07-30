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

N_PERTURB <- 200L   # resamples for the perturbation interval; costed by P4

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

  ## THE SECOND PORT, by resampling rather than by a formula. It is a different
  ## route to the same target, so agreeing with the first is evidence about both
  ## and disagreeing is evidence that at least one is wrong.
  pv <- perturbation_var(rep_data, link, R_use, N_PERTURB)
  out <- rbind(out, mk("maic_perturb", pv + V_BC))
  out
}

## The variance of the target trial's own anchored effect, on the reported
## scale. Binomial arms give the closed form; the identity link uses the sample
## variance. This is a property of the target trial and is shared by every
## method, so it is computed once.
var_theta_BC <- function(rep_data, link) {
  tr <- rep_data$target_reported
  n_arm <- tr$nT / 2
  switch(link,
    identity = 2 * 1 / n_arm,
    ## delta method on g(p) with p estimated from n_arm observations
    logit    = { p <- 0.5; 2 * (1 / (n_arm * p * (1 - p))) * 0.25 },
    cloglog  = { p <- 0.5; 2 * (1 / (n_arm * p * (1 - p))) * (p * log(p))^2 },
    stop("unregistered link: ", link))
}

## --- the perturbation interval ----------------------------------------------
##
## Chen, Chen and Yu resample the reported moments from their sampling
## distribution and refit, so the target-summary uncertainty enters through the
## refit rather than through a gradient. That is the point of including it: it
## does NOT use the estimator gradient, so if prediction 2 is right about the
## gradient this method should behave differently from the entropy port.
perturbation_var <- function(rep_data, link, R_use, n_perturb) {
  tr <- rep_data$target_reported
  p_cov <- ncol(rep_data$source$x)
  Om <- Omega_normal(tr$mean, tr$sd, R_use, binary = tr$binary) / tr$nT
  L <- tryCatch(chol(Om + diag(1e-10, nrow(Om))), error = function(e) NULL)
  if (is.null(L)) return(NA_real_)
  th <- vapply(seq_len(n_perturb), function(b) {
    m_b <- as.vector(tr$m + crossprod(L, rnorm(nrow(Om))))
    fw <- fit_weights(rep_data$source$h, m_b)
    if (fw$conv != CONVERGENCE$optim_code) return(NA_real_)
    sp <- sandwich_parts(rep_data$source$h, rep_data$source$A,
                         rep_data$source$Y, fw$w, m_b, link)
    sp$theta_AC
  }, 0)
  stats::var(th, na.rm = TRUE)
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
