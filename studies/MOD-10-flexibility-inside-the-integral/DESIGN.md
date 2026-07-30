# MOD-10 design: a flexible surface integrated over a target it was not fitted on

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

ADJ-04 owns flexible standardization and its interval in the **pairwise** case, and
finds that weighted conformal degrades on the same axis as the overlap failure it
repairs. **This design is the network case**, where the entry names a different
binding constraint: embedding either device inside a hierarchical multi-study
likelihood with numerical integration over an aggregate-data target **adds
computational burden on top of an already heavy ML-NMR fit**, which is a
research-engineering barrier rather than a conceptual one.

The entry also narrows a claim the design must carry precisely. **Reading a fitted
surface as evidence of causal effect modification is invalid when it rests on feature
importance alone**, but **conditional treatment-effect heterogeneity can carry a
causal interpretation under a randomized or otherwise identified design.** So the
prohibition is on the inferential route, not on the quantity.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** neither BART nor a Gaussian-process interaction surface
has been developed for network population adjustment; a flexible surface is estimated
where the source trials have data and then integrated over a target that may lie
partly outside the observed support, so added flexibility can amplify extrapolation
error instead of removing bias; and Gaussian-process scaling collides with the
integration burden already present.

**Refuting sentence:** *at the overlap levels real analyses face, the flexible surface
is integrated almost entirely over supported regions, so the amplification is
hypothetical and the only real barrier is compute.*

## 2. The mechanism: two error sources that move in opposite directions with flexibility

The target contrast is $\int \hat\tau(x)\,dF_T(x)$. Split the integral at the source's
support boundary:

$$\int_{\mathcal{S}} \hat\tau\,dF_T \;+\; \int_{\mathcal{U}} \hat\tau\,dF_T .$$

Three consequences:

1. **Flexibility reduces the first term's bias and can increase the second's.** Inside
   the support a flexible surface fits a nonlinear $\tau$ that a parametric form
   misses; outside it, the flexible surface's value is set by its prior or kernel
   rather than by data, and a parametric form at least extrapolates a stated shape.
   **So the net effect is a difference of two terms with opposite signs**, and which
   dominates depends on $F_T(\mathcal{U})$ and on how nonlinear $\tau$ is inside.
   **That is the design's central prediction and it makes the refuting sentence a
   quantitative question rather than a rhetorical one.**
2. **The crossover is locatable.** There is a share of unsupported target mass at
   which flexibility stops paying, and it depends on the nonlinearity. **Reporting
   that surface is the deliverable**, and it is what an analyst would consult.
3. **The integration burden multiplies, it does not add.** ML-NMR integrates the
   individual model over each aggregate study's covariate distribution at every
   likelihood evaluation. A Gaussian-process surface costs $O(n^3)$ to fit and
   $O(n)$ or more per prediction, **so the product with the integration points is the
   binding term**, and sparse or inducing-point approximations reduce it. **No
   approximation creates support**, which is the entry's own sentence and the reason
   compute is not the whole problem.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect from a network fit, by
quadrature over the true target law at an order fixed by P1.

**The extrapolation share is a second reported quantity**: the fraction of the target
integral contributed by mass outside the source support, computed exactly since the
generating law is known. **It is what indexes the crossover in consequence 2.**

**No causal effect-modification claim is made from any fitted surface.** Where the
design's randomization identifies conditional heterogeneity, that is stated as coming
from the design; feature importance is not reported as evidence of modification at
all.

## 4. Data-generating mechanism, and what it makes invisible

Network with IPD and aggregate studies, so the integration step is real rather than
simulated away.

### Factors

| factor | levels | why |
|---|---|---|
| interaction nonlinearity | linear; moderate; threshold | consequence 1's first term |
| source-target overlap | good, moderate, poor | the usual axis |
| **share of target mass outside observed support** | 0%, 5%, 20% | **consequence 1's second term, set directly** |
| integration points | 64, 256 | consequence 3, and whether more points buy accuracy against a wrong surface |
| network size | 6, 12 studies | the burden's other multiplier |

### What the mechanism makes true, and therefore what the study cannot see

- **One flexible device, not two.** The note orders this after simpler overlap work,
  and ADJ-04's note requires narrowing to one primary comparison for the same reason.
  **BART is chosen** for consistency with ADJ-04, so the two designs' results compose;
  Gaussian processes are named, and their cost is characterized in P3 rather than
  their performance.
- Support is well defined because covariates are continuous and low-dimensional.
- **Cross-fitting separates discovery from inference and does not repair
  extrapolation**, which is stated rather than assumed away.
- The target law is known exactly. **CMP-15 and OVL-03 own its reconstruction**, and
  including it would confound the flexibility question with the reconstruction one.

