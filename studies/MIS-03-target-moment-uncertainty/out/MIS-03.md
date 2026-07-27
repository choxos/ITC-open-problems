# What conditioning on sampled target moments costs a
population-adjusted indirect comparison
Ahmad Sofi-Mahmudi
2026-07-28

# Abstract

Population-adjusted indirect comparisons match individual patient data
from a source trial to a target trial known only through a published
baseline table. Every matching-adjusted indirect comparison
implementation we could examine treats the target’s reported covariate
means and standard deviations as exact constants, though they are sample
estimates carrying their own sampling error, and no study has measured
what that costs in anchored MAIC.

**Registered result.** The prespecified analysis is **uninformative**.
Its gates require the reference interval and the negative controls to be
nominal, and at poor covariate overlap they are not: the Wald sandwich
undercovers by up to seven percentage points for every method compared,
including scenarios containing no effect modification at all, where the
population omission is exactly zero and the four intervals should very
nearly coincide. That is a failure of the source variance estimator
under extreme weighting, not a target-moment effect, and it invalidates
the absolute-coverage analysis wherever it occurs.

**Exploratory result.** Restricting to the 196 of 252 scenarios where
the reference and its matched control are nominal, conditioning on the
reported moments omits between -9.5% and 14.9% of the variance and moves
coverage of a nominal 95% interval between 92.1% and 96.2%. This
restriction selects on an observed outcome and the results are labelled
exploratory throughout.

**An identity, not a finding.** The net omitted component is, to first
order, $(1-2\kappa)\mathrm{Var}_T\{\tau(X)\}/n_T$, where $\kappa$ is how
far the target trial’s own treatment effect is modified by the same
covariates as the source trial’s. Its sign is therefore fixed
analytically rather than discovered; regressing the measured omission on
this prediction gives a slope of 1.003 (SE 0.042). What the simulation
adds is the magnitude at realistic sample sizes, and the observation
that $\kappa$ is not identified from the inputs a matching-adjusted
comparison ordinarily uses.

**Practical implication, restricted.** The two corrections an analyst
could deploy add only the positive moment-variance term and omit the
cross-covariance, so they are **partial**. Analytically they are closer
to the correct variance than doing nothing only when $\kappa < 1/4$;
between $1/4$ and $1/2$ they are worse than doing nothing, and the
design contains no interior $\kappa$ with which to test this. In the
exploratory restricted set, at $\kappa \in \{0, 0.5, 1\}$ with
**exactly** multivariate-normal covariates and a single equicorrelation
discrepancy, they kept coverage inside 93% to 97% in every scenario, at
a median interval-width cost of 2.24%. That figure applies under exact
multivariate normality and may differ substantially under skewed,
bounded, categorical or rounded covariates, which are untested. Extrema
sat within about one Monte Carlo standard error of the band edges.

# The problem

