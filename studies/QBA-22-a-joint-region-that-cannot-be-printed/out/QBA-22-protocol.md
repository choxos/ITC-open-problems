# Protocol: which summary of a joint decision-invariant region to print

**Target problem.** QBA-22. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered.** DIA-13 computed non-additivity exactly for three mechanisms on an unanchored MAIC
(interaction up to 0.16 on the log odds ratio; joint bias beyond the largest single bias in 22 of 36
combinations). QBA-20 showed one-at-a-time envelopes missing 23% to 26% of a joint bias box, 7% of which
reversed the decision while every curve was robust. Both are statements about bias values. **Open, and
targeted here:** the reportable form of the joint region, its candidate summaries scored against decision
error, their dependence on the metric, and order dependence of sequential correction.

**Algebra, registered before the run.** With tipping surface $S(\gamma) = L(0, \gamma)$, the estimate a
null effect would give under bias $\gamma$, and $L$ increasing in the effect, the decision corrected for
$\gamma$ is "B better" iff $\hat\theta < S(\gamma)$. Every candidate verdict is therefore $\hat\theta$
against one number: the extreme of $S$ over a set (the cross, for one-at-a-time; the box, which is
minimum-norm at least 1 under $L_\infty$ in half-range units; the Euclidean ball) or a quantile of $S$ under
the elicited law (preservation fraction at least 0.95). The inradius at the origin equals the minimum-norm
violation under the same metric, so the entry's three candidates are two. The region's decision content is
printable as one threshold per declared set; the question is which set. **Refuting sentence:** a small set of
one-dimensional threshold intervals conveys the region's decision-relevant content adequately.

## 2. Design

DIA-13's model and bias vector $\gamma = (g_u, m, q)$: omitted confounder, comparator misclassification,
reliability loss $q = 1 - r$. Elicited box $g_u \in [-1, 1]$, $m \in [0, 0.2]$, $q \in [0, 0.4]$; elicited
law uniform on it with a Gaussian copula, $\mathrm{corr}(g_u, m) = \mathrm{corr}(g_u, q) = \rho \in
\{0, 0.5, -0.5\}$. World: $\gamma^*$ from the elicited law (calibrated) or from it with ranges times 1.5
(overconfident). Conditional B effect $d \in \{-0.3, 0.3\}$; two ($g_u$, $m$) or three mechanisms.
$\hat\theta \sim N(L(d, \gamma^*), 0.186^2)$, the delta-method SE at 300 per arm (P1). Truth, DIA-14's
definition: flip $= \mathrm{sign}(\hat\theta - S(\gamma^*)) \ne \mathrm{sign}(\hat\theta)$. Summaries per
analysis on a $41 \times 21 \times 21$ grid over twice the box (thresholds unchanged on a grid twice as
fine, P2): one-at-a-time distance, minimum norm under $L_\infty$ and $L_2$, and the fraction of 4000
elicited draws that keep the decision; verdicts at 1 and 0.95. 24 cells, **2000 replicates**: about 12,000
three-mechanism analyses per world, AUROC bootstrap SE about 0.01; false-reassurance MCSE at most 0.035 per
cell once 200 flips occur. Measured cost 0.10 CPU-hours.

## 3. Decision

**Primary** (three mechanisms, pooled per world): AUROC for a flip of each continuous summary, smaller meaning
at risk. **Holds** if the best joint summary beats the one-at-a-time distance by at most 0.02 in both worlds;
**fails** if by at least 0.05 in both, and that summary is the deliverable; **conditional on calibration** if
at least 0.05 only in the calibrated world, since the summary then inherits the elicitation's failure (DIA-14);
**conditional on overconfidence** if at least 0.05 only in the overconfident world, a summary that helps only
when the true bias leaves the elicited box; otherwise intermediate. **Metric falsifier:** minimum norm is a
property of the metric if its $L_2$ and $L_\infty$ AUROCs differ by at least 0.02 or the ball and box
verdicts disagree on at least 10% of analyses.

**Null control (identity):** in the calibrated world $\gamma^*$ lies in the box, so box false reassurance
must be exactly 0; the Euclidean ball is a strict subset of the box, so its false reassurance there is
reported as part of the metric result. **Second null:** with one mechanism the cross, box and ball thresholds are
identical (P1: identical). **Positive control:** with three mechanisms the cross is robust while the box is
fragile in at least 2% of analyses; P1 shows the reachable case, box upper threshold 0.279 against the
cross's 0.188. Reported: false reassurance and false fragility of every verdict rule by cell, and order
dependence computed exactly on 45 box points and 4 estimates. Sequential correction is operationalized as
practice applies single-bias tools: each step solves $L(d, \gamma_j e_j) = $ current value for $d$ as if
mechanism $j$ were the only one, reports the truth at that $d$, and passes it to the next step; six orders
(P3: spread up to 0.179, sequential minus joint up to 0.306). Subtracting single-mechanism biases on the log
odds scale would commute; this procedure does not.

## 4. Departures from DESIGN.md

$\hat\theta$ from a normal approximation with one SE, not from MAIC fits; log odds ratio only, no risk ratio
or RMST; DIA-13's three mechanisms, so no effect-modifier or selection mechanism; no composition with the
multibias machinery; no Shapley allocation; order dependence computed, not simulated; two metrics, both in
half-range units. **Set after probes:** the conditional B effect moved from $-0.3, -0.1$ to $-0.3, 0.3$ after the
first smoke, because with both effects negative the binding direction was the $g_u$ axis alone and the
off-axis corner $(1, 0, 0.4)$, the case the entry is about, was never binding; the positive control and the
overconfident-only branch were added after the pipeline test.
