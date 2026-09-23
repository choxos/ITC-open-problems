# Interaction coefficients need their own consistency check
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** In network meta-regression the treatment-by-covariate
interactions satisfy a consistency equation of their own. If direct and
indirect paths carry opposing interactions, the pooled coefficient can
be near zero while the usual consistency check on treatment effects
passes. Catalog problem COV-10 asks how often this happens, what it
costs and whether an interaction-consistency check detects it.

**Methods.** Triangle networks with two, four or eight studies per
comparison, covariate spread across studies of 0.3 or 1 SD, path
interaction slopes that were consistent, partly opposing or cancelling
(modification of 0.3 on every path pooling to zero), and treatment
effects consistent or not: 36 scenarios, 2000 replicates each.

**Results.** The effect-consistency check flagged 0.094 to 0.107 of
analyses with inconsistent interactions, its null rate. The pooled
interaction for the cancelling configuration averaged 0.000; its spread
across analyses was 1.50 to 4.23 times its model SE (0.190 against 0.053
with four studies and wide spread), so a Wald test still selected the
covariate in up to 0.882 of analyses. Either way the target effect was
biased: by -0.134 to -0.260 with partly opposing and -0.227 to -0.305
with cancelling interactions. An interaction-consistency check detected
it in 0.163 to 1.000 of analyses depending on study count and covariate
spread.

**Conclusion.** Cancellation is not a knife-edge: partial opposition
attenuates the pooled interaction across a continuum and biases the
target effect. Check the consistency of interactions directly; a passed
effect-consistency check says nothing about them.

# The problem

Consistency requires $d_{BC} = d_{AC} - d_{AB}$ for effects and,
separately, $\beta_{BC} = \beta_{AC} - \beta_{AB}$ for interactions.
With equal precision on the three paths a consistency meta-regression
estimates C’s interaction as $(s_{AB} + 2s_{AC} + s_{BC})/3$ from the
path slopes, so slopes of $-0.3$, $0.3$ and $-0.3$ give zero although
each path is modified. The effect check ([1](#ref-bucher1997)) compares
intercepts, not slopes, and cannot see it.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Study estimates with SE 0.1; covariate means
$N(0.5, \text{SD}^2)$; effects $d_{AB} = -0.3$, $d_{AC} = -0.5$,
$d_{BC} = -0.2$ plus a loop shift of 0 or 0.2. Path slopes
$(aB, B, cB)$, $B = 0.3$: consistent $(0, 1)$, partly opposing
$(-0.5, -0.5)$, cancelling $(-1, -1)$. The covariate is kept if the Wald
test of both interactions has $p < 0.10$. Target: C versus A at
covariate 1.5 with the AC path’s truth.

# Results

<div id="fig-checks">

![](figures/fig1-checks.png)

Figure 1: Flag rates of the interaction-consistency and
effect-consistency checks by studies per comparison. The dashed line is
the nominal 0.10.

</div>

The two checks responded to different parameters
(<a href="#fig-checks" class="quarto-xref">Figure 1</a>): the
interaction check reached 1.000 with eight studies and wide covariate
spread but only 0.227 with two studies and narrow spread, while the
effect check fired only when effects themselves were inconsistent.

The masking showed in the value of the pooled coefficient, not in
selection: under inconsistency the model-based SE assumes the paths
agree, so the estimate scattered well beyond it and the Wald test often
rejected. Whether selected or not, the analysis used an attenuated
interaction and missed the target by 0.13 to 0.30. With consistent
interactions and narrow covariate spread, selection itself cost coverage
(as low as 0.318) because the covariate was often dropped.

# What this does not answer

Stylized triangles with continuous study estimates; the
design-by-treatment interaction model and larger networks were not run.
Per-path regressions with two studies and narrow covariate spread were
unstable, so the AC-path estimates in `results/decision.md` are not
interpretable there. Peer review has not been done.

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

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
