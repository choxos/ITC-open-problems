# OUT-14 design: half the difference in assessment spacing, in the units of the estimand

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog corrects its own premise and the correction defines the study.**
Population-adjusted survival likelihoods *do* represent this structure: `multinma`
has supported left, right and interval censoring and left truncation since 0.6.0,
and `cpaic`'s exact survival likelihood supports delayed entry for individual and
aggregate pseudo-patient rows **when those fields are supplied.**

So this is not a likelihood problem. **It is an information problem**, and the
note is right that it cannot be solved by a better reconstruction algorithm.
Section 2 shows the resulting error has a closed form and a shape that is easy to
mistake for a treatment effect.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** pseudo individual data reconstructed from a published
right-censored Kaplan-Meier curve cannot express delayed entry or interval
censoring, because the publication reports neither, so an analysis built on it
silently reverts to complete follow-up with exactly observed event times;
assessment schedules are design features that patient-level covariate balancing
cannot correct; and once an outcome is dichotomized into an event-by-time
proportion, the follow-up length and assessment grid disappear from the reported
number.

**Refuting sentence:** *the coarsening induced by realistic assessment grids is
small relative to the estimand's scale, so treating interval-censored times as
exact is a harmless approximation.*

## 2. The mechanism: the bias is half the grid spacing, and it does not cancel

With assessments on a grid of spacing $\delta$, an event at true time $t$ is
recorded at the next assessment, so the recorded time exceeds the true one by
$U \sim \mathrm{Unif}(0,\delta)$ in expectation $\delta/2$. Treating the recorded
time as exact therefore shifts the estimated survival curve to the right by
approximately $\delta/2$.

Three consequences:

1. **Within one trial the shift is common to both arms and cancels in a hazard
   ratio.** That is why the problem is invisible in single-trial analysis and why
   it has not been noticed.
2. **Across trials with different grids it does not cancel.** The transported
   contrast between a trial on grid $\delta_1$ and one on grid $\delta_2$ carries
   a shift of approximately $(\delta_1 - \delta_2)/2$ in time units. **On the RMST
   scale that is a direct additive bias; on the survival-probability scale it is
   the local slope times that shift.** So

   $$\text{bias in RMST difference} \;\approx\; \tfrac{1}{2}(\delta_1 - \delta_2), \qquad \text{bias in } S(t) \text{ difference} \;\approx\; \tfrac{1}{2}(\delta_1-\delta_2)\,h(t)S(t).$$

   **A number an analyst can compute from two published protocols**, and nobody
   does.
3. **It looks like a treatment effect and covariate balancing cannot touch it.**
   The catalog says substituting exact times for interval-censored ones can shift
   progression-type curves in a way that resembles a treatment effect, and section
   2 says why: the shift acts on the time axis exactly as a delayed benefit would.
   **Since it arises from design rather than from patients, no weighting or
   standardization removes it**, and its magnitude is set by the protocols, not by
   the data.

**Different maximum follow-up is a separate and non-negotiable problem.** Trials
identify the survival function over different ranges, so a common summary requires
either truncation to the shortest window or extrapolation, **and each choice
changes the estimand.** The design carries both and reports them as different
estimands rather than as a sensitivity analysis.

**The binary case is the one with no method at all.** An event-by-time proportion
discards the grid and the window, so two such proportions from trials with
different windows are not comparable, **and covariate balancing cannot repair a
difference arising purely from follow-up length.** The proposed route, treating the
binary endpoint as a coarsening of a time-to-event process, is implemented here as
an arm.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference at a horizon supported by all
contributing trials, and the event risk at a common declared horizon.

**True value** by exact integration of the generating survival functions over the
target covariate law, **using the true continuous event times**, not the coarsened
ones. That distinction is the whole point: truth is a property of the process, and
the coarsening is a property of the observation.

**Anything beyond the shortest common horizon is declared extrapolation** and
reported as a separate estimand with that label, following the catalog's
instruction.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| assessment grid spacing, per trial | equal; differing by a factor of 2; by a factor of 4 | **section 2 consequence 2**, the only factor that matters |
| delayed entry | none; staggered with entry independent of prognosis; **entry dependent on prognosis** | the third level is where truncation bias, not just coarsening, appears |
| maximum follow-up difference | none; moderate; large | the estimand-choice problem |
| event process | exponential; delayed-benefit; progression-type with a steep early hazard | consequence 3, where the shift most resembles an effect |
| effect-modifier overlap | good, poor | the adjustment layer |
| endpoint form | time-to-event; binary event-by-time | the case with no method |

### What the mechanism makes true, and therefore what the study cannot see

- **The likelihoods already support the structure**, so every arm that *has* the
  fields uses them correctly. This study measures the cost of **not having** them,
  which is a data-availability result and not a software one.
- Reconstruction error itself is held at zero except in one arm; **CMP-17 owns
  it**, and confounding the two would make neither attributable.
