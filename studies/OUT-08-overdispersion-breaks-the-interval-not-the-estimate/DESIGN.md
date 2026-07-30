# OUT-08 design: separating the uncertainty problem from the transport problem

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog narrows its own source in a way that determines the whole design.
**Where the conditional mean is correctly specified, the Poisson estimating score
remains unbiased under negative-binomial variance**, so residual overdispersion
invalidates likelihood-based uncertainty while leaving rate-ratio point estimates
consistent. **Transport bias instead requires misspecification of the conditional
mean, the zero mechanism, the frailty, or the exposure weighting.**

Those are two different failures with two different fixes, and a design that
crossed them would report one number for both. **The two auditors disagreed about
how much of the source's mechanism survives, and that disagreement is recorded
rather than resolved**; this design measures both halves so the disagreement becomes
answerable.

The note also separates the count benchmark from recurrent-event and joint-frailty
development. **This design takes the count benchmark.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no population-adjusted implementation offers an
overdispersed, zero-inflated or recurrent-event likelihood, so an analyst facing
exacerbation or relapse counts either accepts Poisson uncertainty or leaves the
framework; and a structural-zero subgroup makes the population a mixture whose
mixing proportion can vary across trial populations, which is a transport problem
rather than a fitting problem.

**Refuting sentence:** *a robust or sandwich variance on the Poisson fit repairs the
uncertainty, and the mean is what transports, so the missing likelihoods are a
convenience rather than a requirement.*

**That refutation is strong and the design registers it as the comparator that can
win**, because if it holds the recommendation is a variance option rather than four
new likelihood families.

## 2. The mechanism: two failures with orthogonal nulls

**Failure one, uncertainty.** With a correct conditional mean $\mu(x)$ and
negative-binomial variance $\mu + \mu^2/\theta$, the Poisson score
$\sum (y_i - \mu_i)x_i$ has mean zero, so $\hat\beta$ is consistent. The Poisson
information understates the true variance by the dispersion factor, so
model-based intervals are too narrow by approximately $\sqrt{1 + \bar\mu/\theta}$.
**A quantity computable from the fitted means and an estimated $\theta$**, which is
what makes the refuting sentence plausible.

**Failure two, transport.** The target rate is $\int \mu(x)\,dF_T(x)$. Bias requires
$\mu$ itself to be wrong, and there are exactly four routes the catalog names:

1. **Conditional mean misspecified** — ordinary and not count-specific.
2. **Zero mechanism.** With a structural-zero subgroup at prevalence $\pi_s$, the
   population mean is $(1-\pi_s)\mathbb{E}[\text{count} \mid \text{at risk}]$.
   **If $\pi_s$ differs between source and target, transporting the count model
   without the mixture transports the wrong quantity**, and no dispersion parameter
   repairs it. **This is a genuine transport problem and it is the design's
   sharpest cell.**
3. **Frailty.** A subject-level frailty makes the marginal rate depend on the
   frailty distribution, which is population-dependent; transporting the
   conditional rate does not transport the marginal one.
4. **Exposure weighting.** CMP-20 owns this exactly: the Poisson aggregate
   likelihood needs zero exposure-rate covariance, and its bias is a difference of
   arm-level covariances.

**The two failures have orthogonal nulls**, which is what makes the design work:
overdispersion with no structural zeros and no frailty leaves the point estimate
consistent; a structural-zero difference with Poisson-equal dispersion leaves the
interval correct and the estimate wrong. **Section 8 uses both.**

## 3. Estimand, with its true value defined

**Primary.** The target-population rate ratio, and the **target absolute rate**,
since the entry asks for absolute-rate calibration and a rate ratio can be right
while both arms' rates are wrong.

**True value** by exact integration of the generating count model over the target
covariate law, **including the mixture and frailty structure where present**.
Defining truth from the Poisson component alone would build the misspecification
into the answer.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| dispersion | Poisson; moderate NB; strong NB | failure one |
| structural-zero prevalence | 0; equal across trials; **differing across trials** | **failure two, route 2**, and only the third level is a transport problem |
| frailty heterogeneity | none; moderate | route 3 |
| covariate-dependent exposure | none; present | route 4, imported from CMP-20 |
| covariate overlap | good, poor | the adjustment layer |
| event rate | low, moderate | where zero inflation is detectable at all |

**The structural-zero factor's second and third levels are the design's core
contrast**: equal prevalence is a fitting problem, differing prevalence is a
transport problem, and current practice cannot tell them apart.

### What the mechanism makes true, and therefore what the study cannot see

- **Recurrent events and joint frailty models are excluded**, per the note. Frailty
  enters only as a generating mechanism, not as a fitted family, so this design
  measures the cost of ignoring it and does not build the fix.
- Time to first event and total burden are different estimands. **Only total burden
  is estimated here**, and the entry's point that they can move in different
  directions is inherited rather than tested.
