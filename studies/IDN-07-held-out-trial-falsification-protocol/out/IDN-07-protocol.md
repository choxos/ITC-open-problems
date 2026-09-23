# Protocol: calibrating a held-out-trial falsification rule

**Target problem.** IDN-07. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Withholding a trial, predicting its contrast from the rest and comparing with what it
observed is a coherent falsification check only if the prediction targets the withheld
trial's own population and the discrepancy's variance includes every component:
prediction, observation and between-trial heterogeneity. **Refuting sentence:** with an
externally prespecified target a standardized residual with nominal calibration is
adequate, so the missing object is a convention. DESIGN.md expects the size to be
controllable and the power to be low.

## 2. Design

One individual-data trial of B versus C (300 per arm, $x \sim N(0, 1)$) and five aggregate
trials (200 per arm, $x \sim N(\mu_k, 1)$, $\mu_k = s\cdot(-0.4, 0, 0.4, 0.8, 1.2)$). Continuous
outcome $y = 0.5x + A(-0.3 + 0.3x + u_k + v\,\mathbb 1[k = \text{withheld}]) + e$, heterogeneity
$u_k \sim N(0, \tau^2)$, violation $v$. Aggregate trials report the mean difference, its SE and
the covariate mean.

Factors: $v \in \{0, 0.15, 0.3\}$, $\tau \in \{0, 0.1\}$, $s \in \{1, 2\}$, withheld trial
central (third) or peripheral (fifth): 24 cells, **2000 replicates** (0.2 core-hours).

Prediction: STC from the individual data at the withheld trial's reported covariate mean.
$D$ = prediction minus observed. Rules, each flagging at $\lvert z\rvert > 1.96$:

| rule | variance of $D$ |
|---|---|
| full | prediction + observed + $\hat\tau^2$ (DerSimonian-Laird from the other trials' residuals) |
| naive | prediction + observed |
| reduced-network target | prediction at the mean covariate of the remaining trials, full variance |
| decision flip | flags when prediction and observation fall on opposite sides of 0 |

## 3. Decision

- **A calibrated rule exists** if the full rule's size is at most 0.07 in every null cell
  and its power at $v = 0.15$ is at least 0.80 everywhere.
- **Coherent but underpowered** if its size holds and its power at $v = 0.3$ is below 0.50
  everywhere; then the registered output is that a pass licenses little.
- Otherwise the size failure or mixed power is reported per position.
- $E[D]$ under the null with the external and the reduced-network target, and the share of
  $\operatorname{Var}(D)$ each component explains.

**Controls.** Null ($v = 0$, $\tau = 0$): the full rule near nominal. Second null (reduced-
network target, peripheral trial): $E[D] \ne 0$ and inflated size. Positive ($v = 0.3$,
central, $\tau = 0$): the highest power in the grid.

## 4. Departures from DESIGN.md

Continuous outcome and STC prediction rather than a network with MAIC or ML-NMR weights,
so weight-estimation variance is absent; the Bayesian predictive-tail rule and the
conditional-moment test are not run; the target covariate mean is the withheld trial's
reported sample mean; 2000 rather than 4000 replicates.
