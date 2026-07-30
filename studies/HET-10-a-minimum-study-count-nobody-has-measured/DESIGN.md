# HET-10 design: measure first, because measuring is cheap and nobody has

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The entry's most awkward sentence is the design's instruction: **the realized
coverage of population-adjusted network intervals as a function of the number of
studies is a simulation, not a theorem, and nobody has run it.** So this study
measures before it derives, and the note's warning that the full calibration is a
month rather than a week is honored by making the measurement the primary and the
derivation the secondary.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** random-effects network inference rests on a large-sample
approximation in the **number of studies** and fails when that number is small; the
exact permutation repair does not carry to population adjustment because estimated
weights from one IPD dataset supply several contrasts, so study labels are not
exchangeable; and population-adjusted networks are where study counts are smallest.

**Refuting sentence:** *population-adjusted network intervals are already
conservative enough at small study counts that the undercoverage documented for
aggregate-data methods does not appear.*

## 2. The mechanism: three routes and none of them is closed

**Frequentist two-stage.** The permutation argument needs a null under which
study-level contributions are exchangeable. A weight vector estimated from one IPD
dataset enters several contrasts, so those contrasts are dependent and permuting
study labels does not leave the null distribution unchanged. **The failure is
structural rather than a matter of degree**, which is why importing the exact method
would give an interval of unknown coverage.

**One-stage mixed-granularity.** IPD and aggregate studies enter the likelihood
through different terms and are not interchangeable, so **the symmetry a permutation
scheme needs is not obviously present**. Whether any scheme is exact here is an open
question, and the entry says that if none is, the field should stop waiting and
calibrate approximations instead. **That is a decidable question and it is probe
P3.**

**Bayesian.** With a handful of studies the heterogeneity variance is determined by
its prior, so **the interval inherits a choice rather than the data.** That is
CMU-02's mechanism at the variance-component level and CMP-16's at the network
level, and the prior-free precision those studies use applies directly.

**The consequence that shapes the design:** all three routes fail for different
reasons, so **a single "small-study correction" cannot be the answer**, and the
deliverable is a per-route characterization plus a minimum study count.

## 3. Estimand, with its true value defined

**Primary.** The target-population relative effect for a declared contrast, by
quadrature at an order fixed by P1.

**Realized coverage as a function of the number of studies is the derived estimand**,
and **it is reported by study count and never averaged over it**, because the
small-count regime is the point.

**The minimum study count is the deliverable**: the smallest count at which each
interval method attains coverage within a declared band across the grid, with the
statement that below it no population-adjusted network interval should be presented
as calibrated.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| number of studies | 2, 3, 4, 6, 8, 12, 16 | the axis; the aggregate-data literature starts at 8 and **the PAIC regime starts at 2** |
| number of IPD studies | 1; a third; all | how much weight estimation contributes |
| heterogeneity | none, moderate, large | where the aggregate-data undercoverage was worst |
| covariate overlap | good, poor | the adjustment layer |
| effect-modifier strength | moderate, strong | how much the adjustment does |

**Study count crossed with heterogeneity is the design**, matching the axes on which
the aggregate-data failure was documented so the two are comparable.

### What the mechanism makes true, and therefore what the study cannot see

- **The within-comparison variance question is settled and is not reopened.**
  Chandler and Proskorovsky benchmarked variance estimators across 108 scenarios;
  their guidance is adopted for the single-comparison layer and this study measures
  the network layer on top of it.
- Consistency holds, so undercoverage is attributable to the small-study
  approximation rather than to inconsistency; HET-04 owns that.
- One outcome type. The entry's own framing is about study counts rather than
  outcomes.
- **Hartung-Knapp-style corrections have no derivation for a network whose inputs
  carry estimated weights**, so importing one would give an interval of unknown
  coverage in exactly the situation where coverage is the question. **It is carried
  as a candidate and reported as uncalibrated**, not as a fix.

## 5. Methods, including one that can win

| method | role |
|---|---|
| MAIC/STC contrasts combined in a network, sandwich | current two-stage practice |
| the same, bootstrap | the other current practice |
| ML-NMR credible intervals under standard heterogeneity priors | current one-stage practice |
| **study-level bootstrap re-estimating weights inside each replicate** | the entry's promising route, respecting the dependence a permutation destroys |
| Hartung-Knapp-style inflation with degrees of freedom accounting for estimated weights | the candidate correction, reported as uncalibrated |
| **ML-NMR with the heterogeneity prior varied** | so the prior-determined interval in section 2 is visible rather than assumed |

