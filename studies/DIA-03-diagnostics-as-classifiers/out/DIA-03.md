# Effective sample size is a variance statistic being read as a bias
warning
Ahmad Sofi-Mahmudi
2026-07-27

# Abstract

Every population-adjusted indirect comparison is reported with a panel
of numbers beside it: the effective sample size after weighting, the
same figure as a percentage, the largest individual weight, standardized
differences before and after adjustment. An appraisal committee reads
them as evidence about whether to believe the estimate, and a widely
quoted rule says to worry once absolute effective sample size falls
below about 30 to 35. An audit of the open-problem catalog found that no
published work has scored any of these as a classifier of realized
error, with discrimination and calibration, against a known truth.

We do that. The design is an anchored indirect comparison with a
continuous outcome and an identity link, chosen because on that scale
the realized error of a linear estimator splits **exactly** into three
pieces: chance covariate imbalance between the source arms, transport
error, and outcome noise. Transport error is the only piece a covariate
diagnostic could know about before an outcome is seen, so a diagnostic
can be scored against the part it has a claim on rather than only
against the part it does not. The design has 128 cells crossing an
omitted effect modifier, a cross-moment modifier that no baseline table
could ever reveal, overlap, source size, how correlated the omitted
modifier is with the adjustment set, and a target dispersion ratio that
destroys effective sample size while adding no bias wherever the
modifier structure is correctly specified. 4,000 replicates per cell,
four estimators.

The prespecified verdict is **the panel does not classify realized error
at the thresholds in use**. Reading the panel is not reading a warning
about bias: effective sample size separates the noise component at AUROC
0.847 and the transport component at 0.653. In the stratum where an
effect modifier is omitted and the omission is diagnosable in principle,
the ESS \< 35 rule reaches sensitivity 0.309 at specificity 0.926. Three
of the panel’s members are one statistic written three ways, because
$\mathrm{ESS}/n = 1/(1+\mathrm{CV}^2(w))$ exactly and area under the ROC
curve is invariant to monotone transformation; a fourth, the
post-weighting balance on the matched moments, is zero at the solution
of the calibration equations and cannot discriminate anything.
Converting the residual imbalance on a measured-but-unadjusted covariate
into the units of the estimand, using an interaction the source data can
estimate, reaches 0.937 against the transport component where the panel
reaches 0.851, and is blind exactly where the information is absent.

# What the audit left open

