# Response to the second pre-run critique

Kimi K3, given a 2.3 KB condensed statement of the design, arriving while cells 9 to 16 were
running. Three fatal findings, six serious, nine minor, one named omission, and a table of
registered numerical predictions.

**Important qualification, stated first so nothing below is read as more or less than it is.**
This reviewer saw a condensed summary, not the protocol and not the code. Several findings are
artifacts of what the summary omitted rather than of what the study does, and those are marked
as such rather than accepted for credit. The rest are real, and two of them change the study.

The first three attempts to obtain this critique returned empty. The cause was diagnosed and is
recorded at the end.

---

## Confirmed by the run before the critique was read

The sharpest finding is F1, and the run had already produced the number that proves it.

> Realized error includes estimation noise in $d_A$, $d_C$ ... **P(material error) = 0.31 to
> 0.56 at the global null**. A *perfect* check passes only null cells and posts 0.43 > 0.10.

Cell 1, the six-study network at zero drift where the shared-interaction assumption is exactly
true, measured **P(material error) = 0.46**, inside the predicted interval. The consequence is
the one stated: the registered gate cannot rank a perfect check above a broken one, because
estimation error alone puts a correctly specified fit over a 0.03 absolute-risk threshold in
about half of thin networks.

**Applied.** The gate is reported as registered, and reported again against **what the best
available model achieves on the same replicates**. The oracle is the model that matches the
truth: the shared fit where the interactions really are shared, the split fit where they are
not. Excess over oracle is what separates a check that is uninformative from a threshold that
is unreachable. This costs no extra fits; all four models are already fitted in every
replicate.

## The drift grid skipped the region that matters

> In units of your own $\varepsilon = 0.153$, the grid is $\{0, 1.96, 3.92, 7.84\}$. No
> sub-material-nonzero cell, nothing in $(0.5\varepsilon, 1.5\varepsilon)$ where a useful check
> must discriminate. You will measure the floor and the ceiling and nothing between.

Correct, and neither the first critique nor we caught it. A check is interesting where the
violation is near the boundary of mattering; the registered grid jumps from exactly zero to
twice the boundary.

**Applied, as a recorded amendment.** Eight cells at drift 0.15, exactly one $\varepsilon$,
crossing the other three factors, numbered 33 to 40 so that cells 1 to 32 keep their numbering,
their random streams and their computed results. The amendment is dated, its reason is
recorded, and no result from those cells was seen before they were specified. They are excluded
from the deployment mixture, which was registered over the original four levels, and reported
on their own.

## Contraction is prior-relative, and the prior is not the package default

> Under default `prior_reg = normal(scale = 10)`, my per-cell contraction gap is 0.003 to
> 0.054, 4 to 60 times short of M2's 0.20 ... State the priors; register the prior-free SD
> ratio alongside contraction.

The prior here is `normal(0, 2.5)`, not `multinma`'s default of scale 10, and the condensed
summary did not say so. The reviewer's inference from that omission was sound: a contraction of
0.162 under a scale-10 prior would require a standard error above 15, which is not credible, so
either the prior is informative or the number came from a different fit. It is the former, and
the number is arithmetically consistent with a 2.5 prior: cell 1 gives posterior SD 1.595 and
contraction $1 - 1.595/2.5 = 0.362$.

The substantive point survives and is accepted: **contraction measures the posterior against a
prior we chose**, so M2's threshold is partly a modelling choice. The prior-free ratio of
posterior standard deviations is now reported beside it. In cell 1 it is **7.1**: the
aggregate-only treatment's interaction has seven times the posterior spread of the treatment
with individual data. That statement does not depend on the prior and is stronger than the one
M2 registered.

The choice of 2.5 rather than 10 is also now stated as a limitation with its direction: a wider
prior would widen every posterior, which would make the margin rule fire more often and the
equivalence rule fire even less.

## "The check fired" has two readings, and one of them flatters the check

> If "fires" means *any* covariate, x2-misattribution firings remove high-error replicates from
> the conditioning set while relax-x2-only leaves the x1 error in place: **the verdict improves
> because the check fired uselessly**.

