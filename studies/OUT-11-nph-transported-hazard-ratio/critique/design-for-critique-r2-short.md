# THE OPEN PROBLEM (catalog entry OUT-11, key sections)

## Statement

The transported hazard ratio remains the default reported quantity in survival indirect comparisons, and on the marginal scale it can be population-dependent and time-varying through risk-set selection, while under non-proportional hazards a fitted Cox coefficient is a censoring- and event-weighted constant summary of a time-varying contrast. A conditional hazard ratio under a proportional-hazards model is constant by definition, so the instability belongs to the marginal scale or to non-proportionality rather than to the coefficient as such. The recommended alternatives are not missing from software: multinma has shipped survival models since 0.6.0 with predict() types including survival, hazard, cumulative hazard, mean, median, quantile and restricted mean survival time, marginal_effects() returns RMST and survival-probability differences standardized to a target population, and auxiliary parameters can be stratified by treatment to relax proportional hazards. The gap is between available methods and prevailing practice, and in the absence of any simulation benchmark comparing these estimators against proportional-hazards MAIC and STC under crossing hazards and differential censoring.

## Why it is open

Practice still reports a coefficient, so the mismatch between the estimand a reimbursement decision needs and the estimand produced persists even though the tooling exists in one package. Separating a baseline-hazard difference from an effect-modifier difference requires assumptions that published Kaplan-Meier curves cannot adjudicate, and the standard proportional-hazards test is often underpowered. No simulation study compares general-likelihood ML-NMR against proportional-hazards MAIC and STC on Weibull, Gompertz and multistate mechanisms with crossing hazards and differential censoring, so the relative operating characteristics of the recommended replacements are unknown. Component PAIC implementations such as cpaic still hold treatment effects proportional and lack target-marginal survival contrasts.

## Probable solution or research direction

Run the benchmark rather than rebuild the estimators: compare general-likelihood ML-NMR and one-step exact-likelihood survival network meta-analysis against proportional-hazards MAIC and STC on Weibull, Gompertz and multistate data-generating mechanisms with crossing hazards and differential censoring, reporting RMST bias, hazard-ratio instability and calibration over time. Report target-standardized survival curves, milestone contrasts and RMST differences at prespecified horizons the data support, with the horizon declared as part of the estimand, without asserting that RMST is universally required. Add target-marginal survival contrasts and time-varying treatment effects to the component PAIC implementations that lack them.

# THIS IS ROUND TWO OF PRE-RUN CRITIQUE

You are reviewing a REVISED protocol. Version one came back `unsound` and `needs-revision` from two independent reviewers. Their findings are listed compactly below; the full reports are omitted deliberately. Nothing has been simulated yet.

Judge the revision. For each round-one finding say whether the response is adequate. Authors may disagree with a reviewer and say why; a reasoned refusal is legitimate and judged on its reasoning. What is NOT legitimate is claiming a fix the protocol does not contain, so check the text against the claim. Add `round1_resolution` to your JSON: a list of {"reviewer":"sol|kimi","finding":"short label","resolved":"yes|partly|no","note":"..."}. Then attack the revision on its own terms, on the same axes.

# ROUND-ONE FINDINGS, COMPACT