- Assessment grids are regular. Real protocols have irregular and protocol-deviating
  schedules, which would add variance and are not simulated.
- One target population; EST-11 owns the menu.

## 5. Methods, including one that can win

| method | role |
|---|---|
| true observation process | entry times and assessment intervals supplied; the ceiling |
| standard reconstructed pseudo-IPD | exact times, complete follow-up; current practice |
| interval-censored with the grid supplied | what the likelihood can already do if the protocol is read |
| truncation to the shortest common horizon | the estimand-preserving choice |
| **binary endpoint as a coarsened time-to-event** | the missing method, built here |

**The comparator that can win is standard reconstructed pseudo-IPD.** If its bias
is below the decision threshold across realistic grid differences, the refuting
sentence holds and the recommendation is only to declare that the analysis reverted
to exact times. Registered as such.

**Supplying the grid costs nothing but reading two protocols**, so if the
interval-censored arm removes the bias, the deliverable is a workflow instruction
rather than a method.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and calibration of the RMST and event-risk contrasts per method per
cell, with MCSE; **survival-curve calibration as a band**, since section 2's shift
is a curve property and a single landmark could miss it.

**The registered mechanism check:** observed bias regressed on
$\tfrac{1}{2}(\delta_1-\delta_2)$. Slope 1 on the RMST scale confirms section 2 and
gives the analyst the correction they can compute themselves.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias in the target RMST difference under standard
reconstructed pseudo-IPD, across the grid-difference axis, for the
progression-type event process.

**Decision rule.**

- Bias tracking $\tfrac{1}{2}(\delta_1-\delta_2)$ and exceeding the decision
  threshold at realistic grid differences: **confirmed**, and the deliverable is
  the closed form plus the requirement to supply grids.
- Bias below threshold throughout: **refuted**, and the deliverable is the
  declaration requirement alone.
- **The binary-endpoint arm is reported in either branch**, because no method
  currently exists there and its performance does not depend on the time-to-event
  verdict.

## 8. Three controls, each of which can fail

**Null control.** With equal grids across trials, section 2 makes the shift cancel
exactly, so standard reconstruction must be unbiased **despite being wrong about
every individual event time.** That is the cleanest possible demonstration that the
problem is cross-trial rather than within-trial, and it is what would stop this
being reported as a general indictment of reconstruction.

**Second null control.** With an exponential event process and equal grids,
coarsening shifts the curve but leaves the hazard ratio unchanged, so a
hazard-ratio analysis must be unbiased while an RMST analysis is shifted. **The
estimand determines whether the problem appears**, and showing that is what tells
an analyst when to care.

**Positive control.** Grid spacing differing fourfold with a progression-type
process: bias must exceed the decision threshold. If not, the mechanism is
unreachable at realistic protocols and the study says so.

**Falsifier for the study's own headline.** The expected headline is that grids
must be supplied. Its falsifier is the delayed-entry arm: **if entry dependent on
prognosis produces a larger bias than any grid difference, then the study's focus
is on the smaller of two problems**, and the recommendation should lead with entry
times rather than assessment intervals.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming the likelihoods cannot represent the structure | Corrected in the header; framed as an information problem | removed |
| Within-trial and cross-trial coarsening conflated | Null control isolates them | removed |
| Reconstruction error confounded with coarsening | Held at zero except in one arm; CMP-17 named | removed |
| Follow-up differences reported as sensitivity | Reported as different estimands, per the catalog | removed |
| Irregular real-world schedules | Not simulated; stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and the analytic shift | Continuous-time truths and $\tfrac{1}{2}(\delta_1-\delta_2)$ per cell on both estimand scales | The grid; cells below Monte Carlo resolution are dropped | hours |
| **P2** realistic grid differences | Assessment spacings from published oncology protocols, so materiality is judged against the field's own numbers before the run | **The materiality verdict** | days |
| **P3** binary-coarsening identifiability | Whether a binary event-by-time proportion plus a declared window identifies enough of the time-to-event process to be placed on a common scale, and under what assumption | **Whether the missing method exists** | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | hours |

**P3 is the one that could produce a negative result worth publishing on its own**:
if the coarsening is not invertible under any defensible assumption, then binary
endpoints from trials with different windows are simply not comparable, and saying
so with a proof is more useful than a method that hides the assumption.

## 11. Cost

Parametric survival fits; modest. Priced in P4.

---

## Relationship to the rest of the queue

- **CMP-17** owns reconstruction error; **OUT-13** owns digitization uncertainty.
- **OUT-11** owns non-proportional hazards, and section 2 consequence 3 says the
  coarsening artifact mimics exactly the delayed-benefit pattern OUT-11 studies;
  **the two must be read together or a grid artifact could be reported as
  non-proportionality.**
- **DIA-09** owns the outcome families and RMST estimands.
- **MIS-02** owns censoring-weighted transport.
