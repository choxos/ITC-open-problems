# Protocol: the transported control-arm check as a classifier

**Target problem.** IDN-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Comparing a MAIC-transported control-arm outcome with the target's observed control
arm tests prognostic transport; the relative effect needs effect-modification
transport. So the check alarms on prognostic shifts that cancel in an anchored
contrast (false alarm) and passes modifier shifts that bias it (false reassurance).
**Refuting sentence:** the check's agreement tracks relative-effect bias closely
enough to be a usable screen.

## 2. Design

Anchored MAIC; individual data A versus C (300 per arm) in the source, arm counts on B
versus C in the target. Measured $x$ (matched), unmeasured prognostic $u$ and
unmeasured modifier $v$ of A's effect. Binary outcome
$\operatorname{logit} p = \operatorname{logit}(0.3) + 0.5x + 0.6u + \text{treatment}$, with A's
effect $-0.6 + 0.3x + 0.6v$ and B's $-0.4 + 0.3x$. Target $x \sim N(0.5, 1)$,
$u \sim N(\mu_u, 1)$, $v \sim N(\mu_v, 1)$.

| factor | levels |
|---|---|
| $\mu_u$ (prognostic shift) | 0, 0.3, 0.6 |
| $\mu_v$ (modifier shift) | 0, 0.3, 0.6 |
| target size per arm | 200, 500 |

18 cells, **1000 replicates** (0.1 core-hours). Estimands: anchored B-versus-A log OR
and the control-arm risk in the target (Monte Carlo over $10^6$ draws). The check is
$z = (\operatorname{logit}\hat p_C^{\text{transported}} - \operatorname{logit}\hat p_C^{\text{observed}})/\text{SE}$.

## 3. Decision

- **Confirmed** if with $\mu_u = 0$ and $\mu_v > 0$ the alarm rate ($\lvert z\rvert > 1.96$)
  is below 0.10 in every cell while the contrast is biased, and with $\mu_u = 0.6$,
  $\mu_v = 0$ it is above 0.20 while the contrast is unbiased.
- Operating characteristics across thresholds on $\lvert z\rvert$, and the per-replicate
  AUROC of $\lvert z\rvert$ for a biased contrast.

**Control.** No shift: alarm rate within Monte Carlo error of 0.05, contrast unbiased.

## 4. Departures from DESIGN.md

Binary outcome only; the survival-curve and RMST versions, offsetting mechanisms and
outcome-definition differences are not run. $n_{sim} = 1000$.
