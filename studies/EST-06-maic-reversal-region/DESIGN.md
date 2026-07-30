# EST-06 design: the reversal is a hyperplane separating two target means

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is careful about novelty and the design has to be too. This is **not**
new with Jiang et al. 2025: Phillippo et al. 2018 documented the same reversal in
a real appraisal, two competing manufacturers' MAICs, and prescribed the remedy,
namely deciding which population represents the decision target and transporting
to it. **Jiang et al.'s increment is that the paradox persists even when both
analyses use the same covariate set.** And a target-population difference is not
the only way two MAICs can disagree; sampling error, different adjustment sets,
misspecification and measurement differences can each do it.

So the study is not "does the paradox exist" and not "what is the remedy". It is
**where in covariate space the reversal lives, how often that region is reached,
and which of the competing explanations produced any particular disagreement.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** swapping which trial supplies IPD can reverse the
direction of the apparent comparison while each analysis remains internally
coherent, because the two estimate effects in different target populations; the
2018 remedy has not changed behavior; and how often the reversal arises and under
what covariate configurations is unmeasured.

**Refuting sentence:** *the configurations producing reversal are extreme enough
that the phenomenon is a curiosity, and observed disagreements between sponsor
MAICs are better explained by sampling error and differing adjustment sets.*

**That refutation is testable here in a way it is not in a case series**, because
the competing explanations can be switched off one at a time.

## 2. The mechanism: reversal is a separating hyperplane

With linear modification, the target effect in population $F$ is $\Delta(F) =
\delta + \beta_{EM}^\top \bar x_F$. Swapping the IPD trial swaps the target from
$F_A$ to $F_B$, so a reversal occurs exactly when

$$\mathrm{sign}\big(\delta + \beta_{EM}^\top \bar x_A\big) \;\neq\; \mathrm{sign}\big(\delta + \beta_{EM}^\top \bar x_B\big),$$

that is, **exactly when the zero-effect hyperplane $\{x : \delta + \beta_{EM}^\top
x = 0\}$ separates the two target means.** Four consequences:

1. **The reversal region is a slab in covariate space and its boundary is the
   same object DEC-28 is about.** Reversal is the special case where the optimal-
   treatment boundary falls between the two candidate targets, and Phillippo et
   al. 2025's proof that conditional and marginal estimands rank treatments
   oppositely only when individual effects cross within the population is the same
   condition seen from the other side. **These three entries are one geometric
   fact and the design says so rather than treating them as separate phenomena.**
2. **Reversal probability is computable**, not merely observable: given the
   sampling distributions of $\hat\delta$ and $\hat\beta_{EM}$ and the two target
   means, it is the probability that the estimated hyperplane separates them,
   which has a closed-form Gaussian approximation. **So the study can report a
   formula an analyst can evaluate before running either MAIC**, which is what
   "anticipated rather than discovered after submission" would require.
3. **Reversal needs no large populations separation if $\beta_{EM}$ is large**, and
   no large modification if the separation is large. It is again a product, so
   varying one factor alone understates it.
4. **The competing explanations have different signatures.** Sampling error
   produces reversals that are not reproducible across replicates at the same
   configuration; a target difference produces reversals that are systematic.
   **That distinction is measurable here and is not available in a case series**,
   which is the strongest reason to simulate rather than only to review.

## 3. Estimand, with its true value defined

**The design's discipline is a single externally declared target.** Both analyses
are scored against $\Delta(F_D)$ for a declared decision population $F_D$ that is
neither $F_A$ nor $F_B$, computed by quadrature at an order fixed by P1.

$\Delta(F_A)$ and $\Delta(F_B)$ are also computed, so each analysis can be scored
against its own native target as well. **Scoring only against native targets makes
both analyses unbiased and the paradox invisible**, which is EST-11's identity
applied here; scoring only against $F_D$ hides that each analysis is internally
coherent, which is the catalog's point. Both are reported.

