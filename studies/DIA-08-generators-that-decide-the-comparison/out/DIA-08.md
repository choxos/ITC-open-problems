# Departures from shared linear effect modification did not reorder
population-adjustment methods
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Simulation studies of population adjustment usually
generate shared linear effect modification, which makes the restriction
of a linear outcome model true. Catalog problem DIA-08 asks whether
departures from that structure reverse the method ranking, so that
published rankings reflect the generator.

**Methods.** Anchored binary-outcome comparison with reported moments
held fixed. A’s effect modification was linear, a threshold, a
modifier-by-modifier interaction or quadratic, at target covariate means
of 0.3, 0.8 and 1.2 SD, plus skewed covariates with linear modification:
16 scenarios, 2000 replicates each. Unadjusted, MAIC on means, MAIC on
means and SDs, STC with linear interactions and STC with quadratic and
product terms were ranked by RMSE.

**Results.** The RMSE ordering under linear modification was reproduced
under every departure (rank correlation 0.90 to 1.00); the only change
was a swap between the two worst methods. STC with linear interactions
ranked first in every scenario, although its bias grew to 0.119 under
the interaction departure at the poorest overlap, because MAIC’s
variance there was far larger (RMSE 0.344 against 0.534). Registered
verdict: refuted.

**Conclusion.** At these magnitudes, departures that break a linear
model’s restriction biased it less than weighting’s loss of effective
sample size cost the alternatives, so rankings were set by variance and
survived. A generator decides a ranking only when the departure’s bias
exceeds the precision differences between methods.

# The problem

A method that imposes a restriction true under the generator gains
efficiency for free, so under shared linear modification a linear STC
should win on RMSE. A departure from linearity biases it and leaves
MAIC’s matching of moments comparatively unaffected, so the ranking
might reverse. Whether it does depends on whether the new bias is large
relative to the variance differences, which published comparisons
([1](#ref-phillippo2020)) do not separate.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). AC trial with individual data, 300 per arm; BC
trial in the target, 300 per arm, reporting covariate means and SDs and
arm event counts.
$\operatorname{logit}p = -0.5 + 0.5(x_1 + x_2) + \text{treatment}$; B’s
effect $-0.8$; A’s effect $-0.6 + 0.4x_1 + 0.4x_2$ (linear), with the
$x_1$ term replaced by $0.8\,\mathbb 1(x_1 > 0.5)$ (threshold), or plus
$0.4x_1x_2$ (interaction) or $0.3x_1^2$ (quadratic). Estimand: marginal
log odds ratio, B versus A, in the target. STC marginalizes over normals
with the reported moments.

The registered rule reads a Spearman correlation of at least 0.9 as
orderings surviving. With five methods one adjacent swap gives exactly
0.9, which the first run of the analysis stored as 0.8999… and
classified as partial; the correlation is now rounded before comparison,
which changes the verdict to refuted and nothing else.

# Results

<div id="fig-rmse">

![](figures/fig1-rmse.png)

Figure 1: RMSE and bias by method and effect-modification structure at
three overlap levels.

</div>

RMSE was nearly flat across departures for every method
(<a href="#fig-rmse" class="quarto-xref">Figure 1</a>); what changed it
was overlap. The departures moved the linear STC’s bias from about zero
to 0.119, while its RMSE advantage over MAIC at the poorest overlap
exceeded 0.2. The quadratic STC, correctly specified under two of the
departures, paid more in variance than it saved in bias. Skewed
covariates reordered the second and third methods at the smallest shift,
as much as any modification departure did.

# What this does not answer

Departure magnitudes were moderate (they changed the target effect by
0.1 to 0.3 on the log odds ratio scale); stronger departures or larger
trials, where variance matters less, can reverse the ranking.
Treatment-specific, subnetwork and within-versus-between departures need
a network and were not run; no ML-NMR. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-phillippo2020" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Nicky J. Welton. Assessing the performance of population
adjustment methods for anchored indirect comparisons: A simulation
study. Statistics in Medicine. 2020;39(30):4885–911.
doi:[10.1002/sim.8759](https://doi.org/10.1002/sim.8759)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
