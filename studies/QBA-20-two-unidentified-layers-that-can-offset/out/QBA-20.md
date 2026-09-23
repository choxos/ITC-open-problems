# One-at-a-time sensitivity analysis of two bias layers reports
robustness that the joint analysis does not support
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A disconnected component comparison with no cross-gap
evidence rests on two unidentified assumptions: that the populations
transport, and that shared components act the same on both sides of the
gap. Sensitivity analyses vary one at a time. Catalog problem QBA-20
asks whether that bounds their joint effect.

**Methods.** A logistic model for the cross-gap contrast with an omitted
modifier (population layer) and component main-effect and
component-by-modifier drift (bridge layer). The bias of the reported
target marginal log odds ratio (-0.20, favoring A) was computed exactly
over elicited ranges at three scales, one parameter at a time and
jointly.

**Results.** At the base scale each one-at-a-time curve stayed within
±0.157 and none reversed the decision; the joint box reached -0.413, and
7% of it reversed the decision. 24% of the box lay outside the
one-at-a-time envelope. The component-by-modifier drift moved the
estimate by at most 0.041 alone, because its effect is its product with
the omitted modifier’s imbalance. Under positively dependent elicitation
13% of draws reversed the decision.

**Conclusion.** One-at-a-time curves do not bound two layers acting on
one contrast, and the drift form current tooling excludes is the one
they cannot see. The layers must be varied jointly and the region
reported.

# The problem

A bias analysis that varies each unidentified parameter with the others
fixed at their null values measures a cross through the parameter space,
not the space ([1](#ref-greenland2005)). For additive biases the joint
range is the sum of the one-at-a-time ranges, so the cross never bounds
it. Two features make the component case worse. The drift of a
component’s interaction with a modifier biases the target contrast only
through that modifier’s imbalance between populations, a product of the
two layers that is zero along both axes of the cross. And with no
cross-gap evidence, neither layer can be checked.

# Design

Registered protocol: `protocol.md`. Individual model
$\operatorname{logit}p = -0.5 + 0.5x + 0.5u + a(-0.45 + 0.3x + 0.4u + d_m + d_iu)$
with $x$ measured and $u$ omitted; target $x \sim N(0.5, 1)$,
$u \sim N(\mu_u, 1)$. The analysis assumes $\mu_u = d_m = d_i = 0$.
Elicited half-ranges at scale 1: $\mu_u$ 0.5 (a population-layer bias of
up to about 0.13), $d_m$ 0.2, $d_i$ 0.4; scales 0.5, 1 and 1.5. Exact
quadrature; a $21^3$ grid over the box and 4000 draws from each of three
elicited distributions (independent, or correlation $\pm0.5$ between
$\mu_u$ and each drift parameter).

# Results

<div id="fig-joint">

![](figures/fig1-joint.png)

Figure 1: Bias of the reported log odds ratio at scale 1 with component
main-effect drift at its upper limit (0.2). Dashed: the one-at-a-time
envelope’s lower edge. Solid: the bias that reverses the decision; to
its right the truth favors B.

</div>

<div id="tbl-main">

Table 1: Reported log odds ratio -0.203; a bias below it reverses the
decision. Masked: both layers at least 0.1 in absolute value with net
bias below 0.05.

| scale | one-at-a-time envelope | joint envelope | box reversing | box outside envelope | masked | outside, elicited ind / + / − | reversing, elicited ind / + / − |
|---:|----|----|---:|---:|---:|----|----|
| 0.5 | -0.078 to 0.078 | -0.186 to 0.147 | 0% | 23% | 0% | 22% / 34% / 5% | 0% / 0% / 0% |
| 1.0 | -0.156 to 0.157 | -0.413 to 0.341 | 7% | 24% | 4% | 21% / 32% / 8% | 5% / 13% / 0% |
| 1.5 | -0.234 to 0.235 | -0.674 to 0.577 | 17% | 26% | 6% | 24% / 32% / 12% | 16% / 25% / 4% |

</div>

The registered failure condition held at every scale: at least 23% of
the box lay outside the one-at-a-time envelope
(<a href="#tbl-main" class="quarto-xref">Table 1</a>). At scale 1 the
one-at-a-time analysis declared the decision robust while the joint box
contained reversals, the spurious robustness the entry describes; at
scale 0.5 both declared it robust, and at 1.5 neither did. The reversal
region needs all three parameters to push the same way
(<a href="#fig-joint" class="quarto-xref">Figure 1</a>): a positive
omitted-modifier imbalance, positive main-effect drift and positive
interaction drift. Offsetting configurations also exist: in 4% of the
box both layers were material and their net bias was under 0.05, so a
correct-looking estimate could hide two large errors.

The elicited dependence mattered as much as the ranges. If the analyst
believes the two layers move together, a quarter to a third of the
elicited mass lies outside the one-at-a-time envelope; if opposite, far
less. No data inform that dependence.

# What this does not answer

A population-level calculation on one logistic model: no sampling, no
component network fit and no time-to-event scale. The joint law of
measured and omitted covariates was known, so the price of eliciting it
(the design’s fairness requirement) is not measured.
Component-by-component non-additivity and backbone interactions were not
included and are drift forms this analysis does not cover. Peer review
has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-greenland2005" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Sander Greenland. Multiple-bias
modelling for analysis of observational data. Journal of the Royal
Statistical Society Series A. 2005;168(2):267–306.
doi:[10.1111/j.1467-985X.2004.00349.x](https://doi.org/10.1111/j.1467-985X.2004.00349.x)</span>

</div>

</div>
