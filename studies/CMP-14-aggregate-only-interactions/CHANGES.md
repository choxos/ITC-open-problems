# CMP-14: what changed, when, and why

**This file is the change history. `protocol.md` is what is registered now.**

They were one document until the fifth round of critique, and separating them is a
fix rather than tidying. Two independent reviewers returned 45 findings between
them and **60% turned on an internal inconsistency or a label that contradicted the
value beside it**: a claim withdrawn in one section and still standing in another, a
threshold called registered where the registration block said otherwise, a control
whose words promised more than its code tested. Those were not separate defects.
They were one defect, which is that the protocol had been rewritten in five layers
and each layer left part of the previous one in place.

Nothing here is deleted. Every disclosure, every withdrawn claim and every
measurement that overturned an earlier one is below, and `protocol.md` states the
current position once.

---

## The reviewers, and what they were

Five rounds of adversarial pre-run critique. **Rounds 1 to 4 used one reviewer**
(GPT-5.6 Sol) because the other two were unavailable: `opencode/kimi-k3` had reached
its weekly quota and Grok returned HTTP 402. **Round 5 was the first independent
review**, and it matters what it showed.

| round | reviewer | verdict | fatal | serious |
|---|---|---|---:|---:|
| 1 | codex | unsound | 8 | 4 |
| 2 | codex | unsound | 7 | 5 |
| 3 | codex | unsound | 6 | 5 |
| 4 | codex | unsound | 5 | 5 |
| 5 | codex | unsound | 9 | 7 |
| 5 | grok | needs-revision | 11 | 13 |

**Seven topics were raised independently by both reviewers in round 5**: the
equal-SD guard's hidden baseline restriction, the source statistic not being a
contribution share, primary 2's arm-size against patient-budget contradiction,
primary 1's stale counts and grid weighting, the fourth control testing existence
rather than what its words promised, the provenance claim being incomplete, and E2
contradicting itself about which conditions fired. Several of those had already
been "fixed" in an earlier round, so two independent readers saw through the same
cosmetic repairs.

Grok also found what four rounds of a single reviewer had not: that `eff_rank` is
two statistics carrying one registered threshold, that section 2's Gaussian
identity model cannot be the model E2 uses, and arithmetic that does not reproduce.

## A reviewer that fails is not a reviewer that agrees

Grok returned 200 to 300 bytes on every part at every size tried, and it was read as
a quota problem. Captured directly, the reply was a planning preamble, *"I'll review
the full pre-registration against the code and export it claims to match..."*, and
then nothing: `--permission-mode plan` put it in a mode where it announces intent
and then wants to read files it had not been given. Dropping plan mode and adding an
explicit no-tools instruction produced 28 findings. The driver records every
unobtained part as **NOT OBTAINED** and never as agreement, which is what kept four
rounds honest about resting on one reviewer.

## A fix applied in one place and asserted everywhere

Round 4 established that every information state must have the same arm count,
and gave the reason: with ten arms in one state and twelve in another, an equal
patient budget hands the SHARED BACKGROUND studies different per-arm sizes, so a
state comparison changes the background network as well as the target's evidence
route. That is not the comparison primary 2 is registered as.

**The fix was made in `build_state` and never reached `build_state_nl`.** The
`curvature` state kept two-arm target studies, so it ran at ten arms and 300
patients per arm while every other state ran at twelve and 250, and the protocol
said in plain words that they matched. It survived rounds 4 and 5 and was found in
round 6 **by both reviewers independently**, which is what convergence is for.

Three things follow and only one of them is the arm count.

- **The geometry is now computed.** `R/06-nonlinear.R` builds every state, prints
  the arm count and per-arm size, and **stops the run** if they differ. The claim
  that made it through five rounds was prose; nothing had ever evaluated it.
- **The repair broke something downstream and the warning nearly hid it.**
  `R/08-routes.R` assigned aggregate covariate means with `rep(c(0.1, mu2), each =
  2)`, which assumed two arms per aggregate study. With three, R recycled four
  values into six slots, warned, and **the route table's four assertions still
  passed** against a network whose two studies no longer had cleanly different
  means. Means are now assigned by study identity, and the count is asserted. **A
  warning is not a failure, and every guard in this study would have kept
  certifying the wrong network.**
- **The route table is unchanged**, recomputed on the corrected geometry: mean
  identifies on both links, variance and baseline on the logit link only, none on
  neither. So the arm-count defect did not reach the taxonomy, which is worth
  recording because it easily could have.

The second reviewer's version of the same finding was arithmetic rather than
structural: twelve equal arms at budgets of 1000 and 10000 give $83.\overline{3}$
and $833.\overline{3}$ per arm, which are not patient counts. **That one is
answered by saying what the code does rather than by changing it.** Nothing here
simulates individuals; every quantity is an exact Fisher information with $n$ as a
weight, so a non-integer $n$ is a legitimate information scale and rounding would
put an artifact into an exact computation for nothing. The protocol now says so.

