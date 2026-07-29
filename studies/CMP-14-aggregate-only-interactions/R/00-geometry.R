## ---------------------------------------------------------------------------
## CMP-14, groundwork: WHERE does a component interaction's information come
## from, and can that be read off the design before any data exist?
##
## This file exists before the protocol, deliberately. CMP-14 asks for two
## summaries that do not exist in any implementation: prior-to-posterior
## contraction per interaction parameter, and an effective likelihood rank. Both
## are properties of the FISHER INFORMATION, so both can be computed from the
## design alone. If they cannot separate the information states the catalog
## names, there is no study here and the design changes; if they can, the study
## is about what they still miss.
##
## THE MODEL. K binary components. A treatment is a subset, written as an
## indicator c in {0,1}^K, so treatment "1+3" has c = (1,0,1,...). Additivity
## says its effect is c'delta and its effect modification is c'Gamma. For an
## individual with covariate x in study s on treatment t,
##
##   eta = alpha_s + c_t' delta + x * (beta + c_t' Gamma).
##
## THE FOUR SOURCES, which are different linear functionals of Gamma.
##
##   1. IPD WITHIN-STUDY. Individual x varies inside an arm, so the x-slope of
##      arm t is identified: beta + c_t' Gamma. Differencing two arms of the same
##      study gives (c_t - c_u)' Gamma. Randomization makes this causal.
##
##   2. AGGREGATE BETWEEN-STUDY. An aggregate arm reports a mean outcome, so on
##      an identity link the arm contrast within study s is
##      (c_t - c_u)'delta + mu_s (c_t - c_u)'Gamma. One study cannot separate the
##      two; several studies with different mu_s can. Nobody randomized mu_s, so
##      this is the confounded ecological route, and it is IDN-06's subject.
##
##   3. AGGREGATE CURVATURE. On a NONLINEAR link the aggregate mean is
##      E[g^{-1}(eta)] over the study's covariate law, which depends on the
##      variance of x and not only its mean. A single aggregate study therefore
##      carries some information about Gamma with no between-study contrast at
##      all. This is the state CMP-14 is named for, and it does not exist on an
##      identity link, which is why it cannot be studied in CMU-02's design.
##
##   4. ADDITIVITY. Gamma_k can be identified with no arm that isolates component
##      k, through c_{1,3} - c_1 = e_3. This route is INVISIBLE in the parameter
##      count and it is the one component methods are built on.
##
## What this file computes is the per-source Fisher information for each
## Gamma_k, so a claim about which state a parameter is in becomes arithmetic.
## ---------------------------------------------------------------------------

## --- a component network, described by its design ---------------------------
## `arms` is one row per study-arm: study, whether the study supplies IPD, the
## component indicator, and the study's covariate mean and SD.
make_network <- function(studies) {
  do.call(rbind, lapply(seq_along(studies), function(s) {
    z <- studies[[s]]
    do.call(rbind, lapply(z$arms, function(cc) data.frame(
      study = s, ipd = z$ipd, mu = z$mu, sd = z$sd, n = z$n,
      t(setNames(cc, paste0("c", seq_along(cc)))))))
  }))
}

K_of <- function(net) sum(grepl("^c\\d+$", names(net)))
C_of <- function(net) as.matrix(net[, sprintf("c%d", seq_len(K_of(net))), drop = FALSE])

## --- the information each source contributes, per source --------------------
##
## Everything below is the Fisher information for the FULL parameter vector
## theta = (alpha_1..alpha_S, delta_1..delta_K, beta, Gamma_1..Gamma_K) under a
## Gaussian outcome with unit residual variance. Working with the full vector
## rather than Gamma alone matters: a component interaction is weakly identified
## precisely when it is nearly collinear with a study intercept or a main effect,
## and profiling those out by hand is where that would be lost.
##
## Each source is returned separately so a parameter's state is decomposable
## rather than asserted.

