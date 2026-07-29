## ---------------------------------------------------------------------------
## E2, rebuilt after round 1 destroyed its premise.
##
## WHAT ROUND 1 FOUND, and it was right on all three counts.
##
##  (a) The curvature state as registered does not identify anything. "A single
##      aggregate study on a nonlinear link, whose arm mean depends on the
##      covariate variance" supplies ONE observed proportion for TWO unknown
##      target parameters, the main effect delta_3 and the interaction Gamma_3.
##      Depending on the variance does not create a second observation. The
##      information is rank one and a change in Gamma_3 can be offset by delta_3.
##
##  (b) The registered withdrawal rule compared `ecological` with `additivity`
##      using contraction alone, when E2 exists to compare `curvature` with
##      `ecological` using both summaries. It answered a different question, so
##      E2 could have failed completely without triggering it.
##
##  (c) None of E2 existed. The protocol claimed a sampler policy, refit rule and
##      failure handling were "registered in R/00-config.R alongside the rest";
##      that file held a link name, five labels and two counts. That is the same
##      registered-but-unimplementable defect the previous study in this
##      programme found five times, reappearing in round 1 of this one.
##
## WHAT REPLACES IT.
##
## The curvature route needs two aggregate studies at the SAME covariate mean and
## DIFFERENT covariate standard deviations. On an identity link the aggregate arm
## mean does not depend on the SD at all, so the two studies give identical
## equations and the state is rank deficient by construction; on a nonlinear link
## they differ, and the pair identifies (delta_3, Gamma_3). That is what makes
## `curvature` a nonlinear-only state, and the first version had the mechanism
## right and the design wrong.
##
## This arm is ASYMPTOTIC, not exact and not fitted. A logistic model is not
## conjugate, so there is no closed-form posterior; what is closed form is the
## Fisher information, and from it the large-sample posterior covariance and the
## large-sample sampling distribution of the posterior mode. Coverage below is
## therefore a normal approximation, and it is labeled as one everywhere. It is
## not a substitute for fitting, and a fitted arm remains future work rather than
## a registered promise.
##
##   Rscript R/06-nonlinear.R
## ---------------------------------------------------------------------------

source("R/01-exact.R")

## --- the logit design --------------------------------------------------------
## For a Bernoulli outcome with p = expit(eta), the Fisher information is
## X' diag(n p (1-p)) X. An IPD arm contributes its covariate distribution
## through quadrature; an AGGREGATE arm contributes ONE observation, the arm
## proportion, whose mean is the integral of expit over the study covariate law
## and whose variance is pbar(1-pbar)/n. That single row is why the state is rank
## one per study, and it is the point round 1 made.
expit <- function(z) 1 / (1 + exp(-z))

agg_p <- function(theta, b, i) {
  gh <- gh_rule(64)
  xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
  w  <- gh$w / sqrt(pi)
  S <- b$S; K <- b$K
  eta <- vapply(xs, function(x) sum(design_row(b$net, i, x, S, K) * theta), 0)
  sum(w * expit(eta))
}

## Gradient of the aggregate arm proportion, by the same quadrature. The chain
## rule through the integral is exact here because the integral is a finite sum.
agg_grad <- function(theta, b, i) {
  gh <- gh_rule(64)
  xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
  w  <- gh$w / sqrt(pi)
  S <- b$S; K <- b$K
  rows <- t(vapply(xs, function(x) design_row(b$net, i, x, S, K), numeric(b$p)))
  eta <- as.vector(rows %*% theta)
  p <- expit(eta)
  as.vector(crossprod(rows, w * p * (1 - p)))
}

## The information matrix on the logit scale, split by source exactly as the
## identity-link version is, so `source_share` reads the same object.
logit_info <- function(b, theta) {
  I_within <- matrix(0, b$p, b$p); I_between <- matrix(0, b$p, b$p)
  gh <- gh_rule(64)
  for (i in seq_len(nrow(b$net))) {
    if (as.logical(b$net$ipd[i])) {
      xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      for (j in seq_along(xs)) {
        r <- design_row(b$net, i, xs[j], b$S, b$K)
        pj <- expit(sum(r * theta))
        I_within <- I_within + b$net$n[i] * w[j] * pj * (1 - pj) * tcrossprod(r)
      }
    } else {
      ## ONE row, one observation: the arm proportion. Its information is
      ## g g' * n / (pbar (1 - pbar)), with g the gradient above.
      pb <- agg_p(theta, b, i)
      g <- agg_grad(theta, b, i)
      I_between <- I_between + (b$net$n[i] / (pb * (1 - pb))) * tcrossprod(g)
    }
  }
  list(within = I_within, between = I_between, total = I_within + I_between)
}

