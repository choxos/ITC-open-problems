# COV-03 design: what an anchored comparison must balance on a non-collapsible scale

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's own note is the design constraint: *focus on non-collapsible
marginal effects because the collapsible-scale result is already established and
would make a repetitive study.* Section 2 goes further and says what the
non-collapsible answer should be, in one scalar, before anything is simulated.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** covariate role is a function of the estimand and the
scale, not of the variable. On a conditional or collapsible scale in an anchored
comparison, balancing a strong prognostic non-modifier spends effective sample
size without removing bias. On a non-collapsible scale it does not: a variable
purely prognostic conditionally still changes the marginal effect, so cross-study
imbalance in it biases an anchored marginal comparison even when marginal
covariate moments are balanced (Remiro-Azócar 2024,
[doi:10.1002/sim.10111](https://doi.org/10.1002/sim.10111)).

**Refuting sentence:** *the non-collapsibility contribution is second order and
dominated by the effective-sample-size cost at realistic prognostic strengths, so
the collapsible-scale guidance is right in practice even though it is wrong in
principle.*

## 2. The mechanism, algebraically, and it identifies one scalar

Take a correctly specified conditional logistic model with **no effect
modification at all**: $\eta = \alpha + \gamma^\top x + \delta A$. The marginal
log odds ratio in a population with covariate law $F$ is

$$\Delta(F) \;=\; \mathrm{logit}\!\int\!\mathrm{expit}(\alpha + \gamma^\top x + \delta)\,dF \;-\; \mathrm{logit}\!\int\!\mathrm{expit}(\alpha + \gamma^\top x)\,dF .$$

Expand about the mean of the **prognostic index** $u = \gamma^\top x$. The
first-order terms cancel between arms because $\delta$ shifts both integrands
identically; the second-order terms do not, and they are weighted by
$\mathrm{Var}_F(u)$. To second order,

$$\Delta(F) \;\approx\; \delta \cdot \big\{1 - c(\alpha,\delta)\,\mathrm{Var}_F(u)\big\}$$

with $c > 0$ set by the curvature of $\mathrm{expit}$ at the population's average
risk. Three consequences, each a prediction:

1. **$\Delta(F)$ depends on $F$ only through the variance of the prognostic
   index, not through its mean.** A purely prognostic variable enters $u$ through
   $\gamma$, so it moves the marginal effect. That is Remiro-Azócar's result, with
   the scalar responsible named.
2. **Balancing prognostic *means* is therefore the wrong operation.** It is what
   MAIC does, it cancels from the contrast at first order anyway, and it costs
   effective sample size for nothing. **The quantity that needs balancing is
   $\mathrm{Var}(u)$**, and no PAIC method balances it, because no method
   constructs $u$.
3. **Attenuation is toward the null and grows with prognostic strength**, so the
   bias direction is predictable rather than arbitrary, and a study that finds
   bias away from the null has found something other than this mechanism.

**Prediction 2 is the study's reason to exist.** It converts "should we adjust for
prognostic variables?" from a yes/no question into a different operation, and it
is falsifiable: matching the index variance should remove the bias that matching
the covariate means does not.

**Unanchored comparisons are the contrast case.** There the prognostic mean does
not cancel, because there is no common comparator arm, and omitting prognostic
variables biases on any scale. That arm is included so the anchored result is not
mistaken for a general one.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio for the indirect
comparison, anchored.

**Secondary.** The target-population marginal log hazard ratio, the other
non-collapsible case, in a Weibull PH arm; and the marginal risk difference,
collapsible, as the reference case where the established guidance should hold.

**True value.** By quadrature over the true target law with the true conditional
model, at an order fixed by P1. **Not** by transforming a conditional coefficient:
that transformation is exactly the non-collapsibility error the study is about.

**$\mathrm{Var}_T(u)$ and $\mathrm{Var}_S(u)$ are recorded per replicate** and
their difference is the predicted driver, so section 2 is checked rather than
assumed.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| design | anchored; unanchored | the split that section 2 says holds only on collapsible scales |
| scale | risk difference; log OR; log HR | one collapsible reference, two non-collapsible |
| prognostic strength $\|\gamma\|$ | 3 levels spanning $\mathrm{Var}(u) \in \{0.25, 1, 4\}$ | the driver in section 2, parameterized in the scalar itself rather than in a proxy |
| cross-study index-variance gap | $\mathrm{Var}_T(u)-\mathrm{Var}_S(u) \in \{0, 0.5, 1.5\}$ | **the axis prediction 1 says matters**, held separate from the mean gap |
| cross-study mean gap | 0, moderate, large | the axis current practice balances, crossed with the above so the two are not confounded |
| effect modification | absent; present | absent isolates the pure prognostic mechanism; present is the realistic mixture |
| overlap | moderate, poor | the ESS cost side of the trade-off |

**Crossing the index-variance gap against the mean gap is the design's whole
point**, and no existing study does it: they move a covariate's distribution and
therefore move both at once.

### What the mechanism makes true, and therefore what the study cannot see

- The conditional model is correctly specified. Every effect seen is
  non-collapsibility, not misspecification; MOD-02 owns the latter.
- In the `effect modification: absent` cells there is by construction nothing a
  modifier-based method could adjust for, so those cells cannot be used to argue
  about modifier selection. COV-01 owns that.
- Covariates are continuous and jointly normal in the base arm, so $u$ is normal
  and the second-order expansion is accurate. A skewed arm is included to check
  that the expansion, not just the conclusion, survives.
- Anchored comparisons assume the common comparator behaves identically across
  studies. That is imposed, so nothing here speaks to inconsistency.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| unadjusted anchored | Bucher | the baseline the trade-off is measured against |
| MAIC, modifiers only | balance effect modifiers | current guidance on a collapsible scale |
| MAIC, modifiers + prognostics | balance both | the ESS-spending option |
| **MAIC, index-variance matched** | balance modifiers plus $\mathrm{Var}(u)$, with $u$ built from the source outcome model | **prediction 2, implemented** |
| STC | prognostic main effects separate from interactions, marginalized by simulation | the outcome-model route; `cpaic` already separates these roles |
| augmented weighting | prognostic covariates through the outcome model, no balancing constraint | Campbell and Remiro-Azócar 2025, extended from unanchored to anchored |

**The comparator that can win is augmented weighting.** If it is unbiased and
efficient across the grid without needing the index-variance construction, then
prediction 2 is a curiosity and the recommendation is simply to use an augmented
estimator. Registered as such.

**One arm is a novel construction and is labeled as one.** Index-variance
matching uses a $u$ estimated from the source data, so it carries estimation
error the other arms do not. Its interval must account for that or the comparison
is unfair in its favor; how, is probe P3.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, empirical SD, RMSE, interval width, effective sample size and
its ratio to $n$, per method per cell, each with MCSE.

**The registered mechanism check:** regress observed bias on
$c\cdot\{\mathrm{Var}_T(u)-\mathrm{Var}_S(u)\}$ across cells with no effect
modification. Slope 1 confirms section 2; anything else means the expansion is
not the operative mechanism at these strengths, which is itself the answer to the
refuting sentence in section 1.

Common random numbers across methods; MCSE clustered on the replicate block.

$n_{sim} = 2000$ per cell, from a coverage MCSE target of 0.005.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias in the anchored target-population marginal log odds
ratio, in cells with **no effect modification**, as a function of the index-
variance gap, comparing modifiers-only MAIC against index-variance matching.

That cell is the sharp one: current guidance says there is nothing to adjust for,
and section 2 says there is.

**Decision rule.**

- Modifiers-only MAIC biased by more than 0.05 on the log OR at an index-variance
  gap of 0.5 or more, while index-variance matching is unbiased, **confirms** the
  proposition and establishes the operation.
- Both unbiased at every gap **refutes** materiality and supports the current
  guidance in practice, which is a useful negative result and is reported as the
  headline.
- Bias present but not removed by index-variance matching means section 2's
  expansion is not the mechanism. Reported as such, with no substitute mechanism
  invented after the fact.

**The effective-sample-size cost is reported on the same axis in every branch**,
since the trade-off, not the bias alone, is what guidance needs.

## 8. Three controls, each of which can fail

**Null control.** On the risk-difference scale, with no effect modification, every
method must be unbiased at every index-variance gap. Collapsibility makes this
exact, so a failure here is an implementation fault and the study stops.

**Positive control.** On the log OR scale at maximal prognostic strength and
maximal index-variance gap, the unadjusted anchored comparison must be biased by
at least three MCSEs. If it is not, there is no signal and no downstream
comparison means anything.

**Falsifier for the study's own headline.** The expected headline is that index
variance is the quantity to balance. Its falsifier is a cell where the mean gap
is large and the index-variance gap is zero: there, modifiers-only MAIC must be
**unbiased**, and if it is biased the driver is the mean after all and prediction
1 is wrong.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Index-variance gap and mean gap move together, as in every prior study | Crossed independently; P2 verifies the crossing is realizable | removed if P2 passes |
| Novel arm favored by ignoring its estimation error | P3 fixes the interval construction before the run | pending P3 |
| Repeating the established collapsible result | Risk difference included only as the null control, not as a result | removed |
| Non-collapsibility confounded with misspecification | Conditional model correct by construction | removed |
| Second-order expansion invalid at strong prognosis | Skewed arm plus the registered slope check | removed |
| Anchored/unanchored difference attributed to scale when it is design | Both crossed with all three scales | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Marginal truths on all three scales; the realized $c(\alpha,\delta)$ | The definition of truth | minutes |
| **P2** factor realizability | Covariate laws achieving each (mean gap, index-variance gap) pair with the same marginal support | **The grid.** Moving one without the other may not be achievable in the required range, and if it is not, the design's central manipulation does not exist | hours |
| **P3** inference for the novel arm | A valid interval for index-variance matching that accounts for $\hat u$ | Whether that arm is reportable at all | hours |
| **P4** unit cost | Per-replicate wall clock and the total, computed not typed | The grid | minutes |

**P2 is the one that can kill the design.** If mean and index-variance gaps
cannot be moved independently at realistic covariate laws, this study collapses
into the ones already published, and finding that out before registering is worth
more than the probe costs.

## 11. Cost

Small; GLM and weighting fits. Quoted only after P4.

---

## Relationship to the rest of the queue

- **COV-01** owns modifier selection. This study holds the modifier set correct
  so the prognostic question is isolated.
- **MOD-02** owns functional-form misspecification, switched off here.
- **DIA-06** owns the overlap axis as an estimator-family comparison; the ESS cost
  measured here is the same quantity on a different question.
- **OVL-02** owns whether ESS is a sufficient diagnostic, which is what the cost
  side of this trade-off is denominated in.
- **HET-04** and **EST-12** own target-referent questions that this study's
  estimand definition assumes settled.
