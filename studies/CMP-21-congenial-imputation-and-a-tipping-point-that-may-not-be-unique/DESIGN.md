# CMP-21 design: one sensitivity parameter entering three layers at once

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is a scope instruction and it is followed exactly: **one
estimand, one missingness location, one PAIC method.** Component ML-NMR, missing
effect modifiers in the IPD, the target-population component contrast.

MIS-01 owns participant-level missingness in MAIC and establishes that
complete-case bias is a product of the unmatched covariates' effect and the
missingness-induced shift. **This design takes the two things that are specific to
the component transport setting and that MIS-01 cannot reach**: what congeniality
means when the analysis likelihood integrates over a target covariate
distribution, and what happens when one MNAR parameter propagates through three
layers simultaneously.

Section 2 finds that the second has a consequence nobody has stated.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no imputation model has been made congenial with a
likelihood that integrates over a target covariate distribution and shares
component parameters across subnetworks; and a single MNAR sensitivity parameter
propagates simultaneously through the adjustment step, the covariate overlap and
the bridging assumption, with no framework saying how those effects combine.

**Refuting sentence:** *the three propagation routes have the same sign and
comparable magnitude, so a tipping-point analysis behaves exactly as it does in an
ordinary MAIC and the existing workflow transfers unchanged.*

## 2. The mechanism: three routes, and the tipping point need not be unique

Let $\delta$ index an MNAR departure: the shift between the distribution of a
missing effect modifier and what a missing-at-random model would impute. In
component ML-NMR, $\delta$ enters in three places.

**Route A, the interaction.** Shifting the imputed modifier values changes the
estimated component-by-covariate interaction $\hat\beta_{EM}$, roughly linearly in
$\delta$.

**Route B, the integration distribution.** The aggregate arms are fitted by
integrating the individual model over a covariate distribution built from the
**IPD-informed** correlation and marginal structure. Shifting the imputed values
shifts that distribution, so the integration is taken over a different law.

**Route C, the bridge.** The cross-gap contrast is identified through shared
components whose effects are assumed constant across subnetworks. If the
subnetworks differ in missingness, $\delta$ shifts them unequally and the
constancy the bridge needs is perturbed.

The target contrast is therefore

$$\Delta(\delta) \;=\; \Delta_0 \;+\; a\,\delta \;+\; b\,\delta \;+\; c\,\delta \;+\; O(\delta^2),$$

**and $a$, $b$ and $c$ need not share a sign.** Three consequences:

1. **The routes can cancel.** A $\delta$ that biases the interaction upward can
   shift the integration distribution so as to bias the contrast downward. **A
   sensitivity analysis that finds no movement is then not evidence of
   robustness**; it is evidence that the routes cancelled at that $\delta$.
2. **$\Delta(\delta)$ need not be monotone**, so the decision can flip, flip back,
   and flip again. **"The tipping point" presupposes monotonicity and may not be
   unique.** Every tipping-point analysis in this literature reports a single
   value, and if $\Delta(\delta)$ is non-monotone that single value is the
   smallest of several and the analysis understates the region of concern.
   **This is the design's sharpest and most checkable claim.**
3. **The three routes can be switched on separately in simulation** by holding the
   integration distribution at its true value (kills B) and by making missingness
   identical across subnetworks (kills C). So $a$, $b$ and $c$ are separately
   estimable, which is what turns "no framework says how they combine" into a
   measured answer.

**Congeniality, made concrete.** An imputation model is congenial with this
analysis only if it is at least as rich as the analysis model: it must contain the
component-by-covariate interactions, the study-specific structure, **and** be
compatible with the covariate law the integration assumes. **An imputation drawn
from a model that omits the interaction attenuates exactly the term the transport
depends on**, which is a prediction rather than a definition and is testable
against a congenial comparator.

## 3. Estimand, with its true value defined

**Primary.** The target-population component-regimen contrast, on the model's
scale, by quadrature over the declared target law at an order fixed by P1.

**Two derived estimands.** The **route coefficients** $a$, $b$, $c$ of section 2,
each with a defined truth from the generating model. And the **tipping set**, the
full set of $\delta$ at which the decision changes, **defined as a set rather than
a point** so that non-uniqueness is representable; a design that recorded a scalar
tipping point could not detect consequence 2 at all.

## 4. Data-generating mechanism, and what it makes invisible

Component network with two subnetworks and a shared component; missingness in one
effect modifier within the IPD studies.

### Factors

| factor | levels | why |
|---|---|---|
| missingness fraction | 10%, 30%, 50% | Esnault et al. faced roughly half missing on ECOG, so 50% is realistic rather than extreme |
| mechanism | MAR; MNAR at declared $\delta$ | the sensitivity axis |
| **missingness symmetry across subnetworks** | identical; differing | **switches route C**, section 2 consequence 3 |
| **integration distribution** | held at truth; rebuilt from imputations | **switches route B** |
| covariate overlap | good, poor | the adjustment layer |
| imputation congeniality | congenial; interaction omitted | the congeniality prediction |

### What the mechanism makes true, and therefore what the study cannot see

- **One missingness location.** Outcome missingness and its inverse-probability-
  of-censoring weighting, which the catalog notes interacts multiplicatively with
  adjustment weights, is **excluded**; that multiplicative interaction is a real
  problem and it is named, not addressed.
- One PAIC method, component ML-NMR. The two-stage routes handle missingness by
  delegating to standard complete-case regression and behave differently; MIS-01
  covers the MAIC case.
