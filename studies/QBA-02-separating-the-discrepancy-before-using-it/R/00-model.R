## ---------------------------------------------------------------------------
## QBA-02: a benchmark discrepancy is not yet a residual-bias prior.
##
## A benchmark program of K trials in the Gupta et al. design: each trial's
## experimental arm is compared once with its randomized control arm and once
## with an external control arm. Per-arm log-hazard estimation errors u_x, u_c,
## u_e ~ N(0, 1/E), event counts E ~ uniform on 25..150 per arm. Log HR:
## randomized theta_k + u_x - u_c; emulated theta_k + b_k + m_k + u_x - u_e, with
## systematic bias b_k ~ N(MU_B, TAU^2) and estimand or outcome-definition
## mismatch m_k ~ N(0, SIG_M^2). The discrepancy D_k = b_k + m_k + u_c - u_e:
## its sampling variance is 1/E_c + 1/E_e, because the shared experimental arm
## cancels; the sum of the two reported squared SEs adds 2/E_x.
##
## Residual-bias priors N(mu_hat, tau2_hat) built from the D_k:
##   raw     mean and variance of D (the discrepancy distribution used directly)
##   naive   var(D) minus the mean of se_rct^2 + se_emul^2, truncated at 0
##   shared  var(D) minus the mean of 1/E_c + 1/E_e (shared-arm covariance), at 0
##   reml    random-effects REML with within variances 1/E_c + 1/E_e; predictive
##           interval with t on K - 2 df and the SE of mu_hat added
## A new unanchored submission has theta_hat = theta + b_new + e, b_new drawn from
## the same bias law, no mismatch, SE_NEW. Its bias-adjusted 95% interval is
## theta_hat - mu_hat +- q sqrt(SE_NEW^2 + tau2_hat [+ se(mu_hat)^2]). Coverage of
## theta given the prior is a normal probability, computed exactly per benchmark.
## Concealment (analyst adaptation) is not simulated: it needs analysts.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261602L
N_SIM <- 2000L; MU_B <- 0.1; SE_NEW <- 0.15; E_RANGE <- 25:150
METHODS <- c("raw", "naive", "shared", "reml")

build_grid <- function() {
  g <- expand.grid(tau = c(0, 0.1, 0.3), sig_m = c(0, 0.1), K = c(15L, 40L), KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
truth <- function(cell) c(tau2 = cell$tau^2, mu = MU_B)
## Common random numbers across mismatch levels: m is drawn last, so the seed block
## ignores sig_m and every other draw is shared.
crn_block <- function(cell) cell$cell - 3L * (cell$sig_m > 0)

draw <- function(cell) { K <- cell$K; E <- matrix(sample(E_RANGE, 3 * K, replace = TRUE), K)
  u <- matrix(stats::rnorm(3 * K), K) / sqrt(E)                      # columns: x, c, e
  b <- MU_B + cell$tau * stats::rnorm(K); m <- cell$sig_m * stats::rnorm(K)
  data.frame(D = (b + m + u[, 1] - u[, 3]) - (u[, 1] - u[, 2]), v_shared = 1 / E[, 2] + 1 / E[, 3],
             v_naive = 2 / E[, 1] + 1 / E[, 2] + 1 / E[, 3]) }

## Exact coverage of theta by theta_hat - mu_hat +- hw, given the prior.
coverage <- function(mu_hat, hw, cell) { s <- sqrt(cell$tau^2 + SE_NEW^2); off <- MU_B - mu_hat
  stats::pnorm((hw - off) / s) - stats::pnorm((-hw - off) / s) }

one_rep <- function(cell) {
  d <- draw(cell); mu <- mean(d$D); vd <- stats::var(d$D); z <- stats::qnorm(0.975)
  t2 <- c(raw = vd, naive = max(0, vd - mean(d$v_naive)), shared = max(0, vd - mean(d$v_shared)))
  hw <- z * sqrt(SE_NEW^2 + t2); mus <- rep(mu, 3); conv <- rep(TRUE, 3)
  f <- tryCatch(metafor::rma(yi = d$D, vi = d$v_shared, method = "REML", control = list(maxiter = 1000)), error = function(e) NULL)
  if (is.null(f)) f <- metafor::rma(yi = d$D, vi = d$v_shared, method = "DL")
  t2 <- c(t2, reml = f$tau2); mus <- c(mus, f$b[[1]]); conv <- c(conv, f$method == "REML")
  hw <- c(hw, stats::qt(0.975, cell$K - 2) * sqrt(SE_NEW^2 + f$tau2 + f$se^2))
  data.frame(method = METHODS, mu_hat = mus, tau2_hat = t2, halfwidth = hw, coverage = coverage(mus, hw, cell), reml_ok = conv,
             excess = vd - mean(d$v_shared))                  # untruncated var(D) minus the true sampling variance
}
