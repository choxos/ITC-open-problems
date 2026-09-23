# Protocol: planning a MAIC in information rather than in n

**Target problem.** OVL-06. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A planner can compute three candidate precisions before any data exist, from posited
source and target laws: the nominal-$n$ variance; the same with each arm's $n$
replaced by its Kish ESS; and the estimator's own influence-function variance
(stacked estimating equations evaluated on a large draw from the posited laws).
**Refuting sentence:** nominal $n$ with a crude overlap adjustment predicts achieved
precision well enough for planning. DESIGN.md also predicts Kish ESS errs toward
pessimism; the probe found it optimistic at poor overlap (planned SE 0.429 against an
achieved 0.532), and the run tests the direction across the grid.

## 2. Design

Individual-data trial A versus C with $d$ independent normal covariates; binary
outcome $\operatorname{logit} p = \operatorname{logit}(\pi) + 0.4\sum_j x_j/\sqrt d + A(-0.5 + 0.4x_1)$;
MAIC on means to a target at Mahalanobis distance $s$.

| factor | levels |
|---|---|
| total $n$ | 150, 400, 1000 |
| shift $s$ | 0.2, 0.5, 0.8 |
| dimension $d$ | 2, 5 |
| allocation A:C | 1:1, 2:1 |
| prevalence $\pi$ | 0.1, 0.3 |

72 cells, **1000 replicates** (about 1 core-hour). Estimand: the SD of the MAIC
estimate of the marginal log OR, achieved over replicates (MCSE $s/\sqrt{2(n-1)}$).

## 3. Decision

- **Refuting sentence holds** if the Kish-based planned SE is within 10% of the
  achieved SD in at least 90% of cells.
- The same criterion reported for the nominal and influence-function plans.
- **Direction:** share of cells where the Kish plan is pessimistic (planned above
  achieved).

## 4. Departures from DESIGN.md

The unanchored bias-floor arm and the survival (RMST) arm are not run; overlap is
indexed by Mahalanobis distance rather than the positivity template. $n_{sim} = 1000$.
