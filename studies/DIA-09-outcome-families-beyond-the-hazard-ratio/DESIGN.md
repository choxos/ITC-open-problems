# DIA-09 design: the outcome families that have no target-population estimand yet

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**OUT-11 is already running the slice this entry's note recommends first.** It
compares proportional-hazards MAIC and STC against flexible survival ML-NMR on
target RMST differences, milestone survival differences and the time-varying
marginal hazard ratio, under delayed and crossing effects with differential
censoring. So the decisive question the sketch names, whether methods with
acceptable hazard-ratio error still have large RMST or survival-curve error, is
being answered.

**This design is therefore the rest of DIA-09**, and the scoping is not a
convenience: running the same slice twice would produce two studies that cannot
disagree.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** cure fractions, competing risks, recurrent events,
multistate processes, proportional-odds violations for ordinal outcomes and
jointly generated efficacy, safety, quality-of-life and cost outcomes are absent
from the PAIC simulation literature; generating them with a known
target-population marginal estimand requires deriving that estimand analytically
or by large-sample Monte Carlo, which is routinely skipped; and PAIC methods
behave differently on them than the hazard-ratio literature implies.

**Refuting sentence:** *population adjustment operates on the covariate
distribution and is indifferent to the outcome family, so results established for
one family transfer, and the missing families are a reporting gap rather than a
methods gap.*

**That refutation is plausible for weighting and false for outcome models**, and
section 2 says why, which makes it a real test rather than a formality.

## 2. The mechanism: where the outcome family enters, and where it does not

Weighting methods estimate a density ratio and apply it to whatever outcome
follows, so the covariate-side machinery is genuinely family-agnostic. **The
outcome family enters in two other places and both are load-bearing.**

**First, the estimand itself may not be a contrast of means.** A cure fraction is
a mixture parameter; a competing-risks estimand is a cumulative incidence that
depends on the cause-specific hazards of *every* cause; a recurrent-event burden
is a mean function over time. For each, the target-population marginal quantity is

$$\theta(F_T) \;=\; \Psi\!\left(\int \mu(x)\,dF_T(x)\right)$$

for a family-specific and generally **nonlinear** $\Psi$. Two consequences:

1. **Non-collapsibility is not the only nonlinearity.** A cumulative incidence
   involves a competing cause the analysis may not even model, so transporting the
   cause of interest correctly can still give the wrong absolute quantity. **A
   method can be unbiased for every cause-specific hazard ratio and biased for the
   cumulative incidence the decision uses.**
2. **Joint outcomes make the decision functional nonlinear across outcomes, not
   only within one.** Net benefit is a function of efficacy, safety, utility and
   cost together, and simulations that generate one outcome at a time cannot
   represent the covariance that a nonlinear functional is sensitive to. **The
   error in net benefit is not the sum of the errors in its components**, so
   scoring components separately does not bound it.

**Second, the truth must be computable.** The catalog names this as the reason
generators skip these families and it is correct. **For every family here the
target-population marginal estimand is derived explicitly or computed by
large-sample Monte Carlo whose own error is bounded, and that derivation is the
study's first deliverable** independent of any method comparison.

## 3. Estimand, with its true value defined

One per family, each declared with the population it indexes:

| family | estimand | truth |
|---|---|---|
| cure fraction | target-population cure proportion difference | analytic from the mixture model |
| competing risks | target cumulative incidence difference at declared times | numerical integration of the cause-specific hazards over $F_T$ |
| recurrent events | target mean cumulative function difference at declared times | analytic from the intensity |
| ordinal | target category-probability differences and the marginal odds ratio | quadrature |
| joint multi-outcome | target incremental net monetary benefit | Monte Carlo over the joint outcome law, with its own error bounded in P1 |

**Every truth is verified two ways where possible**, analytic against large-sample
Monte Carlo, because a single derivation of an unfamiliar estimand is the most
likely place for a silent error in this design.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| outcome family | the five above | the design |
| effect-modifier overlap | good, poor | the standard axis, kept comparable to the published benchmarks |
| effect-modification strength | 2 levels | the multiplier |
| family-specific severity | cure fraction 0.1/0.4; competing-cause hazard low/high; recurrence dispersion; proportional-odds violation absent/present | **each family needs its own severity axis, and using one generic "strength" would make families incomparable in an uncontrolled way** |
| outcome correlation (joint arm) | 0, moderate, strong | section 2 consequence 2 |

### What the mechanism makes true, and therefore what the study cannot see

- **Non-proportional hazards on a single time-to-event outcome is OUT-11's
  subject and is excluded here.** Where a family involves a hazard, it is
  proportional within cause, so nothing here is confounded with OUT-11's
  question and the two studies' results compose rather than compete.
- Censoring is administrative and non-informative. OUT-07 owns informative
  censoring, and MIS-02 owns censoring-weighted transport.
- The joint multi-outcome arm uses a declared utility and cost model. **Net
  benefit results are conditional on that model and are not a claim about any
  particular decision problem**; the arm exists to test whether component-wise
  scoring bounds joint error, which is a structural question.
- One target population per replicate. EST-11 owns the menu.

## 5. Methods, including one that can win

