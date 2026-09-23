# Protocol: target moments released under differential privacy

**Target problem.** ADJ-15. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A target trial releasing covariate moments under differential privacy adds noise of
known variance. MAIC to the noisy moments estimates the effect in a displaced
population; the variance to add is $g^\top\Sigma_{\text{noise}}g$ with
$g = \partial\hat\Delta/\partial m$ and $\Sigma_{\text{noise}}$ known exactly
($2b^2$ per Laplace-released statistic). Noise variance scales as
$1/(n\varepsilon)^2$, sampling variance as $1/n$, so small arms and small budgets are
where it matters; and splitting the budget over more statistics raises each one's
noise. **Refuting sentence:** at budgets that preserve the guarantee the noise is
small relative to sampling error, so propagation adds nothing.

## 2. Design

Source trial A versus C, 200 per arm, two covariates clipped to $[-3, 3]$; continuous
outcome $y = 0.5\sum x_j + A(-0.4 + 0.4x_1 + \beta_2 x_1^2) + e$. Target trial of size
$n_T$ with covariates $N(0.5, 0.8^2)$ clipped. The target releases pooled means
(sensitivity $6/n_T$) or means and second moments (sensitivity $9/n_T$), with the
budget split equally.

| factor | levels |
|---|---|
| target size $n_T$ | 40, 150, 500 |
| budget $\varepsilon$ | 0.5, 1, 4, none |
| released | means; means and second moments |
| modification | linear ($\beta_2 = 0$); quadratic ($\beta_2 = 0.3$) |

48 cells, **1000 replicates** (0.7 core-hours). Truth: the effect at the target
trial's own non-private moments, so its sampling error is not part of this study.

Methods: MAIC to the non-private moments; MAIC to the private moments ignoring the
noise; the same with $\hat g^\top\Sigma_{\text{noise}}\hat g$ added, $\hat g$ by
central differences.

## 3. Decision

- **Refuting sentence holds** if ignoring the noise gives coverage at least 0.93 in
  every cell with $\varepsilon \ge 1$ and $n_T \ge 150$.
- **Propagation:** coverage of the propagated interval in every private cell.
- **Released statistics:** RMSE of means-only against means-and-second-moments by
  modification form and budget.

**Controls.** $\varepsilon$ = none: the two private methods equal the non-private
one. Linear modification with means released at $n_T = 500$, $\varepsilon = 4$: all
coverage within $[0.93, 0.97]$.

## 4. Departures from DESIGN.md

Gaussian mechanism, correlation release, overlap levels and the EST-07 comparison
arm are not run. $n_{sim} = 1000$.
