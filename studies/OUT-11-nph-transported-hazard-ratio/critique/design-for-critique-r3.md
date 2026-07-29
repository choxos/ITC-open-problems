# THE OPEN PROBLEM (catalog entry OUT-11, key sections)

## Statement

The transported hazard ratio remains the default reported quantity in survival indirect comparisons, and on the marginal scale it can be population-dependent and time-varying through risk-set selection, while under non-proportional hazards a fitted Cox coefficient is a censoring- and event-weighted constant summary of a time-varying contrast. A conditional hazard ratio under a proportional-hazards model is constant by definition, so the instability belongs to the marginal scale or to non-proportionality rather than to the coefficient as such. The recommended alternatives are not missing from software: multinma has shipped survival models since 0.6.0 with predict() types including survival, hazard, cumulative hazard, mean, median, quantile and restricted mean survival time, marginal_effects() returns RMST and survival-probability differences standardized to a target population, and auxiliary parameters can be stratified by treatment to relax proportional hazards. The gap is between available methods and prevailing practice, and in the absence of any simulation benchmark comparing these estimators against proportional-hazards MAIC and STC under crossing hazards and differential censoring.

## Why it is open

Practice still reports a coefficient, so the mismatch between the estimand a reimbursement decision needs and the estimand produced persists even though the tooling exists in one package. Separating a baseline-hazard difference from an effect-modifier difference requires assumptions that published Kaplan-Meier curves cannot adjudicate, and the standard proportional-hazards test is often underpowered. No simulation study compares general-likelihood ML-NMR against proportional-hazards MAIC and STC on Weibull, Gompertz and multistate mechanisms with crossing hazards and differential censoring, so the relative operating characteristics of the recommended replacements are unknown. Component PAIC implementations such as cpaic still hold treatment effects proportional and lack target-marginal survival contrasts.

## Probable solution or research direction

Run the benchmark rather than rebuild the estimators: compare general-likelihood ML-NMR and one-step exact-likelihood survival network meta-analysis against proportional-hazards MAIC and STC on Weibull, Gompertz and multistate data-generating mechanisms with crossing hazards and differential censoring, reporting RMST bias, hazard-ratio instability and calibration over time. Report target-standardized survival curves, milestone contrasts and RMST differences at prespecified horizons the data support, with the horizon declared as part of the estimand, without asserting that RMST is universally required. Add target-marginal survival contrasts and time-varying treatment effects to the component PAIC implementations that lack them.

# THIS IS ROUND THREE OF PRE-RUN CRITIQUE

You are reviewing a protocol revised twice. Round one returned `unsound` and
`needs-revision`. Round two returned `unsound` again with three fatal findings,
and `needs-revision` with four serious ones. Nothing has been simulated yet.

Every round-two fatal was checked against the protocol text before being
accepted, and all three were confirmed. The revision is a substantial rebuild,
not a patch: the network changed from four studies to two, the decision rule
changed from a bias tolerance to an excess-recommendation-error rate, the
data-generating mechanism is now numerically locked, the integration order is
measured rather than cited, and the flexible ML-NMR estimator was replaced after
implementation showed the registered one cannot produce the study's estimand.

