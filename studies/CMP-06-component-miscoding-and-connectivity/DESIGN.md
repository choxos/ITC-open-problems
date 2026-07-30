# CMP-06 design: a coding error that changes the rank, not the coefficient

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note says to narrow to either covariate measurement error or
component miscoding, and that the latter offers the clearer experiment. **This
design takes the miscoding half only**, and section 2 says why that is not a
matter of taste: miscoding is a qualitatively different kind of error and the
measurement-error machinery does not apply to it.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the component matrix is derived by deterministically
parsing treatment labels with no probability model for assignment; because a
bridge exists exactly when two subnetworks share a component, a coding error can
change the design matrix, its rank and its row space, and so create or remove
shared-component paths rather than perturbing a coefficient.

**Refuting sentence:** *plausible miscodings leave the row space intact, so their
effect is a small perturbation of an estimate rather than a change of what is
estimable, and standard sensitivity analysis covers it.*

## 2. The mechanism: this is a discrete change in identifiability

Let $C$ be the regimen-by-component matrix and $X(C)$ the resulting design. The
target cross-gap contrast $g$ is estimable if and only if

$$g \in \mathrm{rowspace}\big(X(C)\big),$$

equivalently $X(C)\,X(C)^{+}g = g$. **That is a yes-or-no property of $C$, not a
continuous function of it.** Flipping one component assignment changes a row of
$C$, which can change $\mathrm{rank}(X)$ by one, which can move $g$ into or out of
the row space.

Three consequences that separate this from measurement error:

1. **The failure is not attenuation.** Measurement error in a covariate
   attenuates an interaction toward zero, with a direction that depends on the
   error structure. Miscoding can take an estimand from *identified* to *not
   identified*, and there is no bias to correct because there is no estimate.
2. **Regression calibration and SIMEX do not apply.** They correct a biased
   estimate; they cannot restore a rank. The mature machinery the catalog names
   exists for the covariate half and does **not** carry over to this half, which
   is a reason to separate them rather than run them together.
3. **Not every miscoding matters, and which ones do is computable in advance.**
   For a candidate coding set $\mathcal{C}$, the analyst can check $g \in
   \mathrm{rowspace}(X(C))$ for every $C \in \mathcal{C}$ **without any data**.
   **That is the diagnostic the catalog asks for as its first deliverable**, and
   it is a rank computation, not a study.

The study's job is therefore not to discover that miscoding matters. It is to
measure **how often plausible codings move the estimand across the identifiability
boundary, what happens to inference in the cells where they do not, and whether
probabilistic coding produces honest intervals in the cells where they do.**

## 3. Estimand, with its true value defined

**Primary.** The target-population cross-gap component-regimen contrast, on the
scale of the fitted model.

**True value** from the generating model, over the declared target population, by
quadrature at an order fixed by P1.

**Estimability is a second, binary estimand with a defined truth**: whether $g$
lies in the row space under the **true** coding. A replicate in which the true
coding does not identify $g$ is not a replicate about miscoding, and P2 verifies
that every cell's true coding identifies it. CMP-14 shipped a rank-deficient
state through four rounds of review by not doing this.

## 4. Data-generating mechanism, and what it makes invisible

Two subnetworks connected only through a shared component, which is the geometry
in which a bridge exists at all.

### Factors

| factor | levels | why |
|---|---|---|
| miscoding probability per regimen | 0, 0.05, 0.15 | 0 is the null control |
| miscoding type | **connectivity-changing** (the shared component); **connectivity-preserving** (a component internal to one subnetwork) | **section 2's distinction**, and the design's central manipulation |
| component effect heterogeneity | additive; with synergy | whether the miscoded component's effect is separable at all |
| covariate overlap | good, poor | the usual axis |
| network size | 6 studies, 12 studies | how much redundancy exists to absorb a miscoding |
| effect-modification strength | 2 levels | the multiplier on any resulting bias |

### What the mechanism makes true, and therefore what the study cannot see

- **Covariates are measured without error throughout.** That half of CMP-06 is
  deliberately excluded and the paper's title and abstract say so. Running both
  would make every result unattributable, which is the reason the catalog's note
  recommends narrowing.
- The set of plausible codings is supplied to the estimator as a prior. In
  practice an analyst constructs that set by reading trial reports, and its
  adequacy is not tested here; a coding error outside the plausible set is
  invisible to every method in section 5, and that is stated rather than
  discovered.
- Component effects are constant over time. CMP-18 owns time-varying component
  effects.
- Miscoding is independent across regimens. Systematic miscoding driven by a
  reporting convention would be correlated and is not covered.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| deterministic coding, true $C$ | oracle | the ceiling |
| deterministic coding, miscoded $C$ | one wrong coding, taken as certain | current practice |
| **probabilistic coding** | posterior over $C$ within the plausible set, propagated into the design matrix and the estimand | the proposed fix |
| coding sensitivity | refit at each plausible $C$, report the range | the cheap deployable version |
| **estimability screen** | the rank check of section 2 consequence 3, reported before fitting | the first deliverable, and it costs no fitting at all |

