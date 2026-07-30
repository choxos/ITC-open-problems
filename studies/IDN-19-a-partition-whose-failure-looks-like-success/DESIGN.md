# IDN-19 design: widening the class weakens the assumption and improves the fit

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note says the full selection problem is too broad and to **begin with a decisive
partition-sensitivity analysis**. That is also the cheapest change that would alter
practice, and section 2 explains why nothing else in the workflow will.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the shared effect-modifier assumption is defined relative
to a treatment set that nothing governs; in practice the set is enlarged until the
model is estimable, and the partition is typically settled after the analyst has seen
which version converges; no criterion links class membership to an observable
implication and no requirement reports the partition as an identifying assumption.

**Refuting sentence:** *target contrasts are insensitive to the partition across
clinically defensible alternatives, so the absence of a criterion costs nothing in
practice.*

**Only a partition-sensitivity analysis can decide that**, and none has been built.

## 2. The mechanism: the incentive and the diagnostic point the same way

Widening the class imposes equality on more interaction vectors. Two effects follow
and they are both in the same direction:

1. **The identifying assumption strictly weakens** as more treatments are forced to
   share, since the equality constraint is imposed on parameters that may genuinely
   differ.
2. **Estimability strictly improves**, because the constrained model has fewer free
   interaction coordinates and a rank that is easier to attain.

**So a wider class fits, converges and returns narrower intervals**, and the
diagnostic signature of an indefensible partition is indistinguishable from success.
Three consequences:

- **The incentive runs toward the widest partition a reviewer will accept**, and
  nothing in the output opposes it.
- **The assumption is testable only in networks that do not need it.** Where the
  partition carries identifying weight, the treatments' interactions are by
  hypothesis not separately estimable, so any within-model relaxation has least
  power exactly where it matters most. Phillippo et al.'s covariate-wise relaxation
  concedes low power for this reason, and **it relaxes within a fixed partition
  rather than over the partition itself.**
- **Therefore the only available evidence is the induced range**: refit under every
  defensible partition and report how far the target contrast moves. **That is not a
  test and the design must not present it as one**; it is a sensitivity display, and
  its value is that a contrast whose sign depends on the class structure becomes
  visible.

**The simulation's job is to establish when the range is informative.** A range that
is always wide is useless; one that is narrow when the partition is right and wide
when it is wrong is a diagnostic. **Which of those it is depends on within-class
heterogeneity and network information**, and those are the design's axes.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal contrast for a treatment identified
partly through the shared-class restriction, by quadrature at an order fixed by P1.

**The induced range across admissible partitions is the derived estimand**, with its
truth being the range of contrasts the true generating structure permits.

**Two diagnostic properties are scored:** whether the range **contains** the truth,
and whether its **width** discriminates a correct partition from an incorrect one.
**A range that always contains by being wide fails the second**, and reporting only
the first is how such a display gets recommended.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| within-class interaction heterogeneity | zero; moderate; large | whether the shared restriction is true |
| separation between true classes | small; large | whether a defensible partition exists at all |
| **partition used for fitting** | the true one; a wider one; a narrower one; the widest estimable one | **the practice under test**, including the one the incentive produces |
| network information | sparse; rich | where the restriction carries identifying weight |
| covariate overlap | good, poor | the adjustment layer |
| candidate partition set | 3, 6 admissible partitions | the sensitivity display's cost |

### What the mechanism makes true, and therefore what the study cannot see

- **The admissible candidate set is supplied to the simulation.** In practice it
  must be defined with clinicians before fitting and recorded in the protocol, which
  is a process recommendation this study can motivate but not evaluate.
- **Class membership is a claim about shared mechanism of effect modification, which
  is not the same as shared mechanism of action** and is rarely the subject of direct
  evidence. The design does not simulate clinical plausibility; it simulates the
  statistical consequences of getting the partition wrong.
- The number of possible partitions grows quickly, and **the design uses a small
  declared candidate set** rather than enumerating, which is what a real analysis
  would do.
- `multinma`'s `class_interactions` argument moves between common, exchangeable and
  independent structures **within** a partition. That relaxation is available and is
  carried as a method; **extending it across partitions is what does not exist.**

## 5. Methods, including one that can win

