# DIA-16 design: what a deletion result implicates, and the suite that would make it repeatable

**Status: design. Not registered.** Gated on curation; see section 10.
Written against `studies/DESIGN-STANDARD.md`.

**Bridge deletion is an established published design, not an unused idea.** Beliveau et
al. disconnect two public connected networks in multiple ways and score the reconstructed
cross-gap comparisons against the connected analysis, with code released. Petropoulou et
al. remove 20 studies with 34 pairwise comparisons from a Cochrane network to create 19
disconnected variants and report the cross-subnetwork estimate is **either inestimable or
misleading.**

**What does not exist is a curated, maintained public suite** with IPD or well-
reconstructed pseudo-IPD on both sides of the deleted edge, on which methods are
routinely scored. The note is blunt that **curation and estimand harmonization dominate
the work and a single deletion supplies weak general evidence**, so this design is a suite
specification plus the analysis that runs on it.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the restrictions used exclusively to extrapolate across an
unsupported gap cannot be tested inside the disconnected data, so the only empirical check
is an artificial disconnection where the answer is known; suitable networks are scarce and
scattered, no maintained collection exists, and every attempt starts from scratch.

**Refuting sentence:** *the two published deletion exercises already establish what a
suite would, so curating one adds repeatability rather than evidence.*

**That refutation is partly right and the design says so**: both published attempts
already returned negative results. **What they cannot supply is the factorial hidden-cell
design for component additivity and the stratification by overlap and extrapolation
reliance**, which need more than two networks.

## 2. The mechanism: what a deletion result does and does not implicate

**Two preconditions, and violating either makes the exercise uninterpretable:**

1. **The held-out contrast must remain in the row space of the training design.** A
   deletion that removes estimability produces a non-result, not a failure, and
   conflating the two would report a rank condition as a method's inadequacy. **This is
   the same rank check IDN-07, CMP-06 and DIA-07 need**, and it is checked per deletion
   rather than assumed.
2. **All estimates must share population, outcome definition, follow-up and effect
   scale.** Otherwise the discrepancy includes an estimand mismatch, and **DIA-17's
   section 2 shows how large that can be on a non-collapsible scale.**

**And the conclusion is weaker than it looks.** A disagreement **implicates the joint
model rather than the bridging assumption alone**: the outcome model, the covariate
adjustment and the bridge all contribute, and the deletion cannot separate them. **So
every reported discrepancy is attributed to the joint model**, and a design claiming to
test the bridge specifically would be overclaiming.

**The suite's value is in stratification.** A single deletion gives one number. **A suite
gives discrepancy as a function of covariate overlap across the induced gap and of how
far the reconstruction extrapolates**, which is what tells a reader whether a published
deletion result applies to their situation. **DIS-21 and IDN-08 need exactly that
stratification** and cannot build it from two networks.

## 3. Estimand, with its true value defined

**Primary.** The reconstructed marginal effect for the deleted contrast, targeted to the
**held-out trial's population**, against the held-out randomized estimate.

**The reference is not truth**: it is a randomized estimate with its own sampling error,
so **every comparison is uncertainty-aware**, as in DIA-17 and IDN-08.

**Decision agreement is the second estimand**, since a discrepancy that does not change a
recommendation is a different finding from one that does.

## 4. Suite specification, and what it cannot cover

**Two families are curated:**

- **Connected networks suitable for bridge deletion**, with IPD or well-reconstructed
  pseudo-IPD **on both sides of the deleted edge**, which is the binding scarcity.
- **Factorial or multicomponent networks suitable for component deletion**, where a
  hidden cell provides ground truth for an unobserved combination. **That is the design
  CMP-03 needs and no collection provides.**

**Published ground truth per deletion**: the deleted edge or hidden cell, the retained
estimate, and the preconditions in section 2 verified and recorded.

### What it cannot cover

- **Suitable networks are scarce**, so the suite will be small and its stratification
  coarse. **A coarse stratification is still more than one number**, but the design does
  not promise coverage of the configuration space.
- **The exercise mainly produces evidence against methods**, which the entry notes gives
  developers little incentive to run it. **A standing suite changes the incentive by
  making the exercise cheap for third parties**, which is its main contribution.