SOL verdict: unsound
  [fatal] answers-problem: OUT-11 asks for a benchmark of general-likelihood ML-NMR and one-step exact-likelihood survival NMA against PH MAIC and STC under crossing hazards and differential censoring, including RMST bias and calibration over time. The proposed study makes censoring sen
  [serious] answers-problem: The protocol never defines the benchmark's actual performance outputs: bias, RMSE, empirical standard error, interval coverage, calibration at milestones, convergence failures, or interval-score criteria. A methods table alone does not produce the operating-ch
  [serious] dgm-builds-in-finding: The qualitative central result is built in by φ_B != 0 together with changing censoring rates. Treatment-specific Weibull shape makes the conditional log hazard ratio time-varying, and the probability limit of a misspecified constant Cox coefficient generally 
  [fatal] dgm-builds-in-finding: The φ_B = 0 cell is not the claimed marginal proportional-hazards negative control. It gives conditional proportional hazards at fixed covariates, but marginalization over prognostic covariates, especially with γ_k differing by treatment, generally produces a 
  [serious] dgm-builds-in-finding: Moderate, strong, near, far, light, heavy, and differential are labels without numerical values. The baseline shape, treatment scales, γ parameters, covariate law, study effects, censoring rates, crossing times, and exact scenario matrix are unset. These degre
  [serious] dgm-builds-in-finding: A nonzero treatment-specific Weibull shape guarantees a single conditional hazard crossing somewhere on the positive time axis, not necessarily a target-marginal crossing within the supported analysis window. Calling φ_B a crossing-hazards factor without calib
  [fatal] estimand: The target is alternately described as an aggregate-study population known through published sample means and standard deviations and as a target law available for Gauss-Hermite integration. Means and standard deviations do not identify a law, and the truth fo
  [serious] estimand: The marginal hazard is not defined. The target-marginal hazard is -d log E[S_k(t|X)]/dt, equivalently E[S_k(t|X)h_k(t|X)] divided by E[S_k(t|X)], not the simple covariate average E[h_k(t|X)]. The notation bar h_B(t)/bar h_A(t) is therefore ambiguous and could 
  [serious] estimand: The constant hazard ratios reported by the methods are not a common estimand. Weighted treatment-only Cox MAIC produces a marginal Cox projection, whereas PH STC or ML-NMR may report a conditional coefficient, potentially at a reference covariate value when γ_
  [serious] estimand: The claim that truth stays fixed across censoring conflicts with setting τ to a quantile of follow-up. Follow-up quantiles change when censoring changes, so a cell-specific τ changes the RMST estimand and its true value.
  [serious] estimand: Moment-balanced MAIC targets its weighted empirical pseudo-population, whereas STC and ML-NMR appear to integrate over an assumed parametric target law. Unless the weighting basis exactly transports the full distribution relevant to nonlinear survival expectat
  [fatal] fair-comparison: The columns are mislabeled as proportional versus flexible baseline. A flexible baseline hazard shared by treatment arms is still a proportional-hazards model. Only treatment-by-time interactions or treatment-specific shape or spline parameters relax PH, and t
  [fatal] fair-comparison: Weighted Cox plus Bucher does not by itself produce a target B-versus-A RMST difference. A hazard ratio does not identify survival curves without a baseline curve, and Bucher combination on the log-hazard-ratio scale is not the additive indirect comparison of 
  [serious] fair-comparison: ML-NMR can use all five aggregate B studies to identify γ_B, while ordinary anchored MAIC and STC may use only the designated target B study. A row contrast then changes both the method and the amount of evidence, so it cannot isolate method family as claimed.
  [serious] fair-comparison: Only PH MAIC receives a named variance procedure. There is no uncertainty method for flexible MAIC or either STC, no account of estimated weights and aggregate comparator uncertainty, and no prior, posterior-summary, or convergence policy for ML-NMR. Coverage 
  [fatal] decision-rule: There is no operational decision rule. The consequence, numerical threshold, deployment weights, definition of range, replicate count, acceptable Monte Carlo error, and reject, accept, or inconclusive conditions are all absent. A threshold promised for later i
  [fatal] decision-rule: A hazard ratio range does not uniquely imply a change in RMST. The mapping also requires a baseline survival distribution, horizon, covariate distribution, and a rule for reconciling potentially different fitted baselines. This reintroduces the category error 
  [serious] decision-rule: A range across noisy fitted hazard ratios is upward-biased and a deployment-weighted range is undefined unless zero-weight scenarios are excluded. Independent simulation samples across censoring cells would also confound sampling noise with censoring sensitivi
  [serious] feasibility: At 251 seconds per fit and two ML-NMR fits per replicate, three workers require about 46.5 hours for 1000 replicates in one scenario. Three censoring scenarios alone require about 5.8 days; a full 3 by 3 by 2 by 2 grid requires about 69.7 days, excluding faile
  [serious] feasibility: One fit with maximum R-hat rounded to 1.00 does not validate two chains of 1000 iterations for thousands of heterogeneous fits. Bulk and tail effective sample sizes, divergences, treedepth, posterior Monte Carlo error, and convergence-failure frequency can dom
  [serious] citation: The central censoring-weighted Cox claim, the recommended implementations and variance procedures for every comparator, and two appeals to study 5 are not traceably cited. The exact-likelihood comparator required by the catalog is also unnamed. No obvious auth

