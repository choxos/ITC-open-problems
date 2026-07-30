# OUT-07 design: two trials, two dropout mechanisms, no cancellation

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note requires narrowing to **one outcome type and one sensitivity
parameterization**, and this design takes time-to-event with a single declared
dependence parameter.

The catalog also narrows two claims and both matter. **The untestability is specific
rather than total**: dependence between the dropout process and the post-dropout outcome
is not identified from observed event and censoring data alone, **but observable
censoring patterns and some model implications can still be examined.** And **correction
is not ruled out in principle**: baseline covariates may suffice under conditional
independent censoring, and time-varying inverse-probability-of-censoring weighting,
congenial imputation or joint models can identify effects under further assumptions.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the source and comparator trials can have different
censoring mechanisms, so the biases do not cancel in an indirect comparison; aggregate
publications report at-risk tables rather than censoring reasons, so a
missing-not-at-random sensitivity analysis has no anchor on the comparator side; and
generic inverse-probability-of-censoring weighting adjusts within a study rather than
across the transport step.

**Refuting sentence:** *informative censoring biases both arms of an indirect comparison
in the same direction, so the contrast is protected even where each arm is not.*

## 2. The mechanism: cancellation requires the mechanisms to match, and nothing makes them

Let each trial's estimate carry a censoring-induced bias $c_S$ and $c_T$. The indirect
contrast carries $c_S - c_T$. Three consequences:

1. **Cancellation requires the two mechanisms to be equal**, not merely both present.
   The source trial is typically a randomized trial with protocol-driven follow-up; the
   comparator may be an external or single-arm source where **censoring reflects
   discontinuation for toxicity, patient preference or early switch to alternative
   therapies.** Those are different processes producing different $c$, so **the refuting
   sentence requires a coincidence that the settings actively work against.**
2. **The asymmetry is largest exactly where the design is weakest.** Externally
   controlled comparisons combine the most informative censoring with the least
   information about it, since the external source is the one whose censoring reasons
   are unreported.
3. **A transport-compatible sensitivity analysis needs a parameter on both sides and has
   one on neither.** The source trial's censoring can be modeled from its individual
   data; **the comparator's cannot be modeled at all from an at-risk table.** So the
   honest object is a one-sided sensitivity: how much comparator-side dependence would
   be needed to change the decision, with the source side estimated. **That asymmetric
   form is the design's deliverable** and it is what makes the analysis possible at all.

**What is examinable and what is not**, kept separate per the entry: observed censoring
patterns, their dependence on **baseline** covariates, and implications such as a
censoring hazard that varies by arm are all inspectable. **Dependence on the
post-dropout outcome is not**, and no arm here claims to test it.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference and survival contrast, by exact
integration over the target law under the generating event process, **using the complete
uncensored data**, so truth is a property of the process and censoring is a property of
the observation.

**The tipping quantity is the derived deliverable**: the magnitude of comparator-side
outcome dependence at which the decision changes, reported as a set following CMP-21
rather than as a point.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| source censoring dependence on latent outcome | none; moderate | one side of $c_S - c_T$ |
| **comparator censoring dependence** | none; moderate; large | **the other side; the asymmetry is the design** |
| censoring prevalence, per trial | 20%, 50% | magnitude |
| time-varying predictors of censoring available | in the source only; in both | what IPCW can use |
| target overlap | good, poor | the adjustment layer |
| censoring-hazard shape | proportional; time-varying | whether a proportional censoring model suffices |

**The two dependence factors crossed is the mechanism**, and the diagonal where they are
equal is the cancellation case the refuting sentence describes.

### What the mechanism makes true, and therefore what the study cannot see

- **One outcome type and one sensitivity parameterization**, per the note. Continuous
  outcomes with outcome-dependent missingness are named and not run.
- **Post-dropout dependence is generated and is unidentified from the observed data**,
  so every result under it is sensitivity analysis by construction.
- The comparator's censoring reasons are unavailable to the estimator, matching
  practice; **they are available to the simulation**, which is what makes the tipping
  quantity scorable.
- MIS-02 owns the TADA estimator's robustness; **this design owns the asymmetry between
  trials**, and the two compose rather than overlap.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive PAIC ignoring censoring dependence | current practice |
