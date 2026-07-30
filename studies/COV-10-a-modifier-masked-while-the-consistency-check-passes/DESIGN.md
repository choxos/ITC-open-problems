# COV-10 design: the effect check passes and the interaction is inconsistent

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The entry contains a worked demonstration that is hard to improve on. In a fabricated
antimalarial network, **direct-evidence interaction coefficients were 0.0000 (95% credible
interval −0.0115 to 0.0116) while the corresponding indirect coefficients were 0.0399,
−0.0400 and 0.0800**, and the network meta-regression concluded **no interaction exists.**
At the same time the ordinary consistency check passed: **posterior probability that direct
and indirect evidence agree was 0.9976 to 1.000 for the log odds ratios and 0 for the
interaction coefficients.**

**So an analyst who checks treatment effects for inconsistency sees nothing wrong**, and
the covariate is dropped from the modifier set. The note says run early because the
question has measurable operating characteristics.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** treatment-by-covariate interaction coefficients satisfy a
consistency equation of their own; when it fails, direct and indirect paths can carry
interactions of opposite sign that cancel in the pooled fit; and no selection procedure,
guidance document or software checks interaction consistency before a covariate is
accepted or rejected.

**Refuting sentence:** *the cancellation requires opposing interactions of similar
magnitude, which is a knife-edge configuration unlikely at realistic parameter values, so
the demonstration is a constructed curiosity.*

## 2. The mechanism: two consistency equations, and only one is checked

For treatment effects, consistency requires $d_{BC} = d_{AC} - d_{AB}$. **The interaction
coefficients satisfy the same relation independently**, so a network can be consistent in
effects and inconsistent in interactions. Three consequences:

1. **The pooled interaction is a precision-weighted average across paths.** If the paths
   carry $+\beta$ and $-\beta$ with comparable precision, the pooled estimate is near
   zero **with a narrow interval**, because averaging two precise opposing estimates
   produces a precise estimate of nothing. **The narrowness is what makes it convincing**,
   and it is exactly what the worked example shows: an interval of $\pm 0.0116$ around
   zero while the paths carry $\pm 0.04$ to $0.08$.
2. **Cancellation is not knife-edge in the way the refuting sentence supposes.** Partial
   cancellation attenuates the pooled coefficient toward zero for **any** opposing
   configuration, so the modifier is understated across a continuum and fully masked only
   at the balance point. **So the phenomenon has a magnitude, not a threshold**, and its
   frequency is a measurable function of how often paths disagree in sign.
3. **The effect-level check has no power against it by construction.** Node splitting on
   $d$ compares treatment effects; interaction inconsistency lives in a different
   coefficient. **The two checks are looking at different parameters**, which is why one
   passes at 0.9976 while the other is at 0.

**The action when the check fires is also unsettled and the design registers it.** A
covariate whose interaction differs across paths **is a modifier on at least one of
them**, so balancing on it is defensible even though the pooled coefficient says
otherwise. **The analysis should say which path drove the decision**, and that is a
reporting rule this study can supply.

## 3. Estimand, with its true value defined

**Primary.** The target-population treatment effect after modifier selection, by
quadrature at an order fixed by P1, so the downstream cost of a masked modifier is
measured rather than inferred from the coefficient alone.

**Two derived estimands.** The **path-specific interaction coefficients**, whose truths
are generated; and **modifier-selection accuracy**, whether the covariate is retained.

**The diagnostic's operating characteristics are the third**: type I error and power of
interaction node splitting and of the interaction design-by-treatment model, **and the
recovery probability of a masked modifier** as a function of trials per path, between-trial
covariate variation and cancellation size, which is what the entry asks for.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **path-specific interaction signs and magnitudes** | equal; partially opposing; fully cancelling | **consequence 2's continuum**, not just the balance point |
| between-trial covariate variation | small, large | the check needs a covariate that varies |
| trials per path | 2, 4, 8 | the check needs enough studies on each path |
| treatment-effect inconsistency | absent; present | so the two consistency equations are crossed |
| network size | small; larger | the sparse regime where adjustment is used |

**Interaction inconsistency crossed with effect inconsistency is the design**, because the
entry's point is that the first can occur without the second.

### What the mechanism makes true, and therefore what the study cannot see

- **The check needs a covariate that varies across trials and enough studies per path**,
  which is **rarely available in the small sparse networks where population adjustment is
  used.** The design includes those cells so the unavailability is measured rather than
  assumed, and **where the check cannot be run the report must say so** rather than citing
  the pooled coefficient as evidence of no modification. That reporting rule is a
  deliverable.
- The diagnostics exist only as bespoke Bayesian models and are **not implemented in
  `netmeta`, `gemtc`, `multinma` or any population-adjustment package**, so running them
  means writing the code. **P2 reproduces the source's worked example** before anything
  new is claimed.
