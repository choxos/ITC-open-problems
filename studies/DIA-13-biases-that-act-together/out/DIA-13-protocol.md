# Protocol: do bias mechanisms in an unanchored MAIC combine additively?

**Target problem.** DIA-13 (also bears on QBA-22). Numerical study (population-level, no
sampling). Committed before the computation. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

The limit of an unanchored MAIC under several bias mechanisms is
$\Delta + b_1 + b_2 + b_{12}$, and the interaction $b_{12}$ is generally nonzero because the
mechanisms act on the same nonlinear estimator. **Refuting sentence:** biases combine
approximately additively at plausible magnitudes, so a one-at-a-time analysis bounds the joint
effect.

The refuting sentence contains two claims that can separate: additivity (small $b_{12}$) and
bounding (the joint bias no larger than the largest single-mechanism bias a one-at-a-time
analysis reports). Under exact additivity with biases of the same sign the joint bias is their
sum and exceeds each, so bounding fails even when additivity holds. Both are scored.

## 2. Design

Individual data on arm A in the source; the target publishes the covariate mean and B's event
proportion. $\operatorname{logit}P(Y = 1) = -1 + 0.5x + g_uU + \text{treatment}$ (B: $-0.4$). Source
$x \sim N(0, 1)$, $U \sim \text{Bern}(0.3)$; target $x \sim N(0.5, 1)$, $U \sim \text{Bern}(0.5)$.

| mechanism | parameter |
|---|---|
| omitted confounder | $g_u \in \{-1, -0.5, 0, 0.5, 1\}$ |
| comparator outcome misclassification | sensitivity $1 - m$, specificity $1 - m/2$, $m \in \{0, 0.1, 0.2\}$ |
| measurement error in the matched covariate | reliability $r \in \{1, 0.8, 0.6\}$ |

45 combinations, computed exactly by 80-point quadrature. Estimand: marginal log odds ratio,
B versus A, in the target. Interaction by inclusion-exclusion against each mechanism alone.

## 3. Decision

- **Additivity** holds if, wherever two or three mechanisms act, the interaction is at most 10%
  of the sum of the marginal biases.
- **Bounding** is reported as the number of such combinations where the joint bias exceeds the
  largest single-mechanism bias.
- Cancellation: combinations where the mechanisms' biases have opposite signs.

## 4. Departures from DESIGN.md

Population-level, so no estimation, QBA procedure, false reassurance or tipping sets; three
mechanisms, no selection mechanism or correlated sensitivity parameters; one overlap level.
