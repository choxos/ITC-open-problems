# SFW-14 design: what a simulation of drMAIC can and cannot settle

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog draws a line this design must not blur. **Double robustness is an
analytical property** holding under identification, positivity, regularity and
correct specification of at least one nuisance model. **A simulation tests the
implementation and its finite-sample behavior, not the theorem.** A study that
reported "double robustness confirmed" would have confirmed the wrong object.

It also names the comparator: **augmented weighting for PAIC is not new with
drMAIC.** G-MAIC combines outcome regression with weighting adjustment and was
evaluated across 18 scenarios against MAIC and parametric g-computation. **Any
benchmark that omitted it would compare a new package against methods weaker than
the published state.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** drMAIC appeared on CRAN with one vignette and a single
test file, no methods publication and no independent evaluation, so treating it as a
reference implementation is premature; and a CRAN release confers apparent
legitimacy in HTA submissions faster than independent evaluation can be produced.

**Refuting sentence:** *the implementation is correct and its finite-sample behavior
matches the published augmented-weighting literature, so the absence of a paper is a
documentation gap rather than a validation gap.*

**That is the outcome this design most expects and it is worth establishing**, since
the alternative is that a package in use is wrong.

## 2. The mechanism: the 2×2 the double-robustness claim implies

An augmented weighting estimator is consistent when **either** the weighting model
or the outcome model is correct. That gives four cells and the theorem makes three
predictions:

| weighting model | outcome model | augmented estimator | plain MAIC | plain outcome regression |
|---|---|---|---|---|
| correct | correct | consistent | consistent | consistent |
| **correct** | **wrong** | **consistent** | consistent | biased |
| **wrong** | **correct** | **consistent** | biased | consistent |
| wrong | wrong | biased | biased | biased |

Three consequences:

1. **The two off-diagonal cells are the whole test of the implementation.** If the
   augmented estimator is biased in either, the estimating equations are
   misimplemented, since the theorem says otherwise. **That is a check on code
   against theory and it is decisive**, unlike a general performance comparison.
2. **The bottom-right cell is not a failure of the method.** Both models wrong means
   no consistency was claimed, and reporting it as a drMAIC weakness would be
   reporting the theorem's scope as a defect. **It is included so the reader can see
   the boundary**, not as an indictment.
3. **Finite-sample behavior is where a simulation adds something the theorem does
   not.** Under weak overlap the augmented estimator's variance can exceed either
   single-model estimator's, and its bootstrap interval can fail even where the
   point estimate is consistent. **That is the practically important question and it
   is not a question about double robustness at all.**

**Omitted-modifier scenarios are a different thing again.** They violate
exchangeability, which no double-robustness property addresses, so the catalog
places them in a sensitivity analysis. **This design keeps them separate and
labeled**, because mixing them in would let a failure of identification read as a
failure of the package.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, binary and
time-to-event, by quadrature and exact integration at orders fixed by P1.

**Failed-fit frequency is a first-class outcome**, not a footnote: the catalog asks
for failed fits to be reported rather than only successful ones, and a package with
one test file is where that matters.

## 4. Data-generating mechanism, and what it makes invisible

**The published comparator's grid is the base.** G-MAIC's 18 scenarios supply the
covariate structure and effect sizes, so drMAIC is compared on ground where a
published evaluation already exists.

### Factors

| factor | levels | why |
|---|---|---|
| weighting model | correct; misspecified | section 2's rows |
| outcome model | correct; misspecified | section 2's columns |
| overlap | strong; weak | consequence 3 |
| outcome type | binary; time-to-event | the package's stated scope |
| sample size | 2 levels | finite-sample behavior |
| **omitted modifier** | absent; present | **carried in a separately labeled sensitivity arm**, not in the 2×2 |

### What the mechanism makes true, and therefore what the study cannot see

- **The theorem is not tested.** Consequence 1 tests the implementation against the
  theorem, which is the reverse.
- Misspecifications are of declared severity, calibrated in P2 so the two are
  comparable; **unequal severities would report which model was broken harder.**
- Component drift belongs only in a component-PAIC extension and is **not** in this
  benchmark, per the catalog.
- The package is evaluated as released. **Reviewing its estimating equations by
  reading the code is a separate task the catalog also asks for**, and it is listed
  as P3 because a discrepancy found there would explain any simulation failure.

## 5. Methods, including one that can win

| method | role |
|---|---|
| drMAIC augmented | the package under test |
| conventional MAIC | the weighting-only baseline |
| parametric g-computation | the outcome-only baseline |
| **G-MAIC** | **the published augmented comparator**, without which the benchmark is unfair to the literature |

