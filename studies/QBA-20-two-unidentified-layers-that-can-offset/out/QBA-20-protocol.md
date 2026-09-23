# Protocol: two unidentified bias layers on one cross-gap contrast

**Target problem.** QBA-20. Population-level numerical study. Committed before the computation.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

In a disconnected component comparison with no cross-gap evidence, population transportability and
component invariance are both unidentified and can offset, so one-at-a-time sensitivity analysis can
report robustness the joint analysis does not support. **Refuting sentence:** the two layers do not cancel at
plausible magnitudes, so one-at-a-time curves bound the joint effect.

## 2. Design

Individual model for the cross-gap comparison of A with B:
$\operatorname{logit}p = -0.5 + 0.5x + 0.5u + a(-0.45 + 0.3x + 0.4u + d_m + d_iu)$, $x$ measured, $u$ an omitted
modifier; target $x \sim N(0.5, 1)$, $u \sim N(\mu_u, 1)$. The analysis assumes $\mu_u = 0$ (population layer) and
$d_m = d_i = 0$ (bridge layer: component main-effect drift and component-by-modifier drift), and reports a
target marginal log odds ratio of about $-0.20$, favoring A. Bias = reported minus true, by 24-point
Gauss-Hermite quadrature in each covariate. Elicited half-ranges at scale 1: $\mu_u$ 0.5, $d_m$ 0.2, $d_i$ 0.4;
scales 0.5, 1 and 1.5. One-at-a-time: each parameter over its range with the others at zero (21 points).
Joint: the $21^3$ grid over the box, and 4000 draws from elicited distributions on the box (independent
uniform, or a Gaussian copula with correlation $\pm 0.5$ between $\mu_u$ and each bridge parameter).

## 3. Decision

**Primary:** spurious robustness at scale 1: the one-at-a-time analysis finds no reversal of the decision
while the joint box contains reversals. **Refuting sentence holds** if at every scale the one-at-a-time
envelope contains at least 95% of the joint box and of each elicited distribution; otherwise it fails.
Reported: both envelopes, the share of the box and of each elicited distribution outside the one-at-a-time
envelope and reversing the decision, and masking (both layers at least 0.1 in absolute value, net bias
below 0.05).

Controls. **Null:** at the origin the bias is zero. **Second null:** with only the population layer active the
one-at-a-time curve contains the effect exactly. **Positive:** at scale 1 the one-at-a-time analysis is robust
and the joint box contains a reversal.

## 4. Departures from DESIGN.md

Population level: no sampling, fitting or Stan, so bias is the only error and coverage is not defined; binary
outcome only; component-by-component non-additivity and backbone interactions not included; the joint
target law of $x$ and $u$ is known (independence), so the marginals-only arm is not run; no
partial-identification bounds beyond the box envelope. The attribution of bias between layers (population
alone versus the remainder) is one stated rule, not a decomposition of a real quantity.
