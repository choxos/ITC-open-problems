# QBA-07 design: the interval-censored likelihood already covers one case, and only one

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's narrowing determines the whole design. **The sub-mechanisms need different
parameters and not all are always required**: sensitivity and specificity address event
classification, lag and interval endpoints address timing, linkage completeness addresses
missing capture, and visit-process association parameters are needed **only when
observation is informative.**

And one case is already solved. **Where visit times are noninformative given modeled
covariates and the event is known to lie between visits, an interval-censored likelihood
accommodates different grids without any extra bias parameter**, and implementations
support it. **So a design that added a parameter for every mechanism would be
over-parameterizing three of four cases.**

The note orders this after simpler survival QBA because the interacting latent event and
observation processes make it a poor early experiment.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** protocol-driven trial assessment and routine-care capture
detect the same events at different times and with different completeness, so using
detection time as event time makes progression curves depend on the assessment grid;
ascertainment parameters cannot be estimated from the comparison data because the true
event process is never observed in either source; and assessment schedules and linkage
completeness are rarely reported in enough detail to be bounded from protocol
information.

**Refuting sentence:** *the interval-censored likelihood covers the practically important
case, so the remaining mechanisms are refinements that do not change a decision.*

## 2. The mechanism: four sub-mechanisms with different remedies and one interaction

**Solved case.** Noninformative visit times with the event bracketed: the interval-censored
likelihood is correct and grid differences cost precision rather than bias. **No sensitivity
parameter is warranted.**

**Three unsolved cases, each with its own parameter:**

1. **Event misclassification.** Sensitivity $Se$ and specificity $Sp$ on the event
   indicator. A false negative postpones the recorded event indefinitely; a false positive
   creates one. **These are not symmetric in a survival setting**, because a missed event is
   censoring at the wrong place while a spurious one is an event at the wrong time.
2. **Informative visiting.** Visit intensity depending on latent disease state, so sicker
   patients are seen sooner and their events recorded earlier. **The bracket is then not
   independent of the event**, and interval censoring is no longer valid; a joint
   visit-outcome or inverse-intensity model is required.
3. **Recording lag and incomplete linkage.** A lag distribution and a capture parameter.
   Incomplete linkage acts like a false negative but with a different dependence structure.

**The interaction is the entry's own evidence.** Misclassified progression events and
irregular assessment timing together **may generate bias greater than the sum of their
parts**, which is QBA-22's non-additivity in this layer. **So a one-at-a-time sensitivity
analysis understates the joint effect**, and the design crosses the two that were measured
to interact.

**And the asymmetry between studies is what makes it a PAIC problem.** A protocol-driven
trial has scheduled visits and adjudicated events; routine care has neither. **So the four
mechanisms are present at different strengths on the two sides, and the biases do not
cancel**, which is OUT-07's structure applied to ascertainment rather than to censoring.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference, by exact integration of the generating
event process **using true event times**, so truth is a property of the disease and the
observation process is a property of the data.

**The derived deliverable is the sensitivity surface over the warranted parameters**, with
the warranted set determined by the setting rather than by convention, which is the entry's
instruction.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| assessment interval, per study | equal; differing by 2×; by 4× | the grid difference |
| **visit intensity depends on latent state** | no; yes | **the switch between the solved and unsolved cases** |
| event sensitivity and specificity | 1.0; 0.9; 0.8 | mechanism 1 |
| recording lag | none; moderate | mechanism 3 |
| linkage completeness | complete; 90% | mechanism 3's other half |
| asymmetry between studies | symmetric; trial-vs-routine | the PAIC-specific axis |

**The informative-visiting switch is the design's hinge**, because it decides whether the
existing likelihood suffices.

### What the mechanism makes true, and therefore what the study cannot see

- **Ascertainment parameters are not estimable from the comparison data**, so every
  correction is sensitivity analysis under declared parameters. **No arm claims estimation.**
- **Schedules and linkage completeness are rarely reported in enough detail to be bounded**,
  so the design's parameter ranges come from protocols where available and are declared
  otherwise. **A reporting requirement for both is a deliverable regardless of the results.**
- One outcome family, per the note's ordering; OUT-07 owns censoring and MIS-02 owns
  censoring-weighted transport, and both are held fixed here so ascertainment is
  attributable.
