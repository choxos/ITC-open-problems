# CMP-26 design: generating from outside the family the estimator assumes

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**A conflict of interest has to be stated first.** `cpaic` is written by the author
of this study program. The catalog entry's sharpest sentence applies directly:
**when the author of the theory writes the only implementation, agreement between
theory and program is guaranteed rather than informative.** Nothing in this design
removes that; what it can do is make the tests adversarial and the artifacts
public, so that someone else can check the result without trusting the author.

The catalog's note sets the increment: **a preregistered adversarial simulation
module is the strongest first step**, not the full ten-item programme.

The entry is also careful that the repository is not bare: it contains tracked
analytic, adversarial and recovery unit tests and a continuous integration workflow
comparing its two Stan backends. **And several of the ten proposed validation items
restate ADEMP rather than being bespoke requirements**, which matters because
presenting a standard as a novel demand would overstate the gap.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the package's evidence base is a local, gitignored
factorial simulation over synthetic examples whose summaries omit Monte Carlo
standard errors, with no real full-IPD benchmark and no independent replication;
and synthetic data generated from the model family the estimator assumes can
confirm that the code implements the model, not that the model recovers truth under
realistic violations.

**Refuting sentence:** *the estimator's operating characteristics under violations
are already implied by the non-component ML-NMR literature, so a component-specific
adversarial module would reproduce known results.*

## 2. The mechanism: what a within-family simulation can and cannot establish

If data are generated from density $p_\theta$ and fitted by a model assuming
$p_\theta$, then consistency of the fitting code implies recovery of $\theta$.
**The simulation is then a test of the code**, and it is a good one; CMU-03 makes
that point precisely and gives simulation-based calibration as its sharpest form.

**What it cannot test is the model.** Recovery under $q \neq p_\theta$ is a
different question, and the answer depends entirely on which direction $q$ departs
in. So an adversarial module is defined by its departures, and the departures have
to be chosen for a reason:

1. **Additivity violation.** Components interact, so the additive design matrix is
   misspecified. **This is the assumption the whole component apparatus rests on**,
   and CMP-03 owns whether it is clinically false.
2. **Component-by-covariate interaction drift across subnetworks.** The bridge
   requires constancy; violating it is the failure that has no in-sample test,
   which is IDN-01's subject.
3. **Target-distribution misspecification.** The integration law is wrong, which is
   CMP-15's and COV-12's subject.
4. **Overlap failure.** Positivity is violated in part of the target, which is
   OVL-01's.

**The catalog names the circularity in choosing these: adversarial scenario design
requires knowing which violations matter most, which is what the validation is
supposed to reveal.** The way out is not to guess but to **order the departures by
a computable quantity**: the change each induces in the estimand at fixed
magnitude, computed analytically before any fitting. **That gives a severity
scale that is not chosen by the author's intuition**, and it is probe P1.

## 3. Estimand, with its true value defined

**Primary.** The target-population treatment contrast for a cross-gap regimen,
computed by quadrature over the declared target law from the **generating** model,
which under every adversarial departure is not the fitted model.

**Failure rate and Monte Carlo error are first-class outcomes**, not diagnostics:
the entry's complaint is that the existing summaries omit MCSEs, so every reported
quantity here carries one and replicate failures are reported rather than dropped.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| additivity violation | none; moderate; strong synergy | departure 1 |
| interaction drift across subnetworks | none; moderate; strong | departure 2 |
| target-law misspecification | correct; wrong correlation; wrong family | departure 3 |
| overlap | good; poor; a hole in the target | departure 4 |
| bridge strength | one shared component; two | how much the bridge is doing |

**Each departure is calibrated to equal severity by P1's scale**, so the module
reports which violation the estimator is most fragile to rather than which one the
author made largest.

### What the mechanism makes true, and therefore what the study cannot see

- **The generator is written by the same author as the estimator.** That is the
  irreducible limitation and it is stated in the abstract. **The mitigation is that
  generators, manifests, seeds and raw outputs are committed and public**, so the
  generator can be inspected and disagreed with, which is the part that is
  currently gitignored.
- **Independent replication is not achievable by this study** and is not claimed.
  The entry lists it and the catalog notes several items require resources the
  author cannot unilaterally obtain.
- Full-IPD gold standards are absent; DIA-17 owns that and is gated on data access.
- The comparison set is component ML-NMR against MAIC, non-component ML-NMR and
  CNMA. The entry's full list also includes g-computation, unanchored and
  partial-identification alternatives; those are named and deferred.

## 5. Methods, including one that can win

Component ML-NMR, non-component ML-NMR where the network permits, CNMA, and MAIC.

