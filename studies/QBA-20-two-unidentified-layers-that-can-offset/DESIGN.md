# QBA-20 design: two unidentified layers, and a one-at-a-time curve cannot see the cancellation

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is an ordering instruction: this should follow work on
target-law uncertainty and multivariate sensitivity dependence. **Those are
CMP-15/MOD-01 and QBA-22 respectively**, and this design depends on both, which
section 10 makes a hard prerequisite rather than a preference.

The entry also carries a correction that shapes the scope: **population or
selection bias is not necessarily nonidentified** when adequate covariates and
transport assumptions are available. So the joint problem arises specifically in
the disconnected component case with no cross-gap evidence, and the design is
restricted there rather than claiming both layers are always unidentified.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** in a disconnected component PAIC with no cross-gap
evidence, violations of population transportability and of component invariance are
both unidentified and can offset each other, so an analysis varying only one may
report spurious robustness; and the joint model requires a joint target
distribution of measured and omitted covariates that published aggregate data do
not supply.

**Refuting sentence:** *the two layers act on the estimand in ways that do not
cancel at plausible magnitudes, so one-at-a-time curves bound the joint effect and
the joint model's extra assumptions buy nothing.*

## 2. The mechanism: two layers, one estimand, and the sign is free

Write the target contrast under perturbation by population bias $\gamma_P$ (omitted
modifier imbalance) and bridge bias $\gamma_B$ (component drift):

$$\Delta^\star(\gamma_P, \gamma_B) \;=\; \Delta + b_P(\gamma_P) + b_B(\gamma_B) + b_{PB}(\gamma_P,\gamma_B).$$

Three consequences specific to the component case:

1. **Both layers move the same scalar and neither is identified**, so their signs
   are free. A one-at-a-time curve fixes the other layer at its assumed null, which
   is precisely the value at which cancellation is invisible. **This is QBA-22's
   structure, and the component setting is where it bites hardest** because the
   cross-gap contrast has no direct evidence at all.
2. **The bridge layer is not one parameter.** It contains component main-effect
   drift **and** component-by-modifier drift, and the entry adds
   component-by-component non-additivity and backbone interactions. **Current
   tooling varies one common bound on main-effect drift and explicitly excludes
   interaction drift**, so the layer that can interact with the population layer
   through the modifier is exactly the one not implemented.
3. **The joint model needs an integration that published data cannot support.**
   Evaluating it means integrating inverse-linked perturbed predictions over the
   **joint** target distribution of measured **and omitted** covariates. The
   measured part is CMP-15's and MOD-01's problem; the omitted part has no data at
   all and is elicited. **So the joint model's inputs are strictly weaker than the
   one-at-a-time model's**, and a fair comparison must charge it for that.

**That last point is the design's fairness requirement**: the joint model is not
free, and a comparison that gave it the true joint law while the one-at-a-time
model used marginals would be measuring the law, not the model.

## 3. Estimand, with its true value defined

**Primary.** The target marginal log odds ratio, and the RMST difference for a
time-to-event arm, by quadrature and exact integration at orders fixed by P1.

**The layer-attribution shares are derived estimands, and they inherit the
nonidentification of their inputs.** The entry says so plainly: they **describe a
chosen model rather than recovering an underlying quantity.** They are reported
under an explicitly stated attribution rule with the fixed parameter vector or
averaging distribution named, and they are never presented as a decomposition of a
real quantity.

**Whether apparent robustness comes from cancellation** is the binary derived
outcome, with a known truth by construction.

## 4. Data-generating mechanism, and what it makes invisible

Disconnected component network with no cross-gap evidence, one shared component
bridging two subnetworks.

### Factors

| factor | levels | why |
|---|---|---|
| omitted-modifier imbalance | 0, moderate, large | the population layer |
| component main-effect drift | 0, moderate, large | the bridge layer, part one |
| **component-by-modifier drift** | 0, moderate, large | **part two, and the one current tooling excludes** |
| sign configuration | reinforcing; cancelling | section 2 consequence 1 |
| dependence between layers | independent; correlated, both signs | the elicited structure |
| target-law knowledge | true joint law; marginals only | **section 2's fairness requirement** |
| estimand | log OR; RMST | non-additivity differs by scale |

### What the mechanism makes true, and therefore what the study cannot see

- **Component-by-component non-additivity and backbone interactions are named by
  the entry and are not included.** Adding them would make the joint space
  four-dimensional and the region uncomputable at any affordable grid; **they are
  listed as forms of drift the model does not cover**, which the entry explicitly
  asks any such model to state.
- The dependence structure between layers is elicited and **no data can inform
  it**. Every result is a function of it.
- Selection bias is treated as identified where covariates and transport
  assumptions permit, per the entry's correction, and enters only as part of the
  population layer where they do not.
- The omitted covariate's joint distribution with measured covariates is supplied
  by assumption in the joint arm. **That assumption is the joint model's price**
  and the design charges it.

## 5. Methods, including one that can win

