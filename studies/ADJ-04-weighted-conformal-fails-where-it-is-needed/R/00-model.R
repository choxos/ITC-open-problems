## ---------------------------------------------------------------------------
## ADJ-04: weighted split-conformal prediction under covariate shift.
##
## Source x ~ N(0, 1), n = 600 (300 to fit, 300 to calibrate); target x ~ N(MU, 1).
## Outcome y = 1 + 0.5 x + 0.4 max(x - 1, 0)^2 + e, e ~ N(0, 1): the curvature sits
## where the source is thin. Model: natural spline with 3 df fitted on the
## training half. Scores |y - y_hat| on the calibration half.
## Intervals for target patients (1000 per replicate):
##   unweighted   ordinary split conformal
##   weighted     likelihood-ratio weighted conformal with the true density ratio
##   weighted_est the same with the ratio estimated by logistic regression of
##                target (1000 unlabeled draws) against source calibration points
## Coverage overall and among target patients above the source's largest x;
## share of infinite intervals; effective calibration size (sum w)^2 / sum w^2.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261107L; N_FIT <- 300L; N_CAL <- 300L; N_TEST <- 1000L; N_SIM <- 500L; ALPHA <- 0.1
LEVELS <- list(mu = c(0.5, 1, 1.5))
build_grid <- function() { g <- data.frame(mu = LEVELS$mu); g$cell <- seq_len(nrow(g)); g }
f <- function(x) 1 + 0.5 * x + 0.4 * pmax(x - 1, 0)^2
wquant <- function(s, w, w_test, a) { o <- order(s); s <- s[o]; p <- w[o] / (sum(w) + w_test); cp <- cumsum(p)
  k <- which(cp >= 1 - a)[1]; if (is.na(k)) Inf else s[k] }
one_rep <- function(cell) {
  xf <- stats::rnorm(N_FIT); yf <- f(xf) + stats::rnorm(N_FIT); xc <- stats::rnorm(N_CAL); yc <- f(xc) + stats::rnorm(N_CAL)
  xt <- stats::rnorm(N_TEST, cell$mu); yt <- f(xt) + stats::rnorm(N_TEST)
  m <- stats::lm(y ~ splines::ns(x, 3), data = data.frame(x = xf, y = yf))
  pr <- function(x) stats::predict(m, newdata = data.frame(x = x))
  sc <- abs(yc - pr(xc)); pt <- pr(xt); err <- abs(yt - pt); tail <- xt > max(c(xf, xc))
  r_true <- function(x) exp(cell$mu * x - cell$mu^2 / 2)
  xu <- stats::rnorm(N_TEST, cell$mu); lr <- stats::glm(c(rep(0, N_CAL), rep(1, N_TEST)) ~ c(xc, xu), family = stats::binomial())
  r_est <- function(x) exp(stats::coef(lr)[1] + stats::coef(lr)[2] * x) * N_CAL / N_TEST
  q0 <- stats::quantile(sc, (1 - ALPHA) * (1 + 1 / N_CAL), type = 1)
  qw <- function(rf) { wc <- rf(xc); sapply(rf(xt), function(wt) wquant(sc, wc, wt, ALPHA)) }
  q1 <- qw(r_true); q2 <- qw(r_est)
  ess <- function(w) sum(w)^2 / sum(w^2)
  cov <- function(q) c(mean(err <= q), if (any(tail)) mean(err[tail] <= q[tail]) else NA, mean(!is.finite(q)), stats::median(2 * q[is.finite(q)]))
  out <- rbind(unweighted = cov(rep(q0, N_TEST)), weighted = cov(q1), weighted_est = cov(q2))
  data.frame(method = rownames(out), coverage = out[, 1], coverage_tail = out[, 2], infinite = out[, 3], median_width = out[, 4],
             tail_infinite = c(0, mean(!is.finite(q1[tail])), mean(!is.finite(q2[tail]))), ess_cal = ess(r_true(xc)), tail_share = mean(tail))
}