**Reversal is a derived estimand:** the indicator that the two analyses' point
estimates have opposite signs, with its true value being whether $\Delta(F_A)$ and
$\Delta(F_B)$ genuinely have opposite signs.

## 4. Data-generating mechanism, and what it makes invisible

Two trials, each able to supply IPD, sharing a common comparator; the covariate
set is **held fixed and common** across the two analyses, which is Jiang et al.'s
increment and the condition that rules out the adjustment-set explanation by
construction in the base arm.

### Factors

| factor | levels | why |
|---|---|---|
| target-mean separation | 4 levels including zero | one factor in section 2's product |
| effect-modification strength | 4 levels including zero | the other |
| position of the zero-effect hyperplane | between the targets; outside; at one target | **the direct manipulation**, rather than hoping the product lands there |
| overlap | good, poor | whether either transport is even supportable |
| trial sizes | equal; 3:1 | the sampling-error explanation's magnitude |
| explanation arm | target difference only; **plus** differing adjustment sets; **plus** measurement differences | **section 2 consequence 4**: the competing explanations, switched on one at a time |

### What the mechanism makes true, and therefore what the study cannot see

- Modification is linear and shared, so the reversal region is a hyperplane. Under
  nonlinear modification the region is curved and the closed-form probability does
  not hold; **DIA-08 owns that departure and this design's formula is stated as
  conditional on linearity.**
- Both trials are internally valid and randomized. The reversal here is entirely a
  target-population phenomenon plus the named competing explanations, and nothing
  about bias from unmeasured confounding is included; that is QBA's territory.
- The declared decision target is available to the simulation. **In practice
  transporting both effects to one target needs common support, compatible outcome
  definitions and enough information to carry both transports**, which the catalog
  says is often exactly what is missing when the populations differ enough to
  produce the reversal. **The poor-overlap cells are where that bites and the
  design must report the arbitration methods' failure rate there rather than only
  their accuracy where they succeed.**
- One outcome type. Non-collapsibility adds a second reversal route through
  DEC-28's mechanism and is carried only as a secondary scale.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| MAIC with A as IPD | conventional | one sponsor's analysis |
| MAIC with B as IPD | conventional | the other sponsor's |
| transport both to $F_D$ | the 2018 remedy | the prescribed fix |
| **arbitrated indirect comparison** | Fang and He (arXiv:2510.18071), fixing the overlap population as the common target | the existing methodological response, **evaluated rather than reinvented** |
| naive average of the two MAICs | what a committee might do | included because it is what happens, and the catalog says not to do it unless the average is deliberately defined as an effect in a specified mixture population |

**The comparator that can win is the arbitrated comparison.** If fixing the
overlap population gives lower error against the declared decision target than
transporting both to that target does, then the practical answer does not require
a committee to declare a target at all. **The catalog's instruction is explicit
that the task is to evaluate it against transporting to an external decision
target, not to reinvent it**, and that comparison is the study's second primary.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage against the declared decision target and, separately, against
each analysis's native target. **Reversal probability**, both realized and against
section 2's closed-form prediction, whose agreement is a registered check.

**The explanation-attribution measure**, which is section 2 consequence 4: given
an observed disagreement, the probability that each candidate explanation is
correctly identified by the diagnostic available to a reader, namely the two
analyses' reported covariate tables and effective sample sizes. **A reader cannot
run this simulation; they see two tables.** Whether those tables distinguish a
target-driven reversal from a sampling-driven one is the practically useful
result.

**Failure rate of each arbitration method at poor overlap** is reported beside its
accuracy, since a method that declines or breaks is not a method that is right.

Common random numbers across the two IPD assignments, which is what makes the
reversal paired and its probability estimable at reasonable cost. MCSE clustered
on the replicate block. $n_{sim} = 4000$ per cell, because reversal is a binary
event whose rate must be resolved to a fraction of a percent in the cells where it
is rare.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Realized reversal probability as a function of target-mean
separation and modification strength, against section 2's closed-form prediction,
with the covariate set held common.

**Decision rule.**

