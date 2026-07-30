# HET-03 design: defending or abandoning a default on network size

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The modeling work is largely done and the catalog says so.** Four replacements for the
homogeneous-variance assumption were built and compared in 2013; empirically derived
heterogeneity priors exist for 80 settings; weakly informative priors exist for the
very-few-studies case; and class-specific variance components with sharing across sparse
classes ship in `multinma` via `class_sd`, **though that is a within-class treatment
standard deviation rather than $\tau$.**

**What has not been done is the distinguishability question**, and the note restricts this
to realistic ML-NMR network sizes. **That is the study.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** networks rarely contain enough studies per class to estimate
separate variances, so a separate-variance model is often only nominally identified and its
posterior is driven by the prior; model comparison statistics have little power to
distinguish competing variance structures at realistic sizes; **and no one has established
the size at which they become distinguishable, so the default is neither tested nor visibly
violated.**

**Refuting sentence:** *at the network sizes ML-NMR is applied to, structures are
distinguishable often enough that a data-driven choice is defensible, so the shared default
is a convenience rather than a necessity.*

## 2. The mechanism: a variance component with no likelihood information looks fitted

A separate-variance model adds $\tau_k$ per class. With $m_k$ studies in class $k$, the
likelihood information about $\tau_k$ scales roughly with $m_k$, and **for small $m_k$ the
posterior for $\tau_k$ is essentially its prior.** Three consequences:

1. **The fit does not announce this.** A weakly identified $\tau_k$ produces a proper
   posterior with a plausible interval, so the model converges, reports, and is compared on
   fit like any other. **CMU-02's finding applies exactly**, and its prior-free marginal
   precision is the instrument that distinguishes a fitted variance component from a
   restated prior. **It is imported rather than rebuilt.**
2. **Model comparison inherits the problem.** Comparing a shared-$\tau$ model against a
   separate-$\tau$ one when the latter's components are prior-driven compares a model
   against a prior, **so selection accuracy is bounded by identification and not by the
   criterion's power.** That is why the distinguishability question must be answered before
   any selection recommendation.
3. **The direction of the error under a wrong default is not obvious and is a reported
   outcome.** A shared $\tau$ pooled across heterogeneous and homogeneous classes inflates
   the homogeneous class's intervals and deflates the heterogeneous one's, so **coverage
   fails in opposite directions in different parts of the same network** — which CMP-16
   finds for the bridge and which here affects every class's treatment effects.

**The genuinely new case is heterogeneity indexed by target population**, which none of the
existing work addresses and which the software cannot currently express, since the parameter
is a single network-wide scalar. **That arm is carried as a specification question**: whether
a target-indexed $\tau$ is identified at all in a mixed IPD-and-aggregate network, which P3
answers before anything is fitted.

## 3. Estimand, with its true value defined

**Primary.** The target-population treatment effect under each variance structure, by
quadrature at an order fixed by P1.

**Two derived estimands.** **Selection accuracy**, whether the true structure is chosen; and
**heterogeneity-parameter coverage**, which is where consequence 1 shows.

**The distinguishability threshold is the deliverable**: the studies-per-class at which
selection accuracy exceeds a declared level, reported per structure pair. **A single number
would be an average over pairs that differ**, so it is reported as a table.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **studies per class** | 2, 4, 8, 16 | **the axis, and the deliverable's units** |
| true variance ratio across classes | 1 (shared is true); 2; 5 | how far apart the structures are |
| number of classes | 2, 4 | how thin the data get |
| prior informativeness | vague; weakly informative; empirically derived | consequence 1, and the entry's three available prior families |
| target-indexed heterogeneity | absent; present | the new case, if P3 says it is expressible |

**Studies per class crossed with the variance ratio is the design**, since together they
determine whether a difference exists and whether it is visible.

### What the mechanism makes true, and therefore what the study cannot see

- **The answer will be scenario-dependent**, which the note says and which the deliverable's
  form accepts: a table by studies-per-class and variance ratio, not a rule.
- **Component-specific variances need further assumptions about the covariance among
  component deviations**, and any structured alternative must keep the random-effects
  covariance positive semidefinite. **That constraint is why existing proposals have not
  displaced the default**, and P2 verifies every candidate satisfies it rather than
  discovering it mid-run.
- `class_sd` is a within-class treatment standard deviation, **not $\tau$**, so it is not
  treated as an existing implementation of the structure under test.
- One outcome family.

