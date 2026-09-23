# Choosing among population-adjustment methods on the same data: the
interval survives, the estimate does not
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Analysts often fit several population-adjustment methods
and report one, with that method’s interval. Catalog problem MIS-04 asks
whether the selection matters and what averaging over the candidates
would change.

**Methods.** Re-scoring of 32,000 stored replicates from DIA-08
(anchored binary-outcome comparison, 16 scenarios), each with estimates
and SEs from MAIC on means, MAIC on means and SDs, linear STC and
quadratic STC. Rules: a prespecified method; the method with the
smallest SE; the method with the most favorable estimate; and an
equal-weight average with between-model variance added.

**Results.** Choosing the most precise method reproduced the
prespecified linear STC in most replicates and covered 0.938 to 0.956.
Choosing the most favorable estimate biased it by up to -0.259 on the
log odds ratio scale while coverage stayed at 0.927 or more, because the
favored method was often a wide-interval MAIC. Averaging with
between-model variance over-covered (up to 0.991), since the candidates
share the same data. The registered rule counts that difference, so the
refuting sentence fails as registered.

**Conclusion.** Among outcome and weighting models the candidates are
close and a conditional interval loses little coverage, but selecting by
result moves the estimate materially while its interval looks fine.
Prespecify the method. Averaging needs weights that account for the
candidates’ shared data; adding between-model variance to the mean
within-model variance is too conservative.

# The problem

Model selection is part of inference ([1](#ref-buckland1997)), and a
conditional interval ignores it. For population adjustment the
candidates are estimates from the same individual data, so they are
strongly correlated: how much selection costs depends on how far apart
they are and on which rule chooses.

# Design

Registered protocol: `protocol.md`, committed before any scoring
(DIA-08’s RMSE rankings were already known). The four candidates’
estimates and SEs per replicate came from DIA-08’s run: threshold,
interaction, quadratic and linear modification at target covariate means
0.3, 0.8 and 1.2, skewed covariates, and no modification.

# Results

<div id="fig-rules">

![](figures/fig1-rules.png)

Figure 1: Bias and coverage by selection rule across the 16 scenarios.

</div>

<a href="#fig-rules" class="quarto-xref">Figure 1</a> shows the
asymmetry. The result-selected estimate was shifted in the favored
direction in every scenario, most at poor overlap where the candidates
differed most, but its interval, often from the least precise candidate,
still covered. A reader would see a nominal interval around a biased
estimate. The averaged interval was the widest of all rules.

# What this does not answer

Selection over outcome and weighting models only; treatment partitions
and bridges, where candidates can be observationally equivalent and no
data-based weight exists, were not studied. Equal weights rather than
stacking. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-buckland1997" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">S. T. Buckland, K. P. Burnham, N.
H. Augustin. Model selection: An integral part of inference. Biometrics.
1997;53(2):603–18.
doi:[10.2307/2533961](https://doi.org/10.2307/2533961)</span>

</div>

</div>
