# Protocol: what would the two summaries CMP-14 asks for actually tell an analyst?

**Target problem.** CMP-14 *Aggregate-data-only interactions may be prior-driven*. Bears in
part on IDN-06 *ML-NMR interactions can rest solely on aggregate-data variation*.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Provenance.** Every number this document prints is exported from the code that computes it
by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export,
currently **123** assertions. The four controls in section 5 are asserted against the values
that made them pass, not merely described, because section 8 concedes that two of them were
weakened after they failed.

**Registration status, stated plainly because it is not uniform across the two experiments.**

- **E1 is exact and was computed before this document was written.** It contains no sampling,
  no replicates and no estimator: given the grid, its output is a mathematical fact rather
  than an estimate. Its grid, estimands, diagnostics and thresholds were fixed in
  `R/00-config.R` and `R/04-analyze.R`, but earlier probes were read while choosing them, and
  the analysis was run before this protocol existed. **E1 is therefore reported as exact and
  exploratory**, and section 8 records every design choice that was changed after seeing a
  number.
- **E2 has no confirmatory standing, and the earlier claim that it had some is withdrawn.** An
  earlier version of this bullet said its separation rules "were committed before it ran and are
  confirmatory with respect to it". That was true of the rules as first written and false of the ones
  now in force: round 3 rebuilt them after E2's output had been read, to cover the whole-model rank
  count and the complete per-state distributions. Round 4 pointed out that I had applied this reasoning
  to the equal-SD condition and not to the rules I rebuilt around it. **Every part of E2 is
  exploratory.** It is reported as a check on whether E1's conclusion survives a nonlinear link, not
  as independent confirmation of it, and section 9 carries the consequence. E2 involves **no MCMC and fits no model**: it is an
  asymptotic calculation from the Fisher information of a logistic component model. An earlier
  version of this bullet said "fitted by MCMC rather than solved" while section 7 said the
  opposite; round 2 found the contradiction and it is resolved in favour of what the code does.

Pre-registration exists to stop data-dependent choices from manufacturing a result. For a
deterministic computation the corresponding risk is choosing the grid or the outcome
definition after seeing which choice gives the desired answer. That risk is real here, it is
not removed by the computation being exact, and section 8 is where it is disclosed rather
than where it is denied.

---

## 1. The problem

CMP-14 states that interaction parameters informed only by aggregate data can be regularized
into finite posterior intervals by the prior, so a proper credible interval is not evidence
that the likelihood contributed anything. It credits `cpaic` with three optional diagnostics
and names exactly what is missing:

> a default numerical summary: **prior-to-posterior contraction per interaction parameter**
> and an **effective likelihood rank**, reported without the analyst having to ask.

Two neighboring questions are already answered and this study does not re-open them.

**CMU-02** measured the operating characteristics of five prior-sensitivity diagnostics,
contraction among them, in a conjugate Gaussian population-adjusted network. Its headline was
that these diagnostics measure the prior's *influence* while the harm comes from the prior's
*location*. Its own scope statement says CMP-14 "is touched only for the generic
aggregate-only interaction, not for component models".

**CMP-13** measured what the shared-interaction restriction costs in a component network:
coverage of the causal within-trial interaction falls from 93.8% to 17.2% as the within-trial
and across-trial coefficients diverge. It evaluated no diagnostic.

The open part is the join. In a **component** network a parameter can be identified by routes
that do not exist in a plain one, and the question is whether the two summaries CMP-14 names
tell an analyst what they need about those routes.

## 2. The model and the five information states

$K = 4$ binary components. A treatment is an indicator $c \in \{0,1\}^K$ with additive effect
$c'\delta$ and additive modification $c'\Gamma$. For an individual with covariate $x$ in
study $s$,

$$E[y] = \alpha_s + c'\delta + x\,(\beta + c'\Gamma), \qquad \operatorname{Var}(y) = \sigma^2 .$$

Each source of evidence is a different linear functional of $\Gamma$:

| state | route to $\Gamma_k$ | randomized? | in E1 | in E2 |
|---|---|---|:--:|:--:|
| **own_ipd** | its own individual-data trial; within-study covariate variation | yes | ✓ | ✓ |
| **additivity** | only inside the combination $1{+}k$, alongside an arm for 1 alone, so the slope difference is exactly $\Gamma_k$ | yes, if additivity holds | ✓ | ✓ |
| **ecological** | only in aggregate studies, so only the contrast between reported covariate means | **no** | ✓ | ✓ |
| **curvature** | two aggregate studies at the **same covariate mean** and **different covariate SDs**, on a **nonlinear** link | **no** | — | ✓ |
| **absent** | nothing; the coordinate is rank-deficient | n/a | ✓ | ✓ |

