# COV-04 design: shrinkage is settled, its interval is not

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**Shrinkage over stepwise selection is already a benchmarked recommendation.** Seo
et al. compared LASSO, ridge, adaptive LASSO, Bayesian LASSO and stochastic search
against stepwise regression and the all-interactions model for IPD meta-analysis and
recommended shrinkage; Efthimiou et al. carried Bayesian variable selection into
component network meta-analysis combining aggregate data and IPD.

**What survives is the honest-uncertainty half**: neither evaluation covers the
regularized horseshoe, heredity constraints or projection-predictive selection, and
**both report mean squared error rather than interval coverage with the selection
step included.** The note requires a sharply reduced comparison, and this design
takes three priors rather than eight.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a posterior interval reported conditional on a
data-selected model, with the selection event ignored, is not automatically honest,
and that calibration has not been checked for decision-grade PAIC use.

**Refuting sentence:** *continuous shrinkage does not select, so there is no
selection event to condition on and the posterior interval is honest by
construction.*

**That refutation is the standard defense of shrinkage and it is half right**, which
is why the design separates the priors that select from those that shrink.

## 2. The mechanism: continuous shrinkage has no selection event and still has a conditioning problem

Three regimes, and they are not the same:

1. **Spike-and-slab and stochastic search select.** The reported interval is
   conditional on the selected inclusion pattern, and DEC-11's mechanism applies
   directly: coverage is nominal within the selection event and not marginally.
2. **Continuous shrinkage does not select**, so the refuting sentence is right that
   there is no discrete conditioning event. **But the posterior is still an interval
   from a model whose regularization strength was fitted to the same data.** With a
   hierarchical scale parameter the shrinkage adapts, and the interval for a strong
   interaction is computed under a scale estimated partly from the many weak ones.
   **The result is a shrinkage-induced bias with an interval that does not carry
   it**, which is a coverage failure without a selection event.
3. **Heredity constraints reintroduce discreteness.** Requiring the main effect
   whenever an interaction enters is a combinatorial restriction, so a
   hierarchy-respecting prior selects even when its coordinate-wise counterpart does
   not.

**So the honest question is coverage of the whole procedure**, and the measure is the
same for all three: unconditional coverage over repeated datasets with the
regularization and any selection re-run inside each replicate. **That is exactly
what the two existing benchmarks do not report**, and it is not an extension of MSE.

**One further consequence specific to PAIC:** interaction terms carry far less
information than main effects, which COV-01's section 2 quantifies. **So the
shrinkage is doing most of the work in exactly the coordinates the decision depends
on**, and the prior's influence on the reported interval is largest where it
matters most.

## 3. Estimand, with its true value defined

**Primary.** The target-population treatment effect, by quadrature at an order fixed
by P1.

**Unconditional coverage of the whole procedure is the derived estimand**, and it is
what the study exists to measure. Conditional coverage given the selected or fitted
model is computed alongside, **so the gap between them is visible** rather than
inferred.

**False interaction discoveries** are a third outcome, defined against the true
sparsity pattern.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| number of true interactions | 0, 1, 4 | sparsity, and 0 is where false discoveries are measurable |
| interaction strength | at, above and below COV-01's detectability threshold | consequence 4; the prior's influence is largest below it |
| candidate interactions | 6, 20 | the dimension shrinkage is for |
| network information | sparse; rich | how much the likelihood can override the prior |
| overlap | good, poor | the adjustment layer |
| heredity | main effects strong; main effects weak | consequence 3's constraint has bite only when they differ |

### What the mechanism makes true, and therefore what the study cannot see

- **Three priors, not eight**, per the note: a regularized horseshoe, a
  hierarchy-respecting group prior, and spike-and-slab, plus the all-interactions
  model and projection-predictive selection as the two non-prior comparators.
  **The existing benchmarks' priors are not re-run**, since their MSE ranking is
  established and this study measures a different quantity.
- Prespecification and dimension reduction can substitute for shrinkage, as the
  entry notes, and **the prespecified-set arm is the ceiling** rather than a
  competitor.
- Multi-task shrinkage across treatment classes and components is named by the entry
  and is **not** in the reduced comparison; it adds a layer whose calibration is
  untested and would double the design.
- The true sparsity pattern is known. **An analyst does not know it**, and COV-01
  owns choosing the set.

## 5. Methods, including one that can win

