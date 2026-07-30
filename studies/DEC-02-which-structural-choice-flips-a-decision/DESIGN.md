# DEC-02 design: two rankings, because two kinds of choice are not comparable

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is a hard constraint and this design is built inside it:
**attempt it only after DEC-01 defines the decision metric and the factor set is
reduced.** The unrestricted factorial would be incoherent, and the reason is in
the entry's own text: the four choices are not equivalent in kind.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no study crosses bridge type, prior specification,
target-population definition and outcome model in a factorial scored on decision
reversals, so there is no ranking of which structural choice most often flips a
recommendation; the four choices are made at different points in the workflow by
different people, so their interactions are never observed.

**Refuting sentence:** *one factor dominates so heavily that a ranking is
uninformative, and the useful output is a single warning rather than an ordering.*

**The two published data points suggest which factor that would be.** Jiang et al.
2025 show target-population choice alone can reverse which drug is judged
superior, and Cassidy et al. 2023 show across 80 comparisons that MAICs
systematically shift estimates toward the treatment whose IPD is held.

## 2. The mechanism: a reversal means different things for different factors

The entry's own sentence is the design: changing the target population changes the
**estimand**; changing the bridge changes the **identifying assumptions**; a prior
changes **regularization and the posterior**; an outcome-model specification
usually changes the **estimator**, not the estimand.

Write the decision as $D(\theta)$ for a decision functional $D$ and estimand
$\theta$. Then a reversal between two analyses can arise two ways:

$$\underbrace{D(\theta_1) \neq D(\theta_2)}_{\text{different questions}} \qquad\text{or}\qquad \underbrace{D(\hat\theta^{(1)}) \neq D(\hat\theta^{(2)}) \text{ with } \theta_1 = \theta_2}_{\text{same question, different answer}} .$$

Three consequences:

1. **A reversal of the first kind is not sensitivity.** Two target populations are
   two decision questions, and reporting their disagreement as instability
   conflates a definitional choice with an inferential one. **So target population
   cannot be a factor in the same factorial as prior scale**, and the catalog says
   so: alternative target populations are analyzed **separately as different
   decision questions**.
2. **The bridge is the hard case and it is not obviously on either side.** It
   changes the identifying assumptions, so two bridges answer the same question
   under different premises. That is neither a different question nor merely a
   different estimator. **It is placed with the estimand-changing factors and the
   placement is declared**, because it is a judgment and a reader must be able to
   disagree with it.
3. **Therefore the deliverable is two rankings, not one.** Within the fixed
   decision question: which of prior and outcome model more often flips $D$.
   Across questions: how much the target and bridge choices move $D$, reported as
   a range over declared alternatives rather than as a reversal rate. **A single
   undifferentiated ranking would be the incoherent study the note warns
   against.**

## 3. Estimand, with its true value defined

**Primary.** The target-population incremental net benefit at a declared
willingness-to-pay threshold, in **one** declared decision population held fixed
throughout the factorial.

**True value** by quadrature over the declared target with the generating model
and a declared cost and utility model, at an order fixed by P1.

**The decision is the derived estimand:** $D = \mathbb{1}\{\text{INB} > 0\}$, with
its true value known. **Reversal is defined against the truth, not against another
analysis**, which is what makes "wrong decision" measurable rather than merely
"different decision". Both are reported: **wrong-decision probability** against
truth, and **recommendation reversal** between factor levels, because the second
is what an appraisal committee actually observes and the first is what matters.

**The decision metric is DEC-01's**, imported rather than defined here. If DEC-01
has not run, this study cannot start; that dependency is stated rather than
worked around.

## 4. Data-generating mechanism, and what it makes invisible

### The factorial, inside one decision question

| factor | levels | kind |
|---|---|---|
| prior specification | weak; default; informative | regularization |
| outcome model | linear; spline; misspecified | estimator |
| overlap | good, poor | context, crossed with both |
| effect modification | moderate, strong | context |

Fully crossed. **Only coherent combinations are run**, and P2 enumerates them: a
prior level is meaningless for a frequentist outcome-model arm, and crossing them
anyway would produce cells that do not exist.

### The estimand-changing choices, analyzed separately

| choice | levels |
|---|---|
| target population | index; comparator; pooled; overlap |
| bridge | shared-component; baseline-risk anchor; no bridge, subnetworks separate |

**These are reported as a range of decision outcomes across declared
alternatives**, with each alternative's estimand named, and never as a reversal
rate pooled with the factorial above.

### What the mechanism makes true, and therefore what the study cannot see

- **The willingness-to-pay threshold and the cost model are declared and fixed.**
  Every result is conditional on them, and a different threshold would give a
  different ranking. **That conditionality is the largest limitation and belongs
  in the abstract**, not in a discussion paragraph.
- Cassidy et al.'s empirical finding, that MAICs shift toward the IPD holder's
  treatment, is a property of real submissions and **cannot be reproduced by a
  simulation in which no one chooses which trial to hold**. The design does not
  attempt it and does not claim to explain it.
- One network geometry and one outcome type, so the ranking is for that setting.
- The factors are varied by the analyst here; in practice they are chosen by
  different people at different times, which is the entry's own explanation for
  why their interactions are never observed. **A simulation cannot restore that
  organizational structure**, so interaction estimates here are an upper bound on
  what a single analysis would reveal.

## 5. Methods, including one that can win