**`additivity` is the state component methods create and no other design has**, and
**`curvature` exists only on a nonlinear link**, which is why CMU-02's identity-link design
could not contain it and why E2 is necessary rather than decorative.

**The curvature state was specified wrongly in the first version and round 1 caught it.** That
version said a *single* aggregate study identifies the interaction because its arm mean depends
on the covariate variance. Depending on the variance does not create a second observation: one
aggregate arm supplies one proportion for two unknown target parameters, $\delta_3$ and
$\Gamma_3$, so the information is rank one and a change in one is absorbed by the other. The
corrected state uses **two** aggregate studies at the same covariate mean and different
covariate SDs. Verified rather than asserted (`R/06-nonlinear.R`): with equal SDs the target is
not estimable on either link, because the two studies give identical equations; with unequal
SDs it is not estimable on the identity link and **is** estimable on the logit link. That is
precisely what makes `curvature` a nonlinear-only state.

**A consequence sharper than the original framing.** The curvature route is still a
*between-study* contrast; the link's nonlinearity changes only which moment of the covariate
distribution carries it, from the mean to the variance. Nobody randomized a study's covariate
spread any more than its covariate mean. So **every aggregate-only route is an unrandomized
between-study route**, and a summary that groups them together is not failing to distinguish
them; it is refusing to distinguish two things that are the same kind of evidence.

The target is component 3 throughout. Components 1, 2 and 4 stay in `own_ipd`, so the network
is otherwise well identified and the target's behavior is not confounded with a globally weak
design. **Every state enrolls the same total number of patients**, which is enforced by
dividing a registered budget among however many arms a state's structure needs; the first
version gave every arm the same size and `additivity`, which has twelve arms against the
others' ten, silently ran on 20% more data.

## 3. Estimand

The **causal within-study component interaction** $\Gamma_{W,3}$, on the conditional scale.
This is the quantity a component model reports and the one whose interval CMP-14 says may be
prior-driven.

## 4. The diagnostics compared

| rule | what it is | source |
|---|---|---|
| `contraction` | marginal posterior SD over marginal prior SD, for the target's own coordinate | **what CMP-14 asks for** |
| `eff_rank` | likelihood-to-prior information ratio along the target's coordinate, plus the whole-model count of directions where the data outweigh the prior | **what CMP-14 asks for** |
| `rank_screen` | is the coordinate identified by the likelihood at all, computed with no prior | the estimability screen `cpaic` already ships |
| `source_survival` | the fraction of the target's marginal likelihood precision that **survives deleting** a source, computed prior-free. Called a *share* in earlier versions, which round 4 rejected: it is not a share of anything, because the sources are not additive and no single source identifies the target in every state | **this study's candidate replacement, exploratory** |

The fourth is proposed because of an argument, not a hunch. Contraction and effective rank are
functions of the information matrix, and an information matrix is a **sum over rows**. Summing
is what destroys the distinction the analyst needs: a row from an individual-data arm and a
row from a between-study covariate contrast contribute the same kind of number while carrying
opposite causal warrant. The fix is not a better threshold on the sum. It is to not take the
sum. This costs nothing: the decomposition reads the same matrix.

Registered thresholds: `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`, `SOURCE_OK = 0.50`,
in `R/00-config.R`.

## 5. E1: the exact arm

**Why exact.** The study evaluates summaries meant to tell an analyst whether a posterior is
held up by its prior. If the posterior were itself a Monte Carlo approximation, every
diagnostic would carry sampling noise of unknown size and a failure to flag could not be
separated from a failure to converge. With a conjugate Gaussian model the posterior, the
coverage and every diagnostic are closed form, so a failure belongs to the diagnostic.

**A consequence that is a result, not a convenience, stated more carefully than in the first
version.** The posterior covariance is $(I + P_0)^{-1}$, which does not involve the outcomes.
**Contraction and effective likelihood rank therefore depend on the data only through the
realized covariate design, never through what the outcomes turned out to say.** Whatever these
summaries measure, it is not the content of the evidence.

