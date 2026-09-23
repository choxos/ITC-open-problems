## ---------------------------------------------------------------------------
## OVL-02: is an infeasible MAIC calibration signaled, and by what?
##
## Method-of-moments MAIC has a solution only if the target mean lies in the
## convex hull of the source covariate rows: a linear program decides it exactly.
## When it does not, minimizing sum(exp(Xc a)) has no minimizer; a quasi-Newton
## routine drifts and stops on a tolerance, returning weights that do not match the
## target. Two consequences checked here:
##   - the residual imbalance max |sum w (x - m_T)| / sum w is zero at any solution
##     and bounded away from zero without one, so the balance table MAIC already
##     prints separates feasible from infeasible exactly, if it is computed rather
##     than assumed; DIA-03's "identically zero" holds only on feasible problems;
##   - ESS is small in both hard-but-feasible and infeasible problems, so it cannot.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260930L
N_ARM <- 200L
ALPHA <- stats::qlogis(0.3); DELTA <- -0.5; GAMMA <- 0.4
N_SIM <- 1000L
LEVELS <- list(dim = c(3L, 8L), shift = c("easy", "q10", "q30", "q50", "q70", "q90"), em = c(0, 0.5))
EASY_SHIFT <- 1.5   # feasible with margin in both dimensions

build_grid <- function() {
  g <- expand.grid(dim = LEVELS$dim, shift = LEVELS$shift, em = LEVELS$em,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Target mean m_T = s u, u the equal-weight unit direction. s is set per
## dimension from probe P2 so that the feasibility probability runs across the
## grid: the shift at which a fraction q of replicates are infeasible.
unit_dir <- function(d) rep(1, d) / sqrt(d)

lp_feasible <- function(X, m) {
  n <- nrow(X); d <- ncol(X)
  A <- rbind(t(X), rep(1, n))
  r <- Rglpk::Rglpk_solve_LP(obj = rep(0, n), mat = A, dir = rep("==", d + 1),
                             rhs = c(m, 1), bounds = NULL, max = FALSE)
  r$status == 0
}

maic <- function(X, m) {
  Xc <- sweep(X, 2, m)
  f <- function(a) { z <- Xc %*% a; mx <- max(z); log(sum(exp(z - mx))) + mx }
  gr <- function(a) { z <- Xc %*% a; w <- exp(z - max(z)); colSums(Xc * as.vector(w)) / sum(w) }
  o <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS",
                    control = list(maxit = 500, reltol = 1e-12))
  z <- Xc %*% o$par; w <- as.vector(exp(z - max(z)))
  list(w = w, conv = o$convergence,
       resid = max(abs(colSums(Xc * w) / sum(w))))
}

truth <- function(cell, s) {
  ## marginal log OR in the target by Monte Carlo on a fixed large draw
  m <- s * unit_dir(cell$dim)
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(77L + cell$dim)
  X <- sweep(matrix(stats::rnorm(4e5 * cell$dim), ncol = cell$dim), 2, m, "+")
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  eta <- ALPHA + GAMMA * rowSums(X)
  stats::qlogis(mean(stats::plogis(eta + DELTA + cell$em * X[, 1]))) - stats::qlogis(mean(stats::plogis(eta)))
}

one_rep <- function(cell, s, th) {
  d <- cell$dim; m <- s * unit_dir(d)
  X <- matrix(stats::rnorm(2 * N_ARM * d), ncol = d); A <- rep(0:1, each = N_ARM)
  y <- stats::rbinom(2 * N_ARM, 1, stats::plogis(ALPHA + GAMMA * rowSums(X) + DELTA * A + cell$em * X[, 1] * A))
  feas <- lp_feasible(X, m)
  f <- maic(X, m); w <- f$w
  p1 <- sum(w[A == 1] * y[A == 1]) / sum(w[A == 1]); p0 <- sum(w[A == 0] * y[A == 0]) / sum(w[A == 0])
  v <- function(a, p) sum(w[A == a]^2 * (y[A == a] - p)^2) / sum(w[A == a])^2 / (p * (1 - p))^2
  ok <- p1 > 0 && p1 < 1 && p0 > 0 && p0 < 1
  est <- if (ok) stats::qlogis(p1) - stats::qlogis(p0) else NA
  se <- if (ok) sqrt(v(1, p1) + v(0, p0)) else NA
  wn <- w / sum(w)
  c(feasible = feas, conv = f$conv, resid = f$resid, ess = 1 / sum(wn^2),
    max_w = max(wn), est = est, se = se, err = est - th)
}
