## ---------------------------------------------------------------------------
## The least-false parameter of an ANCHORED INDIRECT comparison.
##
## Round four found that E1 and E2 were computing the wrong quantity, and it was
## right. They evaluated cox_limit(A, B): the coefficient a direct head-to-head
## trial of B against A would report. OUT-11 is about a TRANSPORTED ANCHORED
## INDIRECT comparison, assembled from a separate A-versus-placebo study and a
## separate B-versus-placebo study.
##
## These are not the same number, and not merely by sampling noise. Least-false
## Cox coefficients are NOT TRANSITIVE under non-proportional hazards: each leg
## is a censoring- and event-weighted average of its own time-varying contrast,
## with weights determined by that leg's own risk sets and its own censoring
## distribution. Subtracting two such averages does not give the average that a
## direct comparison would produce. Version 4 defended the head-to-head framing
## explicitly, and the defense was wrong.
##
## It also omitted the case the catalog entry cares about most: the two studies
## having DIFFERENT follow-up. That is now a crossed factor rather than a single
## shared censoring survival.
##
## EACH LEG IS EVALUATED IN ITS OWN STUDY, AT THE TARGET COVARIATE LAW.
##
## Version 5 initially evaluated both legs at the TARGET study's baseline hazard,
## describing that as "population adjustment assumed perfect". That is stronger
## than perfect population adjustment and no method delivers it. MAIC reweights
## the IPD study's patients and fits in the IPD study; STC fits a conditional
## model in the IPD study. Both leave the IPD study's BASELINE HAZARD in place,
## and the least-false Cox projection is weighted by risk sets, which the
## baseline determines. So leg A converges to its least-false value under the
## IPD study's own baseline and censoring, not the target's.
##
## The difference is not negligible and it is not a constant offset: at
## kappa_A = 0.30 it reaches 2.86% on the hazard-ratio scale and varies from
## 2.86% to 1.38% across the four censoring regimes, which is the same order as
## the non-transitivity gap that round four identified as a fatal error. Giving
## leg A the target baseline OVERSTATED its censoring spread: 17.27% against the
## 16.08% it actually has at kappa_A = 0.30, Weibull. (An earlier version of this
## comment had those two numbers the wrong way round and called the error an
## understatement. A reviewer caught the contradiction from the text alone.)
##
## What IS assumed perfect is the covariate adjustment: both legs are evaluated
## at the TARGET covariate law, mu = MU_TGT. That isolates the censoring
## dependence from covariate-adjustment error, which is what E3 measures
## separately. The residual baseline transport is not an assumption being made
## here; it is part of what the anchored estimator actually faces.
## ---------------------------------------------------------------------------

## Anchored log hazard ratio for B versus A, by Bucher, with each leg's
## least-false parameter computed under ITS OWN study and ITS OWN censoring.
## Each leg carries its own placebo arm because the two studies are two separate
## trials with two separate baselines and two separate placebo groups.
anchored_limit <- function(pbo_a, arm_a, pbo_b, arm_b, mu, sd,
                           rate_a, t_admin_a, rate_b, t_admin_b, alloc = ALLOC) {
  leg_a <- cox_limit(pbo_a, arm_a, mu, sd, rate_a, t_admin_a, alloc)   # A vs PBO, study 1
  leg_b <- cox_limit(pbo_b, arm_b, mu, sd, rate_b, t_admin_b, alloc)   # B vs PBO, study 2
  c(leg_a = leg_a, leg_b = leg_b, anchored = leg_b - leg_a)
}

## How far the anchored contrast moves when the two studies' censoring regimes
## vary INDEPENDENTLY, with the truth held exactly fixed throughout. The
## diagonal of this grid is the "both studies followed alike" case that version
## 4 mistook for the whole problem; the off-diagonal is the case an indirect
## comparison actually faces.
anchored_grid <- function(pbo_a, arm_a, pbo_b, arm_b, mu, sd,
                          regimes = CENS_REGIMES, alloc = ALLOC) {
  ## Leg A is the IPD study and takes rate_ipd; leg B is the aggregate study and
  ## takes rate_agd. The two columns hold identical values in every registered
  ## regime, so this is not a numeric change, but naming the right column is
  ## what keeps E1 and E2 comparing the same thing if either column ever moves.
  do.call(rbind, lapply(seq_len(nrow(regimes)), function(i)
    do.call(rbind, lapply(seq_len(nrow(regimes)), function(j) {
      v <- anchored_limit(pbo_a, arm_a, pbo_b, arm_b, mu, sd,
                          regimes$rate_ipd[i], regimes$t_admin[i],
                          regimes$rate_agd[j], regimes$t_admin[j], alloc)
      data.frame(regime_a = regimes$label[i], regime_b = regimes$label[j],
                 leg_a_hr = exp(v["leg_a"]), leg_b_hr = exp(v["leg_b"]),
                 anchored_hr = exp(v["anchored"]), row.names = NULL,
                 stringsAsFactors = FALSE)
    }))))
}

## Non-transitivity, quantified rather than asserted: the anchored contrast
## against the direct head-to-head coefficient, both under matched censoring.
## If these agreed, version 4's framing would have been harmless.
transitivity_gap <- function(pbo_a, arm_a, pbo_b, arm_b, mu, sd,
                             regimes = CENS_REGIMES, alloc = ALLOC) {
  do.call(rbind, lapply(seq_len(nrow(regimes)), function(i) {
    a <- anchored_limit(pbo_a, arm_a, pbo_b, arm_b, mu, sd,
                        regimes$rate_ipd[i], regimes$t_admin[i],
                        regimes$rate_agd[i], regimes$t_admin[i], alloc)
    ## The direct comparator is a head-to-head trial run in the TARGET
    ## population, which is the only place both treatments could be given.
    d <- cox_limit(arm_a, arm_b, mu, sd, regimes$rate_agd[i],
                   regimes$t_admin[i], alloc)
    data.frame(regime = regimes$label[i], anchored_hr = exp(a["anchored"]),
               direct_hr = exp(d), gap_pct = 100 * (exp(a["anchored"]) / exp(d) - 1),
               row.names = NULL)
  }))
}
