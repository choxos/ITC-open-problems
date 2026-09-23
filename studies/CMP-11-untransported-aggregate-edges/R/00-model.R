## ---------------------------------------------------------------------------
## CMP-11: two-stage pooling of edges that live in different populations.
##
## K = 8 trials estimate one component's effect (A added to a backbone). Trial e's
## population has covariate mean m_e; the target has mean X_T = 0.5. A fraction of
## the trials supply individual data and are standardized to the target; the rest
## publish their own-population effect. Outcome, with effect modification BETA:
##   continuous (collapsible):  y = 0.5 x + a (-0.3 + BETA x) + e, e ~ N(0, 1)
##   binary (log odds ratio):   logit p = -0.5 + 0.5 x + a (-0.3 + BETA x)
## Aggregate trials sit at m_e = X_T - SEP; individual-data trials at X_T - SEP / 2.
## 200 patients per arm per trial.
## Estimand: the marginal effect of A in the target (mean difference or log OR).
## Methods, each pooling the eight edge estimates by inverse variance:
##   two_stage_marg   IPD edges standardized to the target (G-computation, marginal),
##                    aggregate edges as published                 (bias b1)
##   two_stage_cond   IPD edges as the conditional effect at the target mean profile,
##                    aggregate edges as published                 (b1 + b2)
##   transported      aggregate edges also carried to the target with the modification
##                    estimated from the pooled IPD (their covariate law known)
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261207L; K <- 8L; N_ARM <- 200L; X_T <- 0.5; N_SIM <- 1000L
build_grid <- function() { g <- expand.grid(scale = c("continuous", "binary"), p_ipd = c(0.25, 0.5, 0.75), sep = c(0, 0.5, 1), beta = c(0, 0.3), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g }
GH <- statmod::gauss.quad.prob(40, "normal")
marg <- function(scale, beta, m, b0 = -0.3, bb = beta) { x <- GH$nodes + m; w <- GH$weights
  if (scale == "continuous") return(b0 + bb * m)
  e0 <- -0.5 + 0.5 * x; stats::qlogis(sum(w * stats::plogis(e0 + b0 + bb * x))) - stats::qlogis(sum(w * stats::plogis(e0))) }
truth <- function(cell) marg(cell$scale, cell$beta, X_T)

sim_trial <- function(cell, m) { x <- stats::rnorm(2 * N_ARM, m); A <- rep(0:1, each = N_ARM)
  y <- if (cell$scale == "continuous") 0.5 * x + A * (-0.3 + cell$beta * x) + stats::rnorm(2 * N_ARM) else
    stats::rbinom(2 * N_ARM, 1, stats::plogis(-0.5 + 0.5 * x + A * (-0.3 + cell$beta * x)))
  data.frame(x = x, A = A, y = y) }
agd_effect <- function(cell, d) { if (cell$scale == "continuous") { f <- stats::lm(y ~ A, data = d); return(c(stats::coef(f)[["A"]], stats::vcov(f)["A", "A"])) }
  p1 <- mean(d$y[d$A == 1]); p0 <- mean(d$y[d$A == 0])
  c(stats::qlogis(p1) - stats::qlogis(p0), 1 / (N_ARM * p1 * (1 - p1)) + 1 / (N_ARM * p0 * (1 - p0))) }
## IPD edge: fit the outcome model, standardize to the target (marginal) with a
## delta-method variance, and report the conditional effect at the target mean.
ipd_effects <- function(cell, d) {
  fam <- if (cell$scale == "continuous") stats::gaussian() else stats::binomial()
  f <- stats::glm(y ~ x * A, family = fam, data = d); b <- stats::coef(f); V <- stats::vcov(f)
  gc <- c(0, 0, 1, X_T); cond <- c(sum(gc * b), drop(t(gc) %*% V %*% gc))
  if (cell$scale == "continuous") return(list(marg = cond, cond = cond, beta = c(b[["x:A"]], V["x:A", "x:A"]), fit = f))
  x <- GH$nodes + X_T; w <- GH$weights
  M1 <- cbind(1, x, 1, x); M0 <- cbind(1, x, 0, 0); p1 <- stats::plogis(drop(M1 %*% b)); p0 <- stats::plogis(drop(M0 %*% b)); q1 <- sum(w * p1); q0 <- sum(w * p0)
  g <- colSums(w * M1 * (p1 * (1 - p1))) / (q1 * (1 - q1)) - colSums(w * M0 * (p0 * (1 - p0))) / (q0 * (1 - q0))
  list(marg = c(stats::qlogis(q1) - stats::qlogis(q0), drop(t(g) %*% V %*% g)), cond = cond, beta = c(b[["x:A"]], V["x:A", "x:A"]), fit = f)
}
pool <- function(est, v) c(est = sum(est / v) / sum(1 / v), se = sqrt(1 / sum(1 / v)))

one_rep <- function(cell) {
  n_ipd <- round(cell$p_ipd * K); m_ipd <- X_T - cell$sep / 2; m_agd <- X_T - cell$sep
  ipd <- lapply(seq_len(n_ipd), function(i) ipd_effects(cell, sim_trial(cell, m_ipd)))
  agd <- t(vapply(seq_len(K - n_ipd), function(i) agd_effect(cell, sim_trial(cell, m_agd)), numeric(2)))
  im <- t(vapply(ipd, `[[`, numeric(2), "marg")); ic <- t(vapply(ipd, `[[`, numeric(2), "cond")); ib <- t(vapply(ipd, `[[`, numeric(2), "beta"))
  ## Transport the aggregate edges: shift = marg(target) - marg(own population) under the
  ## pooled IPD modification and the pooled IPD main effect; its variance from the
  ## pooled modification's variance.
  bh <- pool(ib[, 1], ib[, 2]); d0 <- pool(ic[, 1] - bh[["est"]] * X_T, ic[, 2])[["est"]]
  shift <- function(bb) marg(cell$scale, 0, X_T, d0, bb) - marg(cell$scale, 0, m_agd, d0, bb)
  sh <- shift(bh[["est"]]); dsh <- (shift(bh[["est"]] + 1e-4) - shift(bh[["est"]] - 1e-4)) / 2e-4
  ## Every aggregate edge moves by the same estimated shift, so the shift enters the
  ## pooled estimate once, weighted by the aggregate edges' share of the precision.
  ## (Its covariance with the IPD edges' own estimates is ignored.)
  v_all <- c(im[, 2], agd[, 2]); w_agd <- sum(1 / agd[, 2]) / sum(1 / v_all)
  raw <- pool(c(im[, 1], agd[, 1]), v_all)
  res <- list(two_stage_marg = raw, two_stage_cond = pool(c(ic[, 1], agd[, 1]), c(ic[, 2], agd[, 2])),
              transported = c(est = raw[["est"]] + w_agd * sh, se = sqrt(raw[["se"]]^2 + (w_agd * dsh)^2 * bh[["se"]]^2)))
  do.call(rbind, lapply(names(res), function(k) data.frame(method = k, est = res[[k]][["est"]], se = res[[k]][["se"]])))
}
