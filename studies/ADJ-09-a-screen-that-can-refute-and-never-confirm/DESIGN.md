# ADJ-09 design: checking stability where the data are, for a bridge used where they are not

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note requires framing this **as falsification rather than validation**, and section 2
shows that is not a stylistic preference: the logic of the check permits nothing else.

Two qualifications from the catalog belong in the claim and shape the design. **A trial,
era, country or subnetwork is not automatically a valid environment**, since that needs
harmonized variables, suitable exogenous shifts and adequate within-environment treatment
support. And **strong instability should flag a bridge for sensitivity analysis rather
than trigger automatic rejection**, because sampling error, measurement change, case mix
and effect-scale non-collapsibility produce instability too.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no invariant-causal-prediction screen for bridge or component
assumptions exists in evidence synthesis; the bridging assumption concerns the gap where
no data exist, so every stability check is necessarily performed somewhere else; and
invariance methods need enough distinct environments to separate stable structure from
noise, which evidence networks do not supply.

**Refuting sentence:** *instability where the data are is strongly predictive of bridge
failure where they are not, so the screen has confirmatory value in practice even though
it lacks it in logic.*

## 2. The mechanism: the asymmetry is logical, the power is empirical

**The logical half.** Let $S$ be the set of environments where effects are observable and
$G$ the gap. Invariance across $S$ is a property of $S$. **Passing is consistent with the
bridge failing on $G$**, because nothing constrains behavior outside the observed
environments. **So the procedure can refute and never confirm**, and that is not a
limitation to be reduced by better methods.

**The empirical half, which is what the study can measure.** Whether **failing** on $S$
predicts failing on $G$ is a correlation, and it depends on whether the mechanism causing
instability is the same one the bridge relies on. Three consequences:

1. **Specificity is the binding problem, not sensitivity.** Sampling error with few
   trials, measurement change, case mix and **effect-scale non-collapsibility** all
   produce instability under a valid bridge. **The last is a design artifact: a marginal
   effect on a non-collapsible scale varies with the covariate distribution even when the
   conditional effect is invariant**, so a screen run on marginal effects will find
   instability wherever populations differ, which is everywhere. **That predicts the
   screen fires most in exactly the networks it is used for**, and it is the design's
   sharpest testable claim.
2. **The remedy is to screen on the conditional scale or to standardize first**, which
   turns the specificity problem into a design choice rather than an intrinsic limit.
   **Both are run, so the artifact is measured rather than assumed away.**
3. **The number of environments bounds the signal**, as ADJ-10 finds for discovery: the
   identifying denominator is trials, not patients. **So the abstention rate should fall
   with environments and the design varies them.**

**Abstention is the right output, not rejection.** The nearest published precedent uses a
two-condition abstention rule that declines to report a pooled estimate when stability is
not supported, and this design adopts abstention rather than a pass/fail gate, per the
entry.

## 3. Estimand, with its true value defined

**Primary.** The target-population treatment contrast, by quadrature at an order fixed by
P1, **estimated after flagged bridges are routed to sensitivity analysis**, since that is
the workflow the screen is for.

**The screen's operating characteristics are the derived estimands:** sensitivity and
specificity for genuine bridge violations, and **abstention rate**, which is the cost side.

**A genuine violation is defined by the generator** as drift in the component or class
effect across the gap, distinct from the four nuisance sources in consequence 1.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **number of environments** | 3, 6, 12 | consequence 3 |
| event counts per environment | low, moderate | sampling-error instability |
| genuine modifier or component drift | none, moderate, large | the signal |
| measurement shift across environments | absent; present | a nuisance source |
| **effect scale** | risk difference (collapsible); log OR | **consequence 1's artifact, switched** |
| screening scale | marginal; conditional; standardized | consequence 2's remedy |

**Effect scale crossed with screening scale is the design**, because that pair decides
whether the artifact is present and whether the remedy removes it.

### What the mechanism makes true, and therefore what the study cannot see

- **A valid environment is defined by construction here**, with harmonized variables and
  adequate treatment support. **In practice establishing that is the hard part**, and the
  entry says so; the design measures the screen given valid environments and cannot say
  how often they exist.
- **The screen cannot confirm**, per consequence 1's logical half, and no arm reports a
  pass as evidence the bridge holds.
- The published precedent operates **within a connected evidence base** and is a
  single-author preprint, so it **does not certify a bridge across a disconnected gap**;
  it is adopted as the abstention-rule template, not as validation.
