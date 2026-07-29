# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART D OF 7: the cell matrix and Monte Carlo error

You are reviewing a protocol revised four times. Round one returned `unsound`,
round two `unsound`, round three `unsound`, round four `unsound`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
`round4_resolution` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

## 8. E3: the cell matrix

Registered by `build_cells()` in `R/04-calibrate.R`. Ten distinct parameter cells crossed with the
registered censoring conditions give **21 cell-by-censoring conditions**, at 40 replicates each, for
**840 replicates**. This table is checked against the code's own export by
`review/verify-protocol.py`, which caught it stale when $\kappa_A$ was added.

| arm | family | $\kappa_A$ | $\kappa_B$ | $\gamma$ | true $\Delta_{\text{RMST}}(18)$ | $\beta_B$ | censoring |
|---|---|---:|---:|---:|---:|---:|---|
| primary | Weibull | 0.00 | 0.00 | 0.30 | 0.75 | $-0.4140$ | balanced, differential, reversed |
| primary | Weibull | 0.00 | 0.15 | 0.30 | 0.75 | $-0.2706$ | balanced, differential, reversed |
| primary | Weibull | 0.00 | 0.30 | 0.30 | 0.75 | $-0.1431$ | balanced, differential, reversed |
| margin | Weibull | 0.00 | 0.00 | 0.30 | 0.35 | $-0.3255$ | balanced |
| margin | Weibull | 0.00 | 0.30 | 0.30 | 0.35 | $-0.0505$ | balanced |
| control | Weibull | 0.00 | 0.00 | 0.00 | 0.75 | $-0.4223$ | balanced, differential |
| **ipd-nph** | Weibull | **0.30** | 0.00 | 0.30 | 0.75 | $-0.6984$ | balanced, differential, reversed |
| **ipd-nph** | Weibull | **0.30** | 0.30 | 0.30 | 0.75 | $-0.4383$ | balanced, differential, reversed |
| family | Gompertz | 0.00 | 0.00 | 0.30 | 0.75 | $-0.4450$ | balanced |
| family | Gompertz | 0.00 | 0.30 | 0.30 | 0.75 | $-0.3110$ | balanced |

**The two `ipd-nph` cells are new in version 4 and exist because round 3 found the benchmark was
not testing what it claimed.** With $\kappa_A$ fixed at zero, the IPD-side A-versus-PBO contrast,
the only contrast MAIC weighting or STC regression ever touches, was exactly proportional in every
cell, while all the time-variation sat in an aggregate-side fit both rows share. Their registered
properties:

| $\kappa_A$ | $\kappa_B$ | conditional cross | marginal cross | marginal HR range | PH test rejects |
|---:|---:|---:|---:|---|---:|
| 0.30 | 0.00 | 2.7 | 2 | 0.503 to 2.039 | 0.535 |
| 0.30 | 0.30 | none | none | 0.828 to 0.858 | 0.040 |

The second is the more interesting of the two and version 3 could not express it at all: with
$\kappa_A = \kappa_B$ the **target contrast is proportional while both arms are strongly
non-proportional**. The proportional-hazards test rejects at 0.040, at nominal. A method that reacts
to arm-level rather than contrast-level non-proportionality will be penalized here and should not
be, which is a distinction no other cell in the design can draw.

Censoring in E3 is **between-study differential follow-up**, which is what "differential censoring"
means in the OUT-11 entry: balanced is rate 0.010 in both studies, differential is 0.020 in the IPD
study against 0.100 in the aggregate study, cutoff 36 in both. Arm-differential censoring within a
comparison is declared out of scope in section 12.

**$\beta_B$ is solved, not chosen**, so that the true target RMST difference lands on a registered
margin relative to the decision threshold. Section 10 explains why that is the difference between a
decision rule that can fire and one that cannot.

**Registered properties of every cell**, computed by `cell_properties()` before the run, at 200 per
arm with a Grambsch-Therneau test at the 0.05 level:

