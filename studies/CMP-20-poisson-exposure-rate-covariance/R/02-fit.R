## ---------------------------------------------------------------------------
## The joint individual-plus-aggregate Poisson likelihood, fitted three ways, and
## the sensitivity calculation.
##
## Parameters theta = (mu1, mu2, b, dA, dB, gamma).
##
## Individual data (study 1):  y_i ~ Poisson(T_i exp(mu1 + b x_i + dA A_i + gamma x_i A_i))
## Aggregate arm j (study 2):  Y_j ~ Poisson(E_j * lambda_bar_j), with
##   lambda_bar_j = integral of exp(mu2 + dB 1[B] + k_j x) over the integration
##   law N(m_j, s_j^2), k_j = b + gamma 1[B], which in closed form is
##   exp(mu2 + dB 1[B] + k_j m_j + k_j^2 s_j^2 / 2).
##
## This is the structure multinma's aggregate Poisson likelihood has: total
## exposure times the mean modeled rate over the arm's covariate law. The closed
## form replaces quadrature, so integration error is exactly zero and probe P1
## of the design has nothing to measure.
##
## The three methods differ only in the integration law (m_j, s_j):
##   unweighted     N(reported mean, reported SD) in both arms, the status quo
##   weighted       N(m + c_j, 1): the exposure-weighted law, exact, supplied
##   borrowed       N(m + c_hat_j, 1), with c_hat_j the slope of log exposure on
##                  the covariate estimated in the individual-data study's arm of
##                  the same type and carried to the aggregate study
## ---------------------------------------------------------------------------

source("R/01-dgm.R")

agd_logrates <- function(th, m, s2) {
  k <- c(C = th[3], B = th[3] + th[6])
  c(C = th[2] + k[["C"]] * m[1] + k[["C"]]^2 * s2[1] / 2,
    B = th[2] + th[5] + k[["B"]] * m[2] + k[["B"]]^2 * s2[2] / 2)
}

negll <- function(th, d, m, s2) {
  X <- d$ipd
  eta <- th[1] + th[3] * X$x + th[4] * X$A + th[6] * X$x * X$A
  l1 <- sum(X$y * eta - X$T * exp(eta))
  lr <- agd_logrates(th, m, s2)
  l2 <- sum(d$agd$Y * lr - d$agd$E * exp(lr))
  -(l1 + l2)
}

## Analytic gradient and observed information.
grad_info <- function(th, d, m, s2) {
  X <- d$ipd
  eta <- th[1] + th[3] * X$x + th[4] * X$A + th[6] * X$x * X$A
  mu <- X$T * exp(eta); r <- X$y - mu
  Z <- cbind(1, 0, X$x, X$A, 0, X$x * X$A)
  g <- colSums(Z * r)
  I <- crossprod(Z * sqrt(mu))
  k <- c(th[3], th[3] + th[6]); isB <- c(0, 1)
  lr <- agd_logrates(th, m, s2)
  for (j in 1:2) {
    lam <- d$agd$E[j] * exp(lr[j]); rj <- d$agd$Y[j] - lam
    dk <- m[j] + k[j] * s2[j]
    gj <- c(0, 1, dk, 0, isB[j], isB[j] * dk)
    Hj <- matrix(0, 6, 6)
    Hj[3, 3] <- s2[j]
    if (isB[j] == 1) { Hj[3, 6] <- Hj[6, 3] <- Hj[6, 6] <- s2[j] }
    g <- g + rj * gj
    I <- I + lam * tcrossprod(gj) - rj * Hj
  }
  list(g = g, I = I)
}

## Start from the individual-data GLM and the crude aggregate log rates.
start_values <- function(d, m, s2) {
  X <- d$ipd
  f <- stats::glm(y ~ x * A, family = stats::poisson(), offset = log(T), data = X)
  cf <- stats::coef(f)
  b <- cf[["x"]]; g <- cf[["x:A"]]
  lrC <- log(d$agd$Y[1] / d$agd$E[1]); lrB <- log(d$agd$Y[2] / d$agd$E[2])
  mu2 <- lrC - b * m[1] - b^2 * s2[1] / 2
  kB <- b + g
  dB <- lrB - mu2 - kB * m[2] - kB^2 * s2[2] / 2
  c(cf[["(Intercept)"]], mu2, b, cf[["A"]], dB, g)
}

