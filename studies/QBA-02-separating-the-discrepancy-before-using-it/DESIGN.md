# QBA-02 design: a benchmark discrepancy is not yet a bias distribution

**Status: design. Not registered.** Gated on data access; see section 10.
Written against `studies/DESIGN-STANDARD.md`.

**The note names the binding constraint and it is not statistical design:** this should
not run early without committed access to masked randomized and external-control IPD,
because **data governance is the constraint.**

The catalog is also precise about what the strongest existing exercise did and did not
do. Gupta et al. replaced the randomized control arms of 14 oncology trials with external
controls and benchmarked 15 emulated comparisons: **mean log hazard ratio discrepancy
0.247 unadjusted, 0.139 after measured-confounder adjustment and 0.098 after external
adjustment, with per-trial values from −0.229 to 1.205.** The bias analysis was
prespecified, **but the randomized answers were not concealed from the analysts** and the
trials are named with their published hazard ratios. **That is retrospective benchmarking
rather than hidden-truth calibration.**

And **concealment is not the only known-truth design.** Simulation, open randomized
emulation, validation samples and bridge-deletion exercises each quantify specified
components of error, so a design that treated concealment as the sole route would
overstate the gap.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no prospectively concealed, analyst-blinded, multi-disease
calibration program exists; the one substantial exercise is confined to a single disease
area and outcome under unusually favorable conditions; **and a benchmark discrepancy is a
single aggregate number folding every mechanism together**, so it can inform a
residual-bias distribution only after sampling error, estimand mismatch and
outcome-definition differences are separated out.

**Refuting sentence:** *retrospective benchmarking with a prespecified analysis plan
removes analyst adaptation adequately, so concealment adds procedure without adding
validity.*

## 2. The mechanism: three components inside one number, and only one is what a prior needs

The observed discrepancy between an emulated and a randomized estimate is

$$D \;=\; \underbrace{b}_{\text{systematic residual bias}} \;+\; \underbrace{\varepsilon}_{\text{sampling error, both estimates}} \;+\; \underbrace{m}_{\text{estimand and outcome-definition mismatch}} .$$

Three consequences:

1. **Only $b$ is what a residual-bias prior should be built from**, and $D$ is what a
   benchmark reports. **Using the observed discrepancy distribution directly as a prior
   inflates it by the sampling variance of two estimates and by any mismatch**, which
   makes a QBA look better calibrated than it is because its prior is too wide. **That
   direction matters: a too-wide bias prior produces intervals that cover by being
   uninformative.**
2. **$\varepsilon$ is estimable** from both estimates' standard errors, so $\mathrm{Var}(b)$
   can be recovered by subtraction, in the same way a between-study variance is recovered
   in meta-analysis. **That is a straightforward correction nobody applies**, and it is
   the design's cheapest deliverable.
3. **$m$ is not estimable from the benchmark** and must be removed by construction:
   matching population, outcome definition, follow-up and effect scale between the
   emulated and randomized estimates. **DIA-16 imposes the same requirement for the same
   reason.**

**What concealment adds is separate from all three.** It removes analyst adaptation, which
does not enter $D$'s decomposition but does enter whether the reported analysis is the one
that would have been prespecified. **So concealment's value is measurable only by
comparing concealed and unconcealed analyses of the same data**, which is the design's
one genuinely new comparison and the only thing a prospective program buys that a
retrospective one cannot.

**And transportability of a calibration is unverifiable.** Whether a discrepancy
distribution obtained in one indication, data source and era applies to the submission at
hand cannot be checked, **so every calibration must ship with an explicit statement of the
setting to which it is claimed to transport**, and the design treats that as a reporting
requirement rather than a research question.

## 3. Estimand, with its true value defined

**Primary.** The absolute discrepancy between the emulated target effect and the
concealed randomized result, on a declared scale, with **both estimates' uncertainty
carried**.

**The derived deliverable is $\mathrm{Var}(b)$**, the systematic component after
subtracting sampling variance per consequence 2, which is what a residual-bias prior
should be built from.

**Two further outcomes.** **Interval coverage** of the emulated estimate against the
randomized one; and **whether tipping conclusions agree** with the revealed randomized
result, which is what the QBA claimed.

## 4. Design, and what it cannot cover

**The comparison that makes this prospective rather than a repetition:** the same
analysts, the same data, analyzed **with the randomized answer concealed** and, later,
**with it revealed**, so consequence 3's adaptation effect is measured rather than
assumed.

**Stratification** across disease areas, outcomes, data sources and bias mechanisms,
since the existing exercise is confined to one indication under **verbatim high
adherence, few losses to follow-up and no competing events** — conditions the catalog
names as unusually favorable and which bound what it can say.

