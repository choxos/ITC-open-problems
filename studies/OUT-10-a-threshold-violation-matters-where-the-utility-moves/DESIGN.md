# OUT-10 design: relaxing proportional odds, and where the relaxation pays

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note says the high rating overstates the urgency, and it is right:
**proportional-odds ML-NMR and target-standardized category probabilities already
exist.** `multinma` ships ordered multinomial models through `multi()`, and
Phillippo et al. fit ordered PASI 75, 90 and 100 by ML-NMR and reported the
percentage achieving each endpoint on each treatment in external target
populations.

**So this design does not rebuild standardized category probabilities.** It takes
the relaxation half and the utility half, and section 2 finds they interact in a way
that decides when the relaxation is worth anything.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** proportional odds imposes one treatment coefficient
across all cut-points, and a treatment may shift patients out of the worst category
without changing the top of the scale; aggregate publications often report a
dichotomized version or a single ordinal odds ratio, so the cut-point-specific
pattern needed to test the assumption is unavailable; and decision analyses
combining joint category-probability draws with explicit, possibly uncertain
utilities do not exist.

**Refuting sentence:** *proportional odds is close enough at realistic
threshold-specific effects that the relaxed families give the same
target-standardized category probabilities, and the utility layer is arithmetic on
draws that already exist.*

## 2. The mechanism: the decision-relevant error is weighted by the utility increments

Under a violated proportional-odds assumption, the fitted single coefficient is a
least-false value: a weighted average of the cut-point-specific effects
$\beta_1,\dots,\beta_{K-1}$, with weights set by the category prevalences and the
link's curvature. **This is the same least-false structure OUT-11 solves for the
transported hazard ratio and CMP-18 for component effects**, and it means "the true
proportional-odds coefficient" does not exist when the assumption fails.

The decision quantity is expected utility,

$$U \;=\; \sum_{k} u_k\, p_k(F_T), \qquad \text{so}\qquad \Delta U \;=\; \sum_k u_k\,\Delta p_k .$$

Because $\sum_k \Delta p_k = 0$, this rewrites as a sum over **utility increments**
between adjacent categories times the cumulative probability errors at each
cut-point:

$$\Delta U \;=\; \sum_{k=1}^{K-1} (u_{k+1}-u_k)\,\Delta P(\text{above cut-point } k).$$

Three consequences:

1. **A proportional-odds violation at cut-point $k$ reaches the decision only in
   proportion to the utility increment $u_{k+1}-u_k$ there.** A treatment that
   shifts patients out of the worst category is decision-relevant if that boundary
   carries a large utility step and nearly irrelevant if it does not. **So the
   relaxation's value is not a property of the violation alone**, and no existing
   work makes that pairing.
2. **This gives the design its sharpest manipulation:** hold the violation fixed and
   move the utility increments across cut-points. **The same fitted model then
   produces a decision error that varies by an order of magnitude**, which is
   testable and which no proportional-odds diagnostic could reveal, because
   diagnostics look at the model and not at the utilities.
3. **Utility uncertainty enters linearly**, so it inflates the decision's variance
   without biasing it, **unless the utilities covary with the categories whose
   probabilities are most in error.** That covariance is the second-order term and
   is a factor here.

**Non-collapsibility persists regardless:** even a conditional proportional-odds
model yields population-dependent marginal odds ratios, so the target-standardized
category probabilities are the right output and the marginal odds ratio is not.
That is already what `multinma` produces and this design keeps it.

## 3. Estimand, with its true value defined

**Primary.** Target-standardized category probabilities $p_k(F_T)$ for each
treatment, by integration over the target covariate law at an order fixed by P1.

**Secondary and decision-facing.** **Expected ordinal utility** and its contrast,
with the utility vector declared and its uncertainty propagated.

**Where proportional odds fails, no single ordinal odds ratio is an estimand**, and
the design reports category probabilities rather than manufacturing one. The
least-false coefficient is computed only to show what a proportional-odds fit is
reporting.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| threshold-specific effects | proportional; mild violation; strong violation at the **bottom** cut-point; strong at the **top** | consequence 1 needs violations located, not just sized |
| **utility increment profile** | uniform; concentrated at the bottom; concentrated at the top | **consequence 2, the design's core manipulation** |
| category sparsity | balanced; sparse top category | where cut-point-specific effects are least determined |
| effect-modifier overlap | good, poor | the adjustment layer |
| utility uncertainty | none; moderate; correlated with category | consequence 3 |
| available aggregate reporting | full ordinal; dichotomized only | the entry's point that the pattern needed to test the assumption is often unavailable |

**Violation location crossed with utility location is the design.** A study varying
only violation size would report an average over utility profiles that no decision
uses.

### What the mechanism makes true, and therefore what the study cannot see

