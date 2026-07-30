# COV-02 design: how the adjustment set moves when the same data are read on four scales

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is explicit that the definitional question is settled and the
estimand-first rule has been stated: effect modification is defined on a
conditional measure, decisions need marginal effects, and under non-collapsibility
purely prognostic variables can modify marginal effects. **What is undone is uptake
and evidence**: neither source paper reports how the modifier set changes across
the candidate scales a decision might use.

So this study does not argue for the rule. **It measures its consequences**, which
the note says makes it the cleaner early experiment.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the modifier set is a property of the estimand rather
than of the variable; a set that is right for the fitted model can be wrong for the
decision; and no published analysis shows how the set moves when the same data are
read on the risk difference, risk ratio, odds ratio and hazard-ratio scales.

**Refuting sentence:** *at realistic effect sizes the sets coincide on every scale a
decision would use, so scale sensitivity is a theoretical concern and declaring the
scale is sufficient.*

## 2. The mechanism: the marginal set is the conditional set plus the prognostic index

COV-03 establishes that for a non-collapsible marginal estimand the target contrast
depends on the covariate law, to second order, through the variance of the
prognostic index $u=\gamma^\top x$:

$$\Delta^{\text{marg}}(F) \;\approx\; \delta\left\{1 - c\,\mathrm{Var}_F(u)\right\}.$$

Three consequences that give the scale-specific sets directly:

1. **Risk difference (collapsible, linear).** The marginal effect is the average of
   the conditional contrast, so **only conditional modifiers matter.** The
   adjustment set is $\mathcal{M}_{\text{cond}}$.
2. **Marginal odds ratio or hazard ratio (non-collapsible).** The second term
   depends on every variable entering $u$, so **the set is $\mathcal{M}_{\text{cond}}
   \cup \{\text{variables with nonzero } \gamma\}$**, which is strictly larger and
   typically much larger, since prognostic variables outnumber modifiers.
3. **Risk ratio.** Collapsible on the log scale for the treated but not in general;
   its set sits between the two, and **where exactly is an empirical question this
   design answers rather than assumes.**

**So the sets are nested in a predictable order and the nesting is derivable.**
That converts "the set depends on the scale" from a caution into a rule an analyst
can apply, and **it makes a falsifiable prediction: the marginal-OR set should
contain the RD set in every replicate.**

**A fourth consequence the entry emphasizes and the design must carry:** population
adjustment is not only about transporting conditional effect modification.
Unanchored comparisons need prognostic adjustment regardless, and marginal
non-collapsible estimands vary with the prognostic distribution even with **no**
conditional interaction. **So a cell with zero conditional modifiers is not a cell
with an empty adjustment set**, and that cell is the design's sharpest control.

## 3. Estimand, with its true value defined

**Primary.** The target-population contrast on four scales: risk difference, risk
ratio, marginal odds ratio, marginal hazard ratio, each by quadrature at an order
fixed by P1.

**The scale-specific adjustment set is the derived estimand**, with a known truth
from section 2: the set of variables whose omission changes that scale's contrast
by more than a declared threshold. **Defined by consequence, not by coefficient**,
because a variable with a tiny $\gamma$ enters $u$ but does not matter.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| conditional modifiers | 0, 1, 3 | **0 is consequence 4's control** |
| prognostic non-modifiers | 2, 6 | how much larger the marginal set gets |
| prognostic strength | moderate, strong | the size of $\mathrm{Var}(u)$ |
| outcome type | binary; time-to-event | which scales are available |
| cross-study imbalance | small, large | whether a set difference produces a contrast difference |
| overlap | good, poor | the cost of the larger set |

### What the mechanism makes true, and therefore what the study cannot see

- **Modification is linear.** Under nonlinear modification the sets are not nested
  in the same way and the derivation does not hold.
- The true sets are known to the simulation; **an analyst estimates them, and
  COV-01 owns that estimation.** This study measures what the right set is per
  scale, not how to find it.
- Anchored and unanchored are both carried, because consequence 4's asymmetry is
  one of the entry's stated points.