### What it cannot cover

- **Governance, not design, is the constraint**, and the design says so rather than
  presenting a protocol as though the data were available.
- **Retrospective and open designs are carried alongside**, because concealment is not
  the only known-truth route and a program that ran only concealed studies would be
  slower and no more informative about $b$.
- Whether a calibration transports is unverifiable; **the requirement is a statement of
  claimed scope**, not a test.

## 5. Methods

Each analyst team applies a prespecified PAIC with prespecified QBA to an external
comparator, targeting the same estimand as the concealed randomized comparison.

**The comparator that can win is prespecified retrospective benchmarking.** If concealed
and revealed analyses of the same data give the same discrepancies, **the refuting
sentence holds**, prespecification is sufficient, and the field can extend the cheaper
design rather than building a concealed program. **Registered as such, and it is the
outcome that would most accelerate the work.**

## 6. Performance measures

Absolute discrepancy; **coverage of the emulated interval against the randomized
estimate**; tipping-conclusion agreement; and **the decomposition of consequence 2**,
with $\mathrm{Var}(b)$ reported separately from $\mathrm{Var}(D)$.

**The concealment effect**: the difference in discrepancy between concealed and revealed
analyses of the same data, which is the program's own justification.

**Per-study discrepancies are reported, never only the mean.** The existing exercise's
per-trial range of −0.229 to 1.205 around a mean of 0.098 is the reason: **a mean
discrepancy of 0.098 with that spread is a very different object from a mean of 0.098
with a tight one**, and only the spread informs a prior.

## 7. Decision rule, declared before any data access

- Concealed discrepancies materially larger than revealed ones: **concealment is
  necessary**, and the deliverable is the program design plus the corrected
  $\mathrm{Var}(b)$.
- No difference: **prespecification suffices**, and the field should extend retrospective
  benchmarking across indications instead, which is cheaper and faster.
- **The decomposition is reported in either branch**, because consequence 2's correction
  applies to every existing benchmark including the published one and can be applied to
  it immediately.

## 8. Controls

**Null control.** Where the emulated and randomized populations coincide and the
comparator is the randomized control arm itself, discrepancy must be sampling error only.
**That calibrates $\varepsilon$ empirically and validates the decomposition.**

**Second null control.** Where the outcome definitions differ deliberately, $m$ should
appear and be attributable. **That checks the harmonization requirement is doing work.**

**Positive control.** A known strong unmeasured confounder in the external source must
produce a discrepancy exceeding the sampling scale.

**Falsifier for the program's own headline.** The expected headline is that concealment
is needed. Its falsifier is consequence 2: **if most of the observed discrepancy variance
is sampling error and mismatch, then the systematic component is small and the whole
calibration enterprise is estimating something close to zero with a very expensive
instrument.** **That can be checked on the published exercise's numbers before any new
data is sought**, and section 10 does it first.

## 9. Threats

| threat | what was done | status |
|---|---|---|
| Presenting Gupta et al. as hidden-truth calibration | Stated as retrospective, with the randomized answers named and published | removed |
| Treating concealment as the only known-truth design | Simulation, open emulation, validation samples and deletion named as alternatives | removed |
| Using the discrepancy distribution directly as a prior | Decomposed; only the systematic component is used | removed |
| Estimand mismatch folded into bias | Removed by construction; verified | removed |
| Claiming a calibration transports | Scope statement required, not tested | disclosed |
| Mean discrepancy reported without spread | Per-study values reported | removed |

## 10. The gate, and what runs before it

| step | what it produces |
|---|---|
| **G0** decomposition of the published exercise | Apply consequence 2 to Gupta et al.'s reported per-trial discrepancies and standard errors and report $\mathrm{Var}(b)$. **This needs no new data, costs days, and could establish the falsifier in section 8 before any governance conversation begins** |
| **G1** protocol registration | This document, before access is sought |
| **G2** governance survey | Which sponsors and data holders could supply masked randomized and external-control IPD, and under what terms |
| **G3** pipeline validation | The concealed-then-revealed comparison rehearsed on simulated data |

**G0 is the priority.** It is the cheapest step, it applies to work already published, and
it can show whether the systematic component this program exists to estimate is large
enough to be worth the governance effort.

## 11. Relationship to the rest of the queue

- **IDN-10** owns the transported control-arm check and shares the Gupta design.
- **DIA-16** and **DIA-17** own the deletion and masking routes, which are the
  alternative known-truth designs named here.
- **QBA-26** owns benchmarking as calibration by analogy and shares the point that a
  benchmark measures what was observed.
- **DIA-14** owns QBA scored as a classifier and would use $\mathrm{Var}(b)$ as its
  elicitation's empirical anchor.
