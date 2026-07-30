# COV-12 design: median-based summaries reaching the integration distribution

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Two mature literatures exist and neither owns the join. Median-to-mean estimators
(Wan 2014, Luo 2018, Shi 2020, McGrath 2020, implemented in `metamedian`) were
built to feed an inverse-variance meta-analysis of a location parameter. ML-NMR
needs a whole marginal law to integrate over. Section 2 makes precise what the
catalog states qualitatively: **the accuracy criterion those estimators were
optimized for is the right one under exactly one condition, and ML-NMR never
satisfies it.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** reconstructing an aggregate study's covariate
marginal from a median with range or interquartile range introduces error into
the target-standardized contrast that is not controlled by the reconstruction
error in the mean, is worst where the reporting convention itself signals skew,
and is currently invisible because a reconstructed marginal leaves no trace in
the output.

**Refuting sentence:** *the contrast error is a monotone function of the mean
recovery error, so the existing estimators are already optimizing the right
thing and the join is a documentation problem rather than a methods problem.*

## 2. The mechanism, algebraically

The reconstructed marginal $\hat F$ replaces the true $F$ in the integration. The
error in the target-standardized contrast is

$$\Delta(\hat F) - \Delta(F) \;=\; \int \tau(x)\,d(\hat F - F)(x)$$

for a collapsible link with conditional contrast function $\tau$. Two cases, and
the gap between them is the study.

**Linear $\tau(x) = \tau_0 + \beta^\top x$, collapsible link.**

$$\Delta(\hat F) - \Delta(F) \;=\; \beta^\top(\hat{\bar x} - \bar x).$$

**Only the reconstructed mean enters, and only multiplied by the interaction.**
The reconstructed standard deviation is irrelevant, the family assumption is
irrelevant, and the median-to-mean literature's own criterion is exactly right.
This is the condition under which the refuting sentence is true, and it is worth
establishing rather than assuming, because it tells an analyst when they may stop
worrying.

**Curved link or nonlinear $\tau$.** Expanding $\tau$ to second order,

$$\Delta(\hat F) - \Delta(F) \;\approx\; \beta^\top(\hat{\bar x}-\bar x) \;+\; \tfrac{1}{2}\,\mathrm{tr}\!\left[\nabla^2\tau\,\big(\widehat{\mathrm{Var}} - \mathrm{Var}\big)\right] \;+\; \text{higher moments}$$

so the reconstructed **variance** enters at second order and the reconstructed
**shape** at third. Since ML-NMR is used with logit and log-hazard links, the
second term is always present; and the third is exactly where a normality-based
reconstruction of a skewed covariate fails. **The estimators are least reliable in
the term that only exists because the link is curved, and the reporting of a
median with range is itself the signal that the covariate is skewed.**

Three predictions follow:

1. Under an identity link with linear interaction, the choice of SD estimator and
   marginal family does not affect the contrast at all. **This is a falsifiable
   invariance, and it is section 8's falsifier.**
2. Under a curved link the family choice affects the contrast even when the
   recovered mean is exact, so mean-recovery accuracy is not sufficient.
3. A range-only summary cannot identify dispersion, so reconstruction from
   median+range must be strictly worse than from median+IQR, and the gap grows
   with the second-order term. The catalog states this; it has never been
   measured in contrast units.

## 3. Estimand, with its true value defined

**Primary.** The target-standardized marginal treatment effect on the log odds
ratio scale (curved link, the realistic case).

**True value.** By quadrature over the **true** covariate law, at an order fixed
by P1. Truth is defined against the generating law, never against a
well-reconstructed marginal, because the whole question is the gap between them.

**Scored on the contrast, never on the recovered mean.** The catalog says so and
it is the design's central discipline: a marginal error reaches the estimate only
through the interaction it multiplies, so the recovered mean's error is a
nuisance quantity, not an outcome.

## 4. Data-generating mechanism, and what it makes invisible

Covariate laws are the ones the reported cases actually involve, taken from the
Maciel et al. 2024 multiple-myeloma application rather than invented: number of
prior treatment lines (count, right-skewed), time since diagnosis (lognormal),
tumor burden (gamma).

### Factors

| factor | levels | why |
|---|---|---|
| true covariate law | Poisson-like count; lognormal; gamma; normal | the reported cases plus the case the estimators assume |
| skewness | 3 levels within each family | the property that triggers median reporting and breaks the estimators |
| reported summary | median+range; median+IQR; five-number | prediction 3; range-only is the common oncology case |
| reconstruction estimator | Wan 2014; Luo/Shi; McGrath ML; McGrath Bayes | the candidates, including the two that do not assume normality |
| assumed marginal family | normal; lognormal; gamma; Poisson | **the pairing nobody has specified**, which is the actual deliverable |
| interaction strength | 0, moderate, strong | the multiplier in section 2; 0 is the null control |
| interaction shape | linear; threshold | prediction 2 |
| study size | 50, 200, 800 | reconstruction error scales with it; contrast bias does not vanish with the *source* size |
| link | identity; logit | prediction 1 versus 2 |

Estimator crossed with family fully, since that pairing is the output. The rest
crossed at a reduced grid fixed by P2.

### What the mechanism makes true, and therefore what the study cannot see

- Reported summaries are computed from the simulated sample, so they carry the
  right sampling variability by construction. Rounding, transcription error and
  inconsistent definitions of "range" across publications are not simulated.
- One covariate is reconstructed at a time in the base arm. The copula linking
  reconstructed margins is held at the truth, so this study isolates the marginal
  and says nothing about the copula. **CMP-15 owns the joint distribution**, and
  conflating the two would make both uninterpretable.
