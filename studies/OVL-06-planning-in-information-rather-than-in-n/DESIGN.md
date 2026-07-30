# OVL-06 design: a planning calculation that can be reproduced and audited

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**Nothing prevents a design-specific information calculation.** The catalog is
explicit: scenario-based planning that posits source and target distributions,
derives the anticipated weights and uses influence-function or simulation
calculations is **already feasible**. What is missing is a standardized procedure,
software, and agreed reporting of what was assumed.

So this is not a study about whether planning is possible. **It is a study about
whether a planning calculation, built and stated, actually predicts what a PAIC
achieves.** The note narrows it to one outcome type, and this design takes binary
with a survival arm carried only where P2 says it is affordable.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** nominal sample size does not determine PAIC precision;
information depends on anticipated overlap, the balancing constraints, the outcome
distribution, treatment allocation and the estimator's influence function; the Kish
ESS understates the true effective sample size when weights are estimated and
correlated with the outcome; and no accepted procedure, software or reporting
convention exists.

**Refuting sentence:** *a calculation in nominal $n$ with a crude overlap
adjustment predicts achieved precision well enough for planning, so the missing
procedure would add rigor without adding accuracy.*

## 2. The mechanism: three candidate planning quantities and only one is the estimator's

**Nominal $n$** ignores weighting entirely. **Kish ESS** is a weight functional and
carries two documented problems: it ignores arm allocation, outcome variance and
nuisance estimation, and Phillippo et al. record it is *likely an underestimate* of
the true ESS because the weights are estimated and correlated with the outcome. **A
planning calculation stated in Kish ESS therefore inherits a biased quantity, and
the direction of the bias is toward pessimism**, which is a peculiar thing to build
a sample-size rule on.

**The influence-function variance is the estimator's own information.** For a
weighted estimator with influence function $\psi$,

$$\mathrm{Var}(\hat\Delta) \;=\; \frac{1}{n}\mathbb{E}\big[\psi(O)^2\big],$$

and $\psi$ carries the weights, the outcome variance, the allocation and the
nuisance-estimation correction together. **It can be evaluated at posited source and
target distributions before any data exist**, which is precisely the calculation the
catalog says is feasible and unstandardized.

Three consequences:

1. **The three quantities can be ranked in advance by how much of the estimator they
   contain**, and the study's job is to measure how much that ranking matters for
   predicting achieved precision.
2. **For survival outcomes the unit is events, and even total events plus a
   censoring fraction are insufficient** without timing, allocation, risk-set
   composition and the censoring mechanism. **So the survival planning quantity is
   weighted risk-set and event information**, not a count, and a single grid cannot
   serve both outcome types. That is why the note's narrowing is structural.
3. **Unanchored designs carry a strictly stronger identification burden**, and
   omitted prognostic structure creates **structural bias that a larger sample does
   not cure.** So an unanchored planning calculation must report a bias floor
   alongside a precision target, and **a power calculation that ignores it promises
   something no $n$ delivers.** That is the design's sharpest deliverable and it is
   a statement about what planning can and cannot do.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio, and in the survival arm
the RMST difference, by quadrature at an order fixed by P1.

**The planning quantities are the derived estimands**: predicted power and predicted
interval width from each of the three calculations, against **achieved** power and
width in the simulation. **Prediction error, not achieved power, is the outcome**,
because the question is whether a planning calculation works.

## 4. Data-generating mechanism, and what it makes invisible

**The existing templates are extended, not duplicated**, per the catalog: the
162-scenario anchored grid supplies overlap, imbalance and sample-size levels, and
the positivity-severity design supplies the overlap indexing.

### Factors

| factor | levels | why |
|---|---|---|
| nominal sample size | 3 levels from the benchmark grid | the quantity being tested against |
| overlap | indexed on severity, following the positivity template | the axis the field already uses |
| modifier dimension | 2, 5, 8 | more balancing constraints, less information |
| treatment allocation | 1:1, 2:1 | ignored by Kish ESS entirely |
| outcome prevalence | 0.1, 0.3 | outcome variance, also ignored by Kish ESS |
| design | anchored; unanchored with an omitted prognostic variable | **consequence 3, the bias floor** |

### What the mechanism makes true, and therefore what the study cannot see

- **The planner knows the posited source and target distributions.** A real planner
  guesses them, and **the calculation's sensitivity to that guess is a separate
  question** carried as one factor level rather than solved.
- Universal guidance is out of scope, per the note. **The deliverable is a procedure
  and its validation on one outcome type**, not a threshold.
