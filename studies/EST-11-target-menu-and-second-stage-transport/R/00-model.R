## ---------------------------------------------------------------------------
## EST-11: scoring methods against their own implicit target or a declared
## decision target, across a menu of targets, with correct or misspecified
## second-stage transport.
##
## Individual data on A versus C in S (x ~ N(0, 1)); aggregate B versus C in T_B
## (x ~ N(0.6, 1), mean and SD published); 300 per arm. Binary outcome
##   logit p = -0.5 + 0.5 x + a_A (-0.5 + 0.3 x) + a_B (-0.7 + G_B x),
## G_B = 0.3 (B shares A's modification) or 0.6 (it does not).
## Estimand: marginal log OR of B versus A in a declared target F_D, x ~ N(m_D, 1),
## m_D in {0, 0.6, 1.2}. Methods (anchored):
##   bucher      unadjusted; native target mixes S (for A-C) and T_B (for B-C)
##   maic        A-C reweighted to T_B; native target T_B
##   stc         A-C by G-computation over T_B; native target T_B
##   stc_2stage  both contrasts carried to F_D, B's modification assumed equal to A's;
##               native target F_D
## The mismatch term Delta(native) - Delta(F_D) is computed exactly; only the
## estimation term needs replicates.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261206L; N_ARM <- 300L; N_SIM <- 1000L; M_B <- 0.6
build_grid <- function() { g <- expand.grid(m_d = c(0, 0.6, 1.2), g_b = c(0.3, 0.6), KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
GH <- statmod::gauss.quad.prob(40, "normal")
mlo <- function(eta1, eta0, m) { x <- GH$nodes + m; w <- GH$weights; stats::qlogis(sum(w * stats::plogis(eta1(x)))) - stats::qlogis(sum(w * stats::plogis(eta0(x)))) }
e0 <- function(x) -0.5 + 0.5 * x
dAC <- function(m) mlo(function(x) e0(x) - 0.5 + 0.3 * x, e0, m)
dBC <- function(m, g_b) mlo(function(x) e0(x) - 0.7 + g_b * x, e0, m)
Delta <- function(m, g_b) dBC(m, g_b) - dAC(m)
native_truth <- function(method, cell) switch(method, bucher = dBC(M_B, cell$g_b) - dAC(0), maic = , stc = Delta(M_B, cell$g_b), stc_2stage = Delta(cell$m_d, cell$g_b))

draw <- function(cell) { x <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM)
  y <- stats::rbinom(2 * N_ARM, 1, stats::plogis(e0(x) + A * (-0.5 + 0.3 * x)))
  xb <- stats::rnorm(2 * N_ARM, M_B); B <- rep(0:1, each = N_ARM)
  yb <- stats::rbinom(2 * N_ARM, 1, stats::plogis(e0(xb) + B * (-0.7 + cell$g_b * xb)))
  p1 <- mean(yb[B == 1]); p0 <- mean(yb[B == 0])
  list(ipd = data.frame(x = x, A = A, y = y), d_bc = stats::qlogis(p1) - stats::qlogis(p0)) }

fit_all <- function(cell, dd) { d <- dd$ipd
  lo <- function(w, a) { p1 <- sum(w[a == 1] * d$y[a == 1]) / sum(w[a == 1]); p0 <- sum(w[a == 0] * d$y[a == 0]) / sum(w[a == 0]); stats::qlogis(p1) - stats::qlogis(p0) }
  X <- cbind(d$x - M_B, d$x^2 - (1 + M_B^2))
  b <- stats::optim(c(0, 0), function(b) sum(exp(X %*% b)), function(b) colSums(X * as.vector(exp(X %*% b))), method = "BFGS")$par
  w <- as.vector(exp(X %*% b))
  f <- stats::glm(y ~ x * A, family = stats::binomial(), data = d); cf <- stats::coef(f)
  base <- function(x) cf[1] + cf[2] * x; effA <- function(x) cf[3] + cf[4] * x
  gA <- function(m) mlo(function(x) base(x) + effA(x), base, m)
  ## B's main effect calibrated to reproduce the published B-C log OR in T_B,
  ## with B's modification set equal to A's.
  dB <- stats::uniroot(function(dl) mlo(function(x) base(x) + dl + cf[4] * x, base, M_B) - dd$d_bc, c(-5, 5))$root
  gB <- function(m) mlo(function(x) base(x) + dB + cf[4] * x, base, m)
  c(bucher = dd$d_bc - lo(rep(1, nrow(d)), d$A), maic = dd$d_bc - lo(w, d$A), stc = dd$d_bc - gA(M_B), stc_2stage = gB(cell$m_d) - gA(cell$m_d))
}
one_rep <- function(cell) { e <- fit_all(cell, draw(cell)); data.frame(method = names(e), est = unname(e)) }
