# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART FULL OF 7: the complete protocol

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

# Protocol: what a transported hazard ratio summarizes, and how the recommended replacements behave

Registered before any replicate of the reported run. Catalog problem **OUT-11**.

This is the **fourth** version. Three rounds of adversarial pre-run critique preceded it, and each
returned `unsound` or `needs-revision`. Round 1 found a fatal algebraic error in the data-generating
mechanism that the design's own calibration run had missed. Round 2 returned three fatal findings.
Round 3 returned ten, including **a bug in this study's own code**. Every allegation was checked
against the document or the source before being accepted, and every fatal one held. Section 13
records each finding and its resolution. Nothing has been simulated at any point, so nothing has
been discarded except time.

Three things belong at the top, because they are why this version exists.

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
Giving leg A the target baseline understated its own censoring spread, 16.08% against 17.27%.

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
cell, matched follow-up moves D3 by 0.0868 months while crossed follow-up moves it by 1.3805, a
factor of 16, because when both legs are followed alike their movements largely cancel in the Bucher
difference. Version 4's design would have reported that cell as one of the safest in the study.

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

This solves **one leg**. The reported quantity is the Bucher difference of two such roots, each
evaluated **in its own study**, under its own baseline hazard and its own censoring:
$\hat\beta_{B/A} = \beta^*_{B/\text{PBO}}(\bar G_2) - \beta^*_{A/\text{PBO}}(\bar G_1)$.

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

- $\gamma = 0$ **and** $\kappa_B = 0$ gives zero movement (computed: $2.6\times10^{-9}$).
- $\gamma > 0$, $\kappa_B = 0$, covariate spread collapsed to zero gives zero movement (computed:
  $2.1\times10^{-9}$).

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
absolute discrepancy between the simulated mean and the analytic limit is **0.0141** on the log
scale, at most 3.01 times its own Monte Carlo standard error, and the Bucher 95% interval covers
the E1 limit **0.937 to 0.958** of the time against a nominal 0.95. E1 is therefore checked, not
merely asserted. This is emphatically *not* evidence that the interval covers the estimand: a Wald
interval around a least-false parameter is correctly centered on that parameter and on nothing
else, which is the whole problem.

**Could an analyst notice?** The regime-induced shift reaches **0.876 sampling standard deviations
of a single reported estimate**, and it is larger with the two trials' follow-up crossed (0.876)
than matched (0.722). Yet two analysts holding independent evidence sets under different follow-up
would call their anchored estimates significantly different only **10.5%** of the time against a
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
| MAIC marginal graft, Weibull, $\kappa_A = 0$ | $1.1\times10^{-15}$ | $+0.0074$ |
| MAIC marginal graft, Weibull, $\kappa_A = 0.30$ | $8.9\times10^{-16}$ | $+0.0116$ |
| MAIC marginal graft, Gompertz, worst cell | $1.1\times10^{-15}$ | $+0.0061$ |
| STC conditional transport, every cell | $<4\times10^{-15}$ | $<4\times10^{-15}$ |

**The graft costs MAIC at most 0.0116 months**, which is 1.6% of MAIC-PH's measured 0.725-month
pilot bias and 2% of the 0.50-month decision threshold. It is exactly zero when $\gamma = 0$,
confirming that the covariate effect is its only driver. STC's conditional transport is exact to
machine precision in every cell, which the protocol previously asserted and now checks.

So the objection does not bite on this design: the across-row differences cannot be attributed to
the graft, because the graft is two orders of magnitude too small to produce them. The across-row
contrasts remain **descriptive** for the separate and unrelated reason given in section 10.1, that
the matched-flexibility premise was withdrawn in round 2.

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

| $\kappa_A$ | $\kappa_B$ | conditional cross | marginal cross | marginal HR range | PH test rejects |
|---:|---:|---:|---:|---|---:|
| 0.30 | 0.00 | 2.7 | 2 | 0.503 to 2.039 | 0.535 |
| 0.30 | 0.30 | none | none | 0.828 to 0.858 | 0.040 |

