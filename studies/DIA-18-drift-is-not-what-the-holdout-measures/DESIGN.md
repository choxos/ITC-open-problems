# DIA-18 design: prediction error against calendar gap is four things at once

**Status: design. Not registered.** Gated on data; see section 10.
Written against `studies/DESIGN-STANDARD.md`.

**No prior work is identified for this problem in the reviewed sources**, and the claim
that none exists is **an absence claim the literature auditor could not verify**. This
design makes no absence claim.

The catalog also narrows what the holdout tests, and the narrowing is the design's centre.
It assesses **joint out-of-time predictive transportability rather than equality of
specific component or effect-modifier coefficients**, it requires the newer trial's
contrast to lie in the **estimable row space of the training design** with adequate
overlap, and **prediction error against calendar gap combines sampling error, ordinary
between-study heterogeneity, design and outcome-definition changes and any genuine drift**,
so **it does not by itself identify a decay rate or justify a universal trial-age cutoff.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** constancy of component effects and effect modification is
assumed across studies conducted decades apart; calendar time bundles changes in standard
of care, diagnostic criteria, outcome ascertainment and treatment versions; **chronology is
always recorded, so the holdout is uniquely feasible, yet no estimate of context-specific
drift exists.**

**Refuting sentence:** *once sampling error and ordinary heterogeneity are removed, the
systematic temporal component is small enough that trial age is not a useful selection
criterion.*

**That refutation is the likely outcome and it is worth establishing**, because a
non-result here would retire a widely felt but unquantified worry.

## 2. The mechanism: four components, and only one is drift

Prediction error for a held-out later trial decomposes as

$$e \;=\; \underbrace{\varepsilon}_{\text{sampling}} \;+\; \underbrace{h}_{\text{ordinary between-study heterogeneity}} \;+\; \underbrace{d}_{\text{design and outcome-definition change}} \;+\; \underbrace{\delta(\text{gap})}_{\text{temporal drift}} .$$

Three consequences:

1. **A single fit-and-predict exercise estimates $e$ and reports it as $\delta$.** That is
   the error the design exists to avoid, and it is why **repeated holdouts or a hierarchical
   temporal model are required rather than one prediction.** $h$ is estimable from the
   within-era spread; $\varepsilon$ from the estimates' standard errors; $d$ only where
   design changes are recorded. **$\delta$ is what remains**, and QBA-02's section 2 does
   the same subtraction for a different benchmark.
2. **Regressing $e$ on calendar gap without the subtraction fits a decay rate to the sum**,
   which will look like drift because $h$ and $d$ both tend to grow with separation in time.
   **So a positive slope is not evidence of drift**, and the design's primary is the slope
   after subtraction rather than before.
3. **The row-space precondition is not a formality.** If the held-out contrast is not
   estimable from the earlier design, the exercise produces a non-result rather than a large
   error, **and conflating them would report a rank condition as temporal drift.** The same
   check IDN-07, DIA-07 and DIA-16 require.

**And the estimand must align.** Outcome definitions change over calendar time, which is
precisely $d$; **so a holdout that does not harmonize the estimand is measuring the thing it
is trying to subtract.** Harmonization is a precondition, and where it is impossible the
holdout is not run.

## 3. Estimand, with its true value defined

**Primary.** The held-out later trial's marginal arm outcomes and relative effect,
standardized to that trial's population, with the **observed randomized result as the
reference** — which carries its own uncertainty and is not truth.

**The deliverable is $\widehat{\mathrm{Var}}(\delta)$ and its dependence on calendar gap**,
after the subtraction in consequence 1, reported **as context-specific drift estimates
rather than a universal decay rate**, per the entry.

**Arm-level prediction is reported alongside the relative effect**, since IDN-10 establishes
that the two can fail independently and a transport model predicts both.

## 4. Design, and what it cannot see

**Repeated holdouts**, not one: fit on all trials before each calendar cutoff, predict the
next, and repeat across cutoffs and across networks, which is what makes the components in
consequence 1 separable.

### Factors, insofar as observational data permit

| factor | how it enters |
|---|---|
| calendar gap | the axis |
| recorded design change between eras | a covariate, so $d$ is partly modeled rather than assumed absent |
| covariate overlap between eras | a precondition and a stratifier |
| network and indication | context, since the deliverable is context-specific |

### What it cannot see

- **Unrecorded design change is absorbed into $\delta$.** That is irreducible: $d$ is only
  as separable as the record allows, **so every drift estimate is an upper bound** and the
  design says so.
- **A universal trial-age cutoff is not derivable** from this, per the entry, and no branch
  proposes one. **Any inclusion-window recommendation is conditional on indication and
  outcome.**
