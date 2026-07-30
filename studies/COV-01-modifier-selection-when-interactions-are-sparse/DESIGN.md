# COV-01 design: what significance screening can actually detect

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is a design constraint and it is right: this is highly
important and too broad as stated. **The narrowing is to four selection
strategies, one declared estimand and one design geometry**, and section 2 says
why the sharpest result available is a power calculation rather than a
comparison.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** there is no agreed default for choosing the
effect-modifier set; in the small samples typical of these analyses significance
screening is unstable; balancing on every available covariate can destroy
overlap and exhaust the information available for interaction terms; and the
downstream interval is conditional on a selection event that is never reported.

**Refuting sentence:** *at the modifier strengths that actually matter for a
decision, screening detects reliably and the instability is confined to modifiers
too weak to change any conclusion.*

**Section 2 predicts this refutation fails and says by how much**, which is a
better deliverable than a ranking of strategies.

## 2. The mechanism: an interaction is estimated far worse than a main effect

In a randomized trial of $n$ per arm with a covariate of variance $\sigma^2$, the
main effect of treatment has standard error $\propto \sqrt{2/n}$ while a
treatment-by-covariate interaction has

$$\mathrm{SE}(\hat\beta_{EM}) \;\approx\; \frac{2\,s}{\sigma\sqrt{n}},$$

roughly **twice** the main-effect standard error per unit of covariate spread.
Significance screening at level $\alpha$ therefore has power governed by the
noncentrality

$$\lambda \;=\; \frac{\beta_{EM}\,\sigma\,\sqrt{n}}{2s},$$

**which is computable before any simulation and does not depend on the
selection strategy at all.** Three consequences:

1. **The modifier strength at which screening reaches 80% power is a number**, and
   at HTA-scale trial sizes it is expected to sit well above the strengths that
   change a decision. If so, screening is not unstable in a subtle way; it is
   underpowered in a calculable way, and the honest recommendation follows
   immediately.
2. **Omitting a modifier costs bias $\beta_{EM}\,d$**, linear in the same
   $\beta_{EM}$ that screening has to detect. So the strength at which the bias
   becomes material and the strength at which screening detects it are two
   thresholds on one axis, **and the gap between them is the field's actual
   problem**. Reporting that gap is the study's central deliverable.
3. **Balancing on everything is not monotonically worse.** The catalog is careful
   here and the design must be too: extra balancing constraints usually make the
   weights harder to satisfy and cut effective sample size, **though not
   monotonically**. So covariate count is a factor and the relationship is
   measured rather than assumed.

**Selection conditioning is a separate defect with a separate fix.** An interval
computed after selection on the analyzed data is conditional on the selection
event. That is DEC-11's subject; here it enters only through whether a strategy's
interval is nominal, and the strategies that resample the whole procedure are
included so the two studies join.

## 3. Estimand, with its true value defined

**Primary, and declared because the catalog says the right set depends on the
estimand:** the target-population marginal treatment contrast on the log odds
ratio scale, in an anchored comparison, at a declared target population.

**True value** by quadrature over the target law at an order fixed by P1.

**Two derived estimands.** **Selection stability**, the probability that a
strategy returns the same modifier set on independent replicates of the same
scenario, since the catalog's complaint is that the same evidence base yields
different sets. And **the detection-materiality gap** from section 2 consequence
2, reported as two strengths on one axis.

## 4. Data-generating mechanism, and what it makes invisible

Anchored two-trial geometry at HTA scale, because that is the setting the
complaint is about, and the sample sizes are taken from the reviewed appraisals
rather than chosen.

### Factors

| factor | levels | why |
|---|---|---|
| candidate covariates | 6, 13 | the reviewed median is 6 with a range of 1 to 13, so these are the field's own numbers |
| true modifiers among them | 1, 3 | interaction sparsity |
| modifier strength | 5 levels spanning the power curve of section 2, including the 80%-power point | **the axis the deliverable is stated on** |
| source-target imbalance | small, moderate, large | the multiplier on omission bias |
| overlap | good, poor | the ESS cost of balancing on everything |
| source size | the reviewed appraisals' quartiles | realism, not convenience |

Modifier strength × imbalance fully crossed; the rest reduced by P2.

### What the mechanism makes true, and therefore what the study cannot see

- Every true modifier is among the candidates. **A modifier that no trial
  reported is invisible to every strategy here**, and that is the commonest real
  failure; the study's results are optimistic for that reason and the paper says
  so. Minimum covariate reporting sets, which the catalog proposes, are the fix
  for that case and this study cannot evaluate them.
- Expert elicitation is **not** simulated as a strategy, because there is no
  defensible way to generate it. The oracle set is carried instead as the
  ceiling, which is what a perfect elicitation would give, and the gap between
  the oracle and the best data-driven strategy bounds what elicitation could
  possibly buy.
- Covariates are continuous and measured without error. COV-09 owns measurement
  non-equivalence and CMP-06 owns miscoding.
- Modification is linear and shared across treatments. **DIA-08 owns that
  restriction**, and it is the one this study most obviously inherits.

## 5. Methods, including one that can win

Four strategies, narrowed as the catalog's note requires, plus two reference
points:

