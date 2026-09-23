## ---------------------------------------------------------------------------
## IDN-07: calibrating a held-out-trial falsification rule.
##
## One individual-data trial of B versus C (300 per arm, x ~ N(0, 1)) and K = 5
## aggregate trials of B versus C (200 per arm, x ~ N(mu_k, 1), mu_k = s * MU0).
## Continuous outcome y = 0.5 x + A (DELTA + BETA x + u_k + v 1[k = held]) + e,
## u_k ~ N(0, tau^2) between-trial heterogeneity, v the transport violation in
## the withheld trial. Aggregate trials report the mean difference, its SE and
## the covariate mean.
##
## Prediction for the withheld trial: STC from the individual data at the trial's
## reported covariate mean. Discrepancy D = prediction - observed. Heterogeneity
## tau^2 is estimated (DerSimonian-Laird) from the other trials' residuals.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261017L
N_IPD <- 300L; N_AGD <- 200L; DELTA <- -0.3; BETA <- 0.3; MU0 <- c(-0.4, 0, 0.4, 0.8, 1.2)
N_SIM <- 2000L; DEC_T <- 0
LEVELS <- list(v = c(0, 0.15, 0.3), tau = c(0, 0.1), s = c(1, 2), held = c(3L, 5L))
build_grid <- function() {
  g <- expand.grid(v = LEVELS$v, tau = LEVELS$tau, s = LEVELS$s, held = LEVELS$held, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

draw <- function(cell) {
  x <- stats::rnorm(2 * N_IPD); A <- rep(0:1, each = N_IPD)
  ipd <- data.frame(x = x, A = A, y = 0.5 * x + A * (DELTA + BETA * x) + stats::rnorm(2 * N_IPD))
  mu <- cell$s * MU0; u <- stats::rnorm(length(mu), 0, cell$tau)
  agd <- do.call(rbind, lapply(seq_along(mu), function(k) {
    xk <- stats::rnorm(2 * N_AGD, mu[k]); Ak <- rep(0:1, each = N_AGD)
    yk <- 0.5 * xk + Ak * (DELTA + BETA * xk + u[k] + cell$v * (k == cell$held)) + stats::rnorm(2 * N_AGD)
    d1 <- yk[Ak == 1]; d0 <- yk[Ak == 0]
    data.frame(k = k, xbar = mean(xk), est = mean(d1) - mean(d0), se = sqrt(stats::var(d1) / N_AGD + stats::var(d0) / N_AGD),
               truth_k = DELTA + BETA * mu[k] + u[k] + cell$v * (k == cell$held))
  }))
  list(ipd = ipd, agd = agd)
}

dl_tau2 <- function(r, v) { w <- 1 / v; m <- sum(w * r) / sum(w); Q <- sum(w * (r - m)^2)
  max(0, (Q - (length(r) - 1)) / (sum(w) - sum(w^2) / sum(w))) }

fit_all <- function(cell, dd) {
  f <- stats::lm(y ~ A * x, data = dd$ipd); b <- stats::coef(f)[c("A", "A:x")]; V <- stats::vcov(f)[c("A", "A:x"), c("A", "A:x")]
  pred <- function(m) c(sum(b * c(1, m)), drop(t(c(1, m)) %*% V %*% c(1, m)))
  a <- dd$agd; h <- cell$held; o <- a[a$k != h, ]
  po <- t(sapply(o$xbar, pred)); r <- o$est - po[, 1]; tau2 <- dl_tau2(r, po[, 2] + o$se^2)
  ph <- pred(a$xbar[h]); obs <- a$est[h]; vo <- a$se[h]^2
  pw <- pred(mean(o$xbar))                                # target implied by the reduced network
  D <- ph[1] - obs; Dw <- pw[1] - obs
  c(D = D, z_full = D / sqrt(ph[2] + vo + tau2), z_naive = D / sqrt(ph[2] + vo),
    z_wrong_target = Dw / sqrt(pw[2] + vo + tau2), decision_flip = as.numeric(sign(ph[1] - DEC_T) != sign(obs - DEC_T)),
    v_pred = ph[2], v_obs = vo, tau2 = tau2, D_wrong = Dw)
}
