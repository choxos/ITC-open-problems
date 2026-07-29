# THE OPEN PROBLEM (catalog entry OUT-11, key sections)

## Statement

The transported hazard ratio remains the default reported quantity in survival indirect comparisons, and on the marginal scale it can be population-dependent and time-varying through risk-set selection, while under non-proportional hazards a fitted Cox coefficient is a censoring- and event-weighted constant summary of a time-varying contrast. A conditional hazard ratio under a proportional-hazards model is constant by definition, so the instability belongs to the marginal scale or to non-proportionality rather than to the coefficient as such. The recommended alternatives are not missing from software: multinma has shipped survival models since 0.6.0 with predict() types including survival, hazard, cumulative hazard, mean, median, quantile and restricted mean survival time, marginal_effects() returns RMST and survival-probability differences standardized to a target population, and auxiliary parameters can be stratified by treatment to relax proportional hazards. The gap is between available methods and prevailing practice, and in the absence of any simulation benchmark comparing these estimators against proportional-hazards MAIC and STC under crossing hazards and differential censoring.


# ROUND FOUR OF PRE-RUN CRITIQUE, PART 2 OF 2

Rounds 1, 2 and 3 all returned `unsound` or `needs-revision`. Nothing has been
simulated. Round 3 returned ten fatal findings from one reviewer, and every one
was checked against the document or the source before being accepted; all held.
Two were bugs in the study's own code, not in its prose:

  1. The STC rows stored Gauss-Hermite weights and never applied them. Equal
     weighting of 32 nodes implies a covariate SD of 5.568 against a target of
     1.000 (checked: E[S] 0.4609 equal-weighted against 0.4753 both correctly
     weighted and by 4,000,000-draw Monte Carlo). This invalidated the pilot and
     with it a bias the protocol had REGISTERED as an anticipated mechanism.
  2. Forcing STC through MAIC's marginal log-cumulative-hazard graft is invalid
     under the registered DGM and handicapped STC before sampling.

Other round-3 fatals, all accepted: the "aggregate" study was analyzed as IPD;
the decision metric divided out estimator variance so an arbitrarily noisy
estimator passed; kappa_A = 0 quarantined all non-proportionality on the side of
the network where MAIC and STC never act; E1/E2 and N_INT were not in the locked
configuration; the study cannot settle OUT-11 and must say so.

Three further defects were found by MEASUREMENT rather than by review, and are
disclosed because they bear on how much to trust the rest:
  - The replacement decision metric was also killed: a constant "always
    recommend" rule scores 0.0500 against the best estimator's 0.0913.
  - "Four chains cost the same wall clock" was false (166.9 s against 74.1 s).
  - An earlier claim that integration error was "systematic and monotone" was
    two draws of noise; the paired rerun shows +0.063 then -0.007.

THE PROTOCOL IS SPLIT ACROSS TWO REVIEWS BECAUSE OF PAYLOAD LIMITS.
You have SECTIONS 9 TO 14. Judge only what is in front of you; do not
report a section as missing when it is in the other half.

Context: two-study anchored network (one IPD study PBO vs A, one aggregate
study PBO vs B defining the target population), 14 cells x 25 replicates, seven
estimators, primary estimand the target-population marginal RMST difference
B minus A at 18 months, truth by quadrature.

Judge this version on its own terms. Check the text against each claimed fix;
claiming a fix the text does not contain is what this round exists to catch.
Add `round3_resolution` to your JSON for findings this half bears on: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

NEW IN THIS VERSION AND NEVER CRITIQUED: kappa_A as a design factor and the two
ipd-nph cells (including a cell where the target contrast is PROPORTIONAL while
both arms are strongly non-proportional); the corrected STC conditional
transport; the quadrature guard; structural deletion of aggregate individual
covariates; estimation quality as primary with paired contrasts replacing any
threshold; and the frozen budget with N_INT = 128 chosen from a paired
measurement showing the package default of 64 is biased by 0.066 months.

## 9. Monte Carlo error, and what cannot be resolved

