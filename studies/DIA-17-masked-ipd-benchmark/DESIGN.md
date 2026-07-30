# DIA-17 design: a standing benchmark, and the estimand it must match

**Status: design. Not registered.** Gated on data access; see section 10.
Written against `studies/DESIGN-STANDARD.md`.

**The binding constraint is not analysis.** The catalog's note says this should run
only after an appropriate shared multi-trial IPD dataset is secured, and the entry
explains why the incentives run against it: **masked-IPD validation is uniquely
capable of embarrassing a method**, so the real-data checks that exist are
sponsor-authored one-offs rather than standing benchmarks.

So this document is a protocol written to be ready when data is. **Its
methodological content is section 2, which fixes a comparison that is easy to get
wrong and that the entry says is material.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no study masks selected trials of a multi-trial IPD
dataset to aggregate data and scores PAIC estimates against the full-IPD
target-standardized analysis; and PAIC validation concentrates on relative effects
rather than on the absolute arm-level predictions a transport model actually makes.

**Refuting sentence:** *relative-effect agreement is sufficient evidence for a
transport model, because arm-level prediction error reflects baseline modeling that
the relative estimand is invariant to.*

**The entry does not claim real-data benchmarking is absent** and neither does this
design: Signorovitch et al. 2023 compared published guselkumab MAIC estimates
against subsequently completed head-to-head trials. **That is a real check with a
known answer**; what is missing is a standing benchmark with a reusable protocol.

## 2. The mechanism: the comparator must match the estimand, and on a non-collapsible scale that bites

The benchmark is **not known truth.** It is a prespecified reference analysis
carrying its own uncertainty, and every discrepancy measure must propagate both.

**And the reference must target the same estimand as the method being scored.** A
marginal PAIC estimate needs a marginal target-standardized comparator; a
conditional STC or conditional ML-NMR output needs a conditional one. On a
collapsible scale the two coincide and the distinction is cosmetic. On a
non-collapsible scale they differ by the collapsibility gap, which depends on the
target covariate spread:

$$\Delta^{\text{cond}} - \Delta^{\text{marg}} \;\approx\; c \cdot \Delta \cdot \mathrm{Var}_T(\gamma^\top x),$$

the same quantity COV-03 and MOD-01 identify. **So a benchmark that scores a
conditional estimate against a marginal reference reports the collapsibility gap as
method error**, and would rank methods by which estimand they happen to return.
`cpaic`'s two functions differ in exactly this way: `cstc()` returns a conditional
effect at the target covariate values and `cmaic()` a marginal weighted effect.

**Two consequences for the protocol:**

1. **Every method is paired with its own reference**, declared before any
   estimate is seen, and the pairing is part of the registered protocol rather than
   an analysis choice.
2. **The collapsibility gap is computed and reported for each pairing**, so a
   reader can see how much of any cross-method difference is estimand rather than
   performance.

**Arm-level calibration is the second half and it is not redundant.** A transport
model predicts absolute arm outcomes; the relative effect is a difference of two
predictions and can be right when both are wrong. **So a failed arm-level
prediction is evidence against the transport model even when the relative effect
agrees**, and the entry asks for it to be a routine output. **The refuting sentence
in section 1 is exactly the claim that this is not so, and the benchmark can settle
it empirically** by measuring how often relative agreement and arm-level agreement
disagree.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect for each masked trial,
with the target population declared before masking.

**The reference is a prespecified full-IPD target-standardized analysis of the
identical estimand**, carrying its own interval. **Discrepancy is
uncertainty-aware**: the comparison is between two intervals, not between a point
and a truth, and the measure is registered in section 6 rather than chosen after.

**Arm-level predicted outcomes** are the second estimand, with the observed
arm-level outcomes as reference.

## 4. Design of the benchmark, and what it cannot see

**Masking protocol.** Each selected trial is reduced to the aggregate summaries a
publication would report, at a declared reporting resolution, and **the masking is
performed by a procedure fixed in advance** so it does not vary with what each
method needs. Removed information is excluded from fitting, verified rather than
intended.

**Rotation.** Every trial is masked in turn, so the benchmark reports a
distribution over which trial is held out rather than one number. **IDN-07 finds
the analogous verdict depends heavily on which trial is withheld**, and averaging
would hide it.

### What the design cannot see

- **Data-sharing agreements rarely permit the repeated re-analysis a validation
  study needs.** The protocol therefore specifies the minimum number of re-analyses
  and the exact outputs required, so an agreement can be sought for a bounded
  request rather than an open one.
