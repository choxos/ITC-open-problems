# Protocol: which failures double robustness covers

**Target problem.** QBA-11. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A doubly robust (augmented weighting) estimator converges to the right functional of
the observed data when either the weighting or the outcome model is correct. An
omitted confounder changes that functional, so the DR estimator carries the same
omitted-variable bias as any other consistent estimator, and a sensitivity region
built on a misspecified estimator is translated, not widened. **Refuting sentence:**
at realistic magnitudes a DR estimator plus a conventional sensitivity grid is
adequate and a combined estimator would change no conclusion.

## 2. Correction found in the probe

With exact-balance (entropy) weights, augmentation by an outcome model whose terms are
all balanced is an identity: $\sum_i w_i\hat m(x_i) = E_T\hat m$, so the augmented
estimator equals MAIC exactly. The probe shows DR with both models correct equal to
MAIC with correct weights, and DR with both wrong equal to MAIC with wrong weights,
in every replicate. Augmentation changes the estimate only when the outcome model has
terms the weights do not balance. This is the known double robustness of entropy
balancing for linear outcome models, and it means DESIGN.md's four DR arms reduce to
two distinct estimators plus two copies of MAIC.

## 3. Design

Unanchored: individual data on 300 patients of A in the source; the target
publishes covariate means and SDs. Continuous outcome
$y = 1 + 0.5x_1 + 0.5x_2 + 0.4(x_1^2 - 1) + \gamma u + e$; source $x \sim N(0, I)$;
target $x_1 \sim N(\mu_1, 0.7^2)$, $x_2 \sim N(0.3, 1)$; omitted binary $u$ with
prevalence $0.3 + \delta$ in the source and 0.3 in the target, independent of $x$.
Estimand: the target mean of $Y(A)$ (B's published mean is subtracted in practice).
Every consistent estimator converges to $\Delta^\star = \Delta + \gamma\delta$.

Factors: $\gamma \in \{0, 0.25, 0.5, 1\}$, $\delta \in \{0.1, 0.3\}$,
$\mu_1 \in \{0.5, 1\}$ (overlap): 16 cells, **2000 replicates**.

Weighting: tilting on means (wrong, the variances differ) or on means and second
moments (correct). Outcome model: linear (wrong) or with $x_1^2$ (correct). Methods:
MAIC with each weighting, outcome regression with each model, and the augmented
estimator with each of the four combinations. Sensitivity region: the estimate minus
$\gamma'\delta'$ over $\gamma' \in [0, 1]$, $\delta' \in [0, 0.3]$, which contains every
simulated bias.

## 4. Decision

- **Primary.** DR with both models correct against each correctly specified
  single-model estimator across $\gamma$: the curves **coincide** if paired differences
  are within 3 MCSE (or below 0.005) in every cell and DR bias equals $\gamma\delta$
  within 3 MCSE.
- The table at $\gamma = 0$ and $\gamma = 1$: bias, location error
  (estimate minus $\Delta^\star$) and region inclusion for every method.
- **Refuting sentence fails** if a misspecified estimator's region includes the truth
  at $\gamma = 0$ in at least 90% of replicates while its location error exceeds 0.1,
  i.e. the grid looks adequate while its tipping point is wrong.

**Controls.** Null ($\gamma = 0$, both correct): all correct estimators unbiased.
Second null ($\gamma = 0$, one model wrong): DR unbiased, the wrong single model biased
beyond 3 MCSE. Positive ($\gamma = 1$, $\delta = 0.3$): every estimator biased beyond 3
MCSE. Falsifier: with both models wrong, bias minus its $\gamma = 0$ value minus
$\gamma\delta$ within 3 MCSE (additivity).

## 5. Departures from DESIGN.md

Continuous outcome, so the omitted-variable bias is exactly $\gamma\delta$ and the
correct outcome model stays correct after omitting $u$; a binary outcome would make
it only approximately correct. Treatment interaction with the omitted variable is not
a factor (unanchored, single arm). No cross-fitting (parametric nuisance models);
drMAIC's E-value screen not run. 16 cells.
