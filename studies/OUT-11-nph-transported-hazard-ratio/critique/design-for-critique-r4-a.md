# THE OPEN PROBLEM (catalog entry OUT-11, key sections)

## Statement

The transported hazard ratio remains the default reported quantity in survival indirect comparisons, and on the marginal scale it can be population-dependent and time-varying through risk-set selection, while under non-proportional hazards a fitted Cox coefficient is a censoring- and event-weighted constant summary of a time-varying contrast. A conditional hazard ratio under a proportional-hazards model is constant by definition, so the instability belongs to the marginal scale or to non-proportionality rather than to the coefficient as such. The recommended alternatives are not missing from software: multinma has shipped survival models since 0.6.0 with predict() types including survival, hazard, cumulative hazard, mean, median, quantile and restricted mean survival time, marginal_effects() returns RMST and survival-probability differences standardized to a target population, and auxiliary parameters can be stratified by treatment to relax proportional hazards. The gap is between available methods and prevailing practice, and in the absence of any simulation benchmark comparing these estimators against proportional-hazards MAIC and STC under crossing hazards and differential censoring.


# ROUND FOUR OF PRE-RUN CRITIQUE, PART 1 OF 2

Rounds 1, 2 and 3 all returned `unsound` or `needs-revision`. Nothing has been
simulated. Round 3 returned ten fatal findings from one reviewer, and every one
was checked against the document or the source before being accepted; all held.
Two were bugs in the study's own code, not in its prose:

  1. The STC rows stored Gauss-Hermite weights and never applied them. Equal
     weighting of 32 nodes implies a covariate SD of 5.568 against a target of
     1.000 (checked: E[S] 0.4609 equal-weighted against 0.4753 both correctly
     weighted and by 4,000,000-draw Monte Carlo). This invalidated the pilot and
     with it a bias the protocol had REGISTERED as an anticipated mechanism.
  2. Forcing STC through MAIC's marginal log-cumulative-hazard graft is invalid
     under the registered DGM and handicapped STC before sampling.

Other round-3 fatals, all accepted: the "aggregate" study was analyzed as IPD;
the decision metric divided out estimator variance so an arbitrarily noisy
estimator passed; kappa_A = 0 quarantined all non-proportionality on the side of
the network where MAIC and STC never act; E1/E2 and N_INT were not in the locked
configuration; the study cannot settle OUT-11 and must say so.

Three further defects were found by MEASUREMENT rather than by review, and are
disclosed because they bear on how much to trust the rest:
  - The replacement decision metric was also killed: a constant "always
    recommend" rule scores 0.0500 against the best estimator's 0.0913.
  - "Four chains cost the same wall clock" was false (166.9 s against 74.1 s).
  - An earlier claim that integration error was "systematic and monotone" was
    two draws of noise; the paired rerun shows +0.063 then -0.007.

THE PROTOCOL IS SPLIT ACROSS TWO REVIEWS BECAUSE OF PAYLOAD LIMITS.
You have SECTIONS 1 TO 8. Judge only what is in front of you; do not
report a section as missing when it is in the other half.

Judge this version on its own terms. Check the text against each claimed fix;
claiming a fix the text does not contain is what this round exists to catch.
Add `round3_resolution` to your JSON for findings this half bears on: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

NEW IN THIS VERSION AND NEVER CRITIQUED: kappa_A as a design factor and the two
ipd-nph cells (including a cell where the target contrast is PROPORTIONAL while
both arms are strongly non-proportional); the corrected STC conditional
transport; the quadrature guard; structural deletion of aggregate individual
covariates; estimation quality as primary with paired contrasts replacing any
threshold; and the frozen budget with N_INT = 128 chosen from a paired
measurement showing the package default of 64 is biased by 0.066 months.

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
| **E1** | The censoring dependence of the transported hazard ratio, computed exactly by quadrature and root-finding across all four censoring regimes | none |
| **E2** | Finite-sample behavior of the transported hazard ratio around that limit: whether an analyst at realistic sample sizes can distinguish the regimes | minutes |
| **E3** | The benchmark: six estimators on a common target-population estimand | the whole budget |

**What E1 and E2 compare, stated precisely**, because round 3's second reviewer was right that
version 3 was loose about it. Both evaluate the hazard ratio that a **head-to-head trial of B
against A in the target population** would report: `cox_limit(A, B)` analytically in E1, and a
simulated two-arm Cox fit in E2. That is deliberately not an indirect comparison. It isolates the
censoring dependence of a reported constant hazard ratio from any transport or population-adjustment
error, which is the only way to size the one without contaminating it with the other. The quantity
is the estimand an anchored indirect comparison is trying to recover, and E3 is where the recovery
itself is tested.

The one place E1 uses the two legs separately is the D3 plug-in calculation, which applies each
leg's reported hazard ratio to the target placebo curve and differences them. That is done because
it is what an analyst does with an anchored indirect comparison, not because least-false parameters
decompose across legs; they do not, and the protocol does not claim they do.

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

Round 3 was right that version 3 left this experiment as prose: it named neither its family, nor
its $\beta_B$, nor its $\gamma$, nor its treatment contrast. All of it is now in `R/00-config.R`
alongside E1's grids, which were likewise only function defaults.

Registered: Weibull; $\kappa_A = 0$; $\kappa_B \in \{0, 0.15, 0.30\}$; $\gamma = 0.30$; $\beta_B$
solved to the same registered `recommend` margin as E3, so the truth is the same 0.75 months; 200
per arm, the benchmark's own aggregate-study arm size; **all four censoring regimes**; 1,000
replicates per cell per regime.

Each replicate fits an unadjusted Cox model in the target study, nothing else, so the experiment
costs `coxph` fits and runs in minutes. Reported: the scatter of the estimate around its E1
analytic limit, and the power of a paired test to distinguish the reference regime from each other
regime at realistic sample sizes. This is the part the theorem does not give, and it is the only
part of the censoring story that needs simulation at all.

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
analysis is what MAIC produces and it has no conditional model to transport instead. The resulting
approximation error under a different baseline is a property of the method and is reported as one
rather than engineered away.

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

Registered by `build_cells()` in `R/04-calibrate.R`. Fourteen cells, 40 replicates each, **560
replicates**. This table is checked against the code's own export by
`review/verify-protocol.py`, which caught it stale when $\kappa_A$ was added.

| arm | family | $\kappa_A$ | $\kappa_B$ | $\gamma$ | true $\Delta_{\text{RMST}}(18)$ | $\beta_B$ | censoring |
|---|---|---:|---:|---:|---:|---:|---|
| primary | Weibull | 0.00 | 0.00 | 0.30 | 0.75 | $-0.4140$ | balanced, differential |
| primary | Weibull | 0.00 | 0.15 | 0.30 | 0.75 | $-0.2706$ | balanced, differential |
| primary | Weibull | 0.00 | 0.30 | 0.30 | 0.75 | $-0.1431$ | balanced, differential |
| margin | Weibull | 0.00 | 0.00 | 0.30 | 0.35 | $-0.3255$ | balanced |
| margin | Weibull | 0.00 | 0.30 | 0.30 | 0.35 | $-0.0505$ | balanced |
| control | Weibull | 0.00 | 0.00 | 0.00 | 0.75 | $-0.4223$ | balanced, differential |
| **ipd-nph** | Weibull | **0.30** | 0.00 | 0.30 | 0.75 | $-0.6984$ | balanced |
| **ipd-nph** | Weibull | **0.30** | 0.30 | 0.30 | 0.75 | $-0.4383$ | balanced |
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

