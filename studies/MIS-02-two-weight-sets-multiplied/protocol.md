# Protocol: participation weights multiplied by censoring weights (TADA) under heavy censoring and poor overlap

**Target problem.** MIS-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

TADA multiplies method-of-moments participation weights by inverse-probability-of-censoring weights and
estimates variance by the bootstrap; its behavior under heavy censoring, poor overlap and censoring-model
misspecification is unmapped. DESIGN.md's mechanism: the product's effective sample size collapses faster
than either factor's when the two weight sets are positively correlated. **Refuting sentence:** the
estimator's operating characteristics under these departures are close enough to its published behavior
that the authors' future-work list is a formality.

## 2. Design

Individual data from a trial of A versus C, 250 per arm; $x_1 \sim N(0, 1)$, $x_2 \sim \text{Bern}(0.4)$.
The target publishes means: $x_1 \sim N(\mu_T, 1)$, $x_2 \sim \text{Bern}(0.6)$, $\mu_T \in \{0.5, 1.2\}$
(good, poor overlap). Weibull proportional hazards (shape 1.2, control median 18 months at $x = 0$) with
log hazard $0.5x_1 + 0.4x_2 + A(-0.5 + 0.3x_1)$. Exponential censoring with hazard
$\lambda_c e^{\kappa x_1}$, $\kappa = 1.2$ (censoring and participation weights both large at high $x_1$:
positively correlated) or $-1.2$ (negatively correlated), $\lambda_c$ set so 25% or 60% of patients are
censored before 24 months. 8 cells plus two controls (no censoring; censoring independent of covariates,
60%). **500 replicates per cell.**

Estimand: target RMST to 24 months, A minus C, by numerical integration. Methods: participation-weighted
Kaplan-Meier (no censoring model); TADA, the Hajek inverse-probability-of-censoring mean of
$\min(T, 24)$ with weights $w_{\text{part}}/\hat G(\min(T, 24)^- \mid x)$ from a Cox censoring model on
$x_1, x_2$ within arm, with bootstrap SE (100 resamples, both weight sets re-estimated); the same estimate
with a sandwich SE treating both weight sets as fixed; and TADA with a censoring model omitting $x_1$.

## 3. Decision

**Primary:** TADA with bootstrap SE in the cell with 60% censoring, poor overlap and positive
correlation. **Holds** if coverage is 0.93 to 0.97 and the SE ratio (mean SE over empirical SD) is 0.9 to 1.1.
Otherwise it **fails by bias or degeneracy** if the bias exceeds 3 MCSE or the SE ratio is within 0.9 to 1.1,
and **fails by variance** if not. Bias, SE ratio and coverage are reported for every method and cell, with
the participation and product effective sample sizes and the weight correlation.

Controls. **Null:** with no censoring before the horizon TADA equals the participation-weighted Kaplan-Meier
(difference below $10^{-8}$). **Second null:** with censoring independent of covariates the
participation-weighted Kaplan-Meier is unbiased within 3 MCSE. **Positive:** in the primary cell the
product's ESS is below 0.8 times the participation ESS. Dropped replicates are counted.

## 4. Departures from DESIGN.md

RMST only, not the transported log hazard ratio (so no least-false parameter), and TADA's weights applied in
the complete-case IPCW form for RMST rather than time-varying weights in a Cox model; two censoring levels,
two overlap levels; proportional censoring hazard only; participation model correctly specified; no stacked
M-estimation sandwich, only the fixed-weight sandwich; no sensitivity parameter for censoring by unmeasured
prognosis; target moments exact; no reproduction of Yan et al.'s own simulation (probe P2). Correlation is
manipulated through the censoring model's dependence on $x_1$ and cannot be set independently of the
censoring weights' spread.
