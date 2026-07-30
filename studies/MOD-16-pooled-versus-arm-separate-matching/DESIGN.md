# MOD-16 design: pooled or arm-separate matching, and the product that decides it

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Petto et al. 2019 introduced arm-separate matching, found it more precise and
less biased, and wrote down its own risk: it might break the randomization,
covariates might be imbalanced after weighting, and further investigation across
a more diverse array of situations is needed. Nobody has run that investigation.
Section 2 shows the bias is an exact product of two factors, and **the two
factors are precisely the pair the catalog says nobody has crossed.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the two weighting partitions identify different
quantities and fail in opposite directions; arm-separate weighting can introduce
confounding through covariates outside the matching set; and no diagnostic
reports whether the randomization-induced balance survived a particular
weighting.

**Refuting sentence:** *arm-separate weighting is uniformly better, as its
introducing paper found, because the confounding it can introduce is second order
relative to the arm-imbalance bias it removes.*

## 2. The mechanism, algebraically, and it is a pure interaction

**Pooled matching** estimates one weight function $w(x)$ and applies it to both
arms. Because $w$ does not depend on treatment, the reweighted trial is still a
valid randomized comparison: within the reweighted population, treatment remains
independent of every covariate, matched or not. **Randomization survives
exactly.**

**Arm-separate matching** estimates $w_1$ and $w_0$ separately. The weighted
contrast is

$$\int \mu_1\,dF_1^w - \int \mu_0\,dF_0^w \;=\; \underbrace{\int(\mu_1-\mu_0)\,dF_1^w}_{\text{causal effect in }F_1^w} \;+\; \underbrace{\int \mu_0\,\big(dF_1^w - dF_0^w\big)}_{\text{confounding}} .$$

The second term is the **prognostic surface integrated against the difference
between the two reweighted covariate distributions**. It is exactly zero when
either factor is zero:

- if every prognostic covariate is in the matching set, $\mu_0$ is constant on
  the unmatched directions and the integral vanishes;
- if the aggregate trial's arms are balanced, $F_1^w = F_0^w$ and it vanishes.

$$\text{bias}_{\text{arm-separate}} \;\approx\; \gamma_U^\top\,\big(\bar x_{U,1}^w - \bar x_{U,0}^w\big)$$

for unmatched covariates $U$ with prognostic coefficients $\gamma_U$, and the
reweighted mean difference is driven by the aggregate trial's arm imbalance.
**The bias is a product: prognostic strength of unmatched covariates times
aggregate arm imbalance. Neither factor alone produces it.**

Two consequences:

1. **A factorial that varies one factor at a time cannot see this**, which is why
   the two published positions disagree: they were generated under mechanisms
   that happened to sit at different points of the product. Reading them against
   each other cannot settle it, and the catalog says so.
2. **The estimands genuinely differ.** Arm-separate weighting places the two arms
   in different covariate distributions whenever the aggregate trial is
   imbalanced, so the contrast is not a contrast within one population at all.
   Pooled weighting targets the effect in the pooled aggregate population. **Which
   corresponds to the decision population is a question with an answer, and it is
   the pooled one**, unless the decision is explicitly about a population that
   inherits the comparator trial's arm imbalance, which no decision is.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, where the target is
the **pooled** aggregate trial population, declared in advance.

**Both estimands are computed.** The arm-separate quantity, the contrast between
arm-specific reweighted populations, is computed as its own truth so that
arm-separate weighting is scored against what it targets as well as against what
the decision needs. **Scoring a method only against a quantity it does not target
is how a comparison is rigged**, and this design refuses that both ways.

**True values** by quadrature over the relevant covariate laws at an order fixed
by P1.

## 4. Data-generating mechanism, and what it makes invisible

Standard anchored geometry: one IPD trial with active A and common comparator C,
one aggregate trial with active B and comparator C, arm-level aggregate summaries
published.

### Factors

| factor | levels | why |
|---|---|---|
| aggregate arm imbalance | 0, moderate, large, in SD units on the matched covariates | **first factor in the product** |
| prognostic strength of unmatched covariates | 0, moderate, large | **second factor in the product**; zero is the null control |
| number of unmatched covariates | 1, 4 | the bias accumulates over them |
| effect modification | 0, moderate, strong | separates modification from prognosis |
| effective sample size after weighting | 2 levels by covariate dimension | the precision side of the trade-off |
| direction of imbalance | aligned with the modifier; orthogonal to it | whether the two mechanisms reinforce or cancel |

The first two are fully crossed, which is the entire design.

### What the mechanism makes true, and therefore what the study cannot see

- The IPD trial is genuinely randomized, so pooled weighting's preservation of
  randomization is exact rather than approximate. Chance imbalance within the IPD
  trial is present at its natural rate but is not itself a factor;
  Remiro-Azócar's two-stage MAIC, which weights arms differently *in order to*
  correct that, is a different object and is included as a method rather than as
  a mechanism.
- Matching is on means only, as in practice. Higher-moment matching would change
  the weight functions and is out of scope.
- The aggregate trial's arm imbalance is imposed exactly and is known to the
  simulation but not to the estimator, which is the real situation.
