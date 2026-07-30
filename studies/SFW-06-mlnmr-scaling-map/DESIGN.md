# SFW-06 design: where ML-NMR stops being affordable, in the right currency

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

This is a benchmark, not an inferential simulation, and it has to be honest about
that. Two auditors read the same issue tracker and reached different conclusions:
the literature auditor took issue #66 as evidence that users hit prohibitive
runtimes; GPT-5.6 Sol observed that release 0.9.1 already reduced the default
integration burden and added integration checking. **Both readings are compatible
with the facts because nobody has measured where the boundary is.** That is the
whole gap, and it is measurable.

Section 2 argues the field has also been measuring the wrong thing.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** ML-NMR cost grows with total integration rows in a
way that is not amortizable across iterations, and at some characterizable scale
this turns computation into a methodological constraint on the sensitivity
analyses the rest of the agenda demands.

**Refuting sentence:** *after 0.9.1's reduction of the default integration
burden, the binding constraint at realistic scales is sampler mixing rather than
integration arithmetic, so integration rows are the wrong axis and a scaling map
built on them would mislead.*

**The refutation is section 2's own prediction under one of two regimes**, so the
study is built to tell them apart rather than to confirm either.

## 2. The mechanism, and why wall clock is the wrong metric

Cost per gradient evaluation is roughly linear in total integration rows $R$ and
in parameter dimension $p$; the number of gradient evaluations per iteration is
$2^{\tau}$ for realized treedepth $\tau$; so

$$\text{wall clock} \;\approx\; c \cdot R \cdot p \cdot 2^{\bar\tau} \cdot n_{\text{iter}} .$$

Integration nodes and design data are reused across iterations, but the
parameter-dependent likelihood terms are not, so the $R$ factor does not
amortize. That is the catalog's claim and it is correct.

**But $\bar\tau$ and $n_{\text{iter}}$ are not constants, and this is the point
the tracker discussion misses.** What an analyst needs is not iterations per hour
but **effective draws per minute**:

$$\text{ESS/min} \;=\; \frac{\mathrm{ESS}(n_{\text{iter}})}{\text{wall clock}} .$$

Two consequences:

1. **A change that halves wall clock while doubling treedepth is not an
   improvement**, and reporting either quantity alone cannot tell. A reduction in
   default integration points reduces $R$ and can worsen the geometry, so 0.9.1's
   "much faster to run by default" and issue #66's 24 hours are not in
   contradiction and cannot be adjudicated in the currency both are quoted in.
2. **The binding constraint is whichever of $R$ and $\bar\tau$ dominates**, and
   which one that is should switch somewhere in the design space. **Locating that
   switch is the deliverable**, and it is what turns two incompatible readings
   into one map.

**Integration error is the constraint's other side.** Fewer rows are cheaper and
less accurate, so the honest axis is not cost against rows but cost against rows
*at a fixed integration error*. OUT-11 measured that error directly on production
fits, at 256 and 512 points, and those measurements are imported rather than
repeated.

## 3. Estimand, with its true value defined

This study estimates computational quantities, so "truth" means something
different and has to be said plainly.

**Primary.** ESS per minute for the bulk and tail of the decision contrast's
posterior, at a stated hardware configuration and concurrency.

**Its true value is the quantity itself**, measured, with the measurement's own
error characterized: repeated timings of an identical configuration give a
distribution, and every reported figure carries its spread across repeats. **A
single timing is not a measurement**, which is the error OUT-11 made when it
projected an arm's cost at 1.93× from two replicates and had to correct it to
1.13-1.15× at 71 gaps once contention from concurrent probes was excluded.

**Second estimand:** the configuration frontier, defined as the set of
configurations meeting declared thresholds on elapsed time, convergence and
Monte Carlo error simultaneously. A configuration that finishes fast and fails
R-hat is not on the frontier, and reporting speed without convergence is the
mistake this design exists to avoid.

## 4. Data-generating mechanism, and what it makes invisible

The "data" are model configurations. Each cell is fitted to simulated networks
whose scientific properties are held constant so that only the computational
factors vary.

### Factors

| factor | levels | why |
|---|---|---|
| integration points per aggregate study | 32, 64, 128, 256, 512 | the axis in dispute |
| aggregate studies | 4, 10, 25 | total rows is the product, and the product is what section 2 says matters, so both factors are needed to test whether only the product matters |
| covariate dimension | 2, 5, 10 | $p$, and it also drives the copula construction cost |
| outcome model | normal identity; binomial logit; survival M-spline | the survival likelihood is the expensive one and is what OUT-11 ran |
| random effects | fixed; random treatment effects | issue #66's report is a random-effects model |
| backend | rstan; cmdstanr if available | issue #29's request, tested rather than assumed to help or not |

**Total rows appears as a derived quantity and its sufficiency is a registered
hypothesis**: if cost depends on integration points and study count only through
their product, the map has one axis instead of two, which is a materially
different deliverable.

### What the mechanism makes true, and therefore what the study cannot see

- One machine, one concurrency, stated. **Every figure is wall clock at that
  concurrency and is not core time.** Results transfer as ratios, not as
  absolutes, and the paper must say so rather than publishing hours as if they
  were portable.
- Networks are synthetic and well behaved. A pathological posterior costs more
  than any configuration factor here, and the map does not predict it.
- Package versions are pinned and recorded. `multinma` 0.9.1 and 0.9.1.9002 are
  different estimators, and a runtime that moves between them is a finding rather
  than noise.