- MNAR departures are **generated at declared magnitudes** and are unidentifiable
  from the data, so every MNAR result is sensitivity analysis by construction.
- Additivity and correct component coding hold. CMP-03 and CMP-06 own those.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| complete case | records with missing modifiers dropped | current implementation's only option, since it rejects missing modifiers and does not impute |
| **congenial multiple imputation** | imputation model containing the component-by-covariate interactions and compatible with the integration law | the proposed fix |
| uncongenial multiple imputation | interaction omitted | what an analyst would reach for |
| joint model | missingness modeled inside the analysis | the fully coherent route |
| MNAR tipping analysis | Esnault et al.'s workflow, adapted | the existing practice, **adapted rather than invented** |

**The comparator that can win is complete case.** If it is unbiased across the
realistic grid, the component layer adds nothing to MIS-01's finding and the
recommendation is simply to report which strategy was used. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, interval width and effective sample size for the target contrast,
per method per cell, with MCSE.

**The route decomposition:** $\hat a$, $\hat b$, $\hat c$ estimated from the
switching arms and compared with the generating truth. **Their signs are reported
individually**, because consequence 1 turns on whether they differ.

**Tipping-set calibration:** the number of sign changes in $\Delta(\delta)$ over
the declared $\delta$ range, and the fraction of replicates where the tipping set
has more than one element. **That fraction is the headline for consequence 2**,
and it is a number no published analysis could have produced because none looks
for it.

Common random numbers across methods and across $\delta$; MCSE clustered on the
replicate block. $n_{sim} = 1000$, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The fraction of replicates in which the tipping set is not a
single point, at 30% missingness with differing missingness across subnetworks.

**Decision rule.**

- A non-negligible fraction **confirms** consequence 2 and the deliverable is that
  a tipping-point analysis in component PAIC must report the tipping **set** and
  the route decomposition, not a scalar.
- A negligible fraction with all three routes sharing a sign **refutes** it, the
  existing workflow transfers, and the study says so.
- Cancellation observed without non-monotonicity is consequence 1 without
  consequence 2: **the sensitivity analysis is still misleading**, because no
  movement is being read as robustness, and the deliverable is the route
  decomposition alone.

## 8. Three controls, each of which can fail

**Null control.** Under MAR with congenial imputation, every imputation arm must
be unbiased and nominal, and complete case must lose only precision when
missingness is independent of the unmatched structure. **This is the check that
the imputation machinery works before any MNAR result is interpretable.**

**Second null control, and it isolates the routes.** With the integration
distribution held at truth **and** missingness identical across subnetworks, only
route A is active, so $\Delta(\delta)$ must be linear in $\delta$ with slope
matching the analytic $a$. **A nonlinear or mismatched response there means the
route decomposition is not measuring what section 2 says**, and every result about
combination is void.

**Positive control.** At 50% missingness with strong MNAR and differing
subnetwork missingness, complete case must be biased by at least three MCSEs and
the tipping set must be non-empty. If no $\delta$ in the declared range flips the
decision, the design has no sensitivity to analyze.

**Falsifier for the study's own headline.** The expected headline is that the
routes can cancel and the tipping point need not be unique. Its falsifier is the
route-decomposition sign test: **if $a$, $b$ and $c$ share a sign in every cell,
cancellation is impossible and non-uniqueness cannot arise from this mechanism.**
That test is cheap, it runs first, and if it fails the study reports a much
smaller result honestly rather than hunting for non-monotonicity elsewhere.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| A scalar tipping point recorded, hiding non-uniqueness | Tipping **set** is the estimand | removed |
| Cancellation read as robustness | Route decomposition reported with individual signs | removed |
| Routes confounded | Two switching factors isolate B and C | removed |
| Congeniality asserted rather than tested | Uncongenial arm carried and its attenuation predicted | removed |
| MNAR results read as estimation | Declared magnitudes; labeled sensitivity | removed |
| Outcome missingness and its multiplicative weight interaction | Excluded and named | disclosed |
| Duplicating MIS-01 | Different method, different layer; MIS-01's product result imported | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and route coefficients | The target contrast's truth and the analytic $a$, $b$, $c$ per cell | **The falsifier in section 8.** If the analytic signs already agree everywhere, the study's central claim is unavailable and the design must change before registration | days |
| **P2** tipping-range attainability | That some $\delta$ in a plausible range flips the decision at the chosen threshold | The $\delta$ range and the decision threshold | hours |
| **P3** congenial imputation feasibility | Whether an imputation model compatible with the integration law can be specified and sampled at all | **Whether the proposed fix exists** | days |
| **P4** unit cost | Per-fit cost times imputations times $\delta$ grid points; total computed not typed | $n_{sim}$ and the $\delta$ resolution | hours |

**P1 is the probe that can end the study cheaply and should run first.**

## 11. Cost

$n_{sim}$ times imputations times $\delta$ grid points times a Stan fit. **That
quadruple product is the largest multiplier in this queue** and it is computed in
P4 rather than quoted here; the $\delta$ resolution is the term most easily set
too fine.

---

## Relationship to the rest of the queue

- **MIS-01** owns participant-level missingness in MAIC and supplies the
  complete-case product result; this design does not repeat it.
- **MIS-04** owns model and bridge selection uncertainty entering the interval.
- **QBA-22** owns non-additivity of total bias across mechanisms, which is
  section 2's cancellation seen as a general phenomenon; if it runs first, its
  framework is imported.
- **DIA-14** owns tipping-point analysis scored honestly and would inherit the
  tipping-set definition.
- **CMP-06** owns component miscoding, held correct here.
