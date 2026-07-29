## ---------------------------------------------------------------------------
## Turns the design factors into locked numbers, and reports every quantity a
## reviewer asked to see before the run:
##
##   * beta_B solved so the true target RMST difference lands on a registered
##     margin relative to the decision threshold (so the decision rule can fire)
##   * conditional and target-marginal crossing times
##   * Grambsch-Therneau rejection rate at every retained kappa (detectability)
##   * event fractions and the probability of remaining at risk at TAU
##   * the true marginal hazard-ratio range, and the Cox projection per regime
##
## The previous protocol asserted "kappa was calibrated against a named
## detectability standard" while reporting the rejection rate at kappa = 0 only.
## This file reports it at every level and writes the table the protocol quotes.
## ---------------------------------------------------------------------------

source("R/00-config.R")
source("R/01-dgm.R")
source("R/02-cox-limit.R")
source("R/02b-anchored-limit.R")

## --- solve beta_B for a registered true RMST margin --------------------------
## The estimand is target-standardized: BOTH arms are evaluated at the TARGET
## study's baseline and the TARGET covariate law. That is what "if both
## treatments were given in the target population" means, and it is the only
## reading under which all six estimators target the same thing.
truth_delta <- function(family, beta_b, kappa_b, gamma, tau = TAU,
                        kappa_a = KAPPA_A) {
  a <- make_arm(family, "tgt", beta = BETA_A, kappa = kappa_a, gamma = gamma)
  b <- make_arm(family, "tgt", beta = beta_b,  kappa = kappa_b, gamma = gamma)
  rmst_marg(tau, MU_TGT, SD_X, b) - rmst_marg(tau, MU_TGT, SD_X, a)
}

solve_beta_b <- function(family, kappa_b, gamma, target_delta,
                         kappa_a = KAPPA_A) {
  f <- function(bb) truth_delta(family, bb, kappa_b, gamma, TAU, kappa_a) - target_delta
  lo <- -2.5; hi <- 1.0
  if (f(lo) * f(hi) > 0)
    stop(sprintf("no beta_B bracket for %s kappa=%.2f gamma=%.2f delta=%.2f",
                 family, kappa_b, gamma, target_delta))
  uniroot(f, c(lo, hi), tol = 1e-10)$root
}

## --- descriptive properties of one locked cell -------------------------------
cell_properties <- function(family, beta_b, kappa_b, gamma,
                            cens = E3_CENS[1, ], n_ph = 400, n_rep_ph = 200,
                            kappa_a = KAPPA_A) {
  a <- make_arm(family, "tgt", beta = BETA_A, kappa = kappa_a, gamma = gamma)
  b <- make_arm(family, "tgt", beta = beta_b,  kappa = kappa_b, gamma = gamma)

  ## conditional B-vs-A contrast: beta_B - beta_A + kappa_B g(t). gamma cancels,
  ## so this does not depend on x, and the conditional crossing time is exact.
  g <- switch(family, weibull = function(t) log(t / T0),
                      gompertz = function(t) (t - T0) / T0)
  ## The contrast bends with kappa_B - kappa_A, not kappa_B: when the two are
  ## equal the target contrast is proportional even though both arms are not.
  dlt <- beta_b - BETA_A
  dk  <- kappa_b - kappa_a
  cond_cross <- if (dk == 0) NA_real_ else {
    tc <- switch(family, weibull  = T0 * exp(-dlt / dk),
                         gompertz = T0 * (1 - dlt / dk))
    if (is.finite(tc) && tc > 0 && tc < T_ADMIN) tc else NA_real_
  }

  ## target-marginal hazard ratio over the supported window
  grid <- seq(0.25, T_ADMIN, by = 0.25)
  hr   <- haz_marg(grid, MU_TGT, SD_X, b) / haz_marg(grid, MU_TGT, SD_X, a)
  s    <- sign(log(hr)); k <- which(diff(s) != 0)
  marg_cross <- if (length(k)) grid[k[1]] else NA_real_

  ## support: event fraction and probability still at risk at TAU
  G_tau <- exp(-cens$rate_agd * TAU) * (TAU < cens$t_admin)
  risk_a <- surv_marg(TAU, MU_TGT, SD_X, a) * G_tau
  risk_b <- surv_marg(TAU, MU_TGT, SD_X, b) * G_tau

  ## GRAMBSCH-THERNEAU POWER, PER LEG, AT EACH LEG'S OWN SAMPLE SIZE.
  ##
  ## Round 5 found that this was computed on a DIRECT B-versus-A trial at 400 per
  ## arm, and that no such trial exists in the simulated network. An analyst holds
  ## A-versus-placebo at N_IPD_ARM per arm and B-versus-placebo at N_AGD_ARM, and
  ## would run the diagnostic on each leg separately. That distinction is not
  ## cosmetic here: at kappa_A = kappa_B the direct contrast is exactly
  ## proportional and the direct test has no power at all, while BOTH legs are
  ## strongly non-proportional and their tests should fire. Reporting the direct
  ## test would have said "undetectable" about the cell where an analyst is most
  ## likely to notice something is wrong.
  ph_power <- function(arm_cmp, pbo_arm, n_arm, seed_off) {
    set.seed(SEED + seed_off + round(1e4 * (beta_b + kappa_b + gamma)))
    mean(vapply(seq_len(n_rep_ph), function(i) {
      x0 <- rnorm(n_arm, MU_TGT, SD_X); x1 <- rnorm(n_arm, MU_TGT, SD_X)
      d0 <- sim_arm(n_arm, x0, pbo_arm, cens$rate_agd, cens$t_admin)
      d1 <- sim_arm(n_arm, x1, arm_cmp, cens$rate_agd, cens$t_admin)
      d  <- rbind(cbind(d0, z = 0), cbind(d1, z = 1))
      fit <- try(survival::coxph(survival::Surv(time, status) ~ z, data = d),
                 silent = TRUE)
      if (inherits(fit, "try-error")) return(NA)
      zp <- try(survival::cox.zph(fit), silent = TRUE)
      if (inherits(zp, "try-error")) return(NA)
      zp$table["z", "p"] < 0.05
    }, logical(1)), na.rm = TRUE)
  }
  pbo_i <- placebo_arm(family, "ipd")
  a_i   <- make_arm(family, "ipd", beta = BETA_A, kappa = kappa_a, gamma = gamma)
  pbo_t <- placebo_arm(family, "tgt")
  rej_a <- ph_power(a_i, pbo_i, N_IPD_ARM, 0)        # IPD study, A vs placebo
  rej_b <- ph_power(b,   pbo_t, N_AGD_ARM, 1)        # aggregate study, B vs placebo

  data.frame(
    family = family, kappa_a = kappa_a, kappa_b = kappa_b, gamma = gamma,
    beta_b = beta_b,
    delta_rmst = truth_delta(family, beta_b, kappa_b, gamma, TAU, kappa_a),
    surv_diff  = surv_marg(T_STAR, MU_TGT, SD_X, b) -
                 surv_marg(T_STAR, MU_TGT, SD_X, a),
    cond_cross = cond_cross, marg_cross = marg_cross,
    hr_min = min(hr), hr_max = max(hr),
    ev_frac_a = 1 - risk_a, ev_frac_b = 1 - risk_b,
    at_risk_tau_a = risk_a, at_risk_tau_b = risk_b,
    ph_reject_leg_a = rej_a, ph_reject_leg_b = rej_b,
    stringsAsFactors = FALSE
  )
}

