# DIA-14 design: false reassurance is bounded by the elicitation, not by the method

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's central observation is that supplying the true sensitivity
parameters removes exactly the uncertainty QBA exists to represent, so the
evaluation is circular and every correctly coded method passes. Section 2 turns
that into a factorization with a consequence the field has not stated: **most of
the error rate that matters is not under the method's control at all.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** QBA in PAIC is evaluated on oracle recovery rather
than on honest classification; the measures that would show classification honesty
are not reported; and false reassurance, the costly error, stays invisible unless
the simulation deliberately places the truth outside the analyst's assumed
region.

**Refuting sentence:** *a well-constructed sensitivity set is wide enough in
practice that truth exclusion is rare, so oracle recovery plus a conventional
width rule is an adequate evaluation.*

**The catalog also records an absence claim the literature auditor could not
verify**, that no minimum ADEMP standard exists for QBA simulation in PAIC. **This
design repeats no absence claim.** It cites what exists and evaluates it.

## 2. The mechanism: false reassurance factorizes

Let $\gamma$ be the true bias parameter and $\mathcal{G}$ the analyst's assumed
region. A QBA declares **robust** when the decision is unchanged for every
$\gamma' \in \mathcal{G}$. Then

$$P(\text{false reassurance}) \;=\; P\big(\gamma \notin \mathcal{G}\big)\;\times\;P\big(\text{decision wrong at } \gamma \;\big|\; \gamma \notin \mathcal{G},\ \text{declared robust}\big).$$

Three consequences, and the first is the point:

1. **The first factor is a property of the elicitation, not of the QBA method.**
   No computational method can push false reassurance below the rate at which the
   assumed region misses the truth. **So a QBA method's contribution is bounded,
   and reporting its false-reassurance rate without reporting the elicitation's
   miss rate attributes an elicitation property to a method.** That is a
   structural statement and it survives whatever the simulation finds.
2. **The second factor is where methods differ**, through how they explore
   $\mathcal{G}$, whether they respect dependence between bias parameters, and
   whether they report a tipping point rather than a verdict. A method reporting
   the tipping point lets a reader apply their own $\mathcal{G}$, which
   **moves the first factor out of the method entirely** and is why the tipping
   arm is the comparator that can win.
3. **False fragility has the mirror structure** and is not symmetric in cost. A
   rule that declares everything fragile has zero false reassurance and is
   useless, which is why both rates must be reported together and why the
   deliverable is a frontier rather than a rate.

**The elicitation must therefore be simulated**, including width, centering error,
dependence and expert error. The catalog calls this a behavioral component that
statistical simulation conventions have no vocabulary for, and it is right: **the
elicitation model here is a declared assumption, not an empirical one**, and the
paper must present results as a function of it rather than marginalized over it.

## 3. Estimand, with its true value defined

**Primary.** The **robustness classification**: whether the decision, at a fixed
declared threshold, is unchanged across the assumed region.

**Its true value** is whether the decision at the true $\gamma$ matches the
decision under no bias, which is computable exactly since $\gamma$ is generated.

**The underlying effect estimand** is the target-population marginal treatment
effect in an unanchored comparison, with truth by quadrature at an order fixed by
P1. **Both are needed:** estimation at the true parameters and classification
under unknown parameters are scored **separately**, which is the catalog's own
instruction and prevents a method from passing on the half that is circular.

**The tipping point is a third estimand where one exists**, with a defined
distance: the smallest $\|\gamma\|$ at which the decision flips. **Where no
tipping point exists within a plausible range, that is reported rather than
extrapolated**, since a tipping point outside any plausible bias is the strongest
possible robustness statement and must not be recorded as a missing value.

## 4. Data-generating mechanism, and what it makes invisible

Unanchored PAIC with an unmeasured confounder, following Ren et al. 2025's setting
so the comparison is against the practice being criticized rather than a new one.

### Factors

| factor | levels | why |
|---|---|---|
| sensitivity-set width | narrow, moderate, wide | the elicitation's first property |
| centering error | 0, moderate, large | the elicitation's second, and what drives truth exclusion |
| truth-exclusion probability | 0, 0.1, 0.3 | **set directly rather than induced**, so section 2's first factor is a controlled quantity |
| dependence among bias parameters | independent; correlated | whether a method that ignores dependence is penalized |
| true bias magnitude | below, at, above the decision threshold's tipping point | the second factor in section 2 |
| effect-modification and overlap | 2 levels each | the PAIC layer, kept minimal |

**Setting truth exclusion directly is the design's key device.** Inducing it from
width and centering would confound the two factors of section 2, and the whole
contribution is keeping them apart.

### What the mechanism makes true, and therefore what the study cannot see

- **The elicitation model is assumed, not estimated.** No data exist on how
  analysts actually choose sensitivity ranges in this setting, so every result is
  conditional on the model and is reported as a function of its parameters. **The
  study cannot say how often false reassurance occurs in practice**, only how it
  depends on the elicitation, and that limit belongs in the abstract.
- One bias mechanism, unmeasured confounding. **DIA-13 owns crossing QBA bias
  mechanisms with the primary factors**, and mixing them here would make the
  classification estimand ambiguous.
- One decision threshold, declared. Sensitivity to the threshold is reported but
  the primary is at the declared value.
- Support and effective sample size are checked across the QBA grid, since a QBA
  that changes weighting or the implied target distribution can leave the support
  it started from. The catalog asks for this and it is cheap.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| deterministic grid QBA | point estimates and intervals across assumed bias parameters, as in current practice | the practice under test |