The second is the more interesting of the two and version 3 could not express it at all: with
$\kappa_A = \kappa_B$ the **target contrast is proportional while both arms are strongly
non-proportional**. The proportional-hazards test rejects at 0.040, at nominal. A method that reacts
to arm-level rather than contrast-level non-proportionality will be penalized here and should not
be, which is a distinction no other cell in the design can draw.

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

**14 cell-by-censoring conditions at 40 replicates is 560 replicates per estimator.** The standard
error of a pooled coverage estimate near 0.95 is then **0.009**. Restricted to the six primary
cells it is 240 replicates and 0.014, not the 0.011 version 2 printed for a replicate count it was
not using; round 2 caught that arithmetic and it was right.

That resolution is sufficient to certify a calibrated estimator but not to detect mild
miscalibration. Rather than assert otherwise, the decision rule uses a Monte Carlo confidence
interval, has an explicit **inconclusive** outcome, and section 10.3 tabulates the probability of
each verdict under both a calibrated and a miscalibrated truth.

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

## 11. The decision model behind the 0.50-month threshold

A treatment is recommended if its target-population RMST gain over the comparator at 18 months
exceeds the gain that justifies its cost, set at 0.50 months. It is declared before the run and
every conclusion that depends on it is labeled as depending on it. It now enters in exactly two
places: **D3**, where it is the tolerance the plug-in hazard ratio's across-regime range is judged
against, and the **secondary decision-loss appendix** of section 10.0. Version 4 also used it in
D1, which is withdrawn.

**Sensitivity: D3 and the decision-loss appendix are both recomputed at thresholds of 0.40 and 0.60
months** and reported, since the number is a stipulation and not an estimate. D3's verdict is
insensitive to this: its worst range of 1.3805 months exceeds even the 0.60 tolerance by more than
a factor of two, so the failure is not an artifact of where the threshold was set.

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

Round 3, this version. Three reviews: one on the whole protocol, two on halves because the second
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

Round 4, this version. Two reviews, the second split into halves for an input-size ceiling; a third
returned empty and is recorded as not obtained rather than counted as agreement. **Three of the
findings were defects I introduced while fixing round 3**, which is the specific failure this round
existed to catch.

| Finding | Severity | Resolution |
|---|---|---|
| E1 and E2 evaluate a direct head-to-head coefficient, but OUT-11 concerns a transported **anchored indirect** comparison, and least-false Cox coefficients are not transitive under non-proportional hazards | **fatal** | **Confirmed, and version 4 had defended the wrong framing explicitly.** Both experiments rebuilt on the anchored contrast with each leg under its own study's censoring and the two regimes crossed independently. Measured gap between the two quantities: 0.93% to 1.78%, and it varies with censoring. Consequences were large: D3 moves from 0.697 (pass) to **1.3805 (fail)** |
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

| step | measured |
|---|---|
| **one replicate, both ML-NMR arms, 128 points, production config** | **256.9 s** |
| **one replicate, both ML-NMR arms, 256 points, production config** | **442.0 s** |
| ratio, 256 against 128, measured not extrapolated | 1.72 |
| one flexible fit at 256 points, alone | 255.1 s |
| one bootstrap resample, all five frequentist rows, one core | 0.467 s |
| bootstrap speedup on four cores, measured | 2.10x |

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
| replicates per condition | **40** |
| total replicates | **840 replicates** |
| bootstrap resamples | **500 resamples** |
| integration points | **256** |
| Stan pass | 103.2 h |
| frequentist pass | 25.9 h |
| **main run** | **129.2 h**, about 6.2 h per condition |

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

### Sensitivity arms, which round 3 found missing from the budget

Registered and costed at their own unit prices rather than mentioned. Round 4 found version 4's
integration arm costed at another order's prices, understating it 2.6-fold.

| arm | what it varies | cost |
|---|---|---|
| integration | 512 points, bounding what remains at 256 | 10.6 h |
| prior sensitivity | interaction and auxiliary scales halved and doubled | 6.1 h |
| knot complexity | 2 and 5 internal knots | 6.1 h |
| **total** | | **22.9 h** |

Each runs on the same prespecified subset of two primary cells at 50 replicates. The 512-point line
is priced by extrapolating the measured 1.72 ratio one further doubling and is labeled as an
extrapolation; the arm records its own timings when it runs.