- The correlation structure is supplied correctly, as Maciel et al. could not do;
  their "assumed to match the IPD" step is a separate error not measured here.
- Only the aggregate arm's covariates are reconstructed; the IPD arm is exact.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| oracle marginal | the true law supplied | the ceiling; isolates reconstruction from everything else |
| reported-moment marginal | exact mean and SD supplied | the situation when a publication reports moments; the target to match |
| reconstructed, each estimator × family | the grid above | the thing under test |
| **propagated reconstruction** | prior on the reconstructed mean and SD from McGrath 2023's sampling variability, integration points regenerated inside the sampler | **the step nobody has taken** |
| interval-of-marginals | the contrast reported over the set of marginals compatible with the reported quantiles | the honest fallback when no family fits |

**The comparator that can win is the reported-moment marginal.** If the best
estimator-family pairing matches it across the grid, reconstruction is solved by
choosing correctly and the propagation arm is unnecessary. That is the outcome
that would most weaken the expected headline.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of the target-standardized contrast, per pairing per
cell, with MCSE. Interval width, and for the propagated arm the increase in width
relative to the fixed-grid arm, since that is its cost.

**The registered criterion test**, which decides the refuting sentence directly:
the correlation, across all cells, between reconstruction error in the mean and
error in the contrast. Near 1 means the existing literature already optimizes the
right thing; substantially below 1 means it does not, and section 2 predicts the
correlation drops as the link curves and the interaction becomes nonlinear.
**Reported as a surface over link and interaction shape, not as one number**,
because a single correlation averaged over a grid designed to contain both
regimes would be uninterpretable.

$n_{sim} = 2000$ per cell for the fixed-grid arms. The propagated arm is a Stan
fit and runs at a reduced count set by P4, reported with its own MCSE at its own
count.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias in the target-standardized log odds ratio under
median+range reporting of a skewed covariate with strong interaction, by
estimator-family pairing.

**Decision rule.**

- If some pairing achieves bias within Monte Carlo error of the reported-moment
  arm across every skewed law, that pairing is the **recommended default** and is
  named in the output. This is the deliverable the catalog asks for.
- If no pairing does, the reconstruction is not solvable by choosing well and the
  interval-of-marginals arm becomes the recommendation.
- If the propagated arm reaches nominal coverage where the fixed-grid arms do
  not, propagation is established as necessary rather than optional.

**Two-sided on coverage.** An interval-of-marginals arm that covers at 0.999 is
useless, not safe, and is recorded as a failure of the same rule.

## 8. Three controls, each of which can fail

**Null control.** At zero interaction, section 2 makes the reconstruction error's
path to the contrast **algebraically closed**: no estimator, family or summary
type can bias the contrast. Bias must be zero to Monte Carlo error in every one
of those cells. This is an exact control, not an approximate one, and a failure
means the harness is leaking the reconstruction somewhere it should not.

**Positive control.** At maximal skew, range-only reporting, strong nonlinear
interaction and a normal assumed family, bias must exceed the decision threshold.
If the worst case the design can build is harmless, the problem is not material
and the study says so instead of hunting for a cell where it fires.

**Falsifier for the study's own headline.** Prediction 1: under the identity link
with a linear interaction, the SD estimator and the family must be **irrelevant**,
so all pairings must agree to Monte Carlo error. If they differ there, the
mechanism in section 2 is wrong and no result downstream can be attributed to
curvature. **This control is what separates "the curvature term matters" from
"reconstruction is just noisy".**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Scoring on mean recovery, the wrong criterion | Contrast is the only outcome; mean error kept as a nuisance and used only for the registered correlation test | removed |
| Marginal error confounded with copula error | Copula held at the truth; CMP-15 named as the owner | removed |
| Estimators evaluated only where they were derived to work | Normal family included as one of four, not as the base case | removed |
| Recommendation that depends on the grid's skew levels | The recommended pairing must hold across every skewed law, not on average | removed |
| Propagated arm favored by wider intervals | Two-sided coverage rule plus width reported | removed |
| `metamedian` versions differ | Version pinned and recorded in provenance; a result that moves between versions is a finding | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The true target-standardized contrast per law, stable to $10^{-4}$ | The definition of truth | minutes |
| **P2** skew realizability | The parameterizations giving the requested skewness at the requested means, per family, and whether median+range is even well defined at the small sizes | The grid. A "range" from $n=800$ is a different statistic from one at $n=50$ and the estimators know it | hours |
| **P3** propagation feasibility | Whether integration points can be regenerated inside a `multinma` sampler at all, or whether the arm needs a custom Stan model | **Whether the propagated arm exists.** CMP-14 registered two specifications that `multinma` rejected at the Stan level | hours |
| **P4** unit cost | Per-replicate cost of the propagated arm; the total, computed not typed | The propagated arm's replicate count | hours |

**P3 decides whether this study has its most interesting arm.** The fixed
integration grid is built before sampling begins, by construction, and making it
random is not a switch.

## 11. Cost

The fixed-grid arms are cheap. The propagated arm dominates and is unpriced until
P4. No total quoted here.

---

## Relationship to the rest of the queue

- **CMP-15** owns the joint target distribution; the copula is held at truth here
  precisely so the two do not confound.
- **EST-07** owns sampling error in *reported* moments; this study owns error from
  moments that were never reported.
- **CMU-01** owns ML-NMR integration cost, which is what the propagated arm
  multiplies.
- **SFW-06** and **DEC-11** own the reporting side: a declaration that a marginal
  was reconstructed is a reporting requirement, and this study supplies the
  evidence for asking.
