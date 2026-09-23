## ---------------------------------------------------------------------------
## CMP-21: one MNAR sensitivity parameter entering an anchored transported
## contrast through several routes, and whether the tipping set is one point.
##
## Two individual-data trials sharing control C: trial 1 A versus C, trial 2 B
## versus C, 300 per arm, x ~ N(0, 1), binary outcome
##   logit p = -0.5 + 0.6 x + a_A (-0.4 + 0.4 x) + a_B (-0.6 + 0.4 x).
## x is missing not at random: P(missing) = plogis(c_j + x), c_j set so trial j
## loses MISS_j of x values. Imputation: x | y, arm by normal regression on the
## complete cases (congenial with the analysis: it contains the outcome-by-arm
## term), plus a sensitivity shift delta; one imputation with common random
## draws across delta. Analysis: logistic y ~ x * arm per trial, standardized to
## the target x ~ N(0.8, s^2) by G-computation, where s is the true SD 1
## (integration route off) or the completed trial's SD (route on).
## Estimand: marginal log OR of B versus A in the target (anchored through C).
## The tipping set: the deltas in [-1.5, 1.5] at which the estimate's sign
## differs from its sign at delta = 0.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261213L; N_ARM <- 300L; N_SIM <- 500L; M_T <- 0.8
DELTAS <- seq(-1.5, 1.5, by = 0.1)
build_grid <- function() { g <- expand.grid(miss2 = c(0.3, 0.1), route_b = c(FALSE, TRUE), KEEP.OUT.ATTRS = FALSE); g$miss1 <- 0.3; g$cell <- seq_len(nrow(g)); g }
GH <- statmod::gauss.quad.prob(30, "normal")
mlo <- function(b, m, s) { x <- GH$nodes * s + m; w <- GH$weights
  stats::qlogis(sum(w * stats::plogis(b[1] + b[2] * x + b[3] + b[4] * x))) - stats::qlogis(sum(w * stats::plogis(b[1] + b[2] * x))) }
truth <- function() mlo(c(-0.5, 0.6, -0.6, 0.4), M_T, 1) - mlo(c(-0.5, 0.6, -0.4, 0.4), M_T, 1)
c_for <- function(miss) stats::uniroot(function(c0) stats::integrate(function(x) stats::plogis(c0 + x) * stats::dnorm(x), -Inf, Inf)$value - miss, c(-10, 10))$root
draw_trial <- function(eff, miss) { x <- stats::rnorm(2 * N_ARM); a <- rep(0:1, each = N_ARM)
  y <- stats::rbinom(2 * N_ARM, 1, stats::plogis(-0.5 + 0.6 * x + a * (eff + 0.4 * x)))
  obs <- stats::runif(2 * N_ARM) >= stats::plogis(c_for(miss) + x)
  list(x = ifelse(obs, x, NA), a = a, y = y, obs = obs, z = stats::rnorm(2 * N_ARM)) }
curve_trial <- function(tr, route_b) {
  cc <- tr$obs; f <- stats::lm(x ~ y * a, data = data.frame(x = tr$x, y = tr$y, a = tr$a)[cc, ]); sg <- summary(f)$sigma
  mu <- stats::predict(f, newdata = data.frame(y = tr$y, a = tr$a))
  vapply(DELTAS, function(dl) { x <- ifelse(cc, tr$x, mu + sg * tr$z + dl)
    b <- stats::coef(stats::glm(tr$y ~ x * tr$a, family = stats::binomial()))
    mlo(b[c(1, 2, 3, 4)], M_T, if (route_b) stats::sd(x) else 1) }, 0) }
one_rep <- function(cell) {
  t1 <- draw_trial(-0.4, cell$miss1); t2 <- draw_trial(-0.6, cell$miss2)
  d <- curve_trial(t2, cell$route_b) - curve_trial(t1, cell$route_b)
  s0 <- sign(d[DELTAS == 0]); flip <- sign(d) != s0
  runs <- rle(flip); n_regions <- sum(runs$values)                     # separate stretches of reversed sign
  ends <- cumsum(runs$lengths); starts <- ends - runs$lengths + 1
  interior <- any(runs$values & starts > 1 & ends < length(DELTAS))   # a reversal that reverts inside the range
  data.frame(est0 = d[DELTAS == 0], slope = unname(stats::coef(stats::lm(d ~ DELTAS))[2]), range = diff(range(d)),
             n_regions = n_regions, not_single = n_regions >= 2 || interior, any_flip = any(flip), monotone = all(diff(d) >= 0) || all(diff(d) <= 0), max_abs_move = max(abs(d - d[DELTAS == 0]))) }
