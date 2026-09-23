# Protocol: contribution shares of a network contrast across the plausible range of tau

**Target problem.** DEC-17. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Contribution measures that attribute a network estimate to its studies and comparisons are computed at the
point estimate of the between-study variance. **Refuting sentence:** contribution shares are stable over
the plausible range of $\tau$, so conditioning on a point estimate is harmless.

## 2. Design

Three treatments; two-arm studies of AB and AC (star) or AB, AC and BC (loop), allocated in turn; 4, 8 or 16
studies; within-study variances equal (0.04) or spread 5:1 (0.02 to 0.10, randomly assigned); true $\tau$ 0,
0.1 or 0.25. Target contrast C versus B. Random-effects network meta-analysis by generalized least squares,
$\tau^2$ by REML on a grid over $[0, 1]$, and its 95% profile-likelihood interval (capped at 1). Contribution
of study $s$: $|h_s|/\sum|h|$ with $h$ the target row of the hat matrix at a given $\tau$; a comparison's
contribution sums its studies'. 36 cells, **1000 networks** each.

## 3. Decision

**Primary:** loop network, 4 studies, 5:1 spread: the share of networks whose leading contributing comparison
changes across the $\tau$ interval. **Confirmed** if at least 10% at any true $\tau$; **refuted** otherwise.
Reported for every cell: the same at study level, the largest movement of any study's share across the
interval, the error of shares at $\hat\tau$ against shares at the true $\tau$, and whether the leading study at
$\hat\tau$ is the leading study at the true $\tau$. **Derived before the run:** in the star network the target
needs both comparisons with coefficient one, so comparison-level shares are 50% each at every $\tau$; only
study-level shares can move there.

Controls. **Second null:** with equal within-study variances the weights are proportional at every $\tau$, so
shares must be invariant (movement below $10^{-10}$). **Positive:** loop, 4 studies, 5:1, $\tau = 0.25$: mean
largest share movement at least 0.05. The first null ($\tau = 0$ fixed) is exact by construction and not run.

## 4. Departures from DESIGN.md

Frequentist only: no Bayesian draw-specific weight matrix, no information-matrix decomposition including the
variance block and no parametric bootstrap, so the three candidate quantities reduce to the value at
$\hat\tau$, the range over the interval and the value at the true $\tau$. One contribution measure (absolute
hat-matrix row), not the shortest-path or random-walk flow decompositions. Two-arm studies only; one outcome
scale.