MAIC, STC with family-appropriate marginalization, ML-NMR with the general
likelihood extension (arXiv:2401.12640, which is what makes absolute-scale
target-population quantities computable at all), ML-UMR, and no adjustment.

**The comparator that can win is MAIC.** Section 2 says the weighting side is
family-agnostic, so if MAIC's performance ranking is the same across families,
the refuting sentence holds for the family that matters most in practice and the
recommendation is that the existing evidence transfers. Registered as such.

**One arm is a structural check rather than a method:** for the competing-risks
family, an analysis that transports the cause-specific hazard correctly and then
computes cumulative incidence with the **source** trial's competing-cause hazard.
That is what an analyst does when the competing cause is not reported, and section
2 consequence 1 says it fails; it is included so that failure is measured rather
than asserted.

## 6. Performance measures, MCSE, and $n_{sim}$

Per family: bias, coverage and RMSE of the declared estimand, with MCSE.
**Time-indexed error where the estimand is a function of time**, reported as a
curve with a simultaneous band rather than at one arbitrary landmark.

**The measures are attached to the families they are defined for, not applied
universally.** The catalog is explicit: integrated Brier score where survival
predictions and censoring handling are defined; extrapolation error where the
pipeline extrapolates beyond observed follow-up; recurrent-event calibration
where event burden is the estimand. **A measure reported where it is not defined
is a number without an interpretation**, and applying one panel to five families
is how that happens.

**The joint arm's registered check:** whether the error in net benefit is bounded
by the errors in its components. Section 2 says it is not, and a violation is the
result.

Common random numbers across methods within a family; MCSE clustered on the
replicate block. $n_{sim} = 2000$; ML-NMR arms reduced by P4 and reported at
their own counts.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target cumulative incidence
difference under competing risks, at poor overlap, comparing methods that
transport the competing cause against the arm that does not.

That family is chosen because section 2's first consequence is sharpest there and
because cumulative incidence is what an economic model consumes.

**Decision rule.**

- The non-transporting arm materially biased while the transporting arms are
  nominal **confirms** that the outcome family changes what must be transported,
  and the deliverable is a requirement to report competing-cause information.
- All arms nominal across every family **refutes** the proposition; the existing
  hazard-ratio evidence transfers and the study says so.
- **The truth derivations are published in either branch**, because they are what
  makes any future simulation in these families possible and they do not depend
  on the verdict.

## 8. Three controls, each of which can fail

**Null control.** With no effect modification, every method must be unbiased for
every family's estimand. **This is also the check that each unfamiliar truth is
derived correctly**, since with no modification the target and source estimands
coincide and an error in the derivation shows up immediately.

**Second null control.** In the joint arm at zero outcome correlation, net benefit
error must be exactly the weighted sum of component errors. **That is algebraic,
and it is what makes the nonzero-correlation result interpretable.**

**Positive control.** Competing risks with a high competing-cause hazard and
strong modification: the non-transporting arm must be biased by at least three
MCSEs. If it is not, the mechanism is unreachable and the primary outcome has no
signal.

**Falsifier for the study's own headline.** The expected headline is that outcome
family matters. Its falsifier is MAIC's ranking being stable across families: if
weighting behaves identically everywhere, the family-specific machinery matters
for the estimand and not for the method, which is a narrower and different
conclusion. **Both are publishable and the design must not be able to confuse
them.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Duplicating OUT-11's non-proportional-hazards slice | Excluded; hazards proportional within cause | removed |
| One severity axis across incomparable families | Family-specific severity factors | removed |
| One measure panel applied where measures are undefined | Measures attached to families, per the catalog | removed |
| Truths derived once and wrong | Verified two ways where possible; null control checks them | removed |
| Net benefit results read as a decision claim | Declared utility and cost model; the arm's purpose stated as structural | disclosed |
| Informative censoring confounded with family effects | Excluded; owners named | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth derivations | Each family's target-population marginal estimand, analytically and by large-sample Monte Carlo, with the Monte Carlo error bounded | **The families.** A family whose truth cannot be computed to tolerance is dropped, and finding that out first is the entire reason this probe leads | days |
| **P2** general-likelihood feasibility | Whether the ML-NMR general-likelihood extension fits each family at all, and at what cost | Which families have an ML-NMR arm | days |
| **P3** severity calibration | Family-specific severity levels producing comparable difficulty, in a declared metric | The grid | hours |
| **P4** unit cost | Per-replicate cost per family; total computed not typed | $n_{sim}$ and the family list | hours |

**P1 is the deliverable as well as a probe.** Even if the method comparison were
abandoned, the derivations would be the thing this entry most needs.

## 11. Cost

Five families times five methods; ML-NMR with general likelihoods dominates.
Unpriced until P2 and P4.

---

## Relationship to the rest of the queue

- **OUT-11** owns non-proportional hazards and the transported hazard ratio, and
  is running. This design is explicitly the remainder.
- **OUT-08** owns overdispersed counts and recurrent events, and **OUT-10** owns
  proportional odds and ordinal utilities; if either runs first, this study
  imports rather than repeats, and the recurrent-event and ordinal families here
  become their arms.
- **DIA-08** owns the generator question on the effect-modification axis; the two
  share a generator if both run.
- **QBA-24** owns survival QBA beyond the hazard ratio.
- **DEC-01** owns decision error, which the joint arm operationalizes.
