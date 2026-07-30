# EST-12 design: separating rank movement from target choice from rank movement from noise

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The dependence is demonstrated rather than theoretical. Susukida et al. reweighted
a four-medication cocaine dependence network to successive target populations and
the medications reordered in both directions, **with the medication ranked worst
for abstinence becoming second best, while every pairwise interval still
overlapped**. A reader of the unweighted hierarchy had no signal that the ordering
was population-specific.

Wigle and Moodie supply the **conditional** version, a hierarchy at one covariate
profile, and explicitly advise against the aggregate-data meta-regression route
because of ecological confounding, which closes it to the aggregate-only networks
most submissions contain. **The target-standardized version does not exist**, and
section 2 shows it is a join rather than new inference.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** ranking metrics are functionals of the whole set of
relative effects, so they inherit the population dependence of every contrast at
once; none is defined with respect to a declared target covariate distribution; and
no reporting template requires a hierarchy to name the population it refers to.

**Refuting sentence:** *rank movement across plausible targets is small relative to
rank movement from sampling variability, so an unlabeled hierarchy is
uninformative for a different and already-known reason and adding a target referent
changes nothing a reader would act on.*

**Trinquart et al. quantified the noise component**, so the refuting sentence has a
measured baseline and this study's job is to put the target component on the same
axis.

## 2. The mechanism: a rank reversal is a pairwise boundary crossing

Under linear modification, treatment $k$'s target effect is $\Delta_k(F_T) =
\delta_k + \beta_k^\top \bar x_T$. Treatments $j$ and $k$ swap between targets
$T_1$ and $T_2$ exactly when

$$(\delta_j-\delta_k) + (\beta_j-\beta_k)^\top \bar x_{T} \quad\text{changes sign between } \bar x_{T_1} \text{ and } \bar x_{T_2},$$

that is, when the segment joining the two target means **crosses the pairwise
zero-difference hyperplane.** Three consequences:

1. **This is the same geometric object as EST-06's MAIC reversal and DEC-28's
   optimal-treatment boundary.** A hierarchy is a collection of pairwise
   comparisons, so the ranking is stable exactly where the target means lie on one
   side of every pairwise hyperplane. **Three entries in this queue are one fact**
   and the design says so rather than treating them separately.
2. **A hierarchy is discontinuous, so uncertainty propagates non-smoothly.** A small
   change in the target can flip ranks without moving any effect materially, which
   is exactly what Susukida et al. observed with overlapping intervals. **So the
   right output is not a hierarchy with an interval; it is a family of hierarchies
   indexed by target**, which the entry says plainly.
3. **The two sources of rank movement are separable and have different signatures.**
   Sampling noise reshuffles ranks independently across replicates at a fixed
   target; target choice moves them systematically and reproducibly. **So a
   diagnostic can attribute rank instability**, and that diagnostic is this
   study's deliverable: each treatment's rank range across a prespecified target
   set, reported alongside its rank interval from sampling variability.

**The machinery for the join already exists on both sides.** ML-NMR returns
population-average effect draws for an arbitrary declared target; SUCRA and the
P-score are functionals of those draws. **No new inferential machinery is needed**,
which is why this is a feasible study rather than a research programme.

## 3. Estimand, with its true value defined

**Primary.** The target-standardized hierarchy: SUCRA, P-score and probability-best
computed from relative effects **averaged over a named target's joint covariate
distribution**.

**True value** from the generating model: the true target-standardized effects, and
hence the true ranking, computed exactly per target.

**Two derived estimands.** **Rank range across the target set**, and **rank interval
from sampling variability at a fixed target**. Their comparison is the primary
outcome, and reporting either alone is what current practice does.

## 4. Data-generating mechanism, and what it makes invisible

Mixed IPD-and-aggregate network of five to six treatments, the size at which
hierarchies are actually reported.

### Factors

| factor | levels | why |
|---|---|---|
| target set | each contributing trial population; the pooled network population; a jurisdictional decision population | the entry's own prespecified set |
| effect-modifier imbalance across trials | small, moderate, large | how far apart the targets are |
| **position of target means relative to the pairwise hyperplanes** | all on one side; one crossing; several crossings | **section 2 consequence 1, manipulated directly** rather than hoped for |
| uncertainty in target moments | exact; $n_T = 300$ | propagates non-smoothly, per consequence 2 |
| network size | 5, 6 treatments | the number of pairwise boundaries grows quadratically |
| true effect separation | well separated; two nearly tied | rank instability needs near-ties to be interesting |

### What the mechanism makes true, and therefore what the study cannot see

- **Modification is linear and shared within treatment**, so the boundaries are
  hyperplanes. Under nonlinear modification they curve and the closed-form
  crossing condition does not hold; DIA-08 owns that departure.
- The target distributions are known. **EST-07 and MIS-03 own their sampling
  error**, carried here only as a two-level factor because consequence 2 says the
  propagation is non-smooth and that is worth seeing.
- ML-NMR is the only method fitted, because it is the only one returning
  population-average effects for an arbitrary target. **Wigle and Moodie's advice
  against the aggregate-data meta-regression route is followed**, not tested.
