# Protocol: what would the two summaries CMP-14 asks for actually tell an analyst?

**Target problem.** CMP-14 *Aggregate-data-only interactions may be prior-driven*. Bears in part
on IDN-06 *ML-NMR interactions can rest solely on aggregate-data variation*.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Change history is in [`CHANGES.md`](CHANGES.md), not here.** Eight rounds of critique returned
**143** fatal and serious findings between two reviewers, counted as returned rather than
deduplicated. The recurring one was an internal inconsistency: a claim withdrawn in one section and
still standing in another, which came from rewriting this document in layers. **Every position is
now stated once**, and what it replaced is in the history.

**Provenance, stated for what it does rather than for what it sounds like.** **The assertion is the
guarantee; emission is a convenience.** `R/05-export.R` writes every quantity this document quotes to
`results/registered-design.json`. `review/verify-protocol.py` then checks the document against that
file, currently **172** assertions, and that is the link that catches a stale or invented number.
`review/emit-tables.py` regenerates a handful of sentences from the same export so they need not be
retyped; it covers **some** numbers, not all, and **it now fails when one of its patterns matches
nothing** rather than reporting success. Round 6 found it targeting a sentence an earlier rebuild had
deleted, so it had been a no-op while the document named it as a link in a chain.

Two staleness guards, both of which have fired in anger: the exporter refuses to run when an artifact
is older than the code that produces it, and the verifier refuses to run when the export is older
than the code. **The verifier is not a proof that the document is right.** It checks the values it
was told to check; round 6 found five assertions that had been written as "the document contains this
sentence" and were therefore pinning withdrawn claims in place.

---

## 1. Registration status, stated before anything else

Nothing in this study is confirmatory. That is a real limitation and it is stated first rather than
qualified later.

- **E1 was computed before this document existed.** Its grid, estimands, diagnostics and thresholds
  are fixed in `R/00-config.R`, but earlier probes were read while choosing them and the analysis
  ran before the protocol. **E1 is exact and exploratory.**
- **E2 has no confirmatory standing either.** Its separation rules were rebuilt in round 3 after its
  output had been read. **Every part of E2 is exploratory.**
- **The candidate statistic is post hoc in both of its forms**, `surv_between` and `surv_sd`, defined
  in section 5. Neither was registered in advance, and neither carries the standing of the two
  summaries CMP-14 asks for. Every outcome that reports it says so on the row.

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
runs from **0.2506 to 0.3760** across the registered grid. An earlier version gave
0.2913 to 0.3291, measured on a slice at SD ratio 2.0, **which is not a registered level at all**;
the guard now sweeps the distinct cells of `build_grid_e2()` itself. An earlier version of this document said
placebo arms sit at prevalence 0.3, which is true nowhere. `R/07-run-e2.R` computes the range over the
registered grid and **stops the run if any arm comes within 5e-5 of 0.3**, which is the precision
this document quotes it to. An earlier version stopped only on exact equality, which floating point
makes almost inert: every arm could sit at 0.2999 with the guard silent and this sentence false. The two models are different and the sections that use
them say which.

**$\sigma^2$ is fixed and known** at $\sigma = 1$. That is not incidental: the closed-form posterior
covariance $(I + P_0)^{-1}$ used throughout E1 holds for a Gaussian model with known residual
variance and a Gaussian prior on the coefficients. If $\sigma$ were estimated the coefficient block
would not be that expression and E1 would not be exact.

**The true values, in full, because coverage is a performance measure against a truth.** The grid
registers the *departures* from the truth; these are the truth they depart from.

| quantity | true value |
|---|---|
| $\Gamma_k$, **every** component's effect modification, target and background alike | **0.4** |
| $\delta_k$, every component's main effect | $-0.5$ |
| $\beta$, the prognostic slope | 0.3 |
| $\sigma$, known | 1 |
| $\alpha_s$, every study intercept, E1 | 0 |
| $\alpha_s$, every study intercept, E2 | $\operatorname{logit}(0.3) = -0.8473$ |