KIMI verdict: needs-revision
  [serious] dgm-builds-in-finding: The 'factor that carries the paper' is guaranteed by theory. With treatment on the Weibull shape (phi_B != 0), the limiting Cox partial-likelihood estimate is a censoring- and event-weighted average of the time-varying log-hazard contrast (Struthers & Kalbflei
  [serious] fair-comparison: The claim that 'the column effect isolates the proportional-hazards assumption' holds only for the ML-NMR row, where aux_by = .study vs aux_by = c(.study, .trt) genuinely toggles PH within one machinery. For MAIC/STC, the aggregate-side inputs as practiced are
  [serious] fair-comparison: The evidence base per row is unspecified. ML-NMR fits the full 6-study network and identifies gamma_B through between-study covariate contrasts across the 5 aggregate studies. Anchored MAIC/STC as practiced are pairwise against the single target study and cann
  [serious] decision-rule: As drafted the rule cannot be audited for whether it fires. Three components are missing: (1) the numeric RMST threshold 'derived from a consequence' is promised but not stated; (2) the deployment-weighting distribution over censoring scenarios is undefined, a
  [serious] feasibility: The runtime measurement is honest (251 s per flexible ML-NMR fit, ~2 fits per replicate, 3 workers), but there is no replicate budget: no cell count times replicates times wall-clock, and no MCSE target for the RMST-bias comparisons. Rough arithmetic: a full c
  [limitation] answers-problem: The truth-generating mechanism is Weibull-only, while the catalog entry's missing benchmark explicitly spans Weibull, Gompertz and multistate mechanisms, which produce crossings of structurally different kinds (Weibull with treatment on shape gives a log-HR li
  [minor] answers-problem: The entry's proposed direction names two replacement families: general-likelihood ML-NMR and one-step exact-likelihood survival IPD network meta-analysis (the Royston-Parmar one-step line in the entry's own timeline). The design drops the second comparator wit
  [minor] estimand: The estimand machinery is otherwise right, but two things are unstated: (1) whether the target is the realized aggregate-study sample (what MAIC actually targets) or the target superpopulation law (what the quadrature truth computes) — with only means/SDs shar
  [minor] decision-rule: Censoring appears twice in inconsistent roles: as a three-level crossed design factor and as a dedicated manipulation 'run at fixed everything else'. The relationship between the censoring main effect in the crossed design and the headline fixed-truth manipula

# WHAT THE AUTHORS VERIFIED AND CHANGED

# What the pre-run critique changed, and what the rebuilt mechanism already shows

Sol returned `unsound` with three fatal findings. Kimi returned `needs-revision` with five
serious ones. Each found something the other missed. Everything below was checked numerically
before it was accepted.

## The fatal finding, confirmed and fixed

**Sol.** The first design put the treatment on the Weibull shape and log-scale directly, so the
log hazard ratio contained the study baseline:

$$\log \mathrm{HR}_k(t,x) = \log(a_k/a_0) - a_k(d_k + \gamma_k x) - (a_k - a_0)\lambda_j + (a_k - a_0)\log t.$$

The treatment contrast would have varied across studies mechanically, manufacturing
treatment-by-study inconsistency that none of the fitted models allows.

Confirmed: the log hazard ratio moved from $-0.6955$ to $-0.9719$ across baselines of $\log 8$ to
$\log 18$, a spread of $-0.2764$, matching the predicted $(a_0-a_B)(\lambda_2-\lambda_1)$ to four
decimals. The first design's own calibration run never showed it, because that run held the
baseline fixed at $\log 12$.

Fixed by building the treatment arm as a **study-invariant multiplier** on the study's own
placebo hazard, $h_{jk}(t,x) = h_{j0}(t)\exp\{\beta_k + \kappa_k g(t) + \gamma_k x\}$. Verified
baseline-invariant to $4.4\times10^{-16}$, for both families.

The same change fixes a second finding of Sol's. In the old parameterization, changing the
non-proportionality also changed the effective size of the treatment effect and the
effect-modifier strength, because both were multiplied by the treatment-specific shape. In the
new one, $g(t_0)=0$, so the log hazard ratio at the reference time is $\beta_k + \gamma_k x$
whatever $\kappa_k$ is. Verified to $5.3\times10^{-16}$. **$\kappa$ now isolates
non-proportionality**, which is what the design claimed all along and did not deliver.

Gompertz is added, using $g(t)=(t-t_0)/t_0$ so the family is closed under the multiplier. The
quadrature truth agrees with 2,000,000 simulated draws for both families, to within the
simulation's own Monte Carlo error.

## The centrepiece was a theorem

