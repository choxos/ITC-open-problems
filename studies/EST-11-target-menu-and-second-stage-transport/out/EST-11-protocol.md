# Protocol: native versus declared targets across a target menu

**Target problem.** EST-11. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

$\hat\Delta_E - \Delta(F_D) = \{\hat\Delta_E - \Delta(F_E)\} + \{\Delta(F_E) - \Delta(F_D)\}$: scoring a method against its own
native target $F_E$ measures only the first term. **Refuting sentence:** the two terms move together across a
realistic target menu, so scoring against native estimands gives the same method ranking as scoring against
a declared decision estimand.

## 2. Design

Individual data on A versus C in S ($x \sim N(0, 1)$); published B versus C in $T_B$ ($x \sim N(0.6, 1)$); 300 per
arm; binary outcome $\operatorname{logit}p = -0.5 + 0.5x + a_A(-0.5 + 0.3x) + a_B(-0.7 + g_Bx)$ with $g_B = 0.3$ (B
shares A's modification) or $0.6$. Declared target $F_D$: $x \sim N(m_D, 1)$, $m_D \in \{0, 0.6, 1.2\}$; estimand the
marginal log odds ratio B versus A there. Methods: Bucher (native target mixes S and $T_B$), MAIC to $T_B$ and
STC to $T_B$ (native $T_B$), and two-stage STC carrying both contrasts to $F_D$ under the assumption that B's
modification equals A's (native $F_D$; misspecified when $g_B = 0.6$). The mismatch term is exact by
quadrature; the estimation term from **1000 replicates** per cell; 6 cells.

## 3. Decision

**Primary:** per cell, whether the method with the lowest RMSE against its native target differs from the
method with the lowest RMSE against the declared target. **Confirmed** if that happens in at least a quarter
of cells; **refuted** otherwise. Reported: both RMSEs, the mismatch term and the Spearman correlation of the
two metrics' RMSEs per cell.

## 4. Departures from DESIGN.md

Three declared targets, one covariate, one sample size, known target moments (no moment uncertainty), four
methods; no ML-NMR or ML-UMR arm; a fractional design rather than the full menu.
