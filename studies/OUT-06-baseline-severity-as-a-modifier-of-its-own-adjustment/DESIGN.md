# OUT-06 design: the combination is settled, the adjustment step is not

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog dismantles the source's framing and the note agrees the broad entry is
overstated.** Mixing endpoint and change-score results is **an estimand and
variance-handling choice rather than an unprincipled conversion**: the change-score
treatment contrast equals the endpoint contrast minus the baseline contrast, **and the
baseline-endpoint correlation is required for the variance of a change score, not for its
mean contrast.** Under randomization the baseline contrast is zero in expectation, so the
two can target the same follow-up effect, and meta-epidemiological work across **21
meta-analyses, 189 trials and 41,256 patients found combining them generally valid, with a
mean difference in standardized mean differences of −0.04 (95% CI −0.13 to 0.06).**

**So the combination question is answered.** What survives is the adjustment step, which the
note calls a clean, feasible experiment that could run early.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** **baseline severity is often itself an effect modifier and
regression to the mean acts differently in populations with different baseline
distributions**, so where baseline modifies the effect, change and endpoint analyses can
imply different effect-modification structures and **the representation interacts with the
adjustment instead of being a fixed offset.**

**Refuting sentence:** *the change-minus-endpoint identity holds after adjustment as well as
before, so the representation remains a fixed offset and the choice is immaterial for the
target-standardized contrast.*

## 2. The mechanism: the identity survives randomization and not reweighting

**Unadjusted.** $\Delta^{\text{change}} = \Delta^{\text{endpoint}} - \Delta^{\text{baseline}}$,
and randomization makes the last term zero in expectation. **The representations agree.**

**Adjusted.** Reweighting or standardizing to a target changes the baseline distribution.
Two things follow:

1. **If baseline is an effect modifier, the two representations carry different modifier
   structures.** The endpoint analysis models $E[Y_1] $ with baseline as a covariate; the
   change analysis models $E[Y_1 - Y_0]$, in which baseline enters both the outcome and the
   covariate. **So the interaction being estimated is not the same interaction**, and
   transporting it to a target with a different baseline distribution gives different
   answers. **The representations agree at the source and diverge at the target**, which is
   exactly what a fixed offset would not do.
2. **Regression to the mean is population-dependent.** The expected change from a given
   baseline depends on how extreme that baseline is **within its own population**, so the
   same conditional model implies different changes in populations with different baseline
   spreads. **Reweighting changes the spread**, so the regression-to-the-mean component of a
   change score moves with the adjustment. **This is a mechanism with no analogue in the
   endpoint representation**, and it is what makes the choice interact with the target
   rather than with the source.

**Both consequences vanish when baseline is not a modifier**, which is the null control and
which is also why the meta-epidemiological result holds for unadjusted synthesis: **there is
no adjustment to interact with.**

**The remaining items in the entry are declared optional estimands, not defects.**
Target-standardized trajectories and model-derived responder probabilities have no
established population-adjusted formulation; **and dichotomizing a reported mean remains
invalid without the outcome distribution**, which is a statement about what published data
supports rather than about method choice.

## 3. Estimand, with its true value defined

**Primary.** The target-population **follow-up mean** contrast, by quadrature over the target
covariate law including baseline, at an order fixed by P1.

**Defining the estimand on follow-up rather than on change is deliberate**: it is the
quantity both representations claim to target, so **it is the ground on which they can
disagree.** A design defining the estimand as "the change contrast" would make the change
analysis correct by construction.

**Responder probability at a declared threshold is the secondary**, derived from
individual-level indicators where IPD allow it, **and from a latent model only where they do
not**, per the entry. **Which route was used is reported**, since they are not the same
estimand.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **baseline-by-treatment interaction** | absent; moderate; strong | **consequence 1's switch, and the null control** |
| baseline-target distribution shift | none, moderate, large | what reweighting changes |
| baseline prognostic strength | moderate, strong | the size of the regression-to-the-mean term |
| baseline-follow-up correlation | 0.4, 0.8 | consequence 2's magnitude |
| overlap | good, poor | the adjustment layer |

**Baseline-by-treatment interaction crossed with baseline shift is the design**, because
section 2 says neither alone produces the divergence.

### What the mechanism makes true, and therefore what the study cannot see

- **The combination question is not re-litigated.** The meta-epidemiological result stands
  and the design does not test it; **it tests what happens after an adjustment step that
  study did not include.**
- **Joint repeated-measures models need compatible time definitions and within-trial
  covariances that aggregate publications do not report**, so the trajectory arm is carried
  only where IPD supply them and its scope is stated.
- One continuous outcome; OUT-05 owns the residual-structure questions and is held at a
  common well-behaved specification here.
