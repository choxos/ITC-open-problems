# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART E OF 7: the registered outcomes, and the decision rule that was withdrawn

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
while the decision margins are 0.15 to 0.25 months. Put concretely, with 0.75 as the registered
planning value for the per-replicate standard deviation and a truth sitting 0.25 months above the
threshold, **an exactly unbiased estimator gets the recommendation wrong 37% of the time from
sampling noise alone**. Any rule demanding a low raw error rate is unmeetable by a perfect
estimator, and any rule that subtracts the estimator's own noise floor divides out the variance it
should be penalizing. Version 3 tried the second and section 10.2b records why it failed.

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

The registered comparisons are each tested as a paired difference with a confidence interval, and
they are **not of equal standing**. Round 4 was right that version 4 registered them as if they
were.

**Primary: flexible versus proportional, within a row.** `MAIC-PH` against `MAIC-flex`, `STC-PH`
against `STC-flex`, `MLNMR-PH` against `MLNMR-flex`. Both members of each pair share an
implementation, a weighting or regression step and a code path, so the contrast isolates the
survival-model restriction, which is what this study is about. No threshold is required.

**Secondary and descriptive: method family across rows.** `MAIC-flex` against `MLNMR-flex`,
`STC-flex` against `MLNMR-flex`, `MAIC-PH` against `MLNMR-PH`. Version 4 registered these as
primary on the premise of **matched flexibility**, and round 4 caught that the same document had
already **withdrawn** that premise in round 2: a 3-knot Royston-Parmar spline and a 3-knot M-spline
do not carry the same effective flexibility, so an equal knot count does not equate the two. A
registered primary contrast cannot rest on a premise the protocol itself retracted.

These rows are therefore demoted to descriptive, and the effective degrees of freedom of each
fitted survival model is **recorded per replicate** so the eventual paper can report how far apart
the flexibilities actually were rather than assuming they matched. Registering the diagnostic now,
before the run, is what stops it from becoming a post hoc excuse for whichever way the comparison
falls.

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

### 10.2b Withdrawn: D1, excess recommendation error

Version 3 registered **D1**, the deployment-weighted mean absolute excess of an estimator's
recommendation-error rate over a floor computed from **that estimator's own realized standard
deviation**, with an estimator declared fit for purpose below 0.10. Round 3 killed it: because the
floor uses the estimator's own $\hat\sigma$, inflating variance drives both the raw error and the
floor toward 0.5 and the excess toward zero, so the rule is a standardized-bias measure in which
imprecision hides bias. The claim that it "cannot be gamed by an estimator that simply shrinks its
variance" was true and irrelevant; the exploitable direction is the other one.

**Version 4 said this was replaced and then kept registering it.** Section 10.2 still carried the
rule verbatim, still called it "the primary outcome" in direct contradiction of sections 10.0 and
10.1, still gated verdicts on the 0.10 and 0.20 cutoffs, and still repeated the one-directional
gaming claim that had already been conceded. Both round-4 reviewers found it independently. It is
deleted here rather than demoted, because a metric that was killed for being structurally unable to
measure what it claims should not continue issuing verdicts under any label.

Nothing replaces it in the primary position. Section 10.0 explains why: measurement showed that
**no** decision metric discriminates at these sample sizes, and estimation quality compared paired
on the replicate is the primary outcome. Decision loss survives only as the secondary appendix
described there, reported against both constant baselines and carrying its own negative finding.

The 0.10 cutoff is withdrawn with the rule. Round 3's separate objection, that the cutoff had been
calibrated on the same pilot it was then used to judge, is therefore moot rather than answered, and
version 4's answer to it (that the ML-NMR rows were held out of the pilot) is withdrawn too: a
holdout protects a threshold, and there is no longer a threshold.

### 10.3 What the pilot records, and a correction

A 60-replicate pilot over the six Weibull cells, five frequentist estimators, no ML-NMR. Bias in
months against the truth:

| cell (truth) | MAIC-PH | MAIC-flex | STC-PH | STC-flex | MAIC-Cox |
|---|---:|---:|---:|---:|---:|
| control $\kappa_B{=}0,\gamma{=}0$ (0.75) | $+0.030$ | $-0.005$ | $+0.021$ | $-0.062$ | $+0.032$ |
| $\kappa_B{=}0$ (0.75) | $-0.016$ | $-0.055$ | $+0.186$ | $-0.051$ | $-0.014$ |
| $\kappa_B{=}0.15$ (0.75) | $-0.375$ | $-0.049$ | $-0.176$ | $-0.046$ | $-0.373$ |
| $\kappa_B{=}0.30$ (0.75) | $-0.725$ | $-0.046$ | $-0.529$ | $-0.043$ | $-0.724$ |
| margin $\kappa_B{=}0$ (0.35) | $-0.004$ | $-0.061$ | $+0.198$ | $-0.058$ | $-0.002$ |
| margin $\kappa_B{=}0.30$ (0.35) | $-0.715$ | $-0.046$ | $-0.519$ | $-0.042$ | $-0.713$ |

