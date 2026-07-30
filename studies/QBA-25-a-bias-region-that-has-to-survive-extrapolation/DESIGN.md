# QBA-25 design: the decision depends mostly on a period with no data

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note orders this after a narrower estimand-scale QBA, **because otherwise the
economic model merely inherits an unsettled bias specification.** QBA-24 is that
narrower study and is named as the prerequisite.

The catalog also corrects the entry twice. **A $p = 0.05$ tipping boundary is a valid
answer to an inferential question and merely insufficient for the decision**, so it is not
wrong, only mismatched. And **the claim that nothing links the ITC sensitivity region to
the economic model is wrong**: published guidance already recommends incorporating
sensitivity results into economic scenario analyses and judging robustness by whether all
scenarios yield ICERs below the threshold. **What does not exist is a link to the model's
probabilistic sensitivity analysis through a shared parameter space, or any framework
indexing the survival extrapolation model jointly with the bias parameters.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the map from a bias parameter to a decision runs through
survival extrapolation, costs and QALYs and is strongly nonlinear, so **a modest change in
a hazard ratio can move the decision quantity far more than it moves the effect
estimate**; and bias parameters are naturally specified for the observed follow-up while
**the decision depends mostly on a period in which no data exist.**

**Refuting sentence:** *propagating a corrected point estimate with its interval into the
economic model reproduces the decision surface adequately, so the shared parameter space
is an elegance rather than a requirement.*

## 2. The mechanism: nonlinearity, and a bias defined where the decision is not

**Nonlinearity.** Incremental net benefit is $\lambda\,\Delta\mathrm{QALY} -
\Delta\mathrm{Cost}$, and $\Delta\mathrm{QALY}$ is an integral of a survival difference
over a lifetime horizon. A hazard ratio shift changes the extrapolated tail
multiplicatively, so **the QALY difference moves by more than the effect estimate does**
whenever the tail carries substantial mass. **So propagating a point estimate and an
interval cannot reproduce the surface**, because the map is not locally linear over the
plausible bias region.

**The extrapolation coupling, which is the sharper point.** A bias parameter is specified
on the observed follow-up. The decision depends on the extrapolated period. **Those are
linked by the extrapolation model, and the choice of that model is itself uncertain.**
Two consequences:

1. **A bias parameter and an extrapolation family are not independent inputs.** A hazard
   ratio shifted within the observed window implies different lifetime survival under a
   Weibull than under a mixture-cure or a spline model, **so the bias region's image in
   net-benefit space depends on which family is used** and exploring them separately
   displays neither interaction. **Indexing the extrapolation model jointly with the bias
   parameters is the missing framework** and it is this design's deliverable.
2. **Where the two are explored separately, the reported robustness is the union of two
   marginal explorations**, which can miss a combination that reverses the decision while
   neither margin does. **That is QBA-22's cross-versus-region argument in the decision
   layer**, and the same summary problem follows: with several bias parameters the tipping
   point is a surface with no accepted summary.

**And judging whether the tipping region is attainable still requires the elicitation the
method was often adopted to avoid**, which the entry says and this design does not paper
over: the tipping surface is reported, and whether it is reachable is an elicitation
question DIA-14 and QBA-02 own.

## 3. Estimand, with its true value defined

**Primary.** Incremental net benefit at a declared willingness-to-pay threshold, over a
lifetime horizon, with the true value computed from the generating survival and cost
model by exact integration.

**Decision-reversal probability and expected regret** are the derived estimands, and
**coverage of the true net benefit** is the third.

**The bias region's image in net-benefit space is the deliverable**, reported as a surface
rather than a point, per the entry.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| residual bias magnitude | 0, moderate, large | the sensitivity axis |
| bias dependence across parameters | independent; correlated | the region's shape |
| **survival extrapolation family** | Weibull; spline; mixture-cure | **consequence 1's coupling** |
| willingness-to-pay threshold | two values | conditionality made visible |
| tail mass beyond observed follow-up | small; large | where nonlinearity bites |

**Extrapolation family crossed with bias magnitude is the design**, because consequence 1
says their interaction is what nobody displays.

### What the mechanism makes true, and therefore what the study cannot see

- **The economic model is declared and fixed**, and every conclusion is conditional on it.
  A different cost or utility structure could reorder everything.
- **Economic models are usually built by a different team in different software**, so the
  shared-parameter-space proposal is an organizational change as much as a statistical
  one; the design measures its value and cannot deliver the interfaces.
- The bias specification is inherited from QBA-24 rather than invented, per the note. **If
  QBA-24 has not run, this study has an unsettled input and should not start.**