**The comparator that can win is coding sensitivity.** If refitting over the
plausible set and reporting the range gives intervals with the coverage that
probabilistic coding gives, then the fix requires no new model and the
recommendation is a workflow change. Registered as the outcome most likely to
overturn the expected headline, and it is by far the cheaper answer.

## 6. Performance measures, MCSE, and $n_{sim}$

**Conditional on estimability**, which must be stated because averaging over
replicates where the estimand does not exist is meaningless: bias, coverage,
interval width, with MCSE.

**Unconditionally:** the probability the target contrast becomes non-estimable
under the miscoded coding; the topology-selection error rate, meaning how often
the inferred bridge structure differs from the true one; and the fraction of
replicates in which a method returns a confident estimate for a contrast that is
not identified under the coding it used. **That last number is the one that
matters most**: a finite interval for a non-identified quantity is the failure
mode, and CMP-14 found its own statistic returning positive values for
quantities whose prior-free value is exactly zero.

Prior-free marginal precision from CMP-14 is reported for every Bayesian arm, so
"the interval is finite" is never read as "the data identified it".

Common random numbers across coding methods; MCSE clustered on the replicate
block. $n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the target cross-gap contrast under
deterministic miscoded coding versus probabilistic coding, in the
connectivity-changing miscoding cells, conditional on estimability under the
true coding.

**Decision rule.**

- Deterministic miscoding undercovering materially while probabilistic coding is
  nominal **confirms** the problem and establishes propagation as necessary.
- Coding sensitivity matching probabilistic coding means the fix is a workflow
  change rather than a model change, and that is the recommendation.
- Both nominal at plausible miscoding rates **refutes** materiality for
  inference, in which case the deliverable is the estimability screen alone,
  which remains worth having because it is free.

**The screen's operating characteristics are registered separately:** it is useful
only if it flags essentially every replicate where the contrast is in fact
non-estimable under the used coding, at a false-positive rate below a declared
level. A screen with a high false-positive rate would stop analyses that are fine.

## 8. Three controls, each of which can fail

**Null control.** At zero miscoding probability every method must coincide with
the oracle. Divergence is implementation error.

**Second null control, and it is the design's central check.** Under
**connectivity-preserving** miscoding, section 2 says the row space is unchanged,
so the contrast stays estimable and the error is a coefficient perturbation. The
estimability screen must **not** fire, and deterministic coding must remain
approximately nominal. **If connectivity-preserving miscoding breaks inference as
badly as connectivity-changing miscoding, the distinction section 2 is built on is
not operative** and the study's framing is wrong.

**Positive control.** Under connectivity-changing miscoding at the highest rate,
the target contrast must become non-estimable in a substantial fraction of
replicates. If it never does, the network has enough redundancy that a single
shared component is not load-bearing, and the design has not built the geometry
the problem describes.

**Falsifier for the study's own headline.** The expected headline is that coding
uncertainty must be propagated. Its falsifier is the coding-sensitivity arm
succeeding, which would make propagation unnecessary. It is included for that
reason and not as a robustness check.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Covariate error and miscoding confounded | Covariate error excluded entirely; stated in title and abstract | removed |
| Averaging over replicates where the estimand does not exist | Every inferential measure conditional on estimability, stated | removed |
| A finite interval for a non-identified contrast read as an estimate | Prior-free precision reported; the frequency of that failure is a primary-level outcome | removed |
| True coding itself rank deficient | P2 verifies estimability under the true coding in every cell | removed |
| Plausible coding set assumed adequate | Stated as untested scope | disclosed |
| Correlated systematic miscoding | Independent miscoding only | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The true cross-gap contrast per cell | The definition of truth | minutes |
| **P2** rank map | Estimability of $g$ under the true coding **and** under every plausible miscoding, in every planned cell, before any fitting | **The grid.** This is the same probe IDN-06 and CMP-14 need and the same one CMP-14 skipped; a cell whose true coding does not identify the target is a broken cell | hours |
| **P3** probabilistic coding feasibility | Whether a posterior over $C$ can be sampled jointly with the model, or whether it must be done by model averaging over a fixed set | Whether the propagation arm is a single fit or an average, which changes both its cost and its interpretation | hours |
| **P4** unit cost | Per-fit wall clock; total computed not typed | The grid | hours |

## 11. Cost

Stan-dominated, and the probabilistic-coding arm multiplies by the size of the
plausible coding set unless P3 finds a joint sampler. Unpriced until P3 and P4.

---

## Relationship to the rest of the queue

- **CMP-14** supplies the prior-free precision and the rank machinery; its route
  table and `lik_marginal_precision` are imported rather than rebuilt.
- **COV-09** owns measurement non-equivalence of covariates across trials, which
  is the covariate half this design excludes, and is where that half belongs.
- **DIS-11** and **IDN-08** own bridge validation, which is what a miscoding-
  induced topology change would invalidate.
- **CMP-03** owns whether strict additivity is clinically false, which changes
  what a component even is.
- **MIS-04** owns model and bridge selection uncertainty entering the interval,
  of which coding uncertainty is one instance.
