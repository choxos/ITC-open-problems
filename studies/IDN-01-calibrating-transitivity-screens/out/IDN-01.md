# Transitivity screens have blind spots that can be constructed, and
their union shares one
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Transitivity cannot be tested directly; it is screened
by comparing reported study characteristics across comparisons, testing
loop inconsistency and measuring heterogeneity. Catalog problem IDN-01
asks how well these screens perform together and whether their pattern
identifies which assumption failed.

**Methods.** Triangle networks (A, B, C) with two or five studies per
comparison. Five mechanisms of size 0.1, 0.2 or 0.4: none; a measured
modifier whose study means differ by comparison; an unmeasured modifier
making C look better in every comparison that includes it, which keeps
the loop consistent; a loop-breaking shift; and study-level drift. 26
scenarios, 2000 replicates each. Screens at $p < 0.10$: dissimilarity of
the measured modifier, the Bucher loop test and Cochran’s $Q$. Target: B
versus C in a declared population, by consistency network meta-analysis.

**Results.** The loop-consistent unmeasured modifier of size 0.4 biased
the network estimate by -0.402 (coverage 0.004 or less) while at least
one screen fired in 0.279 to 0.281 of analyses, the same as with no
violation (0.274 to 0.283). A loop-breaking shift of 0.4 was flagged in
0.766 to 0.975 and drift in 0.948 to 1.000. A measured modifier was
flagged every time although meta-regression left the estimate unbiased.
Reading the mechanism from which screen fired was right for 0.433 of
loop breaks and 0.341 of drift analyses.

**Conclusion.** Each screen sees one direction of violation, and a
violation that shifts a treatment consistently wherever it was tested is
invisible to all of them while biasing the result as much as any.
Passing every screen does not establish transitivity, a failed screen
does not identify the mechanism, and a dissimilarity flag need not mean
bias.

# The problem

A screen $T$ is a function of observed data; if the transport
restriction $R$ implies $T$, then failing $T$ refutes $R$, but passing
$T$ does not confirm it. A violation whose projection onto what $T$
responds to is zero is detected at $T$’s size. Dissimilarity sees
reported covariates, the loop test ([1](#ref-bucher1997)) sees
violations that break the loop, and heterogeneity
([2](#ref-cochran1954)) sees within-comparison variation. An unreported
modifier that makes one treatment look better in every comparison that
includes it changes no reported covariate, keeps the loop closed and
adds no within-comparison variation.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([3](#ref-morris2019)). Study estimates with SE 0.15; $d_B = -0.3$,
$d_C = -0.5$ against A. Measured modifier means 0, 0.5, 1 across AB, AC,
BC in the measured-modifier mechanism and 0.5 otherwise. The estimator
is a fixed-effect consistency model, with meta-regression on the
measured modifier when its study means vary. Mechanisms were read from
the flag pattern as: dissimilarity, measured modifier; loop test without
dissimilarity, loop break; heterogeneity alone, drift; nothing, no
violation.

# Results

<div id="fig-det">

![](figures/fig1-detection.png)

Figure 1: Proportion of analyses flagged by at least one screen against
the bias of the network estimate. The dashed line is the rate with no
violation.

</div>

<a href="#fig-det" class="quarto-xref">Figure 1</a> shows the blind
spot: the loop-consistent mechanism sits at the null detection rate at
every bias. More studies per comparison raised the power of the loop
test and $Q$ against the mechanisms they can see, and did nothing for
this one.

Identification from the flag pattern was poor. Drift also raised the
loop test’s rejection rate (to 0.568), so drift and loop breaks were
confused, and a loop break was read as no violation in 0.417 of analyses
pooled over sizes. The unmeasured mechanism produced the same pattern as
no violation in 0.717 of analyses (the decision table in
`results/decision.md` counts this as the pattern being read correctly,
which it is only in that sense). The dissimilarity screen’s firing for a
measured modifier is a correct signal that adjustment is needed, not
evidence of bias after it.

# What this does not answer

Stylized triangles with continuous study estimates rather than real
network geometries; calendar-time drift represented as random study
shifts; the published record of network meta-analyses abandoned on
transitivity grounds was not scored. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-bucher1997" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Heiner C. Bucher, Gordon H.
Guyatt, Lauren E. Griffith, Stephen D. Walter. The results of direct and
indirect treatment comparisons in meta-analysis of randomized controlled
trials. Journal of Clinical Epidemiology. 1997;50(6):683–91.
doi:[10.1016/S0895-4356(97)00049-8](https://doi.org/10.1016/S0895-4356(97)00049-8)</span>

</div>

<div id="ref-cochran1954" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">William G. Cochran. The
combination of estimates from different experiments. Biometrics.
1954;10(1):101–29.
doi:[10.2307/3001666](https://doi.org/10.2307/3001666)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
