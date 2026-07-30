# SFW-13 design: the ML-UMR half, and the one thing this program cannot supply

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The same conflict of interest as CMP-26 applies and is stated first.** The catalog
says it plainly: **both packages are authored by this catalog's own byline holder,
which is why independent replication matters more here than usual.** Nothing in this
design supplies that replication, and it does not claim to.

The note requires splitting the entry into a focused `cpaic` benchmark and a separate
ML-UMR benchmark. **CMP-26 is the `cpaic` benchmark.** This design is the ML-UMR half
plus the two concrete remaining builds the entry names.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** `cpaic` and `mlumr` are young single-maintainer research
packages on GitHub, neither on CRAN, that need independent benchmarking and external
validation of the strong structural and unanchored assumptions they rely on; being
first integrated implementations, there is no second implementation to compare
against, so numerical equivalence testing is largely unavailable.

**Refuting sentence:** *`mlumr`'s Bayesian g-computation route is a standard
construction whose correctness follows from components that are independently
validated, so the absence of a second implementation is not an evidential gap.*

**That refutation is partly available and the design tests it**: `mlumr` is adapted
from `multinma` concepts **rather than running on `multinma`**, so agreement with
`multinma` where their scopes overlap is a genuine external check and is the closest
thing to equivalence testing available.

## 2. The mechanism: what is untestable, what is checkable, and what is merely unbuilt

Three categories, and conflating them is how a software entry becomes unanswerable.

**Untestable from data.** Unanchored comparison requires conditional exchangeability
of absolute outcomes given adjusted covariates. **Software can make the assumption
explicit but cannot test it**, and no benchmark changes that. **So every unanchored
estimate needs quantitative bias analysis attached**, which is QBA-11's, QBA-13's and
DIA-14's territory and is a reporting requirement here rather than a study outcome.

**Checkable by construction.** Whether the implementation recovers its own generative
model, whether it agrees with `multinma` where scopes overlap, and how it behaves
under declared departures. **These are the study.**

**Merely unbuilt.** Marginal standardization on the `cML-NMR` path, which currently
returns a conditional profile contrast; and extension of `mlumr` beyond one pairwise
contrast. **The second is not an implementation task**: it requires first settling how
unanchored links compose across a network, which is a methodological question. **The
design states that rather than listing it as a feature request.**

**The overlap check is the design's core and it is sharper than it looks.** `mlumr`
transports treatment effects and absolute outcomes to an arbitrary target by Bayesian
g-computation. Where the network is a single IPD-versus-aggregate pair with an anchor,
**`multinma` can fit the same problem**, and the two should agree on the anchored
contrast to within Monte Carlo error. **Disagreement there is a defect in one of
them**, and since one is independently used and the other is not, the presumption is
locatable.

## 3. Estimand, with its true value defined

**Primary.** The target-population **absolute** outcomes per arm and the marginal
treatment effect, since `mlumr`'s distinctive output is the absolute quantity and an
unanchored method that transports relative effects correctly while getting absolute
outcomes wrong is failing at what it is for.

**True values** by quadrature over the declared target from the generating model.

**Agreement with `multinma`** is a second estimand with a defined tolerance, computed
only in the overlapping scope.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| covariate overlap | good, poor | the adjustment layer |
| **omitted prognostic covariate** | none; moderate; strong | **the unanchored assumption's violation**, which is the method's central risk |
| omitted effect modifier | none; present | the anchored-style violation, for contrast |
| outcome family | binary; continuous; time-to-event | the package's stated scope |
| target population | the IPD trial's; the aggregate trial's; an external one | the arbitrary-target claim |
| scope | overlapping with `multinma`; unanchored only | **section 2's overlap check** |

### What the mechanism makes true, and therefore what the study cannot see

- **Independent replication is not achieved here.** The design's outputs are a
  benchmark and a comparison; **replication requires someone unconnected to the
  packages to run them**, and the entry says so. The paper must not present a
  self-run benchmark as independent validation.
- **The unanchored assumption is not tested**, per section 2. The omitted-covariate
  factor measures the consequence of violating it, which is a different and weaker
  thing than testing whether it holds.
- `cpaic` is CMP-26's subject; only the marginal-standardization gap is noted here.
- Neither package is described as installable from CRAN, **because they are not**.

## 5. Methods, including one that can win

| arm | role |
|---|---|
| `mlumr` Bayesian g-computation | the package under test |
| `multinma` on the overlapping scope | the external check |
| naive unadjusted comparison | the floor |
| STC | the comparator `mlumr` ships |
| `mlumr` with QBA attached | the reporting requirement, demonstrated |

