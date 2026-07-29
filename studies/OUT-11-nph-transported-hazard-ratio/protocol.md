# Protocol: what a transported hazard ratio summarizes, and how the recommended replacements behave

Registered before any replicate of the reported run. Catalog problem **OUT-11**.

This is the **seventh** version. Six rounds of adversarial pre-run critique preceded it, and each
returned `unsound` or `needs-revision`. Round 1 found a fatal algebraic error in the data-generating
mechanism that the design's own calibration run had missed; it also found **a bug in this study's own
code**. Rounds 2 through 6 returned **3**, **6**, **8**, **5** and **13** fatal findings. Every allegation was
checked against the document or the source before being accepted, and every fatal one held. Section
13 records each finding and its resolution. Nothing has been simulated at any point, so nothing has
been discarded except time.

**In each of the last three rounds the largest single category of fatal finding was a defect
introduced while fixing the round before.** That is why the numbers in this document are no longer
typed: `R/09-export-design.R` writes every quoted value out of the code that computes it, and
`review/verify-protocol.py` asserts the document against that file, currently **346** assertions
including whole tables cell by cell, the arithmetic that connects printed units to printed totals, and the per-cell tables in `results/e1-results.md` and `results/e2-results.md`, which until now were guarded by nothing.
Three separate fatal findings were tables of stale or hand-copied numbers, so a value that only
exists in prose is treated here as a value that has not been checked.

Three things belong at the top, because they constrain how everything below must be read.

**Implementing the version-2 specification showed that the estimator registered as the flexible
ML-NMR arm cannot produce this study's own estimand.** Section 7.1 gives the evidence.

**A reviewer reading the source found that the STC rows never applied their quadrature weights**,
marginalizing over an implied covariate standard deviation of 5.568 against a target of 1.000. That
invalidated the pilot, and with it a bias this protocol had already **registered as an anticipated
mechanism**. A registered prediction resting on wrong code is worse than none, because it would
have been reported as a confirmed prediction.

**Both attempts to make a reimbursement decision the primary outcome failed, and measurement killed
the second.** Under the version-3 rule, a constant recommendation ignoring the data entirely
outperforms every estimator in the benchmark. Estimation quality is now primary and compared paired
on the replicate; decision loss becomes a secondary appendix carrying its own finding. Section 10
gives the table.

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
| **E1** | The censoring dependence of the transported **anchored** hazard ratio, computed exactly by quadrature and root-finding, with each study's censoring regime crossed independently over all four | none |
| **E2** | Finite-sample behavior of that anchored contrast around the E1 limit: whether the limit is what finite samples reach, and whether an analyst at realistic sample sizes can distinguish the regimes | minutes |
| **E3** | The benchmark: seven estimator rows on a common target-population estimand | the whole budget |

**What E1 and E2 compare, stated precisely.** Both evaluate the **anchored indirect** contrast:
a least-false Cox coefficient from an A-versus-placebo study, a second from a separate
B-versus-placebo study, combined by Bucher. Each leg is evaluated **in its own study**, under that
study's own baseline hazard and its own censoring regime, and the two regimes are crossed
independently.

**"In its own study" is not decoration, and getting it wrong was a second error in this same
rework.** A first version of the anchored computation evaluated both legs at the *target* study's
baseline hazard, describing that as "population adjustment assumed perfect". It is stronger than
perfect population adjustment and no method delivers it: MAIC reweights the IPD study's patients and
fits there, STC fits a conditional model there, and both leave the IPD study's baseline hazard in
place. The least-false Cox projection is weighted by risk sets, which the baseline determines, so
leg A converges under the IPD study's baseline and not the target's. Measured, the difference
reaches **2.86%** on the hazard-ratio scale at $\kappa_A = 0.30$ and varies from 2.86% to 1.38%
across the four regimes, which is the same order as the non-transitivity gap round 4 called fatal.
Giving leg A the target baseline **overstated** its own censoring spread, 17.27% against the 16.08%
it actually has.

What *is* idealized is the covariate adjustment: both legs are evaluated at the target covariate
law. That isolates the censoring dependence from covariate-adjustment error, which is what E3
measures separately. The residual baseline transport is not an assumption being made here; it is
part of what the anchored estimator actually faces.

Version 4 evaluated `cox_limit(A, B)` instead, the coefficient a direct head-to-head trial would
report, and defended that choice explicitly. **Round 4 found the defense wrong and it was right.**
Least-false Cox coefficients are not transitive under non-proportional hazards: each leg is a
censoring- and event-weighted average of its own time-varying contrast, with weights set by its own
risk sets, and the difference of two such averages is not the average a direct comparison produces.
Measured on this design, the anchored and direct values differ by 0.93% to 1.78%, and **the gap
itself varies with the censoring**, so the error was not a constant offset that would have cancelled
out of a spread.

Crossing the two regimes independently is not a refinement; it is the case the catalog entry names.
Version 4 could only express a single shared censoring survival, which is the "both trials followed
alike" diagonal. That diagonal is the *least* informative slice: on the $\kappa_A=\kappa_B=0.30$
cell, the plug-in reaches the **correct** recommendation in every matched-follow-up configuration
and the wrong one in 5 of 16 once the two studies' follow-up is allowed to differ, because when both
legs are followed alike their movements largely cancel in the Bucher difference. Version 4's design
could only ever have seen the diagonal and would have reported that cell as flawless.

Round 2's first fatal finding was that four censoring regimes appeared throughout the analysis
sections while the cell matrix and the runtime estimate silently assumed one. That was correct.
The regimes are now assigned to experiments explicitly: **E1 and E2 use all four, crossed
independently; E3 uses three** (`balanced`, `differential` and `differential-reversed`, registered in
`E3_CENS`),
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

1. The contrast does not depend on the study baseline. Worst spread $4.406\times10^{-16}$.
2. $\kappa$ isolates non-proportionality: at $t=t_0$, $g=0$, so the log hazard ratio is
   $\beta_k+\gamma_k x$ whatever $\kappa_k$ is. Worst spread $5.274\times10^{-16}$.
3. The quadrature truth agrees with 2,000,000 simulated draws, both families, within the
   simulation's own Monte Carlo error.

**Who carries which parameter.** Round 2 asked, correctly, which treatment each Greek letter
belongs to. $\kappa_A$ is **zero in most cells and 0.30 in the two `ipd-nph` cells**, for the reason
given below; $\kappa_B$ varies over $\{0, 0.15, 0.30\}$. $\gamma$ is **shared between A and B**,
which is the anchored shared-effect-modifier assumption that MAIC, STC and ML-NMR all require; it
therefore holds by construction here, and this study is about the survival-model dimension rather
than about effect-modifier identification, which is IDN-05's subject.

A consequence worth stating, because it strengthens the study: with $\gamma$ shared, the
conditional B-versus-A contrast is $\beta_B-\beta_A+(\kappa_B-\kappa_A) g(t)$ with **no covariate
term at all**. Any movement of the reported hazard ratio at $\kappa_B=\kappa_A$ is therefore pure
risk-set selection, with zero effect modification of the contrast being reported.

**The covariate is a pure effect modifier, not a prognostic factor**, and version 3 said otherwise.
Checked: placebo survival at $t=12$ is 0.4356 at $x=-2$, $0$ and $+2$, because $\gamma_{\text{PBO}}
= 0$. It modifies each active-versus-placebo contrast and has no effect under placebo. One useful
consequence is that the aggregate study's placebo arm identifies the target baseline cumulative
hazard directly, with no deconvolution, which is what makes the corrected STC transport in
section 7 exact.

**That property is now verified rather than asserted**, over both families, both studies and five
covariate values, and the spread of placebo survival across them is **exactly 0**. Round 6 found the
property claimed in prose across six files while eighteen call sites built the placebo arm with a
nonzero $\gamma$, so every analytic experiment in the study was describing a mechanism the benchmark
does not run. It also found that a verifier for exactly this had been written and never called: it
sat below the `saveRDS` in `R/12-verify-dgm.R` that would have stored it. A check that does not run is
the same defect as a procedure that cannot run, in the one file whose entire purpose is to run checks.

**$\kappa_A$ is a design factor, and in version 3 it was not.** Round 3's second reviewer found that
$\kappa_A = 0$ in every cell put all the non-proportionality on the aggregate side of the network,
which is the side neither MAIC weighting nor STC regression ever touches: both act on the IPD study,
and both consume the same shared aggregate-side fit for B. The MAIC-versus-STC comparison was
therefore never exercised under crossing hazards, which is precisely the comparison the catalog
entry asks for. That was correct and it was not visible to me. Cells with $\kappa_A > 0$ are added,
and because $\gamma$ is shared the contrast still carries no covariate term, so the property that
made the mechanism clean survives the change.

**Network. Two studies.** One contributes individual patient data and compares PBO with A; one
contributes aggregate data, compares PBO with B, and defines the target population. Every one of
all seven estimator rows can use both studies in full, so **the evidence set is identical across methods
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
| $\beta_A$ | $-0.25$ |
| $\kappa_A$ | **design factor**: $0$ in most cells, $0.30$ in the two `ipd-nph` cells |
| $\gamma$ (shared A and B) | 0.30; 0 in the marginal-PH control |
| $\kappa_B$ | 0, 0.15, 0.30 |
| $\beta_B$ | **solved**, see section 10 |

## 4. Estimand

**Target population.** The aggregate study's covariate law, taken as $N(0.60, 1)$. That it is
normal is an **assumption** and is stated as one.

**Target summaries are the aggregate study's PUBLISHED moments, supplied identically to every
method.** Round 2 found a real mismatch in version 2: it named a superpopulation estimand while
saying MAIC targets the realized aggregate sample, and scored both against the same truth. Version
2's answer was to give the frequentist rows the true $(0.60, 1.00)$.

**Round 6 found that answer was never implemented symmetrically, and it is now reversed.** MAIC
matched, and STC marginalized, to `MU_TGT` and `SD_X`; ML-NMR's aggregate likelihood integrated over
the **realized** sample moments that the generator computes from the aggregate patients. So
target-summary sampling error entered the ML-NMR rows alone, and the claim of identical inputs was
false in the direction that flatters the rows the recommended method is compared against. At 200 per
arm the reported mean carries a standard error near 0.071 and the reported standard deviation near
0.050, which is not negligible against the differences this study reports.

The asymmetry is resolved toward the realistic side. An analyst has published moments, not
superpopulation values: MAIC matches to what the paper reports, STC marginalizes through a
quadrature rule built on what the paper reports, and ML-NMR integrates over a distribution fitted to
what the paper reports. Giving three rows the true values was an advantage no analyst has. **The
truth is still evaluated at the true target law**, so all seven rows are scored against the same
estimand and none of them knows it.

Target-summary sampling error is therefore *in* this study, shared equally, rather than excluded
from it. That is a change of scope from version 5 and is recorded as one. MIS-03 remains the entry
that studies this error as its subject; here it is a common nuisance rather than a factor.

**Primary.** Target-population marginal RMST difference between B and A at $\tau = 18$:

$$\Delta_{\text{RMST}}(\tau) = \int_0^\tau \bar S_B(t)\,dt - \int_0^\tau \bar S_A(t)\,dt,
\qquad \bar S_k(t) = \mathbb{E}_{x\sim\text{target}}[S_k(t\mid x)].$$

Both arms are evaluated at the **target study's own baseline** and the target covariate law: that
is what "if both treatments were given in the target population" means, and it is the only reading
under which all seven estimator rows target the same thing. $\tau$ is fixed numerically and is identical
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

**Version 5 registered that sentence and no code applied the functional to anything.** Round 6 found
`cox_limit` called only on analytic arms in E1, E2 and the verifiers, never on a fit, and the
checkpoints retained no curves to apply it to. It is now implemented: `cox_solve` in
`R/02-cox-limit.R` is the shared root-find, `cox_limit` feeds it analytic survival and hazard,
`cox_project` feeds it a **fitted** curve pair with the hazards recovered by differentiating the log
cumulative hazard. Checked against the analytic value on the same mechanism, the projection agrees to
$8\times10^{-5}$ on a 200-point grid and $1\times10^{-5}$ on 2,000.

The regime is **pinned to the balanced condition** for every method and every cell. A least-false Cox
coefficient depends on the censoring that produced it, which is E1's entire subject, so the
functional is prespecified only if the regime is fixed; otherwise the "common summary" would move
with each cell's own follow-up and would not be comparable at all. The five frequentist rows carry a
bootstrap interval for it at no extra fitting cost; the two ML-NMR rows cost one extra prediction per
fit, measured at 0.5 s against a fit of about 440 s.

One implementation detail is recorded because it silently returned `NA` for every ML-NMR row on the
first attempt: a fitted curve is naturally evaluated **on** the administrative cutoff, where the
censoring survival is zero, so both risk sets vanish and the score weight is $0/0$. The analytic
caller never meets this because it stops just short of the cutoff. The solver now contributes zero
where nobody is at risk, which is what the integrand does there anyway.

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
disagreement 0.003083 on the log scale.

This solves **one leg**. The reported quantity is the Bucher difference of two such roots, each
evaluated **in its own study**, under its own baseline hazard and its own censoring:
$\hat\beta_{B/A} = \beta^*_{B/\text{PBO}}(\bar G_2) - \beta^*_{A/\text{PBO}}(\bar G_1)$.

**Spread** below always means $(\max - \min)/\min$ of the anchored **hazard ratio** over the stated
set of regime pairs, in percent, with the truth held exactly fixed throughout.

**Four regimes, crossed independently over the two studies**, giving a $4\times 4$ grid: rate
0.010, 0.050, 0.100 at cutoff 36, and rate 0.020 at cutoff 18. The truth is held exactly fixed
across all sixteen by construction, since censoring touches no survival function.

**The leg decomposition is exact and is the cleanest check in the study.** Each leg's censoring
dependence tracks *its own* non-proportionality and nothing else: leg A's spread is 0.62% in every
cell with $\kappa_A = 0$ whatever $\kappa_B$ does, and 16.08% in both cells with $\kappa_A = 0.30$.
A leg cannot be moved by the other study's parameters, and the computation confirms it rather than
assuming it.

