# Response to round one

Sol `major-revision`, twelve major comments and `conclusions_supported: false`. GLM `accept`
with one minor comment. Kimi returned an empty response on the 61 KB package; the cause is
recorded at the end.

Sol is right that the conclusions were not supported as written. Five of the twelve comments
identify arithmetic or logic that was wrong, not merely overstated, and every one of those was
verified numerically before it was accepted. The title has been replaced, one registered claim
has been downgraded from confirmed to not clearly met, the headline finding has been reframed
from a property of a rule into a statement about precision, and the document that records the
prespecified decision is now generated from the result files rather than typed.

---

## 1. The study measures our formalizations, not one published rule

Accepted without reservation. "Compare the posteriors and the model fit" describes an
exploratory practice, not a decision rule. The five rules scored here are ours, and the
equivalence rule in particular was never part of the original proposal, so its failure is not
evidence that anyone claimed the practice affirms equivalence.

The manuscript now says this in the second paragraph of the introduction, before any result, and
again in the limitations. The claim that survives is narrower and is stated as such: no rule in
this family, on these networks, separates violations that matter from their absence.

## 2. The margin and equivalence rules are driven by the prior

**Correct, and this was the most consequential error in the paper.** Verified: with independent
`normal(0, 2.5)` priors the contrast has prior standard deviation 3.536, so the prior alone
places **0.9655** of it beyond $\varepsilon = 0.1531$, which is above the 0.95 threshold at
which the margin rule fires. Only 0.0345 lies inside the equivalence region.

The headline "the check never gives an all-clear" was therefore partly an artifact of a prior we
chose. It has been replaced by the statement the data actually support, which is sharper. For
the equivalence rule to fire, the posterior standard deviation of the contrast must fall below
$\varepsilon/1.96 = 0.0781$. The tightest stratum in the design reaches 0.30, a factor of 3.8
short, and the loosest 1.64. **No network in this design came within a factor of three of the
precision needed to affirm the assumption at the margin that matters.** That is why the count is
zero, and it would remain zero under any prior that does not itself supply the answer. The prior
arithmetic is now in the manuscript.

## 3. M1 is algebraic, and pass value does not depend on displacement alone

Accepted on both halves. The first half of M1 is a bookkeeping identity, since the same fits are
reused at every displacement; the manuscript said so but then reported it as a finding. It is
now labelled as verifying the bookkeeping rather than discovering anything. And "depends
entirely on displacement" was wrong: pass value depends on the drift as well, and the check is
blind to both. The sentence now says displacement is the axis this section isolates because it
can be varied while holding the fitted network exactly fixed.

## 4. The analysis violates its own registered fit-eligibility rule

**Correct in letter, and the protocol text was never updated.** The registered rule excluded a
replicate if any fit had $\hat R > 1.05$, ESS $< 100$, or divergences. That rule was amended
before the reported run, for a reason recorded in the code at the time: the first cell showed
all six exclusions were diagnostic failures, five involved a split model, and the shared model
never failed once, so the rule removes exactly the replicates where relaxation is hardest.
Amending it was right; leaving section 4 of the protocol saying the opposite was not.

The protocol now records the amendment, its reason and its date, and the limitations disclose it
as a departure from registration.

On the substance, that retaining bad fits is what makes relaxation look poor: **it is not.**
Every primary comparison is now repeated on the 1,479 replicates where all four fits met the
original criteria. The paired advantage of check-then-relax over relaxing everything is 0.0109
on all replicates and 0.0116 on the converged subset; over imposing the restriction, 0.0173 and
0.0174. The conclusion is unchanged.

## 5. The estimand is not well defined under treatment-effect heterogeneity

Accepted. Where $\tau_{re} = 0.15$ the truth is defined at $\delta_{jk} = 0$, a superpopulation
quantity, while the fixed-effect fits estimate a precision-weighted function of the realized
studies; and integrating the inverse link over the random-effect distribution is not the same as
setting the random effect to zero. Part of the error attributed to the check in those cells is
that mismatch, and the oracle does not remove it because the oracle is fixed-effect there too.
This is now stated in the limitations, and results in the eight $\tau_{re} = 0$ cells are
reported separately.

## 6. Several claims do not respect Monte Carlo error

**Correct, and one registered claim changes verdict.**

"Fires in at most 8% of analyses" was the maximum of eight cell estimates each with a standard
error of about 0.065. It is gone. Detection is now reported **pooled across strata**, where the
standard error is near 0.01, with intervals:

| true contrast | DIC < −5 | 95% CI |
|---|---|---|
| 0 | 0.013 | [0.005, 0.029] |
| 0.15 | 0.020 | [0.010, 0.039] |
| 0.30 | 0.045 | [0.029, 0.070] |
| 0.60 | 0.147 | [0.116, 0.186] |
| 1.20 | 0.453 | [0.404, 0.501] |

The title is now drawn from this table.

**M4 is downgraded from confirmed to not clearly met.** 0.107 against a threshold of 0.10, with
a 95% interval of [0.097, 0.118] whose lower bound is below the threshold. A point estimate
0.007 above a threshold with a standard error of 0.006 does not clear it.

Strategy comparisons are now **paired**, since the three strategies are scored on the same
replicate, and reported with intervals.