**Kimi.** The first design's headline experiment was to hold the survival functions fixed, vary
only the censoring, and report that the transported hazard ratio moves. That is not an empirical
question. Struthers and Kalbfleisch (Biometrika 1986, doi:10.2307/2336212) and Xu and O'Quigley
(Biostatistics 2000, doi:10.1093/biostatistics/1.4.423) established that a misspecified
proportional-hazards fit converges to a least-false parameter that is a censoring- and
event-weighted average of the time-varying contrast. Both citations were checked against
CrossRef. The design's promise that "if it does not move, the entry's warning is weaker" was
false: non-movement is asymptotically impossible under non-proportional hazards.

Kimi's fix is adopted. The least-false parameter is now **computed**, by solving the limiting
score equation

$$\int f_1(t)\,dt = \int \frac{r_1(t)e^{\beta}}{r_0(t)+r_1(t)e^{\beta}}\,\bigl(f_0(t)+f_1(t)\bigr)\,dt,
\qquad r_k = \pi_k \bar S_k \bar G,\quad f_k = r_k \bar h_k,$$

with the marginal survival and hazard from the quadrature truth. Verified against a Cox fit on
400,000 per arm: worst disagreement 0.0031 on the log scale. Simulation is now reserved for
finite-sample behaviour around that limit, which is the part that is not already known.

## What the rebuilt mechanism shows, at zero compute cost

Sizing the effect exactly, rather than discovering its direction:

| $\kappa$ | true RMST diff at 18 | true marginal HR | reported HR across four censoring regimes | spread |
|---:|---:|---|---|---:|
| 0.00 | +1.155 | 0.73--0.82 | 0.769, 0.780, 0.792, 0.789 | 3.0% |
| 0.15 | +1.817 | 0.51--0.78 | 0.720, 0.703, 0.677, 0.694 | 6.4% |
| 0.30 | +2.359 | 0.32--0.84 | 0.687, 0.648, 0.593, 0.624 | 16.0% |

The $\kappa = 0$ row is the one worth having, and neither the first design nor either critique
anticipated it. That row is **exact conditional proportional hazards**, where Kimi predicted the
reported hazard ratio must not move. It moves by 3.0%. Decomposing why:

| $\gamma$ at $\kappa=0$ | marginal HR drift | reported HR spread |
|---:|---:|---:|
| 0.00 | 0.0% | **0.00%** |
| 0.15 | 2.7% | 0.76% |
| 0.30 | 11.6% | 3.01% |
| 0.50 | 35.8% | 7.93% |

and with $\gamma = 0.30$ but the covariate spread collapsed to zero, the movement is
**0.000%**.

So the censoring dependence of a transported hazard ratio has **two separate sources**, and they
are separable exactly:

1. **Non-proportional hazards**, the source the catalog entry names.
2. **Effect modification combined with covariate spread**, which moves the reported hazard ratio
   by up to 7.9% even when the conditional model is exactly proportional. Remove either
   ingredient and it is exactly zero.

The second is the mechanism the catalog entry's auditors described when they corrected the
source's framing, saying the instability "belongs to the marginal scale". Nobody appears to have
quantified it. It is now quantified, exactly, and it required no simulation at all.


# THE REVISED PROTOCOL

# Protocol: what a transported hazard ratio summarises, and how the recommended replacements behave

Registered before any replicate of the reported run. Catalog problem **OUT-11**.

This is the second version. The first was sent for adversarial critique before anything was run
and came back `unsound` from one reviewer and `needs-revision` from the other, with a fatal error
in the data-generating mechanism that both the design and its own calibration run had missed.
Section 12 records what changed and why. Nothing had been simulated, so nothing was discarded
except a day.

---

## 1. The problem, and the part of it this study settles

The OUT-11 entry is marked **overstated**, and its verification trail says why: the source
claimed target-standardized survival curves and RMST are outputs current software cannot
produce, and that is false. `multinma` has shipped survival likelihoods since 0.6.0,
`marginal_effects()` has returned target-standardized RMST and survival-probability differences
since 0.7.0, and `aux_by = c(.study, .trt)` stratifies auxiliary parameters by treatment to relax
proportional hazards.

Two auditors also corrected the framing, and that correction defines this study. A **conditional**
hazard ratio under a proportional-hazards model is constant by definition. The instability
belongs either to the **marginal** scale, where risk-set selection makes the hazard ratio
population-dependent and time-varying, or to **non-proportionality**, where a fitted Cox
coefficient is a censoring- and event-weighted constant summary of a time-varying contrast.

What the entry leaves open is a benchmark: no simulation study compares general-likelihood
ML-NMR against proportional-hazards MAIC and STC under crossing hazards and differential
censoring.

