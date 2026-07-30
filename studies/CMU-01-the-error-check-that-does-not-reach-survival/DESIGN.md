# CMU-01 design: an integration-error check that exists everywhere except where it is needed

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The integration-error diagnostic exists.** `multinma` has checked it automatically
since 0.6.0, running half the chains at `n_int` and half at `n_int/2` so an R-hat
failure can be ascribed to the sampler or to too few integration points, an algorithm
formalized in the general-likelihood paper. **So the work is to lower the cost it
prices and widen the checks it does not cover**, which is the catalog's own framing.

The note requires a focused start: **integration-point adaptation and within-chain
parallelization**, not the full list of approximations. And one premise needs
correcting: **the aggregate-data likelihood does have a closed form for Gaussian
identity-link models**; the burden is real for the non-Gaussian and survival cases.

SFW-06 owns the general scaling map. **This design owns the flexible-survival
corner**, which is the most expensive one and the one where the diagnostic is weakest.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** for general likelihoods and flexible survival models each
aggregate-study individual carries its own integral, so cumulative integration-error
plots are unsupported there; adaptive integration and parallelization have never been
evaluated for ML-NMR; and analysts cut integration points, converting a visible
runtime cost into an invisible likelihood bias.

**Refuting sentence:** *the split-chain check already catches insufficient integration,
so an analyst who cuts points is warned, and the missing cumulative plot is a
convenience.*

## 2. The mechanism: the two checks answer different questions

**The split-chain check is a convergence test.** It compares chains at two integration
orders and flags a discrepancy, so it detects when $n_{\text{int}}$ is **too small to
sample consistently.** It does **not** quantify residual error at the chosen order.

**The cumulative plot is an error estimate.** Plotting the estimate against the number
of quasi-Monte Carlo points shows the sequence converging and bounds what remains.
**It is unavailable for general likelihoods** because each aggregate individual carries
its own integral, so there is no single prefix sequence to plot.

Three consequences:

1. **An analysis can pass the split-chain check and still carry material integration
   bias**, if both orders are insufficient in the same direction. **The check is
   relative, and two wrong answers that agree pass it.** That is the refuting
   sentence's weak point and it is directly testable against a high-accuracy
   reference.
2. **The error's effect is on the likelihood, so it propagates non-uniformly.**
   OUT-11 found the arm-differential integration error mattered for its primary
   contrast while each arm's absolute error was small, because **the errors did not
   cancel between arms.** So a scalar residual-error summary can be small while the
   contrast is wrong.
3. **Cost is driven by likelihood and gradient evaluations, not by saved draws**, and
   grows with points, studies, covariates and outcome-model flexibility. **So the
   flexible survival case is the product of every multiplier**, and it is where an
   analyst is most tempted to cut.

**The reference is a high-accuracy ML-NMR fit**, and everything is scored against it,
which is what makes "residual error" a measured quantity rather than a diagnostic's
opinion.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal survival contrast, RMST and milestone
survival, at a flexible baseline hazard.

**True value in two senses, and both are needed.** The **generating** truth, for bias;
and the **high-accuracy ML-NMR reference**, for integration error specifically.
**Separating them is what distinguishes integration error from model error**, and a
design with only one could not.

**Residual integration error is the derived estimand**, defined as the difference from
the reference at matched sampler settings, **reported for the contrast and not only for
the likelihood**, per consequence 2.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| integration points | 32, 64, 128, 256, 512 | the axis; 64 is the current default |
| covariate dimension | 2, 5 | a multiplier |
| aggregate studies | 4, 12 | another |
| baseline-hazard flexibility | Weibull; M-spline with 3 knots; M-spline with 5 | **the flexible-survival corner** |
| censoring | 30%, 60% | changes the likelihood's shape |
| approximation | none; **adaptive integration**; **within-chain parallelization** | the note's two |

### What the mechanism makes true, and therefore what the study cannot see

- **Variational approximation, GPU backends and likelihood emulation are named and not
  evaluated**, per the note. Each is a separate project and including them would make
  the comparison shallow everywhere.
- **The Gaussian identity-link case has a closed form**, so it is excluded from the
  cost comparison and used only as a correctness check where an exact answer exists.
- The reference fit is itself approximate at a high order; **P1 establishes the order
  at which it is stable**, and its residual is reported rather than assumed zero.
- One network geometry; DIA-07 owns topology.

## 5. Methods, including one that can win

