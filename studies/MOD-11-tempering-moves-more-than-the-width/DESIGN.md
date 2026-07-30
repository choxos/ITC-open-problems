# MOD-11 design: a mixture over study populations, and a learning rate nobody can calibrate

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note requires narrowing to **one mixture model and one transported estimand**, and
this design does that. The catalog also corrects two premises, and both corrections
change what the design measures:

- **With few studies these models can be strongly prior-sensitive but are not
  necessarily almost entirely prior-driven.** Rich IPD or well-separated components
  can supply real information, so "prior-driven" is a measurement rather than an
  assumption.
- **Tempering does not widen intervals roughly uniformly**, because it can change
  posterior location, shrinkage and the relative information of parts of a nonlinear
  hierarchical model. Section 2 makes that precise.

**The Dirichlet-process machinery already works inside network meta-analysis**, with a
regularized horseshoe base measure and a baseline-risk extension. **What is missing is
transport**, so the task is extension rather than construction.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no worked implementation combines a mixture over study
populations with transport to a declared target and aggregate-data integration; no
calibrated learning-rate procedure exists for hierarchical evidence synthesis with
transport; and neither device identifies a cross-gap contrast the likelihood does not
touch.

**Refuting sentence:** *at the study counts an ITC supplies, the mixture's clustering
is determined by its prior, so the extension would add machinery whose output is a
restatement of its concentration parameter.*

**That is the catalog's own corrected premise turned into a testable statement**, and
measuring it is the study's first job.

## 2. The mechanism: tempering rescales the likelihood at every level at once

A tempered posterior is $\pi(\theta)\,p(y\mid\theta)^{\eta}$. In a **flat** model with
a Gaussian likelihood this inflates the variance by $1/\eta$ and leaves the mean
alone, which is where the "widens intervals uniformly" intuition comes from.

**In a hierarchical model it does not.** The likelihood enters at the observation
level, while the prior structure enters at the study and hyperparameter levels, so
raising the likelihood to $\eta$ **changes the balance between them differently at
each level**. Three consequences:

1. **Location moves.** Shrinkage toward the hierarchical mean is governed by the ratio
   of within-study to between-study information; tempering scales only the first, so
   estimates shrink further and **the posterior mean of a study-specific quantity
   moves**, not merely its spread.
2. **The mixture's clustering changes.** A Dirichlet-process partition is driven by
   how strongly the data distinguish components; tempering weakens that, so **fewer
   clusters are resolved and the apparent population heterogeneity falls.** Tempering
   applied for robustness therefore **reduces** the structure the mixture was added to
   find.
3. **The integration term is affected unequally.** Aggregate arms enter through an
   integrated likelihood and IPD arms through individual contributions, so tempering
   changes their relative weight, **shifting the analysis toward or away from the IPD
   studies depending on $\eta$.** That is a transport-relevant effect with no analogue
   in a flat model, and it is why no learning-rate calibration from elsewhere ports.

**Neither device identifies a cross-gap contrast the likelihood does not touch**, and
the design does not test them as if they might. **They are evaluated for heterogeneity
and non-normality**, per the entry's own recommendation.

## 3. Estimand, with its true value defined

**Primary, and one only per the note.** The target-population marginal treatment
contrast at a declared external target, by quadrature at an order fixed by P1.

**Prior-to-posterior movement is a reported quantity for every contrast**, per the
entry, so the nonparametric structure's contribution is visible rather than assumed.
**CMP-14's prior-free marginal precision is the instrument** and is imported.

**The number of resolved clusters is a second estimand** with a known truth, since the
design generates the latent population structure.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| latent study-population clusters | 1, 2, 3 | the structure the mixture should find |
| **separation between clusters** | small, large | the catalog's correction: well-separated components supply real information |
| number of studies | 6, 12 | where prior dependence bites |
| IPD availability | one study; half | the other source of real information |
| target overlap | good, poor | the transport layer |
| prior concentration | three values | prior sensitivity, measured rather than assumed |
| **learning rate $\eta$** | 1 (untempered), 0.75, 0.5 | consequence 1 to 3 |

### What the mechanism makes true, and therefore what the study cannot see

- **One mixture model**, the Dirichlet process with the published base measure, per
  the note. Finite mixtures are named and not run.
- **Tempering is reported as a sensitivity dimension rather than a fixed analytic
  default**, which is the entry's instruction and follows from consequence 1: a
  default $\eta$ would silently move locations.
