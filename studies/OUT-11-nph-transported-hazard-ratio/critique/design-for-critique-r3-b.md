# THE OPEN PROBLEM (catalog entry OUT-11, key sections)

## Statement

The transported hazard ratio remains the default reported quantity in survival indirect comparisons, and on the marginal scale it can be population-dependent and time-varying through risk-set selection, while under non-proportional hazards a fitted Cox coefficient is a censoring- and event-weighted constant summary of a time-varying contrast. A conditional hazard ratio under a proportional-hazards model is constant by definition, so the instability belongs to the marginal scale or to non-proportionality rather than to the coefficient as such. The recommended alternatives are not missing from software: multinma has shipped survival models since 0.6.0 with predict() types including survival, hazard, cumulative hazard, mean, median, quantile and restricted mean survival time, marginal_effects() returns RMST and survival-probability differences standardized to a target population, and auxiliary parameters can be stratified by treatment to relax proportional hazards. The gap is between available methods and prevailing practice, and in the absence of any simulation benchmark comparing these estimators against proportional-hazards MAIC and STC under crossing hazards and differential censoring.


# ROUND THREE OF PRE-RUN CRITIQUE, PART 2 OF 2

Rounds one and two both returned `unsound`. Nothing has been simulated yet.
Every round-two fatal was checked against the text before being accepted and all
were confirmed. This revision is a rebuild, not a patch: the network went from
four studies to two, the decision rule from a bias tolerance to an excess
recommendation-error rate, the data-generating mechanism is now numerically
locked, the integration order is measured rather than cited, and the flexible
ML-NMR estimator was replaced after implementation showed the registered one
cannot produce the study's estimand.

Round-two fatal findings, all claimed fixed: (1) four censoring regimes appeared
in the analysis sections but not in the cell matrix, replicate total or runtime;
(2) the DGM was not numerically locked; (3) a 0.5-month reimbursement threshold
was used as a 0.5-month bias tolerance while every cell sat 0.65 to 1.86 months
clear of it, so no tolerated error could change a recommendation; (4) pairwise
MAIC and STC cannot consume three aggregate studies.

Round-two serious findings, condensed: PH-versus-flexible columns changed
likelihood and basis as well as proportionality; equal knot counts do not equate
Royston-Parmar and M-spline flexibility; superpopulation estimand versus MAIC's
realized-sample target; no time-indexed calibration outcome; coverage
unresolvable with no inconclusive region; no priors or bootstrap interval type;
R-hat alone is not a sampler policy; the integration citation argued against the
choice it justified; the runtime omitted the bootstrap, which dominates; the two
sources of censoring dependence were called exactly separable when the
least-false root is nonlinear; no cell produced an in-window hazard crossing;
comparator authorship uncited; the novelty claim overclaimed.

THE PROTOCOL IS SPLIT ACROSS TWO REVIEWS BECAUSE OF PAYLOAD LIMITS. You are
reviewing SECTIONS 10 TO 14: the decision rules, the decision model, the limitations, the round-by-round change log, and feasibility. Judge only what is in front of you; do not report a section
as missing when it is simply in the other half. Material that is NEW and has never been critiqued: the excess recommendation-error rule and its noise floor, the disclosure of how its threshold was calibrated, and the measured runtime. For context, the design is a two-study anchored network (one IPD study comparing PBO with A, one aggregate study comparing PBO with B which defines the target population), 12 cells at 40 replicates, seven estimators, primary estimand the target-population marginal RMST difference between B and A at 18 months, truth computed by quadrature.

Add `round2_resolution` to your JSON for any round-two finding this half bears
on: a list of {"finding":"short label","resolved":"yes|partly|no","note":"..."}.

## 10. Prespecified decision

