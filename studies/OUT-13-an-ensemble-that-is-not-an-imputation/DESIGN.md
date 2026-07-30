# OUT-13 design: is the ensemble's spread the reconstruction error's spread

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

CMP-17 owns propagating reconstruction error into a component survival analysis and
finds it concentrates in the tail. **This design owns the condition under which any
such propagation is valid**, which the entry states precisely and which nobody
checks: multiple reconstruction is a valid analogue of multiple imputation **only
where the repeated reconstructions are proper draws from a calibrated distribution
conditional on the image, the risk table and the reported totals**, rather than
repeated runs of a deterministic algorithm or arbitrary tuning variants.

**That condition is testable and it has never been tested.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** reconstruction is deterministic given the image, so
every standard method runs without complaint and repeating it reveals nothing; the
published Kaplan-Meier ordinates are dependent derived statistics, so a likelihood
defined on them needs an explicit digitization, rounding, censoring and risk-table
observation model, which nobody has written.

**Refuting sentence:** *the existing ensemble machinery already produces a spread
that matches the true reconstruction error, so the calibration condition is met in
practice and the remaining likelihood work is optional.*

## 2. The mechanism: an ensemble is only uncertainty if it is calibrated

Let $\hat\theta(\mathcal{R})$ be an estimand computed from reconstruction
$\mathcal{R}$, and let $\mathcal{R}^{(1)},\dots,\mathcal{R}^{(M)}$ be an ensemble.
Rubin-style pooling is valid when the between-reconstruction variance estimates the
sampling variance of $\hat\theta$ induced by the unknown true reconstruction. **That
requires the ensemble to be draws from the posterior of the reconstruction given
the published information.** Three consequences:

1. **Tuning variants are not draws.** Varying an algorithm's smoothing parameter
   produces a spread governed by the parameter range chosen, which has no relation
   to the information the publication carries. **The resulting between-variance can
   be arbitrarily small or large and is a property of the analyst.**
2. **Calibration is directly checkable in simulation and only in simulation**,
   because it requires knowing the true event times. **The check is the ratio of
   the ensemble's between-variance to the true variance of $\hat\theta$ across
   independently generated true datasets consistent with the same published
   summaries.** A ratio near one means the ensemble is an imputation; far from one
   means it is a spread.
3. **The error does not inflate uniformly across estimands.** Curve error partly
   cancels under integration, so RMST within the observed window can be more robust
   than a milestone survival probability, while extrapolated survival can be
   amplified by the tail model. **So a single inflation factor is wrong** and the
   calibration ratio must be reported per estimand.

**The likelihood-on-ordinates route is the principled alternative** and it is
unbuilt because it needs an observation model for digitization, rounding, censoring
and risk-table reporting. **This design specifies that observation model and fits
it**, which is the piece the entry says is missing; whether it is affordable is
probe P3.

## 3. Estimand, with its true value defined

**Primary.** Target RMST at a within-window horizon and milestone survival at
declared times, by exact integration of the generating survival functions over the
target covariate law.

**The calibration ratio is the derived estimand** and it is the study's centre: per
estimand, the ensemble between-variance divided by the true variance of the
estimate across true datasets consistent with the same published summaries.
**Defining it requires generating many true datasets that produce the same
publication**, which is what P2 constructs.

## 4. Data-generating mechanism, and what it makes invisible

The pipeline is end to end: generate event data, render a Kaplan-Meier figure with a
risk table at declared resolution, digitize, reconstruct.

### Factors

| factor | levels | why |
|---|---|---|
| image resolution | vector; 300 dpi; 96 dpi | the digitization component |
| axis and ordinate rounding | fine; coarse | the rounding component |
| risk-table granularity | every 3 months; 6 months; absent | the dominant information source |
| censoring marks | shown; absent | RESOLVE-IPD's own axis |
| censoring pattern | administrative; heavy early; heavy late | where the allocation assumption bites |
| overlap | good, poor | the adjustment layer |
| reconstruction calibration | deterministic single; tuning-variant ensemble; **calibrated ensemble** | **section 2 consequence 1, the design's core contrast** |

### What the mechanism makes true, and therefore what the study cannot see

- **Human digitization variability is not simulated**, so the pixel component is a
  lower bound, as in CMP-17.
- **How much this matters is context-dependent**, which the entry says plainly; the
  design reports the calibration ratio and the movement per estimand rather than a
  verdict that transfers.
- Single-arm curves without competing risks; DIA-09 owns the harder families.
- Published summaries are internally consistent. Inconsistent tables are a
  different and larger problem.