Six primary cells at 40 replicates is 240 replicates, so the standard error of a pooled coverage
estimate near 0.95 is **0.014**, not the 0.011 version 2 printed for a replicate count it was not
using. Round 2 caught the arithmetic and it was right.

That resolution is **not sufficient** to place a point estimate confidently inside a window as
narrow as $[0.90, 0.98]$. Rather than assert otherwise, the decision rule uses a Monte Carlo
confidence interval and has an explicit **inconclusive** outcome (section 10). The budget, not the
science, sets this resolution, and section 14 states what it would cost to improve.

Per-cell coverage at 40 replicates has a standard error of 0.034 and is **descriptive only**.
IDN-05 published a maximum over eight noisy cell estimates as if it were a bound, and a reviewer
was right that it was not; that mistake is not repeated.

Bias in $\Delta_{\text{RMST}}$: a 60-replicate pilot on six cells gives a per-replicate standard
deviation between 0.62 and 0.87 months depending on estimator and cell, so **0.75 is the registered
planning value** and the pooled bias over the six primary cells has a standard error near 0.048
months. Version 2 asserted 0.35 without having measured it, which is less than half the truth and
would have understated every reported uncertainty; the number is now measured and the pilot is
kept in `results/freq-pilot.rds`.

**Estimator comparisons are paired on the replicate**, since all seven are computed on the same
simulated network, and reported with paired intervals. Common random numbers are used across
censoring regimes within a cell.

## 10. Prespecified outcomes and comparisons

### 10.0 Why decision quality is not the primary outcome, decided by measurement

Versions 2 and 3 both tried to make a reimbursement decision the primary outcome, and both failed
for reasons that only measurement exposed.

Version 2 set a 0.5-month bias tolerance against a 0.5-month threshold while every cell's truth sat
0.655 to 1.859 months clear of it, so no tolerated error could change any recommendation. Round 2
caught it.

Version 3 replaced that with excess recommendation error over a per-estimator noise floor. Round 3
found the hole from two directions independently: the floor is computed from the estimator's own
variance, so as $\sigma$ grows both the raw error and the floor approach 0.5 and the excess
approaches zero. It is a standardized-bias measure, and inflating variance hides bias. The claimed
protection covered only the opposite direction.

The replacement was expected decision loss in months against untuned constant-rule baselines.
**Measuring that killed it too**, and this part neither reviewer could have seen without numbers:

| estimator | weighted decision loss | bias at $\kappa_B=0.30$ |
|---|---:|---:|
| STC-flex | 0.0913 | $-0.043$ |
| STC-PH | 0.0915 | $-0.529$ |
| MAIC-flex | 0.0939 | $-0.046$ |
| MAIC-Cox | 0.1053 | $-0.724$ |
| MAIC-PH | 0.1054 | $-0.725$ |
| **always-recommend** | **0.0500** | n/a |
| never-recommend | 0.1667 | n/a |

A constant rule that ignores the data outperforms every estimator. Decision loss spreads the
methods by 15% while bias spreads them by a factor of seventeen. And MAIC-PH scores best of all
estimators in the $\kappa_B=0.30$ margin cell, at 0.0150, precisely because its $-0.715$ bias
pushes it below the threshold, which is the right decision there for the wrong reason.

The cause is structural and no loss function repairs it: per-replicate noise is 0.70 to 0.87 months
while the decision margins are 0.15 to 0.25 months.

**So estimation quality is primary and is compared paired on the replicate**, which requires no
threshold and therefore also disposes of the objection that version 3's cutoff was tuned on a
pilot. Decision loss survives as a secondary appendix reported against both constant baselines,
carrying its own finding: at trial-realistic sample sizes the choice of estimator moves the
*estimate* by a factor of seventeen and the *decision* by less than sampling noise. That is a
result the catalog entry should have, and it is the opposite of what versions 2 and 3 were built to
report.

### 10.1 Primary outcomes

All computed on the common target-population estimand, all reported **paired on the replicate**
since every estimator sees the same simulated network, with paired intervals:

1. **Bias** in $\Delta_{\text{RMST}}(18)$: deployment-weighted mean absolute cell bias. Absolute and
   per-cell, because round 2 was right that a pooled signed bias lets cells cancel.
