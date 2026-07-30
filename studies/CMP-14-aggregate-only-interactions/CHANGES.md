# CMP-14: what changed, when, and why

**This file is the change history. `protocol.md` is what is registered now.**

They were one document until the fifth round of critique, and separating them is a
fix rather than tidying. Twelve rounds of critique returned **180 fatal and serious findings** between three
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
| 7 | codex | unsound | 5 | 5 |
| 7 | grok | unsound | 4 | 6 |
| 8 | codex | unsound | 1 | 7 |
| 8 | grok | unsound | 3 | 5 |
| 8 | glm | needs-revision | 4 | 1 |
| 9 | codex | unsound | 1 | 4 |
| 9 | grok | needs-revision | 1 | 3 |
| 9 | glm | needs-revision | 0 | 0 |
| 10 | codex | needs-revision | 0 | 7 |
| 10 | grok | needs-revision | 0 | 3 |
| 10 | glm | needs-revision | 0 | 1 |
| 11 | codex | needs-revision | 0 | 5 |
| 11 | grok | needs-revision | 0 | 2 |
| 11 | glm | needs-revision | 0 | 0 |
| 12 | codex | needs-revision | 0 | 3 |
| 12 | grok | needs-revision | 0 | 2 |
| 12 | glm | **sound** | 0 | 0 |

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

## Round 7: a truth I typed, a Hessian that was not one, and two arms that disagree

Round 7 ran three reviewers. **GLM returned nothing**: the opencode backend
answered "Insufficient balance", recorded as **NOT OBTAINED** and never as
agreement, which is the rule this programme has followed since round 5. So this
was still two reviewers, and they returned nine fatal findings between them.

**The worst one was mine, introduced by the round-6 repair.** Round 6 added an
ADEMP true-values table because the grid registered the departures from a truth
it never stated. I typed that table, including `gamma_other = 0` for components
1, 2 and 4, and typed the same zero into the exporter. **`theta_true()` has never
done that**: it assigns `GAMMA_W` to all four interaction coordinates.
Recomputing under the declared zeros moves E1 coverage by up to 0.44 and
reclassifies 11 scenarios, so the verifier was certifying a truth the simulation
does not use. The fix is the rule this file already had and that block had
broken: **the vector is read off `theta_true()` on a built design.** Components
1, 2 and 4 are background because their *information state* is `own_ipd`, not
because their modification is zero.