- **The closed-form-likelihood barrier may already be removed.** The literature
  auditor flagged a Bayesian synthetic likelihood lead (arXiv:2603.11019) they did
  not read. **P3 reads it before any integration machinery is rebuilt**, because if
  it does what its title says, the implementation route changes entirely.
- Aggregate arms report annualized rates, as publications do, so the design inherits
  the information limitation the entry describes.

## 5. Methods, including one that can win

| method | role |
|---|---|
| weighted Poisson MAIC | current practice |
| Poisson ML-NMR | current practice, one-stage |
| **Poisson with robust/sandwich variance** | **the comparator that can win**: repairs failure one without a new likelihood |
| negative-binomial ML-NMR | the overdispersion family |
| hurdle or zero-inflated ML-NMR, with the zero and count components permitted to differ | route 2's fix |
| correctly specified oracle | the ceiling |

**Registered: if the robust-variance Poisson arm attains nominal coverage wherever
the conditional mean is correct, failure one needs no new likelihood**, and the
recommendation reduces to a variance option plus a transport warning for route 2.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE of the rate ratio; **absolute-rate calibration in the target**,
reported separately; interval width; convergence, with MCSE on all.

**The two failures reported separately and never pooled**: bias against the true
target rate ratio, and the SE ratio against the empirical SD. **A method can fail
one and pass the other, and a single "performance" summary would hide which.**

**The registered dispersion check:** the observed SE understatement against
$\sqrt{1+\bar\mu/\theta}$ from section 2. Agreement confirms failure one's form and
makes it correctable by hand.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the target rate ratio when structural-zero prevalence
**differs** across trial populations, under Poisson and negative-binomial fits, at
moderate overlap.

**Decision rule.**

- Material bias there, unrepaired by any dispersion family and repaired by a
  hurdle or zero-inflated model with a transported mixing proportion: **route 2 is
  established as a transport problem** and the deliverable is that family plus the
  requirement to report zero structure.
- No bias there: the mixture is not a transport problem at realistic prevalence
  differences and the whole concern reduces to failure one.
- **The robust-variance Poisson arm's coverage is reported in either branch**,
  because it decides whether four new likelihood families are needed or one variance
  option is.

## 8. Three controls, each of which can fail

**Null control, failure one isolated.** Strong overdispersion, equal structural-zero
prevalence, no frailty, correct mean: **the Poisson point estimate must be unbiased
and its model-based interval too narrow.** Both halves must hold. **That is the
catalog's own narrowing tested directly**, and if the point estimate is biased there
the narrowing is wrong and the auditors' disagreement resolves the other way.

**Second null control, failure two isolated.** Poisson-equal dispersion with
differing structural-zero prevalence: **the interval must be correctly calibrated
and the estimate biased.** The mirror image, and together the two controls establish
that the failures are orthogonal.

**Positive control.** Strong overdispersion, differing zero prevalence, poor
overlap: Poisson must fail on both measures. If it does not, neither failure is
reachable.

**Falsifier for the study's own headline.** The expected headline is that the
missing likelihoods matter. Its falsifier is the robust-variance arm succeeding
plus route 2 turning out immaterial: **then Poisson with a sandwich is adequate and
the entry's software gap is a convenience gap**, which the design must be able to
conclude.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Uncertainty failure and transport failure reported as one | Orthogonal nulls; separate measures | removed |
| Claiming overdispersion biases the point estimate | The catalog's narrowing carried and tested as the first null control | removed |
| Truth defined from the Poisson component | Defined from the full generating model | removed |
| Rebuilding integration machinery before reading the lead | P3 reads arXiv:2603.11019 first | removed |
| Exposure-rate covariance confounded | Imported from CMP-20 as one factor with its owner named | removed |
| Recurrent events and joint frailty | Excluded per the note; frailty generates but is not fitted | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Target rate ratio and absolute rates under mixture and frailty structures | The definition of truth | hours |
| **P2** detectability | Whether zero inflation is distinguishable from low-rate Poisson at the chosen event rates and sample sizes | **The grid.** At low rates the two are near-indistinguishable and the transport cell would be measuring noise | hours |
| **P3** read the lead | Whether Bayesian synthetic likelihood removes the closed-form constraint for ML-NMR | **The implementation route for every non-Poisson arm** | days |
| **P4** unit cost | Per-fit cost across six arms; total computed not typed | $n_{sim}$ | hours |

**P3 costs a day of reading and could save weeks**, which is why it is listed as a
probe rather than as background.

## 11. Cost

Count-model fits are cheap; the ML-NMR arms and any synthetic-likelihood route are
not. Priced in P4 after P3 settles the route.

---

## Relationship to the rest of the queue

- **CMP-20** owns the exposure-rate covariance, one of the four transport routes.
- **OUT-02** owns rare events and the effective event sample size, the low-count
  regime of the same likelihood.
- **DIA-09** owns recurrent events as an estimand and would inherit the frailty
  transport question this design generates but does not fit.
- **SFW-06** and **CMU-01** bound the ML-NMR arms' cost.