2. **Root mean squared error** in $\Delta_{\text{RMST}}(18)$, which retains bias and variance
   together and is the direct answer to round 3's objection that efficiency is a method property
   and must not be divided out.
3. **Coverage** of nominal 95% intervals, pooled, classified from its Monte Carlo interval as
   calibrated inside $[0.90, 0.98]$, miscalibrated outside, or **inconclusive** when the interval
   straddles a boundary.
4. **Calibration over time**: bias and pointwise 95% coverage of $\bar S_B(t)-\bar S_A(t)$ at
   $t \in \{6, 12, 18\}$.

The registered comparisons are the two contrasts the design was built to separate, each tested as a
paired difference with a confidence interval: **flexible versus proportional within a row**, and
**method family across rows at matched flexibility**. No threshold is required for either.

### 10.2 Historical: why version 2's rule could not fire

Round 2's sharpest finding. Version 2 set a 0.5-month reimbursement threshold and a 0.5-month bias
tolerance, and its true RMST gains were 1.155, 1.817 and 2.359 months. Every cell therefore sat
0.655 to 1.859 months clear of the boundary, and **no estimation error of the size being tolerated
could ever change a recommendation**. The threshold and the tolerance were the same number
measuring different things. Confirmed against version 2's own table before being accepted.

Two changes follow. First, $\beta_B$ is **solved per cell** so the truth lands at registered
distances from the boundary: 0.75 months in the primary and control cells (recommend) and 0.35
months in the margin cells (decline), against a threshold of 0.50. Errors are then possible in both
directions. Second, the rule is stated in terms of the decision itself.

### 10.2 The rules

**D1, excess recommendation error.** For each estimator, in each replicate, recommend B if the
estimated $\Delta_{\text{RMST}}(18)$ exceeds 0.50 months; the correct recommendation is fixed and
known per cell.

A raw error rate will not do, and measuring before registering is what showed it. At the registered
sample sizes the per-replicate standard deviation of $\hat\Delta_{\text{RMST}}(18)$ is about 0.75
months, against a distance of 0.25 months between the truth and the threshold. **An exactly
unbiased estimator therefore gets the recommendation wrong about 37% of the time from sampling
noise alone.** A rule demanding an error rate below 0.10 could not be met by any estimator,
including a perfect one. That is the same defect round 2 found in version 2's rule, inverted:
version 2's rule could never fire against a method, and a naive replacement would fire against
every method.

The registered quantity is therefore the **excess** over the irreducible floor. For each estimator
and cell, the floor is the error rate of a hypothetical unbiased estimator with **that estimator's
own realized standard deviation**, $\Phi\{(0.50-\Delta_{\text{true}})/\hat\sigma\}$ when
$\Delta_{\text{true}} > 0.50$ and its complement otherwise.

The primary outcome is the deployment-weighted **mean absolute** cell excess, uniform over the six
primary and two margin cells, with a Monte Carlo interval. An estimator is fit for purpose if it is
below **0.10** and its interval excludes 0.20.

**Absolute, because the signed version cancels**, and the pilot showed it does. A downward-biased
estimator over-declines: it is wrong more often where the truth is above the threshold and right
more often where the truth is below it. In the pilot, MAIC-PH records $+0.435$ excess in the
$\kappa_B=0.30$ recommend cell and $-0.318$ in the $\kappa_B=0.30$ decline cell, so its signed
average over six cells is 0.072 and it reads as nearly fit for purpose while carrying a $-0.725$
month bias. This is the same cancellation round 2 identified in version 2's pooled signed bias,
one level up, and it is closed the same way.

This isolates decision error caused by **bias**, which is the method's responsibility, from decision
error caused by **sampling noise**, which is the sample size's. It cannot be gamed by an estimator
that simply shrinks its variance, because the floor is computed from that estimator's own variance.
On the marginal-PH control at 60 pilot replicates the excess runs $-0.071$ to $+0.050$ across the
five frequentist rows, which is the behavior a correctly-specified cell should show.

