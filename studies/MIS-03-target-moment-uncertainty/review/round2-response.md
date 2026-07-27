Reviewer 1 judged that seven of eight round-one points were only partly resolved, and was
right about all seven. Three of our round-one responses claimed changes that the manuscript
did not contain. We list those first, because a response that misdescribes the manuscript is
a worse failure than the original omission.

## Claims we made in round one that were not true of the manuscript

**We said the omitted-variance and width formulas were inserted. They were not.** They
existed only as a comment in the analysis code. They are now in the manuscript text, at the
tables that use them, with the ratio-of-scenario-summaries construction stated explicitly
and a note that scenario extrema carry no multiplicity adjustment.

**We said the finite-sample discrepancy in the negative controls was quantified. It was
not.** It is now: on the controls, where the population omission is exactly zero, the
finite-sample departure moves the model standard error by a median of 0.26% and at most
1.49%, and the largest coverage difference between any two methods there is 0.008.

**We said the scope section stated the restriction on $\kappa$. It did not.** Section 3.1
now says that $\kappa$ imposes exact non-negative proportionality between the source and
target modifier coefficient vectors, and that modifier sets differing in direction,
overlapping only partially, or orthogonal are not studied.

On the subtitle: it is present in the document front matter, and the Markdown output format
drops subtitles as it drops abstracts. Since the Markdown file is what reviewers receive,
the reviewer correctly saw no subtitle. The partial-answer framing no longer depends on it;
it is in the abstract and in the section the reviewer reads as the conclusion.

## Major 4. The threshold is one quarter, not one half

**Accepted, and this is a mathematical error we made.** The reviewer's derivation is
correct: with $M = J^\top\Omega J$, the correct increment is $(1-2\kappa)M$, so the status
quo errs by $|1-2\kappa|M$ and the partial method by $2\kappa M$. The partial method is
closer only when $2\kappa < |1-2\kappa|$, that is when $\kappa < 1/4$. Between $1/4$ and
$1/2$ it is **worse than doing nothing**, which is the opposite of what we wrote.

The manuscript now derives this as @eq-quarter, states that the design contains
$\kappa \in \{0, 0.5, 1\}$ and therefore **no interior values with which to test it
empirically**, and makes no claim about intermediate alignment. The practical
recommendation is conditioned on $\kappa < 1/4$ rather than on $\kappa$ being "small".

## Major 3. The identity check was computed on the selected subset

**Accepted.** The manuscript reported 167 scenarios with SE 0.025 while the protocol
reported 216 with SE 0.042, because the manuscript computed the check on the restricted set
and presented it before the restriction was introduced. That is exactly the error we
labelled elsewhere: evaluating a claim on a set chosen by an outcome. The check now runs on
all 216 scenarios with effect modification, giving slope 1.003 (SE 0.042, $R^2 = 0.72$),
and the text says which set it uses and why.

## Major 2. The mechanism fixes the magnitude too

**Accepted.** Since $\mathrm{SD}_T(\tau)$, $\kappa$ and $n_T$ are design inputs, the
first-order absolute omitted component is fixed analytically and the simulation does not
discover it. The manuscript now says what the simulation *does* contribute: the fraction of
total variance, which depends on source information the identity does not fix; the coverage
consequences; the finite-sample departures; and the behavior of the partial estimators.

## Major 1. Labelling does not restore confirmatory evidence

**Accepted, and the conclusion is rewritten accordingly.** The scope section now separates
what is established analytically from what is established empirically and only in the
restricted set, and states plainly that **the registered coverage question is not
confirmatorily answered**. We had written "answers MIS-03 in part" in a way that blurred the
two; the two are now listed separately with their different warrants.

We have still not performed the new registered run. It remains the correct next step and we
do not claim to have taken it. The catalog entry records the study as answering part of the
problem with the confirmatory question open, rather than as closing it.

## Major 5. Monte Carlo uncertainty for extrema and stratification

**Partly accepted, partly not done.** Accepted: the abstract no longer asserts a uniform
band, and now says the extrema sat within about one Monte Carlo standard error of the band
edges. The paired table caption now explains why a McNemar contrast's Monte Carlo error is
governed by discordant pairs rather than by marginal coverage.

Not done: we have not added per-extremum Monte Carlo intervals, a direct normal-recon versus
reported-cov paired contrast, or stratification by target-correlation misspecification. We
judge these worth doing and they are within reach of the existing output, but they are
additions to an analysis we have already labelled exploratory, and adding detail to a
selected analysis does not change its status. They belong in the confirmatory run.

## Major 6. Formulas and the ratio construction

Formulas added, as above. On the construction: we agree that squaring a ratio of
scenario-mean standard errors is not identical to a ratio of mean estimated variances. The
manuscript now states which one is computed rather than leaving it to be inferred. We have
not switched to the alternative; the two agree closely here and changing it would not alter
any conclusion, but the reader can now see which was used.

## Major 7. Over-broad observed-data and robustness claims

**Accepted.** "Nothing in a publication identifies $\kappa$" is now "the inputs a
matching-adjusted comparison ordinarily uses do not identify $\kappa$", and the manuscript
notes that reported subgroup effects or interaction estimates might in principle carry some
of the required information and that we have not investigated whether they do.
"Approximately normal" is corrected to exactly multivariate normal with a single
equicorrelation discrepancy. "No deployable correction exists" is now "we are not aware of a
deployable correction".

## Minor 8. "Must coincide"

**Accepted.** The abstract now says the population omission is exactly zero there and the
four intervals should very nearly coincide, consistent with the finite-sample statement in
section 3 and with the quantification now supplied.

## Our position on the standing recommendation

We accept the reviewer's judgement that this manuscript does not confirmatorily answer its
registered question, and we have not tried to argue otherwise. We are publishing it with
that judgement attached rather than withholding it, because the analytic content stands on
its own, the negative result about the source sandwich is worth reporting, and the catalog
entry it serves is more useful with a partial answer and a visible reviewer objection than
with nothing. The review, including this standing recommendation of major revision, is
published beside the paper.
