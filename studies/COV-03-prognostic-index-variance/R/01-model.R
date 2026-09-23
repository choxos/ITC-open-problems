## ---------------------------------------------------------------------------
## Data-generating mechanism, exact truth, and the five estimators.
##
## Source: the A-versus-C trial, individual data, x ~ N(0, ratio I).
## Target: the B-versus-C trial, arm counts and covariate means and SDs,
##         x ~ N(shift 1, I).
## Outcome: logit P(y = 1) = ALPHA + g sum(x) + delta_trt + EM_BETA x1 1[A, EM].
## The baseline is shared across trials, so the anchored comparison's common
## comparator behaves identically in both.
## ---------------------------------------------------------------------------

source("R/00-config.R")

GH <- statmod::gauss.quad.prob(120, dist = "normal")

## E[expit(a + Z)], Z ~ N(m, v), by 120-point Gauss-Hermite.
mean_expit <- function(a, m, v) sum(GH$weights * stats::plogis(a + m + sqrt(v) * GH$nodes))

## Marginal log OR of treatment t versus C in a population x ~ N(mu 1, s^2 I).
marg_logor <- function(cell, t, mu, s2) {
  g <- gcoef(cell$var_T)
  em <- if (t == "A" && cell$em == "present") EM_BETA else 0
  d <- if (t == "A") DELTA_A else DELTA_B
  ## Treated: the index plus em x1, still normal.
  m1 <- (g + em) * mu + (P - 1) * g * mu
  v1 <- ((g + em)^2 + (P - 1) * g^2) * s2
  m0 <- P * g * mu; v0 <- P * g^2 * s2
  stats::qlogis(mean_expit(ALPHA + d, m1, v1)) - stats::qlogis(mean_expit(ALPHA, m0, v0))
}

## The estimand: marginal log OR of B versus A in the target, and the anchored
## Bucher estimator's population-level bias, Delta_A(T) - Delta_A(S).
truth <- function(cell) marg_logor(cell, "B", cell$shift, 1) - marg_logor(cell, "A", cell$shift, 1)
bucher_bias <- function(cell) marg_logor(cell, "A", cell$shift, 1) - marg_logor(cell, "A", 0, cell$ratio)
unanchored_naive_bias <- function(cell) {
  g <- gcoef(cell$var_T)
  pA <- function(mu, s2) {
    em <- if (cell$em == "present") EM_BETA else 0
    mean_expit(ALPHA + DELTA_A, (g + em) * mu + (P - 1) * g * mu,
               ((g + em)^2 + (P - 1) * g^2) * s2)
  }
  stats::qlogis(pA(cell$shift, 1)) - stats::qlogis(pA(0, cell$ratio))
}

## Section 2's second-order formula, for the mechanism check on anchored,
## no-modification cells: Delta(F) ~= delta - V (expit(a + m + delta) - expit(a + m)).
second_order_bias <- function(cell) {
  g <- gcoef(cell$var_T)
  f <- function(m, v) DELTA_A - v * (stats::plogis(ALPHA + m + DELTA_A) - stats::plogis(ALPHA + m))
  f(P * g * cell$shift, cell$var_T) - f(0, cell$var_T * cell$ratio)
}

draw <- function(cell) {
  g <- gcoef(cell$var_T); em <- if (cell$em == "present") EM_BETA else 0
  n <- N_ARM
  xs <- matrix(stats::rnorm(2 * n * P, 0, sd_S(cell$ratio)), 2 * n, P)
  A <- rep(0:1, each = n)
  ys <- stats::rbinom(2 * n, 1, stats::plogis(ALPHA + g * rowSums(xs) + DELTA_A * A + em * xs[, 1] * A))
  xt <- matrix(stats::rnorm(2 * n * P, cell$shift, 1), 2 * n, P)
  B <- rep(0:1, each = n)
  yt <- stats::rbinom(2 * n, 1, stats::plogis(ALPHA + g * rowSums(xt) + DELTA_B * B))
  list(xs = xs, A = A, ys = ys,
       ## what the target publication reports
       mT = colMeans(xt), sT = apply(xt, 2, stats::sd),
       rB = c(sum(yt[B == 0]), sum(yt[B == 1])), nB = c(n, n))
}

## --- MAIC ------------------------------------------------------------------------
## Method of moments on centered balancing columns: minimize sum exp(Hc a).
maic_weights <- function(H, target) {
  Hc <- sweep(H, 2, target)
  f <- function(a) sum(exp(Hc %*% a))
  gr <- function(a) colSums(Hc * as.vector(exp(Hc %*% a)))
  o <- stats::optim(rep(0, ncol(Hc)), f, gr, method = "BFGS",
                    control = list(maxit = 500, reltol = 1e-14))
  w <- as.vector(exp(Hc %*% o$par))
  list(w = w, ok = o$convergence == 0 &&
         max(abs(colSums(Hc * w) / sum(w))) < 1e-4)
}

wlogit <- function(y, w) {
  p <- sum(w * y) / sum(w)
  v <- sum(w^2 * (y - p)^2) / sum(w)^2
  c(est = stats::qlogis(p), var = v / (p * (1 - p))^2)
}

ess <- function(w) sum(w)^2 / sum(w^2)