| method | role |
|---|---|
| all-interactions model | no shrinkage, no selection; the honest-interval baseline |
| **regularized horseshoe** | the prior neither benchmark covers |
| **hierarchy-respecting group prior** | heredity, consequence 3 |
| spike-and-slab | the selecting prior, consequence 1 |
| **projection-predictive selection from a rich reference model** | the route neither benchmark covers |
| prespecified oracle set | the ceiling |
| **each of the above with the whole procedure resampled** | the calibration fix |

**The comparator that can win is the all-interactions model.** It has no selection
event and no adaptive shrinkage, so its interval is honest by construction; **if its
precision cost is tolerable at realistic candidate counts, the entire calibration
problem is avoidable by not shrinking.** Registered as such, and COV-01 registers
the same comparator for the same reason.

## 6. Performance measures, MCSE, and $n_{sim}$

Unconditional and conditional coverage of the target effect; interval width; bias;
**false interaction discovery rate** and true discovery rate against the known
sparsity; **selection or shrinkage stability** across replicates, with MCSE.

**Coverage is the primary and MSE is secondary**, reversing the existing benchmarks'
emphasis deliberately, because the entry says the MSE question is answered.

$n_{sim} = 2000$ per cell; the resampled-procedure arms multiply by their resample
count, priced in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Unconditional coverage of the target-population treatment
effect under the regularized horseshoe, at 20 candidate interactions with one true
interaction just below COV-01's detectability threshold.

**Decision rule.**

- Unconditional coverage materially below nominal while the resampled-procedure
  version is nominal: **confirmed**, and the deliverable is that a shrinkage
  interval must account for the procedure.
- Unconditional coverage nominal: **the refuting sentence holds for continuous
  shrinkage**, and the recommendation distinguishes it from selecting priors.
- All-interactions competitive on width: **shrinkage is unnecessary at these
  dimensions**, which is the simplest possible recommendation and is registered as
  reachable.

## 8. Three controls, each of which can fail

**Null control.** With no true interactions and a rich network, every method must be
unbiased with nominal coverage, and the false discovery rate must be at its declared
level. **A prior that discovers interactions where none exist is disqualified before
its coverage is interesting.**

**Second null control.** With the prespecified oracle set, there is no selection and
no adaptive shrinkage, so conditional and unconditional coverage must coincide.
**That is the anchor that makes the gap elsewhere interpretable**, and it is exactly
DEC-11's null control in a different setting.

**Positive control.** Twenty candidates, sparse network, one strong interaction:
spike-and-slab's conditional coverage must exceed its unconditional coverage
materially. **If the gap cannot be produced for a selecting prior, the design cannot
detect it for a shrinking one.**

**Falsifier for the study's own headline.** The expected headline is that shrinkage
intervals need procedure-level calibration. Its falsifier is consequence 2 failing:
**if continuous shrinkage's unconditional coverage is nominal at every strength,
then the conditioning problem is confined to selecting priors** and the
recommendation narrows to those, which is a smaller and more precise claim.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Re-running a benchmarked MSE comparison | Coverage is primary; the existing priors are not re-run | removed |
| Treating continuous shrinkage and selection as one problem | Three regimes separated in section 2 | removed |
| Too large a comparison, which the note warns against | Three priors plus two non-prior comparators | removed |
| Multi-task shrinkage | Named, out of the reduced comparison | disclosed |
| The true set known to the design | Stated; COV-01 owns selection | disclosed |
| Detectability threshold chosen arbitrarily | Imported from COV-01's power calculation | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and detectability | Target truth per cell and COV-01's threshold at these sample sizes | The interaction-strength levels | hours |
| **P2** gap reachability | The conditional-versus-unconditional coverage gap at pilot settings for a selecting prior | **Whether the design can detect the gap at all** | days |
| **P3** projection-predictive feasibility | Whether projection selection from a rich reference model is fittable at these dimensions | Whether that arm exists | days |
| **P4** unit cost | Per-replicate cost with resampled procedures; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

The resampled-procedure arms multiply each prior's cost by the resample count, and
projection-predictive selection needs a rich reference fit per replicate. Priced in
P4.

---

## Relationship to the rest of the queue

- **COV-01** owns selection and supplies the detectability threshold; **DEC-11**
  owns propagating selection uncertainty and its mechanism applies to the selecting
  priors here.
- **MOD-04** owns post-selection inference for model choice generally.
- **CMP-16** owns weakly identified variance components, the same prior-versus-data
  question one layer over.
- **CMU-02** owns prior-driven posteriors, which is what a shrunk interaction with a
  weak likelihood becomes.
