# A shared interaction matrix in component multilevel network
meta-regression forces a causal coefficient to equal a confounded one
Ahmad Sofi-Mahmudi
2026-07-28

# Abstract

Component multilevel network meta-regression estimates
treatment-by-covariate interactions from individual and aggregate data
together, fitting one shared interaction matrix on a globally centered
covariate. For a binary modifier with study-specific prevalence that
parameterization is algebraically identical to **imposing** that the
within-trial interaction, which randomization makes causal, equals the
across-trial association between a study’s case mix and its treatment
effect, which nothing randomizes.

In 320 scenarios and 640,000 simulated component networks, coverage of a
nominal 95% interval for the causal within-trial interaction falls from
93.8% when the restriction happens to be true to 17.2% when the two
coefficients are equal and opposite. Separating them restores it: the
joint split and the IPD-anchored estimator stay within 92.6% to 96.3%
across every discordance examined.

**The catalog’s stated cause is incomplete rather than wrong.** CMP-13
says aggregate studies pull the shared estimate. With **all twelve
trials supplying individual patient data** the shared model still has
median absolute standardized bias 0.15 and coverage as low as 44.6%, so
aggregate data are **not necessary** for the conflation. But removing
individual data makes it worse, from median 0.15 at full availability to
0.29 at the sparsest, so aggregate data **amplify** it. The restriction
is the cause; aggregate data are an aggravating factor.

**A component with no within-trial information behaves differently
again.** There the IPD-anchored estimator declines to report, as it
should; the shared model returns an estimate of -0.34 against a truth of
zero, of the wrong sign and sourced entirely from the ecological
gradient; and the joint split returns intervals so wide that coverage
approaches one, when it returns one at all. The failure in both cases is
that a number is produced at all, not that the interval is narrow.

**A cluster-robust variance made things worse.** With twelve studies the
study-clustered sandwich covered 75.4% to 92.4% in scenarios where the
shared model is correctly specified, so it is reported as a finding
rather than used as a comparator.

# The problem