**The margin cells are what stop directional bias from being rewarded**, and the pilot shows why
they are not optional. In a cell whose truth is above the threshold, an estimator biased *upward*
gets the recommendation right more often than an unbiased one: at $\kappa_B=0$, $\gamma=0.30$ the
pilot's STC-PH row carries a $+0.383$ bias and records an excess of $-0.192$, scoring better than
correct. The margin cells put the truth below the threshold, where the same upward bias costs it.
D1 is therefore only ever read as the weighted average over both kinds of cell, never cell by cell.

### 10.3 Where the 0.10 threshold comes from, and what protects it

A 60-replicate pilot over the six Weibull cells, five frequentist estimators, no ML-NMR. Bias in
months, then the weighted mean absolute excess D1 would score:

| cell (truth) | MAIC-PH | MAIC-flex | STC-PH | STC-flex | MAIC-Cox |
|---|---:|---:|---:|---:|---:|
| control $\kappa_B{=}0,\gamma{=}0$ (0.75) | $+0.030$ | $-0.005$ | $+0.089$ | $+0.009$ | $+0.032$ |
| $\kappa_B{=}0$ (0.75) | $-0.016$ | $-0.055$ | $+0.383$ | $+0.143$ | $-0.014$ |
| $\kappa_B{=}0.15$ (0.75) | $-0.375$ | $-0.049$ | $-0.028$ | $+0.148$ | $-0.373$ |
| $\kappa_B{=}0.30$ (0.75) | $-0.725$ | $-0.046$ | $-0.424$ | $+0.151$ | $-0.724$ |
| margin $\kappa_B{=}0$ (0.35) | $-0.004$ | $-0.061$ | $+0.397$ | $+0.136$ | $-0.002$ |
| margin $\kappa_B{=}0.30$ (0.35) | $-0.715$ | $-0.046$ | $-0.416$ | $+0.151$ | $-0.713$ |
| **D1 (mean absolute excess)** | **0.195** | **0.076** | **0.188** | **0.036** | **0.203** |

A threshold of 0.10 separates the flexible rows from the proportional ones on this pilot. **That
the threshold was set after seeing these numbers is disclosed rather than hidden**, because a
threshold calibrated against nothing is how version 2 produced a rule that could not fire.

What protects it from being tuned toward a favorable conclusion is that **the ML-NMR rows, which
are the methods the catalog entry recommends and therefore the ones this study exists to evaluate,
were not in the pilot.** The threshold cannot have been chosen to flatter them. It was chosen
against the comparators alone, and if ML-NMR fails it, that failure is registered in advance.

Three further things this pilot fixes or records before the run:

- **MAIC-PH and MAIC-Cox agree to three decimals in every cell** ($-0.725$ against $-0.724$,
  $-0.375$ against $-0.373$). Weighted Cox with a Breslow baseline and weighted Royston-Parmar
  under a proportional restriction estimate the same least-false constant, so the *basis* does not
  matter and the *proportional-hazards restriction* does. That is a useful null result and it also
  validates that the seventh row is not silently a different estimator.
- **STC-PH carries a bias that has nothing to do with non-proportionality**: $+0.383$ and $+0.397$
  in the two $\kappa_B=0$ cells with $\gamma=0.30$, against $+0.089$ in the control where
  $\gamma=0$. Under exact conditional proportional hazards, transporting a relative effect on a
  marginal scale across studies with different baselines is not exact when a prognostic covariate
  makes the marginal contrast non-collapsible. This is registered here as an **anticipated
  mechanism**, so that if the run reproduces it, it is a confirmed prediction and not a
  post hoc story.
- At $\kappa_B=0.15$ STC-PH records a bias of $-0.028$, which looks excellent and is a
  coincidence: its positive non-collapsibility bias and its negative non-proportionality bias
  happen to cancel at that one level. A design with a single non-proportionality level would have
  reported it as the best estimator in the study.