The first version overstated this as "functions of the design alone, computable before a single
patient is enrolled", and round 1 was right to reject it: for individual data the information
is $X'X/\sigma^2$, which depends on the covariates actually observed, so realized contraction
does carry replicate-level variation. E1 represents each individual-data arm by its
Gauss-Hermite nodes, which is the **expected** covariate design.

Round 3 asked for the consequence to be stated precisely rather than as "an expectation", and it
is right that the loose wording hid something. Substituting the expected information is not the
same as averaging any reported quantity over realized designs, because coverage and contraction
are nonlinear functions of the design. Every E1 number is exact for a study whose covariate
distribution is realized exactly at the quadrature weights, and for one that is not it is neither
an average, nor an upper bound, nor a lower bound. The unit of analysis is the scenario
**conditional on that design**, and that conditioning is a limitation carried in section 9 rather
than a property being claimed.

**The interaction prior is applied to the interactions only.** The first version set one prior
scale on every coordinate, so a result attributed to the registered factor could have been
shrinkage of study intercepts and main effects whose true values are nonzero. Nuisance
coefficients now carry a fixed weak `PRIOR_SD_NUISANCE = 10`.

**That it is doing no work is measured, not asserted.** Round 2 pointed out that "must not be
doing work" was a claim with nothing behind it. Every scenario is re-evaluated with the nuisance
scale at 3 and at 30, an order of magnitude either side, and the largest movement in any
registered quantity across the whole grid is **0.0005 in coverage, 0.0001 in contraction and
0.0000 in the source survival fraction**. The interaction prior is the only prior doing work, within that
tolerance. **What was tested is exactly that**: two alternative scales on E1's grid, on the
identity link. Round 3 found the claim stated more broadly than the test, so it is narrowed here.
E2's nuisance prior is not varied, and neither arm establishes invariance outside the range 3 to 30.

**The grid**, a full factorial with two structural restrictions (`R/03-run-e1.R`):

| factor | levels |
|---|---|
| information state | own_ipd, additivity, ecological, absent |
| between-study covariate spread | 0.3, 0.6, 1.0, 1.4, 2.0, 3.0 |
| discordance $\Gamma_B - \Gamma_W$ | 0.00, 0.15, 0.40 (ecological only) |
| total patients per network | 1000, 3000, 10000 |
| prior SD on interactions | 0.1, 0.5, 1.0, 2.5 |
| synergy (additivity violated) | 0.00, 0.20 (additivity only) |

**504 scenarios**. Discordance acts only through aggregate rows carrying the target and
synergy only through arms holding components 1 and 3 together, so carrying either into a
state that has neither would add scenarios bit-identical to their zero twins and inflate
every count.

**Four controls, all of which must hold or the run stops** (`R/03-run-e1.R`). Each is stated
as what it actually tests, after round 1 found two of them promising more than they checked.

1. **Absent is prior-only.** Contraction $> 0.999$ in every absent scenario.
2. **The null control does not undercover**, and it is *not* claimed to be nominal: some scenarios
   overcover, all of them `ecological` at the smallest between-study spread where the posterior SD
   exceeds the sampling SD of its own centre. That is ordinary shrinkage producing a conservative
   interval, the harmless end of prior domination, and the control requires the overcoverage to be
   confined to that mechanism rather than widening its threshold until it passes.
3. **The tight prior pulls every state toward zero**, and pulls hardest where there is least
   information to resist with. The first version said it depresses every state *alike*; measured, the
   magnitudes differ by more than a third of the truth, so **"alike" is withdrawn**. What holds, and
   what the argument needs, is that the direction is the same everywhere, so the failure belongs to
   the prior and not to any one evidence structure. Two orderings are asserted: `absent`, which has
   no likelihood information at all, is pulled hardest of any state, and among the states that do
   have information `ecological` is pulled hardest.
4. **Both kinds of prior-driven parameter are present.** The absent state must cover the truth
   essentially always under a wide prior and essentially never under a tight misplaced one. Without
   both, the grid contains only the harmless kind and the comparison is rigged. Round 3 found the
   check testing only that a scenario of each kind **exists**, weaker than the words "essentially
   always"; both are group properties now, so a single conforming scenario cannot carry the control.

**The numbers these controls actually produced**, emitted from the run rather than typed, because
round 2 found two of them stale from before the patient budget was equalized and round 4 changed
every one of them again by matching the arm counts:

