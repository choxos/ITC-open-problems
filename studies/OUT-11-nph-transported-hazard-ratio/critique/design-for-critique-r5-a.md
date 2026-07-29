# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART A OF 7: the problem, the data-generating mechanism, and the estimand

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