- Non-collapsibility is generated deliberately as a nuisance, so **the design does not
  claim the screen fails in general**; it claims it fails on a scale it should not be run
  on.

## 5. Methods, including one that can win

| method | role |
|---|---|
| no screen | the floor |
| **sign-stability screen with abstention**, marginal scale | the precedent as published |
| the same, conditional scale | consequence 2's remedy |
| the same, standardized to a common target first | the other remedy |
| formal invariance test across environments | the fuller version |

**The comparator that can win is the marginal-scale screen.** If its specificity is
adequate despite consequence 1's artifact, the remedy is unnecessary and the precedent
transfers as published. **Registered as such**, and consequence 1 says it should fail on
a non-collapsible scale, which makes the comparison sharp rather than general.

## 6. Performance measures, MCSE, and $n_{sim}$

Sensitivity, specificity and **abstention rate** of each screen for genuine violations,
with MCSE; **bias and coverage of the target contrast after flagged bridges are routed to
sensitivity analysis**, which is the workflow-level outcome.

**Specificity decomposed by nuisance source**: among false flags, the share attributable
to sampling error, measurement shift, case mix and non-collapsibility. **Consequence 1
predicts the last dominates on a non-collapsible scale**, and that decomposition is what
turns a specificity number into an actionable one.

$n_{sim} = 4000$ per cell, from resolving a false-flag rate of 0.05 to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Specificity of the marginal-scale screen on the log odds ratio scale
with valid bridges and differing environment populations, against the conditional-scale
screen in the same cells.

**Decision rule.**

- Marginal-scale specificity poor and restored on the conditional scale: **consequence 1
  is confirmed**, and the deliverable is that invariance screening must be run on a
  collapsible or conditional quantity.
- Specificity adequate on both: **refuted**, and the precedent transfers as published.
- Specificity poor on both: the instability is not the collapsibility artifact and its
  source must be found from the decomposition rather than assumed.

**Sensitivity and abstention rate are reported together in every branch**, since a screen
that abstains often is costly regardless of its accuracy.

## 8. Three controls, each of which can fail

**Null control.** With valid bridges, identical environment populations and high event
counts, no screen may flag above its nominal rate. **A screen firing where nothing
differs is measuring noise.**

**Second null control, and it is consequence 1's algebra.** On the **risk-difference**
scale with a valid bridge and differing populations, collapsibility makes the marginal
effect invariant, so the marginal screen must **not** fire. **That is the cell separating
"populations differ" from "populations differ on a non-collapsible scale"**, and it is
what makes the artifact attributable.

**Positive control.** Large genuine drift with 12 environments: every screen must flag in
essentially every replicate. **If the screen cannot detect large drift where environments
are plentiful, it has no regime.**

**Falsifier for the study's own headline.** The expected headline is that the screen is a
falsification device whose specificity depends on the scale. Its falsifier is the
workflow outcome: **if routing flagged bridges to sensitivity analysis does not improve
bias or coverage of the target contrast, then the screen's operating characteristics do
not matter because nothing downstream uses them well.** That is reported rather than
assumed.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting the screen as validation | Framed as falsification, per the note and consequence 1 | removed |
| Automatic rejection on instability | Abstention and routing to sensitivity analysis, per the entry | removed |
| Treating any trial or era as an environment | Validity built in by construction; the practical difficulty stated | disclosed |
| Non-collapsibility artifact unmeasured | Effect scale crossed with screening scale; second null control | removed |
| The precedent presented as certifying a bridge | Stated as within-connected and a preprint | removed |
| Specificity reported as one number | Decomposed by nuisance source | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Target contrast truths per cell | The definition of truth | hours |
| **P2** artifact magnitude | The analytic instability a non-collapsible scale produces at the planned population differences, before fitting | **The primary outcome's prediction**, and whether the artifact is reachable | hours |
| **P3** environment validity | That the constructed environments meet the harmonization and treatment-support conditions | The design's premise | hours |
| **P4** unit cost | Per-network cost at $n_{sim}=4000$ | The grid | hours |

## 11. Cost

Network fits at 4000 replicates across five screens; the screens are cheap and the fits
dominate. Moderate.

---

## Relationship to the rest of the queue

- **DIS-11** owns what can and cannot validate a bridge and establishes that deletion has
  leverage while predictive criteria do not; **this screen is a third route with a third
  logic.**
- **ADJ-10** shares consequence 3's environment-counting argument.
- **IDN-01** owns transitivity screens generally and would carry this one.
- **COV-02** owns the scale dependence that consequence 1 turns into an artifact.
