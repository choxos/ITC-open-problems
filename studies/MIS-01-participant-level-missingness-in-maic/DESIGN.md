# MIS-01 design: deleting a record changes which population is being matched

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog's note fixes the scope and the reason is structural, not
budgetary.** PAIC missingness spans three layers resting on different assumptions:
participant-level missingness inside the IPD, trial-level non-reporting in the
aggregate publication, and structurally unavailable IPD for whole studies. **The
second and third are identification and data-access problems that no missing-data
method reaches**, and running them together would produce a factorial in which
nothing is attributable. This design takes layer one.

Layer one also has an existing solution: Fang et al. 2026 multiply an
inverse-probability-of-being-observed weight into the matching weights, with
simulation evidence. **So the work here is validation and extension, not
invention**, and the design says so.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** complete-case deletion removes a patient from the
balancing constraint set, so the population actually being matched shifts with
nothing in the output to signal it; the existing weighting solution is specific to
MAIC and to missingness at random; multiple imputation congenial with the
transport model is unbuilt; and no software records which strategy was used.

**Refuting sentence:** *at the missingness rates these analyses face, complete-case
deletion shifts the matched population negligibly, so the existing solution
addresses a problem that does not bite.*

## 2. The mechanism: the shift is in the unmatched directions

MAIC weights solve $\sum_i w_i x_i = \bar x_T$ over the **available** records. Under
complete-case deletion the constraint is solved on the complete-case subsample, so
the **matched** moments are correct by construction: balance tables look perfect,
which is exactly why nothing in the output signals the problem.

The shift lands in the **unmatched** directions. Let $u$ be covariates not in the
balancing set, with effect $\gamma_u$ on the outcome. Then

$$b_{\text{CC}} \;=\; \gamma_u^\top\Big(\mathbb{E}\big[u \mid \text{complete}, \text{weighted}\big] \;-\; \mathbb{E}\big[u \mid \text{weighted}\big]\Big),$$

**a product of the unmatched covariates' effect and the missingness-induced shift
in their weighted distribution.** Four consequences:

1. **Zero when either factor is zero.** If missingness is independent of the
   unmatched covariates given the matched ones, or if the unmatched covariates do
   not affect the outcome, complete-case analysis is unbiased **at any missingness
   rate**. So a rate-based threshold is the wrong test, which the catalog states
   and section 2 explains: **a negligible-missingness threshold is neither
   necessary nor sufficient for complete-case validity.**
2. **Balance diagnostics cannot detect it**, because the matched moments are
   balanced by construction. This is the same structural point DIA-03 established
   empirically, finding the post-weighting balance statistic never exceeded
   $1.4\times10^{-14}$ and could discriminate nothing.
3. **The effective sample size falls twice**: once from deletion and once from
   solving a harder constraint on fewer records. **Whether the ESS drop signals
   the bias is a testable question** and section 2 consequence 1 says it should
   not, since ESS is a weight functional and the bias is an outcome-weighted one.
4. **The inverse-probability-of-observation weight repairs the first factor's
   route under MAR** by restoring the full-sample distribution of $u$. Under MNAR
   it does not, and the residual is exactly the part of the shift not predicted by
   observed variables.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, computed by
quadrature over the declared target law at an order fixed by P1.

**The matched-population discrepancy is a second, directly observable estimand**:
the difference between the covariate distribution the weights actually produce and
the one they would produce with no missingness, measured on the unmatched
directions. **That quantity is what an analyst would want reported and nothing
reports it**, so measuring it is part of the deliverable rather than a diagnostic
of the simulation.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| missingness rate | 5%, 15%, 30%, 50% | the catalog's stated range |
| mechanism | MCAR; MAR on matched covariates; MAR on unmatched covariates; controlled MNAR | **the mechanism, not the rate, is what section 2 says matters** |
| missingness depends on effect modifiers | no; yes | the sharpest case, and the sketch names it |
| unmatched covariate effect $\gamma_u$ | 0, moderate, strong | **the other factor in the product; 0 is the null** |
| overlap | good, poor | interacts with the double ESS loss |
| what is missing | covariates; outcomes; both | Fang et al. handle both and they behave differently |

Mechanism × $\gamma_u$ fully crossed, which is the design.

### What the mechanism makes true, and therefore what the study cannot see

- **Layers two and three are excluded and the exclusion is stated in the title.**
  An unreported aggregate moment cannot be imputed from nothing without auxiliary
  information, and a study with no IPD is an access problem. **Neither is a missing
  data problem in the sense this study addresses**, and pretending otherwise is the
  conflation the entry exists to correct.
- The MNAR departure is **controlled**, meaning generated at declared magnitudes,
  because MNAR is unidentifiable from the data. Results under it are sensitivity
  analysis by construction and are labeled as such, not as estimation.
- The target summaries are exact. EST-07 and MIS-03 own their uncertainty; joint
  propagation across imputation, weighting and target-summary estimation is named
  as the remaining gap and is **not** built here.
- MAIC and STC only. ML-NMR's integration step interacts with missingness
  differently and would need its own design.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| complete case | deletion, as most software does by default | the status quo |