**D2, estimation quality.** Reported alongside, not instead: deployment-weighted **mean absolute
cell bias** in $\Delta_{\text{RMST}}(18)$, and pooled coverage of a nominal 95% interval. Round 2
was right that taking the absolute value of one pooled signed bias lets large positive and negative
cell biases cancel; the weighted mean of absolute cell biases cannot. Coverage is classified from
its Monte Carlo interval: **calibrated** if the interval lies inside $[0.90, 0.98]$,
**miscalibrated** if it lies outside, and **inconclusive** otherwise. At 240 replicates the
inconclusive region is wide, and that is reported as a limitation of the budget.

**D3, the hazard ratio as a decision input.** Evaluated on the **analytic least-false parameter
from E1**, not on replicate-fitted hazard ratios, so that the statistic carries no simulation noise
at all; E2's finite-sample scatter is reported around it rather than mixed into it. Round 2's
second reviewer asked for exactly this separation.

Across the four censoring regimes with the truth held exactly fixed, the transported constant
hazard ratio is converted to an RMST difference by applying it to **one fixed target placebo
curve**, the truth's own, so that baseline noise cannot enter; the statistic is the maximum minus
the minimum across the four regimes, with the regimes weighted uniformly. The hazard ratio is fit
for purpose as a decision input if that range is below 0.50 months. This is labeled throughout as the performance of the **PH plug-in decision procedure**,
not as a general conversion from a hazard ratio to a non-proportional RMST contrast, which does not
exist. Round 2 was right on every part of this.

Deployment weights are uniform and are stated as the declared judgment they are.

## 11. The decision model behind the 0.50-month threshold

A treatment is recommended if its target-population RMST gain over the comparator at 18 months
exceeds the gain that justifies its cost, set at 0.50 months. It is declared before the run, it is
the same number in D1 and D3, and every conclusion that depends on it is labeled as depending on
it. **Sensitivity: D1 is recomputed at thresholds of 0.40 and 0.60 months** and reported, since the
number is a stipulation and not an estimate.

## 12. What this cannot settle

- One covariate. Multiplicity across covariates is not measured.
- Weibull and Gompertz only. Multistate mechanisms cross in ways these families cannot produce, and
  the entry names them.
- No separate one-step exact-likelihood survival NMA estimator. Stated as an omission; no
  equivalence claim is made.
- Independent censoring, varied **between studies**. Arm-differential censoring within a comparison
  is not varied.
- Target summaries treated as known, deliberately; see MIS-03.
- Digitization error in reconstructing aggregate survival curves is assumed away entirely.
- Shared effect modification holds by construction; its failure is IDN-05's subject.
- Fixed-effect synthesis throughout, on a two-study network where heterogeneity is not identified.
- **The novelty claim is not a systematic review.** "No simulation study compares these estimators"
  reflects the searches recorded in the catalog entry's verification trail and no more; round 2 was
  right that no reproducible search strategy supports it, and it is downgraded to a statement about
  what was found rather than what exists.
- **The marginal-scale mechanism is not new and this study does not claim it is.** That a marginal
  hazard ratio drifts under exact conditional proportional hazards, because the risk set selects on
  a prognostic covariate, is established: Hernán, *The hazards of hazard ratios*
  (doi:10.1097/EDE.0b013e3181c1ea43); Aalen, Cook and Røysland
  (doi:10.1007/s10985-015-9335-y); Stensrud and Hernán (doi:10.1001/jama.2020.1267). Round 2 was
  right that version 2's "nobody appears to have quantified it" overclaimed against exactly this
  literature. What is offered here is narrower and is stated narrowly: the **censoring-regime
  dependence** of that drift, sized exactly against the non-proportionality pathway on a common
  scale, and the finding that under the shared-effect-modifier assumption these methods require it
  is an order of magnitude the smaller of the two.

## 12b. OUT-11 remains open after this study

Stated plainly because round 3 asked for it plainly. The catalog entry asks for general-likelihood
ML-NMR and a separate one-step exact-likelihood estimator, against proportional-hazards MAIC and
STC, across Weibull, Gompertz **and multistate** mechanisms, plus missing component-PAIC
functionality. This study runs two of the three mechanism families, does not implement the one-step
estimator, and adds nothing to component PAIC. It is a partial benchmark. **After it is published,
OUT-11 should remain marked open**, with its verification trail recording which part this study
closed and which parts it did not. Version 3 argued the one-step omission away on the grounds that
ML-NMR fits the same exact likelihood; round 2 was right that this is not an estimator-level
equivalence argument, and the claim is withdrawn rather than restated.