**Reported as a factorial with an interaction term, not as an additive decomposition.** Round 2
was right that the least-false root is nonlinear, so the two pathways to marginal
non-proportionality do not add. The computed table shows it sharply: raising $\gamma$ from 0 to
0.50 adds **3.26 points** of spread at $\kappa_B = 0$ but only **0.49 points** at
$\kappa_B = 0.30$ (17.39% to 17.88%). Under additivity both increments would be 3.26.

The prespecified claims are the two ablations, which are exact:

- $\gamma = 0$ **and** $\kappa_A = \kappa_B = 0$ gives zero movement (computed: $2.6\times10^{-9}$).
- $\gamma > 0$, $\kappa_A = \kappa_B = 0$, covariate spread collapsed to zero gives zero movement
  (computed: $2.1\times10^{-9}$).

The $\kappa_A = 0$ condition is part of both claims and version 5 first stated them without it, which
made them false as written: at $\kappa_A = 0.30$ leg A alone moves 16.08% whatever $\kappa_B$ does,
so "$\kappa_B = 0$ gives zero movement" is only true when the other leg is proportional too.

## 6. E2: finite-sample behavior of the anchored contrast

Round 3 was right that version 3 left this experiment as prose: it named neither its family, nor
its $\beta_B$, nor its $\gamma$, nor its treatment contrast. All of it is now in `R/00-config.R`
alongside E1's grids, which were likewise only function defaults.

Registered: Weibull; $\kappa_A \in \{0, 0.30\}$ crossed with $\kappa_B \in \{0, 0.15, 0.30\}$;
$\gamma = 0.30$; $\beta_B$ solved to the same registered `recommend` margin as E3, so the truth is
the same 0.75 months in every cell; **250 per arm in the A leg and 200 in the B leg**, the
benchmark's own study sizes; **all four censoring regimes, crossed independently**; 2,000
replicates per cell per leg per regime.

Each replicate builds **two independent two-arm studies** and fits one unadjusted Cox model in
each, so the experiment costs `coxph` fits and runs in minutes. The legs are simulated once per
regime and reused across every crossing, which is both cheaper and more faithful: leg A's data
cannot depend on the follow-up of a trial it was not part of. Common random numbers are used across
regimes *within* a leg and never *between* legs, since two independent trials is what an indirect
comparison has and coupling them would manufacture a correlation the Bucher variance assumes away.

Two things are reported, answering different questions.

**Does the E1 limit hold in finite samples?** Over all 96 registered regime pairs the worst
absolute discrepancy between the simulated mean and the analytic limit is **0.0135** on the log
scale, at most 2.84 times its own Monte Carlo standard error, and the Bucher 95% interval covers
the E1 limit **0.941 to 0.959** of the time against a nominal 0.95.

**Both variance estimators are recorded**, because round 5 objected that E2 used the model-based Cox
variance while under non-proportional hazards the ordinary inverse-information variance need not
estimate the sampling variance of the least-false coefficient, so the coverage could be a
variance-estimator artifact. The objection is right in general and does not bite here: the robust
sandwich gives **0.940 to 0.957** against the model-based 0.941 to 0.959, with a mean robust/model
standard-error ratio of **0.9974**. The two agree to a quarter of a percent. E1 is therefore checked, not
merely asserted. This is emphatically *not* evidence that the interval covers the estimand: a Wald
interval around a least-false parameter is correctly centered on that parameter and on nothing
else, which is the whole problem.

**Could an analyst notice?** The regime-induced shift reaches **0.769 sampling standard deviations
of a single reported estimate**, and it is larger with the two trials' follow-up crossed (0.876)
than matched (0.722). Yet two analysts holding independent evidence sets under different follow-up
would call their anchored estimates significantly different only **9.4%** of the time against a
nominal size of 5%. The movement is nearly as large as the noise on any one estimate and the
obvious test for it has almost no power, which is the combination that makes this failure mode
survive review.

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

**A second silent failure, found in round 5, sits in the specification that does work.**
`aux_regression` **cannot be combined with `aux_by`** (documented), and it pools the baseline spline
across studies: the flexible arm's auxiliary parameters are indexed by treatment alone,
`beta_aux[.trtPBO, k]`, `beta_aux[.trtA, k]`, `beta_aux[.trtB, k]`, while the proportional arm's are
indexed by study, `scoef[S1, k]`, `scoef[S2, k]`. Asking for both by writing
`aux_regression = ~ .study + .trt` is **accepted and silently ignored**: it produces the identical 18
treatment-indexed parameters, with no error and no warning.

So in `multinma` 0.9.1 there is no specification giving both non-proportional hazards and
study-specific baselines. That is a finding about the method, in the same class as the `aux_by`
transport failure above, and it is reported as one.

**Whether it damages this study was answered too weakly in version 5, and round 6 was right to say
so.** That version argued: both arms retain study intercepts $\mu_{S1}$, $\mu_{S2}$, so what the
pooling forces is a common baseline *shape*, not a common *level*; this design's two studies differ
only in Weibull scale (12 against 14) or Gompertz level ($1/25$ against $1/30$), and both are **pure
level shifts** on the log-cumulative-hazard scale:

$$\log H^{\text{ipd}}(t) - \log H^{\text{tgt}}(t) = \text{constant in } t.$$

Checked rather than asserted, at every family, $\kappa$, $\gamma$ and covariate value the design
uses (`R/13-verify-pooling.R`): the difference is 0.184981 for Weibull and 0.182322 for Gompertz,
varying over time by at most $2.8\times10^{-14}$. The study intercepts absorb it exactly.

**That argument is sound and it does not support the conclusion drawn from it.** It establishes that
both model classes contain the population truth under this mechanism. It says nothing about whether
their finite-sample likelihoods, parameter sharing or priors behave alike, and the registered
within-row outcomes are RMSE, interval coverage and finite-sample bias, none of which follow from
identifiability. Version 5 concluded that "the pooled spline is not misspecified here and the primary
within-row ML-NMR contrast does isolate proportionality"; the first clause is established and the
second does not follow from it.

**The right response is a third arm, not a better argument**, and the software will not supply one.
What is needed is a *proportional* fit whose baseline is pooled the way the flexible arm's is, so that
`pooled-PH` against `flexible` varies proportionality alone and `pooled-PH` against `MLNMR-PH`
prices the pooling by itself. `R/18-probe-pooled-ph.R` tries the two specifications that could express
it and both are rejected by `multinma` 0.9.1 at the Stan level, before sampling:

| candidate | outcome |
|---|---|
| `aux_regression = ~ 1` | `prior_aux_location` dimension mismatch, declared $(2,6)$ against found $(1,6)$ |
| `aux_by = c(.pool)` on a constant column | `aux_id` dimension mismatch, declared 900 against found 13,300 |

Both **return from `nma()` normally**, printing the Stan exception and yielding an object with no
draws and no auxiliary parameters, so a `try()` around the call catches nothing. The first version of
that probe was fooled by exactly this and reported a rejected specification as an available one, which
is the same silent-acceptance failure the probe was written to detect.

**So the confound is declared, and the within-row ML-NMR claim is downgraded accordingly.** The
contrast `MLNMR-PH` against `MLNMR-flex` changes the baseline parameterization from study-indexed to
treatment-indexed-and-pooled at the same time as it changes proportionality, and no specification in
`multinma` 0.9.1 separates them. **Any difference in RMSE, coverage or finite-sample bias within the
ML-NMR row is therefore attributable to the two jointly and not to proportionality alone**, and it is
reported that way throughout. What the level-shift result does license is narrower and is kept: the
pooling introduces no *asymptotic* misspecification under this mechanism, so a difference that
persists as sample size grows is not an artifact of the pooled baseline being unable to represent the
truth. The five frequentist rows carry no such confound, and the flexible-versus-proportional
comparison within *those* rows changes the spline specification alone; the paper leans on them for the
proportionality claim and reports the ML-NMR row's within-row difference as a joint effect.

**The limitation is also stated for the case this design does not reach**: a mechanism whose two
studies differ in baseline *shape*, not merely level, would activate the asymptotic half of the
software limitation too. Both halves are in section 12.

**A separate check of the same arm answered the question it was asked, and exposed a defect in this
study rather than in the software.** Round 5 asked whether `predict(baseline = "S2", aux = "S2")`
anchors correctly when the auxiliary parameters carry no study index and treatment A is observed
only in study S1. The worry was aliasing: a treatment-specific spline could absorb its own study's
baseline, so a "target-standardized" curve would be standardized to the target covariate law while
anchored on the wrong baseline, and a near-truth B minus A could then arise from two offsetting
errors rather than from correct transport. The check is direct, because only a per-treatment
comparison can separate those: predict every treatment's target RMST and compare each against its
own known truth (`R/14-verify-anchoring.R`).

**Version 5 and the first version of this section reported a large absolute-scale bias here, and it
was an artifact of the placebo defect described in section 3.** The truth used for the placebo arm
was 9.596 months, computed with a prognostic placebo; the registered mechanism gives 10.516.
That produced a reported placebo error of $+1.028$ months at 3.6 Monte Carlo standard errors, then
a large-sample diagnostic at four times the arm sizes reporting $+0.751$ at 10.1, a two-part decay
fit and a planned sixteen-times run to decide whether it was structural. None of that exists.
Coincidentally the wrong figure was almost exactly the **IPD study's own** placebo RMST, 9.596, which is
the value a wrongly anchored prediction would drift toward; that is why the artifact looked so much
like the aliasing it was supposed to test for, and why "the drift is away from the anchor" read as
evidence when it was an accident of arithmetic.

Measured against the registered truth, in the hardest cell ($\kappa_A = \kappa_B = 0.30$), with
$\text{PBO} = 10.516$, $A = 11.997$, $B = 12.747$:

| | arms per study | reps | placebo error | MCSE | A error | B error | contrast error | MCSE |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 256 points, 1x | 250 / 200 | 4 | $+0.109$ | 0.286 | $+0.122$ | $+0.035$ | $-0.087$ | 0.577 |
| 64 points, 1x | 250 / 200 | 5 | $+0.194$ | 0.240 | $+0.174$ | $-0.036$ | $-0.209$ | 0.451 |
| 64 points, 4x | 1000 / 800 | 5 | $-0.169$ | 0.074 | $-0.164$ | $-0.092$ | $+0.072$ | 0.176 |

**The answer to round 5's question is that the arm anchors correctly.** Every treatment's error is a
fraction of a month and the three move together within a configuration, which is a small common
shift and not the offsetting pair the aliasing hypothesis required. The predictions sit near the
target truth of 10.516 and nowhere near the IPD study's 9.596. The contrast error is consistent with
zero at both arm sizes, as the cancellation argument predicts, and it is now consistent with zero
for the honest reason rather than because two large errors happened to subtract.

**No absolute-scale claim about the flexible ML-NMR arm is made anywhere in this protocol** even so.
The registered estimand is a difference, these levels are measured at five replicates in one cell,
and a level accurate to two tenths of a month there is not a licence to report levels generally.

**The proportional arm was checked the same way and passes.** `aux_by = .study` returns all three
treatments in the target population at sane values, PBO 11.25, A 11.47 and B 11.35, with
$\hat R = 1.008$ and minimum ESS 456. On that check replicate, at $\kappa_B = 0.30$, it estimates
$\Delta_{\text{RMST}} = -0.12$ against a truth of $+0.75$, an error comparable to the
proportional MAIC rows. The ML-NMR row is not privileged by this design: its proportional variant
fails under non-proportionality exactly as the other proportional variants do, which is what makes
the column contrast worth reporting.

### 7.2 The seven estimator rows

Round 2 was right that version 2's PH-versus-flexible columns changed likelihood and baseline
representation as well as proportionality, so the column effect was uninterpretable outside
ML-NMR. Within each row, the likelihood, basis and evidence set are now identical and **only the
treatment-by-time terms are toggled**.

| | proportional | flexible |
|---|---|---|
| **weighting** | MAIC weights, weighted Royston-Parmar, treatment as a scalar log-HR | MAIC weights, weighted Royston-Parmar, treatment-specific spline coefficients |
| **outcome regression** | STC, Royston-Parmar, treatment as a scalar log-HR, marginalized over the target law | STC, Royston-Parmar, treatment-specific spline coefficients, marginalized |
| **ML-NMR** | `mspline`, `aux_by = .study` | `mspline`, `aux_regression = ~ .trt` |

Attributions, since round 2 was right that "by its own authors' recommendation" is unauditable
without them. Round 3 then showed that CrossRef resolution is not enough: version 3 cited
doi:10.2165/11538370-000000000-00000 for MAIC, which resolves with matching author, year and title
but is the **psoriasis application** paper, not the methods paper. A DOI that resolves is not a DOI
that supports the claim. Corrected: MAIC methods, Signorovitch et al. 2012, *Value in Health*
(doi:10.1016/j.jval.2012.05.004), with the 2010 application paper
(doi:10.2165/11538370-000000000-00000) cited alongside where the applied practice is meant; STC, Ishak et al. 2015 (doi:10.1007/s40273-015-0271-1);
ML-NMR, Phillippo et al. 2020 (doi:10.1111/rssa.12579); the anchored indirect contrast, Bucher et
al. 1997 (doi:10.1016/S0895-4356(97)00049-8); the flexible parametric basis, Royston and Parmar
2002 (doi:10.1002/sim.1203); the proportional-hazards test used for calibration, Grambsch and
Therneau 1994 (doi:10.1093/biomet/81.3.515).

**Each method gets the strongest valid transport its own structure supports**, which is not the same
rule for all of them. Version 3 forced every frequentist row through one marginal
log-cumulative-hazard graft, and round 3 was right that this is invalid under the registered DGM and
that it handicapped STC before sampling began. Marginalization is nonlinear, so a ratio of
**marginal** cumulative hazards formed under the IPD study's baseline does not transport to a
different baseline; the registered $\gamma = 0.30$ with Weibull scales 12 against 14 activates the
error by construction.