**The Laplace comparator was Fisher-at-mode.** `R/09-contraction-gap.R` inverted
`logit_info()` at the expected-data mode and called it a Laplace covariance. For
an aggregate arm the observed Hessian carries a residual term,

  -d2l/dt2 = n{ [v + (q-p)(1-2p)]/v^2 · g g' - (q-p)/v · H_p },  v = p(1-p),

which vanishes only at the data-generating parameter. A proper prior moves the
mode, so it does not vanish there. Newton on the Fisher information is Fisher
scoring: right root, wrong curvature. The observed Hessian is now implemented and
**checked against a central finite difference of the score at points deliberately
off the DGP**, agreeing to 2e-10 relative. Individual-data arms need no
correction, since for a canonical link the observed and expected Hessians
coincide, which is the same aggregate-versus-individual asymmetry the rest of the
study turns on.

**The measured gap has now grown twice, each time because a correction removed
something that was hiding the worst cases**: 0.0351 and 4.73% over the
44 correctly-specified scenarios, 0.0882 and 14.64% once the 28 aliased ones were
restored, **0.1212 and 20.11%** with the real Hessian.

**The two arms disagree on primary 3, and the old presentation hid it.** The
protocol quoted one $\rho = 0.3295$ over 144 scenarios under a heading that
section 8 also claimed was computable on E2. E2's confounded family is **eight**
scenarios and its correlation is **-0.5952**, the opposite sign. E1's contraction
becomes more reassuring as coverage worsens; E2's does not. **The E1 finding does
not reproduce on the nonlinear arm**, and that is now stated where the numbers
are rather than discovered by a reader.

**The placebo guard measured a slice that is not in the grid.** Round 6's guard
swept the states at spread 0.6 and SD ratio 2.0, and 2.0 is not a registered SD
ratio: `E2_SD_RATIO` is 1.0, 1.5, 3.0. A guard whose whole purpose was to
describe the registered arms reported a range from arms the study never runs. Over
the real grid the range is **0.2506 to 0.3760**, not 0.2913 to 0.3291, and the
curvature pair is 0.3099 against 0.3141 at ratio 1.5 and 0.3099 against 0.3321 at
ratio 3.0. The guard now takes its cells from `build_grid_e2()`.

**Primary 2's decision rule was typed in two files and registered in neither.**
The protocol registered a matched set and never said what is compared; the code
selected pairs whose contraction differs by less than 0.02 and reported their
maximum coverage gap. That is a filter on a primary outcome, so it is now
`PAIRS_CLOSE_TOL` in `R/00-config.R` and both files read it from there.

**Primary 3 existed only in the exporter**, so the designated E1 analysis output
did not contain the registered primary and rerunning the normal analysis path
would still have produced only the strata. `results/e1-analysis.rds` was also
outside the exporter's staleness list, so it could sit unregenerated while every
other artifact was fresh.

**The nuisance-prior rule checked three quantities while claiming to check every
reported one**, and judged a contraction movement against the 0.05 *coverage*
threshold. The claim needed is that no registered DECISION changes, so the
comparison is now over the failure label, the nominal label and all five warning
rules: **3,528 binary classifications, zero flips at either scale.**

**A repair from round 6 turned out to be cosmetic.** The "randomized?" column
that fused assignment with validity was fixed by moving the qualifier inside the
cell, which left validity in the column. Assignment and the extra assumption are
now separate columns.

**Two more phrase-pinning assertions**, bringing the total to seven: one required
the $I(\theta_{\text{true}})$ covariance formula the code had stopped using, and
one required a blanket prior-free claim. Both were holding a stale statement in
place, and correcting the document failed the check.

**And the round-6 emitter fix caught its first real case**, on my own edit:
renaming the inertness sentence made its pattern match nothing and
`review/emit-tables.py` stopped with an error instead of reporting "already
current". That is exactly the failure it was built for, one round later.

**The one thing that got better rather than worse**: `absent` now appears in the
arm map, the thresholds each carry a rule and an inequality, and the E1/E2 cross
-arm check added in round 7 confirms both arms compute the aliasing bias
identically, to 1.6e-15 over 40 scenarios.

## Auditing round 7's repairs before round 8 did

Round 7's worst finding was a table added in round 6 whose values were **typed
rather than read from the code**, and which stated a data-generating truth the
simulation had never used. That is a repeating disease, so round 7's own repairs
were audited the same way before round 8 reported on them.

**Six of them had the disease.** `PAIRS_CLOSE_TOL` was moved into the config and
then quoted in the protocol as a typed literal, and was not exported at all. The
standing field, E2's primary-3 correlation, the nuisance decision flips, the arm
map and the true-values table were all exported and asserted by nothing, so each
number in the document could drift from the code that produced it without any
guard noticing. The arm map was the clearest case: **the whole table was
hand-written**, including the `absent` row added in round 7 precisely because a
reviewer could not check that state's geometry. The typed row happened to be
correct, which is not the same as being checked.

**Twenty-three assertions now bind them**, cell by cell: every true value against
`theta_true()` as the exporter read it, every arm-map cell against what
`R/06-nonlinear.R` built, both primary-3 rows against their own arms, and the
flip counts against the run. Three of them are conditional rather than positional,
which is the shape this study has been moving toward: **the document may claim the
two arms disagree only if the exported signs disagree**, may claim the nuisance
prior decides nothing only if the flip count is zero, and must mark the candidate
post hoc in the exported rows and not only in prose.

## Round 8: the bridge between the arms was testing the wrong proposition

Round 8's most useful finding was structural rather than numerical. **E2's
registered rule was called a criterion for withdrawing E1's conclusion, and it
tested a proposition E1 never states.** The six comparisons ask whether the three
CMP-14 rules separate the information states; E1's conclusion is primary 1, that
no threshold on any summary separates failing coverage from nominal. Those are
different claims, and a rule that does not test a primary cannot withdraw it.

**E1's actual conclusion is now tested on E2, which the aliasing result made
possible.** Coverage exists on all 72 scenarios, so primary 1's overlap test runs
on E2 unchanged, over 41 failing and 12 nominal scenarios. **Every statistic
overlaps there too**, so the central negative result reproduces on the nonlinear
link. That points the opposite way from primary 3, which reverses sign, and the
two are now both stated: **primary 1 reproduces, primary 3 does not.**

**And the outcomes section had never stated primary 1's answer at all.** It
defined the existence claim, printed primary 3's correlation and the secondary
false-alarm rates, and omitted the answer to the study's central question. That
answer is now the first thing the section reports.

**Primary 1's implementation was not the registered test.** Two ranges overlap
when each starts below the other ends, and `overlap_table()` checked one of those
two inequalities. Two disjoint ranges lying the wrong way round would have been
reported as overlapping. The current values satisfy both, so no reported result
changes; the procedure was still not the one registered.

**Three claims were disproved by measurement rather than argument.** "Effective
rank is unaffected" by the comparator: 6 of 72 scenarios change their count and 2
flip the warning. "`EFF_RATIO_OK` governs `target_ratio` only": `eff_rank()`
takes it as its eigenvalue cutoff in both callers. "Two contractions within 0.02
are the same number to two decimals": only 15 of 54 pairs display identically,
and **the pair carrying the largest coverage gap is not one of them**, at 0.067771
against 0.081321. That last one matters less than it looks, which is also worth
recording: over the display-identical subset the maximum gap is 0.95 against
0.951 over all 54, so primary 2 survives the stricter reading.

**Undefined is not zero and is not an alarm.** Where the target's likelihood
precision is exactly zero the survival ratio has a zero denominator. The overlap
table substituted zero, putting an invented value at the alarming end of the
candidate's range; the warning rule read the missing value as an alarm. Neither
is the registered rule. Both now report undefined and drop the row, 18 rows and
72 rows respectively, and every outcome reports how many it dropped.

**The 20.11% gap does not bound what it was offered as bounding.** Section 9 tied
it to "a Gaussian approximation to a non-Gaussian posterior". Both quantities in
that gap are Gaussian approximations. It bounds the choice of Gaussian; the
distance to the true posterior is measured nowhere, and the limitation now says so.

**Two claims rested on the wrong arm's measurement.** "Section 8 establishes that
this holds to machine precision on both arms" cited an E2-only check for an E1
claim; E1's own numbers, 1.6e-15 and 1.8e-15, come from the smoke test and are now
quoted. And section 7's round-7 repair said "every number in this section is an
**E1** number" in the same section that reports an E2 correlation, which both
reviewers caught independently.

**A guard written earlier in this same session had to be withdrawn.** It required
the document to state that `EFF_RATIO_OK` governs `target_ratio` only, which is
false. That is the **eighth** assertion in this study to pin a wrong statement in
place by demanding a phrase, and the first whose author had to reverse himself
inside one sitting.

## A third reviewer, four fatal findings, and all four wrong

Round 8 was the first round in which GLM produced output; rounds 5 to 7 recorded
it as **NOT OBTAINED** for quota and balance failures. It returned four fatal
findings and one serious. **Every one of the four fatals is arithmetically
wrong**, and checking them rather than acting on them is the point of this entry.

- **"Two E2 discordance frequencies contradict each other."** The correlations at
  0.15 and 0.40 are **E1's** strata; `DISCORD` is 0, 0.15, 0.40 and `E2_DISCORD`
  is 0, 0.40. An E1 sentence was read as an E2 registration.
- **"The false-alarm correction runs in the wrong direction."** The argument was
  that removing 84 scenarios from a success denominator "can only raise the
  rate". That holds only if the removed scenarios alarm no more often than the
  retained ones, and here they alarm far more: the contraction rule fires on
  **71 of the 84** middle-band scenarios, 84.5%, against 6 of 169 nominal ones.
  Most of that band is `absent` under a wide prior, where the posterior is the
  prior, contraction is 1 and the rule alarms by construction. The direction is
  consistent.
- **"28 is not printable from the listed factors."** It is: 8 `ecological` and 12
  `curvature` at discordance 0.40, plus 8 `additivity` at synergy 0.20. The
  reviewer's own reconstruction did not apply the grid's restrictions.
- **"The pooled 0.3295 lies below both strata."** It lies between them, 0.2232 and
  0.5119. The accompanying claim that a pooled rank correlation must lie inside
  its strata's range is also false in general.

**Two of the four still earned changes**, which is why a wrong finding is not a
worthless one. The strata sentence did not say which arm it described, and the 28
was stated without its breakdown. Both are now explicit and both are asserted, and
the false-alarm paragraph now carries the middle band's 84.5% alarm rate, which is
the fact that makes its direction obvious rather than surprising.

The fifth finding, that the nuisance-inertness paragraph reads as a guarantee,
quoted wording round 7 had already replaced.

**The record for this study now reads: a reviewer that fails is not a reviewer
that agrees, and a reviewer that speaks is not a reviewer that is right.** Both
halves have cost real work to learn.

## Round 9: every finding was a round-8 repair that stopped halfway

Round 9 was asked to look hardest at round 8's repairs, and every finding it
returned is one. That is the third consecutive round where the previous round's
fixes were the richest seam, and it is the reason the instruction now stands in
the preamble.

**A criterion revoked in prose and left running in code.** Round 8 established
that the six state-separation comparisons cannot withdraw E1's conclusion, and
`e2_verdict()` went on computing `withdraw_e1` from them, exporting it, and
printing "E1's conclusion is withdrawn". Two sentences and a section heading also
survived the revocation. A future separation would have had the software withdraw
E1 while the E2 overlap test said it reproduces.

**A guard cited for a check that did not exist.** The protocol said `R/09-smoke.R`
established E1's pointwise aliasing identity to 1.8e-15. The smoke test computed
only the scalar bias identity; the number came from a scratch script and was typed
into prose next to the words naming the guard. **That is round 7's typed truth
table wearing a guard's clothes**, and it is worse, because a reader who checks
the cited file finds a real check that is not the claimed one. The identity now
runs over all 504 E1 scenarios and both gaps are exported.

**A staleness guard whose premise had expired.** The verifier excluded
`R/05-export.R` from its newest-code check, on the reasoning that the exporter
only consumes artifacts. That was true when written and stopped being true when
the exporter began computing values; editing it after a run left a stale export
that all assertions passed against.

**A taxonomy asserted against a constant.** The four-row route table is the
thesis's foundation, and `review/verify-protocol.py` had its expected entries
written in as literals. A change in `R/08-routes.R` would have left document and
guard agreeing and both wrong. The table is exported and compared to the run.

**Numbers reported without the arm they came from.** Primary 2's 0.951 over 54
close pairs, and the candidate's 402/18/72 exclusion counts, sit in sections that
cover both arms and are E1's alone; E2's grid cannot produce them. Worse, section
8 asserted primary 2 runs on E2 and **no result line for it existed**. It does
now, and it is a negative one: **16 matched pairs, 1 close, coverage gap 0.** E2's
grid has two spreads where E1 has six, so it produces too few comparable pairs for
the test to bite. **Primary 2 is an E1 result and E2 neither confirms nor refutes
it.**

That completes the reproduction picture, which section 9 now states in one place:
**primary 1 reproduces on the nonlinear arm, primary 2 is untestable there, and
primary 3 reverses sign.** One of three.

**And the document's own meta-claim was false.** "Every position is now stated
once" could not survive a round that found one revoked criterion asserted in three
places. It is an aim now, not a guarantee.

Two smaller ones: the nuisance-prior denominator counted 3,528 slots when 72 hold
no decision, and the header credited 148 findings to two reviewers when the table
names three.

## The third reviewer's second outing, and a decision about it

GLM's round-9 output refuted four of its own six findings while writing them.
Three end "Not a defect", one ends "Wait — ... This reproduces". That is the
arithmetic discipline the round-9 preamble asked for, arriving one paragraph too
late each time. **It is recorded in the table as 0 fatal and 0 serious**, because
a finding its own author withdraws is not a finding.

The two that survived are both wrong.

- **"The 8 and 12 are swapped."** They are not. `ecological` runs at one SD ratio,
  because that factor acts only on `curvature`, giving $2 \times 2 \times 2 = 8$
  departure cells; `curvature` runs at one spread but all three SD ratios,
  giving $3 \times 2 \times 2 = 12$. The reviewer applied the SD-ratio factor to
  `ecological`, which is the error it corrected in its own next-but-one finding.
- **"72 should be 48."** The by-state counts are `absent` 8, `additivity` 16,
  `curvature` 24, `ecological` 16, `own_ipd` 8, summing to 72. The reviewer's
  by-state arithmetic halved four of the five.

**Cumulative: GLM has returned seven fatal findings across two rounds and all
seven were wrong.** Round 8's cost two clarifications that were worth making;
round 9's cost a cycle and produced one. **The decision is to keep it**, because
the marginal cost is one CLI call and a wrong finding still occasionally lands on
ambiguous wording, but its findings are now treated as claims to check first
rather than defects to fix. That is how every finding should be treated; GLM
merely makes the point unmissable.

**The lasting change is that the disputed arithmetic is now exported.** The E2
grid's per-state counts and the departure split are in
`results/registered-design.json` and asserted against the document, so "is it 8 or
12" and "is it 72 or 48" are answerable by reading a file rather than by
recomputing a factorial by hand. That should have been true before a reviewer
asked.

## Round 10: a guard that rewrote the document to make itself pass

**Codex returned no fatal findings for the first time in ten rounds**, and seven
serious ones, every one of them in a round-9 repair. The worst is the smallest to
describe.

**An assertion added in round 9 edited its own input.** It read

    f"**{gap:.3g}** over {n}" in PROTOCOL.replace("1.06e-15", f"{gap:.3g}")

so it substituted the exported value into the document text and then checked that
the exported value was present. **It passed by construction.** The document said
1.06e-15, the artifact said 1.0547e-15 which exports as 1.05e-15, and the guard
existed precisely to catch that disagreement. The number came from rounding
"1.055e-15" up by hand instead of taking `signif(x, 3)` from the export, which is
the rule this study has broken and re-learned in five separate rounds.

**A guard that rewrites its input is worse than one that pins a phrase.** The
phrase-pinning guards, eight of them so far, at least failed loudly when the
document changed; this one could never fail. `review/verify-protocol.py` now
carries a meta-assertion that no check may substitute into `PROTOCOL`, `RAW` or
`CHANGES` before a membership test, and **it caught a second instance on its first
run**, in the overcoverage check, which was rewriting "four" to "4".

**Two numbers had been quoted from a reviewer for three rounds.** The claim that
the wrong truth table would have moved E1 coverage by 0.44 and reclassified 11
scenarios appeared in prose and in code comments and was computed nowhere, while
the provenance paragraph claimed every quoted quantity is exported.
`R/10-truth-counterfactual.R` reruns the whole grid under the truth the table
wrongly declared: **0.4399 and 11 of 504**, reproducing the reviewer's figures
exactly.

**The registered secondary analysis existed for E1 only**, while section 7
presented its numbers under a heading covering both arms. Applying the same five
rules to E2 changes the picture materially: contraction's Youden index is
**0.8049 on E2 against 0.2195 on E1**, with a false-alarm rate of zero. **On
twelve nominal scenarios**, which is stated beside it, because a zero over twelve
is a weakly determined zero. And primary 1 still overlaps on E2 while those
thresholds separate well on average, which is the distinction primary 1 exists to
draw.

**Primary 2 on E2 was called untested and is not.** The registered rule asks for
at least one close pair and sets no minimum; E2 has one, with a gap of
**1.286e-4**. Reporting it as 0 was an artifact of rounding to three decimals, and
calling the outcome "untested" confused a sparse grid with an undefined result.
The reproduction summary now reads: **one of three primaries reproduces**, and the
other two differ in ways E2's grid is too thin to adjudicate.

Three more repairs that reached the stored fields and not the analyst-facing
output: `R/08-routes.R` still printed the "any between-study heterogeneity" claim
section 4 had revoked, `R/07-run-e2.R` still headed its state-separation table
"the registered withdrawal rules", and its candidate line read a field name that
does not exist, so the second form's result could never have printed. **That is
the third round running in which a repair reached the data and stopped before the
console.**

Two smaller ones: the aliasing tolerance was verified against a literal rather
than the exported `E2_ALIAS_TOL`, and primary 2's 0.951 was claimed as a lower
bound when the unrounded maximum is 0.9505515516.

## Round 10's second reviewer, and two findings that arrived already fixed

Grok reviewed the same document hash as codex, `583ab31d`, and returned three
serious findings of which **two were the same defects codex found**: the
secondary false-alarm figures unlabeled in a dual-arm section, and primary 2 on E2
described as untested when it returns a number. Both were repaired from codex's
version before grok's reply arrived. **That is convergence, and it is the second
time in this study two reviewers have independently found the same thing**; the
first was the ten-arm curvature state in round 6.

Its third finding is new and is a contradiction inside one paragraph. The
sentence naming the study's **central negative result** listed the post hoc
candidate alongside the three CMP-14 rules and the estimability screen, while the
next paragraph says primary 1 covers the four and that the candidate "is not a
primary result". **One sentence both asserted and denied the candidate's
standing.** The central result is now the four registered statistics; the
candidate overlaps as well, carries `post-hoc-candidate` on its row, and is
outside the claim.

Two minor ones, both about a residue the previous repair left. The bias identity
had been checked on **a sample of 40 scenarios with no statement of which 40**, in
a document that had just removed a number produced by a scratch script; a subset
that might miss the shifted cells cannot underwrite the arm, so it runs on all 504
now and reports **1.67e-15** rather than the sample's 1.05e-15. And "the E1
finding" was used for primary 3 while "E1's conclusion" meant primary 1, so
section 9 could be read as retracting the bridge section 8 asserts. Both claims
are named by primary now.

## GLM's third outing: eight fatal claims, eight wrong

GLM returned one fatal finding and four serious ones in round 10. **The fatal is
wrong and so are three of the four.** Recorded as 0 fatal and 1 serious, counting
only what survived checking.

- **"The 5e-5 placebo guard is inert because no registered cell trips it."** That
  is what a passing guard looks like. Every `stopifnot` in this study fails to
  fire on the current design; firing would mean the design is broken. The
  question is discriminating power, and 5e-5 is strictly stronger than the exact
  equality it replaced: it catches any future change that lands an arm within
  5e-5 of 0.3, where bit-equality caught almost nothing.
- **"The threshold table lists `CONTRACT_OK` for `target_ratio`."** The row reads
  `` `target_ratio` | $<$ `EFF_RATIO_OK` | 1.00 ``. The reviewer read the
  contraction row's values into the target-ratio row.
- **"41 and 12 are unlabeled."** The sentence says "on E1, over 251 failing and
  169 nominal scenarios, and on E2 over 41 and 12".

Two earned changes, and both are about a reader's path rather than a fact.
Primary 1's E2 comparison set (41 + 12) and primary 3's E2 confounded family (8)
are different subsets a paragraph apart, and this reviewer conflated them, so the
document now says they are different. And **"`curvature` runs at the first spread
alone" has now been misread as a restriction on the SD ratio by two separate
reviewers**, inverting the per-state counts both times; the two axes are named
apart.

The fifth finding, that the false-alarm denominator is registered only in prose,
is half right: it is `classes()` built from `COVER_BAD`, `NOMINAL` and
`COVER_TOL`, so it derives from registered constants, but the choice to use it
rather than `!failed` was made after the old value had been seen. That is now
said where the number is, along with where the denominator lives.

**Cumulative across three rounds: GLM has returned eight fatal findings and all
eight were wrong.** It has never once identified a real fatal defect, and it has
twice produced clarifications worth making by misreading something a careful
reader could also misread. That is the value it adds, and it is worth one CLI
call, but it is not the value a third reviewer was added to provide.

## Round 11: a distribution nobody registered, and a pair that proves nothing

**Second consecutive round with no fatal finding.** Five serious ones, and two of
them change what the study can claim.

**E2 rests on a covariate distribution the protocol never registered.** The
document said an aggregate arm's prevalence "depends on each study's covariate
mean and SD". It does not: the arm probability is
$\int \operatorname{expit}(\eta(x))\,\phi(x)\,dx$, and that integral depends on
the whole law. Two covariates with the same mean and SD give different arm
probabilities, different Fisher information, different contraction and different
coverage. The implementation has always assumed **normality**, through 64-point
Gauss-Hermite quadrature, and nothing said so. **Every E2 number is conditional on
a distributional assumption that appeared in no section**, which section 9 now
carries. On the identity link the shape genuinely does not matter, which is
presumably why it went unnoticed for eleven rounds.

**Primary 2's E2 pair carries no confounding, so it settles nothing.** E2's single
close pair sits at **discordance zero**, which this document elsewhere calls the
unconfounded null control. Primary 2 exists to price a randomized route against a
confounded one, and E2 has **no close confounded pair at all**, against E1's 36.

**Both of this study's earlier statements about it were wrong, in opposite
directions.** Round 9 called primary 2 "untested" on E2, understating a defined
outcome. Round 10 corrected that to "does not reproduce", overstating what a
null-control pair can refute. **The accurate statement is narrower than either**:
the statistic is defined on E2 and the comparison it stands for is unavailable
there. Two rounds of confidently reversing a claim, and the truth was outside both
positions.

Three more, all in round-10 repairs. The runtime candidate line printed
`surv_between`'s two zeros beside `surv_sd`'s separation verdict, so it showed
identical values next to TRUE and no reader could tell which form separates; both
forms now print beside their own verdicts. The E2 secondary was described as
resting on "41 failing and 12 nominal cells" when the candidate row rests on
**33 failing**, `surv_between` being undefined in 16 E2 scenarios. And the E2
secondary table, added in round 10 to fix a labeling promise, **shipped without
the standing column that promise is about**.

One minor: the protocol still said GLM "contributed only in round 8" after it had
reviewed in rounds 9 and 10.

## One leg of the central result cannot fail, and now says so

**No reviewer returned a fatal finding in round 11**, the second such round, and
this time all three reviewers ran.

The sharpest finding is structural. Primary 1 is described as a four-statistic
existence claim and called the study's central negative result. **One of the four
legs cannot fail.** A coordinate the likelihood does not identify has a posterior
equal to its prior, so its coverage is deterministic, **0 or 1, never within 0.01
of 0.95**. Every nominal scenario is therefore estimable; failing scenarios
include both estimable and non-estimable cells; so `rank_screen`'s two ranges
overlap **by construction** and no grid could falsify that leg. Checked: 0 of 169
nominal E1 scenarios are non-estimable, non-estimable coverage takes only the
values 0 and 1, and 233 of 251 failing scenarios are estimable.

**The claim was true and one quarter of it was not evidence.** The informative
content is the three CMP-14 summaries, each continuous, each of which could have
separated and did not. `R/09-smoke.R` asserts the structural fact instead of
leaving it an argument.

**A blanket superiority claim the table beneath it contradicted.** "On E2 the same
rules perform far better" quantified over all five rows while the candidate's
Youden index is *worse* on E2, 0.2424 against 0.2585, and it is the only rule with
a nonzero E2 false-alarm rate. Scoped to the three summaries now.

**And a repair phrase that withdrew a measurement.** "The strata agree with the
pooled reading, which is now asserted rather than observed" read as retracting
three printed numbers. The agreement is measured; what round 6 changed is that the
verifier checks it.

### The third reviewer's fourth outing

**GLM claimed no fatal finding for the first time**, and its two serious findings
are both wrong. One argues primary 3's sign convention is self-contradictory, on
the premise that "higher contraction = more shrinkage = looks better-identified".
It is the reverse: contraction is posterior SD over prior SD, so **high**
contraction means the posterior is nearly the prior and the parameter is
prior-driven, which is the alarming case. The other says the document's printed
`E2_ALIAS_TOL` may not be tied to the exported constant; assertion 174 ties it,
and the reviewer reads no code, which it acknowledged in its refutation condition.

**Its three minor findings are all fair and all were acted on**, which is a first:
E2's three-class accounting was never printed where E1's was (41 failing, 12
nominal, 19 neither), the $3{,}528 - 72 = 3{,}456$ slot arithmetic was asserted
without showing the multiplication, and "the states carrying a departure are
disjoint because the grid's restrictions make them so" names the wrong mechanism.
They are disjoint because a scenario has exactly one state; what the restrictions
do is stop a single scenario carrying two departures.

## Round 12: convergence, and a claim that reversed twice

**No reviewer returned a fatal finding.** Codex and grok both said so in words;
**GLM returned `VERDICT: sound`**, the first sound verdict in twelve rounds, and
ended "Two clean rounds preceded this one; this one is clean. That is
convergence."

The serious count fell from 11 to 7 to 5. Three of those five were in round-11
repairs and one reversed a claim made in the same round.

**The candidate's cross-arm comparison has now been wrong in both directions.**
The E2 secondary table's E1 column was **typed and unasserted** while only the E2
column was checked, and it held a stale Youden of 0.2585 that no export contained.
Round 11 used that stale number to correct "all five rules perform far better" to
"the candidate is worse on E2". The real E1 value is **0.2287**, so the candidate
is marginally *better* on E2 and neither wording was right. **Both columns now
come from the export and every cell of the table is asserted**, which is the same
one-side-only defect the route table had before round 9.

**Round 11's structural finding was overstated and round 12 corrected it.** The
claim was that `rank_screen`'s primary-1 leg "cannot fail". Half of it cannot: no
nominal scenario is ever non-estimable, measured on both arms. But the overlap
also needs an **estimable failing scenario**, and that is a measured fact, 233 of
251 on E1, not a definitional one; had none failed, the binary screen would have
separated. The smoke test's own separate check of that fact was the evidence.
**The leg is half structural, not unfalsifiable.** On the logit link the mechanism
is looser still: E2's non-estimable contractions run 0.998888 to 1 rather than
exactly 1, while their coverage remains exactly 0 or 1.

**And the same shape appeared once more in the secondary table.** `rank_screen`
alarms only on non-estimable coordinates, which can never be nominal, so its
false-alarm rate is **structurally zero on any grid using these class
definitions**. It sat in the same column as four measured zeros. It is marked now.

Two remaining: the round-11 covariate repair left the sentence it declared false
standing as the operative one, two paragraphs above its own correction, and the
E2 candidate's printed and saved results still lacked the per-row standing the
protocol promises.

**A third guard was found to have stopped growing with the data.** The reviewer
table's verdict field was matched as `[\w-]+`, and round 12's `**sound**` does not
match it, so that row would have dropped from the finding total silently. It
contributed 0 + 0, so nothing moved, which is exactly how this survives. After the
number-word list that stopped at seven and the round number that matched one
digit, the parser now **counts its own rows against the table's line count**.