- No effective-sample-size threshold is proposed. **The catalog says none is
  defensible and this design does not manufacture one**; ESS bands are used as
  stress-test strata, as the source recommends.
- The survival arm is carried only if P2 shows it is affordable, and its absence
  would be stated rather than quietly dropped.

## 5. Methods, including one that can win

| planning calculation | role |
|---|---|
| nominal $n$ with a crude overlap adjustment | the refuting sentence's candidate |
| Kish ESS-based | current informal practice, inheriting a documented bias |
| **influence-function based** | the estimator's own information |
| **simulation-based** | the reference, and the most expensive |
| **as software** | the procedure packaged so a calculation can be reproduced and audited |

**The comparator that can win is the nominal-$n$ calculation.** If its prediction
error is comparable to the influence-function calculation's, the refuting sentence
holds and the field loses nothing by planning crudely. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**Prediction error** of planned against achieved power and against achieved interval
width, per calculation per cell, with MCSE; **calibration**, whether the predicted
power is systematically optimistic or pessimistic; **the Kish ESS bias**, measured
directly as the ratio of Kish ESS to the effective sample size implied by the
achieved variance, which tests Phillippo et al.'s recorded caution.

**In the unanchored arm, the bias floor**: achieved coverage as $n$ grows, which
should approach zero rather than nominal if omitted prognostic structure creates
structural bias. **That curve is consequence 3 made visible** and is what a planner
needs to see.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Prediction error of the influence-function calculation against
the nominal-$n$ and Kish-ESS calculations, for achieved power, at moderate overlap
with five modifiers and unequal allocation.

**Decision rule.**

- Influence-function prediction materially more accurate: **the procedure is
  established** and the deliverable is the software plus a reporting requirement for
  the assumed source and target distributions.
- All three comparable: **refuted**, and planning in nominal $n$ with an overlap
  adjustment is adequate, which would be a useful simplification.
- **The Kish ESS bias direction is reported in either branch**, because a quantity
  documented as an underestimate and used for planning is worth quantifying whatever
  the verdict.

## 8. Three controls, each of which can fail

**Null control.** At complete overlap with one modifier and 1:1 allocation, weights
are near-constant, so all three calculations must coincide and predict achieved
power accurately. **A disagreement there is an implementation fault**, since there is
nothing for them to disagree about.

**Second null control.** In the anchored arm with no effect modification, the
unanchored bias floor must be absent and achieved coverage must approach nominal as
$n$ grows. **That is the contrast that makes consequence 3's floor attributable to
omitted prognostic structure rather than to sample size.**

**Positive control.** Poor overlap with eight modifiers and 2:1 allocation: the
nominal-$n$ calculation must be materially optimistic. If it is not, nominal $n$ is
adequate everywhere reachable and the study says so.

**Falsifier for the study's own headline.** The expected headline is that
information-based planning is worth standardizing. Its falsifier is the
posited-distribution sensitivity: **if the influence-function calculation's accuracy
collapses when the posited target distribution is modestly wrong, then its apparent
superiority requires knowledge a planner does not have**, and the honest
recommendation is the crude calculation with a stated margin.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Proposing an ESS threshold | None proposed; ESS bands used as stress strata, per the source | removed |
| Duplicating existing simulation templates | Extended; their grids reused | removed |
| Planning stated in a quantity documented as biased | The bias measured directly | removed |
| A precision target promised where structural bias exists | Bias floor reported in the unanchored arm | removed |
| The calculation given knowledge a planner lacks | Sensitivity to the posited distribution is the falsifier | removed |
| Universal guidance | Out of scope per the note | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Target truths per cell | The definition of truth | hours |
| **P2** survival affordability | Whether the weighted risk-set information calculation and its simulation reference fit the budget | **Whether the survival arm exists**, which the note's narrowing anticipates | days |
| **P3** influence-function derivation | The influence function for each estimator, verified against the empirical sandwich on simulated data | **The central arm.** A misderived influence function would be reported as a planning failure | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | hours |

## 11. Cost

Weighting fits at 2000 replicates; modest, and the software deliverable is
engineering rather than compute.

---

## Relationship to the rest of the queue

- **OVL-01** and **OVL-02** own the overlap diagnostics and the feasibility test a
  planning calculation would sit beside.
- **DIA-03** proved the Kish identity that makes ESS a pure weight functional.
- **OUT-02** proposes the effective **event** sample size, which is the survival
  planning quantity consequence 2 needs.
- **SFW-10** owns the variance estimator whose calibration a planning calculation
  presupposes.