**MAIC keeps the graft**, $\log H^{\text{tgt}}_A(t) = \log H^{\text{agd}}_{\text{PBO}}(t) +
[\log H^{\text{ipd}}_A(t) - \log H^{\text{ipd}}_{\text{PBO}}(t)]$, because a reweighted marginal
analysis is what MAIC produces and it has no conditional model to transport instead.

**Round 4 objected that this cannot support a method-family comparison**: scoring MAIC through a
transport the protocol itself calls invalid, while STC gets a valid one, could be measuring MAIC's
structural inability to deliver an *absolute* estimand rather than weighting against regression.
The objection is legitimate and it is answered by measurement rather than by caveat, because the
structural error is **exactly computable with no simulation** (`R/05b-graft-error.R`).

Give MAIC perfect weighting and perfect estimation so that only the graft remains. Under this
mechanism, matching the mean and variance of a normal covariate recovers the target law exactly, so
perfect weighting is attainable in the limit and the remainder is the graft alone:

| structural error in $\Delta_{\text{RMST}}(18)$, months | $\gamma = 0$ | $\gamma = 0.30$ |
|---|---:|---:|
| MAIC marginal graft, Weibull, $\kappa_A = 0$ | $0$ | $-0.0302$ |
| MAIC marginal graft, Weibull, $\kappa_A = 0.30$ | $0$ | $-0.0235$ |
| MAIC marginal graft, Gompertz, worst cell | $1.8\times10^{-15}$ | $-0.0187$ |
| STC conditional transport, every cell | $<2\times10^{-15}$ | $<2\times10^{-15}$ |

**The graft costs MAIC at most 0.0302 months.** It is exactly zero when $\gamma = 0$, confirming
that the covariate effect is its only driver. The grid is complete for the quantity: the graft
transports treatment **A**, whose curve depends on the family, $\kappa_A$ and $\gamma$ and not on
$\kappa_B$, and all eight combinations of those are computed. STC's conditional transport is exact to machine
precision in every cell, which the protocol previously asserted and now checks.

**Round 5 was right that version 5 then compared that number against the wrong thing.** Setting
0.0116 beside MAIC-PH's 0.725-month pilot bias makes it look negligible, 62 times smaller, which
version 5 rounded up to "two orders of magnitude" and should not have. More importantly, MAIC-PH is
not the contrast the graft could contaminate. The contrast at risk is between the **flexible** rows,
and in the pilot `MAIC-flex` and `STC-flex` differ by about **0.003 months**, which the graft exceeds
several times over.

Stated honestly: the graft is negligible against the decision threshold and against the proportional
rows' biases, and it is **not** negligible against the difference between the two flexible
frequentist rows. **Any conclusion ranking `MAIC-flex` against `STC-flex` on a difference smaller
than 0.0116 months is withdrawn in advance**, and that pair is always reported with the graft error
printed beside it. What the graft cannot explain is a difference of the size the proportional rows
show.

The across-row contrasts remain **descriptive** for the separate and unrelated reason given in
section 10.1, that the matched-flexibility premise was withdrawn in round 2.

**The ML-NMR within-row contrast carries its own version of this problem, and it was found by
extending a probe no reviewer asked about.** Every integration probe before version 6 fitted only
the flexible arm, so it measured the quadrature error of one estimator and could say nothing about
the contrast the study registers, which is flexible against proportional **within** the ML-NMR row.
Fitting both arms at 256 and 512 points on the same replicates measures it directly. Eight paired
replicates were registered as the target; at five and six the two errors appeared to move in
opposite directions, which would mean they add in that difference rather than cancelling, and at
eight they do not:

| arm | replicates | $\hat\Delta_{512} - \hat\Delta_{256}$, months | MCSE | $t$ |
|---|---:|---:|---:|---:|
| ML-NMR flexible | 8 | $+0.0179$ | 0.0153 | $+1.17$ |
| ML-NMR proportional | 8 | $-0.0007$ | 0.0093 | $-0.07$ |
| **difference, paired** | 8 | $+0.0186$ | 0.0135 | $+1.38$ |

**At the full eight paired replicates, none of the three is distinguishable from zero**, and that is
the honest result. The differential ran $t = 2.14$ at five replicates, $2.64$ at six, $2.50$ at
seven and **1.38** at eight. The registered target was eight from the start, and reaching it is what
showed the effect was not there; stopping at six, where it looked established, would have put a
significant arm-differential quadrature error into a pre-registration on the strength of a run that
had not finished.

What survives is a **bound**, which is what this measurement was for. The 95% upper limit on the
differential is **0.045 months**. Registered on the same principle as the graft bound above: **any
conclusion ranking `MLNMR-flex` against `MLNMR-PH` on a difference smaller than 0.045 months is
withdrawn in advance**, and the ML-NMR within-row contrast is always reported with this figure
printed beside it. It is 9% of the 0.50-month decision threshold, so it does not touch any
decision-scale claim.

The opposite-sign reading that earlier versions of this section built on is withdrawn. At eight
replicates the flexible arm sits at $+0.0179$ and the proportional arm at $-0.0007$, which is
consistent with the two arms having the same quadrature error, or none. Extending the probe to the
proportional arm was still worth doing: it is what turned an unmeasured assumption that the errors
cancel into a measured bound on how much they might not.

**STC transports the conditional model and marginalizes last.** It fits the conditional outcome
model on the IPD, reads off the placebo covariate effect and the conditional treatment effect,
solves for the target baseline $c(t)$ such that the implied marginal placebo curve matches the
aggregate study's observed one, builds the target conditional curve for A, and integrates over the
target law once, at the end. The code does not assume the placebo covariate effect is zero even
though it is here, so the estimator stays correct if that changes.

B's curve comes from the aggregate study directly, and the aggregate-side model is fitted once per
replicate and shared across rows, which is the identical-evidence clause made operational rather
than asserted.

**The target law is a weighted quadrature rule, and a guard enforces it.** Round 3 found that
version 3's STC stored Gauss-Hermite weights and never used them, taking a plain mean over the
abscissas. Equal weighting of 32 Gauss-Hermite nodes spans $-9.48$ to $+10.68$ and implies a
covariate standard deviation of **5.568** against a target of 1.000; on a test survival probability
it returns 0.4609 where correct weighting and a 4,000,000-draw Monte Carlo both give 0.4753. Every
STC number in the version-3 pilot was integrating over the wrong distribution, including a bias that
had been registered as an anticipated mechanism and was an artifact. Nodes and weights now live in
one object, one function performs every marginalization, and `verify_quad()` asserts the rule
reproduces the target mean and standard deviation before any estimator runs.

**What the aggregate study makes observable, enforced structurally.** Round 3 found that version 3
fitted `flexsurvspline` directly to the aggregate study's individual records and bootstrapped
individuals from it, which evaluates a two-IPD analysis rather than an indirect comparison.
Reconstructed pseudo-individual event times are legitimately observable, since Kaplan-Meier curves
are published and digitization is declared exact and out of scope in section 12. Individual
**covariate** values are not: a published trial reports means and standard deviations. The
generator therefore computes the covariate summaries once and then **deletes the column**, so an
estimator reaching for an aggregate individual covariate fails loudly instead of quietly using
information it could not have. The aggregate data frame carries `study`, `trt`, `time` and `status`
and nothing else.

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
bases, and the comparison is interpreted only to the extent that arm supports it. The knot count is
`N_KNOTS` in `R/00-config.R` and reaches both bases from there, so "for both bases" is enforced by
construction; until round 6 it was hardcoded separately in each and the arm could not have run at all.

**The effective degrees of freedom of each fitted survival model is recorded per replicate**, so the
paper reports how far apart the flexibilities actually were rather than assuming they matched.
Round 6 found no run pass returning it, with both fit objects discarded, so the diagnostic that this
whole descriptive comparison depends on would not have existed. It is now taken while the fit is in
scope: $p_{\text{WAIC}}$, the summed posterior variance of the log-likelihood contributions, for the
two ML-NMR rows, and the exact free-parameter count for the maximum-likelihood Royston-Parmar rows. A
raw coefficient count would not do for the Bayesian rows, because the M-spline coefficients are
simplex-constrained and shrunk by their prior, so counting them overstates the flexible fit's real
freedom by exactly the amount this arm is trying to measure.

**Marginalized STC**, not the mean-profile plug-in, which returns a conditional quantity at an
average covariate profile.

**Uncertainty.** Nonparametric bootstrap over the full pipeline, resampling individuals within arm
within study and re-running weight estimation, model fitting and re-standardization, 500 resamples,
percentile intervals, for all four frequentist rows and the seventh row. Posterior draws for both
ML-NMR rows. The inner Monte Carlo error of a 500-resample percentile interval is reported rather
than assumed negligible.

**How that inner error is obtained, because round 6 found it unreconstructible.** `freq_boot` kept
only the two endpoints and the count of successful resamples; the resample draws, the one object the
endpoint error can be recovered from, were discarded on the next line. Both endpoints now carry a
standard error estimated by redrawing the stored resample values `N_MCSE_REP = 200` times and taking
the standard deviation of the recomputed percentile, for every quantity the bootstrap produces:
$\Delta_{\text{RMST}}$, the three survival differences and the Cox projection. This costs no model
fitting at all, since the expensive part of a bootstrap is producing the 500 statistics and quantiles
of a length-500 vector are free. The asymptotic alternative,
$\sqrt{p(1-p)/B}\,/\,f(q_p)$, needs a density estimate at the endpoint, which is the least stable
place in the distribution to put one. This is Monte Carlo error **conditional on the data**: how much
the interval would move under a different resampling seed. It is not the sampling variability of the
interval across replicates, which the run measures directly by having 40 of them.

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

Two corrections, one of which was itself corrected. Version 2 moved to **four chains** on the
reasoning that chains run in parallel so four cost the same wall clock as two. **Round 3 asked
whether that had been measured, and measuring it showed it was false**: 166.9 s against 74.1 s per
fit, because four chains oversubscribe four performance cores. Four chains were also chosen to
satisfy an ESS floor applied to the global minimum over every monitored parameter, which is the
diagnostic the second correction rejects. **Two chains of 1,000 iterations are registered**
($N_{\text{chains}} = 2$ in `R/00-config.R`) and the derived estimand reaches ESS above 2,000 at
that setting, so nothing the study uses is short of draws.

The second correction stands: the ESS criterion binds on the **derived estimand**, the
target-standardized $\Delta_{\text{RMST}}(18)$ and the survival differences on the time grid, which
is what the study actually uses; the global minimum across all internal spline coefficients is
recorded for every fit and reported, but is not a pass criterion, because a weakly identified
nuisance coefficient failing to mix does not invalidate a well-mixed estimand.

Registered thresholds: $\hat R < 1.01$ and bulk and tail ESS $\geq 400$ on the derived estimand,
zero divergent transitions, no transition at maximum treedepth. A fit failing any criterion is
refit once at doubled iterations with `adapt_delta = 0.99`; a fit failing twice is **recorded as a
failure, not silently dropped**, and the primary analysis is repeated on the subset where every fit
met every criterion.

**The tail criterion above was registered from version 1 and had never been evaluated.**
`target_rmst_diff` computed bulk ESS, Monte Carlo error and $\hat R$ on the derived estimand but not
tail ESS, and the run assembled its diagnostic record with `ess_tail` set to the bulk value, so the
pass rule tested one statistic twice. It binds on precisely the output that depends on it: the
interval this study reports is the 2.5% and 97.5% quantile of that posterior vector, and coverage of
that interval is a registered outcome, so tail mixing is what decides whether the outcome means
anything. Tail ESS is now computed and the pass rule **stops** if any of its five inputs is missing
or non-finite, because a threshold whose input is absent passes everything, which is how this
survived five rounds of review.

**Round 6 found the policy was applied to RMST alone, although it is registered on the survival
differences as well, and that is now fixed.** `target_surv_diff` returns no diagnostics in version 5,
so a fit whose survival prediction mixed badly, or failed outright and was stored as `NULL`, still
passed on the strength of its RMST. The prediction now carries $\hat R$, bulk ESS and tail ESS per **registered time**, the pass rule requires all three thresholds at every time, and a fit whose
survival prediction is missing or non-finite **fails**. Since the pointwise intervals this study
reports at $t \in \{6, 12, 18\}$ come from exactly those draws, a policy that did not look at them
was not guarding the output it exists to guard.

**A related time-grid defect is fixed in the frequentist rows.** They evaluated the survival
difference at the nearest point of a 200-point grid, so values labeled $t = 6$ and $t = 12$ were
taken at 6.0033 and 11.9565 and then compared against truths at exactly 6 and 12. That folds up to
0.0435 months of grid error into the reported calibration bias. The curves are now interpolated at
the registered times.

**The pipeline is executed end to end before the run, not only read.** `R/15-smoke.R` runs both
passes and the analysis layer on the design's hardest cell at one replicate, at sample sizes,
integration order and iteration count far below the registered ones, and asserts structure rather
than values: that all five frequentist rows and both ML-NMR rows return finite ordered intervals,
that the bootstrap keeps its resamples, that every sampler criterion is a finite number, that tail
ESS is **not** identical to bulk ESS, and that all seven estimators arrive in the analysis with no
column entirely missing. It produces no reportable number. Two registered procedures have now failed
in a way reading did not catch, the refit escalation in round 5 and the tail criterion here, and both
were in code that had been reviewed repeatedly; the difference is that reading checks what the code
says and running checks what it does.

**Integration order is measured, not cited.** Version 2 cited IDN-05's finding that moving from 64
to 256 integration points flipped 8.3% of its verdicts and then chose 32, which is *below* the
order IDN-05 found insufficient; IDN-05 also recorded that 256 was not itself shown to be
converged, so it is not an accuracy reference either. Round 2 caught the citation and it was
right. The order is instead measured on this study's own network by `R/probe-integration.R`,
comparing the target-standardized RMST difference at 32, 64, 128 and 256 points, and the selected
order is registered in section 14 before the run.

