# COV-09 design: reporting nonidentification rather than a correction that needs data nobody has

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is a constraint on what this study may conclude: it is a clean
early study **provided it reports nonidentification rather than presenting
correction without bridge information as universally available.** That constraint
shapes the decision rule in section 7, not just the discussion.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** nominally identical covariates may be recorded on
different assays, scales, thresholds, timings, assessors or definitions, so
balancing the recorded summaries does not guarantee balance of the underlying
construct; and without metadata, bridge information or defensible mapping
assumptions, balance on the latent covariate and the transported effect are not
identified from ordinary PAIC inputs.

**Refuting sentence:** *classical nondifferential error attenuates the interaction
predictably, so a single correction factor recovers the transported effect and the
nonidentification is a theoretical concern.*

**The entry itself refutes that**: classical nondifferential additive error
attenuates a linear treatment-by-covariate interaction, **but differential error,
Berkson error, misclassification, correlated error, nonlinear links and
non-collapsible estimands can bias the interaction in either direction.** So the
design's job is to show which regimes are which, and where nothing can be done.

## 2. The mechanism: the balancing constraint is solved on the wrong quantity

Let the source record $X$ and the target report $X^\star = a + bX + e$, a
calibration shift with slope $b$, offset $a$ and noise $e$. MAIC matches the
source's $X$ to the target's reported mean of $X^\star$, so the constraint solved is

$$\sum_i w_i X_i \;=\; \bar X^\star_T \;=\; a + b\,\bar X_T ,$$

which balances the source to a point that is **not** the target's latent mean
unless $a = 0$ and $b = 1$. Three consequences:

1. **The induced bias in the transported effect is $\beta_{EM}\{(a + b\bar X_T) -
   \bar X_T\}$**, a product of the interaction and the calibration discrepancy at
   the target's mean. **Zero when the variable is not a modifier**, whatever the
   measurement problem, which is the design's null control and the reason the entry
   says this is decision-critical only for strong modifiers.
2. **Nothing in the analysis can detect it.** The balance table shows the matched
   moments matched, because they were matched to the reported number. **This is the
   same structural blindness DIA-03 measured and MIS-01 finds for complete-case
   deletion**: the diagnostic is a function of the quantity that was made to agree.
3. **The direction is not fixed once error is differential.** If the source and
   target instruments err differently, $b$ differs between them and the sign of the
   discrepancy depends on which way. **So a correction factor estimated in the
   source does not transfer**, which is exactly the input the existing corrections
   assume is available.

**Nonidentification is therefore the honest headline for the no-bridge case**, and
the design's contribution is bounding: over a declared range of $(a,b)$, what range
of transported effects is compatible with the reported data. **That is computable
from published summaries alone**, which is what makes it deployable where the
corrections are not.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, defined on the
**latent** covariate, by quadrature at an order fixed by P1. **Defining truth on
the recorded covariate would build the measurement problem into the answer.**

**The sensitivity interval is a second estimand**: the range of transported effects
over a declared $(a,b)$ set, with **containment of the truth** and **width** both
reported, since a bound that always contains by being wide is not a result.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| calibration shift | none; offset only; slope only; both | section 2 consequence 1 |
| differential between source and target | no; yes | **consequence 3, and it is what breaks the corrections** |
| reliability | high, moderate, low | classical error's attenuation |
| cut-point misclassification | none; one threshold shifted | the dichotomized case, which is common and cheap to check |
| interaction strength | 0, moderate, strong | the multiplier; 0 is the null |
| bridge sample | absent; small; large | **whether correction is even possible** |
| link | identity; logit | where the sign guarantees fail |

### What the mechanism makes true, and therefore what the study cannot see

- **The measurement model is parametric and known to the simulation.** Real
  non-equivalence includes definitional differences that no $(a,b)$ captures, and
  those are named rather than modeled.
- The bridge sample, where present, administers both instruments, following
  Siddique et al.'s design. **The entry records counter-evidence that
  imputation-based harmonization can fail even with calibration studies**, so the
  bridge arm is not assumed to work and its failure rate is measured.
- Only one covariate is mismeasured at a time, so bias is attributable.
- Reported summaries are otherwise exact; EST-07 and COV-12 own their other
  defects.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive adjustment on the recorded number | current practice |
