# DEC-01 design: carrying threshold-and-loss machinery into method comparison

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**Several designs in this queue depend on this one.** DEC-02 names it a hard
prerequisite; OUT-10, DIA-09 and others use decision loss as a scoring currency.
**It is also the cheapest of them**, at feasibility 4 with modest implementation cost.

The catalog is careful about what is and is not established. **ADEMP's Table 6 lists
bias, empirical standard error, relative precision, mean squared error, model standard
error, coverage and rejection percentage, and no decision measure.** But whether ITC
method comparisons *routinely* omit decision metrics is **contested**: the literature
auditor found no such evaluation, GPT-5.6 Sol holds the prevalence claim is not
established by the cited paper. **This design makes no prevalence claim.**

And one correction that must be carried: **expected value of information does not
belong on the list of estimator-quality metrics.** It measures the value of collecting
information and **can rise as uncertainty rises**, so an estimator that is worse would
score better. It is excluded.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the link from estimator error to decision error runs
through a threshold and a loss function, neither of which ADEMP requires, so a method
that wins on RMSE can lose on the recommendation; and the blocker is adoption inside
method-comparison simulation rather than missing machinery.

**Refuting sentence:** *estimator and decision rankings agree in practice, so the
existing measures are adequate proxies and adding a decision layer changes no
conclusion.*

**Morris et al.'s own Figure 1 already shows RMSE and coverage ranking methods
differently**, so the possibility of disagreement between measures is not in doubt.
**What is in doubt is whether the decision ranking differs from both**, and that is
this study.

## 2. The mechanism: decision error is not a monotone function of estimator error

Let $\Delta$ be the truth, $\hat\Delta$ the estimate and $\tau$ the decision
threshold. Wrong-decision probability is

$$P\big(\mathrm{sign}(\hat\Delta - \tau) \neq \mathrm{sign}(\Delta - \tau)\big),$$

which depends on $\hat\Delta$'s distribution **relative to $\tau$**, not on its
distance from $\Delta$. Three consequences:

1. **Bias in the direction away from the threshold reduces wrong-decision
   probability.** A method with larger RMSE whose bias pushes estimates away from
   $\tau$ can decide correctly more often than an unbiased one with the same variance.
   **So the rankings can genuinely invert**, and it is not a subtle effect: it is a
   sign, not a magnitude.
2. **A method's decision performance is not a property of the method alone.** It
   depends on $|\Delta - \tau|$, so **the same method ranks differently in a scenario
   where the truth is near the threshold and one where it is far.** Averaging over
   scenarios that differ in that distance produces a decision ranking that is an
   artifact of the grid's composition. **The design therefore reports decision
   performance indexed by threshold distance**, never pooled.
3. **Loss asymmetry decouples the two further.** With unequal costs of the two errors,
   the optimal action is not $\hat\Delta > \tau$ but a shifted rule, and a method's
   estimate enters through that shift. **So loss asymmetry is a factor rather than a
   fixed convention.**

**Consequence 2 is also DEC-02's falsifier**, and the two designs share it: if
reversal rates are essentially a function of threshold distance, then any ranking is
an artifact of where the truths sit.

## 3. Estimand, with its true value defined

**Primary.** Treatment-specific target-population **net benefit** under a declared
decision model, and the resulting recommendation, by quadrature at an order fixed by
P1.

**True values** from the generating model with the declared cost and utility model,
which is **fixed before any result** and stated in the abstract, since every
conclusion is conditional on it.

**Two derived estimands.** **Wrong-decision probability** against the true
recommendation, and **rank reversal** among treatments. Both indexed by threshold
distance per consequence 2.

## 4. Data-generating mechanism, and what it makes invisible

**Published benchmark scenarios are re-scored** rather than replaced, per the catalog:
the point is to compare the estimation ranking with the decision ranking on the same
scenarios the field already cites.

### Factors

| factor | levels | why |
|---|---|---|
| overlap | good, moderate, poor | the benchmark's axis |
| effect modification | 2 levels | the benchmark's axis |
| **distance from truth to threshold** | at the threshold; near; far | **consequence 2, and it must be a factor rather than an accident** |
| decision threshold | two willingness-to-pay values | conditionality made visible |
| loss asymmetry | symmetric; 2:1; 5:1 | consequence 3 |

### What the mechanism makes true, and therefore what the study cannot see

- **Every conclusion is conditional on the prespecified decision model and
  thresholds**, which the note requires and the abstract states. A different economic
  model could reorder methods.
- **Expected value of information is excluded**, per the catalog's correction, and the
  reason is stated rather than left implicit.
