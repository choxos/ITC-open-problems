# Protocol: a negative-control outcome for transport bias

**Target problem.** IDN-09. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A negative-control outcome calibrates confounding within one data source because it shares the
confounding pathway. Across studies the bias is a transport gap, and a control shares it only
if the unmeasured covariate affects the control as it affects the primary outcome, including any
modification of the treatment effect, which an outcome without a treatment effect cannot have.
**Refuting sentence:** the existing calibration machinery transfers to transport with its
operating characteristics intact.

## 2. Design

Unanchored: individual data on 500 patients of A; the target publishes B's (500) proportions of
the primary outcome $Y$ and a negative-control outcome $N$, and the mean of a measured covariate
$x$. Unmeasured $V \sim N(0, 1)$ in the source and $N(\text{shift}, 1)$ in the target.
$Y$: $\operatorname{logit} = -1 + 0.5x + 0.5V$ plus B's effect $-0.4$ or A's modification $\beta V$;
$N$: $\operatorname{logit} = -1 + 0.5x + g_NV$, no treatment effect. MAIC balances $x$.

Factors: $g_N \in \{0, 0.25, 0.5, 1\}$ (0.5 equals the primary's), $\beta \in \{0, 0.5\}$,
shift $\in \{0, 0.5\}$: 16 cells, **2000 replicates**. Estimand: marginal log odds ratio of $Y$, B
versus A, in the target.

Methods: naive MAIC contrast; negative-control test (MAIC contrast on $N$, $\lvert z\rvert > 1.96$);
calibrated contrast (primary minus control, variances added).

## 3. Decision

- **Refuting sentence fails** if, with a population shift, the calibrated contrast is biased beyond
  0.1 and 3 MCSE in some cell other than the one where the control matches the primary exactly
  ($g_N = 0.5$, $\beta = 0$).
- Size and power of the control test; coverage of both contrasts.

## 4. Departures from DESIGN.md

No availability survey of control outcomes in appraisal records; one control outcome rather than
a bank; empirical calibration reduced to subtraction; unanchored only.