**The comparator that can win is ML-NMR under its standard prior.** If its credible
intervals attain nominal coverage down to two or three studies, the refuting sentence
holds for the method most likely to be used and the problem is confined to the
two-stage branch. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Coverage and interval width for the target-population relative effect, **by study
count**, with MCSE; convergence and failure rates.

**Prior dependence of the Bayesian arm**, as the movement of coverage and width
across heterogeneity priors, which is section 2's third route made measurable.

**The registered comparison to the aggregate-data baseline:** the same networks
analyzed without population adjustment, so the **additional** undercoverage
attributable to adjustment is separable from the known small-study problem.
**Without that arm the study would re-measure a documented failure and attribute it
to PAIC.**

$n_{sim} = 4000$ per cell, from resolving a coverage shortfall of 2 points; the
ML-NMR arms reduced by P4 and reported at their own counts.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the two-stage sandwich network interval at 3 and 4
studies with large heterogeneity.

**Decision rule.**

- Coverage materially below nominal, and further below than the unadjusted baseline:
  **confirmed**, and the deliverable is the minimum study count per method plus the
  study-level bootstrap if it repairs it.
- Coverage at nominal down to two studies: **refuted**, and that is a reassuring and
  currently unsupported result.
- **The minimum study count is reported for every method in either branch**, because
  it is what a reviewer needs and it does not depend on which method wins.

## 8. Three controls, each of which can fail

**Null control.** At 16 studies with no heterogeneity, every method must be nominal.
**That is the large-sample regime the approximation is derived for**, and failure
there means the harness rather than the approximation.

**Second null control, and it is the attribution anchor.** The same networks without
population adjustment must reproduce the documented aggregate-data undercoverage at
8, 12 and 16 studies. **Reproducing a published failure is what licenses attributing
anything extra to adjustment**, and DIA-08 and DIA-10 register the same kind of
control.

**Positive control.** Two studies with large heterogeneity: every method must
undercover materially, since two studies cannot estimate a heterogeneity variance.
**If some method is nominal there it is not estimating heterogeneity at all**, and
its interval is a fixed-effect interval wearing a random-effects label.

**Falsifier for the study's own headline.** The expected headline is that population
adjustment worsens small-study undercoverage. Its falsifier is the second null
control: **if the adjusted and unadjusted intervals fail identically, the problem is
the study count and not the adjustment**, and the deliverable is a minimum count
that the aggregate-data literature could have supplied.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Re-measuring the documented aggregate-data failure and calling it a PAIC finding | Unadjusted baseline arm; attribution is the second null control | removed |
| Reopening the settled within-comparison variance question | Published guidance adopted for that layer | removed |
| Importing Hartung-Knapp as a fix | Carried and reported as uncalibrated | removed |
| Averaging coverage over study count | Reported by count | removed |
| Bayesian arm's prior dependence hidden | Prior varied; movement reported | removed |
| Inconsistency confounded | Consistency imposed; HET-04 named | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target relative effect per cell | The definition of truth | hours |
| **P2** baseline reproduction | That the unadjusted arm reproduces the documented undercoverage at 8, 12 and 16 studies | **The attribution**, and therefore everything | days |
| **P3** permutation symmetry | Whether any permutation scheme is exact for the one-stage mixed-granularity likelihood, settled analytically | **Whether the field should keep waiting for one**, which the entry says is worth deciding | days |
| **P4** unit cost | Per-network cost across six methods at $n_{sim}=4000$; total computed not typed | The ML-NMR counts | hours |

**P3 is a derivation rather than a computation and it can be reported on its own**,
whichever way it resolves.

## 11. Cost

Networks are small, so most arms are cheap; the ML-NMR arms at 4000 replicates set
the budget and are reduced accordingly.

---

## Relationship to the rest of the queue

- **CMP-16** owns a shared heterogeneity parameter and **CMU-02** owns prior-driven
  posteriors; both bear on section 2's third route and supply the prior-free
  precision.
- **HET-03** owns a single shared variance across classes, the structural version of
  the same problem.
- **SFW-10** owns the single-comparison variance estimator this study builds on.
- **HET-04** owns node splitting, whose small-study behavior inherits this.
