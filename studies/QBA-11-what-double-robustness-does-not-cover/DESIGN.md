# QBA-11 design: two robustness properties that are orthogonal

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog asks for something a simulation can deliver cleanly and that nobody
has published: **an explicit demonstration of which failures double robustness
does and does not cover.** Section 2 shows the answer is a factorization, and the
note's instruction to restrict to one residual-bias model is what keeps the
demonstration decisive rather than diffuse.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** double robustness is a property of the measured-data
layer only; sensitivity analysis for an omitted variable holds the outcome model
fixed, so misspecification of the retained model propagates untouched into every
scenario on the grid; and no published unanchored-PAIC estimator is simultaneously
doubly robust and indexed by explicit residual-bias parameters.

**Refuting sentence:** *at realistic magnitudes the two error sources are small
enough relative to each other that a doubly robust estimator plus a conventional
sensitivity grid is adequate, and the missing combined estimator would change no
conclusion.*

## 2. The mechanism: the two properties multiply, they do not compose

Write the estimator's limit as a function of two things: the measured-data nuisance
models $(\pi, m)$ and the identification condition. The augmented estimator
satisfies

$$\hat\Delta \;\xrightarrow{p}\; \Delta^\star(\gamma) \quad\text{whenever } \pi \text{ or } m \text{ is correct,}$$

where $\gamma$ indexes the failure of conditional data-source ignorability. Three
consequences, and the first is the whole demonstration:

1. **$\Delta^\star(\gamma) \neq \Delta$ for $\gamma \neq 0$ regardless of $\pi$ and
   $m$.** Double robustness delivers the *right functional of the observed data*;
   it does not deliver the causal quantity when the identification condition
   fails. So **the omitted-variable bias is the same for the doubly robust
   estimator as for a correctly specified single-model estimator, to first
   order**, and that is a sharp prediction: the DR and non-DR bias curves in
   $\gamma$ should coincide once both models are correct.
2. **Conversely, at $\gamma = 0$ with one model wrong, DR is unbiased and the
   single-model estimators are not.** So the two properties are orthogonal, and a
   $2\times2$ over (model correctness) × (omitted variable) has a different
   winner in each cell. **That table is the deliverable the catalog asks for**, and
   it is four numbers.
3. **A sensitivity grid built on a misspecified retained model is offset by the
   misspecification bias at every grid point.** The whole sensitivity region is
   translated, so its **width** is right and its **location** is wrong, which is
   the worst case for a tipping-point reading: the tipping point moves while the
   analysis looks unaffected. **That is a prediction about the shape of the error,
   not just its size**, and it is testable.

**Model-form error is not a scalar** and cannot be indexed by a prevalence or an
association, which is why consequence 3 cannot be repaired by widening the grid.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio in an unanchored
comparison, by quadrature at an order fixed by P1.

**The sensitivity region is a second estimand with a defined truth**: the set of
$\Delta^\star(\gamma)$ over the true $\gamma$ range. **Its coverage of the truth is
scored, and separately its location error**, since section 2 consequence 3
predicts the two behave differently under misspecification.

**One residual-bias model only**, as the note instructs: an omitted binary
confounder indexed by its prevalence in each population and its association with
outcome. Everything else about the bias model is fixed, so the demonstration is
attributable.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| weighting model | correct; misspecified | one arm of double robustness |
| outcome model | correct; misspecified (threshold or interaction the linear form omits) | the other |
| omitted-variable strength $\gamma$ | 0, small, moderate, large | **the identification failure, orthogonal to the above** |
| omitted-variable imbalance | small, large | its transport-relevant component |
| treatment interaction with the omitted variable | absent; present | whether the omission is prognostic or modifying |
| overlap | good, poor | the usual axis |

**The $2\times2\times$($\gamma$) core is fully crossed**, because section 2's table
is the deliverable.

### What the mechanism makes true, and therefore what the study cannot see

- **Only one residual-bias mechanism.** Selection on unmeasured prognosis, outcome
  misclassification, target-distribution error and bridge drift are all things
  double robustness is silent about, and the catalog lists them; **this study
  demonstrates the silence for one of them and states that the argument
  generalizes without claiming the magnitudes do.**
- Unanchored comparisons only, following the estimator's own framing.
- Flexible learners are **not** used. The catalog notes they would need
  cross-fitting and extrapolation-aware prediction intervals that no current PAIC
  implementation supplies; including them would confound the demonstration with a
  nuisance-estimation question. MOD-02 owns that.
- Positivity holds in the base arm. **Unsupported target profiles are a positivity
  problem calling for support restrictions, bounds or stated extrapolation
  assumptions**, and treating them as residual bias would be the exact conflation
  this study exists to prevent; a poor-overlap level is carried but is analyzed
  separately.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| MAIC | entropy balancing, no augmentation | the weighting-only estimator |
| outcome regression | conditional model, marginalized | the outcome-only estimator |
| **augmented MAIC** | Campbell and Remiro-Azócar's doubly robust estimator, cross-fitted | the DR estimator |
| **bias-indexed augmented MAIC** | the same functional evaluated at every point of the sensitivity region | **the estimator the catalog says does not exist**, built here as the natural composition |
| `drMAIC` with E-values | the CRAN package's generic screen | included because it is what is available, and the catalog calls it a generic screen rather than the missing estimator |

