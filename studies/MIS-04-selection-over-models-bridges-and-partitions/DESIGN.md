# MIS-04 design: what a fit statistic can and cannot arbitrate

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**MOD-04 is merged into this design**, on MOD-04's own instruction: its note says it
overlaps heavily with MIS-04 and should be combined or delayed until one concrete
selection workflow is chosen. `MOD-04-.../DESIGN.md` records the merge and the one
increment MOD-04 adds.

The catalog narrows this entry in ways that determine the scope. **A prespecified or
externally chosen model does not create the problem at all**, and the distortion can
run in either direction. **For bridges the difficulty is narrower than the source
claimed**: likelihood-based weights can be formed when candidates imply different
observed-data likelihoods or predictions, and are unavailable only for
**observationally equivalent** identifying assumptions. And **model averaging is
established in evidence synthesis generally** and has not been applied to PAIC, so
the task is porting and testing.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** when the same data select a PAIC model, bridge or
treatment partition and ordinary conditional intervals are reported, nominal coverage
is generally not guaranteed; no PAIC software feeds model or bridge averaging into
the reported effect interval; and for observationally equivalent bridges no fit
statistic can separate them, so the only honest input is a prior on assumption
plausibility, which nobody has elicited.

**Refuting sentence:** *the candidate models that survive scientific screening are
close enough that averaging over them changes nothing, so conditional intervals are
adequate in practice.*

## 2. The mechanism: three selectable objects, and only two are arbitrable by fit

Selection in PAIC happens over at least three objects, and they differ in whether
data can decide:

1. **The outcome or modifier model.** Candidates imply different likelihoods, so
   fit statistics and predictive weights are meaningful. **Selection uncertainty is
   propagable by averaging or by resampling the procedure.**
2. **The treatment partition**, meaning whether doses, formulations, schedules,
   devices or control conditions become one node or two. Candidates imply different
   likelihoods too, **but the differences are small**: five treatment-definition
   models for one dataset gave a deviance spread of 168.6 to 180.5 while **the
   resulting decision changed.** So fit arbitrates weakly exactly where the decision
   is sensitive.
3. **The bridge**, where candidates may be **observationally equivalent**. Then no
   fit statistic separates them, by definition, and averaging with likelihood-based
   weights is not available. **Elicited plausibility is the only input, and it is
   not a nuisance to be integrated out silently but an assumption to be stated.**

Three consequences:

- **A single "selection uncertainty" treatment cannot cover all three**, and a design
  that averaged over them would report a number with three different meanings.
- **The predictive unit is a choice, not an ambiguity.** Stacking weights need a
  held-out unit aligned with the prediction target: patient, study and contrast level
  prediction are **different estimands**, and the design declares one rather than
  inheriting a default.
- **Projection-predictive selection controls predictive loss and does not by itself
  deliver valid post-selection intervals**, and robust Bayes covers only the model
  and prior classes represented. **Neither is a finished answer**, and the design
  tests them rather than adopting them.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, by quadrature at an
order fixed by P1, **at a declared predictive unit** which is stated before any fit.

**Unconditional coverage over repeated datasets with the selection re-run inside each
replicate** is the derived estimand, alongside conditional coverage so the gap is
visible.

**For the observationally-equivalent bridge arm there is no data-determined truth
about which bridge is right**, so that arm's outcome is the width and containment of
an interval built from an elicited prior, reported as a function of that prior.
**Presenting it as coverage would imply the data decided something it cannot.**

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **selected object** | outcome model; treatment partition; bridge | section 2's three, kept separate |
| candidate multiplicity | 3, 8 | how much selection there is to price |
| true modifier set size | 1, 3 | the model arm's sparsity |
| bridge distinguishability | distinguishable; **observationally equivalent** | consequence 3 |
| selection level | patient; contrast; study | consequence 2's predictive unit |
| overlap | good, poor | the adjustment layer |

### What the mechanism makes true, and therefore what the study cannot see

- **Prespecified models are carried as the control**, since the catalog says they do
  not create the problem; the contrast between prespecified and selected is what
  isolates the effect.
- The elicited prior over bridge plausibility is **declared**, and no data informs
  it. **QBA-02 owns creating an empirical basis for such elicitation** and this
  design assumes one.
- One PAIC method family per arm, so the selection result is not confounded with a
  method comparison.
- **The candidate sets are restricted before the run**, per the note, because a
  design testing every selection and bridge problem together would be
  uninterpretable.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive conditional interval | current practice |