## 8. E3: the cell matrix

Registered by `build_cells()` in `R/04-calibrate.R`. Ten distinct parameter cells crossed with the
registered censoring conditions give **21 cell-by-censoring conditions**, at 40 replicates each, for
**840 replicates**. This table is checked against the code's own export by
`review/verify-protocol.py`, which caught it stale when $\kappa_A$ was added.

| arm | family | $\kappa_A$ | $\kappa_B$ | $\gamma$ | true $\Delta_{\text{RMST}}(18)$ | $\beta_B$ | censoring |
|---|---|---:|---:|---:|---:|---:|---|
| primary | Weibull | 0.00 | 0.00 | 0.30 | 0.75 | $-0.4140$ | balanced, differential, reversed |
| primary | Weibull | 0.00 | 0.15 | 0.30 | 0.75 | $-0.2706$ | balanced, differential, reversed |
| primary | Weibull | 0.00 | 0.30 | 0.30 | 0.75 | $-0.1431$ | balanced, differential, reversed |
| margin | Weibull | 0.00 | 0.00 | 0.30 | 0.35 | $-0.3255$ | balanced |
| margin | Weibull | 0.00 | 0.30 | 0.30 | 0.35 | $-0.0505$ | balanced |
| control | Weibull | 0.00 | 0.00 | 0.00 | 0.75 | $-0.4223$ | balanced, differential |
| **ipd-nph** | Weibull | **0.30** | 0.00 | 0.30 | 0.75 | $-0.6984$ | balanced, differential, reversed |
| **ipd-nph** | Weibull | **0.30** | 0.30 | 0.30 | 0.75 | $-0.4383$ | balanced, differential, reversed |
| family | Gompertz | 0.00 | 0.00 | 0.30 | 0.75 | $-0.4450$ | balanced |
| family | Gompertz | 0.00 | 0.30 | 0.30 | 0.75 | $-0.3110$ | balanced |

**The two `ipd-nph` cells are new in version 4 and exist because round 3 found the benchmark was
not testing what it claimed.** With $\kappa_A$ fixed at zero, the IPD-side A-versus-PBO contrast,
the only contrast MAIC weighting or STC regression ever touches, was exactly proportional in every
cell, while all the time-variation sat in an aggregate-side fit both rows share. Their registered
properties:

Their properties are in the single cell-properties table later in this section, together with
every other cell, rather than in a second table of their own. Version 5 kept two PH tables and
updated only one of them, which is how a withdrawn statistic stayed in print.

**The Grambsch-Therneau rejection rates are per leg, at each leg's own sample size, and round 5 was
right that version 5's were not.** Version 5 computed them on a direct B-versus-A trial at 400 per
arm. No such trial exists in this network: an analyst holds A-versus-placebo at 250 per arm and
B-versus-placebo at 200, and would run the diagnostic on each separately.

The distinction reverses the reading of the last row. Version 5 reported a rejection rate of 0.040
there, essentially nominal, and concluded the cell was undetectable. That is an artifact of testing
a contrast which, at $\kappa_A = \kappa_B$, is exactly proportional by construction. **Both legs are
strongly non-proportional and both tests fire**, at 0.810 and 0.678. So the honest statement about
that cell is not that the problem is invisible; it is that an analyst who checks only the combined
contrast sees nothing, while the diagnostic that would have caught it is the one applied to each leg
before combining. That is a more useful finding than the one it replaces, and it is actionable.

The second is the more interesting of the two and version 3 could not express it at all: with
$\kappa_A = \kappa_B$ the **target contrast is proportional while both arms are strongly
non-proportional**. A method that reacts to arm-level rather than contrast-level non-proportionality
will be penalized here and should not be, which is a distinction no other cell in the design can
draw. Version 5 supported this with a rejection rate of 0.040 on the B-versus-A contrast; that
statistic is withdrawn, because no such trial exists in this network, and it is **not** replaced by
the per-leg rates, which are 0.810 and 0.678 and describe the arms rather than the contrast. The
point stands on the construction itself, which makes the contrast exactly proportional at
$\kappa_A = \kappa_B$, and needs no test to establish.

Censoring in E3 is **between-study differential follow-up**, which is what "differential censoring"
means in the OUT-11 entry: balanced is rate 0.010 in both studies, differential is 0.020 in the IPD
study against 0.100 in the aggregate study, cutoff 36 in both. Arm-differential censoring within a
comparison is declared out of scope in section 12.

**$\beta_B$ is solved, not chosen**, so that the true target RMST difference lands on a registered
margin relative to the decision threshold. Section 10 explains why that is the difference between a
decision rule that can fire and one that cannot.

**Registered properties of every cell**, computed by `cell_properties()` before the run, at 200 per
arm with a Grambsch-Therneau test at the 0.05 level:

Every row is computed from the registered design by `R/16-ph-power.R` and `R/09-export-design.R`.
Version 5's table came from a saved file that **nothing regenerated**, and it still carried the
direct-trial rejection rate that round 5 withdrew; the per-leg replacement had reached the table
above and not this one. The rejection rates are now measured at **2,000** replicates, worst standard
error **0.0112**, which supports the two decimals printed and no more. At the 200 replicates version
5 used, a rate near 0.65 carried a standard error of 0.034, so its third decimal was noise.

| family | $\kappa_A$ | $\kappa_B$ | cond. cross | marg. cross | marginal HR range | at risk at 18, A / B | PH rejects, leg A | leg B |
|---|---:|---:|---:|---:|---|---:|---:|---:|
| Weibull | 0.00 | 0.00 | none | none | 0.849 to 0.873 | 0.240 / 0.288 | 0.103 | 0.083 |
| Weibull | 0.00 | 0.15 | 13.8 | 13 | 0.548 to 1.149 | 0.240 / 0.263 | 0.083 | 0.125 |
| Weibull | 0.00 | 0.30 | 8.4 | 8 | 0.349 to 1.484 | 0.240 / 0.239 | 0.096 | **0.457** |
| Weibull (margin) | 0.00 | 0.00 | none | none | 0.927 to 0.940 | 0.240 / 0.262 | 0.086 | 0.082 |
| Weibull (margin) | 0.00 | 0.30 | 6.2 | 6 | 0.382 to 1.596 | 0.240 / 0.213 | 0.092 | **0.471** |
| Weibull (control) | 0.00 | 0.00 | none | none | **0.842 to 0.842** | 0.291 / 0.344 | 0.048 | 0.050 |
| Weibull (ipd-nph) | 0.30 | 0.00 | 2.7 | 2 | 0.503 to 2.039 | 0.269 / 0.371 | **0.588** | 0.068 |
| Weibull (ipd-nph) | 0.30 | 0.30 | none | none | 0.828 to 0.858 | 0.269 / 0.325 | **0.561** | **0.444** |
| Gompertz | 0.00 | 0.00 | none | none | 0.823 to 0.852 | 0.336 / 0.393 | 0.092 | 0.080 |
| Gompertz | 0.00 | 0.30 | 14.4 | 14 | 0.701 to 1.629 | 0.336 / 0.364 | 0.088 | **0.312** |

Every null cell sits at nominal size, 0.048 to 0.059 against 0.05, which is what says the test is
being applied correctly rather than merely producing large numbers where non-proportionality was put
in.

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
at 13.8, 8.4, 6.2 and 14.4 months, all well inside the 36-month cutoff and **all before** the
18-month horizon. Version 5 said they bracketed it, which none of them does. That they fall before
$\tau$ is what matters and is the stronger statement: the reversal is complete inside the window the
estimand integrates over, so it is fully expressed in $\Delta_{\text{RMST}}(18)$ rather than
partly beyond it.

**The retained levels are the ones an analyst misses.** On the aggregate study's own leg, which is
where $\kappa_B$ acts, the proportional-hazards test rejects at 0.050 to 0.057 in the proportional
cells, which calibrates the test rather than the design; at **0.281** for $\kappa_B=0.15$; and at
**0.525 to 0.694** for $\kappa_B=0.30$. So an analyst misses the mild violation **72%** of the time
and the strong one **31% to 48%** of the time. Nothing retained is a violation so large that no
competent analyst could overlook it.

These are the per-leg rates at 2,000 replicates. Version 5's figures here, 0.215 and 0.53 to 0.64,
were the withdrawn direct-trial statistic at 200 replicates and are superseded.

## 9. Monte Carlo error, and what cannot be resolved

**21 cell-by-censoring conditions at 40 replicates is 840 replicates per estimator.** The standard
error of a pooled coverage estimate near 0.95 is then **0.0075**. Restricted to the nine
`primary` conditions it is 360 replicates and **0.0115**.

Version 5 printed 14 conditions, 560 replicates and 0.009 here, and "six primary cells", after the
matrix had been frozen at 21. Round 5 raised that and it was corrected in the operating-
characteristic table below but not in this paragraph, so two condition counts stayed live in one
document. That is not a cosmetic mismatch: with both counts present, the coverage pool is
selectable after the results are seen, and the calibrated-inconclusive-miscalibrated verdict follows
the pool. **The registered pool is all 21 conditions.** The nine-condition `primary` restriction is
reported alongside it and is never substituted for it. No other subset is defined and none may be
introduced after the run.

**Those figures assume independent sampling and the run does not have it.** The round-6 common-
random-numbers fix makes the three censoring conditions of a parameter cell one latent network
censored three ways, which is what makes the censoring comparison paired. It also means the 840 rows
are **400 (parameter cell, replicate) blocks**, not 840 independent observations. Every standard
error printed in this section, and the operating-characteristic table below, is the
independent-sampling value; **the registered interval is the cluster-robust one**, computed over
`param_id` by `cluster_se` in `R/08-analyze.R` and reported beside the independent figure with their
ratio, so the size of the correction is visible rather than assumed.

The direction is deliberately not assumed. Positive within-block correlation inflates the true
variance and makes the naive interval too narrow; the pairing that the same seeding buys makes some
contrasts more precise, not less. Which dominates is a property of the run and is measured by it.
The independent-sampling arithmetic is retained here as the reference point it was computed as, and
is **not** the quantity any verdict is read from.

That resolution is sufficient to certify a calibrated estimator but not to detect mild
miscalibration. Rather than assert otherwise, the decision rule uses a Monte Carlo confidence
interval, has an explicit **inconclusive** outcome, and section 10.3 tabulates the probability of
each verdict under both a calibrated and a miscalibrated truth.

Per-cell coverage at 40 replicates has a standard error of 0.034 and is **descriptive only**.
IDN-05 published a maximum over eight noisy cell estimates as if it were a bound, and a reviewer
was right that it was not; that mistake is not repeated.

Bias in $\Delta_{\text{RMST}}$: a 60-replicate pilot on six cells gives a per-replicate standard
deviation between 0.62 and 0.87 months depending on estimator and cell, so **0.75 is the registered
planning value** and the pooled bias over the nine `primary` conditions has a standard error near
**0.040** months. Version 5 said "six primary cells" here, a grouping that does not exist in the
frozen 21-condition matrix; the `primary` arm is nine conditions, being three $\kappa_B$ levels
crossed with three censoring regimes. Version 2 asserted 0.35 without having measured it, which is less than half the truth and
would have understated every reported uncertainty; the number is now measured and the pilot is
kept in `results/freq-pilot.rds`.

**Estimator comparisons are paired on the replicate**, since all seven are computed on the same
simulated network, and reported with paired intervals. Common random numbers are used across
censoring regimes within a cell.

**That last sentence was false until round 6, and the fix is checked rather than asserted.** The
network seed was keyed on `cell_id`, which runs over all 21 cell-by-censoring rows, so the three
censoring variants of one parameter cell were three independent networks with different covariates
and different event times. The censoring comparison therefore carried the variance of two
independent draws where the design assumes one network censored two ways, and E1 puts the effect
being compared at a fraction of a month, which is exactly the scale pairing exists to resolve. The
seed is now keyed on `param_id`, the parameter cell. This works because `sim_arm` draws event times
**before** censoring times and `rexp` consumes the same stream whatever its rate, so no branch
skips a draw; all three registered regimes have a positive rate, so none takes the `Inf` shortcut.
Measured on the $\kappa_B = 0.30$ primary cell: the covariate vectors are identical across the
three regimes, the uncensored event times agree wherever two regimes both observe them, and the
event counts differ, at 435, 387 and 201. Identical inputs, different censoring, which is what
common random numbers means.

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

**That table is the six-cell pilot mixture, and round 5 was right that the constant-rule result does
not carry to the frozen design.** The registered matrix has **19 recommend conditions against 2
decline**, so under uniform weights an always-recommend rule scores 0.0143 and is nearly free by
construction. The comparison would then be measuring the scenario distribution, which is a design
choice, rather than the estimators.

The appendix is therefore reported under **two weightings**: uniform over the registered conditions,
and **balanced**, giving the recommend and decline groups equal total weight so no constant rule can
win on mixture alone. Under balanced weights the constant baselines score 0.0750 and 0.1250. Only a
finding that survives both weightings is reported as one.

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