| arm | role |
|---|---|
| default settings | what a user gets |
| the split-chain check | the existing diagnostic |
| **cumulative error extended to general likelihoods** | the missing check, built here |
| **adaptive integration** | the note's first approximation |
| **within-chain parallelization** | the note's second |
| high-accuracy reference | the ceiling |

**The comparator that can win is the split-chain check.** If it flags every
configuration whose residual contrast error is material, the refuting sentence holds
and the cumulative extension is a convenience. **Registered as such, and consequence 1
gives the specific way it could fail**, which makes the test sharp rather than general.

## 6. Performance measures, MCSE, and $n_{sim}$

**Residual integration error** in the contrast against the reference, per
configuration; **likelihood error**; **contrast bias and interval coverage** against
the generating truth; **predictive log score**; **runtime and effective draws per
minute**, following SFW-06 since wall clock alone cannot separate a speedup from a
geometry change.

**The split-chain check's operating characteristics**, scored as a classifier of
material residual contrast error: **sensitivity and false-positive rate.** That is
consequence 1 made measurable and it is the primary.

**The arm-differential error is reported separately from the per-arm error**, per
consequence 2 and following OUT-11's finding.

$n_{sim}$ is small, since each replicate is a survival ML-NMR fit; **the count is
derived in P4 from the reference fit's cost** rather than chosen.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Sensitivity of the split-chain check to material residual
contrast error, at 64 integration points with a 5-knot M-spline baseline, 5 covariates
and 12 aggregate studies.

**Decision rule.**

- Sensitivity low: **consequence 1 is confirmed**, and the deliverable is the
  cumulative-error extension plus a recommendation that residual error be reported for
  the contrast.
- Sensitivity high: **refuted**, the existing check suffices, and the deliverable
  reduces to the cost work.
- **Runtime against residual error is reported in either branch**, because the
  catalog's request is that the trade-off be made knowingly and that does not depend on
  the diagnostic's verdict.

## 8. Three controls, each of which can fail

**Null control.** In the Gaussian identity-link case the integral has a closed form,
so **every method must match it exactly** and the residual error must be numerical
precision. **That is an exact control and it validates the whole error-measurement
pipeline** before any approximate case is interpreted.

**Second null control.** At the highest integration order, all arms must agree with the
reference to within its own residual. **Cheap, and it checks the reference is a
reference.**

**Positive control.** 32 points with a 5-knot baseline and 12 aggregate studies: the
residual contrast error must exceed the material threshold. **If the worst
configuration is harmless, cutting integration points is safe and the entry's concern
does not arise.**

**Falsifier for the study's own headline.** The expected headline is that the existing
check misses material contrast error. Its falsifier is consequence 2 failing: **if
per-arm error and contrast error move together, then a scalar residual summary is
adequate and the arm-differential reporting OUT-11 needed is specific to its design.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming no integration-error diagnostic exists | Credited in the header; the split-chain check is a scored arm | removed |
| Claiming the aggregate likelihood never has a closed form | Corrected; the Gaussian case is the exact null control | removed |
| Evaluating five approximations shallowly | Two, per the note; the rest named | removed |
| Integration error confounded with model error | Two truths carried | removed |
| Reference assumed exact | Its residual established in P1 and reported | removed |
| Runtime compared at unequal accuracy | Reported against residual error | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** reference order | The integration order at which the reference is stable, and its residual | **The definition of integration error** | days |
| **P2** material threshold | The contrast error a decision would notice | Every classifier result | hours |
| **P3** cumulative extension feasibility | Whether a per-individual-integral cumulative error estimate can be constructed at all for a general likelihood | **Whether the missing check can be built**, which is the design's main deliverable | days |
| **P4** cost and $n_{sim}$ | Reference and production fit costs; the replicate count derived from them; checked against SFW-06's frontier | Everything | days |

## 11. Cost

**The most expensive per-fit configuration in the queue**, and the reference fits cost
more again. **SFW-06 should run first and bound this**, which is why both designs name
each other.

---

## Relationship to the rest of the queue

- **SFW-06** owns the general scaling map and bounds this design; the two share the
  timing harness.
- **OUT-11** measured arm-differential integration error on production fits and
  supplies consequence 2's evidence.
- **CMU-03** notes that a coded-likelihood SBC replicate cannot see integration error
  at all, which is the same blindness in the calibration layer.
- **CMP-15** owns the reconstruction the integration is over; **COV-12** owns the
  margins.
- **MOD-10** multiplies this cost by a flexible interaction surface.