- **Utilities come from a preference source outside the trials** in the base arm,
  as the entry notes, though they can be elicited within one. **Preference transport
  between source and target populations is a second transport problem** and is
  carried as one factor level only, not solved.
- The ordered multinomial machinery is `multinma`'s and is not rebuilt.
- Component PAIC has no ordinal family at all; **adding one is named as work and is
  not attempted here.**
- One outcome per replicate. Joint efficacy, safety and cost outcomes are DIA-09's.

## 5. Methods, including one that can win

| method | role |
|---|---|
| proportional-odds ML-NMR | the existing, published method |
| **partial proportional-odds ML-NMR** | the relaxation, treatment effect free at some cut-points |
| **adjacent-category ML-NMR** | a different relaxation with a different invariance |
| **continuation-ratio ML-NMR** | the sequential-process relaxation |
| dichotomized analysis at one cut-point | what an aggregate publication often forces |

**The comparator that can win is proportional odds.** If its target-standardized
category probabilities are within Monte Carlo error of the relaxed families across
the violation grid, the refuting sentence holds and the relaxation is unnecessary.
Registered as such, and the note's scepticism about urgency gives it a real chance.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of each category probability; **calibration of the whole
probability vector**, since a model can be right on average and wrong in shape;
interval width; convergence, with MCSE.

**Decision loss**, defined as the expected-utility difference between acting on the
fitted probabilities and acting on the truth. **That is the measure section 2
consequence 1 predicts will vary by utility profile at fixed violation**, and it is
the primary outcome.

**The registered mechanism check:** decision loss regressed on
$\sum_k (u_{k+1}-u_k)\,\Delta P_k$ from section 2. **Slope 1 confirms that the
utility increments are the weights**, which is the study's transportable finding.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Decision loss under proportional-odds fitting, at a strong
violation located at the bottom cut-point, crossed with utility increments
concentrated at the bottom versus at the top.

**Decision rule.**

- Decision loss materially larger when the utility increments align with the
  violation, and small when they do not: **consequence 1 is confirmed**, and the
  deliverable is that a proportional-odds check must be read against the utility
  profile rather than alone.
- Decision loss uniformly small: the refuting sentence holds and the relaxation is
  not needed at these violations.
- Decision loss uniformly large: the relaxation is needed regardless of utilities,
  which is a simpler recommendation and is reported as such.

## 8. Three controls, each of which can fail

**Null control.** Under true proportional odds, every family must recover the same
category probabilities, with the relaxed ones costing only precision. **A bias in a
relaxed family there means it is misimplemented, not more flexible.**

**Second null control, and it is consequence 1's algebra.** With a strong violation
at a cut-point whose utility increment is **zero**, decision loss must be
approximately zero despite the model being badly wrong. **That is the cell that
separates model error from decision error**, and it is the design's most
counter-intuitive prediction.

**Positive control.** Strong violation at the bottom cut-point with utility
increments concentrated there: proportional odds must incur decision loss exceeding
the declared threshold. If not, the mechanism is unreachable.

**Falsifier for the study's own headline.** The expected headline is that
violations matter where utilities move. Its falsifier is the dichotomized-reporting
factor: **if an aggregate publication reports only one cut-point, no relaxed family
is estimable regardless of how much it would help**, and the binding constraint is
reporting rather than method. **That would make the deliverable a reporting request
and the note's scepticism correct**, and the design must be able to reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Rebuilding standardized category probabilities | Stated as existing; `multinma` used | removed |
| Violation size varied without location | Location crossed with utility location | removed |
| A least-false ordinal odds ratio reported as an estimand | Category probabilities are the estimand; the coefficient is shown only as what a fit reports | removed |
| Utility uncertainty assumed independent of categories | Correlated level carried | removed |
| Preference transport | One level; named, not solved | disclosed |
| Component ordinal family | Named as work; not attempted | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and least-false coefficients | Target category probabilities and the least-false proportional-odds value per cell | The definition of truth | hours |
| **P2** utility profiles | Realistic utility increments for an ordinal scale in use, so consequence 2's manipulation spans what decisions actually weight | **The materiality verdict** | days |
| **P3** relaxed-family feasibility | Whether partial proportional odds, adjacent-category and continuation-ratio models fit inside `multinma`'s integration, or need custom Stan | Which relaxed arms exist | days |
| **P4** unit cost | Per-fit cost across five families; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Five ordinal families across a six-factor grid, Stan-dominated. **SFW-06 bounds
it**; the design is wide rather than deep for that reason.

---

## Relationship to the rest of the queue

- **OUT-11** and **CMP-18** share the least-false-parameter structure.
- **DIA-09** owns outcome families and joint multi-outcome decision functionals;
  the utility layer here is the ordinal case of its net-benefit question.
- **DEC-01** owns decision error as the scoring currency, which this design's
  primary outcome uses.
- **QBA-25** owns decision QBA and net benefit, where utility uncertainty is a
  first-class subject.