**All four interactions are 0.4, not just the target's.** An earlier version of this table said
components 1, 2 and 4 had zero modification, which `theta_true()` has never done. That was typed here
rather than read from the code, and the exporter repeated the same typed zero, so the verifier
certified a truth the simulation does not use; recomputing under the declared zeros moves E1 coverage
by up to 0.44 and reclassifies 11 scenarios. **The whole vector is now read off `theta_true()` on a
built design.** Components 1, 2 and 4 are background because their *information state* is held at
`own_ipd`, not because their effect modification is zero, and the two are different things.

**The estimand is the within-study effect modification $\Gamma_W$ in the data-generating
mechanism**, not a separate model parameter. The fitted model carries **one** $\Gamma$ per
component. When the between-study association differs from the within-study one, that single
coefficient **estimates a different quantity rather than becoming wrong**: the likelihood is
satisfied exactly at $\Gamma_W + \text{shift}$, and the size of the resulting error is what the study
measures. **Section 8 establishes this for E2** (worst pointwise gap 2.22e-16 against a registered
tolerance of 1e-12). **E1's version is established separately**, in `R/09-smoke.R`: E1's exact
Gaussian bias, computed with no aliasing algebra in it at all, equals the same
$\text{shift} - [(I+P_0)^{-1}P_0\theta^{*}]_{\Gamma_3}$ expression to **1.6e-15** over 40 scenarios,
and `mean_true` equals $X\theta^{*}$ to **1.8e-15**. Saying "section 8 establishes it on both arms"
pinned an E1 claim on an E2-only measurement. Calling
the estimand $\Gamma_{W,3}$ elsewhere suggested the model contains $\Gamma_W$ and $\Gamma_B$
separately; it does not.

## 3. The information states

| state | route to $\Gamma_k$ | assignment | extra assumption | E1 | E2 |
|---|---|:--:|:--:|:--:|:--:|
| `own_ipd` | its own individual-data trial | randomized | none | yes | yes |
| `additivity` | only inside the combination $1{+}k$, alongside an arm for 1 | randomized | additivity | yes | yes |
| `ecological` | only in aggregate studies, via the between-study contrast in covariate means | **not randomized** | none | yes | yes |
| `curvature` | two aggregate studies, same covariate mean, different covariate SDs | **not randomized** | none | — | yes |
| `absent` | nothing | n/a | n/a | yes | yes |

**Assignment and validity are separate columns, because they are separate questions.** The table once
had a single "randomized?" column with `additivity` answering "yes, if additivity holds", which fuses
them: a combination trial is randomized whether or not additivity holds, and the assumption is what
makes the *route* valid, not what makes the *trial* randomized. A first repair moved the qualifier
inside the same cell, which left validity in the column and was no repair at all. **The study's
thesis lives in the assignment column alone**: the aggregate routes are non-randomized, which is a
different and worse thing than being assumption-laden.

The target is component 3 throughout. Components 1, 2 and 4 stay in `own_ipd`. **Every state's
target studies carry three arms**, so every state has twelve arms, an identical shared background
and the same per-arm size at a given budget. **`R/06-nonlinear.R` computes the arm count and the
per-arm size for every state and stops the run if they differ**, because this sentence was true of
the linear states and false of `curvature`, which ran at ten arms and 300 per arm through five
rounds of critique until both round-6 reviewers found it independently.

**The map, because "twelve arms" does not show that the constraints are jointly satisfiable.** Three
background studies supply individual data on components 1, 2 and 4, **two arms each, six arms in
total, not nine**; two target studies carry three arms each. Every state shares that background
exactly.

| study | supplies | arms | in `own_ipd` | in `additivity` | in `ecological` / `curvature` | in `absent` |
|---|---|---|---|---|---|---|
| 1–3 | IPD | 2 each | `PBO, 1` · `PBO, 2` · `PBO, 4` | same | same | same |
| 4–5 | see right | 3 each | IPD, `PBO, 1, 3` | IPD, `PBO, 1, 1+3` | **aggregate**, `PBO, 1, 3` | IPD, `PBO, 1, 2` |

