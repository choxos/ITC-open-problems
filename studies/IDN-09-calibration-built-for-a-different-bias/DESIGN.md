# IDN-09 design: importing calibration is real work, not a citation

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog corrects its source on the central point: **the calibration machinery the
source treats as nonexistent does exist**, in control outcome calibration and in
empirical calibration from banks of negative and synthesized positive controls, routine
in OHDSI network studies with a CRAN implementation. **Both were built for unmeasured
confounding within one data source and have not been adapted to cross-study transport**,
and the entry says importing them is real work rather than a citation.

The note also orders this after more direct diagnostics, because **unavailable outcomes
and questionable control validity may limit the payoff regardless of statistical
calibration.** Section 2 says which of those two binds.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** for indirect comparisons there are no disease-area
catalogues of design-sensitive control outcomes, no power or specificity
characterization under correlated baseline covariates and non-collapsible scales, and
no validated mapping from a control signal to a bias parameter for the primary contrast.

**Refuting sentence:** *the existing calibration machinery transfers to transport with
its operating characteristics intact, so the adaptation is a re-derivation rather than a
new method.*

## 2. The mechanism: the shared-bias assumption changes meaning across studies

**Within one source**, a negative control shares the confounding pathway because it is
measured on the same patients under the same assignment mechanism. **The shared-bias
assumption is about one population.**

**Across studies**, the bias is a transport gap: the source and target populations
differ in the distribution of modifiers. A control outcome shares that gap only if
**the same covariates modify the control outcome in the same way**, which is a much
stronger requirement than sharing a confounding pathway. Three consequences:

1. **A valid negative control for transport must have zero treatment effect *and*
   modifier structure matching the primary outcome's.** Those pull in opposite
   directions: an outcome with no treatment effect has no treatment-by-covariate
   interaction to share. **So the natural candidates are structurally poor controls**,
   and this is not a practical difficulty but a tension in the definition.
2. **The signal-to-bias mapping is therefore not a rescaling.** Empirical calibration
   maps a distribution of control estimates to a corrected interval assuming the
   controls' bias distribution matches the primary's. **Under transport that assumption
   is consequence 1's requirement**, and its violation is not detectable from the
   controls themselves.
3. **Specificity is unknown for a separate reason.** With few trials and correlated
   baseline covariates, an apparent placebo interaction can reflect collinearity with a
   true modifier, a scale artifact, or multiplicity. **All three produce a signal in a
   valid control**, so a positive test is evidence against a joint set of assumptions
   rather than a measurement of bias.

**The availability problem may bind before any of this.** Control outcomes are rarely
reported in the aggregate publications indirect comparisons rely on, **which is where
the check is most needed.** P3 measures how often they are available in the appraisal
record, and **if the answer is almost never, the statistical calibration question is
academic** — which the note anticipates and which the design is willing to report.

## 3. Estimand, with its true value defined

**Primary.** Whether the population-adjusted contrast is affected by residual transport
bias, with the truth known by construction.

**The residual bias itself** is the quantity a calibration would estimate, and its truth
is generated.

**Two derived estimands.** The negative-control test's **type I error and power**; and
the **coverage of the calibrated interval for the primary contrast**, which is what
empirical calibration promises and what has never been checked under transport.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| control-outcome prevalence | low, moderate | power's denominator |
| **correlation of the control's modifier structure with the primary's** | perfect; partial; none | **consequence 1**, the definitional tension made a factor |
| shared-bias strength | none, moderate, large | the signal |
| covariate correlation | low, high | consequence 3's collinearity |
| network size | 4, 10 trials | consequence 3's multiplicity |
| scale | risk difference; log OR | consequence 3's scale artifact |

### What the mechanism makes true, and therefore what the study cannot see

- **Control validity is generated, not assessed.** In practice, knowing an outcome has
  no treatment effect and shares the relevant pathways **is exactly the knowledge that
  is incomplete**, and data-driven selection cannot supply it. The design measures what
  a valid control buys and what an invalid one costs, and cannot tell an analyst which
  they have.
- **A calibrated signal is evidence against a joint set of assumptions**, per the entry,
  and no arm reports it as a bias measurement.
- Catalogue construction and reporting requirements are process recommendations this
  study can motivate and not evaluate.
- One bias mechanism.

## 5. Methods, including one that can win

