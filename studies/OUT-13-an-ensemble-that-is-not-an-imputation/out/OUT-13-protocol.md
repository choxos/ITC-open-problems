# Protocol: is a reconstruction ensemble's spread the reconstruction error?

**Target problem.** OUT-13. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Repeating a reconstruction of individual data from a published Kaplan-Meier curve is a valid analogue of
multiple imputation only if the repetitions are draws from the distribution of the true data given the
publication. **Refuting sentence:** the ensembles analysts already build produce a spread that matches the
true reconstruction error.

## 2. Design

One arm, 250 patients, Weibull event times (shape 1.2, median 18 months), administrative censoring from
24 months of uniform accrual and 36 months of follow-up; in the clustered pattern 30% also drop out just
before a 6-monthly visit. The publication: the curve read at pixel-column centers of a 1500 by 1000 (fine)
or 300 by 200 (coarse) plot with ordinates rounded to the pixel grid; a risk table every 3 or 6 months or
none; the event total. Reconstruction by Guyot's algorithm (IPDfromKM 0.1.10). Functionals of each
reconstruction: RMST to 24 months and survival at 12 months from the Kaplan-Meier curve, and survival at
48 months from a Weibull fit. 12 cells (resolution x table x censoring) plus a null control (fine, monthly
table, spread censoring). **300 replicates per cell.**

Methods: the true data (oracle); a single reconstruction from all digitized corners; **analyst variants**,
six reconstructions from 30, 60 or 120 digitized points with the event total supplied or not; and
**observation-model draws**, 20 reconstructions with each step's level redrawn uniformly within its pixel
row and its start time within the preceding column width, and censorings placed uniformly at random within
their risk-table interval instead of evenly spaced. Guyot's rounding of event counts is deterministic in all.

## 3. Estimands and decision

The reconstruction error of a functional is its value on a reconstruction minus its value on the true data.
**Variance calibration ratio** of an ensemble of size $M$: $\overline{B}(1 + 1/M)$ over the variance across
replicates of the ensemble mean's error; one for draws from the posterior given the publication. Near one:
0.67 to 1.5; far: below 0.5 or above 2. Reported with bootstrap MCSE, alongside the ensemble mean's error
bias, the MSE version of the ratio and coverage of the true-data value by $\bar\theta \pm 1.645\sqrt{(1+1/M)B}$.

**Primary:** the ratio for RMST in the four 6-month-table cells. Confirmed if the variants are far from one
and the draws near one in all four; refuted if the variants are near one in all four; "both far" if both are
far in all four; otherwise mixed and reported by cell.

Secondary: coverage of the population value by the Rubin-pooled interval
$\bar\theta \pm 1.96\sqrt{\overline{W} + (1+1/M)B}$ and by each single analysis; width relative to the oracle;
reconstruction RMSE relative to the sampling SD of the true-data value (materiality). **Non-uniformity:** the
draws' width inflation $\sqrt{1 + (1+1/M)\overline{B}/\overline{W}} - 1$ differs across the three functionals
by a factor of at least 2 in at least 7 of the 12 main cells. **Null control:** single-reconstruction RMSE
below 10% of the sampling SD for RMST and 12-month survival (48-month survival reported, since censoring
times matter to a Weibull fit even with a monthly table). **Positive control:** in the coarse, no-table,
clustered cell, single-reconstruction RMSE for 12-month survival at least 25% of its sampling SD; if not,
the entry's concern about milestone survival is not reachable in this design. Dropped replicates are counted.

## 4. Departures from DESIGN.md

300 rather than 1000 replicates; no likelihood on the reported ordinates (probe P3's principled arm is not
built); the consistent-truth construction of probe P2 is replaced by cross-replicate error against each
replicate's true data, which estimates the expected conditional variance; no human digitization variability
or line-width offset; censoring marks not used (IPDfromKM does not read them); image resolution at two
levels; single arm with no population-adjustment layer, since reconstruction error enters an unanchored
difference through the comparator's functional alone; no case study.