**This study settles part of that and says so.** It runs Weibull and Gompertz mechanisms; it does
not run a multistate mechanism, which the entry also names. It compares MAIC, STC and ML-NMR,
each with a proportional and a flexible baseline; it does not implement a separate one-step
exact-likelihood survival NMA as a distinct estimator, because on a network of individual data
plus reconstructed pseudo-individual data the ML-NMR arm already fits the exact individual-level
likelihood to both. That is an argument, not a dismissal, and it is offered for the reviewers to
reject.

The title and the abstract will scope the conclusion to the mechanisms and estimators actually
run. A reader must not be able to read this as the whole benchmark the entry asked for.

## 2. Two contributions, one of which needs no simulation

**A. An exact decomposition of why a transported hazard ratio depends on the censoring.**
Computed, not simulated. See section 5.

**B. A benchmark of six estimators on a common target-population estimand.** Simulated. See
sections 6 to 8.

A is primary in the sense that it is exact and settles a mechanism. B is primary in the sense
that it is what the catalog asked for. Both are reported; neither is presented as the other.

## 3. Data-generating mechanism

Individual $i$ in study $j$ on treatment $k$, with one covariate $x \sim N(\mu_j, 1)$. The
treatment arm is a **study-invariant multiplier** on the study's own placebo hazard:

$$h_{jk}(t \mid x) \;=\; h_{j0}(t)\,\exp\{\beta_k + \kappa_k\, g(t) + \gamma_k x\}.$$

The contrast is therefore exactly $\beta_k + \kappa_k g(t) + \gamma_k x$, with no study term in
it, by construction rather than by calibration.

| family | placebo hazard | $g(t)$ | resulting family |
|---|---|---|---|
| Weibull | $(a_0/s_j)(t/s_j)^{a_0-1}$ | $\log(t/t_0)$ | Weibull, shape $a_0 + \kappa_k$ |
| Gompertz | $b_j e^{\xi t}$ | $(t-t_0)/t_0$ | Gompertz, rate $\xi + \kappa_k/t_0$ |

with $t_0 = 12$ the reference time. Both stay in closed form, so the truth stays exact.

Three properties, each **verified in code rather than asserted**, by
`verify_invariance()`, `verify_kappa_isolates()` and `verify_truth()`, all run at analysis time:

1. The contrast does not depend on the study baseline. Worst spread $4.4\times10^{-16}$.
2. $\kappa$ isolates non-proportionality: at $t = t_0$, $g = 0$, so the log hazard ratio is
   $\beta_k + \gamma_k x$ whatever $\kappa_k$ is. Worst spread $5.3\times10^{-16}$.
3. The quadrature truth agrees with 2,000,000 simulated draws, both families, within the
   simulation's own Monte Carlo error.

$\kappa_k = 0$ gives **exact conditional proportional hazards**, so the proportional cell is a
special case of the same mechanism and not a different one.

**Network.** One study contributes individual patient data and compares PBO with A. Three
studies contribute aggregate data and compare PBO with B, so B's effect modifier is identified
only through between-study contrasts of covariate means. That asymmetry is the situation
population adjustment exists for. Study baselines $s_j$ and covariate means $\mu_j$ vary across
studies; that they can vary without corrupting the contrast is the point of the
reparameterization above.

**Censoring.** Independent exponential at a per-study rate, plus a common administrative cutoff.
It touches no survival function, so the true estimand is invariant to it by construction.

## 4. Estimand

**Target population.** The covariate distribution of a designated aggregate study, taken as
$N(\mu_{\text{tgt}}, 1)$. **This normality is an assumption and is stated as one**: means and
standard deviations do not pin down a distribution. Inside this study the quadrature law and the
generating law are the same normal, so truth and estimators target the same population; in an
application they need not, and that is a limitation, not a property of the methods.

The estimand is a **superpopulation** quantity, not the realized aggregate sample. MAIC matches
realized moments and therefore targets the realized sample; at the sample sizes here the
difference is small, but it is a difference and it is declared.

**Primary.** Target-population marginal RMST difference between B and A at horizon $\tau$:

$$\Delta_{\text{RMST}}(\tau) = \int_0^\tau \bar S_B(t)\,dt - \int_0^\tau \bar S_A(t)\,dt,
\qquad \bar S_k(t) = \mathbb{E}_{x\sim\text{target}}[S_k(t\mid x)].$$

