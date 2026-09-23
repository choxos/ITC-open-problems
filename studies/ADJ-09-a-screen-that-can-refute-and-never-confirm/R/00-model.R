## ---------------------------------------------------------------------------
## ADJ-09: an invariance screen for a bridging assumption, scored as a classifier.
##
## K observed trials (environments) and one gap environment with no data. Each
## trial: logit p = a_k + G x + A (DELTA + drift(z_k)), x ~ N(mu_k, 1), where z_k
## is an environment feature and drift is the bridge violation. The analyst
## transports the pooled effect to the gap unless the screen abstains.
##
## The screen is Cochran's Q across the trials' effect estimates, abstaining at
## p < 0.10. On the conditional log OR scale Q tests the drift. On the marginal
## scale the effect varies with mu_k through non-collapsibility even when the
## conditional effect is constant, so a marginal screen fires under a valid bridge
## wherever populations differ (DESIGN.md consequence 1). Standardizing every
## trial's marginal effect to one reference population removes that.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261010L
N_ARM <- 300L; DELTA <- -0.6; Z_GAP <- 2; SPREAD_MU <- 0.6
N_SIM <- 1000L
LEVELS <- list(K = c(4L, 10L), G = c(0.5, 1.5),
               drift = c("none", "observed_and_gap", "gap_only"), size = c(0.15, 0.3))

build_grid <- function() {
  g <- expand.grid(K = LEVELS$K, G = LEVELS$G, drift = LEVELS$drift, size = LEVELS$size,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$drift == "none" & g$size == 0.3), ]
  g$ctrl <- "none"
  ## Controls (DESIGN.md section 8): identical environments; a risk-difference
  ## outcome, collapsible, with a valid bridge; large observable drift.
  ctl <- data.frame(K = 10L, G = 1.5, drift = c("none", "none", "observed_and_gap"),
                    size = c(0.15, 0.15, 0.6), ctrl = c("identical", "rd", "positive"))
  g <- rbind(g, ctl)
  g$cell <- seq_len(nrow(g)); g
}

## Environment features: observed trials at z in [-1, 1]; the gap at Z_GAP.
env_z <- function(K) seq(-1, 1, length.out = K)
env_mu <- function(K) SPREAD_MU * env_z(K)
## Trial covariate SDs also differ (0.5 to 1.5, unrelated to z), so the prognostic
## index's variance, which drives non-collapsibility, differs between trials.
env_sd <- function(K) 0.5 + (seq_len(K) - 1) %% 3 / 2
drift_fn <- function(z, cell) switch(cell$drift, none = 0 * z,
  observed_and_gap = cell$size * z,
  gap_only = ifelse(z > 1.5, cell$size * (z - 1.5) / (Z_GAP - 1.5) * 2, 0))

## Truth: conditional log OR in the gap (the quantity the bridge transports).
truth <- function(cell) if (cell$ctrl == "rd") RD else DELTA + drift_fn(Z_GAP, cell)

## Risk-difference control: p = 0.35 + 0.04 x + A (-0.12), so the marginal and
## conditional risk differences are both -0.12 in every environment.
RD <- -0.12

draw <- function(cell) {
  z <- env_z(cell$K); mu <- env_mu(cell$K); sdk <- env_sd(cell$K)
  if (cell$ctrl == "identical") { mu <- 0 * mu; sdk <- 0 * sdk + 1 }
  do.call(rbind, lapply(seq_len(cell$K), function(k) {
    x <- stats::rnorm(2 * N_ARM, mu[k], sdk[k]); A <- rep(0:1, each = N_ARM)
    ## Baseline risk is not re-centered for the covariate mean: trials differ in
    ## their average risk as well as their covariate law, as real trials do.
    a <- stats::qlogis(0.3) + if (cell$ctrl == "identical") 0 else stats::rnorm(1, 0, 0.3)
    p <- if (cell$ctrl == "rd") pmin(pmax(0.35 + 0.04 * x + A * RD, 0.001), 0.999) else
      stats::plogis(a + cell$G * x + A * (DELTA + drift_fn(z[k], cell)))
    y <- stats::rbinom(2 * N_ARM, 1, p)
    data.frame(k = k, x = x, A = A, y = y)
  }))
}

q_test <- function(est, v) { w <- 1 / v; m <- sum(w * est) / sum(w)
  Q <- sum(w * (est - m)^2); c(pooled = m, se = sqrt(1 / sum(w)), p = stats::pchisq(Q, length(est) - 1, lower.tail = FALSE)) }

fit_all <- function(cell, d) {
  if (cell$ctrl == "rd") {
    per <- do.call(rbind, lapply(split(d, d$k), function(s) {
      f <- stats::lm(y ~ x + A, data = s); p1 <- mean(s$y[s$A == 1]); p0 <- mean(s$y[s$A == 0])
      data.frame(cond = stats::coef(f)[["A"]], v_cond = sandwich::vcovHC(f, "HC0")["A", "A"], marg = p1 - p0,
                 v_marg = p1 * (1 - p1) / sum(s$A == 1) + p0 * (1 - p0) / sum(s$A == 0)) }))
    per$std <- per$cond; per$v_std <- per$v_cond
  } else per <- do.call(rbind, lapply(split(d, d$k), function(s) {
    f <- stats::glm(y ~ x + A, family = stats::binomial(), data = s)
    cond <- stats::coef(f)[["A"]]; vc <- stats::vcov(f)["A", "A"]
    p1 <- mean(s$y[s$A == 1]); p0 <- mean(s$y[s$A == 0])
    marg <- stats::qlogis(p1) - stats::qlogis(p0)
    vm <- 1 / sum(s$y[s$A == 1]) + 1 / sum(1 - s$y[s$A == 1]) + 1 / sum(s$y[s$A == 0]) + 1 / sum(1 - s$y[s$A == 0])
    ## standardized to a reference population x ~ N(0, 1), by G-computation
    zr <- stats::qnorm(stats::ppoints(200)); b <- stats::coef(f)
    q1 <- mean(stats::plogis(b[1] + b[2] * zr + b[3])); q0 <- mean(stats::plogis(b[1] + b[2] * zr))
    gr <- c(mean(stats::dlogis(b[1] + b[2] * zr + b[3])) / (q1 * (1 - q1)) - mean(stats::dlogis(b[1] + b[2] * zr)) / (q0 * (1 - q0)),
            mean(zr * stats::dlogis(b[1] + b[2] * zr + b[3])) / (q1 * (1 - q1)) - mean(zr * stats::dlogis(b[1] + b[2] * zr)) / (q0 * (1 - q0)),
            mean(stats::dlogis(b[1] + b[2] * zr + b[3])) / (q1 * (1 - q1)))
    data.frame(cond = cond, v_cond = vc, marg = marg, v_marg = vm,
               std = stats::qlogis(q1) - stats::qlogis(q0), v_std = drop(t(gr) %*% stats::vcov(f) %*% gr))
  }))
  qc <- q_test(per$cond, per$v_cond); qm <- q_test(per$marg, per$v_marg); qs <- q_test(per$std, per$v_std)
  c(p_cond = qc[["p"]], p_marg = qm[["p"]], p_std = qs[["p"]],
    pooled_cond = qc[["pooled"]], se_cond = qc[["se"]])
}
