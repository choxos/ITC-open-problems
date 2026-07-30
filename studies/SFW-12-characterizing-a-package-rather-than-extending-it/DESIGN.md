# SFW-12 design: where the estimate moves, and one dependence that is definitional

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog draws a distinction the design must keep. **Dependence on the target
covariate distribution is partly definitional rather than a defect**: standardization
is defined relative to a declared target, so the estimate *should* move when the
target changes. **Dependence on the outcome model is a genuine robustness concern.**
Treating both as sensitivity would report a definition as a weakness.

The note is also explicit: run the focused pairwise robustness study early, and
**defer the disconnected-network extension until its bridge assumptions and
identification conditions are stated analytically.** This design does not attempt it.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** `outstandR` is framed around the two-trial limited-IPD
problem with no published validation of its behavior in networks or across
disconnected evidence; reconstructing the target covariate distribution from limited
published moments makes the result sensitive to the reconstruction, which the
package's copula vignette exposes but cannot resolve; and dependence on the outcome
model is a robustness concern.

**Refuting sentence:** *the estimate is insensitive to both the reconstruction and
the outcome model across defensible alternatives, so the absence of published
network validation is the only real gap and it is a scope statement rather than a
defect.*

## 2. The mechanism: two dependences, one of which is not a defect

**The target-distribution dependence.** $\Delta(F_T) = \int\tau\,dF_T$ changes with
$F_T$ **by definition**. Two sub-cases must be separated:

1. **Changing the declared target** changes the estimand. **That is not
   sensitivity**; it is EST-11's and EST-12's subject and the estimate moving is
   correct behavior.
2. **Changing the reconstruction of a fixed declared target** changes the estimate
   without changing the estimand. **That is sensitivity**, and CMP-15 establishes it
   lives above the second moment, so calibrating the correlation does not remove it.

**Only the second is in scope**, and the design holds the declared target fixed while
varying the reconstruction, which is exactly what the package's copula machinery
permits.

**The outcome-model dependence.** Standardizing a fitted surface over $F_T$
propagates any misspecification of $\tau$, weighted by $F_T$'s mass where the
misspecification lives. MOD-02's taxonomy applies: a prognostic misspecification
common to both arms cancels at an identity link and does not at a curved one, and an
interaction misspecification bites on every scale. **So the outcome-model sensitivity
is predictable from that taxonomy rather than something to be mapped blind.**

**A third thing the entry names and the design must not conflate with either:** the
2.0.0 separation of `outcome_model` from `balance_model` **prepares the way for
doubly robust variants that are not there yet.** A package that has separated the
components but not augmented them is not doubly robust, and **the design does not
evaluate it as if it were**; QBA-11 and SFW-14 own that property.

## 3. Estimand, with its true value defined

**Primary.** The marginal target-population treatment effect at a **fixed declared
target**, by quadrature over the true joint law at an order fixed by P1.

**The movement of the estimate across reconstructions and across outcome models is
the derived estimand**, reported separately, since section 2 says one is sensitivity
and the other is robustness and they should not be summed.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| target reconstruction | true joint; Gaussian copula; tail-dependent copula; independence | section 2 case 2, using the package's own machinery |
| outcome model | correct; prognostic misspecification; interaction misspecification | MOD-02's taxonomy, which predicts which bites |
| effect-modifier overlap | good, poor | where standardization extrapolates |
| link | identity; logit | which misspecification cancels |
| effect-modification strength | moderate, strong | the multiplier |

**The declared target is held fixed throughout.** Varying it would produce movement
that is definitional and would inflate the apparent sensitivity.

### What the mechanism makes true, and therefore what the study cannot see

- **Networks and disconnected evidence are out of scope**, per the note. Extending
  standardization to a network requires deciding how standardized arm-level
  quantities combine while preserving within-study randomization, **which is not a
  mechanical generalization**, and the disconnected case needs a bridge assumption
  standardization cannot identify.
- **The package is not evaluated as doubly robust**, because it is not.
- Two trials only, matching the package's framing.
- The copula machinery used is the package's own, so **a failure is attributable to
  the reconstruction rather than to a reimplementation**.

## 5. Methods, including one that can win

