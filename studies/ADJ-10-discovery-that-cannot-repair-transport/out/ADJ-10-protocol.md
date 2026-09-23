# Protocol: data-driven modifier discovery across few trials

**Target problem.** ADJ-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Discovering effect modifiers from pooled trial data is limited by the number of trials for anything identified across
trials, and a study-level factor that shifts the treatment effect and correlates with a covariate's trial mean produces a
false modifier that more data do not remove. **Refuting sentence:** with the trial counts and event rates evidence networks
supply, discovered modifier sets are stable enough and the aggregated effect accurate enough that discovery is a usable
component rather than a hypothesis generator.

## 2. Design

$K \in \{3, 6, 12\}$ trials with 2400 patients in total; ten candidate covariates with trial means varying across trials;
continuous outcome $y = 0.3\sum x + A(-0.5 + 0.2\sum_{j \le M}x_j + cS_k) + e$ with $M \in \{1, 3\}$ true modifiers and an
unmeasured study-level factor $S_k$. With confounding ($c = 0.3$) the tenth covariate's trial mean follows $S_k$, so it
appears to modify across trials but not within them. 12 cells, **300 replicates**, each with a second independent dataset
for stability.

Discovery by lasso on the ten interactions, with the penalty at minimum cross-validated error and by the one-standard-error
rule: pooled (one treatment effect across trials) and within-trial (trial-specific treatment effects). Target effect at
covariate means 0.5 and $S = 0$ from least squares with the selected interactions.

## 3. Decision

**Refuting sentence holds** only if every method-penalty combination has stability (Jaccard similarity of the sets from
two independent datasets) of at least 0.8 and at most 0.5 false discoveries per analysis in every cell. Reported also: power,
selection of the confounded covariate by method, stability by number of trials, and target bias and RMSE.

## 4. Departures from DESIGN.md

Lasso rather than multi-study causal forests; continuous outcome, so event sparsity is not studied; linear modification
only; one overlap level. Discovered sets are evaluated as hypotheses; the target effect after selection is reported for
completeness, not as a recommended analysis.