## A wrong label, an admission, and a guard that was enforcing the label

The protocol said two things about E2's contraction. **"Contraction of a Laplace
approximation"** was a wrong label: `evaluate_e2` forms
$(I(\theta_{\text{true}}) + P_0)^{-1}$, the expected Fisher information at the
**true parameter**, while a Laplace covariance inverts the Hessian of the log
posterior at the **mode**. The two agree when the information is parameter-free,
which holds on an identity link and fails on the logit link E2 uses, and when the
mode equals the truth, which a proper prior centred at zero rules out.

**The code is right and the label was wrong.** E2 is an exact information
calculation with no data and no sampling, so evaluating at the truth is
deterministic and is a property of the design; a Laplace covariance would make
the diagnostic depend on where the prior pulls the mode, which is the prior's
behaviour rather than the design's. So the label changed, not the computation.

The second sentence was **"the gap is bounded by nothing measured here"**, which
is an admission that can be deleted by measuring it. `R/09-contraction-gap.R`
solves $U(\theta;\,\mathbb{E}[y \mid \theta_{\text{true}}]) = P_0\theta$ by Newton
iteration and recomputes the contraction at that mode. Across the 44 correctly
specified E2 scenarios the **maximum absolute difference is 0.0351, the median is
0.00093, and the maximum relative difference is 4.73%**. `displacement()` could
not be reused, because it recomputes the true proportions at whatever $\theta$ it
is handed and therefore returns zero; the score had to separate the
data-generating parameter from the evaluation parameter.

**And the verifier was enforcing the mislabel.** One of its assertions required
the protocol to *contain the phrase* "contraction of a Laplace approximation", so
correcting the document failed the check and the failure read as a regression. **A
guard that pins a wrong description in place is worse than no guard**, and it is
the second in this study to behave that way, after the equal-SD guard that kept
certifying a mechanism under a restriction nobody had registered. The assertion now
requires the approximation to be *named*, and separate assertions check that the
name is the right one and that neither the mislabel nor the admission has returned.

## Three numbers that went stale, and what finally stopped it

Rounds 2, 4 and 5 each found a printed number that no longer followed from the code.
Each time the repair was to retype it, which is the operation that produces
staleness. The sequence ended only when the numbers stopped being prose: they are
emitted from the export by `review/emit-tables.py` and asserted back by
`review/verify-protocol.py`, independently, so the document and the code cannot
disagree without the verifier failing.

Two further guards came out of the same class:

- **`R/05-export.R` refuses to export** when any artifact is older than the newest
  file in `R/`. On its first run it caught six stale artifacts, not the two round 5
  found, including all three groundwork probes.
- **`review/verify-protocol.py` refuses to run** when the export is older than the
  code. Without that, the exporter stopping on an error leaves the previous export
  in place and the verifier passes against it, which happened immediately: a clean
  125/125 printed against an export the exporter had just declined to refresh.

---

## Every design choice changed after seeing a number

Recorded because E1 was computed before this document existed, and a disclosure list is the
only thing that makes an exploratory exact computation interpretable. Round 1 found the first
version of this list incomplete; it now covers changes made both before and after that review.

