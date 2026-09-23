## ---------------------------------------------------------------------------
## OUT-02: effective sample size counted in events.
##
## For a weighted proportion with weights w_i and risks p_i, the sandwich
## variance of its log odds is, for small risks,
##   Var ~= sum w_i^2 y_i / (sum w_i y_i)^2 = 1 / EESS,
##   EESS = (sum w_i y_i)^2 / sum w_i^2 y_i,
## so the event-based effective sample is the reciprocal of the variance the
## sandwich already reports. Against the weights-only reading ESS x p-hat,
##   E[EESS] / (ESS p-bar) = E_w[w] E_w[p] / E_w[w p]
## (E_w a w-weighted mean), which is below 1 when weight and risk covary
## positively (weights concentrate on high-risk patients) and above 1 when they
## covary negatively. DESIGN.md section 2 had the direction reversed.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260927L
P <- 3L; GAMMA <- 1.0               # x1 is the only prognostic covariate
N_SIM <- 1000L
LEVELS <- list(risk = c(0.005, 0.02, 0.10), shift = c(0.3, 0.6, 0.9),
               direction = c("aligned", "misaligned", "independent"),
               n = c(300L, 1000L), delta = c(0, -0.5))

build_grid <- function() {
  g <- expand.grid(risk = LEVELS$risk, shift = LEVELS$shift, direction = LEVELS$direction,
                   n = LEVELS$n, delta = LEVELS$delta, KEEP.OUT.ATTRS = FALSE,
                   stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Target mean vector. Aligned: target at higher x1, so MAIC up-weights high-risk
## source patients; misaligned: lower x1; independent: shift in a non-prognostic x2.
target_mean <- function(cell) switch(cell$direction,
  aligned = c(cell$shift, 0, 0), misaligned = c(-cell$shift, 0, 0),
  independent = c(0, cell$shift, 0))

## Intercept chosen so the target control-arm marginal risk equals the risk level.
GH <- statmod::gauss.quad.prob(80, dist = "normal")
mexp <- function(a, m) sum(GH$weights * stats::plogis(a + GAMMA * (m + GH$nodes)))
alpha_for <- function(cell) {
  m1 <- target_mean(cell)[1]
  stats::uniroot(function(a) mexp(a, m1) - cell$risk, c(-20, 10), tol = 1e-12)$root
}
truth <- function(cell) {
  a <- alpha_for(cell); m1 <- target_mean(cell)[1]
  stats::qlogis(mexp(a + cell$delta, m1)) - stats::qlogis(mexp(a, m1))
}

draw <- function(cell, a) {
  X <- matrix(stats::rnorm(2 * cell$n * P), 2 * cell$n, P)
  A <- rep(0:1, each = cell$n)
  y <- stats::rbinom(2 * cell$n, 1, stats::plogis(a + GAMMA * X[, 1] + cell$delta * A))
  list(X = X, A = A, y = y, p = stats::plogis(a + GAMMA * X[, 1] + cell$delta * A))
}

maic_w <- function(X, target) {
  Xc <- sweep(X, 2, target)
  f <- function(b) sum(exp(Xc %*% b))
  gr <- function(b) colSums(Xc * as.vector(exp(Xc %*% b)))
  o <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS",
                    control = list(maxit = 1000, reltol = 1e-14))
  as.vector(exp(Xc %*% o$par))
}

arm_stats <- function(y, w, p) {
  ph <- sum(w * y) / sum(w)
  ess <- sum(w)^2 / sum(w^2)
  eess <- if (sum(y) > 0) sum(w * y)^2 / sum(w^2 * y) else 0
  ## population version with the true risks, for the ratio in the header
  eess_pop <- sum(w * p)^2 / sum(w^2 * p)
  v <- if (ph > 0 && ph < 1) sum(w^2 * (y - ph)^2) / sum(w)^2 / (ph * (1 - ph))^2 else NA
  c(ph = ph, ess = ess, eess = eess, essp = ess * ph, eess_pop = eess_pop,
    essp_pop = ess * sum(w * p) / sum(w), v = v, events = sum(y))
}

one_rep <- function(cell, a) {
  d <- draw(cell, a)
  w <- maic_w(d$X, target_mean(cell))
  s1 <- arm_stats(d$y[d$A == 1], w[d$A == 1], d$p[d$A == 1])
  s0 <- arm_stats(d$y[d$A == 0], w[d$A == 0], d$p[d$A == 0])
  ok <- is.finite(s1[["v"]]) && is.finite(s0[["v"]])
  est <- if (ok) stats::qlogis(s1[["ph"]]) - stats::qlogis(s0[["ph"]]) else NA
  se <- if (ok) sqrt(s1[["v"]] + s0[["v"]]) else NA
  harm <- function(a, b) if (a > 0 && b > 0) 1 / (1 / a + 1 / b) else 0
  c(est = est, se = se, ok = ok,
    eess = harm(s1[["eess"]], s0[["eess"]]), essp = harm(s1[["essp"]], s0[["essp"]]),
    ess = harm(s1[["ess"]], s0[["ess"]]),
    eess_pop = harm(s1[["eess_pop"]], s0[["eess_pop"]]),
    essp_pop = harm(s1[["essp_pop"]], s0[["essp_pop"]]),
    events_min = min(s1[["events"]], s0[["events"]]))
}
