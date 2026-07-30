# CMP-18 design: a time-constant summary is study-specific even when the truth is common

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog corrects the scope in one important way: **non-proportional hazards is
not an open gap at the non-component level.** `multinma` has supported it since
0.6.0 through `aux_regression`, which allows treatment and covariate effects on
shape parameters and spline coefficients across a wide family of baselines. So
this is not a study about whether ML-NMR can do non-proportional hazards. It is
about what happens to a **component bridge** when component effects vary in time,
and the note's instruction to narrow to time-varying effects rather than the full
cure and multistate agenda is followed.

Section 2 finds a consequence sharper than the catalog states.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** component survival models place time-invariant
component effects on the hazard; combination-therapy components can produce
delayed, waning or crossing effects; if two components have different time
profiles the additive combination of their time-constant summaries has no clear
correspondence to the combination's actual hazard trajectory; and allowing
time-varying component effects multiplies what the bridge must assume constant.

**Refuting sentence:** *a time-constant component effect is an adequate summary of
a time-varying one for the estimands decisions use, so the extension buys
precision loss and untestable assumptions for nothing.*

## 2. The mechanism: the least-false constant depends on the study

Let component $k$ have a genuinely time-varying log hazard ratio $\beta_k(t)$,
common to every study. Under additivity the combination's log hazard ratio is
$\sum_k \beta_k(t)$, also time-varying.

A model that forces a **constant** $\beta_k$ estimates a least-false value: the
solution of the limiting score equation, which is a weighted average of
$\beta_k(t)$ with weights given by the at-risk and event distribution:

$$\bar\beta_k \;=\; \frac{\int \beta_k(t)\, w(t)\, dt}{\int w(t)\, dt}, \qquad w(t) \;\propto\; \text{events at } t \times \text{risk-set variance at } t .$$

Three consequences, and the second is the finding:

1. **This is the same least-false-parameter problem OUT-11 solved for the
   transported hazard ratio**, one level down: the constant being reported is not
   a parameter of the data-generating mechanism, so a "true constant component
   effect" does not exist and any bias computed against one is a comparison to a
   number that is not there. **The truth in section 3 is defined accordingly.**
2. **$w(t)$ depends on the study's baseline hazard, its follow-up length and its
   censoring.** So $\bar\beta_k$ **differs between studies even when $\beta_k(t)$
   is identical across them.** The constancy the bridge requires therefore fails
   **because of the summarization, not because of the science**: two studies that
   genuinely share a component effect will disagree about its constant summary if
   they have different follow-up. That is a stronger claim than the catalog makes
   and it is directly testable by holding $\beta_k(t)$ common and varying
   follow-up alone.
3. **Additivity in $\beta_k(t)$ does not imply additivity in $\bar\beta_k$**,
   because the weights are the combination's, not the components'. So a network
   in which components are exactly additive at every $t$ can appear non-additive
   in the fitted constants, and an additivity test would reject a true model.

**The bridge becomes a trajectory.** When components have different time profiles
the cross-gap contrast is a function of $t$, not a number, and RMST is the summary
that survives; the catalog says to make it an estimand rather than a derived
quantity and this design does.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference for a cross-gap regimen
contrast at a declared horizon, and the survival-probability contrast at declared
times. **Both defined on the trajectory**, so no time-constant summary is needed
to state them.

**True value** by exact integration of the generating hazards over the target
covariate law, at an order fixed by P1.

**The least-false constant is a second estimand with its own definition**, solved
by root-finding the limiting score equation per study, following OUT-11's
treatment of the same problem. **Without it, section 2 consequence 2 cannot be
tested**, because there would be no defined quantity for the two studies to
disagree about.

## 4. Data-generating mechanism, and what it makes invisible

Two subnetworks joined by a shared component, so a cross-gap contrast exists, with
components carrying different time profiles.

### Factors

| factor | levels | why |
|---|---|---|
| component time profile | constant; delayed; waning; crossing | the mechanism |
| profile discordance between the two components | same profile; different profiles | section 2 consequence 3, additivity in $t$ versus in the constant |
| **follow-up length, held with $\beta_k(t)$ common** | short; long; mixed across studies | **section 2 consequence 2, the design's sharpest manipulation** |
| cross-subnetwork information | rich; sparse | how much the bridge is doing |
| censoring | administrative; heavier early | changes $w(t)$ without changing the science |
| covariate overlap | good, poor | the population-adjustment layer |

### What the mechanism makes true, and therefore what the study cannot see

- **Additivity holds in $\beta_k(t)$ at every $t$ by construction.** So every
  apparent non-additivity is the summarization artifact of section 2 consequence
  3. **CMP-03 owns whether additivity is clinically false**, and mixing the two
  would make both uninterpretable.
- Cure and multistate structures are excluded, per the catalog's note. They are
  absent from the non-component packages too, so they are new work rather than a
  port.
- The baseline hazard is flexible (M-spline) in every arm, so nothing here is a
  baseline-misspecification result.
- Extrapolation beyond observed follow-up is required for the long-horizon RMST
  and is **reported separately from the within-follow-up horizon**, because the
  catalog notes that cure and multistate structures which would discipline that
  extrapolation are unavailable.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| time-constant component effects | current implementation | the thing under test |