| **transport-congenial IPCW** | weights congenial with the transport model, not only with the within-study analysis |
| congenial multiple imputation | the imputation route |
| joint outcome-and-dropout model | the fully specified route |
| **one-sided tipping analysis** | consequence 3's asymmetric form, the deliverable |

**The comparator that can win is naive PAIC.** If the contrast is protected across the
realistic asymmetry range, the refuting sentence holds and the concern is about each
arm rather than the comparison. Registered as such, and consequence 1 says it should
fail only where the mechanisms differ, which is a specific and checkable condition.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of the target contrast per method per cell, with MCSE, and the
**per-trial bias reported separately**, so consequence 1's cancellation is visible
rather than inferred.

**Tipping-set cardinality and location**, following CMP-21's treatment.

**The registered mechanism check:** observed contrast bias against $c_S - c_T$ computed
analytically. **A slope of 1 confirms the difference is the operative quantity** and
makes the cancellation condition precise.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target RMST difference under naive PAIC,
across the asymmetry axis with 50% censoring.

**Decision rule.**

- Bias tracking $c_S - c_T$, absent on the diagonal and material off it: **confirmed**,
  and the deliverable is the one-sided tipping analysis plus a reporting request for
  censoring reasons.
- Bias present on the diagonal too: the mechanisms do not cancel even when equal, which
  would mean something beyond the difference is operating and the study reports that.
- Bias immaterial throughout: **refuted**, and the concern is per-arm rather than
  comparative.

## 8. Three controls, each of which can fail

**Null control.** With administrative censoring independent of everything in both
trials, every method must be unbiased. **A bias there is a pipeline fault.**

**Second null control, and it is the refuting sentence made a cell.** With **identical**
informative censoring in both trials, consequence 1 makes $c_S - c_T = 0$, so the
contrast must be unbiased **while each arm's estimate is biased.** Both halves must hold
simultaneously. **That is the sharpest available demonstration that this is a difference
problem**, and it is what stops the study reading as a general indictment of censoring.

**Positive control.** No source dependence with large comparator dependence at 50%
censoring: naive PAIC must be biased by at least three MCSEs. If not, the asymmetry
cannot be made to matter.

**Falsifier for the study's own headline.** The expected headline is that the asymmetric
tipping analysis is the usable output. Its falsifier is its width: **if the tipping
magnitude is far outside anything clinically plausible in every cell, the contrast is
robust and the analysis, while correct, tells a reader nothing they did not know.**
Plausibility is fixed in P2 from documented discontinuation patterns before the run.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Treating the untestability as total | Examinable and unexaminable features separated per the entry | removed |
| Ruling out correction in principle | Baseline-sufficient and IPCW routes carried | removed |
| Symmetric sensitivity requiring a comparator-side model that does not exist | One-sided tipping form | removed |
| Per-arm bias and contrast bias conflated | Reported separately; second null control | removed |
| Duplicating MIS-02 | That study owns TADA's robustness; this owns the between-trial asymmetry | removed |
| Continuous outcomes | Named, out of scope per the note | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Target contrast truths under the complete uncensored process | The definition of truth | hours |
| **P2** plausible dependence range | Documented discontinuation and switch patterns, fixed before the run | **The falsifier**, and the materiality verdict | days |
| **P3** congeniality specification | What congenial means between an IPCW model and a transport model, written down before implementation | Whether that arm is well defined | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | hours |

**P3 is the same congeniality question CMP-21 faces one layer over**, and the two should
be settled together.

## 11. Cost

Survival fits with weighting and an imputation arm; modest. The joint-model arm is the
expensive one.

---

## Relationship to the rest of the queue

- **MIS-02** owns censoring-weighted transport's robustness and shares the IPCW
  machinery.
- **CMP-21** owns congenial imputation and the tipping-set definition.
- **OUT-14** owns the observation process that publications do not report, of which
  censoring reasons are one instance.
- **QBA-24** owns survival QBA and notes censoring QBA should be added when informative
  censoring is plausible rather than by default, which this design follows.
- **DIA-10** owns access mechanisms, of which informative censoring is one.
