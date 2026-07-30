# SFW-10 design: the variance that stacks, and the estimand trimming silently changes

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note says this entry is too bundled for one study, that the variance
comparison is the cleanest early experiment, and that trimming requires an
explicitly defined post-trimming estimand. **This design takes those two and drops
the rest**, and the rest is genuinely droppable: several disclosures the source
asked for already exist in the release. The bootstrap re-estimates weights inside
each IPD resample, the anchored path perturbs the published comparator effect by
its standard error, scaled and unscaled weights are exposed, the survival effect is
labeled as a hazard ratio, and the unanchored bootstrap documents its assumption
about the comparator population.

Two corrections in the entry also shape the design. **Treating estimated weights as
fixed does not invariably understate variance**; the direction depends on the
design. And **simple trimming changes calibration and the effective target without
producing a clean ATT estimand.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** MAIC weights are estimated, so a variance ignoring the
weight-estimation step is wrong in a design-dependent direction; no released
estimator stacks the outcome and weighting estimating equations; and trimming
changes the calibration and the population actually estimated, with no agreed rule
to implement.

**Refuting sentence:** *the published variance guidance already identifies an
estimator that performs well across the realistic range, so stacking adds
complexity without adding coverage.*

**That refutation has real support.** Chandler and Proskorovsky compared four
families across 108 scenarios and found ESS-weighted conventional estimators
accurate across most scenarios, with sandwich estimators downward-biased at small
ESS and finite-sample adjustment markedly improving them. **A stacked estimator
must beat that, not merely beat the naive one.**

## 2. The mechanism: two derivatives, and the missing one has a sign

MAIC solves for weights $\hat\alpha$ from the calibration equations and then
estimates the effect $\hat\Delta$ from a weighted outcome equation. Stacking gives

$$\begin{pmatrix} g_1(\alpha) \\ g_2(\Delta, \alpha)\end{pmatrix} = 0, \qquad
\mathrm{Var}\begin{pmatrix}\hat\alpha \\ \hat\Delta\end{pmatrix} = A^{-1} B A^{-\top},$$

with $A$ block lower-triangular. The variance of $\hat\Delta$ then carries a term
$\partial g_2/\partial\alpha$ that a fixed-weight sandwich omits entirely.

Three consequences:

1. **The omitted term's sign is not fixed.** It is a covariance between the
   outcome score and the calibration score, and it can be positive or negative
   depending on whether the outcome and the balancing covariates are aligned.
   **So the entry's correction is right and it is derivable**: treating weights as
   fixed does not invariably understate variance. **A design that assumed
   understatement would be unable to detect the cells where the naive variance is
   conservative**, and those are the cells where the current guidance is safest.
2. **The term vanishes when the outcome is uncorrelated with the balancing
   covariates**, which is the null control, and grows with effect-modification
   strength, which gives the design its axis.
3. **Trimming is not a variance question at all.** Removing weights above a
   threshold breaks the calibration equations, so the weighted sample no longer
   matches the target moments. **The estimand becomes the effect in whatever
   population the trimmed weights do match**, which is not the declared target and
   is not the ATT either. **So a trimmed analysis must report the population it
   actually estimated**, and that population is computable: it is the covariate
   distribution induced by the trimmed weights.

**Consequence 3 turns the trimming half from a rule-choosing exercise into a
reporting requirement**, and it is what makes an explicitly defined post-trimming
estimand possible rather than merely demanded.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect at the declared
target, by quadrature at an order fixed by P1.

**The post-trimming estimand is a second quantity with a computable truth:** the
marginal effect in the population induced by the trimmed weights, obtained by
integrating the true conditional model over that induced covariate distribution.
**Both are computed for every trimmed analysis**, so the divergence between the
nominal and the realized target is measured rather than asserted.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| effective sample size | high, moderate, small | where the sandwich is documented to fail |
| overlap | good, moderate, poor | Chandler and Proskorovsky's axis, so results are comparable |
| outcome prevalence | 0.1, 0.3 | binary-outcome behavior at small event counts |
| effect-modification strength | 0, moderate, strong | **section 2 consequence 2**, the size of the omitted term |
| alignment of outcome with balancing covariates | positive; negative | **section 2 consequence 1**, the sign of the omitted term |
| trimming | none; 99th percentile; 95th percentile | the second half |

**The alignment factor is the design's own contribution** and no prior variance
comparison includes it; without it the sign question in consequence 1 cannot be
answered.

### What the mechanism makes true, and therefore what the study cannot see

- **The variance question is scoped to MAIC.** Other estimators have different
  nuisance structures.
- Target summaries are exact. **Whether they should carry uncertainty depends on
  the inferential framework**, the entry says so, and EST-07 and MIS-03 own it;
  the package conditions on them without saying that is a choice, and this design's
  recommendation includes saying it.
- The remaining bundled items, parallel bootstrap, weight scaling, reporting
  expansion, are engineering rather than method and are out of scope, per the note.
- One outcome type per arm; survival is carried at one setting only.

## 5. Methods, including one that can win