## --- the locked cell table ---------------------------------------------------
## E3, the expensive benchmark. Registered here; the protocol quotes this table.
build_cells <- function() {
  rows <- list()
  add <- function(fam, kap, gam, margin, arm, cens_labels, kap_a = 0) {
    bb <- solve_beta_b(fam, kap, gam, unname(MARGIN_LEVELS[margin]), kap_a)
    for (cl in cens_labels)
      rows[[length(rows) + 1L]] <<- data.frame(
        arm = arm, family = fam, kappa_a = kap_a, kappa_b = kap, gamma = gam,
        margin = margin, target_delta = unname(MARGIN_LEVELS[margin]),
        beta_b = bb, cens = cl, stringsAsFactors = FALSE)
  }
  ## primary: non-proportionality crossed with between-study differential
  ## follow-up in BOTH DIRECTIONS, effect size held at the same registered margin
  ## throughout so kappa moves proportionality alone. The reversed condition is
  ## new in version 5; see E3_CENS for why one sign was not enough.
  for (k in KAPPA_B_LEVELS)
    add("weibull", k, GAMMA, "recommend", "primary", E3_CENS$label)
  ## decision-margin arm: the same cells on the other side of the threshold, so
  ## recommendation errors can occur in both directions.
  for (k in c(0, 0.30))
    add("weibull", k, GAMMA, "decline", "margin", "balanced")
  ## marginal-PH control: gamma = 0 as well, so the marginal hazard ratio is
  ## constant and the proportional methods are correctly specified. If they do
  ## not win here the comparison is rigged and the paper says so.
  add("weibull", 0, 0, "recommend", "control", c("balanced", "differential"))
  ## IPD-side non-proportionality. Round three found that with kappa_A fixed at
  ## zero, the only contrast MAIC weighting and STC regression ever touch was
  ## exactly proportional in every cell, so the comparison the catalog entry
  ## asks for was never exercised. These cells put the bend where those methods
  ## have to model it.
  ##   kappa_A = 0.30, kappa_B = 0     : IPD side bends, aggregate side does not
  ##   kappa_A = 0.30, kappa_B = 0.30  : both arms bend, target contrast is
  ##                                     proportional, which version 3 could not
  ##                                     express at all
  ##
  ## These cells get ALL THREE censoring conditions as of version 5. Version 4
  ## gave them `balanced` only, so the two cells where the IPD-side contrast is
  ## non-proportional never saw differential follow-up at all. That is the same
  ## quarantine defect round 3 found when kappa_A was fixed at zero: the factor
  ## and the mechanism it acts on were never crossed. These are also the cells
  ## where E1 measures the largest movement, so they are the last place the
  ## factor should have been omitted.
  add("weibull", 0,    GAMMA, "recommend", "ipd-nph", E3_CENS$label, kap_a = 0.30)
  add("weibull", 0.30, GAMMA, "recommend", "ipd-nph", E3_CENS$label, kap_a = 0.30)
  ## family sensitivity
  for (k in c(0, 0.30))
    add("gompertz", k, GAMMA, "recommend", "family", "balanced")
  out <- do.call(rbind, rows)

  ## PARAM_ID IDENTIFIES THE PARAMETER CELL, NOT THE CENSORING VARIANT, AND THE
  ## NETWORK SEED IS KEYED ON IT.
  ##
  ## Round 6 found that E3 did not use common random numbers across censoring
  ## regimes, although the protocol says it does. R/07-run.R seeded each network
  ## on `cell_id`, which runs over all 21 cell-by-censoring ROWS, so the three
  ## censoring variants of one parameter cell drew three entirely different
  ## networks: different covariates, different event times, different censoring.
  ## The censoring comparison was therefore unpaired, carrying the variance of
  ## two independent networks where the design assumes one network censored two
  ## ways, and E1 puts the censoring effect at a fraction of a month, which is
  ## the scale that pairing exists to resolve.
  ##
  ## Keying on the parameter cell gives genuine common random numbers, because
  ## sim_arm draws event times BEFORE censoring times and rexp consumes the same
  ## stream whatever its rate. All three registered regimes have a positive rate,
  ## so no branch skips a draw and the streams stay aligned.
  out$param_id <- match(
    do.call(paste, c(out[, c("arm", "family", "kappa_a", "kappa_b", "gamma",
                             "margin")], sep = "|")),
    unique(do.call(paste, c(out[, c("arm", "family", "kappa_a", "kappa_b",
                                    "gamma", "margin")], sep = "|"))))
  out
}