### Failure handling

A fit failing the sampler policy is refit once at doubled iterations with `adapt_delta = 0.99`; a
fit failing twice is recorded as a failure, not dropped, and the primary analysis is repeated on the
subset where every fit passed.

**The refit escalation is capped and costed**, which round 4 found it was not. Version 4 described
the contingency and gave it no budget line, which is exactly the unfrozen contingency the freeze
exists to eliminate. The registered cap is **20% of fits**, at doubled iterations, which is
**41.3 hours** at the frozen configuration and is included in the total below. The rate is not
assumed to be 20%: the integration probe returned 45 divergent transitions on one replicate and 0 to
8 on the rest, so the observed rate is reported. If it exceeds the cap, the excess fits are recorded
as failures and the all-passed subset analysis carries them, rather than the budget being revised
mid-run.

### The total

| | |
|---|---|
| main run | 129.2 h |
| sensitivity arms | 22.9 h |
| refit escalation, at its registered cap | 41.3 h |
| **total** | **193.3 h** |

About eight days of compute, stated plainly rather than presented as a headline number with the arms
and contingencies excluded. Round 3 found version 3 quoting a total that omitted arms it had just
registered; that is not repeated. The main run is the part that must complete; the arms and the
refit cap are separately resumable and separately reportable.

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
##   * kappa and gamma belong to SPECIFIC treatments. kappa_A is a DESIGN FACTOR
##     as of version 4 (see KAPPA_A_LEVELS below); it is zero in most cells and
##     0.30 in the two ipd-nph cells. gamma is SHARED between A and B, which is
##     the anchored shared-effect-modifier assumption that MAIC, STC and ML-NMR
##     all require. It therefore holds by construction here, and this study is
##     about the survival-model dimension, not about effect-modifier
##     identification (that is IDN-05).
##
##   * The B-versus-A conditional contrast is
##     beta_B - beta_A + (kappa_B - kappa_A) g(t), with NO covariate term,
##     because gamma cancels. Movement of the reported hazard ratio at
##     kappa_B = kappa_A is therefore pure risk-set selection.
##
##   * The covariate is a PURE EFFECT MODIFIER, not a prognostic factor, and an
##     earlier version of this comment said otherwise. Verified: placebo
##     survival at t = 12 is 0.4356 at x = -2, 0 and +2, because gamma_PBO = 0.
##     A useful consequence is that the aggregate study's placebo arm identifies
##     the target baseline cumulative hazard directly, with no deconvolution.
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
GAMMA   <- 0.30    # shared A and B effect modification; 0 in the marginal-PH control

## KAPPA_A IS A DESIGN FACTOR, AND IN VERSION 3 IT WAS FIXED AT ZERO.
##
## A round-three critique found that kappa_A = 0 in every cell put ALL the
## non-proportionality on the aggregate side of the network, which is the side
## neither MAIC weighting nor STC regression ever touches: both act on the IPD
## study, and both consume the same shared aggregate-side fit for B. So the
## MAIC-versus-STC comparison was never exercised under crossing hazards, which
## is exactly the comparison the catalog entry asks for. That was correct and it
## was not visible from the protocol text alone.
##
## Because gamma is shared, the B-versus-A contrast is
## beta_B - beta_A + (kappa_B - kappa_A) g(t), still with NO covariate term, so
## the property that made the mechanism clean survives. Note that kappa_A =
## kappa_B gives a PROPORTIONAL target contrast built from two NON-proportional
## arms, which is a cell worth having and which version 3 could not express.
KAPPA_A_LEVELS <- c(0, 0.30)
KAPPA_A <- 0.00    # default for the cells that do not vary it

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
##
## THREE CONDITIONS, NOT TWO, AND THE THIRD IS THE MIRROR OF THE SECOND.
##
## Version 4 registered only `balanced` and `differential`, the latter putting
## the heavier censoring on the AGGREGATE study. Checked against E1's full 4x4
## grid, those two conditions span 0.6199 months of the 1.3805 the grid contains,
## which is 45%, and they span it in ONE DIRECTION ONLY: both sit at or above the
## balanced case. E1's minimum, where the IPD study is the heavily censored one,
## was never reachable.
##
## That is a real hole rather than a coverage quibble. With one sign only, every
## estimator's differential-follow-up bias points the same way, and an estimator
## with an offsetting bias reads as accurate. It is the same failure the margin
## cells exist to prevent for the decision rule, one level down. Adding the
## mirror takes coverage to 87% and makes the two departures from balanced
## nearly symmetric, +0.6199 and -0.5794.
E3_CENS <- data.frame(
  label     = c("balanced", "differential", "differential-reversed"),
  rate_ipd  = c(0.010, 0.020, 0.100),
  rate_agd  = c(0.010, 0.100, 0.020),
  t_admin   = c(36,    36,    36),
  stringsAsFactors = FALSE
)

