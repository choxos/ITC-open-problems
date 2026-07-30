# IDN-10 design: a check that is neither necessary nor sufficient, scored as a test

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is careful about what Gupta et al. established and what they did not.
They showed a hidden-randomized-truth benchmark is feasible, setting aside the
randomized control arms of 14 non-small-cell lung cancer trials and substituting
external controls, with mean absolute log hazard ratio differences of 0.247
unadjusted, 0.139 after measured-confounder adjustment and 0.098 after external
adjustment. **That benchmarks relative effects. It does not calibrate transported
absolute control-arm outcomes**, which is what this entry is about, and the note
warns this is not an early study unless such a dataset is analysis-ready.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** comparing transported control-arm outcomes with
observed ones tests the absolute-outcome transport model rather than only the
relative effect; agreement conflates prognostic transport, outcome definition,
follow-up, censoring and care context, so a pass can arise from offsetting errors;
and no accepted tolerance states how close is close enough.

**Refuting sentence:** *the check's agreement tracks relative-effect bias closely
enough at realistic magnitudes that it is a usable screen, and a tolerance can be
calibrated.*

**The whole point is that this is a question about operating characteristics**,
and the catalog states the theoretical answer already: agreement is neither
necessary nor sufficient. Section 2 says exactly when each failure occurs, which
turns a caveat into a design.

## 2. The mechanism: two transports, one of which the check does not see

Transport of the control arm requires $\mathbb{E}[Y \mid A=0]$ to move correctly
from source to target, which needs the **prognostic** structure to transport.
Transport of the relative effect requires $\mathbb{E}[Y\mid A=1] -
\mathbb{E}[Y\mid A=0]$ to move correctly, which needs the **effect-modification**
structure to transport. Those are different requirements, and the four
combinations give the check's whole operating-characteristic table:

| prognostic transport | modification transport | control-arm check | relative effect |
|---|---|---|---|
| holds | holds | passes | unbiased |
| **fails** | **holds** | **fails** | **unbiased** — false alarm |
| **holds** | **fails** | **passes** | **biased** — false reassurance |
| fails | fails | usually fails | biased |

Three consequences:

1. **Row three is the dangerous one and it is not exotic.** A covariate can be a
   modifier without being strongly prognostic, in which case the control arm
   transports fine and the effect does not. **So false reassurance has a named
   mechanism**, and the design generates it directly rather than hoping it arises.
2. **Row two makes the check costly, not merely useless.** A failed check on an
   unbiased comparison is a false alarm that would stop a valid analysis, and
   **its rate has never been measured.**
3. **Offsetting errors add a fifth possibility**: prognostic transport failing in
   two mechanisms that cancel in the control arm. The check passes, and whether
   the relative effect is biased depends on whether the same cancellation occurs
   in the modification structure, which it need not.

**The check is therefore a classifier with two error rates and no threshold**, and
that is exactly what the design measures.

## 3. Estimand, with its true value defined

**Primary.** The target-population absolute control-arm quantity: risk, survival
curve, and restricted mean survival time, all three, since the entry asks for the
extension from point outcomes to curves and RMST.

**Secondary and equally registered.** The target-population relative treatment
effect, because the check's value is entirely in what it predicts about this.

**True values** from the generating model by exact integration.

**The check's verdict is the derived estimand**, defined by a tolerance that is
**not** fixed in advance: the study computes the operating characteristics across
a range of tolerances and reports the curve, since the catalog's complaint is that
no accepted tolerance exists and inventing one would answer a question nobody
asked.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **prognostic transport failure** | none, moderate, large | row two and three of section 2 |
| **modification transport failure** | none, moderate, large | crossed with the above, which is the table |
| outcome-definition mismatch | none; shifted threshold | a conflated mechanism |
| censoring difference | none; heavier in target | another |
| care-context shift | none; baseline hazard shifted | another |
| offsetting configuration | absent; two prognostic mechanisms that cancel | section 2 consequence 3 |

**The first two crossed fully is the design.** Everything else is crossed at their
middle levels.

### What the mechanism makes true, and therefore what the study cannot see

- **The check requires a control arm.** It is unavailable in the single-arm
  comparator case that motivates much unanchored adjustment, and **the catalog is
  careful that unanchored does not by itself imply single-arm**. The study
  measures the check where it can run and cannot establish transfer to
  control-free targets; that extrapolation is named as untested and is not
  assumed.
- Arm-level quantities are available to the simulation. **In practice they are
  usually not published**, since analyses report relative effects, so the check's
  practical availability is a reporting question and the study's recommendation
  includes it.
- Conditional constancy fails only through the two named routes, so the check's
  errors are attributable.

## 5. Methods, including one that can win

