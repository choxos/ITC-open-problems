# Round four: what was found, what was confirmed, what it cost

Two reviews were obtained. A third returned zero bytes at every payload size
attempted, including sizes that had succeeded in earlier rounds, and is recorded
here as **not obtained** rather than counted as agreement.

| reviewer | verdict | findings |
|---|---|---|
| GPT-5.6 Sol, max effort, whole protocol | `unsound` | 7 fatal |
| Kimi K3, second half | `unsound` | 2 fatal, 4 serious, 1 limitation, 1 minor |
| Kimi K3, first half | not obtained | returned 0 bytes at 105, 79.5, 61, 49.7 and 37.4 KB |

The Kimi payload ceiling is not a stable size. It succeeded at 37.9 KB in round
three and failed at 37.4 KB in round four, so the working assumption is now that
any payload above roughly 25 KB is unreliable and round five splits into three.

## The finding that changed the science

**E1 and E2 measured the wrong quantity.** Both evaluated `cox_limit(A, B)`, the
least-false coefficient a direct head-to-head trial of B against A would report.
OUT-11 concerns a **transported anchored indirect** comparison, assembled from a
separate A-versus-placebo study and a separate B-versus-placebo study.

These are different numbers, and not by sampling noise. Least-false Cox
coefficients are **not transitive** under non-proportional hazards: each leg is a
censoring- and event-weighted average of its own time-varying contrast, weighted
by its own risk sets, and the difference of two such averages is not the average
a direct comparison produces.

Version 4 had defended the head-to-head framing explicitly, in a passage written
in response to round three asking for the comparison to be stated precisely. The
defense was wrong.

Measured after the rebuild:

- The anchored and direct values differ by **0.93% to 1.78%**, and the gap
  itself varies with censoring, so it is not an offset that cancels from a
  spread.
- The rebuild also added what version 4 could not express: the two studies'
  censoring regimes **crossed independently**, rather than a single shared
  censoring survival. Differential follow-up between the two trials is the case
  the catalog entry names.
- **D3 moves from 0.697 (pass) to 1.4332 (fail)** against its 0.50-month
  tolerance.
- On the $\kappa_A = \kappa_B = 0.30$ cell, matched follow-up moves D3 by
  **0.0312** months and crossed follow-up by **1.4332**, a factor of **46**,
  because when both legs are followed alike their movements largely cancel in
  the Bucher difference. Version 4's design would have reported that cell among
  the safest in the study.

The leg decomposition is exact and confirms the mechanism rather than assuming
it: leg A's censoring spread is 0.62% in every cell with $\kappa_A = 0$
regardless of $\kappa_B$, and 17.27% in both cells with $\kappa_A = 0.30$.

E2, rebuilt on the same quantity, then **validated E1 independently**: over 96
regime pairs the worst discrepancy between simulation and the analytic limit is
0.0112 on the log scale, and the Bucher interval covers the E1 limit 0.939 to
0.956 of the time against a nominal 0.95.

## Three findings were defects introduced while fixing round three

This is the specific failure the round exists to catch, and it happened three
times.

**1. The pilot table carried pre-fix numbers.** Round three found that STC never
applied its Gauss-Hermite weights; the code was fixed and the pilot rerun. But
section 10.3's table still printed the **old** STC-PH and STC-flex columns:
twelve values produced by deleted code. Every STC-flex entry had the wrong sign,
published near $+0.15$ against a measured $-0.05$.

Worse, one of the three findings drawn from that table did not survive
correction. Version 4 reported that STC-PH's bias at $\kappa_B = 0.15$ was
$-0.028$, that its non-collapsibility and non-proportionality biases cancelled
there, and that a design with a single non-proportionality level would have
crowned it the best estimator in the study. The corrected value is $-0.176$.
**There is no cancellation and the finding does not exist.**

The non-collapsibility mechanism itself survives at $+0.186$ and $+0.198$ against
$+0.021$ in the $\gamma = 0$ control, which is less than half what version 4
registered. The mechanism is real; the number was not.

**2. D1 was declared replaced and kept registering verdicts.** Round three killed
the excess-over-own-variance decision metric because the floor uses the
estimator's own realized standard deviation, so inflating variance drives the
excess to zero. Version 4's change log recorded it as replaced. Section 10.2
still carried the rule verbatim, still called it "the primary outcome" in direct
contradiction of sections 10.0 and 10.1, still gated verdicts on the 0.10 and
0.20 cutoffs, and still repeated the one-directional gaming claim that had
already been conceded. **Both reviewers found this independently.**