1. **Bias** in $\Delta_{\text{RMST}}(18)$: deployment-weighted mean absolute cell bias, reported
   **both raw and corrected for its own Monte Carlo floor**. Absolute and per-cell, because round 2
   was right that a pooled signed bias lets cells cancel.

   Round 5 found that the uncorrected statistic is badly biased upward, and it was right. A cell
   mean over 40 replicates at the registered per-replicate SD of 0.75 has a standard error of 0.119
   months, so the expected absolute value of a cell mean whose **true bias is exactly zero** is
   $0.75\sqrt{2/\pi}/\sqrt{40} = 0.095$ months. That floor exceeds the entire measured bias of the
   flexible rows in the pilot (0.043 to 0.046). Taking absolute values before averaging converts
   noise into apparent bias and would rank estimators partly on their variance, which is the same
   defect, one level up, that killed version 3's decision rule.

   Version 5 corrected it with $\sqrt{\max(0, \hat b^2 - \mathrm{se}^2)}$. **Round 6 found that
   this does not remove the floor and the objection is exactly right.** Subtracting
   $\mathrm{se}^2$ debiases $\hat b^2$, but the square root is concave, so the result keeps a
   positive expectation when the true bias is zero. Simulated at 4,000,000 draws under this
   protocol's own planning model, that expectation is **0.3431 se** against the 0.3426 the reviewer
   derived, which at $\mathrm{se} = 0.75/\sqrt{40}$ leaves **0.0407 months**. The flexible rows'
   pilot biases are 0.043 to 0.046. The "corrected" statistic was still about the size of the
   effects it existed to resolve, and would still have ranked estimators partly by variance.

   **The registered statistic is therefore on the squared scale, where the correction is exact.**
   $\mathbb{E}[\hat b^2] = \mu^2 + \mathrm{se}^2$ holds for every $\mu$, so
   $\hat b^2 - \mathrm{se}^2$ is an exactly unbiased estimate of $\mu^2$, and the registered
   quantity is its deployment-weighted mean over cells. It keeps the per-cell absolute treatment
   that stops cells cancelling, and it has no floor to correct. **It can come out negative** when
   the true bias is near zero; that is deliberate, because a statistic bounded below by zero cannot
   be unbiased at zero, and truncating it is precisely what put the floor back. A square root of
   the pooled value is printed for interpretability and labeled as a back-transform, never as the
   registered quantity. The raw mean absolute bias, its uncorrected floor and the residual floor of
   version 5's correction are all reported beside it, so the size of what was removed is visible.

   **Its resolution is limited by the number of cells, not replicates**, since it is a per-cell
   aggregate, and the cells are not independent: the round-6 common-random-numbers fix means the 21
   conditions come from 10 latent networks. Its standard error is therefore clustered on the
   parameter cell. The replicate-level pairing that makes this design resolvable at 40 replicates
   applies to outcome 2 and to the registered paired contrasts, not to this one.
2. **Root mean squared error** in $\Delta_{\text{RMST}}(18)$, which retains bias and variance
   together and is the direct answer to round 3's objection that efficiency is a method property
   and must not be divided out.
3. **Coverage** of nominal 95% intervals, pooled, classified from its Monte Carlo interval as
   calibrated inside $[0.90, 0.98]$, miscalibrated outside, or **inconclusive** when the interval
   straddles a boundary.
4. **Calibration over time**: bias and pointwise 95% coverage of $\bar S_B(t)-\bar S_A(t)$ at
   $t \in \{6, 12, 18\}$.

   **This outcome was registered from version 2 and no code produced it until version 6.** Round 6
   found that `pack()` had computed the survival differences since version 3 and `freq_boot()`
   discarded them, keeping only RMST, while the ML-NMR path predicted `type = "rmst"` alone and so
   had no survival quantity at any time for either of its rows. A search for the field across the
   source returned one hit, its own definition. It is now carried through: the bootstrap returns
   point estimates and percentile intervals for all three times alongside RMST at no extra fitting
   cost, `target_surv_diff` predicts the two ML-NMR rows, and `calibration_table` in
   `R/08-analyze.R` computes bias, Monte Carlo error and pointwise coverage against a truth taken by
   quadrature rather than simulated. `R/15-smoke.R` asserts that all seven estimators return a
   value at all three times, because the previous version also ran without error.

   One implementation note, because it was a real defect rather than a detail: a survival prediction
   names its parameters `pred[New 1: B, 3]`, with the time index following the treatment, where an
   RMST prediction names them `pred[New 1: B]`. Reusing the RMST pattern matched nothing and the
   first version of the fix returned no ML-NMR rows at all. The time index is now parsed from the
   name and used to order the columns, so a change in `multinma`'s column order cannot pair the
   wrong times together silently.

**Each registered comparison is tested as a paired difference on each registered outcome**, with a
confidence interval clustered on the latent network. Version 5 tested one thing and called it four:
`paired_contrast` computed a paired difference in per-replicate **absolute error**, which is none of
the four outcomes above. Absolute error mixes bias and variance, so a lower-variance estimator can
beat a lower-bias one and the result would have been reported as a bias finding, while bias, RMSE
and coverage received no paired interval at all. Round 6 caught it.

Every contrast now returns one row per outcome:

| outcome | paired quantity | paired on | resolution set by |
|---|---|---|---|
| 2, RMSE | $(\hat\Delta_a-\Delta)^2-(\hat\Delta_b-\Delta)^2$ | replicate | replicates |
| 3, coverage | $\mathbb{1}[\text{covered}_b]-\mathbb{1}[\text{covered}_a]$ | replicate | replicates |
| 1, bias | $(\hat b_a^2-\mathrm{se}_a^2)-(\hat b_b^2-\mathrm{se}_b^2)$ | **cell** | **cells** |
| descriptive | $\lvert\hat\Delta_a-\Delta\rvert-\lvert\hat\Delta_b-\Delta\rvert$ | replicate | replicates |

The last row is what version 5 reported as primary. It is retained because it is a legitimate
summary and because deleting it would hide what changed, but it is labeled descriptive and is not
one of the four. Outcome 4, calibration over time, is compared through `calibration_table` at each
registered time rather than through this function.

The registered comparisons are **not of equal standing**.

**Primary 1: the question the catalog entry asks.** `MLNMR-flex` against `MAIC-PH`, and `MLNMR-flex`
against `STC-PH`. Section 1 defines the open problem as whether a general-likelihood survival ML-NMR
recovers the target estimand where proportional-hazards MAIC and STC do not. That is a comparison
between the recommended method and what practitioners currently do, and it is **deliberately
unmatched on flexibility**, because the flexibility difference is the treatment and not a confounder.

**Version 5 did not register this comparison at all, and round 5 was right to call that fatal.**
Round 4 found that the across-row contrasts rested on a matched-flexibility premise round 2 had
withdrawn; the response demoted every across-row contrast to descriptive, which removed the study's
own question along with the unsupportable ones. The withdrawn premise constrains *matched*
comparisons and has no bearing on these two.

**Primary 2: flexible versus proportional, within a row.** `MAIC-PH` against `MAIC-flex`, `STC-PH`
against `STC-flex`, `MLNMR-PH` against `MLNMR-flex`. Both members of each pair share an
implementation, a weighting or regression step and a code path, so the contrast isolates the survival
model restriction. Primary 1 measures the practical consequence; primary 2 identifies the mechanism.
Reporting both is what distinguishes "ML-NMR wins because it is flexible" from "ML-NMR wins for some
other reason".

**Descriptive: method family across rows at matched flexibility.** `MAIC-flex` against
`MLNMR-flex`, `STC-flex` against `MLNMR-flex`, `MAIC-PH` against `MLNMR-PH`. These are the contrasts
the withdrawn premise does constrain: a 3-knot Royston-Parmar spline and a 3-knot M-spline do not
carry the same effective flexibility, so an equal knot count does not equate the two. The effective
degrees of freedom of each fitted survival model is **recorded per replicate** so the paper can
report how far apart the flexibilities actually were rather than assuming they matched. Registering
the diagnostic before the run is what stops it becoming a post hoc excuse for whichever way the
comparison falls.

No threshold is required for any of them.

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
- **STC-PH carries a bias that survives at any sample size, and round 5 was right that version 5
  explained it wrongly.** Version 5 attributed it to transporting a relative effect on a *marginal*
  scale, which is the mechanism of MAIC's graft. STC has not used a graft since round 3, and section
  7.2 reports its conditional transport exact to $4\times10^{-15}$; the two statements could not both
  hold, and the explanation was a leftover from the deleted implementation.

  Measured rather than re-explained, at $\kappa_B = 0$, $\gamma = 0.30$, 40 replicates per size:

  | IPD arm size | STC-PH bias | MCSE | STC-flex bias |
  |---:|---:|---:|---:|
  | 250 | $+0.191$ | 0.112 | $-0.045$ |
  | 1,000 | $+0.084$ | 0.055 | $-0.027$ |
  | 4,000 | $+0.161$ | 0.032 | $-0.008$ |

  **STC-flex converges to zero and STC-PH does not**, sitting five Monte Carlo standard errors from
  zero at 4,000 per arm. The bias is therefore structural, not finite-sample, and the earlier claim
  that STC's structural error is exactly zero was also too strong: that computation assumed the
  *conditional* model was the fitted one, and the fitted row is PH-restricted.

  The mechanism this points to, stated as a hypothesis to be confirmed by the run rather than as an
  established fact: the proportional restriction is applied to a **marginal** aggregate-side fit,
  and under an effect modifier the true marginal contrast is non-proportional even where the
  conditional one is exactly proportional. That is non-collapsibility, located in the aggregate-side
  fit rather than in any graft. It predicts that the bias appears only when $\gamma > 0$, which the
  pilot shows ($+0.186$ and $+0.198$ at $\gamma = 0.30$ against $+0.021$ at $\gamma = 0$), and that
  `MAIC-PH` should carry a component of it too, since both rows share the same aggregate-side fit.
  Both predictions are registered here and are checkable against the run.
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
estimator's pooled coverage across all 21 cell-by-censoring conditions:

| design | pooled $n$ | P(calibrated) | P(inconclusive) | P(miscalibrated) |
|---|---:|---:|---:|---:|
| version 4: 14 conditions, 25 replicates | 350 | 0.733 | 0.267 | 0.000 |
| an intermediate 14 conditions, 40 replicates | 560 | 0.954 | 0.046 | 0.000 |
| **registered: 21 conditions, 40 replicates** | **840** | **0.995** | **0.005** | **0.000** |

when the estimator is in truth exactly calibrated at 0.95. **This is the concrete cost of version
4's replicate cut**, and it is larger than that version recorded: at 25 replicates the rule fails to
certify a genuinely calibrated estimator more than a quarter of the time. Round 5 found the middle
row still presented as the registered design after the matrix went to 21 conditions, which is
corrected here.

Power against genuine miscalibration is the weaker side and is stated rather than hidden. At 840
observations the rule returns "miscalibrated" for a true coverage of 0.85 with probability 0.990,
for 0.88 with probability 0.423, and for 0.90 essentially never, since 0.90 is the boundary itself.
**Gross miscalibration is caught, mild miscalibration is not**, and an "inconclusive" verdict must
therefore not be read as evidence of calibration.

**D3, the hazard ratio as a decision input.** Evaluated on the **analytic least-false parameter
from E1**, not on replicate-fitted hazard ratios, so the statistic carries no simulation noise at
all; E2's finite-sample scatter is reported around it rather than mixed into it. Round 2's second
reviewer asked for exactly this separation.

The statistic is stated once, here, and sections 2 and 5 refer to this definition rather than
restating it, because round 4 found three incompatible versions of it in version 4.

**Round 5 then found that the statistic itself was a category error, and it was right.** Version 5
compared the across-regime **range** of implied RMST against the **0.50-month reimbursement
threshold**. That threshold is a boundary on the *level* of benefit, not a tolerance for *variation*.
A range of 1.09 months can sit entirely above 0.50 and change no decision; a range of 0.05 straddling
0.50 reverses every decision. The old statistic could not establish the conclusion it was used to
draw, even where that conclusion was true. This design contains a direct counterexample: the
$\kappa_B = 0.30$ margin cell has a range of **0.7157 months** and flips **nothing**.

**The registered statistic is the decision itself.** With the truth held exactly fixed across
regimes, apply each leg's least-false hazard ratio to one fixed target placebo curve (the truth's
own, so no baseline noise enters), difference the two implied RMSTs, and ask whether the resulting
recommendation matches the correct one. Reported per cell over the $4\times4$ grid of independently
crossed regimes:

- **`flip_frac`**, the fraction of the 16 regime pairs whose implied recommendation is wrong;
- **`flip_frac_diag`**, the same restricted to matched follow-up;
- **`spans`**, whether the implied values straddle the threshold at all.

The PH plug-in is **fit for purpose as a decision input only if no cell flips**. This is labeled
throughout as the performance of the **PH plug-in decision procedure**, not as a general conversion
from a hazard ratio to a non-proportional RMST contrast, which does not exist.

**D3 carries no Monte Carlo error and therefore no interval.** Round 5 asked for one, reasonably,
since a five-significant-digit verdict declared before the expensive run invites the question. Every
D3 number is Gauss-Hermite quadrature plus a root-find on the exact data-generating mechanism: there
is no sampling, no replicate count, and no estimator. What D3 does *not* carry is finite-sample
behavior, and that is E2's subject, reported separately rather than mixed in.

**Its numerical error is bounded by a convergence study, and version 5's bound was the wrong
quantity.** That version said the uncertainty "is quadrature error, which the control cell bounds at
$1.2\times10^{-10}$". Round 6 was right to reject it. The control cell is the *proportional* one, so
what its across-regime cancellation measures is how exactly two nearly identical calculations cancel
in the easiest case the design contains. That is not a bound on the absolute error of a root-find
through a crossing marginal hazard, and reporting the two as one quantity overstated the certainty by
seven orders of magnitude.

`R/17-d3-convergence.R` measures it instead, by refining every knob at once: Gauss-Hermite order 64 to
128, Cox root-finding grid 2,000 to 8,000, RMST trapezoid 2,001 to 8,001. A quantity unmoved by that
is not resting on any one of those choices.

| | |
|---|---|
| largest movement under refinement, over every cell and regime pair | $9.7\times10^{-4}$ months |
| closest any implied value comes to the 0.50 threshold | 0.0065 months |
| within each cell, its own margin against its own error, at worst | **34 times** |
| flip fractions identical at both resolutions | **yes**, 4 cells at each |

**The per-cell ratio is the one that matters**, because the largest error and the smallest margin
occur in different cells; dividing one by the other compares quantities from two places and
understates the margin everywhere. A flip is an artifact only if a cell's *own* numerical error can
carry its *own* nearest implied value across the threshold, and the tightest such case has 34 times
the room it would need. The direct check agrees: the flip fractions are bit-identical at both
resolutions. So an inconclusive region is empty, which is what version 5 claimed, but now for a
measured reason at the right scale rather than a borrowed one at the wrong scale.

