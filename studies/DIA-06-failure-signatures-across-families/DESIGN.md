# DIA-06 design: how each estimator family dies as overlap goes

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**DIA-03 answered part of this and named the rest.** It compared two estimator
families and no adjustment on identical replicates, under a continuous outcome
with an identity link, and said: ML-NMR, NMI, doubly robust estimators and
flexible learners are absent, and nothing transfers to non-collapsible effect
measures or time-to-event outcomes, where part of the error is a collapsibility
artifact rather than an adjustment failure.

It also proved something this design is built on. **ESS/n = 1/(1+CV²(w))
exactly**, and area under the ROC curve is invariant to monotone transformation,
so three members of the standard diagnostic panel are one statistic. That
identity is not a curiosity here; section 2 shows it is exactly the functional
that governs one failure mode and is blind to the other.

---

## 1. The claim, restated as something that can be false

Three large factorials have already mapped where MAIC stops paying: Phillippo et
al. 2020, Remiro-Azócar et al. 2021 over 162 scenarios, and Liu et al. 2025 over
729. The catalog does not dispute them. Its claim is narrower and sharper: **no
study characterizes and contrasts the failure *signatures* of weighting,
outcome-model and machine-learning estimators as overlap deteriorates, or reports
whether those failures are visible in any diagnostic an analyst would report.**

**Proposition under test:** the families fail in qualitatively different ways
that no single performance measure orders, weighting by variance explosion and
outcome models by silent extrapolation, and the reported diagnostics see only the
first.

**Refuting sentence:** *the failure onsets coincide on a common axis, so a single
overlap statistic orders all families and the extra arms add nothing to the
existing factorials.*

## 2. The mechanism, algebraically

Let $r(x) = f_T(x)/f_S(x)$ be the density ratio from source to target. Both
failure modes are functionals of $r$, and they are different functionals. That is
the whole design.

**Weighting.** MAIC weights estimate $r$ up to the matched moments. The variance
of a weighted mean is governed by the second moment of the weights, and

$$\frac{n}{\mathrm{ESS}} \;=\; 1 + \mathrm{CV}^2(w) \;=\; \mathbb{E}_S[r^2] \;=\; \chi^2(F_T \,\|\, F_S) + 1 .$$

So **the effective sample size is the chi-square divergence**, and DIA-03's
identity is that statement. Weighting's failure is a *variance* functional and it
is exactly what the diagnostic measures. It diverges when $F_T$ has mass where
$F_S$ has little, and it does so before support is formally violated.

**Outcome modeling.** An outcome model incurs no variance penalty for poor
overlap. Its error is

$$\int \{\hat\mu(x) - \mu(x)\}\,dF_T(x)$$

which is small wherever $\hat\mu$ is fitted well and grows with the **mass of
$F_T$ outside the region $F_S$ constrains**, multiplied by the curvature of the
true surface there. This is a *bias* functional, it is governed by the tail of
$r$ rather than by its second moment, and **nothing in the weight-based panel is
a function of it**, because the outcome model does not produce weights.

**The prediction that follows.** Order the grid by $\chi^2(F_T\|F_S)$. Weighting's
error onset is a fixed function of that axis. The outcome model's onset is *not*,
and moves with the curvature of the true surface at fixed divergence. Therefore:

1. A single overlap statistic cannot order both families, which is the catalog's
   claim made testable.
2. Increasing curvature at fixed divergence moves the outcome model's onset and
   leaves weighting's where it is. **That is a manipulation the existing
   factorials cannot perform**, because they vary overlap and effect-modification
   strength together and never hold divergence fixed while moving curvature.
3. Doubly robust estimators inherit the *variance* functional through their
   weighting component, so they should track weighting's onset, not the outcome
   model's, despite being described as robust. If they do not, that is the most
   interesting result available here.
4. Flexible learners have no explicit functional form, so their extrapolation is
   set by regularization. Their onset should sit between the two and move with
   the penalty rather than with the design, which makes them the one family whose
   failure is not a property of the data.

**On a non-collapsible scale one more term appears**, and DIA-03 named it: part
of the error is a collapsibility artifact rather than an adjustment failure.
Marginal and conditional effects differ by a factor depending on the target
covariate spread, so an estimator targeting the conditional effect and one
targeting the marginal effect differ even with perfect overlap. That gap is
computed and **subtracted before onsets are compared**, or every family's
signature is contaminated by the same nuisance.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, on the log odds
ratio scale for the binary arm and as an RMST difference for the survival arm.

