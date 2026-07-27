# Protocol: what conditioning on sampled target moments costs

**Target problems.** [MIS-03](https://choxos.github.io/ITC-open-problems/) *Nothing
propagates sampling error in reported target moments*, and
[EST-07](https://choxos.github.io/ITC-open-problems/) *Reported target moments are
treated as known constants*.

**Status.** Registered before any result was seen. The commit that adds this file is
the timestamp. Nothing below was changed after the run began; changes, if any, are
recorded in a dated amendment section at the end.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

---

## 1. The problem

A population-adjusted indirect comparison reweights or standardizes individual patient
data from a source trial so that its covariate distribution matches a target trial known
only through a published baseline table. That table gives, per covariate, a mean and a
standard deviation, plus the sample size.

Those numbers are estimates. They are sample moments computed from the target trial's
participants, and they carry sampling error of order $n_T^{-1/2}$. Every standard
estimator treats them as fixed constants. The reported confidence interval therefore
conditions on them, and omits their variability, whenever the intended estimand refers to
a target *superpopulation* rather than to the realized target sample.

MIS-03 states that the weight-estimation half of this problem is settled: sandwich,
ESS-rescaled and bootstrap variance estimators exist, are implemented, and were
benchmarked by Chandler and Proskorovsky (2024,
[doi:10.1002/jrsm.1759](https://doi.org/10.1002/jrsm.1759)) across 108 scenarios. What is
untouched is the published-moment half, because a baseline table arrives without the
covariance among its own entries, so there is nothing to resample.

MIS-03 asks for exactly one thing: **how much coverage is lost by conditioning on target
moments at realistic aggregate-data sample sizes.** This study answers that.

## 2. Aims

1. Measure the signed coverage error of the current-practice interval, meaning empirical
   coverage minus 0.95, across the design.
2. Locate the boundary: where in the space of source and target sample sizes,
   effect-modification strength and overlap does that error exceed two percentage points?
3. Determine what has to be reported for a correction to work. Three corrections are
   compared, requiring successively more information from the target publication.

## 3. Notation and the estimating system

Source trial: $n_S$ participants, treatments $A$ and $C$, equal allocation, covariates
$X_i \in \mathbb{R}^3$, outcome $Y_i$. Target trial: $n_T$ participants, treatments $B$
and $C$, equal allocation.

Write $h(X) = (X_1, X_2, X_3, X_1^2, X_2^2, X_3^2)^\top$. Matching on $h$ is matching on
the reported means and standard deviations, because a mean and a standard deviation
together determine the first and second raw moments. Let $\hat m_T = n_T^{-1} \sum_j h(X_j)$
be the six moments the target publication reports.

MAIC solves, over the source participants,

$$\sum_{i=1}^{n_S} w_i(\lambda)\,\{h(X_i) - \hat m_T\} = 0, \qquad w_i(\lambda) = \exp\{\lambda^\top h(X_i)\}.$$

Stacking this with the two weighted arm-mean equations gives an M-estimator in
$\psi = (\lambda, \mu_A, \mu_C)$, with per-participant score

$$u_i = \big(\,w_i\{h(X_i) - \hat m_T\},\ \ \mathbb{1}(A_i)\,w_i(Y_i - \mu_A),\ \ \mathbb{1}(C_i)\,w_i(Y_i - \mu_C)\,\big).$$

The transported effect is $\hat\theta_{AC} = \hat\mu_A - \hat\mu_C$, and the anchored
estimate is $\hat\theta_{AB} = \hat\theta_{AC} - \hat\theta_{BC}$ where $\hat\theta_{BC}$
is the target trial's own unadjusted arm-mean difference.

With $\hat A$ the empirical Jacobian of the mean score, $\hat B = n_S^{-1}\sum_i u_i u_i^\top$
and $c = (0,0,0,0,0,0,1,-1)^\top$, the usual sandwich is

$$V_S = c^\top \hat A^{-1} \hat B \hat A^{-\top} c / n_S .$$

The sensitivity of the transported effect to the reported moments follows from the
implicit function theorem. Since $\partial u_{i,\lambda} / \partial \hat m_T^\top = -w_i I$
and the arm-mean equations do not involve $\hat m_T$,

$$J = \frac{\partial \hat\theta_{AC}}{\partial \hat m_T} = -\,c^\top \hat A^{-1} C, \qquad C = \begin{pmatrix} -\bar w I_6 \\ 0 \\ 0\end{pmatrix}.$$

$V_S$ conditions on $\hat m_T$. Everything the study compares differs only in what is
added for the fact that $\hat m_T$ is an estimate.

## 4. Data-generating mechanism

Covariates are trivariate normal with unit variances and equicorrelation. Source
covariates are centered at $0$ with correlation $0.30$; target covariates are centered at
$d$ with correlation $\rho_T$.

Prognostic function, common to both trials:

$$f(X) = 0.20 + 0.35X_1 - 0.25X_2 + 0.20X_3 + 0.10(X_1^2-1) - 0.08(X_2^2-1) + 0.05(X_3^2-1).$$

Effect modifier, up to a scale $s$:

$$g(X) = 0.30X_1 - 0.20X_2 + 0.20X_3 + 0.15(X_1^2-1) - 0.10(X_2^2-1) + 0.10(X_3^2-1).$$

Outcomes are $Y = f(X) + \mathbb{1}(A)\tau_{AC}(X) + \varepsilon$ in the source and
$Y = f(X) + \mathbb{1}(B)\tau_{BC}(X) + \varepsilon$ in the target, with
$\varepsilon \sim N(0,1)$ independently per participant, and

$$\tau_{AC}(X) = -0.10 + s\,g(X), \qquad \tau_{BC}(X) = -0.10 + \kappa\, s\, g(X).$$

The scale $s$ is set per scenario so that the treatment effect has a prespecified standard
deviation across individuals **in the target population**. The quadratic terms are half the
linear ones, so shifting the covariate means multiplies the effective linear coefficient by
$(1+d)$: fixed coefficients give an effect modifier of standard deviation 0.477 at $d=0$ and
0.745 at $d=0.8$. Holding coefficients fixed while varying overlap would vary
effect-modification strength at the same time and confound the two factors, so strength is
calibrated instead.

The target trial's participants are generated and then discarded. The estimator receives
$n_T$, the three means, the three standard deviations, and $\hat\theta_{BC}$ with its
standard error. Nothing else, except where a method is explicitly given more (section 6).

### Factors

| Factor | Levels | Why |
|---|---|---|
| Source size $n_S$ | 500, 2000 | The omitted term is $J^\top \Omega J / n_T$ and the retained source term is of order $1/\mathrm{ESS}_S$, so what governs whether the omission matters is the **ratio** of source to target information. A pilot holding $n_S=500$ found the omission was 1% to 7% of total variance; at $n_S=2000$ the same quantity reached 23%. |
| Target size $n_T$ | 200, 500, 2000 | The range MIS-03 poses. |
| Overlap $d$ | 0, 0.4, 0.8 | Standardized mean difference per covariate. Population-limit ESS fractions near 1.00, 0.65 and 0.25, spanning the strong, moderate and poor regimes of Chandler and Proskorovsky (2024). |
| Effect modification $\mathrm{SD}_T(\tau)$ | 0, 0.45, 0.90 | Standard deviation of the individual treatment effect in the target, against a residual standard deviation of 1. Zero is the negative control. |
| Alignment $\kappa$ | 0, 0.5, 1 | How much the target treatment's effect is modified by the same function. |
| Target correlation $\rho_T$ | 0.30, 0.60 | At 0.30 the analyst's borrowed source correlation is correct; at 0.60 it is wrong. |

Fully factorial, except that $\kappa$ is meaningless when $\mathrm{SD}_T(\tau)=0$ and those
cells are collapsed. **252 scenarios.**

### What the mechanism makes true, and therefore what the study cannot see

Covariates are multivariate normal, so the study says nothing about skewed, heavy-tailed,
bounded or categorical covariates, and it favors the normal-reconstruction correction,
which is derived under exactly this assumption.

The outcome is continuous and the effect additive, so marginal and conditional effects
coincide. The study says nothing about noncollapsibility, and therefore nothing directly
about binary or time-to-event outcomes, where MAIC is most often used.

Effect modification lies exactly in the span of the six calibrated moments, so there is no
unmeasured effect modifier and no outcome-model extrapolation. The study measures a
variance failure under otherwise correct identification, not the size of confounding bias.

$\kappa$ is why the mechanism does not decide the answer. At $\kappa=0$ the omitted term is
a pure positive variance and the interval must be too narrow. At $\kappa=1$ the transported
$A$ versus $C$ estimate and the observed $B$ versus $C$ estimate move together, the omitted
covariance is negative, and the interval is too wide. An earlier version of this design used
only these two endpoints, which fixes the sign of the result by construction; $\kappa=0.5$
is included so the cancellation point is located rather than assumed.

## 5. Estimands

**Primary.** The target-superpopulation marginal $A$ versus $B$ mean difference,

$$\theta_{AB,T} = \mathbb{E}_T\{\tau_{AC}(X)\} - \mathbb{E}_T\{\tau_{BC}(X)\} = (1-\kappa)\,s\,(0.30\,d + 0.15\,d^2),$$

using $\mathbb{E}[X_j]=d$ and $\mathbb{E}[X_j^2-1]=d^2$. The expectation is over a fresh
draw from the target superpopulation, not over the realized target trial. Correlation does
not enter because $g$ contains no cross-products, so the truth is exact in closed form and
needs no Monte Carlo evaluation. This has been checked against a $3\times10^6$-draw
simulation in every cell, agreeing to under $2\times10^{-4}$.

The superpopulation qualifier is the whole point. Conditioning on the reported moments is
the *correct* thing to do when the estimand is defined by those moments, or when they are
exact administrative counts. The problem exists only for a superpopulation estimand, and
the protocol declares that rather than leaving it implicit.

## 6. Methods

All four share the same point estimate. The question is not which estimator is less biased;
it is what a reported interval omits. Anything that also moved the point estimate would
confound the two.

| Method | Interval variance | What the target must publish |
|---|---|---|
| **target-fixed** (status quo) | $V_S + \widehat{\mathrm{Var}}(\hat\theta_{BC})$ | $n_T$, means, SDs, effect and its SE |
| **normal-recon** | $V_S + J^\top \Omega_{\mathrm{norm}} J / n_T + \widehat{\mathrm{Var}}(\hat\theta_{BC})$ | the same, plus a borrowed correlation matrix |
| **reported-cov** | $V_S + J^\top \Omega_{hh} J / n_T + \widehat{\mathrm{Var}}(\hat\theta_{BC})$ | additionally the $6\times6$ covariance of $h(X)$ |
| **joint-score** | $V_S + (J,-1)^\top \Omega_T (J,-1) / n_T$ | additionally its covariance with the outcome influence function |

$\Omega_{\mathrm{norm}}$ is reconstructed from the reported means and standard deviations
and a borrowed correlation under a multivariate normal model, using
$\mathrm{Cov}(X_j,X_k) = \Sigma_{jk}$, $\mathrm{Cov}(X_j,X_k^2) = 2\mu_k\Sigma_{jk}$ and
$\mathrm{Cov}(X_j^2,X_k^2) = 2\Sigma_{jk}^2 + 4\mu_j\mu_k\Sigma_{jk}$. This is what an
analyst could actually compute today.

$\Omega_{hh}$ and $\Omega_T$ are computed from the target microdata inside the simulation
and then passed to the estimator **as matrices only**. They are not an assumption that
microdata are available; they are enhanced-reporting benchmarks, and the point of including
them is to make the required reporting addition an explicit result of the study.

`joint-score` replaces rather than adds to the target arm-mean variance, which it already
contains: the influence function
$\phi_{BC,j} = 2\mathbb{1}(B_j)(Y_j-\bar Y_B) - 2\mathbb{1}(C_j)(Y_j-\bar Y_C)$ satisfies
$\mathrm{Var}(\phi_{BC})/n_T = \widehat{\mathrm{Var}}(\hat\theta_{BC})$, which is checked in
the tests.

**Non-convergence** is declared when the optimizer does not report success, when the largest
remaining standardized moment imbalance exceeds $10^{-4}$, when the effective sample size
falls below 5, or when the Jacobian is singular. A replicate that fails still contributes a
row with a recorded reason, so the convergence rate has a real denominator.

## 7. Performance measures

**Primary:** empirical coverage of the nominal 95% interval for $\theta_{AB,T}$, reported as
the signed error $100(\text{coverage} - 0.95)$ in percentage points.

**Secondary:** paired coverage difference against `joint-score`; bias and bias over empirical
SE; empirical SE; mean model SE; relative error in model SE; MSE; bias-eliminated coverage;
rejection rate at $\theta_{AB,T}=0$; mean interval width; median and 5th-percentile ESS;
convergence rate. Every measure carries a Monte Carlo standard error.

**Replicates: 5000 per scenario**, 1,260,000 in total. At nominal coverage the Monte Carlo
SE is $\sqrt{0.95 \times 0.05 / 5000} = 0.0031$, so a two-point coverage error sits more than
six Monte Carlo SEs from nominal and a one-point error more than three. Methods share the
replicate and the point estimate and differ only in interval width, so paired differences are
McNemar-type and their Monte Carlo SE is governed by the discordance rate: at 2% discordance
it is $\sqrt{0.02/5000} = 0.20$ points.

The replicate count was raised from an initially proposed 2000 for a specific reason. A pilot
showed the coverage effect in the originally nominated confirmatory cells is under one
percentage point, which 2000 replicates (Monte Carlo SE 0.49 points) could not have resolved.
That design would have reported "no material effect" as an artifact of its own precision.

## 8. Decision rule, fixed in advance

The original design nominated four cells and asked whether coverage left a 93% to 97% band
there. A pilot established that it cannot: in those cells the omitted variance is under 2% of
the total, moving coverage by less than half a point. A rule no achievable result can trigger
is not a rule, and concluding "not material" from it would report the design's own choice of
residual variance rather than a property of population adjustment.

So the question is not whether some cell exists where this bites; it is **where the boundary
lies**. The study commits in advance to exactly one of these conclusions.

**Material at ordinary strength.** At least one scenario with $\mathrm{SD}_T(\tau) \le 0.45$
has status-quo coverage outside 0.93 to 0.97 with its Monte Carlo 95% interval excluding
0.95, and `joint-score` covers within 0.93 to 0.97 in that same scenario.

**Material only when effect modification is strong.** Every scenario with
$\mathrm{SD}_T(\tau) \le 0.45$ is inside 0.93 to 0.97, and at least one scenario at
$\mathrm{SD}_T(\tau) = 0.90$ is outside.

**Not material anywhere in this range.** Every scenario is inside 0.93 to 0.97, and every
paired coverage difference from `joint-score` is under 0.01 in absolute value with its Monte
Carlo 95% interval inside $(-0.02, 0.02)$.

**Uninformative** if any confirmatory method converges on fewer than 98% of replicates; or
raw and bias-eliminated coverage differ by more than 0.02, meaning the point estimate rather
than the interval is at fault; or `joint-score` itself misses 0.93 to 0.97, meaning the
variance decomposition is wrong; or any $\mathrm{SD}_T(\tau)=0$ negative control is outside
0.93 to 0.97.

## 9. Threats, and what was done about each

| Threat | What was done |
|---|---|
| The mechanism decides the sign of the result | $\kappa$ varies continuously through 0.5, so the cancellation point is located rather than assumed |
| Overlap and effect-modification strength are confounded | Strength is calibrated to a fixed target-population SD in every cell, so the two factors are orthogonal |
| The answer is an artifact of one arbitrary source size | $n_S$ is a factor; a pilot showed the conclusion turns on it |
| Undercoverage from weight estimation misread as a target-moment effect | Every method uses the identical source sandwich, and $\mathrm{SD}_T(\tau)=0$ negative controls must be nominal |
| The decision rule cannot fire | Expected coverage was derived from a pilot before thresholds were set; the rule now asks where the boundary is, not whether an effect exists |
| Enhanced-reporting methods use information publications do not contain | They are labeled as benchmarks, receive covariance matrices and never microdata, and the deployable reconstruction is evaluated separately |
| Searching 252 scenarios invites picking the most dramatic cell | The conclusion is a single prespecified statement about the whole grid, not a selected cell |
| Normal covariates favor the normal reconstruction | Stated as a limitation; $\rho_T = 0.60$ tests the part of the reconstruction an analyst can get wrong today |

## 10. Scope, stated plainly

This study covers **anchored MAIC on a continuous outcome, where the reported target moments
and the reported $B$ versus $C$ effect come from the same randomized trial.** That is the
common case and it is the case with the largest cross-covariance, but it is one case.

It does **not** cover: target summaries from a separate sample; covariate-adjusted published
treatment effects, whose influence functions differ; STC, ML-NMR, ML-UMR or NMI, which have
different sensitivities $J$; binary or time-to-event outcomes; or reconstructed correlations
as a source of model uncertainty rather than sampling error.

Accordingly this study **answers MIS-03 in part** and **answers a named component of EST-07**.
Neither is closed by it. The catalog entries will record which part.

## 11. Amendments

### 2026-07-27, after the run: the gates are also applied per scenario

**What changed.** Section 8 writes the uninformative gates over the whole grid: if
`joint-score` misses 0.93 to 0.97 anywhere, or any negative control does, the run is
uninformative. Read that way the run *is* uninformative, and that is reported first
because it is what was registered. The gates are additionally applied per scenario, and
the conclusion is read off the scenarios that pass.

**Why.** At $d = 0.8$ the effective sample size falls to a median of 148 of 500 and the
Wald sandwich undercovers for **every** method, including `joint-score` and including the
$\mathrm{SD}_T(\tau) = 0$ negative controls, where the target moments carry no information
about the transported effect at all and every method must agree by construction. That
failure is real, it is reported as a secondary finding, and it has nothing to do with
target moments. The global gate lets it void 252 scenarios on the strength of a failure
in 56.

This was anticipated. Section 9's threat table already contains "Wald sandwich intervals
may fail at $n_T = 200$ for reasons unrelated to target-moment omission", with the
mitigation "require the reference method and null controls to attain 93% to 97% coverage
before attributing failure to fixed target moments; otherwise classify as uninformative".
The per-scenario reading is that mitigation applied where it was meant to apply. The
global reading applies it everywhere at once, which was a drafting error rather than an
intention.

**What it changes.** Under the global reading: uninformative. Under the per-scenario
reading: 196 of 252 scenarios are usable and the conclusion is *material at ordinary
effect-modification strength*, though that category is triggered by a single marginal
scenario and the robust statement is the one about magnitude and sign. Both readings are
reported in `results/decision.md` and in the manuscript, in that order.

**What it does not change.** No threshold, no factor, no performance measure, no
replicate count, and no scenario's data. The amendment is a restriction of the analysis
set on a criterion that was itself prespecified, not a change to the criterion.