**3. Replicate and resample counts contradicted across sections.** Sections 8 and
9 said 40 replicates and 560 total while section 14 said 25 and 350; section 7
said 500 bootstrap resamples while section 14 said 250.

All three are the same mechanism: an edit applied in one place and not another,
in a document long enough that rereading does not catch it. The response is in
`review/verify-protocol.py`, which grew from 40 assertions to 109 and now parses
whole tables cell by cell instead of spot-checking scalars.

## Budget arithmetic, wrong twice

**The bootstrap line was wrong by roughly eightfold.** Kimi computed
$250 \times 350 \times 0.658\,\text{s} \approx 16$ hours against a claimed 2.0
hours. Direct measurement showed the unit cost was **also** wrong: 0.711 s per
resample, not 0.658 s, and the superseded "6.4 h" figure implied about 62
resamples per replicate rather than 500.

**The Stan line was internally impossible.** It claimed 227 s for both ML-NMR
arms of a replicate while the same table measured 296.2 s for a single flexible
fit at the production integration order. The 227 s figure came from dividing a
wall clock by a concurrency assumption that was never checked.

**The 256-point sensitivity arm was costed at 128-point prices**, understating it
about 2.6-fold.

This is the second round in which a hand-written budget total failed to follow
from the unit costs printed beside it. The response is `R/10-budget.R`, which
computes every line from timings measured by `R/11-measure-production.R`, and
verifier assertions that the protocol's budget table matches.

## The fair-comparison objection, answered by measurement

Sol's objection: scoring MAIC through a marginal log-cumulative-hazard graft the
protocol itself calls invalid, while STC gets a valid conditional transport,
cannot support a method-family comparison.

The objection is legitimate. It is answered by sizing the graft rather than
arguing about it, and the structural error turns out to be **exactly computable
with no simulation** (`R/05b-graft-error.R`). Give MAIC perfect weighting and
perfect estimation so only the graft remains:

- **MAIC's graft costs at most 0.0116 months** of RMST, which is 1.6% of
  MAIC-PH's measured 0.725-month pilot bias and 2% of the decision threshold.
- It is **exactly zero when $\gamma = 0$** ($\sim 10^{-15}$), confirming the
  covariate effect is its only driver.
- **STC's conditional transport is exact to machine precision** in every cell,
  which the protocol previously asserted and now checks.

So the objection does not bite on this design: the across-row differences cannot
be attributed to the graft, which is two orders of magnitude too small to
produce them.

## The withdrawn premise still gating a primary contrast

Kimi found that section 10.1 registered "method family across rows at matched
flexibility" as a **primary** paired comparison, while the same document's round-2
resolution table recorded that the matched-flexibility claim had been
**withdrawn**, because equal knot counts do not equate Royston-Parmar and
M-spline flexibility. A registered primary contrast cannot rest on a premise the
protocol retracted.

Those three contrasts are now descriptive, and the effective degrees of freedom
of each fitted survival model is recorded per replicate so the paper can report
the flexibility gap rather than assume it away.

## What the reviewers agreed was sound

Both reviews independently praised the integration-order measurement as the
best-evidenced part of the protocol: paired within replicate, an honest $t = 1.0$
for 256 against 128, an explicit statement that absolute biases below roughly
0.05 months cannot be distinguished from integration error, and a reportable
finding that `multinma`'s default `n_int = 64L` is biased by 0.066 months for
this estimand.

Also accepted as sound: the scoping in section 12b that OUT-11 remains open after
this study; the coherent target-population estimand with truth by converged
quadrature; the `ipd-nph` cell with a proportional target contrast built from two
strongly non-proportional arms; making estimation quality primary and paired
after measurement showed decision metrics collapse at these sample sizes; and
recording sampler failures rather than dropping them.

## Consequences for the run

The instruction that arrived during this round was to prioritize robustness over
schedule. Combined with the corrected arithmetic, that reversed the version-4
budget cuts:

| | version 4 | version 5 |
|---|---:|---:|
| replicates per cell | 25 | **40** |
| bootstrap resamples | 250 | **500** |
| P(coverage rule certifies a calibrated estimator) | 0.733 | **0.953** |

The last row is the concrete cost of the cut version 4 made, and it is larger
than that version recorded.