- Reconstructed pseudo-IPD carries CMP-17's and OUT-13's error, and **the suite records
  which side of each edge is reconstructed** so that a discrepancy can be checked against
  it.

## 5. Methods scored on the suite

Disconnected-network methods (random baseline, matching bridge, baseline-risk anchor) and
component methods (additive CNMA, interaction CNMA), each targeted to the held-out
population.

**The comparator that can win is a declared abstention.** If no method's reconstruction
agrees with the randomized estimate within a declared tolerance on most deletions, **the
suite's finding is that bridged cross-gap comparisons are not decision-grade**, which is
what both published attempts already suggest and what a suite would establish with more
than two networks.

## 6. Performance measures

Uncertainty-aware discrepancy from the held-out randomized estimate; **decision
agreement**; and **both stratified by covariate overlap across the induced gap and by
reliance on extrapolation**, which is the suite's reason to exist.

**Estimability is reported per deletion**, and non-estimable deletions are counted
separately rather than scored, per section 2 precondition 1.

**Reconstruction provenance is reported** for each side of each edge.

## 7. Decision rule, before any data is curated

- Discrepancies small and decisions agreeing across most deletions: bridged comparisons
  are supported on this suite, with the stratification saying where.
- Discrepancies large: **the finding is about the joint model**, per section 2, and is
  reported that way.
- **The stratification is published in either branch**, because it is what lets a reader
  locate their own gap and it is the thing two networks cannot provide.

**Tolerances are declared before curation**, so a later dataset cannot shape them.

## 8. Controls

**Null control.** Deleting an edge and refitting **with that edge retained** must
reproduce the connected estimate exactly. **The identity case, and it validates the
pipeline.**

**Second null control.** Deleting an edge whose contrast is also identified by two other
paths should give near-perfect recovery, since the bridge is barely load-bearing.
**That anchors the overlap stratification's low end.**

**Positive control.** Deleting the only path between two subnetworks with poor covariate
overlap must give a large discrepancy. **If it does not, the suite contains no hard
case.**

**Falsifier for the suite's own headline.** The expected headline is that a suite adds
evidence beyond the published attempts. Its falsifier is homogeneity: **if discrepancy
does not vary with overlap or extrapolation reliance across the curated networks, then
the stratification carries no information and two networks were enough.**

## 9. Threats

| threat | what was done | status |
|---|---|---|
| Claiming bridge deletion is unattempted | Both published attempts credited in the header | removed |
| Non-estimable deletions scored as failures | Rank precondition checked and counted separately | removed |
| Estimand mismatch counted as bridge failure | Harmonization required and verified; DIA-17's mechanism named | removed |
| A discrepancy attributed to the bridge alone | Attributed to the joint model, per the entry | removed |
| Tolerances set after seeing data | Declared before curation | removed |
| Reconstruction error unrecorded | Provenance reported per edge | removed |

## 10. The gate, and what can be done before it opens

| step | what it produces |
|---|---|
| **G1** suite specification and tolerances | This document, published before curation begins |
| **G2** candidate inventory | Which connected and factorial networks carry the required IPD or pseudo-IPD on both sides, **shared with IDN-08's and DIA-17's surveys**; one survey serves three studies |
| **G3** pipeline on simulated networks | Deletion, rank checking, harmonization and scoring validated where truth exists |
| **G4** ground-truth publication | Deleted edges, hidden cells and retained estimates, published so a third party can score a new method without recurating |

**G4 is the contribution.** The analysis is secondary; **the artifact is the suite**, and
it is what makes the next attempt cheap rather than another start from scratch.

## 11. Relationship to the rest of the queue

- **IDN-08** asks whether a cut link resembles a real gap and needs this suite's
  stratification; **DIS-21** needs it to calibrate a match threshold; **DIA-17** shares
  the data survey. **One curation effort serves all four.**
- **CMP-03** needs the factorial hidden-cell family for its omitted-interaction bound.
- **DIS-11** establishes that deletion has leverage, which this suite presupposes.
- **CMP-26** is the simulation benchmark that runs without any of this data.
