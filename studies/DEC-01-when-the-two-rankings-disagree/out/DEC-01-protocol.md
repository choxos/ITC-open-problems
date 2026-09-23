# Protocol: do estimation and decision rankings of methods agree?

**Target problem.** DEC-01. ADEMP reporting. Committed before any decision scoring.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

The wrong-decision probability $P\{\operatorname{sign}(\hat\Delta - \tau) \ne \operatorname{sign}(\Delta - \tau)\}$
depends on the estimator's distribution relative to the threshold $\tau$, not on its
distance from the truth. A method whose bias points away from the threshold decides
correctly more often than an unbiased one with the same variance, so RMSE and decision
rankings can disagree, and decision performance depends on where the truth sits relative
to the threshold. **Refuting sentence:** estimator and decision rankings agree in
practice, so adding a decision layer changes no conclusion.

## 2. Data

No new simulation. The 108,000 stored replicates of COV-03 (108 anchored and unanchored
binary-outcome scenarios; unadjusted, MAIC on means, on means and variances, on the
prognostic index variance, and G-computation; estimate and SE per replicate) are
re-scored. COV-03's estimation results (bias, RMSE, coverage) were known when this
protocol was written; no decision measure had been computed.

## 3. Decision model

Threshold $\tau = \Delta + d$, $d \in \{-0.3, -0.1, 0.1, 0.3\}$ on the log odds ratio scale:
near ($\lvert d\rvert = 0.1$) and far (0.3), on both sides. Adopt B over A when
$P(\Delta < \tau) \ge c/(1 + c)$ under $N(\hat\Delta, \widehat{\text{SE}}^2)$, with loss ratio
$c \in \{1, 2, 5\}$ (cost of a wrong adoption relative to a wrong rejection); $c = 1$ is the
plain rule $\hat\Delta < \tau$. Expected loss: $c$ per wrong adoption, 1 per wrong rejection.
Regret $\lvert d\rvert$ is constant within a stratum and is not multiplied in. Expected
value of information is excluded (DESIGN.md).

## 4. Outcomes and decision

Within each cell, threshold and loss ratio: the Spearman correlation between the five
methods' RMSE and expected loss, and whether the RMSE-best method is also loss-best.

- **Primary.** Near-threshold strata in poor-overlap cells (target shift 0.6, source
  index variance half the target's; 12 cells, 2 thresholds), symmetric loss. **Confirmed**
  if the mean correlation is at most 0.7 with the upper bootstrap limit below 0.9;
  **refuted** if at least 0.9.
- Consequence 1: wrong-decision probability of biased methods ($\lvert\text{bias}\rvert > 0.05$)
  when the bias points away from against toward the threshold.
- All strata are reported separately, never pooled across threshold distance.

**Null control.** Far from the threshold with identical populations, every method
decides correctly in nearly every replicate.

## 5. Departures from DESIGN.md

Re-scores COV-03 rather than the published Phillippo or Remiro-Azócar benchmarks; the
decision is on the relative effect, not a net-benefit model with costs and utilities;
no ML-NMR; 1000 rather than 4000 replicates.
