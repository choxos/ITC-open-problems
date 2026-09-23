# Protocol: does the generator's effect-modification structure decide the method ranking?

**Target problem.** DIA-08. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Simulations that generate shared linear effect modification make the restrictions of
linear outcome models true, so they rank methods by efficiency. DESIGN.md predicts that
departures (threshold, modifier-by-modifier interaction, curvature) reverse the ranking
toward the methods whose restrictions the departure leaves intact. **Refuting
sentence:** the ordering under shared linear modification survives every departure, so
existing simulations rank methods correctly. The probe (150 replicates) shows the linear
STC first in RMSE under almost every departure, so the refuting sentence may hold.

## 2. Design

Anchored pairwise comparison. AC trial with individual data, 300 per arm, $x_1, x_2$
mean 0, SD 1. BC trial in the target, 300 per arm, covariate means $(m, m)$, SD 1,
reporting means, SDs and arm event counts. Binary outcome,
$\operatorname{logit}p = -0.5 + 0.5(x_1 + x_2) + \text{treatment}$; B's effect $-0.8$; A's
conditional effect by departure:

| departure | $\tau_A(x)$ |
|---|---|
| linear (reference) | $-0.6 + 0.4x_1 + 0.4x_2$ |
| threshold | $-0.6 + 0.8\,\mathbb 1(x_1 > 0.5) + 0.4x_2$ |
| interaction | $-0.6 + 0.4x_1 + 0.4x_2 + 0.4x_1x_2$ |
| quadratic | $-0.6 + 0.4x_1 + 0.4x_2 + 0.3x_1^2$ |
| none (control) | $-0.6$ |

Reported moments are identical across departures. Target mean $m \in \{0.3, 0.8, 1.2\}$;
covariate law normal, plus linear modification with standardized Gamma(2) covariates
(same moments) as the covariate-law falsifier. 16 cells, **2000 replicates** (0.7
core-hours). Estimand: marginal log OR, B versus A, in the target (Monte Carlo over
$2\times10^6$ draws).

Methods: unadjusted (Bucher); MAIC on means; MAIC on means and second moments; STC with
linear interactions and STC with quadratic and product interactions, both marginalized
over normals with the reported moments.

## 3. Decision

RMSE ordering of the five methods per cell; Spearman correlation between the ordering
under linear modification and under each departure at the same target mean, with a
paired bootstrap SE.

- **Refuted** (orderings survive) if $\rho \ge 0.9$ for every departure at every target
  mean.
- **Confirmed** if $\rho \le 0.5$ for some departure at $m = 1.2$ (poor overlap).
- Otherwise **partial**: some reordering without reversal.
- Bias, coverage and RMSE are reported for every method and cell.

**Controls.** No modification: every adjustment method unbiased within 3 MCSE except
for the anchored non-collapsibility bias of the unadjusted and mean-only analyses.
Covariate-law falsifier: skewed covariates under linear modification should not reorder
more than any modification departure does.

## 4. Departures from DESIGN.md

No ML-NMR or ML-UMR arm, so the treatment-specific, subnetwork and within/between
departures (which need a network) are not run; CMP-13 covered the last. One scale (log
OR); single pair; means-only and means-and-SDs MAIC stand in for the reported-moment
factor.