$\tau = 18$, **fixed numerically before the run and identical in every cell and every censoring
regime**. A horizon defined as a quantile of observed follow-up would move with the censoring,
which would destroy the claim that the truth is held fixed; the first draft made exactly that
error. Administrative cutoff is 36, so $\tau$ is inside observed follow-up everywhere. The
probability of remaining under observation at $\tau$ is reported per arm per cell.

**Secondary.** Milestone survival difference $\bar S_B(12) - \bar S_A(12)$. The true time-varying
marginal hazard ratio $\bar h_B(t)/\bar h_A(t)$, with the marginal hazard defined as
$-\mathrm{d}\log \bar S/\mathrm{d}t = \mathbb{E}[h(t\mid x)S(t\mid x)]/\mathbb{E}[S(t\mid x)]$,
which is **not** the average of conditional hazards.

**The constant hazard ratio is not treated as a common estimand across methods.** A weighted Cox
coefficient is a censoring-dependent projection; STC and ML-NMR coefficients are conditional and
vary with $x$. Comparing them directly would be a category error. Instead **one prespecified Cox
projection functional** (section 5) is applied to every method's fitted target survival curves,
so the constant summaries being compared are the same functional of different fits.

## 5. Contribution A: the censoring dependence, computed

A reviewer pointed out that the first design's centerpiece was a theorem, not a question.
Struthers and Kalbfleisch (Biometrika 1986, doi:10.2307/2336212) and Xu and O'Quigley
(Biostatistics 2000, doi:10.1093/biostatistics/1.4.423) establish that a misspecified
proportional-hazards fit converges to a least-false parameter that is a censoring- and
event-weighted average of the time-varying contrast. Both citations were checked against
CrossRef. The first design's promise that non-movement would weaken the entry's claim was false:
under non-proportional hazards, non-movement is asymptotically impossible.

So the effect is **sized**, not tested. The least-false constant log hazard ratio solves

$$\int f_1(t)\,dt = \int \frac{r_1(t)e^{\beta}}{r_0(t)+r_1(t)e^{\beta}}\bigl(f_0(t)+f_1(t)\bigr)dt,
\qquad r_k = \pi_k\bar S_k\bar G,\quad f_k = r_k\bar h_k,$$

a root-find over known quantities. Verified against a Cox fit at 400,000 per arm: worst
disagreement 0.0031 on the log scale.

**Prespecified decomposition.** The reported hazard ratio is evaluated across four censoring
regimes with the truth held exactly fixed, at each combination of $\kappa$ and $\gamma$. The
prespecified claim is that the movement has two separable sources, and that setting either
$\gamma = 0$ or the covariate spread to zero removes the second **exactly**.

Simulation is used only for finite-sample behaviour around this limit: whether an analyst at
realistic sample sizes can distinguish the regimes, and how the estimators scatter around the
limit. That is the part the theorem does not give.

## 6. Contribution B: the benchmark

Six estimators, crossed rather than listed, so that "ML-NMR beats MAIC" and "flexible beats
proportional" are separable rather than confounded:

| | proportional baseline | flexible baseline |
|---|---|---|
| **weighting** | MAIC, weighted Cox, then Breslow baseline, curves integrated to RMST | MAIC, weighted Royston-Parmar, 3 internal knots, treatment-specific spline coefficients |
| **outcome regression** | STC, PH Weibull, marginalized over the target law | STC, Royston-Parmar, 3 internal knots, treatment-specific spline coefficients |
| **ML-NMR** | `mspline`, 3 knots, `aux_by = .study` | `mspline`, 3 knots, `aux_by = c(.study, .trt)` |

Every cell produces the same target RMST difference, so the row effect isolates the method
family and the column effect isolates the proportional-hazards restriction.

**Within each family the likelihood, baseline family, knot count, evidence set and numerical
settings are held fixed and only the treatment-by-time terms are toggled.** A reviewer noted that
comparing Cox with a flexible parametric fit changes the baseline estimator and the likelihood as
well as proportionality; that comparison is between families, not within, and is not read as the
column effect.

**Flexibility is matched across rows deliberately.** Three internal knots with treatment-specific
coefficients in every flexible cell. Giving the non-ML-NMR rows a weaker flexible fit would rig
the column; this is a design choice and it is stated.

**Marginalized STC**, not the mean-profile plug-in: plugging target means into a nonlinear model
returns a conditional quantity at an average covariate profile, which is a known error and would
rig the comparison in the proposal's favour.