**`absent` is in the table because leaving it out made the twelve-arm invariant uncheckable for the
one state whose route is "nothing".** It keeps two three-arm individual-data target studies and
simply never mentions component 3, so it is neither a smaller study nor one whose background arms are
sized differently. Its third arm is component 2, which is already identified by study 2, so the arm
adds size without adding a route to the target.

`R/06-nonlinear.R` asserts all four constraints at once: every background study supplies IPD, **no
background arm carries the target**, the background is identical across states, and the
aggregate-only states supply no individual data on the target. So components 1, 2 and 4 are in
`own_ipd` in every state, and **in `ecological` and `curvature`** component 3 is aggregate-only,
inside a fixed twelve-arm geometry, with no leakage. In `own_ipd` and `additivity` the target's
studies are themselves individual-data; that is what those states are.

**The per-arm size is an information weight and is not rounded to a patient count.** Nothing here
simulates individuals: every quantity is an exact Fisher information computed with $n$ as a weight,
so at budgets of 1000 and 10000 the per-arm size is $83.\overline{3}$ and $833.\overline{3}$ and
stays that way. "Total patients per network" is a label for that scale. Rounding would put an
artifact into an exact computation and buy nothing.

## 4. The aggregate routes, and the restriction the curvature state needs

On a curved link, **each of the three nuisance quantities this design has** identifies the
interaction on its own. `R/08-routes.R` isolates each with the others held exactly equal, and asserts
every cell:

| between-study difference | identity link | logit link |
|---|:--:|:--:|
| none | not estimable | not estimable |
| covariate **means** | estimable | estimable |
| covariate **SDs** | not estimable | **estimable** |
| baseline **risks** | not estimable | **estimable** |

So there are three aggregate routes. The mean route works on **both links checked here** and is the
classical ecological one; the other two are nonlinear-only. "Both links checked" rather than "any
link", because the table is an existence result on the identity and logit links and not a theorem
about link functions.

**"Any" would be a stronger claim than three examples support, and the document used to make it.**
What is checked is one nonzero contrast in each of the three quantities a study in this design can
differ in, on a fixed geometry, with no general rank argument and no sweep over contrast sizes.
Nothing here rules out a fourth nuisance quantity in a richer design that identifies nothing, or a
contrast size at which one of these three fails numerically. The table is an existence result for
three routes, which is all the thesis needs and is less than the word "any" promised.

**The `curvature` state therefore requires equal target-study baselines, and that restriction is
registered rather than assumed.** With unequal baselines, equal SDs already identify the target, so
the variance contrast is one nonlinear route among several rather than the unique one.
`R/06-nonlinear.R` asserts both halves: the claim holds under the restriction and fails without it.

**"Baseline" here means the study intercept $\alpha_s$, not arm-level prevalence, and the two are
not the same thing.** The curvature state's two target studies share an intercept and differ in
covariate SD, so their placebo *arm* prevalences differ: **0.3099 against 0.3141 at SD ratio 1.5, and
0.3099 against 0.3321 at SD ratio 3.0**, the two ratios at which the mechanism operates. The rank
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

**CMP-14 asks for two summaries and they produce three rules.** The two are prior-to-posterior
contraction per interaction parameter, and an effective likelihood rank. The rank has a whole-model
reading and a per-parameter one, and both are reported because a model-level count can be high while
the single coordinate an analyst cares about is prior-driven. **The title's "two" is the catalog's
two; the table's three are their implementations.** Until round 6 the exported warning table carried
the per-parameter numbers under the whole-model name and the whole-model count controlled no
decision at all.

**Every precision *entering the ratios* is prior-free**, meaning $1/[I^{-1}]_{gg}$ from the
likelihood alone and exactly zero where the likelihood does not identify the coordinate. Computing it
from a prior-regularized inverse credits the likelihood with identification the prior supplied.
**`contraction` is the exception and is not a prior-free quantity**: it is a posterior SD over a
prior SD, so it uses $(I + P_0)^{-1}$ by construction. That is not an oversight in the diagnostic; it
is what makes contraction the summary most exposed to CMP-14's own question.

