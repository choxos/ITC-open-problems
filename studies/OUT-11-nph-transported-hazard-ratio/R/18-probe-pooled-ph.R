## ---------------------------------------------------------------------------
## Can the ML-NMR within-row contrast be made to vary proportionality ALONE?
##
## Round 6 upheld this objection and it is correct as stated. The registered
## within-row contrast compares
##
##   MLNMR-PH    aux_by = .study            study-indexed baseline splines
##   MLNMR-flex  aux_regression = ~ .trt    treatment-indexed, POOLED across studies
##
## so it changes proportionality and baseline pooling together. Version 5's
## defense was that this design's two studies differ by a pure level shift on the
## log-cumulative-hazard scale, which the study intercepts absorb exactly. That
## argument is sound and insufficient: it shows both model classes contain the
## population truth, which says nothing about whether their finite-sample
## likelihoods, parameter sharing and priors behave alike. A claim about RMSE and
## coverage cannot rest on a claim about identifiability.
##
## The right fix is not a defense but a third arm: a PROPORTIONAL fit whose
## baseline is pooled the same way the flexible one is. Then
##
##   pooled-PH  vs  flexible   varies proportionality alone,  and
##   pooled-PH  vs  MLNMR-PH   measures what the pooling alone costs.
##
## This probe asks whether multinma 0.9.1 can express such a fit at all. Three
## candidate specifications are tried and the parameters each actually produces
## are read out of the fitted Stan object, because round 5 found
## `aux_regression = ~ .study + .trt` ACCEPTED AND SILENTLY IGNORED, producing
## treatment-indexed parameters with no error and no warning. A specification
## that runs is not a specification that did what it says.
##
##   Rscript R/18-probe-pooled-ph.R
## ---------------------------------------------------------------------------

Sys.setenv(PROBE_NOMAIN = "1")
source("R/probe-integration.R")

set.seed(SEED + 991)
d <- sim_network(SEED + 991, family = "weibull", kappa_b = 0.30, gamma = GAMMA,
                 beta_b = -0.44, cens = E3_CENS[E3_CENS$label == "balanced", ],
                 kappa_a = 0)
net <- build_net(d, 32L)
nd  <- target_newdata(d, 32L)

## A constant column, so `aux_by` has something to group EVERYTHING into. The
## aggregate side carries it too, since `build_net` reads both frames.
transform_net <- function(z) {
  z$ipd$.pool <- "all"; z$agd$.pool <- "all"
  z
}

## What distinguishes the specifications is which index the spline coefficients
## carry, so that is what gets read back.
aux_params <- function(f) {
  nm <- names(f$stanfit@sim$samples[[1]])
  p <- grep("^(scoef|beta_aux)\\[", nm, value = TRUE)
  idx <- unique(sub("^[^\\[]+\\[([^,]+),.*$", "\\1", p))
  list(family = unique(sub("\\[.*$", "", p)), n = length(p), index = idx)
}