- The threshold defining "matters" is declared in P2 from the decision context, and
  every set is conditional on it. **A different threshold gives different sets**,
  and that dependence is reported rather than hidden.

## 5. Methods

Adjustment on the RD-derived set, the marginal-OR-derived set, the union, and the
oracle set for the scale being reported. **Each contrast is then estimated on every
scale**, so a mismatch between the set's scale and the report's scale is measured
directly, which is the practice under test.

**The comparator that can win is the union set.** If adjusting for everything is
unbiased on every scale at acceptable precision cost, the scale-specific derivation
is unnecessary in practice and the recommendation is one sentence. Registered as
such, and COV-01 registers the same comparator for the same reason.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of each scale's contrast under each adjustment set, with
MCSE; **modifier-set overlap** between scales, as a Jaccard index; **decision
reversals** between scales at a declared threshold.

**The registered nesting check:** whether the marginal-OR set contains the RD set
in every replicate, which section 2 predicts. **A violation would mean the
derivation is wrong**, and it is cheap to check.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the marginal odds ratio when adjusted on the
RD-derived set, at strong prognostic strength with large imbalance and **zero
conditional modifiers**.

That cell is the sharp one: current practice would call the adjustment set empty,
and section 2 consequence 4 says it is not.

**Decision rule.**

- Material bias there while the marginal-OR set is unbiased: **confirmed**, and the
  deliverable is the scale-indexed set derivation plus the diagnostic.
- No material bias on any scale from any set: **refuted**, and declaring the scale
  is sufficient.
- **Set overlap and decision reversals across scales are reported in either
  branch**, because that is the evidence the entry asks for and it does not depend
  on the verdict.

## 8. Three controls, each of which can fail

**Null control.** On the risk-difference scale with no conditional modifiers, every
set must give an unbiased contrast, since collapsibility makes prognostic variables
irrelevant. **Algebraic, and it is the anchor for the whole nesting claim.**

**Second null control, and it is consequence 4.** On the marginal odds ratio with
no conditional modifiers, the RD-derived set is **empty** and must be biased, while
the marginal-OR set must not. **Both halves must hold simultaneously**, and if the
empty set is unbiased there, non-collapsibility is not reaching the estimand at
these strengths.

**Positive control.** Three conditional modifiers, six strong prognostic variables,
large imbalance: the set overlap between RD and marginal OR must be materially
below one. If the sets coincide there, they coincide everywhere reachable.

**Falsifier for the study's own headline.** The expected headline is that the
scale determines the set. Its falsifier is the union arm: **if adjusting for
everything is affordable, the scale-specific derivation is a curiosity**, and
whether it is affordable is an overlap question the design answers directly.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Arguing for a rule already stated | The rule is applied; the evidence is the contribution | removed |
| Set defined by coefficients rather than consequences | Defined by omission-induced change against a declared threshold | removed |
| Threshold dependence hidden | Reported; sets are conditional on it | disclosed |
| Estimation of the set confounded with its definition | True sets known; COV-01 named as the estimation owner | removed |
| Unanchored asymmetry ignored | Both designs carried, per the entry | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths on four scales | Each scale's target truth and the analytic $c$ | The definition of truth | hours |
| **P2** materiality threshold | The change a decision would notice, per scale | **Every set**, since sets are threshold-defined | hours |
| **P3** nesting verification | That the derived sets nest as section 2 predicts, analytically, before any fitting | **The mechanism.** A failure here means the design's central claim is wrong and cheaply so | hours |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | minutes |

## 11. The case-study half

The same scale-sensitivity analysis in a published PAIC dataset: report how the
adjustment set and the estimate move across the candidate scales. **That is the
evidence the entry says is missing and a simulation cannot supply it.**

---

## Relationship to the rest of the queue

- **COV-03** supplies the prognostic-index-variance result section 2 is built on
  and asks what to balance; this asks which set belongs to which scale.
- **COV-01** owns estimating the set; this owns what the right set is.
- **MOD-01** shares the same scalar for the reconstruction question.
- **DEC-02** owns which structural choice flips a decision, of which scale is one.