**`source_survival` is not a share and asking for one is ill-posed.** No single source identifies the
target in every state, so a parameter's precision cannot be apportioned among sources. Asking how
much survives deleting a source needs no additivity and no prior.

**Where the likelihood identifies nothing, the survival ratio does not exist and is reported as
undefined.** In all `absent` scenarios the target's full likelihood precision is exactly zero, so the
ratio has a zero denominator. Two code paths used to disagree about that: the overlap table
substituted **zero**, putting an invented value at the alarming end of the candidate's range, while
the warning rule read the missing value as an **alarm**. Neither is the registered rule
`surv_between < SOURCE_OK`. **Both now report undefined and exclude the row**, so the candidate's
comparison runs on 402 scenarios with **18** excluded and its warning
on the same basis with **72** excluded. Nothing is lost by this: a coordinate the
likelihood does not identify at all is exactly what `rank_screen` exists to flag, and it does.

**It has exactly two forms, both survivals, both reassuring when high.** `surv_between` deletes the
between-study source and reports what the within-study rows still identify; `surv_sd` flattens the
aggregate covariate SDs and reports what the remaining routes still identify. An earlier version
computed the second as the fraction *lost*, so a value of 1 meant zero survival where this definition
says complete survival, and the document referred to "three forms" without ever defining a third.
The registered warning rule uses `surv_between`.

**Registered thresholds, each bound to one rule with its alarm direction written as an inequality.**
Round 7 found the thresholds listed without saying which rule each governs or which side alarms, so
"at the registered thresholds" did not name a decision rule at all.

| rule | alarms when | threshold | why that value |
|---|---|---|---|
| `contraction` | $\ge$ `CONTRACT_OK` | 0.50 | the conventional halving of the prior SD |
| `target_ratio` | $<$ `EFF_RATIO_OK` | 1.00 | the likelihood is worth less than the prior along the target's own direction |
| `eff_rank` | $<$ the parameter count | none | **not a tuning choice**: the count is the model's own $p$, so the rule is "the data fail to dominate the prior somewhere" |
| `rank_screen` | not estimable | none | structural |
| `source_survival` | $<$ `SOURCE_OK` | 0.50 | **a stipulation**, since the statistic is introduced here |

**`EFF_RATIO_OK` is the one "likelihood outweighs prior" cutoff and both rank summaries use it, at
different levels.** `target_ratio` compares the likelihood's marginal precision to the prior's along
the target's own coordinate and alarms below it. `eff_rank` counts the eigendirections of
$P_0^{-1/2} I P_0^{-1/2}$ that exceed it, and its *warning* then compares that count to the parameter
count $p$, which is why the warning rule carries no threshold of its own. An earlier version of this
paragraph said `EFF_RATIO_OK` governs `target_ratio` only; `eff_rank()` takes it as `thresh` in both
`diag_eff_rank()` and the E2 evaluator, so the denial was false. **What round 6 separated is the two
rules and their outputs, not the constant**, and one cutoff for one concept is the right design. The
first two thresholds are conventional; **`SOURCE_OK` cannot be**, and it is labeled a stipulation
wherever it appears.

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
`PRIOR_SD_NUISANCE = 10`.

**Its inertness is an exploratory diagnostic with a stated rule, not a property of the design.** The
rule: rerun the whole grid at nuisance scales 3 and 30 and compare against the registered scale of 10,
**on the registered DECISIONS, not on selected magnitudes**. The decisions are the failure label, the
nominal label and all five warning rules, which is **3,528** binary
classifications across the grid. **0 flip at scale 3 and 0 at scale 30.**

Round 7 found the earlier version of this rule checking three quantities while claiming to check
every reported one, and judging a contraction movement against the 0.05 *coverage* scale, which is a
different quantity's threshold. Magnitudes are still reported as supporting detail, worst moves
**0.0005 in coverage, 0.0001 in contraction and
0 in `surv_between`, `target_ratio` and `eff_rank`**, but the claim rests on
the flip count, because "moves nothing this study decides on" is a statement about decisions.