## 5. Methods, including one that can win

| structure | role |
|---|---|
| single shared $\tau$ | the default under test |
| separate $\tau_k$ per class | the unconstrained alternative |
| exchangeable $\tau_k$ around a common mean | the shrinkage alternative |
| consistency-constrained variances | the 2013 alternative |
| **target-indexed $\tau$** | the new case, if expressible |

**The comparator that can win is the single shared $\tau$.** If it gives nominal
treatment-effect coverage at realistic sizes even when it is wrong, **the default is
defensible on the grounds it was adopted for**, and the deliverable is the size threshold
below which nothing better is available. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Selection accuracy; **heterogeneity-parameter coverage**; **treatment-effect coverage by
class**, since consequence 3 predicts failures in opposite directions; interval width; with
MCSE.

**Prior-free marginal precision for every $\tau_k$**, which is consequence 1's instrument
and separates a fitted variance from a restated prior. **Reported alongside the posterior,
so a reader can see which is which.**

**Prior sensitivity**: the movement of the treatment effect across the three prior families,
reported rather than claiming any prior is universally robust, which the entry warns
against.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Selection accuracy between shared and separate structures at a true
variance ratio of 5, across the studies-per-class axis.

**Decision rule.**

- Accuracy crossing a declared level at some studies-per-class: **the threshold is the
  deliverable**, and a default can be defended below it and abandoned above it.
- Accuracy never crossing at realistic sizes: **the default cannot be tested from the data**,
  and the recommendation is prior-based structure selection with the prior stated, which is
  what the empirically derived priors are for.
- **Treatment-effect coverage by class is reported in either branch**, because consequence 3's
  opposite-direction failure is the practical harm and does not depend on selection.

## 8. Three controls, each of which can fail

**Null control.** With a true variance ratio of 1, the shared structure is correct, so it must
be selected at approximately its nominal rate and must be most efficient. **A separate-$\tau$
model winning there is overfitting and its selection criterion is miscalibrated.**

**Second null control.** At 16 studies per class with a ratio of 5, every structure must be
identified and selection accuracy must be high. **That is the large-sample regime**, and
failing it means the criterion rather than the data is the problem.

**Positive control.** At 2 studies per class, the separate-$\tau$ components' prior-free
precision must be near zero. **That is consequence 1 stated as a measurement**, and it is
checkable in P2 before any fitting.

**Falsifier for the study's own headline.** The expected headline is that a size threshold
exists. Its falsifier is consequence 3: **if treatment-effect coverage is acceptable under
the wrong structure across the whole grid, then distinguishability does not matter and the
threshold is an answer to a question nobody needs.** Coverage is therefore reported beside
selection accuracy throughout.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting existing structures as unbuilt | Credited in the header; four alternatives and three prior families carried | removed |
| `class_sd` treated as the structure under test | Identified as a within-class treatment SD, not $\tau$ | removed |
| A weakly identified variance component read as fitted | Prior-free precision reported beside the posterior | removed |
| A universal prior claimed robust | Prior sensitivity reported across three families | removed |
| Positive semidefiniteness assumed | Verified in P2 for every candidate | removed |
| A single threshold implying a rule | Reported as a table by structure pair and variance ratio | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Target effect truths per cell | The definition of truth | hours |
| **P2** identification map | Prior-free precision for each $\tau_k$ at each studies-per-class, and positive semidefiniteness of every candidate structure, **before fitting** | **The grid, and the positive control** | days |
| **P3** target-indexed expressibility | Whether a target-indexed $\tau$ is identified in a mixed IPD-and-aggregate network at all | **Whether the new case exists** | days |
| **P4** unit cost | Per-fit cost across five structures; total computed not typed | $n_{sim}$ | hours |

**P2 may answer the primary question before the simulation runs**, since a component with
zero prior-free precision cannot be selected on data at any criterion.

## 11. Cost

Five structures across a five-factor grid at 1000 replicates, Bayesian throughout. Bounded
by SFW-06.

---

## Relationship to the rest of the queue

- **CMP-16** owns the shared-$\tau$ problem where it changes the bridge's apparent support;
  this owns the network-wide distinguishability question. **They share a generator.**
- **CMU-02** supplies the prior-free precision and owns prior-driven posteriors.
- **HET-10** owns small-study intervals, the regime where these variance components live.
- **EST-11** owns the target menu that a target-indexed $\tau$ would be indexed by.
