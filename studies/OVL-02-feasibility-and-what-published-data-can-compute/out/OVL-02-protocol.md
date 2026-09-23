# Protocol: is an infeasible MAIC calibration signaled, and by what?

**Target problem.** OVL-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md);
the registered shifts are in `results/shifts.csv`.

## 1. Claim

Method-of-moments MAIC has a solution only if the target mean lies in the convex hull
of the source covariate rows, which a linear program decides exactly. Without one,
the optimizer drifts and may report success. DESIGN.md: ESS cannot separate "hard"
from "impossible". **Refuting sentence:** infeasibility is rare and the resulting ESS
is low enough that existing conventions catch it.

**Addition from the probes.** At any solution the residual imbalance
$\max_j \lvert\sum_i w_i(x_{ij} - m_j)\rvert / \sum_i w_i$ is zero; without one it is
bounded away from zero. So the balance check MAIC already prints detects infeasibility
exactly when it is computed from the returned weights rather than assumed. In the pilot
(dimension 8), feasible replicates had residual at most 5.1e-5 and infeasible ones at
least 1.4e-2, and the optimizer reported convergence in 34% of infeasible replicates.

## 2. Design

Source trial A versus C, 200 per arm, $x \sim N(0, I_d)$; binary outcome
$\operatorname{logit} p = \operatorname{logit}(0.3) + 0.4\sum_j x_j - 0.5A + \beta x_1 A$.
Target $N(s\,u, I_d)$, $u$ the equal-weight unit vector. MAIC on means.

| factor | levels |
|---|---|
| dimension $d$ | 3, 8 |
| shift $s$ | 1.5 (feasible with margin); the shifts giving 10, 30, 50, 70, 90% infeasible (P2) |
| modification $\beta$ | 0, 0.5 |

24 cells, **1000 replicates** (0.4 core-hours). Estimand: target marginal log OR of A
versus C, by Monte Carlo over 400,000 target draws.

## 3. Outcomes and decision

Per replicate: linear-program feasibility (truth), optimizer convergence code,
residual imbalance, ESS, maximum normalized weight, estimate error and coverage.

- **Primary:** AUROC for infeasibility of ESS (low reads as risk), of maximum weight,
  of residual imbalance, and of the optimizer's convergence code; and, at the
  conventional reading "ESS below 10% of $n$", the share of infeasible analyses
  flagged and of feasible analyses flagged. The refuting sentence holds if ESS's
  AUROC is at least 0.95 and the 10% rule flags at least 95% of infeasible and at most
  20% of feasible analyses.
- **Silent failure:** share of infeasible replicates the optimizer reports as
  converged.
- **Consequence:** bias and coverage in feasible versus infeasible replicates.
- **Rate:** infeasibility at the easy shift.

**Controls.** Easy shift: every replicate feasible and residual below 1e-4.

## 4. Departures from DESIGN.md

Tail-overlap, omitted-moment and network-redundancy factors are not run; the
computability taxonomy is reported from the design as an analytic table, not
simulated. Only MAIC on means. $n_{sim} = 1000$.