**That is a post-data check, it ran with the rest of E1 before this document existed, and it carries
exactly the standing section 1 gives everything in E1.** Saying "its inertness is measured rather
than asserted" without the rule or the tolerance presented a measurement as a guarantee.

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

**Every number in this section is exploratory, on both arms.** Section 1 says so globally; round 7
pointed out that a reader arriving at an outcomes section and finding $\rho = 0.3295$ and a
false-alarm rate of 0.0355 reads them as the study's results, and a global disclaimer eight sections
earlier does not travel with the sentence. The repair then said "every number in this section is an
**E1** number", which was false in the same paragraph that primary 3 reports an E2 correlation, and
round 8 caught it.

**E1 ran before this document existed. Every E2 rule was rebuilt after E2's output had been read.**
Neither arm is confirmatory and the E2 row is not the safer of the two. Nothing below is a
confirmation of anything; each is a measurement whose grid and outcome definitions were chosen with
earlier numbers already seen.

**Three classes, named once and used everywhere.** A scenario **fails** if coverage is below
`COVER_BAD = 0.90`. It is **nominal** if coverage is within `COVER_TOL = 0.01` of 0.95. Everything
else, the band between 0.90 and nominal and everything above nominal, is **neither**, and no outcome
in this study counts it on either side.

**Gross overcoverage is in `neither`, not in `failed`.** An earlier version of this paragraph called
it "a different failure" while the code has only ever tested `coverage < COVER_BAD`, so the word
"failure" named a set that was not the failure set. It is a real defect of an interval and it is not
the defect this study measures, so it is excluded rather than reclassified. Reclassifying it would
need an upper band nothing here registers.

**Primary 1, an existence claim no weighting can move.** For each statistic, does the range of values
taken by failing scenarios overlap the range taken by nominal ones? One value compatible with both
establishes that no threshold separates them. Reported over the **comparison set**, the failing plus
the nominal scenarios; the intermediate and over-covering bands belong to neither side and are
excluded from the denominator as well.

**The answer, which this section did not previously state: every statistic overlaps, on both arms.**
On E1, over 251 failing and 169 nominal
scenarios, and on E2 over 41 and 12.
**No threshold on contraction, on either effective-rank reading, on the estimability screen or on the
candidate separates failing coverage from nominal coverage.** That is the study's central negative
result and section 7 had been reporting the secondary numbers and primary 3 without it.

**Primary 1 covers the three CMP-14 rules and `rank_screen`. `source_survival` appears in the same
table and is not a primary result.** It is this study's own post hoc candidate, and giving it the
same standing as the summaries the catalog asks about would be confirmatory packaging of a quantity
section 1 concedes was never registered. Its row is marked exploratory in the exported table and any
claim resting on it is labeled as such.

**Primary 2, with its decision rule registered rather than left to the code.** `additivity` against
`ecological`, matched on spread, total patient budget and prior scale, with synergy off. **Discordance
is deliberately NOT a matching key and is free on the `ecological` side**, so one `additivity`
scenario pairs with every `ecological` scenario sharing its three keys. That is the point: the
comparison is between a randomized route and a confounded one, and fixing discordance at zero would
remove the confounding the contrast exists to price. The rule is `key = (spread, n, prior_sd)` in
`state_pairs()` and it was unstated until round 8. Within that matched set, take the pairs whose **contraction differs by less than `PAIRS_CLOSE_TOL = 0.02`** and
report the **maximum absolute coverage gap** across them, which is **0.951**.
The claim is that two evidence structures a reader would call identically well identified differ by
**at least that much** in whether the interval covers. An earlier wording said "arbitrarily", which a
finite maximum over a finite grid cannot establish.

The tolerance is absolute closeness, and **that is not the same as displaying identically**. An
earlier version justified 0.02 by saying two contractions within it are "the same number to anyone
reading a diagnostic to two decimals"; only **15 of the
54** pairs passing the filter actually round to the same two decimals, and the pair
producing the largest coverage gap is not among them: its contractions are
**0.067771 and 0.081321**, which display as 0.07
and 0.08.

