## ---------------------------------------------------------------------------
## QBA-20: two unidentified bias layers acting on one cross-gap contrast.
##
## Population-level numerical study. Individual model for the cross-gap
## comparison of A (built from components across the gap) with B:
##   logit p = -0.5 + 0.5 x + 0.5 u + a (DC + 0.3 x + G_U u + d_m + d_i u),
## x measured, u an omitted modifier. Target x ~ N(0.5, 1), u ~ N(mu_u, 1).
## The analysis assumes mu_u = 0 (population layer) and d_m = d_i = 0 (bridge
## layer: component main-effect drift d_m and component-by-modifier drift d_i).
## Bias of the analysis = its target marginal log OR minus the true one.
## One-at-a-time sensitivity varies each parameter over its elicited range with
## the others at zero; the joint analysis varies them together.
## ---------------------------------------------------------------------------

G_U <- 0.4; DC <- -0.45
RANGE <- c(mu_u = 0.5, d_m = 0.2, d_i = 0.4)             # elicited half-ranges at scale 1
GH <- statmod::gauss.quad.prob(24, "normal")
marg <- function(mu_u, d_m, d_i) {
  n <- GH$nodes; w <- GH$weights; X <- outer(n + 0.5, rep(1, 24)); U <- outer(rep(1, 24), n + mu_u); W <- outer(w, w)
  e0 <- -0.5 + 0.5 * X + 0.5 * U; e1 <- e0 + DC + 0.3 * X + G_U * U + d_m + d_i * U
  stats::qlogis(sum(W * stats::plogis(e1))) - stats::qlogis(sum(W * stats::plogis(e0)))
}
ANALYST <- marg(0, 0, 0)
bias <- function(mu_u, d_m, d_i) ANALYST - marg(mu_u, d_m, d_i)
