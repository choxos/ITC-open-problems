# Protocol: one MNAR sensitivity parameter through several routes, and the shape of the tipping set

**Target problem.** CMP-21. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

An MNAR shift $\delta$ in imputed effect-modifier values enters a transported anchored contrast through the
fitted interaction in each trial, through the integration law built from the completed data, and through
differences in missingness between the trials that the anchor would otherwise cancel. The routes can
offset, and the contrast need not be monotone in $\delta$, so the tipping set need not be one point.
**Refuting sentence:** the routes share a sign and a tipping-point analysis behaves as in an ordinary MAIC.

## 2. Design

Two individual-data trials sharing control C (A versus C, B versus C), 300 per arm, $x \sim N(0, 1)$,
$\operatorname{logit}p = -0.5 + 0.6x + a_A(-0.4 + 0.4x) + a_B(-0.6 + 0.4x)$. $x$ missing with probability
$\operatorname{expit}(c_j + x)$ (not at random), 30% in trial 1 and 30% or 10% in trial 2. Imputation by normal regression
of $x$ on outcome, arm and their product among complete cases, plus the shift $\delta \in [-1.5, 1.5]$ (step 0.1),
one imputation with common random draws across $\delta$. Each trial: logistic regression with the treatment
interaction, standardized to a target $x \sim N(0.8, s^2)$ with $s = 1$ (integration route off) or the completed
trial's SD (on). Estimand: the marginal log odds ratio B versus A in the target. The tipping set: the $\delta$
values at which the estimate's sign differs from its sign at $\delta = 0$. 4 cells, **500 replicates**.

## 3. Decision

**Primary:** the share of replicates whose tipping set is not a single point (two or more separate reversed
stretches, or a reversal that reverts inside the range), with differing missingness. **Confirmed** if at least
5% in either integration setting; otherwise **refuted** if the curve is also rarely flat (maximum movement
under 0.05 in under 5% of replicates), and **cancellation without non-unique sets** if not. Reported:
non-monotonicity, flatness, mean slope and movement, and bias at $\delta = 0$.

## 4. Departures from DESIGN.md

Two individual-data trials anchored through a common control rather than a disconnected component network,
so the bridge route is the anchor's cancellation of equal missingness; one imputation per $\delta$ rather than
multiple imputation; frequentist STC rather than component ML-NMR; the imputation model is congenial by
construction; one MNAR mechanism.