## --- the two-source decomposition, recomputed under the locked config --------
## With gamma shared between A and B the conditional B-vs-A contrast has no
## covariate term at all, so any movement of the reported hazard ratio at
## kappa_B = 0 is pure risk-set selection on a PROGNOSTIC covariate. That is a
## stronger and cleaner statement than the previous draft's, which relied on a
## treatment-specific gamma.
decomposition <- function(family = "weibull",
                          kappas = c(0, 0.15, 0.30),
                          gammas = c(0, 0.15, 0.30, 0.50)) {
  do.call(rbind, lapply(kappas, function(k) do.call(rbind, lapply(gammas, function(g) {
    bb <- solve_beta_b(family, k, g, unname(MARGIN_LEVELS["recommend"]))
    ## ANCHORED, not direct: each leg IN ITS OWN STUDY, under its own regime,
    ## combined by Bucher, with the two study regimes crossed independently.
    ## Round four found the direct head-to-head coefficient is a different
    ## quantity from the one OUT-11 asks about, and that least-false
    ## coefficients are not transitive. Leg A sits in the IPD study because
    ## population adjustment reweights patients and leaves the baseline hazard
    ## alone; see the header of R/02b-anchored-limit.R.
    pbo_a <- placebo_arm(family, "ipd")
    a     <- make_arm(family, "ipd", beta = BETA_A, kappa = KAPPA_A, gamma = g)
    pbo_b <- placebo_arm(family, "tgt")
    b     <- make_arm(family, "tgt", beta = bb,     kappa = k,       gamma = g)
    gr <- anchored_grid(pbo_a, a, pbo_b, b, MU_TGT, SD_X)
    hr <- gr$anchored_hr
    data.frame(family = family, kappa_b = k, gamma = g, beta_b = bb,
               hr_ref = gr$anchored_hr[1],
               hr_spread = (max(hr) - min(hr)) / min(hr),
               hr_spread_diag = local({
                 dg <- gr$anchored_hr[gr$regime_a == gr$regime_b]
                 (max(dg) - min(dg)) / min(dg) }),
               stringsAsFactors = FALSE)
  }))))
}

## Ablation: hold gamma but collapse the covariate spread. Both ingredients are
## needed; removing either must give exactly zero movement.
decomposition_ablation <- function(family = "weibull", kappa = 0, gamma = 0.30) {
  do.call(rbind, lapply(c(1.0, 0.5, 1e-6), function(sdx) {
    bb <- solve_beta_b(family, kappa, gamma, unname(MARGIN_LEVELS["recommend"]))
    pbo_a <- placebo_arm(family, "ipd")
    a     <- make_arm(family, "ipd", beta = BETA_A, kappa = KAPPA_A, gamma = gamma)
    pbo_b <- placebo_arm(family, "tgt")
    b     <- make_arm(family, "tgt", beta = bb,     kappa = kappa,   gamma = gamma)
    hr <- anchored_grid(pbo_a, a, pbo_b, b, MU_TGT, sdx)$anchored_hr
    data.frame(sd_x = sdx, hr_spread = (max(hr) - min(hr)) / min(hr))
  }))
}