**The comparator that can win is drMAIC.** If it matches G-MAIC across the 2×2 and
the overlap axis, the refuting sentence holds, the package is validated, and the
deliverable is that validation plus a note that the documentation gap remains.
**Registered explicitly because the reflex in an entry framed around a missing paper
is to look for faults.**

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, interval width, RMSE and **failed-fit frequency** per method per
cell, with MCSE.

**Reported as section 2's table**, cell by cell, rather than averaged, since the
off-diagonal cells are the informative ones and an average over the 2×2 would hide
them.

**Bootstrap interval behavior reported separately from point-estimate behavior**,
because consequence 3 says they can fail independently and the package's intervals
are bootstrap.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of drMAIC's augmented estimator in the two off-diagonal
cells of section 2, at strong overlap where finite-sample effects are smallest.

**Decision rule.**

- Unbiased in both off-diagonal cells: **the implementation delivers what the
  theory promises** and the deliverable is that statement plus the finite-sample
  characterization.
- Biased in one or both: **an implementation defect is indicated**, and P3's code
  review is the place to locate it before any claim is published. **The finding is
  reported as an implementation issue with the specific cell named**, not as a
  refutation of augmented weighting.
- Unbiased but with failed fits or interval failure at weak overlap: **that is the
  practically important result** and is reported as such, since it is what a user
  would encounter.

**Publication of a defect follows the same courtesy any package deserves:** the
maintainer is notified with a reproducible example before the result is written up.
That is stated here so it is a protocol commitment rather than a later decision.

## 8. Three controls, each of which can fail

**Null control.** With both models correct and strong overlap, every method must be
unbiased and nominal, and drMAIC must not be materially less efficient than the
single-model estimators. **A loss there is a finite-sample cost worth quantifying**;
a bias there is a defect.

**Second null control.** With no effect modification and no misspecification, the
augmented estimator must reduce to the weighting estimator to Monte Carlo error.
**Cheap, exact, and it checks the augmentation term vanishes when it should.**

**Positive control.** Weighting model wrong, outcome model correct, strong overlap:
plain MAIC must be biased and drMAIC must not. **If plain MAIC is not biased there,
the misspecification is not severe enough to test anything**, and P2's calibration
has failed.

**Falsifier for the study's own headline.** The expected headline is a validation.
Its falsifier is the failed-fit and interval behavior at weak overlap: **a package
can be analytically correct and practically unusable**, and reporting only the 2×2
would miss that. Failed fits are therefore a primary-level outcome rather than a
diagnostic.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reporting a simulation as testing the theorem | Section 2 states it tests the implementation | removed |
| Comparing a new package only against weaker methods | G-MAIC included as the published augmented comparator | removed |
| Omitted-modifier failure read as a package defect | Separately labeled sensitivity arm | removed |
| Unequal misspecification severity | Calibrated in P2 | removed |
| Bottom-right cell reported as a weakness | Labeled as the theorem's boundary | removed |
| A defect published without notice to the maintainer | Notification committed in the protocol | removed |
| Component drift | Out of scope, per the catalog | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Target truths on both outcome types | The definition of truth | hours |
| **P2** misspecification calibration | Weighting and outcome misspecifications of comparable declared severity, with plain MAIC and plain regression each demonstrably biased in their own off-diagonal cell | **The positive control, and the fairness of the 2×2** | days |
| **P3** code and estimating-equation review | Whether the implemented estimating equations match the augmented form the package documents | **Where any simulation failure comes from.** A review finding explains a result the simulation can only detect | days |
| **P4** unit cost | Per-replicate cost including bootstrap; total computed not typed | $n_{sim}$ | hours |

**P3 runs before the simulation**, because a discrepancy found by reading is cheaper
to act on than one inferred from a bias.

## 11. Cost

Weighting and regression fits with a bootstrap inside; the resample count is the
multiplier and is measured.

---

## Relationship to the rest of the queue

- **QBA-11** owns what double robustness does not cover and uses the same augmented
  estimator; if both run, the 2×2 is shared and QBA-11 adds the $\gamma$ axis.
- **COV-03** owns augmented weighting's use of prognostic covariates.
- **SFW-10**, **SFW-12** and **SFW-13** own the other software entries; this is the
  template an independent package evaluation would follow.
- **CMP-26** applies the same logic to a package whose author wrote this program, and
  the two designs' conflict-of-interest handling differs for that reason.
