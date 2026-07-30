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
`review/verify-protocol.py`, currently **105** assertions. The exporter
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

**E2 uses a logistic link**, $P(y = 1) = \operatorname{expit}(\eta)$ with the same $\eta$, with
$\alpha_s$ set so the **conditional placebo risk at $x = 0$ is 0.3**. **Placebo *arm* prevalence is
not 0.3 and is not constant**: on a curved link the arm-level value integrates the covariate
distribution through $\operatorname{expit}$, so it depends on each study's covariate mean and SD and
runs from **0.2913 to 0.3291** across the registered states. An earlier version of this document said
placebo arms sit at prevalence 0.3, which is true nowhere. `R/07-run-e2.R` computes the range and
stops the run if any arm hits 0.3 exactly. The two models are different and the sections that use
them say which.

**The estimand is the within-study effect modification $\Gamma_W$ in the data-generating
mechanism**, not a separate model parameter. The fitted model carries **one** $\Gamma$ per
component. When the between-study association differs from the within-study one, that single
coefficient **estimates a different quantity rather than becoming wrong**: the likelihood is
satisfied exactly at $\Gamma_W + \text{shift}$, and the size of the resulting error is what the study
measures. Section 8 establishes that this holds to machine precision on both arms. Calling
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
and the same per-arm size at a given budget. **`R/06-nonlinear.R` computes the arm count and the
per-arm size for every state and stops the run if they differ**, because this sentence was true of
the linear states and false of `curvature`, which ran at ten arms and 300 per arm through five
rounds of critique until both round-6 reviewers found it independently.

**The per-arm size is an information weight and is not rounded to a patient count.** Nothing here
simulates individuals: every quantity is an exact Fisher information computed with $n$ as a weight,
so at budgets of 1000 and 10000 the per-arm size is $83.\overline{3}$ and $833.\overline{3}$ and
stays that way. "Total patients per network" is a label for that scale. Rounding would put an
artifact into an exact computation and buy nothing.

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

**"Baseline" here means the study intercept $\alpha_s$, not arm-level prevalence, and the two are
not the same thing.** The curvature state's two target studies share an intercept and differ in
covariate SD, so their placebo *arm* prevalences differ, **0.3099 against 0.3194**. The rank
calculation that establishes the restriction uses the intercept, so the restriction holds; read as
prevalence it would not. `R/07-run-e2.R` asserts that the intercepts are equal, that the prevalences
differ, and therefore that the distinction is doing work rather than being a quibble.

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
for an information calculation.

**Neither departure is misspecification, so coverage is reported on all 72 scenarios.** Discordance
adds its amount to the target modification in the *aggregate* rows carrying the target, and in
`ecological` and `curvature` the target appears in no other row. Synergy adds its amount to arms
holding components 1 and 3 together, and in `additivity` the target appears in no other arm. In both
cases every row the departure touches carries the target and every target-bearing row is touched, so
a **single shifted coefficient reproduces the truth exactly**:

$$p^{\text{true}}(x;\,\theta_{\text{true}},\text{departure}) \;=\; p^{\text{model}}(x;\,\theta^{*}),
\qquad \theta^{*} = \theta_{\text{true}} + \text{shift}\cdot e_{\Gamma_3}.$$

`R/07-run-e2.R` asserts this **per scenario and pointwise in the covariate**, not on the arm mean,
because an individual-data arm contributes a per-individual likelihood and two different probability
functions can share a mean. The worst gap over the grid is **2.22e-16**, against a registered
tolerance `E2_ALIAS_TOL` of 1e-12. A future state whose departure touched only some target-bearing
rows would stop the run rather than quietly reintroduce the misspecification this paragraph says is
absent.

