# DEC-28 design: a cut-point is a ratio, and nobody puts an interval on it

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's sentence to build on: *a narrow interval on every contrast is
compatible with a boundary that could sit almost anywhere.* Section 2 makes that
exact, and the reason is more elementary than the nonregular-argmax framing the
literature reaches for.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the optimal-treatment partition is a function of
estimated interaction coefficients, no population-adjustment implementation
reports uncertainty on it, and the resulting point cut-point is materially
uninformative in exactly the region a decision turns on.

**Refuting sentence:** *in networks with the interaction precision achievable in
practice, the boundary is well determined, so reporting it as a point is
harmless and the missing interval is a formality.*

## 2. The mechanism: the boundary is a ratio, not a contrast

With individual linear predictors $\eta_k(x) = \delta_k + \beta_k^\top x$, the
boundary between treatments $j$ and $k$ is the set where they cross:

$$\{x : (\delta_j - \delta_k) + (\beta_j - \beta_k)^\top x = 0\}.$$

For a single modifier this is the point

$$x^\star \;=\; -\,\frac{\delta_j-\delta_k}{\beta_j-\beta_k}\;,$$

**a ratio of two estimated quantities whose denominator is an interaction
difference.** Three consequences, and they are elementary rather than exotic:

1. **The delta-method variance carries $(\beta_j-\beta_k)^{-2}$**, so it diverges
   as the two treatments' modification becomes similar. The contrasts $\delta$ and
   $\beta$ can each be tightly estimated while $x^\star$ is not, which is the
   catalog's sentence with a formula attached.
2. **The correct interval is a Fieller interval, and it can be the whole line or
   an exclusive region.** When the denominator's interval includes zero, no
   bounded confidence set for $x^\star$ exists. **A method that always returns a
   bounded interval is therefore wrong**, and that is a check, not a preference.
3. **The smooth object is the probability, not the location.** $P\{k =
   \arg\max_m \eta_m(x)\}$ is well defined and smooth in $x$ even where the
   argmax is not unique, and it is computable from existing ML-NMR posterior
   draws with no new machinery. That is what the catalog proposes and section 5
   implements.

**The second mechanism, which is not sampling error at all.** In a network, part
of $\beta_k$ is identified by between-study covariate variation, which is
ecologically confounded. CMP-13 established the algebra and IDN-06 measures it in
the Bayesian case. **So the boundary inherits a bias that no posterior width can
show**, and a band that covers the *estimable* boundary can miss the true one
entirely. The design carries a within/between discordance factor for exactly this
reason, and it is what separates this study from a single-dataset subgroup
analysis.

## 3. Estimand, with its true value defined

**Primary.** The optimal-treatment partition over a declared target covariate
space: for each profile $x$ on a declared grid, which treatment maximizes the
individual effect.

**True value** from the generating coefficients, evaluated exactly on the grid.
The true $x^\star$ is available in closed form for the one-modifier arm and by
root-finding on the grid for the two-modifier arm.

**Two derived estimands, both scored.** The **profile-specific optimality
probability** $P\{k \text{ optimal at } x\}$, whose truth is degenerate (0 or 1)
at every profile away from the true boundary, so it is scored by calibration and
by Brier score rather than by coverage. And **treatment-assignment regret**: the
expected loss in target-population outcome from following the estimated partition
instead of the true one, which is the quantity a decision actually pays.

**Regret is the deciding summary**, fixed now. A boundary that is misplaced where
the treatments are nearly tied costs almost nothing, and any measure that
penalizes it equally with a misplacement in a region of real difference is
measuring the wrong thing.

## 4. Data-generating mechanism, and what it makes invisible

ML-NMR networks with IPD and aggregate studies, three treatments, one or two
continuous effect modifiers.

### Factors

| factor | levels | why |
|---|---|---|
| interaction separation $\|\beta_j-\beta_k\|$ | large, moderate, near zero | **the denominator in section 2**; near zero is where Fieller unboundedness appears |
| modifier count | 1, 2 | a point boundary versus a line; the second is where "read the cut-point off a plot" stops working |
| treatment separation $\delta_j-\delta_k$ | 2 levels | moves the boundary within the covariate range |
| within/between discordance | 0, moderate | **the non-sampling error**; zero is the null control for it |
| covariate overlap | good, poor | how much of the boundary region is supported by data |
| profile position | on the grid, including profiles at, near and far from the true boundary | regret is dominated by the near-boundary profiles and they must be represented |
| partition selection | modifier fixed in advance; modifier chosen from 4 candidates by induced variation | **the selection component**, which the catalog says leaves any subgroup interval too narrow |

### What the mechanism makes true, and therefore what the study cannot see

- The individual-level model is correctly specified, so the boundary's error is
  estimation and ecological confounding, not functional form. MOD-02 owns the
  latter and a curved boundary is not covered.
- Only ML-NMR is fitted, because it is the only population-adjustment method
  producing the individual-level probabilities a boundary needs. **That is a
  finding about the field, not a limitation of the design**, and the paper should
  say so: for most submitted analyses the object cannot be computed at all.
- Three treatments. With more, the partition has more faces and the selection
  problem compounds; nothing here extrapolates to that.
