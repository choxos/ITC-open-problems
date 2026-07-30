# DIS-21 design: publish the curve, in units of the within-trial distance

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note is a precondition: **run early only after fixing the dissimilarity index**,
and a study claiming one universal cutoff would be weak. Both are followed. **The
index is standardized first**, because a threshold calibrated on one index does not
transfer to another, and **the output is a curve rather than a number.**

The entry supplies two anchors this design is built on. **Arms of the same randomized
trial differ by an average distance of 0.01, range 0.00 to 0.03, against a threshold
of 0.1 used in practice**, roughly an order of magnitude looser; only one of eight
admitted matches would have survived a randomized-comparable cutoff. And where an
external check existed, the matched analysis returned a hazard ratio of **1.15 (0.77
to 1.74) against 0.73 and 0.60 from individual-patient analyses** — the opposite side
of the null, with the widest interval.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** nothing ties the maximum admissible dissimilarity to the
bias it induces; the cutoff also decides **which cross-gap comparisons exist at all**,
so one number silently fixes both the point estimate and the reported comparison set;
and the two failure modes are not commensurable.

**Refuting sentence:** *bias in the bridged contrast is flat over the range of
thresholds anyone would use, so the cutoff matters only through the comparison set and
the calibration question is really a reporting question.*

## 2. The mechanism: the threshold moves the estimate and the question together

Let $\theta$ be the threshold and $\mathcal{M}(\theta)$ the admitted match set. Two
things vary with $\theta$ and they vary in opposite directions:

$$\text{bias} \;=\; b(\theta), \quad \text{increasing in } \theta; \qquad
|\mathcal{M}(\theta)|, \quad \text{also increasing in } \theta .$$

Three consequences:

1. **A sensitivity analysis over $\theta$ does not hold the estimand fixed.** Tighten
   the threshold and some comparisons cease to exist; loosen it and new ones appear.
   **So the usual sensitivity display, the estimate against the parameter, is
   comparing different questions at different points**, and the design must report the
   comparison set alongside the estimate at every $\theta$ or the curve is
   uninterpretable. **The entry says exactly this and no published analysis does it.**
2. **The two failure modes are not on one scale.** A loose threshold biases the point
   estimate; a tight one understates uncertainty **and** shrinks the reported
   comparison set. **No loss function trades them**, and this design does not invent
   one; it reports both arms of the trade-off and lets the decision context weight
   them.
3. **The natural unit is the within-randomized-trial distance distribution.** Arms of
   one randomized trial are exchangeable by construction, so the distances between
   them measure what "as similar as randomization delivers" looks like on that index.
   **Expressing $\theta$ as a multiple of that distribution makes thresholds
   comparable across indices and applications**, which a raw 0.1 is not. **That is the
   entry's proposal and it is the design's standardization.**

**The index must be fixed before any of this means anything.** Covariate set,
weighting rule and normalization are analyst choices, and a threshold calibrated on
one does not transfer. **P1 fixes the index and the design reports results per index
definition rather than averaging over them.**

## 3. Estimand, with its true value defined

**Primary.** The cross-gap treatment contrast after edge deletion, with the **retained
full-network estimate as the reference**, which is not truth: it carries its own
uncertainty, and every comparison is uncertainty-aware as in IDN-08.

**The comparison set is a second, equally reported estimand:** how many and which
cross-gap comparisons exist at each $\theta$.

**The deliverable is the pair as a function of $\theta$**, expressed in multiples of
the within-trial distance distribution, so a reader can locate the threshold they were
going to use and read off both the expected bias and what they would be giving up.

## 4. Data-generating mechanism, and what it makes invisible

Two layers, as the sketch specifies: **Monte Carlo networks establish operating
characteristics; real-network deletions test whether the calibration survives
realistic covariate reporting and topology.**

### Factors

| factor | levels | why |
|---|---|---|
| threshold $\theta$ | a grid in multiples of the within-trial distance, spanning 1× to 20× | the axis, in the standardized unit |
| index definition | three declared covariate-set and weighting choices | consequence 3's transferability |
| covariate overlap across the gap | good, poor | how much the match is doing |
| index normalization | two rules | an analyst choice with no convention |
| true similarity of the matched pair | similar; dissimilar within threshold | whether the threshold is doing its job |

### What the mechanism makes true, and therefore what the study cannot see

- **The calibration is borrowed from settings where the answer is known**, and whether
  it transfers to a real gap is **IDN-08's question**. This design produces the curve;
  IDN-08 asks whether a cut link resembles a real gap. **Neither answers the other and
  the two should be read together.**