| family | $\kappa_B$ | $\gamma$ | cond. cross | marg. cross | marginal HR range | at risk at 18, A / B | PH test rejects |
|---|---:|---:|---:|---:|---|---:|---:|
| Weibull | 0.00 | 0.30 | none | none | 0.849 to 0.873 | 0.240 / 0.288 | 0.060 |
| Weibull | 0.15 | 0.30 | 13.8 | 13 | 0.548 to 1.149 | 0.240 / 0.263 | 0.215 |
| Weibull | 0.30 | 0.30 | 8.4 | 8 | 0.349 to 1.484 | 0.240 / 0.239 | 0.600 |
| Weibull | 0.00 | 0.30 (margin) | none | none | 0.927 to 0.940 | 0.240 / 0.262 | 0.065 |
| Weibull | 0.30 | 0.30 (margin) | 6.2 | 6 | 0.382 to 1.596 | 0.240 / 0.213 | 0.640 |
| Weibull | 0.00 | 0.00 (control) | none | none | **0.842 to 0.842** | 0.291 / 0.344 | 0.055 |
| Gompertz | 0.00 | 0.30 | none | none | 0.823 to 0.852 | 0.336 / 0.393 | 0.055 |
| Gompertz | 0.30 | 0.30 | 14.4 | 14 | 0.701 to 1.629 | 0.336 / 0.364 | 0.530 |

Three things this table settles, all of which round 2 asked for and version 2 did not supply.

**The marginal-PH control is exact.** At $\kappa_B=\gamma=0$ the marginal hazard ratio is 0.842 at
both ends of the grid, so it is constant to the printed precision and the proportional methods are
correctly specified. That is where they must win; if they do not, the comparison is rigged and the
paper will say so.

**Crossings happen inside the supported window, and in version 2 they did not.** Round 2's second
reviewer found that no version-2 cell produced an in-window crossing: with a large treatment effect
the marginal hazard ratio ran from 0.32 to 0.84 at $\kappa_B=0.30$ and never reached 1 before the
cutoff, so a protocol promising a benchmark "under crossing hazards" delivered divergence without
crossing. That was correct against version 2. It is resolved here as a **side effect of the fix to
a different reviewer's finding**: solving $\beta_B$ down to a decision-relevant margin shrinks the
early advantage enough that the late reversal crosses. The marginal hazard ratio now runs 0.349 to
1.484 and crosses 1 at 8 months at $\kappa_B=0.30$, 0.548 to 1.149 crossing at 13 months at
$\kappa_B=0.15$, and 0.701 to 1.629 crossing at 14 months for Gompertz. Conditional crossings are
at 13.8, 8.4, 6.2 and 14.4 months, all well inside the 36-month cutoff and bracketing the 18-month
horizon.

**The retained levels are the ones an analyst misses.** The proportional-hazards test rejects at
0.055 to 0.065 in the three proportional cells, which calibrates the test rather than the design;
at 0.215 for $\kappa_B=0.15$; and at 0.53 to 0.64 for $\kappa_B=0.30$. So an analyst misses the
mild violation 78% of the time and the strong one about 40% of the time. Nothing retained is a
violation so large that no competent analyst could overlook it.

## 9. Monte Carlo error, and what cannot be resolved

**14 cell-by-censoring conditions at 40 replicates is 560 replicates per estimator.** The standard
error of a pooled coverage estimate near 0.95 is then **0.009**. Restricted to the six primary
cells it is 240 replicates and 0.014, not the 0.011 version 2 printed for a replicate count it was
not using; round 2 caught that arithmetic and it was right.

That resolution is sufficient to certify a calibrated estimator but not to detect mild
miscalibration. Rather than assert otherwise, the decision rule uses a Monte Carlo confidence
interval, has an explicit **inconclusive** outcome, and section 10.3 tabulates the probability of
each verdict under both a calibrated and a miscalibrated truth.

Per-cell coverage at 40 replicates has a standard error of 0.034 and is **descriptive only**.
IDN-05 published a maximum over eight noisy cell estimates as if it were a bound, and a reviewer
was right that it was not; that mistake is not repeated.

Bias in $\Delta_{\text{RMST}}$: a 60-replicate pilot on six cells gives a per-replicate standard
deviation between 0.62 and 0.87 months depending on estimator and cell, so **0.75 is the registered
planning value** and the pooled bias over the six primary cells has a standard error near 0.048
months. Version 2 asserted 0.35 without having measured it, which is less than half the truth and
would have understated every reported uncertainty; the number is now measured and the pilot is
kept in `results/freq-pilot.rds`.

**Estimator comparisons are paired on the replicate**, since all seven are computed on the same
simulated network, and reported with paired intervals. Common random numbers are used across
censoring regimes within a cell.

