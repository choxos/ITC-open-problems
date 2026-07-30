# CMP-14: what changed, when, and why

**This file is the change history. `protocol.md` is what is registered now.**

They were one document until the fifth round of critique, and separating them is a
fix rather than tidying. Six rounds of critique returned **107 fatal and serious findings** between two
reviewers, counted as the table below counts them: findings **as returned**, so a defect
found again in a later round is counted again, and the minor findings are not in that
total. **It is not a count of distinct defects and no such count is claimed.** An earlier
version of this paragraph said "45 findings" and "60% turned on an internal
inconsistency"; the first reconciled with nothing in the table and the second was never
computed. What the table does support is that **the largest single category is a claim
withdrawn in one section and still standing in another**: a claim withdrawn in one section and still standing in another, a
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
| 6 | codex | unsound | 6 | 5 |
| 6 | grok | needs-revision | 8 | 3 |

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

## The misspecification that was never there

Round 3 found E2's coverage calculation invalid wherever discordance or synergy
acted, and its algebra was right: under misspecification the score variance is not
the model Fisher information, and for an aggregate arm the expected Hessian is not
either. Coverage was suppressed in 28 of 72 scenarios. **Round 6 found the premise
false.** Neither departure is misspecification.

Discordance adds its amount to the target modification in the *aggregate* rows
carrying the target, and in `ecological` and `curvature` the target appears in no
other row. Synergy adds its amount to arms holding components 1 and 3 together,
and in `additivity` the target appears in no other arm. Every row a departure
touches carries the target, and every target-bearing row is touched, so one
shifted coefficient reproduces the truth exactly. Measured pointwise in the
covariate across the grid, the worst gap is **2.22e-16** on E2 and **1.78e-15** on
E1. The model is correct; the **estimand** is aliased.

**That is a stronger result than the one it replaced, and it is the thesis.** An
aggregate-only route does not produce a wrong-looking answer. It produces a
correctly sized interval around a different quantity, which is worse, and which is
exactly what CMP-14 asks whether the summaries can detect. The restriction had
removed precisely the scenarios the study exists to examine, and it left primaries
2 and 3 uncomputable on E2, which is the second reviewer's finding by a different
route.

Three things follow that were not free. **The 28 restored scenarios are where the
two contraction approximations differ most**, because the shift moves $\theta^{*}$
further from the prior center, so the measured Laplace gap rose from 0.0351 to
**0.0882** absolute and from 4.73% to **14.64%** relative. Keeping the restriction
would have meant reporting the smaller number by excluding the worst cases.
**Everything is now evaluated at $\theta^{*}$**, including the information, which
on a curved link depends on the parameter, so the diagnostics move with the shift.
And **the aliasing is asserted per scenario rather than argued**: a state whose
departure touched only some target-bearing rows would stop the run.

**A third guard was enforcing the withdrawn claim.** `verify-protocol.py` required
the protocol to contain "only where the model is correctly specified", so
correcting the document failed the check. That is the same failure as the Laplace
label and the equal-SD restriction before it, and the pattern is now explicit:
**an assertion written as "the document says X" survives the discovery that X is
wrong, and reports the correction as a regression.** Assertions here now check a
computed value or a named property wherever one exists.

## A prevalence that is true nowhere, and why it was not just a word

The protocol said E2's **placebo arms sit at prevalence 0.3**. The code sets
$\alpha_s = \operatorname{logit}(0.3)$, which fixes the **conditional** risk at
$x = 0$. On a curved link the arm-level value is the covariate distribution
integrated through $\operatorname{expit}$, so it varies with each study's
covariate mean and SD, runs from **0.2913 to 0.3291** across the registered
states, and equals 0.3 in none of them.

That much is a labelling error. **The consequence is not.** The `curvature`
state's registered restriction is *equal target-study baselines*, and its two
target studies share an intercept while differing in covariate SD, so their
placebo arm prevalences are **0.3099 and 0.3194**. Read as prevalence, the state
violates the restriction its own non-identifiability claim depends on; read as
the intercept, which is what the rank calculation actually uses, it holds. The
restriction was stated in the ambiguous word for four rounds. `R/07-run-e2.R`
now computes both readings and stops the run if any arm hits 0.3 exactly, if the
intercepts stop being equal, or if the two prevalences stop differing, which is
the condition under which the distinction would no longer be worth drawing.