**The claim survives the stricter reading almost unchanged**, which is why the filter stays as
absolute closeness rather than being redefined after the fact. Over the
15 display-identical pairs the maximum coverage gap is
**0.95**, against
**0.951** over all 54. Both are reported and both are
exported.

**The tolerance was typed into the analysis and the exporter and registered in neither** until round
7, which made an unregistered filter part of a primary outcome; it now lives in `R/00-config.R` and
both files read it from there.

**Primary 3, one correlation over the confounded family, computed separately on each arm.** The rank
correlation between contraction and coverage across every `ecological` scenario with nonzero
discordance, **pooled, not stratified by discordance level**. **Low contraction is the reassuring
value, so a POSITIVE correlation means the diagnostic becomes more reassuring as the answer gets
worse.**

| arm | scenarios in the confounded family | $\rho$ |
|---|---:|---:|
| **E1**, exploratory and computed before this document existed | 144 | **0.3295** |
| **E2** | 8 | **-0.5952** |

**The two arms disagree, and that is the substantive reason this had to be split.** E1's correlation
is positive, so contraction there becomes *more* reassuring as coverage gets worse. E2's is
**negative**, so on the logit link over its eight confounded scenarios contraction moves the way an
analyst would hope. Quoting a single $\rho$ under one heading fused a pre-protocol E1 number with an
E2 deliverable that had no $N$, and in doing so it concealed a disagreement rather than an agreement.

**Neither number settles anything, and the eight-scenario one settles less.** A rank correlation over
eight deterministic points is a description of eight points; it has no sampling distribution here and
no confidence statement attaches to it. What the split establishes is that **the E1 finding does not
reproduce on the nonlinear arm**, which is a limitation of the finding and is carried in section 9.

Until round 6 only the per-level correlations were computed, 0.2232 at discordance 0.15 and 0.5119 at
0.40, and the registered pooled value existed nowhere. Stratified and pooled rank correlations can
differ in sign, so this mattered whether or not it changed the answer. **Here it does not: all three
are positive and the strata agree with the pooled reading**, which is now asserted rather than
observed.

**Secondary, and grid-weighted.** Sensitivity, false-alarm rate and Youden index at the registered
thresholds. These are averages over a chosen grid and are labeled as such.

**The false-alarm denominator is the nominal scenarios, not "everything that did not fail".** Failure
is one-sided at `COVER_BAD`, while primary 1 excludes the intermediate and over-covering bands from
both sides; using `!failed` here counted 84 scenarios as successes that primary 1 refuses to call
successes. **This change flatters the diagnostics and is reported for that reason**: the contraction
rule's false-alarm rate falls from 0.3043 to 0.0355 under the corrected denominator, and the old
value is exported alongside the new one so the size of the correction is visible.

## 8. E2: the nonlinear arm

Asymptotic, **not fitted**. No model is sampled and no sampler policy exists because none is needed
for an information calculation.

**E2's grid, which was previously described only as "a reduced factorial".** Five states $\times$ two
spreads $\{0.6, 2.0\}$ $\times$ three SD ratios $\{1.0, 1.5, 3.0\}$ $\times$ two discordances
$\{0, 0.4\}$ $\times$ two budgets $\{3000, 10000\}$ $\times$ two prior scales $\{0.1, 1.0\}$
$\times$ two synergies $\{0, 0.2\}$, cut by four structural restrictions: synergy acts only on
`additivity`, discordance only on `ecological` and `curvature`, the SD ratio only on `curvature`, and
`curvature` runs at the first spread alone because it holds covariate means equal by construction.
**That leaves 72 scenarios.** The levels are a subset of E1's, chosen where E1 found the conclusion
turns, plus the SD ratio that `curvature` needs.

