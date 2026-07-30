# QBA-06 design: correcting one path can be worse than correcting neither

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note requires restriction to **one misclassified binary covariate and one outcome
type**, and this design takes that. The stakes are established: in an unweighted
unanchored external-control design, **sensitivity and specificity of 0.9 still left
roughly 67% relative bias and 79.6% coverage**, while a validation-informed likelihood
held bias near zero at about 95.5% coverage with wider intervals.

**The joint model can be written down in principle**, so the gap is a validated
PAIC-specific implementation and the validation data to inform it, not the absence of
any joint form. Section 2 finds why the PAIC case is not a straightforward composition.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** misclassification correction modifies the outcome
likelihood while MAIC modifies the estimating equation through weights, and no validated
implementation combines them; **a mismeasured covariate is often also a balancing
variable**, so the error propagates into the weights as well as the outcome model.

**Refuting sentence:** *correcting the outcome model is sufficient, because the weights'
error is second order relative to the likelihood's.*

## 2. The mechanism: two paths, and their signs need not agree

Let $X$ be the true binary covariate and $X^\star$ its misclassified version with
sensitivity $Se$ and specificity $Sp$. Then

$$P(X^\star = 1) \;=\; Se\,p \;+\; (1-Sp)(1-p),$$

so the observed prevalence is a contraction of the true one toward
$(1-Sp)/(2-Se-Sp)$. Two things follow and they are different failures.

**Path one, the weights.** MAIC matches the source's $X^\star$ to the target's reported
$X^\star$ prevalence. **If $Se$ and $Sp$ are the same in both studies the contraction is
common and the matched quantity is a consistent monotone transform of the truth**, so
balance on $X^\star$ implies balance on $X$. **If they differ between studies it does
not**, and the weights balance a variable that means different things on the two sides.
**That is COV-09's calibration shift with a known error model**, and it is the case where
the error is *differential*.

**Path two, the outcome model.** Even with non-differential error, the fitted
interaction on $X^\star$ is attenuated toward zero relative to the interaction on $X$,
so the transported effect is biased through the modifier's coefficient.

**Three consequences:**

1. **The two paths can have the same or opposite sign.** Attenuation in path two biases
   the interaction toward zero; a differential contraction in path one biases the
   weighted population toward or away from the target depending on which study has the
   worse assay. **So correcting only one path can move the total bias further from
   zero**, which is the design's sharpest and most decision-relevant prediction.
2. **A sequential correction is order-dependent** for the same reason, which is the same
   structure QBA-22 finds for multiple biases and CMP-21 for one parameter entering
   three layers.
3. **Under non-differential error with the covariate not in the balancing set**, path
   one vanishes and the problem reduces to the known outcome-model case. **That is the
   null control that separates the PAIC-specific half from the established one.**

**The validation data problem is real and is not solved here.** Internal validation
substudies are rarely embedded in sponsor IPD and **essentially never exist for a
published aggregate comparator**, so the most informative parameter source is
unavailable exactly where it is needed. **The design therefore carries a priors-only arm
alongside the validation-informed one**, and reports the increase in uncertainty
correction brings rather than only the point correction.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal risk ratio, defined on the **true**
covariate, by quadrature at an order fixed by P1. Defining it on the measured covariate
would build the error into the answer.

**The two bias paths are separately computed**, by holding the weights at their
true-covariate values (kills path one) and by fitting the outcome model on the true
covariate (kills path two), which makes consequence 1 measurable rather than inferred.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| sensitivity and specificity | 0.95, 0.90, 0.80 | the entry's own scale |
| **differential between studies** | non-differential; differential | **path one's switch** |
| **covariate in the balancing set** | yes; no | **path one's other switch, and consequence 3's null** |
| validation-sample size | none; 100; 500 | what informs the error model |
| source-target overlap | good, poor | the adjustment layer |
| interaction strength | moderate, strong | path two's multiplier |

### What the mechanism makes true, and therefore what the study cannot see

- **One misclassified binary covariate and one outcome type**, per the note. Continuous
  proxies with calibration slope and intercept, and eligibility measurement differences,
  are named and not run. **Eligibility differences change who is compared while outcome
  differences change what counts as an event**, and the entry says the corrections
  interact where the mechanisms co-occur; that interaction is out of scope.