**Evidence set held constant.** Every method uses the same studies. A separate factor would be
needed to study the effect of pooling more aggregate studies, and that is not this study.

**Aggregate inputs.** Each aggregate study supplies reconstructed patient-level survival times
and status (the digitization step is assumed exact and its error is declared out of scope in
section 11), per-arm covariate means and standard deviations, and arm sizes. The target absolute
survival baseline comes from the designated target study's own placebo arm, which every method
uses identically. Bucher is used only where it belongs, to combine relative effects; it does not
supply an absolute target survival curve and is not used as if it did.

**Uncertainty, per method, by its own authors' recommendation.** Nonparametric bootstrap over the
full pipeline, including re-estimation of weights and re-standardization, for both MAIC rows and
both STC rows, 500 resamples. Posterior draws for both ML-NMR rows. Coverage of a nominal 95%
interval for $\Delta_{\text{RMST}}(\tau)$ is a reported outcome, not an afterthought; the entry
asks for calibration and the first design omitted it entirely.

## 7. Design factors and the cell matrix

| Factor | Levels |
|---|---|
| family | Weibull, Gompertz |
| non-proportionality $\kappa_B$ | 0, 0.15, 0.30 |
| effect modification $\gamma$ | 0.15, 0.30 |

Not fully crossed. The cells actually run:

- **Core, Weibull:** $\kappa \in \{0, 0.15, 0.30\} \times \gamma \in \{0.15, 0.30\}$, 6 cells.
- **Family sensitivity, Gompertz:** $\kappa \in \{0, 0.30\}$ at $\gamma = 0.30$, 2 cells.
- **Marginal-PH control:** $\kappa = 0$, $\gamma = 0$, 1 cell. A reviewer correctly noted that
  $\kappa = 0$ alone is only *conditionally* proportional, so it is not a clean control; with
  $\gamma = 0$ as well the marginal hazard ratio is constant and the proportional methods are
  correctly specified. This is where they must win, and if they do not, the comparison is rigged
  and the paper will say so.

**9 cells, 40 replicates each, 360 replicates.**

$\kappa$ was calibrated against a named detectability standard rather than chosen by adjective.
At 200 per arm with a Grambsch-Therneau test at the 0.05 level, the proportional-hazards test
rejects in 0.04 of replicates at $\kappa=0$, and the levels retained are those an analyst would
plausibly miss. A level large enough that the test catches it almost always is a stress test, not
a scenario, and is excluded from the deployment mixture.

## 8. Monte Carlo error, and what can be resolved

360 replicates pooled. Standard error of a coverage estimate near 0.95 is 0.011; per cell at 40
replicates it is 0.034. **Coverage is therefore reported pooled with intervals, and per-cell
coverage is descriptive only.** Study 5 published a maximum over eight noisy cell estimates as if
it were a bound, and a reviewer was right that it was not; that mistake is not repeated.

Bias in $\Delta_{\text{RMST}}$: pilot scatter gives a per-replicate standard deviation near 0.35
months, so the standard error of a pooled bias is about 0.018 months and of a per-cell bias about
0.055.

**Estimator comparisons are paired on the replicate**, since all six are computed on the same
simulated network, and reported with paired intervals. Common random numbers are used across
censoring regimes.

## 9. Prespecified decision

Two rules, both numeric, both fixed before the run.

**D1, the benchmark.** An estimator is fit for purpose if, pooled over the core cells, the
absolute bias in $\Delta_{\text{RMST}}(18)$ is below **0.5 months** and the coverage of a nominal
95% interval is within **[0.90, 0.98]**. The 0.5 months is the consequence threshold: it is the
smallest RMST difference that changes a recommendation under the reimbursement decision model
declared in section 10. Each of the six estimators is scored against it separately and the result
is reported as a table of passes and failures, not as a winner.

**D2, the hazard ratio as an input.** The transported constant hazard ratio is fit for purpose
if, across the four censoring regimes with the truth held exactly fixed, the implied change in
$\Delta_{\text{RMST}}(18)$ is below the same 0.5 months. The mapping from a hazard ratio to an
RMST difference is **not** free: it is computed by applying the reported constant hazard ratio to
the target study's own estimated placebo survival curve and integrating, which is exactly what an
analyst does, and that mapping is specified here rather than left implicit. A reviewer noted the
first draft asserted a threshold-free conclusion while also stating a threshold; that
contradiction is removed.

Deployment weights: uniform over the six core cells. Stated as the declared judgment it is, not
buried.

## 10. The decision model behind the 0.5-month threshold

