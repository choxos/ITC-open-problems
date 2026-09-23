## ---------------------------------------------------------------------------
## QBA-23: bootstrap intervals over a bias grid when resamples fail.
##
## Unanchored: individual data on N patients of A with x ~ N(0, 1) and
## y = x + e, e ~ N(0, 1). A sensitivity analysis sweeps the assumed target
## mean m of x; the estimand at m is A's target mean outcome, m. MAIC to m is
## infeasible when m exceeds the sample's largest x, and becomes unstable close
## to it. A nonparametric bootstrap (B resamples) re-solves the weights at each m;
## failed resamples are dropped, as in practice.
## Interval: percentile of the successful resamples. Reported: coverage when the
## original fit succeeded; coverage counting a failed original fit as no interval;
## the resample failure share; the effective sample size.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261106L; B <- 200L; N_SIM <- 500L; GRID <- c(1, 1.5, 2, 2.5)
LEVELS <- list(n = c(100L, 300L))
build_grid <- function() { g <- data.frame(n = LEVELS$n); g$cell <- seq_len(nrow(g)); g }
draw <- function(cell) { x <- stats::rnorm(cell$n); data.frame(x = x, y = x + stats::rnorm(cell$n)) }
## Weights by minimizing the convex log-sum-exp objective (numerically stable);
## infeasible if m lies outside the sample range, failed if balance is not reached.
maic_mean <- function(x, y, m) { if (m >= max(x) || m <= min(x)) return(c(NA, NA)); xc <- x - m
  lse <- function(a) { z <- a * xc; mx <- max(z); mx + log(sum(exp(z - mx))) }
  a <- stats::optimize(lse, c(-200, 200), tol = 1e-10)$minimum
  z <- a * xc; w <- exp(z - max(z)); if (abs(sum(w * xc) / sum(w)) > 1e-4) return(c(NA, NA)); c(sum(w * y) / sum(w), sum(w)^2 / sum(w^2)) }
fit_all <- function(cell, d) do.call(rbind, lapply(GRID, function(m) {
  f <- maic_mean(d$x, d$y, m)
  bs <- replicate(B, { i <- sample.int(nrow(d), replace = TRUE); maic_mean(d$x[i], d$y[i], m)[1] })
  ok <- is.finite(bs); ci <- if (sum(ok) >= 20) stats::quantile(bs[ok], c(0.025, 0.975)) else c(NA, NA)
  data.frame(m = m, est = f[1], ess = f[2], fail_share = mean(!ok), lo = ci[1], hi = ci[2], orig_ok = is.finite(f[1]))
}))