| method | role |
|---|---|
| negative-control outcome test | the detection route |
| negative-control covariate (placebo interaction) test | the other detection route |
| **control outcome calibration, adapted to transport** | the correction route, re-derived per section 2 |
| **empirical calibration from a control bank, adapted** | the interval-calibration route |
| no control | the floor |

**The comparator that can win is the unadapted empirical calibration.** If applying it
as-published restores nominal coverage of the primary contrast under transport bias,
then consequence 2's concern is immaterial and the import is a citation after all.
**Registered as such**, and it is the cheapest possible outcome.

## 6. Performance measures, MCSE, and $n_{sim}$

Type I error and power of each detection test; **coverage of the calibrated interval**
for the primary contrast; **bias of the calibrated point estimate**, with MCSE.

**Reported by the modifier-structure correlation factor**, since consequence 1 says that
is what governs whether calibration can work at all, and pooling over it would average a
valid control with an invalid one.

**Specificity decomposition**: among false positives, the share attributable to
collinearity, to scale artifact and to multiplicity, which consequence 3 says are three
distinct sources and which no study separates.

$n_{sim} = 4000$ per cell, from resolving a type I error of 0.05 to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the empirically calibrated interval for the primary
contrast, at partial modifier-structure correlation with moderate shared bias.

**Decision rule.**

- Coverage restored at perfect correlation and lost at partial: **consequence 1 and 2
  are confirmed**, and the deliverable is the adapted derivation plus the statement that
  control validity for transport requires matching modifier structure.
- Coverage restored throughout: **refuted**, and the import is straightforward.
- Coverage never restored: calibration does not transfer at all, and the honest
  deliverable is detection only, which is the weaker use the entry already allows.

**The availability rate from P3 is reported in every branch**, because it bounds the
practical value of any answer.

## 8. Three controls, each of which can fail

**Null control.** With no transport bias, every detection test must hold nominal type I
error and calibration must not move the primary estimate. **A calibration that shifts an
unbiased estimate is manufacturing a correction.**

**Second null control.** With a control whose modifier structure matches the primary's
**perfectly**, consequence 1's tension is absent and calibration should work as
published. **That is the case the imported method was built for**, and confirming it
licenses the failure at partial correlation.

**Positive control.** Large shared bias with a perfectly matched control: the detection
test must fire in essentially every replicate. **If it does not, the test has no power
where everything is favorable.**

**Falsifier for the study's own headline.** The expected headline is that adaptation is
real work. Its falsifier is consequence 1 taken as a design constraint: **if no
generated control can have both zero treatment effect and matched modifier structure,
then the second null control is unbuildable and the tension is not a factor level but an
impossibility.** **P2 checks that before the run**, and if it is an impossibility the
study reports a definitional result rather than an empirical one.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming calibration machinery does not exist | Credited; the unadapted version is the registered winner | removed |
| A calibrated signal reported as a bias measurement | Reported as evidence against a joint assumption set, per the entry | removed |
| Control validity assessed rather than generated | Stated as generated; the knowledge gap is named | disclosed |
| False positives pooled | Decomposed into collinearity, scale and multiplicity | removed |
| Availability ignored | Measured in P3 and reported in every branch | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and residual bias | The primary contrast's truth and the generated residual bias per cell | The grid | hours |
| **P2** control constructibility | Whether a control with zero treatment effect and matched modifier structure exists in the generating family | **The falsifier**, and possibly the whole design | days |
| **P3** availability rate | How often candidate control outcomes are reported in the appraisal record | **The practical value of any result**, and the note's stated concern | days |
| **P4** unit cost | Per-replicate cost at $n_{sim}=4000$ | The grid | hours |

**P2 and P3 both run before the simulation**, because either can turn this into a
definitional or an empirical-availability result rather than a calibration one.

## 11. Cost

Weighting and regression fits at 4000 replicates; small. **The control bank multiplies
the empirical-calibration arm** and is the term to price.

---

## Relationship to the rest of the queue

- **IDN-01** lists negative controls among the falsification devices PAIC lacks and
  supplies the screen-calibration framework.
- **QBA-26** owns held-out benchmarking, the other data-based route, and shares the
  point that a maximum over measured quantities does not bound unmeasured structure.
- **DIA-14** supplies the classification measures.
- **QBA-02** owns prospectively blinded calibration, which is what a control bank would
  become if it were assembled prospectively.