| control quantity | value |
|---|---|
| absent-state contraction, minimum | 1.0000 |
| null control, minimum coverage | 0.9468 |
| null control, scenarios overcovering | 4 |
| null control, overcoverage range | 0.961 to 0.983 |
| the shrinkage causing it: posterior SD against sampling SD | 0.536 against 0.453 |
| tight prior, coverage recovered at the largest budget, `additivity` | 0.938 |
| tight prior, coverage recovered at the largest budget, `ecological` | 0.735 |
| tight prior, coverage recovered at the largest budget, `own_ipd` | 0.725 |
| tight prior, mean bias, `absent` | -0.400 |
| tight prior, mean bias, `additivity` | -0.114 |
| tight prior, mean bias, `ecological` | -0.306 |
| tight prior, mean bias, `own_ipd` | -0.204 |
| absent state, coverage by prior SD | 0.1: 0.00, 0.5: 1.00, 1: 1.00, 2.5: 1.00 |

## 6. Outcomes

**Primary 1, and the only one no weighting can move.** For each statistic, does the range of
values taken by *failing* scenarios overlap the range taken by *nominal* ones? A single value
compatible with both a nominal and a badly failing scenario establishes that **no threshold
separates them**, whatever the grid contains. Reported as the most reassuring failure, the
least reassuring success, and the fraction of the **comparison set** lying between them. The comparison set is the failing scenarios plus the nominal ones; the intermediate band belongs to neither and is excluded from the denominator as well as from both sides.

**Nominal means nominal, and the band is two-sided.** The first version contrasted failing
scenarios with merely non-failing ones, which lumps a scenario covering at 0.91 in with one
covering at 0.950. Round 3 found the repair still one-sided, so a scenario covering at **1.000**
counted as nominal and sat on the good side: gross overcoverage is not nominal, it is a different
failure, and the `absent` state under a wide prior produces it by having no likelihood information
at all. Nominal is now $|{\text{coverage}} - 0.95| \leq$ `COVER_TOL`, and both the intermediate
band and the over-covering scenarios belong to neither side. That drops the nominal count from 241
to 165 and the comparison set from 493 to 417; every statistic still overlaps.

**Both forms of effective rank are analyzed.** Round 1 found the whole-model count computed and
never used, so one of the two summaries CMP-14 actually asks for appeared in no outcome. Primary
1 now covers the per-parameter likelihood-to-prior ratio *and* the whole-model count.

**Primary 2.** `additivity` against `ecological`, matched on spread, **total patient budget** and
prior scale, with synergy off. This is the comparison CMU-02 could not make. Reported as the pairs
whose contraction differs by less than 0.02 and what their coverage does.

**Round 4 found that this comparison changed the shared background network too, and it was right.**
With two arms in `ecological` against three in `additivity`, the states had ten and twelve arms, so
an equal patient budget gave the background studies for components 1, 2 and 4 different per-arm
sizes. Matching per-arm size instead recreates the round-1 defect of handing `additivity` 20% more
data, so neither of the two obvious fixes works. **The arm counts are matched instead**: every
state's target studies now carry three arms, so every state has twelve arms, 250 patients per arm and
an identical background. The added arm in `ecological` is component 1 alone, which is what
`additivity`'s third arm is built from, so the two target designs are structurally identical except
for the one thing the comparison is about: whether component 3 appears alone in an **aggregate** arm
or only inside the combination inside an **individual-data** arm.

With that fixed, **54 matched pairs differ in contraction by less than 0.02 while their coverage
differs by up to 0.951**, and the gap is now attributable to the evidence route alone rather than
partly to a bigger background network.

**Primary 3.** Within the confounded family, the rank correlation between contraction and
coverage. **Read the sign carefully: low contraction is the reassuring value, so a POSITIVE
correlation means the diagnostic becomes more reassuring as the answer gets worse.** The
column is named for what it means rather than for what it is, because a misread sign has cost
this program three fatal findings.

**Secondary, and labeled as grid-weighted.** Sensitivity, false-alarm rate and Youden index of
each registered threshold rule. These are averages over a grid someone chose and are reported
as such.

A scenario **fails** if coverage of the 95% interval for $\Gamma_{W,3}$ is below
`COVER_BAD = 0.90`.

## 7. E2: the nonlinear arm, rebuilt after round 1 destroyed its premise

E1 cannot contain the state CMP-14 is named for. On an identity link an aggregate arm mean
depends only on the covariate mean, so aggregate data carry interaction information *only*
through the between-study contrast in means. On a nonlinear link the arm mean depends on the
covariate variance as well, so a contrast in **variances** carries information the identity
link cannot.

