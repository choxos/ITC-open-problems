# Protocol: what would the two summaries CMP-14 asks for actually tell an analyst?

**Target problem.** CMP-14 *Aggregate-data-only interactions may be prior-driven*. Bears in part
on IDN-06 *ML-NMR interactions can rest solely on aggregate-data variation*.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Change history is in [`CHANGES.md`](CHANGES.md), not here.** Five rounds of critique returned 45
findings between two reviewers and 60% of them turned on an internal inconsistency: a claim
withdrawn in one section and still standing in another. That was one defect, not twenty-seven, and
it came from rewriting this document in layers. **Every position is now stated once**, and what it
replaced is in the history.

**Provenance.** Every number here is exported from the code that computes it by `R/05-export.R`,
emitted into the document by `review/emit-tables.py`, and asserted back by
`review/verify-protocol.py`, currently **87** assertions. The exporter
refuses to run when an artifact is older than the code that produces it; the verifier refuses to run
when the export is older than the code.

---

## 1. Registration status, stated before anything else

Nothing in this study is confirmatory. That is a real limitation and it is stated first rather than
qualified later.

- **E1 was computed before this document existed.** Its grid, estimands, diagnostics and thresholds
  are fixed in `R/00-config.R`, but earlier probes were read while choosing them and the analysis
  ran before the protocol. **E1 is exact and exploratory.**
- **E2 has no confirmatory standing either.** Its separation rules were rebuilt in round 3 after its
  output had been read. **Every part of E2 is exploratory.**
- **The candidate statistic is post hoc in all three of its forms.** None was registered in advance.

Pre-registration exists to stop data-dependent choices from manufacturing a result. For a
deterministic computation the corresponding risk is choosing the grid or the outcome definition
after seeing which choice gives the desired answer. `CHANGES.md` lists every design choice changed
after a number was seen, which is the only thing that makes an exploratory computation
interpretable.

## 2. The model

$K = 4$ binary components. A treatment is an indicator $c \in \{0,1\}^K$ with additive
effect $c'\delta$ and additive modification $c'\Gamma$.

**E1 uses a Gaussian identity link.** For an individual with covariate $x$ in study $s$,

$$E[y] = \alpha_s + c'\delta + x\,(\beta + c'\Gamma), \qquad \operatorname{Var}(y) = \sigma^2 .$$

**E2 uses a logistic link**, $P(y = 1) = \operatorname{expit}(\eta)$ with the same $\eta$, centred so
placebo arms sit at prevalence 0.3. The two are different models and the sections that
use them say which.

**The estimand is the within-study effect modification $\Gamma_W$ in the data-generating
mechanism**, not a separate model parameter. The fitted model carries **one** $\Gamma$ per
component. When the between-study association differs from the within-study one, that single
coefficient is misspecified, and the size of the resulting error is what the study measures. Calling
the estimand $\Gamma_{W,3}$ elsewhere suggested the model contains $\Gamma_W$ and $\Gamma_B$
separately; it does not.

## 3. The information states

| state | route to $\Gamma_k$ | randomized? | E1 | E2 |
|---|---|:--:|:--:|:--:|
| `own_ipd` | its own individual-data trial | yes | yes | yes |
| `additivity` | only inside the combination $1{+}k$, alongside an arm for 1 | yes, if additivity holds | yes | yes |
| `ecological` | only in aggregate studies, via the between-study contrast in covariate means | **no** | yes | yes |
| `curvature` | two aggregate studies, same covariate mean, different covariate SDs | **no** | — | yes |
| `absent` | nothing | n/a | yes | yes |

The target is component 3 throughout. Components 1, 2 and 4 stay in `own_ipd`. **Every state's
target studies carry three arms**, so every state has twelve arms, an identical shared background
and the same per-arm size at a given budget.

## 4. The aggregate routes, and the restriction the curvature state needs

On a curved link, **any** between-study heterogeneity in a nuisance parameter identifies the
interaction. `R/08-routes.R` isolates each with the others held exactly equal, and asserts every
cell:

| between-study difference | identity link | logit link |
|---|:--:|:--:|
| none | not estimable | not estimable |
| covariate **means** | estimable | estimable |
| covariate **SDs** | not estimable | **estimable** |
| baseline **risks** | not estimable | **estimable** |

So there are three aggregate routes. The mean route works on any link and is the classical
ecological one; the other two are nonlinear-only.

**The `curvature` state therefore requires equal target-study baselines, and that restriction is
registered rather than assumed.** With unequal baselines, equal SDs already identify the target, so
the variance contrast is one nonlinear route among several rather than the unique one.
`R/06-nonlinear.R` asserts both halves: the claim holds under the restriction and fails without it.

**None of the three routes is randomized.** Nobody assigns a study its case mix, its covariate
spread or its baseline risk. That is the thesis, and it holds for more routes than the two-route
version it replaced.

## 5. The diagnostics