- The error model is known to the simulation. **In practice it must come from validation
  data, external evidence or explicit priors, and any validation-based model carries its
  own transport assumption into both studies** — which the design states and does not
  test.
- Outcome misclassification is excluded so the covariate path is attributable.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive | no correction |
| outcome-model correction only | **path two only; consequence 1 says this can be worse than naive** |
| weight correction only | path one only |
| sequential correction | consequence 2's order dependence, run in both orders |
| **joint latent-variable model** | the implementation the entry says is missing |
| joint model with priors instead of validation data | the deployable version where no validation exists |

**The comparator that can win is naive.** Consequence 1 says a partial correction can
increase total bias, so **naive can beat a partial correction**, and if it also matches
the joint model at realistic error rates the whole exercise is unnecessary. Registered as
such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and interval width per method per cell, with MCSE. **Width is reported
prominently**, since the entry's evidence is that correction buys coverage with width and
that trade is the deliverable.

**The two-path decomposition** from section 3, reported with signs, since consequence 1
turns on whether they agree.

**Order dependence**: the difference between the two sequential orders, which is
consequence 2 and is zero if the paths do not interact.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the outcome-model-only correction against naive, in cells
with **differential** error on a **balancing** covariate.

**Decision rule.**

- Outcome-only correction further from zero than naive: **consequence 1 is confirmed in
  its sharpest form**, and the deliverable is that partial correction is unsafe and the
  joint model is required.
- Outcome-only correction monotonically better: **refuted**, and the established
  outcome-model machinery suffices.
- **The priors-only joint model's performance is reported in either branch**, because
  validation data are usually unavailable and that arm is what an analyst could actually
  run.

## 8. Three controls, each of which can fail

**Null control.** With perfect measurement, every method must coincide. **A correction
that moves an unmeasured-error estimate is manufacturing one.**

**Second null control, and it is consequence 3.** With non-differential error on a
covariate **not** in the balancing set, path one is absent, so the outcome-model
correction must be sufficient and must match the joint model. **That reproduces the
established result and licenses the PAIC-specific claim elsewhere.**

**Positive control.** Differential error at $Se = Sp = 0.8$ on a strongly interacting
balancing covariate: naive must be materially biased. If not, the mechanism is
unreachable at the entry's own error rates.

**Falsifier for the study's own headline.** The expected headline is that correction must
be joint. Its falsifier is the width trade: **if the joint model's intervals are so wide
that no decision survives, then a biased narrow interval and an unbiased useless one are
both unusable**, and the honest recommendation is to report the bias direction as a
qualitative caution. Width is therefore a primary-level outcome.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming no joint form exists | Stated as writable in principle; the gap is implementation and data | removed |
| Truth defined on the measured covariate | Defined on the true one | removed |
| Two paths reported as one bias | Decomposed with signs | removed |
| Correction assumed monotonically helpful | Naive registered as able to win | removed |
| Validation data assumed available | Priors-only arm carried and reported in every branch | removed |
| Eligibility and outcome measurement | Out of scope per the note; their interaction named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and analytic paths | The target truth and the analytic sign of each bias path per cell | **The primary outcome's prediction**, and whether opposite signs are reachable | days |
| **P2** validation informativeness | How much a validation sample of each size constrains $Se$ and $Sp$ | The validation levels | hours |
| **P3** joint-model identifiability | Whether the joint latent model is identified without validation data under the chosen priors | **Whether the deployable arm is estimation or prior propagation** | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

The joint model is Bayesian and multiplies the arm's cost; otherwise weighting and GLM
fits.

---

## Relationship to the rest of the queue

- **COV-09** owns measurement non-equivalence without a known error model and supplies
  the nonidentification result that bounds the priors-only arm.
- **QBA-22** and **CMP-21** own multi-path composition and order dependence.
- **QBA-07** owns outcome ascertainment, the path excluded here.
- **DEC-11** owns what belongs in an interval; a measurement correction's added width is
  sampling-like where validation data exist and structural where they do not.