## --- estimation settings ----------------------------------------------------
## Two chains. An earlier version of this file said four, on the reasoning that
## chains run in parallel so four cost the same wall clock. That was asserted,
## not measured, and measuring it showed otherwise: 166.9 s against 74.1 s per
## fit on this machine, because four chains oversubscribe four performance
## cores.
##
## The four-chain choice also rested on the wrong diagnostic. It was made to
## satisfy an ESS floor applied to the GLOBAL minimum over every monitored
## parameter, which runs 25 to 646 and is dominated by weakly identified spline
## nuisance coefficients the study never uses. The registered policy binds on
## the DERIVED estimand, whose ESS was measured above 2000 even at two chains.
N_CHAINS <- 2
N_ITER   <- 1000
## N_INT is NOT set here by citing another study's number. A critique noted that
## the previous draft cited IDN-05's finding that 64 -> 256 integration points
## flipped 8.3% of verdicts and then chose 32, which is below the order IDN-05
## found insufficient. The order is instead MEASURED on this study's own network
## by R/probe-integration.R, comparing the target-standardized RMST difference
## across orders PAIRED WITHIN REPLICATE so the comparison is not swamped by the
## Monte Carlo error of separate MCMC runs.
##
## Measured, pooled over every paired replicate the study has paid for:
##   128 - 64 : +0.0398  SE 0.0174  n=4  t = 2.3
##   256 - 64 : +0.0656  SE 0.0072  n=3  t = 9.1  -> 64 is biased low, decisively
##   256 - 128: +0.0198  SE 0.0129  n=5  t = 1.5  -> not separable from noise
##
## The package default is 64 and it is not adequate for this estimand.
##
## THE ORDER IS 256, AND VERSION 4'S CHOICE OF 128 RESTED ON A COST FIGURE THAT
## WAS WRONG. That version argued "256 in production is about 185 hours, so it
## was never affordable", from a single flexible fit timed at 597 s. That timing
## was taken while another job was running on the same four cores, which nobody
## had checked for. Re-measured at the exact production configuration on a
## verified-quiet machine, a replicate costs 442 s at 256 points against 256.9 s
## at 128: a ratio of 1.72, not the 4.6 the old figure implied. Production at
## 256 costs about 69 hours of Stan rather than 185.
##
## The accuracy argument then decides it. The increments halve with each
## doubling (+0.040 from 64 to 128, +0.020 from 128 to 256), which is what a
## converging quadrature sequence looks like and implies roughly 0.02 months
## still missing at 128. That is the SAME SIZE as the entire measured bias of
## the flexible estimator rows (-0.043 to -0.046 months in the pilot), so at 128
## this study could not distinguish "the flexible methods are nearly unbiased"
## from "their bias is the size of my integration error". At 256 the residual is
## halved again and a registered 512-point arm bounds what is left, which is
## something IDN-05 explicitly could not do for its own 256-point reference.
N_INT <- 256L

