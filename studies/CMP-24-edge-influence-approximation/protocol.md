# Protocol: cpaic's diagonal-weight edge influence against refitted references

**Target problem.** CMP-24. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). **Conflict of interest:** cpaic is written by this catalog's author.

## 1. Claim

`edge_influence()` in cpaic (commit cf27b1a, `R/diagnostics.R`) computes each edge's coefficient in the
contrast, $a = m'(X'WX)^+X'W$, with $W$ diagonal in the pairwise rows' inverse variances plus $\hat\tau^2$. This is
exact for two-arm studies at fixed weights and approximate for multi-arm studies and when $\tau$ would be
re-estimated. **Refuting sentence:** the approximation preserves the ranking even where it misstates values.

## 2. Design

Random connected networks of $K \in \{8, 16\}$ studies over A, B, C, D: all two-arm, or each study three-arm
with probability 0.3; arm sizes 50 to 300; true effects $(0, -0.2, -0.3, -0.4)$; random effects with $\tau \in
\{0, 0.1, 0.3\}$ (correlation 0.5 within multi-arm studies). Target D versus A. The diagonal influence is
reimplemented from cpaic's formula (all pairwise rows, naive variances, $\hat\tau^2$ from the correct model) and
summed over each study's rows. References from the correct model (basic contrasts with within-study
covariance, $\tau^2$ by REML on a grid, fixed at 0 when $\tau = 0$): leave-one-study-out refits with $\tau$
re-estimated, scored by variance importance $1 - \mathrm{Var}_{\text{full}}/\mathrm{Var}_{-s}$ and by the absolute change in the
estimate. 12 cells, **500 networks**.

## 3. Decision

**Not fit for ranking** if, in any cell, the mean Spearman correlation between study influence and variance
importance is below 0.9 or the most important study is misidentified in more than 10% of networks; otherwise
adequate. **Primary cells:** three-arm studies with $\tau = 0.3$. **P1 (exactness):** with two-arm studies, the
diagonal influence must equal the correct model's hat row at the same $\hat\tau$ to numerical precision.
Reported: Spearman with the estimate change, and studies with zero diagonal influence whose removal still
moves the estimate (through $\hat\tau$).

## 4. Departures from DESIGN.md

Standard network meta-analysis (each treatment its own component) rather than component networks with
disconnection; no population adjustment layer; study-level rather than edge-level deletion (a multi-arm
study's pairwise edges are linearly dependent, so deleting one edge removes no information); no Yang et al.
or flow-network decompositions; the formula is reimplemented, not called, because the package's working tree
was changing during the study.
