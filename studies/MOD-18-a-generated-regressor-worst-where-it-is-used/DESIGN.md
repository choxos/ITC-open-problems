# MOD-18 design: the score is least well estimated exactly where it is acted on

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note restricts this to **uncertainty propagation**, deferring the joint-model
identification problem, and the entry itself says where to start: **quantify the
understatement first, because it is cheap and decides whether the rest is worth doing.**

The three-stage paper's own authors state that implementing all three stages in a single
Bayesian model **would naturally incorporate uncertainty from all stages and avoid
spuriously overprecise conclusions**, and stop short of doing so.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** where the prognostic model, the recalibration and the network
meta-regression are fitted separately, the synthesis conditions on the fitted risk score as
though it were observed, so **standard errors computed as if an estimated regressor were
data are too small**, and **the understatement grows where the regressor is least well
estimated, which in risk modeling is the tails of the risk distribution and therefore
exactly where risk-stratified treatment recommendations are made.**

**Refuting sentence:** *the prognostic cohort is far larger than the trials, so the score's
estimation error is negligible relative to the trial-level uncertainty and the plug-in
interval is adequate.*

**That refutation is the reason nobody has paid the cost**, and it is plausible at the
median. **Section 2 says it is least plausible at the tails**, which is where the
recommendation lives.

## 2. The mechanism: generated regressors, and a tension with no free choice

**The generated-regressor problem.** The network meta-regression uses $\hat r_i$, an
estimate of the true risk $r_i$. Treating $\hat r$ as data omits a term from the variance
of every coefficient that multiplies it, including the treatment-by-risk interaction. **The
omitted term scales with $\mathrm{Var}(\hat r)$**, so the understatement is a function of
where in the risk distribution the estimate sits.

Three consequences:

1. **A prognostic model's predictions are least precise in the tails**, because the tails
   are where the cohort has fewest observations and where shrinkage acts hardest. **So the
   understatement is worst at the extremes**, and a risk-stratified recommendation is made
   at the extremes. **The refuting sentence is therefore true where nobody acts and false
   where everybody does**, which is a sharper statement than "intervals are too narrow" and
   is directly measurable.
2. **Shrinkage compounds it.** A shrunk score is biased toward the mean, so the
   treatment-by-risk interaction is attenuated **and** its interval is understated. **Two
   errors in the same direction**: the interaction looks both smaller and better determined
   than it is.
3. **The two obvious fixes conflict.** A fully joint fit propagates the uncertainty but
   lets a handful of trials influence a prognostic model fitted on a far larger cohort,
   **which is the standard motivation for cutting feedback**; and **cutting feedback is
   precisely what discards the uncertainty at issue.** So the choice is not between right
   and wrong but between two named costs, **and measuring both is the design's second
   deliverable.**

**A bootstrap over the prognostic model is available in principle** but must be propagated
through recalibration and a Bayesian network fit for every replicate, **which is expensive
enough that nobody has reported it.** That expense is the reason the first deliverable is
the measurement rather than the method.

## 3. Estimand, with its true value defined

**Primary.** The risk-specific treatment effect at declared risk percentiles, **including
the tails**, by quadrature at an order fixed by P1 using the true risk.

**Truth is defined on the true risk, not the fitted score.** Defining it on the score would
build the generated-regressor problem into the answer.

**The derived deliverable is interval widening**: the ratio of the propagated interval's
width to the plug-in interval's, **reported separately at the median and at the tails**,
which is consequence 1 made a number.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| prognostic-model sample size | 1000, 5000, 20000 | how precise the score is |
| score shrinkage | none; moderate; strong | consequence 2 |
| calibration drift between cohort and trials | none; moderate | what recalibration must absorb |
| **target risk percentile** | 10th, 50th, 90th | **consequence 1's axis** |
| number of trials | 6, 12 | how much feedback a joint fit would receive |

### What the mechanism makes true, and therefore what the study cannot see

- **The joint model's identification is deferred**, per the note. Whether the treatment-by-
  risk interaction is identified when cohort and trials differ in population is a
  transportability question, and **where it fails the recalibration parameters carry the
  difference with no settled answer on sharing, stratifying or partially pooling them.**
  The design carries one declared choice and states it.
- The true risk is known to the simulation; an analyst has only the score.
- One outcome family and one prognostic model form.
- **The cohort-trial score equivalence is assumed in the base arm** and violated only
  through calibration drift, which is the modelable part.

## 5. Methods, including one that can win