**The comparator that can win is `drMAIC`'s generic screen.** If its E-value
ordering identifies the analyses that fail as well as the bias-indexed estimator's
region does, then the composition is unnecessary and an available package suffices.
Registered as the outcome most likely to overturn the expected headline.

**The bias-indexed arm is a composition, not new theory**, and the design says so:
the catalog notes that constructing an estimator both doubly robust and indexed by
explicit bias parameters would require redoing the influence-function theory under
a perturbed identification condition, **which this design does not do**. It
evaluates the existing functional at each grid point and reports the measured and
residual layers separately, which is the catalog's own first suggestion and is
achievable; the theory question is named and left open.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE per method per cell, with MCSE, **reported as section 2's
table**: the four (model correctness × omitted variable) cells at each $\gamma$.

**Sensitivity-region truth inclusion and location error**, separately, since
consequence 3 predicts the region translates rather than widens. **Reporting only
inclusion would miss the entire predicted failure**, because a translated region
can still include the truth while its tipping point is wrong.

**Tipping-point error** where a tipping point exists, and the frequency with which
misspecification moves it across a decision threshold.

Common random numbers across methods within a cell; MCSE clustered on the
replicate block. $n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the augmented estimator against the correctly
specified single-model estimator, as a function of $\gamma$, with both nuisance
models correct.

**Decision rule.**

- The two bias curves coinciding **confirms** section 2 consequence 1 and
  establishes that double robustness does not cover omitted variables. **That is
  the explicit demonstration the catalog asks for, and it is a figure.**
- The augmented estimator less biased in $\gamma$ than the single-model one means
  augmentation confers some protection against identification failure, which
  would be a genuinely surprising result and is reported as such rather than
  explained away.
- **The sensitivity-region location error under outcome misspecification is
  reported in either branch**, because consequence 3 is a separate claim with its
  own evidence.

## 8. Three controls, each of which can fail

**Null control.** At $\gamma = 0$ with both models correct, every estimator must be
unbiased and nominal. Failure means the harness, not the theory.

**Second null control, and it is the double-robustness property itself.** At
$\gamma = 0$ with **exactly one** model misspecified, the augmented estimator must
be unbiased while the corresponding single-model estimator is biased, **in both
directions of misspecification**. **A study demonstrating what double robustness
does not cover must first demonstrate that it covers what it claims**, or the
whole comparison reduces to a broken implementation.

**Positive control.** At large $\gamma$ with both models correct, every estimator
must be biased by at least three MCSEs. If the omitted variable does not bite,
there is nothing for the demonstration to show.

**Falsifier for the study's own headline.** The expected headline is that the two
robustness properties are orthogonal. Its falsifier is the interaction cell: if
misspecification and omitted-variable bias **interact**, so that the DR estimator's
$\gamma$-curve differs by model correctness, then they are not orthogonal and
section 2's factorization is wrong. **The full crossing exists to detect exactly
that, and a design that ran only the margins could not.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Double robustness read as protection against residual bias generally | The $2\times2$ table is the deliverable | removed |
| Demonstrating the limitation without demonstrating the property | Second null control requires DR to work where it claims to | removed |
| Region coverage reported without location | Both reported; consequence 3 predicts they differ | removed |
| Positivity failure treated as residual bias | Overlap analyzed separately; stated | removed |
| Flexible learners confounding nuisance estimation with the demonstration | Excluded; MOD-02 named | removed |
| Claiming new influence-function theory | The bias-indexed arm is a composition; the theory gap is named and left open | removed |
| Generalizing from one bias mechanism | The argument is stated as general, the magnitudes as specific | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and $\Delta^\star(\gamma)$ | The true target effect and the estimator's biased limit at each $\gamma$, analytically where possible | **The primary outcome's comparison**, which is against a computed limit and not only against the truth | hours |
| **P2** misspecification calibration | Weighting and outcome misspecifications of comparable severity, in a declared metric | The grid; unequal severities would report which model was broken harder | hours |
| **P3** DR reproduction | That the implemented augmented estimator reproduces Campbell and Remiro-Azócar's reported behavior on their own conditions | Whether the central arm is a comparator or a confound | days |
| **P4** unit cost | Per-replicate cost with cross-fitting at each grid point; total computed not typed | The sensitivity-grid resolution, which multiplies everything | hours |

## 11. Cost

The bias-indexed arm evaluates a cross-fitted estimator at every point of the
sensitivity grid, so cost is $n_{sim} \times$ grid points $\times$ folds. **That
triple product is the kind of line this program has mispriced twice** and it is
computed in P4 rather than quoted here.

---

## Relationship to the rest of the queue

- **DIA-14** owns QBA scored as a classifier and supplies the tipping-point and
  region measures; if both run, the scoring code is shared.
- **QBA-22** owns non-additivity of total bias across mechanisms, which is the
  generalization this design deliberately restricts.
- **MOD-02** owns functional-form misspecification and flexible learners.
- **SFW-14** owns `drMAIC` having no methods paper and no independent evaluation,
  which this design partially supplies as a by-product.
- **QBA-13** owns simulated-covariate QBA as an STC route rather than a general
  solution.
