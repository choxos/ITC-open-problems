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
## identity-link version is, so `source_survival` reads the same object.
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
  ## THE THIRD ARM IS HERE FOR THE REASON `build_state` GIVES, AND IT WAS MISSING.
  ##
  ## Round 4 established that every state's arm COUNT must match: with ten arms
  ## here and twelve elsewhere, an equal patient budget gives the shared
  ## background studies different per-arm sizes, so a state comparison changes the
  ## background network as well as the target's evidence route. That fix was made
  ## in `build_state` and never reached this function, so `curvature` ran at ten
  ## arms and 300 per arm while every other state ran at twelve and 250, and the
  ## protocol asserted they matched.
  ##
  ## Round 6 found it, independently, in both reviewers. The arm added is
  ## component 1 alone, the same arm `ecological` and `additivity` use, so the
  ## target designs stay structurally comparable and the component-3 interaction
  ## is still identified only through the between-study SD contrast at a common
  ## covariate mean. `check_curvature_rank` and `R/08-routes.R` verify that.
  target <- list(
    list(ipd = FALSE, mu = 0.1, sd = 1.0,
         arms = list(PBO, e_vec(1), e_vec(3))),
    list(ipd = FALSE, mu = 0.1, sd = sd_ratio,
         arms = list(PBO, e_vec(1), e_vec(3))))
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
## ROUND 5: THIS GUARD STILL PASSED FOR THE WRONG REASON.
##
## Round 4 found that equal-SD non-identifiability holds only when the two target
## studies share a baseline, and R/08-routes.R documented it. The guard itself was
## left reading `theta_true`, which sets every intercept equal, so it kept
## certifying a mechanism whose stated restriction it did not test. Documenting a
## defect is not fixing it, and a guard that passes under an unregistered
## restriction is worse than no guard because it looks like evidence.
##
## The guard now checks BOTH baseline configurations and requires the equal-SD
## claim to hold only where the restriction holds, which is what makes the
## restriction visible instead of silent.
check_curvature_rank <- function(total_n = 3000L, baseline_offset = 0) {
  out <- list()
  for (r in c(1.0, 2.0)) {
    net <- build_state_nl("curvature", spread = 0, sd_ratio = r, total_n)
    b <- build_design(net)
    gi <- gi_of(b)
    th <- theta_true(b)
    ## The second target study's baseline. Zero is the registered restriction that
    ## isolates the variance route; nonzero is the configuration round 4 found.
    if (baseline_offset != 0) th[5] <- th[5] + baseline_offset
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
  ck <- check_curvature_rank(baseline_offset = 0)
  ck_b <- check_curvature_rank(baseline_offset = 0.8)
  cat("  with EQUAL target-study baselines, the registered restriction:\n")
  for (nm in names(ck)) {
    z <- ck[[nm]]
    cat(sprintf("    SD ratio %.1f : identity %-5s | logit %-5s\n",
                z$sd_ratio, z$identity_estimable, z$logit_estimable))
  }
  cat("  with UNEQUAL baselines, which round 4 found the guard was hiding:\n")
  for (nm in names(ck_b)) {
    z <- ck_b[[nm]]
    cat(sprintf("    SD ratio %.1f : identity %-5s | logit %-5s\n",
                z$sd_ratio, z$identity_estimable, z$logit_estimable))
  }
  stopifnot(
    "the equal-SD claim does not hold even under its own restriction"
      = !ck[["1"]]$logit_estimable && !ck[["1"]]$identity_estimable,
    "unequal baselines do NOT identify the target, so round 4's finding is wrong"
      = ck_b[["1"]]$logit_estimable)
  cat("\nWhat this shows, stated with the restriction it needs:\n")
  cat("  UNDER EQUAL TARGET-STUDY BASELINES, equal SDs identify nothing on either\n")
  cat("  link, and unequal SDs identify the target on the logit link only. That is\n")
  cat("  what makes the variance contrast a nonlinear-only route.\n")
  cat("  WITHOUT that restriction the claim is false: unequal baselines identify\n")
  cat("  the target on the logit link with equal SDs, so the variance contrast is\n")
  cat("  one nonlinear route among several rather than the unique one. See\n")
  cat("  R/08-routes.R for the three routes this design can exhibit.\n")
  ## Round 2: the first version omitted the equal-SD IDENTITY half, so the state
  ## could have stopped being nonlinear-only while this still printed TRUE. All
  ## four cells of the two-by-two are required.
  ok <- !ck[["1"]]$logit_estimable && !ck[["1"]]$identity_estimable &&
        !ck[["2"]]$identity_estimable && ck[["2"]]$logit_estimable
  cat(sprintf("\nmechanism holds: %s\n", ok))

  ## THE GEOMETRY CLAIM IS NOW ASSERTED, NOT WRITTEN.
  ##
  ## The protocol says every state has the same arm count and the same per-arm
  ## size at a given budget. That sentence was true of `build_state` and false of
  ## `build_state_nl`, and it stayed false through five rounds of critique because
  ## nothing computed it. Both round-6 reviewers found it independently.
  ##
  ## The stated reason for matching counts is that the shared background studies
  ## must carry equal per-arm size, so the check is on BOTH the count and the
  ## size, and it stops the run rather than printing a warning.
  geo <- do.call(rbind, lapply(E2_STATES[E2_STATES != "own_ipd" | TRUE],
    function(s) {
      net <- build_state_nl(s, spread = 0.6, sd_ratio = 2.0, total_n = 3000L)
      data.frame(state = s, arms = length(net$n), per_arm = unique(net$n)[1],
                 distinct_sizes = length(unique(net$n)))
    }))
  cat("\n=== arm geometry across E2 states, computed ===\n")
  print(geo, row.names = FALSE)
  stopifnot(
    "states differ in arm count; the shared background would carry unequal
     per-arm sizes and a state comparison would change the background network"
      = length(unique(geo$arms)) == 1L,
    "states differ in per-arm size at a common budget"
      = length(unique(geo$per_arm)) == 1L,
    "some state has unequal per-arm sizes within itself"
      = all(geo$distinct_sizes == 1L))
  cat("geometry matches across states: TRUE\n")

  ## THE STUDY-BY-STUDY MAP, because "twelve arms" does not say whether the four
  ## constraints can hold at once. A reviewer asked how components 1, 2 and 4 can
  ## each have own-IPD identification while component 3 is aggregate-only, inside
  ## a fixed twelve-arm geometry with an identical shared background. The answer
  ## is a table rather than a paragraph: three two-arm IPD background studies use
  ## six arms, not nine, and the two target studies carry three arms each.
  arm_map <- do.call(rbind, lapply(E2_STATES, function(s) {
    net <- build_state_nl(s, spread = 0.6, sd_ratio = 2.0, total_n = 3000L)
    C <- C_of(net)
    do.call(rbind, lapply(sort(unique(net$study)), function(j) {
      rows <- which(net$study == j)
      labs <- vapply(rows, function(i) {
        k <- which(C[i, ] == 1)
        if (!length(k)) "PBO" else paste(k, collapse = "+")
      }, "")
      data.frame(state = s, study = j,
                 ipd = as.logical(net$ipd[rows[1]]),
                 role = if (j <= 3L) "background" else "target",
                 arms = paste(labs, collapse = ", "),
                 n_arms = length(rows),
                 carries_target = any(C[rows, TARGET] == 1),
                 stringsAsFactors = FALSE)
    }))
  }))
  cat("\n=== the study-by-study map ===\n")
  print(arm_map, row.names = FALSE)
  ## The four constraints, each asserted rather than asserted-in-prose.
  bg <- arm_map[arm_map$role == "background", ]
  tg <- arm_map[arm_map$role == "target", ]
  stopifnot(
    "a background study does not supply IPD, so components 1, 2 and 4 are not
     all in own_ipd" = all(bg$ipd),
    "a background study carries the target, so the target's state is not what
     the target studies alone determine" = !any(bg$carries_target),
    "the background is not identical across states" =
      length(unique(vapply(split(bg, bg$state), function(z)
        paste(z$arms, collapse = " | "), ""))) == 1L,
    "the aggregate-only states supply IPD on the target" =
      all(!tg$ipd[tg$state %in% c("ecological", "curvature")]),
    "every state does not have exactly two target studies" =
      all(table(tg$state) == 2L))
  cat("background identical across states, no background arm carries the",
      "target, aggregate-only states supply no target IPD: TRUE\n")

  ## Placebo-arm prevalence is checked in R/07-run-e2.R, where `theta_true_nl`
  ## is defined; it is a fact about the E2 truth rather than about the geometry.

  saveRDS(list(check = ck, check_unequal_baseline = ck_b, holds = ok,
               geometry = geo, arm_map = arm_map,
               equal_sd_needs_equal_baseline =
                 !ck[["1"]]$logit_estimable && ck_b[["1"]]$logit_estimable),
          "results/curvature-rank.rds")
  cat("written: results/curvature-rank.rds\n")
}