**Round 1 found three defects here and all three held.** The state was rank deficient as
specified; the registered withdrawal rule compared the wrong pair of states using one of the
two summaries; and none of E2 existed, while the protocol claimed a sampler policy, refit rule
and failure handling were "registered in `R/00-config.R` alongside the rest" when that file
held a link name, five labels and two counts. **That is the registered-but-unimplementable
defect the previous study in this programme found five times, reappearing in round 1 of this
one.** It is the reason E2 is now code before it is prose.

**What E2 is.** An asymptotic nonlinear arm (`R/06-nonlinear.R`), computed from the Fisher
information of a logistic component model. A logistic likelihood is not conjugate, so there is
no closed-form posterior; what *is* closed form is the information, and from it the
large-sample posterior covariance and the large-sample sampling distribution of the mode.
**Every E2 coverage figure is a normal approximation and is labeled as one.** The corrected
`curvature` state is two aggregate studies at the same covariate mean with different covariate
SDs.

**What E2 is not.** It is not a fitted arm. No `multinma` model is run, no MCMC is involved,
and no sampler policy is registered, because none is needed for an information calculation and
registering one would repeat exactly the defect round 1 found. **A fitted arm remains future
work and is not registered here as a promise.**

**The mechanism, verified rather than asserted** (`R/06-nonlinear.R`):

| aggregate SD ratio | estimable on identity link | estimable on logit link |
|---|:--:|:--:|
| 1.0, equal SDs | no | no |
| 2.0, unequal SDs | no | **yes** |

Equal SDs give two identical equations and identify nothing on either link. Unequal SDs
identify the target on the logit link and not on the identity link, which is what makes
`curvature` a nonlinear-only state and is what the first version got wrong.

**The registered rule, now attached to the states E2 exists to compare.** The claim under test
is that `curvature` and `ecological` are the same *kind* of evidence, both unrandomized
between-study contrasts differing only in which moment carries them, and that no summary of
the information matrix should or does separate them from each other while all of them fail to
separate either from `additivity`.

- If, on the logit link, **contraction or either form of effective rank separates `additivity`
  from `ecological` or from `curvature` at any threshold** across the E2 scenarios, then E1's
  central claim is an artifact of the identity link and **is withdrawn**.
- If **`source_share` separates `curvature` from `ecological`**, then the claim that they are
  the same kind of evidence is wrong and the statistic is measuring something narrower than
  advertised; that is reported as a defect in the proposed replacement, not hidden.
- **Exploratory, not confirmatory.** If `curvature` proves **estimable with equal aggregate SDs**
  on the logit link, the mechanism above is wrong and the state is withdrawn. This condition was
  **checked before it was written down**: `R/06-nonlinear.R` was run, its answer read, and the
  rule then recorded. Round 2 found it presented as a registered test and it is not one. It is
  retained as a standing guard in `R/07-run-e2.R`, which stops the run if it ever fails, but it
  cannot be counted as confirmatory evidence.

**E2 has been run and none of the three conditions fires.** It was run after these rules were
committed, so the rules are registered with respect to it even though E1's are not.

| registered rule | fires? |
|---|:--:|
| contraction separates additivity from ecological | no |
| target_ratio separates additivity from ecological | no |
| eff_rank separates additivity from ecological | no |
| contraction separates additivity from curvature | no |
| target_ratio separates additivity from curvature | no |
| eff_rank separates additivity from curvature | no |
| `share_within` separates `curvature` from `ecological` | no; both are 0 |
| `share_curv` separates `curvature` from `ecological` | **yes** |
| `curvature` estimable with equal aggregate SDs | no |

**E1's conclusion is not withdrawn**: neither summary CMP-14 asks for separates any of these four
states from any other, on the nonlinear link as on the linear one.

**But the source-share condition fired, and it reverses something this study reported.** An
earlier version claimed E2 confirmed that `curvature` and `ecological` are the same kind of
evidence, because both scored 0 on `share_within`. Round 2 found that this could not have come
out otherwise: in both states every target-bearing row is aggregate, so both score 0 **by
construction**, and a safeguard that cannot fail is decoration. That report was arithmetic
presented as a finding, and it is withdrawn.

