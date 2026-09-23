# Protocol: the number of studies per class at which heterogeneity structures become distinguishable

**Target problem.** HET-03. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

With few studies per class a class-specific between-study variance is weakly identified, so model
comparison cannot distinguish shared from separate variance structures at realistic network sizes.
**Refuting sentence:** at the network sizes ML-NMR is applied to, structures are distinguishable often enough
that a data-driven choice is defensible.

## 2. Design

Two classes of $m \in \{2, 3, 5, 8, 12, 20, 40\}$ studies each; study estimates with within-study SE uniform on
0.1 to 0.25 and between-study SDs 0.1 and $0.1\sqrt{R}$, variance ratio $R \in \{1, 2, 5\}$. Shared and separate
between-study variances fitted by REML; selection by AIC, BIC and a 5% likelihood-ratio test (reference $\chi^2_1$).
21 cells, **2000 replicates**.

## 3. Decision

**Primary:** balanced selection accuracy, the mean of the rate of choosing separate at $R = 5$ and of choosing
shared at $R = 1$, by $m$. The deliverable is the smallest $m$ at which it reaches 0.8 for each criterion; if none
does by 40 studies per class, the structure cannot be chosen from the data at realistic sizes.

## 4. Departures from DESIGN.md

Frequentist REML on contrast-level data with two classes, no priors (so prior-driven posteriors are
represented by REML's instability), no ML-NMR fit, no class-specific treatment SD (`class_sd`) arm.
