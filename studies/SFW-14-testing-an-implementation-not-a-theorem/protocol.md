# Protocol: testing drMAIC against the properties it claims

**Target problem.** SFW-14. ADEMP reporting. Committed before the registered run. Package: drMAIC
0.1.0 from CRAN. Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim and what code inspection showed

A doubly robust augmented weighting estimator is consistent when either the weighting or the outcome
model is correct. A simulation tests the implementation, not the theorem. **Refuting sentence:** the
implementation is correct and its finite-sample behavior matches the augmented-weighting literature.

Reading `dr_maic()` before the run (quoted in the manuscript) showed three things to test:

1. The outcome-model term is `sum(w_norm * m_hat)`, the weighted mean of predictions over the
   individual data, not the prediction averaged over the target population. The augmented estimate is
   then $\sum w\hat m + \sum w(Y - \hat m) = \sum wY$, the MAIC estimate, for binary and continuous
   outcomes.
2. The variance is `sum((w_norm * (Y - theta))^2) / n`: the sandwich variance of a weighted mean with
   normalized weights, divided by $n$ a second time.
3. That probability-scale variance is added to the comparator's squared SE and used as the SE of a log
   odds ratio.

`bootstrap_ci()` recomputes the weights on means only and refits the outcome model with the default
formula, and holds the comparator estimate fixed.

## 2. Design

Unanchored: individual data on 300 patients of A; the target publishes $x_1$'s mean and SD, the
proportion with $x_2 = 1$, and B's response proportion and SE (300 patients). $x_1 \sim N(0, 1)$,
$x_2 \sim \text{Bern}(0.4)$ in the source; $x_1 \sim N(m, 0.8^2)$, $x_2 \sim \text{Bern}(0.6)$ in the target,
$m \in \{0.5, 1\}$. $\operatorname{logit}P(Y = 1) = -0.5 + 0.6x_1 + 0.5x_2 + 0.4x_1^2$ for A; B adds $-0.4$.
Estimand: marginal log odds ratio, A versus B (the package's orientation). Weighting correct (means and
$x_1$'s second moment) or wrong (means only); outcome model correct (with $x_1^2$) or wrong (linear). 8
cells, **600 replicates**. Comparator: a correctly augmented estimator (outcome model averaged over the
published target law plus the weighted residual mean) with a 50-resample bootstrap SE. The package's
percentile bootstrap (200 resamples) in the two cells with a correct outcome model at $m = 0.5$, 150
replicates each.

## 3. Decision

**Refuting sentence fails** if any of: the package's DR estimate equals its MAIC estimate in every
replicate (to $10^{-10}$); in the cells with wrong weights and a correct outcome model, the package's DR
is biased beyond 3 MCSE while the correctly augmented estimator is not; the package's analytic interval
covers below 0.90 in some cell.

## 4. Departures from DESIGN.md

Binary outcome only (the time-to-event path uses a weighted median survival time labeled a hazard ratio,
reported from the code, not simulated); no G-MAIC comparator; no failed-fit tally beyond errors dropped;
600 rather than more replicates.
