## ---------------------------------------------------------------------------
## DEC-17: contribution shares of a network contrast across the plausible range of tau.
##
## Three treatments A, B, C; two-arm studies of AB, AC and (loop network) BC; the
## target contrast is B versus C. Study estimates y_s ~ N(d_s, v_s + tau^2) with
## within-study variances equal (0.04) or spread 5:1 (0.02 to 0.10). Random-effects
## network meta-analysis by generalized least squares; tau^2 by REML, with its 95%
## profile-likelihood interval.
## Contribution of study s to the target: |h_s| / sum |h|, h the target row of the
## hat matrix H(tau) = x_t (X' W X)^-1 X' W, W = (V + tau^2 I)^-1; a comparison's
## contribution sums its studies'. The leading contributor is the largest share.
## Reported: shares at tau-hat, over the profile interval, and at the true tau.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261130L; N_SIM <- 1000L; D <- c(AB = -0.2, AC = -0.4)       # effects of B and C against A
build_grid <- function() {
  g <- expand.grid(net = c("star", "loop"), K = c(4L, 8L, 16L), spread = c("equal", "5:1"), tau = c(0, 0.1, 0.25),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
design <- function(cell) {
  cmp <- if (cell$net == "star") rep(c("AB", "AC"), length.out = cell$K) else rep(c("AB", "AC", "BC"), length.out = cell$K)
  v <- if (cell$spread == "equal") rep(0.04, cell$K) else seq(0.02, 0.10, length.out = cell$K)[sample.int(cell$K)]
  X <- t(vapply(cmp, function(k) switch(k, AB = c(1, 0), AC = c(0, 1), BC = c(-1, 1)), c(0, 0)))
  list(cmp = cmp, v = v, X = X)
}
XT <- c(-1, 1)                                                     # C versus B = d_AC - d_AB
hat_row <- function(X, v, tau2) { W <- 1 / (v + tau2); drop(XT %*% solve(crossprod(X, W * X)) %*% t(W * X)) }
share <- function(h, cmp) { s <- abs(h) / sum(abs(h)); list(study = s, comparison = tapply(s, cmp, sum)) }
reml <- function(tau2, y, X, v) { W <- 1 / (v + tau2); A <- crossprod(X, W * X); b <- solve(A, crossprod(X, W * y)); r <- y - X %*% b
  -0.5 * (sum(log(v + tau2)) + as.numeric(determinant(A)$modulus) + sum(W * r^2)) }
TAU_GRID <- c(0, exp(seq(log(1e-4), log(1), length.out = 200)))

one_rep <- function(cell) {
  ds <- design(cell); y <- drop(ds$X %*% D) + stats::rnorm(cell$K, 0, sqrt(ds$v + cell$tau^2))
  ll <- vapply(TAU_GRID^2, function(t2) reml(t2, y, ds$X, ds$v), 0); th <- TAU_GRID[which.max(ll)]
  ci <- TAU_GRID[2 * (max(ll) - ll) <= stats::qchisq(0.95, 1)]
  sh <- lapply(ci^2, function(t2) share(hat_row(ds$X, ds$v, t2), ds$cmp))
  s_hat <- share(hat_row(ds$X, ds$v, th^2), ds$cmp); s_true <- share(hat_row(ds$X, ds$v, cell$tau^2), ds$cmp)
  lead_s <- vapply(sh, function(s) which.max(s$study), 0); lead_c <- vapply(sh, function(s) names(which.max(s$comparison)), "")
  S <- do.call(rbind, lapply(sh, `[[`, "study"))
  data.frame(tau_hat = th, ci_lo = min(ci), ci_hi = max(ci),
             lead_study_changes = length(unique(lead_s)) > 1, lead_cmp_changes = length(unique(lead_c)) > 1,
             max_study_move = max(apply(S, 2, function(z) max(z) - min(z))),
             hat_vs_true = max(abs(s_hat$study - s_true$study)),
             lead_hat_is_true = which.max(s_hat$study) == which.max(s_true$study))
}