- Modifier selection is treated as an input fixed before any network model is fitted, so
  **the workflow never creates an occasion at which this diagnostic could be run.** That
  is a process finding and the design states it.
- One outcome type.

## 5. Methods, including one that can win

| method | role |
|---|---|
| pooled network meta-regression, no interaction check | current practice |
| effect-level node splitting | the check that passes |
| **interaction node splitting** | the check that would fire |
| **interaction design-by-treatment model** | the global version |
| unrelated mean effects with interactions | the third extension |

**The comparator that can win is the effect-level check.** If it fires whenever
interaction inconsistency is present at realistic magnitudes, the existing workflow
catches the problem incidentally and the refuting sentence holds. **Registered as such,
and consequence 3 says it should not**, which makes the test sharp.

## 6. Performance measures, MCSE, and $n_{sim}$

Type I error and power of each check; **recovery probability of a masked modifier**;
**modifier-selection accuracy**; and **bias and coverage of the target-population effect**
after selection, with MCSE.

**The registered demonstration:** in fully cancelling cells, the pooled interaction's
point estimate and interval width against the path-specific truths. **Reproducing the
worked example's pattern — a tight interval around zero over paths carrying large opposing
effects — is the study's most quotable output** and it needs no new theory.

**Feasibility rate**: how often the interaction check is runnable at all given trials per
path and covariate variation, which is the practical constraint.

$n_{sim} = 4000$ per cell, from resolving a type I error of 0.05 to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Recovery probability of a masked modifier by interaction node
splitting, at 4 trials per path with large covariate variation and full cancellation,
against the effect-level check's firing rate in the same cells.

**Decision rule.**

- Interaction check recovering the modifier while the effect check does not:
  **confirmed**, and the deliverable is the implemented check plus the selection-workflow
  change and the action rule from section 2.
- Effect check firing too: **refuted**, and the existing workflow suffices.
- Neither recovering at realistic trials per path: **the check is coherent and
  underpowered**, and the deliverable is the reporting rule that a pooled coefficient
  cannot be cited as evidence of no modification where the check could not be run.

## 8. Three controls, each of which can fail

**Null control.** With consistent interactions across paths, the interaction check must
hold nominal size and the pooled coefficient must be unbiased. **Size before power.**

**Second null control, and it is consequence 3.** With **treatment-effect** inconsistency
and **consistent interactions**, the effect check must fire and the interaction check must
not. **That establishes the two checks are looking at different parameters**, which is the
mechanism's core and is testable in one cell.

**Positive control.** Full cancellation with 8 trials per path and large covariate
variation: the interaction check must fire in essentially every replicate and the pooled
interval must exclude the path-specific truths. **If the check cannot detect the
constructed case, it cannot detect anything.**

**Falsifier for the study's own headline.** The expected headline is that interaction
consistency must be checked before modifier selection. Its falsifier is the downstream
measure: **if masking a modifier changes the target-population effect negligibly because
the modifier is weak where the target sits, then the coefficient is wrong and the decision
is fine.** The target effect is therefore the primary estimand rather than the coefficient,
fixed before the run.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Treating cancellation as knife-edge | Partial cancellation is a factor level; consequence 2 | removed |
| Scoring the coefficient rather than the decision | Target effect is the primary estimand | removed |
| Implementing bespoke models without reproducing their source | P2 reproduces the worked example first | removed |
| Assuming the check is runnable | Feasibility rate measured; the reporting rule covers when it is not | removed |
| No stated action when the check fires | Action rule registered in section 2 | removed |
| Effect and interaction inconsistency conflated | Crossed | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Target effect truths and path-specific interaction truths | The definition of truth | hours |
| **P2** worked-example reproduction | That the implemented interaction node split reproduces the published example's numbers | **Everything.** The models are bespoke and unimplemented, so a discrepancy here is in the implementation | days |
| **P3** feasibility map | Trials per path and covariate variation at which the check is estimable, before fitting | **The grid**, and which cells report a null rather than a result | hours |
| **P4** unit cost | Per-network cost at $n_{sim}=4000$; total computed not typed | The grid | hours |

## 11. Cost

Bayesian network fits at 4000 replicates across five checks; the interaction models add
parameters rather than expense. Moderate.

---

## Relationship to the rest of the queue

- **HET-04** owns node splitting without target standardization; the two checks are the
  same machinery applied to different coefficients and should share an implementation.
- **COV-01** owns modifier selection and is where this diagnostic would be inserted;
  **the entry's process finding is that selection happens before any network fit, so the
  occasion never arises.**
- **IDN-05** owns the shared-modifier check, which presumes the modifier set is right.
- **MOD-15** owns pooling within- and across-trial interaction information, the same
  averaging-away-a-signal structure in a different decomposition.
