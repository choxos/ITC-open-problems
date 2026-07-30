# CMP-12 design: what a two-stage adjusted estimator loses when a trial has three arms

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is unusually precise about where the damage currently is: **the
practical cost is lost evidence rather than wrong intervals**, because both the
component MAIC and component STC routes reject IPD studies with more than two
arms outright. That means the honest primary outcome is not "how wrong are the
intervals" but "how much does refusing the capability cost, and does the obvious
workaround cost more."

---

## 1. The claim, restated as something that can be false

**Proposition under test:** when a multi-arm trial's contrasts are
population-adjusted one at a time, the within-study covariance induced by a
shared arm **and by a shared weighting step** is not recovered by naive variance
formulas; a multivariate bootstrap carrying all of a trial's contrasts jointly
recovers it; and doing so is worth more than the current practice of splitting or
dropping such trials.

**Refuting sentence:** *splitting a multi-arm trial into independent pairwise
comparisons costs so little in a realistic network that the added machinery is
not worth its complexity.*

## 2. The mechanism, algebraically, and the second term is the new one

For a three-arm IPD trial with arms $A$, $B$, $C$ and estimated arm means
$\hat\mu_a$, the two contrasts $\hat d_{AB}$ and $\hat d_{AC}$ share arm $A$:

$$\mathrm{Cov}(\hat d_{AB}, \hat d_{AC}) \;=\; \mathrm{Var}(\hat\mu_A) \;>\;0 .$$

That much is standard and is exactly what network meta-analysis has always
handled. **Population adjustment adds a second term that is not standard.** The
weights $\hat w$ are estimated once from the trial's covariates and enter every
contrast, so

$$\mathrm{Cov}(\hat d_{AB}, \hat d_{AC}) \;=\; \underbrace{\mathrm{Var}(\hat\mu_A)}_{\text{shared arm}} \;+\; \underbrace{\left(\frac{\partial d_{AB}}{\partial w}\right)^{\!\top}\!\mathrm{Var}(\hat w)\left(\frac{\partial d_{AC}}{\partial w}\right)}_{\text{shared weighting}} .$$

Three consequences:

1. **The second term has no analogue in unweighted synthesis**, so importing
   NMA's multi-arm handling is not sufficient. A bootstrap that resamples per
   contrast destroys it; only a bootstrap that resamples the trial once and
   recomputes **all** its contrasts inside the same replicate preserves it. This
   is precisely the architectural change the catalog names.
2. **Its sign is not fixed.** The two gradients can point the same way or
   oppositely depending on how the target populations of the two comparisons
   differ, so ignoring it is not conservative in general and cannot be defended
   as such. **That is testable and it is the study's sharpest claim.**
3. **Splitting a three-arm trial into two independent two-arm trials double
   counts arm $A$**, which inflates the trial's contribution to network precision
   and produces anticonservative pooled intervals. Dropping the trial instead is
   unbiased but discards evidence. The two current options therefore fail in
   opposite directions and the study measures both against the joint estimator.

## 3. Estimand, with its true value defined

**Primary.** The network contrast $d_{BC}$ in the declared target population,
which is the derived contrast most sensitive to the covariance: its variance is
$\mathrm{Var}(d_{AB}) + \mathrm{Var}(d_{AC}) - 2\mathrm{Cov}$, so the omitted term
enters doubled and with a sign.

**True value** by quadrature over the target law with the generating model, at an
order fixed by P1.

**The empirical within-study covariance is a second estimand with a defined
truth**: the Monte Carlo covariance of the two contrast estimators across
replicates, which is what each variance method is trying to reproduce. Scoring a
covariance estimator against this rather than against coverage alone is what
separates "the method works" from "two errors cancelled".

## 4. Data-generating mechanism, and what it makes invisible

Networks containing one multi-arm IPD trial plus aggregate studies, the smallest
geometry where $d_{BC}$ is estimable and the multi-arm trial is not the only
evidence.

### Factors

| factor | levels | why |
|---|---|---|
| IPD trial arms | 3, 4 | four arms give three contrasts and a covariance matrix rather than a scalar |
| shared-arm size | small, equal, large relative to the others | drives the first term in section 2 |
| covariate overlap | good, poor | drives $\mathrm{Var}(\hat w)$ and therefore the second term |
| effect modification | 0, moderate, strong | the gradients $\partial d/\partial w$; **at zero the second term vanishes** |
| gradient alignment | comparisons transported to similar targets; to dissimilar targets | **section 2 prediction 2**, the sign axis |
| network size | multi-arm trial plus 2 aggregate studies; plus 5 | how much the trial's mis-weighting matters to the pooled result |

### What the mechanism makes true, and therefore what the study cannot see

- The multi-arm trial is the only IPD trial, so all weighting error is
  concentrated in it. Networks with several IPD trials would dilute the effect
  and are not covered.
- Consistency holds, so any pooled-interval failure is a variance failure and not
  an inconsistency one. HET-02 and the node-splitting entries own the latter.
- Component structure is present only in the component arms; the mechanism in
  section 2 is not component-specific and the design says so by carrying a
  non-component arm.
- The aggregate studies are two-arm. Multi-arm aggregate studies raise the same
  covariance question on the synthesis side, where it is already solved, and
  including them would blur which side the fix belongs on.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| drop the multi-arm trial | current `cpaic` behavior for >2 arms | the status quo, and it is unbiased |