## 7. The numerical instability is the same order as the signal

Accepted, and the characterization is retracted. The manuscript called an 8.3% verdict-flip rate
"small beside the resolution problem". It is not small: the DIC rule's detection rate rises by
about three percentage points between no violation and one twice the size that matters, and
changing the quadrature grid alone moves the verdict in 8.3% of replicates. The text now says
this. The subset is also now described: 24 simulated networks from two cells, the largest
network at the widest covariate spread with and without drift, which is where quadrature is most
stressed; and since 256 points is not demonstrated to be a converged reference, the figure is
reported as a lower bound on the instability rather than a measurement of it.

## 8. Numbers disagree between the manuscript and the evaluated decision

**Correct on all three, and this is the process failure, not a typo.**

- M2 clears its threshold in **5** of 8 strata. The decision document said 6.
- The type I error gap is 0.080 on the drifting covariate and 0.0875 pooling both covariates.
  The manuscript quoted 0.087 beside a table showing 0.0125 and 0.0925, which is the first pair.
- The stable-factor calibration error is 0.058 in the leave-one-factor-level-out analysis; the
  0.099 in the decision document came from a different analysis.

All three arose the same way: the decision document was typed by hand from a mix of tables.
**It is now generated by `R/08-decision.R` from the same result files the manuscript reads**, so
the two cannot drift apart again. That script is published with the study. Every number in the
document is computed; nothing is transcribed.

This is the fifth time in this program that a published summary has contained a number the
underlying analysis did not support, and the first time the fix has been to remove the
transcription step entirely rather than to check the transcription more carefully.

## 9. Drift 0.15 is not the boundary

**Correct, and the claim was false as written.** At drift 0.15 the transported error is 0.0294,
which is below the 0.03 threshold, so by this study's own definition that violation is not
material. The contrast that lands exactly on the threshold is 0.1531. The manuscript described
these cells as the exact boundary and as "the violation that precisely changes a decision"; both
statements are corrected. What the cells show is behaviour at a violation just short of
mattering, and the finding there is stronger for being stated correctly: pooled detection is
0.020 [0.010, 0.039] against 0.013 [0.005, 0.029] under the global null, intervals overlapping.

On the amendment's status: it was made during the run and is not part of the registered design.
It is dated, its reason is recorded, no result from those cells was seen before they were
specified, and they are excluded from the deployment mixture. They are reported as an amendment
throughout and are not used for any registered claim.

## 10. "Displacement cannot help because it is not in the statistic" is a logical error

Accepted. A predictor can improve a prediction without changing another predictor, and M1 shows
displacement moves the outcome strongly. The reasoning was wrong.

The prespecified target-aware model was computed and its absence from the manuscript was an
omission. It is now reported: adding displacement changes the held-out absolute error from 0.099
to 0.099, no improvement, and the correct explanation is narrow and empirical. Each fold holds
out a drift level or a design factor, so all four displacements are present in training within
every fold and displacement carries no information the mapping did not already have. What fails
is transport across drift, and knowing the target does not repair that.

## 11. The data-only standard error is not well defined

**Correct, and the title depended on it.** Subtracting prior precision from posterior precision
recovers the likelihood only under Gaussian conditions that a weakly identified interaction does
not satisfy. The study's own prior-sensitivity arm demonstrates the failure: the same networks
give a data-only standard error of about 1.0 under `normal(0, 1)` and about 1.8 under
`normal(0, 2.5)`, and those should agree.

The quantity is retained as an order-of-magnitude statement with that instability disclosed in
the text, and **no claim in the paper now rests on it**. The title has been replaced with one
drawn from directly measured detection rates. What the resolution section now leads with is the
posterior standard deviation itself, 0.30 to 1.64 across strata, which is what an analyst reads
off the output.

## 12. The recommendation to use the check is not established

Partly accepted. The comparison is now paired, reported with intervals, and repeated on the
converged subset, and on that footing check-then-relax does beat both alternatives at every
displacement with intervals excluding zero. The advantage is small and is described as small.

Two parts of the comment are not answered and are declared rather than argued away. Exact
deployment weights are in the configuration and the protocol but were not restated in the
results, which is fixed. And the hierarchical or exchangeable interaction strategy is genuinely
missing: it is the middle ground IDN-05 proposes, `multinma` documents
`class_interactions = "exchangeable"` and raises "not yet supported", and we did not implement
it ourselves. The manuscript now says that package non-implementation is a reason for its absence and not a
justification, that we could have written the model ourselves and did not, and that until
someone does, "check, then relax what fired" is the best of three options rather than a
recommendation about what to do.

## GLM, minor

The point about 50 replicates is accepted and is now enforced rather than merely stated: every
detection rate in the results is pooled or stratum-level, and the pooled table carries
intervals.

## Why Kimi returned nothing

`opencode run --pure` gives the model no tools. On the 61 KB package it produced an empty
response, as it did on a 9 KB design document earlier in this study while answering a 2.3 KB
prompt normally. The reviewer prompt already forbids tools, so the earlier diagnosis does not
explain this one; the remaining pattern is input size. A retry is running and its outcome will
be recorded in the round-two package either way.