- One outcome family per arm of the design; no time-varying effects.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| pooled matching | one weight vector to the pooled aggregate summaries | the Signorovitch default |
| arm-separate matching | two weight vectors, arm to arm through the common comparator | Petto et al. |
| two-stage MAIC | treatment-assignment weights inside the IPD trial combined with trial-assignment weights | Remiro-Azócar 2022; arms weighted differently *to correct* chance imbalance rather than to reproduce the aggregate trial's |
| pooled + prognostic adjustment | pooled weighting with unmatched prognostic covariates in an outcome model | the obvious repair, and the one that should remove the product term without breaking randomization |

**The comparator that can win is arm-separate matching**, on its own terms: if it
is unbiased for the decision estimand across the whole product grid, the catalog's
open question closes in its favor and the warning in its own introducing paper is
retired. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage against **both** estimands; precision; per-arm effective sample
size; and **post-weighting balance on the unmatched covariates**, which is the
measured form of the randomization-breaking warning. That balance statistic is
the study's candidate diagnostic and is scored as a *predictor* of realized bias,
with discrimination and calibration, not merely reported.

**The registered mechanism check:** regress observed arm-separate bias on
$\gamma_U^\top(\bar x^w_{U,1}-\bar x^w_{U,0})$ across cells. Slope 1 confirms
section 2.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the decision estimand under
arm-separate weighting, across the imbalance × prognostic-strength grid.

**Decision rule.**

- Bias appearing **only** where both factors are nonzero, growing with their
  product, confirms section 2 and yields a rule an analyst can apply: pooled
  unless the aggregate trial is balanced or the unmatched covariates are weakly
  prognostic.
- Bias present at zero imbalance or at zero prognostic strength refutes the
  mechanism, and the study reports that its explanation is wrong rather than
  keeping the recommendation.
- Neither option biased anywhere means the choice is immaterial at these
  magnitudes and the deliverable is the disclosure requirement alone.

**The disclosure recommendation is made in every branch**, because it costs
nothing and the catalog's point that practice leaves no trail is true regardless
of which weighting wins.

## 8. Three controls, each of which can fail

**Null control.** Zero prognostic strength for unmatched covariates: section 2
makes arm-separate bias **exactly zero** at every imbalance level. Must hold to
Monte Carlo error, or the mechanism is not what is being measured.

**Second null control.** Zero aggregate arm imbalance: arm-separate and pooled
weighting must coincide up to Monte Carlo error, since $F_1^w = F_0^w$. **Both
null controls must pass, and they test different halves of the product.**

**Positive control.** Maximal imbalance and maximal prognostic strength:
arm-separate bias must exceed three MCSEs while pooled remains unbiased. If not,
the product mechanism does not bite at attainable magnitudes and the study says
so instead of searching for a cell where it does.

**Falsifier for the study's own headline.** The expected headline is that pooled
weighting is the safer default. Its falsifier is the precision comparison: if
pooled weighting's variance inflation costs more RMSE than arm-separate's bias
across the realistic part of the grid, the recommendation inverts. **RMSE, not
bias, is therefore reported as the deciding summary in the realistic cells**, and
that is fixed now rather than chosen after seeing which favors the expected
answer.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Scoring a method against a quantity it does not target | Both estimands computed; each method scored against both | removed |
| Reproducing one of the two published mechanisms and inheriting its answer | The product is crossed; both prior mechanisms are points in the grid | removed |
| Randomization-breaking left as a warning | Post-weighting balance measured and scored as a classifier | removed |
| Bias favored over RMSE after the fact | Deciding summary fixed in section 8 before the run | removed |
| Chance IPD imbalance confounded with deliberate arm-separate weighting | Two-stage MAIC included as a distinct method | removed |
| Matching on means only | Stated as scope | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Both estimands per cell; the analytic product bias | The definition of truth, and which cells carry a detectable signal | minutes |
| **P2** attainability | Whether the requested arm imbalance is achievable with the requested matched-covariate marginals, and what effective sample size results | **The grid.** A large imbalance may leave arm-separate weights so concentrated that the comparison is about ESS collapse rather than about confounding | hours |
| **P3** two-stage implementation | Whether the two-stage MAIC arm is implementable at these geometries | Whether that arm exists | hours |
| **P4** unit cost | Per-replicate wall clock; total computed not typed | The grid | minutes |

**P2 matters more than it looks.** Arm-separate weighting to a badly imbalanced
comparator arm is exactly the setting where weights concentrate, and a study that
does not check this will report a variance failure as a confounding failure.

## 11. Cost

Small; weighting fits only. Quoted after P4.

---

## Relationship to the rest of the queue

- **OVL-02** and **DIA-03** own effective sample size as a diagnostic, which is
  the currency of this trade-off's cost side.
- **COV-03** owns prognostic covariates' role, which supplies the $\gamma_U$ that
  makes this product nonzero.
- **HET-02** owns multi-arm covariance lost by pairwise adjustment, a related
  partitioning defect.
- **SFW-10** owns `maicplus` disclosure gaps, which is where the reporting
  recommendation would land.
