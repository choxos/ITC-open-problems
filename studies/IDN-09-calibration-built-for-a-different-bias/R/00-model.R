## ---------------------------------------------------------------------------
## IDN-09: a negative-control outcome for transport bias in an unanchored MAIC.
##
## Individual data on arm A (n = 500) in the source; the target publishes B's
## (n = 500) proportions for the primary outcome Y and a negative-control outcome
## N, and the mean of a measured covariate x. Unmeasured V ~ N(0, 1) in the
## source and N(SHIFT, 1) in the target.
##   Y: logit = -1 + 0.5 x + G_Y V + treatment (B: DELTA; A: BETA V)
##   N: logit = -1 + 0.5 x + G_N V, no treatment effect
## MAIC balances x only. The negative-control contrast (B minus A on N) estimates
## the bias the unmeasured V causes on N; calibration subtracts it from the primary
## contrast. It is right only if V biases N as it biases Y: the same prognostic
## strength and no modification of the treatment effect by V.
## Estimand: marginal log odds ratio of Y, B versus A, in the target.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261028L
N <- 500L; G_Y <- 0.5; DELTA <- -0.4; N_SIM <- 2000L
LEVELS <- list(g_n = c(0, 0.25, 0.5, 1), beta = c(0, 0.5), shift = c(0, 0.5))
build_grid <- function() { g <- expand.grid(g_n = LEVELS$g_n, beta = LEVELS$beta, shift = LEVELS$shift, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
GH <- statmod::gauss.quad.prob(40, "normal")
marg <- function(f, mx, mv) { s <- 0; for (i in seq_along(GH$nodes)) s <- s + GH$weights[i] * sum(GH$weights * f(mx + GH$nodes[i], mv + GH$nodes)); s }
truth <- function(cell) { pB <- marg(function(x, v) stats::plogis(-1 + 0.5 * x + G_Y * v + DELTA), 0.5, cell$shift)
  pA <- marg(function(x, v) stats::plogis(-1 + 0.5 * x + G_Y * v + cell$beta * v), 0.5, cell$shift); stats::qlogis(pB) - stats::qlogis(pA) }

draw <- function(cell) {
  x <- stats::rnorm(N); v <- stats::rnorm(N)
  yA <- stats::rbinom(N, 1, stats::plogis(-1 + 0.5 * x + G_Y * v + cell$beta * v)); nA <- stats::rbinom(N, 1, stats::plogis(-1 + 0.5 * x + cell$g_n * v))
  xb <- stats::rnorm(N, 0.5); vb <- stats::rnorm(N, cell$shift)
  yB <- stats::rbinom(N, 1, stats::plogis(-1 + 0.5 * xb + G_Y * vb + DELTA)); nB <- stats::rbinom(N, 1, stats::plogis(-1 + 0.5 * xb + cell$g_n * vb))
  list(x = x, yA = yA, nA = nA, mx = mean(xb), pyB = mean(yB), pnB = mean(nB))
}
fit_all <- function(d) {
  xc <- d$x - d$mx; a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20))$root; w <- exp(a * xc); w <- w / sum(w)
  lo <- function(p) stats::qlogis(p); vy <- function(z, pB) { p <- sum(w * z); sum(w^2 * (z - p)^2) / (p * (1 - p))^2 + 1 / (N * pB * (1 - pB)) }
  cy <- lo(d$pyB) - lo(sum(w * d$yA)); cn <- lo(d$pnB) - lo(sum(w * d$nA))
  sy <- sqrt(vy(d$yA, d$pyB)); sn <- sqrt(vy(d$nA, d$pnB))
  c(naive = cy, se_naive = sy, control = cn, se_control = sn, calibrated = cy - cn, se_cal = sqrt(sy^2 + sn^2))
}