| arm | role |
|---|---|
| `outstandR` with the true joint supplied | the ceiling |
| `outstandR` with each reconstruction | the sensitivity map |
| `outstandR` with each outcome model | the robustness map |
| conventional STC at target means | the estimand-mismatched reference MOD-01 owns |
| MAIC | the weighting comparator the published method claims to beat at poor overlap |

**The comparator that can win is `outstandR` with the independence reconstruction.**
If the estimate barely moves from the true-joint arm across the realistic grid, the
reconstruction sensitivity the copula vignette exposes is immaterial and the refuting
sentence holds for that half. Registered as such, and MOD-01's mixed-sign
cancellation gives it a real chance.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE per arm per cell, with MCSE.

**Estimate movement**, reported as two separate quantities: the range across
reconstructions at a fixed outcome model, and the range across outcome models at the
true reconstruction. **Summing them would report a definition and a defect as one
number.**

**The registered taxonomy check:** whether prognostic misspecification moves the
estimate at the identity link. **MOD-02's section 2 says it should not**, and a
package that moves there is doing something other than standardizing.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The range of the estimate across reconstructions at a fixed
declared target, with a tail-dependent true joint and a curved link.

**Decision rule.**

- Range exceeding the decision threshold: **the reconstruction sensitivity is
  material**, and the deliverable is that an `outstandR` analysis should report the
  range across reconstructions, using machinery the package already ships.
- Range below threshold: **refuted for that half**, and the recommendation concerns
  the outcome model only.
- **The two ranges are reported separately in either branch**, because conflating
  them is the specific error section 2 exists to prevent.

## 8. Three controls, each of which can fail

**Null control.** With one covariate there is no joint law, so every reconstruction
coincides and the range must be exactly zero. **Cheap, exact, and it checks the
reconstruction factor is doing what it claims.**

**Second null control.** At an identity link with linear modification, section 2 and
MOD-01 make the copula irrelevant, so the range across reconstructions must be zero
to Monte Carlo error **even with several covariates.** That separates "the joint
matters" from "the joint matters here".

**Positive control.** Tail-dependent true joint, curved link, strong modification,
five covariates: the independence reconstruction must be biased by at least three
MCSEs. If it is not, the reconstruction cannot be made to matter at attainable
dependence and the study reports that.

**Falsifier for the study's own headline.** The expected headline is that
reconstruction and outcome-model sensitivity should be reported. Its falsifier is the
poor-overlap comparison with MAIC: **the published method's own claim is that it is
more precise and more accurate than MAIC particularly when overlap is poor**, and if
that holds across the sensitivity grid, then the sensitivities are real and the
method is still the better choice, which is a different recommendation from "report
the range".

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reporting a definitional dependence as a defect | Declared target held fixed; only the reconstruction varies | removed |
| Evaluating the package as doubly robust | Not done; the component separation is not augmentation | removed |
| Attempting the network extension | Out of scope per the note; the reason stated | removed |
| Reconstruction failure attributed to a reimplementation | The package's own copula machinery is used | removed |
| Two ranges summed into one sensitivity figure | Reported separately | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target truth under each true joint | The definition of truth | hours |
| **P2** matched-moment joints | Alternative joints with identical published moments, imported from CMP-15 | **The sensitivity factor**; shared with CMP-15 and OVL-03 | days |
| **P3** package interface | That the copula machinery accepts each planned reconstruction and that the outcome-model slot accepts each misspecification | Whether the arms exist as designed | hours |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | hours |

## 11. The case-study half

Reproduce the most consequential sensitivity in a published limited-IPD comparison,
using the package on that analysis's own reported moments. **That is what turns a
simulation range into a statement about an analysis someone acted on.**

## 12. Cost

Regression fits and simulation-based marginalization; small.

---

## Relationship to the rest of the queue

- **MOD-01** owns the conditional-versus-marginal estimand this package resolves, and
  the copula reconstruction question; **CMP-15** owns the copula error's structure
  and supplies P2.
- **MOD-02** supplies the misspecification taxonomy used in section 2.
- **QBA-11** and **SFW-14** own double robustness; this package is not evaluated for
  it.
- **DIS-11** owns bridge validation, which any disconnected extension would need.
