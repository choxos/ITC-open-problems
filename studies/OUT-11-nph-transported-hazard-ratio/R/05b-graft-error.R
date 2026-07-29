## ---------------------------------------------------------------------------
## How much of MAIC's error is STRUCTURAL rather than statistical, computed.
##
## Round four raised a fair-comparison objection that had to be answered rather
## than caveated: MAIC is scored through a marginal log-cumulative-hazard graft
## that the protocol itself calls invalid under this data-generating mechanism,
## while STC is given a valid conditional transport. If the graft carries a large
## error of its own, then any across-row contrast measures MAIC's structural
## inability to produce an ABSOLUTE estimand, not weighting against regression,
## and calling it a method-family comparison would be wrong.
##
## The objection is real. The answer is to SIZE the graft error rather than argue
## about it, and it turns out to be exactly computable with no simulation at all,
## in the same way E1 is.
##
## The decomposition. MAIC natively produces a RELATIVE effect: a reweighted
## marginal contrast in the IPD study. To reach an absolute target-population
## RMST it must graft that contrast onto the aggregate study's placebo curve.
## Give MAIC PERFECT weighting and PERFECT estimation, so the only thing left is
## the graft, and compare what it then returns against the truth:
##
##   dl_true    = logH(S_A^ipd(target covariate law)) - logH(S_PBO^ipd(same))
##                the exact marginal contrast a perfectly weighted IPD analysis
##                would recover: TARGET covariate law, but still the IPD STUDY'S
##                OWN baseline hazard, because weighting fixes covariates and
##                does nothing to baselines
##   S_A^graft  = exp(-exp(logH(S_PBO^tgt) + dl_true))
##   truth      = S_A^tgt
##
## The gap between the last two is the graft error, and it is a property of the
## method and the mechanism, not of any sample. Because the estimand is
## Delta = RMST_B - RMST_A, a graft that overstates A's survival BIASES DELTA
## DOWNWARD, so the sign is flipped when reported as a contribution to Delta.
##
## STC gets the same treatment for symmetry: its conditional transport is exact
## under this mechanism, so its structural error should be numerically zero, and
## computing it is a check on that claim rather than an assertion of it.
## ---------------------------------------------------------------------------

source("R/04-calibrate.R")

logH_ <- function(S) log(pmax(-log(pmax(S, 1e-300)), 1e-300))
S_of_ <- function(lh) exp(-exp(lh))

## Structural (graft) error for one cell, in months of RMST, exactly.
graft_error <- function(family, kappa_a, gamma, tau = TAU, n_grid = 4001) {
  tt <- seq(1e-6, tau, length.out = n_grid)
  trap <- function(y) sum(diff(tt) * (head(y, -1) + tail(y, -1)) / 2)

  pbo_ipd <- placebo_arm(family, "ipd")
  a_ipd   <- make_arm(family, "ipd", beta = BETA_A, kappa = kappa_a, gamma = gamma)
  pbo_tgt <- placebo_arm(family, "tgt")
  a_tgt   <- make_arm(family, "tgt", beta = BETA_A, kappa = kappa_a, gamma = gamma)

  ## Perfectly weighted IPD study: TARGET covariate law, IPD baseline.
  S_pbo_ipd_w <- surv_marg(tt, MU_TGT, SD_X, pbo_ipd)
  S_a_ipd_w   <- surv_marg(tt, MU_TGT, SD_X, a_ipd)
  dl_true     <- logH_(S_a_ipd_w) - logH_(S_pbo_ipd_w)

  S_pbo_tgt <- surv_marg(tt, MU_TGT, SD_X, pbo_tgt)
  S_a_tgt   <- surv_marg(tt, MU_TGT, SD_X, a_tgt)
  S_a_graft <- S_of_(logH_(S_pbo_tgt) + dl_true)

  ## For contrast: the SAME graft applied in the study where it is exact, i.e.
  ## when the two studies share a baseline. If this is not zero the computation
  ## itself is wrong, so it is a self-check rather than a result.
  S_pbo_ipd_at_ipd <- surv_marg(tt, MU_IPD, SD_X, pbo_ipd)

  data.frame(
    family = family, kappa_a = kappa_a, gamma = gamma,
    rmst_a_true  = trap(S_a_tgt),
    rmst_a_graft = trap(S_a_graft),
    ## Contribution to the bias of Delta = RMST_B - RMST_A, hence the sign flip.
    graft_bias_delta = -(trap(S_a_graft) - trap(S_a_tgt)),
    max_abs_surv_gap = max(abs(S_a_graft - S_a_tgt)),
    selfcheck_zero = trap(S_of_(logH_(S_pbo_ipd_at_ipd) +
                                (logH_(surv_marg(tt, MU_IPD, SD_X, a_ipd)) -
                                 logH_(S_pbo_ipd_at_ipd)))) -
                     trap(surv_marg(tt, MU_IPD, SD_X, a_ipd)),
    stringsAsFactors = FALSE)
}

