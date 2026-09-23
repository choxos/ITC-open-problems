# Protocol: bootstrap intervals over a bias grid when resamples fail

**Target problem.** QBA-23. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A bootstrap over a sensitivity grid re-solves the weights in every resample. Near the edge of the source's
support the weights fail in some resamples, and dropping them makes the interval conditional on the weighting
having worked, at the grid points where the analysis is least reliable. **Refuting sentence:** failure rates
are low enough at the settings a sensitivity analysis explores that conditioning on success is immaterial.

## 2. Design

Unanchored: individual data on $n \in \{100, 300\}$ patients of A, $x \sim N(0, 1)$, $y = x + e$. A sensitivity
analysis sweeps the assumed target mean of $x$ over 1, 1.5, 2 and 2.5; the estimand at each value is A's mean
outcome there, equal to the value. MAIC to that mean (log-sum-exp minimization; infeasible outside the sample
range, failed if balance is not reached to $10^{-4}$); 200 bootstrap resamples; percentile interval from the
successful resamples. 2 cells, **500 replicates**.

## 3. Decision

**Refuting sentence fails** if, at grid points where more than 10% of resamples fail, coverage given success is
below 0.85 or exceeds unconditional coverage (counting a failed original fit as no interval) by more than 0.05.
Failure share, effective sample size and width along the grid are reported.

## 4. Departures from DESIGN.md

One covariate and a continuous outcome; the cost and surrogate-model half of DESIGN.md (warm starts,
approximations) is not studied; no identified-set output.