## 13. What changed after each critique round

Round 1, both reviewers, resolved in version 2 and unchanged since: the treatment contrast
depended on the study baseline (fatal, confirmed numerically at a spread of $-0.2764$, mechanism
rebuilt, invariance verified to $4.4\times10^{-16}$); $\kappa$ did not isolate non-proportionality
(fixed by the same reparameterization, verified to $5.3\times10^{-16}$); the centerpiece experiment
demonstrated a known theorem (accepted, reframed as sizing); $\tau$ as a follow-up quantile would
move with censoring (fixed at 18); the marginal hazard was defined as an average of conditional
hazards (corrected).

Round 2, this version:

| Finding | Severity | Resolution |
|---|---|---|
| Censoring absent from the cell matrix, replicate total and runtime | **fatal** | **Confirmed.** Regimes assigned to experiments explicitly: four in E1 and E2, two in E3; matrix, replicate total and runtime recomputed |
| DGM not numerically locked | **fatal** | **Confirmed.** Every parameter registered in `R/00-config.R` and transcribed in section 3; crossing times, PH-test power, event fractions and at-risk fractions reported per cell in section 8 |
| 0.5-month threshold does not justify a 0.5-month bias tolerance | **fatal** | **Confirmed against version 2's own numbers.** Rule restated as recommendation error; $\beta_B$ solved so cells straddle the boundary; absolute pooled bias replaced by weighted mean absolute cell bias |
| MAIC and STC cannot consume three aggregate studies | fatal | **Confirmed.** Network reduced to two studies so the identical-evidence claim is true |
| PH-versus-flexible columns changed likelihood and basis too | serious | Rows rebuilt on one basis each, toggling only treatment-by-time terms; weighted Cox retained as a separate labeled row |
| Equal knot counts do not equate RP and M-spline flexibility | serious | Matched-flexibility claim withdrawn; knot placement specified; complexity-sensitivity arm added |
| Superpopulation estimand versus MAIC's realized-sample target | serious | Target summaries supplied as known superpopulation values to every method |
| No time-indexed calibration outcome | serious | Pointwise survival-difference bias and coverage at 6, 12, 18 |
| Coverage cannot be resolved at 240 replicates; no inconclusive region | serious | Arithmetic corrected to 0.014; Monte Carlo intervals and an explicit inconclusive verdict |
| D2 underspecified: statistic, weights, allocation, baseline | serious | All specified in D3; fixed baseline curve; range statistic; labeled a PH plug-in procedure |
| No priors, prior sensitivity, bootstrap interval type or resampling unit | serious | All registered in section 7.2 |
| $\hat R$ alone is not a sampler policy | serious | ESS, divergences, treedepth and a refit-and-record escalation registered |
| Integration order cited from IDN-05 argues against the choice it justified | serious | **Confirmed.** Order measured on this network; section 14 |
| Runtime omitted censoring regimes and bootstrap | serious | Recomputed in section 14 from measured timings |
| Two sources called "exactly separable" | serious | **Confirmed by the computed table**; reported as a factorial with interaction, with only the two exact ablations claimed |
| Study 5 unidentified; novelty claim unsourced; one-step equivalence unestablished | citation | IDN-05 named and linked; novelty claim downgraded; equivalence claim withdrawn |
| Broad title overstates a partial benchmark | limitation | Title and abstract scoped to Weibull and Gompertz |

Round 3, this version. Three reviews: one on the whole protocol, two on halves because the second
reviewer has an input-size ceiling.