- The target covariate distribution is known exactly. CMP-15 and COV-12 own its
  uncertainty, and adding it would confound partition error with input error.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| point cut-point | plug-in $\hat x^\star$, no interval | current practice, in the applied papers the catalog cites |
| delta-method interval | plug-in variance from section 2 | the naive interval, expected to fail where the denominator is weak |
| **Fieller interval** | exact ratio interval, permitted to be unbounded or exclusive | section 2 prediction 2 |
| **posterior optimality map** | $P\{k \text{ optimal at } x\}$ recomputed in every posterior draw, with a pointwise band on the boundary | the catalog's proposal, implementable from existing draws |
| m-out-of-n bootstrap | Chakraborty, Laber and Zhao, ported to the boundary parameters, for a frequentist fit | the nonregularity technology, tested for whether it survives target-population standardization |

**The comparator that can win is the delta-method interval.** If it is nominal
across the achievable range of interaction separation, the Fieller and bootstrap
machinery is unnecessary and the deliverable is a one-line addition to standard
output. Registered as the outcome most likely to overturn the expected headline;
it is also the cheapest possible fix, so it deserves a real chance.

## 6. Performance measures, MCSE, and $n_{sim}$

Coverage of the boundary location (with the fraction of unbounded intervals
reported separately, since an unbounded interval covers trivially and must not be
scored as a success); boundary-location error; **treatment-assignment regret**;
calibration and Brier score of the optimality map; coverage of subgroup contrast
intervals **when the same data chose the partition**; and the frequency with which
the selected modifier is the true one.

**The variance decomposition is a registered outcome**, not a by-product: for
each cell, the share of boundary variability attributable to within-study and to
between-study interaction information, computed from CMP-14's prior-free
leave-one-source-out precision. That is the catalog's explicit request and it is
what shows a band can be narrow and wrong.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 1000$ per cell, Stan-limited, with the coverage MCSE stated at 0.007
rather than a round count asserted.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Treatment-assignment regret under the point cut-point versus
the posterior optimality map, at moderate interaction separation with nonzero
within/between discordance.

**Decision rule.**

- The map reducing regret materially while the point cut-point's implied
  confidence is not supported by any interval method **confirms** the problem and
  establishes the map as the reporting object.
- Comparable regret and nominal delta-method coverage everywhere **refutes**
  materiality, and the study reports that a point cut-point is adequate at
  achievable precisions.
- **Regardless of branch, the fraction of cells in which no bounded confidence
  set for $x^\star$ exists is reported**, because that number alone determines
  whether a cut-point is a reportable quantity, and it does not depend on which
  method wins.

## 8. Three controls, each of which can fail

**Null control.** At zero within/between discordance and large interaction
separation, every method must be nominal and the map's calibration must be within
Monte Carlo error of perfect. Failure here is implementation, not mechanism.

**Positive control.** At near-zero interaction separation, the Fieller interval
must be unbounded in a substantial fraction of replicates. **If it is never
unbounded, it is not a Fieller interval** and section 2 prediction 2 has not been
implemented.

**Falsifier for the study's own headline.** The expected headline is that
posterior bands understate boundary error because part of it is ecological. Its
falsifier is the zero-discordance arm, where the band must cover nominally. If
the band undercovers there too, the shortfall is Monte Carlo or model error and
the ecological explanation is withdrawn. **Without that arm the two causes are
indistinguishable and the headline would be unsupported.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Unbounded interval scored as coverage success | Reported separately and excluded from the coverage claim | removed |
| Boundary error penalized where treatments are tied | Regret is the deciding summary, fixed before the run | removed |
| Selection effect confounded with estimation error | Partition selection is a registered factor with a fixed-modifier level | removed |
| Ecological bias indistinguishable from sampling error | Discordance factor plus the prior-free variance decomposition | removed |
| Only one method can compute the object, framed as a design choice | Stated as a finding about the field | disclosed |
| Boundary curvature | Linear predictors only; scope named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and grid | True partition and $x^\star$ per cell; the profile grid, weighted so near-boundary profiles are represented | The regret definition's weighting, which is otherwise an unexamined choice | hours |
| **P2** separation calibration | The interaction separations at which the Fieller denominator's interval includes zero at achievable precisions | **The grid.** If unboundedness never occurs at realistic network sizes, the study's sharpest claim is unavailable and the design must say so before running | hours |
| **P3** m-out-of-n tuning | Whether the adaptive resample size is estimable here, since it was built for single-study data | Whether that arm exists | hours |
| **P4** unit cost | Per-fit wall clock and the total, computed not typed | $n_{sim}$ and the grid | hours |

## 11. Cost

Stan-dominated. Unpriced until P4; no total quoted.

---

## Relationship to the rest of the queue

- **CMP-13** and **IDN-06** own the within/between conflation that supplies this
  study's non-sampling error; the discordance factor is theirs.
- **CMU-02** owns prior-driven posteriors, which is the other way a band can be
  narrow and wrong.
- **DEC-01** owns scoring method evaluations by decision error rather than
  estimator error, which is what regret operationalizes here.
- **DEC-02** owns which choice most often flips a decision.
- **EST-12** owns treatment hierarchies without a declared target referent, the
  same defect one level up.