**D3 fails.**

| | |
|---|---|
| cells whose recommendation flips on censoring alone | **4 of 10** |
| worst flip fraction | **0.7500**, that is 12 of 16 regime pairs wrong |
| cells that flip only when follow-up is **crossed**, never when matched | **1** |
| 0.40 | 5 of 10 | 0.5625 |
| **0.50**, registered | **4 of 10** | **0.7500** |
| 0.60 | 6 of 10 | 1.0000 |

The truth is identical across all sixteen regime pairs in every cell. Nothing about the treatments,
the population or the estimand changes; only how long the two trials happened to follow their
patients. In the worst cell an analyst using the standard proportional-hazards plug-in reaches the
wrong reimbursement decision in **eleven of sixteen** follow-up configurations.

The single sharpest cell is $\kappa_A = \kappa_B = 0.30$, where both arms are strongly
non-proportional but the target contrast is exactly proportional. Its recommendation is correct in
**every** matched-follow-up configuration and wrong in 5 of 16 once the two studies' follow-up is
allowed to differ. Version 4's shared-regime design could only ever have seen the diagonal, and
would have reported this cell as flawless.

Deployment weights are uniform and are stated as the declared judgment they are.

## 11. The decision model behind the 0.50-month threshold

A treatment is recommended if its target-population RMST gain over the comparator at 18 months
exceeds the gain that justifies its cost, set at 0.50 months. It is declared before the run and
every conclusion that depends on it is labeled as depending on it. It now enters in exactly two
places: **D3**, where each regime's implied $\Delta_{\text{RMST}}$ is compared against it to give a
recommend-or-decline decision and D3 counts how often that decision differs from the one the truth
supports, and the **secondary decision-loss appendix** of section 10.0. Version 4 also used it in
D1, which is withdrawn. Version 5 described D3's use here as judging an across-regime **range**
against the threshold; that was the formulation round 5 found fatal, on the ground that a range and
a level are not comparable quantities, and the replacement statistic is a decision flip. The
description above was not updated with the statistic, which is recorded because a stale description
of a replaced rule is how a withdrawn rule gets read back in.

**Sensitivity: D3 and the decision-loss appendix are both recomputed at thresholds of 0.40 and 0.60
months** and reported, since the number is a stipulation and not an estimate.

**The flip COUNT is not invariant, and version 5 said it was.** It claimed "at a 0.40 or 0.60
threshold the same four cells still flip", reasoning from the implied values spanning the threshold
while "the truth sits at 0.750". Round 6 found both halves wrong. The truth is 0.750 only in the
`recommend` cells; the `margin` cells sit at 0.35, on the other side of every candidate threshold,
which is the entire reason those cells exist. And a flip count depends on which side of the threshold
each cell's *truth* falls as well as where its implied values fall, so it cannot be read off a range
at all. Recomputed rather than argued:

| threshold | cells that flip | worst flip fraction |
|---:|---:|---:|
| 0.40 | 5 of 10 | 0.5625 |
| **0.50**, registered | **4 of 10** | **0.7500** |
| 0.60 | 6 of 10 | 1.0000 |

**What survives is the verdict, not the count.** D3 fails at every threshold tried, and it fails
harder as the threshold rises. That is a weaker claim than the invariant-cell-count version 5 made,
and it is the one the computation supports. The registered rule is a pass only if no cell flips, so a
count that moves between 4 and 6 changes nothing about whether the rule fires.

## 12. What this cannot settle

- **Decision relevance is placed by construction, and the decision-frequency results are conditional
  on that placement.** $\beta_B$ is solved so each cell's truth sits 0.25 months above or 0.15 below
  the 0.50-month threshold, because round 2's fatal finding was that version 2's cells sat so far
  from the boundary that no tolerated error could change a recommendation. Fixing that necessarily
  means D3's flip fractions and the decision-loss appendix describe behavior *near* the boundary.
  They are not estimates of how often real reimbursement decisions reverse, and are not reported as
  such. What is not placement-dependent is that the truth is held exactly fixed across regimes while
  the recommendation moves.
- **The MAIC graft bound is measured under conditions chosen to favor MAIC, so it is a lower bound
  on the graft's contribution in general.** One covariate, normal with the same variance in both
  studies, a shared $\gamma$, target summaries supplied as known superpopulation values, and exact
  moment matching. Under those conditions MAIC's exponential tilt recovers the target law exactly,
  which is why the graft's structural error is as small as 0.0116 months. With several covariates, a
  non-normal or different-variance covariate law, or estimated target summaries, the weighting step
  is no longer exact and the graft would carry more. Round 5 raised this and it is accepted: the
  0.0116 figure bounds the graft **in this design** and is not a claim about MAIC generally.
- **No absolute-scale claim is made for the flexible ML-NMR arm**, in either direction. Version 5
  listed an upward bias of 1.03 months in its target-standardized placebo curve as a limitation; that
  figure was an artifact of the placebo defect (section 7.1) and does not exist. Corrected, the
  per-treatment errors are a fraction of a month and move together, which is what correct anchoring
  looks like. But they are measured at four and five replicates in one cell, so they license no
  general statement about levels either. The registered estimand is a difference and nothing in this
  study is reported on an absolute scale for that arm.
- One covariate. Multiplicity across covariates is not measured.
- **The within-row ML-NMR contrast changes proportionality and baseline pooling together, and no
  specification in `multinma` 0.9.1 separates them.** `MLNMR-PH` indexes the baseline spline by study
  and `MLNMR-flex` indexes it by treatment while pooling across studies, so any within-row difference
  in RMSE, coverage or finite-sample bias is attributable to the two jointly. Two candidate
  pooling-matched proportional specifications were tried and both are rejected before sampling
  (section 7.1). What *is* established is the asymptotic half: this design's between-study difference
  is a pure level shift that the study intercepts absorb exactly, so the pooled baseline can represent
  the truth and a difference that persists as sample size grows is not an artifact of it. The
  finite-sample half is not separable and is not claimed. The four spline-based frequentist rows carry
  no such confound and are what the proportionality claim rests on.
- **Between-study baseline differences are pure level shifts here.** Under a mechanism whose studies
  differ in baseline *shape*, the flexible arm's pooled spline would be misspecified in a way the
  proportional arm is not, which would add an asymptotic confound to the finite-sample one above.
  That case is not tested.
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

Round 2.

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

Round 3. Three reviews: one on the whole protocol, two on halves because the second
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

Round 4. Two reviews, the second split into halves for an input-size ceiling; a third
returned empty and is recorded as not obtained rather than counted as agreement. **Three of the
findings were defects I introduced while fixing round 3**, which is the specific failure this round
existed to catch.

| Finding | Severity | Resolution |
|---|---|---|
| E1 and E2 evaluate a direct head-to-head coefficient, but OUT-11 concerns a transported **anchored indirect** comparison, and least-false Cox coefficients are not transitive under non-proportional hazards | **fatal** | **Confirmed, and version 4 had defended the wrong framing explicitly.** Both experiments rebuilt on the anchored contrast with each leg under its own study's censoring and the two regimes crossed independently. Measured gap between the two quantities: 0.93% to 1.78%, and it varies with censoring. Consequences were large: D3 moves from passing to failing in **4 of 10 cells** |
| Section 10.3's pilot table still carried the pre-fix STC columns | **fatal**, found as "not distinguished from the withdrawn artifact" and worse on inspection | **Confirmed and worse than reported.** Twelve values from deleted code; every STC-flex entry had the wrong sign. One claimed finding (STC-PH's biases cancelling at $\kappa_B{=}0.15$) rested entirely on the artifact and is **withdrawn**, section 10.3 |
| D1 is claimed replaced but section 10.2 still registers it as "the primary outcome" with its 0.10 cutoff and the conceded gaming claim | **fatal**, both reviewers independently | **Confirmed.** Deleted rather than demoted, section 10.2b. Contradiction with sections 10.0 and 10.1 removed |
| The bootstrap budget contradicts the protocol's own unit cost by roughly eightfold | **fatal** | **Confirmed by direct measurement**, which also showed the unit cost itself was wrong: 0.711 s, not 0.658 s, and the "6.4 h" line implied about 62 rather than 500 resamples per replicate. Section 14 rebuilt |
| The Stan unit cost (227 s for both arms) is below the measured cost of one 128-point fit (296.2 s) | serious | **Confirmed.** Re-measured directly at the exact production configuration, section 14 |
| Sections 8, 9 and 10.2 quote replicate arithmetic the freeze had superseded | serious | **Confirmed.** Counts restored to 40 per cell and 500 resamples on the instruction to prioritize robustness over schedule, and propagated by machine check rather than by rereading |
| "Method family across rows at matched flexibility" is registered as a primary contrast on a premise round 2 **withdrew** | **fatal** | **Confirmed.** Those three contrasts demoted to descriptive; effective degrees of freedom recorded per replicate so the eventual paper can report the flexibility gap instead of assuming it away, section 10.1 |
| Scoring MAIC through a knowingly invalid graft while STC gets a valid conditional transport cannot support a method-family comparison | **fatal** | **Confirmed as a legitimate objection and answered by measurement.** The graft's structural error is exactly computable: at most **0.0116 months**, 1.6% of MAIC-PH's pilot bias, and exactly zero when $\gamma=0$. STC's conditional transport is exact to machine precision. The objection does not bite on this design, section 7.2 |
| D3's estimand stated three incompatible ways across sections 2, 5 and 10 | **fatal** | **Confirmed.** Defined once in section 10.3; other sections refer to it |
| The 256-point sensitivity arm is costed at 128-point prices | serious | **Confirmed.** Recosted at measured 256-point timings, section 14 |
| The coverage rule's operating characteristics are stated only as "the region is wide" | limitation | Tabulated under both a calibrated and a miscalibrated truth, section 10.3. This is also what showed the replicate restoration matters: P(calibrated) rises from 0.733 to 0.953 |
| The refit escalation has no budget line | minor | Capped and costed at 41.3 h, section 14 |

Four further defects were found by the author while implementing the above, before round 5 saw any
of it. They are listed here because a change log that records only what reviewers caught understates
how much of a protocol is still wrong at each revision.

| Found while fixing | Severity | Resolution |
|---|---|---|
| The rebuilt anchored computation evaluated **both legs at the target study's baseline**, which is stronger than perfect population adjustment and which no method delivers | **fatal** | Leg A moved to the IPD study's own baseline. Worth 2.86% on the hazard-ratio scale at $\kappa_A = 0.30$, varying by regime; D3's worst range moves from 1.4332 to **1.3805**, section 2 |
| Every timing the study had taken was inflated roughly twofold by machine contention, because the check for a quiet machine grepped for `Rscript` while the process is named `R` | **fatal** | Re-measured on a verified-quiet machine with the load recorded. This overturned the cost figure that had justified `N_INT = 128`, and the order is now **256**, section 14 |
| E3's censoring factor spanned only 45% of E1's range and only **one direction**: both conditions put the heavier censoring on the aggregate study, so an offsetting bias would read as accuracy | **fatal** | A mirrored condition registered, taking coverage to 87% and making the factor two-sided. The two `ipd-nph` cells, where the effect is largest, previously had no differential-follow-up condition at all, which is the same quarantine defect round 3 found for $\kappa_A$ |
| E2's per-cell seed stride was 1,000 with 2,000 replicates, so cells with identical leg-A parameters drew the same 1,000 datasets | minor | Stride raised above the replicate count, with a guard. Nothing reported was affected, since every E2 figure is computed within a cell |
| The refit escalation was **registered but not implementable**: `fit_flex` and `fit_ph` hardcoded the iteration count and `adapt_delta`, so "refit once at doubled iterations with `adapt_delta = 0.99`" could not have run | serious | Both are arguments now and `fit_mlnmr` performs the escalation, retains both attempts, and records whether it fired so the observed rate is reportable against the 20% cap |

Round 5. One review of the whole protocol and seven of parts, because the
part-reviewer's input ceiling is not a stable size; one part returned empty twice and one returned
truncated. **Two of the five fatal findings were defects introduced while fixing round 4**, which is
now the third consecutive round in which my own regressions were the largest category.

