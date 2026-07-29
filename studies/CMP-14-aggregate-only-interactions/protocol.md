# Protocol: what would the two summaries CMP-14 asks for actually tell an analyst?

**Target problem.** CMP-14 *Aggregate-data-only interactions may be prior-driven*. Bears in
part on IDN-06 *ML-NMR interactions can rest solely on aggregate-data variation*.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Provenance.** Every number this document prints is exported from the code that computes it
by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export,
currently **64** assertions. The four controls in section 5 are asserted against the values
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
- **E2 is confirmatory and is registered blind.** It has not been run. It tests the same
  claims in the setting where they cannot be deduced: a nonlinear link, where aggregate
  curvature carries real information, fitted by MCMC rather than solved.

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
| **curvature** | a single aggregate study on a **nonlinear** link, whose arm mean depends on the covariate variance | yes, but weak | — | ✓ |
| **absent** | nothing; the coordinate is rank-deficient | n/a | ✓ | ✓ |

**`additivity` is the state component methods create and no other design has**, and
**`curvature` exists only on a nonlinear link**, which is why CMU-02's identity-link design
could not contain it and why E2 is necessary rather than decorative.

The target is component 3 throughout. Components 1, 2 and 4 stay in `own_ipd`, so the network
is otherwise well identified and the target's behavior is not confounded with a globally weak
design. Every state carries the same total number of patients.

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
| `source_share` | share of the target's marginal likelihood precision contributed by **randomized within-study rows** rather than by the between-study gradient | **this study's candidate replacement** |

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

**A consequence that is a result, not a convenience.** The posterior covariance is
$(I + P_0)^{-1}$, which contains no data. **Contraction and effective likelihood rank are
therefore functions of the design alone, computable before a single patient is enrolled.**
Whatever they measure, it cannot be anything about what the data turned out to say. The unit
of analysis is consequently the scenario, and there is no replicate count.

**The grid**, a full factorial with two structural restrictions (`R/03-run-e1.R`):

| factor | levels |
|---|---|
| information state | own_ipd, additivity, ecological, absent |
| between-study covariate spread | 0.3, 0.6, 1.0, 1.4, 2.0, 3.0 |
| discordance $\Gamma_B - \Gamma_W$ | 0.00, 0.15, 0.40 (ecological only) |
| arm size | 100, 300, 1000 |
| prior SD on interactions | 0.1, 0.5, 1.0, 2.5 |
| synergy (additivity violated) | 0.00, 0.20 (additivity only) |

**504 scenarios**. Discordance acts only through aggregate rows carrying the target and
synergy only through arms holding components 1 and 3 together, so carrying either into a
state that has neither would add scenarios bit-identical to their zero twins and inflate
every count.

**Four controls, all of which must hold or the run stops** (`R/03-run-e1.R`):

1. **Absent is prior-only.** Contraction $> 0.999$ in every absent scenario.
2. **Null control.** With no discordance, no synergy and a prior that is not itself the
   problem, coverage is nominal.
3. **Prior-domination positive control.** At the tightest prior and smallest arm size,
   coverage is below nominal in *every* state alike, which is what shows the mechanism is the
   prior and not the evidence structure.
4. **Both kinds of prior-driven parameter are present.** The absent state must cover the truth
   essentially always under a wide prior and essentially never under a tight misplaced one.
   Without both, the grid contains only the harmless kind and the comparison is rigged.

## 6. Outcomes

**Primary 1, and the only one no weighting can move.** For each statistic, does the range of
values taken by *failing* scenarios overlap the range taken by *nominal* ones? A single value
compatible with both a nominal and a badly failing scenario establishes that **no threshold
separates them**, whatever the grid contains. Reported as the most reassuring failure, the
least reassuring success, and the fraction of the grid lying between them.

**Primary 2.** `additivity` against `ecological`, matched on spread, arm size and prior scale,
with synergy off. This is the comparison CMU-02 could not make. Reported as the pairs whose
contraction differs by less than 0.02 and what their coverage does.

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