**The comparator that can win is `multinma` on the overlapping scope.** If it and
`mlumr` agree to Monte Carlo error across that scope, **the refuting sentence holds
for the checkable part** and the remaining gap is genuinely the untestable assumption
rather than the implementation. Registered as the outcome that would most support the
package, which is why it is worth registering explicitly given the authorship.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and convergence for absolute outcomes and for the marginal effect, per
arm per cell, with MCSE; **failed fits reported, never dropped**.

**Agreement with `multinma`** as a paired difference with a declared tolerance in the
overlapping scope, with the tolerance fixed before the run.

**Sensitivity-analysis calibration**: whether the package's prior-sensitivity output
tracks the actual prior dependence, scored against refits under alternative priors.
**A sensitivity tool that under-reports its own sensitivity is worse than none**, and
this is the cheapest check on it.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target-population absolute control-arm
outcome under a strong omitted prognostic covariate, and the paired difference against
`multinma` in the overlapping scope.

**Decision rule.**

- Agreement with `multinma` within tolerance, and bias under omitted prognosis
  tracking its analytic magnitude: **the implementation is behaving as the theory
  says**, and the deliverable is that benchmark plus the standing requirement for
  independent replication.
- Disagreement with `multinma`: **an implementation defect is indicated in one of
  them**, and the discrepancy is localized before anything is claimed. **The
  presumption falls on the less-used package and the design says so.**
- Bias under omitted prognosis larger than analytic: something beyond the known
  identification failure is operating and must be found.

## 8. Three controls, each of which can fail

**Null control.** With no omitted covariates and full overlap, every method must be
unbiased and nominal, and `mlumr` must agree with `multinma` exactly in scope.
**Failure is implementation.**

**Second null control.** With the target set to the IPD trial's own population, no
transport occurs, so `mlumr` must reproduce the within-trial estimate. **Cheap,
exact, and it checks the g-computation reduces correctly.**

**Positive control.** Strong omitted prognostic covariate: the unanchored estimate
must be biased by its analytic magnitude. **A package that is unbiased there is not
doing unanchored comparison**, and this is the control that would catch a silently
anchored implementation.

**Falsifier for the study's own headline.** The expected headline is that these
packages need external validation. Its falsifier is the overlap check: **if `mlumr`
and `multinma` agree wherever both apply, the implementation has an external witness
even without a second implementation of the unanchored path**, and the honest
conclusion is that the remaining gap is the assumption rather than the code.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Author benchmarking own packages | Stated in the abstract; the supporting outcome is registered; replication explicitly not claimed | **disclosed, not removed** |
| A self-run benchmark presented as independent validation | Ruled out in section 4 | removed |
| Testing an untestable assumption | Section 2 separates untestable from checkable; only the consequence is measured | removed |
| A methodological question listed as a feature request | Network composition of unanchored links named as methodology | removed |
| Describing the packages as installable from CRAN | They are not, and the design says so | removed |
| `cpaic` and `mlumr` benchmarked together | Split per the note; CMP-26 owns `cpaic` | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and analytic omitted-covariate bias | Absolute and relative truths, and the bias a strong omitted prognostic covariate implies | The positive control's target | hours |
| **P2** overlapping scope | Exactly which problems both packages can fit, and the agreement tolerance, fixed before the run | **The external check's existence and its strictness** | days |
| **P3** sensitivity-tool reference | Refits under alternative priors, against which the package's own sensitivity output is scored | Whether that check is possible | days |
| **P4** unit cost | Per-fit cost; total computed not typed | $n_{sim}$ | hours |

## 11. What this design cannot deliver, stated plainly

**Independent replication.** The entry asks for it, the catalog says single-maintainer
packages written by the person who wrote the agenda have no independent user base to
generate validation evidence, and **that remains true after this study runs.** The
deliverable is a public benchmark with committed generators, seeds and raw outputs so
that replication becomes cheap for someone else, which is the most the author can do
for a problem defined by the author's involvement.

---

## Relationship to the rest of the queue

- **CMP-26** is the `cpaic` half and carries the adversarial departure module.
- **CMP-11** owns the marginal-standardization gap on the component path as a
  methodological question rather than a build item.
- **QBA-11**, **QBA-13** and **DIA-14** own the bias analysis every unanchored
  estimate needs.
- **SFW-14** applies the same evaluation template to a package with no such conflict,
  which makes the two readable against each other.