- The individual-level caliper result does not port: **study-level matching has more
  covariates, no individual data, and a distance on reported summaries rather than on
  an estimated propensity score.** The template is acknowledged and not reused.
- Real-network deletion depends on covariate reporting, which is the binding
  constraint IDN-08 also faces.
- **No universal cutoff is proposed in any branch**, per the note.

## 5. Methods, including one that can win

| arm | role |
|---|---|
| matched bridge at each $\theta$ | the thing under test |
| full-network estimate | the reference |
| component network meta-analysis | the alternative bridge, the only head-to-head evidence available |
| **whole admissible match space reported as a sensitivity** | the entry's proposal: report the space, not one admitted set |

**The comparator that can win is the component network meta-analysis bridge.** If it
recovers the full-network contrast across the grid without needing a threshold at all,
**the calibration problem is avoidable by choosing a different bridge**, and the
deliverable becomes that recommendation. Registered as such, and Rücker et al.'s
head-to-head is the reason it is live.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, interval coverage and **decision reversal** in the bridged contrast at each
$\theta$, uncertainty-aware against the reference, with MCSE.

**Edge retention** at each $\theta$: how many cross-gap comparisons survive, and which.

**Reported as a joint curve**, since consequence 1 says either alone misleads.

**The within-trial distance distribution is measured on the same networks**, so the
standardized unit is empirical rather than borrowed from one published application.

$n_{sim} = 2000$ Monte Carlo networks per cell; the real-network deletions are
enumerated rather than sampled.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and decision reversal against $\theta$, in multiples of the
within-trial distance, at poor overlap.

**Decision rule.**

- Bias rising materially with $\theta$ over the used range: **confirmed**, and the
  deliverable is the curve with the comparison set alongside, plus the observation
  that the conventional threshold sits far outside the within-trial range.
- Bias flat: **refuted**, and the cutoff matters only through the comparison set,
  which is still worth reporting and is a much simpler message.
- **The within-trial distance distribution is reported in either branch**, because it
  is the unit and it is measurable without any calibration.

## 8. Three controls, each of which can fail

**Null control.** Deleting an edge and re-admitting a match between the **same two
studies** must recover the full-network estimate exactly. **That is the identity case
and it validates the deletion-and-match pipeline before any threshold result.**

**Second null control.** At $\theta$ equal to the within-trial distance's median, the
admitted matches are as similar as randomization delivers, so bias must be at its
floor. **If bias is already material there, the threshold is not the operative
quantity** and the index is failing rather than the cutoff.

**Positive control.** At $\theta = 20\times$ the within-trial distance with poor
overlap, bias must be material. If it is not, the threshold cannot be made to matter
in this design and the study says so.

**Falsifier for the study's own headline.** The expected headline is that thresholds
should be calibrated and expressed in within-trial units. Its falsifier is
consequence 1 taken seriously: **if the comparison set changes so much across the
grid that the curves at different $\theta$ describe different networks, then no single
curve is readable** and the honest output is the whole admissible match space with no
recommended point on it. **That is the entry's own fallback and the design must be
able to land there.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Proposing one universal cutoff | Excluded by the note and by section 2 consequence 2 | removed |
| A threshold calibrated on an unstandardized index | Index fixed in P1; results reported per definition | removed |
| Sensitivity curve that silently changes the question | Comparison set reported at every $\theta$ | removed |
| Porting the individual-level caliper result | Acknowledged as not transferring | removed |
| Full-network estimate treated as truth | Uncertainty-aware throughout | removed |
| Whether a cut link resembles a real gap | IDN-08's question, named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** index standardization | A fixed covariate set, weighting rule and normalization, declared before any calibration | **Everything**, per the note's precondition | days |
| **P2** within-trial distance distribution | The empirical distribution of arm-to-arm distances within randomized trials on the fixed index, which is the unit | **The axis.** Without it the grid is in raw units and does not transfer | days |
| **P3** real-network availability | Which connected networks carry the covariate reporting needed, shared with IDN-08's survey | Whether the second layer runs | days |
| **P4** unit cost | Per-network cost; total computed not typed | The grid | hours |

## 11. Cost

Frequentist network fits at 2000 replicates across a threshold grid; the grid
multiplies, and the real-network layer is data access rather than compute.

---

## Relationship to the rest of the queue

- **IDN-08** owns whether deletion-based calibration transfers to a real gap, and
  shares P3's data survey; the two are halves of one validation programme.
- **DIS-11** owns whether predictive criteria can validate a bridge at all.
- **DIS-03** owns baseline risk as an alternative anchor.
- **CMP-24** owns edge influence, which says how much a manufactured edge carries.
- **OVL-02** owns feasibility, which decides whether a match is even computable.