Because the revision is large, judge it primarily ON ITS OWN TERMS. Round-two
findings and their claimed resolutions are listed compactly below; check the
protocol text against each claim, since claiming a fix the text does not contain
is the failure mode this round exists to catch. Add `round2_resolution` to your
JSON: a list of {"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Pay particular attention to material that is NEW in this version and has never
been critiqued: the two-study network, the shared transport rule on the
log-cumulative-hazard scale, the excess-recommendation-error decision rule and
its noise floor, the solved beta_B, and the aux_regression finding.

## Round-two findings and claimed resolutions

### Reviewer one, verdict `unsound`

FATAL. Censoring absent from the cell matrix, replicate total and runtime, while
four regimes appeared throughout the analysis sections.
CLAIMED FIX: confirmed; regimes assigned to experiments explicitly, four in the
analytic and cheap-simulation experiments and two in the benchmark; matrix,
replicate total and runtime recomputed.

FATAL. The data-generating mechanism is not numerically locked: beta, gamma per
treatment, a0, xi, study baselines, study means, sample sizes, allocation and
censoring rates all unset. No crossing times or PH-test power at retained levels.
CLAIMED FIX: confirmed; every parameter registered in R/00-config.R and
transcribed into the protocol; crossing times, PH-test power, event fractions and
at-risk fractions computed and tabulated per cell.

FATAL. A 0.5-month reimbursement threshold does not justify a 0.5-month bias
tolerance. True gains were 1.155, 1.817, 2.359 against a 0.5 boundary, so every
cell sat 0.65 to 1.86 clear of it and no tolerated error could change a
recommendation. Also, absolute value of a pooled signed bias permits cancellation.
CLAIMED FIX: confirmed against version two's own numbers; beta_B is now solved so
cells straddle the boundary; the rule is excess recommendation error over a
computed noise floor; weighted mean absolute cell bias replaces absolute pooled
bias.

FATAL. Pairwise MAIC and STC cannot consume three aggregate studies, so "every
method uses the same studies" was asserted, not implemented.
CLAIMED FIX: confirmed; network reduced to two studies so the claim is true.

SERIOUS, condensed. PH-versus-flexible columns changed likelihood and basis as
well as proportionality; equal knot counts do not equate Royston-Parmar and
M-spline flexibility; superpopulation estimand versus MAIC's realized-sample
target; no time-indexed calibration outcome; coverage unresolvable at the stated
budget with no inconclusive region; the four-regime statistic underspecified; no
priors, prior sensitivity, bootstrap interval type or resampling unit; R-hat alone
is not a sampler policy; the integration citation argues against the choice it
justified; runtime omitted censoring regimes and bootstrap; the two sources of
censoring dependence were called exactly separable when the least-false root is
nonlinear; "Study 5" unidentified; the one-step equivalence claim unestablished;
the title overstates a partial benchmark.
CLAIMED FIXES: all addressed in the protocol below; see its section 13 table.

### Reviewer two, verdict `needs-revision`

SERIOUS. The column-effect claim is false for the MAIC and STC rows, and the
protocol both asserts and disavows it.
CLAIMED FIX: rows rebuilt on one basis each, toggling only treatment-by-time
terms; weighted Cox retained as a separately labelled row outside the factorial.

SERIOUS. The rule by which MAIC and STC turn three aggregate studies into one
target estimate is unspecified, and naive pooling mixes populations when gamma
is nonzero.
CLAIMED FIX: dissolved by the two-study network; the transport rule is now
written out explicitly and is shared by all frequentist rows.

SERIOUS. No scenario produces an in-window hazard crossing, although the entry
asks for crossing hazards; the marginal HR spans 0.32 to 0.84 and crosses 1 only
beyond the administrative cutoff.
CLAIMED FIX: confirmed against version two; resolved as a side effect of solving
beta_B down to a decision-relevant margin. Marginal hazard ratios now cross 1 at
8, 13 and 14 months; conditional crossings at 6.2 to 14.4 months.

SERIOUS. The 500-resample full-pipeline bootstrap is plausibly the dominant cost
and was called "cheap" without measurement.
CLAIMED FIX: confirmed, and it is. Measured at 0.658 s per resample, which is
several times the Stan cost; the runtime is recomputed from the measurement.

MINOR, condensed. "Study 5" still cited despite the change log claiming removal;
comparator authorship uncited; "nobody appears to have quantified it" overclaims
against Hernan 2010, Aalen Cook and Roysland 2015, and Stensrud and Hernan 2020;
gamma's role ambiguous; D1 pooling ambiguous; priors and interval types
unspecified; ESS and divergences absent from the recording policy.
CLAIMED FIXES: all addressed; six comparator attributions added and verified, the
novelty claim narrowed against the named literature, gamma stated as shared.

# THE REVISED PROTOCOL (version three)

# Protocol: what a transported hazard ratio summarizes, and how the recommended replacements behave

Registered before any replicate of the reported run. Catalog problem **OUT-11**.

This is the **third** version. Two rounds of adversarial pre-run critique preceded it. Round 1
returned `unsound` and `needs-revision` and found a fatal algebraic error in the data-generating
mechanism that the design's own calibration run had missed. Round 2 returned `unsound` again,
with three fatal findings, all three of which were confirmed against this document before being
accepted. Section 13 records every finding and its resolution. Nothing had been simulated at
either point, so nothing was discarded except time.

The single most useful thing the second round produced is not in the critique. It is what
implementing the registered specification revealed: **the estimator this protocol had registered
as the flexible ML-NMR arm cannot produce the study's own estimand.** Section 7 gives the
evidence.

---

## 1. The problem, and the part of it this study settles

The OUT-11 entry is marked **overstated**, and its verification trail says why: the source claimed
target-standardized survival curves and RMST are outputs current software cannot produce, and that
is false. `multinma` has shipped survival likelihoods since 0.6.0 and `marginal_effects()` has
returned target-standardized RMST since 0.7.0.

Two auditors corrected the framing, and that correction defines this study. A **conditional**
hazard ratio under a proportional-hazards model is constant by definition. The instability belongs
either to the **marginal** scale, where risk-set selection makes the hazard ratio
population-dependent and time-varying, or to **non-proportionality**, where a fitted Cox
coefficient is a censoring- and event-weighted constant summary of a time-varying contrast.

What the entry leaves open is a benchmark: no simulation study compares general-likelihood ML-NMR
against proportional-hazards MAIC and STC under crossing hazards and differential censoring.

**This is a partial Weibull and Gompertz benchmark and the title says so.** It does not run a
multistate mechanism, which the entry also names. It does not implement a separate one-step
exact-likelihood survival NMA as a distinct estimator; that omission is now stated as an omission
rather than argued away. Round 2 was right that "ML-NMR already fits the exact individual-level
likelihood" does not establish estimator-level equivalence, and no such claim is made.

## 2. Three experiments, only one of which is expensive

| | what it establishes | cost |
|---|---|---|
| **E1** | The censoring dependence of the transported hazard ratio, computed exactly by quadrature and root-finding across all four censoring regimes | none |
| **E2** | Finite-sample behavior of the transported hazard ratio around that limit: whether an analyst at realistic sample sizes can distinguish the regimes | minutes |
| **E3** | The benchmark: six estimators on a common target-population estimand | the whole budget |

Round 2's first fatal finding was that four censoring regimes appeared throughout the analysis
sections while the cell matrix and the runtime estimate silently assumed one. That was correct.
The regimes are now assigned to experiments explicitly: **E1 and E2 use all four; E3 uses two**,
because E3 is the only one where a regime costs Stan fits. That is a budget decision, it is stated
as one, and section 14 recomputes the runtime from it.

## 3. Data-generating mechanism

Individual $i$ in study $j$ on treatment $k$, with one covariate $x \sim N(\mu_j, 1)$. The
treatment arm is a **study-invariant multiplier** on the study's own placebo hazard:

$$h_{jk}(t \mid x) \;=\; h_{j0}(t)\,\exp\{\beta_k + \kappa_k\, g(t) + \gamma_k x\}.$$

| family | placebo hazard | $g(t)$ | resulting family |
|---|---|---|---|
| Weibull | $(a_0/s_j)(t/s_j)^{a_0-1}$ | $\log(t/t_0)$ | Weibull, shape $a_0 + \kappa_k$ |
| Gompertz | $b_j e^{\xi t}$ | $(t-t_0)/t_0$ | Gompertz, rate $\xi + \kappa_k/t_0$ |

with $t_0 = 12$. Both stay in closed form, so the truth stays exact.

Three properties, each **verified in code rather than asserted**, all run at analysis time:

1. The contrast does not depend on the study baseline. Worst spread $4.4\times10^{-16}$.
2. $\kappa$ isolates non-proportionality: at $t=t_0$, $g=0$, so the log hazard ratio is
   $\beta_k+\gamma_k x$ whatever $\kappa_k$ is. Worst spread $5.3\times10^{-16}$.
3. The quadrature truth agrees with 2,000,000 simulated draws, both families, within the
   simulation's own Monte Carlo error.

**Who carries which parameter.** Round 2 asked, correctly, which treatment each Greek letter
belongs to. $\kappa_A = 0$ always: A is exactly proportional and B is the only treatment whose
contrast bends. $\gamma$ is **shared between A and B**, which is the anchored shared-effect-modifier
assumption that MAIC, STC and ML-NMR all require; it therefore holds by construction here, and
this study is about the survival-model dimension rather than about effect-modifier identification,
which is IDN-05's subject.

A consequence worth stating, because it strengthens the study: with $\gamma$ shared, the
conditional B-versus-A contrast is $\beta_B-\beta_A+\kappa_B g(t)$ with **no covariate term at
all**. Any movement of the reported hazard ratio at $\kappa_B=0$ is therefore pure risk-set
selection on a **prognostic** covariate, with zero effect modification of the contrast being
reported. That is the cleanest possible form of the mechanism the entry's auditors described.

**Network. Two studies.** One contributes individual patient data and compares PBO with A; one
contributes aggregate data, compares PBO with B, and defines the target population. Every one of
the six estimators can use both studies in full, so **the evidence set is identical across methods
by construction rather than by assertion**. Version 2 used three aggregate studies, and both
reviewers were right that no pairwise MAIC or STC can consume three aggregate studies without
becoming a different method; asserting that "every method uses the same studies" did not make it
so. The fix is to shrink the network until the claim is true.

**Locked parameters.** Registered in `R/00-config.R`, which the run sources; this table is a
transcription, not a paraphrase.

| quantity | value |
|---|---|
| $\tau$ (RMST horizon), $t^*$ (milestone), $t_0$, administrative cutoff | 18, 12, 12, 36 |
| per-arm size, IPD study / aggregate study | 250 / 200, equal randomization |
| covariate mean, IPD study / target | 0.00 / 0.60, SD 1.00 both |
| Weibull scale $s_j$, IPD / target; shape $a_0$ | 12 / 14; 1.2 |
| Gompertz level $b_j$, IPD / target; rate $\xi$ | 1/25 / 1/30; 0.05 |
| $\beta_A$, $\kappa_A$ | $-0.25$, $0$ |
| $\gamma$ (shared A and B) | 0.30; 0 in the marginal-PH control |
| $\kappa_B$ | 0, 0.15, 0.30 |
| $\beta_B$ | **solved**, see section 10 |

## 4. Estimand

**Target population.** The aggregate study's covariate law, taken as $N(0.60, 1)$. That it is
normal is an **assumption** and is stated as one.

**Target summaries are supplied to every method as the true superpopulation values** $(0.60,
1.00)$, identically. Round 2 found a real mismatch in version 2: it named a superpopulation
estimand while saying MAIC targets the realized aggregate sample, and scored both against the same
truth. Supplying known moments removes the mismatch rather than papering over it, and it makes
MAIC's balancing target the superpopulation, which is what it is scored against. Target-summary
sampling error is thereby excluded from this study on purpose; it is the subject of MIS-03 in this
same program, and is cross-referenced rather than silently dropped.

**Primary.** Target-population marginal RMST difference between B and A at $\tau = 18$:

$$\Delta_{\text{RMST}}(\tau) = \int_0^\tau \bar S_B(t)\,dt - \int_0^\tau \bar S_A(t)\,dt,
\qquad \bar S_k(t) = \mathbb{E}_{x\sim\text{target}}[S_k(t\mid x)].$$

Both arms are evaluated at the **target study's own baseline** and the target covariate law: that
is what "if both treatments were given in the target population" means, and it is the only reading
under which all six estimators target the same thing. $\tau$ is fixed numerically and is identical
in every cell and every censoring regime, so the truth cannot move with follow-up.

**Calibration over time.** Round 2 was right that OUT-11 asks for calibration over time and that
version 2 supplied it at a single horizon. Bias and pointwise 95% interval coverage of the
target-standardized survival difference $\bar S_B(t)-\bar S_A(t)$ are therefore reported at
$t \in \{6, 12, 18\}$, alongside the RMST primary, with the time grid registered here.

**Secondary.** The true time-varying marginal hazard ratio $\bar h_B(t)/\bar h_A(t)$, with the
marginal hazard defined as $\mathbb{E}[hS]/\mathbb{E}[S]$, which is **not** the average of
conditional hazards.

**The constant hazard ratio is not a common estimand across methods.** One prespecified Cox
projection functional (section 5) is applied to every method's fitted target survival curves, so
the constant summaries being compared are the same functional of different fits.

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

**Four regimes**, all used here: rate 0.010, 0.050, 0.100 at cutoff 36, and rate 0.020 at cutoff
18. The truth is held exactly fixed across them by construction, since censoring touches no
survival function.

**Reported as a factorial with an interaction term, not as an additive decomposition.** Round 2
was right that the least-false root is nonlinear, so the two pathways to marginal
non-proportionality do not add. The computed table shows exactly that: at $\kappa_B = 0.30$ the
spread across regimes *falls* from 18.2% to 15.7% as $\gamma$ rises from 0 to 0.50. The
prespecified claims are the two ablations, which are exact:

- $\gamma = 0$ **and** $\kappa_B = 0$ gives zero movement (computed: $1\times10^{-9}$).
- $\gamma > 0$, $\kappa_B = 0$, covariate spread collapsed to zero gives zero movement (computed:
  $1.6\times10^{-11}$).

## 6. E2: finite-sample behavior of the transported hazard ratio

For each of the four regimes and each $\kappa_B$, 1,000 replicates at the benchmark's own sample
sizes, fitting an unadjusted Cox model in the target study. Reported: the scatter of the estimate
around its analytic limit, and the power of a pairwise test to distinguish the reference regime
from each other regime. This is the part the theorem does not give. It costs `coxph` fits only.

## 7. E3: the estimators, and a specification that does not transport

### 7.1 What implementing the registered specification revealed

Version 2 registered the flexible ML-NMR arm as `aux_by = c(.study, .trt)`, following the OUT-11
catalog entry, which names that option as the way to relax proportional hazards. **It is correct
for the within-study fit and silently unable to transport.**

Stratifying the baseline hazard by study-arm makes each arm's spline a free parameter attached to a
study that observed that arm, with no rule connecting it to a population where the arm was never
given. Asked for a target-standardized prediction on the two-study network, `multinma` can only
return treatments whose auxiliary parameters exist in the named study: `aux = "S2"` returns PBO and
B, `aux = "S1"` returns PBO and A, and there is no call in which A and B are both standardized to
the target. The absolute values it does return are not merely imprecise but wrong, giving RMST of
3.3 and 4.6 months against a placebo of 14.7 on the same fit, and the package emits a note pointing
at `aux_regression` instead.

**The flexible arm is therefore `aux_regression = ~ .trt`**, which makes the spline coefficients a
regression on treatment so the *shape* of a treatment's hazard is a shared transportable function.
On a single check replicate it returned PBO 10.84, A 10.98, B 11.75 in the target population,
against a locked truth of $\Delta_{\text{RMST}} = 0.75$.

This is a reportable result and not merely an implementation note: the catalog entry recommends a
setting that cannot deliver the entry's own requested output, and the failure is silent in the
sense that the fit converges and returns numbers.

**The proportional arm was checked the same way and passes.** `aux_by = .study` returns all three
treatments in the target population at sane values, PBO 11.25, A 11.47 and B 11.35, with
$\hat R = 1.008$ and minimum ESS 456. On that check replicate, at $\kappa_B = 0.30$, it estimates
$\Delta_{\text{RMST}} = -0.12$ against a truth of $+0.75$, an error comparable to the
proportional MAIC rows. The ML-NMR row is not privileged by this design: its proportional variant
fails under non-proportionality exactly as the other proportional variants do, which is what makes
the column contrast worth reporting.

### 7.2 The six estimators

Round 2 was right that version 2's PH-versus-flexible columns changed likelihood and baseline
representation as well as proportionality, so the column effect was uninterpretable outside
ML-NMR. Within each row, the likelihood, basis and evidence set are now identical and **only the
treatment-by-time terms are toggled**.

| | proportional | flexible |
|---|---|---|
| **weighting** | MAIC weights, weighted Royston-Parmar, treatment as a scalar log-HR | MAIC weights, weighted Royston-Parmar, treatment-specific spline coefficients |
| **outcome regression** | STC, Royston-Parmar, treatment as a scalar log-HR, marginalized over the target law | STC, Royston-Parmar, treatment-specific spline coefficients, marginalized |
| **ML-NMR** | `mspline`, `aux_by = .study` | `mspline`, `aux_regression = ~ .trt` |

Attributions, each verified against CrossRef, since round 2 was right that "by its own authors'
recommendation" is unauditable without them: MAIC, Signorovitch et al. 2010
(doi:10.2165/11538370-000000000-00000); STC, Ishak et al. 2015 (doi:10.1007/s40273-015-0271-1);
ML-NMR, Phillippo et al. 2020 (doi:10.1111/rssa.12579); the anchored indirect contrast, Bucher et
al. 1997 (doi:10.1016/S0895-4356(97)00049-8); the flexible parametric basis, Royston and Parmar
2002 (doi:10.1002/sim.1203); the proportional-hazards test used for calibration, Grambsch and
Therneau 1994 (doi:10.1093/biomet/81.3.515).

**The transport rule is shared by all five frequentist rows**, so the row and column contrasts mean
something. An A-versus-PBO RMST difference is not transportable across studies with different
baselines, so the transported object is the relative effect on the log-cumulative-hazard scale:
$\log H^{\text{tgt}}_A(t) = \log H^{\text{agd}}_{\text{PBO}}(t) + [\log H^{\text{ipd}}_A(t) - \log
H^{\text{ipd}}_{\text{PBO}}(t)]$, with the bracket computed in the target covariate distribution
and constant in $t$ only in the proportional variants. B's curve comes from the aggregate study
directly. The aggregate-side model is fitted once per replicate and shared across rows, which is
the identical-evidence clause made operational rather than asserted.

**MAIC weights** match the target's first and second moments by exponential tilt. Round 2 noted,
correctly, that with one covariate and equal variances in study and target, matching the mean alone
would transport a normal exactly, because an exponential tilt on $x$ shifts a normal's mean without
touching its variance. Both moments are matched anyway, because that is what an analyst does and
because this study should not quietly grant MAIC an exactness its applied use does not have.

**Weighted Cox with a Breslow baseline is retained as a seventh, separately labeled row, "MAIC as
practiced".** It is what applied MAIC actually does, it is nearly free to fit, and it is reported
and interpreted on its own rather than used to define the column effect.

**Flexibility is not claimed to be matched across rows.** Round 2 was right that equal internal
knot counts do not equate a Royston-Parmar restricted cubic spline on the log-cumulative-hazard
scale with an M-spline on the hazard scale. Each method uses its own recommended specification:
Royston-Parmar with 3 internal knots at quantiles of the uncensored event times and boundary knots
at the extremes; `multinma` M-splines with 3 internal knots at its own default placement. A
**complexity-sensitivity arm** repeats a prespecified subset at 2 and 5 internal knots for both
bases, and the comparison is interpreted only to the extent that arm supports it.

**Marginalized STC**, not the mean-profile plug-in, which returns a conditional quantity at an
average covariate profile.

**Uncertainty.** Nonparametric bootstrap over the full pipeline, resampling individuals within arm
within study and re-running weight estimation, model fitting and re-standardization, 500 resamples,
percentile intervals, for all four frequentist rows and the seventh row. Posterior draws for both
ML-NMR rows. The inner Monte Carlo error of a 500-resample percentile interval is reported rather
than assumed negligible.

**Priors**, registered: `normal(0, 10)` on intercepts and treatment effects, `normal(0, 2.5)` on
the covariate interaction, `half_normal(1)` on auxiliary parameters, `normal(0, 2.5)` on the
auxiliary regression. A prior-sensitivity arm halves and doubles the interaction and auxiliary
scales on a prespecified subset. Round 2 was right that version 2 registered none of this.

**Sampler policy**, registered, and revised because measuring it showed the first draft of the
policy was unmeetable. Round 2 was right that maximum $\hat R$ alone is not a policy. The
replacement was written as $\hat R < 1.01$ and bulk and tail ESS $\geq 400$ **on every monitored
parameter**, at 2 chains of 1,000 iterations. Probe fits then returned $\hat R$ of 1.011 to 1.015
and minimum ESS of 229 to 355, so essentially every fit in the run would have been declared a
failure and refit, which is a policy that reports nothing except its own threshold.

Two corrections. **Four chains of 1,000 iterations**, not two: four chains cost the same wall clock
per fit on this machine, since chains run in parallel, and they double the draws while making
$\hat R$ itself better estimated. And the ESS criterion binds on the **derived estimand**, the
target-standardized $\Delta_{\text{RMST}}(18)$ and the survival differences on the time grid, which
is what the study actually uses; the global minimum across all internal spline coefficients is
recorded for every fit and reported, but is not a pass criterion, because a weakly identified
nuisance coefficient failing to mix does not invalidate a well-mixed estimand.

Registered thresholds: $\hat R < 1.01$ and bulk and tail ESS $\geq 400$ on the derived estimand,
zero divergent transitions, no transition at maximum treedepth. A fit failing any criterion is
refit once at doubled iterations with `adapt_delta = 0.99`; a fit failing twice is **recorded as a
failure, not silently dropped**, and the primary analysis is repeated on the subset where every fit
met every criterion.

**Integration order is measured, not cited.** Version 2 cited IDN-05's finding that moving from 64
to 256 integration points flipped 8.3% of its verdicts and then chose 32, which is *below* the
order IDN-05 found insufficient; IDN-05 also recorded that 256 was not itself shown to be
converged, so it is not an accuracy reference either. Round 2 caught the citation and it was
right. The order is instead measured on this study's own network by `R/probe-integration.R`,
comparing the target-standardized RMST difference at 32, 64, 128 and 256 points, and the selected
order is registered in section 14 before the run.

## 8. E3: the cell matrix

Registered by `build_cells()` in `R/04-calibrate.R`. Twelve cells, 40 replicates each, **480
replicates**.

| arm | family | $\kappa_B$ | $\gamma$ | true $\Delta_{\text{RMST}}(18)$ | $\beta_B$ | censoring |
|---|---|---:|---:|---:|---:|---|
| primary | Weibull | 0.00 | 0.30 | 0.75 | $-0.4140$ | balanced, differential |
| primary | Weibull | 0.15 | 0.30 | 0.75 | $-0.2706$ | balanced, differential |
| primary | Weibull | 0.30 | 0.30 | 0.75 | $-0.1431$ | balanced, differential |
| margin | Weibull | 0.00 | 0.30 | 0.35 | $-0.3255$ | balanced |
| margin | Weibull | 0.30 | 0.30 | 0.35 | $-0.0505$ | balanced |
| control | Weibull | 0.00 | 0.00 | 0.75 | $-0.4223$ | balanced, differential |
| family | Gompertz | 0.00 | 0.30 | 0.75 | $-0.4450$ | balanced |
| family | Gompertz | 0.30 | 0.30 | 0.75 | $-0.3110$ | balanced |

Censoring in E3 is **between-study differential follow-up**, which is what "differential censoring"
means in the OUT-11 entry: balanced is rate 0.010 in both studies, differential is 0.020 in the IPD
study against 0.100 in the aggregate study, cutoff 36 in both. Arm-differential censoring within a
comparison is declared out of scope in section 12.

**$\beta_B$ is solved, not chosen**, so that the true target RMST difference lands on a registered
margin relative to the decision threshold. Section 10 explains why that is the difference between a
decision rule that can fire and one that cannot.

**Registered properties of every cell**, computed by `cell_properties()` before the run, at 200 per
arm with a Grambsch-Therneau test at the 0.05 level:

| family | $\kappa_B$ | $\gamma$ | cond. cross | marg. cross | marginal HR range | at risk at 18, A / B | PH test rejects |
|---|---:|---:|---:|---:|---|---:|---:|
| Weibull | 0.00 | 0.30 | none | none | 0.849 to 0.873 | 0.240 / 0.288 | 0.060 |
| Weibull | 0.15 | 0.30 | 13.8 | 13 | 0.548 to 1.149 | 0.240 / 0.263 | 0.215 |
| Weibull | 0.30 | 0.30 | 8.4 | 8 | 0.349 to 1.484 | 0.240 / 0.239 | 0.600 |
| Weibull | 0.00 | 0.30 (margin) | none | none | 0.927 to 0.940 | 0.240 / 0.262 | 0.065 |
| Weibull | 0.30 | 0.30 (margin) | 6.2 | 6 | 0.382 to 1.596 | 0.240 / 0.213 | 0.640 |
| Weibull | 0.00 | 0.00 (control) | none | none | **0.842 to 0.842** | 0.291 / 0.344 | 0.055 |
| Gompertz | 0.00 | 0.30 | none | none | 0.823 to 0.852 | 0.336 / 0.393 | 0.055 |
| Gompertz | 0.30 | 0.30 | 14.4 | 14 | 0.701 to 1.629 | 0.336 / 0.364 | 0.530 |

Three things this table settles, all of which round 2 asked for and version 2 did not supply.

**The marginal-PH control is exact.** At $\kappa_B=\gamma=0$ the marginal hazard ratio is 0.842 at
both ends of the grid, so it is constant to the printed precision and the proportional methods are
correctly specified. That is where they must win; if they do not, the comparison is rigged and the
paper will say so.

**Crossings happen inside the supported window, and in version 2 they did not.** Round 2's second
reviewer found that no version-2 cell produced an in-window crossing: with a large treatment effect
the marginal hazard ratio ran from 0.32 to 0.84 at $\kappa_B=0.30$ and never reached 1 before the
cutoff, so a protocol promising a benchmark "under crossing hazards" delivered divergence without
crossing. That was correct against version 2. It is resolved here as a **side effect of the fix to
a different reviewer's finding**: solving $\beta_B$ down to a decision-relevant margin shrinks the
early advantage enough that the late reversal crosses. The marginal hazard ratio now runs 0.349 to
1.484 and crosses 1 at 8 months at $\kappa_B=0.30$, 0.548 to 1.149 crossing at 13 months at
$\kappa_B=0.15$, and 0.701 to 1.629 crossing at 14 months for Gompertz. Conditional crossings are
at 13.8, 8.4, 6.2 and 14.4 months, all well inside the 36-month cutoff and bracketing the 18-month
horizon.

**The retained levels are the ones an analyst misses.** The proportional-hazards test rejects at
0.055 to 0.065 in the three proportional cells, which calibrates the test rather than the design;
at 0.215 for $\kappa_B=0.15$; and at 0.53 to 0.64 for $\kappa_B=0.30$. So an analyst misses the
mild violation 78% of the time and the strong one about 40% of the time. Nothing retained is a
violation so large that no competent analyst could overlook it.

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

# LOCKED CONFIGURATION, VERBATIM

The protocol's parameter table is a transcription of this file, which the run
sources. It is included so the transcription can be checked.

```r
## ---------------------------------------------------------------------------
## Every number the design depends on, in one place, fixed before the run.
##
## A pre-run critique returned "the DGM is still not numerically locked" as a
## fatal finding, and it was right: the previous protocol registered only the
## kappa and gamma grids and left the treatment effects, baselines, study means,
## sample sizes, allocation and censoring rates unset. A preregistration that
## cannot be executed from its own text is not a preregistration. This file is
## the executable version, and the protocol quotes it rather than paraphrasing.
##
## Two conventions matter and are stated rather than left to be inferred:
##
##   * kappa and gamma belong to SPECIFIC treatments. kappa_A = 0 always: A is
##     exactly proportional, and B is the only treatment whose contrast bends.
##     gamma is SHARED between A and B, which is the anchored shared-effect-
##     modifier assumption that MAIC, STC and ML-NMR all require. It therefore
##     holds by construction here, and this study is about the survival-model
##     dimension, not about effect-modifier identification (that is IDN-05).
##
##   * The B-versus-A conditional contrast is beta_B - beta_A + kappa_B g(t),
##     with NO covariate term, because gamma cancels. Marginal non-proportion-
##     ality at kappa_B = 0 therefore arises purely from risk-set selection on a
##     prognostic covariate, which is the cleanest possible form of the mechanism
##     the catalog entry's auditors described.
## ---------------------------------------------------------------------------

## --- times ------------------------------------------------------------------
TAU      <- 18    # RMST horizon. Fixed numerically, identical in every cell and
                  # every censoring regime, so the truth cannot move with follow-up.
T_STAR   <- 12    # milestone survival time (secondary)
T_ADMIN  <- 36    # administrative cutoff in the reference regime
T_GRID   <- c(6, 12, 18)   # time grid for calibration-over-time outcomes

## --- network ----------------------------------------------------------------
## Two studies. The IPD study compares PBO with A; the aggregate study compares
## PBO with B and defines the target population. Every one of the six estimators
## can use both studies in full, so the evidence set is identical across methods
## by construction rather than by assertion. A previous draft used three
## aggregate studies, which no pairwise MAIC or STC can consume without becoming
## a different method; a critique called that out and it is fixed by shrinking
## the network rather than by asserting equivalence.
N_IPD_ARM <- 250  # per arm in the IPD study (PBO, A)
N_AGD_ARM <- 200  # per arm in the aggregate study (PBO, B)
ALLOC     <- 0.5  # equal randomization in both studies

MU_IPD <- 0.00    # covariate mean, IPD study
MU_TGT <- 0.60    # covariate mean, aggregate study = the target population
SD_X   <- 1.00    # covariate SD, both studies and the target law

## Study baselines differ, which is the situation population adjustment exists
## for, and which the rebuilt parameterization tolerates: the treatment contrast
## is invariant to them (verify_invariance(), 4.4e-16).
S_IPD <- 12; S_TGT <- 14        # Weibull scale, per study
B_IPD <- 1/25; B_TGT <- 1/30    # Gompertz level, per study
A0    <- 1.2                    # Weibull shape, placebo
XI    <- 0.05                   # Gompertz rate, placebo

## --- treatment effects ------------------------------------------------------
BETA_A  <- -0.25   # log HR of A versus PBO at t = T0, all cells
KAPPA_A <- 0.00    # A is exactly proportional, all cells
GAMMA   <- 0.30    # shared A and B effect modification; 0 in the marginal-PH control

## beta_B is NOT a free design number: it is SOLVED per cell so that the true
## target-population RMST difference lands on a registered margin relative to
## the decision threshold (see 04-calibrate.R). A critique showed that the
## previous design's true gains were 1.155, 1.817 and 2.359 months against a
## 0.5-month decision boundary, so every cell was 0.65 to 1.86 months clear of
## it and no estimation error of the size being tolerated could ever change a
## recommendation. Fixing the margin rather than the coefficient is what makes
## the decision rule able to fire.
DELTA_THRESHOLD <- 0.50          # months of RMST gain that justify the cost
MARGIN_LEVELS   <- c(recommend = 0.75, decline = 0.35)   # true Delta_RMST(TAU)

KAPPA_B_LEVELS <- c(0, 0.15, 0.30)

## --- censoring --------------------------------------------------------------
## Independent exponential at a per-study rate plus an administrative cutoff.
## Touches no survival function, so the true estimand is invariant to it by
## construction: that is what makes censoring a manipulation of a nuisance.
##
## E3 (the expensive benchmark) uses two regimes; E1 and E2 (analytic and cheap)
## use all four. Which experiment sees which regime is registered here rather
## than being left to the runtime, because a critique found the four regimes
## appearing in the analysis sections while the cell matrix and the runtime
## estimate silently assumed one.
CENS_REGIMES <- data.frame(
  label     = c("reference", "moderate", "heavy", "short-followup"),
  rate_ipd  = c(0.010, 0.050, 0.100, 0.020),
  rate_agd  = c(0.010, 0.050, 0.100, 0.020),
  t_admin   = c(36,    36,    36,    18),
  stringsAsFactors = FALSE
)
## The benchmark's censoring factor is BETWEEN-STUDY differential follow-up,
## which is what "differential censoring" means in the OUT-11 entry. Arm-
## differential censoring within a comparison is declared out of scope.
E3_CENS <- data.frame(
  label     = c("balanced", "differential"),
  rate_ipd  = c(0.010, 0.020),
  rate_agd  = c(0.010, 0.100),
  t_admin   = c(36,    36),
  stringsAsFactors = FALSE
)

## --- estimation settings ----------------------------------------------------
## Four chains, not two. Chains run in parallel so four cost the same wall clock
## per fit on this machine, they double the draws, and they make R-hat itself
## better estimated. Measured at two chains the probe fits returned R-hat 1.011
## to 1.015 and minimum ESS 229 to 355, which would have failed the registered
## sampler policy on essentially every fit in the run.
N_CHAINS <- 4
N_ITER   <- 1000
## N_INT is NOT set here by citing another study's number. A critique noted that
## the previous draft cited IDN-05's finding that 64 -> 256 integration points
## flipped 8.3% of verdicts and then chose 32, which is below the order IDN-05
## found insufficient. The order is instead MEASURED on this study's own network
## by R/04-calibrate.R and registered before the run.
N_INT <- NA_integer_   # set by the integration calibration, then hard-coded

N_BOOT <- 500          # full-pipeline bootstrap resamples, frequentist rows
N_REP  <- 40           # replicates per cell in E3
N_REP_E2 <- 1000       # replicates per cell in E2 (coxph only, milliseconds)

SEED <- 20260728

## --- helpers ----------------------------------------------------------------
## Build an arm specification for a given study and treatment.
make_arm <- function(family, study = c("ipd", "tgt"),
                     beta = 0, kappa = 0, gamma = 0) {
  study <- match.arg(study)
  list(family = family,
       a0  = A0,
       s_j = if (study == "ipd") S_IPD else S_TGT,
       xi  = XI,
       b_j = if (study == "ipd") B_IPD else B_TGT,
       beta = beta, kappa = kappa, gamma = gamma)
}
```

# THE SHARED TRANSPORT RULE AND THE FREQUENTIST ESTIMATORS, VERBATIM

```r
## --- MAIC weights ------------------------------------------------------------
## Method-of-moments exponential tilt matching the target's first and second
## moments, which is standard practice (Signorovitch et al. 2010,
## doi:10.2165/11538370-000000000-00000).
##
## Worth recording because a reviewer raised it: with ONE covariate and equal
## variances in study and target, matching the mean alone would transport a
## normal exactly, since an exponential tilt on x shifts a normal's mean without
## touching its variance. Both moments are matched anyway, because that is what
## an analyst does and because the study should not quietly grant MAIC an
## exactness its applied use does not have.
maic_weights <- function(x, mu_t, sd_t) {
  X <- cbind(x - mu_t, (x - mu_t)^2 - sd_t^2)
  obj <- function(a) sum(exp(X %*% a))
  gr  <- function(a) colSums(as.vector(exp(X %*% a)) * X)
  o <- optim(c(0, 0), obj, gr, method = "BFGS",
             control = list(maxit = 500, reltol = 1e-12))
  w <- as.vector(exp(X %*% o$par))
  list(w = w * length(w) / sum(w),
       ess = sum(w)^2 / sum(w^2),
       converged = o$convergence == 0)
}

## --- Royston-Parmar fits, PH and flexible ------------------------------------
## `k` internal knots at quantiles of the uncensored event times; boundary knots
## at the extremes. Same basis, same likelihood, in every cell of a row.
rp_fit <- function(d, flexible, weights = NULL, covariate = FALSE, k = RP_KNOTS) {
  fml <- if (covariate) Surv(time, status) ~ trt01 + x1 + trt01:x1
         else           Surv(time, status) ~ trt01
  ## The flexible variant lets the treatment shift every spline coefficient,
  ## which is exactly "treatment-specific spline coefficients"; the proportional
  ## variant leaves treatment as a scalar on the log-cumulative-hazard scale.
  anc <- if (flexible) {
    stats::setNames(rep(list(~ trt01), k + 1), c("gamma1", paste0("gamma", seq_len(k) + 1)))
  } else NULL
  args <- list(formula = fml, data = d, k = k, scale = "hazard")
  if (!is.null(weights)) args$weights <- weights
  if (!is.null(anc)) args$anc <- anc
  do.call(flexsurvspline, args)
}

## log cumulative hazard of a fitted RP model at times `tt` for a covariate
## profile, marginalized over the target law when `xs` has length > 1.
rp_logH <- function(fit, tt, trt, xs = NA_real_) {
  nd <- if (all(is.na(xs))) data.frame(trt01 = trt)
        else data.frame(trt01 = trt, x1 = xs)
  ## Marginal survival in the target population is the AVERAGE of conditional
  ## survival, not survival at the average covariate. Averaging on the survival
  ## scale then taking log(-log(.)) is the correct order.
  S <- summary(fit, newdata = nd, t = tt, type = "survival", ci = FALSE, tidy = TRUE)
  Sm <- if (nrow(nd) == 1L) S$est else
        tapply(S$est, S$time, mean)[as.character(tt)]
  log(pmax(-log(pmin(pmax(as.vector(Sm), 1e-12), 1 - 1e-12)), 1e-12))
}

## --- the shared transport step ----------------------------------------------
## Turns an IPD-side relative effect and an aggregate-side placebo curve into
## the target-population estimand. Identical in all four RP rows.
transport <- function(logH_pbo_agd, logH_B_agd, dlogH_A, tt, tau = TAU,
                      t_grid = T_GRID) {
  S_of <- function(lh) exp(-exp(lh))
  S_A <- S_of(logH_pbo_agd + dlogH_A)
  S_B <- S_of(logH_B_agd)
  rmst <- function(S) {
    i <- tt <= tau
    sum(diff(tt[i]) * (head(S[i], -1) + tail(S[i], -1)) / 2)
  }
  list(rmst_diff = rmst(S_B) - rmst(S_A),
       surv_diff = vapply(t_grid, function(u) {
         j <- which.min(abs(tt - u)); S_B[j] - S_A[j] }, 0))
}

## --- the five frequentist estimators -----------------------------------------
## Each takes the simulated network and returns a named list with rmst_diff and
## surv_diff. `d$ipd` has PBO and A; `d$agd` has PBO and B.
##
## The aggregate side is fitted once per replicate and shared, since every row
## uses the same aggregate-study model; only the IPD-side relative effect
## differs between rows. That is the "evidence set held constant" clause made
## operational rather than asserted.
prep <- function(d, tt) {
  ipd <- transform(d$ipd, trt01 = as.integer(trt == "A"))
  agd <- transform(d$agd, trt01 = as.integer(trt == "B"))
  list(ipd = ipd, agd = agd, tt = tt,
       agd_ph   = rp_fit(agd, flexible = FALSE),
       agd_flex = rp_fit(agd, flexible = TRUE))
}

est_maic <- function(p, flexible, mu_t = MU_TGT, sd_t = SD_X) {
  w <- maic_weights(p$ipd$x1, mu_t, sd_t)
  f <- rp_fit(p$ipd, flexible = flexible, weights = w$w)
  a <- if (flexible) p$agd_flex else p$agd_ph
  out <- transport(rp_logH(a, p$tt, 0), rp_logH(a, p$tt, 1),
                   rp_logH(f, p$tt, 1) - rp_logH(f, p$tt, 0), p$tt)
  c(out, list(ess = w$ess))
}

## STC marginalizes the IPD outcome model over the TARGET law by quadrature,
## not by plugging in the target mean: the mean-profile plug-in returns a
## conditional quantity at an average covariate profile and would rig the
## comparison in the proposal's favor.
STC_NODES <- local({ g <- gh_nodes(32); list(x = g$x, w = g$w / sqrt(pi)) })
est_stc <- function(p, flexible, mu_t = MU_TGT, sd_t = SD_X) {
  f  <- rp_fit(p$ipd, flexible = flexible, covariate = TRUE)
  xs <- mu_t + sqrt(2) * sd_t * STC_NODES$x
  a  <- if (flexible) p$agd_flex else p$agd_ph
  out <- transport(rp_logH(a, p$tt, 0), rp_logH(a, p$tt, 1),
                   rp_logH(f, p$tt, 1, xs) - rp_logH(f, p$tt, 0, xs), p$tt)
  c(out, list(ess = NA_real_))
}

## "MAIC as practiced": weighted Cox with a Breslow baseline. Reported on its
## own; it is a different likelihood and a different baseline estimator from
## every other row and is never read as a column effect.
est_maic_cox <- function(p, mu_t = MU_TGT, sd_t = SD_X) {
  w <- maic_weights(p$ipd$x1, mu_t, sd_t)
  cx <- coxph(Surv(time, status) ~ trt01, data = p$ipd, weights = w$w,
              robust = TRUE)
  out <- transport(rp_logH(p$agd_ph, p$tt, 0), rp_logH(p$agd_ph, p$tt, 1),
                   rep(unname(coef(cx)), length(p$tt)), p$tt)
  c(out, list(ess = w$ess))
}

## --- all five, on one replicate ---------------------------------------------
freq_all <- function(d, tt = seq(0.05, TAU, length.out = 200)) {
  p <- prep(d, tt)
  list(`MAIC-PH`   = est_maic(p, FALSE), `MAIC-flex` = est_maic(p, TRUE),
       `STC-PH`    = est_stc(p, FALSE),  `STC-flex`  = est_stc(p, TRUE),
       `MAIC-Cox`  = est_maic_cox(p))
}

## --- the bootstrap, and its cost --------------------------------------------
## A critique flagged the 500-resample full-pipeline bootstrap as plausibly the
## DOMINANT cost while version 2 called it "cheap" without measuring it. It is
## measured here, and the protocol quotes the measurement.
##
## Resampling unit: individuals within arm within study, so arm sizes are held
## and the weighting step is re-estimated on every resample, which is the point
## of a full-pipeline bootstrap.
boot_once <- function(d) {
  rs <- function(z) do.call(rbind, lapply(split(z, list(z$study, z$trt), drop = TRUE),
                                          function(g) g[sample.int(nrow(g), replace = TRUE), ]))
  list(ipd = rs(d$ipd), agd = rs(d$agd))
}

freq_boot <- function(d, n_boot = N_BOOT, tt = seq(0.05, TAU, length.out = 200)) {
  base <- freq_all(d, tt)
  nm <- names(base)
  reps <- lapply(seq_len(n_boot), function(b) {
    r <- try(freq_all(boot_once(d), tt), silent = TRUE)
    if (inherits(r, "try-error")) return(NULL)
    vapply(nm, function(k) r[[k]]$rmst_diff, 0)
  })
  reps <- do.call(rbind, Filter(Negate(is.null), reps))
  ci <- t(apply(reps, 2, quantile, c(0.025, 0.975), na.rm = TRUE))
  list(est = vapply(nm, function(k) base[[k]]$rmst_diff, 0),
       lo = ci[, 1], hi = ci[, 2], n_ok = nrow(reps))
}
```