| method | role |
|---|---|
| one-at-a-time curves, each layer | current practice |
| bounded main-effect drift only | what current tooling implements |
| **joint model over both layers** | the proposal |
| joint model with marginals-only target law | the deployable version, paying section 2's price |
| partial-identification bounds over both layers | the honest extreme when nothing is elicited |

**The comparator that can win is bounded main-effect drift.** It is what exists, it
is cheap, and if it bounds the joint effect across the realistic range then the
interaction-drift and omitted-modifier layers can be left as disclosures rather
than modeled. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and decision reversal per method per cell, with MCSE.

**The bounding rate**: fraction of joint cells where the one-at-a-time region
contains the joint truth, reported **separately for reinforcing and cancelling
configurations**, since a high rate achieved through cancellation is not
reassurance.

**The cancellation-detection rate**: fraction of replicates where the analysis
reports robustness and the truth is in fact outside the decision-invariant region.
**That is the operational form of "spurious robustness" and it is the primary
outcome.**

**Feasibility, effective sample size, edge influence, effect and decision-reversal
surfaces and partial-identification bounds are exposed as a single object**, which
the entry asks for and no implementation provides. **Whether that object is
readable is itself reported**, following QBA-22's finding that a joint region above
two or three dimensions has no reporting form.

$n_{sim} = 1000$ per cell, Stan-limited; the joint grid multiplies it and P3 sets
its resolution.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The spurious-robustness rate of one-at-a-time analysis in the
cancelling configuration with interaction drift active.

**Decision rule.**

- A substantial rate **confirms** the entry and the deliverable is the joint model
  plus the statement of which drift forms it covers.
- A negligible rate **refutes** it at these magnitudes, and bounded main-effect
  drift is sufficient.
- The joint model with marginals-only target law failing where the true-law version
  succeeds: **the joint model is not deployable**, which is a different and more
  useful conclusion than either, and it is what section 2 consequence 3 predicts.

## 8. Three controls, each of which can fail

**Null control.** With both layers at zero, every method must be unbiased and
declare robust. This also checks the joint machinery adds nothing when there is
nothing to add.

**Second null control.** With **only** the population layer active, the
one-at-a-time curve for that layer must bound the effect exactly, because there is
nothing to cancel against. **That is the cell where current practice is correct,
and establishing it is what makes the failure elsewhere attributable.**

**Positive control.** Cancelling configuration, interaction drift active, no
cross-gap evidence: one-at-a-time must report robustness while the truth lies
outside the region. **If that cannot be produced, the entry's central claim is
unreachable at attainable magnitudes and the study says so.**

**Falsifier for the study's own headline.** The expected headline is that joint
analysis is required. Its falsifier is section 2's fairness requirement: **if the
joint model needs a target law nobody can supply, then it is not an available
alternative regardless of how much better it is with one.** The marginals-only arm
exists to decide that, and it is registered as capable of overturning the
recommendation.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming both layers are always unidentified | Restricted to the no-cross-gap-evidence case, per the entry's correction | removed |
| Joint model given inputs the one-at-a-time model lacks | Marginals-only arm carried; the price is charged | removed |
| Attribution shares presented as a decomposition | Reported under a stated rule as descriptive, per the entry | removed |
| Bounding rate averaged over cancellation and reinforcement | Reported separately | removed |
| Drift forms not covered, left implicit | Listed explicitly, which the entry requires | removed |
| A joint region that cannot be read | Readability reported; QBA-22 named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P0** QBA-22 and CMP-15/MOD-01 | The joint-region summary and the target-law machinery. **The note orders this study after them and section 2 makes that a dependency, not a preference** | Everything | two studies |
| **P1** truths and interaction term | Estimand truths and the analytic $b_P$, $b_B$, $b_{PB}$ per cell | **The grid.** A cell whose interaction term is negligible cannot exhibit cancellation | days |
| **P2** cancellation attainability | That reinforcing and cancelling configurations both exist at plausible magnitudes | Whether the primary outcome has a signal | days |
| **P3** joint grid resolution | The grid density at which the decision-invariant region is stable | The budget, exponentially | days |
| **P4** unit cost | Grid times $n_{sim}$ times a Stan fit; total computed not typed | Everything | hours |

## 11. Cost

The joint grid over two layers, one of which has two components, times $n_{sim}$
times a component ML-NMR fit. **This is among the most expensive designs in the
queue and its ordering behind two prerequisites is not deference; it is the only
way the grid is affordable**, since QBA-22's region summary is what allows the
joint object to be reported at all.

---

## Relationship to the rest of the queue

- **QBA-22** owns joint bias composition and the region-summary problem, and is a
  hard prerequisite.
- **CMP-15** and **MOD-01** own the target-law uncertainty this design must charge
  the joint model for, and are the note's other prerequisite.
- **CMP-21** finds the same three-route cancellation for one MNAR parameter.
- **DIS-11** and **IDN-08** own bridge validation, which is what would make the
  bridge layer identified rather than elicited.
- **CMP-26** owns the adversarial module in which these drift forms first appear
  as departures.