**The verifier's first version of this guard was the wrong shape**, for the third
time in this study. It asserted the withdrawn phrase was *absent*, which failed
on the sentence that withdraws it. The guard now requires the phrase to appear
exactly once and only inside that sentence, so reinstating the claim still fails
while admitting it does not.

**And every one of these numbers was typed.** They were correct, and they were
still a violation of the rule that produced this document's provenance section:
`R/05-export.R` now emits `pbo_prev_min`, `pbo_prev_max` and `curv_pbo_prev`, and
the assertions compare the document against those rather than against literals.
Two further assertions check the export against itself, that the curvature pair
lies inside the reported range and that no arm sits at `E2_BASE_P`, because a
guard reading numbers from the same file it is defending needs at least one claim
that is not a string comparison.

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
| Prior-domination control restated at the smallest budget | The first version asserted collapse at the tight prior in every state; measured, coverage recovers to 0.938 in `additivity`, 0.735 in `ecological` and 0.725 in `own_ipd` at the largest budget as the likelihood wins. **Round 6 found 0.875 and 0.798 printed here, stale from before the arm-geometry fix** **Round 2 found the figures previously printed here, "0.94, 0.84 and 0.80", stale from before the patient budget was equalized, and no scenario rounded to 0.84** | It would have asserted a false claim about the tight prior's reach |
| **Round 1:** total patients equalized across states | Every arm had been given the same size, so `additivity` with twelve arms ran on 20% more data than the others' ten, while both the code and this document claimed the totals were equal | A difference of sample size reported as a difference of evidence structure |
| **Round 1:** interaction prior separated from nuisance priors | One scale had been applied to every coordinate, including study intercepts and main effects whose true values are nonzero | A result attributed to the registered prior factor that was really nuisance shrinkage |
| **Round 1:** null control restated as "no undercoverage" | Tested two-sided as its name promised, it failed: four scenarios overcover at 0.961 to 0.983, corrected in round 6 from a stale "five ... 0.962 to 0.986". All four are `ecological` at the smallest spread where the posterior SD exceeds the sampling SD of its centre, which is ordinary shrinkage | A conservative interval counted as a violation, or the threshold widened until it passed |
| **Round 1:** "alike" withdrawn from the prior-domination control | The tight prior's mean bias runs $-0.114$ in `additivity`, $-0.204$ in `own_ipd` and $-0.306$ in `ecological`, a spread of 0.192 against a truth of 0.40; round 6 found $-0.177$, $-0.278$ and 0.165 printed here, stale | A claim of uniformity the numbers do not support |
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


## Four outcomes that were not the outcomes they were named after

Round 6's two reviewers found four separate places where a registered output and
the thing computed under its name were different objects. They are grouped here
because the failure is one failure.

**The `eff_rank` warning was built from `target_ratio`.** `warnings_from()` named
a column for the whole-model effective rank and populated it from the
per-parameter ratio; `d$eff_rank` appeared in no warning at all. So the exported
sensitivity, false-alarm and Youden figures for the model-level summary CMP-14
asks for were the per-parameter summary's figures, and the model-level count
controlled no decision. Both now exist under their own names, the whole-model
rule firing when the data fail to dominate the prior in every direction, which
makes its threshold the parameter count rather than a tuning choice.

**The candidate's two forms pointed in opposite directions.** `source_survival`
is registered as "the fraction surviving deletion of a source". `share_within`
had that orientation. `share_curv` was one minus its analogue, the fraction
*lost* when the covariate-SD contrast is flattened, so a value of 1 meant zero
survival where the registered definition says complete survival. Both are now
survivals and are named for the source deleted, `surv_between` and `surv_sd`.
The document also referred to "three forms" of the candidate; there were two, and
the verifier had an assertion requiring the word "three".