**The first repair was also wrong, and round 3 caught it.** It computed each route's
"precision" as the posterior marginal precision minus the prior's diagonal, then subtracted two
such quantities and reported their ratio. That is not a decomposition of Fisher information: when
a coordinate is not identified by a source, the expression still returns a positive number
supplied entirely by regularization. In the curvature state's aggregate rows it returned 0.2275
and 0.0072 for quantities whose prior-free value is **exactly zero**, and the ratio of those two
artifacts, 0.933 to 0.969, was reported here as this study's headline. **Withdrawn.**

**All of this is post hoc and is labeled so.** The statistic was not registered in advance in any
of its three forms: the two-way version was written with E1, the aggregate split was prompted by
round 2's finding that the two-way version could not fire, and the leave-one-source-out version by
round 3's finding that the split was not a decomposition. Round 3 asked for that to be stated
rather than left implicit. **The source-share results are exploratory throughout**, they are not
covered by any registered rule, and the only registered thing about them is that E2 must report
whether they separate the two aggregate routes, which it does.

**The well-posed question is leave-one-source-out, and it is cleaner than either attempt.**
Asking what share of a parameter's precision comes from each source presumes each source
identifies it alone; in the curvature state none does, because the aggregate rows carry the target
while the individual-data rows are what pin down the prognostic slope and study intercepts it must
be separated from. Asking instead how much precision *survives* when a source is deleted needs no
additivity and no prior. Computed that way, from the likelihood's own marginal precision
$1/[I^{-1}]_{gg}$, and exactly zero where the likelihood does not identify the coordinate at all:

| state | share surviving without aggregate rows | share lost without the variance contrast |
|---|---:|---:|
| `own_ipd` | **1** | 0 |
| `additivity` | **1** | 0 |
| `ecological` | 0 | 0 |
| `curvature` | 0 | **1** |
| `absent` | undefined | undefined |

Exact zeros and ones, not artifacts near them, and the three identified routes separate pairwise.
`absent` is undefined rather than zero, because a parameter the likelihood does not identify at
all has no shares to apportion.

**What that changes and what it does not.** The claim that both routes are *unrandomized* stands,
and it is the claim that carries the causal argument: nobody randomized a study's covariate
spread any more than its mean. What does not stand is the stronger claim that no summary should
or does distinguish them. One does, it costs nothing, and it is strictly more informative than
either summary CMP-14 asked for. The study's proposed replacement is therefore a **three-way**
decomposition, into randomized within-study information, the between-study mean gradient and the
between-study curvature route, and the two-way version reported earlier was too coarse.

## 8. Every design choice changed after seeing a number

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

## 9. What this cannot settle

- **Additivity is assumed in three of the four E1 states.** Whether it holds is CMP-13's
  subject. State `additivity`'s causal standing is conditional on it, and the synergy arm
  prices that conditionality rather than removing it.
- **One continuous covariate**, one binary component structure, a single target component.
- **Conditional estimand only.** Nothing is claimed here about a target-population marginal
  contrast; that is a further step and a further set of assumptions.
- **Numerical summaries only.** A prior-versus-posterior plot read by an experienced analyst
  is a different instrument and is not evaluated.
- **Two of the three thresholds are conventional and one is this study's own.** `CONTRACT_OK` and
  `EFF_RATIO_OK` are taken from how such summaries are described rather than tuned. `SOURCE_OK`
  cannot be conventional, because `source_share` is introduced here: no prior source defines the
  statistic, so no prior source defines a cut point for it. Round 2 found all three described as
  conventional. Its 0.50 is a stipulation, chosen as the point at which randomized evidence stops
  being the majority contributor, and the secondary table is the only outcome that depends on it.
  Primary 1 depends on none of them.
- **E1's identity link cannot represent aggregate curvature**, which is the state CMP-14 is
  named for; E2 covers it.
- **E1's diagnostics are conditional on the expected covariate design.** Individual-data arms
  are represented by Gauss-Hermite nodes, so every E1 number is exact for a study whose
  covariate distribution is realized exactly and is an expectation otherwise. Realized
  contraction carries replicate-level variation that E1 does not measure.
- **E2 is asymptotic, not fitted.** Its coverage figures are normal approximations from the
  Fisher information. No `multinma` model is run and no posterior is sampled, so nothing here
  measures MCMC error or the behavior of these summaries under a genuinely non-conjugate
  posterior. A fitted arm is future work.
- Fixed-effect synthesis, known residual variance, correctly specified linear mean.