**The comparator that can win is non-component ML-NMR.** If it matches the
component estimator under every departure on the contrasts both can express, the
component apparatus buys nothing on this grid and the honest report says so.
**Given that the component package is the author's, registering its most likely
rival as the one that can win is the minimum available guard against a favorable
result.**

**Reproduction of the public CNMA benchmark is an arm, not a check.** Petropoulou
et al. supply a public factorial CNMA benchmark with disconnection-construction
scripts. **Extending it rather than replacing it is what makes this module
comparable to something**, and failure to reproduce its non-adjusted results would
be the first finding.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE, interval width, **failure rate** and **Monte Carlo standard
error on every one**, which is the entry's specific complaint about the existing
evidence.

**Artifacts are outputs.** Generators, scenario manifests, seeds and raw
per-replicate outputs are committed, because the entry's operative sentence is
that without them a reported operating characteristic cannot be checked, rerun or
extended by anyone else. **A results table without them is the thing being
corrected, so producing another one would be self-defeating.**

**Degrees of freedom are reported for every fit-based check.** IDN-08 records that
`additivity_test()` can return $Q = 0$ on zero degrees of freedom, which is a
vacuous pass; **any check reported here states its degrees of freedom so a vacuous
pass is visible.**

$n_{sim} = 1000$ per cell, Stan-limited, with the coverage MCSE stated.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the cross-gap contrast under each
departure at matched severity, component ML-NMR against the comparator set.

**Decision rule.**

- Component ML-NMR degrading no faster than its rivals under every departure: the
  estimator's operating characteristics are established for this grid, and the
  deliverable is the public module plus the severity ordering.
- Degrading faster under a specific departure: **that departure is the one to
  disclose in the package documentation**, and the deliverable includes it.
- Failing to reproduce the public CNMA benchmark's non-adjusted results: **the
  study stops there and reports that**, because nothing downstream would be
  interpretable.

## 8. Three controls, each of which can fail

**Null control.** With no departure, every method must be unbiased and nominal.
**This is the within-family test the entry says is already done and is not
informative about the model**; it is retained because it must pass before any
adversarial result means anything, and it is labeled as a code check rather than
as validation.

**Second null control.** With a single subnetwork and no bridge, the component
estimator must reduce to CNMA and agree with it numerically. **Cheap, exact, and it
catches a class of implementation error that no adversarial scenario would.**

**Positive control.** Strong synergy with strong drift and poor overlap: the
component estimator must fail materially. **A module whose worst scenario does not
break the estimator has not built an adversarial scenario**, and given the
authorship that is the specific way this study could quietly fail.

**Falsifier for the study's own headline.** The expected headline is that the
adversarial module reveals operating characteristics the within-family evidence
could not. Its falsifier is the refuting sentence in section 1: if the departures'
effects match what the non-component ML-NMR literature already reports, the module
reproduces known results and its value is the artifacts rather than the findings.
**That is still worth publishing and the design says so**, so there is no incentive
to overstate novelty.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Author validating own package | Stated in the abstract; rival registered as the comparator that can win; artifacts public | **disclosed, not removed** |
| Departures chosen to be survivable | Severity calibrated by P1's computable scale before any fitting | removed |
| Within-family simulation presented as validation | Labeled a code check, per section 2 | removed |
| ADEMP restated as bespoke requirements | Followed as the standard it is | removed |
| Vacuous fit-based passes | Degrees of freedom reported | removed |
| Independent replication implied | Explicitly not claimed | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** severity scale | The analytic change in the estimand induced by each departure at a common parameterization, so departures can be equalized | **The grid, and the study's defense against author-chosen severity** | days |
| **P2** benchmark reproduction | That the harness reproduces Petropoulou et al.'s public CNMA results on their own scenarios | **Everything downstream** | days |
| **P3** rank map | Estimability of the cross-gap contrast in every planned cell before fitting | The grid; the same probe CMP-14 skipped for four rounds | hours |
| **P4** unit cost | Per-fit cost; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Stan-dominated across a five-factor grid. **SFW-06's scaling map should bound it
before registration.**

---

## Relationship to the rest of the queue

- **CMU-03** owns simulation-based calibration, which is the sharp form of the
  within-family code check this design labels as such.
- **CMP-03** owns additivity, **IDN-01** owns constancy, **CMP-15** and **COV-12**
  own the target law, **OVL-01** owns overlap: the four departures each have an
  owner, and this module is where they meet one estimator.
- **DIA-17** owns full-IPD gold standards and **IDN-08** owns bridge-deletion
  benchmarks; both are gated on data access and neither is attempted here.
- **SFW-13** owns the fact that `cpaic` and `mlumr` are unreleased and
  independently unvalidated.