## Replicate and bootstrap counts are set from MEASURED cost. THE BUDGET ITSELF
## IS NOT WRITTEN HERE. It is computed in R/10-budget.R from timings measured by
## R/11-measure-production.R and asserted against the protocol by
## review/verify-protocol.py, because a hand-written total that did not follow
## from the unit costs beside it has now produced two separate fatal findings.
##
## Two lessons are worth keeping in the file rather than only in the change log.
##
## FIRST, the arithmetic was wrong in the direction that favored the cheaper
## option. A previous comment claimed "14 cells x 40 reps, 500 resamples ->
## 6.4 h of bootstrap", which implies about 62 resamples per replicate, not 500.
## That understated figure was the number used to argue the counts down.
##
## SECOND, and worse, every timing this study had taken was inflated by machine
## contention nobody had checked for. An earlier probe was still running during
## the "production" measurement and was not noticed, because the process is
## named `R`, not `Rscript`, and the check used to confirm a quiet machine
## grepped for the latter. Re-measured on a verified-quiet machine, a bootstrap
## resample costs 0.467 s rather than 0.711 s, and a flexible fit at 256
## integration points costs 255 s rather than 597 s. The 597 s figure was the
## sole basis for the claim that 256 in production would cost "about 185 hours"
## and was therefore unaffordable, which is how the integration order came to be
## registered at 128.
##
## 40 replicates and 500 resamples are chosen. A previous version chose 25 and
## 250 on wall-clock grounds; that trade was withdrawn once the instruction was
## to prioritize robustness over schedule. 500 resamples is also the point below
## which a percentile interval's endpoints carry visible resampling noise, which
## matters because CI COVERAGE is a registered primary outcome, not a diagnostic.
##
## Pooled over all 14 cell-by-censoring conditions at 40 replicates, the
## coverage rule certifies a genuinely calibrated estimator 95.3% of the time
## against 73.3% at 25 replicates. That is the concrete cost of the cut.
##
## R/07-run.R checkpoints per REPLICATE, not per cell: this machine terminates
## long-running background jobs and a per-cell checkpoint would discard hours of
## finished work each time.
N_BOOT <- 500          # full-pipeline bootstrap resamples, frequentist rows
N_REP  <- 40           # replicates per cell in E3
N_CORES_BOOT <- 4      # the frequentist pass parallelizes; the Stan pass does not

## --- E1 and E2, registered here rather than left as function defaults --------
## A round-three critique found that E1's gamma grid and variance ablation, and
## the whole of E2, existed only as hard-coded defaults inside 04-calibrate.R.
## A preregistration that cannot be executed from its own text is not one, and
## the same objection had already been upheld against the E3 parameters in
## round two. These are the executable versions.

## E1: the computed decomposition. Deterministic; no replicates, no seed.
E1_KAPPA_B <- c(0, 0.15, 0.30)
E1_GAMMA   <- c(0, 0.15, 0.30, 0.50)
E1_FAMILY  <- c("weibull", "gompertz")
E1_SD_ABLATION <- c(1.0, 0.5, 1e-6)   # covariate spread, collapsed to zero last
## E1 uses all four regimes in CENS_REGIMES.

## E2: finite-sample scatter of the ANCHORED transported hazard ratio around the
## E1 limit. Two independent two-arm studies, an unadjusted Cox fit in each, and
## a Bucher difference. No population adjustment and no Bayesian machinery, so it
## costs milliseconds per replicate and can afford many.
##
## Version 4 simulated ONE study comparing B against A directly, which is not the
## quantity OUT-11 is about and which round four identified as a fatal. Least-
## false Cox coefficients are not transitive under non-proportional hazards, so
## the direct coefficient and the anchored difference are different numbers.
##
## kappa_A is crossed here as of version 5. With kappa_A fixed at zero the A leg
## was always proportional, so E2 never measured the sampling behavior of a
## least-false coefficient on the side of the network MAIC and STC act on, which
## is the same defect round three found in the E3 cell matrix.
E2_FAMILY   <- "weibull"
E2_GAMMA    <- GAMMA
E2_KAPPA_B  <- c(0, 0.15, 0.30)
E2_KAPPA_A  <- c(0, 0.30)
E2_MARGIN   <- "recommend"    # beta_B solved to the same registered margin as E3
E2_N_A_ARM  <- N_IPD_ARM      # leg A is the IPD study: 250 per arm
E2_N_B_ARM  <- N_AGD_ARM      # leg B is the aggregate study: 200 per arm
N_REP_E2    <- 2000           # replicates per cell per leg per regime
## E2 crosses the two studies' regimes independently over all four in
## CENS_REGIMES, giving a 4 x 4 grid, exactly as E1 does.

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