The catalog entry DIA-03 originally said that whether
population-adjustment diagnostics predict error “has never been
quantified”. Two independent auditors judged that too strong, and they
were right. An ISPOR Europe 2024 simulation reported bias in unanchored
MAIC once absolute effective sample size fell below roughly 30 to 35
([1](#ref-msr65)), and Remiro-Azócar, Heath and Baio tied small
effective sample size to underestimation of variability by the robust
sandwich variance estimator ([2](#ref-remiroazocar2021)). What survived
the audit is narrower:

> Neither treats a diagnostic as a classifier with discrimination and
> calibration against known truth.

One auditor added the objection that turns this from a complaint into a
research question. Computing a diagnostic from the fitted data does not
logically prevent it from predicting error. Sensitivity, specificity and
calibration are defined only relative to a specified distribution of
analyses and a prespecified threshold for material error; they are not
intrinsic properties of a statistic. That is why the field has no
numbers: nobody has written the distribution down. This study writes one
down in advance, and reports everything twice, once under it and once
with all cells weighted equally.

It also reports the primary results **within** strata of
misspecification rather than over a mixture of them, which removes the
dependence on our chosen frequencies entirely. That change came from an
adversarial critique of this design, before the run.

# What a covariate diagnostic could possibly know

Write the source trial’s outcome as
$Y_i = f(X_i) + \mathbb{1}(A_i)\{d_A + g_A(X_i)\} + \varepsilon_i$ with
$\varepsilon_i \sim N(0, \sigma^2)$, and let the estimand be the
transported effect in the target superpopulation,
$\theta_{AC}(T) = d_A + \mathbb{E}_T\{g_A(X)\}$. The identity link does
not make the heterogeneous conditional effect equal to the marginal one;
what it buys is the absence of non-collapsibility, so the marginal
effect is exactly the average of the conditional effects over the target
covariate distribution.

MAIC, STC and the unadjusted comparison are all **linear in the outcome
vector** for a fixed design: each is $\hat\theta = L(Y)$ for some linear
functional $L$. For MAIC,
$L(y) = \sum_{i \in A} w_i y_i / \sum_{i \in A} w_i - \sum_{i \in C} w_i y_i / \sum_{i \in C} w_i$;
for STC, $L(y) = a^\top y$ with $a = M(M^\top M)^{-1} e_A$. Applying the
same $L$ to each piece of $\mathbb{E}[Y \mid X, A]$ gives an identity,
not an approximation:

$$\underbrace{\hat\theta - \theta_{AC}(T)}_{\text{realized error}}
= \underbrace{L(f)}_{\text{arm imbalance}}
\;+\; \underbrace{L\big(\mathbb{1}(A)\{d_A + g_A\}\big) - \theta_{AC}(T)}_{\text{transport error}}
\;+\; \underbrace{L(Y) - L\big(\mathbb{E}[Y \mid X, A]\big)}_{\text{outcome noise}}.$$

Three consequences organize the whole study.

**Only the middle term is what adjustment exists to remove.** The first
is chance covariate imbalance between the source arms, which
randomization makes mean-zero but not zero in any one trial. The third
is sampling error in the outcomes.

**Only the middle term is knowable from covariates.** The first and
third depend on the realized outcomes; no function of $X$, the weights
and a published baseline table has any information about $\varepsilon$.
A diagnostic that fails to predict total realized error may simply be
being asked to predict noise. A diagnostic that fails to predict the
transport component has no such excuse. Both are reported, and the
difference between them is the finding.

**The identity holds per replicate.** We verified it numerically to
$3 \times 10^{-14}$ before the run.

# Two facts that algebra settles before any data exist

The panel is smaller than it appears.

**Effective sample size, effective sample size as a percentage, and the
coefficient of variation of the weights are one statistic.** With
$\bar w$ the mean weight and $s^2$ the population variance of the
weights,

$$\frac{\mathrm{ESS}}{n} = \frac{\left(\sum_i w_i\right)^2}{n \sum_i w_i^2}
= \frac{n^2 \bar w^2}{n \cdot n\left(s^2 + \bar w^2\right)}
= \frac{\bar w^2}{s^2 + \bar w^2} = \frac{1}{1 + \mathrm{CV}^2(w)}.$$

Area under the ROC curve depends on the score only through its ranks, so
a strictly monotone transformation cannot change it. Within a fixed
source size the three therefore have **identical** discrimination as a
matter of arithmetic. Across sizes they differ, because $n$ varies. A
submission that reports all three is reporting one number three times
and calling it triangulation.

**The post-weighting standardized difference on the matched moments is
zero.** The MAIC calibration equations are
$\sum_i w_i\{h(X_i) - m_T\} = 0$; the balance statistic is that
expression divided by a standard deviation. It is set to zero by the
thing being reported as evidence that it worked. In this run it never
exceeded 1.4e-14.

Both are checked in the results rather than assumed, because the check
is a test of the implementation.

# Design

The full protocol was registered before the run. What matters for
reading the results:

**Four estimators.** MAIC calibrating the target’s means and standard
deviations of the adjustment set; MAIC calibrating means only; STC with
a heteroskedasticity-consistent variance ([3](#ref-mackinnon1985)); and
no adjustment at all. All adjust for the same three covariates, so when
a modifier is omitted they are misspecified in the same way. MAIC’s
variance is the M-estimation sandwich over the stacked calibration and
arm-mean equations ([4](#ref-stefanski2002)).

**Three bias channels, differing in whether anything could see them.**
An omitted effect modifier $X_4$, which the source data can estimate an
interaction for and a baseline table may report a mean for, so it is
diagnosable in principle. A cross-moment term in $X_1 X_2$ with source
and target correlations of 0.30 and 0.70, which no marginal balance
statistic can see and which no baseline table reports. And
extrapolation, which moves effective sample size and bias together and
is what gives effective sample size its only real chance.

**The factor that makes the study falsifiable.** The target’s covariate
standard deviations are either equal to the source’s or 25% larger.
Matching second moments to a more dispersed target destroys effective
sample size while adding no bias in the well-specified stratum, because
the modifier is linear in the adjustment set and its mean is matched
either way. Without it, every low-effective-sample-size cell would also
be a poor-overlap cell, and a variance statistic would look like a bias
statistic because the design never separated the two.

**The reference.** Material error means
$\lvert\hat\theta_{AC} - \theta_{AC}(T)\rvert > 0.20$, a fifth of the
outcome standard deviation. No diagnostic enters its definition.

**Scale.** 128 cells, 4,000 replicates each, four estimators. MAIC found
a solution on 99.3% of replicates; the rest are reported per cell rather
than dropped silently.

# Results

## The panel at the thresholds in use

<div id="tbl-primary">

Table 1: Sensitivity and specificity for material error, within each
misspecification stratum, cells weighted equally inside a stratum. Monte
Carlo standard errors in brackets.

<div class="cell-output-display">

| diagnostic (sensitivity / specificity) | well.specified | omitted.modifier | cross.moment | both |
|:---|:--:|:--:|:--:|:--:|
| ESS | 0.326 / 0.923 | 0.309 / 0.926 | 0.265 / 0.918 | 0.251 / 0.915 |
| ESS % | 0.742 / 0.623 | 0.735 / 0.654 | 0.649 / 0.607 | 0.642 / 0.633 |
| largest weight | 0.350 / 0.919 | 0.332 / 0.920 | 0.285 / 0.913 | 0.269 / 0.909 |
| balance, matched moments | 0.000 / 1.000 | 0.000 / 1.000 | 0.000 / 1.000 | 0.000 / 1.000 |
| imbalance before weighting | 0.822 / 0.408 | 0.823 / 0.431 | 0.767 / 0.403 | 0.771 / 0.440 |
| Mahalanobis distance | 0.656 / 0.692 | 0.652 / 0.721 | 0.570 / 0.683 | 0.564 / 0.707 |
| balance, unmatched covariate | 0.559 / 0.610 | 0.571 / 0.639 | 0.520 / 0.608 | 0.543 / 0.681 |
| estimated bias (proposed) | 0.099 / 0.962 | 0.393 / 0.807 | 0.091 / 0.957 | 0.358 / 0.827 |

</div>

</div>

The prespecified bar was sensitivity at least 0.80 with specificity at
least 0.50 in every stratum, lower Monte Carlo limits above both. No
rule met it.

In the omitted-modifier stratum, which is where a diagnostic has both
something to find and the information with which to find it, the
published cutoff reaches sensitivity 0.309 (0.001) at specificity 0.926.
Two members of the panel reach high sensitivity by firing on nearly
everything: the pre-weighting imbalance rule fires on 70.6% of analyses
in that stratum and the unmatched-balance rule on 47.4%. A rule that
warns about almost every analysis is not a classifier, and its
specificity says so: 0.431 and 0.639.

Replicates on which MAIC had no solution: 3,747. Bracketing the primary
rule’s sensitivity by counting every one of them as a caught failure,
then as a missed one, gives 0.285 and 0.273.

## The statistics carry information the thresholds do not use

<div id="tbl-auc">

Table 2: Discrimination under the declared deployment distribution. The
last two columns are the point of the study: which component of the
realized error does each statistic actually track?

<div class="cell-output-display">

|  | diagnostic | AUROC | AUPRC | vs outcome noise | vs transport error |
|:---|:---|---:|---:|---:|---:|
| ess | ESS | 0.731 (0.001) | 0.707 | 0.847 | 0.653 |
| ess_pct | ESS % | 0.723 (0.001) | 0.698 | 0.813 | 0.667 |
| cv_w | CV(w) | 0.723 (0.001) | 0.698 | 0.813 | 0.667 |
| max_w | largest weight | 0.741 (0.001) | 0.716 | 0.833 | 0.660 |
| smd_matched | balance, matched moments | 0.550 (0.001) | 0.509 | 0.571 | 0.538 |
| smd_pre | imbalance before weighting | 0.683 (0.001) | 0.671 | 0.799 | 0.655 |
| maha | Mahalanobis distance | 0.682 (0.001) | 0.669 | 0.796 | 0.656 |
| smd_unmatched | balance, unmatched covariate | 0.606 (0.001) | 0.592 | 0.663 | 0.665 |
| bias_hat | estimated bias (proposed) | 0.604 (0.001) | 0.591 | 0.643 | 0.684 |
| orc_cross | oracle: cross-moment | 0.581 (0.001) | 0.551 | 0.505 | 0.809 |

</div>

</div>

Discrimination is not zero. Nothing here is uninformative in the sense
of being independent of error. But the ordering in the last two columns
is the answer to what the panel is measuring: every weight-based
statistic reads the noise channel better than the transport channel, and
the gap for effective sample size is 0.194. That is the sense in which a
variance statistic is being read as a bias warning.

The oracle row separates two different failures. The cross-moment oracle
uses the target’s true $\mathbb{E}[X_1X_2]$, which no baseline table
reports, and reaches 0.809 against transport error while everything
computable sits near 0.667. Where the oracle wins, the information is
missing rather than the statistic being the wrong function of it.

One row needs a warning label. The balance statistic on the matched
moments shows AUROC 0.550, which is not 0.5 and might be read as weak
signal. It is not. That statistic never exceeded 1.4e-14 anywhere in the
run: what is being ranked is floating-point residual from the
calibration solver, and the residual is larger in cells where the
equations were harder to solve, which are also harder cells. The
apparent discrimination is discrimination of arithmetic difficulty.
Scoring a statistic that is identically zero produces a number, and the
number means nothing.

## The panel is smaller than it looks

<div id="tbl-redundancy">

Table 3: The algebraic identities, checked. Within a fixed source size
the three weight-dispersion statistics have the same AUROC to machine
precision, and the matched-moment balance statistic is zero.

<div class="cell-output-display">

| source per arm |   ESS | ESS % | CV(w) | max matched imbalance |
|---------------:|------:|------:|------:|----------------------:|
|            150 | 0.706 | 0.706 | 0.706 |               1.3e-14 |
|            400 | 0.740 | 0.740 | 0.740 |               1.4e-14 |

</div>

</div>

## Calibration

A diagnostic is calibrated if a mapping from it to a risk of material
error, fitted once and locked, tells the truth on analyses it has not
seen. The mapping here is fitted on odd-numbered design cells and
evaluated on even-numbered ones, which is the question an analyst faces;
refitting within the same cells is reported as the optimistic bound
([5](#ref-austin2019)).

<div id="tbl-cal">

Table 4: Calibration of a locked logistic mapping from each diagnostic
to the risk of material error. Perfect calibration is intercept 0 and
slope 1.

<div class="cell-output-display">

|  | diagnostic | intercept | slope | calibration error, new cells | calibration error, same cells |
|:---|:---|---:|---:|---:|---:|
| ess | ESS | 0.297 | 0.888 | 0.065 | 0.066 |
| ess_pct | ESS % | 0.248 | 0.837 | 0.061 | 0.069 |
| max_w | largest weight | 0.243 | 0.801 | 0.069 | 0.091 |
| smd_pre | imbalance before weighting | 0.648 | 0.845 | 0.143 | 0.075 |
| maha | Mahalanobis distance | 0.649 | 0.844 | 0.143 | 0.075 |
| smd_unmatched | balance, unmatched covariate | 0.534 | 0.765 | 0.127 | 0.101 |
| bias_hat | estimated bias (proposed) | 0.535 | 0.766 | 0.130 | 0.086 |

</div>

</div>

The weight-dispersion statistics calibrate tolerably across cells they
have not seen: effective sample size has intercept 0.297 and slope
0.888, with an integrated calibration error of 0.065. The overlap
statistics do not: the pre-weighting imbalance mapping carries an error
of 0.143 on new cells against 0.075 when refitted on the cells it is
scored in, so nearly half of its apparent calibration is memory of the
setting. That gap is the reason the split is across cells rather than
across replicates, and an adversarial review of the design is the reason
it is.

## Is acting on the warning better than not acting?

Net benefit relative to flagging nothing, over a range of threshold
probabilities at which an analyst would act ([6](#ref-vickers2006)). A
rule earns its place only above both flagging nothing and flagging
everything.

<div id="tbl-dca">

Table 5: Net benefit relative to flagging nothing, under the deployment
weights.

<div class="cell-output-display">

| action threshold | flag nothing | flag everything | ESS \< 35 | ESS \< 50% | imbalance \> 0.25 | Mahalanobis \> 1 | estimated bias \> 0.10 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.1 | 0 | 0.421 | 0.086 | 0.281 | 0.341 | 0.242 | 0.066 |
| 0.2 | 0 | 0.348 | 0.083 | 0.259 | 0.297 | 0.224 | 0.061 |
| 0.3 | 0 | 0.255 | 0.080 | 0.231 | 0.241 | 0.202 | 0.056 |
| 0.4 | 0 | 0.131 | 0.075 | 0.194 | 0.167 | 0.172 | 0.049 |
| 0.5 | 0 | -0.043 | 0.069 | 0.142 | 0.063 | 0.130 | 0.039 |

</div>

</div>

Every rule in the panel is beaten by flagging everything at action
thresholds up to 0.300. An analyst who would act on a 10.0% chance of
material error does better scrutinizing every population adjustment than
reading any of these numbers. Only once the action threshold reaches
0.400, meaning the analyst will only intervene when material error is at
least that likely, does a diagnostic earn its place, and the one that
does it is the relative effective-sample-size rule rather than the
absolute one that gets quoted.

![](../results/figures/fig5-decision-curve.png)

## The four prespecified mechanism claims

<div id="tbl-mech">

Table 6: The four claims registered before the run, and whether the run
supports them.

<div class="cell-output-display">

| claim | holds | evidence |
|:---|:--:|:---|
| It is a variance statistic, not a bias statistic | yes | Effective sample size discriminates outcome noise at AUROC 0.847 and transport error at 0.653, a gap of 0.194 against a prespecified 0.10. |
| The threshold is not transportable | no | Across the 24 cells the rule flags on most replicates, the material-error rate runs from 0.751 to 0.902, a span of 0.150 against a prespecified 0.30. Across the 88 cells it is silent on, the rate runs from 0.045 to 0.835. |
| The panel is one statistic | yes | Within a fixed source size the three agree to 0.0e+00 in AUROC, and the matched-moment balance statistic never exceeds 1.4e-14. |
| A better statistic is available from the same information | no | In the diagnosable stratum, against the transport component, the proposal reaches 0.937 and the best routinely reported diagnostic 0.851, a gain of 0.086 against a prespecified 0.10. |

</div>

</div>

Two of the four hold and two do not, and the two that do not are
reported as they were registered rather than adjusted until they did.

**The threshold-transportability claim failed as written, and the
complementary quantity is the interesting one.** We registered a span of
at least 0.30 in the material-error rate across the cells the rule
*flags*. The observed span is 0.150, and the reason is visible in
<a href="#fig-ess" class="quarto-xref">Figure 1</a>: the flagged cells
are all in the low-effective-sample-size region where almost everything
is wrong, so there is little room for a spread. The cells the rule is
**silent** on are where a spread matters, because silence is what an
analyst acts on, and there the material-error rate runs from 0.045 to
0.835, a span of 0.789 across 88 cells. That is a stronger result than
the one registered and it was not prespecified, so it is reported as an
observation and not as a passed test.

**The proposal missed its bar too.** Registered at a gain of at least
0.10 in area under the ROC curve against the transport component in the
diagnosable stratum; observed 0.937 against 0.851, a gain of 0.086. It
is a real improvement and it is not the one we said would count.

<div id="fig-ess">

<img src="../results/figures/fig1-ess-vs-error.png" id="fig-ess" />

Figure 1

</div>

![](../results/figures/fig3-components.png)

## The other estimators

<div id="tbl-other">

Table 7: The same replicates seen by the other three estimators. Median
effective sample size is over the whole design.

<div class="cell-output-display">

| method | diagnostic | AUROC | vs transport | material error | median ESS | coverage |
|:---|:---|---:|---:|---:|---:|---:|
| MAIC, means only | ESS | 0.704 | 0.599 | 0.433 | 261.783 | 0.730 |
| MAIC, means only | imbalance before weighting | 0.685 | 0.607 | 0.433 | 261.783 | 0.730 |
| MAIC, means only | Mahalanobis distance | 0.683 | 0.608 | 0.433 | 261.783 | 0.730 |
| MAIC, means only | balance, unmatched covariate | 0.602 | 0.624 | 0.433 | 261.783 | 0.730 |
| MAIC, means only | estimated bias (proposed) | 0.602 | 0.641 | 0.433 | 261.783 | 0.730 |
| STC | imbalance before weighting | 0.656 | 0.635 | 0.340 | 550.000 | 0.533 |
| STC | Mahalanobis distance | 0.655 | 0.636 | 0.340 | 550.000 | 0.533 |
| STC | balance, unmatched covariate | 0.606 | 0.619 | 0.340 | 550.000 | 0.533 |
| STC | estimated bias (proposed) | 0.611 | 0.628 | 0.340 | 550.000 | 0.533 |
| no adjustment | imbalance before weighting | 0.804 | 0.891 | 0.596 | 550.000 | 0.357 |
| no adjustment | Mahalanobis distance | 0.804 | 0.891 | 0.596 | 550.000 | 0.357 |
| no adjustment | balance, unmatched covariate | 0.802 | 0.892 | 0.596 | 550.000 | 0.357 |
| no adjustment | estimated bias (proposed) | 0.798 | 0.873 | 0.596 | 550.000 | 0.357 |

</div>

</div>

The unadjusted comparison is the control that explains the rest of the
paper. Its pre-weighting imbalance statistic predicts its own transport
error at AUROC 0.891, against 0.655 for the same statistic applied to
MAIC. The statistic is not weak. It is an excellent measure of the gap
between the two populations, and the gap between the two populations is
exactly the error of an estimator that does nothing about it. Once
weighting has closed those gaps, the statistic is measuring something
that has been removed, and what remains is the part of the modifier
structure the weights never touched. The diagnostic is informative about
the problem and uninformative about the solution.

Means-only MAIC is worth a line for the same reason. It carries a median
effective sample size of 261.783 against 170.748 for the version that
also matches standard deviations, and a lower material-error rate, 0.433
against 0.479. Calibrating second moments that the modifier structure
does not use costs effective sample size and buys nothing here. A reader
should not generalize that: with a modifier that is nonlinear in the
covariates, those moments would matter.

# What this answers, and what it does not

**DIA-03.** The entry asked for the routine panel to be scored as a
classifier of realized error with discrimination and calibration against
a known truth, under a specified scenario distribution and a
prespecified material-error threshold. That is done, for the MAIC
weighting panel and the overlap statistics it shares with STC. The
second half of the entry, the mismatch between the hierarchical level at
which cross-validation is reported and the level at which the prediction
is made, is untouched: no PSIS-LOO is computed at any level here, and
grouped study-level leave-one-out is no more implemented in this study
than it is in the packages. That half remains open.

**DIA-06.** Answered in part, and the part is small. Four estimators
from two families see the same replicates, so their failure modes can be
compared on identical data; but ML-NMR, NMI, doubly robust estimators
and flexible learners are absent, and the entry names five families. A
design critique made this point before the run and it is accepted rather
than argued with.

**What the mechanism deliberately makes true.** Randomization holds. The
prognostic and modifier functions are shared across trials, so
conditional constancy holds. Covariates are normal. The link is the
identity. Target moments are exact, because study 1 of this program
already measured what their sampling error costs and carrying it here
would add a noise channel no source-side diagnostic can observe. Every
estimator adjusts for the same covariates.

**Therefore the study says nothing about** non-collapsible effect
measures, time-to-event outcomes, skewed or discrete covariates,
unanchored comparisons, target-moment sampling error, or the diagnostics
specific to Bayesian population adjustment. A binary or survival outcome
would add a component of error that is a collapsibility artifact rather
than an adjustment failure, and the exact decomposition in
<a href="#sec-decomposition" class="quarto-xref">Section 2</a> would not
be available; that is the price paid for the instrument, and it is the
largest limitation here.

**The deployment weights are a judgment, not a measurement.** Nothing in
this program estimated how often an effect modifier is omitted in
practice. That is why the primary results are within strata, where the
judgment does not enter, and why every mixture-level figure is reported
under two weightings.

**The proposal is ours.** $\widehat{b}$ was invented for this study,
scored at a threshold fixed in advance, against the same reference as
everything else, and its prespecified claim was restricted before the
run to the stratum and the error component where it has any information
at all. It is not a validated diagnostic and this study does not make it
one; it is a demonstration that the information to do better is
sometimes already in the analyst’s hands.

# Peer review

This manuscript was reviewed by three independent reviewers over two
rounds. The reports, the authors’ responses and the editorial decision
are published in full and unedited alongside it.

# Reproducibility

All code is in the study directory. `R/00-config.R` holds the design,
the thresholds and the decision rule; `R/01-dgm.R` the mechanism;
`R/02-estimators.R` the four estimators and the exact error
decomposition; `R/03-diagnostics.R` the panel; `R/04-run.R` the run;
`R/05-analyze.R` the analysis; `R/06-figures.R` the figures. Replicates
are seeded from one master seed through independent L’Ecuyer-CMRG
streams, so a replicate draws the same data whatever the core count.
`results/provenance.md` records the R version and package versions that
produced these numbers. Raw replicate output is regenerable from the
seed and is not tracked; the tracked artifacts are the summary tables,
the figures and the rendered manuscript.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-msr65" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">MSR65 can low effective sample
size in matching-adjusted indirect comparisons (MAICs) lead to bias?
Findings from a simulation study \[Internet\]. ISPOR Europe 2024,
abstract published in Value in Health; 2024. Available from:
<https://www.valueinhealthjournal.com/article/S1098-3015(24)05162-3/fulltext></span>

</div>

<div id="ref-remiroazocar2021" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Antonio Remiro-Azócar, Anna Heath,
Gianluca Baio. Methods for population adjustment with limited access to
individual patient data: A review and simulation study. Research
Synthesis Methods. 2021;12(6):750–75.
doi:[10.1002/jrsm.1511](https://doi.org/10.1002/jrsm.1511)</span>

</div>

<div id="ref-mackinnon1985" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">James G. MacKinnon, Halbert White.
Some heteroskedasticity-consistent covariance matrix estimators with
improved finite sample properties. Journal of Econometrics.
1985;29(3):305–25.
doi:[10.1016/0304-4076(85)90158-7](https://doi.org/10.1016/0304-4076(85)90158-7)</span>

</div>

<div id="ref-stefanski2002" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">Leonard A. Stefanski, Dennis D.
Boos. The calculus of m-estimation. The American Statistician.
2002;56(1):29–38.
doi:[10.1198/000313002753631330](https://doi.org/10.1198/000313002753631330)</span>

</div>

<div id="ref-austin2019" class="csl-entry">

<span class="csl-left-margin">5.
</span><span class="csl-right-inline">Peter C. Austin, Ewout W.
Steyerberg. The integrated calibration index (ICI) and related metrics
for quantifying the calibration of logistic regression models.
Statistics in Medicine. 2019;38(21):4051–65.
doi:[10.1002/sim.8281](https://doi.org/10.1002/sim.8281)</span>

</div>

<div id="ref-vickers2006" class="csl-entry">

<span class="csl-left-margin">6.
</span><span class="csl-right-inline">Andrew J. Vickers, Elena B. Elkin.
Decision curve analysis: A novel method for evaluating prediction
models. Medical Decision Making. 2006;26(6):565–74.
doi:[10.1177/0272989X06295361](https://doi.org/10.1177/0272989X06295361)</span>

</div>

</div>
