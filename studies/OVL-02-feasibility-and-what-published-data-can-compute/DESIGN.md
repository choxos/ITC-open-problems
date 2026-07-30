# OVL-02 design: the optimizer returns weights for a problem with no solution

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Three studies in this queue touch overlap diagnostics and they must not be one
study written three times. **DIA-03 has run**: it scored the reported panel as
classifiers of realized error and proved algebraically that ESS, ESS/n and the
weight coefficient of variation are one statistic, and that the post-weighting
balance on matched moments is identically zero at the solution of the calibration
equations. **OVL-01 owns identification and abstention**: whether unsupported mass
matters depends on its alignment with effect modification, which no
covariate-space statistic can see.

**What is left for OVL-02 is the part neither covers, and Glimm and Yau supply the
striking fact it turns on:** the MAIC calibration problem can be provably
infeasible while `optim()` silently returns weights with an effective sample size
of 2% of $n$. That is not a diagnostic failing to warn. **That is a solver
returning an answer to a question with no solution.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** ESS is a concentration functional of the weight vector
and carries no information about where the weight mass sits, about omitted
moments, about the outcome model or about the adjusted edge's network position;
the missing battery items are partly hard rather than merely unimplemented,
because several are not computable when the target is known only through published
marginals; and infeasibility is not signaled.

**Refuting sentence:** *infeasibility is rare in realistic configurations and,
where it occurs, the resulting ESS is low enough that the existing convention
already catches it.*

**That refutation is precisely what Glimm and Yau's example contradicts in one
case and it has never been measured over a grid.** Establishing the rate is the
study's first job.

## 2. The mechanism: feasibility is a linear program, ESS is a by-product

The method-of-moments calibration has a finite solution **only if the target mean
lies in the convex hull of the source covariate rows.** That is a linear-program
feasibility question with a yes-or-no answer, and it is decidable exactly.

Three consequences:

1. **Infeasibility is a property of the data, and the optimizer's output under
   infeasibility is a property of the optimizer.** A quasi-Newton routine on the
   dual objective diverges slowly and stops on a tolerance, returning weights that
   satisfy nothing. **Nothing in the returned object distinguishes that from
   convergence**, which is why the failure is silent.
2. **A low ESS is a symptom, not a signal**, because low ESS also arises from
   feasible-but-difficult problems. **So ESS cannot separate "hard" from
   "impossible", and a threshold on it therefore either misses infeasible
   analyses or rejects feasible ones.** Which it does is measurable, and it is the
   primary outcome.
3. **The hull test on target *means* tests calibration feasibility, not support
   for the target joint distribution.** The catalog is careful here and the design
   must be: with published marginals only, a feasible calibration can still
   correspond to a target joint law with no support in the source. **So the
   feasibility item and the support item are different items**, and conflating
   them would overstate what the battery can deliver.

**That last point generalizes into the study's second deliverable: a computability
taxonomy.** For each proposed battery item, whether it is computable from
published marginals alone, computable only under an assumed target joint
distribution, or not computable at all. Density-ratio maps, convex-hull support
for the joint law, and stratum-specific ESS all fall in the second or third
category, and **an item that cannot be computed from what publications print
cannot be required of an analyst**, however good it would be.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio, by quadrature at an
order fixed by P1.

**Two derived estimands and they are the study.** **Feasibility**, the exact
linear-program answer, known by construction and by solving the program.
**Material failure**, defined as absolute error above a declared threshold or
interval coverage below nominal, which is what any diagnostic is being scored
against.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| convex-hull feasibility | feasible with margin; marginally feasible; infeasible | **the axis**, set by construction and verified by the linear program |
| tail overlap | good; thin tails; truncated support | feasible problems of varying difficulty, so ESS's confusion in section 2 consequence 2 is reachable |
| omitted moments | all reported moments matched; a modifier's moment unreported and unmatched | the item ESS is structurally blind to |
| effect modification | 0, moderate, strong | whether an omitted moment matters |
| covariate dimension | 3, 8 | infeasibility becomes commoner with dimension at fixed marginal overlap |
| network redundancy | the adjusted edge is the only evidence; other edges inform the contrast | the edge-influence item |

### What the mechanism makes true, and therefore what the study cannot see

- **Alignment between unsupported mass and effect modification is OVL-01's axis
  and is held fixed here**, so the two studies' results compose. This design is
  about feasibility and computability; OVL-01 is about identification.
- **The classifier-scoring machinery is imported from DIA-03, not rebuilt**, and
  DIA-03's proven identities are used rather than rediscovered: ESS, ESS/n and the
  weight CV are one statistic, and balance on matched moments is identically zero.
  **Re-establishing them would waste the budget and imply they are in doubt.**
- The target joint distribution is known to the simulation, which is what makes
  the computability taxonomy scorable: each item can be computed under full
  knowledge and under marginals-only, and the two compared. **That comparison is
  the taxonomy's evidence** and it is unavailable to an analyst by definition.
- One estimator family, MAIC. The battery is a MAIC battery and the entry says so.

## 5. Methods, including one that can win

The comparison is among diagnostics, with one estimator:

| item | source | computability |
|---|---|---|
| Kish ESS, ESS/n | conventional | marginals only |
| max normalized weight, top-5% mass, entropy efficiency | `weight_diagnostics()` | marginals only |
| **convex-hull feasibility (linear program)** | Glimm and Yau, with its R package | marginals only, for the mean |
| residual balance on matched moments | conventional | **identically zero; carried only to demonstrate that, per DIA-03** |
| density-ratio map | proposed | requires an assumed target joint law |
| stratum-specific ESS | proposed | requires known target stratum masses |
| edge influence | `edge_influence()` | requires the fitted network; approximate for multi-arm, which is CMP-24's subject |

