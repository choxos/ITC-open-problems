# Protocol: covariance of adjusted contrasts from a multi-arm trial

**Target problem.** CMP-12. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Population-adjusting a multi-arm trial's contrasts one at a time loses their
covariance, which has a shared-arm term and, DESIGN.md claims, a shared-weighting
term whose sign depends on how the arms' effect modification aligns; so ignoring the
covariance is not conservative in general. **Refuting sentence:** splitting a
multi-arm trial into independent pairwise comparisons costs little.

## 2. Design

Three-arm individual-data trial (A, B, C) in the source, $x \sim N(0,1)$, 200 per arm
in B and C and $200 r$ in A; outcome $y = 0.5x + d_t + \beta_t x + e$, $d = (0, -0.3,
-0.5)$, $\beta_A = 0$. MAIC with one weight vector to a target $x \sim N(s, 1)$.
Aggregate two-arm trials A versus C and B versus C, 200 per arm, run in the target.

| factor | levels |
|---|---|
| modification magnitude $\lvert\beta\rvert$ for B and C | 0, 0.3, 0.6 |
| alignment | $\beta_C = \beta_B$ (same), $\beta_C = -\beta_B$ (opposite) |
| target shift $s$ | 0.3, 0.8 |
| shared-arm ratio $r$ | 0.5, 1, 2 |

30 cells, **1000 replicates** (1.1 core-hours). Estimands: $d_{AB}$, $d_{AC}$, $d_{BC}$
in the target (closed form).

**Methods** (covariance given to the trial's pair $(\hat d_{AB}, \hat d_{AC})$): split
(each contrast's own stacked sandwich, covariance zero); fixed (joint sandwich with
weights treated as known); stacked (joint M-estimation of weights and arm means);
drop (trial removed). Each is reported for the trial alone and for the network by
generalized least squares with the two aggregate trials.

## 3. Outcomes and decision

Bias, coverage and width of each contrast per method, with MCSE. Covariance
recovery: mean estimated $\mathrm{Cov}(\hat d_{AB}, \hat d_{AC})$ over its Monte Carlo
value, with a bootstrap MCSE over replicates.

- **Primary:** coverage of $d_{BC}$ at $\lvert\beta\rvert = 0.6$, $s = 0.8$, for split
  and stacked, trial alone and network.
- **Sign test (DESIGN.md prediction 2):** confirmed only if split's trial-alone
  $d_{BC}$ coverage exceeds 0.95 beyond 3 MCSE in one alignment cell and falls below
  it beyond 3 MCSE in another. One-sided everywhere withdraws the claim.
- **Shared-weighting term:** (stacked minus fixed covariance) over the Monte Carlo
  covariance, per cell; and the Monte Carlo covariance at $\beta = 0$ against
  $\beta \ne 0$.
- **Dropping:** network $d_{AB}$ interval width, drop over stacked. A ratio above
  1.10 counts as material precision lost.

**Controls.** Null ($\beta = 0$): stacked and fixed covariance recovery agree within
3 MCSE. Nominal: stacked trial-alone coverage within $[0.93, 0.97]$ at $r = 2$,
$s = 0.3$.

## 4. Departures from DESIGN.md

The bootstrap arms are replaced by the stacked sandwich, their analytic equivalent,
which the study scores against the Monte Carlo covariance directly. Four-arm trials,
network-size levels and the one-stage ML-NMR arm are not run. The network is fixed:
the trial plus two aggregate trials. $n_{sim} = 1000$.
