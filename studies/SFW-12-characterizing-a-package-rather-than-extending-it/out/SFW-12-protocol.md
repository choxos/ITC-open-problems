# Protocol: how far outstandR's G-computation estimate moves across target reconstructions

**Target problem.** SFW-12. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

outstandR (2.0.0, CRAN) reconstructs the aggregate trial's covariates from published means and SDs with
normal margins and a Gaussian copula whose parameter defaults to the IPD's correlation. The estimate can
move with that reconstruction. **Refuting sentence:** the estimate is insensitive to the reconstruction
across defensible alternatives, so the gap is only the absence of network validation.

## 2. Design

Target covariates $x_1 \sim \text{Gamma}(2, 2)$, $x_2 \sim \text{Gamma}(4, 4)$, joined by a Clayton (tail-dependent) or
Gaussian copula at Pearson correlation 0.5; IPD covariates $\text{Gamma}(2, 2.5)$ and $\text{Gamma}(4, 5)$ with a
Gaussian copula at correlation 0.5 (same) or 0.1 (different). Binary outcome
$\operatorname{logit}p = -1 + 0.5x_1 + 0.5x_2 + a(\delta + 0.6x_1 + 0.4x_2)$, $\delta = -0.5$ for A and $-0.7$ for B; 300 per arm per trial.
Estimand: anchored marginal log odds ratio B versus A in the target (Monte Carlo, $2 \times 10^6$). The package's
internal `gcomp_ml_means()` is called directly, without its bootstrap, with 20000 pseudo-patients under five
reconstructions: default (normal margins, IPD correlation), normal margins with the target's sample
correlation, normal margins with independence, gamma margins by moments with the IPD correlation, gamma
margins with the target correlation. 4 cells, **400 replicates**.

## 3. Decision

**Primary:** the mean over replicates of the range of the estimate across the five reconstructions, in the
Clayton cells. **Material** if at least 0.05 on the log odds ratio scale in some cell; otherwise refuted for the
reconstruction half. Reported: bias, empirical SD and RMSE of each reconstruction, and the range split into
correlation choices and margin family.

## 4. Departures from DESIGN.md

Pairwise anchored comparison only (no network), two covariates, one outcome model (correctly specified),
no Bayesian G-computation or multiple-imputation marginalization, point estimates only (no intervals).
