# Protocol: does reconstruction error change the ranking of methods or only their level?

**Target problem.** DIA-10 (reconstruction-error access mechanism only). ADEMP reporting. Committed before
the registered run. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Simulations that omit an access mechanism attribute its error to the methods, and the ranking of methods
is preserved only if that error is common to them. Reconstruction error should penalize methods that use
individual event times (an exact likelihood) more than summary-based ones. **Refuting sentence:** access-driven
error is small relative to method differences, so rankings survive its inclusion.

## 2. Design

The comparator arm of an unanchored survival comparison is published as a Kaplan-Meier figure and
reconstructed by Guyot's algorithm, using OUT-13's data-generating and publication model (250 patients,
Weibull events, pixel-rounded figure at fine or coarse resolution, a 6-monthly risk table or none, spread or
clustered censoring). Estimand: the comparator's RMST to 24 months (it enters the RMST difference
additively; the individual-data arm is common to all methods and omitted). Methods: Kaplan-Meier RMST and
Weibull-model RMST, each on the true data (no access error) and on the reconstruction, and the digitized
curve integrated directly. 8 cells, **1000 replicates**, common random numbers.

## 3. Decision

Per cell, the better of Kaplan-Meier and Weibull by RMSE against the population RMST, with and without
reconstruction. **Confirmed** if the better method differs in at least one cell; otherwise **ranking preserved,
levels shifted** if reconstruction raises either method's RMSE by at least 5% in some cell, and **refuted** if
not. Reported: each method's share of mean squared error attributable to reconstruction.

## 4. Departures from DESIGN.md

Reconstruction error only (no informative censoring, loss to follow-up, selective reporting, MNAR covariates
or informative IPD availability); one estimand; no MAIC, STC or ML-NMR layer, since the comparator's
reconstruction enters their unanchored contrasts identically; no reproduction of a published benchmark.