| method | role |
|---|---|
| plug-in staged fit | current practice |
| **bootstrap over the prognostic model and recalibration** | the expensive propagation the entry says nobody has reported |
| **joint Bayesian model** | consequence 3's first horn |
| **cut-feedback joint model** | consequence 3's second horn |

**The comparator that can win is the plug-in fit.** If its intervals are adequate at the
tails as well as the median, the refuting sentence holds and the cost is not worth paying.
**Registered as such, and the entry's own framing is that nobody has measured the harm**, so
a negative result would be as useful as a positive one.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the risk-specific treatment effect **at each declared percentile**,
with MCSE; **interval width ratios** from section 3; **attenuation of the treatment-by-risk
interaction** under shrinkage, which is consequence 2's first error.

**The cost of cutting feedback**, measured as the change in the prognostic model's own
parameters between the joint and cut-feedback fits, so consequence 3's trade-off is
quantified on both sides rather than asserted.

**Calibration of predicted benefit** and **stability of the recalibration parameters**,
which the entry names as the comparison axes.

$n_{sim} = 1000$ per cell; the bootstrap arm multiplies by its replicate count, which is the
term P3 prices.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the risk-specific treatment effect at the 90th percentile
under the plug-in staged fit, against the bootstrap and joint fits.

**Decision rule.**

- Plug-in coverage materially below nominal at the tails and adequate at the median:
  **consequence 1 is confirmed in the form that matters**, and the deliverable is the
  widening ratios plus a recommendation that risk-stratified intervals be propagated.
- Plug-in adequate throughout: **refuted**, and the field can keep the staged fit.
- **The feedback trade-off is reported in either branch**, because a joint fit's cost to the
  prognostic model is a fact about the architecture and not about the coverage result.

## 8. Three controls, each of which can fail

**Null control.** With the true risk supplied instead of a fitted score, every method must
coincide and be nominal. **That is the no-generated-regressor case** and it validates
everything else.

**Second null control.** With a very large prognostic cohort and no shrinkage, the score is
nearly exact, so plug-in and propagated intervals must agree. **That is the regime the
refuting sentence describes**, and confirming it licenses the failure elsewhere.

**Positive control.** Small cohort, strong shrinkage, 90th percentile: plug-in coverage must
fall materially below nominal. **If it does not, the generated-regressor effect is
unreachable at realistic cohort sizes** and the entry's concern does not arise.

**Falsifier for the study's own headline.** The expected headline is that propagation is
needed at the tails. Its falsifier is the width: **if propagated intervals at the 90th
percentile are so wide that no stratified recommendation survives, then the honest output is
that tail recommendations are not supportable rather than that they need wider intervals.**
**That is arguably the more important finding** and the design must be able to report it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Truth defined on the fitted score | Defined on the true risk | removed |
| Widening reported as one number | Reported by risk percentile | removed |
| Joint model presented as free | Cut-feedback trade-off measured on both sides | removed |
| The joint model's identification assumed | Deferred per the note; the declared choice stated | disclosed |
| Attenuation and interval understatement conflated | Reported separately; consequence 2 | removed |
| A wide tail interval read as a fix | The falsifier states the alternative reading | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and percentiles | Risk-specific truths at each declared percentile | The definition of truth | hours |
| **P2** analytic understatement | The omitted variance term at each percentile, from the prognostic model's prediction variance, **before any fitting** | **The primary outcome's prediction**, and it is nearly free | hours |
| **P3** bootstrap cost | Cost of propagating through recalibration and a Bayesian network fit per replicate | **Whether the propagating arm is affordable**, which is why nobody has reported it | days |
| **P4** unit cost | Total, computed not typed | $n_{sim}$ | hours |

**P2 predicts the answer for hours of work**, which makes it the first thing to run.

## 11. The case-study half

Refit a published risk-modeling network meta-regression with the prognostic model and
recalibration bootstrapped, and **report how much the credible intervals widen at the median
and at the tails.** The entry names this as the cheap first step and it is; **it needs no
new theory and it is what would motivate anyone to pay for the rest.**

---

## Relationship to the rest of the queue

- **DEC-17** finds the same conditioning failure for contribution measures: a quantity
  computed at a point estimate of a nuisance parameter and reported as though it carried no
  uncertainty. **The two are the same defect in different outputs.**
- **CMU-02** owns prior-driven posteriors, which is what a cut-feedback fit's prognostic
  block becomes.
- **DEC-28** owns inference on a stratified recommendation's boundary, which a risk score
  defines here.
- **COV-03** owns the prognostic index, of which a fitted risk score is an estimate.
