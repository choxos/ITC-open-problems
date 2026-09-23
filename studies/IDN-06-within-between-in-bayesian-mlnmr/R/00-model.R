## ---------------------------------------------------------------------------
## IDN-06: what identifies the interaction of a treatment with no individual data.
##
## Exact normal-normal calculation (credible intervals are closed form, and every
## posterior mean is linear in data whose sampling law is normal, so coverage is
## exact). Treatment j has an individual-data trial giving a within-trial
## interaction estimate b_j ~ N(beta_j, V_W). Treatment k has S aggregate trials at
## covariate means m_s (spread SPREAD around 0.5) each reporting
## d_s ~ N(delta_k + beta_k m_s + E (m_s - mean m), V_A): E is an ecological term.
## Truth: beta_j = 0.3, beta_k = beta_j + D (discordance).
## Posteriors for beta_k (flat priors on delta_k and beta_j):
##   shared        beta_k = beta_j, informed by the within-trial estimate and the
##                 aggregate gradient together (as a shared-interaction ML-NMR)
##   separate      beta_k with prior N(0, 0.5^2), informed only by the aggregate gradient
##   hierarchical  beta_k ~ N(beta_j, 0.15^2), beta_j from the within-trial estimate
## Reported: coverage and width of the 95% credible interval, and the direct share:
## the part of the posterior precision that comes from information about beta_k
## itself (the aggregate gradient) rather than from the prior or the borrowed beta_j.
## ---------------------------------------------------------------------------

V_W <- 0.01; V_A <- 0.01; BETA_J <- 0.3; PRIOR_SD <- 0.5; OMEGA <- 0.15
build_grid <- function() expand.grid(S = c(1L, 2L, 4L), spread = c(0.3, 1), D = c(0, 0.15, 0.3), E = c(0, 0.1), KEEP.OUT.ATTRS = FALSE)
## Gradient information from S aggregate trials: slope estimate and its variance
## (least squares of d on m with a free intercept); none if S = 1.
grad <- function(S, spread) { m <- if (S == 1) 0.5 else 0.5 + spread * seq(-1, 1, length.out = S); list(m = m, v = if (S >= 2) V_A / sum((m - mean(m))^2) else Inf) }
evaluate <- function(cell) {
  gi <- grad(cell$S, cell$spread); bk <- BETA_J + cell$D; gbias <- cell$E                  # aggregate slope estimates beta_k + E
  z <- stats::qnorm(0.975)
  cover <- function(mean_bias, sd_sampling, sd_post) stats::pnorm(z * sd_post / sd_sampling - mean_bias / sd_sampling) - stats::pnorm(-z * sd_post / sd_sampling - mean_bias / sd_sampling)
  out <- list()
  ## shared: precision-weighted combination of b_j (mean beta_j) and the slope (mean beta_k + E)
  pw <- 1 / V_W; pg <- if (is.finite(gi$v)) 1 / gi$v else 0; vp <- 1 / (pw + pg)
  mean_est <- vp * (pw * BETA_J + pg * (bk + gbias)); out$shared <- c(bias = mean_est - bk, sd_samp = sqrt(vp^2 * (pw + pg)), sd_post = sqrt(vp), data_share = pg / (pw + pg))
  ## separate: prior N(0, PRIOR_SD^2) and the slope
  p0 <- 1 / PRIOR_SD^2; vp <- 1 / (p0 + pg); mean_est <- vp * pg * (bk + gbias)
  out$separate <- c(bias = mean_est - bk, sd_samp = sqrt(vp^2 * pg), sd_post = sqrt(vp), data_share = pg / (p0 + pg))
  ## hierarchical: beta_k ~ N(beta_j, OMEGA^2), beta_j ~ from b_j, plus the slope
  pr_v <- V_W + OMEGA^2; vp <- 1 / (1 / pr_v + pg); mean_est <- vp * (BETA_J / pr_v + pg * (bk + gbias))
  out$hierarchical <- c(bias = mean_est - bk, sd_samp = sqrt(vp^2 * (1 / pr_v^2 * V_W + pg)), sd_post = sqrt(vp), data_share = pg / (1 / pr_v + pg))
  do.call(rbind, lapply(names(out), function(k) { o <- out[[k]]; data.frame(cell, model = k, bias = o[["bias"]], sd_post = o[["sd_post"]],
    coverage = if (o[["sd_samp"]] > 0) cover(o[["bias"]], o[["sd_samp"]], o[["sd_post"]]) else as.numeric(abs(o[["bias"]]) <= z * o[["sd_post"]]), data_share = o[["data_share"]]) }))
}