| **Fang et al. weighting** | inverse probability of being observed multiplied into the matching weights | the existing solution, **validated rather than reinvented** |
| **transport-congenial multiple imputation** | imputation model containing the transport model's terms, including the treatment interaction | the unbuilt method |
| generic multiple imputation | imputation without the interaction terms | **the uncongenial version**, included because it is what an analyst would reach for and congeniality is the whole point |
| MNAR sensitivity | pattern-mixture shift at declared magnitudes | the declared-sensitivity route |

**The comparator that can win is complete case.** If it is unbiased across the
realistic mechanism grid, the refuting sentence holds and the recommendation is
that layer one is not where the problem is. Registered as such, and section 2
consequence 1 gives it a real chance in every cell where either factor is small.

**Congenial versus uncongenial imputation is a registered contrast**, because
imputation that omits the treatment interaction will attenuate exactly the term
the transport depends on, and that is a prediction rather than a robustness check.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE, interval width, effective sample size and **the
matched-population discrepancy** from section 3, per method per cell, with MCSE.

**The diagnostic question, scored:** whether ESS, the missingness rate, or the
balance table predicts realized bias, as classifiers with AUROC. Section 2
consequence 2 says balance cannot and consequence 3 says ESS should not; **both are
falsifiable predictions and are registered as such.**

**The registered mechanism check:** observed complete-case bias regressed on
$\gamma_u^\top\Delta u$ from section 2. Slope 1 confirms.

Common random numbers across methods within a replicate, since they differ only in
how the same missing data are handled; MCSE clustered on the replicate block.
$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of complete-case MAIC against the
weighting and congenial-imputation arms, under MAR on **unmatched** covariates
with strong $\gamma_u$, across missingness rates.

**Decision rule.**

- Complete-case bias growing with the product and removed by the weighting arm:
  the mechanism is established, the existing solution is validated outside its
  original conditions, and the deliverable includes the matched-population
  discrepancy as a reportable quantity.
- Complete case unbiased across the grid: the refuting sentence holds for layer
  one and the study says so.
- The weighting arm failing where congenial imputation succeeds, or the reverse:
  the two are not interchangeable and the conditions separating them are the
  deliverable.

**A rate-based threshold is evaluated explicitly and expected to fail.** Whatever
the verdict, the study reports whether any missingness rate cleanly separates safe
from unsafe cells, because that is the rule practice actually uses.

## 8. Three controls, each of which can fail

**Null control.** MCAR at every rate: section 2 makes the shift zero in
expectation, so every method must be unbiased and complete case must lose only
precision. **A bias here means the deletion is doing something other than what
section 2 describes.**

**Second null control.** $\gamma_u = 0$ with strong MNAR: the unmatched covariates
have no effect, so **no missingness mechanism can bias the estimate**, at any rate.
Every method must be unbiased. **This is the exact test that the rate is not the
operative quantity**, and it is the cheapest way to establish the catalog's
threshold point.

**Positive control.** MAR on unmatched covariates, 50% missing, strong $\gamma_u$:
complete case must be biased by at least three MCSEs while the weighting arm is
not. If the weighting arm is also biased there, it is misimplemented, since that
is the condition it was derived for.

**Falsifier for the study's own headline.** The expected headline is that layer one
needs a method. Its falsifier is the realistic corner: if bias is material only at
missingness rates or $\gamma_u$ values outside what P2 establishes as realistic,
the honest conclusion is that the solution addresses a rare case. **P2 fixes the
realistic range before the run, so this cannot be judged after seeing the bias.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Three structurally different layers run as one factorial | Layers two and three excluded, in the title | removed |
| A rate-based threshold assumed to be the right test | Evaluated explicitly; the $\gamma_u=0$ control tests its logic | removed |
| Uncongenial imputation used as the imputation arm | Both carried; congeniality is a registered contrast | removed |
| MNAR results read as estimation | Generated at declared magnitudes; labeled sensitivity | removed |
| Balance tables trusted to detect the shift | Scored as a classifier; prediction registered | removed |
| Reinventing Fang et al. | Implemented from the paper and validated in P3 against its reported behavior | removed |
| Realistic range judged after seeing results | Fixed in P2 | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell; the analytic $b_{\text{CC}}$ | The grid | minutes |
| **P2** realistic ranges | Missingness rates and unmatched-covariate effects from the reviewed applied literature, fixed before the run | **The materiality verdict** | days |
| **P3** reproduction of the existing solution | That the implemented weighting arm reproduces Fang et al.'s reported simulation behavior on their own conditions | Whether the arm is a comparator or a confound | hours |
| **P4** unit cost | Per-replicate cost including imputation; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Multiple imputation multiplies its arms by the imputation count, which is the line
item this program has mispriced twice. Priced in P4.

---

## Relationship to the rest of the queue

- **MIS-04** owns model and bridge selection uncertainty; **DEC-11** owns
  propagation generally and this study's joint-propagation gap is named there.
- **EST-07** and **MIS-03** own target-summary uncertainty, held exact here.
- **COV-09** owns measurement non-equivalence, which is a different corruption of
  the same inputs.
- **DIA-10** owns data access simulated as benign, which is layer three taken
  seriously.
- **OVL-02** owns the diagnostic battery this study's matched-population
  discrepancy would join.
