## ---------------------------------------------------------------------------
## OVL-03: a support diagnostic integrated over a target law reconstructed from
## published marginals.
##
## Source trial A versus C, N_ARM per arm, x = (x1, x2) ~ N(0, I) truncated to
## s = x1 + x2 <= C_TR, so the unsupported region is a JOINT set: its target mass
## P_T(s > C_TR) depends on the target correlation, which a publication of means
## and SDs does not report. Target x ~ N((MU, MU), [1 RHO; RHO 1]); the
## publication gives MU and unit SDs only. Continuous outcome
## y = 0.5 s + A tau(x) + e, e ~ N(0, 1), tau(x) = TAU0 + TAU1 s + H (s - C_TR)_+:
## linear inside the source support, bent beyond it when H > 0.
##
## Method: linear G-computation (STC), y ~ A * (x1 + x2), standardized over the
## target. On the identity scale with a linear model the standardized estimate
## depends on the target law only through its means, so it is the same under the
## true law and under any reconstruction; the joint law enters the truth and the
## diagnostic, not the estimate (MOD-01 owns the estimate). Limit bias
## -H E_T[(s - C_TR)_+], closed form.
##
## Diagnostics, each aggregated over a target law L: hull (L-mass outside the
## source's convex hull); Mahalanobis distance to the source, mean and 95th
## percentile over L; extrapolated modification, E_L of the amount by which the
## fitted modification index b1 x1 + b2 x2 leaves its range over the source
## (modification-weighted, zero inside); mean prediction SD of the fitted
## tau(x) over L; and the contrast's own SE (law-invariant here). Laws: the true
## law (oracle) and the independence reconstruction (RHO = 0, the maximum-entropy
## law given the published marginals). A range over RHO in ENV_RHO is computed
## exactly in the probes only: it does not depend on the true RHO, so it cannot
## restore discrimination across correlations.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261503L
N_ARM <- 300L; N_SIM <- 1000L
C_TR <- 2; TAU0 <- -0.5; TAU1 <- 0.3; H_BENT <- 1
MU <- c(0.3, 0.6); RHO <- c(-0.7, 0, 0.7); ENV_RHO <- c(-0.8, -0.4, 0, 0.4, 0.8)
MATERIAL <- 0.2; N_TGT <- 2000L
DIAGS <- c("hull", "maha_mean", "maha_q95", "extrap", "predsd")

build_grid <- function() {
  g <- expand.grid(mu = MU, rho = RHO, shape = c("linear", "bent"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$h <- ifelse(g$shape == "bent", H_BENT, 0); g$cell <- seq_len(nrow(g)); g
}

## E[(s - c)_+] for s ~ N(m, v).
hinge_mean <- function(m, v, c = C_TR) { sd <- sqrt(v); z <- (c - m) / sd; sd * stats::dnorm(z) - (c - m) * stats::pnorm(-z) }
truth <- function(cell) TAU0 + TAU1 * 2 * cell$mu + cell$h * hinge_mean(2 * cell$mu, 2 + 2 * cell$rho)
unsupported_mass <- function(mu, rho) stats::pnorm((2 * mu - C_TR) / sqrt(2 + 2 * rho))

draw <- function(cell) {
  n <- 2 * N_ARM; x <- matrix(0, 0, 2)
  while (nrow(x) < n) { z <- matrix(stats::rnorm(4 * n), ncol = 2); x <- rbind(x, z[rowSums(z) <= C_TR, , drop = FALSE]) }
  x <- x[seq_len(n), ]; s <- x[, 1] + x[, 2]; A <- rep(0:1, each = N_ARM)
  data.frame(x1 = x[, 1], x2 = x[, 2], A = A, y = 0.5 * s + A * (TAU0 + TAU1 * s + cell$h * pmax(s - C_TR, 0)) + stats::rnorm(n))
}

## Target draws under a law with correlation r, from one fixed standard-normal base,
## so every law is evaluated on common random numbers.
Z_BASE <- local({ set.seed(7); matrix(stats::rnorm(2 * N_TGT), ncol = 2) })
law <- function(mu, r) cbind(mu + Z_BASE[, 1], mu + r * Z_BASE[, 1] + sqrt(1 - r^2) * Z_BASE[, 2])

## Outside a convex polygon: any edge with the point strictly on its outer side
## (vertices put in counterclockwise order first).
outside_hull <- function(P, H) { k <- nrow(H); j <- c(2:k, 1)
  if (sum(H[, 1] * H[j, 2] - H[j, 1] * H[, 2]) < 0) H <- H[k:1, ]
  out <- rep(FALSE, nrow(P))
  for (e in seq_len(k)) out <- out | ((H[j[e], 1] - H[e, 1]) * (P[, 2] - H[e, 2]) - (H[j[e], 2] - H[e, 2]) * (P[, 1] - H[e, 1])) < 0
  out }

diagnostics <- function(P, X, Hv, Si, xb, b, Vt, rng) {
  dm <- sqrt(rowSums(((P - rep(xb, each = nrow(P))) %*% Si) * (P - rep(xb, each = nrow(P)))))
  ti <- drop(P %*% b)
  c(hull = mean(outside_hull(P, Hv)), maha_mean = mean(dm), maha_q95 = unname(stats::quantile(dm, 0.95)),
    extrap = mean(pmax(ti - rng[2], 0) + pmax(rng[1] - ti, 0)),
    predsd = mean(sqrt(rowSums((cbind(1, P) %*% Vt) * cbind(1, P))))) }

one_rep <- function(cell) {
  d <- draw(cell); X <- cbind(d$x1, d$x2)
  f <- stats::lm(y ~ A * (x1 + x2), data = d); b <- stats::coef(f); V <- stats::vcov(f)
  gr <- c(0, 1, 0, 0, cell$mu, cell$mu); est <- sum(gr * b); se <- sqrt(drop(t(gr) %*% V %*% gr))
  bi <- b[c("A:x1", "A:x2")]; it <- c("A", "A:x1", "A:x2"); Vt <- V[it, it]
  Hv <- X[grDevices::chull(X), ]; Si <- solve(stats::cov(X)); xb <- colMeans(X); rng <- range(drop(X %*% bi))
  dg <- function(r) diagnostics(law(cell$mu, r), X, Hv, Si, xb, bi, Vt, rng)
  data.frame(est = est, se = se, diag = DIAGS, true_law = dg(cell$rho), indep = dg(0))
}