- Realized probability tracking the formula confirms the geometry and **the
  deliverable is the formula**: a calculation an analyst can perform before either
  MAIC is run, from the two reported covariate tables and an assumed modification
  strength.
- Realized probability far from the formula means the geometry is not what drives
  reversal at these sample sizes, most likely because sampling error dominates,
  and that is reported as the finding.
- **Reversal confined to configurations outside the range seen in the reviewed
  appraisals refutes materiality**, and P2 fixes that range from the published
  cases before the run so this cannot be judged afterwards.

**Second primary, registered equally:** error against the declared decision target
for the arbitrated comparison versus transporting both effects, at poor overlap.

## 8. Three controls, each of which can fail

**Null control.** At zero effect modification, $\Delta(F)$ is constant across
populations, so the two analyses must agree and reversal must occur only at the
sampling-error rate. **That rate is computable and is checked against the
realized one**, which validates the sampling-error explanation's calibration
before it is used to attribute anything.

**Second null control.** With the zero-effect hyperplane far outside both targets,
reversal must be essentially absent at every separation and modification level.
**This is the direct test that reversal is the separating-hyperplane event and not
merely correlated with the product of two factors.**

**Positive control.** With the hyperplane placed between the targets and strong
modification, reversal must be near certain. If it is not, the manipulation is not
doing what section 2 says.

**Falsifier for the study's own headline.** The expected headline is that
reversal is a predictable geometric event. Its falsifier is the sampling-error
arm at 3:1 trial sizes: if reversals there are as frequent as in the geometric
cells and are not reproducible across replicates, then observed sponsor
disagreements are better explained by noise, the refuting sentence in section 1
holds, and the recommendation changes from a formula to a reproducibility check.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming novelty for the paradox or its remedy | Both credited to 2018 in the header; the study maps occurrence | removed |
| Attributing every disagreement to target difference | Competing explanations are switched on one at a time and attribution is measured | removed |
| Adjustment-set differences confounding the base arm | Covariate set held common, per Jiang et al.'s increment | removed |
| Reinventing the arbitrated comparison | It is evaluated as an arm, per the catalog's instruction | removed |
| Arbitration scored only where it succeeds | Failure rate at poor overlap reported beside accuracy | removed |
| Reversal region assumed reachable | P2 fixes the realistic configuration range from published appraisals before the run | removed |
| Linearity, which makes the region a hyperplane | Stated as a condition of the formula; DIA-08 named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and hyperplane placement | The three truths per cell and the hyperplane's position relative to both targets | The definition of truth and the placement factor | hours |
| **P2** realistic configuration range | Target-mean separations and plausible modification strengths from the published appraisals the catalog cites, so materiality is judged against the field's own numbers | **The grid, and the materiality verdict.** Judging reachability after seeing reversal rates is the failure this probe prevents | days |
| **P3** arbitration implementation | That Fang and He's estimator can be implemented and reproduces its paper's reported behavior on its own example | Whether that arm is a comparator or a confound | days |
| **P4** unit cost | Per-replicate cost at $n_{sim} = 4000$; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Weighting fits only, but $n_{sim} = 4000$ across a crossed grid with five methods.
Modest; priced in P4.

---

## The case-study half

The queue records this entry as simulation **plus case study**, and the case half
is not decoration: the mechanism is reproduced in a published two-sponsor MAIC by
recomputing both directions from the reported covariate tables and evaluating
section 2's formula against what the two submissions actually reported. **That is
the only part of this study that speaks to whether the configurations occur in
practice**, and the simulation cannot substitute for it.

---

## Relationship to the rest of the queue

- **DEC-28** owns the boundary this study's hyperplane is a case of; if both run,
  the geometry is derived once.
- **EST-11** owns the target menu and supplies the native-versus-declared scoring
  identity used in section 3.
- **EST-12** owns treatment hierarchies without a declared referent, the
  network-scale version.
- **COV-14** owns differing adjustment sets across comparators, which is one of
  the competing explanations here and its owner.
- **DEC-02** owns which choice most often flips a decision.
