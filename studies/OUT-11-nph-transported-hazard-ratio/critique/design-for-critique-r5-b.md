# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART B OF 7: E1 and E2, the anchored contrast, rebuilt this round

You are reviewing a protocol revised four times. Round one returned `unsound`,
round two `unsound`, round three `unsound`, round four `unsound`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
`round4_resolution` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

## 5. E1: the censoring dependence, computed

Round 1 established that the first design's centerpiece was a theorem. Struthers and Kalbfleisch
(Biometrika 1986, doi:10.2307/2336212) and Xu and O'Quigley (Biostatistics 2000,
doi:10.1093/biostatistics/1.4.423) show that a misspecified proportional-hazards fit converges to a
least-false parameter that is a censoring- and event-weighted average of the time-varying contrast.
Non-movement is asymptotically impossible under non-proportional hazards, so the effect is
**sized**, not tested. The least-false constant log hazard ratio solves

$$\int f_1 = \int \frac{r_1 e^{\beta}}{r_0+r_1e^{\beta}}(f_0+f_1),
\qquad r_k = \pi_k\bar S_k\bar G,\quad f_k = r_k\bar h_k,$$

with $\pi_k = 0.5$ and $\bar G$ the exponential-plus-administrative censoring survival of the
regime, both registered in `R/00-config.R`. Verified against a Cox fit at 400,000 per arm: worst
disagreement 0.0031 on the log scale.

This solves **one leg**. The reported quantity is the Bucher difference of two such roots, each
evaluated **in its own study**, under its own baseline hazard and its own censoring:
$\hat\beta_{B/A} = \beta^*_{B/\text{PBO}}(\bar G_2) - \beta^*_{A/\text{PBO}}(\bar G_1)$.

**Four regimes, crossed independently over the two studies**, giving a $4\times 4$ grid: rate
0.010, 0.050, 0.100 at cutoff 36, and rate 0.020 at cutoff 18. The truth is held exactly fixed
across all sixteen by construction, since censoring touches no survival function.

**The leg decomposition is exact and is the cleanest check in the study.** Each leg's censoring
dependence tracks *its own* non-proportionality and nothing else: leg A's spread is 0.62% in every
cell with $\kappa_A = 0$ whatever $\kappa_B$ does, and 16.08% in both cells with $\kappa_A = 0.30$.
A leg cannot be moved by the other study's parameters, and the computation confirms it rather than
assuming it.

**Reported as a factorial with an interaction term, not as an additive decomposition.** Round 2
was right that the least-false root is nonlinear, so the two pathways to marginal
non-proportionality do not add. The computed table shows it sharply: raising $\gamma$ from 0 to
0.50 adds **3.26 points** of spread at $\kappa_B = 0$ but only **0.49 points** at
$\kappa_B = 0.30$ (17.39% to 17.88%). Under additivity both increments would be 3.26.

The prespecified claims are the two ablations, which are exact:

- $\gamma = 0$ **and** $\kappa_B = 0$ gives zero movement (computed: $2.6\times10^{-9}$).
- $\gamma > 0$, $\kappa_B = 0$, covariate spread collapsed to zero gives zero movement (computed:
  $2.1\times10^{-9}$).

## 6. E2: finite-sample behavior of the anchored contrast

Round 3 was right that version 3 left this experiment as prose: it named neither its family, nor
its $\beta_B$, nor its $\gamma$, nor its treatment contrast. All of it is now in `R/00-config.R`
alongside E1's grids, which were likewise only function defaults.

Registered: Weibull; $\kappa_A \in \{0, 0.30\}$ crossed with $\kappa_B \in \{0, 0.15, 0.30\}$;
$\gamma = 0.30$; $\beta_B$ solved to the same registered `recommend` margin as E3, so the truth is
the same 0.75 months in every cell; **250 per arm in the A leg and 200 in the B leg**, the
benchmark's own study sizes; **all four censoring regimes, crossed independently**; 2,000
replicates per cell per leg per regime.

Each replicate builds **two independent two-arm studies** and fits one unadjusted Cox model in
each, so the experiment costs `coxph` fits and runs in minutes. The legs are simulated once per
regime and reused across every crossing, which is both cheaper and more faithful: leg A's data
cannot depend on the follow-up of a trial it was not part of. Common random numbers are used across
regimes *within* a leg and never *between* legs, since two independent trials is what an indirect
comparison has and coupling them would manufacture a correlation the Bucher variance assumes away.

Two things are reported, answering different questions.

**Does the E1 limit hold in finite samples?** Over all 96 registered regime pairs the worst
absolute discrepancy between the simulated mean and the analytic limit is **0.0141** on the log
scale, at most 3.01 times its own Monte Carlo standard error, and the Bucher 95% interval covers
the E1 limit **0.937 to 0.958** of the time against a nominal 0.95. E1 is therefore checked, not
merely asserted. This is emphatically *not* evidence that the interval covers the estimand: a Wald
interval around a least-false parameter is correctly centered on that parameter and on nothing
else, which is the whole problem.

**Could an analyst notice?** The regime-induced shift reaches **0.876 sampling standard deviations
of a single reported estimate**, and it is larger with the two trials' follow-up crossed (0.876)
than matched (0.722). Yet two analysts holding independent evidence sets under different follow-up
would call their anchored estimates significantly different only **10.5%** of the time against a
nominal size of 5%. The movement is nearly as large as the noise on any one estimate and the
obvious test for it has almost no power, which is the combination that makes this failure mode
survive review.


# THE ANCHORED LIMIT, VERBATIM

```r
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
## leg A the target baseline understated its censoring spread (16.08% against
## 17.27% measured correctly at kappa_A = 0.30, Weibull).
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
```