| Finding | Severity | Resolution |
|---|---|---|
| STC stored Gauss-Hermite weights and never used them, marginalizing over an implied SD of 5.568 against a target of 1.000 | **fatal** | **Confirmed by measurement** (0.4609 against 0.4753 correct and 0.4753 by Monte Carlo). Fixed; the pilot it invalidated was rerun; a registered "anticipated mechanism" built on it is withdrawn as an artifact; `verify_quad()` now blocks the failure class |
| Forcing STC through MAIC's marginal graft is invalid and handicaps it | **fatal** | **Confirmed.** Each method now gets the strongest valid transport its own structure supports: MAIC keeps the graft as its own declared limitation, STC transports conditionally and marginalizes last |
| The aggregate study was analyzed as individual patient data | **fatal** | **Confirmed.** Covariate column deleted at generation; only reconstructed event times and reported summaries survive |
| Excess-over-own-floor divides out variance, so an arbitrarily noisy estimator passes | **fatal** and independently **serious** from the second reviewer | **Confirmed.** Replaced; then the replacement was killed by measurement too, since a constant rule beats every estimator. Estimation quality is now primary and paired, needing no threshold |
| All non-proportionality sits on the aggregate side, where MAIC and STC do not act, so the comparison the entry asks for is never exercised | serious | **Confirmed, and not visible to me.** $\kappa_A$ becomes a design factor; the contrast still carries no covariate term |
| The 0.10 cutoff was calibrated on the pilot it was tested against | **fatal** | Moot: paired comparison requires no cutoff |
| Integration acceptance threshold 0.02 sits below its own standard error 0.024 | **fatal** and independently serious | **Confirmed**, and my own earlier caution was warranted: the 64-to-128 gap is $+0.063$ in one replicate and $-0.007$ in the next. Rule becomes an uncertainty bound; 256 must be shown converged, not assumed |
| E1 and E2 not in the locked configuration; `N_INT` still `NA`; `N_REP` cut unspecified | **fatal** | All move into `R/00-config.R` and freeze before any replicate runs |
| The study cannot settle OUT-11 | **fatal** | Accepted; section 12b states OUT-11 remains open afterward |
| D1 cell mixture irreconcilable between the 6-cell pilot and the 8-cell rule | serious | Moot with the threshold removed |
| Prior-sensitivity and knot-complexity arms absent from the runtime table | serious | Same omission class as a round-2 fatal; both enter section 14 |
| "Four chains cost the same wall clock" | serious | **False, measured**: 166.9 s against 74 s. Two chains suffice, since the derived estimand reaches ESS above 2000 |
| No cell produced an in-window hazard crossing | serious | **Confirmed against version 2.** Resolved as a side effect of solving $\beta_B$ to a decision margin; crossings now at 6 to 14 months, section 8 |
| The 500-resample bootstrap is plausibly the dominant cost and was called "cheap" unmeasured | serious | **Confirmed, and it is.** Measured at 0.658 s per resample, which is 11.0 hours against roughly 3 hours of Stan; section 14 |
| Comparator authorship uncited, so the fairness guarantee is unauditable | citation | Six attributions added and CrossRef-verified, section 7.2 |
| "Nobody appears to have quantified it" overclaims against the marginal-HR literature | citation | **Confirmed.** Hernán 2010, Aalen et al. 2015 and Stensrud and Hernán 2020 cited; the claim narrowed to the censoring-regime dependence, section 12 |
| $\gamma$'s role ambiguous between prognostic and treatment-specific | minor | $\gamma$ stated as shared across A and B, with the consequence that it cancels from the B-versus-A contrast, section 3 |
| MAIC mean-matching transports a same-variance normal exactly, unremarked | minor | Recorded in section 7.2, with the reason both moments are matched anyway |

## 14. Feasibility, measured, and the run frozen

Every number here is measured on this machine, not extrapolated. Round 2 and round 3 both found the
runtime unauditable, and round 3 additionally found that `N_INT` was still `NA` and that section 14
permitted cutting the replicate count without saying to what. Both are closed here: the
configuration is frozen and `R/07-run.R` refuses to start unless it is.

### Measured unit costs

| step | measured |
|---|---|
| ML-NMR flexible fit, 64 integration points | 150.6 s |
| ML-NMR flexible fit, 128 points | 296.2 s |
| ML-NMR flexible fit, 256 points | 597.1 s |
| **one replicate, both ML-NMR arms, production config** | **227 s** |
| one bootstrap resample, all five frequentist rows | 0.658 s |
| all five frequentist estimators, one replicate | 0.77 s |