**True value.** By quadrature over the true target law with the true outcome
surfaces, at an order fixed by probe P1. The conditional-scale truth is computed
alongside so the collapsibility gap in section 2 can be subtracted rather than
assumed negligible.

**Failure onset is a derived estimand and needs its own definition.** For each
family, the smallest $\chi^2$ divergence at which the family's absolute error
exceeds a declared material threshold in at least half of replicates. The
threshold is set in probe P2 from the decision context, not chosen round, and the
onset is estimated by isotonic regression across the divergence grid so it is a
monotone summary rather than the first cell that happens to cross.

## 4. Data-generating mechanism, and what it makes invisible

**The existing factorials are held fixed and extended, not replaced.** The
covariate structure, sample sizes and effect-modification levels are Phillippo et
al. 2020's, so results are comparable to the published benchmark rather than to a
new mechanism. What is added is the divergence axis, the curvature axis, and the
estimator arms.

### Factors

| factor | levels | why |
|---|---|---|
| $\chi^2$ divergence | 6 levels, complete to near-disjoint, spaced evenly in $\log(1+\chi^2)$ | the common axis; spacing is in the statistic, not in a mean shift, so the axis means the same thing at every level |
| surface curvature | linear; moderate; strong, at fixed divergence | **the manipulation that separates the two functionals**, and the one no existing factorial performs |
| outcome scale | continuous identity; binary logit; survival RMST | the two non-collapsible cases DIA-03 could not reach |
| effect-modification strength | 3 levels from the benchmark grid | comparability |
| source size | 2 levels | variance onset scales with it; bias onset does not, which is a second separating prediction |

Cell count fixed by P2.

### What the mechanism makes true, and therefore what the study cannot see

- Divergence is manipulated through the covariate law, so the target population
  changes across the axis. The estimand therefore changes too, and every
  comparison is within a divergence level and never across one. **A curve of
  error against divergence is not a curve of one estimand.**
- Only two covariates are effect modifiers and both are measured. Missing
  modifiers are DIA-08's and COV-01's subject; adding them here would confound
  the extrapolation signature with an omitted-variable bias that has no support
  dependence at all.
- The outcome models are correctly specified in the linear-curvature arm by
  construction, so that arm measures variance behavior only. That is deliberate:
  it is the null control in section 8.
- Anchored comparisons throughout. Unanchored PAIC has a different bias structure
  and is QBA's subject.

## 5. Methods, including one that can win

| family | method | role |
|---|---|---|
| none | unadjusted indirect comparison | the floor the factorials found MAIC falls below |
| weighting | MAIC, method of moments, robust SE | the variance functional |
| outcome model | STC, marginalized by simulation | the bias functional |
| outcome model | ML-NMR (`multinma`) | integrates rather than centers; a distinct extrapolation behavior and absent from DIA-03 |
| doubly robust | augmented weighting with the same two components | section 2 prediction 3 |
| flexible | outcome surface by gradient boosting, with the weighting component unchanged | section 2 prediction 4; absent from this literature entirely |

**The comparator that can win is the doubly robust estimator.** If its onset is
strictly later than both single-component families across the divergence axis,
the practical recommendation is straightforward and the study's "no single winner"
framing is wrong. Registered as the outcome that would most weaken the expected
headline.

**One arm is deliberately limited.** The catalog's own note says adding doubly
robust and flexible learners makes a one-week study unrealistic. Only one
flexible learner is fitted, with a fixed tuning protocol declared in advance, and
the study claims nothing about flexible learners as a class. That restriction is
stated in the abstract, not buried.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, empirical SD, RMSE, coverage, interval width, and convergence rate per
family per cell, each with MCSE. The collapsibility gap reported separately.

**The signature measures**, which are what distinguishes this from the existing
factorials: onset of bias, onset of variance inflation, and the ratio of the two,
per family. Plus, for each reported diagnostic, whether it crosses its
conventional threshold before or after the family's own onset. **A diagnostic
that fires after the error has arrived is not a warning.**

Common random numbers across families within a cell, so differences are paired.
**MCSE is clustered on the replicate block accordingly.**

$n_{sim} = 2000$ per cell for the non-Stan arms, from a coverage MCSE target of
0.005. The ML-NMR arm runs at a reduced replicate count set by P4 and its MCSE is
reported at that count rather than at the nominal one; a shared $n_{sim}$ quoted
for arms that did not all run it is the kind of label-value mismatch that has
produced repeated findings in this program.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The failure onsets by family on the common divergence axis,
under strong curvature, on the binary scale.

