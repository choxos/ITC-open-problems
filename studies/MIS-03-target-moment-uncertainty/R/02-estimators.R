## The four intervals under comparison.
##
## Every one of them uses the SAME point estimate. That is the design: the
## question is not which estimator is less biased, it is what a reported interval
## omits. Comparing methods that also differ in their point estimate would
## confound the two.
##
## Notation. The source contributes nS participants with covariates giving
## h_i = (X_i, X_i^2), treatment indicator A_i and outcome Y_i. Write
##
##   w_i(lambda) = exp(lambda' h_i)
##
## and let m_T be the six reported target moments. MAIC solves
##
##   sum_i w_i (h_i - m_T) = 0                                            (1)
##
## for lambda, which makes the weighted source covariate moments equal the
## reported target moments. The transported A vs C effect is the difference of
## weighted arm means, and the anchored estimate subtracts the target trial's own
## B vs C effect.
##
## Stacking (1) with the two weighted arm-mean equations gives an M-estimator in
## psi = (lambda, mu_A, mu_C), whose sandwich variance is the status quo interval.
## What that sandwich conditions on is m_T. The three remaining methods differ
## only in what they add for the fact that m_T is itself an estimate.

## Solve (1). Convex in lambda; the equivalent objective
## sum_i exp(lambda'(h_i - m_T)) has gradient exp(-lambda'm_T) times the left
## side of (1) and therefore the same root, and is the standard MAIC objective.
fit_weights <- function(h, m_T, maxit = 500L) {
  hc <- sweep(h, 2, m_T, "-")
  obj <- function(l) {
    z <- as.vector(hc %*% l)
    ## Shift before exponentiating. Without this a poor-overlap replicate
    ## overflows to Inf and the optimizer walks off rather than failing loudly.
    mz <- max(z)
    mz + log(sum(exp(z - mz)))
  }
  gr <- function(l) {
    z <- as.vector(hc %*% l)
    p <- exp(z - max(z))
    as.vector(crossprod(hc, p) / sum(p))
  }
  o <- stats::optim(rep(0, ncol(h)), obj, gr, method = "BFGS",
                    control = list(maxit = maxit, reltol = 1e-12))
  z <- as.vector(hc %*% o$par)
  w <- exp(z - max(z))
  w <- w / mean(w)                      # scale is arbitrary; see note below
  list(lambda = o$par, w = w, conv = o$convergence,
       ## Worst standardized imbalance that remains. The estimating equation is
       ## solved when this is zero; it is reported so a replicate that did not
       ## actually balance cannot pass as one that did.
       max_imbalance = max(abs(colSums(w * hc)) / sum(w) /
                             pmax(apply(h, 2, stats::sd), 1e-8)),
       ess = sum(w)^2 / sum(w^2))
}

## Rescaling w by a positive constant leaves everything below unchanged: it
## multiplies the score by that constant, so A and C scale by it and B by its
## square, and both A^{-1} B A^{-T} and A^{-1} C are invariant. Normalizing to
## mean one is therefore free and keeps the matrices well conditioned.

## The stacked M-estimator: matrices A, B, and the derivative of the score with
## respect to the reported target moments.
##
## For the calibration block, d/dlambda' of w_i (h_i - m_T) is w_i (h_i - m_T) h_i',
## and d/dm_T' of the same is -w_i I. For the arm-mean blocks,
## d/dlambda' of 1(A_i) w_i (Y_i - mu_A) is 1(A_i) w_i (Y_i - mu_A) h_i', and
## d/dmu_A is -1(A_i) w_i. The target moments do not appear in the arm-mean
## equations, so their rows of the m_T derivative are zero.
sandwich_parts <- function(h, A, Y, w, m_T) {
  n <- nrow(h); p <- ncol(h)
  muA <- sum(w * A * Y) / sum(w * A)
  muC <- sum(w * (1 - A) * Y) / sum(w * (1 - A))

  hc <- sweep(h, 2, m_T, "-")
  u <- cbind(w * hc, A * w * (Y - muA), (1 - A) * w * (Y - muC))

  Amat <- matrix(0, p + 2L, p + 2L)
  Amat[1:p, 1:p]      <- crossprod(w * hc, h) / n
  Amat[p + 1L, 1:p]   <- crossprod(A * w * (Y - muA), h) / n
  Amat[p + 2L, 1:p]   <- crossprod((1 - A) * w * (Y - muC), h) / n
  Amat[p + 1L, p + 1L] <- -sum(A * w) / n
  Amat[p + 2L, p + 2L] <- -sum((1 - A) * w) / n

  Cmat <- matrix(0, p + 2L, p)
  Cmat[1:p, 1:p] <- -diag(mean(w), p)

  list(A = Amat, B = crossprod(u) / n, C = Cmat, n = n,
       theta_AC = muA - muC, muA = muA, muC = muC)
}

