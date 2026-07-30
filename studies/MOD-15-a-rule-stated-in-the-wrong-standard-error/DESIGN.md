# MOD-15 design: half a standard error, but of which estimate

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note calls this a clean and decisive simulation and a strong early candidate, and
section 2 finds a defect in the published rule that is arithmetic rather than
empirical, which makes the study sharper than a general calibration exercise.

The stakes are documented. **In the worked example accompanying the rule, pooling
would have moved a chemotherapy-plus-surgery interaction from +0.172 to −0.120,
reversing its sign.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the only published criterion for pooling within-trial and
across-trial interaction information is a visual comparison plus a rule that the
within-trial estimate lie within half a standard error of the across-trial estimate,
described in its source as relatively strict and justified by pointing at interactions
later debunked rather than by calibration; and no study reports its power, its
false-positive rate, or the coverage of the combined estimate conditional on a pass.

**Refuting sentence:** *the rule's operating characteristics are adequate at realistic
network sizes, so its lack of calibration is a documentation gap rather than a defect.*

## 2. The mechanism: the rule is stated in the wrong units

Let $\hat\beta_W$ and $\hat\beta_A$ be the within-trial and across-trial interaction
estimates with standard errors $s_W$ and $s_A$. The rule admits pooling when

$$|\hat\beta_W - \hat\beta_A| \;<\; \tfrac{1}{2}\,s_A .$$

**But under the null that both estimate the same quantity, the difference has standard
error $\sqrt{s_W^2 + s_A^2}$, not $s_A$.** So the rule's size is

$$P\left(|Z| > \frac{0.5\,s_A}{\sqrt{s_W^2+s_A^2}}\right),$$

**which depends on the ratio $s_W/s_A$ and is therefore not controlled.** Three
consequences:

1. **The rule is not necessarily strict.** In a network with few trials the
   across-trial estimate is imprecise, so $s_A \gg s_W$ and the threshold
   $0.5\,s_A$ approaches $0.5\sqrt{s_W^2+s_A^2}$, giving a rejection rate near
   $P(|Z|>0.5) \approx 0.62$. **In the opposite regime, many trials with tight
   across-trial estimates, $s_A \ll s_W$ and the threshold becomes tiny relative to
   the difference's spread, so the rule rejects almost always.** Either way the size
   swings with the network, and **the source's description of the rule as relatively
   strict is a statement about one regime.**
2. **The regime where extra precision is most wanted is the one with few trials**,
   which is where consequence 1 says the rule is most permissive. **So the rule is
   loosest exactly where the across-trial information is least trustworthy**, which is
   the opposite of what a guard should do.
3. **A rule in the difference's units would have controlled size**, and stating it
   that way costs nothing. **That is the design's cheapest deliverable** and it does
   not depend on any simulation result.

**The simulation's job is what the algebra cannot supply**: power against a set
ecological bias, and the coverage and bias of the pooled estimate **conditional on
having passed**, which is a selection-conditional quantity and is exactly what DEC-11
and COV-04 measure for other selections.

**Agreement is evidence in one direction only.** Disagreement can come from ecological
confounding or from noise; **agreement can occur under confounding whenever the bias is
small next to the standard errors**, and consequence 1 says those standard errors are
large in the regime of interest. So a pass licenses very little, and quantifying how
little is the study's second deliverable.

## 3. Estimand, with its true value defined

**Primary, and it is not the interaction.** The **transported treatment effect in a
target population**, since the catalog asks for results in terms of the quantity the
interaction is used for, so a rule can be chosen on decision cost rather than on
interaction coverage alone.

**The pooled interaction is the secondary**, with truth being the within-trial
coefficient, which is the causal quantity; the across-trial association is not it,
which is the whole reason the pooling decision exists.

**Ecological bias $\delta$ is a set parameter** in the generator, so the alternative is
indexed rather than vague.

## 4. Data-generating mechanism, and what it makes invisible

**A generative model for trial-level confounding is required and this literature has
not standardized one.** P1 declares it explicitly, because a pooling rule calibrated
against an unstated confounding model is calibrated against nothing.

### Factors

| factor | levels | why |
|---|---|---|
| ecological bias $\delta$ | 0, small, moderate, large | the alternative; 0 is the size |
| **number of trials** | 5, 10, 20 | **consequence 1's $s_W/s_A$ ratio** |
| dispersion of trial covariate means | small, large | the other driver of $s_A$ |
| covariate overlap | good, poor | the transport layer |
| true within-trial interaction | zero, moderate, strong | the quantity being protected |

**Number of trials crossed with mean dispersion is the design**, because together they
determine the standard-error ratio consequence 1 turns on.

### What the mechanism makes true, and therefore what the study cannot see

- **The identifying assumption behind the across-trial component is not testable from
  the data being pooled**, and no rule changes that. **The study measures a rule's
  operating characteristics, not whether the assumption holds.**
- The confounding model is declared. **Results are conditional on it**, and a
  different mechanism could change the power curve.
