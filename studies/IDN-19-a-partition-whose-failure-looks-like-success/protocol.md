# Protocol: sensitivity of a network contrast to the shared effect-modifier partition

**Target problem.** IDN-19. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Widening a shared effect-modifier class weakens the identifying assumption and improves estimability and
fit at once, so an indefensible partition looks like success. **Refuting sentence:** target contrasts are
insensitive to the partition across defensible alternatives.

## 2. Design

Reference A; B, C, D with effect $d_k + g_kx$. Evidence: an individual-data trial of A vs B (400 patients) giving
$(d_B, g_B)$; aggregate trials of A vs C at covariate means $-0.5$ and $0.5$; one aggregate trial of A vs D at mean 0;
each aggregate effect with variance 0.01. Truth $g_B = 0.3$, $g_C = 0.3 + s$, $g_D = 0.3 + h$, $s \in \{0, 0.3\}$,
$h \in \{0, 0.15, 0.3\}$. Target covariate mean 1; estimand D versus A there. Admissible partitions that identify
it: {BCD}, {BD}{C}, {B}{CD}. Each fitted by generalized least squares on the sufficient statistics (drawn
from their exact normal law); the residual chi-square tests fit where it has degrees of freedom. 6 cells,
**4000 replicates**.

## 3. Decision

**Primary:** the widest partition {BCD} at $h = 0.3$, $s = 0$. **Confirmed** if its bias is at least 0.1 in absolute
value, its coverage below 0.90, and its fit test rejects in under 20% of analyses. Reported: bias, SE, coverage
and fit-test rejection per partition and cell; the induced range over the three partitions (of estimates,
and of their 95% intervals), whether it contains the truth, and its width.

## 4. Departures from DESIGN.md

Continuous outcome, linear modification, one small hand-built network; three admissible partitions;
sufficient statistics drawn directly; no overlap factor or ML-NMR fit.