| Finding | Severity | Resolution |
|---|---|---|
| Section 1 defines the open problem as general-likelihood ML-NMR against PH MAIC and STC, but 10.1 makes flexible-versus-proportional *within* a family primary and registers `MLNMR-flex` against `MAIC-PH` or `STC-PH` **nowhere** | **fatal** | **Confirmed.** Fixing round 4's matched-flexibility fatal had demoted every across-row contrast and took the study's own question with it. The withdrawn premise constrains *matched* comparisons only; these two are unmatched on purpose. Registered as primary 1, section 10.1 |
| D3 compares an across-regime **range** with a threshold on the **level** of benefit, which cannot establish what it is used to claim | **fatal** | **Confirmed, and the design contains its own counterexample**: the $\kappa_B=0.30$ margin cell has a range of 0.7529 months and flips nothing. Replaced by a decision-flip statistic; the result strengthened, from a bare range to 4 of 10 cells reversing and 11 of 16 regime pairs wrong in the worst, section 10.3 |
| The coverage rule still uses 14 conditions and 560 replicates after the matrix went to 21 and 840 | **fatal** | **Confirmed**, and the same staleness class as round 4. Recomputed at 840: P(calibrated) 0.995 |
| The decision-loss table is computed on the old six-cell mixture; the frozen design is 19 recommend against 2 decline, so a constant rule wins by construction | **fatal** | **Confirmed.** Reported under uniform *and* balanced weights (constants at 0.0750 and 0.1250); only findings surviving both are reported, section 10.0 |
| The registered STC-PH mechanism contradicts the protocol's own claim that STC's conditional transport is exact | **fatal** | **Confirmed, and both statements were wrong.** The explanation was a leftover describing MAIC's graft; my rebuttal assumed the conditional model was the fitted one, and the fitted row is PH-restricted. Measured against sample size, STC-PH's bias **survives at 4,000 per arm** ($+0.161$, five MCSE) while STC-flex's converges to zero. Registered as a hypothesis with two checkable consequences, section 10.3 |
| `aux_regression = ~ .trt` pools the baseline spline across studies while `aux_by = .study` does not, so the ML-NMR column toggle changes baseline representation as well as proportionality | serious | **Confirmed as a software finding and measured as inert here.** `multinma` 0.9.1 offers no specification with both non-proportional hazards and study-specific baselines, and silently ignores `.study` in the formula. But this design's between-study difference is a **pure level shift** ($2.8\times10^{-14}$ variation over time), absorbed exactly by the study intercepts, sections 7.1 and 12 |
| The flexible arm's target anchoring is unverified, and a near-truth contrast can arise from offsetting errors | serious | **Measured**, and the measurement was against the wrong truth. Round 5's resolution reported the absolute placebo curve biased high by 1.03 months while the contrast was not. **Round 6 found that figure to be an artifact of the placebo defect and it is withdrawn**; the corrected per-treatment errors are a fraction of a month and move together. The conclusion that survives is round 5's question answered in the affirmative: the arm anchors correctly, section 7.1 |
| Mean absolute cell bias is biased upward by its own Monte Carlo noise, by more than the effects it must resolve | serious | **Confirmed.** The floor is 0.095 months at 40 replicates against flexible-row biases of 0.043 to 0.046. Reported raw **and** corrected, with the floor stated, section 10.1 |
| E2 uses the model-based Cox variance where the robust sandwich is the right one under non-proportional hazards | serious | **Confirmed as an objection and measured as immaterial**: robust 0.939 to 0.957 against model-based 0.937 to 0.958, SE ratio 0.9974. Both now recorded |
| The graft's 0.0116 months is compared against MAIC-PH's 0.725 bias, not against the contrast it could contaminate | serious | **Confirmed.** `MAIC-flex` and `STC-flex` differ by 0.003 in the pilot, which the graft exceeds several times. Any ranking of that pair on a difference below 0.0116 is **withdrawn in advance**, section 7.2. The "two orders of magnitude" claim was also an overstatement of 62-fold and is corrected |
| The Grambsch-Therneau rejection rates describe a direct B-versus-A trial that does not exist in the network | serious | **Confirmed, and it reversed a conclusion.** Per leg at each leg's own size, both legs of the $\kappa_A=\kappa_B=0.30$ cell fire (0.780 and 0.627) where the direct test gave 0.040. The cell is not undetectable; the per-leg diagnostic catches what the combined contrast hides, section 8 |
| The Stan budget appears to omit a concurrency factor | serious | **Not a defect, but the labeling was.** The unit is amortized wall clock, not latency; both reviewers divided by concurrency twice. Raw elapsed and replicate counts are now printed so the division is visible. A typed unit cost of 442.0 against the true 442.4 **was** a defect and is fixed, with a new assertion that printed units reproduce printed totals |
| Sensitivity-arm replicate count contradicts between prose and code; the budget file contains a typed fallback ratio; the 512 arm has no registered decision rule | serious and minor | All confirmed and fixed: 50 replicates total stated in both places, the fallback replaced by a hard stop, and a rule registered for what the 512 result changes, section 14 |
| Decision relevance is engineered by solving $\beta_B$ to straddle the threshold | serious | **Accepted as a scope limitation.** It was necessary to fix round 2's fatal; it means the flip fractions describe behavior near the boundary and are not estimates of real reversal rates, section 12 |
| The graft bound is measured under conditions most favorable to MAIC | serious | **Accepted.** Stated as a lower bound in this design rather than a claim about MAIC generally, section 12 |
| D3 is declared a failure with no Monte Carlo interval | serious | D3 carries no Monte Carlo error at all: quadrature plus a root-find, with the control cell bounding quadrature error at $1.2\times10^{-10}$. Stated explicitly, section 10.3 |

**Findings the author made while responding, which no reviewer raised.** Every integration probe
before version 6 fitted only the flexible ML-NMR arm, so it measured one estimator's quadrature error
and could say nothing about the registered contrast, which is flexible against proportional **within**
that row. Extending it to the proportional arm at 256 and 512 points appeared, at five and six paired
replicates, to show the two errors moving in opposite directions and therefore adding in the
difference, at $t = 2.14$ and $t = 2.64$. **At the registered eight replicates it is $t = 1.38$ and the
effect is not there.** The claim is withdrawn and the episode is recorded rather than deleted,
because stopping at six would have put a significant arm-differential quadrature error into this
pre-registration on the strength of a run that had not finished. What the probe delivers instead is a
bound, 0.045 months at 95%, registered against the ML-NMR within-row contrast in section 7.2, which is
what turns an unmeasured assumption that the errors cancel into a measured limit on how much they
might not.

Round 6, this version. One review of the whole protocol by one reviewer; two others were attempted
and are recorded as not obtained rather than quietly omitted. **Thirteen fatal findings, the most any
round has produced, and they concentrate in a single category that no earlier round had named.**

**The category: registered procedures the code could not perform.** Four of the thirteen were a
procedure specified in this document with no implementation capable of running it. The refit
escalation (round 5), the tail-ESS criterion, the calibration-over-time outcome, the common Cox
projection and the entire sensitivity program were all registered, reviewed repeatedly, and
unrunnable. They survived six rounds because reviewing prose asks whether the document says the right
thing and reading code asks whether the code is correct, and neither asks whether the code does what
the document says. `R/15-smoke.R` now runs the whole pipeline end to end at toy sizes before the
expensive run and asserts the shape of what comes out; it found a fifth defect on its first execution.

| Finding | Severity | Resolution |
|---|---|---|
| Every analytic experiment builds the placebo arm with $\gamma_{\text{PBO}} = \gamma$ while `sim_network` builds it with 0, so E1, E2, the per-leg PH powers, the graft bound and the anchoring truth all describe a mechanism the benchmark does not run | **fatal** | **Confirmed, at eighteen call sites across six files.** Measured: placebo $S(12)$ was 0.6337/0.4356/0.2199 at $x = -2/0/+2$ against a flat 0.4356. Everything analytic recomputed; D3's worst flip went 0.6875 to 0.7500, E2's max shift 0.876 to 0.769 SDs, the graft bound $+0.0116$ to $-0.0302$. `truth_delta` is B minus A with no placebo, so every solved $\beta_B$ and the whole E3 matrix stand |
| Common random numbers are analyzed as 840 independent observations | **fatal** | **Confirmed, and it is a consequence of my own round-5 fix.** Keying the seed on the parameter cell made the three censoring regimes one network censored three ways, so the 840 rows are 400 blocks. Every Monte Carlo error is now cluster-robust over (parameter cell, replicate), the independence value is printed beside it as a labeled reference point, and the registered interval is the cluster-robust one, section 9 |
| ML-NMR alone receives sampled target summaries; the frequentist rows receive the superpopulation values | **fatal** | **Confirmed.** `published_moments` now supplies every row from what the aggregate study reports, so all seven read the same numbers an analyst would have, section 7.2 |
| The registered paired tests change the outcome to mean absolute error, which is not a registered outcome | **fatal** | **Confirmed.** The paired contrast now returns one row per registered outcome: squared error, coverage and squared bias. Mean absolute error is retained and labeled descriptive, section 10.1 |
| The squared-scale bias correction reintroduces a floor when back-transformed | **fatal** | **Confirmed.** $E[\hat b^2] = \mu^2 + \sigma^2$ is exact, but the square root is not, and the floor it leaves is $0.3431\sigma$. The debiased quantity is reported **on the squared scale**, where it is unbiased, and the back-transformed value carries its floor stated beside it |
| The ML-NMR within-row contrast changes pooling and priors together, so a difference in RMSE or coverage cannot be attributed to proportionality | **fatal** | See below: probed for a pooling-matched specification |
| Calibration over time is omitted from production and mislabeled for the frequentist rows | **fatal** | **Confirmed and worse than stated.** `freq_boot` discarded the survival differences and the ML-NMR path predicted RMST only, so registered primary outcome 4 could not be produced for any of the seven rows. Both paths now produce it, `main()` calls it, and the times are interpolated exactly rather than read at the nearest grid point (6.0033 and 11.9565 against 6 and 12) |
| The sampler policy monitors RMST but not the registered survival differences | **fatal** | **Confirmed**, and a fit whose survival prediction failed outright was stored with a `NULL` and passed on its RMST. The policy now binds per registered time and such a fit fails |
| The common fitted-curve Cox projection has no implementation | **fatal** | **Confirmed.** `cox_solve` is now the shared root-find; `cox_limit` feeds it analytic curves and `cox_project` feeds it fitted ones, agreeing to $8\times10^{-5}$ on the production grid. All seven rows report it, the five frequentist ones with a bootstrap interval at no extra fitting cost |
| The sensitivity program is neither executable nor fully budgeted | **fatal** | **Confirmed on every count.** Cells named, driver written, knots and prior scales made arguments, and the budget rebuilt per fit set from the table `R/07-run.R` iterates: 38.2 h against the 22.9 h claimed, because "halved and doubled" is two fit sets and the knot arm's frequentist half had no line at all, section 14 |
| The refit cap and the all-passed analysis are not implemented | **fatal** | **Confirmed, and the rule is replaced rather than implemented.** Discarding valid converged fits to hold a schedule number lets a budget assumption select the analysis set, and which fits get discarded depends on the order they finish in. 20% is now an assumption whose realized value is reported. The all-passed subset now repeats **every** registered outcome, not `bias_table` alone |
| Bootstrap endpoint Monte Carlo error is discarded | **fatal** | **Confirmed.** The resample draws are the only object it can be recovered from and they were thrown away one line after the endpoints. Both endpoints now carry a standard error from 200 redraws of the stored resample values, for every quantity, at no fitting cost, section 7.2 |
| The 512-point decision rule has uncovered outcomes | **fatal** | **Confirmed.** An interval such as $[-0.03, 0.01]$ crossed zero without being contained in $\pm 0.02$ and fell through both branches, and "its magnitude" was undefined for an interval. A third inconclusive branch is registered and the magnitude is defined as $\max(|L|, |U|)$, section 14 |
| D3 is not insensitive to the alternative thresholds | serious | **Confirmed.** The count moves: 5 cells flip at 0.40, 4 at 0.50, 6 at 0.60. The reasoning was wrong twice over, since the margin cells' truth is 0.35 rather than 0.750 and a flip count cannot be read off a range at all. The verdict survives, the invariant count does not, section 10.3 |
| The proportional control does not bound non-proportional numerical error | serious | See below: replaced by a convergence study |
| Effective degrees of freedom are not recorded | serious | **Confirmed.** Both fit objects are discarded, so the diagnostic that the descriptive matched-flexibility comparison depends on could not have existed. Now taken while the fit is in scope: $p_{\text{WAIC}}$ for the Bayesian rows, exact parameter counts for the maximum-likelihood ones, section 7.2 |
| The nine-condition coverage restriction is never reported | serious | **Confirmed.** Production called `coverage_table` once on all 21 conditions. Both summaries are now printed unconditionally, since the guard against choosing the favorable pool only works if both exist |
| The verifier silently skips missing quoted-value sources | serious | **Confirmed, and it had already happened**: `results/dgm-verification.rds` was absent while the script reported 253 of 253 passing, because a missing key removed both the number and its assertions and shrank the denominator with them. The artifact list is now explicit and the export stops when one is missing; every conditional key is required once up front |

**Two findings the reviewer raised that this version answers by measurement rather than by argument.**

*The proportional control does not bound non-proportional numerical error.* Upheld. The control cell
is the proportional one, so its across-regime cancellation of $1.2\times10^{-10}$ measures how exactly
two nearly identical calculations cancel in the easiest case the design contains, which is not a bound
on the absolute error of a root-find through a crossing marginal hazard. Version 5 reported two
different quantities as one. The replacement is a convergence study (`R/17-d3-convergence.R`) that
doubles the Gauss-Hermite order, quadruples the Cox root-finding grid and refines the RMST trapezoid
at once, and reports both how far the answers move and how close any implied value comes to the
threshold, because a flip is an artifact only if numerical error can move a value across it.

**Findings the author made while responding, which no reviewer raised.** The placebo defect above
overturned a finding this protocol had reported as settled twice. Version 5's section 7.1 carried a
$+1.028$ month anchoring bias for the flexible ML-NMR arm, at 3.6 Monte Carlo standard errors, with a
large-sample diagnostic at four times the arm sizes reporting $+0.751$ at 10.1, a two-part decay fit,
and a planned sixteen-times run to decide whether it was structural. None of it exists: the placebo
truth it was measured against was 9.596, computed with a prognostic placebo, where the registered
mechanism gives 10.516. Corrected, the three errors are $+0.109$, $+0.194$ and $-0.169$, comparable to
the A and B errors beside them. **The estimator was right and the yardstick was wrong.** A coincidence
made the artifact convincing: 9.596 is almost exactly the IPD study's own placebo RMST, which is the
value a wrongly anchored prediction would drift toward, so "the drift is away from the anchor" read as
evidence when it was an accident of arithmetic.

The smoke test found a fifth unrunnable procedure on its first execution, and it is the one worth
recording. The Cox projection returned `NA` for every ML-NMR row, because a fitted survival curve is
naturally evaluated **on** the administrative cutoff, where the censoring survival is zero, so both
risk sets vanish and the score weight is $0/0$. The analytic caller never meets it because it stops
just short. Nothing about reading the code would have surfaced that; it was found only because the
smoke test asserts all seven rows return a finite value.

`R/12-verify-dgm.R` was found to contain a verifier for the placebo property that had been written and
never called, because it sat below the `saveRDS` that would have stored it. A check that does not run
is the same defect as a procedure that cannot run, in the one file whose whole purpose is running
checks. It is now called, and placebo survival is verified flat to exactly 0 over both families, both
studies and five covariate values.

## 14. Feasibility, measured, and the run frozen

Every number here is measured on this machine, not extrapolated. Round 2 and round 3 both found the
runtime unauditable, and round 3 additionally found that `N_INT` was still `NA` and that section 14
permitted cutting the replicate count without saying to what. Both are closed here: the
configuration is frozen and `R/07-run.R` refuses to start unless it is.