- Population-shift validation additionally requires an identified absolute-risk
  transport model, compatible outcome definitions and follow-up, adequate overlap
  and preferably a shared arm. **The entry calls this a rarer configuration than it
  appears**, and the protocol records which of those conditions each dataset meets
  rather than assuming them.
- The reference analysis is itself a model. **A discrepancy is evidence about the
  pair, not about the masked method alone**, and the protocol says so.

## 5. Methods

MAIC, STC (conditional and marginalized variants reported separately), ML-NMR,
ML-UMR, and no adjustment. **Each paired with its matching reference per section
2.**

**The comparator that can win is no adjustment.** If the unadjusted indirect
comparison agrees with the reference as often as the adjusted ones on the datasets
available, that is the finding, and it is the one the incentive structure most
suppresses.

## 6. Performance measures

**Uncertainty-aware discrepancy**, registered as the standardized difference
between the masked and reference estimates with both variances carried; **interval
agreement**, the overlap of the two intervals; **decision agreement**, whether both
cross a declared threshold; **arm-level prediction error** with its own interval;
and **the collapsibility gap per pairing** from section 2.

**Discordance between relative agreement and arm-level agreement is a reported
outcome**, since section 2 says that is where the entry's second claim is decided.

Monte Carlo error does not apply in the usual way; **the uncertainty here is
sampling uncertainty in both analyses of a fixed dataset**, and it is propagated by
the bootstrap or posterior as appropriate to each method.

## 7. Decision rule, before any data is seen

- Adjusted methods agreeing with the reference within the declared discrepancy
  tolerance on most masked trials, with arm-level calibration also acceptable: the
  transport models are supported on these datasets.
- Relative agreement acceptable while arm-level calibration fails: **the entry's
  second claim is confirmed**, and the deliverable is that arm-level calibration
  must be a routine output.
- Both failing: reported, whatever the sponsorship of the data.

**The tolerance is declared before analysis and is not adjusted afterwards.**
Given that this benchmark is capable of embarrassing methods, the tolerance moving
after results are seen is the specific way it would fail.

## 8. Controls

**Null control.** Masking a trial that is uninformative for the target contrast
should leave the reference and masked estimates in near-perfect agreement. A
disagreement there is a pipeline fault.

**Second null control.** On a collapsible scale, the conditional and marginal
references must coincide, so every method's pairing gives the same reference.
**That is where section 2's machinery is checked before it is relied on.**

**Positive control.** Masking the trial that supplies most of the target
population's information should degrade agreement measurably. If it does not, the
masking is not removing what it claims to.

## 9. Threats

| threat | what was done | status |
|---|---|---|
| Conditional estimate scored against a marginal reference | Pairings declared in the protocol; collapsibility gap reported | removed |
| Treating the reference as truth | Uncertainty-aware discrepancy throughout | removed |
| One held-out trial standing for all | Full rotation; distribution reported | removed |
| Tolerance moved after results | Declared before data access | removed |
| Arm-level check omitted as redundant | Registered as a primary-level outcome, and its discordance with relative agreement is the deciding measure | removed |
| Sponsor incentive against publication | Protocol and tolerance registered before data access; a null or unfavorable result is pre-committed | disclosed |

## 10. The gate, and what can be done before it opens

**This study cannot start without a shared multi-trial IPD dataset**, and the
catalog says so. Three things can be done now and are the design's deliverable in
the meantime:

| step | what it produces |
|---|---|
| **G1** protocol registration | This document, with tolerances, pairings and measures fixed, published before any dataset is sought, so a later agreement cannot shape the analysis |
| **G2** masking pipeline | The masking procedure implemented and tested on **simulated** multi-trial data, so the pipeline is validated before real data touches it |
| **G3** dataset survey | Which shared repositories hold multi-trial IPD meeting the section 4 conditions, and what each permits, recorded as a table rather than as an assumption |

**G2 is not a formality.** A masking pipeline that leaks information is
undetectable on real data, where no truth exists to reveal it, and detectable on
simulated data, where it does.

## 11. Relationship to the rest of the queue

- **IDN-08** is the same problem for bridged cross-gap comparisons and shares the
  data gate; a dataset serving one may serve both.
- **IDN-10** owns the arm-level transported-control check and supplies its
  operating characteristics.
- **IDN-07** owns held-out-trial falsification, which is this design's simulated
  counterpart and supplies the per-position reporting.
- **COV-03** and **MOD-01** own the collapsibility-gap scalar used in section 2.
- **DIA-16** owns a curated public suite for bridge-deletion validation with IPD.