## --- G-computation ------------------------------------------------------------
## Logistic outcome model in the source, marginalized over a normal target law
## with the published means and SDs, delta-method variance.
gcomp <- function(X, y, trt, mT, sT, em, arm_only = FALSE) {
  Z <- matrix(stats::rnorm(G_POINTS * P), G_POINTS, P)
  Z <- sweep(sweep(Z, 2, sT, "*"), 2, mT, "+")
  if (arm_only) {
    D <- data.frame(y = y, X)
    f <- stats::glm(y ~ ., family = stats::binomial(), data = D)
    M <- cbind(1, Z)
    p <- stats::plogis(M %*% stats::coef(f))
    gp <- colMeans(M * as.vector(p * (1 - p)))
    pb <- mean(p)
    return(c(est = stats::qlogis(pb),
             var = drop(t(gp) %*% stats::vcov(f) %*% gp) / (pb * (1 - pb))^2))
  }
  D <- data.frame(y = y, X, A = trt)
  fo <- if (em) y ~ X1 + X2 + X3 + A + A:X1 else y ~ X1 + X2 + X3 + A
  f <- stats::glm(fo, family = stats::binomial(), data = D)
  mk <- function(a) {
    M <- cbind(1, Z, a)
    if (em) M <- cbind(M, a * Z[, 1])
    M
  }
  M1 <- mk(1); M0 <- mk(0); b <- stats::coef(f)
  p1 <- stats::plogis(M1 %*% b); p0 <- stats::plogis(M0 %*% b)
  q1 <- mean(p1); q0 <- mean(p0)
  g1 <- colMeans(M1 * as.vector(p1 * (1 - p1))) / (q1 * (1 - q1))
  g0 <- colMeans(M0 * as.vector(p0 * (1 - p0))) / (q0 * (1 - q0))
  gg <- g1 - g0
  c(est = stats::qlogis(q1) - stats::qlogis(q0), var = drop(t(gg) %*% stats::vcov(f) %*% gg))
}

## --- all methods on one replicate --------------------------------------------
fit_all <- function(cell, d) {
  em <- cell$em == "present"
  anchored <- cell$design == "anchored"
  X <- d$xs; colnames(X) <- paste0("X", 1:P)
  keep <- if (anchored) rep(TRUE, nrow(X)) else d$A == 1
  Xk <- X[keep, , drop = FALSE]; yk <- d$ys[keep]; Ak <- d$A[keep]

  ## The target side of the contrast.
  if (anchored) {
    r <- d$rB; n <- d$nB
    tB <- c(est = stats::qlogis(r[2] / n[2]) - stats::qlogis(r[1] / n[1]),
            var = 1 / r[1] + 1 / (n[1] - r[1]) + 1 / r[2] + 1 / (n[2] - r[2]))
  } else {
    r <- d$rB[2]; n <- d$nB[2]
    tB <- c(est = stats::qlogis(r / n), var = 1 / r + 1 / (n - r))
  }

  ## The source side, per method: Delta_A(T) if anchored, logit p_A(T) if not.
  src <- function(w) {
    if (anchored) {
      a1 <- wlogit(yk[Ak == 1], w[Ak == 1]); a0 <- wlogit(yk[Ak == 0], w[Ak == 0])
      c(est = a1[["est"]] - a0[["est"]], var = a1[["var"]] + a0[["var"]])
    } else wlogit(yk, w)
  }
  out <- list()
  out$unadjusted <- c(src(rep(1, nrow(Xk))), ess = nrow(Xk))

  mT2 <- d$mT^2 + d$sT^2
  w2 <- maic_weights(Xk, d$mT)
  out$maic_means <- if (w2$ok) c(src(w2$w), ess = ess(w2$w)) else NULL
  w3 <- maic_weights(cbind(Xk, Xk^2), c(d$mT, mT2))
  out$maic_meanvar <- if (w3$ok) c(src(w3$w), ess = ess(w3$w)) else NULL

  ## Index-variance matching: the prognostic index from a source outcome model.
  D <- data.frame(y = yk, Xk)
  if (anchored) {
    D$A <- Ak
    fo <- if (em) y ~ X1 + X2 + X3 + A + A:X1 else y ~ X1 + X2 + X3 + A
  } else fo <- y ~ X1 + X2 + X3
  gh <- stats::coef(stats::glm(fo, family = stats::binomial(), data = D))[paste0("X", 1:P)]
  u <- as.vector(Xk %*% gh)
  uT_mean <- sum(gh * d$mT); uT_m2 <- uT_mean^2 + sum(gh^2 * d$sT^2)
  w4 <- maic_weights(cbind(Xk, u^2), c(d$mT, uT_m2))
  out$maic_index <- if (w4$ok) c(src(w4$w), ess = ess(w4$w)) else NULL

  gc <- if (anchored) gcomp(Xk, yk, Ak, d$mT, d$sT, em)
        else gcomp(Xk, yk, NULL, d$mT, d$sT, em, arm_only = TRUE)
  out$gcomp <- c(gc, ess = NA)

  ## Contrast B versus A in the target.
  lapply(out, function(s) if (is.null(s)) NULL else
    c(est = tB[["est"]] - s[["est"]], se = sqrt(tB[["var"]] + s[["var"]]), ess = s[["ess"]]))
}
