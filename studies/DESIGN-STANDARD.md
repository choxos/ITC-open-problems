# What a design document must contain

Seven studies have been through this program. Between them they absorbed
somewhere over two hundred findings from adversarial pre-run critique, and the
findings are not evenly spread: the same eleven mistakes keep recurring, in
different studies, under different names, made by me each time.

This file is those eleven mistakes turned into a checklist, and every section
below names the study that produced it. It is applied to a design **before** the
design is probed or reviewed, because every item on it was found late and
expensively at least once.

A design that satisfies this checklist is not registered. Registration needs the
probes in section 10 to have been run and the numbers they produce written into
the document. The distinction matters: **the difference between a design and a
protocol is a set of computed numbers**, and a design that asserts those numbers
instead of computing them is the specific failure mode that produced three of
OUT-11's fatal findings.

---

## 1. The claim, restated as something that can be false

The catalog entry is prose. Restate it as a proposition with a truth value, and
then write the sentence that would make it false.

CMP-13's catalog entry says aggregate data cause a shared interaction to
conflate within-trial and across-trial modification. Restated: *the loss requires
aggregate arms*. That is false, and the study found it false, because the loss is
present with twelve IPD trials. Had the entry been carried as prose, the study
would have confirmed a weaker claim and never noticed the stated mechanism was
wrong.

**Required:** the proposition, the refuting sentence, and which of the two the
study is powered to detect. A design that can only confirm is not a study.

## 2. The mechanism, algebraically

State what inside the estimator produces the behavior. Not "the model may be
biased" but the identity, the score equation, or the rank deficiency.

CMP-13's whole result rests on one line: for a binary modifier with study
prevalence $p_s$, a shared interaction on a globally centered covariate is
algebraically identical to imposing $\beta_W = \beta_B$. OUT-11 needed the Cox
least-false parameter (Struthers and Kalbfleisch 1986) solved by root-finding the
limiting score equation, because without it "the truth" for a misspecified Cox
model is undefined and every bias number is uninterpretable.

**Required:** the algebra, and a statement of what it predicts before anything is
simulated. If the mechanism is not derivable, say so; that is a finding about the
problem and it changes what the study can claim.

## 3. One estimand, with its true value *defined*

Name it, give its scale, and define how its true value is computed. "The true
treatment effect" is not a definition when the estimator is misspecified.

This is where OUT-11 spent the most: a hazard ratio reported by a proportional
hazards model fitted to non-proportional data does not estimate any parameter of
the data-generating mechanism, so bias against the "true HR" is a comparison to a
number that does not exist. The least-false parameter is the definition that
makes it exist.

**Required:** estimand, scale, target population, and the computation that gives
its true value. If the true value is only available by numerical integration or
root-finding, that computation is one of the probes in section 10.

## 4. Data-generating mechanism, and what it makes invisible

Factors, levels, what is crossed, what is held fixed, and the replicate count.

Then a subsection nothing else replaces: **what the mechanism makes true, and
therefore what the study cannot see.** CMP-13 carries one. Under its discordance
patterns the split model is correctly specified, so the study measures the cost
of a known restriction rather than establishing that real networks contain such
disagreement. Writing that down is what stopped the manuscript claiming the
latter.

**Required:** the factor table, the fixed quantities with their values, and the
invisibility list. Any factor dropped after a probe was read goes in section 9.

## 5. Methods, including one that can win

A comparison whose winner is determined by the design is not a comparison.

CMP-13 included a study-clustered sandwich specifically so the result could not
be attributed to the variance estimator, and reported that it covered 75.4% to
92.4% with twelve clusters, as a finding rather than as the comparator. That is
what a fair comparator looks like: it was given a real chance and its failure is
reported.

**Required:** every method with the exact specification it will be fitted under,
and at least one comparator whose success would weaken the study's expected
headline. Name which one that is.

## 6. Performance measures with Monte Carlo standard errors, and $n_{sim}$ derived

Every measure carries an MCSE. The replicate count is derived from a target MCSE,
not chosen round.