## --- the nonlinear states ----------------------------------------------------
## `curvature` is the corrected one: same covariate mean, different SDs.
build_state_nl <- function(state, spread, sd_ratio, total_n) {
  if (state != "curvature") return(build_state(state, spread, total_n))
  base <- list(
    list(ipd = TRUE, mu = 0.0, sd = 1, arms = list(PBO, e_vec(1))),
    list(ipd = TRUE, mu = 0.2, sd = 1, arms = list(PBO, e_vec(2))),
    list(ipd = TRUE, mu = 0.1, sd = 1, arms = list(PBO, e_vec(4))))
  target <- list(
    list(ipd = FALSE, mu = 0.1, sd = 1.0, arms = list(PBO, e_vec(3))),
    list(ipd = FALSE, mu = 0.1, sd = sd_ratio, arms = list(PBO, e_vec(3))))
  studies <- c(base, target)
  n_arms <- sum(vapply(studies, function(z) length(z$arms), 0L))
  studies <- lapply(studies, function(z) { z$n <- total_n / n_arms; z })
  net <- make_network(studies)
  for (k in seq_len(K_COMP)) {
    nm <- sprintf("c%d", k)
    if (is.null(net[[nm]])) net[[nm]] <- 0
  }
  net[, c("study", "ipd", "mu", "sd", "n", sprintf("c%d", seq_len(K_COMP)))]
}

## --- the rank claim round 1 made, checked rather than accepted ---------------
## On an identity link, two aggregate studies at the same covariate mean must
## leave the target unidentified whatever their SDs. On a logit link they must
## identify it as soon as the SDs differ. Both halves are checked, because the
## first version of this design asserted the mechanism and got it wrong.
check_curvature_rank <- function(total_n = 3000L) {
  out <- list()
  for (r in c(1.0, 2.0)) {
    net <- build_state_nl("curvature", spread = 0, sd_ratio = r, total_n)
    b <- build_design(net)
    gi <- gi_of(b)
    th <- theta_true(b)
    ## Identity link: the exact information already used by E1.
    I_id <- crossprod(b$X * sqrt(b$prec))
    ## Logit link, same network.
    I_lg <- logit_info(b, th)$total
    estimable <- function(I) {
      u <- numeric(nrow(I)); u[gi] <- 1
      sum(abs(I %*% (MASS::ginv(I) %*% u) - u)) < 1e-6
    }
    out[[as.character(r)]] <- list(
      sd_ratio = r,
      identity_estimable = estimable(I_id),
      logit_estimable = estimable(I_lg),
      identity_prec = max(1 / solve(I_id + diag(1e-8, nrow(I_id)))[gi, gi], 0),
      logit_prec = 1 / solve(I_lg + diag(1e-8, nrow(I_lg)))[gi, gi])
  }
  out
}

if (!interactive() && Sys.getenv("NL_NOMAIN") == "") {
  suppressPackageStartupMessages(library(MASS))
  cat("=== is the curvature state identified, and by what? ===\n")
  ck <- check_curvature_rank()
  for (nm in names(ck)) {
    z <- ck[[nm]]
    cat(sprintf("  SD ratio %.1f : identity link estimable %-5s | logit estimable %-5s\n",
                z$sd_ratio, z$identity_estimable, z$logit_estimable))
  }
  cat("\nExpected, and the reason curvature is a nonlinear-only state:\n")
  cat("  equal SDs   -> NOT estimable on either link (two identical equations)\n")
  cat("  unequal SDs -> NOT estimable on the identity link, estimable on logit\n")
  ## Round 2: the first version omitted the equal-SD IDENTITY half, so the state
  ## could have stopped being nonlinear-only while this still printed TRUE. All
  ## four cells of the two-by-two are required.
  ok <- !ck[["1"]]$logit_estimable && !ck[["1"]]$identity_estimable &&
        !ck[["2"]]$identity_estimable && ck[["2"]]$logit_estimable
  cat(sprintf("\nmechanism holds: %s\n", ok))
  saveRDS(list(check = ck, holds = ok), "results/curvature-rank.rds")
  cat("written: results/curvature-rank.rds\n")
}