| **component `aux_regression`** | the existing auxiliary-parameter regression ported to component effects, so component-specific shape parameters and spline coefficients carry the profile | the extension the catalog proposes |
| non-component ML-NMR with `aux_regression` | where the network permits it | the reference that already works, so the component layer's contribution is isolated |
| time-constant with a stratified bridge | constants estimated separately by follow-up stratum | the cheap partial fix for section 2 consequence 2 |

**The comparator that can win is the time-constant model.** If its RMST contrasts
are unbiased and nominal across the profile grid, the refuting sentence holds:
constants summarize adequately for the estimand decisions use, and the extension's
extra constancy assumptions are not worth paying. Registered as such, and it is a
live possibility because RMST integrates the trajectory and integration is
forgiving.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the RMST and survival-probability contrasts, per method per
cell, with MCSE; **the trajectory reported as a curve with a simultaneous band**,
since a bridge that is a function of time cannot be summarized at one landmark
chosen after the fact.

**The registered check for section 2 consequence 2:** the fitted constant
$\hat{\bar\beta}_k$ compared across studies that share $\beta_k(t)$ exactly and
differ only in follow-up, against the analytic least-false values. **Disagreement
matching the analytic prediction confirms that the constancy failure is
summarization**, and that is the study's most transportable finding.

**The registered check for consequence 3:** an additivity test applied to the
fitted constants in a network where additivity holds exactly in $t$. **Its
rejection rate is the false-positive rate of a test the field would run**, and it
should exceed nominal.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 1000$, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target-population RMST difference
under time-constant component effects, in cells where the two components have
**different** profiles and follow-up differs across studies.

**Decision rule.**

- Time-constant biased with coverage below 90% while the extended model is
  nominal: the extension is established, and the deliverable includes an explicit
  statement of which parameters the bridge now requires constant across
  subnetworks, which the catalog asks for and no port would supply by itself.
- Time-constant nominal across the grid: the refuting sentence holds and the
  extension is not worth its assumptions.
- **The false-positive rate of the additivity test is reported in either branch**,
  because a test that rejects true additivity is a problem regardless of which
  model wins.

## 8. Three controls, each of which can fail

**Null control.** With constant component effects, the time-constant model is
correctly specified and must be unbiased and nominal, and the extended model must
cost only precision. **A bias in the extended model here means the port is
wrong.**

**Second null control, and it isolates consequence 2.** With time-varying but
**identical** profiles across components and **identical follow-up** across
studies, the least-false constants coincide across studies, so the bridge's
constancy holds despite the truth being time-varying. **Time-constant fitting must
be approximately unbiased there.** That is the cell separating "time variation
breaks it" from "differing follow-up breaks it", and they call for different
fixes.

**Positive control.** Different component profiles, mixed follow-up, sparse
cross-subnetwork information: time-constant fitting must be biased by at least
three MCSEs. If not, the mechanism is unreachable and the study says so.

**Falsifier for the study's own headline.** The expected headline is that
time-constant summaries break the bridge. Its falsifier is the RMST estimand
itself: RMST integrates over time and may absorb the trajectory error even when
the constants are badly wrong. **If RMST is fine while the constants disagree, the
honest conclusion is that the constants are uninterpretable but the decision
quantity is safe**, which is a different and more reassuring paper.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming non-proportional hazards is unsupported in ML-NMR | Stated as supported since 0.6.0 in the header; the study is about the component layer | removed |
| Bias computed against a "true constant" that does not exist | Least-false constant defined and solved, following OUT-11 | removed |
| Time variation and differing follow-up confounded | Second null control separates them | removed |
| Summarization artifact read as non-additivity | Additivity holds in $t$ by construction; the test's false-positive rate is an outcome | removed |
| Extrapolated and within-follow-up horizons pooled | Reported separately | removed |
| A landmark time chosen after seeing the trajectory | Times declared in advance; trajectory reported as a band | removed |
| Cure and multistate agenda | Excluded per the note; named as new work | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and least-false constants | RMST and survival truths; the per-study least-false constants by root-finding | **The definition of both estimands**, and whether consequence 2 is detectable | days |
| **P2** port feasibility | Whether `aux_regression`'s structure can carry component-specific auxiliary parameters at all, in `multinma` or in a custom Stan model | **Whether the extension arm exists.** CMP-14 registered two specifications `multinma` rejected at the Stan level | days |
| **P3** follow-up separation | That the least-false constants differ detectably between the short and long follow-up levels at the chosen profiles | The follow-up levels; without separation the sharpest manipulation is inert | hours |
| **P4** unit cost | Per-fit cost of the extended model; total computed not typed | $n_{sim}$ and the grid | hours |

## 11. Cost

Flexible-baseline survival ML-NMR with auxiliary regression is among the most
expensive fits in this queue, and **SFW-06's scaling map should decide whether the
grid is affordable before this is registered.** Priced in P4.

---

## Relationship to the rest of the queue

- **OUT-11** owns the least-false parameter for a transported hazard ratio and
  supplies the root-finding treatment imported here.
- **CMP-03** owns whether strict additivity is clinically false; this design holds
  additivity true so the summarization artifact is isolated.
- **DIA-09** owns outcome families beyond the hazard ratio and would supply the
  RMST estimand machinery.
- **CMP-17** owns reconstruction error, which section 2 of that design places in
  the tail where these trajectories are least determined.
- **SFW-06** and **CMU-01** own whether these fits are affordable at all.
