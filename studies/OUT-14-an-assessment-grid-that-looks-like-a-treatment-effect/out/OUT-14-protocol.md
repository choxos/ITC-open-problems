# Protocol: assessment grids that differ between trials

**Target problem.** OUT-14. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

An event assessed on a grid of spacing $d$ is recorded at the next visit. Treating
recorded times as exact inflates RMST at horizon $\tau$ by about $(d/2)F(\tau)$, half
the spacing times the probability of an event before $\tau$; DESIGN.md wrote $d/2$
without $F(\tau)$. Within one trial the shift is shared by both arms; across trials
with different grids it enters the contrast, and no covariate balancing acts on it.
**Refuting sentence:** the coarsening from realistic grids is small relative to the
estimand, so treating interval-censored times as exact is harmless.

## 2. Design

Unanchored comparison of single arms A (trial 1, grid $d_1$) and B (trial 2, grid
$d_2$), 300 each, Weibull event times (shape 1.2), dropout uniform on 12 to 60 months,
administrative censoring at 36 months, $\tau = 24$.

| factor | levels |
|---|---|
| $d_1$ (months) | 0 (continuous), 1, 2, 3 |
| $d_2$ | 0, 3 |
| A's median | 8, 16 months |
| B's median minus A's | 0, 3 months |

32 cells, **1000 replicates** (1.6 core-hours). Estimand: RMST(24) of B minus A,
exact by integration.

Methods: Kaplan-Meier on recorded times as exact; Kaplan-Meier after moving each
recorded event back by $d/2$ (midpoint); interval-censored Weibull fit (events in
(previous visit, recorded visit]), which is correctly specified here.

## 3. Decision

- **Materiality confirmed** if the naive bias exceeds 0.25 months, beyond its 95%
  Monte Carlo interval, in every cell where the grids differ by 2 months or more.
- **Mechanism:** slope of naive cell bias on $(d_2/2)F_B(\tau) - (d_1/2)F_A(\tau)$.
- **Repairs:** bias of midpoint and interval-censored methods.

**Control.** Equal grids: naive within 3 MCSE of zero.

## 4. Departures from DESIGN.md

The binary event-by-time endpoint and the different-maximum-follow-up estimands are
not run; pseudo-IPD reconstruction error is not simulated (recorded times are used
directly, which is what an ideal reconstruction returns); no covariates, since the
grid acts on the time axis and balancing cannot reach it. The interval-censored model
is correctly specified, which favors it.