**Decision rule.**

- If the onsets separate by more than one divergence level between the weighting
  and outcome-model families, **and** that separation moves with curvature at
  fixed divergence, the catalog's claim is confirmed with the mechanism
  identified.
- If the onsets coincide within one level at every curvature, the claim is
  **refuted** and the existing factorials are sufficient.
- If they separate but do not move with curvature, the separation is real and the
  mechanism in section 2 is wrong. Reported as such, with the alternative not
  invented after the fact.

**The diagnostic rule, registered separately.** For each family, the reported
diagnostic panel must reach sensitivity 0.80 at specificity 0.50 for that
family's own onset. DIA-03 found no fixed cutoff met that requirement for
weighting; the question here is whether the outcome-model families do worse, and
section 2 predicts they do because no member of the panel is a functional of
their failure mode.

## 8. Three controls, each of which can fail

**Null control.** At complete overlap, every family must be unbiased and nominal,
and no onset may be declared. Any family that fails here is misimplemented and
its results are withdrawn rather than interpreted.

**Positive control.** In the linear-curvature arm the outcome models are
correctly specified, so their bias onset must be **absent** across the whole
divergence axis while weighting's variance onset is present. If the outcome
models degrade there too, the extrapolation mechanism is not what is driving them
and section 2 prediction 2 fails before the primary is examined.

**Falsifier for the study's own headline.** The expected headline is that the
diagnostic panel is blind to outcome-model failure. Its falsifier is a fitted
diagnostic built from the outcome model itself, the mass of $F_T$ outside the
source's fitted leverage region, included in the panel. **If that one works, the
right conclusion is "the panel is incomplete", not "diagnostics cannot see it",
and those are different papers.** DIA-03 found the analogous constructed
statistic beat the standard panel and missed its registered margin; that near
miss is reported the same way here.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Comparing families on a measure that favors one | Onsets defined per family on a common axis; no single winner declared from a single measure | removed |
| Collapsibility gap read as adjustment failure | Computed against the conditional truth and subtracted before onsets compared | removed |
| Divergence axis confounded with the estimand | Comparisons within level only; stated in section 4 | disclosed, unavoidable |
| Flexible learner tuned until it wins or loses | Tuning protocol declared before the run; one learner only; class-level claims disclaimed | removed |
| Reproducing the existing factorials rather than extending them | Benchmark grid held fixed; only the axis and arms added | removed |
| ML-NMR run at fewer replicates than the rest | Reported at its own count with its own MCSE | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Marginal and conditional truths, and the collapsibility gap per cell | The definition of truth; a gap larger than the material threshold makes the subtraction load-bearing rather than cosmetic | minutes |
| **P2** divergence calibration | The covariate-law parameters giving evenly spaced $\chi^2$, and the material threshold from the decision context | The whole grid. **The axis has to be the statistic, not a proxy for it**; a grid spaced in mean-shift units would not be a divergence axis at all | hours |
| **P3** onset estimability | Whether the isotonic onset is estimable at $n_{sim}$, by simulating a known onset and recovering it | The replicate count, or the onset definition | hours |
| **P4** unit cost | Per-replicate wall clock per family, especially ML-NMR and the learner; the total, computed not typed | The ML-NMR replicate count and possibly the grid | hours |

## 11. Cost

Unmeasured until P4. The ML-NMR arm dominates and is the reason its replicate
count is separate. The boosting arm's cost is per-fit and is measured, not
assumed cheap; OUT-11 called a resampling step cheap without measuring it and it
then dominated the run.

---

## Relationship to the rest of the queue

- **DIA-03** owns the diagnostic panel scored as classifiers and its ESS identity
  is imported. This study adds the families and scales DIA-03 named as missing.
- **OVL-01** owns weak overlap leaving target regions unsupported, which is the
  same axis viewed as an identification question rather than an estimator
  comparison.
- **MOD-09** asks when ML-NMR should be preferred to MAIC or STC, which is the
  decision this study's onset map would inform.
- **DIA-07** owns network topology in scenario grids, which this design holds
  fixed at two trials.
- **ADJ-04** owns flexible outcome surfaces and support diagnostics in
  standardization, and is the natural home for a serious treatment of the
  learner arm this study deliberately keeps to one method.
