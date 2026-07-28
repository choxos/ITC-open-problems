# Response to round two

Sol `major-revision`, eight major comments and `conclusions_supported: false`. Kimi
`minor-revision`, two major comments and `conclusions_supported: false`. GLM `minor-revision`,
two minor comments and `conclusions_supported: true`.

Kimi's **round-one** report also arrived during round two. The first attempt returned an empty
response; a retry succeeded after the round-two package had already been sent, so that report
never received a round-one response and is answered here. It is truncated by an output limit at
comment 10 of an unknown total, which is recorded rather than hidden. Nine complete comments
survive and four of them anticipate what Sol raised in round two, independently and from a
different model family.

Two reviewers say the conclusions are not supported. They are right, and the reason is not
overstatement. **Round two found two errors in this study's code**, both derived by reviewers
from published numbers alone without access to the source, plus a manuscript that shipped with
two literal blanks where results should have been, plus an undisclosed departure from
registration. Every allegation below was checked numerically before it was accepted, and three
further defects were found in the course of checking that no reviewer reported.

---

## The two code errors

### 1. Contraction was divided by a prior the arm was not fitted under

Kimi, round one, comment 2. **Confirmed, and it inverted the direction of a published result.**

`R/02-fit.R` computed $1 - \mathrm{sd}(\text{posterior}) / \mathrm{sd}(\text{prior})$ with the
denominator hard-coded to `PRIOR_REG_SD`, the main design's 2.5, in every arm. The
prior-sensitivity arm is fitted under `normal(0, 1)`. Its contraction was therefore measured
against a prior it never used.

The reviewer reached this without the code, from the published figures and one theoretical
observation: for a fixed likelihood, tightening a prior cannot *raise*
$1 - \mathrm{sd}(\text{post})/\mathrm{sd}(\text{prior})$, and the paper reported it rising from
0.33--0.42 to 0.68--0.70. The reviewer's reconstruction, that 0.68--0.70 is approximately
$1 - 0.88/2.5$, is exactly right.

Corrected. `check_stats()` now takes the prior as an argument and records it in the output;
`03-replicate.R` reads it from the prior object rather than the config. The already-run fits
stored raw posterior standard deviations, so the repair is exact algebra on what is on disk and
needed no refit. Against the prior each arm actually used, contraction **falls** from 0.37 to
about 0.20 when the prior tightens, which is the direction it must move.

What the arm was for survives: the check's flag rate barely moves between priors. The narrative
conclusion is unchanged and the number supporting it was wrong.

### 2. The primary bound was computed for a different quantity than the one it bounds

Kimi, round one, comment 3. **Confirmed, though not by the mechanism proposed.**

The registered gate is an upper bound on the **deployment-weighted** risk. `R/05-analyze.R`
computed `hi95` as a one-sided Wilson bound on the **unweighted** count and printed it beside
the weighted point estimate. So the paper's headline 0.777 was a bound on 0.758, presented as a
bound on 0.675.

The reviewer inferred from the width that the effective sample size must be about 55 and
suspected the deployment weighting had concentrated mass. That diagnosis is not right: the
weights are mild, with a Kish effective count of 24.2 of 32 cells. But the finding is right, and
it is the one that matters: the published bound could not be reconstructed from the published
sample size because it belonged to a different estimator.

Corrected. Weights are constant within a cell, so the estimator is a ratio of weighted cell
means and its variance is exact up to plugging in the cell rates. The weighted bound is
**0.697** with a standard error of 0.0134. The unweighted Wilson bound is retained beside it and
labelled. **The verdict is unchanged: FAILS, by a factor of about seven.**

One consequence is worth stating because it looks like a bug and is not. The systematic-error
indicator is a deterministic function of a cell's drift and the displacement, so it has no
within-cell variance and its bound equals its point estimate exactly. All remaining uncertainty
is in weights that are declared rather than estimated. This is now said in the text.

---

## The manuscript shipped with blanks

Sol comment 1 and Kimi comment 1, independently. **Confirmed at two places in the rendered
file.**

`out/IDN-05.md` line 306 read `At the amendment level of 0.15 the rate is \[, \]` and line 631
`the DIC rule fires in \*\*\*\* \[, \]`. `power-pooled.csv` was built from the 32 registered
cells and the amendment arm lives in a different file, so `pp[pp$drift == 0.15, ]` returned zero
rows, `pc()` returned `character(0)`, and Quarto rendered nothing. No error was raised anywhere:
a zero-length inline result is a silent empty string.