## Reconstruct the covariance of h(X) in the target from the reported means and
## SDs plus a borrowed correlation matrix, under a multivariate normal model.
##
## For X multivariate normal with covariance S and means mu,
##   Cov(Xj, Xk)     = S_jk
##   Cov(Xj, Xk^2)   = 2 mu_k S_jk
##   Cov(Xj^2, Xk^2) = 2 S_jk^2 + 4 mu_j mu_k S_jk
##
## Nothing in a published baseline table identifies the correlations, so they
## have to come from somewhere; borrowing the source correlation is what an
## analyst would do, and the study varies whether that borrowing is correct.
Omega_normal <- function(mu, sd, R) {
  S <- diag(sd) %*% R %*% diag(sd)
  p <- length(mu)
  O <- matrix(0, 2 * p, 2 * p)
  O[1:p, 1:p] <- S
  for (j in 1:p) for (k in 1:p) {
    O[j, p + k] <- 2 * mu[k] * S[j, k]
    O[p + j, k] <- 2 * mu[j] * S[j, k]
    O[p + j, p + k] <- 2 * S[j, k]^2 + 4 * mu[j] * mu[k] * S[j, k]
  }
  O
}

## All four intervals for one replicate.
##
## `R_borrow` is the correlation matrix the analyst plugs in for the normal
## reconstruction, which is the source correlation in this study.
estimate_all <- function(rep_data, R_borrow, level = 0.95, conv = CONVERGENCE) {
  s <- rep_data$source
  tr <- rep_data$target_reported
  p <- ncol(s$h)
  z <- stats::qnorm(1 - (1 - level) / 2)

  fail <- function(why) structure(list(), class = "estim_fail", why = why)

  fw <- fit_weights(s$h, tr$m)
  ## Convergence is judged on whether the estimating equation was actually
  ## solved, not only on whether the optimizer said it stopped. A BFGS run can
  ## report success at a point where the moments are still materially unbalanced
  ## under poor overlap, and that replicate is not a MAIC fit.
  if (fw$conv != conv$optim_code) return(fail("optimizer"))
  if (!is.finite(fw$max_imbalance) || fw$max_imbalance > conv$max_imbalance)
    return(fail("imbalance"))
  if (!is.finite(fw$ess) || fw$ess < conv$min_ess) return(fail("ess"))

  sp <- sandwich_parts(s$h, s$A, s$Y, fw$w, tr$m)

  Ainv <- tryCatch(solve(sp$A), error = function(e) NULL)
  if (is.null(Ainv)) return(fail("singular-jacobian"))

  cvec <- c(rep(0, p), 1, -1)                       # picks mu_A - mu_C
  aI <- as.vector(crossprod(cvec, Ainv))            # c' A^{-1}

  ## Source contribution: weight estimation and outcome variance, conditional on
  ## the reported target moments.
  V_S <- as.numeric(aI %*% sp$B %*% aI) / sp$n

  ## Sensitivity of the transported effect to the reported moments, by the
  ## implicit function theorem applied to the stacked score.
  J <- as.vector(-aI %*% sp$C)                      # length p

  theta <- sp$theta_AC - tr$theta_BC

  ## The covariance of the six reported moments under each information regime.
  ## Divided by nT because they are sample means of h(X) over nT participants.
  O_norm <- Omega_normal(tr$mean, tr$sd, R_borrow)
  V_norm <- as.numeric(J %*% O_norm %*% J) / tr$nT
  V_rep  <- as.numeric(J %*% rep_data$hidden$Omega_hh %*% J) / tr$nT

  ## Full joint: the moments and the B vs C effect come from the same people, so
  ## their covariance enters with the gradient (J, -1). This replaces rather than
  ## adds to the target arm-mean variance, which it already contains.
  g <- c(J, -1)
  V_joint <- as.numeric(g %*% rep_data$hidden$Omega_T %*% g) / tr$nT

  mk <- function(name, v) {
    se <- if (is.finite(v) && v > 0) sqrt(v) else NA_real_
    data.frame(method = name, est = theta, se = se,
               lower = theta - z * se, upper = theta + z * se,
               ess = fw$ess, max_imbalance = fw$max_imbalance,
               stringsAsFactors = FALSE)
  }

  rbind(
    mk("target-fixed",   V_S + tr$var_BC),
    mk("normal-recon",   V_S + V_norm + tr$var_BC),
    mk("reported-cov",   V_S + V_rep  + tr$var_BC),
    mk("joint-score",    V_S + V_joint)
  )
}