- No claim is made about a defect. **No maintainer statement concedes a runtime
  bug**, and the catalog is explicit that this is a scaling boundary to document,
  not a defect to concede. The paper's framing follows that.

## 5. Methods, including one that can win

The "methods" are the configurations, plus the modeling of them:

| arm | specification | role |
|---|---|---|
| baseline | package defaults at 0.9.1 | what a user gets without choosing |
| swept configurations | the grid above | the map |
| runtime prediction model | log ESS/min regressed on log rows, $p$, model family, structure, with interactions | **the deliverable a user consults before starting** |
| cmdstanr backend | same configurations, different backend | issue #29, measured |

**The comparator that can win is the baseline.** If package defaults sit inside
the feasible frontier across the whole realistic range, the caution is material
only at scales few analyses reach, GPT-5.6 Sol's reading is correct, and the
paper says so. Registered as such.

## 6. Performance measures and repeat count

Wall clock; ESS bulk and tail per minute; realized treedepth; divergence **rate**,
not count, since OUT-11 registered `divergent == 0` and that criterion would have
failed every fit in a production run; R-hat; and the integration error at each
row count, imported from OUT-11's measurements where the configuration matches
and measured where it does not.

**Every configuration is timed on at least 5 repeats** and reported with its
spread. The repeat count is set by P2 from the observed timing variance, not
chosen. **Timings are taken with no other job on the machine**, and that is
enforced rather than intended, because contention from this program's own probes
is what produced OUT-11's wrong cost projection.

There is no $n_{sim}$ in the usual sense; the replicate unit is a timed fit.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The feasible frontier: configurations meeting the declared
elapsed-time, convergence and Monte Carlo error thresholds simultaneously, and
where it sits relative to the configurations a realistic sensitivity program
needs.

**Decision rule.**

- A realistic sensitivity program (a declared number of prior, integration and
  structure variations, taken from this program's own OUT-11 and CMP-14
  sensitivity arms rather than invented) falling outside the frontier at
  achievable scales **confirms** the constraint is material.
- The same program fitting inside the frontier **refutes** it at those scales and
  the paper reports the boundary's location as the useful output.
- **The switch point between integration-dominated and geometry-dominated cost is
  reported in either branch**, because that is what tells a user which knob to
  turn and it does not depend on the verdict.

## 8. Three controls, each of which can fail

**Null control.** At the smallest configuration, cost must be dominated by fixed
overhead (compilation, setup) and independent of integration rows. If cost scales
with rows even there, the timing harness is measuring something other than the
model.

**Positive control.** At the largest configuration, cost must scale approximately
linearly in total rows at fixed treedepth. **The linearity is section 2's claim
and it is checkable**, so it is checked rather than assumed; a nonlinearity would
mean the cost model in section 2 is wrong and the prediction model must be
rebuilt rather than fitted anyway.

**Falsifier for the study's own headline.** The expected headline is that
integration rows are the binding axis. Its falsifier is a cell where ESS/min
*falls* as integration points *increase* while wall clock rises less than
linearly, which would mean the geometry improved with more accurate integration
and that rows buy mixing as well as cost. **That is a real possibility and the
design would miss it entirely if only wall clock were recorded**, which is why
ESS/min is primary.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Wall clock reported as the measure of cost | ESS/min is primary; wall clock is a component | removed |
| A single timing treated as a measurement | 5+ repeats with spread; count set by P2 | removed |
| Contention from concurrent jobs | Enforced exclusive timing; this program's own history is the reason | removed |
| Speed reported without convergence | Frontier requires convergence and MCSE thresholds jointly | removed |
| Absolutes read as portable | Hardware and concurrency stated; results framed as ratios | disclosed |
| Framed as a package defect | Framed as a scaling boundary, per the catalog | removed |
| Integration cost compared at unequal accuracy | Cost reported at fixed integration error, using OUT-11's measurements | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** timing harness validation | That the harness reproduces OUT-11's already-measured production costs at matching configurations, within its stated spread | **Whether any number here is trustworthy.** An independent measurement that disagrees with a known one is the cheapest possible check and this program has a known one | hours |
| **P2** repeat count | The timing variance at a mid-grid configuration, from which the repeat count follows | The repeat count and therefore the budget | hours |
| **P3** grid feasibility | Whether the largest configurations finish at all within a declared cap, and what to do with those that do not | **The grid.** A cell that does not finish is a result and must be recorded as censored rather than dropped | days |
| **P4** total budget | The grid's total cost, computed from P2 and P3, not typed | The grid | hours |

**P3 is the one with a trap.** The largest cells are the interesting ones and are
the ones most likely to be abandoned mid-run; a benchmark that silently drops them
reports that everything is fast.

## 11. Cost

Unusually, cost is the subject rather than a constraint, and the study's own
budget is the largest single line: the grid times the repeat count, with the
largest cells running for many hours each. Computed in P3 and P4, capped, and the
cap's consequences stated. No total quoted here.

---

## Relationship to the rest of the queue

- **CMU-01** owns ML-NMR integration cost for flexible survival models
  specifically, which is the most expensive corner of this map; if both run, this
  study supplies the map and CMU-01 the corner.
- **OUT-11** supplies validated production timings and integration-error
  measurements, imported rather than repeated.
- **CMU-03** (SBC) is the concrete example of a program whose feasibility this
  map decides, and it is one of the sensitivity programs used in section 7.
- **SFW-08** and **SFW-13** own other software-side questions in the same family.