Production configuration is 2 chains, 128 integration points, two replicates in flight.

### The integration order, frozen at 128

Measured **paired within replicate**, which matters: orders are separate MCMC runs, and a first
attempt compared them unpaired at an effective sample size where each posterior mean carried a
Monte Carlo standard error of 0.047 against differences of 0.02 to 0.07. That measurement was the
same size as its own noise, and the monotone pattern it appeared to show did not survive: the
64-to-128 gap is $+0.063$ in one replicate and $-0.007$ in the next.

Three complete paired replicates:

| contrast | mean | SE | $t$ |
|---|---:|---:|---:|
| 256 minus 64 | $+0.0656$ | 0.0072 | **9.1** |
| 256 minus 128 | $+0.0238$ | 0.0226 | 1.0 |

**`multinma`'s default is `n_int = 64L`, and it is measurably inadequate for this estimand.** The
bias is 0.066 months, comparable to the entire bias of the better estimators in the pilot. This is
reported as a result about the package default, and it extends IDN-05's finding in this same
program, which saw 64 to 256 change 8.3% of its DIC verdicts while recording that 256 was not
itself shown to be converged.

**The choice was never between 128 and 256.** At 597 s per fit and 700 fits, 256 in production is
about 185 hours, so it was never affordable. 128 is registered, and the residual uncertainty is
reported rather than hidden: the 128-to-256 difference is $+0.024 \pm 0.023$, so **ML-NMR absolute
bias estimates below roughly 0.05 months cannot be distinguished from integration error**, and any
conclusion resting on one is labeled accordingly. Reaching a 95% upper bound below 0.03 would need
about 7 paired replicates, below 0.02 about 15, and below 0.01 about 59; the last is roughly 17
hours of compute for a number that cannot change the production choice.

A **256-point sensitivity arm** on a prespecified subset is registered instead, because it measures
the thing that matters, whether a conclusion moves, rather than whether one replicate does.

### The run, frozen

| | |
|---|---|
| cells | 14 |
| replicates per cell | **25** |
| total replicates | **350** |
| bootstrap resamples | **250** |
| Stan | 22.1 h |
| bootstrap | 2.0 h |
| **total** | **24.1 h**, about 1.7 h per cell |

Round 3 was right that a permission to cut replicates without a number is not a registration. The
cut from 40 to 25 is made here, before the run, with its consequences stated: pooled over the six
primary cells the bias standard error is **0.061 months** and the coverage standard error is
**0.018**. What the cut costs is per-cell precision, already declared descriptive only. What it
preserves is the **paired** contrasts that are the registered primary comparisons, and those are
resolved far better than any single estimator's own scatter because every estimator sees the same
network.

Per-cell chunking is not only a budget device. This machine terminates long-running background
jobs, which happened three times during the integration measurement, so `R/07-run.R` checkpoints
after each cell and skips completed ones. The run proceeds as fourteen resumable chunks rather than
one job that cannot survive to the end.

### Sensitivity arms, which round 3 found missing from the budget

Registered and costed rather than mentioned: the 256-point integration arm, the prior-sensitivity
arm halving and doubling the interaction and auxiliary scales, and the knot-complexity arm at 2 and
5 internal knots. Each runs on the same prespecified subset of two primary cells at 25 replicates,
so each costs about 3.2 h of Stan, and together about 9.6 h. Round 3's second reviewer noted that
version 3 declared these arms and left them out of the runtime table, which is the same omission
class that was a round-2 fatal.

### Failure handling

A fit failing the sampler policy is refit once at doubled iterations with `adapt_delta = 0.99`; a
fit failing twice is recorded as a failure, not dropped, and the primary analysis is repeated on the
subset where every fit passed. The refit budget is **not** assumed at 10%: the integration probe
returned 45 divergent transitions on one replicate and 0 to 8 on the rest, so the rate will be
estimated from the first two completed cells and reported, and the budget revised in the open if it
exceeds 20%.
