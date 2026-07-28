# Response to round two

Sol `major-revision` with four major comments, GLM `minor-revision` with none, Kimi
`minor-revision` with one. Sol resolved ten of sixteen round-one points as "partly" and six
as "yes"; GLM twenty-five of twenty-eight as "yes"; Kimi eighteen of twenty-five as "yes".
Kimi's round two required a second attempt: the first returned an empty response on a 148 KB
package, which is recorded in the raw log.

Sol's first comment is answered first, because it is the same failure this program has now
made four times, and this time it slipped past a check built specifically to catch it. Kimi
then found two more instances of it in sections the check did not read, which is answered in
point 5.

---

## 1. The abstract still contained the sentence we said we had retracted

Sol writes:

> The abstract still says, "Transport error is the only piece a covariate diagnostic could
> know about before an outcome is seen," even though the manuscript and response explicitly
> call that statement wrong.

Correct. We rewrote section 3, said in the response letter that the claim was withdrawn, and
left the same claim standing in the abstract.

The check we ran before writing the round-one letter passed thirty-four of thirty-four items.
It was the wrong check. It verified that each **new** statement was present and never that
each **retracted** statement was absent, so a corrected section and an uncorrected abstract
both counted as success. The check now runs in two halves, positive and negative, and the
negative half is what would have caught this. Both halves pass on the current text, and the
negative half is listed in the published record so a reader can see what it looks for.

The abstract is rewritten. It no longer makes a knowability claim at all; it says that two of
the three components are functions of covariates, assignment and weights, that the panel is
built from those ingredients, and that the third is what adjustment exists to remove.

## 2. Systematic bias was never evaluated, and the title claimed more than the results support

Sol writes that the quantity we call transport error is a realized effect-modifier component,
not systematic bias, so comparing 0.847 against 0.653 does not establish a
variance-versus-bias conclusion. Agreed, and this is the most consequential comment of either
round.

We have added the analysis: the systematic part is estimated as the Monte Carlo mean of the
transport term **within a cell**, and every diagnostic is scored against it with the cell as
the unit. Forty-two of 128 cells carry a systematic transport bias above 0.20. Against that
target, effective sample size reaches **0.808**, not 0.653.

We are reporting the result that weakens our framing, and then reporting why it does not
rescue the panel either. The statistic that is **identically zero** reaches **0.708** on the
same analysis. Nothing that never departs from $10^{-14}$ detects bias; what is happening is
that 128 cells is a small sample in which the bias and every diagnostic move along the same
overlap axis, so a cell-level ranking cannot separate the diagnostics from each other or from
noise. The whole panel lands between 0.708 and 0.845, oracle included. We say this in the
text rather than presenting 0.808 as either vindication or refutation.

What survives is the replicate-level statement, and the paper is now titled as that and only
that: **effective sample size tracks the error an analysis got by chance better than the
error it got from adjusting on the wrong covariates.** The previous title asserted a
variance-versus-bias dichotomy outright and has been withdrawn. The section says explicitly
that the claim is about the level at which a diagnostic is read, one analysis at a time, and
not about the cell level.

## 3. Tables 8 and 9 were internally inconsistent

Correct, and the fault was presentation rather than arithmetic. The registered mechanism
claim is evaluated over the **diagnosable stratum**, which spans two of the four
misspecification strata, under deployment weights, against the best **routinely reported**
diagnostic, a set that excludes the unmatched-balance check because that is our proposal and
not part of the panel. The stratum table is per stratum, under equal cell weights, and
includes everything. Both are now labeled with what they cover, and the difference is
explained where the numbers appear.

Kimi pressed further and was right to: the comparator behind 0.851 was never named, and no
number in the stratum table equals it. It is **effective sample size as a percentage**,
over the diagnosable set, under deployment weights, where it reaches 0.851 and the next
routinely reported member is pre-weighting imbalance at 0.847. That is now stated where the
claim appears, and the stratum table's caption, which asserted that the claim-4 numbers lived
in it, has been corrected to say the opposite.

Reconciling the two properly also reverses part of what we conceded in round one, and we are
reporting the reversal rather than leaving a tidier retraction standing. Over the diagnosable
set our converted statistic reaches 0.937 and the plain unmatched-balance check 0.890, so the
conversion does help there. Inside the omitted-modifier stratum alone the order reverses,
0.946 against 0.938. The two sets differ by whether the well-specified cells are included,
and that is the whole explanation: where the unmatched covariate is a modifier in every cell,
imbalance in it and bias from it are the same thing and converting one to the other only adds
estimation noise; where the analyst does not know whether it is a modifier, which is the real
situation, the conversion is what keeps the statistic quiet on covariates that are imbalanced
and harmless. Our round-one summary, that the conversion "did not earn its keep", was too
strong in one direction just as the registered claim was too strong in the other.

## 4. The calibration interpretation is still stronger than the analysis permits

Agreed. A one-term logistic mapping can fail because the diagnostic does not transport or
because a single linear term is the wrong functional form in the held-out setting, and this
analysis cannot separate them. We did not fit richer forms. The text now says so and confines
itself to the operational fact: a mapping of this shape, fitted elsewhere, is off by about
twenty points of absolute risk in the setting it transports worst to, and the analyst does
not know which setting they are in.

## 5. Kimi found the same failure twice more, in sections the check did not read

Two sentences we said we had corrected survived elsewhere. The introduction still claimed
that within-stratum reporting "removes the dependence on our chosen frequencies entirely",
which the limitations already contradicted; and the protocol's performance-measures section
still described the calibration mapping as fitted on odd-numbered **replicates**, two
revisions out of date. Both are fixed, and both are now in the negative half of the check.

This is the third distinct shape of the same failure and the check has grown a third time to
match. The round-one version looked only for text that should be present. The round-two
version added text that should be absent. Kimi's comments showed that both halves were still
reading too few files, and that the patterns were literal enough to fail on a reflowed
paragraph, which is exactly how the equivalent check passed in study 2 of this program while
the manuscript went unchanged. The check now normalizes whitespace before matching and covers
the manuscript source, the rendered output, the protocol and the analysis code. It is
published in the study directory rather than described, so a reader can see what it does and
does not look for.

## 6. Minor items

**Sol 10, Kimi.** The decision-curve sentence said four rules and named three. The fourth
entry is the coefficient of variation of the weights, which is relative effective sample size
under another name by the identity in the algebra section, not a fourth statistic. Fixed and
explained where it appears.

---

## What we still have not done

Fold-level uncertainty and calibration plots (Sol 4), paired Monte Carlo intervals for the
two mechanism differences (Sol 7 and 14), a reproducible literature-search account (Sol 12
and GLM), richer functional forms for the risk mapping, and the extensions named in the
limitations: heteroskedastic errors, multiple or nonlinear omitted modifiers, uncertain
target moments, cross-fitting the proposed diagnostic, and differential covariate
displacement. Sol resolved ten round-one points as "partly" and most of the residue is here.
We are not claiming these are unimportant. The paper's conclusions do not rest on them, the
limitations name each one, and we would rather publish with the gaps stated than assert a
completeness we have not reached.

Sol's standing recommendation is `major-revision` and we are publishing it with that
attached, unchanged, alongside GLM's `minor-revision`. Neither reviewer has been talked out
of anything.