Two refinements both bought with real findings. **Cluster the MCSE when the
design uses common random numbers**, because paired replicates are not
independent and OUT-11's per-cell errors were wrong until they were blocked on
`(param_id, rep)`. **A bootstrap or resampling step has its own Monte Carlo
error**, and in OUT-11 that endpoint error measured about 3.1% of interval width
on production data, which is not negligible and was nearly dropped as such.

**Required:** measures, their MCSE formulas, the clustering unit if any, the
target MCSE, and the $n_{sim}$ that follows from it.

## 7. Primary outcome and decision rule, before the run

One primary outcome. The rule that maps its value to a conclusion, written so
that someone else applying it to the results gets the same conclusion.

The rule must be two-sided where the measure is. CMP-14 registered nominal
coverage one-sided and 76 over-covering scenarios counted as successes until
round 3 caught it. Gross overcoverage is not a pass.

**Required:** the primary outcome, the decision rule, the refutation threshold
from section 1, and an explicit statement that a near-miss is reported as a
near-miss. CMP-13 missed its refutation threshold at 47% against 50% and reported
that rather than moving it.

## 8. Three controls, each of which can fail

- **Null control.** In a condition where the mechanism is switched off, nothing
  fires. Scope it: CMP-14's null control failed in 54 scenarios at the tight
  prior, which was the prior doing exactly what it was added to do, so the
  control is registered restricted to `prior_sd >= 0.5` and the restriction is
  stated.
- **Positive control.** In a condition where the mechanism is at full strength,
  the diagnostic must fire. A diagnostic that cannot fire is not a diagnostic:
  CMP-14's source statistic scored two states at zero by construction for two
  rounds, so its agreement with a second statistic was arithmetic.
- **Falsifier for the study's own headline.** The condition under which the
  study's expected answer is wrong, run at enough replicates to detect it.

**Seven of CMP-14's controls were written from expectation, failed, and had to be
restated.** That sequence is how a control becomes decorative. Each control here
says what it now tests, not only that it passes.

## 9. Threats, and what happened to each

A table: threat, what was done, and whether it is removed or disclosed. A threat
that is disclosed rather than removed is fine; a threat that is silently absent
is not.

Include every design choice made after seeing a number. CMP-14 carries eleven,
because an exploratory computation that preceded the protocol makes every later
choice suspect unless the changes are listed. If a factor was dropped after a
probe, it is here.

## 10. The probes that must run before this is a protocol

The explicit list. Each probe names the number it produces and the section that
number goes into. This is the section that separates this document from a
registered protocol, and it exists because:

- **A cost that is typed is wrong.** OUT-11 produced two fatal budget findings,
  both a total that did not follow from the unit costs three lines above it. Its
  budget is now computed in `R/10-budget.R` from measured timings and asserted
  against the document.
- **An identifiability claim that is asserted is wrong.** CMP-14 registered
  "variance is the unique nonlinear aggregate route" and it was false; the guard
  passed only because every study intercept happened to be equal. The route table
  is now computed in `R/08-routes.R` with all four cells asserted.
- **A precision that includes the prior is not evidence.** CMP-14's source
  statistic returned 0.2275 and 0.0072 for quantities whose prior-free value is
  exactly zero, and the ratio of two prior artifacts was very nearly this
  study's headline.

**Required:** probe name, what it computes, what it would take to change the
design, and its rough cost.

## 11. Cost, and what it depends on

Wall clock at a stated concurrency, derived from a measured unit cost, with the
sensitivity program priced per fit set rather than per arm. OUT-11's sensitivity
program was priced at roughly half its minimum cost because "halved and doubled"
priors was costed as one fit set when it is plainly two.

**Required:** the unit cost, its source (measured or extrapolated, labeled), the
number of fits, and the total. Where a number is extrapolated, say from what.

---

## Two operational rules that are not about design

**Nothing typed twice.** Any number appearing in both code and prose is emitted
from the code and asserted back independently. Three of this program's fatal
findings were stale numbers, and each repair by retyping produced the next one.

**Anything long-running records the code that produced it.** An E3 process ran
for eleven hours holding a sampler policy that had been replaced, because R loads
source at `source()` time and nothing in the output said which version was
loaded. Checkpoints now carry the modification time of the code and the policy
constants in force.