| arm | role |
|---|---|
| MAIC, STC, ML-UMR | the transport methods whose control arms are checked |
| control-arm check on the point outcome | current conception |
| **check on the survival curve** | the extension, with a band-based verdict |
| **check on RMST** | the extension, on the decision-relevant scale |
| relative-effect benchmark | Gupta et al.'s quantity, computed alongside so the two are comparable |

**The comparator that can win is the relative-effect benchmark.** If it is
available wherever the control-arm check is, and predicts bias better, then the
control-arm extension adds nothing and the recommendation is to keep doing what
Gupta et al. did. Registered as the outcome most likely to overturn the expected
headline.

## 6. Performance measures, MCSE, and $n_{sim}$

**The check scored as a classifier of relative-effect bias**: sensitivity,
specificity, AUROC and calibration, across the tolerance range, with MCSE.

**False reassurance and false alarm reported separately and never pooled**, since
section 2 gives them different mechanisms and different costs.

**Power to detect transport failure** at each magnitude, which is the check's own
job independent of what it implies about the effect.

**The offsetting-error rate:** the fraction of replicates in which the check
passes while prognostic transport has in fact failed. **That is the quantity the
catalog names as making a pass uninformative and nobody has measured it.**

$n_{sim} = 4000$ per cell, from resolving a false-reassurance rate to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** False-reassurance rate of the control-arm check across the
tolerance range, in the cell where prognostic transport holds and modification
transport fails.

**Decision rule.**

- A substantial false-reassurance rate at every tolerance **confirms** that the
  check cannot license a transport model, and the deliverable is a statement of
  what a pass does and does not license, plus the operating-characteristic curve.
- A tolerance existing at which both error rates are acceptable across the grid
  **refutes** the concern and the deliverable is that tolerance with its curve.
- **The curve is published in either branch**, because it is what a committee
  needs and it does not depend on the verdict.

## 8. Three controls, each of which can fail

**Null control.** With both transports holding, the check must pass at
approximately its nominal rate and the relative effect must be unbiased. **The
check's false-alarm rate under the null is the floor** against which every other
rate is read.

**Second null control, and it is row two of section 2.** With prognostic transport
failing and modification transport holding, the check must **fail** while the
relative effect is **unbiased**. **Both halves must hold simultaneously.** If the
relative effect is also biased there, the two transports are not separated in the
generator and the whole table collapses.

**Positive control.** With modification transport failing badly and prognostic
transport holding, the check must pass and the relative effect must be materially
biased. **This is row three, the false-reassurance mechanism, and if it cannot be
produced the design has not built the failure the entry is about.**

**Falsifier for the study's own headline.** The expected headline is that the
check cannot license transport. Its falsifier is the joint use of both checks: if
the control-arm check and the relative-effect benchmark together achieve
acceptable error rates where neither does alone, the recommendation is to report
both rather than to distrust the first.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming Gupta et al. calibrated absolute outcomes | Stated in the header that they benchmarked relative effects | removed |
| A tolerance invented so a verdict can be reported | Operating characteristics reported across the tolerance range | removed |
| False alarms and false reassurance pooled | Separate mechanisms, separate rates | removed |
| Extrapolating to control-free targets | Named as untested, not assumed | disclosed |
| The check's practical unavailability | Reporting recommendation included | disclosed |
| Offsetting errors assumed rare | Generated explicitly and their rate measured | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Control-arm and relative-effect truths per cell | The definition of truth | hours |
| **P2** transport separation | That prognostic and modification transport can be failed independently at the chosen covariate structure | **The design's central crossing.** If a covariate cannot be a modifier without being prognostic in this generator, rows two and three do not exist | days |
| **P3** dataset readiness | Whether a hidden-randomized-truth dataset with arm-level outcomes is analysis-ready, since the note makes that the gate on the case-study half | **Whether the case half runs at all** | days |
| **P4** unit cost | Per-replicate cost across three methods; total computed not typed | The grid | hours |

## 11. The case-study half

The queue records this as simulation **plus case study**. The case half extends the
existing hidden-truth benchmark rather than proposing one: the same set-aside
design, with the **absolute control-arm comparison the published example did not
make**, and extended from point outcomes to survival curves and RMST. **The
catalog is explicit that masked or external validation control outcomes suffice,
so prospective withholding is not a precondition and must not be allowed to gate
the work.** P3 decides whether it can run.

## 12. Cost

Simulation is modest; the case half's cost is data access, which P3 establishes.

---

## Relationship to the rest of the queue

- **IDN-01** lists the transported control-arm comparison as one of its screens;
  this design gives that screen its operating characteristics.
- **IDN-07** owns held-out-trial falsification, the other member of the same
  family, and shares the "what does a pass license" question.
- **DIA-17** owns held-out IPD as a benchmark against truth.
- **QBA-11** and **DIA-14** own the QBA layer this check would sit beside.
- **DIA-09** owns RMST and survival-curve estimands, imported here for the
  extension.
