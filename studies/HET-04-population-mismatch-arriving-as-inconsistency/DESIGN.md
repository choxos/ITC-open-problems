# HET-04 design: one number for two explanations, and both rates are computable

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog says the immediate work is **measurement rather than method**, and it is
right: `multinma` has supported `consistency = "nodesplit"` since 0.4.0 and the
same call accepts a regression formula and integration points, so the adjusted
split already exists. What nobody has measured is how often the **unadjusted**
diagnostic, which is the one applied work runs, flags population mismatch as
inconsistency or misses real inconsistency that a compensating mismatch has masked.

Section 2 shows both rates follow from one line.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** standard aggregate-data node splitting compares direct
and indirect evidence without standardizing either path to a common target, so a
population difference and a genuine loop conflict arrive as a single number; and
the adjusted split reports a conditional inconsistency factor rather than one
standardized to a named target on the marginal scale.

**Refuting sentence:** *the covariate differences between the study sets supplying
the two paths are small in real networks, so the unadjusted diagnostic is
approximately valid and adjusting is not worth its cost.*

## 2. The mechanism: the inconsistency factor is a sum of two things

Under linear modification, the contrast estimated along a path is $\delta +
\beta^\top \bar x$ evaluated at that path's study populations. The node-splitting
statistic is the difference:

$$w \;=\; \underbrace{\iota}_{\text{true loop inconsistency}} \;+\; \underbrace{\beta^\top\big(\bar x_{\text{direct}} - \bar x_{\text{indirect}}\big)}_{\text{population mismatch}} .$$

Three consequences, and they are the study:

1. **With $\iota = 0$, $w$ is exactly the mismatch term.** So the false-positive
   rate of the unadjusted test is $P(|\beta^\top\Delta\bar x| > c)$, computable from
   the modification strength and the covariate separation between the two study
   sets. **No simulation is needed to know the rate exists; the simulation
   measures how large it is at realistic separations.**
2. **Masking is exact when $\beta^\top\Delta\bar x = -\iota$.** A real conflict of
   any size is invisible if the population difference happens to cancel it, and
   **the cancellation is not a coincidence to be hoped against**: both terms are
   driven by which studies made which comparison, so they are correlated in real
   networks.
3. **Adjustment removes the second term at the conditional level only.** The
   adjusted split conditions on covariates, so the residual is $\iota$ evaluated
   conditionally, and **the decision uses a marginal contrast**. On a
   non-collapsible scale those differ, which is why the entry asks for the split to
   be marginalized to a named target.

**The scoping the entry insists on, and it is not pedantic.** A loop whose every
effect is defined in the **same** population telescopes algebraically, so
consistency is not automatically population-indexed. Population-varying
inconsistency requires **different populations along the evidence paths**,
**design-specific effect surfaces**, or an **inconsistency-by-covariate
interaction**. The design generates the first and the third explicitly and states
that the second is out of scope, so it never claims a population-indexed
inconsistency that its own generator could not produce.

## 3. Estimand, with its true value defined

**Primary.** The **target-marginal inconsistency factor**: $\iota$ evaluated in a
declared target population on the marginal scale, by quadrature at an order fixed
by P1.

**True value** from the generating model, which carries $\iota$ and $\beta$
separately, so the two terms of section 2 are separable by construction.

**The two error rates are the derived estimands**: false-positive rate at $\iota=0$
and masking rate at $\iota \neq 0$ with a compensating mismatch.

## 4. Data-generating mechanism, and what it makes invisible

Networks with at least one closed loop where the direct and indirect paths are
supplied by different study sets, which is the situation node splitting exists for.

### Factors

| factor | levels | why |
|---|---|---|
| covariate separation between paths | none; moderate; large | the mismatch term's size |
| effect-modification strength | 0, moderate, strong | its multiplier; **0 makes the mismatch term exactly zero** |
| true loop inconsistency $\iota$ | 0; moderate; equal and opposite to the mismatch | **consequence 2, generated directly rather than hoped for** |
| inconsistency-by-covariate interaction | absent; present | the case where inconsistency is genuinely population-indexed |
| network size | small loop; larger network | how much the indirect path pools |
| scale | risk difference; log OR | consequence 3 |

### What the mechanism makes true, and therefore what the study cannot see

- **Design-specific effect surfaces are out of scope**, so one of the three routes
  to population-indexed inconsistency is untested and is named.
- The adjusted split inherits the usual transport conditions: consistent estimands,
  positivity, measured modifiers, correctly specified outcome and transport models.
  **Every one holds by construction here**, so the adjusted arm is measured under
  conditions favorable to it and the paper says so.