- **The problem is not confined to full individual-data networks**: any
  mixed-granularity model that lets aggregate covariate variation inform an
  interaction faces it, which is CMP-13's and IDN-06's subject. **This design's rules
  are stated so they apply there too**, and the ML-NMR case is carried as one arm.
- One outcome type.

## 5. Methods, including one that can win

| rule | role |
|---|---|
| **half a standard error of the across-trial estimate** | the published rule, as written |
| **the same in the difference's standard error** | consequence 3's correction |
| a formal test of $\beta_W = \beta_A$ at a stated level | the calibrated version |
| **never pool** | the conservative default the recommendations already set |
| **hierarchical shrinkage of the across-trial contribution toward the within-trial estimate with a data-driven weight** | the continuous alternative, which needs no threshold |

**The comparator that can win is never pooling.** It is the current default in the
statistical recommendations, it needs no rule, and **if the precision it forfeits is
small against the transported effect's total error, the whole calibration question is
moot.** Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**Rejection rate under the null** and **power at each $\delta$** for each rule, with
MCSE; **the realized size against consequence 1's analytic prediction**, which is the
registered mechanism check and needs no simulation to predict.

**Coverage and bias of the pooled interaction conditional on a pass**, which is the
selection-conditional quantity nobody reports.

**Bias, coverage and decision error of the transported effect**, which is the primary
and the currency a rule should be chosen in.

$n_{sim} = 4000$ per cell, from resolving a size of 0.05 to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Realized size of the published rule across the trial-count axis,
against its analytic prediction from consequence 1.

**Decision rule.**

- Size varying materially with the trial count and matching the prediction:
  **confirmed**, and the deliverable is the corrected rule in the difference's units
  plus a calibrated threshold, at essentially no cost.
- Size approximately constant: consequence 1's arithmetic is not operative at these
  configurations and the study reports that its diagnosis was wrong.
- **Transported-effect performance is reported for every rule in either branch**,
  because that is the currency the catalog asks for and it decides which rule to use
  even if the size analysis resolves cleanly.

## 8. Three controls, each of which can fail

**Null control.** At $\delta = 0$ with a correctly calibrated test, size must be at
its nominal level. **The published rule is expected to fail this and the corrected one
to pass**, which is the study in one comparison.

**Second null control.** With zero true within-trial interaction and $\delta = 0$,
pooling cannot change the transported effect, so every rule must give the same answer.
**Cheap, exact, and it separates the rule's behavior from the interaction's magnitude.**

**Positive control.** Large $\delta$ with 20 trials: every rule must reject, and the
pooled estimate conditional on a pass must be badly biased where a pass occurs.
**If a large ecological bias passes the rule frequently, the rule is not a guard at
all**, which is the strongest possible version of the finding.

**Falsifier for the study's own headline.** The expected headline is that the
published rule is miscalibrated. Its falsifier is the transported-effect comparison:
**if the miscalibration does not translate into worse transported-effect performance
than the corrected rule, then the arithmetic defect is real and inconsequential**, and
the design must report that rather than presenting a technically correct finding as a
practical one.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Calibrating against an unstated confounding model | Declared in P1; results conditional and stated | removed |
| Judging a pooling rule on interaction coverage alone | The transported effect is the primary, per the catalog | removed |
| Selection-conditional coverage not reported | Reported conditional on a pass | removed |
| The rule's size assumed rather than derived | Predicted analytically and checked | removed |
| Confining the problem to full-IPD networks | An ML-NMR arm carried; CMP-13 and IDN-06 named | removed |
| Threshold rules compared only against each other | Never-pool and continuous shrinkage both included | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** confounding model | An explicit generative model for trial-level confounding, declared before any calibration | **Everything.** The literature has not standardized one and calibrating without it calibrates against nothing | days |
| **P2** analytic size curve | The published rule's size against $s_W/s_A$ from consequence 1, and the trial counts that span it | **The grid**, and the primary outcome's prediction | hours |
| **P3** attainable $s_W/s_A$ | That the requested ratio range is reachable at realistic trial counts and mean dispersions | Whether consequence 1's swing is observable | hours |
| **P4** unit cost | Per-replicate cost at $n_{sim}=4000$; total computed not typed | The grid | hours |

**P2 costs hours and predicts the primary outcome**, which makes it the first thing to
run and the cheapest possible check on the study's central claim.

## 11. Cost

Regression fits at 4000 replicates; small. The ML-NMR arm is the only expensive part
and is carried at reduced replicates.

---

## Relationship to the rest of the queue

- **CMP-13** proved the shared-interaction restriction is algebraically equivalent to
  forcing the within-trial and across-trial coefficients equal, which is the extreme
  case of pooling; **IDN-06** measures it in Bayesian ML-NMR. **This design is the
  calibrated middle ground between always pooling and never pooling.**
- **DEC-11** and **COV-04** own selection-conditional coverage in other settings.
- **IDN-01** owns the untestable assumption behind the across-trial component.
- **DEC-01** supplies the decision currency the primary is reported in.