try_spec <- function(label, expr) {
  cat(sprintf("\n--- %s ---\n", label))
  t0 <- Sys.time()
  f <- try(eval(expr), silent = TRUE)
  if (inherits(f, "try-error")) {
    cat(sprintf("  REJECTED: %s\n", conditionMessage(attr(f, "condition"))))
    return(list(label = label, ok = FALSE,
                err = conditionMessage(attr(f, "condition"))))
  }
  a <- aux_params(f)
  ## A FAILED SAMPLER IS NOT AN R ERROR HERE. `nma` prints the Stan exception,
  ## returns an object with no draws, and does not signal a condition, so
  ## `try` catches nothing. The first version of this probe was fooled by that
  ## and reported a rejected specification as an available one, which is the
  ## same silent-acceptance failure mode the probe was written to detect.
  if (!length(f$stanfit@sim) || !a$n) {
    cat("  REJECTED: the sampler did not run; no draws and no auxiliary\n")
    cat("  parameters. `nma` returns normally in this case rather than erroring.\n")
    return(list(label = label, ok = FALSE, err = "sampler did not run"))
  }
  cat(sprintf("  fitted in %.0f s\n",
              as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  cat(sprintf("  auxiliary parameter family: %s, count %d\n",
              paste(a$family, collapse = "/"), a$n))
  cat(sprintf("  indexed by: %s\n", paste(a$index, collapse = ", ")))
  r <- try(target_rmst_diff(f, nd), silent = TRUE)
  est <- if (inherits(r, "try-error")) NA_real_ else mean(r)
  cat(sprintf("  target RMST difference B - A: %s\n", format(est, digits = 4)))
  list(label = label, ok = TRUE, index = a$index, n_aux = a$n, est = est)
}

res <- list()

## 1. The registered proportional arm, for reference: study-indexed.
res$study_ph <- try_spec("registered PH: aux_by = c(.study)", quote(
  nma(net, likelihood = "mspline", n_knots = N_KNOTS, trt_effects = "fixed",
      regression = ~ x1:.trtclass, class_interactions = "common",
      aux_by = c(.study),
      prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
      prior_reg = normal(0, PRIOR_REG_SD), prior_aux = half_normal(PRIOR_AUX_SD),
      chains = 2, iter = 600, warmup = 300, refresh = 0, cores = 2,
      control = list(adapt_delta = 0.8))))

## 2. The candidate: an auxiliary regression with NO predictor. If multinma
##    honors it, every study and treatment shares one baseline shape, the
##    treatment effect is a constant log hazard ratio, and the pooling matches
##    the flexible arm exactly.
res$pooled_ph <- try_spec("candidate pooled PH: aux_regression = ~ 1", quote(
  nma(net, likelihood = "mspline", n_knots = N_KNOTS, trt_effects = "fixed",
      regression = ~ x1:.trtclass, class_interactions = "common",
      aux_regression = ~ 1,
      prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
      prior_reg = normal(0, PRIOR_REG_SD), prior_aux = half_normal(PRIOR_AUX_SD),
      prior_aux_reg = normal(0, PRIOR_AUX_REG_SD),
      chains = 2, iter = 600, warmup = 300, refresh = 0, cores = 2,
      control = list(adapt_delta = 0.8))))

## 2b. The second candidate, and the more promising one. `aux_by` takes columns
##     from the network data, so a column that is CONSTANT everywhere should
##     group every study and treatment into one baseline stratum: a single shared
##     spline shape, study intercepts retained, treatment effect a constant log
##     hazard ratio. That is precisely a proportional fit pooled the same way the
##     flexible arm is.
net_pooled <- build_net(transform_net(d), 32L)
res$const_ph <- try_spec("candidate pooled PH: aux_by = c(.pool)", quote(
  nma(net_pooled, likelihood = "mspline", n_knots = N_KNOTS, trt_effects = "fixed",
      regression = ~ x1:.trtclass, class_interactions = "common",
      aux_by = c(.pool),
      prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
      prior_reg = normal(0, PRIOR_REG_SD), prior_aux = half_normal(PRIOR_AUX_SD),
      chains = 2, iter = 600, warmup = 300, refresh = 0, cores = 2,
      control = list(adapt_delta = 0.8))))

## 3. The registered flexible arm, for reference: treatment-indexed and pooled.
res$flex <- try_spec("registered flexible: aux_regression = ~ .trt", quote(
  nma(net, likelihood = "mspline", n_knots = N_KNOTS, trt_effects = "fixed",
      regression = ~ x1:.trtclass, class_interactions = "common",
      aux_regression = ~ .trt,
      prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
      prior_reg = normal(0, PRIOR_REG_SD), prior_aux = half_normal(PRIOR_AUX_SD),
      prior_aux_reg = normal(0, PRIOR_AUX_REG_SD),
      chains = 2, iter = 600, warmup = 300, refresh = 0, cores = 2,
      control = list(adapt_delta = 0.8))))

cat("\n=== verdict ===\n")
usable <- Filter(function(z) isTRUE(z$ok) && z$n_aux > 0 &&
                   z$n_aux < res$flex$n_aux &&
                   !identical(sort(z$index), sort(res$flex$index)),
                 res[c("pooled_ph", "const_ph")])
for (nm in c("pooled_ph", "const_ph")) {
  z <- res[[nm]]
  cat(sprintf("  %-32s %s\n", z$label,
              if (!isTRUE(z$ok)) sprintf("REJECTED (%s)", z$err)
              else sprintf("%d aux parameters indexed by %s", z$n_aux,
                           paste(z$index, collapse = ", "))))
}
cat(sprintf("  %-32s %d aux parameters indexed by %s\n", res$flex$label,
            res$flex$n_aux, paste(res$flex$index, collapse = ", ")))
if (!length(usable)) {
  cat("\nNo pooling-matched proportional specification exists in multinma 0.9.1.\n")
  cat("The within-row confound is structural and must be DECLARED, not removed.\n")
} else {
  z <- usable[[1]]
  cat(sprintf("\nA pooling-matched proportional arm IS available: %s.\n", z$label))
  cat("The within-row contrast can be re-registered on it, removing the\n")
  cat("confound between proportionality and baseline pooling.\n")
  cat(sprintf("  its target RMST difference: %s\n", format(z$est, digits = 4)))
  cat(sprintf("  registered PH:              %s\n",
              format(res$study_ph$est, digits = 4)))
  cat(sprintf("  registered flexible:        %s\n", format(res$flex$est, digits = 4)))
}
res$usable <- names(usable)
saveRDS(res, "results/pooled-ph-probe.rds")
cat("\nwritten: results/pooled-ph-probe.rds\n")
