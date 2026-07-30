# QBA-23 design: dropped replicates hide the problem the analysis was for

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog corrects the entry's framing in three ways and each shapes the design.
**The count of eleven layers is not defensible**: the list names about ten categories and
**conflates sampling uncertainty, model uncertainty, nonidentified sensitivity
assumptions, deterministic numerical error, Monte Carlo estimation error and downstream
decision-model uncertainty.** **Nested resampling and a joint Bayesian model are not the
only credible options.** And **only the resampling route has a failed-replicate problem
at all.**

The note requires a narrowly defined propagation benchmark rather than propagating every
conceivable layer. **This design takes the failed-replicate problem as its centre**,
because section 2 shows it is the one that inverts the analysis's purpose.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** nested bootstrap cost is multiplicative in replicates, grid
points and model fits; **where failed replicates are dropped the reported interval is
conditional on the weighting having succeeded, which understates exactly the positivity
problem the sensitivity analysis was meant to expose**; and there is no accepted way to
represent failures inside an interval.

**Refuting sentence:** *failure rates are low enough at the settings a sensitivity
analysis explores that conditioning on success is immaterial, and the cost problem is the
only real one.*

## 2. The mechanism: failures are informative and dropping them is selection

A nested bootstrap over a bias grid resamples, re-solves the calibration and refits at
each grid point. **Failures are not random.** Calibration fails when the target moments
lie outside the resample's convex hull, which is exactly OVL-02's feasibility condition,
and **that becomes more likely as the bias grid pushes the implied target further from
the source.** Three consequences:

1. **The failure rate rises with the sensitivity parameter**, so the surviving replicates
   at the far end of the grid are a selected subset in which the weighting happened to
   work. **The interval there is conditional on success and is narrower than the
   unconditional one**, so the sensitivity analysis looks most reassuring exactly where
   it should be least.
2. **The failure map is itself the finding.** Reporting where on the bias grid the
   analysis stopped being computable tells a reader more than an interval computed on
   what remained. **Nothing reports it.**
3. **Cost is multiplicative only where every outer replicate must re-solve.** Which
   quantities must be refitted and which can be reused is an implementation question, so
   **the cost claim is conditional and the design measures it rather than asserting it.**
   Warm starts, surrogate models over the bias grid and analytic approximations are
   candidates, and each is validated against the full nested computation rather than
   assumed adequate.

**Numerical and Monte Carlo error are not uncertainty layers.** Integration error is a
deterministic approximation and Monte Carlo error is an estimation artifact; **both are
reported as computational diagnostics beside the statistical uncertainty rather than
inside it**, which is the entry's own instruction and CMU-01's finding.

## 3. Estimand, with its true value defined

**Primary.** The unanchored target-population marginal treatment effect, by quadrature at
an order fixed by P1.

**The derived estimands are the propagation's properties**: interval coverage,
**unconditional** and **conditional on all replicates succeeding**, so consequence 1's
gap is visible; Monte Carlo error of the propagation itself; failed-replicate rate as a
function of the bias parameter; and runtime.

**The identified set is a fourth output** where a non-negligible fraction fail: **an
interval computed on survivors is not the right object there**, and returning a set is
the alternative the entry names.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| overlap | good, moderate, poor | drives the failure rate |
| sensitivity-grid size | 5, 25 points | the cost multiplier and the failure exposure |
| target-law uncertainty | exact; reconstructed | one propagated layer |
| integration accuracy | two orders | the deterministic error reported beside |
| bias-parameter range | narrow; wide | consequence 1's axis |

**Layers are declared and limited.** The design propagates weight estimation, outcome
model and target-law uncertainty, **and states which layers are held fixed**, which is
the entry's own requirement and the reason the eleven-layer framing is not adopted.

### What the mechanism makes true, and therefore what the study cannot see

- **One estimator and one propagation question**, per the note.
- Pseudo-IPD reconstruction error is **held at zero**; CMP-17 and OUT-13 own it, and the
  entry lists it as conventionally treated as negligible without being quantified, which
  those studies do.
- Downstream decision-model uncertainty is a different category and is excluded.
- **The failure mechanism is calibration infeasibility**, which OVL-02 makes exactly
  computable, so failures here are diagnosable rather than mysterious.

