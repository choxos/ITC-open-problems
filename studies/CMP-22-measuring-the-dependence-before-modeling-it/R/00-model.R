## ---------------------------------------------------------------------------
## CMP-22: which trials supply individual data, and what selection on it does.
##
## K = 12 trials of A versus C, 200 per arm; trial covariate means m_k ~ U(-1, 1),
## x ~ N(m_k, 1); continuous outcome y = x + A (DELTA + beta_k x) + e with trial
## interaction beta_k = BETA + u_k, u_k ~ N(0, TAU_U^2). An observed trial variable
## z_k = m_k + N(0, 0.5^2). IPD is available with probability
## plogis(a + s_obs z_k + s_lat u_k / TAU_U), a set for the expected IPD share.
## Aggregate trials report the mean difference, its SE and the covariate mean.
## Estimand: the mean interaction BETA and the effect at a target covariate mean
## X_T, DELTA + BETA X_T.
## Estimators: (a) pooled within-trial interaction from the IPD trials
## (DerSimonian-Laird); (b) combined: IPD trials' within-trial slopes and all
## trials' effects regressed on their covariate means, pooled by inverse variance.
## Diagnostic: leave-IPD-out influence, the largest change in (b) when one IPD
## trial is treated as aggregate.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261027L
K <- 12L; N_ARM <- 200L; DELTA <- -0.5; BETA <- 0.3; TAU_U <- 0.15; X_T <- 1; N_SIM <- 1000L
LEVELS <- list(share = c(0.25, 0.5, 0.75), s_obs = c(0, 1.5), s_lat = c(0, 1, 2))
build_grid <- function() { g <- expand.grid(share = LEVELS$share, s_obs = LEVELS$s_obs, s_lat = LEVELS$s_lat, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }

draw <- function(cell) {
  m <- stats::runif(K, -1, 1); u <- stats::rnorm(K, 0, TAU_U); z <- m + stats::rnorm(K, 0, 0.5)
  lp <- cell$s_obs * z + cell$s_lat * u / TAU_U
  a <- stats::uniroot(function(a) mean(stats::plogis(a + lp)) - cell$share, c(-20, 20))$root
  ipd <- stats::runif(K) < stats::plogis(a + lp); if (sum(ipd) < 2) ipd[order(-lp)[1:2]] <- TRUE
  tr <- lapply(seq_len(K), function(k) { x <- stats::rnorm(2 * N_ARM, m[k]); A <- rep(0:1, each = N_ARM)
    y <- x + A * (DELTA + (BETA + u[k]) * x) + stats::rnorm(2 * N_ARM)
    f <- stats::lm(y ~ A * x); ag <- stats::lm(y ~ A)
    c(slope = unname(stats::coef(f)["A:x"]), v_slope = stats::vcov(f)["A:x", "A:x"], eff = unname(stats::coef(ag)["A"]),
      v_eff = stats::vcov(ag)["A", "A"], mbar = mean(x)) })
  d <- as.data.frame(do.call(rbind, tr)); d$ipd <- ipd; d
}

dl <- function(e, v) { w <- 1 / v; m <- sum(w * e) / sum(w); Q <- sum(w * (e - m)^2)
  t2 <- max(0, (Q - (length(e) - 1)) / (sum(w) - sum(w^2) / sum(w))); w2 <- 1 / (v + t2); c(sum(w2 * e) / sum(w2), sqrt(1 / sum(w2))) }
combined <- function(d) {
  wi <- dl(d$slope[d$ipd], d$v_slope[d$ipd])                                  # within
  X <- cbind(1, d$mbar); W <- diag(1 / d$v_eff); V <- solve(t(X) %*% W %*% X); b <- drop(V %*% t(X) %*% W %*% d$eff)
  vb <- V[2, 2]; beta <- (wi[1] / wi[2]^2 + b[2] / vb) / (1 / wi[2]^2 + 1 / vb)
  ## intercept given the pooled slope, from all trials' effects
  delta <- sum((d$eff - beta * d$mbar) / d$v_eff) / sum(1 / d$v_eff)
  c(beta = beta, target = delta + beta * X_T)
}
fit_all <- function(d) {
  wi <- dl(d$slope[d$ipd], d$v_slope[d$ipd]); cb <- combined(d)
  delta_w <- sum((d$eff - wi[1] * d$mbar) / d$v_eff) / sum(1 / d$v_eff)
  infl <- if (sum(d$ipd) > 2) max(sapply(which(d$ipd), function(k) { d2 <- d; d2$ipd[k] <- FALSE; abs(combined(d2)[["target"]] - cb[["target"]]) })) else NA
  c(beta_within = wi[1], se_within = wi[2], target_within = delta_w + wi[1] * X_T, beta_comb = cb[["beta"]], target_comb = cb[["target"]],
    n_ipd = sum(d$ipd), influence = infl)
}
