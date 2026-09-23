# Protocol: a population difference arriving as inconsistency

**Target problem.** HET-04. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Under linear modification the node-split statistic is
$w = \iota + \beta(\bar x_{\text{direct}} - \bar x_{\text{indirect}})$: true loop inconsistency plus a
population mismatch. With $\iota = 0$ the unadjusted split flags the mismatch; with
$\iota = -\beta\Delta\bar x$ it misses a real conflict. **Refuting sentence:** the covariate
differences between the study sets supplying the two paths are small, so the unadjusted
diagnostic is approximately valid.

## 2. Design

Triangle A, B, C, $M \in \{2, 4\}$ studies per comparison, study SE 0.1. AB and AC studies have
covariate means $N(0, 0.2^2)$; BC studies $N(\text{gap}, 0.2^2)$, gap $\in \{0, 0.5, 1\}$. C's effect
against A is modified by $\beta x$, $\beta \in \{0, 0.2, 0.4\}$, with consistent interactions;
the BC studies carry loop inconsistency $\iota \in \{-0.2, 0, 0.2\}$. 54 cells, **2000
replicates**.

Unadjusted split: direct BC pooled estimate minus AC minus AB, each at its own studies'
populations. Adjusted split: meta-regression on the study covariate means with a
BC-specific inconsistency parameter. Both at $p < 0.05$.

## 3. Decision

- **Refuting sentence fails** if with $\iota = 0$ and populations differing ($\beta > 0$,
  gap $> 0$) the unadjusted split flags more than 0.20 of analyses in any cell.
- Masking: flag rates where $\iota = -\beta\cdot\text{gap}$.
- Size and power of the adjusted split, including its loss of precision as the gap grows.

**Control.** Gap 0 or $\beta = 0$: both splits at their null rate when $\iota = 0$.

## 4. Departures from DESIGN.md

Continuous study estimates, so the conditional and marginal inconsistency factors coincide
and the marginalization to a named target is not needed; one loop; no Bayesian node split.