| variance method | role |
|---|---|
| conventional raw-weight | the family found to understate at poor overlap |
| **ESS-weighted conventional** | the family found accurate across most scenarios; the comparator that can win |
| sandwich, unadjusted | documented downward-biased at small ESS |
| sandwich, finite-sample adjusted | documented markedly improved |
| **stacked estimating equations** | the missing estimator, over outcome and calibration equations |
| bootstrap, weights re-estimated | what the package already does |

**The comparator that can win is the ESS-weighted conventional estimator**, and it
is registered as such because the published evidence favors it. **A stacked
estimator that merely matches it has not earned its complexity**, and the decision
rule in section 7 says so.

## 6. Performance measures, MCSE, and $n_{sim}$

Empirical SD, mean estimated SE, their ratio, and 95% coverage per variance method
per cell, with MCSE. **The ratio is the primary variance measure** because coverage
conflates variance error with any bias.

**The sign check for consequence 1:** the direction of the naive-versus-stacked
variance difference, reported by alignment level. **A consistent sign across
alignment levels would refute the derivation.**

**For trimming:** bias and coverage against **both** estimands; the divergence
between the nominal and realized target populations, as a standardized difference
on the balancing covariates; and the calibration loss, meaning the residual
imbalance the trimming introduces. **All three are what the entry asks a trimming
implementation to disclose**, and they are computed here so a default warning can
be written from evidence rather than from Remiro-Azócar's single quantification.

$n_{sim} = 4000$ per cell, derived from resolving a coverage shortfall of 2 points.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The ratio of mean estimated SE to empirical SD for the stacked
estimator against the ESS-weighted conventional estimator, at small ESS with strong
effect modification, in both alignment directions.

**Decision rule.**

- Stacked within 0.95 to 1.05 in every cell where the ESS-weighted estimator is
  not: the stacked estimator is established and the deliverable is the
  implementation.
- ESS-weighted within band wherever stacked is: **the refuting sentence holds**,
  the published guidance is sufficient, and the recommendation is to adopt it
  rather than to build a sandwich. **That is a real possibility and it would save
  the field effort.**
- Both failing at small ESS: the problem is the small-sample regime rather than
  the estimator, and finite-sample adjustment is the answer, which the published
  comparison already suggests.

**Trimming is decided separately:** the deliverable is the post-trimming estimand
report, and it is produced whatever the variance comparison shows.

## 8. Three controls, each of which can fail

**Null control.** With no effect modification and outcome uncorrelated with the
balancing covariates, section 2 consequence 2 makes the omitted term **zero**, so
naive and stacked variances must agree to Monte Carlo error. **This is the exact
test that the stacked estimator reduces correctly**, and a difference means it is
misimplemented rather than better.

**Second null control.** With no trimming, the nominal and realized estimands must
coincide identically and the calibration residual must be numerically zero.
**DIA-03 established that residual balance on matched moments is identically zero
at the solution**, so this reproduces a known identity as a harness check.

**Positive control.** At small ESS with strong modification, the naive variance
must be materially wrong in **at least one** alignment direction. If it is fine in
both, the omitted term is unreachable and the stacked estimator has nothing to fix.

**Falsifier for the study's own headline.** The expected headline is that stacking
is needed. Its falsifier is the published guidance itself: the ESS-weighted
estimator is registered as the comparator that can win, and **the design gives it
the same cells and the same measures rather than comparing stacking only against
the estimator already known to fail.** Comparing against the naive sandwich alone
would have made the result inevitable.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Repeating disclosures the release already makes | Listed in the header as already present; out of scope | removed |
| Assuming fixed weights always understate variance | Sign is a registered outcome; alignment is a factor | removed |
| Comparing stacking only against the known-bad estimator | ESS-weighted registered as the comparator that can win | removed |
| Trimming treated as a variance problem | Post-trimming estimand defined and computed | removed |
| Trimming rule chosen without evidence | Two thresholds, both reported against both estimands | removed |
| The bundled engineering items | Out of scope per the note | disclosed |
| Target-summary uncertainty | Held exact; the recommendation includes declaring it is a choice | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Both estimands' truths per cell | The definition of the post-trimming estimand | hours |
| **P2** benchmark reproduction | That the harness reproduces Chandler and Proskorovsky's reported ordering of variance families on their own scenarios | **Everything.** A variance study that cannot reproduce the published comparison is measuring its own harness | days |
| **P3** stacked derivation check | That the stacked variance reduces to the naive one under the null control analytically and numerically | Whether the estimator is correct | days |
| **P4** unit cost | Per-replicate cost at $n_{sim}=4000$ across six variance methods; total computed not typed | $n_{sim}$ | hours |

**P2 is the one that would be skipped and it is what lets this study speak to the
published guidance rather than past it.**

## 11. Cost

Weighting fits at 4000 replicates across six variance methods; the bootstrap arm
dominates and its resample count is the multiplier priced in P4.

---

## Relationship to the rest of the queue

- **DEC-11** adopts the published variance guidance and owns what else belongs in
  an interval; this design supplies the stacked estimator that guidance lacks.
- **OVL-02** owns feasibility and the diagnostic battery; trimming's calibration
  loss is a battery item.
- **EST-07** and **MIS-03** own target-summary uncertainty, held exact here.
- **SFW-12**, **SFW-13** and **SFW-14** own the other software entries; a
  post-trimming estimand report is a structural disclosure the Ishak et al.
  framework would carry.
