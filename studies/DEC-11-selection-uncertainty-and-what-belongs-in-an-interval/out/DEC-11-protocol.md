# Protocol: coverage of an STC interval after selecting effect modifiers on the same data

**Target problem.** DEC-11 (also bears on COV-01). ADEMP reporting. Committed before
the registered run. Design: [`DESIGN.md`](DESIGN.md). Probes:
[`results/probes.md`](results/probes.md).

## 1. Claim

An interval computed after selecting the model on the analyzed data is too narrow
unless the selection is part of the variance. **Refuting sentence:** selection at these
sample sizes is so unstable that the selected model is nearly independent of the data,
so the naive interval is approximately right. DESIGN.md predicts the shortfall is
largest at intermediate $n$.

## 2. Design

Source trial A versus C, six independent normal candidate covariates, binary outcome
$\operatorname{logit} p = -0.5 + 0.3\sum_j x_j + A(-0.5 + 0.3\sum_{m \in M} x_m)$ with $M$ the
first 1 or 3 covariates. Target covariate means 0.4. Estimand: target marginal log odds
ratio (Monte Carlo over $10^6$ draws). Estimator: G-computation from a logistic model
with all six main effects and the interactions a rule selects.

Rules: all six interactions; the true set (oracle); none; significance (interactions
with $p < 0.2$ in the full-interaction model); lasso on the interactions with main
effects unpenalized, $\lambda_{1se}$ by 5-fold cross-validation. Intervals: delta method
treating the selected model as fixed; for significance selection also the
whole-procedure bootstrap (60 resamples, selection rerun in each).

Factors: $n \in \{100, 300, 1000\}$ per arm, 1 or 3 true modifiers: 6 cells,
**400 replicates** (coverage MCSE 0.011 at nominal); cost about 5 core-hours.

## 3. Decision

- **Refuting sentence fails** if naive coverage after significance selection is below
  0.93 with its 95% Monte Carlo interval in at least one cell.
- Coverage of every rule by $n$ is reported, with the whole-procedure bootstrap.
- Registered prediction: the shortfall is not monotone in $n$.

## 4. Departures from DESIGN.md

STC (G-computation) only; MAIC-based selection, overlap levels, 13 candidates and
target-summary uncertainty are not run. 400 replicates and 60 bootstrap resamples.
