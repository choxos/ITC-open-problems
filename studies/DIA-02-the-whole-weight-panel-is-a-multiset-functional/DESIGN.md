# DIA-02 design: two analyses with identical diagnostics and different support

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Three other entries touch overlap diagnostics and this one has to be distinct from
all of them. **DIA-03 has run** and scored the reported panel as classifiers.
**OVL-01** owns whether unsupported mass matters, which depends on its alignment
with effect modification. **OVL-02** owns calibration feasibility and what is
computable from published marginals. **DIA-02's own sketch names the manipulation
that belongs to it: hold conventional ESS approximately constant and vary where
the support holes are.**

Section 2 shows that manipulation can be made exact, and that it defeats more than
ESS.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a global effective sample size is a scalar function of
the weight distribution, so it does not encode where in covariate space the
support lies or whether the supported region is relevant to the decision contrast;
balance is reported on the moments that were matched, which is tautological; and
at least three competing ESS calculations exist, so two analyses of the same
evidence can report incomparable numbers.

**Refuting sentence:** *in realistic covariate laws, weight concentration and
support geometry move together tightly enough that the global summary is an
adequate proxy, and constructing a counterexample requires configurations that do
not occur.*

## 2. The mechanism: the panel is a function of the weight multiset

$$\mathrm{ESS} \;=\; \frac{\left(\sum_i w_i\right)^2}{\sum_i w_i^2}$$

depends on the weights **only through their multiset**. Permute which unit carries
which weight and ESS is unchanged. The same is true of every other member of the
reported panel: entropy efficiency, coefficient of variation, maximum normalized
weight and top-share mass are all symmetric functions of $\{w_i\}$.

**So the invariance is not a property of ESS. It is a property of the entire
weight panel**, and DIA-03's proof that ESS, ESS/n and the weight CV are one
statistic is a special case of it. Three consequences:

1. **Two analyses whose weight multisets coincide have identical panels, whatever
   their support geometry.** The counterexample is therefore not a fluke to be
   hunted for; it is constructible.
2. **Any diagnostic capable of distinguishing them must be a function of the
   weights *and their covariate positions*.** Convex-hull distance, region-specific
   ESS, density-ratio maps and optimal-transport cost all are; nothing in the
   reported panel is.
3. **Balance on matched moments cannot help**, because it is zero at the solution
   of the calibration equations. DIA-03 measured this and found it never exceeded
   $1.4\times 10^{-14}$. **Balance on *omitted* moments is a multiset-and-position
   functional and can help**, which makes it the cheapest candidate in the study
   and the one most often skipped.

**The three competing ESS definitions are a separate defect and are treated
separately.** Their disagreement is a comparability problem, not a discrimination
problem, and the design reports the spread across definitions on identical data
rather than picking one.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, by quadrature at an
order fixed by P1.

**Material error is the derived estimand** for the classifier analysis, defined as
absolute error above a declared threshold set in P2 from the decision context.

**A third, and it is what the manipulation needs:** the **support-hole location**,
defined as the region of target covariate space with source density below a
declared quantile, and the **decision relevance** of that region, defined as the
share of the target's effect-modification mass it contains.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **matched weight multiset** | held approximately constant across the support factor | **the manipulation**; P2 constructs it |
| support-hole location | none; in a low-modification region; in a high-modification region | section 2 consequence 1, and it is what makes the hole matter |
| global overlap | good, moderate | the conventional axis, crossed so the manipulation is not confounded with it |
| omitted moments | all reported moments matched; one modifier's second moment unmatched | section 2 consequence 3 |
| effect-modification strength | moderate, strong | the multiplier |
| covariate dimension | 3, 8 | how localized a hole can be |

### What the mechanism makes true, and therefore what the study cannot see

- **The weight multiset is held constant only approximately.** Exact equality is
  not attainable while also varying the geometry, so P2 must establish how close
  it gets and the analysis reports the residual panel difference. **If the panel
  differs materially between arms, the manipulation has failed and the design says
  so rather than proceeding.**
- The support hole is known to the simulation. An analyst does not know it, so
  every candidate diagnostic is computed on estimated support while truth uses the
  real one, as in OVL-01.
- MAIC weights only. STC and ML-NMR do not produce a weight vector, and the panel
  under test is a weighting panel; the entry lists other methods but the
  diagnostic complaint is about weights.
- The full eleven-item panel and cross-package standardization are **out of
  scope**, per the catalog's note. Four candidate geometric diagnostics are
  evaluated, not eleven.

## 5. Methods, including one that can win

