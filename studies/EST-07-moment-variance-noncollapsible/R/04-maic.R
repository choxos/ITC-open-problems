## ---------------------------------------------------------------------------
## MAIC weights, the sandwich, and THE GRADIENT THE PUBLISHED PORTS PROPAGATE.
##
## `estimator_gradient` is the quantity this study exists to compare against the
## estimand gradient in R/02-gradient.R. It is obtained the way MIS-03 obtains
## it and the way every target-summary variance estimator obtains it: by the
## implicit function theorem on the stacked estimating equation,
##
##   J_estimator = -c' A^{-1} C,
##
## where A is the Jacobian of the stacked score and C its derivative with
## respect to the reported moments. Under an identity link this equals beta_EM
## and equals the estimand gradient. Under a curved link it equals neither, and
## the size of that discrepancy is the study's central quantity.
##
##   source("R/04-maic.R")
## ---------------------------------------------------------------------------

source("R/03-sample.R")

CONVERGENCE <- list(optim_code = 0L, max_imbalance = 1e-4, min_ess = 10)

## Method-of-moments weights: exp(h'a) chosen so the weighted source moments
## equal the reported target moments. The dual is convex, so a failure to
## converge is a statement about overlap rather than about the optimizer, and it
## is recorded as such rather than retried.
fit_weights <- function(h, m_T, maxit = 500L) {
  hc <- sweep(h, 2, m_T, "-")
  obj <- function(a) log(mean(exp(as.vector(hc %*% a))))
  gr  <- function(a) {
    w <- exp(as.vector(hc %*% a)); w <- w / sum(w)
    as.vector(crossprod(hc, w))
  }
  o <- stats::optim(rep(0, ncol(h)), obj, gr, method = "BFGS",
                    control = list(maxit = maxit))
  w <- exp(as.vector(hc %*% o$par))
  wn <- w / sum(w)
  list(w = w, a = o$par, conv = o$convergence,
       max_imbalance = max(abs(as.vector(crossprod(hc, wn)))),
       ess = sum(w)^2 / sum(w^2))
}

## The stacked score's Jacobian and its derivative in the reported moments. The
## structure follows MIS-03 exactly, because a port that reorganizes the algebra
## cannot be checked against the case where the answer is known.
sandwich_parts <- function(h, A, Y, w, m_T, link) {
  lf <- link_fns(link)
  n <- nrow(h); p <- ncol(h)
  ## Weighted arm means, then the LINK applied after averaging, which is what
  ## makes the estimand marginal and non-collapsible.
  muA <- sum(w * A * Y) / sum(w * A)
  muC <- sum(w * (1 - A) * Y) / sum(w * (1 - A))

  hc <- sweep(h, 2, m_T, "-")
  u <- cbind(w * hc, A * w * (Y - muA), (1 - A) * w * (Y - muC))

  Amat <- matrix(0, p + 2L, p + 2L)
  Amat[1:p, 1:p]       <- crossprod(w * hc, h) / n
  Amat[p + 1L, 1:p]    <- crossprod(A * w * (Y - muA), h) / n
  Amat[p + 2L, 1:p]    <- crossprod((1 - A) * w * (Y - muC), h) / n
  Amat[p + 1L, p + 1L] <- -sum(A * w) / n
  Amat[p + 2L, p + 2L] <- -sum((1 - A) * w) / n

  Cmat <- matrix(0, p + 2L, p)
  Cmat[1:p, 1:p] <- -diag(mean(w), p)

  ## The contrast vector picks the ARM MEANS, and the delta-method row that maps
  ## them to the reported scale is g'(muA) and -g'(muC). Under the identity link
  ## those are 1 and -1 and the vector reduces to MIS-03's c(0,...,0,1,-1); under
  ## a curved link they do not, and that is the first place curvature enters the
  ## estimator's own gradient.
  dg <- switch(link,
    identity = c(1, 1),
    logit    = c(1 / (muA * (1 - muA)), 1 / (muC * (1 - muC))),
    cloglog  = c(1 / (muA * log(muA)),  1 / (muC * log(muC))),
    stop("unregistered link: ", link))

  list(A = Amat, B = crossprod(u) / n, C = Cmat, n = n,
       cvec = c(rep(0, p), dg[1], -dg[2]),
       theta_AC = lf$g(muA) - lf$g(muC), muA = muA, muC = muC)
}

## THE ESTIMATOR GRADIENT. This is what the ports propagate.
estimator_gradient <- function(rep_data, link) {
  s <- rep_data$source; tr <- rep_data$target_reported
  fw <- fit_weights(s$h, tr$m)
  if (fw$conv != CONVERGENCE$optim_code ||
      !is.finite(fw$max_imbalance) || fw$max_imbalance > CONVERGENCE$max_imbalance)
    return(list(ok = FALSE, why = "weights"))
  sp <- sandwich_parts(s$h, s$A, s$Y, fw$w, tr$m, link)
  Ainv <- tryCatch(solve(sp$A), error = function(e) NULL)
  if (is.null(Ainv)) return(list(ok = FALSE, why = "singular-jacobian"))
  aI <- as.vector(crossprod(sp$cvec, Ainv))
  list(ok = TRUE, J = as.vector(-aI %*% sp$C), ess = fw$ess,
       theta_AC = sp$theta_AC, parts = sp, Ainv = Ainv, w = fw$w)
}

## Reconstruct the covariance of h(X) in the target from the reported means and
## SDs plus an assumed correlation, under a multivariate normal model. Taken
## from MIS-03 unchanged: the reconstruction an analyst performs does not become
## more sophisticated because the link is curved, and changing it here would
## confound the correlation arm with a modeling improvement.
## `binary` marks covariates whose square was dropped from h, so the returned
## covariance matches the moment vector the estimator actually uses. Building the
## full 2p by 2p matrix and subsetting is valid because the reconstruction is
## pairwise.
Omega_normal <- function(mu, sd, R, binary = rep(FALSE, length(mu))) {
  S <- diag(sd) %*% R %*% diag(sd)
  p <- length(mu)
  O <- matrix(0, 2 * p, 2 * p)
  O[1:p, 1:p] <- S
  for (j in 1:p) for (k in 1:p) {
    O[j, p + k] <- 2 * mu[k] * S[j, k]
    O[p + j, k] <- 2 * mu[j] * S[j, k]
    O[p + j, p + k] <- 2 * S[j, k]^2 + 4 * mu[j] * mu[k] * S[j, k]
  }
  keep <- c(rep(TRUE, p), !binary)
  O[keep, keep, drop = FALSE]
}
