# MOD-09 design: measuring the premise everyone repeats

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The auditors split here and the disagreement stands. The literature auditor read
the adoption gap as open; GPT-5.6 Sol held that partial IPD plus suspected
effect-modifier imbalance is not sufficient to declare ML-NMR the default, and
that **the absence of a designated default is not itself an unresolved
methodological problem.** The catalog's note agrees: the universal question would
make a weak study.

So the design does not try to declare a default. It does two things the entry
identifies as genuinely missing: **an explicit decision map over a few measurable
factors**, and a measurement of the entry's own central premise. That premise,
that ML-NMR is harder to specify, fit, diagnose and explain, is described as
**plausible and widely repeated but unmeasured; neither auditor found a study of
it.** A repeated unmeasured premise is exactly the kind of thing this program
exists to test.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** ML-NMR avoids the aggregation bias of aggregate-data
meta-regression and now extends to general likelihoods, yet practice remains
dominated by MAIC and STC because ML-NMR is harder to specify, fit, diagnose and
explain, so the barrier is practical rather than theoretical.

**Refuting sentence:** *the fitting burden is small at realistic network sizes, so
the barrier is not practical, and the adoption gap has another explanation this
study cannot reach.*

**Both halves are testable, but only one is a simulation.** Fitting burden is
measurable. Specification and communication burden are not, and section 4 says so
rather than pretending a simulation can settle them.

## 2. The mechanism: what switching does and does not buy

ML-NMR fits an individual-level model and integrates it over each aggregate
study's covariate distribution, so it avoids aggregation bias by construction:

$$\mathbb{E}[Y_j] \;=\; \int \mu(x;\theta)\,dF_j(x) \quad\text{rather than}\quad \mu(\bar x_j;\theta).$$

The gap between those two is exactly the aggregation bias, and it is zero when
$\mu$ is linear in $x$ and grows with curvature and with $\mathrm{Var}_j(x)$.
**That gives the first axis of the decision map analytically**: the benefit of
ML-NMR over methods that centre on means is a function of link curvature and
within-study covariate spread, both of which an analyst can compute before
choosing.

Three further consequences:

1. **Switching buys coherence rather than assumption relief.** Conditional
   constancy, shared effect-modifier assumptions, overlap and target relevance
   remain only partially testable inside ML-NMR, and the psoriasis application
   assessed those assumptions rather than eliminating them. **So a decision map
   whose axis is "assumptions relieved" would be empty**, and the map's axes must
   be things that actually differ.
2. **The axes that do differ are measurable**: network connectivity, IPD
   availability and placement, target-distribution information, overlap, and
   outcome-model curvature. Those are the sketch's factors and they are all
   computable from the data an analyst holds before fitting.
3. **Fitting burden is measurable on the same grid at no extra cost**, because
   every cell is fitted anyway. Convergence failures, refits, integration-check
   failures, runtime and the number of tuning decisions taken are recorded
   per fit. **That converts the central premise into evidence without a separate
   study.**

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment contrast, by quadrature at
an order fixed by P1.

**The decision map is the derived deliverable:** for each region of the factor
space, which method has the lower RMSE against the declared estimand, with the
region boundaries estimated rather than asserted. **RMSE, not bias**, fixed now,
because a method that removes bias and triples the interval has not helped and
choosing the summary afterwards is the failure this rule prevents.

**Fitting burden is a second, separately reported set of outcomes** and is not
mixed into the map. A method that wins on RMSE and costs ten times as much is a
different recommendation from one that wins and is free, and pooling them into a
single score would bury the trade-off the entry is about.

## 4. Data-generating mechanism, and what it makes invisible

### Factors, chosen because an analyst can evaluate them before fitting

| factor | levels | why |
|---|---|---|
| network connectivity | two-trial pair; star; connected network | where ML-NMR's structure can pay |
| IPD availability | one trial; half; all | the classic axis |
| target-distribution information | full joint law; marginals only; marginals with borrowed correlation | what ML-NMR's integration needs and MAIC does not |
| effect-modifier overlap | good, poor | the standard axis |
| link curvature and within-study spread | low, high | **section 2's analytic axis** |
| outcome-model misspecification | correct; misspecified | so the map is not built only where ML-NMR is correctly specified |

### What the mechanism makes true, and therefore what the study cannot see

- **Specification and communication burden are not simulated.** The entry's
  premise has three parts and this design measures one. **Saying so is the
  point**: a study that measured fitting burden and reported it as "the premise is
  confirmed" would overclaim on exactly the sentence the auditors flagged as
  unsourced.
- ML-NMR is fitted by a competent user with a fixed protocol, so the burden
  measured is a floor. **Real burden includes the analyst's learning curve**,
  which no simulation reaches.
- The decision map's boundaries are estimated on this generator. **DIA-08 owns
  the fact that a generator can decide a comparison**, and this design's map
  inherits that limitation directly; if DIA-08 has run, its departures are added
  as a robustness arm.
- One outcome type per arm of the design; the general-likelihood survival
  extension is carried at one setting only, since it is the most expensive fit
  here.

## 5. Methods, including one that can win

MAIC, STC with marginalization, ML-NMR, all at standard specifications with a
declared tuning protocol.