- Modification is linear and shared. DIA-08 owns the departures.
- Song et al. measured false-positive and masking rates for the **ordinary
  unadjusted test** by simulation; this design measures them for the
  population-indexed comparison, which is a different question, and does not
  restate their result as new.

## 5. Methods, including one that can win

| method | role |
|---|---|
| unadjusted node split | `netmeta`/`gemtc` practice, and the thing under test |
| ML-NMR node split, conditional | `multinma` since 0.4.0, which exists |
| **ML-NMR node split, marginalized to a declared target** | the piece that does not exist |
| design-by-treatment interaction | the global alternative, for reference |

**The comparator that can win is the unadjusted split.** If its false-positive and
masking rates are acceptable at realistic separations, the refuting sentence holds
and the adjusted machinery is not worth its cost, **which is exactly the number the
catalog says decides that question.** Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**False-positive rate at $\iota = 0$**, **masking rate at compensating mismatch**,
power at $\iota \neq 0$ with no mismatch, and bias and coverage of the
target-marginal inconsistency factor, all with MCSE.

**The registered mechanism check:** observed $w$ regressed on $\iota +
\beta^\top\Delta\bar x$. Slope 1 confirms section 2 and makes both rates predictable
from quantities an analyst can estimate.

**Attribution:** among replicates where the unadjusted test fires, the fraction
where $\iota = 0$. **That single number is what tells a reader how much reported
inconsistency in the literature could be population mismatch**, and it is the
study's headline.

$n_{sim} = 4000$ per cell, from resolving a false-positive rate of 0.05 to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** False-positive rate of the unadjusted node split at $\iota=0$
with large covariate separation and strong modification.

**Decision rule.**

- Rate materially above nominal: **confirmed**, and the deliverable is the rate plus
  the marginalized adjusted split.
- Rate at nominal across the grid: **refuted**, and the unadjusted diagnostic is
  adequate.
- **Masking rate is reported in either branch**, because a test that is
  well-calibrated under the null and blind under a compensating alternative is
  still failing, and only one of the two rates is visible in current practice.

## 8. Three controls, each of which can fail

**Null control.** With zero effect modification, section 2 makes the mismatch term
**exactly zero** at any covariate separation, so the unadjusted test must hold
nominal size. **That is the algebraic statement that this is a modification problem
rather than a covariate problem**, and it is checked rather than asserted.

**Second null control.** With zero covariate separation between paths, the two
tests must agree to Monte Carlo error. **Cheap, and it separates "adjustment
matters" from "adjustment differs".**

**Positive control.** Large separation, strong modification, $\iota$ set equal and
opposite: the unadjusted test must fail to fire in most replicates while the
adjusted one fires. **If masking cannot be produced, consequence 2 is unreachable
and the study says so.**

**Falsifier for the study's own headline.** The expected headline is that
adjustment is needed. Its falsifier is consequence 3: **if the conditional adjusted
split and the marginalized one give the same verdict on every scale, the
marginalization is unnecessary** and the recommendation is simply to use the
existing `multinma` option, which needs no new work at all.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming the adjusted split does not exist | Stated as available since 0.4.0; only marginalization is new | removed |
| Assuming consistency is population-indexed | The three routes named; two generated, one scoped out | removed |
| Restating Song et al.'s measured rates as new | Their scope named; this is the population-indexed comparison | removed |
| Masking assumed rare | Generated directly as a factor level | removed |
| Adjusted arm measured under favorable conditions | Transport conditions hold by construction; stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and the two terms | The target-marginal $\iota$ and the analytic mismatch term per cell | The grid, and whether compensation is attainable | hours |
| **P2** realistic separations | Covariate differences between direct and indirect study sets in published networks, fixed before the run | **The materiality verdict**, which otherwise would be judged after seeing the rates | days |
| **P3** marginalization feasibility | Whether the node-split posterior can be marginalized to a target within `multinma`'s output | Whether the new arm exists | hours |
| **P4** unit cost | Per-fit cost at $n_{sim}=4000$; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Stan-dominated at 4000 replicates; **P2's realistic separations may allow a
narrower grid**, which is why it runs before pricing.

---

## Relationship to the rest of the queue

- **IDN-01** owns transitivity screens and lists consistency tests as the most-used
  device; this measures one of them.
- **EST-12** and **EST-06** share the population-dependence geometry.
- **HET-02** owns multi-arm covariance, **HET-03** owns shared heterogeneity: the
  three HET entries are separable defects in the same synthesis layer.
- **DIA-08** owns the shared-linear restriction this design inherits.