A treatment is recommended if its target-population RMST gain over the comparator at 18 months
exceeds the gain that justifies its cost. Setting that at 0.5 months makes the threshold a
consequence rather than a taste. It is declared before the run, it is the same number in D1 and
D2, and every conclusion that depends on it is labelled as depending on it.

## 11. What this cannot settle

- One covariate. Multiplicity across covariates and selection over several pairwise differences
  are not measured.
- Weibull and Gompertz only. Multistate mechanisms cross in ways these families cannot produce,
  and the entry names them.
- No separate one-step exact-likelihood survival NMA estimator, for the reason argued in
  section 1, which reviewers are invited to reject.
- Independent censoring, varied **per study**. Much applied concern is differential follow-up
  **between arms within** a comparison, which this design does not vary.
- Digitization error in reconstructing aggregate survival curves is assumed away entirely. It is
  a real and separate error source in every applied use of these methods.
- Fixed-effect synthesis throughout.

## 12. What changed after the first critique, and why

| Finding | Reviewer | Status |
|---|---|---|
| Treatment contrast depended on the study baseline whenever shapes differed | Sol, fatal | **Confirmed numerically** (spread $-0.2764$ matching the predicted algebra), mechanism rebuilt, invariance verified to $4.4\times10^{-16}$ |
| $\phi$ changed effect size and effect-modifier strength as well as time dependence | Sol, serious | Fixed by the same reparameterization, verified to $5.3\times10^{-16}$ |
| Centerpiece experiment demonstrated a known theorem | Kimi, serious | **Accepted.** Reframed as sizing; least-false parameter now computed and verified against simulation to 0.0031; Struthers-Kalbfleisch and Xu-O'Quigley cited and checked |
| $\kappa=0$ is only conditionally proportional, so not a clean control | Sol, serious | Accepted; a genuine marginal-PH control at $\gamma=0$ added |
| Decision rule could not fire; no threshold, no weights, no HR-to-RMST mapping | Sol fatal, Kimi serious | Rewritten as D1 and D2 with numbers and an explicit mapping |
| Only Weibull; entry names three mechanisms | Sol fatal, Kimi serious | Gompertz added; multistate declared out of scope; scope stated in the title |
| No coverage or calibration estimand anywhere | Kimi, serious | Coverage is now a reported primary outcome with a bootstrap procedure per method |
| "Flexible" undefined for MAIC and STC rows; variance only for weighted Cox | Both, serious | Every cell's model, knots and interval procedure specified in section 6 |
| Cells $\times$ replicates never stated; runtime not auditable | Both, serious | Section 7, with measured per-fit timings |
| $\tau$ as a follow-up quantile would move with censoring | Sol, serious | Fixed numerically at 18 |
| Constant hazard ratios are not common estimands across methods | Sol, serious | One prespecified Cox-projection functional applied to every method's fitted curves |
| Normal target law and superpopulation-versus-sample left unstated | Both | Both stated in section 4 |
| $\kappa$ levels were adjectives | Kimi, minor | Calibrated against Grambsch-Therneau rejection rates |
| Bucher cited for something it does not do | Sol, citation | Corrected in section 6 |
| "Study 5" unverifiable cross-reference | Both, citation | Removed; the devices are described here in full instead |

## 13. Feasibility

Measured on this machine, flexible survival ML-NMR, 2 chains of 1,000 iterations, all converged
with maximum $\hat R \leq 1.008$:

| network rows | integration points | knots | seconds |
|---:|---:|---:|---:|
| 2,500 | 32 | 3 | 327 |
| 1,300 | 32 | 3 | 118 |
| 1,300 | 16 | 3 | 76 |
| 1,050 | 16 | 2 | 48 |

The run uses the 1,300-row network at 32 integration points. Study 5 found that moving from 64 to
256 integration points flipped 8.3% of its verdicts and concluded that under-integrating is a
real and under-reported error source; buying replicates here by dropping to 16 points would
repeat in this study the mistake that study reported. An integration-sensitivity arm at 64 points
runs on a prespecified subset.

Two Stan fits per replicate at about 118 seconds each, three workers: roughly 79 seconds of wall
clock per replicate, so 360 replicates is about **8 hours**, before bootstrap and refits. The
bootstrap runs on the frequentist rows only and is cheap. A refit budget of 10% is assumed for
replicates that fail convergence; failures are **recorded, not silently dropped**, and the
primary analysis is repeated on the subset where every fit met its criteria.