**Primary 3 was registered as one correlation and computed as several.**
`anticorrelation()` split the confounded family by discordance level and reported
a correlation for each; the single pooled correlation the protocol registers
existed nowhere. Stratified and pooled rank correlations can differ in sign, so
this mattered independently of the answer. The pooled value is **0.3295** over
144 scenarios, the strata are 0.2232 and 0.5119, all three are positive, and the
agreement is now asserted rather than noticed.

**The false-alarm denominator was not the success class.** Failure is one-sided,
coverage below `COVER_BAD`, while primary 1 excludes the intermediate and
over-covering bands from both sides. The secondary used `!failed`, so 84
scenarios primary 1 refuses to call successes were counted as successes here.
**The correction flatters the diagnostics and is reported for that reason**: the
contraction rule's false-alarm rate falls from 0.3043 to 0.0355. The old
denominator's value is exported beside the new one so the size of the change is
visible rather than absorbed.

**Two more verifier assertions were pinning withdrawn wording**, one requiring
"in all three of its forms" and one requiring a blanket prior-free claim that was
false of `contraction`, which is a posterior SD over a prior SD and uses
$(I + P_0)^{-1}$ by construction. That is five such guards in this study. The
rule now applied: **an assertion should check a computed value or a named
property, never that a sentence is present verbatim**, because the second kind
survives the discovery that the sentence is wrong.

## Everything the document did not say, and one number that did not add up

The rest of round 6 was specification rather than error: eight findings where the
document asserted something it never defined, and the fix in each case is to state
it and assert it.

**The study-by-study map.** A reviewer could not tell whether own-IPD
identification for components 1, 2 and 4, an aggregate-only target, a fixed
twelve-arm geometry and an identical shared background can hold at once, and
guessed they could not, reasoning that three IPD components at three arms each
already spend nine arms. They spend six: the background studies are two-arm.
`R/06-nonlinear.R` now prints the whole map and asserts all four constraints,
including that **no background arm carries the target** and that the
aggregate-only states supply no individual data on it.

**The ADEMP true values.** Coverage is a performance measure against a truth, and
the grid registered the *departures* from the truth without stating the truth.
All seven values are now in section 2 and exported.

**E2's grid.** E1 registered a 504-scenario factorial with named factors; E2 said
"a reduced factorial". Its seven factors, their levels and the four structural
restrictions that cut it to 72 are now stated.

**$\sigma$ known.** The closed-form posterior covariance $(I + P_0)^{-1}$ holds
for a Gaussian model with known residual variance. The document wrote
$\operatorname{Var}(y) = \sigma^2$ without saying whether $\sigma$ was estimated,
which is the difference between E1 being exact and E1 being approximate.

**Nuisance-prior inertness.** "Its inertness is measured rather than asserted"
presented a post-data check as a settled property, with no estimand, tolerance or
pass rule. The rule is now stated, the measured worst moves are given, and it
carries the exploratory standing section 1 gives the rest of E1.

**"Any" nuisance heterogeneity.** Three isolated contrasts on one geometry do not
establish a universal claim. The sentence now says three, and section 4 says what
is not ruled out.

**The "randomized?" column** answered validity for `additivity`, mixing the
assignment mechanism with an identification assumption. A combination trial is
randomized whether or not additivity holds.

**And the arithmetic did not reconcile.** The headline said 45 findings while the
table summed to 85, with no deduplication rule stated, so the provenance claim
failed against the document's own table. The total is now **computed from the
table** by the verifier in both files, it is 107 across six rounds, and it is
labeled as findings *as returned* rather than as distinct defects, which is the
only thing the table supports.

**Three control justifications in this file were stale**, describing the run from
before the arm-geometry fix: tight-prior recovery, the overcoverage count and
range, and the bias spread. The protocol's numbers were asserted against the
export cell by cell and this file's were not, which is exactly how they survived.
They are now asserted too.

**The emitter had been a no-op.** `review/emit-tables.py` had one substitution and
it targeted a sentence a rebuild had deleted, so it matched zero times, wrote
nothing, printed "already current", and the protocol named it as one of three
links in a provenance chain. It now **fails when a pattern matches nothing**, and
the protocol says plainly that the assertion is the guarantee and emission is a
convenience covering some numbers rather than all.