A population-adjusted indirect comparison estimates the relative effect
of two treatments never compared in one trial. Individual patient data
are available for a source trial comparing $A$ with a common comparator
$C$; for the target trial comparing $B$ with $C$, only a publication is
available. Matching-adjusted indirect comparison
([1](#ref-signorovitch2010)) reweights the source participants so their
covariate distribution matches the target’s, transports the $A$ versus
$C$ effect, and subtracts the target trial’s own $B$ versus $C$ effect
([2](#ref-phillippo2018)).

Everything hangs on a small table: per covariate, a mean and a standard
deviation, with the sample size. Those numbers are the matching targets.

They are sample moments computed from $n_T$ participants and carry
sampling error of order $n_T^{-1/2}$. An interval that conditions on
them omits that variability whenever the intended estimand refers to a
target *superpopulation* rather than to the particular people who
enrolled.

Catalog entry MIS-03 states the position. The weight-estimation half of
the uncertainty problem has been benchmarked: ([3](#ref-chandler2024))
compared conventional, ESS-rescaled, robust sandwich and bootstrap
variance estimators across 108 scenarios for binary and time-to-event
outcomes, finding conventional estimators anticonservative under poor
and moderate overlap and all methods valid under strong overlap. That is
a specific set of settings, not a general guarantee, and section 5 shows
the conventional sandwich failing outside them. The published-moment
half is untouched, because a baseline table arrives without the
covariance among its own entries.

Two results in the transportability literature propagate target-summary
uncertainty for entropy-balancing estimators
([4](#ref-sheng2026),[5](#ref-chen2026)). Neither is framed for the
anchored two-trial setting in which the target moments and the target
treatment effect come from the same participants, and neither has been
carried into indirect-comparison software. The general idea that
estimated calibration totals contribute variance, and that overlapping
samples induce covariance, is long established in survey calibration and
two-phase sampling; nothing here claims that as new. What is new is the
quantification for anchored MAIC and the identification of which term is
missing.

# The estimating system and what it omits

The source trial contributes $n_S$ participants with covariates
$X_i \in \mathbb{R}^3$, treatment indicator $A_i$ and outcome $Y_i$.
Write $h(X) = (X_1, X_2, X_3, X_1^2, X_2^2, X_3^2)^\top$; matching on
$h$ is matching on the reported means and standard deviations. A
publication reports the unbiased sample standard deviation $s_j$, and
the second raw sample moment is recovered as
$\hat m_{2j} = \{(n_T-1)/n_T\} s_j^2 + \bar x_j^2$, so the calibration
target is exactly the sample mean of $h(X)$ over the target
participants.

MAIC solves, over the source participants,

<span id="eq-calib">$$\sum_{i=1}^{n_S} w_i(\lambda)\,\{h(X_i) - \hat m_T\} = 0, \qquad w_i(\lambda) = \exp\{\lambda^\top h(X_i)\}, \qquad(1)$$</span>

the method-of-moments weighting of ([1](#ref-signorovitch2010)), the
dual of entropy balancing ([6](#ref-hainmueller2012)). Stacking
<a href="#eq-calib" class="quarto-xref">Equation 1</a> with the two
weighted arm-mean equations gives an M-estimator
([7](#ref-stefanski2002)) in $\psi = (\lambda, \mu_A, \mu_C)$ with score

$$u_i = \big(\,w_i\{h(X_i) - \hat m_T\},\ \ \mathbb{1}(A_i)\,w_i(Y_i - \mu_A),\ \ \mathbb{1}(C_i)\,w_i(Y_i - \mu_C)\,\big)^\top,$$

transported effect $\hat\theta_{AC} = \hat\mu_A - \hat\mu_C$, and
anchored estimate $\hat\theta_{AB} = \hat\theta_{AC} - \hat\theta_{BC}$.
With $\hat A$ the empirical Jacobian of the mean score,
$\hat B = n_S^{-1}\sum_i u_i u_i^\top$ and $c = (0,\dots,0,1,-1)^\top$,

<span id="eq-vs">$$V_S = c^\top \hat A^{-1} \hat B \hat A^{-\top} c \,/\, n_S . \qquad(2)$$</span>

<a href="#eq-vs" class="quarto-xref">Equation 2</a> conditions on
$\hat m_T$. Differentiating the estimating system with respect to the
reported moments, and using
$\partial u_{i,\lambda} / \partial \hat m_T^\top = -w_i I_6$,

<span id="eq-jacobian">$$J \;=\; \frac{\partial \hat\theta_{AC}}{\partial \hat m_T} \;=\; -\,c^\top \hat A^{-1} C, \qquad C = \begin{pmatrix} -\bar w I_6 \\ 0 \\ 0 \end{pmatrix}. \qquad(3)$$</span>

$J$ is zero in the population when no covariate in $h$ modifies the
treatment effect, which is why the study’s negative control has no
effect modification. In a finite randomized source trial chance
imbalance makes $\hat J$ nonzero, so the four intervals do not coincide
exactly even there; section 5 reports how much.

Two consequences. If $\hat m_T$ were independent of everything else the
interval would simply be too narrow, by $J^\top \Omega_{hh} J / n_T$.
But in the ordinary case $\hat m_T$ and $\hat\theta_{BC}$ come from
**the same people**. Writing $\phi_{BC}$ for the influence function of
the target arm-mean difference, the unconditional variance uses the
joint covariance of $\{h(X), \phi_{BC}\}$ with gradient $(J, -1)$:

<span id="eq-joint">$$V = V_S + (J, -1)^\top \,\Omega_T\, (J, -1) \,/\, n_T . \qquad(4)$$</span>

The cross term $-2\,J^\top \mathrm{Cov}\{h(X), \phi_{BC}\}/n_T$ is
negative when the target treatment’s effect is modified by the same
covariates as the source treatment’s. Conditioning therefore omits a
positive term and a negative term whose balance depends on a quantity
that appears nowhere in a publication.

## An identity that fixes the sign

Under this study’s mechanism the balance is exact to first order. With
$\tau(X) = \tau_0 + s\,g(X)$ in the source and $\tau_0 + \kappa s\,g(X)$
in the target, and $g$ linear in $h$ with coefficient vector $b$, the
population sensitivity is $J = s b$ and
$\mathrm{Cov}\{h(X), \phi_{BC}\} = \kappa\, s\, \Omega_{hh} b$. Hence

<span id="eq-identity">$$\underbrace{J^\top \Omega_{hh} J}_{\text{moment variance}} - \underbrace{2 J^\top \mathrm{Cov}\{h(X), \phi_{BC}\}}_{\text{cross term}} \;=\; (1 - 2\kappa)\, s^2 b^\top \Omega_{hh} b \;=\; (1-2\kappa)\,\mathrm{Var}_T\{\tau(X)\}, \qquad(5)$$</span>

so the net omission is $(1-2\kappa)\mathrm{Var}_T\{\tau(X)\}/n_T$. **The
sign is fixed by $\kappa$ analytically and the cancellation at
$\kappa = 1/2$ is a property of the design, not something the simulation
discovered.** This was pointed out in peer review; an earlier version of
this paper claimed the simulation located the cancellation point, and
that claim is withdrawn.

Regressing the measured omitted variance on
<a href="#eq-identity" class="quarto-xref">Equation 5</a> across **all**
216 scenarios with effect modification, not the restricted subset of
<a href="#sec-restricted" class="quarto-xref">Section 4.2</a>, gives a
slope of 1.003 (SE 0.042, $R^2 = 0.72$), confirming the identity to
first order.

The first-order **magnitude** is fixed by the design as well, since
$\mathrm{SD}_T(\tau)$, $\kappa$ and $n_T$ are all inputs. What the
simulation contributes is therefore narrower than an earlier version of
this paper claimed: the omitted component’s *fraction of total
variance*, which depends on source information the identity does not
fix; its *coverage* consequences; the finite-sample departures from
<a href="#eq-identity" class="quarto-xref">Equation 5</a>; and the
behavior of estimators that can only add the positive term. On the
negative controls, where the population omission is exactly zero, that
finite-sample departure moves the model standard error by a median of
0.26% and at most 1.49%.

$\kappa$ here imposes exact non-negative proportionality between the
source and target modifier coefficient vectors. Modifier sets differing
in direction, overlapping only partially, or orthogonal are **not**
studied, so $\kappa$ is not a general alignment parameter and no claim
is made about those cases.

# Methods

The protocol was registered before the run at
`studies/MIS-03-target-moment-uncertainty/protocol.md`. Reporting
follows ADEMP ([8](#ref-morris2019)).

Covariates are trivariate normal, unit variances, equicorrelation;
source centered at $0$ with correlation $0.30$, target at $d$ with
correlation $\rho_T$. Outcomes are continuous with additive effects and
$N(0,1)$ errors. The target trial’s participants are generated and
discarded; the estimator receives $n_T$, three means, three standard
deviations, and $\hat\theta_{BC}$ with its standard error.

Effect-modification strength is calibrated per scenario so the treatment
effect has a prespecified standard deviation in the *target* population,
because the quadratic coefficients are half the linear ones and fixed
coefficients would make the overlap factor change effect-modification
strength at the same time.

| Factor                                    | Levels         |
|-------------------------------------------|----------------|
| Source size $n_S$                         | 500, 2000      |
| Target size $n_T$                         | 200, 500, 2000 |
| Overlap $d$                               | 0, 0.4, 0.8    |
| Effect modification $\mathrm{SD}_T(\tau)$ | 0, 0.45, 0.90  |
| Alignment $\kappa$                        | 0, 0.5, 1      |
| Target correlation $\rho_T$               | 0.30, 0.60     |

252 scenarios, 5000 replicates each. The $\mathrm{SD}_T(\tau)$ levels
are labelled by their numerical values rather than as “ordinary” and
“strong”: no empirical calibration to published MAIC applications was
available, and value-laden labels would imply one.

$n_S$ is a factor because the omitted term is $J^\top \Omega J / n_T$
against a retained term of order $1/\mathrm{ESS}_S$, so what governs the
ratio is source versus target information rather than $n_T$ alone. A
pilot of 120 replicates per configuration over a 16-cell grid crossing
$n_S \in \{500, 2000\}$, $n_T \in \{200, 2000\}$, $d \in \{0, 0.8\}$ and
two effect-modification strengths, run before the design was fixed,
found the omission was 1% to 7% of variance at $n_S = 500$; the 23%
figure came from $n_S = 2000$, $n_T = 200$, $d = 0.8$ at the stronger
modification. Those numbers justified making $n_S$ a factor and are
reported here so the justification is checkable.

**Estimand.** The target-superpopulation marginal $A$ versus $B$ mean
difference, $(1-\kappa)s(0.30d + 0.15d^2)$, exact in closed form and
verified against a $3\times10^6$-draw evaluation in every cell to within
$2\times10^{-4}$. Conditioning on the reported moments is *correct* when
the estimand is defined by those moments or they are exact
administrative counts; the problem exists only for a superpopulation
estimand.

## Methods compared

All four share the same point estimate, so the comparison isolates the
interval.

| Method | Interval variance | Corrects |
|----|----|----|
| **target-fixed** (status quo) | $V_S + \widehat{\mathrm{Var}}(\hat\theta_{BC})$ | nothing |
| **normal-recon** | $+\,J^\top \Omega_{\mathrm{norm}} J / n_T$ | positive term only |
| **reported-cov** | $+\,J^\top \Omega_{hh} J / n_T$ | positive term only |
| **joint-score** | <a href="#eq-joint" class="quarto-xref">Equation 4</a> | both terms |

$\Omega_{\mathrm{norm}}$ is reconstructed from the reported means and
standard deviations and a borrowed correlation under a multivariate
normal model. It is the only one an analyst can compute today.

**`normal-recon` and `reported-cov` are partial corrections, and they
help over a narrower range than we first stated.** They add
$M = J^\top \Omega J/n_T$, which is non-negative, and omit the cross
term. Writing the correct increment as $(1-2\kappa)M$, the status quo is
wrong by $|1-2\kappa|M$ and the partial method is wrong by $2\kappa M$.
The partial method is therefore closer to the right variance only when
$2\kappa < |1-2\kappa|$, that is when

<span id="eq-quarter">$$\kappa < 1/4 . \qquad(6)$$</span>

They tie at $\kappa = 1/4$ and are **worse than doing nothing** for
$1/4 < \kappa < 1/2$, a range in which an earlier version of this paper
said they helped. Peer review supplied this correction.

The design has $\kappa \in \{0, 0.5, 1\}$ and therefore **no interior
values with which to test
<a href="#eq-quarter" class="quarto-xref">Equation 6</a> empirically**.
<a href="#eq-quarter" class="quarto-xref">Equation 6</a> is an analytic
result with no empirical support at the boundary it defines, and both
reviewers identified that as the largest gap between what this paper
recommends and what it tests. Results are reported stratified by
$\kappa$ and no claim is made about intermediate alignment.

`joint-score` receives $\Omega_T$ computed inside the simulation and
passed **as a matrix only**; it is an enhanced-reporting benchmark, not
an assumption that microdata are available.

# Results

Convergence was at least 99.96% in every one of the 252 scenarios. The
largest absolute bias was 0.052 empirical standard errors and coverage
and bias-eliminated coverage never differed by more than 0.24 percentage
points, so what follows is a property of the interval and not of the
point estimate.

## The registered result: uninformative

The protocol declares the run uninformative if the reference method or
any negative control leaves 0.93 to 0.97. Across the grid that condition
is met, and **the registered conclusion is uninformative.**

The cause is a second failure worth reporting on its own account. At
$d = 0.8$ the effective sample size falls to a median of about 148 of
500 and the Wald sandwich undercovers for *every* method, including
scenarios with $\mathrm{SD}_T(\tau) = 0$
(<a href="#fig-overlap" class="quarto-xref">Figure 1</a>). There the
reported moments carry no population information about the transported
effect, $J$ is zero in expectation, and all four intervals should very
nearly coincide. They do coincide, and at poor overlap they are wrong
together by up to seven percentage points.

This bears directly on the framing in section 1.
([3](#ref-chandler2024)) found conventional estimators anticonservative
under poor and moderate overlap; the conventional sandwich used here
fails in exactly that region. Source weight-estimation variance is
therefore not “settled” in the sense of a procedure that works
everywhere, and any absolute-coverage claim outside the region where the
controls hold is unsupported.

<div id="fig-overlap">

![](../results/figures/fig5-overlap-failure.png)

Figure 1: With no effect modification the reported moments carry no
population information about the transported effect, so all four methods
should nearly coincide. They do, and at poor overlap they are all wrong
together.

</div>

## The exploratory restriction

Applying the same criterion per scenario leaves **196 of 252** scenarios
in which the reference and its matched negative control are both
nominal.

**This selects on an observed outcome.** The selecting quantity is the
reference method’s coverage, which shares replicates with every other
method through the common point estimate and source sandwich, so the
reference method’s coverage range within the restricted set is partly
guaranteed by the selection. Everything in this section is exploratory,
is **hypothesis-generating only**, and should not be cited as evidence
for or against any method’s coverage properties. A confirmatory answer
needs a fresh run under a new registration, with either an ex ante
design criterion such as expected effective sample size or an overlap
restriction fixed in advance, or a source variance procedure validated
to pass the controls throughout. We did not re-restrict by an ex ante
criterion and report whether the conclusions change; that is part of the
same required rerun.

<div id="tbl-kappa">

Table 1: Variance omitted by the status quo, stratified by alignment.
Defined as
$100{(\overline{\mathrm{SE}}_{\text{joint}}/\overline{\mathrm{SE}}_{\text{fixed}})^2 - 1}$,
where each $\overline{\mathrm{SE}}$ is that method’s mean model standard
error within the scenario. Positive means the reported interval is too
narrow. Exploratory.

<div class="cell-output-display">

| Alignment | Minimum | Median | Maximum | Sign predicted by identity |
|----------:|--------:|-------:|--------:|:---------------------------|
|       0.0 |     0.9 |    4.1 |    14.9 | positive                   |
|       0.5 |    -0.0 |    0.7 |     2.5 | zero                       |
|       1.0 |    -9.5 |   -2.3 |     0.0 | negative                   |

</div>

</div>

<div id="fig-omitted">

![](../results/figures/fig3-omitted-variance.png)

Figure 2: The omitted variance component. Magnitude grows with the ratio
of source to target information; the sign follows
<a href="#eq-identity" class="quarto-xref">Equation 5</a>.

</div>

Magnitude tracks the ratio of source to target information, as
<a href="#eq-jacobian" class="quarto-xref">Equation 3</a> predicts: the
omitted term scales as $1/n_T$ and the retained term as
$1/\mathrm{ESS}_S$, so a large source trial matched to a small target
publication is the worst case, not a small target trial as such.

<div id="tbl-methods">

Table 2: Coverage of nominal 95% intervals across the restricted
scenarios with effect modification present, stratified by alignment.
These are the 167 of the 196 restricted scenarios that have effect
modification; the other 29 are the negative controls. Monte Carlo
standard error is 0.31 percentage points at nominal coverage.
Exploratory.

<div class="cell-output-display">

| Method | kappa=0 | kappa=0.5 | kappa=1 | Outside 93-97% |
|:---|---:|---:|---:|---:|
| Status quo | 92.1% to 95.0% | 92.8% to 95.7% | 93.5% to 96.2% | 8 of 167 |
| Normal reconstruction (partial) | 93.2% to 95.6% | 93.5% to 96.5% | 93.7% to 97.0% | 0 of 167 |
| Reported moment covariance (partial) | 93.2% to 95.4% | 93.5% to 96.3% | 93.7% to 97.0% | 0 of 167 |
| Full joint score | 93.2% to 95.3% | 93.2% to 95.8% | 93.4% to 95.5% | 0 of 167 |

</div>

</div>

The minimum paired differences in
<a href="#tbl-paired" class="quarto-xref">Table 3</a> are within about
one and a half Monte Carlo standard errors of zero and carry no
directional interpretation; only the maxima are large relative to Monte
Carlo error.

The status quo is the only method to leave the band, and it leaves in
both directions. The two partial corrections behave as
<a href="#eq-identity" class="quarto-xref">Equation 5</a> requires: they
help at $\kappa = 0$, are mildly conservative at $\kappa = 0.5$ where
the net omission is zero, and are more conservative at $\kappa = 1$
where the interval was already too wide.

<div id="fig-methods">

![](../results/figures/fig2-methods.png)

Figure 3: Only the status quo leaves the band.

</div>

<div id="fig-coverage">

![](../results/figures/fig1-coverage-error.png)

Figure 4: Status-quo coverage error against the ratio of source to
target information.

</div>

<div id="tbl-paired">

Table 3: Paired coverage differences against the full joint score, in
percentage points, with the discordance counts that determine their
Monte Carlo error. A paired difference is a McNemar contrast on shared
replicates, so its Monte Carlo error is governed by the discordant pairs
and not by the marginal coverages. Exploratory.

<div class="cell-output-display">

| Method | Median | Minimum | Maximum | Mean discordant replicates | Mean MCSE (pp) |
|:---|---:|---:|---:|---:|---:|
| Status quo | -0.12 | -2.12 | 1.04 | 25 | 0.09 |
| Normal reconstruction (partial) | 0.32 | -0.12 | 2.00 | 27 | 0.09 |
| Reported moment covariance (partial) | 0.28 | -0.12 | 1.92 | 25 | 0.09 |

</div>

</div>

The single scenario that triggered the prespecified “material at
ordinary strength” category was $n_S = 2000$, $n_T = 500$, $d = 0.8$,
$\mathrm{SD}_T(\tau) = 0.45$, $\kappa = 0$, $\rho_T = 0.30$, with
coverage 0.930 against a Monte Carlo standard error of 0.36 percentage
points. It sits at the poor-overlap boundary where the sandwich is
already marginal, and no weight is placed on it.

## What a publication would have to report

The normal reconstruction needs nothing beyond what is published plus a
correlation matrix borrowed from the source. Within the restricted
scenarios it kept coverage inside 93% to 97% everywhere, at a median
interval-width cost of 2.24% and a maximum of 8.70%, and its paired
difference from being handed the target’s true moment covariance was
small relative to the differences from the benchmark
(<a href="#tbl-paired" class="quarto-xref">Table 3</a>,
<a href="#fig-reporting" class="quarto-xref">Figure 5</a>).
Interval-width cost is
$100(\overline{w}_{\text{recon}}/\overline{w}_{\text{fixed}} - 1)$ with
$\overline{w}$ the scenario-mean interval width. Both this and the
omitted-variance measure are ratios of scenario summaries, not means of
replicate-level ratios; extrema across scenarios are reported without a
multiplicity adjustment and should be read as the range observed rather
than as estimates of a worst case.

<div id="fig-reporting">

![](../results/figures/fig4-reporting.png)

Figure 5: What each level of target reporting buys, as paired
differences against the benchmark using all target information.

</div>

**The recommendation this licenses is narrow.** Covariates here are
multivariate normal, which is the assumption under which the
reconstruction formulas are exactly correct, and the only
misspecification examined moves one positive equicorrelation from 0.30
to 0.60. Real baseline tables contain skewed, bounded, categorical,
rounded and partially missing variables, and nothing here speaks to
those. For approximately normal continuous covariates with modest
correlation error, and where $\kappa$ is believed below about one
quarter, adding $J^\top\Omega_{\mathrm{norm}}J/n_T$ costs about 2% of
interval width and removes a real omission. Where $\kappa$ may be large
the same addition makes a conservative interval more conservative.
Correcting that case needs the covariance between the target’s covariate
moments and its treatment-effect estimate, which the usual inputs do not
supply; we are not aware of a deployable correction, though reported
subgroup effects or interaction estimates might in principle carry some
of the required information, and we have not investigated that.

An earlier version of this paper recommended the addition generally and
concluded that the case for journals publishing moment covariance
matrices is weak. Both claims were withdrawn in peer review: the first
because the correction is partial, the second because the comparison
establishing it was run under conditions favorable to the
reconstruction.

# What this answers, and what it does not

**What is established, and by what.** Two different things, and they
should not be run together. *Analytically*: the omitted component is
$(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$ to first order, its sign is set
by $\kappa$, and a correction adding only the positive term helps only
for $\kappa < 1/4$. That holds wherever the mechanism’s assumptions hold
and does not depend on the simulation. *Empirically, and only in the
restricted exploratory set*: the fraction of total variance this
represents, the resulting coverage, and the finite-sample departures.
**The registered coverage question is not confirmatorily answered**,
because every usable coverage result comes from a post-run restriction
that conditions on an observed outcome. A confirmatory answer requires
the fresh registered run described in section 5.2.

**Does not answer.** Skewed, bounded, categorical, rounded or missing
covariates. Binary and time-to-event outcomes, where MAIC is most used
and noncollapsibility adds a term this design cannot see. Bias from
unmeasured effect modifiers, since modification lies exactly in the
matched span. Target summaries drawn from a sample separate from the
treatment-effect estimate, or a covariate-adjusted published effect with
a different influence function. STC, ML-NMR, ML-UMR and NMI, which have
different sensitivities $J$. And absolute coverage at poor overlap,
where the source variance estimator fails first.

Accordingly, and stated precisely rather than as “answers in part”: this
study contributes an **analytic** result to MIS-03,
<a href="#eq-identity" class="quarto-xref">Equation 5</a> and
<a href="#eq-quarter" class="quarto-xref">Equation 6</a>, which the
simulation confirms as theory and which does not depend on the
restricted set; and it contributes **exploratory only** evidence on the
coverage question MIS-03 actually asks, which is therefore **not**
answered confirmatorily. It answers one named component of EST-07,
sampling error in reported moments, on the same footing. EST-07’s
remaining components, model uncertainty in reconstructed correlations,
inclusion-criteria ambiguity and secular drift, are not sampling error
and are untouched.

**Where $\kappa$ might come from.** The practical recommendation turns
on $\kappa$, which the usual inputs do not identify. Published subgroup
effects, reported treatment-by-covariate interactions, or
covariate-outcome summaries in the target trial could in principle carry
information about how far the target treatment’s effect is modified by
the same covariates. Establishing what those inputs identify, and how
much of $\kappa$ they pin down, would make the correction deployable in
the range where it currently is not. We have not investigated it.

**A finding nobody asked for.** The poor-overlap sandwich failure in
<a href="#sec-registered" class="quarto-xref">Section 4.1</a> is larger
than the effect this study was built to measure and deserves its own
study.

# Peer review

This manuscript was reviewed in two rounds. Reports, the authors’
point-by-point responses and the editorial decision are published in
full at
`studies/MIS-03-target-moment-uncertainty/review/peer-review.md`. Review
changed the paper substantially: the registered result is now reported
first and the restricted analysis is labelled exploratory; the sign of
the effect is presented as the analytic identity it is rather than as a
finding; the two deployable corrections are relabelled partial and the
general recommendation to use them is withdrawn; and a factual claim
that the protocol had anticipated the sandwich failure was found to be
wrong and retracted.

# Reproducibility

R: R version 4.6.0 (2026-04-24) Platform: aarch64-apple-darwin23 Running
under: macOS Tahoe 26.5

## Packages

| package | version |
|---------|---------|
| base    | 4.6.0   |
| stats   | 4.6.0   |
| future  | 1.70.0  |
| furrr   | 0.4.0   |

## Run

- **study**: MIS-03 / EST-07 target-moment uncertainty
- **scenarios**: 252
- **replicates_per_scenario**: 5000
- **total_replicates**: 1260000
- **master_seed**: 20260727

Replicate seeds derive from one master seed through L’Ecuyer-CMRG
streams, so a run gives identical results on any number of cores and an
interrupted run resumes. Code, protocol, review history and results are
at
<https://github.com/choxos/ITC-open-problems/tree/main/studies/MIS-03-target-moment-uncertainty>.

``` bash
Rscript R/03-run.R        # 252 scenarios, resumable
Rscript R/04-analyze.R
Rscript R/05-figures.R
```

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-signorovitch2010" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">James E. Signorovitch, Eric Q. Wu,
Andrew P. Yu, Charles M. Gerrits, Evan Kantor, Yanjun Bao, Shiraz R.
Gupta, Parvez M. Mulani. Comparative effectiveness without head-to-head
trials: A method for matching-adjusted indirect comparisons applied to
psoriasis treatment with adalimumab or etanercept. PharmacoEconomics.
2010;28(10):935–45.
doi:[10.2165/11538370-000000000-00000](https://doi.org/10.2165/11538370-000000000-00000)</span>

</div>

<div id="ref-phillippo2018" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">David M. Phillippo, A. E. Ades,
Sofia Dias, Stephen Palmer, Keith R. Abrams, Nicky J. Welton. Methods
for population-adjusted indirect comparisons in health technology
appraisal. Medical Decision Making. 2018;38(2):200–11.
doi:[10.1177/0272989X17725740](https://doi.org/10.1177/0272989X17725740)</span>

</div>

<div id="ref-chandler2024" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Conor Chandler, Irina
Proskorovsky. Uncertain about uncertainty in matching-adjusted indirect
comparisons? A simulation study to compare methods for variance
estimation. Research Synthesis Methods. 2024;15(6):1094–110.
doi:[10.1002/jrsm.1759](https://doi.org/10.1002/jrsm.1759)</span>

</div>

<div id="ref-sheng2026" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">Ying Sheng, Yifei Sun, Chiung-Yu
Huang. Transportable inference using target population summary
statistics under covariate shift \[Internet\]. 2026. Available from:
<https://arxiv.org/abs/2603.02474></span>

</div>

<div id="ref-chen2026" class="csl-entry">

<span class="csl-left-margin">5.
</span><span class="csl-right-inline">Yi Chen, Xinyuan Chen, Menggang
Yu. Confidence interval construction for causally generalized estimates
with target sample summary information. Statistics in Medicine.
2026;45(1-2):e70358.
doi:[10.1002/sim.70358](https://doi.org/10.1002/sim.70358)</span>

</div>

<div id="ref-hainmueller2012" class="csl-entry">

<span class="csl-left-margin">6.
</span><span class="csl-right-inline">Jens Hainmueller. Entropy
balancing for causal effects: A multivariate reweighting method to
produce balanced samples in observational studies. Political Analysis.
2012;20(1):25–46.
doi:[10.1093/pan/mpr025](https://doi.org/10.1093/pan/mpr025)</span>

</div>

<div id="ref-stefanski2002" class="csl-entry">

<span class="csl-left-margin">7.
</span><span class="csl-right-inline">Leonard A. Stefanski, Dennis D.
Boos. The calculus of m-estimation. The American Statistician.
2002;56(1):29–38.
doi:[10.1198/000313002753631330](https://doi.org/10.1198/000313002753631330)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">8.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