- The latent structure is known. **In practice it is not**, and the study measures
  recovery rather than telling an analyst how many clusters to expect.
- **The mixture is not evaluated as a device to identify cross-gap contrasts**, per
  section 2's last paragraph.

## 5. Methods, including one that can win

| method | role |
|---|---|
| conventional hierarchical transport model | the baseline |
| **Dirichlet-process mixture over study populations with transport** | the extension |
| the same, tempered at each $\eta$ | consequences 1 to 3 |
| conventional model with a heavy-tailed heterogeneity prior | the cheap robustness alternative |

**The comparator that can win is the conventional model with a heavy-tailed
heterogeneity prior.** If it matches the mixture on coverage and predictive accuracy
across the grid, **the nonparametric structure buys nothing at ITC study counts** and
the refuting sentence holds. Registered as such, and it is far cheaper to adopt.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and predictive accuracy of the target contrast per method per cell,
with MCSE; **cluster recovery**; **prior-to-posterior movement** per contrast.

**The tempering decomposition, which is section 2 made measurable:** the change in
posterior **location**, in **shrinkage** and in **the IPD-versus-aggregate information
share** as $\eta$ falls, reported separately. **Reporting only interval width would
reproduce exactly the premise the catalog corrected.**

**The registered prior-dependence check:** prior-free marginal precision for the
mixture's key quantities, so "strongly prior-sensitive" and "almost entirely
prior-driven" are distinguished rather than conflated.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage and bias of the target contrast under the transported
mixture at 6 studies with small cluster separation, against the conventional model.

**Decision rule.**

- Mixture better with prior-free precision showing the likelihood is doing the work:
  **the extension is established**, and the deliverable is the transported mixture with
  its prior-sensitivity reporting.
- Mixture no better, and its prior-free precision near zero: **the refuting sentence
  holds at these study counts**, and the honest recommendation is the heavy-tailed
  prior.
- **The tempering decomposition is reported in either branch**, because it corrects a
  premise in the literature and does not depend on which model wins.

## 8. Three controls, each of which can fail

**Null control.** With one true cluster and large study counts, the mixture must
reduce to the conventional model and agree with it. **A difference there means the
nonparametric structure is manufacturing heterogeneity.**

**Second null control, and it is consequence 1's algebra.** In a **flat** version of
the model with a Gaussian likelihood, tempering must inflate the variance by $1/\eta$
and leave the location unchanged. **That is the case where the corrected premise is
true**, and confirming it licenses the claim that the hierarchical case differs.

**Positive control.** Three well-separated clusters with half the studies supplying
IPD: the mixture must recover the cluster count and beat the conventional model. **If
it cannot recover structure where the information is richest, the extension has no
regime.**

**Falsifier for the study's own headline.** The expected headline is that tempering
moves more than the width. Its falsifier is the magnitude: **if location and shrinkage
move by amounts negligible against the interval, the correction is technically right
and practically immaterial**, and the design must report that rather than presenting a
correct-but-inconsequential finding as a caution.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Assuming these models are almost entirely prior-driven | Measured with prior-free precision; the two conditions distinguished | removed |
| Reporting tempering as uniform widening | Location, shrinkage and information share reported separately | removed |
| Tempering as a fixed default | Reported as a sensitivity dimension, per the entry | removed |
| Treating the mixture as identifying cross-gap contrasts | Explicitly not evaluated that way | removed |
| Two mixture families at once | One, per the note | removed |
| Rebuilding the published DP machinery | Extended, not rebuilt | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target contrast's truth per cell | The definition of truth | hours |
| **P2** transport extension feasibility | Whether the published DP construction admits transport and aggregate-data integration at all | **Whether the extension exists**; CMP-14 registered two specifications the sampler rejected | days |
| **P3** tempering implementation | That $\eta$ is applied to the likelihood only and not to the prior, verified on the flat null control | **The second null control's validity**, and a common implementation error | hours |
| **P4** unit cost | Per-fit cost across three $\eta$ values; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

A Dirichlet-process mixture inside a transported hierarchical model with
aggregate-data integration, at three learning rates. Heavy; bounded by SFW-06.

---

## Relationship to the rest of the queue

- **CMP-16** and **HET-03** own shared heterogeneity structures, the parametric
  version of what this mixture relaxes.
- **CMU-02** owns prior-driven posteriors and **CMP-14** supplies the prior-free
  precision.
- **HET-10** owns small-study intervals, which is the regime this design's prior
  dependence lives in.
- **SFW-06** bounds the cost.