| bootstrap repeating the whole selection | the general fix |
| **Bayesian model averaging, ported from meta-analysis** | the established machinery, untried in PAIC |
| **stacking at a declared predictive unit** | consequence 2 |
| projection-predictive selection | tested for whether it restores coverage, not assumed to |
| robust Bayes over declared model and prior classes | the same |
| **bridge averaging with elicited plausibility weights** | the observationally-equivalent case, stated as an assumption |

**The comparator that can win is the naive conditional interval.** If the candidate
models surviving scientific screening are close enough that averaging changes
nothing, the refuting sentence holds. Registered as such, and section 2 consequence
2 gives a reason it might fail specifically for partitions: **small deviance spreads
with changed decisions.**

## 6. Performance measures, MCSE, and $n_{sim}$

Unconditional and conditional coverage; interval width; **predictive loss at the
declared unit**; and **decision agreement**, since consequence 2's evidence is about
decisions changing while fit does not.

**Reported separately by selected object.** Pooling the three would produce a
"selection uncertainty" figure that means three things.

**For the bridge arm**, width and containment as a function of the elicited prior,
with the prior stated.

$n_{sim} = 2000$ per cell; the resampling and averaging arms multiply by their
counts, priced in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Unconditional coverage of the target effect under naive
conditional intervals when the **treatment partition** is selected on the same data,
at 8 candidates with poor overlap.

The partition arm is chosen as primary because consequence 2 says it is where fit
arbitrates weakest and decisions move most.

**Decision rule.**

- Unconditional coverage materially below nominal, restored by averaging or by
  resampling the procedure: **confirmed**, and the deliverable is the ported
  machinery with the predictive unit declared.
- Coverage nominal: **refuted** for that object, and reported separately for each.
- **The bridge arm's result is reported as an assumption-conditional width in either
  branch**, never as coverage.

## 8. Three controls, each of which can fail

**Null control.** With a prespecified model, no selection occurs and conditional and
unconditional coverage must coincide. **The catalog says prespecification does not
create the problem, so this control tests the harness rather than the theory**, and a
gap there invalidates everything.

**Second null control.** With one candidate, averaging must reduce to the single fit
exactly. Cheap, and it checks the averaging machinery adds nothing when there is
nothing to average.

**Positive control.** Eight partition candidates with a small deviance spread and
decisions that differ across them: naive coverage must fall materially. **That
configuration is taken from the published five-model example rather than
constructed**, so the positive control is calibrated to something real.

**Falsifier for the study's own headline.** The expected headline is that selection
uncertainty must enter the interval. Its falsifier is consequence 3: **for
observationally equivalent bridges there is nothing to enter, and an interval built
from an elicited prior is reporting the elicitation.** If the bridge arm's width is
driven almost entirely by the prior, the honest recommendation is sensitivity
analysis rather than averaging, which is the entry's own position and the design must
be able to reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| One "selection uncertainty" number for three different objects | Reported separately | removed |
| Predictive unit inherited from a default | Declared before fitting, as an estimand statement | removed |
| Projection selection or robust Bayes adopted as the answer | Tested, not assumed | removed |
| Bridge averaging presented as data-driven | Elicited prior stated; result is assumption-conditional | removed |
| A design testing every selection problem at once | Candidate sets restricted before the run, per the note | removed |
| Prespecified models treated as also affected | Carried as the control, per the catalog | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and predictive unit | The target truth and the declared unit's held-out structure | The estimand | hours |
| **P2** deviance-spread calibration | Partition candidates with a small fit spread and different decisions, matching the published example | **The positive control** | days |
| **P3** observational equivalence | That the equivalent-bridge candidates really are equivalent, verified by their implied likelihoods rather than asserted | **The bridge arm's whole premise** | days |
| **P4** unit cost | Per-replicate cost with resampling and averaging; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Resampling times candidates times $n_{sim}$, with the averaging arms fitting every
candidate per replicate. **The candidate count multiplies everything** and is the
term to price.

---

## Relationship to the rest of the queue

- **MOD-04 is merged here** and records its one increment.
- **COV-01** owns which modifiers to select; **COV-04** owns shrinkage priors'
  calibration; **DEC-11** owns propagation and what belongs in an interval. The four
  form one workflow and their nulls are shared.
- **IDN-19** owns the treatment-class partition, a fourth selectable object whose
  range would feed the same interval.
- **DIS-11** and **IDN-08** own bridge validation, which is what would make
  observationally equivalent bridges distinguishable.
- **QBA-02** owns the elicitation this design's bridge arm assumes.