### 10.1 Why version 2's rule could not fire

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
| No cell produced an in-window hazard crossing | serious | **Confirmed against version 2.** Resolved as a side effect of solving $\beta_B$ to a decision margin; crossings now at 6 to 14 months, section 8 |
| The 500-resample bootstrap is plausibly the dominant cost and was called "cheap" unmeasured | serious | **Confirmed, and it is.** Measured at 0.658 s per resample, which is 11.0 hours against roughly 3 hours of Stan; section 14 |
| Comparator authorship uncited, so the fairness guarantee is unauditable | citation | Six attributions added and CrossRef-verified, section 7.2 |
| "Nobody appears to have quantified it" overclaims against the marginal-HR literature | citation | **Confirmed.** Hernán 2010, Aalen et al. 2015 and Stensrud and Hernán 2020 cited; the claim narrowed to the censoring-regime dependence, section 12 |
| $\gamma$'s role ambiguous between prognostic and treatment-specific | minor | $\gamma$ stated as shared across A and B, with the consequence that it cancels from the B-versus-A contrast, section 3 |
| MAIC mean-matching transports a same-variance normal exactly, unremarked | minor | Recorded in section 7.2, with the reason both moments are matched anyway |

## 14. Feasibility, measured

Measured on this machine, the two-study network at 900 rows, 2 chains of 1,000 iterations, one fit
at a time unless noted.

| step | measured cost |
|---|---|
| ML-NMR flexible fit, 32 integration points | 45 s |
| ML-NMR flexible fit, 64 points | 74 s |
| ML-NMR flexible fit, 128 points | 167 s |
| ML-NMR flexible fit, 256 points | 369 s |
| all five frequentist estimators, one replicate | 0.77 s |
| **one bootstrap resample, all five frequentist rows** | **0.658 s** |

**The bootstrap is the dominant cost, and round 2 was right to refuse the word "cheap."** At 500
resamples over 480 replicates it is 43.9 core-hours, which is 5.5 hours on eight workers. It
parallelizes to all eight logical cores because it is single-threaded R with no Stan in it, unlike
the ML-NMR fits, which already use their cores for chains.

Stan, 960 fits for 480 replicates at two arms each, expressed in core-hours so the concurrency
assumption is visible rather than buried:

| integration order | core-hours | wall clock on 8 logical cores | total with bootstrap |
|---:|---:|---:|---:|
| 64 | 39.5 | 4.9 h | **10.4 h** |
| 128 | 89.1 | 11.1 h | **16.6 h** |

**The integration order is the one number still outstanding, and the reason is a flaw in the first
attempt to measure it.** A three-replicate sweep over 32, 64, 128 and 256 points produced a
monotone increase in the estimate, which looked like quadrature error. It is not yet decisive,
because each order is a **separate MCMC run**: at the observed posterior SD near 0.75 and effective
sample size near 250, each posterior mean carries a Monte Carlo standard error near 0.047, while
the order-to-order differences were 0.02 to 0.07. The measurement was the same size as its own
noise.

The replacement, running now, compares orders **paired within replicate** on the same simulated
data across 8 replicates, which puts the standard error of the paired difference near 0.024, and
records the Monte Carlo standard error of each derived estimand rather than a global minimum ESS
over unrelated nuisance parameters. The decision rule is registered here in advance of the result:
**the lowest order whose paired difference from the 256-point reference is below 0.02 months**, one
fortieth of the per-replicate standard deviation and well below the smallest bias the study needs
to resolve. If no order below 256 qualifies, the replicate count is cut rather than the order,
because an integration bias is systematic and does not average out over replicates while a
replicate shortfall only widens intervals.

This matters more than it might appear. `multinma`'s default is `n_int = 64L`, and IDN-05 in this
same program found that moving from 64 to 256 changed 8.3% of its DIC verdicts while recording that
256 was not itself shown to be converged. If 64 proves insufficient for a target-standardized RMST
difference from a flexible survival ML-NMR, that is a result about the package default and is
reported as one.

The bootstrap runs on the frequentist rows only. A refit budget of 10% is assumed for replicates
that fail the sampler policy; failures are recorded, not silently dropped.
