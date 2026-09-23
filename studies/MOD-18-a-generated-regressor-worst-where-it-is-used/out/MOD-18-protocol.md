# Protocol: an estimated risk score used as a regressor

**Target problem.** MOD-18. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Risk-modeling meta-regression fits a prognostic score in one cohort and uses it as a
regressor for treatment-effect heterogeneity in the trials, treating the score as data. The
omitted variance should be largest at the tails of the risk distribution, where
recommendations are made. **Refuting sentence:** the prognostic cohort is large enough that
the score's estimation error is negligible and the plug-in interval is adequate.

**Correction.** DESIGN.md consequence 2 says shrinking the score attenuates the interaction
and understates its interval. Uniform shrinkage multiplies the slopes by a constant, a linear
rescaling of the score that the trial intercepts and the treatment-by-score interaction
absorb exactly, so effects evaluated at score percentiles are unchanged by it. It is not run.

## 2. Design

Eight covariates $X \sim N(0, I)$; true risk logit $r = -1 + X\gamma$,
$\gamma = (0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0, 0)$. Prognostic cohort of $N_P$ untreated patients;
logistic fit gives $\hat r = X\hat\gamma$. Six trials of 400 per arm with trial calibration
shifts $N(0, \text{drift}^2)$; $\operatorname{logit}p = r + \text{cal}_k + A\,\theta(r)$,
$\theta(r) = -0.4 - 0.25(r + 1)$. Analysis: pooled logistic regression with trial intercepts,
$\hat r$, treatment and treatment by $\hat r$. Estimand: $\theta$ at the 10th, 50th and 90th
percentiles of true risk; estimate at the same percentiles of $\hat r$.

Factors: $N_P \in \{300, 1000, 5000\}$, drift 0 or 0.5: 6 cells, **500 replicates** (1.2
core-hours). Plug-in SE from the trial model; propagated SE adds the variance across 20
bootstrap refits of the prognostic model.

## 3. Decision

- **Refuting sentence holds** if the widening ratio (propagated over plug-in SE) is at most
  1.05 at every percentile for cohorts of at least 1000 and plug-in coverage is at least 0.93
  everywhere; otherwise it fails.
- Consequence 1 is assessed by comparing the widening ratio at the tails with the median.

## 4. Departures from DESIGN.md

A pairwise comparison across six trials rather than a network; frequentist fits with a
bootstrap rather than a Bayesian joint or cut model; no score shrinkage (section 1); 500
replicates.