| split into pairwise | two independent two-arm comparisons, shared arm reused | the workaround, and it double counts |
| per-contrast bootstrap | resample per contrast; covariance set to zero | the naive variance the catalog says is wrong |
| **joint stratified bootstrap** | resample the trial once, recompute all contrasts and the weights inside each replicate | the fix; preserves both terms in section 2 |
| stacked estimating equations | contrasts and weight equations stacked, sandwich covariance | the analytic route to the same object |
| one-stage arm-level model | ML-NMR, where the covariance is produced by the likelihood | the structural answer, and the reference the two-stage arms are trying to match |

**The comparator that can win is dropping the trial.** It is unbiased, it is what
the software does today, and if the precision it forfeits is small in a realistic
network then the entire problem is theoretical. Registered as the outcome most
likely to overturn the expected headline, and **it is the outcome the catalog's
own "lost evidence rather than wrong intervals" sentence points at.**

## 6. Performance measures, MCSE, and $n_{sim}$

For the network contrast $d_{BC}$: bias, coverage, interval width, RMSE, per
method, with MCSE.

**The covariance recovery measure:** each method's estimated
$\mathrm{Cov}(\hat d_{AB},\hat d_{AC})$ against the Monte Carlo truth, reported as
a ratio with a bootstrap MCSE. **Decomposed into the two terms of section 2**
where the design permits, by re-running the joint bootstrap with the weights held
fixed at their full-sample values, which switches off the second term. That
decomposition is the study's mechanistic evidence and is registered as an
outcome, not derived afterwards.

**Precision forfeited by dropping** is reported in the same units as the coverage
failure from splitting, so the two current options are comparable on one axis.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 2000$ per cell, with the bootstrap resample count set by P3 and its own
Monte Carlo contribution reported, since OUT-11 found an endpoint resampling error
at about 3.1% of interval width and nearly discarded it as negligible.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the 95% interval for $d_{BC}$ under each
method, at strong effect modification and poor overlap, where section 2 makes the
second term largest.

**Decision rule.**

- Splitting anticonservative, per-contrast bootstrap anticonservative, and the
  joint bootstrap nominal: the fix is established and the capability restriction
  should be lifted rather than patched.
- Joint bootstrap and per-contrast bootstrap indistinguishable everywhere: the
  second term in section 2 is immaterial, and importing NMA's standard multi-arm
  handling is sufficient. **That is a clean, useful negative result** and it is
  reported as the headline.
- Dropping the trial losing less than a declared precision margin against the
  joint bootstrap: the problem is theoretical and the recommendation is to keep
  the current restriction. The margin is set in P2 from what a decision would
  notice, not chosen afterwards.

**The sign test, registered separately.** Section 2 prediction 2 says the omitted
covariance is not conservative in general. It is confirmed only if the
per-contrast bootstrap **over**covers in one alignment cell and **under**covers in
another. A one-sided failure everywhere would mean the sign is fixed after all and
the claim is withdrawn.

## 8. Three controls, each of which can fail

**Null control.** At zero effect modification the weights do not enter the
contrasts' expectations, so the second term in section 2 vanishes and the
per-contrast and joint bootstraps must agree to Monte Carlo error, while both
still capture the shared-arm term. **A control that tests exactly one of the two
terms is what makes the decomposition credible.**

**Positive control.** At strong modification, poor overlap and a small shared
arm, the per-contrast bootstrap must underestimate the covariance by a detectable
margin. If it does not, the second term is not reachable at attainable settings
and the study reports that.

**Falsifier for the study's own headline.** The expected headline is that the
capability restriction should be lifted. Its falsifier is the precision
comparison against dropping: if a realistic network loses little by dropping the
trial, lifting the restriction buys complexity for nothing, and the honest
recommendation is to leave it. **That comparison is registered as the deciding
one in networks of five or more studies**, fixed now rather than chosen after
seeing which favors the expected answer.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Covariance method judged by coverage alone, so two errors can cancel | Scored directly against the Monte Carlo covariance | removed |
| The two terms in section 2 not separable | Weights-fixed re-run switches off the second | removed |
| Bootstrap Monte Carlo error ignored | Resample count set by P3; its contribution reported | removed |
| Problem framed as wrong intervals when the cost is lost evidence | Dropping is the registered winning comparator and precision loss is a primary-level outcome | removed |
| Result specific to component models | Non-component arm carried | removed |
| Inconsistency confounded with variance failure | Consistency imposed | removed, and scope named |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Target-population truths for all contrasts; the analytic size of both covariance terms | The grid; cells where the second term is below Monte Carlo resolution are dropped rather than run | hours |
| **P2** precision margin | What precision loss a decision would notice, from the decision context | The falsifier's threshold | hours |
| **P3** bootstrap resample count | The count at which the covariance estimate's own Monte Carlo error is below a declared fraction of the estimate | $n_{sim}$ and the budget. **This is the line item OUT-11 called cheap without measuring, and it then dominated the run** | hours |
| **P4** unit cost | Per-replicate wall clock including the joint bootstrap and the ML-NMR reference; total computed not typed | The grid | hours |

## 11. Cost

Dominated by $n_{sim} \times$ resamples $\times$ methods. That product is exactly
the one this program has mispriced twice, and no total is quoted until P3 and P4.

---

## Relationship to the rest of the queue

- **HET-02** owns multi-arm covariance lost when contrasts are adjusted pairwise,
  which is the same defect stated at the synthesis level; if both run they share
  a generating mechanism and one of them becomes the other's arm.
- **CMP-24** owns approximate edge influence for multi-arm and random effects.
- **SFW-08** owns the leave-one-out unit for mixed likelihoods, which is the same
  question about what a trial's unit of evidence is.
- **CMP-11** owns two-stage component PAIC adjusting only the IPD edges.