## 7. E2: the confirmatory arm, registered blind and not yet run

E1 cannot contain the state CMP-14 is named for. On an identity link an aggregate arm mean
depends only on the covariate mean, so aggregate data carry interaction information *only*
through the between-study contrast. On a **nonlinear** link the arm mean depends on the
covariate variance as well, so a single aggregate study carries information with no
between-study contrast at all. That is the `curvature` state, and whether the two summaries
distinguish it from `ecological` is the question E1 is structurally unable to answer.

**Registered before running:** logit link, five states including `curvature`, 24 scenarios,
200 replicates each, fitted with `multinma`. Because the posterior is no longer conjugate,
contraction acquires genuine replicate-level variation and MCMC error enters, so E2 also
measures how much of E1's conclusion survives the approximation. Sampler policy, refit rule
and failure handling are registered in `R/00-config.R` alongside the rest.

**E2 is blocked on hardware**, not on design: the OUT-11 benchmark currently holds the
machine. It runs when that finishes.

**What E2 would have to show for E1's conclusion to be withdrawn.** If, on a nonlinear link,
contraction separates `ecological` from `additivity` at any threshold across the 24 scenarios,
then E1's central claim is an artifact of the identity link and is withdrawn.

## 8. Every design choice changed after seeing a number

Recorded because E1 was computed before this document existed, and a disclosure list is the
only thing that makes an exploratory exact computation interpretable.

| change | why | what it would have hidden |
|---|---|---|
| Added `PRIOR_SD = 0.1` | The first grid had the absent state covering the truth 100% of the time: the likelihood contributes nothing, the posterior is the prior, and a wide prior still contains a truth 0.40 away. The diagnostics' positive control was never a failure, so flagging it counted as a false alarm | It made every diagnostic look worse than it is, by scoring a correct warning as a false alarm |
| Null-control guard restricted to `prior_sd >= 0.5` | The first version required nominal coverage whenever discordance and synergy are zero, and it failed in 54 scenarios, all at the tight prior. That is the tight prior doing what it was added to do, not a defect | It would have conflated a prior-induced failure with a confounding-induced one |
| Prior-domination control restated at the smallest arm size | The first version asserted collapse at the tight prior in every state; measured, coverage recovers to 0.94, 0.84 and 0.80 at $n = 1000$ as the likelihood wins. Correct behavior, wrongly asserted away | It would have asserted a false claim about the tight prior's reach |
| Every state given equal total patients | An earlier layout gave `additivity` one study fewer, so it looked worse than `own_ipd` partly on sample size | A difference of sample size reported as a difference of evidence structure |

Two of those four were guards written from expectation rather than from measurement, and both
failed. The third was written only after printing the numbers first. That sequence is recorded
rather than tidied, because "assert, observe failure, weaken assertion" is exactly how a
control becomes decorative, and the disclosure is what stops it.

## 9. What this cannot settle

- **Additivity is assumed in three of the four E1 states.** Whether it holds is CMP-13's
  subject. State `additivity`'s causal standing is conditional on it, and the synergy arm
  prices that conditionality rather than removing it.
- **One continuous covariate**, one binary component structure, a single target component.
- **Conditional estimand only.** Nothing is claimed here about a target-population marginal
  contrast; that is a further step and a further set of assumptions.
- **Numerical summaries only.** A prior-versus-posterior plot read by an experienced analyst
  is a different instrument and is not evaluated.
- **The thresholds are the conventional ones**, taken from how such summaries are described
  rather than tuned. Primary 1 does not depend on them; the secondary table does.
- **E1's identity link cannot represent aggregate curvature**, which is the state CMP-14 is
  named for. That is E2's job and until E2 runs the study answers the component-routing
  question and not the curvature question.
- Fixed-effect synthesis, known residual variance, correctly specified linear mean. Nothing
  transfers directly to a non-conjugate posterior, which is again E2's job.
