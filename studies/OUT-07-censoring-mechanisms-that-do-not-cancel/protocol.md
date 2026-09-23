# Protocol: informative censoring on the two sides of an indirect comparison

**Target problem.** OUT-07. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

If censoring depends on the latent risk of the event, Kaplan-Meier estimates in each trial
are biased, by $c_S$ in the source and $c_T$ in the comparator, and the indirect contrast
carries $c_S - c_T$. Cancellation needs the two mechanisms to be equal. **Refuting
sentence:** informative censoring biases both arms of an indirect comparison in the same
direction, so the contrast is protected even where each arm is not.

## 2. Design

Latent frailty $U \sim N(0, 1)$; event hazard $\lambda_{\text{arm}}e^{0.7U}$
($\lambda_A = 0.045$, $\lambda_B = 0.05$, $\lambda_C = 0.07$ per month); censoring hazard
$\kappa e^{\alpha U}$ with $\kappa$ set for the censoring prevalence by 24 months;
administrative end at 36 months. Estimand: RMST difference at 24 months from complete data
(unanchored A minus B 0.62 months). 300 per arm. A baseline proxy $W = 0.7U + \text{noise}$ is
recorded in the source only.

| factor | levels |
|---|---|
| source dependence $\alpha_S$ | 0, 1 |
| comparator dependence $\alpha_T$ | 0, 1, 2 |
| censoring prevalence | 0.2, 0.5 |
| design | unanchored (A versus B); anchored (A versus C and B versus C) |

24 cells, **1000 replicates**.

Methods: Kaplan-Meier RMST in each arm (naive); source arms with inverse probability of
censoring weights from an exponential censoring model in $W$ (the comparator cannot be
adjusted from an at-risk table); a one-sided comparator sensitivity analysis in which
censored comparator patients' remaining lifetime has rate $\delta$ times the arm's crude
event rate ($\delta = 1$ is independent censoring).

## 3. Decision

- **Refuting sentence fails** if in unanchored cells with $\alpha_S \ne \alpha_T$ the naive
  contrast is biased beyond 3 MCSE and 0.25 months (40% of the true difference) in any cell.
- Reported: bias and coverage on and off the diagonal; the anchored comparison; the source
  IPCW bias; the proportion of analyses whose decision changes for $\delta \in [0.5, 2]$; and the
  $\delta$ that reproduces the true contrast, which shows whether a conventional sensitivity
  range covers the actual dependence.

**Control.** $\alpha_S = \alpha_T = 0$: unbiased, nominal coverage.

## 4. Departures from DESIGN.md

No covariate shift between trials, so the population-adjustment layer is absent and the
bias is censoring alone; proportional (time-constant) censoring hazards; one sensitivity
parameterization; the source's time-varying censoring predictors are represented by one
baseline proxy.