| measurement-error correction with a bridge sample | Wen and Yan's route, ported |
| multiple-imputation harmonization with a bridge sample | Siddique et al.'s route, ported |
| **sensitivity interval over a declared $(a,b)$ range** | the no-bridge deliverable |
| cut-point sensitivity | the cheap check for dichotomized variables |
| **metadata reporting** | assay, cut-point and timing reported beside the summary |

**The comparator that can win is naive adjustment.** If the bias is below the
decision threshold across realistic calibration shifts, the problem is not material
and the recommendation is the metadata reporting alone, which the entry calls a
cheap partial fix. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and decision reversal per method per cell, with MCSE; sensitivity
interval containment and width; **the bridge arm's failure rate**, since the entry
supplies counter-evidence that it can fail.

**The registered mechanism check:** observed bias regressed on
$\beta_{EM}\{(a+b\bar X_T)-\bar X_T\}$. Slope 1 confirms section 2.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of naive adjustment under differential calibration shift
with a strong modifier, and the sensitivity interval's containment at the same
settings.

**Decision rule, constrained by the note.**

- Naive adjustment materially biased and no method recovering the truth **without**
  a bridge sample: **the deliverable is the nonidentification statement plus the
  sensitivity interval**, and the corrections are reported as requiring linking data
  that PAIC usually lacks. **The study does not present them as available.**
- A correction working without bridge information: that would refute the
  nonidentification claim and is reported as such, with the assumption that made it
  work named.
- Naive adjustment unbiased throughout: the problem is immaterial at realistic
  shifts and metadata reporting is the whole recommendation.

## 8. Three controls, each of which can fail

**Null control.** With the mismeasured variable having zero interaction, section 2
consequence 1 makes the bias **exactly zero** at any calibration shift. Every method
must be unbiased. **That is the algebraic statement of why this is decision-critical
only for modifiers**, and it is checked rather than asserted.

**Second null control.** With no calibration shift and only classical
nondifferential error, attenuation is predictable and a single correction must
recover the effect. **That is the one regime where the refuting sentence is true**,
and confirming it is what licenses the claim that other regimes differ.

**Positive control.** Differential shift, strong modifier, logit link, no bridge:
naive adjustment must be biased by at least three MCSEs and no bridge-free method
may recover it. **If some bridge-free method does recover it, the nonidentification
claim is wrong**, and the design must be able to find that.

**Falsifier for the study's own headline.** The expected headline is
nonidentification without bridge information. Its falsifier is the sensitivity
interval's width: **if the interval over a plausible $(a,b)$ range is narrow enough
to support a decision, then the quantity is bounded tightly enough in practice and
"not identified" overstates the practical problem.** Width is therefore a
primary-level output.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting corrections as universally available | Bridge availability is a factor; the decision rule forbids it, per the note | removed |
| Truth defined on the recorded covariate | Defined on the latent one | removed |
| Bridge-based harmonization assumed to work | Its failure rate measured; the entry's counter-evidence cited | removed |
| A bound that contains by being wide | Width is a primary output and the falsifier | removed |
| Definitional non-equivalence beyond a calibration model | Named, not modeled | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The latent-covariate truth per cell | The definition of truth | hours |
| **P2** realistic calibration range | Plausible $(a,b)$ from documented assay and cut-point differences, fixed before the run | **The materiality verdict and the interval's width** | days |
| **P3** identifiability check | That no function of the observed data determines $(a,b)$ without a bridge, stated as a proposition rather than observed from failure to find one | **The headline.** A nonidentification claim asserted from an unsuccessful search is not a claim | days |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | minutes |

**P3 is what makes the honest headline defensible** rather than a report that
nothing tried happened to work.

## 11. Cost

Weighting and GLM fits; small. Priced in P4.

---

## Relationship to the rest of the queue

- **COV-01** owns modifier selection; a mismeasured modifier is selected on the
  wrong quantity, so the two compound and neither study covers that.
- **CMP-06** owns component miscoding, the discrete analogue.
- **MIS-01** and **DIA-03** own the same structural blindness of balance tables.
- **EST-07** and **COV-12** own the other defects of reported summaries.
- **DEC-11** owns what belongs in an interval; a measurement sensitivity range is
  structural rather than sampling and belongs beside it, not inside it.