**This table is a correction, and the correction is the point.** Version 4 printed the same table
with both STC columns carrying the values produced **before** the Gauss-Hermite weighting defect was
fixed in round 3: twelve numbers from code that had already been deleted for being wrong. Every
STC-flex entry had the wrong sign, published near $+0.15$ against a measured $-0.05$. The verifier
did not catch it because the export it checks against was an uncommitted one-liner that happened to
carry only the scalars and the solved $\beta_B$ values. That gap is closed in section 14.

Two of version 4's three stated pilot findings survive the correction. One does not:

- **MAIC-PH and MAIC-Cox agree to three decimals in every cell** ($-0.725$ against $-0.724$,
  $-0.375$ against $-0.373$). Weighted Cox with a Breslow baseline and weighted Royston-Parmar
  under a proportional restriction estimate the same least-false constant, so the *basis* does not
  matter and the *proportional-hazards restriction* does. A useful null result, and it also
  validates that the seventh row is not silently a different estimator.
- **STC-PH carries a bias that has nothing to do with non-proportionality**: $+0.186$ and $+0.198$
  in the two $\kappa_B=0$ cells with $\gamma=0.30$, against $+0.021$ in the control where
  $\gamma=0$. Under exact conditional proportional hazards, transporting a relative effect on a
  marginal scale across studies with different baselines is not exact when a covariate makes the
  marginal contrast non-collapsible. This is registered as an **anticipated mechanism** so that
  reproducing it in the run is a confirmed prediction rather than a post hoc story. The magnitude
  is **less than half** what version 4 registered, because version 4 registered the artifact; the
  mechanism is real, the number was not.
- **WITHDRAWN.** Version 4 reported that STC-PH's bias at $\kappa_B=0.15$ was $-0.028$, that its
  non-collapsibility and non-proportionality biases happened to cancel there, and that a design
  with one non-proportionality level would have crowned it the best estimator in the study. The
  corrected value is $-0.176$. **There is no near-cancellation and the finding does not exist.**
  It was an artifact of the same defect. The argument for crossing several $\kappa_B$ levels stands
  on its own without it and is not restated here as though it had evidence it does not have.

**D2, estimation quality**, is the primary outcome and is specified in section 10.1; it is not
restated here. Coverage is classified from its Monte Carlo interval: **calibrated** if the interval
lies inside $[0.90, 0.98]$, **miscalibrated** if outside, **inconclusive** otherwise.

Round 4 asked for the operating characteristics of this classification rather than the bare
statement that the inconclusive region is wide. Computed by simulation over 200,000 draws, for one
estimator's pooled coverage across all 14 cell-by-censoring conditions:

| replicates per cell | pooled $n$ | P(calibrated) | P(inconclusive) | P(miscalibrated) |
|---|---:|---:|---:|---:|
| 25 (version 4) | 350 | 0.733 | 0.267 | 0.000 |
| **40 (registered)** | **560** | **0.953** | **0.047** | **0.000** |

when the estimator is in truth exactly calibrated at 0.95. **This is the concrete cost of version
4's replicate cut**, and it is larger than the one that cut recorded: at 25 replicates the rule
fails to certify a genuinely calibrated estimator more than a quarter of the time, and the
restoration to 40 removes almost all of it. The narrower reading Kimi applied in round 4, pooling
only the six primary cells, gives 150 observations and a calibrated probability of just 0.117; that
number is correct for that pooling and is why the registered outcome pools over all cells.

Power against genuine miscalibration is the weaker side and is stated rather than hidden. At 560
observations the rule returns "miscalibrated" for a true coverage of 0.85 with probability 0.933,
for 0.88 with probability 0.286, and for 0.90 essentially never, since 0.90 is the boundary itself.
**Gross miscalibration is caught, mild miscalibration is not**, and an "inconclusive" verdict must
therefore not be read as evidence of calibration.

**D3, the hazard ratio as a decision input.** Evaluated on the **analytic least-false parameter
from E1**, not on replicate-fitted hazard ratios, so the statistic carries no simulation noise at
all; E2's finite-sample scatter is reported around it rather than mixed into it. Round 2's second
reviewer asked for exactly this separation.

The estimand is stated once, here, and sections 2 and 5 refer to this definition rather than
restating it, because round 4 found three incompatible versions of it in version 4. **D3 is the
range, over the $4\times4$ grid of independently crossed censoring regimes, of the RMST difference
obtained by applying each leg's least-false hazard ratio to one fixed target placebo curve** (the
truth's own, so baseline noise cannot enter) and differencing the two implied RMSTs. Regimes are
weighted uniformly. This is labeled throughout as the performance of the **PH plug-in decision
procedure**, not as a general conversion from a hazard ratio to a non-proportional RMST contrast,
which does not exist.

**D3 fails.** The worst range is **1.3805 months** against the 0.50-month threshold, in the
$\kappa_A=\kappa_B=0.30$ cell. On the matched-follow-up diagonal alone the same cell moves
**0.0868** months, a factor of 16, which is why version 4's shared-regime design reported the
whole study as passing at 0.697 and would have called this cell among the safest in it.

Deployment weights are uniform and are stated as the declared judgment they are.

