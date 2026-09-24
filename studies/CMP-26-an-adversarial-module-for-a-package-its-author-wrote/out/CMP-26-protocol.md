# Protocol: cpaic's two-stage component bridge under the departures it assumes away

**Target problem.** CMP-26. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).
**Conflict of interest:** cpaic is written by this catalog's author. The generator, seeds and raw
per-replicate outputs are committed so the result can be checked without trusting the author; independent
replication is not claimed. Package: cpaic at commit cf27b1a (the commit CMP-24 used), not installed:
`.cpaic_stc_one_study()` and its validity gate are sourced from copies extracted with `git show`
(`R/cpaic-cf27b1a/`), and the bridge is `netmeta::discomb()` with the arguments `cnma_bridge()` passes. At
cf27b1a `cmlnmr()` has marginal standardization (`R/marginal_effects.R`; commit subject "Add marginal
cML-NMR standardization"), so the catalog's "lacks marginal standardization" describes 9d150e9. That path
is not evaluated here.

## 1. Claim

A simulation from the family the estimator assumes checks the code, not the model. A cross-gap contrast
from cSTC rests on additivity, on component-by-covariate modification being constant across subnetworks,
and on a correctly declared target mean. **Refuting sentence:** the estimator's behavior under each
departure is already implied by known mechanisms, the linear pass-through of each edge's bias into the
contrast (CMP-03 for synergy, CMP-11 for pooled edges), so a component-specific module reproduces known
results.

## 2. Design

Components A to D, inactive P; five two-arm trials with individual data, 200 per arm, binary outcome.
Subnetwork 1: P vs A, P vs B, A vs A+B. Subnetwork 2: C vs C+D, D vs A+D. No regimen is shared; A is.
$\operatorname{logit} p = -0.5 + 0.4x + \sum_{c \in \text{arm}} b_c + g_A x\,[A \in \text{arm}] + \text{SYN}\,[C, D \in \text{arm}]$,
$b = (-0.4, -0.3, -0.2, -0.5)$, $x \sim N(m_t, 1)$, $m_t = (0, 0.3, -0.3, 0.6, 1.2)$, $g_A = 0.4$ in subnetwork 1
and $0.4 + \text{DRIFT}$ in 2. **Estimand:** A+D vs P, the conditional log odds ratio at the true target mean
$x_T$, $b_A + b_D + 0.4\,x_T$ (the quantity cSTC targets; the target follows subnetwork 1). The rank test
(CMP-24's projection) confirms it estimable and C not. Cells, one departure at a time, severity matched as
the shift induced in the corrupted edge at the target: null ($x_T = 1$); synergy C×D $-0.15$, $-0.3$; drift
$-0.15$, $-0.3$; target mean misdeclared by $-0.375$, $-0.75$ (shift $0.4\Delta$); poor overlap ($x_T = 2.5$);
no modification ($g_A = 0$); positive control (strong synergy, strong drift, $x_T = 2.5$). Methods: **cSTC**,
cpaic's per-trial `glm(y ~ arm + xc + arm:xc)` with $x_c = x -$ declared $x_T$, bridged by `discomb` (common
effect); **unadjusted**, each trial's own log odds ratio through the same bridge. **Prediction** per
replicate: $\sum_j h_j(\text{plim}_j - \text{target}_j)$, $h$ the fixed-effect GLS row of the estimand at the
replicate's standard errors, edge limits by quadrature. 10 cells, **1000 replicates** (probe SD 0.33: bias
MCSE 0.010, coverage MCSE 0.007). About 0.5 CPU hours (probes).

## 3. Decision

**Primary:** the refuting sentence **holds** if, for cSTC in every cell, $|\overline{\text{error} - \text{prediction}}|
\le \max(3\,\text{MCSE}, 0.02)$; otherwise it **fails**, naming the cells. **Null control:** cSTC coverage 0.925
to 0.975 in the null cell. **Positive control:** cSTC coverage below 0.80 in the positive cell; otherwise the
module has not built an adversarial scenario. **Disclosure:** a strong-level departure with $|\text{bias}| \ge 0.1$
or coverage below 0.90 is named for the package documentation; pass-through (bias over shift) is reported
per departure. **Comparator that can win:** the unadjusted bridge; any cell where its RMSE is lower by more
than 2 MCSE is reported as one where adjustment buys nothing. Failed fits (cpaic's validity gate, `discomb`
errors) are counted per cell and method. A near-miss is reported as a near-miss.

## 4. Departures from DESIGN.md

The estimator is cpaic's frequentist two-stage cSTC bridge, not cML-NMR: cpaic is not installed and the
Stan path needs its models compiled from the pinned sources. Non-component ML-NMR cannot express a cross-gap
contrast in a disconnected network, so the comparator is the unadjusted bridge. Every trial carries
individual data, because at this commit cSTC refuses aggregate-only edges alongside adjusted ones unless
the experimental gate is opened (CMP-11 measured that bias). The estimand is conditional, so a target-law
departure reduces to a misdeclared mean. Severity is matched by the shift in the corrupted edge, not by P1's
change in the estimand. One network, one covariate, common-effect bridge, one sample size; no MAIC arm,
bridge-strength factor, reproduction of the Petropoulou et al. CNMA benchmark (not on disk), full-IPD
case study or independent replication.
