# Adding time-constant component hazard ratios mispredicted a
combination’s RMST when effects were delayed or follow-up differed
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Component survival models add time-constant log hazard
ratios. A time-constant fit to a time-varying effect is a least-false
average weighted by each trial’s own event times, so two components’
averages from different trials need not add up to the combination’s.
Catalog problem CMP-18 asks whether this matters for the estimands
decisions use.

**Methods.** Trials of each of two components against control, 300 per
arm, with constant, jointly delayed, or delayed-versus-waning effects,
and follow-up of 3 years in both or 1.5 and 3 years; stratified Cox
models with time-constant or piecewise (before and after one year)
component effects predicting the combination’s 3-year RMST difference;
bootstrap SEs; 500 replicates per cell.

**Results.** With both effects delayed, the time-constant prediction was
biased by 0.055 years (truth 0.405), coverage 0.884, and the piecewise
model reduced the bias to 0.017 (coverage 0.942). With delayed and
waning effects and unequal follow-up, the time-constant prediction was
biased by -0.102 (coverage 0.820) and the piecewise model by -0.072
(coverage 0.906), because neither can learn a late effect the shorter
trial never observed.

**Conclusion.** A time-constant component effect is adequate only when
the combination’s effect is itself roughly constant and the trials cover
the same follow-up. A time-varying extension fixes the first condition,
not the second.

# The problem

A Cox fit to a non-proportional effect converges to a least-false hazard
ratio that depends on the event-time distribution and censoring
([1](#ref-struthers1986)). Component models add such summaries across
trials with different follow-up and different effect profiles, and then
apply the sum to a combination nobody observed. The prediction is right
only if the summaries’ weights match and the combined effect is constant
in time.

# Design

Registered protocol: `protocol.md`. Control hazard Weibull (shape 1.2,
scale 3 years). Log hazard ratios: constant ($-0.4$ each), both delayed
($-0.5(1 - e^{-t/0.7})$), or A delayed and B waning ($-0.5e^{-t/0.7}$),
whose sum is constant at $-0.5$. The combination’s log hazard ratio is
the sum. Prediction: trial 1’s control Nelson-Aalen cumulative hazard
times the fitted hazard ratios; SEs from 60 bootstrap resamples within
trial arms.

# Results

<div id="tbl-main">

Table 1: 3-year RMST difference of the combination (years); 500
replicates per cell, bias MCSE at most 0.005.

| component profiles | follow-up A, B (years) | truth | constant: bias (coverage) | piecewise: bias (coverage) |
|----|----|---:|----|----|
| constant | 3.0, 3.0 | 0.481 | -0.004 (0.932) | -0.008 (0.940) |
| same | 3.0, 3.0 | 0.405 | 0.055 (0.884) | 0.017 (0.942) |
| different | 3.0, 3.0 | 0.327 | -0.011 (0.956) | -0.013 (0.952) |
| different | 1.5, 3.0 | 0.327 | -0.102 (0.820) | -0.072 (0.906) |

</div>

The registered rule returned that neither model was nominal where it
mattered (<a href="#tbl-main" class="quarto-xref">Table 1</a>): at
unequal follow-up the piecewise model covered 0.906, below the 0.93
required. Two failures appeared. **Delayed effects:** a constant hazard
ratio moves benefit earlier than a delayed one, and RMST credits early
benefit, so the time-constant prediction overstated the combination’s
gain even with equal follow-up; the piecewise model largely corrected
it. **Unequal follow-up:** component A’s effect after 1.5 years was
never observed, so both models extrapolated its effect from the early
period, where it had not yet appeared. With delayed and waning effects
and equal follow-up the time-constant model was accurate, because the
two effects summed to a constant and the trials weighted time alike.

# What this does not answer

Two single-component trials rather than a component network; no
disconnection or population adjustment; one piecewise extension; one
horizon. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-struthers1986" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Christopher A. Struthers, John D.
Kalbfleisch. Misspecified proportional hazard models. Biometrika.
1986;73(2):363–9.
doi:[10.1093/biomet/73.2.363](https://doi.org/10.1093/biomet/73.2.363)</span>

</div>

</div>