**Neither departure is misspecification, so coverage is reported on all 72 scenarios.** Discordance
adds its amount to the target modification in the *aggregate* rows carrying the target, and in
`ecological` and `curvature` the target appears in no other row. Synergy adds its amount **to the covariate slope** of arms
holding components 1 and 3 together, $\eta \mathrel{+}= \text{synergy}\cdot x$, so it is
interaction-shaped rather than a main-effect offset; in `additivity` the target appears in no other
arm. **That shape is what makes the aliasing work**: a constant add-on would be collinear with an
intercept and could not be absorbed into $\Gamma_3$, and an earlier wording said only "adds its
amount to arms", which describes the wrong departure. In both
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
had removed exactly the scenarios the study exists to examine, and it left **primary 3** uncomputable
on E2. **Primary 2 was never blocked by it**: primary 2 matches `additivity` against `ecological`
with synergy off and does not require nonzero discordance, so its eight scenarios per state sat at
discordance zero and inside the old 44 the whole time. An earlier version of this paragraph named
both primaries, which overstated what the restriction cost.

**Contraction in E2 is contraction of a normal approximation whose covariance is
$(I(\theta^{*}) + P_0)^{-1}$**, the expected Fisher information **at the parameter the data come
from** plus the prior precision. On the 44 undisturbed scenarios $\theta^{*} = \theta_{\text{true}}$
and the two names coincide; on the 28 aliased ones they do not, and the code has evaluated at
$\theta^{*}$ since the aliasing result. This sentence named $\theta_{\text{true}}$ for one round
after the code stopped using it.

**It is not a Laplace approximation**, which would invert the Hessian of the log posterior at the
posterior *mode*. An earlier version of this document called it one. The two coincide when the
information does not depend on the parameter, which holds on an identity link and fails on the logit
link E2 uses, and when the mode equals the data-generating parameter, which a proper prior centred at
zero makes false by construction.

**The registered quantity is the one evaluated at the data-generating parameter, deliberately.** E2
is an exact information calculation with no data and no sampling, so evaluating there is
deterministic and is a property of the design rather than of a realized dataset. A Laplace covariance
would make the diagnostic depend on where the prior happens to pull the mode, which is the prior's
behavior and not the design's.

**The gap is measured rather than admitted.** `R/09-contraction-gap.R` solves for the mode under data
at their expectation **under the parameter the data come from**,
$U(\theta;\,\mathbb{E}[y \mid \theta^{*}]) = P_0\theta$, by Newton
iteration and recomputes the contraction there, at $\theta^{*}$ where a departure acts. It runs on
**all 72 scenarios**; the earlier restriction to 44 was justified by a second displacement of the mode
that the aliasing result shows does not exist. The **maximum absolute difference is 0.1212, the
median is 0.00615, and the maximum relative difference is 20.11%**.

**The comparator is the OBSERVED Hessian, not the Fisher information at the mode.** For an aggregate
arm the log-likelihood's second derivative carries a residual term proportional to $q - p$ times the
curvature of the arm probability, which vanishes only where the model sits at the data-generating
parameter. A proper prior moves the mode, so it does not vanish there. Round 7 found this file
inverting `logit_info()` at the mode and calling the result Laplace; that is **Fisher-at-mode**, and
Fisher scoring finds the right root with the wrong curvature. Individual-data arms need no
correction, since for a canonical link the observed and expected Hessians coincide.

**This figure has now grown twice, each time because a correction removed something that was hiding
the worst cases.** It was 0.0351 and 4.73% over the 44 correctly-specified scenarios; restoring the
28 aliased ones took it to 0.0882 and 14.64%; using the real Hessian takes it to
**0.1212 and 20.11%**. **A 20.11% relative gap is a
real limitation of the registered quantity** and section 9 carries it.

**Effective rank is affected too, and by how much is measured rather than asserted.** It is a property
of the information matrix, so replacing the Fisher information with the observed Hessian at the mode
moves it: **6 of the 72 scenarios change their count and 2 flip the `eff_rank < p` warning**. An
earlier version of this sentence said it was unaffected, which treated "a property of the information
matrix" as if it meant "a property invariant to which matrix". `eff_rank` is one of the six
comparisons that can withdraw E1's conclusion, so this is a limitation of that verdict and not a
footnote.

### E2's separation rules, and what withdrawing E1's conclusion would take