Accepted, and this is a subtle point neither we nor the first reviewer saw. Both readings are
now reported: fires-on-any-covariate, which is how a panel is read, and fires-on-the-drifting-
covariate, which is the only firing that could lead to a repair.

## Findings that are artifacts of the condensed summary

These are recorded because a reviewer's time was spent on them, not because the study changes.

**"The error of the remedy is never scored", named as the most important omission.** The study
scores the target estimand for **all four** fitted models in every replicate and compares three
strategies, always-common, always-relaxed, and check-then-relax with exactly the flagged
covariates relaxed, on RMSE, decision reversal and net benefit across action thresholds. That
analysis was in the first design, is in the protocol, and is implemented in `R/05-analyze.R`.
The condensed summary omitted it. We note, though, that an independent reviewer identifying it
as the single most important thing a study like this must do is corroboration that it belongs
at the front of the paper rather than in a subsection, and it will be.

**"No calibration analysis" (S6).** Leave-one-factor-level-out calibration is registered and
implemented, with the dataset as the fold unit so that all four displacements from one
simulated network stay together.

**"Deployment weights unstated" (F3).** They are numerically specified in the configuration and
the protocol. The related point that a weighted pooled proportion needs a stated interval
method is fair; it is a Wilson bound on the unweighted count, and the uniform-weight version is
now reported alongside so the reader can see how much of the headline is the mixture.

**"trt_effects unstated" (S4).** The fits are fixed-effect while half the cells generate random
treatment effects of SD 0.15. That is deliberate and the protocol says so: an analyst who fits
fixed effects when there is heterogeneity is the realistic case, and whether the
shared-modifier check misreads that heterogeneity is part of what is being measured. The
reviewer is right that it must be stated wherever the heterogeneity factor is interpreted.

**Compute accounting (S2).** The estimate that 6,400 fits is 4.4 core-hours and that 300
replicates would cost 27 core-hours "on the 7 workers already budgeted" is wrong about this
machine by roughly a factor of six. Measured: an Apple M2 with four performance cores, one
occupied by a system process, sustains 2.6-fold speedup at three workers and less at four; a
replicate of four fits plus post-processing takes 21 seconds; the 32-cell run takes 4.3 hours
of wall clock. 300 replicates would be 26 hours. The underlying point is accepted regardless:
at 50 replicates a per-cell rate has standard error 0.07, which is why power is reported by
stratum and why no per-cell difference below about 0.13 is claimed.

## Minor findings accepted

The margin rule's $\varepsilon$ is solved at displacement 1 and applied at all displacements,
so it is loose at 0.5 and strict at 1.5; it stays out of the verdict. M1's rise on the realized
scale is bounded by the noise floor and is now reported as floor plus excess. Drift 1.2 is
eight $\varepsilon$ and flips the sign of the aggregate-only treatment's modifier; it is
labelled a stress test and not cited as practice-relevant. The citation is pinned: the
operational procedure being measured is the informal one described by Phillippo et al. (2023),
"compare posteriors and model fit", which this study formalizes into three explicit rules,
and that formalization is ours and is stated as ours.

## Registered predictions, to be scored against the run

The reviewer registered a table of predicted per-cell power and a predicted headline. It will
be scored in the manuscript. Against the first sixteen cells it is accurate at the low end and
optimistic at the high end: predicted DIC-5 power 0.01 and posterior 0.08 at the thinnest cell
with drift 0.3 against measured 0.02 and 0.08; predicted 1.0 and 0.84 at twelve studies, wide
spread, drift 0.6 against measured 0.28 and 0.40.

## Why the first three attempts returned nothing

`opencode run --pure` gives the model no tools. Asked to critique a design, it replied that it
would first read the prior critique artifacts in the directory, attempted it, and terminated
with 131 bytes. The reviewer prompt in `build/studies/review.py` already forbids tools, sub-
agents and skills, which is why the same model reviewed both rounds of the previous study
successfully; only this ad-hoc critique prompt lacked that instruction. Adding it produced a
22 KB report on the first attempt.