The round-one response asserted 0.020 [0.010, 0.039] for that row. The arithmetic is right, 8 of
400 pooled with a Wilson interval, but it was computed by hand for the letter and never checked
against the page.

Three fixes, at three levels.

- The amendment arm is now pooled into `power-pooled.csv` with an `arm` label, so the lookup
  finds it.
- The lookup **stops** on anything other than exactly one row instead of returning nothing. A
  value that cannot be found now breaks the render.
- `review/verify-render.py` scans the rendered output for the shapes an empty inline result
  leaves behind, plus stray `NA`, `NaN`, `Inf`, `NULL` and unevaluated `` `r ``. It is a
  publish gate. Run against the file the reviewers received, it reports both blanks.

`verify-response.py` could not have caught this. It checks that claimed text is present; this
failure is text that is absent.

---

## The undisclosed departure from registration

Sol comment 1, final clause. **Confirmed, and worse than the reviewer could see.**

The reviewer observed that 960 prior-sensitivity fits cannot come from the registered eight
cells at 100 replicates with four models. Counting the stored cell files shows why: the arm ran
**eight cells at 30 replicates**, 240 replicates, 960 fits, against the 800 replicates and 3,200
fits registered. The shortfall was real, was not deliberate, and was not disclosed in either of
the first two drafts.

The protocol now records it with its date. The cells are the registered ones and nothing was
re-selected after results were seen, but at 30 replicates a cell-level rate carries a Monte
Carlo standard error near 0.09, so the arm is reported as directional and no registered claim
rests on it. `R/05-analyze.R` now writes the arm's composition to a file so the manuscript
states it rather than deriving it.

This is the second undisclosed departure in this study. The first, the fit-eligibility rule, was
disclosed in round one after Sol raised it. That two were found by review rather than by us is
the finding about our process, not about this arm.

---

## Numbers that disagreed across documents

Sol comment 1, Kimi comment 3, and Kimi round-one comment 4. All checked.

**The 720 was wrong; 800 is right.** `m3-null-rules.csv` gives n = 800, which is 8 null cells
$\times$ 50 replicates $\times$ 2 covariates. The 720 in the protocol assumed the eligibility
rule that was amended away before the run. Corrected in both places it appeared, with the reason.

**The M3 gap: both figures were correct and the text never said which.** 0.080 is the drifting
covariate, 0.087 pools both. `m3-null-rules.csv` now carries both poolings as labelled rows and
the manuscript quotes both explicitly. M3 is confirmed on either.

**The M4 denominator.** Kimi is right that the interval used 3,200 covariate-checks drawn from
1,600 replicates, and that the two checks inside a replicate share a fitted network, so a
binomial interval is anti-conservative. The interval is now clustered by replicate, which widens
the standard error from 0.00546 to 0.00570 and the interval to [0.096, 0.118]. M4 remains **not
clearly met**.

**The calibration figure: our response letter was wrong and the manuscript was right.** Sol
found that the letter said 0.099 and the paper said 0.086 and asked which. The manuscript's
0.086 is the mean over the ten held-out folds. The 0.099 in the letter is the `n_studies = 6`
fold alone, which we took for the mean. The letter was wrong.

---

## The calibration explanation, at the third attempt

Sol comment 6. **Accepted, and the reviewer's reasoning was sound where two of ours were not.**

The reviewer's objection to the second explanation is correct: all four displacements being
present in training makes a displacement effect *estimable*, not *redundant*; and since the
check statistic is identical across the four target rows while material-error risk changes
strongly across them, displacement must carry information the statistic does not.

The explanation is a property of the registered metric, which we had not looked at closely
enough. Absolute error between *mean* predicted probability and *mean* observed rate is
calibration in the large, and a logistic model fitted by maximum likelihood is calibrated in the
large on its training set by construction, so a predictor balanced between training and test
cannot move it. The metric was nearly blind to the question.

Held-out discrimination answers it, and the answer is the opposite of what two drafts concluded.
Across the ten held-out folds the check statistic alone discriminates material error at an
AUROC of **0.48 to 0.63**, close to chance. Adding the target displacement raises it to **0.50
to 0.83**, and to **0.69 to 0.75** over the six folds that hold out a design factor rather than
a drift level; the one fold where it does not help holds out drift 0, where the test set has no
violation and material error is pure noise. Knowing the target is
worth far more than knowing the check statistic, and the check cannot tell an analyst the
target. That is a sharper version of the section's claim, and the paper reached it only because
a reviewer refused two wrong explanations of a null result.

---

## The prespecified AUROC analyses

Sol comment 5, Kimi comment 4, and Kimi round-one. **Accepted without reservation.**

These were registered in section 5 of the protocol, computed from the first run onward, and
omitted from the first two drafts while `@hanley1982` was cited for a method whose output never
appeared. Kimi's characterization, an undisclosed protocol deviation, is exact.

They are now reported in full with Hanley and McNeil intervals, against material error and
against the presence of a violation, and the omission is recorded in the protocol. The result is
the strongest form of the paper's central claim and does not depend on any rule of ours:
$-\Delta\mathrm{DIC}$ ranks a violated network above an intact one with an AUROC of **0.557
[0.517, 0.596]** at a violation twice the size that matters, and the directional posterior
probability reaches only 0.507, an interval containing chance. No threshold recovers a ranking
the statistic does not contain.

---

## The strategy recommendation

Sol comment 8, Kimi comment 2. **Accepted, and checking it exposed a third problem neither
reviewer saw.**

Kimi is right that "lowest error at every displacement" is contradicted at displacement 0 by our
own RMSE column, 0.0422 for imposing the restriction against 0.0426 for check-then-relax.

Checking that exposed the reason: the paired differences were computed **unweighted** while the
RMSE table beside them was **deployment-weighted**, and the two disagreed in sign at
displacement 0 for that reason alone. Both are now weighted, so the table and the paired test
answer the same question. `paired()` also computed a squared-error difference and discarded it;
it is now reported, because that is the loss on which the ordering turns.

The corrected result, deployment-weighted and paired:

- Against **relaxing everything**, check-then-relax wins at all four displacements on both
  losses, every interval excluding zero.
- Against **imposing the restriction**, it wins at 0.5, 1.0 and 1.5, and at displacement 0 the
  difference is $-0.00005$ with a 95% interval of $[-0.00069, 0.00059]$, which contains zero.

So the claim is now: better than relaxing everything everywhere, better than the restriction
wherever there is anything to transport, and indistinguishable from it where there is not. That
is what the data support. Paired differences are reported at every displacement, and repeated on
the sixteen homogeneous cells, where the ordering is unchanged.

---

## Where the reviewers' premises were wrong, with evidence

Sol comment 7 raises three objections to the equivalence analysis. Two do not apply, and saying
so is not a refusal to engage: the reasoning is checkable in the code.

**"The contrast SD requires the covariance between treatment-specific interactions, which is not
shown."** It is not assembled from marginal standard deviations. `check_stats()` forms the
contrast draw by draw from the joint posterior,
$z^{(m)} = \gamma_A^{(m)}[x_1] - \gamma_C^{(m)}[x_1]$, and takes the standard deviation over
those draws, so the covariance is fully accounted for.

**"The condition is necessary only under an approximately normal posterior."** True of the
$\varepsilon/1.96$ condition, which is offered as an interpretive gloss and now labelled as one.
But it is not what produces the count of zero. That count comes from
$P(|z| \leq \varepsilon)$ evaluated as the proportion of posterior draws satisfying the
inequality, which assumes no shape at all.

**"A ratio of two posterior SDs is not prior-free merely because no precision subtraction was
performed."** Accepted. Both posteriors shrink toward the same prior. The word is removed; what
survives is that the ratio avoids the instability that demoted the derived column, which is a
narrower and true claim.

The related claim that the count of zero "would remain zero under any prior that does not itself
supply the answer" is withdrawn. A prior placed directly on the contrast would change the
arithmetic, and we did not run one.

---

## Accepted and corrected without argument

- **"Keeps its nominal coverage"** (Sol 10, Kimi 6, Kimi round-one 1). False, and contradicted
  by our own type I error. Split by heterogeneity as Kimi asked: the interval rule fires on
  0.075 [0.046, 0.120] of replicates under the global null with no heterogeneity and 0.110
  [0.074, 0.161] with it. Avoiding covariate selection is necessary for coverage, not
  sufficient. The claim is replaced by the measurement, in the manuscript and in the code
  comment that carried it.
- **"Lower bounds on the failures in practice"** (Kimi 7). Not licensed in generality. Now
  scoped: failures attributable to the listed idealizations are conservative, and three features
  cut the other way, namely fixed-effect fits on heterogeneous data, quadrature noise, and the
  single individual-level study.
- **"The only thing that determines the harm"** (Sol 9). Section retitled.
- **DIC cutoffs of 2, 5, 10 attributed to @spiegelhalter2002** (Sol, citations). Now explicitly
  ours, with the citation for the criterion and not for the cutoffs.
- **Generic package citation for development-version behavior** (Sol, citations). Now cited to
  the exact build: 0.9.1.9002, commit `8489bd83f388f3cb48062947cd9ab083218947dd`, built
  2026-06-27, with a URL to that tree.
- **Decision curve undefined and uncited** (Sol 11, Kimi 8, GLM 2). The formula, the event
  definition, the prevalence entering the curve, and the tie handling are now stated, with
  @vickers2006. There is no "decision reversal" event in this analysis; the event is a material
  error in the risk difference, and that is now said rather than left to inference. The
  action's cost, delay and probability of success are **not** modelled, which is stated.
- **The decision curve contradicts the recommendation** (Kimi 5). The reconciliation is now
  written out: the strategy comparison scores estimation error, where the check contributes a
  little; the decision curve scores whether to trust an analysis at all, where the event is
  dominated by noise no covariate check can predict. Kimi's framing, that this restates the
  noise floor rather than measuring the check, is adopted.
- **The exhaustive novelty claim** (GLM 1, Sol citations). Scoped to the ML-NMR
  population-adjustment literature, with the basis of the search stated and the broader
  network meta-regression literature on interaction structures explicitly excluded from the
  claim.
- **Deployment weights invisible** (Sol 8, Kimi 5). The round-one response said this was fixed
  and it was not. They are now written to `results/deployment-weights.csv` and published.

---

## Found while checking, reported by nobody

Three defects surfaced in the course of verifying the reviewers' arithmetic.

**The worst R-hat was understated.** The paper quoted 1.89 and ESS 3.41 from the fully relaxed
model as though they were the worst in the study. Across all four models the worst R-hat is
**5.13** with ESS **1.03**, in a singly-relaxed fit, and at least one fit misses its criteria in
0.076 of replicates. Quoting the better of two figures understated the problem.

**The weighting mismatch in the strategy comparison**, described above.

**`study.json` still carried the title retracted in round one**, together with three claims the
manuscript had already withdrawn: that one prior-free number carries the paper, that the
failures are lower bounds, and the superseded 0.777 bound. That file feeds the catalog page and
was the one published artifact no checker covered. It is rewritten, and it is now covered.

---

## What is not fixed, and why

Three of Sol's requests are refused for now and declared rather than argued away.

**Demonstrating quadrature convergence** (Sol 2). The request is legitimate and the objection is
the sharpest in the report: a difference between two unconverged grids is not a bound on the
error of either, and with two verdict flips in 24 networks the estimate itself is very noisy.
This would need a new arm at successively finer grids across more networks. It was not run. The
manuscript states that 256 points is not demonstrated to be converged and that the flip rate is
of the same order as the signal it sits beside; that is a limitation on the primary result, and
it is now labelled as one rather than as a qualification.

**Refitting the non-converged models** (Sol 4). Also legitimate. The converged-subset analysis
shows the strategy ranking does not depend on those replicates, which answers the question it
was asked, but it does not make a DIC computed from a chain with R-hat 5.13 valid. Refitting
would need a new run.

**Implementing an exchangeable comparator** (Sol 8). The partial-pooling strategy is the one an
analyst would most want and is absent. The package does not implement it and we did not write it
ourselves. This is stated in the manuscript as a reason for its absence and not a justification,
and the recommendation is scoped to the three strategies compared.

Each of these would change what the paper can claim. None of them is answered by argument here,
and the manuscript's conclusions are narrowed to what the evidence supports without them.

## Verification

`review/verify-response.py` extended to 99 assertions covering both rounds, including the
retracted round-two claims and, for the first time, `study.json`. 99 of 99 pass.
`review/verify-render.py` reports no empty inline results in the rendered manuscript.
