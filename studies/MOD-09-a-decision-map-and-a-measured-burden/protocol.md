# Protocol: a decision map between MAIC, STC and ML-NMR, and ML-NMR's measured fitting burden

**Target problem.** MOD-09. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

In a star network, ML-NMR can carry the aggregate A vs C contrasts to a target population under the shared
effect-modifier assumption; MAIC and STC adjust only the individual-data contrast and carry A vs C
unadjusted. Their extra bias is the transport gap, the A vs C contrast in the aggregate trials' populations
minus that in the target, computable before fitting. The entry's premise is that ML-NMR's advantage is
offset by a practical burden. **Refuting sentence:** MAIC matches ML-NMR on mean squared error wherever
modification is shared and ML-NMR's fitting burden is small, so the adoption gap is rational rather than a
barrier. Only the fitting part of the burden is measured.

## 2. Design

Star network, binary outcome, 200 per arm: AB with individual data; AC1 and AC2 with events per arm and the
means and SDs of $x_1, x_2$. Covariates bivariate normal, SD 1, correlation 0 in AB and 0.6 elsewhere.
$\operatorname{logit}p = -0.5 + 0.5x_1 + 0.3x_2 + [B](-0.6 + 0.4x_1 + 0.2x_2) + [C](-0.4 + \gamma_C'x)$. Target: an
external population, means $(0, 0)$, correlation 0.6. **Estimand:** marginal log odds ratio B vs C in the
target (truth by Monte Carlo over $2 \times 10^5$ draws, seed error $10^{-4}$: $-0.155$ with shared modification,
$-0.095$ violated). Factors, $2^4$: **transport gap**, AC1 and AC2 means 0.2 and $-0.2$, or 1.0 and 0.6, on both
covariates (analytic gap MAIC and STC inherit: 0.001 or $-0.283$ shared, 0.001 or $-0.159$ violated);
**overlap**, AB means 0.3 or 1.2 on both covariates; **target information**,
declared correlation 0.6 (true) or 0 (borrowed from the individual data, multinma's default); **shared
modification**, $\gamma_C = (0.4, 0.2)$ as for B, or half of it (violated: MAIC and STC keep half the gap and
ML-NMR, assuming it shared, over-corrects by the other half, so either can win). A null cell (no modification, every population at the
target) makes 17. Methods: **MAIC**, entropy weights to the target means, sandwich SE; **STC**, G-computation
over the declared target law, delta-method SE; each minus the pooled A vs C log odds ratio; **ML-NMR**, its
integrated likelihood with shared modification maximized (256 Sobol points per aggregate trial, 1024 for the
target, AB's baseline), delta-method SE. Section 2's aggregation term is computed per cell but constant
($-0.045$ shared, $-0.105$ violated), because link and target law are fixed. **Burden:** multinma 0.9.1 on the
first 10 replicates of each cell (same datasets) under a fixed protocol: 2 chains of 2000, 64 integration
points, integration check on, B and C in one class with common interactions, one refit at adapt_delta 0.99 on
any divergence; recorded per fit: CPU, divergences, refit, maximum Rhat, integration-check warnings, and the
posterior mean against the maximum-likelihood estimate. Common random numbers across methods. **1000
replicates** (MCSE of an RMSE near 0.25 about 0.006). CPU: 1.5 hours for the grid, about 8.6 hours for
multinma (probes; extrapolated linearly from one 2 by 200 iteration fit on a shared machine).

## 3. Decision

Per cell, ML-NMR against MAIC by the paired difference in squared error: a winner if the mean difference
exceeds 2 MCSE, otherwise a tie (STC against ML-NMR reported the same way). **Primary**, over the 8
shared-modification cells: **a map exists** if the winner changes across levels of gap, overlap or target
information; **no boundary, ML-NMR better** if ML-NMR wins all 8; **no boundary, MAIC competitive** if it wins
none. **Falsifier:** if ML-NMR loses at least half of its wins when shared modification is violated, the map
depends on an assumption the analyst cannot check and no pre-fitting criterion is registered. **Null
control:** every method $|\text{bias}| \le 3\,\text{MCSE} + 0.01$ and coverage 0.925 to 0.975 (the 0.01 is margin; the
truth's own Monte Carlo error is $10^{-4}$). **Positive
control:** high gap, poor overlap, joint law, shared modification: ML-NMR must win against MAIC; otherwise
its stated advantage is unreachable here. Burden is reported separately and never pooled with error. No
method is declared a default in any branch. A near-miss is reported as one.

## 4. Departures from DESIGN.md

One star network: in a two-trial pair with the target at the aggregate trial ML-NMR reduces to STC, and a
connected network is not run. Individual data in one trial; one outcome, one sample size; curvature and
within-study spread not varied. ML-NMR's operating characteristics come from its maximized likelihood, not
multinma's posterior; agreement is checked on the burden subsample. Burden is fitting only, on 10 fits per
cell: specification, diagnosis, communication and the analyst's learning curve are not measured. No case
study; no DIA-08 robustness arm (DIA-08 ran no ML-NMR). Probe finding: multinma 0.9.1 under rstan
2.39.0.9000 fails with a single chain (`nint_vec` is declared `array[nchains]` and a length-one vector
arrives as a scalar), so every multinma fit uses at least 2 chains.
