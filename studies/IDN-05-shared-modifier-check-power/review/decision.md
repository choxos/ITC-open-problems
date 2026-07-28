**Accept, with the conclusions narrowed and three limitations that bound what the study
establishes.**

Round one: Sol `major-revision` with `conclusions_supported: false`, GLM `accept`, Kimi an empty
response. Round two, on the revision: Sol `major-revision` with `conclusions_supported: false`,
Kimi `minor-revision` with `conclusions_supported: false`, GLM `minor-revision` with
`conclusions_supported: true`. Kimi's round-one report arrived late, after round two had been
sent, and returned `major-revision`; it is published here and answered in the round-two
response even though it could not inform revision one.

Across the two rounds the reviewers were right about more than they could have known, and the
decision rests on what they found rather than on the arithmetic of recommendations.

## What review established

**Two errors in the study's own code**, both derived by reviewers from published numbers alone,
without access to the source.

The first: contraction was divided by the standard deviation of the main design's prior in every
arm, including a prior-sensitivity arm fitted under a different prior. A reviewer noticed that
the published figures had to be measured against the wrong denominator and supplied the argument
that settles it, that tightening a prior cannot raise
$1 - \mathrm{sd}(\text{post})/\mathrm{sd}(\text{prior})$. The direction of a published result was
inverted. It is fixed at source, and repaired exactly for the existing fits from stored
quantities.

The second: the primary bound, the number the whole registered gate turns on, was a Wilson
interval on the unweighted risk printed beside a deployment-weighted point estimate. A reviewer
observed that the published bound could not be reconstructed from the published sample size. The
corrected weighted bound is 0.697 rather than 0.777; the verdict is unchanged and fails by a
factor of about seven either way.

**A manuscript that shipped to three reviewers with two literal blanks.** A zero-row lookup
rendered as an empty string, silently, and the sentences that depended on it were published
without their numbers. Two reviewers reported it independently. The response to round one had
asserted the missing figure from a hand calculation without checking the page.

**An undisclosed departure from registration.** The prior-sensitivity arm ran at 30 replicates
per cell against the 100 registered. It was found because a reviewer asked how a published fit
count followed from the registered design, and it did not. This is the second undisclosed
departure in this study; the first was found the same way, in round one.

**A prespecified analysis computed and then dropped.** The AUROC scoring of the continuous
statistics was registered, computed from the first run, and omitted from two drafts while its
methodological citation remained. All three reviewers asked for it. It is now the strongest
result in the paper and the only one that depends on no threshold of ours.

**Several claims the data contradicted.** That the credible interval keeps nominal coverage,
against the study's own type I error. That check-then-relax has the lowest error at every
displacement, against the study's own RMSE column. That the reported failures are lower bounds
in general. Each is corrected to what was measured.

## Why this is accepted rather than rejected

None of the defects is in the design, and both reviewers who withheld support said so
explicitly. The mechanism is not rigged: the drift parameter *is* the estimand the check
targets, and the margin is derived from a decision threshold rather than tuned. The estimand
discipline on the decision scale is sound. The oracle comparison, which shows a perfect check
would also have failed the registered gate, is the right way to report a failed gate and is
retained.

The corrections moved numbers and narrowed claims. They did not reverse a conclusion. Detection
of a violation twice the size that matters remains 0.045 [0.029, 0.070] against 0.013 [0.005,
0.029] under the null; the threshold-free AUROC at that violation is 0.557 [0.517, 0.596]; the
equivalence reading still never fires; the registered gate still fails.

## What this study does not establish, after two rounds

Three requests are not met, and they bound the result.

**Numerical convergence of the likelihood integration is unestablished.** Changing the
quadrature grid from 64 to 256 points flips the DIC verdict in 8.3% of a 24-network subset, and
256 points is not shown to be converged. A difference between two unconverged grids is not a
bound on the error of either. Since the headline detection difference is about three percentage
points, this is a limitation on the primary result and not a footnote to it. Resolving it needs
a new arm at successively finer grids.

**Fits that failed their diagnostics remain in the main analysis.** Retaining them is defensible
and the converged-subset analysis shows the strategy ranking does not depend on them, but a DIC
computed from a chain with $\hat R$ of 5.13 is not a usable quantity, and the reviewer is right
that a sensitivity analysis does not make it one.

**The partial-pooling comparator is missing.** An exchangeable interaction structure is the
strategy an analyst would most want and the one this catalog entry proposed. The package does
not implement it and we did not write it. The recommendation is therefore scoped to the best of
three options.

## A note on the process, which is part of the record

Revision two was not sent back to the reviewers. The program runs two rounds, and this decision
is made on a revision that changed two code paths and several published numbers without a
reviewer seeing the result. That is a real weakness of a two-round protocol when the second
round finds bugs rather than overstatements, and it is recorded here rather than left implicit.

Three defects in revision two were found by checking the reviewers' arithmetic rather than by
the reviewers: the worst reported $\hat R$ was the worst of one model rather than of any model,
the paired strategy comparison was unweighted while the table beside it was weighted, and
`study.json`, which feeds the public catalog page, still carried the title retracted in round
one along with three withdrawn claims. That last one is the fifth occurrence in this program of
a published artifact carrying a claim the analysis no longer supports, and the first time the
artifact was one no checker covered. It is covered now.

The lesson this study forces is narrower than "check more carefully". Every one of the
structural fixes works by removing a place where a human number could enter: the decision record
is generated, the render is scanned for values that vanished, the lookup that returned nothing
now raises, and the arm composition is written by the analysis rather than derived in prose.