design_row <- function(net, i, x, S, K) {
  ## The linear-predictor gradient for one individual: which entries of theta
  ## multiply what.
  r <- numeric(S + K + 1 + K)
  r[net$study[i]] <- 1                                   # study intercept
  cc <- as.numeric(C_of(net)[i, ])
  r[S + seq_len(K)] <- cc                                # main effects
  r[S + K + 1] <- x                                      # prognostic slope
  r[S + K + 1 + seq_len(K)] <- x * cc                    # interactions
  r
}

## SOURCE 1 and 2 on an identity link, exactly.
##
## For an IPD arm the individual covariates are drawn from the study law, so the
## arm contributes n * E[r r'] with x varying. For an aggregate arm only the arm
## MEAN is observed, so the arm contributes a single observation at x = mu_s with
## precision n (the mean of n observations has variance 1/n). That difference is
## the whole distinction between sources 1 and 2 and it is why an aggregate arm
## carries no within-study covariate information on an identity link.
info_identity <- function(net, ipd_only = FALSE, agd_only = FALSE) {
  S <- max(net$study); K <- K_of(net)
  p <- S + K + 1 + K
  I <- matrix(0, p, p)
  ## Gauss-Hermite over the study covariate law, so E[x^2] is exact rather than
  ## simulated. The interaction block needs the second moment, so a rule that
  ## only matches the mean would silently zero out source 1.
  gh <- gh_rule(32)
  for (i in seq_len(nrow(net))) {
    is_ipd <- as.logical(net$ipd[i])
    if (ipd_only && !is_ipd) next
    if (agd_only && is_ipd) next
    if (is_ipd) {
      xs <- net$mu[i] + sqrt(2) * net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      for (j in seq_along(xs)) {
        r <- design_row(net, i, xs[j], S, K)
        I <- I + net$n[i] * w[j] * tcrossprod(r)
      }
    } else {
      r <- design_row(net, i, net$mu[i], S, K)
      I <- I + net$n[i] * tcrossprod(r)
    }
  }
  I
}

gh_rule <- function(n) {
  i <- seq_len(n - 1); J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- sqrt(i / 2); J[cbind(i + 1, i)] <- sqrt(i / 2)
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = sqrt(pi) * (e$vectors[1, o])^2)
}

## --- the two summaries CMP-14 asks for --------------------------------------
##
## EFFECTIVE LIKELIHOOD RANK. Ordinary rank is binary and the failure this
## problem describes is continuous: a parameter can be nominally estimable while
## the likelihood's contribution along its direction is negligible against the
## prior's. The effective rank counts directions in which the likelihood is
## worth more than the prior, which is the question an analyst actually has.
##
## With prior precision P0 and likelihood information I, the eigenvalues of
## P0^{-1/2} I P0^{-1/2} are the likelihood-to-prior information ratios along the
## prior's own scale. `eff_rank` counts those above 1: directions where the data
## say more than the prior. `rank` is the classical count of nonzero ones.
eff_rank <- function(I, P0, thresh = 1) {
  R <- chol(P0)
  M <- backsolve(R, t(backsolve(R, I, transpose = TRUE)), transpose = TRUE)
  ev <- eigen((M + t(M)) / 2, symmetric = TRUE, only.values = TRUE)$values
  list(eigen = ev, eff_rank = sum(ev > thresh),
       rank = sum(ev > 1e-8 * max(1, max(ev))), n_par = nrow(I))
}

## PER-PARAMETER CONTRACTION. The ratio of posterior to prior standard deviation
## for one coordinate, which is what "prior-to-posterior contraction per
## interaction parameter" means. Marginal, not conditional: an analyst reads the
## marginal interval, so that is what the diagnostic has to describe.
contraction <- function(I, P0) {
  Sp <- solve(P0)                      # prior covariance
  Spost <- solve(I + P0)               # posterior covariance, Gaussian case
  sqrt(diag(Spost) / diag(Sp))
}

## Which coordinates are the interactions.
gamma_idx <- function(net) {
  S <- max(net$study); K <- K_of(net)
  S + K + 1 + seq_len(K)
}
