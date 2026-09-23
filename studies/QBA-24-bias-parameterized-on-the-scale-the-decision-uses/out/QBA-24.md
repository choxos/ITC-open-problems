# A hazard-ratio bias does not translate into a fixed RMST bias
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Bias analyses for population-adjusted survival
comparisons are usually stated on the hazard-ratio scale, while
decisions use restricted mean survival time (RMST). Catalog problem
QBA-24 asks whether a hazard-scale bias can be reinterpreted as a
proportional RMST bias.

**Methods.** Population-level calculation: four baseline hazard shapes
(constant, increasing, decreasing, bathtub), each at 80%, 50% or 20%
survival by 24 months, multiplied by bias hazard ratios of 1.1 to 2. The
change in RMST at 24 months was compared across shapes and with the
first-order (proportional) prediction.

**Results.** At the same survival by 24 months and the same bias, RMST
changed by up to 1.44 times as much for one baseline shape as another
(decreasing against increasing hazard). The proportional prediction
understated the change by about 26% at 80% survival and a bias hazard
ratio of 2, and was off by -1% to +8% at 20% survival, where RMST
saturates.

**Conclusion.** The RMST consequence of a hazard-scale bias depends on
the baseline hazard’s shape and the event level, so a hazard-ratio
sensitivity analysis cannot be read on the RMST scale without the
baseline curve. State the bias on the decision scale, or translate it
with the target’s baseline survival.

# The problem

With $h^\star = he^{\gamma}$, RMST over $[0, \tau]$
([1](#ref-royston2013)) changes by
$\int_0^\tau[\exp\{-e^{\gamma}H(u)\} - \exp\{-H(u)\}]\,du$. Its
first-order slope in $\gamma$ is $-\int_0^\tau S(u)H(u)du$, which
weights the cumulative hazard by survival and so depends on when events
occur. Beyond first order the change is convex in $\gamma$ when events
are few and saturates when most patients have an event within the
window.

# Design

Registered protocol: `protocol.md`. Cumulative hazards $c\,(t/24)^k$
with $k = 1, 1.5, 0.7$, and $c\{0.5(t/24)^{0.5} + 0.5(t/24)^3\}$ for the
bathtub shape, $c$ set for the survival level. Integrals by adaptive
quadrature.

# Results

<div id="fig-delta">

![](figures/fig1-delta.png)

Figure 1: Change in RMST at 24 months against the bias hazard ratio, by
baseline hazard shape and survival level. Dashed lines are the
proportional (first-order) predictions.

</div>

A decreasing hazard concentrates events early, where each extra unit of
hazard removes more remaining time, so the same bias moved RMST most; an
increasing hazard moved it least
(<a href="#fig-delta" class="quarto-xref">Figure 1</a>). The spread
across shapes was largest when events were fewest. The direction of the
proportional prediction’s error depended on the event level: convexity
dominated with few events and saturation with many, so no single
correction factor applies.

# What this does not answer

Only the translation from a hazard-scale bias to RMST. The unanchored
comparison with an unmeasured confounder, pseudo-IPD and curve-based
estimation, reconstruction error and tipping sets were not run. Peer
review has not been done.

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

</div>