**The comparator that can win is Kish ESS.** If a threshold on it separates
infeasible from feasible analyses as well as the linear program does, the
feasibility item is redundant and the recommendation is simpler. Registered as
such; section 2 consequence 2 says it should fail, and that is a falsifiable
prediction rather than an assumption.

**The weight CV is not carried as a separate item.** DIA-03 proved it is a
monotone transform of ESS at fixed $n$, so including it would inflate the battery
with a duplicate, which is the specific error the catalog asks to avoid.

## 6. Performance measures, MCSE, and $n_{sim}$

**Feasibility detection:** sensitivity and specificity of each item for the exact
linear-program answer, and the **silent-failure rate**, the proportion of
infeasible problems on which `optim()` returns weights with no warning and an ESS
above conventional thresholds. **That last number is the headline and it is a
single proportion.**

**Material-failure detection:** each item scored as a classifier with AUROC,
calibration and decision curves, following DIA-03.

**The computability taxonomy:** for each item, the correlation between its
marginals-only version and its full-knowledge version, and the loss in AUROC from
using the former. **An item whose marginals-only version is uncorrelated with its
full-knowledge version is not a deployable item**, and saying so requires
computing both.

$n_{sim} = 4000$ per cell, derived from resolving a silent-failure rate to within
0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The silent-failure rate: among infeasible configurations, the
proportion where the optimizer returns weights without warning and the reported
ESS exceeds the conventional threshold of about 35 or 10% of $n$.

**Decision rule.**

- A non-negligible silent-failure rate **confirms** the problem in the sharpest
  form available and the deliverable is that the feasibility test must be run
  before weights are reported, which costs a linear program.
- A silent-failure rate near zero, because infeasibility always drives ESS below
  threshold, **refutes** it: the existing convention already catches infeasibility
  and the battery needs the feasibility item less than it appears.
- **The computability taxonomy is published in either branch**, because it
  determines which of the eleven proposed items can be required at all and does
  not depend on the verdict.

## 8. Three controls, each of which can fail

**Null control.** In feasible configurations with good overlap, the linear program
must report feasibility in every replicate and the optimizer must converge.
**The feasibility test's own specificity has to be one**, since it is an exact
computation, and anything less means the implementation is wrong rather than
imperfect.

**Second null control.** Residual balance on matched moments must be numerically
zero in every converged feasible replicate. **DIA-03 measured this and found it
never exceeded $1.4\times10^{-14}$**, so this is a reproduction of a known result
used as a harness check; a nonzero value means the calibration is not solving what
it claims to.

**Positive control.** In infeasible configurations, the linear program must report
infeasibility in every replicate. Exact again, so anything less is an
implementation fault.

**Falsifier for the study's own headline.** The expected headline is that ESS
cannot separate infeasible from difficult. Its falsifier is the
marginally-feasible level: if ESS distinguishes those from infeasible ones as well
as the linear program does, then the concentration functional is carrying the
geometric information after all, and the case for a separate feasibility item
collapses. **That level exists in the grid for this reason.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Rewriting DIA-03 | Its identities and machinery imported, not rediscovered; residual balance carried only as a harness check | removed |
| Rewriting OVL-01 | Alignment held fixed; identification and abstention out of scope | removed |
| A battery inflated with duplicate statistics | Weight CV dropped as a monotone transform of ESS, per DIA-03 | removed |
| Proposing items an analyst cannot compute | Computability taxonomy is a registered deliverable | removed |
| Calibration feasibility conflated with joint-law support | Separated in section 2 consequence 3; both computed | removed |
| Edge influence's multi-arm approximation | CMP-24 named as owner; used here only in two-arm configurations | removed |
| Result specific to one optimizer | P3 repeats the silent-failure measurement across the optimizers the common implementations use | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | minutes |
| **P2** feasibility construction | Covariate laws achieving feasible-with-margin, marginally feasible and infeasible at matched marginal overlap, verified by the linear program | **The grid.** The three levels must differ in feasibility and not in anything else, or the comparison is confounded | days |
| **P3** optimizer survey | The silent-failure behavior of the optimizers used by `maicplus`, `outstandR` and the common hand-rolled `optim()` call | **Whether the headline is about MAIC or about one optimizer**, which is the difference between a methods finding and a bug report | days |
| **P4** unit cost | Per-replicate cost including the linear program at $n_{sim}=4000$; total computed not typed | $n_{sim}$ | hours |

**P3 is what makes this publishable as a methods result.** Glimm and Yau's example
is one subgroup with one optimizer; a rate across configurations and
implementations is a different claim.

## 11. Cost

Weighting fits plus a linear program per replicate; both cheap. The grid and
$n_{sim}$ dominate. Priced in P4.

---

## Relationship to the rest of the queue

- **DIA-03** has run and supplies the classifier machinery and two proven
  identities.
- **OVL-01** owns support alignment, identification and abstention.
- **OVL-03** owns aggregating a support diagnostic over a target distribution,
  which is section 2 consequence 3 taken as its own subject.
- **CMP-24** owns edge influence's multi-arm approximation.
- **SFW-10** owns `maicplus` disclosure gaps, and **DEC-11** owns what belongs in
  an interval; a required-battery recommendation lands in both.
- **OUT-02** proposes the effective event sample size, a candidate battery item on
  the outcome side.