- Chronology is always recorded, which is why the exercise is feasible; **but networks with
  enough eras and estimable held-out contrasts are not common**, and G2 counts them.
- The reference is a randomized estimate with sampling error, so comparisons are
  uncertainty-aware as in DIA-17.

## 5. Methods

Population-adjusted outcome and effect-modifier models fitted on the pre-cutoff trials and
standardized to the held-out trial's population, with **a hierarchical temporal model**
fitted across holdouts to perform consequence 1's separation.

**The comparator that can win is a model with no temporal term.** If it predicts held-out
trials as well as one with a drift term across the available networks, **the refuting
sentence holds** and the deliverable is that finding. Registered as such.

## 6. Performance measures

**Uncertainty-aware prediction error** for arm outcomes and relative effects; **the
decomposition** into the four components of consequence 1; and **$\delta$'s dependence on
gap**, reported per indication.

**The naive-versus-adjusted slope** is reported as a pair: the regression of raw prediction
error on calendar gap, and the same after subtraction. **Consequence 2 predicts the first
is steeper**, and showing that difference is the study's most transferable methodological
point even where the drift estimate itself is context-specific.

**Non-estimable holdouts are counted separately**, per consequence 3.

## 7. Decision rule, before any data is analyzed

- $\delta$ materially nonzero and growing with gap after subtraction: **drift is
  established for that context**, and the deliverable is the estimate plus a drift prior for
  subnetwork-specific and hierarchical component models.
- $\delta$ near zero after subtraction while raw error grows: **the refuting sentence
  holds**, and the useful output is the demonstration that raw prediction error against
  calendar gap is not a drift estimate.
- **Both slopes are reported in either branch.**

**Tolerances and the hierarchical model's specification are registered before any holdout is
run**, since the exercise's outcome is otherwise easy to shape.

## 8. Controls

**Null control.** Holding out a trial from the **same era** as the training set must give
prediction error consistent with $\varepsilon + h$ alone. **That calibrates the two
subtractable components empirically** and is what makes the decomposition credible rather
than assumed.

**Second null control.** Holding out a trial whose contrast is **not** estimable from the
training design must be recorded as a non-result. **If such holdouts are silently scored,
consequence 3's confusion is already present in the pipeline.**

**Positive control.** Where a recorded design change is known to have occurred between eras,
$d$ must be detectable as a shift not explained by gap alone. **If it is not, $d$ is not
separable in this data and $\delta$ is an upper bound with no useful ceiling.**

**Falsifier for the study's own headline.** The expected headline is that drift is
estimable once the other components are removed. Its falsifier is the null control: **if
same-era holdout error is as large as cross-era error, then $h$ swamps $\delta$ and no
calendar-gap signal is recoverable at these network sizes**, which is a clean negative
result and should be reported as one.

## 9. Threats

| threat | what was done | status |
|---|---|---|
| An absence claim the auditor could not verify | Not made | removed |
| Raw prediction error reported as drift | Decomposition required; both slopes reported | removed |
| A universal trial-age cutoff | Not proposed; recommendations conditional on indication and outcome | removed |
| Non-estimable holdouts scored as large errors | Counted separately | removed |
| Estimand drift measured as temporal drift | Harmonization is a precondition; unharmonizable holdouts not run | removed |
| Unrecorded design change | Absorbed into $\delta$; every estimate stated as an upper bound | disclosed |

## 10. The gate, and what runs before it

| step | what it produces |
|---|---|
| **G1** protocol registration | This document, with the hierarchical model and tolerances fixed |
| **G2** feasibility census | Which networks have enough eras, estimable held-out contrasts and harmonizable estimands, **shared with DIA-16's and DIA-17's surveys** |
| **G3** pipeline on simulated networks | The decomposition validated where $\delta$ is known, since **a decomposition that cannot recover a known drift is not a decomposition** |
| **G4** same-era calibration | The null control run first, so $\varepsilon + h$ is measured before any cross-era holdout is interpreted |

**G3 is the step that would be skipped**, and it is the only one that can show the
subtraction works before it is trusted on real data.

## 11. Relationship to the rest of the queue

- **QBA-02** performs the same sampling-error subtraction for a benchmark discrepancy and
  the two share the method.
- **IDN-07** owns held-out-trial falsification and supplies the estimability precondition;
  **IDN-10** owns arm-level prediction.
- **DIA-16** and **DIA-17** share the data census.
- **CMP-16**, **HET-03** and **CMP-18** own the drift and heterogeneity structures a drift
  prior from this study would inform.