These were rebuilt in round 3 after E2's output had been read, which is why section 1 calls every
part of E2 exploratory. They were also stated nowhere in this document until round 7, so the E2
verdict could not be reconstructed from the registration.

**Six comparisons**, each of the three CMP-14 rules against each of two states:

| statistic | compared across |
|---|---|
| `contraction`, `target_ratio`, `eff_rank` | `additivity` against `ecological` |
| `contraction`, `target_ratio`, `eff_rank` | `additivity` against `curvature` |

A rule **separates** two states when the ranges of its per-scenario values over those states do not
overlap, that is when the smaller state's maximum is below the larger state's minimum. Range
separation rather than a test, because E2 is deterministic and has no sampling variation to test
against.

**`curvature` rows at SD ratio 1.0 are excluded from these comparisons.** That level is the state's
negative control: with equal aggregate SDs the target is not identified at all, so including those
rows would let a state that identifies nothing masquerade as a separated one.

**None of the six separates**, which is the E2 result. One separation anywhere would have been enough,
so the rule cannot be satisfied by averaging a real one away.

**But state separation is not E1's conclusion, and calling this rule a withdrawal criterion for E1
was wrong.** E1's conclusion is primary 1: no threshold on any summary separates failing coverage
from nominal coverage. Whether the summaries separate the *information states* is a different
proposition, worth registering on its own, and it cannot withdraw a primary it does not test.

**E1's actual conclusion is now tested on E2, because it can be.** Coverage exists on all 72
scenarios after the aliasing result, so primary 1's overlap test runs on E2 unchanged, over
**41 failing and 12 nominal** scenarios.
**Every statistic overlaps on E2 as well**, so E1's conclusion **reproduces on the nonlinear link**.
That is the registered bridge between the arms, and it points the other way from primary 3, which
does not reproduce.

## 9. What this cannot settle

- **Nothing here is confirmatory**, per section 1.
- **E2's contraction figures describe a Gaussian approximation to a non-Gaussian posterior, and the
  distance to that true posterior is not measured anywhere.** What section 8 measures is the gap
  between two *Gaussian* approximations, the registered Fisher-at-$\theta^{*}$ one and a Laplace one
  from the observed Hessian at the mode: up to **20.11%** in relative terms. An earlier version of
  this bullet chained the non-Gaussian worry to that number and called it the largest caveat, which
  offers the wrong reference quantity as a bound. **The 20.11% bounds the choice of Gaussian; it does
  not bound Gaussianity.**
- **The E1 finding does not reproduce on the nonlinear arm.** Primary 3's rank correlation between
  contraction and coverage is $+0.3295$ over E1's 144 confounded scenarios and $-0.5952$ over E2's 8.
  The signs are opposite, so the inversion E1 reports is not a property of the diagnostic that
  survives a change of link in this design. Section 7 promised this limitation would be carried here
  and round 8 found it absent.
- **Effective rank is not invariant to the curvature used.** 6 of 72 E2 scenarios change their count
  and 2 flip the warning under the observed Hessian at the mode rather than the Fisher information,
  and `eff_rank` is one of the six comparisons that can withdraw E1's conclusion.
- **The aliasing result is a property of these five states, not a theorem.** It holds because each
  departure happens to touch exactly the target-bearing rows. A state where a departure reached some
  of them and not others would be genuinely misspecified, and E2's coverage calculation would not
  apply; `R/07-run-e2.R` stops rather than reporting one.
- **E1's diagnostics are conditional on the expected covariate design.**
- **The curvature state's conclusions hold only under equal target-study baselines**, and the route
  list is not claimed to be complete.
- Additivity is the identifying assumption of **one** E1 state, `additivity`, which is the only one
  whose target route runs through the $1{+}3$ combination; the other three use singleton-component
  arms and the grid accordingly permits synergy only there. The synergy arm prices that
  conditionality rather than removing it. An earlier version said three of four states, which no part
  of the design or the code supports.
- One continuous covariate, one binary component structure, one target component.
- Conditional estimand only. Nothing is claimed about a target-population marginal contrast.
- Numerical summaries only; a plot read by an analyst is a different instrument.