Component network meta-analysis decomposes multicomponent interventions
into the parts they share, so that a network which is disconnected at
the level of whole treatments can be reconnected through common
components ([1](#ref-rucker2020)). Multilevel network meta-regression
(ML-NMR) synthesizes individual and aggregate data by specifying a model
at the individual level and integrating it over each study’s covariate
distribution ([2](#ref-phillippo2020mlnmr),[3](#ref-phillippo2025)).
Component ML-NMR combines the two, and estimates a single interaction
matrix $\Gamma$ describing how covariates modify component effects.

That single matrix is the problem. For a binary modifier $X$ with
prevalence $p_s$ in study $s$, a shared interaction fitted on the
globally centered covariate satisfies the identity

<span id="eq-identity">$$\gamma\,(X - 0.5) \;=\; \underbrace{\gamma\,(X - p_s)}_{\text{within trial}} \;+\; \underbrace{\gamma\,(p_s - 0.5)}_{\text{across trials}} . \qquad(1)$$</span>

The two pieces are not the same kind of quantity. The within-trial
coefficient $\gamma_W$ is identified by randomized comparisons between
covariate strata inside a trial; it is a causal interaction. The
across-trial coefficient $\gamma_B$ is the association between a study’s
case mix and its treatment effect across trial populations that nobody
randomized, and is confounded by everything else that differs between
them: era, setting, adherence, concomitant care.

<a href="#eq-identity" class="quarto-xref">Equation 1</a> shows that
fitting one shared $\gamma$ does not pool two sources of information. It
**imposes** $\gamma_W = \gamma_B$.

Separating them by centering covariates at the trial mean is
long-standing advice in individual-participant meta-analysis
([4](#ref-hua2017)–[6](#ref-riley2020)). It has not been carried into
component ML-NMR. `multinma`’s `center` argument does not do it: that
centers regression terms about the *overall* mean, which is numerical
conditioning, and only per-study centering separates the two sources.
This was checked against the package documentation for version
0.9.1.9002.

Two catalog entries state the gap. CMP-13 says a shared $\Gamma$ lets
aggregate studies pull the estimate toward a non-randomized across-trial
association. IDN-06 says interaction directions without adequate
within-study individual data are weakly identified and are then
sensitive to aggregate variation, so one coefficient carrying both
sources conflates individual-level effect modification with an
ecological gradient.

<a href="#eq-identity" class="quarto-xref">Equation 1</a> already
settles that the shared model is misspecified when
$\gamma_W \neq \gamma_B$. Three things it does not settle, and which
this study measures: how much the restriction costs and at what
discordance; whether the cause is really the aggregate data, as CMP-13
states; and what happens to a component that has no within-trial
information at all.

# Design

The protocol was registered before the run and is reproduced at
`studies/CMP-13-within-between-interaction/protocol.md`. Reporting
follows ADEMP ([7](#ref-morris2019)).

## Data-generating mechanism

Twelve two-arm randomized trials over four regimens built from two
components: control $=(0,0)$, A $=(1,0)$, B $=(0,1)$, AB $=(1,1)$. One
binary modifier $X$ with study prevalence $p_s$; write $z = X - p_s$.
The individual log rate is

<span id="eq-dgm">$$\eta = \alpha_s + \beta z + \sum_{c \in \{A,B\}} a_c \{\, \delta_c + \gamma_{W,c}\, z + q_c(p_s) \,\}, \qquad(2)$$</span>

with $\beta = \log 1.5 = 0.4055$, $\delta_A = \log 0.70 = -0.3567$,
$\delta_B = \log 0.75 = -0.2877$, and $\alpha_s = \log 0.30 + u_s$,
$u_s \sim \mathrm{Unif}(-0.2,0.2)$. The within-trial interactions are
$\gamma_{W,A} = \log 1.5 = 0.4055$ and
$\gamma_{W,B} = \log 0.70 = -0.3567$, that is, rate-ratio interaction
multipliers of 1.50 and 0.70 for $X = 1$ against $X = 0$; they are zero
under `null` and `between-only`. Reviewers asked for these because
$\rho$ alone does not fix the absolute discrepancy: at $\rho = 0.5$ the
gap $\gamma_B - \gamma_W$ is $0.203$ for component A on the log-rate
scale, and at $\rho = -1$ it is $0.811$. The nonlinear pattern uses
$q_A(p) = 1.5\{(p-0.5)^2 - M\}$ and $q_B(p) = -1.2\{(p-0.5)^2 - M\}$
with $M$ the mean of $(p_s-0.5)^2$ over the twelve prevalences, so its
linear projection is near zero by symmetry. The twelve prevalences are
0.35 to 0.65 in the narrow setting and 0.15 to 0.85 in the wide one,
allocated so that each of the four trial designs receives one value from
each tertile. Outcomes are Poisson with unit exposure. The across-trial
term is $q_c(p_s) = \gamma_{B,c}(p_s - 0.5)$ with
$\gamma_B = \rho\,\gamma_W$, so $\rho$ is the discordance: at $\rho = 1$
a single shared $\Gamma$ is exactly correct.

Aggregate arms are generated by **exact integration**: the arm total is
Poisson with mean $n_0 e^{\eta \mid X=0} + n_1 e^{\eta \mid X=1}$. This
is exactly the distribution of the sum of the individual outcomes
**because the covariate counts are fixed**: allocation is stratified
with $n_1 = \lfloor n p_s \rceil$ and $n_0 = n - n_1$, so $p_s$ is a
realized finite-sample stratum proportion and not a Bernoulli sampling
probability. Had covariates been drawn independently as
Bernoulli$(p_s)$, the arm total would be a Poisson mixture with extra
variation and the stated equality would be false. Peer review asked
which construction was used; it is the fixed-count one, and the
distinction matters for the standard errors. Generating aggregate arms
by a regression on $p_s$ would test a method nobody uses, since ML-NMR
integrates precisely to avoid that.

## Factors

| Factor | Levels |
|----|----|
| Network structure | isolating, bundled |
| Discordance | $\rho \in \{1, 0.5, 0, -0.5, -1\}$, plus null, between-only, nonlinear |
| Individual data | all 12 trials, six, four, four lowest-prevalence, none containing component B |
| Participants per arm | 100, 400 |
| Prevalence spread | narrow (0.35 to 0.65), wide (0.15 to 0.85) |

Fully factorial: **320 scenarios**, 2000 replicates each, 640,000
networks.

Two of these exist because an adversarial review of the design found the
study would otherwise have answered a different question.

**Network structure.** In the design as first proposed, every contrast
added exactly one component, so each interaction was recoverable from a
directly component-isolating comparison: the study would have tested
ordinary network meta-regression while claiming to test component
models. The `bundled` network contains `control:AB`, which moves both
components at once, and `A:B`, which removes one while adding the other,
so contrasts are aliased across components and the component
decomposition has to do real work. Both structures still identify both
component main effects.

**A component with no within-trial information.** No proposed pattern
produced IDN-06’s actual case. The `no-B-ipd` scheme gives individual
data only to trials in which component B never appears in any arm.
Constructing it required a correction: the within-trial estimator
identifies $\gamma_W$ from the covariate slope *inside an arm*, which is
$\beta + \sum_c a_c \gamma_{W,c}$, not from the treatment contrast, so a
single arm containing component B identifies $\gamma_{W,B}$ once $\beta$
is known even where no contrast in that trial changes B.

That construction also bounds what “within-trial” buys here, and peer
review was right to press on it. Randomization identifies a
treatment-by-covariate interaction through *differences in treatment
contrasts across baseline covariate strata*. The stage-one estimator
instead reads $\gamma_W$ off arm-level covariate slopes, which
additionally assumes a prognostic slope $\beta$ common across arms and
studies. Under this data-generating mechanism that assumption holds by
construction. It is a modeling assumption, not a consequence of
randomization, and calling the resulting coefficient causal is therefore
conditional on it. In bundled networks a component interpretation
further requires component additivity and consistency, which also hold
here by construction.

## Estimand and methods

The estimand is the within-trial component interaction $\gamma_{W,c}$:
the difference in conditional log rate ratio for adding component $c$
between otherwise comparable randomized individuals with $X = 1$ and
$X = 0$ in the same trial. The truth is the coefficient the pattern
specifies, so no Monte Carlo evaluation is needed.

All methods maximize the same integrated component likelihood by maximum
likelihood with analytic gradients, study intercepts profiled
analytically ([8](#ref-stefanski2002)), and Newton polishing until the
maximum absolute score falls below $10^{-6}$.

| Method | Interaction parameterization | What may inform $\gamma_W$ |
|----|----|----|
| **Shared** (status quo) | one $\gamma_c$ on $X - 0.5$ | everything, with $\gamma_W = \gamma_B$ imposed |
| **Shared + sandwich** | identical point estimate | as above, with a 12-study cluster sandwich |
| **Joint split** | $\gamma_{W,c}$ on $z$, $\gamma_{B,c}$ on $p_s - 0.5$ | everything, including aggregate curvature |
| **IPD anchored** | $\gamma_{W,c}$ from individual data only, free intercept per study-arm | within-arm covariate slopes in individual data only |

The sandwich variant exists so the comparison cannot be won merely by
giving the proposed method a more robust variance estimator. The
IPD-anchored method **declines to report** a component appearing in no
individual-data arm, returning it as not estimable rather than supplying
a number from an ecological gradient.

Failures are not dropped silently: every measure is computed over
converged replicates and again counting a failure as non-coverage, and
declining to report is counted separately from failing to converge,
because refusing to answer is a design feature of one method.

# Results

## The registered global result

Read across all 320 scenarios, the registered gates fail: the negative
controls of the shared model lie outside 0.93 to 0.97 in 15 of 160
control scenarios and the split model’s in 27 of 160. **The registered
conclusion is therefore uninformative**, and it is reported first for
the same reason it was in the previous study of this program.

The cause is confined to one factor level, and everything below is what
follows from splitting on it. That split was made after seeing the
pooled result. It is on a level of a factor fixed before the run rather
than on an observed outcome, which is a weaker objection than selection
on results but not the same as prespecification, and the protocol
amendment says so.

## Two regimes

The grid splits into 256 scenarios in which every component has
within-trial information, and 64 in which one component has none. In the
second the shared and joint models are near-unidentified for that
component, failing to return an interval on 11% of replicates against
0.02% elsewhere. Pooling the two makes the negative controls fail and
describes neither, so they are reported separately. This is a different
move from restricting by an observed outcome, and the protocol amendment
says so.

In the primary regime every gate passes: convergence, agreement between
conditional and unconditional summaries, and the negative controls of
all three main methods.

## What the restriction costs

<div id="tbl-rho">

Table 1: Coverage of nominal 95% intervals for the within-trial
component interaction in the primary regime, as a range over network
structure, individual-data availability, arm size, prevalence spread and
component.

<div class="cell-output-display">

| Discordance | Shared | Joint split | IPD anchored |
|:---|---:|---:|---:|
| $\rho = 1$ (shared correct) | 93.850 to 95.800 | 93.844 to 96.000 | 93.750 to 95.900 |
| $\rho = 0.5$ | 88.250 to 95.900 | 93.750 to 96.148 | 93.800 to 96.200 |
| $\rho = 0$ | 65.500 to 96.250 | 93.644 to 95.950 | 93.900 to 96.050 |
| $\rho = -0.5$ | 38.600 to 95.600 | 93.700 to 95.950 | 93.600 to 95.950 |
| $\rho = -1$ | 17.200 to 95.950 | 92.635 to 96.042 | 93.100 to 96.300 |
| no within-trial modification | 67.700 to 96.000 | 94.100 to 96.250 | 94.050 to 96.250 |
| nonlinear across-trial | 64.950 to 95.550 | 94.400 to 96.200 | 94.300 to 96.300 |

</div>

</div>

Median coverage under the shared restriction falls monotonically as the
two coefficients diverge: 0.950, 0.947, 0.941, 0.934, 0.918 at
$\rho = 1, 0.5, 0, -0.5, -1$. It is lower in the **bundled** network,
where contrasts move two components at once, than where every contrast
isolates one, by -0.9 to -0.3 percentage points on the medians; the
direction is consistent across every discordance but the size is modest
and should not be overstated.

Separating the coefficients removes almost all of it. The joint split
lies inside 0.93 to 0.97 in 511 of 512 scenarios; the single exception
covers 0.926, about four Monte Carlo standard errors below nominal, so
“nominal everywhere” would be wrong and is not claimed. The IPD-anchored
estimator lies inside the band in 512 of 512. Both hold under the
nonlinear across-trial pattern, where the linear split model is itself
misspecified.

**What separation costs.** It is not free, but it is cheap. Across
discordant scenarios in the primary regime, the split estimator’s
empirical standard error is 1.048 times the shared model’s and its
intervals are 1.058 times as wide, while its median absolute bias is
0.003 against 0.039. Roughly five per cent more width buys an order of
magnitude less bias.

The prespecified conclusion is **material at mild discordance**: at
$\rho = 0.5$ and $n = 400$, 2 of 32 cells fall below 0.90 coverage with
Monte Carlo intervals excluding nominal, both in the bundled network.

<div id="fig-cov">

![](../results/figures/fig1-coverage-by-discordance.png)

Figure 1: Coverage against the discordance between the within-trial and
across-trial coefficients.

</div>

<div id="fig-controls">

![](../results/figures/fig3-controls.png)

Figure 2: Negative controls: where the shared model is correctly
specified, every method is nominal.

</div>

## The cluster-robust comparator fails its own controls

The sandwich here is the uncorrected CR0 form, $H^{-1} B H^{-1}$ with
$B = \{m/(m-1)\}\sum_s U_s U_s^\top$ over the $m = 12$ study score
vectors, with normal critical values and no degrees-of-freedom
adjustment. No small-cluster correction of the CR2 or Bell-McCaffrey
type was applied, and the established small-sample cluster-robust
literature would predict exactly the anticonservatism seen; the result
is reported as an observation about an uncorrected twelve-cluster
estimator in this setting, not as a contribution to that literature.

`shared-sandwich` was included so the comparison could not be won by
giving the proposed method a better variance estimator. It covered 75.4%
to 92.4% in the 128 control scenarios where the shared model is
correctly specified. With twelve studies the study-clustered sandwich is
badly anticonservative, and it is reported as a finding rather than used
as the status quo. The status quo is the model-based interval, which
passes its controls.

## Is the cause the aggregate data?

CMP-13 states that aggregate studies pull the shared estimate toward the
across-trial association. That is a claim about cause and the protocol
registered it as a separate test.

<div id="tbl-mech">

Table 2: Absolute standardized bias of the shared model across
discordant scenarios, by how many trials supply individual patient data.
If the catalog’s mechanism were right, the first row would be near zero.

<div class="cell-output-display">

| Individual data from          | Median | Maximum | Above 0.20 | Worst coverage |
|:------------------------------|-------:|--------:|-----------:|---------------:|
| All 12 trials                 |   0.15 |    2.03 |        48% |          44.6% |
| Six trials                    |   0.22 |    2.32 |        52% |          33.7% |
| Four trials                   |   0.29 |    2.80 |        56% |          17.2% |
| Four lowest-prevalence trials |   0.26 |    2.82 |        56% |          18.2% |

</div>

</div>

With **every** trial supplying individual patient data the shared model
still has median absolute standardized bias 0.15, a maximum of 2.03, and
coverage as low as 44.6%.

The prespecified support threshold required absolute standardized bias
below 0.10 everywhere, which fails. The prespecified refutation
threshold required more than half of the cells above 0.20; 48% are,
which is just short of it. **The claim is therefore not supported, and
falls narrowly short of the registered refutation threshold.** We report
it that way rather than moving the threshold.

What the evidence does show is narrower than an earlier draft claimed.
Bias is present at full individual-data availability, so aggregate data
are **not necessary** for the conflation; the parameterization alone
produces it. But bias also grows as individual data are removed, from
median 0.153 with all twelve trials to 0.285 at the sparsest, with
worst-case coverage falling from 44.6% to 17.2%. Aggregate data
therefore **amplify** it. CMP-13’s mechanism is incomplete rather than
wrong: it names an aggravating factor as the cause.

<div id="fig-mech">

![](../results/figures/fig2-mechanism.png)

Figure 3: If the catalog’s mechanism were right, the left-hand column
would sit near zero.

</div>

## A component with no within-trial information

In the second regime one component appears in no individual-data arm, so
its within-trial interaction has no within-trial information anywhere.
Three behaviors, all different.

The **IPD-anchored** estimator declined to report it in 100% of
replicates, which is what it is designed to do.

The **shared** model returned an estimate. In the pattern where the true
within-trial interaction is exactly zero, its mean estimate was -0.340:
the wrong sign and magnitude, sourced entirely from the across-trial
gradient. Its coverage there is 90.5%, which is high only because the
intervals are very wide, not because the estimate is good. The failure
is that a number is produced at all.

The **joint split** returned intervals so wide that coverage approaches
one, when it returned one at all; it failed to produce an interval on a
large minority of replicates. Separating the coefficients protects the
estimate from ecological information but cannot manufacture within-trial
information that does not exist, and the honest output in that case is
the refusal.

<div id="fig-noipd">

![](../results/figures/fig4-no-ipd-component.png)

Figure 4: What each method does for a component that appears in no
individual-data arm.

</div>

# What this answers, and what it does not

**What the identity does and does not constrain.**
<a href="#eq-identity" class="quarto-xref">Equation 1</a> is an
algebraic decomposition of one regression term. Whether a given
implementation is thereby constrained depends on its nuisance structure:
free study-by-treatment or study-by-component effects can absorb the
study-constant term $\gamma(p_s - 0.5)$, and random treatment effects or
priors can change the pseudo-true value of a shared coefficient rather
than simply forcing the equality. This study fits fixed study effects
and no random treatment effects, and does not map its likelihood onto
the fixed- and random-effect specifications available in component
ML-NMR. The headline should be read as applying to the specification
simulated here.

Relatedly, the shared and IPD-anchored estimators differ in **two**
ways, not one: the interaction parameterization and the nuisance
intercept structure, since the IPD-anchored stage has a free intercept
per study-arm. Their contrast is therefore not a clean single-factor
comparison, and the joint split, which shares the shared model’s
intercept structure, is the cleaner one. Both are reported.

A further precision: the across-trial coefficient here is a
nonrandomized contextual association, but it is not confounded by any
variable modeled in this mechanism. “Confounded” describes what such a
coefficient is exposed to in practice, not something this simulation
instantiates.

**Scope.** This is a maximum-likelihood analogue of component ML-NMR.
Implemented ML-NMR is Bayesian, and priors matter most exactly where
interactions are weakly identified, so the coverage numbers here do not
transfer directly to `multinma`. What does transfer is
<a href="#eq-identity" class="quarto-xref">Equation 1</a>, which is a
property of the parameterization rather than of the estimation paradigm,
and therefore the direction of the effect. A Bayesian evaluation is a
separate study.

Also out of scope: continuous or multiple correlated modifiers,
misspecified or uncertain aggregate covariate distributions, component
synergy, random component-effect heterogeneity, inconsistency,
time-to-event outcomes, and links other than log. Study prevalences are
reported exactly, and under the $\rho$ patterns the split model is
correctly specified, so the study quantifies the cost of an
algebraically known restriction rather than establishing that real
networks contain within/across disagreement or how large it typically
is.

**What is established, and by what.** *Algebraically*, and independently
of the simulation: a shared interaction on a globally centered covariate
imposes $\gamma_W = \gamma_B$, so it is misspecified whenever the two
differ. *Empirically, in the primary regime*: the size of the resulting
coverage loss, its monotone dependence on discordance, its worsening in
bundled component networks, and the fact that both separated estimators
are nominal throughout. *Empirically, and answering a claim the catalog
makes*: the loss is present at full individual-data availability, so
aggregate data are not necessary for it, though they amplify it
substantially.

Accordingly this **answers CMP-13** for the maximum-likelihood analogue,
and refines rather than corrects its stated mechanism; and it **answers
a named part of IDN-06**, namely what happens when an interaction has no
within-trial support. It does not touch IDN-05.

**One prespecified rule fell narrowly short.** The mechanism claim was
registered with a refutation threshold of more than half the
full-individual-data cells exceeding 0.20 standardized bias. 48% do. We
report the claim as not supported and short of the registered refutation
threshold rather than adjusting the threshold to the result.

# Peer review

This manuscript was reviewed in two rounds by two independent reviewers.
Reports, the authors’ point-by-point responses and the editorial
decision are published in full at
`studies/CMP-13-within-between-interaction/review/peer-review.md`.

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

- **study**: CMP-13 / IDN-06 within versus across-trial component
  interaction
- **scenarios**: 320
- **replicates_per_scenario**: 2000
- **total_datasets**: 640000
- **master_seed**: 20260728

Replicate seeds derive from one master seed through L’Ecuyer-CMRG
streams, so a run gives identical results on any number of cores and an
interrupted run resumes. Code, protocol and results are at
<https://github.com/choxos/ITC-open-problems/tree/main/studies/CMP-13-within-between-interaction>.

``` bash
Rscript R/04-run.R        # 320 scenarios, resumable
Rscript R/05-analyze.R
Rscript R/06-figures.R
```

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-rucker2020" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Gerta Rücker, Maria Petropoulou,
Guido Schwarzer. Network meta-analysis of multicomponent interventions.
Biometrical Journal. 2020;62(3):808–21.
doi:[10.1002/bimj.201800167](https://doi.org/10.1002/bimj.201800167)</span>

</div>

<div id="ref-phillippo2020mlnmr" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Mark Belger, Alan Brnabic, Alexander Schacht, Daniel Saure,
Zbigniew Kadziola, Nicky J. Welton. Multilevel network meta-regression
for population-adjusted treatment comparisons. Journal of the Royal
Statistical Society Series A. 2020;183(3):1189–210.
doi:[10.1111/rssa.12579](https://doi.org/10.1111/rssa.12579)</span>

</div>

<div id="ref-phillippo2025" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Nicky J. Welton. Multilevel network meta-regression for general
likelihoods: Synthesis of individual and aggregate data with
applications to survival analysis. Journal of the Royal Statistical
Society Series A. 2025.
doi:[10.1093/jrsssa/qnaf169](https://doi.org/10.1093/jrsssa/qnaf169)</span>

</div>

<div id="ref-hua2017" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">Hairui Hua, Danielle L. Burke,
Michael J. Crowther, Joie Ensor, Catrin Tudur Smith, Richard D. Riley.
One-stage individual participant data meta-analysis models: Estimation
of treatment-covariate interactions must avoid ecological bias by
separating out within-trial and across-trial information. Statistics in
Medicine. 2017;36(5):772–89.
doi:[10.1002/sim.7171](https://doi.org/10.1002/sim.7171)</span>

</div>

<div id="ref-freeman2018" class="csl-entry">

<span class="csl-left-margin">5.
</span><span class="csl-right-inline">Suzanne C. Freeman, David Fisher,
Jayne F. Tierney, James R. Carpenter. A framework for identifying
treatment-covariate interactions in individual participant data network
meta-analysis. Research Synthesis Methods. 2018;9(3):393–406.
doi:[10.1002/jrsm.1300](https://doi.org/10.1002/jrsm.1300)</span>

</div>

<div id="ref-riley2020" class="csl-entry">

<span class="csl-left-margin">6.
</span><span class="csl-right-inline">Richard D. Riley, Thomas P. A.
Debray, David Fisher, Miriam Hattle, Nadine Marlin, Jeroen Hoogland,
François Gueyffier, Jan A. Staessen, Jiguang Wang, Karel G. M. Moons,
Johannes B. Reitsma, Joie Ensor. Individual participant data
meta-analysis to examine interactions between treatment effect and
participant-level covariates: Statistical recommendations for conduct
and planning. Statistics in Medicine. 2020;39(15):2115–37.
doi:[10.1002/sim.8516](https://doi.org/10.1002/sim.8516)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">7.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-stefanski2002" class="csl-entry">

<span class="csl-left-margin">8.
</span><span class="csl-right-inline">Leonard A. Stefanski, Dennis D.
Boos. The calculus of m-estimation. The American Statistician.
2002;56(1):29–38.
doi:[10.1198/000313002753631330](https://doi.org/10.1198/000313002753631330)</span>

</div>

</div>
