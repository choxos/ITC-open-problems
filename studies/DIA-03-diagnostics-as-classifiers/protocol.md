# Protocol: are the diagnostics reported alongside a population adjustment classifiers of its error?

**Target problem.** [DIA-03](https://choxos.github.io/ITC-open-problems/problems/DIA-03-paic-diagnostics-are-not-evaluated-as-classifiers-of-realize.html)
*PAIC diagnostics are not evaluated as classifiers of realized error*. Also bearing
on [DIA-06](https://choxos.github.io/ITC-open-problems/problems/DIA-06-failure-signatures-across-paic-estimator-families-are-unch.html)
*Failure signatures across PAIC estimator families are uncharacterized*.

**Status.** Registered before any result of the full design was seen. The commit that
adds this file is the timestamp. A pilot was run first and is reported in section 10,
including the two design choices it changed; everything else below was fixed before the
pilot as well.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

---

## 1. The problem, and what is actually open

Every population-adjusted indirect comparison arrives with a panel of numbers beside it:
the effective sample size after weighting, the same figure as a percentage of the
original, the largest individual weight, standardized differences before and after
adjustment, some measure of how far the target population sits from the source. An
appraisal committee reads them as evidence about whether to believe the estimate.

The audit behind DIA-03 narrowed the catalog's original claim. It is not true that
nothing has ever related a diagnostic to error: an ISPOR Europe 2024 simulation
(abstract MSR65) reported bias in unanchored MAIC once absolute effective sample size
fell below roughly 30 to 35, and Remiro-Azócar, Heath and Baio (2021,
[doi:10.1002/jrsm.1511](https://doi.org/10.1002/jrsm.1511)) tied small effective sample
size to underestimation of variance by the robust sandwich estimator. What survives the
audit is narrower and sharper:

> Neither treats a diagnostic as a classifier with discrimination and calibration
> against known truth.

One of the two external auditors added the objection that makes this a real research
question rather than a complaint:

> Computing a diagnostic from fitted data does not logically prevent it from predicting
> error. Sensitivity, specificity, ROC curves and calibration are defined only relative
> to a specified distribution of scenarios and a prespecified material-error threshold;
> they are not intrinsic properties of a diagnostic.

That is correct, and it dictates the shape of this study. A number for the sensitivity
of a diagnostic is meaningless without the distribution of analyses it was computed
over. So this protocol writes that distribution down in advance, as an explicit
judgment, and reports every headline figure twice: once under it and once with all cells
weighted equally.

## 2. Aims

Each has a numerical answer.

1. **The published rule.** What are the sensitivity and specificity of "effective sample
   size below 35" for a material error in the transported treatment effect, under the
   declared deployment distribution?
2. **The rest of the panel.** For each routinely reported diagnostic at a threshold fixed
   before the run: sensitivity, specificity, area under the ROC curve, area under the
   precision-recall curve, and the calibration of a locked mapping from the diagnostic to
   a risk of material error, evaluated out of sample.
3. **What the panel is measuring.** Realized error decomposes exactly into three parts.
   Which part does each diagnostic track?
4. **Whether anything better is available from the same information.** Does an imbalance
   check on covariates that were measured but not adjusted for, converted into the units
   of the estimand, beat the panel?

## 3. Notation, and the exact decomposition the study rests on

A source trial supplies individual data on $n$ participants randomized between $A$ and
$C$. A target trial supplies a baseline table and its own $B$ versus $C$ effect. Write
$X = (X_1, X_2, X_3, X_4)$, with the adjustment set $M = \{1,2,3\}$ and $X_4$ measured but
never adjusted for. The outcome is continuous with an identity link,

$$Y_i = f(X_i) + \mathbb{1}(A_i)\{d_A + g_A(X_i)\} + \varepsilon_i, \qquad \varepsilon_i \sim N(0, 1).$$

The conditional effect $d_A + g_A(X)$ is heterogeneous, so it is not equal to the marginal
effect. What the identity link buys is that there is no non-collapsibility: the marginal
effect is exactly the **average** of the conditional effects over the target covariate
distribution. The estimand is the transported effect in the target **superpopulation**,

$$\theta_{AC}(T) = d_A + \mathbb{E}_T\{g_A(X)\}.$$

MAIC solves $\sum_i w_i(\lambda)\{h(X_i) - m_T\} = 0$ with $w_i = \exp\{\lambda^\top h(X_i)\}$
and $h(X) = (X_1, X_2, X_3, X_1^2, X_2^2, X_3^2)^\top$, which is exactly what a baseline
table of means and standard deviations supports.

All three estimators are **linear in the outcome vector** for a fixed design: write
$\hat\theta = L(Y)$ for the appropriate linear functional $L$. Applying $L$ to each piece
of $\mathbb{E}[Y \mid X, A] = f(X) + \mathbb{1}(A)\{d_A + g_A(X)\}$ splits the realized
error into three terms that add up exactly, with no approximation and no large-sample
argument:

$$\underbrace{\hat\theta - \theta_{AC}(T)}_{\text{realized error}}
= \underbrace{L(f)}_{\text{arm imbalance}}
+ \underbrace{L\big(\mathbb{1}(A)\{d_A + g_A\}\big) - \theta_{AC}(T)}_{\text{transport error}}
+ \underbrace{L(Y) - L\big(\mathbb{E}[Y \mid X, A]\big)}_{\text{outcome noise}}.$$

This identity is why the outcome is continuous and the link is the identity. It is the
instrument of the study: **transport error is the only component a covariate diagnostic
could know about before seeing an outcome.** A diagnostic that fails against total
realized error might be failing because it is being asked to predict noise it has no
access to; one that fails against the transport component alone has no such excuse. Both
are reported.

## 4. Data-generating mechanism

**Covariates.** Source $X \sim N(0, \Sigma_S)$ with unit variances,
$\mathrm{corr}(X_1, X_2) = 0.30$, $\mathrm{corr}(X_1, X_3) = \mathrm{corr}(X_2, X_3) = 0.20$,
and $\mathrm{corr}(X_4, X_j) = \rho_4$ for $j \in M$. Target
$X \sim N(\delta \mathbf{1}, \Sigma_T)$, identical except that
$\mathrm{corr}(X_1, X_2) = 0.70$ and every standard deviation is multiplied by
$s$.

**Outcome.** $f(X) = 0.50X_1 + 0.30X_2 + 0.40X_3 + 0.20X_4$; $d_A = 0.40$, $d_B = 0.25$;
$\varepsilon \sim N(0,1)$.

**Effect modification.** $B$ versus $C$ is not modified, so the $A$ versus $B$ contrast
depends on the target population through $g_A$ alone and adjustment is doing real work.

$$g_A(X) = 0.30X_1 - 0.20X_2 + 0.25X_3 + \kappa X_1 X_2 + \omega X_4.$$

**Target moments are exact.** The target's reported means and standard deviations are its
superpopulation values, not sample moments. Study 1 of this program (MIS-03) measured
what target-moment sampling error costs; carrying it here would add a noise channel no
source-side diagnostic can observe and would depress every discrimination measure by a
common amount without changing which diagnostic beats which. The target's *effect*
estimate is a real estimate, drawn with the variance the outcome model implies for an
unadjusted arm-mean difference,

$$\mathrm{Var}(\hat\theta_{BC}) = \frac{2\{\mathrm{Var}_T(f(X)) + \sigma^2\}}{n_T}
= \frac{2(\beta^\top \Sigma_T \beta + \sigma^2)}{n_T},$$

which runs from 0.0094 to 0.0137 across this design at $n_T = 400$ per arm. Writing
$2\sigma^2/n_T = 0.005$ instead, as an earlier version of this protocol did, would have
been valid only for a covariate-adjusted target estimate with residual variance one, which
is not what a published two-arm trial reports.

### Three bias channels, differing in whether anything could see them

| channel | switched by | can a diagnostic see it? |
|---|---|---|
| omitted effect modifier $X_4$ | $\omega \in \{0, 0.35\}$ | **In principle yes.** The source data estimate the $X_4$ interaction and a baseline table may report its mean. |
| cross-moment $X_1 X_2$ | $\kappa \in \{0, 0.45\}$ | **No.** Matching marginal means and standard deviations does not match a cross-moment, and no baseline table reports a correlation. |
| extrapolation | $\delta$ | Partly. This channel moves effective sample size and bias together. |

The distinction between the first two is the reason the verdict is required to hold in
the $\kappa = 0$ stratum on its own: a bias engineered to be invisible must not be allowed
to condemn the panel by itself.

### Factors

| factor | levels | why |
|---|---|---|
| $\omega$ omitted modifier | 0, 0.35 | the commonest reason an adjustment is wrong, and diagnosable in principle |
| $\kappa$ cross-moment modifier | 0, 0.45 | a bias no marginal balance statistic can see |
| $\delta$ overlap | 0, 0.25, 0.75, 1.25 | 0.25 is an eligibility-criterion difference, 1.25 prompts comment in an appraisal. **0 is included so the panel has cells where it should stay silent** |
| $n$ per arm | 150, 400 | separates absolute from relative effective sample size |
| $\rho_4$ | 0, 0.5 | whether matching the adjustment set balances the omitted modifier by proxy |
| $s$ target SD ratio | 1.00, 1.25 | **the factor that makes the study falsifiable**, see below |

Fully factorial: $2 \times 2 \times 4 \times 2 \times 2 \times 2 = 128$ cells.

**Why $s$ has to be there, and exactly how far the claim goes.** Matching second moments
to a target 25% more dispersed forces heavy tail weighting and destroys effective sample
size. In the **well-specified stratum** ($\kappa = \omega = 0$) it adds no bias at all: the
modifier function is linear in the adjustment set, whose mean is matched exactly either
way. Without a factor like this, every cell with a small effective sample size would also
be a cell with poor mean overlap, and effective sample size would look like a bias
diagnostic purely because the design never separated the two.

The claim does **not** extend to $\kappa \neq 0$, and an earlier version of this protocol
wrongly said it did. Because $\mathbb{E}_T[X_1X_2] = 0.70 s^2 + \delta^2$, moving $s$ from
1.00 to 1.25 moves the target cross-moment by 0.394 and the true transported effect by
$0.45 \times 0.394 = 0.177$. So $s$ is a pure variance instrument only where the
cross-moment channel is off. That is where the study uses it as one.

**What the mechanism deliberately makes true, and what the study therefore cannot
detect.** Randomization holds in both trials. The prognostic and modifier functions are
shared across trials, so conditional constancy holds. Covariates are normal. The link is
the identity, so there is no non-collapsibility. Every estimator uses the same adjustment
set, so none is handed an advantage. The study therefore says nothing about
non-collapsible effect measures, time-to-event outcomes, skewed or discrete covariates,
unanchored comparisons, target-moment sampling error, or the diagnostics specific to
ML-NMR and NMI such as per-level PSIS-LOO. It is about the MAIC weighting panel and the
overlap statistics it shares with STC.

## 5. The deployment distribution

Sensitivity and specificity are properties of a diagnostic *under a distribution of
analyses*. The following product-form weights are an explicit judgment about applied
practice. **Nothing in this program measured them.** They are declared so that the
headline numbers mean something, and every one of those numbers is reported again under
equal cell weights; a conclusion holding under only one weighting is reported as not
holding.

| factor | weights |
|---|---|
| $\omega$ | 0: 0.65, 0.35: 0.35 |
| $\kappa$ | 0: 0.70, 0.45: 0.30 |
| $\delta$ | 0: 0.25, 0.25: 0.35, 0.75: 0.25, 1.25: 0.15 |
| $n$ | 150: 0.45, 400: 0.55 |
| $\rho_4$ | 0: 0.40, 0.5: 0.60 |
| $s$ | 1.00: 0.65, 1.25: 0.35 |

## 6. Estimators

All three adjust for $M$ only, so when the $X_4$ channel is switched on they are
misspecified in the same way and the comparison is fair.

**Every estimator produces an $A$ versus $C$ estimate on the same scale as the primary
reference $\theta_{AC}(T)$**, and every anchored estimate is that quantity minus the *same*
reported target $B$ versus $C$ effect. An earlier description of the unadjusted comparator
had it subtracting the target effect while the others did not, which would have compared
an $A$ versus $B$ estimate with an $A$ versus $C$ truth. The code never did this; the
description did.

| estimator | point estimate | variance | non-convergence |
|---|---|---|---|
| **Unadjusted** | source arm-mean difference, carried across unchanged | arm variances | not possible |
| **MAIC, means and standard deviations** | weighted arm-mean difference, weights calibrated to the target's first two moments of $M$ | M-estimation sandwich over the stacked calibration and arm-mean equations, treating the weights as estimated | maximum standardized residual imbalance above $10^{-6}$ after BFGS plus a Newton polish |
| **MAIC, means only** | the same, calibrating means alone | as above | as above |
| **STC** | source regression $Y \sim A \times (X_1 + X_2 + X_3)$ centered at the target means; the treatment coefficient | **heteroskedasticity-consistent (HC3)** | rank deficiency |

Two of these are answers to the design critique. **A means-only MAIC** is included because
forcing MAIC to calibrate second moments that are irrelevant to a linear
effect-modification structure costs it effective sample size for nothing, and scoring
effective sample size under that handicap would confound the estimator with a modeling
choice. **STC gets a robust variance**, not the model-based one: where the $X_1X_2$ or
$X_4$ modifier is on, its mean model is misspecified, the residual variance depends on
treatment and covariates, and the ordinary least squares variance is invalid even for the
pseudo-parameter the regression converges to. Giving MAIC a sandwich and STC the
model-based variance would have been a rigged comparison.

Non-convergence of MAIC is recorded per cell as an operational outcome, not silently
dropped. Non-existence of a solution is itself a warning, and dropping the replicates
where it happens would remove the hardest cells and flatter every diagnostic.

## 7. The diagnostics

Nothing in the panel uses a quantity the analyst does not have, except entries beginning
`orc_`, which are oracles reported as ceilings so that a failure can be attributed either
to the statistic or to the information not being present.

| diagnostic | threshold | where the threshold comes from |
|---|---|---|
| absolute effective sample size | < 35, and < 30 | a **candidate cutoff motivated by** ISPOR Europe 2024 MSR65, see below |
| effective sample size as a percentage | < 50% | **published**, appraisal commentary |
| coefficient of variation of the weights | > 1.00 | implied by the above |
| largest single weight share | > 0.10 | rule of thumb |
| post-weighting standardized difference, matched moments | > 0.10 | conventional |
| pre-weighting standardized difference | > 0.25 | conventional |
| Mahalanobis distance of the target mean from the source | > 1.00 | **no convention exists**; set a priori, see section 10 |
| post-weighting standardized difference, unmatched covariate | > 0.10 | conventional, applied to a covariate that was measured and not adjusted for |
| $\widehat{b} = \lvert\hat\gamma_4 (\mu_{T4} - \bar X_4^w)\rvert$ | > 0.10 | **this study's proposal**; half the material-error threshold |

Two entries are settled by algebra before any data exist, and are included because a
reader who has seen them side by side in a submission deserves the demonstration.

$$\frac{\mathrm{ESS}}{n} = \frac{(\sum_i w_i)^2}{n\sum_i w_i^2} = \frac{1}{1 + \mathrm{CV}^2(w)}$$

exactly. Area under the ROC curve is invariant to strictly monotone transformation, so
within a fixed source size effective sample size, effective sample size as a percentage
and the coefficient of variation of the weights have **identical** discrimination,
necessarily. And the post-weighting standardized difference on the matched moments is
zero at the solution of the calibration equations, because those equations set it to
zero; it is reported in submissions as evidence that the adjustment worked, and it cannot
discriminate anything.

## 8. Performance measures

**What MSR65 does and does not say.** It reports an approximate empirical region, absolute
effective sample size around 30 to 35, below which bias appeared in a simulation of
**unanchored** MAIC with binary and time-to-event outcomes. It does not recommend a
classifier operating point, does not report sensitivity or specificity, and says nothing
about anchored continuous-outcome comparisons. Whether the cutoff transports to this
setting is an empirical question, and it is one of the questions this study asks. It is
treated throughout as a candidate cutoff in wide informal use, not as an authority.
Likewise Remiro-Azócar and colleagues establish that **the robust sandwich used in their
study** underestimates variability at small effective sample size; the stacked calibration
and outcome M-estimator used here is a different variance procedure and inherits no
guarantee from theirs.

**Primary.** Sensitivity and specificity of effective sample size below 35 for
$\lvert\hat\theta_{AC} - \theta_{AC}(T)\rvert > 0.20$ among fitted MAIC replicates,
reported **within each misspecification stratum** with cells weighted equally inside a
stratum, and secondarily over the declared mixture and over equal cell weights.

Reporting within strata is the answer to the sharpest finding of the design critique: the
frequency of misspecification across cells is a number this protocol chose, and any
headline sensitivity computed over a mixture inherits it. Within a stratum that dependence
is gone. The reviewer's own suggestion, to base the verdict on the well-specified stratum
alone, is not adopted and the reason is stated here: in that stratum there is no transport
bias at all, so material error is pure Monte Carlo noise, and a variance statistic wins by
construction. That would answer a different question.

The material threshold is a fifth of the outcome standard deviation, of the same order as
the smallest difference an appraisal would treat as meaningful, and it is **not defined
from any diagnostic**. Study 3 of this program had to discard a reference that turned out
to be algebraically identical to one of the statistics being scored; that check has been
made here and passes.

Sensitivity under cell weights is a ratio of two weighted means, so its Monte Carlo error
comes from the delta method applied to cell-level binomial quantities. Treating the
design's fixed cells as a random sample, which study 3 of this program did and had to
withdraw, would be wrong here for the same reason.

**Secondary.** Area under the ROC curve, with a cell-stratified bootstrap interval, and
area under the precision-recall curve; calibration intercept, slope and integrated
calibration error for a mapping fitted on odd-numbered replicates and evaluated on
even-numbered ones; decision-curve net benefit against flagging nothing and flagging
everything; the same measures against each of the three exact error components
separately; material thresholds of 0.10 and 0.30; interval non-coverage as an alternative
reference; operational non-fit rate; and the whole analysis repeated for STC and for the
unadjusted comparison.

**Replicates: 4000 per cell.** Derived from the tightest within-cell requirement, a Monte
Carlo standard error below 0.02 on the area under the ROC curve. By Hanley and McNeil, at
an area of 0.75 and a material-error prevalence of 0.10 ($n_1 = 400$, $n_0 = 3600$),

$$\mathrm{SE} = \sqrt{\frac{A(1-A) + (n_1-1)(Q_1 - A^2) + (n_0-1)(Q_2 - A^2)}{n_1 n_0}},
\quad Q_1 = \frac{A}{2-A} = 0.600,\ Q_2 = \frac{2A^2}{1+A} = 0.643,$$

giving $\sqrt{304.6 / 1.44 \times 10^6} = 0.0145$. So 4000 meets the target with margin.
The design is $128 \times 4000 \times 3 = 1{,}536{,}000$ estimates.

## 9. The decision rule, written before the results exist

The three branches are exhaustive by construction: the third is the complement of the
first two, so no result can fall outside them.

**The panel classifies realized error** if some rule at a threshold fixed before the run
reaches sensitivity at least 0.80 and specificity at least 0.50 **in every one of the four
misspecification strata**, with lower 95% Monte Carlo limits above both. Requiring it in
every stratum is what keeps a chosen mixture out of the verdict: a rule has to catch error
where the bias channels are on and stay quiet where they are off.

**The panel does not classify realized error at the thresholds in use** if no rule meets
that bar and, in addition, the upper 95% Monte Carlo limit on the sensitivity of effective
sample size below 35 is below 0.80 **in the omitted-modifier stratum**, which is the one
where a diagnostic has both something to find and the information with which to find it.

**Neither** means the panel discriminates but no fixed threshold is defensible; report
where each member works and where it does not.

**Uninformative** if material error occurs on fewer than 5% or more than 95% of fitted
MAIC replicates under the deployment weights; or the deployment-weighted MAIC non-fit rate
exceeds 10%, so the analyzed set is not the designed set; or the verdict differs between
the two weightings.

### Four mechanistic claims, also prespecified

A verdict that the panel does not work is not an explanation, and the catalog entry asks
for one.

1. **It is a variance statistic, not a bias statistic.** Effective sample size
   discriminates the outcome-noise component better than the transport component by at
   least 0.10 in area under the ROC curve.
2. **The threshold is not transportable.** Across the cells in which the rule fires on
   most replicates, the cell-level rate of material error spans at least 0.30. A
   calibrated threshold would carry roughly the same risk wherever it fires.
3. **The panel is one statistic.** Within a fixed source size the three weight-dispersion
   measures have identical areas under the ROC curve, and the matched-moment balance
   statistic has none. Algebra says both must hold; the run checks the implementation.
4. **A better statistic is available from the same information.** In the diagnosable
   stratum, against the transport component, $\widehat{b}$ beats the best routinely
   reported diagnostic by at least 0.10. Restricting to that stratum and that component is
   stated in advance and is not a post hoc rescue: no statistic computable from a baseline
   table can see the cross-moment channel, and no covariate statistic can see outcome
   noise.

## 10. The pilot, and the two things it changed

A pilot of 16 cells at 500 replicates was run before the design was frozen, to check that
the material-error rate was not pinned at zero or one, that MAIC converged, and that a
correctly specified MAIC covered at nominal where it should. It confirmed all three
(coverage 0.924 to 0.940 in the benign cells; the exact error decomposition reproduced to
$3 \times 10^{-14}$; the algebraic identity to $2 \times 10^{-16}$). Two things changed as a
result, and both are recorded here rather than presented as original design.

**An overlap level of 0 was added.** The conventional baseline-imbalance cut is 0.25
standardized units, so a design whose mildest cell already sat at 0.25 made that rule fire
on 87% of replicates and its specificity unmeasurable. A panel has to be given cells where
it should stay silent.

**The Mahalanobis threshold was moved from 2.00 to 1.00.** At 2.00 it fired on 0.4% of
pilot replicates and could not be evaluated. This statistic has no published convention,
unlike the effective-sample-size rules, which were not touched and will not be. The change
is disclosed because a threshold tuned on the data that scores it is how a diagnostic
acquires performance it does not have, and the reader is entitled to know which of these
thresholds came from the literature and which from us.

A third pilot finding changed the *implementation* rather than the design: BFGS alone left
the calibration score near $10^{-3}$ on 10% of replicates in exactly the cells the study is
about, so a Newton polish was added and the fit rate rose from 90% to 97%. Loosening the
convergence rule instead would have counted unbalanced weights as a MAIC fit.

## 11. Threats to this design

| threat | what was done |
|---|---|
| Effective sample size and bias are both driven by overlap, so a design varying only overlap would make a variance statistic look like a bias statistic | $s$ varies effective sample size with no bias attached, and $\omega, \kappa$ vary bias at fixed overlap. The two are crossed. |
| The reference for material error could be algebraically tied to a diagnostic being scored | The reference is $\lvert\hat\theta - \theta\rvert > 0.20$. No diagnostic enters its definition. Checked explicitly. |
| Dropping non-converged replicates removes the hardest cells and flatters every diagnostic | Newton polish; the remainder reported per cell and bounded by a prespecified uninformative rule. |
| Any single sensitivity figure is a choice presented as a fact | The distribution is declared in advance and every figure is reported under two weightings. |
| A material threshold of 0.20 makes the task mostly noise prediction in benign cells, which favors effective sample size | That direction is conservative against this study's hypothesis. Thresholds 0.10 and 0.30 are also reported. |
| The proposal $\widehat{b}$ is ours, so we have an interest in it doing well | It is scored at a threshold fixed in advance, against the same reference, and its prespecified claim is restricted to the stratum and component where it has any information at all, with that restriction stated before the run. |

## 12. Amendment, 2026-07-27: what an adversarial review of this design changed

The design as first written was sent to an independent adversarial critique before the
full run, with one instruction: find the ways this study answers a question nobody asked,
or produces a result that is a property of the data-generating mechanism rather than of
the methods. It returned two findings graded fatal, ten serious, and three problems with
the citations. Everything below was changed **before** any result of the full design was
seen; the first attempt at the run was stopped and its output deleted.

Two of the findings were arithmetic errors in this protocol, and both were verified
numerically before being accepted.

**The dispersion factor was not the pure variance instrument it was described as.** With
$\mathbb{E}_T[X_1X_2] = 0.70s^2 + \delta^2$, moving $s$ from 1.00 to 1.25 moves the true
transported effect by $0.45 \times 0.394 = 0.177$ wherever the cross-moment channel is on.
The claim now holds only where it is true, and section 4 says so.

**The target trial's variance was understated by a factor of two to three.** An unadjusted
arm-mean difference carries the whole outcome variance, prognostic index included:
$2(\beta^\top\Sigma_T\beta + \sigma^2)/n_T$, which is 0.0094 to 0.0137 here, not
$2\sigma^2/n_T = 0.005$. Corrected in the mechanism.

Five further changes, each attributable to a specific finding.

| finding | change |
|---|---|
| The misspecification frequency across cells is investigator-chosen, so any mixture-level headline inherits it | **The primary results are now reported within each of the four misspecification strata**, with cells weighted equally inside a stratum. The mixture is a labeled secondary. The reviewer's alternative, basing the verdict on the well-specified stratum alone, is declined with a reason given in section 8. |
| STC was given a model-based variance while misspecified, MAIC a sandwich | STC now gets HC3. |
| MAIC was forced to calibrate second moments irrelevant to a linear modifier, which costs it effective sample size for nothing | A **means-only MAIC** was added as a fourth estimator. |
| Calibration fitted and evaluated within the same cells is optimistic by construction | The locked mapping is now fitted on odd-numbered **cells** and evaluated on even-numbered ones. The within-cell split is retained and reported as the optimistic bound. |
| Conditioning on a successful MAIC fit answers a slightly easier question | The primary rule's sensitivity is now **bracketed** by counting every non-fit as a caught failure and then as a missed one. |

The description of the unadjusted comparator was wrong in a way the code was not: it said
the comparator subtracted the target effect while the others did not, which would have
compared an $A$ versus $B$ estimate with an $A$ versus $C$ truth. Corrected in section 6.
The claim that an identity link makes marginal and conditional effects "coincide" was
replaced with the correct averaging statement in section 3. The characterization of MSR65
as publishing an ESS rule was withdrawn and replaced in section 8.

Two findings were answered by the artifacts rather than by a change: the critique read a
summary in which the deployment probabilities and the non-ESS thresholds were not listed,
and judged both fatal. They are listed in sections 5 and 7 and are executable in
`R/00-config.R` and `R/05-analyze.R`, where the weights are also asserted to sum to one.

One finding is accepted and not fixed, because it cannot be fixed within this design: the
study does not characterize failure signatures across the five estimator families DIA-06
names. It compares two families and no adjustment. DIA-06 is answered in part, and the
part is small.

## 13. What this study will not settle

It covers two estimator families where DIA-06 names five, and does not touch ML-NMR or
NMI, so it answers part of DIA-06 and not the whole of it. It says nothing about the
hierarchical-level mismatch in cross-validation that forms the second half of DIA-03's
statement: no PSIS-LOO is computed at any level, and grouped study-level leave-one-out is
not implemented here any more than it is in the packages. Those remain open.
