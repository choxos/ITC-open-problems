## ---------------------------------------------------------------------------
## IDN-10: the transported control-arm check as a classifier.
##
## Anchored MAIC: individual data on A versus C in the source, arm counts and
## covariate means on B versus C in the target. The check compares the
## MAIC-transported control-arm risk with the target's observed control-arm risk.
## Two unmeasured covariates differ between populations:
##   u, prognostic only: moves the control arm, cancels in the anchored contrast;
##   v, modifies A's effect only: leaves the control arm alone, biases the contrast.
## So the check alarms on the failure that does not bias the answer and passes the
## one that does (DESIGN.md section 2, rows two and three).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261009L
N_SRC <- 300L; ALPHA <- stats::qlogis(0.3); GX <- 0.5; GU <- 0.6; BV <- 0.6
D_A <- -0.6; D_B <- -0.4; BX <- 0.3; MX_T <- 0.5
N_SIM <- 1000L
LEVELS <- list(mu_u = c(0, 0.3, 0.6), mu_v = c(0, 0.3, 0.6), n_t = c(200L, 500L))

build_grid <- function() {
  g <- expand.grid(mu_u = LEVELS$mu_u, mu_v = LEVELS$mu_v, n_t = LEVELS$n_t, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

eta <- function(x, u, v, t) {
  d <- switch(t, C = 0, A = D_A + BX * x + BV * v, B = D_B + BX * x)
  ALPHA + GX * x + GU * u + d
}

## Truths by Monte Carlo over the target law: anchored B versus A log OR, and the
## control-arm risk.
truths <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(31)
  x <- stats::rnorm(1e6, MX_T); u <- stats::rnorm(1e6, cell$mu_u); v <- stats::rnorm(1e6, cell$mu_v)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  pr <- function(t) mean(stats::plogis(eta(x, u, v, t)))
  c(log_or_BA = stats::qlogis(pr("B")) - stats::qlogis(pr("A")), p_C = pr("C"))
}

draw <- function(cell) {
  n <- N_SRC; x <- stats::rnorm(2 * n); u <- stats::rnorm(2 * n); v <- stats::rnorm(2 * n)
  A <- rep(0:1, each = n)
  y <- stats::rbinom(2 * n, 1, stats::plogis(ifelse(A == 1, eta(x, u, v, "A"), eta(x, u, v, "C"))))
  m <- cell$n_t; xt <- stats::rnorm(2 * m, MX_T); ut <- stats::rnorm(2 * m, cell$mu_u); vt <- stats::rnorm(2 * m, cell$mu_v)
  B <- rep(0:1, each = m)
  yt <- stats::rbinom(2 * m, 1, stats::plogis(ifelse(B == 1, eta(xt, ut, vt, "B"), eta(xt, ut, vt, "C"))))
  list(x = x, A = A, y = y, mx = mean(xt), rC = sum(yt[B == 0]), rB = sum(yt[B == 1]), m = m)
}

fit <- function(d) {
  xc <- d$x - d$mx
  a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20), tol = 1e-12)$root
  w <- exp(a * xc)
  wp <- function(k) { p <- sum(w[d$A == k] * d$y[d$A == k]) / sum(w[d$A == k])
    v <- sum(w[d$A == k]^2 * (d$y[d$A == k] - p)^2) / sum(w[d$A == k])^2
    c(l = stats::qlogis(p), v = v / (p * (1 - p))^2) }
  a1 <- wp(1); c0 <- wp(0)
  pC <- d$rC / d$m; pB <- d$rB / d$m
  lC <- stats::qlogis(pC); vC <- 1 / d$rC + 1 / (d$m - d$rC); vB <- 1 / d$rB + 1 / (d$m - d$rB)
  est <- (stats::qlogis(pB) - lC) - (a1[["l"]] - c0[["l"]])
  se <- sqrt(vB + vC + a1[["v"]] + c0[["v"]])
  ## the check: transported control arm against the observed one, on log odds
  D <- c0[["l"]] - lC; sD <- sqrt(c0[["v"]] + vC)
  c(est = est, se = se, check_D = D, check_z = D / sD, pC_transported = stats::plogis(c0[["l"]]))
}
