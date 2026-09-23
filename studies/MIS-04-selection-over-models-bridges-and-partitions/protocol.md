# Protocol: choosing among population-adjustment models on the same data

**Target problem.** MIS-04 (MOD-04 merged into it). Re-scoring study. Committed before any scoring.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

When the analyzed data choose the adjustment model and the chosen model's interval is reported, the
interval ignores the selection. **Refuting sentence:** the candidate models that survive scientific
screening are close enough that averaging over them changes nothing, so conditional intervals are
adequate in practice.

## 2. Data

No new simulation. DIA-08's stored replicates (16 anchored binary-outcome scenarios with linear,
threshold, interaction and quadratic effect modification at three overlap levels, plus skewed
covariates and no modification; 2000 replicates each) give per replicate the estimate and SE of four
adjustment methods: MAIC on means, MAIC on means and SDs, linear STC and quadratic STC. DIA-08's RMSE
rankings were known when this protocol was written; no selection rule had been scored.

## 3. Rules

Prespecified linear STC; prespecified MAIC on means; the candidate with the smallest SE (selection by
precision); the candidate with the most negative estimate (selection by result); an equal-weight
average with variance equal to the mean within-model variance plus the between-model variance of the
four estimates.

## 4. Decision

**Refuting sentence fails** if selection by precision covers below 0.93 beyond Monte Carlo error in some
scenario, if selection by result covers below 0.93 anywhere, or if the averaged interval's coverage
differs from the prespecified linear STC's by more than 0.03 somewhere. Bias, RMSE, width and the most
often chosen candidate are reported for every rule.

## 5. Departures from DESIGN.md

Selection over outcome and weighting models only; treatment partitions and bridges (including
observationally equivalent ones, where no data-based weight exists) are not studied; equal weights
rather than stacking or likelihood-based weights.