| strategy | specification | role |
|---|---|---|
| oracle set | true modifiers | the ceiling, standing in for perfect elicitation |
| all candidates | balance or adjust for everything | the support-destroying extreme |
| significance screening | interaction $p < 0.05$ in the IPD trial | what appraisals do |
| penalized interactions | lasso on interaction terms, main effects unpenalized | the shrinkage route |
| stability selection | subsampled penalized selection with a declared threshold | the stability route |
| **resampled whole procedure** | the chosen strategy re-run inside every bootstrap replicate | the only arm whose interval accounts for selection |

**The comparator that can win is all-candidate adjustment.** If it is unbiased
with acceptable precision across the realistic grid, then the entire selection
problem is avoidable by not selecting, and the recommendation is one sentence.
Registered as such, and section 2 consequence 3 says its cost is not monotone, so
it deserves a real chance.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE, interval width, effective sample size, per strategy per
cell, with MCSE. **Selection stability** as defined in section 3. **Sensitivity
and specificity of each strategy's modifier set** against the truth, since a
strategy can be right on average while never selecting the same set twice.

**The registered power check:** the realized detection rate of significance
screening against section 2's analytic power curve. Agreement confirms the
mechanism; disagreement means the noncentrality is not what governs detection
here and the deliverable changes.

Common random numbers across strategies; MCSE clustered on the replicate block.
$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The **detection-materiality gap**: the modifier strength at
which omission bias exceeds the declared material threshold, against the strength
at which significance screening reaches 80% detection, at the reviewed median
covariate count and source size.

**Decision rule.**

- A gap in which bias becomes material well below the strength screening can
  detect **confirms** the problem in its strongest form, and the recommendation
  is that screening should not be used as a selection rule at these sample sizes.
- No gap, meaning screening detects before bias matters, **refutes** the
  proposition and the field's practice is defensible.
- **The gap is reported as two numbers on one axis in either branch**, because
  that is what an analyst can act on and it does not depend on which strategy
  wins.

**Strategies are compared on RMSE against the declared estimand**, fixed now, not
on bias alone: a strategy that removes bias by adjusting for everything and
triples the interval has not helped, and choosing the summary after seeing which
favors a preferred strategy is the failure this rule exists to prevent.

## 8. Three controls, each of which can fail

**Null control.** With no true modifiers, every strategy must be unbiased, and
significance screening must select at approximately its nominal false-positive
rate scaled by the candidate count. **A screening rate far from nominal here is a
harness fault**, and it is the cheapest check in the design.

**Positive control.** At the strongest modifier level with large imbalance,
omitting the modifier must produce bias exceeding the material threshold, and the
oracle set must be unbiased. If the oracle is biased, something other than
selection is wrong and no comparison downstream is interpretable.

**Falsifier for the study's own headline.** The expected headline is that
selection cannot be done reliably at these sample sizes. Its falsifier is
all-candidate adjustment: if it is unbiased with acceptable RMSE, selection is
unnecessary rather than unreliable, and those are different recommendations.
**The falsifier is a method in the comparison, not a robustness check**, and
section 2 gives a reason it might succeed.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Too broad to be decisive, as the catalog warns | Four strategies, one estimand, one geometry; elicitation excluded with a stated reason | removed |
| A strategy judged on bias while it pays in variance | RMSE fixed as the comparison summary before the run | removed |
| Instability reported without saying whether it matters | Detection-materiality gap is the primary outcome | removed |
| All-candidate adjustment assumed monotonically worse | Covariate count is a factor and the relationship is measured | removed |
| Selection-conditional intervals ignored | Resampled-whole-procedure arm carried; DEC-11 named as owner | removed |
| Unreported modifiers, the commonest real failure | Excluded by construction; results stated as optimistic | disclosed |
| Shared linear modification built in | Stated; DIA-08 named as owner | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | minutes |
| **P2** power curve and grid | Section 2's analytic power against modifier strength at the reviewed sample sizes; the material threshold from the decision context | **The modifier-strength levels.** The design's axis must contain both thresholds or the primary outcome is not estimable | hours |
| **P3** overlap cost | How effective sample size actually moves with candidate count at each overlap level | Whether the all-candidate arm is a real alternative or a straw one | hours |
| **P4** unit cost | Per-replicate wall clock across strategies including the resampled procedure; total computed not typed | $n_{sim}$ | hours |

**P2 decides whether the study has a primary outcome at all.** If the two
thresholds sit outside the reachable strength range, the gap cannot be estimated
and the design must change before it is registered rather than after.

## 11. Cost

The resampled-whole-procedure arm multiplies its strategy's cost by the resample
count; that is the line item this program has mispriced twice. Priced in P4; no
total quoted.

---

## Relationship to the rest of the queue

- **DEC-11** owns propagating the selection uncertainty this study creates; the
  two are halves of one workflow and the resampled arm is their join.
- **COV-03** owns the prognostic-versus-modifier distinction, which changes what
  the right set is.
- **COV-04** owns calibration of interaction shrinkage under selection.
- **MOD-04** owns post-selection inference for model choice generally.
- **DIA-08** owns the shared-linear restriction this design inherits.
- **COV-10** owns checking interaction consistency, an alternative to selection.
