# Interval censoring fixes the visit grid of an external comparator but
not the events it misses
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A trial assesses progression at scheduled visits with
adjudication; a routine-care comparator sees patients irregularly and
can miss progression. Catalog problem QBA-07 asks which of these
ascertainment differences an interval-censored analysis covers.

**Methods.** Unanchored RMST(24) comparison of a trial arm (visits every
2 months, every event detected) with an external arm (visits about every
3 months, regular or more frequent for higher-risk patients, per-visit
detection probability 1, 0.85 or 0.7), with a true difference of 0 or
1.59 months: 12 scenarios, 1000 replicates each. Kaplan-Meier on
recorded times, interval midpoints, and an interval-censored Weibull
model.

**Results.** With every event detected, the interval-censored model was
within 0.05 months of the truth under both visiting patterns, where
recorded times were biased by up to 0.42. When the external arm missed
events, every method was biased: 0.25 to 0.38 months at a per-visit
sensitivity of 0.85 and 0.67 to 0.94 at 0.7, up to more than half the
true difference.

**Conclusion.** Interval censoring handles grid differences, and here
risk-dependent visiting too; missed detections need their own bias
parameter, the per-visit sensitivity, in a sensitivity analysis.

# The problem

With every event detected at the next visit and visits unrelated to
risk, the event is known to lie between the last negative and the
detecting visit, and an interval-censored likelihood is correct
(OUT-14). A missed detection moves the recorded event one or more visits
later while the last negative visit, as recorded, is already after the
event, so the bracket itself is wrong. RMST ([1](#ref-royston2013))
accumulates the delay.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Weibull event times (shape 1.2, median 12 months
in A) with a normal frailty on the log hazard (SD 0.6). Risk-dependent
visiting: each external patient’s spacing proportional to $e^{-0.5Z}$
with the same average. Administrative end at 36 months and uniform
dropout from 12 to 60 months.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the RMST(24) difference by per-visit detection
sensitivity, for each visiting pattern and true difference.

</div>

The midpoint and interval-censored methods tracked each other
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>) and removed the
grid bias. Visiting that depended on risk reduced the recorded-time bias
rather than creating one, because the patients most likely to progress
were seen most often; the interval-censored model was unaffected at this
strength, against DESIGN.md’s prediction. Missed detections added bias
roughly in proportion to the miss probability, and no method in the grid
addressed it.

# What this does not answer

No recording lag, linkage loss or false-positive events; one frailty
strength and visiting dependence; no sensitivity analysis implemented
over the detection parameter; no covariates or population adjustment.
Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-royston2013" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Patrick Royston, Mahesh K. B.
Parmar. Restricted mean survival time: An alternative to the hazard
ratio for the design and analysis of randomized trials with a
time-to-event outcome. BMC Medical Research Methodology. 2013;13:152.
doi:[10.1186/1471-2288-13-152](https://doi.org/10.1186/1471-2288-13-152)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