## 5. Methods, including one that can win

| method | role |
|---|---|
| parametric ML-NMR | the baseline |
| spline ML-NMR | flexibility with a transparent form |
| **BART surface inside the ML-NMR likelihood** | the extension |
| BART with a support diagnostic gating the integral | the honest version, flagging where the surface extrapolates |
| BART with sparse approximation | consequence 3's cost route, characterized |

**The comparator that can win is parametric ML-NMR.** Consequence 1 says flexibility
is a net gain only when the supported-region nonlinearity outweighs the unsupported
extrapolation, and at 20% unsupported mass it should lose. **Registered as such, and
the crossover is the result whichever way it falls.**

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of the target effect per method per cell, with MCSE;
**bias decomposed at the support boundary**, so consequence 1's two terms are separate
rather than summed.

**Computation**: wall clock and effective draws per minute, following SFW-06's finding
that wall clock alone cannot tell an improvement from a geometry change. **Reported at
fixed integration accuracy**, since a cheaper fit at fewer points is not cheaper at
matched accuracy.

**Support-diagnostic discrimination** for scenarios with unacceptable extrapolation
error, which is the sketch's second question and is scored as a classifier following
DIA-03.

$n_{sim} = 500$ per cell, low because each replicate is a BART surface inside an
ML-NMR fit; the count is derived from P4's cost rather than chosen.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the flexible surface against parametric ML-NMR, decomposed
at the support boundary, across the unsupported-mass axis with threshold nonlinearity.

**Decision rule.**

- A crossover: flexibility better at low unsupported mass and worse at high:
  **consequence 1 confirmed**, and the deliverable is the crossover surface plus the
  gating diagnostic.
- Flexibility better throughout: **the refuting sentence holds** and the barrier is
  compute alone, which P3 quantifies.
- Flexibility worse throughout: the supported-region gain does not materialize at
  these nonlinearities, and the honest conclusion is that the parametric form is
  adequate for network PAIC.

## 8. Three controls, each of which can fail

**Null control.** With a linear interaction and no unsupported mass, parametric ML-NMR
is correctly specified and must be unbiased and most efficient; **the flexible arm must
cost only precision.** A bias there is a fitting artifact.

**Second null control.** With zero unsupported mass at every nonlinearity,
consequence 1's second term is absent, so **flexibility must be weakly dominant.**
That anchors the crossover: any point where flexibility loses must have unsupported
mass behind it.

**Positive control.** 20% unsupported mass with a threshold interaction: the flexible
arm's unsupported-region bias must exceed its supported-region gain. **If it does not,
the amplification the entry warns about is unreachable.**

**Falsifier for the study's own headline.** The expected headline is that flexibility
inside the integral is a trade-off with a locatable crossover. Its falsifier is
consequence 3: **if the fit is not affordable at realistic network sizes and
integration orders, the trade-off is moot and the finding is an engineering one.**
P3 answers that before the comparison is run, so the study does not spend its budget
establishing a crossover for a method nobody can fit.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reading a fitted surface as causal effect modification | Prohibited; the entry's narrowing about identified designs carried | removed |
| Two flexible devices at once | One, matching ADJ-04 so the results compose | removed |
| Compute compared at unequal integration accuracy | Reported at fixed accuracy, following SFW-06 | removed |
| Bias summed across the support boundary | Decomposed | removed |
| Reconstruction error confounded with flexibility | Target law known; owners named | removed |
| Cross-fitting credited with repairing extrapolation | Stated that it does not | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target truth per cell | The definition of truth | hours |
| **P2** unsupported-mass construction | Target laws with a declared share outside source support, shared with ADJ-04 | The grid | days |
| **P3** feasibility and cost | Whether a BART surface fits inside the ML-NMR likelihood at realistic sizes, and at what cost, checked against SFW-06's frontier | **The falsifier, and whether the study runs at all** | days |
| **P4** $n_{sim}$ | Derived from P3's cost | The replicate count | hours |

**P3 comes first**, because a negative answer there is the finding.

## 11. Cost

The heaviest per-fit design in the queue: a flexible surface inside a numerically
integrated hierarchical likelihood. **SFW-06 and CMU-01 bound it**, and $n_{sim}$ is
derived rather than chosen.

---

## Relationship to the rest of the queue

- **ADJ-04** owns the pairwise case and the interval; the two share P2 and BART so
  their results compose.
- **MOD-02** owns adversarial surfaces and the misspecification taxonomy.
- **OVL-01** and **OVL-03** own support and the gating diagnostic.
- **SFW-06** and **CMU-01** own the integration cost that consequence 3 multiplies.
- **ADJ-10** owns discovery, which this design does not attempt.