### Measured unit costs

Every figure is wall clock at the stated concurrency, measured on this machine by
`R/11-measure-production.R`, saved to `results/production-timing.rds`, and turned into the budget by
`R/10-budget.R`. **No budget line in this document is typed.** Two of the last two rounds produced a
fatal finding against a hand-written total that did not follow from the unit costs printed beside
it, and the response is to stop writing them by hand rather than to check them more carefully.

| step | measured | how |
|---|---:|---|
| ML-NMR Stan pass at 128 points | **1027.6 s** | 4 replicates, both arms, 2 in flight |
| **per replicate, amortized** | **256.9 s** | $1027.6 / 4$ |
| ML-NMR Stan pass at 256 points | **1769.6 s** | 4 replicates, both arms, 2 in flight |
| **per replicate, amortized** | **442.4 s** | $1769.6 / 4$ |
| ratio, 256 against 128 | 1.72 | measured, not extrapolated |
| one flexible fit at 256 points, alone | 255.1 s | single fit, nothing else running |
| one bootstrap resample, all five frequentist rows | 0.4668 s | one core |
| bootstrap speedup on four cores | 2.10x | measured, not assumed to be 4 |

**The per-replicate figures are AMORTIZED WALL CLOCK, not latency**, and both round-5 reviewers read
them as latency and divided by the concurrency a second time. The raw elapsed time and the replicate
count are printed above so the division is visible: a replicate's *latency* at concurrency 2 is
about twice the amortized figure, and it is the amortized figure that multiplies out to a run's wall
clock. $840 \times 442.4\,\text{s} = 103.2$ hours, with the two-in-flight concurrency already inside
the unit.

Production configuration is 2 chains, 256 integration points, two replicates in flight for the Stan
pass, and one replicate at a time forking over four cores for the frequentist pass. The two passes
are separate (`PASS=freq` and `PASS=mlnmr` in `R/07-run.R`) because two replicates at two chains
each already saturates four performance cores, and a bootstrap running alongside them oversubscribes.

**Every earlier timing this study recorded was inflated, and the cause is worth stating.** An
earlier probe was still running during what was called a production measurement, and it was not
noticed because the check used to confirm a quiet machine grepped for `Rscript` while the process is
named `R`. On a verified-quiet machine a bootstrap resample costs 0.467 s rather than 0.711 s, and a
flexible fit at 256 points costs 255 s rather than 597 s. The measurement script now records the
load average and its own process count alongside every figure.

### The integration order, raised to 256

Measured **paired within replicate**, which matters: orders are separate MCMC runs, and a first
attempt compared them unpaired at an effective sample size where each posterior mean carried a Monte
Carlo standard error of 0.047 against differences of 0.02 to 0.07. Pooled over every paired
replicate the study has paid for:

| contrast | $n$ | mean | SE | $t$ |
|---|---:|---:|---:|---:|
| 128 minus 64 | 4 | $+0.0398$ | 0.0174 | 2.3 |
| 256 minus 64 | 3 | $+0.0656$ | 0.0072 | **9.1** |
| 256 minus 128 | 5 | $+0.0198$ | 0.0129 | 1.5 |

**`multinma`'s default is `n_int = 64L`, and it is measurably inadequate for this estimand.** The
bias is 0.066 months, comparable to the entire bias of the better estimators in the pilot. This is
reported as a result about the package default, and it extends IDN-05's finding in this same
program, which saw 64 to 256 change 8.3% of its DIC verdicts while recording that 256 was not itself
shown to be converged.

**Version 4 registered 128, and that choice rested on a cost figure that was wrong.** It argued that
"256 in production is about 185 hours, so it was never affordable", from the contended 597 s
single-fit timing. Measured at the production configuration on a quiet machine, 256 costs **1.72
times** 128, not the 4.6 the old figure implied: 103.2 hours of Stan against 60.0.

The accuracy argument then decides it. The increments halve with each doubling, $+0.040$ from 64 to
128 and $+0.020$ from 128 to 256, which is what a converging quadrature sequence looks like and
implies roughly 0.02 months still missing at 128. **That is the same size as the entire measured
bias of the flexible estimator rows** ($-0.043$ to $-0.046$ months in the pilot). At 128 this study
could not have distinguished "the flexible methods are nearly unbiased" from "their bias is the size
of my integration error", which is precisely the comparison it exists to make. **256 is registered**,
and a 512-point arm bounds what remains, which is the thing IDN-05 explicitly could not do for its
own reference order.

### The run, frozen

| | |
|---|---|
| distinct parameter cells | 10 |
| cell-by-censoring conditions | 21 |
| how they cross | 3 primary and 2 `ipd-nph` cells at all three conditions (15); 1 control cell at two (2); 2 margin and 2 family cells at `balanced` only (4) |
| replicates per condition | **40** |
| total replicates | **840 replicates** |
| bootstrap resamples | **500 resamples** |
| integration points | **256** |
| Stan pass | 103.2 h |
| frequentist pass | 25.9 h |
| **main run** | **129.1 h**, about 6.2 h per condition |

Version 4 froze this at 14 conditions, 25 replicates and 250 bootstrap resamples per replicate for 24.1 hours, on wall-clock
grounds it stated plainly. That trade was withdrawn on an instruction to prioritize robustness over
schedule, and three of the four increases are justified by measurement rather than by preference:
the replicate count changes the probability that the coverage rule certifies a calibrated estimator
from 0.733 to 0.953 (section 10.3); the integration order removes a bias the size of the effect being
measured; the third censoring condition takes E3's coverage of E1's range from 45% to 87% and makes
it two-sided (`R/00-config.R`). The resample count is the one raised on judgment, because 500 is
where a percentile interval's endpoints stop carrying visible resampling noise and interval coverage
is a registered primary outcome.

**Checkpointing is per replicate, not per cell.** A condition is now about 6 hours, and this machine
has terminated long-running background jobs repeatedly during this design work, including one that
lost three completed integration replicates. `R/07-run.R` writes each replicate as it finishes and
skips completed ones on restart, so the run proceeds as 840 resumable units.

### Sensitivity arms, which round 3 found missing from the budget and round 6 found unrunnable

Registered and costed at their own unit prices rather than mentioned. Round 4 found version 4's
integration arm costed at another order's prices, understating it 2.6-fold.

**Round 6 found something worse: the arms could not have been launched at all.** No two cells were
named, `R/07-run.R` had no sensitivity pass, and the knot count and prior scales the arms exist to
vary were hardcoded inside `fit_flex` and `fit_ph`. That is the fourth registered procedure this
study has found that the code could not perform, after the refit escalation (round 5), the tail-ESS
criterion and the common Cox projection (round 6). The pattern is now explicit enough to name: this
protocol has been read six times as a document and its code has been read, but until `R/15-smoke.R`
nothing executed the document's claims against the code. Prose review does not find this class of
defect, and the six rounds of it here are the evidence.

**The subset, named.** Both cells are `primary` Weibull cells at the `balanced` regime, registered in
`SENS_CELLS` in `R/00-config.R` and resolved against the locked cell table so a typo is an error
rather than a silently empty arm:

| cell | $\kappa_A$ | $\kappa_B$ | why this one |
|---|---:|---:|---|
| primary, balanced | 0 | **0.30** | the most non-proportional target contrast in the design, where spline flexibility, integration order and the auxiliary priors all have the most to do |
| primary, balanced | 0 | 0 | the proportional target contrast at the same margin: the null case for all three arms, which separates "the setting matters" from "the setting matters for non-proportionality" |

They are the endpoints of the registered non-proportionality range, so an arm that moves nothing in
either has been tested where the modeling choice bites hardest and where it does not bite at all.
Fixing the regime at `balanced` keeps each arm varying one thing.

**The settings, one row per fit set.** The count of fit sets is what the budget multiplies and what
`R/07-run.R` iterates, and both read the same `SENS_SETTINGS` table, so they cannot diverge:

| arm | setting | $n_{\text{int}}$ | prior $\times$ | knots | reruns bootstrap | cost |
|---|---|---:|---:|---:|:---:|---:|
| integration | `n_int_512` | 512 | 1 | 3 | no | 10.6 h |
| prior | `scales_halved` | 256 | 0.5 | 3 | no | 6.1 h |
| prior | `scales_doubled` | 256 | 2 | 3 | no | 6.1 h |
| knots | `knots_2` | 256 | 1 | 2 | **yes** | 7.7 h |
| knots | `knots_5` | 256 | 1 | 5 | **yes** | 7.7 h |
| **total** | | | | | | **38.2 h** |

Each fit set runs the prespecified subset at **25 replicates per cell, 50 in total**, which is
`N_SENS` in `R/00-config.R`. Version 5's prose said "50 replicates" on a two-cell subset, which reads
as 100 and contradicted the code; round 5 caught it.

**Round 6 found the arms priced at 22.9 h against a true minimum above 35.** The budget charged one
50-replicate fit set for "halved and doubled" and one for "2 and 5", when each of those is two fit
sets, and the knot arm's frequentist half, which the specification registers explicitly as running
"for both bases", had no line at all. The prior multiplier scales exactly the two families the
specification names, the covariate interaction and the auxiliaries; the intercept and treatment-effect
priors stay at `normal(0, 10)`, because those are not what the arm varies. The knot settings rerun the
Royston-Parmar rows at the **full 500 resamples**, not a reduced count, because interval coverage is a
registered primary outcome and a short bootstrap would make the arm's coverage incomparable with the
production coverage it is read against.

**The sensitivity replicates are the production replicates.** `sens_replicate` calls the same
`sim_for(cell, rep_id)` as the main run, so replicate 7 of the $\kappa_B = 0.30$ cell is the same
network in both, and every arm is paired with its production fit on identical data. The contrast
therefore carries the setting alone and not a fresh draw, which is also why 25 replicates per cell
must stay at or below the production 40; `sens_cells` asserts it.

The 512-point line is priced by extrapolating the measured 1.72 ratio one further doubling and is
labeled as an extrapolation; the arm records its own timings when it runs.

**What the 512-point arm decides, registered in advance.** Let $[L, U]$ be the 95% interval for the
paired $512-256$ difference in $\Delta_{\text{RMST}}(18)$, and let
$M = \max(|L|, |U|)$ be the largest integration error the interval is consistent with. Three branches,
which are exhaustive because they partition on $M$ alone:

1. $M \leq 0.02$ months. The integration error is bounded below the smallest effect the study
   interprets and nothing changes.
2. $M > 0.02$ and the interval excludes zero. The primary ML-NMR results are reported **with the
   measured integration bias stated alongside every ML-NMR absolute bias**, and any conclusion resting
   on a difference smaller than that bias is withdrawn.
3. $M > 0.02$ and the interval contains zero. **Inconclusive**, and reported as such: the arm has not
   demonstrated a bias, but neither has it bounded one below 0.02. Every ML-NMR conclusion resting on
   a difference smaller than $M$ is labeled as not separated from residual integration error, and the
   arm's replicate count is reported as the reason the bound is loose rather than the bound being
   presented as a result.

Round 6 found the version-5 rule had only branches 1 and 2, so an interval such as $[-0.03, 0.01]$
fell through both and the arm could have finished with no registered interpretation; "its magnitude"
was also undefined for an interval, which is what $M$ now fixes. The primary analysis is not
re-registered at 512 under any branch, because re-registering an order after seeing the results is how
a sensitivity arm becomes a selection mechanism.

### Failure handling

A fit failing the sampler policy is refit once at doubled iterations with `adapt_delta = 0.99`; a
fit failing twice is recorded as a failure, not dropped, and the primary analysis is repeated on the
subset where every fit passed.

**The refit escalation is costed**, which round 4 found it was not. Version 4 described the
contingency and gave it no budget line, which is exactly the unfrozen contingency the freeze exists
to eliminate. The budget carries **20% of fits** at doubled iterations, which is **41.3 hours** at
the frozen configuration and is included in the total below. The rate is not assumed to be 20%: the
integration probe returned 45 divergent transitions on one replicate and 0 to 8 on the rest, so the
**observed rate is reported against the assumption**.

**Round 6 found the version-5 rule was neither implementable nor right, and it is replaced rather
than implemented.** It said that if the observed rate exceeds the cap, "the excess fits are recorded
as failures and the all-passed subset analysis carries them". `fit_mlnmr` has no counter and the
ML-NMR pass runs under `mclapply`, so no worker can know a global rate; that is the implementability
half. The substantive half is worse: the rule discards *valid converged fits* in order to hold a
schedule number, and which fits get discarded depends on the order they happen to finish in. A
budget assumption is not a scientific criterion and must not be allowed to select the analysis set.

**The registered rule is therefore: 20% is a budget assumption, not a policy that fires.** Every fit
that fails the sampler policy is refit exactly once, whatever the running total. No fit is ever
reclassified to protect the budget. The realized refit rate is reported beside the assumed 20%, and
if it exceeds it the run costs more and the overrun is reported. The `refit` flag that
`fit_mlnmr` already records is what makes the realized rate observable rather than inferred.

### The total

| | |
|---|---|
| main run | 129.1 h |
| sensitivity arms | 38.2 h |
| refit escalation, at the 20% budget assumption | 41.3 h |
| **total** | **208.6 h** |

About nine days of compute, stated plainly rather than presented as a headline number with the arms
and contingencies excluded. Round 3 found version 3 quoting a total that omitted arms it had just
registered; that is not repeated. The main run is the part that must complete; the arms and the
refit cap are separately resumable and separately reportable.

**Every total here is the sum of its rounded components, not a rounded sum.** Round 6 found the arms
table printing $10.6 + 6.1 + 6.1$ against a total of 22.9. Both were correct in their own terms, which
is precisely the problem: a reader checking a registered budget by adding up its own column is doing
the thing that has caught two fatal errors in this protocol, and a column that does not reconcile
punishes them for it. The tenth of an hour lost to rounding is worth less than the column adding up.
