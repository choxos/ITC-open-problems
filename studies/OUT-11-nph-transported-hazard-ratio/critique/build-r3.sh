#!/bin/zsh
## Assemble the round-three critique payload. Kept small on purpose: the second
## reviewer returned 0 bytes on a 79.5 KB payload twice, and succeeded at 37.9 KB.
## The verbatim round-two reports are therefore summarised rather than pasted.
cd "$(dirname "$0")/.."
OUT=critique/design-for-critique-r3.md

{
  sed -n '/^# THE OPEN PROBLEM/,/^# THIS IS ROUND TWO/p' critique/design-for-critique-r2-short.md \
    | sed '$d'

  cat <<'HDR'
# THIS IS ROUND THREE OF PRE-RUN CRITIQUE

You are reviewing a protocol revised twice. Round one returned `unsound` and
`needs-revision`. Round two returned `unsound` again with three fatal findings,
and `needs-revision` with four serious ones. Nothing has been simulated yet.

Every round-two fatal was checked against the protocol text before being
accepted, and all three were confirmed. The revision is a substantial rebuild,
not a patch: the network changed from four studies to two, the decision rule
changed from a bias tolerance to an excess-recommendation-error rate, the
data-generating mechanism is now numerically locked, the integration order is
measured rather than cited, and the flexible ML-NMR estimator was replaced after
implementation showed the registered one cannot produce the study's estimand.

Because the revision is large, judge it primarily ON ITS OWN TERMS. Round-two
findings and their claimed resolutions are listed compactly below; check the
protocol text against each claim, since claiming a fix the text does not contain
is the failure mode this round exists to catch. Add `round2_resolution` to your
JSON: a list of {"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Pay particular attention to material that is NEW in this version and has never
been critiqued: the two-study network, the shared transport rule on the
log-cumulative-hazard scale, the excess-recommendation-error decision rule and
its noise floor, the solved beta_B, and the aux_regression finding.

## Round-two findings and claimed resolutions

### Reviewer one, verdict `unsound`

FATAL. Censoring absent from the cell matrix, replicate total and runtime, while
four regimes appeared throughout the analysis sections.
CLAIMED FIX: confirmed; regimes assigned to experiments explicitly, four in the
analytic and cheap-simulation experiments and two in the benchmark; matrix,
replicate total and runtime recomputed.

FATAL. The data-generating mechanism is not numerically locked: beta, gamma per
treatment, a0, xi, study baselines, study means, sample sizes, allocation and
censoring rates all unset. No crossing times or PH-test power at retained levels.
CLAIMED FIX: confirmed; every parameter registered in R/00-config.R and
transcribed into the protocol; crossing times, PH-test power, event fractions and
at-risk fractions computed and tabulated per cell.

FATAL. A 0.5-month reimbursement threshold does not justify a 0.5-month bias
tolerance. True gains were 1.155, 1.817, 2.359 against a 0.5 boundary, so every
cell sat 0.65 to 1.86 clear of it and no tolerated error could change a
recommendation. Also, absolute value of a pooled signed bias permits cancellation.
CLAIMED FIX: confirmed against version two's own numbers; beta_B is now solved so
cells straddle the boundary; the rule is excess recommendation error over a
computed noise floor; weighted mean absolute cell bias replaces absolute pooled
bias.

FATAL. Pairwise MAIC and STC cannot consume three aggregate studies, so "every
method uses the same studies" was asserted, not implemented.
CLAIMED FIX: confirmed; network reduced to two studies so the claim is true.

SERIOUS, condensed. PH-versus-flexible columns changed likelihood and basis as
well as proportionality; equal knot counts do not equate Royston-Parmar and
M-spline flexibility; superpopulation estimand versus MAIC's realized-sample
target; no time-indexed calibration outcome; coverage unresolvable at the stated
budget with no inconclusive region; the four-regime statistic underspecified; no
priors, prior sensitivity, bootstrap interval type or resampling unit; R-hat alone
is not a sampler policy; the integration citation argues against the choice it
justified; runtime omitted censoring regimes and bootstrap; the two sources of
censoring dependence were called exactly separable when the least-false root is
nonlinear; "Study 5" unidentified; the one-step equivalence claim unestablished;
the title overstates a partial benchmark.
CLAIMED FIXES: all addressed in the protocol below; see its section 13 table.

### Reviewer two, verdict `needs-revision`

SERIOUS. The column-effect claim is false for the MAIC and STC rows, and the
protocol both asserts and disavows it.
CLAIMED FIX: rows rebuilt on one basis each, toggling only treatment-by-time
terms; weighted Cox retained as a separately labelled row outside the factorial.

SERIOUS. The rule by which MAIC and STC turn three aggregate studies into one
target estimate is unspecified, and naive pooling mixes populations when gamma
is nonzero.
CLAIMED FIX: dissolved by the two-study network; the transport rule is now
written out explicitly and is shared by all frequentist rows.

SERIOUS. No scenario produces an in-window hazard crossing, although the entry
asks for crossing hazards; the marginal HR spans 0.32 to 0.84 and crosses 1 only
beyond the administrative cutoff.
CLAIMED FIX: confirmed against version two; resolved as a side effect of solving
beta_B down to a decision-relevant margin. Marginal hazard ratios now cross 1 at
8, 13 and 14 months; conditional crossings at 6.2 to 14.4 months.

SERIOUS. The 500-resample full-pipeline bootstrap is plausibly the dominant cost
and was called "cheap" without measurement.
CLAIMED FIX: confirmed, and it is. Measured at 0.658 s per resample, which is
several times the Stan cost; the runtime is recomputed from the measurement.

MINOR, condensed. "Study 5" still cited despite the change log claiming removal;
comparator authorship uncited; "nobody appears to have quantified it" overclaims
against Hernan 2010, Aalen Cook and Roysland 2015, and Stensrud and Hernan 2020;
gamma's role ambiguous; D1 pooling ambiguous; priors and interval types
unspecified; ESS and divergences absent from the recording policy.
CLAIMED FIXES: all addressed; six comparator attributions added and verified, the
novelty claim narrowed against the named literature, gamma stated as shared.

# THE REVISED PROTOCOL (version three)

HDR

  cat protocol.md

  cat <<'TAIL'

# LOCKED CONFIGURATION, VERBATIM

The protocol's parameter table is a transcription of this file, which the run
sources. It is included so the transcription can be checked.

TAIL
  echo '```r'
  cat R/00-config.R
  echo '```'

  cat <<'TAIL2'

# THE SHARED TRANSPORT RULE AND THE FREQUENTIST ESTIMATORS, VERBATIM

TAIL2
  echo '```r'
  sed -n '/^## --- MAIC weights/,$p' R/03-estimators.R
  echo '```'
} > $OUT

echo "payload: $(wc -c < $OUT) bytes"