| method | role |
|---|---|
| single partition, chosen as the widest estimable | current practice, and what the incentive produces |
| single partition, true | the oracle |
| **partition-sensitivity: refit over the candidate set and report the range** | the proposed display |
| within-partition relaxation, exchangeable interactions | `multinma`'s existing option |
| **hierarchical prior over interaction vectors around a class mean, shrinkage loosened** | the entry's alternative to an equality constraint |

**The comparator that can win is the within-partition exchangeable relaxation.** If
loosening the sharing inside a fixed partition covers the truth as well as varying
the partition does, **the existing software option is sufficient** and the
cross-partition work is unnecessary. Registered as such, and it would be the cheapest
outcome for practice.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target contrast under each fitted partition, with MCSE;
**range containment and range width**; **sign stability**, whether the contrast's
sign is constant across the candidate set, since that is what a reader would act on.

**The registered discrimination check:** whether range width separates cells where
the true within-class heterogeneity is zero from cells where it is large. **Section
2's last consequence says the display is only useful if it does**, and a width that
is constant across those cells means the display carries no information about the
assumption.

**Model fit is reported alongside**, so consequence 2's central claim is visible:
**the widest partition should fit at least as well as the true one while being more
biased.** That pairing is the study's most quotable result.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target contrast under the widest
estimable partition, at large within-class heterogeneity with sparse network
information, against the true partition.

**Decision rule.**

- The widest partition materially biased while fitting at least as well: **confirmed
  in its sharpest form**, and the deliverable is the sensitivity display plus the
  reporting requirement.
- The widest partition unbiased across the grid: **refuted**, and enlarging the class
  costs nothing, which would be worth knowing given how often it is done.
- Bias present but range width undiscriminating: **the display is honest and
  uninformative**, and the deliverable is the reporting requirement without the
  diagnostic claim.

## 8. Three controls, each of which can fail

**Null control.** With zero within-class heterogeneity, every partition that contains
the true classes is correct, so all such fits must agree and the range must be
narrow. **A wide range there means the display is measuring estimation noise rather
than assumption sensitivity.**

**Second null control.** With a rich network that identifies every interaction
separately, the partition carries no identifying weight, so **every partition must
give the same contrast.** That is the regime in which the assumption is testable, and
it anchors the claim that the problem lives where it is not.

**Positive control.** Large within-class heterogeneity, sparse network, widest
estimable partition: bias must exceed three MCSEs **and** model fit must be no worse
than the true partition's. **Both halves are required**, because the second is what
makes the failure invisible and it is the entry's central claim.

**Falsifier for the study's own headline.** The expected headline is that partition
sensitivity should be reported. Its falsifier is the discrimination check: **if range
width does not distinguish a right partition from a wrong one, the display shows a
reader that the answer depends on a choice without telling them which choice is
right**, and whether that is worth reporting is a judgment the study should state
rather than assume.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting the range as a test | Section 2 states it is a display, not a test | removed |
| A range that contains by being wide | Width is scored, and discrimination is a registered check | removed |
| Fit reported without bias, or bias without fit | Paired, since the invisibility is the point | removed |
| Clinical plausibility simulated | Not attempted; the candidate set is supplied | disclosed |
| Enumerating partitions | Small declared candidate set, as a real analysis would use | removed |
| Claiming no relaxation exists | `multinma`'s within-partition option credited and carried | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and estimability by partition | The target truth, and which partitions make the contrast estimable, before fitting | **The partition levels.** "Widest estimable" must be computed rather than guessed | days |
| **P2** fit-versus-bias reachability | That a wider partition can fit at least as well while being biased, analytically | **The positive control's second half**, which is the entry's central claim | days |
| **P3** candidate-set size | The cost of refitting over 6 partitions per replicate | The display's practicality | hours |
| **P4** unit cost | Per-fit cost times partitions times $n_{sim}$ | The grid | hours |

## 11. Cost

Every replicate is refitted once per candidate partition, so the candidate-set size
multiplies the whole design. That multiplier is the one to price rather than assume.

---

## Relationship to the rest of the queue

- **IDN-05** owns the shared-modifier check's power and is the within-partition
  relaxation this design compares against.
- **IDN-06** owns which coordinates are identified by what, which decides "widest
  estimable".
- **CMP-16** and **HET-03** own the analogous sharing question for variance
  components.
- **MIS-04** owns selection uncertainty over models and bridges; a partition is a
  third selectable object and its range would feed the same interval.
- **DEC-02** owns which structural choice most often flips a decision.
