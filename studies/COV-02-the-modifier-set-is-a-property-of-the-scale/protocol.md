# Protocol: the adjustment set is a property of the scale

**Target problem.** COV-02. Numerical study (population-level, no sampling). Committed
before the computation. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim and correction

The covariates an adjustment must balance depend on the scale of the decision contrast.
**Refuting sentence:** at realistic effect sizes the sets coincide on every scale a decision
would use.

**Correction.** DESIGN.md section 2 says that on the risk-difference scale only conditional
modifiers matter. That holds only when the outcome model is linear in risk. With a logistic
model the conditional risk difference varies with baseline risk, so every prognostic variable
modifies it, and the risk-difference set is not the conditional-modifier set. Membership then
differs little between marginal scales; what differs is how much each variable matters. The
study therefore defines a set by consequence: a variable belongs if leaving it unbalanced
changes the target contrast by more than 5% of the contrast. DESIGN.md's nesting prediction
(the marginal odds ratio set contains the risk-difference set) is tested as stated.

## 2. Design

$\operatorname{logit}p = \operatorname{logit}(0.25) + g\sum_jx_j + A(-0.5 + 0.3\sum_{j \le m}x_j)$ with $m$
conditional modifiers and $k$ prognostic non-modifiers; source $x \sim N(0, I)$, target
$N(\mu\mathbf 1, I)$. Balancing means moves each balanced covariate to its target law exactly
(independent normals), and an omitted covariate stays at its source law.

| factor | levels |
|---|---|
| conditional modifiers $m$ | 0, 1, 3 |
| prognostic non-modifiers $k$ | 2, 6 |
| prognostic strength $g$ | 0.3, 0.6 |
| imbalance $\mu$ | 0.2, 0.5 |

24 scenarios; contrasts from $10^6$ common random draws (differences exact to about
$10^{-4}$). Scales: risk difference, log risk ratio, marginal log odds ratio, and the
conditional log odds ratio at the target mean.

## 3. Decision

- **Refuting sentence fails** if the number of prognostic non-modifiers that matter differs
  between the risk difference, the marginal and the conditional log odds ratio in at least
  half of the scenarios.
- The nesting prediction is reported as the share of scenarios where it holds.
- With no conditional modifiers, the conditional set is empty; the marginal sets are
  reported (DESIGN.md's sharpest control).

## 4. Departures from DESIGN.md

No time-to-event scale; no sampling, so estimation of the sets (COV-01's subject) and
overlap are not studied; one anchored-type transport of the A-versus-C contrast.