## 5. Methods, including one that can win

| scheme | role |
|---|---|
| nested bootstrap | the expensive reference |
| parametric bootstrap | cheaper, different failure profile |
| **modular Monte Carlo** | layers propagated separately and combined |
| sandwich or delta method where available | the analytic route the entry says also applies |
| **nested bootstrap with a failure map and an identified set** | the proposal |

**The comparator that can win is the modular scheme.** If it matches the nested
bootstrap's coverage at a fraction of the cost, **the multiplicative-cost problem is
avoidable by not nesting**, which is the cheapest possible resolution. Registered as
such.

## 6. Performance measures, MCSE, and $n_{sim}$

Interval coverage, unconditional and success-conditional; **failed-replicate rate against
the bias parameter**; Monte Carlo error of the propagation; runtime; and, for the
identified-set arm, containment and width.

**The registered gap measure**, which is consequence 1: the difference between
unconditional and success-conditional coverage, **reported across the bias grid.** A
widening gap toward the grid's edge is the study's central figure.

$n_{sim} = 1000$ outer replicates per cell; the inner counts are set by P2 and their own
Monte Carlo contribution is reported, since **a propagation scheme whose own error is
comparable to the effect it propagates is measuring itself.**

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The gap between unconditional and success-conditional coverage at
the far end of the bias grid, at poor overlap.

**Decision rule.**

- Gap material and widening with the bias parameter: **confirmed**, and the deliverable
  is the failure map plus the identified-set output.
- Gap negligible because failures are rare: **refuted**, and the cost question is the
  only one, which the modular comparison answers.
- Failures so frequent that no interval is computable at the grid's edge: **that is the
  strongest form of the finding** and the deliverable is that the grid's usable range
  must be reported.

## 8. Three controls, each of which can fail

**Null control.** At good overlap with a narrow bias grid, failures must be absent and
every scheme must agree. **Failure there is an implementation fault.**

**Second null control.** With calibration feasibility guaranteed by construction, so no
replicate can fail, the two coverages must coincide identically. **That isolates the
selection mechanism from every other difference between schemes.**

**Positive control.** Poor overlap with a wide bias grid: the failure rate must rise
detectably along the grid. **If it does not, consequence 1's selection is unreachable.**

**Falsifier for the study's own headline.** The expected headline is that dropping
failures inverts the analysis. Its falsifier is direction: **if success-conditional
coverage is *lower* rather than higher, the selection does not produce false reassurance
and the concern is misdirected.** Both directions are reachable in principle and the
design reports which occurs rather than assuming.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Adopting an indefensible layer count | Layers declared and limited; the conflation named | removed |
| Nested resampling and joint Bayes as the only options | Four schemes carried, per the catalog | removed |
| Numerical and Monte Carlo error folded into inferential uncertainty | Reported beside it as diagnostics | removed |
| Cost asserted as multiplicative | Measured; reuse and warm starts tested | removed |
| Failures dropped silently | Failure map and identified set are outputs | removed |
| The propagation's own Monte Carlo error | Reported | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target truth per cell | The definition of truth | hours |
| **P2** inner counts | Resample counts at which each scheme's own Monte Carlo error is below a declared fraction | The budget, and whether any scheme is measuring itself | days |
| **P3** failure reachability | The failure rate across the planned grid, computed from OVL-02's feasibility program before any fitting | **Whether the primary outcome has a signal** | hours |
| **P4** unit cost | Nested cost with and without reuse; total computed not typed | The grid | days |

## 11. Cost

**The most expensive propagation is the reference and must be run at least once per cell
to score the cheaper ones.** That is unavoidable and is why the grid is small.

---

## Relationship to the rest of the queue

- **OVL-02** supplies the feasibility program that diagnoses the failures.
- **CMU-01** owns integration error as a computational diagnostic and shares the
  reporting principle.
- **CMP-17** and **OUT-13** own reconstruction error, held at zero here.
- **DEC-11** owns which layers belong in an interval at all; this design takes that
  taxonomy as given and asks how to propagate what does.
- **QBA-22** owns the joint bias region whose grid this propagation runs over.
