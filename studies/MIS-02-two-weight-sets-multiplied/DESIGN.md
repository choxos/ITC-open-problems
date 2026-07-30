# MIS-02 design: characterizing an estimator that is one paper old

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The estimator exists**, so the work is characterization rather than construction,
and the catalog says so. Yan et al. built TADA: time-varying inverse-probability-of-
censoring weights multiplied by method-of-moments participation weights, with
nonparametric bootstrap variance and an ADEMP simulation. **They also list their own
future work**, and this design takes that list as its scope rather than inventing
one: sandwich variance under heavy censoring, non-proportional-hazards censoring
models, and doubly robust protection against partial misspecification.

Overlap is not examined anywhere in the source paper. **That is the gap the design
leads with**, because section 2 says it is where the product structure bites.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** TADA's behavior under censoring-model misspecification,
heavy censoring and non-proportional hazards is unmapped; sampling error in the
published target moments is not propagated because the method of moments conditions
on them; and censoring driven by unmeasured event prognosis is unidentified.

**Refuting sentence:** *the estimator's operating characteristics under these
departures are close enough to its published behavior that the future-work list is
a formality.*

## 2. The mechanism: the product's effective sample size is worse than either factor's

The final weight is $w_i = w_i^{\text{cens}}(t) \cdot w_i^{\text{part}}$. The
variance of a weighted estimator is governed by the second moment of the weights,
so

$$\frac{n}{\mathrm{ESS}} \;=\; \frac{\mathbb{E}[w^2]}{\mathbb{E}[w]^2}, \qquad w = w^{\text{cens}} w^{\text{part}} .$$

Three consequences:

1. **If the two weight sets are positively correlated, the product's second moment
   exceeds the product of the two second moments.** Censoring often depends on
   prognosis and participation on covariates that predict prognosis, so **positive
   correlation is the expected case** and the effective sample size collapses
   faster than either component would suggest. **That is why overlap and censoring
   must be crossed rather than examined separately**, and neither the source paper
   nor any prior study does it.
2. **Heavy censoring makes $w^{\text{cens}}$ heavy-tailed in time.** Late
   observations carry inverse survival probabilities that grow without bound as the
   censoring survival function falls, so the product is most extreme exactly where
   the survival estimand is least determined. **This is the same tail concentration
   CMP-17 finds for reconstruction error**, arriving by a different route into the
   same place.
3. **The sandwich the authors propose must account for both weight-estimation
   steps.** A sandwich treating either as fixed omits a term, and SFW-10's section
   2 shows the omitted term's sign is not fixed. **So "sandwich versus bootstrap"
   is not one comparison but three**: sandwich with both fixed, with one estimated,
   and stacked over both.

**Censoring by unmeasured prognosis is not a modeling problem.** It is not
identified from observed data at all, so the design supplies an explicit sensitivity
parameter rather than a better model, which is what the catalog asks for.

## 3. Estimand, with its true value defined

**Primary.** The transported marginal log hazard ratio, and the transported RMST
difference, since the entry's estimand is a hazard ratio but DIA-09 and OUT-11
establish that RMST is what survives non-proportionality.

**True value** by exact integration over the target covariate law under the
generating survival and censoring processes.

**Under a non-proportional censoring hazard the transported log hazard ratio is a
least-false parameter**, defined by root-finding the limiting score equation
following OUT-11, because a proportional-hazards summary of a non-proportional
process does not estimate any parameter of the mechanism.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| censoring fraction | 10%, 30%, 50%, 70% | the entry's own range; 70% is where consequence 2 bites |
| **covariate overlap** | good, moderate, poor | **unexamined in the source paper**, and consequence 1's other factor |
| censoring hazard | proportional; time-varying | the authors' named future work |
| censoring-model misspecification | correct; omitted covariate; wrong functional form | the robustness question |
| participation-model misspecification | correct; misspecified | the other half of a doubly robust claim |
| correlation between the two weight sets | low; high | **consequence 1, manipulated directly** |
| censoring by unmeasured prognosis | absent; present at declared magnitudes | the unidentified case |

### What the mechanism makes true, and therefore what the study cannot see

- **Target moments are exact except in one arm.** EST-07 and MIS-03 own their
  sampling error; the entry notes TADA conditions on them, and one arm here
  measures what that costs rather than rebuilding the propagation.
- Doubly robust extension is named by the entry as future work and by the catalog's
  note as a separate project. **This design measures where partial misspecification
  hurts, which is what would justify building one**, and does not build it.
- One unanchored survival comparison. Networks are out of scope.
- The censoring mechanism is usually unverifiable from published data and **the
  covariates driving censoring are often not the ones reported for the target**, so
  the misspecification arm is realistic rather than adversarial.