The "methods" are the factor combinations, plus:

| arm | role |
|---|---|
| oracle analysis | correct model, correct prior, declared target: the decision ceiling |
| each factorial cell | the ranking |
| each estimand-changing alternative | the range |

**The comparator that can win is the prior.** The literature's attention is on
target population and bridge, and if prior specification turns out to flip more
decisions than the outcome model within a fixed question, the practical
recommendation is about prespecifying priors, which is cheap and currently not
done. Registered as the outcome most likely to overturn the expected headline.

## 6. Performance measures, MCSE, and $n_{sim}$

Wrong-decision probability against truth, and reversal frequency and **direction**
between factor levels, with MCSE; expected loss under the declared decision
problem; and **factorial contrasts with interactions**, since the entry's point is
that the interactions have never been observed.

**Reversal direction matters and is reported.** A factor that flips decisions
symmetrically is noise; one that flips them consistently toward a particular
treatment is bias, and Cassidy et al.'s finding is exactly of that second kind.

MCSE clustered on the replicate block, with common random numbers across factor
levels so reversals are paired within a replicate. **Pairing is what makes a
reversal rate estimable at reasonable cost**, since a reversal is a change within
one dataset rather than a difference of two rates.

$n_{sim} = 4000$ per cell, derived from resolving a reversal rate of 0.05 to
within 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The ranking of prior specification against outcome model by
reversal frequency within the fixed decision question, at poor overlap and strong
effect modification.

**Decision rule.**

- A clear ordering with non-overlapping intervals: **that ordering is the
  deliverable**, and the recommendation is that the higher-ranked choice must be
  prespecified in a protocol.
- No separable ordering: the study reports that within a fixed decision question
  neither dominates, which is itself worth knowing given that neither is currently
  prespecified.
- **The estimand-changing range is reported in either branch**, with each
  alternative's estimand named, because it answers a different question and does
  not depend on the factorial's verdict.

**The interaction is reported whatever the main effects show.** The entry's stated
gap is that interactions are never observed, so reporting only main effects would
leave the gap open while appearing to close it.

## 8. Three controls, each of which can fail

**Null control.** With good overlap, no effect modification and a correctly
specified model, every factor level must give the same decision in essentially
every replicate. **A reversal here is Monte Carlo noise or an implementation
fault, and its rate is the floor against which every other reversal rate is
read.** Without that floor a reversal rate of 0.05 is uninterpretable.

**Second null control.** With the true effect far from the decision threshold, no
factor may flip the decision. **Reversal is only possible near the threshold**, so
this control establishes that the design's reversal rates are driven by proximity
to the threshold rather than by estimator instability, and it separates the two.

**Positive control.** With the true effect at the threshold, reversal rates must
approach 50% for every factor, since the decision is a coin flip by construction.
**If they do not, the decision functional is not being computed correctly.**

**Falsifier for the study's own headline.** The expected headline is that the
factors can be ranked. Its falsifier is the second null control's logic taken
further: if reversal rates are essentially a function of distance from the
threshold and not of the factor, then the ranking is an artifact of where the
truth sits relative to the threshold, and **the honest deliverable is a statement
about proximity rather than a ranking of choices.** That is a real possibility and
the design must be able to reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Estimand-changing and estimator-changing factors in one ranking | Separated in section 2; two deliverables | removed |
| Incoherent factor combinations | Enumerated in P2; only coherent cells run | removed |
| Reversal rates without a noise floor | Null control supplies it | removed |
| Ranking that is really a threshold-proximity artifact | Second null control and the falsifier | removed |
| Reversal direction ignored | Reported; Cassidy et al.'s finding is directional | removed |
| Decision metric invented here | Imported from DEC-01; dependency stated | removed |
| Willingness-to-pay conditionality | Declared, in the abstract | disclosed |
| Claiming to explain the IPD-holder shift | Explicitly not attempted | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P0** DEC-01 | The decision metric. **This study does not start until DEC-01 has defined it** | Everything | a study |
| **P1** truths and threshold placement | The true INB and its distance from the threshold in each cell | **The grid.** The design needs cells near and far from the threshold, and P1 places them | hours |
| **P2** coherent combinations | The enumeration of factor combinations that exist, and the alias structure if any cell is unfillable | The factorial | hours |
| **P3** noise floor | The reversal rate under the null control at $n_{sim}$, so every other rate is read against it | $n_{sim}$ | hours |
| **P4** unit cost | Per-replicate cost across the factorial including Bayesian arms; total computed not typed | The grid | hours |

## 11. Cost

$n_{sim} = 4000$ across a crossed factorial with Bayesian arms. Large. **The note's
instruction to reduce the factor set is what keeps it feasible**, and P2 is where
that reduction becomes concrete rather than intended.

---

## Relationship to the rest of the queue

- **DEC-01** owns the decision metric and is a hard prerequisite.
- **EST-06** owns the target-population reversal specifically, and its
  separating-hyperplane geometry explains when the estimand-changing route fires;
  if it runs first, this design cites it rather than re-measuring it.
- **COV-14** owns adjustment-set differences across comparators, a fifth
  structural choice not in this factorial.
- **CMU-02** owns prior-driven posteriors, which is the mechanism behind the
  prior factor.
- **DIS-11** and **IDN-08** own bridge validation, which is what would let the
  bridge choice be made on evidence rather than crossed as a factor.
