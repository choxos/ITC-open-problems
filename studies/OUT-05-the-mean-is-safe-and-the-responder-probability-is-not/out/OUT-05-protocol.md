# Protocol: the transported mean is safe and the responder probability is not

**Target problem.** OUT-05. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

With an identity link and a correct conditional mean, the target-standardized mean
contrast contains no residual variance, so a pooled residual SD cannot bias it. A responder
probability $P(Y > c \mid x) = \Phi\{(\mu(x) - c)/\sigma\}$ contains $\sigma$ directly, with a
bias whose sign depends on which side of the threshold the conditional mean lies. A floor on
the scale adds a bias that depends on how far the target sits from the floor, so population
adjustment changes it. **Refuting sentence:** responder probabilities under a pooled normal
residual are close enough to the truth at realistic dispersion differences and boundary
masses that the distinction is formal.

## 2. Design

Source trial A versus C, 300 per arm, $x \sim N(0, 1)$; target $x \sim N(m, 1)$. Latent
$Y^* = 20 + 5x + A(4 + 2x) + \sigma_Ae$, $\sigma_C = 6$, $\sigma_A = 6r$; $e$ standard normal or
standardized Gamma(4); observed $Y = \max(Y^*, \text{floor})$ with the floor set for the
declared mass in the source control arm. Responder thresholds: the target control arm's
latent median (near) and 90th percentile (tail).

| factor | levels |
|---|---|
| SD ratio $r$ | 1, 2 |
| skewness | none, moderate |
| floor mass | 0, 0.10, 0.25 |
| target shift $m$ | 0.3, 1 |

24 cells, **1000 replicates**. Estimands in the target, from $4\times10^5$ Monte Carlo draws:
mean contrast and responder-probability contrasts at both thresholds.

Methods (G-computation over the target law): normal linear model with a pooled residual SD;
with arm-specific SDs; censored normal (Tobit) with arm-specific scales; logistic regression
of the responder indicator.

## 3. Decision

- **Dissociation confirmed** if the pooled-SD model's mean contrast is unbiased (within 3
  MCSE) in every cell without a floor, while at SD ratio 2 its responder contrast is biased
  beyond 3 MCSE and 0.02 at one threshold or both in every cell.
- **Refuting sentence fails** if a pooled-SD responder bias exceeds 0.03 at SD ratio 2.
- Floor by shift: the linear model's mean-contrast bias at floor mass 0.25 at each shift.
- Bias and RMSE of every method for all three estimands.

**Control.** SD ratio 1, no skew, no floor: every method unbiased.

## 4. Departures from DESIGN.md

One IPD trial with arm-specific rather than study-specific dispersion; no ceiling; bias and
RMSE only (no intervals); skewness from a gamma error rather than a skew-normal family; no
ML-NMR.