| rule | what it is | status |
|---|---|---|
| `contraction` | marginal posterior SD over marginal prior SD, target coordinate | what CMP-14 asks for |
| `target_ratio` | the likelihood's own marginal precision over the prior's, along the target coordinate | what CMP-14 asks for, per parameter |
| `eff_rank` | count of directions where the data outweigh the prior, whole model | what CMP-14 asks for, model level |
| `rank_screen` | is the coordinate identified by the likelihood at all, computed with no prior | the estimability screen `cpaic` ships |
| `source_survival` | fraction of the target's marginal likelihood precision surviving deletion of a source | **this study's candidate, exploratory** |

**Every precision here is prior-free**, meaning $1/[I^{-1}]_{gg}$ from the likelihood alone and
exactly zero where the likelihood does not identify the coordinate. Computing it from a
prior-regularized inverse credits the likelihood with identification the prior supplied.

**`source_survival` is not a share and asking for one is ill-posed.** No single source identifies the
target in every state, so a parameter's precision cannot be apportioned among sources. Asking how
much survives deleting a source needs no additivity and no prior.

**Registered thresholds:** `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`,
`SOURCE_OK = 0.50`. The first two are conventional. **`SOURCE_OK` cannot be**, because
the statistic is introduced here, and it is a stipulation.

## 6. E1: the exact arm

**Why exact.** The study evaluates summaries meant to say whether a posterior is held up by its
prior. If the posterior were itself a Monte Carlo approximation, a failure to flag could not be
separated from a failure to converge.

**What that buys and what it costs.** The posterior covariance is $(I + P_0)^{-1}$, which does not
involve the outcomes, so these summaries depend on the data only through the realized covariate
design. E1 represents each individual-data arm by its Gauss-Hermite nodes, the **expected** design.
Substituting expected information is not the same as averaging any reported quantity over realized
designs, because coverage and contraction are nonlinear in the design; every E1 number is exact for
a study realized exactly at the quadrature weights and is neither an average nor a bound otherwise.

The interaction prior applies to the **interactions only**; nuisance coefficients carry a fixed
`PRIOR_SD_NUISANCE = 10`, and its inertness is measured rather than asserted.

**The grid**, a full factorial with two structural restrictions, **504 scenarios**:

| factor | levels |
|---|---|
| information state | `own_ipd`, `additivity`, `ecological`, `absent` |
| between-study covariate spread | 0.3, 0.6, 1, 1.4, 2, 3 |
| discordance $\Gamma_B - \Gamma_W$ | 0, 0.15, 0.4 (ecological only) |
| total patients per network | 1000, 3000, 10000 |
| prior SD on interactions | 0.1, 0.5, 1, 2.5 |
| synergy, additivity violated | 0, 0.2 (additivity only) |

## 7. Outcomes

A scenario **fails** if coverage is below `COVER_BAD = 0.90`, and is **nominal** if
coverage is within `COVER_TOL = 0.01` of 0.95. Both bands are two-sided:
gross overcoverage is not nominal, it is a different failure.

**Primary 1, an existence claim no weighting can move.** For each statistic, does the range of values
taken by failing scenarios overlap the range taken by nominal ones? One value compatible with both
establishes that no threshold separates them. Reported over the **comparison set**, the failing plus
the nominal scenarios; the intermediate and over-covering bands belong to neither side and are
excluded from the denominator as well.

**Primary 2.** `additivity` against `ecological`, matched on spread, total patient budget and prior
scale, with synergy off.

**Primary 3.** Within the confounded family, the rank correlation between contraction and coverage.
**Low contraction is the reassuring value, so a POSITIVE correlation means the diagnostic becomes
more reassuring as the answer gets worse.**

**Secondary, and grid-weighted.** Sensitivity, false-alarm rate and Youden index at the registered
thresholds. These are averages over a chosen grid and are labeled as such.

## 8. E2: the nonlinear arm

Asymptotic, **not fitted**. No model is sampled and no sampler policy exists because none is needed
for an information calculation. Coverage is reported **only where the model is correctly specified**,
since under misspecification the score variance is not the Fisher information and the aggregate
arm's expected Hessian is not either.

**Contraction in E2 is contraction of a Laplace approximation**, not of a posterior, and the gap is
bounded by nothing measured here. Effective rank is unaffected, being a property of the information
matrix directly.

## 9. What this cannot settle

- **Nothing here is confirmatory**, per section 1.
- **E2's contraction figures describe a Gaussian approximation** to a non-Gaussian posterior.
- **E1's diagnostics are conditional on the expected covariate design.**
- **The curvature state's conclusions hold only under equal target-study baselines**, and the route
  list is not claimed to be complete.
- Additivity is assumed in three of four E1 states; the synergy arm prices that conditionality
  rather than removing it.
- One continuous covariate, one binary component structure, one target component.
- Conditional estimand only. Nothing is claimed about a target-population marginal contrast.
- Numerical summaries only; a plot read by an analyst is a different instrument.
