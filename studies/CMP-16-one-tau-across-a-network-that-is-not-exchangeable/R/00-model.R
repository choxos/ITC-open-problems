## ---------------------------------------------------------------------------
## CMP-16: one heterogeneity parameter across two subnetworks that differ in it.
##
## A disconnected network bridged by a shared component: subnetwork 1 (bridging)
## has K studies of component A against its backbone; subnetwork 2 has K studies
## of B against A. The cross-gap target, B against the subnetwork-1 backbone, is
## the sum of the two pooled effects. Study estimates y ~ N(theta + u, s^2 + tau_k^2)
## with within-study SE s from 0.1 to 0.25 and subnetwork-specific tau_k.
## Models, each with random effects and Wald 95% intervals:
##   shared      one tau^2 for both subnetworks (REML)
##   stratified  a tau^2 per subnetwork (REML)
##   shrunk      each subnetwork's tau^2 shrunk toward the shared value with weight
##               K / (K + 4)
## Hartung-Knapp versions of shared and stratified are also reported.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261209L; N_SIM <- 2000L; THETA <- c(-0.3, 0.1)
build_grid <- function() { g <- expand.grid(ratio = c(1, 2, 5), het = c("bridging", "other"), K = c(3L, 6L, 12L), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$ratio == 1 & g$het == "other"), ]; g$cell <- seq_len(nrow(g)); g }
taus <- function(cell) { lo <- 0.05; hi <- lo * cell$ratio; if (cell$het == "bridging") c(hi, lo) else c(lo, hi) }
reml_group <- function(y, s2, groups, shared) {
  nll <- function(lt) { t2 <- exp(lt)[if (shared) rep(1, length(y)) else groups]; w <- 1 / (s2 + t2)
    mu <- tapply(w * y, groups, sum) / tapply(w, groups, sum); r <- y - mu[groups]
    0.5 * (sum(log(s2 + t2)) + sum(log(tapply(w, groups, sum))) + sum(w * r^2)) }
  if (shared) exp(stats::optimize(nll, c(-15, 1))$minimum) else { st <- c(log(0.01), log(0.01))
    exp(stats::optim(st, nll, method = "L-BFGS-B", lower = -15, upper = 1)$par) } }
pooled <- function(y, s2, t2) { w <- 1 / (s2 + t2); c(est = sum(w * y) / sum(w), var = 1 / sum(w), q = sum(w * (y - sum(w * y) / sum(w))^2)) }
one_rep <- function(cell) {
  tk <- taus(cell); g <- rep(1:2, each = cell$K); s2 <- stats::runif(2 * cell$K, 0.1, 0.25)^2
  y <- THETA[g] + stats::rnorm(2 * cell$K, 0, tk[g]) + stats::rnorm(2 * cell$K, 0, sqrt(s2))
  t_sh <- reml_group(y, s2, g, TRUE); t_st <- reml_group(y, s2, g, FALSE); w <- cell$K / (cell$K + 4); t_sk <- w * t_st + (1 - w) * t_sh
  fit <- function(t2v, hk = FALSE) { p <- lapply(1:2, function(k) pooled(y[g == k], s2[g == k], t2v[k]))
    v <- vapply(p, function(z) z[["var"]] * if (hk) max(1, z[["q"]] / (cell$K - 1)) else 1, 0)
    q <- if (hk) stats::qt(0.975, 2 * cell$K - 2) else 1.96
    c(est = sum(vapply(p, `[[`, 0, "est")), se = sqrt(sum(v)), crit = q) }
  r <- rbind(shared = fit(c(t_sh, t_sh)), stratified = fit(t_st), shrunk = fit(t_sk), shared_hk = fit(c(t_sh, t_sh), TRUE), stratified_hk = fit(t_st, TRUE))
  data.frame(method = rownames(r), est = r[, "est"], se = r[, "se"], crit = r[, "crit"], tau_shared = sqrt(t_sh), tau1 = sqrt(t_st[1]), tau2 = sqrt(t_st[2]))
}
