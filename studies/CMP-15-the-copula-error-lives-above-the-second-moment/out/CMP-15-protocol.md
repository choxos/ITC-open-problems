# Protocol: copula family error after correlation calibration

**Target problem.** CMP-15. Population-level numerical study (no sampling of trials). Committed before the
computation's results were seen. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A Gaussian copula calibrated to reproduce the covariates' correlations fixes the variance of any linear
predictor, which is everything a curved link needs to second order; any remaining error lives in
asymmetry and tail dependence. **Refuting sentence:** once the correlation is calibrated, the residual
copula error is too small to move a standardized contrast at realistic link curvatures.

## 2. Design

Three target covariates with common margins, standard normal or a standardized Beta(2, 6) (skewed and
bounded, so every link's marginal mean exists), and exchangeable dependence from a true copula: Gaussian,
Clayton (lower tail), Gumbel (upper tail) or $t$ with 3 degrees of freedom (both tails). Each copula's
parameter is calibrated so the mean pairwise Pearson correlation of the covariates is $r \in \{0.3, 0.6\}$.
Outcome model $\eta_a = \alpha + 0.5\sum_j x_j + a(-0.5 + \gamma\sum_j x_j)$, $\gamma \in \{0.15, 0.3\}$. Estimand:
the target-standardized marginal contrast $h(E[h^{-1}(\eta_1)]) - h(E[h^{-1}(\eta_0)])$ for identity, logit,
log and complementary log-log links (the last is survival at $t = 1$ under an exponential model, so the
contrast is the marginal log cumulative hazard ratio).

Each joint law is evaluated with $10^6$ draws in four batches, with $\sum_j x_j$ as a control variate (its
mean is zero exactly). Reconstructions: Gaussian copula with latent correlation calibrated to reproduce
$r$ (current practice), Gaussian with latent correlation $r$ (uncalibrated), and each other family
(Gaussian, Clayton, Gumbel, survival Clayton, survival Gumbel) calibrated to $r$. The envelope is the range
over those five families. Error: reconstruction contrast minus true contrast; MCSE from the batches.
Integration order: the calibrated Gaussian at 64, 256, 1024 and 4096 randomized quasi-Monte Carlo points
(Sobol with 200 random shifts), $r = 0.6$.

## 3. Decision

Decision threshold 0.02 on the link scale (a fifth of a standard error of 0.1).

**Primary:** calibrated Gaussian error on the complementary log-log scale with a tail-dependent truth
(Clayton or Gumbel), over margins, $r$ and $\gamma$. **Family matters** if some error exceeds 0.02 in absolute
value and 3 MCSE; **refuted** if every error for every link and every true copula is below 0.02.

Secondary: errors for the logit and log links; the uncalibrated Gaussian's error (the size of the upstream
fix); the misspecified flexible families' errors against the calibrated Gaussian's (**falsifier:** if a wrong
flexible family is further from the truth than the calibrated Gaussian in most cells, the deliverable is
an envelope rather than a flexible copula); envelope width and whether it contains the $t$-copula truth,
which lies outside the five families (containment is automatic for the others); RMSE of the calibrated
Gaussian by integration order against its limiting error.

Controls. **Matched margins:** realized mean Pearson correlation within 0.005 of $r$ for every calibrated
family. **Null:** at the identity link every error is zero (exact here, because the control variate makes
the identity contrast equal $-0.5$ for every law). **Positive:** log link, Gumbel truth, Beta margins,
$r = 0.6$, $\gamma = 0.3$: calibrated Gaussian error beyond 3 MCSE.

## 4. Departures from DESIGN.md

Population level: no trials are simulated, so bias is the error and coverage is not defined. Three
covariates only, one exchangeable dependence parameter per copula, common margins; no mixed or discrete
margins, so the numerical inversion of latent correlations for discrete margins is not measured; no vine;
no reconstruction uncertainty. The "flexible copula correctly specified" arm is the truth itself and has
zero error by construction.
