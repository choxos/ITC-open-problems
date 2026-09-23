# Protocol: a simulated-covariate bias analysis by STC and by MAIC

**Target problem.** QBA-13. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A published simulated-covariate bias analysis restricts itself to STC because a MAIC extension "would
suffer extreme effective-sample-size loss and might fail to produce feasible weights". Both are computable.
**Refuting sentence:** the MAIC extension is feasible across the realistic range, its effective-sample-size
loss is comparable to the precision the STC route pays, and the restriction was a conservative choice.

## 2. Design

Unanchored: individual data on 300 patients of A; the target publishes the mean of $x$ (0.5). Unmeasured
binary $U$ with $P(U = 1 \mid x) = \operatorname{logit}^{-1}(a + \rho x)$, prevalence 0.3 in the source and 0.5
in the target; $\operatorname{logit}P(Y = 1) = -1 + 0.5x + 0.8U$. $\rho \in \{0, 0.8\}$: 2 cells, **500
replicates**. The analyst knows $\rho$ and the outcome association and sweeps the assumed target
prevalence of $U$ over 0.1, 0.3, 0.5, 0.7 and 0.9. For each value, ten imputations of $U$ from its
posterior given $x$ and $y$ in the source; STC fits $y \sim x + U$ and standardizes over the target;
MAIC balances the means of $x$ and $U$; Rubin's rules. Estimand at each sweep point: A's marginal log odds
in a target with that prevalence (the analysis's own target).

## 3. Decision

**Refuting sentence holds** if MAIC weights are feasible in at least 95% of replicates at every sweep
point and MAIC's SE is at most 1.25 times STC's there; otherwise it fails. Effective sample size along the
sweep, bias and coverage of both routes are reported.

## 4. Departures from DESIGN.md

One binary unmeasured covariate with a logistic dependence on $x$ (no copula factor); the outcome
association and dependence are assumed correctly; no decision threshold reading; unanchored A side only.