| diagnostic | function of | role |
|---|---|---|
| Kish ESS, entropy efficiency, max weight, top-share | multiset only | the reported panel; section 2 says they cannot discriminate |
| balance on **omitted** moments | multiset and position | the cheap candidate |
| region-specific ESS | multiset and position | the localized version of the panel |
| convex-hull distance | position | geometric |
| optimal-transport cost | position | geometric, and the most expensive |
| the three competing ESS definitions | multiset only | reported for their **spread**, not their discrimination |

**The comparator that can win is balance on omitted moments.** It costs nothing,
it is already computable in every implementation, and if it discriminates as well
as optimal-transport cost then the recommendation is a one-line addition rather
than a new geometry. Registered as the outcome most likely to overturn the
expected headline.

## 6. Performance measures, MCSE, and $n_{sim}$

Each diagnostic scored as a classifier of material error at the level of a single
analysis, with AUROC, calibration and decision curves, following DIA-03.

**The invariance check, which is the study's structural evidence:** the difference
in each panel member between the two support-hole arms at matched multisets. **It
must be within Monte Carlo error for the multiset functionals and materially
nonzero for the geometric ones.** That is section 2 stated as a measurement.

**The comparability measure:** the spread across the three ESS definitions on
identical data, reported as a ratio. **Two analyses reporting incomparable numbers
is the complaint, and its size has never been quantified.**

Common random numbers across diagnostics within a replicate; MCSE clustered on the
replicate block. $n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** AUROC of each diagnostic against material error, in the arm
where the support hole sits in a **high-modification** region at matched weight
multisets.

**Decision rule.**

- Panel members at chance while at least one geometric diagnostic is materially
  better **confirms** the proposition, and the deliverable is that diagnostic plus
  the invariance argument.
- Panel members discriminating as well as geometric ones **refutes** it: in
  realistic laws the geometry tracks the concentration and the reported panel is
  adequate.
- **The ESS-definition spread is reported in either branch**, because
  comparability is a separate defect with a separate fix.

## 8. Three controls, each of which can fail

**Null control.** With no support hole and good overlap, every diagnostic must be
at chance for material error, because there is no material error to detect. **A
diagnostic that appears to discriminate here is discriminating noise**, which
DIA-03 found for the balance statistic, whose apparent AUROC of 0.550 was
floating-point residual.

**Second null control, and it is section 2 made a control.** At matched weight
multisets, every multiset functional must be **numerically identical** between the
two support arms, not merely statistically indistinguishable. **This is an
algebraic identity, so it is checked at numerical precision**, and a difference
means the multisets were not matched and the manipulation did not happen.

**Positive control.** With a support hole in a high-modification region, MAIC must
incur material error at a substantial rate. If it does not, there is nothing for
any diagnostic to detect and the study reports that the geometry does not matter
at these configurations.

**Falsifier for the study's own headline.** The expected headline is that the
panel is blind to geometry. Its falsifier is the matched-multiset construction
itself: **if P2 cannot construct materially different geometries at matched
multisets in realistic covariate laws, then the counterexample requires
configurations that do not occur and the refuting sentence in section 1 stands.**
That is a real possibility and P2 runs before registration for exactly that
reason.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Duplicating DIA-03, OVL-01 or OVL-02 | Scoped to the matched-multiset manipulation; their results imported | removed |
| The eleven-item panel, too large for one study | Four geometric candidates, per the note | removed |
| Matched multisets assumed rather than achieved | Second null control checks at numerical precision; P2 constructs them | removed |
| A diagnostic scored on true support an analyst lacks | Computed on estimated support; truth uses the real one | disclosed |
| ESS-definition spread confused with discrimination | Reported separately as comparability | removed |
| Balance on matched moments used as a comparator | Carried only to demonstrate it is identically zero | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | minutes |
| **P2** matched-multiset construction | Covariate laws and target moments giving materially different support geometry at approximately equal weight multisets, with the residual panel difference quantified | **The whole design, and the falsifier in section 8.** If this cannot be constructed the study does not exist | days |
| **P3** material threshold | The error magnitude a decision would notice | Every classifier result | hours |
| **P4** unit cost | Per-replicate cost including optimal-transport; total computed not typed | The diagnostic set | hours |

## 11. Cost

Weighting fits plus geometric diagnostics; optimal-transport cost is the only
expensive member and its cost is measured rather than assumed small.

---

## Relationship to the rest of the queue

- **DIA-03** has run; its identities and classifier machinery are imported.
- **OVL-01** owns support alignment and abstention; **OVL-02** owns calibration
  feasibility and computability. This design owns the matched-multiset invariance.
- **OVL-03** owns aggregating a support diagnostic over a target distribution,
  which is what region-specific ESS attempts.
- **CMP-24** owns contrast-specific edge influence, the one panel member that is
  not a weight functional at all.