| change | why | what it would have hidden |
|---|---|---|
| Added `PRIOR_SD = 0.1` | The first grid had the absent state covering the truth 100% of the time: the likelihood contributes nothing, the posterior is the prior, and a wide prior still contains a truth 0.40 away. The diagnostics' positive control was never a failure | It scored a correct warning as a false alarm, making every diagnostic look worse than it is |
| Null-control guard restricted to `prior_sd >= 0.5` | The first version required nominal coverage whenever discordance and synergy are zero, and it failed in 54 scenarios, all at the tight prior. That is the tight prior doing what it was added to do | It would have conflated a prior-induced failure with a confounding-induced one |
| Prior-domination control restated at the smallest budget | The first version asserted collapse at the tight prior in every state; measured, coverage recovers to 0.938, 0.875 and 0.798 at the largest budget as the likelihood wins. **Round 2 found the figures previously printed here, "0.94, 0.84 and 0.80", stale from before the patient budget was equalized, and no scenario rounded to 0.84** | It would have asserted a false claim about the tight prior's reach |
| **Round 1:** total patients equalized across states | Every arm had been given the same size, so `additivity` with twelve arms ran on 20% more data than the others' ten, while both the code and this document claimed the totals were equal | A difference of sample size reported as a difference of evidence structure |
| **Round 1:** interaction prior separated from nuisance priors | One scale had been applied to every coordinate, including study intercepts and main effects whose true values are nonzero | A result attributed to the registered prior factor that was really nuisance shrinkage |
| **Round 1:** null control restated as "no undercoverage" | Tested two-sided as its name promised, it failed: five scenarios overcover at 0.962 to 0.986. All five are `ecological` at the smallest spread where the posterior SD exceeds the sampling SD of its centre, which is ordinary shrinkage | A conservative interval counted as a violation, or the threshold widened until it passed |
| **Round 1:** "alike" withdrawn from the prior-domination control | The tight prior's mean bias runs $-0.114$, $-0.177$ and $-0.278$ across states, a spread of 0.165 against a truth of 0.40 | A claim of uniformity the numbers do not support |
| **Round 1:** primary 1 compares failures with *nominal* scenarios | It had compared them with merely non-failing ones, so an overlap could rest on a scenario covering at 0.91 | An overlap claim resting on scenarios that are not good either |
| **Round 1:** whole-model effective rank added to the outcomes | It was computed and never analyzed, so one of the two summaries CMP-14 asks for appeared in no reported outcome | The study answering only half the question it was written for |
| **Pre-protocol:** IPD fraction dropped as a design factor | `DESIGN.md`, written after three numerical probes, listed it; the grid varies the target's information state instead, which subsumes it for one target component | A factor considered and dropped after probes had been read |
| **Pre-protocol:** per-component states replaced by one target component | `DESIGN.md` proposed varying every component's state; the design holds components 1, 2 and 4 fixed so the target's behavior is not confounded with a globally weak network | The same |
| **Pre-protocol:** AUC dropped as the primary outcome | `DESIGN.md` proposed it; an AUC over a chosen grid reports the grid's shape, so primary 1 became a weighting-free existence claim | An outcome definition changed after probes had been read |
| **Pre-protocol:** target-population contrast dropped from the estimand | `DESIGN.md` listed it alongside the conditional interaction; only the conditional one is registered, and section 9 says so | A second estimand quietly removed |
| **Round 2:** source-share made three-way | The two-way version scored `curvature` and `ecological` at zero by construction, so the registered falsifier could not fire and E2's agreement between them was arithmetic | A safeguard that cannot fail, and a reported finding that was not one |
| **Round 2:** the 0.01 coverage slack registered as `COVER_TOL` | `NOMINAL - 0.01` was written into four files as though it were nominal, while the null minimum is 0.9474 and the document claimed nothing covers below nominal | A threshold moving by a hidden hundredth wherever convenient |
| **Round 1:** curvature state redesigned and E2 implemented | The state was rank deficient as specified, and none of E2 existed while the document claimed its operating rules were registered | A confirmatory arm that could not be run and whose central state identified nothing |
| **Round 3:** every precision made prior-free | Each source's "likelihood precision" was the posterior marginal precision minus the prior's diagonal, so a source identifying nothing still scored positive. In the curvature state's aggregate rows it returned 0.2275 and 0.0072 for quantities whose prior-free value is exactly zero | The ratio of two prior artifacts, 0.933 to 0.969, reported as this study's headline decomposition |
| **Round 3:** source share made leave-one-source-out | Decomposing a parameter's marginal precision by source presumes each source identifies it alone, which is false in the curvature state | A decomposition that was not one, for the second time |
| **Round 3:** E2 coverage scoped to correctly specified scenarios | Under misspecification the score variance is not the model Fisher information and the aggregate Hessian is not either; one curvature scenario recomputed correctly moves from 0.9400 to 0.6898 | Coverage figures, failure labels and every rule conditioned on them, all invalid |
| **Round 3:** the withdrawal rule rebuilt | It checked two of the three diagnostics, on a coverage-filtered subset, with equal-SD curvature rows included | A registered separation occurring without triggering withdrawal |
| **Round 3:** nominal made two-sided | A scenario covering at 1.000 counted as nominal, so gross overcoverage sat on the good side of primary 1 | 76 over-covering scenarios treated as successes |
| **Round 3:** the fourth control made a group property | It tested only that one scenario of each kind exists, while its words promise "essentially always" | A control carried by a single conforming scenario |

**Seven of these are guards that were written from expectation, failed, and were changed**, counting the smoke test's own first assertion, which required the interaction prior to leave every nuisance posterior variance untouched and was wrong because the information matrix couples the coordinates. That
sequence is exactly how a control becomes decorative, so each restatement above says what the
control now tests rather than only that it passes, and `review/verify-protocol.py` asserts each
one against the values that made it pass.

**Round 1 was a single reviewer.** GPT-5.6 Sol returned `unsound` with eight fatal and four
serious findings, every one of which is addressed above or in section 7. The two other
reviewers this programme uses were unavailable: `opencode/kimi-k3` had reached its weekly quota
and Grok returned HTTP 402, usage balance exhausted. Both are recorded as **not obtained** and
neither is counted as agreement. A second round with a second reviewer is required before this
protocol is treated as having cleared critique.