- **No prevalence claim is made** about how often decision metrics are omitted; the
  auditors disagreed and the design cites what exists.
- The decision rule is a single-threshold comparison. Multi-criteria decisions are out
  of scope.

## 5. Methods

MAIC, STC, ML-NMR and no adjustment, at standard specifications, so the comparison is
between measures rather than between a new method and an old one.

**The comparator that can win is the estimation ranking itself.** If it agrees with
the decision ranking across the grid, the refuting sentence holds and the field's
measures are adequate proxies. **Registered as such, and it is the outcome that would
save everyone effort.**

## 6. Performance measures, MCSE, and $n_{sim}$

**Both axes on the same scenarios**: bias, RMSE and coverage; and wrong-decision
probability, net-benefit error and rank reversal, all with MCSE.

**The primary summary is the rank correlation between the two rankings**, computed
within threshold-distance strata per consequence 2, with a bootstrap MCSE since the
methods' errors are dependent within a replicate.

**Common random numbers across methods**, so a decision reversal is a within-replicate
event and is estimable at reasonable cost.

$n_{sim} = 4000$ per cell, from resolving a wrong-decision probability of 0.05 to
0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Rank correlation between the RMSE ranking and the
wrong-decision-probability ranking, within the near-threshold stratum at poor overlap.

**Decision rule.**

- Rank correlation materially below 1 in any stratum: **confirmed**, and the
  deliverable is that method comparisons should report both axes under a declared
  decision model, which the ADEMP performance-measure element is broad enough to hold.
- Rank correlation at 1 throughout: **refuted**, and estimator measures are adequate
  proxies.
- **The threshold-distance stratification is reported in either branch**, because
  consequence 2 says a pooled decision ranking is an artifact and that is worth
  establishing regardless.

## 8. Three controls, each of which can fail

**Null control.** With the truth far from the threshold and good overlap, every method
must decide correctly in essentially every replicate, so the decision ranking is
degenerate and only the estimation ranking is informative. **That is the regime where
decision metrics add nothing**, and establishing it is what makes the near-threshold
result interpretable.

**Second null control.** With an unbiased estimator and symmetric loss, consequence 1's
mechanism is absent, so the decision ranking should follow the variance ranking
exactly. **A departure there means something other than bias direction is driving the
disagreement.**

**Positive control.** Two methods with equal RMSE and opposite bias directions
relative to the threshold: their wrong-decision probabilities must differ materially.
**This is constructed rather than hoped for**, and if it cannot be produced,
consequence 1 is not operative.

**Falsifier for the study's own headline.** The expected headline is that decision
metrics should be reported. Its falsifier is consequence 2 taken to its conclusion:
**if the decision ranking is entirely determined by threshold distance and not by the
method, then reporting it tells a reader about their scenario rather than about the
methods**, and the recommendation becomes a scenario-reporting requirement instead.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| A prevalence claim the auditors disputed | Not made | removed |
| EVPI included as an estimator-quality metric | Excluded, with the reason stated | removed |
| Decision performance pooled over threshold distance | Stratified; consequence 2 | removed |
| Decision model chosen to favor an outcome | Declared before any result and stated in the abstract | removed |
| Inventing decision metrics | Existing threshold-and-loss machinery carried in | removed |
| New scenarios instead of published ones | Benchmark scenarios re-scored | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and net benefit | True net benefit and recommendation per cell under the declared model | The definition of truth | hours |
| **P2** threshold placement | The truth-to-threshold distances that make each stratum non-degenerate | **The design's central factor**; a stratum where every method decides correctly carries no information | hours |
| **P3** benchmark re-scoring | That the published scenarios can be re-scored without refitting, or at what cost if not | Whether the comparison is against the literature or against a new grid | days |
| **P4** unit cost | Per-replicate cost at $n_{sim}=4000$; total computed not typed | The grid | hours |

## 11. Cost

Modest: weighting and regression fits plus a decision calculation, at 4000 replicates.
**This is the cheapest of the studies that several others depend on**, which is why it
should run early despite being a prerequisite rather than a headline.

---

## Relationship to the rest of the queue

- **DEC-02** names this a hard prerequisite and shares consequence 2's falsifier.
- **DEC-28**, **EST-06** and **EST-12** all turn on threshold crossings and would use
  this decision model.
- **OUT-10**, **DIA-09** and **DIA-14** use decision loss as a scoring currency and
  import it from here.
- **QBA-25** owns decision QBA, net benefit and tipping surfaces at full generality.
