## ---------------------------------------------------------------------------
## DIA-13: do bias mechanisms in an unanchored MAIC combine additively?
##
## Population-level calculation (exact: Gauss-Hermite quadrature over the measured
## covariate, sums over a binary unmeasured covariate). Individual data on arm A in
## the source; the target publishes the covariate mean and B's event proportion.
## logit P(Y = 1) = -1 + 0.5 x + g_u U + treatment (B: -0.4 relative to A).
## Source x ~ N(0, 1), U ~ Bern(0.3); target x ~ N(0.5, 1), U ~ Bern(0.3 + d_u).
## Mechanisms:
##   OC  omitted confounder: g_u in {-1, -0.5, 0, 0.5, 1} with d_u = 0.2
##   MC  comparator outcome misclassification: sensitivity 1 - m, specificity
##       1 - m / 2, m in {0, 0.1, 0.2}
##   ME  measurement error in the matched covariate: reliability r in {1, 0.8, 0.6};
##       MAIC on the error-prone covariate moves the latent mean by r times 0.5
## Estimand: marginal log odds ratio, B versus A, in the target. Bias of the MAIC
## limit b(g_u, m, r); interaction terms by inclusion-exclusion.
## ---------------------------------------------------------------------------

GH <- statmod::gauss.quad.prob(80, "normal")
risk <- function(mx, pu, gu, trt) { f <- function(u) sum(GH$weights * stats::plogis(-1 + 0.5 * (mx + GH$nodes) + gu * u + trt)); pu * f(1) + (1 - pu) * f(0) }
bias <- function(gu, m, r, du = 0.2) {
  pT <- 0.3 + du
  truth <- stats::qlogis(risk(0.5, pT, gu, -0.4)) - stats::qlogis(risk(0.5, pT, gu, 0))
  pB <- risk(0.5, pT, gu, -0.4); obsB <- (1 - m) * pB + (m / 2) * (1 - pB)      # misclassified comparator proportion
  limA <- risk(0.5 * r, 0.3, gu, 0)                                              # MAIC limit: U at source law, x mean r * 0.5
  stats::qlogis(obsB) - stats::qlogis(limA) - truth
}