- **The tipping surface's summary problem is QBA-22's**, and its candidate summaries are
  imported rather than re-derived.

## 5. Methods, including one that can win

| method | role |
|---|---|
| point estimate plus interval into the model | current practice |
| **scenario analysis over the bias grid** | what published guidance already recommends |
| **shared parameter space: PSA nested or conditioned over bias scenarios with shared draws** | the proposal |
| **jointly indexed extrapolation and bias** | consequence 1's framework |
| tipping surface with QBA-22's summaries | the reporting object |

**The comparator that can win is scenario analysis.** It is already recommended, it is
cheap, and **if its decision-reversal proportions match the shared-parameter-space
version, the elaboration is unnecessary.** Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Decision-reversal probability; expected regret under a declared loss; coverage of the true
net benefit; **and the discrepancy between each cheaper method's decision surface and the
shared-parameter-space reference**, which is what decides the refuting sentence.

**The nonlinearity measure:** the ratio of the net-benefit region's width to what a
locally linear propagation of the effect interval would give. **Consequence 1 predicts it
exceeds one and grows with tail mass**, and a ratio near one would refute the mechanism.

**The extrapolation-interaction measure:** the change in the decision-reversal proportion
when the extrapolation family is varied at fixed bias, and the reverse. **Consequence 1
predicts these do not add.**

$n_{sim} = 1000$ per cell; the economic model is evaluated at every bias-grid point, which
is the multiplier and is priced in P3.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Decision-reversal probability under point-estimate propagation
against the shared-parameter-space reference, at large tail mass with a spline
extrapolation.

**Decision rule.**

- Point propagation materially understating reversal: **confirmed**, and the deliverable
  is the shared parameter space plus the joint indexing.
- Scenario analysis matching the reference: **refuted for the elaboration**, and existing
  guidance suffices, which is a useful and cheap conclusion.
- **The extrapolation interaction is reported in either branch**, because consequence 1's
  coupling is a separate claim and no current practice displays it.

## 8. Three controls, each of which can fail

**Null control.** At zero bias, every method must give the same decision and the same net
benefit. **A method that moves the decision at zero bias is manufacturing one.**

**Second null control.** With a horizon equal to the observed follow-up, there is no
extrapolation, so consequence 1's coupling vanishes and the extrapolation family must not
matter. **That isolates the extrapolation mechanism from the nonlinearity mechanism**,
which section 2 treats as separate.

**Positive control.** Large tail mass with a spline extrapolation and moderate bias: the
net-benefit region must be materially wider than a linear propagation of the effect
interval. **If it is not, the nonlinearity is not reachable.**

**Falsifier for the study's own headline.** The expected headline is that the bias region
must be carried through the extrapolation. Its falsifier is the elicitation problem:
**if the tipping surface's attainability cannot be judged, then a wider and more accurate
surface tells a committee no more than a narrower and wrong one.** The design reports the
surface and states that its attainability is an elicitation question rather than implying
the surface settles it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming no link to the economic model exists | Corrected in the header; scenario analysis is the registered winner | removed |
| Treating a $p=0.05$ tipping boundary as wrong | Stated as valid inferentially and insufficient for the decision | removed |
| An unsettled bias specification inherited | QBA-24 named as a prerequisite | disclosed |
| Extrapolation and bias explored separately | Crossed; their interaction is a reported measure | removed |
| A tipping surface presented as settling attainability | Stated as an elicitation question | removed |
| The economic model's conditionality | Declared and in the abstract | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P0** QBA-24 | The estimand-scale bias specification | Everything | a study |
| **P1** truth and horizon | True net benefit per cell and the tail mass beyond follow-up | The definition of truth | hours |
| **P2** nonlinearity check | The analytic ratio of net-benefit width to linearly propagated width per cell | **The primary outcome's prediction**, computable before any simulation | hours |
| **P3** model evaluation cost | Cost of evaluating the economic model at every bias-grid point, and whether a surrogate reproduces it | **The budget**, and whether the shared parameter space is affordable at all | days |
| **P4** unit cost | Total, computed not typed | The grid | hours |

## 11. Cost

The economic model evaluated at every point of the bias grid times $n_{sim}$. **P3's
surrogate question decides whether that is affordable**, and a negative answer there is
itself a finding about the proposal's practicality.

---

## Relationship to the rest of the queue

- **QBA-24** is the prerequisite and supplies the estimand-scale bias specification.
- **QBA-22** owns the joint region and its summary problem, imported here.
- **DEC-01** supplies the decision metric; **DEC-02** owns which structural choice flips a
  decision.
- **DIA-14** and **QBA-02** own the elicitation this design's attainability question needs.