- The correction is integrated with the weighting or standardization step rather than run as
  a separate appendix analysis, per the entry.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive, detection time as event time | current practice |
| **interval-censored likelihood** | the solved case, and the registered winner |
| misclassification correction with declared $Se$, $Sp$ | mechanism 1 |
| joint visit-outcome or inverse-intensity model | mechanism 2 |
| lag and capture parameters | mechanism 3 |
| all warranted parameters jointly | the interaction case |

**The comparator that can win is the interval-censored likelihood.** If it removes the bias
wherever visiting is noninformative, and informative visiting is rare or weak in practice,
**then three of the four mechanisms are refinements and the recommendation is to use the
likelihood that already exists.** Registered as such, and it is the cheapest possible
answer.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of the target RMST difference per method per cell, with MCSE;
**per-study bias reported separately** so the asymmetry in section 2's last paragraph is
visible.

**The interaction measure**: joint bias against the sum of the two marginal biases for
misclassification and irregular timing, which is the entry's own evidence and is checked
rather than cited.

**Sensitivity to a misspecified observation model**: each correction run under a wrong
parameter value, since **an ascertainment correction under wrong parameters can be worse
than none** and that is the practical risk.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the interval-censored likelihood when **visiting is
informative**, against the joint model, in the asymmetric trial-versus-routine cell.

**Decision rule.**

- Interval censoring biased under informative visiting and repaired by the joint model:
  **the hinge is confirmed**, and the deliverable is a rule for when the extra machinery is
  warranted.
- Interval censoring adequate throughout: **refuted**, and the existing likelihood is the
  recommendation.
- **The interaction result is reported in either branch**, because non-additivity means a
  one-at-a-time sensitivity analysis understates regardless of which correction is used.

## 8. Three controls, each of which can fail

**Null control.** With noninformative visiting, perfect classification, no lag and complete
linkage, the interval-censored likelihood must be unbiased **despite unequal assessment
grids.** **That is the solved case stated as a control**, and it is what distinguishes a
grid difference from an ascertainment problem.

**Second null control.** With equal grids and symmetric mechanisms across studies, section
2's last paragraph makes the biases cancel in the contrast **while each arm is biased.**
Both halves must hold, as in OUT-07.

**Positive control.** Informative visiting with 4× grid difference and $Se = 0.8$
asymmetrically: naive analysis must be biased by at least three MCSEs. If not, the
mechanisms cannot be made to matter.

**Falsifier for the study's own headline.** The expected headline is that the unsolved
mechanisms warrant their own parameters. Its falsifier is the misspecification arm: **if a
correction under wrong parameters is worse than no correction across plausible parameter
error, then invoking the machinery is a net harm unless the parameters are well bounded**,
and the recommendation becomes the reporting requirement rather than the correction.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| A parameter for every mechanism by default | Warranted set determined by the setting, per the entry | removed |
| The solved case treated as unsolved | Interval censoring is the registered winner | removed |
| Correction run as a separate appendix | Integrated with the weighting or standardization step | removed |
| One-at-a-time sensitivity assumed adequate | Interaction measured against the sum of marginals | removed |
| Correction under wrong parameters assumed helpful | Misspecification arm, and it is the falsifier | removed |
| Censoring confounded with ascertainment | Held fixed; OUT-07 and MIS-02 named | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Target RMST truths under the complete event process | The definition of truth | hours |
| **P2** parameter ranges | Assessment schedules, misclassification rates and linkage completeness from protocols and validation studies where available; declared otherwise | **The materiality verdict** | days |
| **P3** informative-visiting prevalence | Whether visit intensity plausibly depends on latent state in the settings this applies to | **The hinge's practical relevance**, which decides whether the primary outcome matters | days |
| **P4** unit cost | Per-replicate cost including the joint model; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

The joint visit-outcome model dominates; the other arms are survival fits with modified
likelihood contributions.

---

## Relationship to the rest of the queue

- **OUT-07** owns informative censoring and shares the between-study asymmetry structure.
- **OUT-14** owns assessment windows as an information problem; **this owns them as a
  bias problem when visiting is informative**, and the two together cover the observation
  process.
- **QBA-06** owns covariate and outcome misclassification with a validation route.
- **QBA-22** owns non-additivity, which the entry's own evidence exhibits here.
- **QBA-24** owns survival QBA on the decision scale and would carry this surface.