## 5. Methods, including one that can win

| method | role |
|---|---|
| single deterministic reconstruction | current practice |
| tuning-variant ensemble | what an analyst might build and call an imputation |
| **calibrated ensemble** | draws conditional on image, risk table and reported totals |
| **Bayesian likelihood on the reported ordinates and risk table** | the unbuilt route, with an explicit observation model |
| oracle IPD | the ceiling |

**The comparator that can win is the tuning-variant ensemble.** If its calibration
ratio is near one, the distinction section 2 draws is academic and the existing
machinery is sufficient. Registered as such, and it is the cheapest possible outcome
for the field.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of RMST and milestone survival per method per cell, with MCSE;
**the calibration ratio per estimand**; **interval width relative to the oracle**,
so the cost of honest propagation is visible.

**The registered non-uniformity check:** whether the ratio of propagated to
unpropagated interval width differs across estimands. **Section 2 consequence 3
predicts it does**, and a uniform inflation would refute the mechanism.

$n_{sim} = 1000$ true datasets per cell, each rendered and reconstructed; the
ensemble multiplies by $M$, set in P3.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The calibration ratio of the tuning-variant ensemble and of the
calibrated ensemble, for target RMST, at coarse risk-table granularity.

**Decision rule.**

- Tuning-variant ratio far from one while the calibrated ensemble is near one:
  **confirmed**, and the deliverable is the calibration condition stated
  operationally plus the construction that meets it.
- Both near one: the refuting sentence holds and existing ensembles are adequate.
- **Both far from one**: no ensemble route is valid and the likelihood-on-ordinates
  route is the only one left, which raises the stakes on P3.

## 8. Three controls, each of which can fail

**Null control.** With a vector figure, a risk table at every event time and visible
censoring marks, reconstruction is essentially exact, so every method must agree
with the oracle and the calibration ratio is undefined rather than one. **Reporting
it as undefined rather than computing a ratio of two near-zero variances is the
correct handling**, and a method that returns a finite ratio there is dividing noise
by noise.

**Second null control.** With the reconstruction held at the truth artificially, all
propagation must reduce to the oracle. **Cheap, and it separates propagation
machinery from reconstruction error.**

**Positive control.** No risk table, 96 dpi, heavy late censoring: single
reconstruction must be materially wrong on milestone survival. If the worst
reporting the design can build is harmless, the entry's concern is not reachable.

**Falsifier for the study's own headline.** The expected headline is that ensembles
must be calibrated to be uncertainty. Its falsifier is consequence 3: **if RMST
error cancels under integration to the point that no reconstruction route changes a
conclusion, then the calibration question is real and immaterial for the estimand
decisions use**, and the recommendation narrows to milestone and extrapolated
quantities.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| An ensemble presented as an imputation without checking | Calibration ratio is the primary outcome | removed |
| Uniform inflation assumed | Reported per estimand; non-uniformity is a registered check | removed |
| Duplicating CMP-17 | That study owns propagation into component PAIC and the tail result; this owns validity of the ensemble | removed |
| Calibration ratio computed where both variances are near zero | Reported as undefined in the null control | removed |
| Human digitization variability | Lower bound; stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** pipeline validation | That render-digitize-reconstruct recovers truth under null-control settings | Everything | days |
| **P2** consistent-truth construction | How to generate multiple true datasets producing the **same** published summaries, which the calibration ratio requires | **The primary outcome's definition.** Without this the ratio has no denominator | days |
| **P3** likelihood feasibility and $M$ | Whether the observation-model likelihood is fittable, and the ensemble size at which pooling stabilizes | Whether the principled arm exists, and the budget | days |
| **P4** unit cost | Per-replicate cost including $M$ reconstructions; total computed not typed | $n_{sim}$ | hours |

**P2 is the design's hardest technical step** and it is what makes calibration
measurable rather than asserted.

## 11. The case-study half

Reanalyze a published PAIC and report **how far RMST and extrapolated survival move
across reconstructions**, per the entry, rather than assuming a uniform inflation.
That movement is the number a reader needs and the simulation cannot supply it for
their curve.

---

## Relationship to the rest of the queue

- **CMP-17** owns propagation into component PAIC and finds the error concentrates
  in the tail; the two share a pipeline and should run together.
- **OUT-14** owns delayed entry and assessment windows, the information the
  publication never had.
- **QBA-24** owns survival QBA and notes landmark survival and in-window RMST can
  be estimated from a published curve without reconstruction at all, which is the
  strongest available alternative to everything here.
- **DEC-11** lists reconstruction uncertainty as unpropagated.
