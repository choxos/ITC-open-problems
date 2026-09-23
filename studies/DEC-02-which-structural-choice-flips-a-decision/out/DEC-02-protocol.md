# Protocol: which analysis choice flips a decision

**Target problem.** DEC-02. Re-scoring study. Committed before any scoring. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Choices made at different points of a population-adjusted analysis change the recommendation, and they are
never crossed. DESIGN.md separates choices that change the question (the target population, the bridge) from
those that change the answer to one question (estimator, outcome model, prior). **Refuting sentence:** one
factor dominates so heavily that a ranking is uninformative, and the useful output is a single warning.

## 2. Data

No new simulation. DIA-08's stored replicates (16 anchored binary-outcome scenarios; 2000 replicates each;
estimates from unadjusted, MAIC on means, MAIC on means and SDs, linear STC and quadratic STC) are re-scored.
DIA-08's RMSE results were known; no decision had been scored.

## 3. Decision model and outcomes

Adopt B when the estimated B-versus-A log odds ratio is below a threshold placed 0.1 or 0.3 above or below the
truth. Within a decision question, a choice flips the decision when its two options disagree: weighting against
outcome model (MAIC on means against linear STC); linear against quadratic STC; MAIC on means against means and
SDs; unadjusted against linear STC. Across questions, the target population's effect on the true decision is
reported as the range of the true effect over target covariate means 0.3, 0.8 and 1.2.

**Refuting sentence holds** if, near the threshold, the choice with the highest mean flip rate flips at least
three times as often as the next; otherwise the ranking is informative and it fails.

## 4. Departures from DESIGN.md

No prior-specification or bridge factor (no Bayesian or disconnected analysis in the source replicates); the
decision is on the relative effect, not a net-benefit model; one outcome type.
