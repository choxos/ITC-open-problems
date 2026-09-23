# Protocol: a proportional-odds violation and the utility increments it meets

**Target problem.** OUT-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

The difference in expected utility is $\sum_k (u_{k+1} - u_k)\,\Delta P(Y > k)$, so a proportional-odds violation at
cut-point $k$ reaches the decision in proportion to the utility increment there. **Refuting sentence:**
proportional odds is close enough at realistic cut-point-specific effects that the relaxed model gives the
same target-standardized decision quantity.

## 2. Design

One trial of A versus C, 300 per arm, $x \sim N(0, 1)$; four ordered categories from
$\operatorname{logit}P(Y > k) = \alpha_k + 0.8x + a\beta_k$ with $\alpha = (1.2, 0, -1.2)$ and $\beta = (0.5, 0.5, 0.5)$
(proportional odds), $(1.2, 0.3, 0.2)$ (violation at the bottom) or $(0.2, 0.3, 1.2)$ (at the top). Target
$x \sim N(0.5, 1)$. Estimand: expected-utility difference A minus C, with utilities $(0, 0.6, 0.8, 1)$ (increments at
the bottom) or $(0, 0.2, 0.4, 1)$ (at the top), by numerical integration. Methods: proportional-odds regression
and separate logistic regressions per cut-point, each standardized over the target by G-computation, with
60-resample bootstrap SEs. 3 cells, **400 replicates**, both utilities on each replicate.

## 3. Decision

**Primary:** the proportional-odds fit's bias. **Confirmed** if, for both violations, the bias when the
violation and the utility increments sit at the same end is at least 0.02 in absolute value and at least
twice the bias when they sit at opposite ends. Reported: bias, RMSE, coverage and SE ratio for both methods.
**Null control:** under proportional odds the proportional-odds fit is unbiased within 3 MCSE with coverage
0.93 to 0.97.

## 4. Departures from DESIGN.md

One individual-data trial rather than an ML-NMR network; separate cut-point logistic regressions as the
relaxed model (no partial proportional odds or multinomial arm, no monotonicity constraint); fixed rather
than uncertain utilities; no dichotomized-publication arm.
