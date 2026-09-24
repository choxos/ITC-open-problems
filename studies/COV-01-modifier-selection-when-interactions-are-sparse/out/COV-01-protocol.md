# Protocol: can screening find an effect modifier where omitting it matters?

**Target problem.** COV-01. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered.** DEC-11 (STC, six candidates, binary outcome): after selecting interactions at
$p < 0.2$ the naive interval covered 0.887 to 0.927 and a whole-procedure bootstrap 0.938 to 0.968; lasso at
$\lambda_{1se}$ dropped real modifiers (coverage down to 0.33); all-candidate STC covered 0.93 to 0.96. COV-04
(continuous STC, eight candidates): shrinkage and selection priors undercovered (empirical-Bayes ridge 0.794
to 0.948, median-probability model 0.785 to 0.931). Neither varied modifier strength, so DESIGN.md's primary
outcome, the detection-materiality gap, is unmeasured; neither ran MAIC, 13 candidates or the effective
sample size cost of balancing on everything. This protocol targets only that remainder.

**Claim:** at appraisal-scale source trials, omitting a modifier is material at strengths that interaction
screening detects in fewer than 80% of analyses. **Refuting sentence:** at the modifier strengths that
matter for a decision, screening detects reliably and the instability is confined to modifiers too weak to
change any conclusion. Mechanism (DESIGN.md section 2): the interaction SE is about $\sigma_e\sqrt{2/n}$ for
unit-variance covariates, so the strength at 80% detection falls as $1/\sqrt n$; the omission bias of a
collapsible mean difference is exactly $\beta\delta$, so the strength at which it reaches a fixed threshold is
$0.1/\delta$ whatever $n$. The gap opens with the target shift $\delta$ and closes with $n$; probe P2 computes
both thresholds before the run.

## 2. Design

Source trial A versus C, 150 per arm, $p \in \{6, 13\}$ independent $N(0, 1)$ candidates (the median and maximum
adjustment-set sizes the catalog's reviews report); $y = 0.3\sum_j x_j + A(-0.5 + \beta x_1) + e$, $e \sim N(0, 1)$, one true modifier of strength
$\beta \in \{0, 0.1, 0.25, 0.4, 0.6\}$. Target: every candidate mean shifted by $\delta \in \{0.2, 0.5\}$, known
as aggregate means. Estimand: target mean difference, $-0.5 + \beta\delta$; the true set is sufficient and
omission bias is $-\beta\delta$. Screening: interactions with $p < 0.05$ in the full-interaction least-squares
model (DESIGN.md's rule; DEC-11 covered 0.2).

Methods, on the same replicate: unadjusted (omits the modifier); MAIC with method-of-moments weights on the
pooled source balancing the true set (oracle), the screened set, or all candidates; STC with all
interactions standardized at the target means, **the comparator that can win**. MAIC SEs: robust sandwich
with fixed weights. 20 cells, **1000 replicates**: MCSE at most 0.016 for a detection rate, 0.007 for
coverage at nominal, about 0.005 for the unadjusted bias against the 0.1 threshold. Cost: probe P4.

## 3. Decision

Omission is **material** when the unadjusted bias is at least 0.1 in absolute value (a fifth of the effect,
ADJ-17's threshold). **Primary cells:** 6 candidates, shift 0.5, strengths 0.1 to 0.6. **Confirmed** if at some
strength omission is material while screening selects $x_1$ in fewer than 80% of replicates; **refuted**
otherwise. Reported for every candidate count and shift: the strength at material omission and at 80%
detection, interpolated on the grid, as two numbers on one axis. **Mechanism check:** empirical detection
within 3 MCSE of the analytic noncentral-$t$ power in the primary cells. **Falsifier:** at shift 0.5,
all-candidate STC or MAIC unbiased within 3 MCSE with RMSE no larger than screened MAIC at every $\beta > 0$.
**Null control:** $\beta = 0$: every method unbiased within 3 MCSE and per-candidate false selection 0.04 to
0.06. **Positive control:** $\beta = 0.6$, $\delta = 0.5$: unadjusted bias at least 0.1 and oracle MAIC
unbiased within 3 MCSE. Also reported: coverage, RMSE, ESS, selection stability. Weights that fail to
balance are counted per method (probe P3 found them for all candidates at 13 and shift 0.5), and MAIC
summaries condition on balance. A near miss is reported as one.

## 4. Departures from DESIGN.md

Continuous outcome, so scale (COV-02) and noncollapsibility do not enter; independent covariates; one true
modifier; one source size, since the mechanism check validates the analytic curve that carries the gap to
other sizes; overlap set by the shift alone; no lasso, stability selection or whole-procedure bootstrap
(DEC-11 and COV-04 ran those routes); no elicitation arm (the oracle is its ceiling); fixed-weight MAIC SEs.
