Reviewer 1 recommends major revision, Reviewer 2 minor. Reviewer 1 identified an error in the
primary measure that changes the reported numbers, and a second point that changes the
conclusion. Both are accepted.

# Response to Reviewer 1 (GPT-5.6 Sol)

## Major 2. The reported sensitivity was not sensitivity

**Accepted, and the analysis is redone.** We called a scenario "detected" when a rule fired on
a majority of its replicates, then averaged over scenarios. As the reviewer says, that is not
sensitivity for flagging analyses whose intervals miss: it discards the pairing between a
warning and a miss within a replicate, and it can penalize a correct warning on a replicate
that did miss simply because its scenario covered well on average. Our "0.111" meant 2 of 18
design cells, not one harmful analysis in nine, and the manuscript said the latter.

Operating characteristics are now computed **per replicate**: among the 56,210 replicate
contrasts whose interval missed, how often did the rule fire, and the same among the 423,790
that covered. The composite has sensitivity 0.366 (MCSE 0.002) at a false-alarm rate of 0.158,
and 0.127 outside the engineered controls.

## Major 4. The uncertainty was not a Monte Carlo standard error

**Accepted, and it follows from Major 2.** Treating 34 fixed factorial design points as a
binomial sample was wrong. At replicate level the draws are genuinely Monte Carlo and the
standard errors are valid; they are also two orders of magnitude smaller, so the prespecified
verdict now rests on an interval that means what it says.

## Major 8. One operating point cannot show the failure is structural

**Accepted, and this changes the conclusion.** We now report threshold-free discrimination.
Used as continuous scores the same statistics reach areas under the curve of 0.51 to 0.78
outside the controls, which is moderate, not none. The manuscript now states that **the failure
is a failure of the prespecified thresholds, not a demonstration that the statistics are
uninformative**, and that a better-calibrated rule would do better. The claim that the failure
was structural is withdrawn as stated and replaced by a narrower one that the evidence
supports: no recalibration of a threshold on an *influence* statistic can detect a prior in the
wrong *location*, which is what the sample-size result shows separately.

## Major 5. Prespecified outputs were missing

**Accepted.** The structural rank screen, the wrong-side decision rate and the amendment
sensitivity are now reported in their own section. The rank screen turns out to matter: it is
the only rule with no false alarms at all, it fires exactly where a contrast leaves the row
space, and it is blind to the disconnected failures where the contrast is estimable and the
answer is still wrong. Interval width and the relationship with the weak-direction share are in
`results/summary.csv` but are not discussed. The Stan validation named in the protocol **was
not run**, and the manuscript now says so rather than leaving it implied.

## Major 6. The power-scaling amendment was made after a first run

**Accepted, and now testable rather than asserted.** The amendment was prompted by an algebraic
fact rather than by a result: with a zero-centered prior, scaling the prior up and the
likelihood down give identical posterior means, so a mean-shift rule of the form "prior
sensitive, likelihood insensitive" cannot fire for any dataset. But the reviewer is right that
power-scaling feeds the composite and the change came after seeing output.

The manuscript now reports the composite with that component removed entirely: sensitivity
0.365 and false alarm 0.146, against 0.366 and 0.158 with it. The verdict does not depend on
the amendment.

On thresholds: we accept that a numerical threshold does not transfer between cumulative
Jensen-Shannon and Hellinger distance merely because both are bounded. The manuscript no longer
claims the 0.05 "carries over"; it states which thresholds come from the source literature and
which are our own choices.

## Major 1. Undercoverage is not prior dominance

**Accepted as a limitation, and it is now in the limitations section rather than implied.** The
reviewer is right that a diagnostic correctly detecting a dominant prior in a cell where the
prior happens to be right is counted here as a false alarm. We chose consequence over geometry
because the geometric reference was algebraically identical to one of the diagnostics being
evaluated, which would have been worse. The manuscript now says plainly that these numbers
answer "do the warnings predict wrong answers" rather than "do the warnings detect prior
dominance", and reports the false-alarm rate separately for cells where the prior is
accidentally correct.

## Major 3, 7 and 9

**Major 3, built in.** Accepted in part. The two engineered geometries were already labelled
positive controls and all headline numbers are reported with and without them. The
disconnected cells were not so labelled and the reviewer is right that a large prior-truth
separation in a weakly identified direction guarantees poor coverage; the manuscript now frames
that cell as demonstrating a mechanism rather than estimating a prevalence.

**Major 7, insufficient design detail.** Accepted. The parameter values, prior covariances,
evidence-matrix construction per geometry and the target contrast formula are in
`R/00-config.R` and `R/01-model.R`, which ship with the study, but the manuscript should not
require reading them. The contrast formula is now given.

**Major 9, limitations.** Accepted. The limitations section now leads with the reference-standard
mismatch, the single form of prior misspecification, the threshold provenance, the unexplored
harm threshold, and the unrun Stan validation.

# Response to Reviewer 2 (GLM-5.2)

**Minor 1. The abstract's "0.000" does not match any reported cell.** Accepted and corrected.
The number was read from the wrong contrast. The disconnected, tight, $\gamma_C = 0.40$ cell at
400 per arm has coverage 0.350 with the composite firing on 0.005 of replicates, and the
abstract now quotes the pair for both sample sizes so the comparison is checkable.

**Minor 2. The structural rank screen was prespecified and absent.** Accepted; it now has its
own results paragraph, as under Reviewer 1's Major 5. It was not dropped deliberately, it was
overlooked.

**Minor 3. Only one form of prior misspecification.** Accepted and added to the limitations: a
diffuse but miscentered prior is untested, and the argument about location versus influence
would apply to it too.

**Minor 4. Sensitivity to the 0.90 harm threshold.** Accepted as a limitation and stated. It is
not explored; the replicate-level analysis reduces its importance, since the primary numbers no
longer depend on classifying scenarios at all.

**Minor 5. Threshold provenance.** Accepted. Only the power-scaling threshold comes from
Kallioinen and colleagues; the others are our choices and the manuscript now says so.