**So the model is correct and the *estimand* is aliased**, which is a stronger result than the one it
replaced. The likelihood identifies $\Gamma_W + \text{shift}$ while the study asks about $\Gamma_W$,
and the interval is correctly sized around the wrong quantity. That is worse than a wide interval and
it is precisely what CMP-14 asks whether the summaries can detect. Everything is evaluated at
$\theta^{*}$, including the information, which on a curved link depends on the parameter; the bias
against the registered estimand is
$\text{shift} - [(I^{*} + P_0)^{-1} P_0 \theta^{*}]_{\Gamma_3}$, the aliasing and the prior shrinkage
in one expression. At shift $= 0$ this reduces term by term to the previous calculation, so the 44
undisturbed scenarios keep their values and **28 scenarios gain a coverage figure they were denied**.

An earlier version reported coverage only where discordance and synergy were both zero, on the
argument that the score variance is not the Fisher information under misspecification. **That algebra
is correct and simply never applied here**; it is not retracted, it is out of scope. The restriction
had removed exactly the scenarios the study exists to examine, and it left primaries 2 and 3
uncomputable on E2.

**Contraction in E2 is contraction of a normal approximation whose covariance is
$(I(\theta_{\text{true}}) + P_0)^{-1}$**, the expected Fisher information at the true parameter plus
the prior precision. **It is not a Laplace approximation**, which would invert the Hessian of the log
posterior at the posterior *mode*. An earlier version of this document called it one. The two
coincide when the information does not depend on the parameter, which holds on an identity link and
fails on the logit link E2 uses, and when the mode equals the truth, which a proper prior centred at
zero makes false by construction.

**The registered quantity is the one evaluated at the truth, deliberately.** E2 is an exact
information calculation with no data and no sampling, so evaluating at the truth is deterministic and
is a property of the design rather than of a realized dataset. A Laplace covariance would make the
diagnostic depend on where the prior happens to pull the mode, which is the prior's behavior and not
the design's.

**The gap is measured rather than admitted.** `R/09-contraction-gap.R` solves for the mode under data
at their expectation, $U(\theta;\,\mathbb{E}[y \mid \theta_{\text{true}}]) = P_0\theta$, by Newton
iteration and recomputes the contraction there, at $\theta^{*}$ where a departure acts. It runs on
**all 72 scenarios**; the earlier restriction to 44 was justified by a second displacement of the mode
that the aliasing result shows does not exist. The **maximum absolute difference is 0.0882, the
median is 0.00413, and the maximum relative difference is 14.64%**.

**Those figures are larger than the ones this paragraph used to carry**, which were 0.0351, 0.00093
and 4.73% over the 44-scenario subset. The aliased scenarios are where the two approximations differ
most, because the shift moves $\theta^{*}$ further from the prior center and the mode is pulled
further back. Reporting the smaller number would have meant keeping a restriction that was excluding
the worst cases. **A 14.64% relative gap is a real limitation of the registered quantity** and
section 9 carries it.

Effective rank is unaffected, being a property of the information matrix directly.

## 9. What this cannot settle

- **Nothing here is confirmatory**, per section 1.
- **E2's contraction figures describe a Gaussian approximation** to a non-Gaussian posterior, and
  section 8 measures how far it sits from its Laplace analogue: up to **14.64%** in relative terms.
  That is the largest single caveat on any E2 number.
- **The aliasing result is a property of these five states, not a theorem.** It holds because each
  departure happens to touch exactly the target-bearing rows. A state where a departure reached some
  of them and not others would be genuinely misspecified, and E2's coverage calculation would not
  apply; `R/07-run-e2.R` stops rather than reporting one.
- **E1's diagnostics are conditional on the expected covariate design.**
- **The curvature state's conclusions hold only under equal target-study baselines**, and the route
  list is not claimed to be complete.
- Additivity is assumed in three of four E1 states; the synergy arm prices that conditionality
  rather than removing it.
- One continuous covariate, one binary component structure, one target component.
- Conditional estimand only. Nothing is claimed about a target-population marginal contrast.
- Numerical summaries only; a plot read by an analyst is a different instrument.