- **A prespecified decision-relevant timepoint is kept alongside any trajectory**, per the
  entry, so a trajectory result never replaces the declared estimand.

## 5. Methods, including one that can win

| method | role |
|---|---|
| endpoint analysis with baseline as a covariate | one representation |
| change-score analysis | the other |
| **joint baseline-and-follow-up model** | the entry's proposal, keeping adjustment and estimand consistent |
| **target-standardized responder probability from individual indicators** | the declared optional estimand, done the way IPD permit |

**The comparator that can win is the change-score analysis.** If it matches the endpoint
analysis on the target-standardized follow-up contrast across the grid, **the refuting
sentence holds**, the representation is a fixed offset after adjustment too, and **the
prespecification guidance is the whole recommendation.** Registered as such, and it is what
the meta-epidemiological result would predict if the adjustment step changed nothing.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target-standardized follow-up contrast under each representation,
with MCSE, **and the difference between representations reported directly**, since section 2
predicts it is zero without a baseline interaction and nonzero with one.

**The registered mechanism check:** the representation difference regressed on the product
of the baseline-by-treatment interaction and the baseline shift. **Section 2 predicts a
product structure with no main effects**, which is the same shape MOD-16 predicts for
arm-separate matching and is falsifiable in the same way.

**Responder-probability agreement** between the individual-indicator and latent-model
routes, since the entry warns they are different estimands.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The difference between change-score and endpoint estimates of the
target-standardized follow-up contrast, at strong baseline-by-treatment interaction with
large baseline shift.

**Decision rule.**

- Difference material and following the product structure: **confirmed**, and the deliverable
  is that the representation must be prespecified **and** that where baseline is a plausible
  modifier the two should be modeled jointly rather than chosen between.
- Difference negligible: **refuted**, and prespecification alone suffices, matching the
  existing guidance.
- Difference present without the product structure: consequence 2's regression-to-the-mean
  route is acting alone, **which is a distinct finding and is reported as such** rather than
  folded into consequence 1.

## 8. Three controls, each of which can fail

**Null control.** With no baseline-by-treatment interaction, section 2 makes both
consequences vanish, so the two representations must agree to Monte Carlo error **at every
baseline shift.** **That is the meta-epidemiological result reproduced under adjustment**,
and it is what licenses attributing any divergence to the interaction.

**Second null control.** With no baseline shift between source and target, there is no
reweighting of the baseline distribution, so **the representations must agree even with a
strong interaction.** That separates consequence 1's two ingredients and shows the product
structure is real rather than a correlate of interaction strength.

**Positive control.** Strong interaction with large shift and high baseline-follow-up
correlation: the difference must exceed three MCSEs. **If it does not, the divergence is
unreachable and prespecification is the whole answer.**

**Falsifier for the study's own headline.** The expected headline is that the representation
interacts with the adjustment. Its falsifier is the joint model: **if modeling baseline and
follow-up jointly removes the divergence entirely, then neither representation is right and
the recommendation is the joint model rather than a prespecification rule**, which is a
different and more actionable conclusion.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Re-litigating the combination question | Not tested; the meta-epidemiological result is the null control | removed |
| Estimand defined as the change contrast | Defined on follow-up, the quantity both claim to target | removed |
| Two responder routes treated as one estimand | Reported separately with the route named | removed |
| A trajectory replacing the declared estimand | A prespecified timepoint kept alongside | removed |
| Dichotomizing a reported mean | Not done; stated as invalid without the outcome distribution | removed |
| Residual-structure effects confounded | Held at a common specification; OUT-05 named | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target-standardized follow-up truth per cell | The definition of truth | hours |
| **P2** analytic divergence | The product term of section 2 per cell, before any fitting | **The grid**, and the primary outcome's prediction; cells below Monte Carlo resolution are dropped | hours |
| **P3** joint-model specification | A baseline-and-follow-up model whose adjustment and estimand stay consistent, written before fitting | Whether the falsifier's arm exists | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | minutes |

## 11. Cost

Small: linear model fits with weighting at 2000 replicates. **One of the cheapest studies in
the queue**, which with its clean product-structure prediction is why the note calls it a
candidate to run early.

---

## Relationship to the rest of the queue

- **OUT-05** owns residual structure and responder probabilities' dependence on it; the two
  share the responder machinery and should be read together.
- **COV-03** owns prognostic covariates' role, and baseline severity is the archetype.
- **MOD-16** predicts the same product structure for a different mechanism, so a slope of one
  in both would be evidence that this shape recurs rather than being fitted.
- **DIA-09** owns outcome families and would carry the trajectory estimand at full
  generality.