## Target estimand as a function of theta, with its gradient for the delta method.
## log RR_BC(target) = dB + gamma m_T + ((b + gamma)^2 - b^2) / 2 at unit variance.
estimand <- function(th) th[5] + th[6] * MEAN_TARGET + th[3] * th[6] + th[6]^2 / 2
estimand_grad <- function(th) c(0, 0, th[6], 0, 1, th[3] + th[6] + MEAN_TARGET)

fit_one <- function(d, m, s2) {
  st <- start_values(d, m, s2)
  o <- stats::optim(st, negll, function(th, d, m, s2) -grad_info(th, d, m, s2)$g,
                    d = d, m = m, s2 = s2, method = "BFGS",
                    control = list(maxit = 500, reltol = 1e-12))
  gi <- grad_info(o$par, d, m, s2)
  V <- tryCatch(solve(gi$I), error = function(e) NULL)
  if (is.null(V) || o$convergence != 0) return(NULL)
  gr <- estimand_grad(o$par)
  est <- estimand(o$par)
  se <- sqrt(drop(t(gr) %*% V %*% gr))
  ## Each aggregate arm's absolute marginal log rate in study 2's own
  ## population, reported so the cancellation is visible rather than inferred.
  k <- c(o$par[3], o$par[3] + o$par[6])
  arm_rate <- c(C = o$par[2] + k[1] * MEAN_AGD + k[1]^2 * SD_X^2 / 2,
                B = o$par[2] + o$par[5] + k[2] * MEAN_AGD + k[2]^2 * SD_X^2 / 2)
  list(est = est, se = se, par = o$par, arm_rate = arm_rate,
       max_grad = max(abs(gi$g)))
}

## Estimated exposure slope in an individual-data arm: regression of log T on x.
slope_log_T <- function(x, T) unname(stats::coef(stats::lm(log(T) ~ x))[2])

## The sensitivity calculation: the closed form evaluated over the analyst's
## declared correlation range, using the unweighted fit's own dispersion
## estimates and each aggregate arm's reported CV of exposure.
sens_interval <- function(f, cvT) {
  b <- f$par[3]; g <- f$par[6]
  cvC <- cv_from_k(b); cvB <- cv_from_k(b + g)
  grid <- seq(SENS_RHO_RANGE[1], SENS_RHO_RANGE[2], length.out = 61)
  rr <- expand.grid(r0 = grid, r1 = grid)
  rr <- rr[abs(rr$r1 - rr$r0) <= SENS_DRHO_BOUND + 1e-12, ]
  fB <- 1 + rr$r1 * cvT[2] * cvB; fC <- 1 + rr$r0 * cvT[1] * cvC
  ok <- fB > 0 & fC > 0
  B <- log(fB[ok]) - log(fC[ok])
  z <- stats::qnorm(0.975)
  c(lo = f$est - z * f$se - max(B), hi = f$est + z * f$se - min(B))
}

## Every method on one replicate.
fit_all <- function(d) {
  A <- d$agd
  m0 <- A$x_mean; s0 <- A$x_var
  out <- list()
  f1 <- fit_one(d, m0, s0)
  out$unweighted <- f1
  out$weighted <- fit_one(d, A$xw_mean, A$xw_var)
  X <- d$ipd
  ch <- c(slope_log_T(X$x[X$A == 0], X$T[X$A == 0]),
          slope_log_T(X$x[X$A == 1], X$T[X$A == 1]))
  ## Tilting N(m, s^2) by exp(c x) gives N(m + c s^2, s^2).
  out$borrowed <- fit_one(d, m0 + ch * s0, s0)
  if (!is.null(f1)) out$sens <- sens_interval(f1, d$agd$cv_T)
  out$c_hat <- ch
  out
}
