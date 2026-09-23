# Protocol: inference on the covariate value at which the better treatment changes

**Target problem.** DEC-28. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

The boundary $x^\star = -\delta/\beta$ between two treatments is a ratio whose denominator is an interaction,
so it can be poorly determined when every contrast is precise; its exact (Fieller) confidence set may be
unbounded; and interaction information from between-trial variation can bias it without widening any
interval. **Refuting sentence:** at achievable interaction precision the boundary is well determined, so
reporting it as a point is harmless.

## 2. Design

Individual effect of A over B $\eta(x) = \delta + \beta x$, $\beta \in \{0.3, 0.15, 0.05\}$ (outcome SD 1, covariate SD
1), $x^\star \in \{0.5, 1.5\}$, $\delta = -\beta x^\star$. Evidence: one individual-data trial of 400 patients
($x \sim N(0, 1)$, $y = 0.3x + A\eta(x) + e$) and five aggregate trials at covariate means $-1, -0.5, 0.5, 1, 1.5$
reporting their effect with SE 0.1. An ecological term $b(m_k - \bar m)$, $b \in \{0, 0.1\}$, shifts aggregate
trial $k$'s effect with its covariate mean. Estimators of $(\delta, \beta)$: the individual trial alone
(within) and generalized least squares on the individual trial's estimates and the five aggregate effects
(combined, as a shared-interaction model does). 12 cells, **2000 replicates**.

Methods: plug-in $\hat x^\star$; delta-method 95% interval; Fieller 95% set (bounded, the complement of an
interval, or the whole line); pointwise optimality map $P(\text{A better at } x) = \Phi(\hat\eta(x)/\text{se}(x))$.
**Derived before the run:** the Fieller set is the set of $x$ where that map lies in $(0.025, 0.975)$, and
treating by the map at 0.5 is the plug-in rule, so the map and the point cut-point have identical regret; the
map changes what is reported, not the decision. Regret is therefore reported once, for the plug-in rule, in
a target $x \sim N(0.5, 1)$, as a share of the value of individualized treatment.

## 3. Decision

**Refuting sentence holds** if delta-method coverage is 0.93 to 0.97 in every cell for both estimators and the
Fieller set is unbounded in under 5% of replicates at $\beta = 0.15$ for both; otherwise it fails. Reported:
Fieller coverage overall, the share bounded, whole-line and exclusive, coverage among bounded sets, median
bounded width, the between-trial share of the interaction's precision, false certainty of the map (share of
profiles at $x^\star \pm 0.5, \pm 1$ where it gives at least 0.975 to the wrong treatment) and Brier score.

Controls. **Null:** $b = 0$, $\beta = 0.3$: delta and Fieller coverage 0.93 to 0.97 and false certainty at most
0.035, for both estimators. **Positive:** $\beta = 0.05$, within: Fieller unbounded in at least half of
replicates. **Falsifier for the ecological explanation:** the combined estimator must cover nominally at
$b = 0$; if it undercovers there too, the shortfall is not ecological.

## 4. Departures from DESIGN.md

Frequentist and closed-form, no ML-NMR or Stan; two treatments and one modifier (a point boundary); no
modifier selection; one overlap level; no m-out-of-n bootstrap. The ecological bias is a declared linear
term, not generated from a study-level confounder.