| probabilistic QBA | priors on the bias parameters, propagated | the interval-producing route, whose calibration is measurable |
| **tipping-point reporting** | the bias magnitude at which the decision flips, with no assumed region | **section 2 consequence 2**: it moves the elicitation out of the method |
| bounds over a declared region | partial identification | the honest extreme |
| no QBA | the unadjusted unanchored estimate | the floor, so the value added by any QBA is visible |

**The comparator that can win is tipping-point reporting.** If it achieves the
same decision accuracy without requiring the analyst's region, then the
elicitation problem is avoidable and the recommendation is a reporting change
rather than a method. Registered as the outcome most likely to overturn the
expected headline.

## 6. Performance measures, MCSE, and $n_{sim}$

**Classification measures**, which is the point: false-reassurance rate,
false-fragility rate, and the frontier between them; sensitivity-set truth
inclusion; tipping-point error where defined; calibration of probabilistic
intervals; decision-reversal classification; expected regret under a declared
loss.

**Separately, estimation at the true parameters**, so the circular evaluation is
reported as what it is: an implementation check.

**Feasibility and computational failure across the QBA grid**, and **the Monte
Carlo error of the QBA computation itself**, both of which the catalog names and
neither of which is reported anywhere. **A QBA whose own Monte Carlo error is
comparable to the effect it explores is measuring itself.**

**The registered decomposition:** false reassurance split into section 2's two
factors, empirically, by conditioning on truth exclusion. That split is what
converts the study from a method ranking into a statement about where the error
lives.

$n_{sim} = 4000$ per cell, derived from resolving a false-reassurance rate of
0.05 to within 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The false-reassurance / false-fragility frontier by method,
at moderate centering error and truth-exclusion probability 0.1.

**Decision rule.**

- One method dominating the frontier: it is the recommendation, with the caveat
  from section 2 consequence 1 attached.
- No method dominating, with the frontier essentially fixed by truth-exclusion
  probability: **section 2 consequence 1 is confirmed empirically**, and the
  deliverable is that QBA evaluation must report the elicitation's miss rate,
  because the method is not what determines the outcome.
- Tipping-point reporting matching the best assumed-region method: the
  recommendation is the reporting change.

**Both rates are reported in every branch and neither is reported alone.**

## 8. Three controls, each of which can fail

**Null control.** With zero truth-exclusion probability and a wide correctly
centered region, false reassurance must be near zero for every method.
**Section 2 makes this exact**: the first factor is zero, so the product is zero
regardless of the second. A nonzero rate here means the classification is being
computed wrongly.

**Second null control.** With no bias at all, every method must declare robust and
no false fragility may exceed its nominal rate. This is the check that the QBA is
not manufacturing fragility from its own Monte Carlo error, which is exactly the
failure the QBA-error measure exists to detect.

**Positive control.** At truth-exclusion probability 0.3 with the true bias beyond
the tipping point, deterministic grid QBA must produce false reassurance at a
substantial rate. **If it does not, the design has not built the failure the
entry is about**, and no comparison is meaningful.

**Falsifier for the study's own headline.** The expected headline is that
classification honesty is not what current practice measures. Its falsifier is
the estimation-at-true-parameters arm: if methods that recover the truth well also
classify well across the whole grid, then oracle recovery is a valid proxy after
all and the circularity complaint, while logically correct, has no practical
force. **That arm is run for exactly this reason and is not a formality.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Circular evaluation at true parameters | Scored separately and labeled an implementation check | removed |
| Elicitation properties attributed to methods | Section 2's decomposition reported empirically | removed |
| Truth exclusion induced rather than controlled | Set directly as a factor | removed |
| A rule that abstains always scoring well | Both error rates and the frontier reported | removed |
| QBA's own Monte Carlo error mistaken for fragility | Measured and reported; second null control tests it | removed |
| Absence claim about ADEMP standards | Not repeated; the study cites what exists | removed |
| Elicitation model assumed | Results reported as a function of it; the limit stated in the abstract | disclosed |
| Missing tipping point recorded as missing data | Reported as robustness beyond the plausible range | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and tipping points | The target effect's truth and the analytic tipping point per cell | The bias-magnitude levels, which must straddle the tipping point | hours |
| **P2** QBA Monte Carlo error | The QBA computation's own error at production settings | Whether the second null control can pass, and the QBA's internal resample counts | hours |
| **P3** elicitation model | A defensible parameterization of width, centering and dependence, with its assumptions written down | **The whole elicitation factor.** This is the piece with no empirical anchor and it must be declared before results are seen, not tuned to them | hours |
| **P4** unit cost | Per-replicate cost across the QBA grid; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

$n_{sim} = 4000$ times the QBA grid size times five methods. The grid is the
multiplier this design could most easily misprice. Computed in P4; no total
quoted.

---

## Relationship to the rest of the queue

- **DIA-13** owns crossing QBA bias mechanisms with the primary factors; this
  design holds one mechanism fixed so the classification estimand stays clean.
- **QBA-22** owns non-additivity of total bias, which is what makes a
  one-at-a-time sensitivity set mislead, and is the natural extension of this
  design's dependence factor.
- **QBA-25** owns decision QBA, net benefit and tipping surfaces, which is where
  the tipping-point arm belongs at full generality.
- **QBA-02** owns prospectively blinded calibration, which is the only route to
  an empirical elicitation model this design has to assume.
- **DEC-01** owns decision error as the scoring currency.