## STC's structural error: its conditional transport should be exact here, so
## this must return zero. Claimed exactness is checked, not asserted.
stc_structural_error <- function(family, kappa_a, gamma, tau = TAU,
                                 n_grid = 4001, n_node = 64) {
  tt <- seq(1e-6, tau, length.out = n_grid)
  trap <- function(y) sum(diff(tt) * (head(y, -1) + tail(y, -1)) / 2)
  g <- gh_nodes(n_node)
  x <- MU_TGT + sqrt(2) * SD_X * g$x; w <- g$w / sqrt(pi)

  pbo_ipd <- placebo_arm(family, "ipd")
  a_ipd   <- make_arm(family, "ipd", beta = BETA_A, kappa = kappa_a, gamma = gamma)
  pbo_tgt <- placebo_arm(family, "tgt")
  a_tgt   <- make_arm(family, "tgt", beta = BETA_A, kappa = kappa_a, gamma = gamma)

  ## Conditional curves at each node, IPD study; the conditional treatment
  ## effect on the log-cumulative-hazard scale is what STC transports.
  cond <- function(arm, xv) vapply(xv, function(u) arm_S(tt, u, arm), numeric(length(tt)))
  lh_pbo_ipd <- logH_(cond(pbo_ipd, x)); lh_a_ipd <- logH_(cond(a_ipd, x))
  delta_cond <- lh_a_ipd - lh_pbo_ipd
  ## Target baseline solved so the implied marginal placebo curve matches the
  ## target study's, exactly as R/03-estimators.R does it.
  lh_pbo_tgt <- logH_(cond(pbo_tgt, x))
  S_a_stc <- as.vector(S_of_(lh_pbo_tgt + delta_cond) %*% w)

  data.frame(family = family, kappa_a = kappa_a, gamma = gamma,
             stc_structural_bias = -(trap(S_a_stc) - trap(surv_marg(tt, MU_TGT, SD_X, a_tgt))),
             stringsAsFactors = FALSE)
}

if (!interactive() && Sys.getenv("GRAFT_NOMAIN") == "") {
  grid <- expand.grid(family = c("weibull", "gompertz"),
                      kappa_a = KAPPA_A_LEVELS, gamma = c(0, GAMMA),
                      stringsAsFactors = FALSE)
  cat("=== structural error of MAIC's marginal graft, exact, months of RMST ===\n")
  gr <- do.call(rbind, Map(graft_error, grid$family, grid$kappa_a, grid$gamma))
  print(gr, row.names = FALSE, digits = 4)

  cat("\n=== structural error of STC's conditional transport, same cells ===\n")
  st <- do.call(rbind, Map(stc_structural_error, grid$family, grid$kappa_a, grid$gamma))
  print(st, row.names = FALSE, digits = 4)

  cat(sprintf("\nworst graft bias in Delta: %+.4f months\n", gr$graft_bias_delta[
    which.max(abs(gr$graft_bias_delta))]))
  cat(sprintf("worst STC structural bias:  %+.4f months\n", st$stc_structural_bias[
    which.max(abs(st$stc_structural_bias))]))
  cat(sprintf("self-check (graft where it is exact, must be 0): %.2e\n",
              max(abs(gr$selfcheck_zero))))
  saveRDS(list(graft = gr, stc = st), "results/graft-error.rds")
  cat("\nwritten: results/graft-error.rds\n")
}