**The comparator that can win is MAIC.** If it matches ML-NMR on RMSE across most
of the realistic factor space, then the adoption gap is rational rather than a
barrier, GPT-5.6 Sol's reading is supported, and the deliverable is a map showing
the small region where switching pays. Registered as the outcome most likely to
overturn the expected headline.

**No method is declared a default in any branch.** The entry's own dispute is
about whether a default is even the right object, and this design's output is a
map plus a burden measurement, which both auditors' readings can use.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, RMSE, coverage and interval width per method per cell, with MCSE.

**Fitting-burden measures**, recorded per fit and reported separately: wall clock;
convergence failures; refits under the sampler policy, with the divergence
criterion as a **rate** not a count, following OUT-11; integration-check failures;
and the count of tuning decisions the protocol required. **Every one is objective
and none of them measures how hard the method is to explain.**

**The registered aggregation-bias check:** observed MAIC-versus-ML-NMR difference
regressed on section 2's analytic aggregation-bias term. Agreement confirms the
map's curvature axis is the operative one; disagreement means the map is being
driven by something else and the axis is relabelled rather than kept.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 1000$, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The estimated boundary in the (curvature × target-information
× IPD availability) space at which ML-NMR's RMSE falls below MAIC's.

**Decision rule.**

- A boundary estimable with non-overlapping intervals: **the map is the
  deliverable**, expressed in quantities an analyst can compute before fitting.
- No boundary, ML-NMR better everywhere: the adoption gap is a barrier and the
  burden measurement says how large a barrier.
- No boundary, MAIC competitive everywhere in the realistic region: **the
  adoption gap is rational**, which is a publishable and currently unsupported
  claim.

**Fitting burden is reported alongside in every branch**, because the entry's
central unsourced premise deserves an answer regardless of which method wins.

## 8. Three controls, each of which can fail

**Null control.** With a linear link, no within-study spread and full target
information, section 2 makes the aggregation bias **exactly zero**, so MAIC, STC
and ML-NMR must agree to Monte Carlo error. **A difference there is not a method
difference; it is an implementation difference**, and it invalidates the map.

**Second null control.** With all trials supplying IPD, there is no aggregate arm
to integrate over, so ML-NMR reduces to an individual-level regression and must
match STC. **Cheap, exact, and it catches a whole class of integration error.**

**Positive control.** With high curvature, high within-study spread and
marginals-only target information, ML-NMR must beat MAIC by a detectable margin.
If it does not, the method's stated advantage is unreachable in this generator
and the map cannot be built.

**Falsifier for the study's own headline.** The expected headline is that a usable
decision map exists. Its falsifier is misspecification: **if the map's boundary
moves substantially between the correctly specified and misspecified arms, then
the map depends on something an analyst cannot check, and the honest deliverable
is that no pre-fitting criterion exists.** That arm is in the grid for this
reason.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Declaring a default, which one auditor disputes is even the right object | No default declared in any branch | removed |
| Measuring fitting burden and reporting it as the whole premise | Three parts named; one measured; stated in the abstract | removed |
| A map built only where ML-NMR is correctly specified | Misspecification arm, and it is the falsifier | removed |
| Bias used as the comparison summary | RMSE fixed before the run | removed |
| Burden and performance pooled into one score | Reported separately | removed |
| Map's dependence on the generator | DIA-08 named; its departures added as a robustness arm if available | disclosed |
| Learning curve and communication burden | Not simulated; stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and aggregation-bias term | Target truths and section 2's analytic aggregation bias per cell | **The curvature axis.** If the analytic term is negligible across realistic levels, the map has no axis there | hours |
| **P2** boundary estimability | Whether an RMSE crossing exists in the factor space at $n_{sim}$, by pilot | **Whether a map exists to estimate** | days |
| **P3** tuning protocol | A declared, fixed ML-NMR fitting protocol, written before any result, so burden is measured against a fixed procedure | The burden measurement's validity | hours |
| **P4** unit cost | Per-fit cost across the grid; total computed not typed; checked against SFW-06's frontier if available | The grid | hours |

## 11. The case-study half

The queue records this as simulation **plus case study**, and the case is what
tests the map rather than illustrating it: reanalyze a published network in which
MAIC, STC and ML-NMR give materially different answers, and check whether the
simulation-derived criteria **predict** which method the map favors there.
**A map that cannot explain a known disagreement is not a map**, and this is the
only part of the design that can find that out.

## 12. Cost

ML-NMR across a six-factor grid at 1000 replicates. **SFW-06's scaling map should
decide feasibility before registration**, and P4 checks against it.

---

## Relationship to the rest of the queue

- **DIA-06** owns failure signatures across families on the overlap axis; this
  design owns the pre-fitting decision map. If both run they share a generator.
- **DIA-08** owns whether a generator decides a comparison, which this map
  inherits.
- **SFW-06** owns ML-NMR runtime and bounds this design's feasibility.
- **CMU-02** and **IDN-06** own the diagnostics that would populate the
  "model credibility" axis the entry names but this design cannot measure.
- **EST-11** owns the target-declaration discipline the map's estimand assumes.