## 5. Methods, including one that can win

| method | role |
|---|---|
| TADA with bootstrap variance | the published estimator |
| TADA with sandwich, weights fixed | the naive sandwich |
| TADA with stacked M-estimation over both weight steps | the authors' named next step, done properly per consequence 3 |
| participation weights only, no IPCW | so the censoring layer's contribution is visible |
| TADA with a sensitivity parameter for unmeasured-prognosis censoring | the unidentified case, bounded rather than modeled |

**The comparator that can win is the bootstrap.** The authors chose it and if it is
well calibrated across the grid, the sandwich work is unnecessary and the future-work
list shortens. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, empirical SD, mean estimated SE and their ratio, and 95% coverage, per method
per cell, with MCSE. **The SE ratio is primary** because coverage conflates variance
error with bias.

**Effective sample size of the product**, reported beside the ESS of each factor,
so consequence 1 is visible rather than inferred.

**Convergence and weight-degeneracy rates**, since at 70% censoring with poor
overlap the product may be numerically degenerate, and **a method that fails to
return is a result** rather than a missing cell.

$n_{sim} = 2000$ per cell; the bootstrap arm multiplies by its resample count,
priced in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage and SE ratio of TADA with bootstrap variance at 70%
censoring with poor overlap and highly correlated weight sets.

**Decision rule.**

- Coverage in 93.5% to 96.5% with SE ratio near one: the estimator is characterized
  as robust in that corner and the future-work list can be reprioritized.
- Coverage failing while stacked M-estimation holds: **the variance work is
  established** and the deliverable is the stacked estimator.
- Both failing: the failure is the weight product's degeneracy rather than the
  variance estimator, and **the recommendation is a feasibility screen before
  fitting**, which is OVL-02's instrument applied here.

## 8. Three controls, each of which can fail

**Null control.** With no censoring, TADA must reduce to ordinary participation
weighting and agree with it numerically. **Exact, and it validates the product
construction before any censoring result is interpreted.**

**Second null control.** With censoring independent of covariates, IPCW weights are
constant and the product reduces to participation weights alone. **Consequence 1's
correlation term is then zero**, so this cell separates "censoring adjustment" from
"censoring adjustment interacting with participation".

**Positive control.** 70% censoring, poor overlap, high correlation: the product's
effective sample size must fall materially below either factor's. **If it does not,
consequence 1 is wrong and the design's leading claim fails cheaply.**

**Falsifier for the study's own headline.** The expected headline is that the
product structure is the problem. Its falsifier is the misspecification arm: **if
correct models with a degenerate product still give nominal coverage while a
misspecified model with a benign product does not, the binding issue is
specification rather than geometry**, and the recommendation changes from a
feasibility screen to a doubly robust extension.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Rebuilding an estimator that exists | Characterization only; the authors' future-work list is the scope | removed |
| Overlap unexamined, as in the source | Crossed with censoring, which is the design's lead | removed |
| "Sandwich versus bootstrap" treated as one comparison | Three sandwich variants, per consequence 3 | removed |
| Non-proportional censoring summarized by a parameter that does not exist | Least-false parameter defined by root-finding, following OUT-11 | removed |
| Unmeasured-prognosis censoring modeled | Sensitivity parameter, per the catalog | removed |
| Failed fits dropped | Degeneracy rate reported as a result | removed |
| Doubly robust extension | Named, not built, per the note | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and least-false parameters | Transported RMST and the least-false log hazard ratio per cell | The definition of truth under time-varying censoring | days |
| **P2** reproduction | That the implemented TADA reproduces Yan et al.'s reported ADEMP results on their own conditions | Whether the base arm is a comparator or a confound | days |
| **P3** weight-correlation construction | Covariate and censoring structures achieving low and high correlation between weight sets at matched marginal weights | **Consequence 1's manipulation**; without it the design's lead is confounded with censoring severity | days |
| **P4** unit cost | Per-replicate cost including the bootstrap; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Bootstrap resamples times $n_{sim}$ times cells, with survival fits inside. The
resample count is the multiplier and it is measured.

---

## Relationship to the rest of the queue

- **OUT-11** supplies the least-false-parameter treatment for a transported hazard
  ratio under non-proportionality.
- **OVL-02** supplies the feasibility screen the third decision branch would use.
- **SFW-10** owns stacked variance over outcome and weight equations, the same
  machinery one layer over.
- **OUT-07** owns informative censoring as a subject; **EST-07** and **MIS-03** own
  target-moment error.
- **DIA-09** and **QBA-24** own the survival estimands beyond the hazard ratio.