- Which population a hierarchy *should* refer to when one review serves several
  decision-makers has no agreed answer, and this study does not supply one. **It
  supplies the family and the diagnostic**, which is what the entry asks for.

## 5. Methods, including one that can win

| method | role |
|---|---|
| unlabeled hierarchy from the pooled network | current practice |
| **target-standardized hierarchy per target** | the join |
| conditional hierarchy at a covariate profile | Wigle and Moodie's version, for comparison |
| **rank range across the target set** | the diagnostic |
| rank interval from sampling variability | Trinquart et al.'s quantity, the baseline |

**The comparator that can win is the unlabeled hierarchy.** If its ordering matches
the target-standardized ordering for every target in the prespecified set across
the realistic imbalance range, the refuting sentence holds and the labeling is a
formality. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**Rank reversal frequency** between targets and against truth; **rank coverage**,
whether the reported rank interval contains the true rank; **decision change**,
whether the top-ranked treatment differs; all with MCSE.

**The attribution measure, which is the deliverable:** for each treatment, rank
range across targets against rank interval from sampling, reported as a paired
display. **Section 2 consequence 3 predicts they are separable, and if they are
not, the diagnostic cannot be built** and that is the finding.

**The registered mechanism check:** observed rank reversals against the analytic
hyperplane-crossing prediction. **Agreement confirms that reversal is a geometric
event and makes it predictable before any fit**, which is the same result EST-06
seeks for the two-trial case.

Common random numbers across targets within a replicate, so rank movement from
target choice is paired and separable from noise. **That pairing is what makes the
attribution possible at all.**

$n_{sim} = 2000$ per cell, Stan-limited to 1000 where ML-NMR is refitted per
target; reported at its own count.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Rank range across the target set against rank interval from
sampling variability, at moderate imbalance with one hyperplane crossing.

**Decision rule.**

- Rank range comparable to or exceeding the sampling interval: **the target
  referent is material**, and the deliverable is the family-of-hierarchies display
  plus the requirement to name the population.
- Rank range negligible against the sampling interval: **refuted**, and the honest
  message is that hierarchies are unstable for the reason already known.
- **The paired display is published in either branch**, because it is what tells a
  reader which kind of instability they are looking at and does not depend on which
  dominates.

## 8. Three controls, each of which can fail

**Null control.** With no effect modification, every target gives the same effects,
so the hierarchy must be identical across targets and the rank range must be
exactly zero. **Any nonzero range there is the harness leaking noise into the target
comparison**, which the common-random-number pairing exists to prevent.

**Second null control.** With all target means on one side of every pairwise
hyperplane, section 2 says no reversal can occur regardless of imbalance
magnitude. **That separates "targets differ" from "targets differ across a
boundary"**, and it is the check that consequence 1 is the operative mechanism
rather than a correlate of imbalance.

**Positive control.** With several crossings and two nearly tied treatments,
reversals must be near-certain. If they are not, the manipulation is not doing what
the geometry says.

**Falsifier for the study's own headline.** The expected headline is that target
choice is a distinct and material source of rank instability. Its falsifier is the
near-tie factor: **if reversals occur only between treatments that are nearly tied,
then no decision turns on them and the instability is real but harmless.** Decision
change, not rank reversal, is therefore reported as the deciding summary in the
realistic cells, fixed now.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Rank instability from noise and from target choice pooled | Common random numbers across targets; paired display | removed |
| Reversal reported without decision relevance | Decision change fixed as the deciding summary before the run | removed |
| Claiming a hierarchy should refer to one population | The family is the output; no single referent prescribed | removed |
| Testing a route already advised against | Aggregate-data meta-regression not used, per Wigle and Moodie | removed |
| Nonlinear modification | Linear only; DIA-08 named | disclosed |
| Target-moment uncertainty | Two levels only; owners named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and hyperplanes | True target-standardized effects and the pairwise boundaries per cell | The definition of truth and the crossing factor | hours |
| **P2** crossing construction | Target sets that do and do not cross boundaries at matched imbalance | **The design's central control**; without it crossing is confounded with distance | days |
| **P3** ranking from ML-NMR draws | That SUCRA, P-score and probability-best can be computed from `multinma`'s target-population draws directly | Whether the join is a script or a package change | hours |
| **P4** unit cost | Per-fit cost times targets times $n_{sim}$; total computed not typed | The target set size | hours |

## 11. The case-study half

Reproduce the analysis in a published IPD-plus-aggregate network and report the
family of hierarchies with the paired display. **That is the output the entry says
does not exist, and producing one on real data is what would make a reporting
requirement arguable.**

---

## Relationship to the rest of the queue

- **EST-06** and **DEC-28** own the same geometry in the two-trial and
  optimal-treatment cases; if any two run, the boundary computation is shared.
- **HET-04** owns node splitting without target standardization, the same defect on
  a different output.
- **EST-11** owns the target menu, which supplies this design's target set.
- **DEC-01** and **DEC-02** own decision error, which is this design's deciding
  summary.
