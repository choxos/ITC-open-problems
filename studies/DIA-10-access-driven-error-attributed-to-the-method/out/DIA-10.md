# Reconstruction error from a digitized Kaplan-Meier curve was too small
to change which method ranks best for RMST
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Simulations of population-adjusted survival comparisons
use true individual data for the comparator, while real analyses
reconstruct it from a published Kaplan-Meier figure. If the omitted
reconstruction error differs between methods it changes their ranking.
Catalog problem DIA-10 asks whether it does.

**Methods.** A 250-patient comparator arm published as a pixel-rounded
Kaplan-Meier figure with a 6-monthly risk table or none, spread or
clustered censoring, at fine or coarse resolution, and reconstructed by
Guyot’s algorithm ([1](#ref-guyot2012)). Kaplan-Meier and Weibull RMST
to 24 months on true and reconstructed data, and the digitized curve
integrated directly; 1000 replicates per cell with common random
numbers.

**Results.** The better of the two methods was the same with and without
reconstruction in all 8 cells (Weibull, correctly specified here).
Reconstruction changed RMSE by at most 1%: it added a bias of 0.003 to
0.040 months to Kaplan-Meier RMST and 0.006 to 0.059 to Weibull RMST,
against a sampling SD of about 0.5 months. Integrating the digitized
curve directly did as well as reconstructing.

**Conclusion.** For RMST within follow-up, omitting reconstruction error
from a simulation does not misattribute error to methods. The larger
exposure of the likelihood-based method was visible but immaterial.

# The problem

The reported error of each method in a simulation that omits an access
mechanism is its error without that mechanism. Rankings survive only if
the omitted error is common to the methods. Reconstruction should expose
a likelihood fitted to individual event and censoring times more than a
Kaplan-Meier summary, because the reconstruction preserves the curve but
not where censoring falls.

# Design

Registered protocol: `protocol.md`. The data-generating and publication
model is OUT-13’s: Weibull event times (shape 1.2, median 18 months), 24
months of accrual and 36 of follow-up, 30% of patients also dropping out
before 6-monthly visits in the clustered pattern; the curve read at
pixel-column centers of a 1500 by 1000 or 300 by 200 plot and rounded to
the pixel grid. The individual-data arm of an unanchored RMST difference
is common to all methods and omitted.

# Results

<div id="tbl-main">

Table 1: RMSE of the comparator arm’s RMST to 24 months against the
population value (months); 1000 replicates per cell.

| resolution | risk table | censoring | KM, true data | KM, reconstructed | Weibull, true data | Weibull, reconstructed | curve integrated |
|----|----|----|---:|---:|---:|---:|---:|
| fine | 6-monthly | spread | 0.518 | 0.517 | 0.506 | 0.506 | 0.517 |
| coarse | 6-monthly | spread | 0.507 | 0.505 | 0.501 | 0.501 | 0.506 |
| fine | none | spread | 0.520 | 0.520 | 0.506 | 0.506 | 0.520 |
| coarse | none | spread | 0.513 | 0.512 | 0.501 | 0.502 | 0.511 |
| fine | 6-monthly | clustered | 0.531 | 0.530 | 0.518 | 0.517 | 0.530 |
| coarse | 6-monthly | clustered | 0.532 | 0.531 | 0.518 | 0.520 | 0.530 |
| fine | none | clustered | 0.518 | 0.518 | 0.500 | 0.499 | 0.518 |
| coarse | none | clustered | 0.513 | 0.513 | 0.504 | 0.506 | 0.513 |

</div>

The registered primary was refuted
(<a href="#tbl-main" class="quarto-xref">Table 1</a>): no ranking
changed and no RMSE moved by 5%. The reconstruction’s bias was upward
and largest at coarse resolution, because a drop read at a pixel
column’s center is recorded up to a column late; the Weibull fit carried
more of it than the Kaplan-Meier summary, as predicted, but the
difference was a few hundredths of a month.

# What this does not answer

Reconstruction error only; RMST within follow-up only, where OUT-13’s
probes found reconstruction error smallest; extrapolated survival and
hazard ratios, where censoring placement matters more, were not scored
for ranking; no human digitization variability. Peer review has not been
done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-guyot2012" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Patricia Guyot, A. E. Ades, Mario
J. N. M. Ouwens, Nicky J. Welton. Enhanced secondary analysis of
survival data: Reconstructing the data from published Kaplan-Meier
survival curves. BMC Medical Research Methodology. 2012;12:9.
doi:[10.1186/1471-2288-12-9](https://doi.org/10.1186/1471-2288-12-9)</span>

</div>

</div>
