# Stacking the weighting step into the MAIC sandwich makes intervals
narrower, not better
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** MAIC weights are estimated, and a variance that treats
them as fixed omits a term. Catalog problem SFW-10 asks whether stacking
the weight and outcome estimating equations improves on the fixed-weight
sandwich and on the ESS-based conventional variance that Chandler and
Proskorovsky found accurate ([1](#ref-chandler2024)), and what a trimmed
analysis estimates.

**Methods.** Binary-outcome MAIC with three covariates, 90 scenarios
crossing target shift, event risk, effect modification, its alignment
with the prognostic direction and weight trimming, 1000 replicates each.
Four variance estimators: fixed-weight sandwich, ESS-based, stacked
sandwich, stacked with an $n/(n-k)$ correction. Trimmed analyses were
scored against the declared target and against the population the capped
weights induce.

**Results.** Stacking lowered the standard error relative to the
fixed-weight sandwich in all 30 untrimmed scenarios (ratio 0.887 to
0.993), so the weighting term had one sign here, not the two DESIGN.md
expected. Because intervals already undercovered at poor overlap,
stacking made coverage worse: 0.844 to 0.953 against 0.893 to 0.960 for
the fixed-weight sandwich and 0.885 to 0.980 for the ESS-based variance.
Coverage within 0.93 to 0.97 held in 24, 18 and 17 of 30 scenarios
respectively. Trimming moved the estimand by up to 0.192 on the log odds
ratio scale.

**Conclusion.** The stacked sandwich is the asymptotically correct
variance, and at the effective sample sizes where MAIC variance matters
it is the most anticonservative of the four. The fixed-weight sandwich
or the ESS-based variance, as current guidance recommends, is the better
default. A trimmed analysis should report the population its weights
induce.

# The problem

MAIC solves $\sum_i w_i(x_i - m_T) = 0$ with
$w_i = \exp(\alpha^\top(x_i - m_T))$ and then computes weighted arm
risks. Stacking both sets of estimating equations gives
$A^{-1}BA^{-\top}$, whose outcome block carries a term through
$\partial g_{\text{outcome}}/\partial\alpha$ that the fixed-weight
sandwich drops. For calibration-type weights, estimating the weights
projects out outcome variation explained by the balancing covariates,
which lowers the variance. Trimming caps the weights, breaks the
calibration, and so changes the population the analysis describes.

# Design

Registered protocol: `protocol.md`. Individual-data trial A versus C,
200 per arm, three independent normal covariates;
$\operatorname{logit} p = \operatorname{logit}(\pi) +
0.5\sum_j x_j + A(-0.5 + \beta x_1)$; MAIC on means to
$N(s\mathbf 1, I)$. Factors: $s \in \{0.2, 0.5, 0.8\}$,
$\pi \in \{0.1, 0.3\}$, $\lvert\beta\rvert \in \{0, 0.5, 1\}$ with
$\beta$ of either sign, trimming none or capped at the 99th or 95th
weight percentile. Truths by Monte Carlo over 400,000 draws with
population-level weights.

# Results

<div id="fig-cov">

![](figures/fig1-coverage.png)

Figure 1: Coverage of each variance estimator against the mean ESS of
the scenario, untrimmed analyses. Dotted lines mark 0.93 and 0.97.

</div>

All four estimators lose coverage as ESS falls
(<a href="#fig-cov" class="quarto-xref">Figure 1</a>). The stacked
sandwich falls fastest because it is the smallest; the $n/(n-k)$
correction, with $k = 5$ parameters and 400 patients, is too small to
matter. The registered comparison of the ESS-based and stacked variances
reads “holds” (in band in 18 against 17 scenarios): stacking adds
nothing an analyst can use. The ESS-based variance overcovered at good
overlap (up to 0.980), the fixed-weight sandwich was closest to nominal
overall.

In trimmed analyses the declared and induced truths differed by up to
0.192, most at the 95th-percentile cap, and the estimate was closer to
the induced truth in 72% of trimmed scenarios: trimming changes what is
estimated, not only how precisely.

# What this does not answer

No bootstrap arm and no small-sample correction beyond $n/(n-k)$; one
sample size, so the point at which stacking’s asymptotic advantage
appears is not located. Binary outcome, three covariates, MAIC on means.
The induced population is computed from population-level weights and a
population cap. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-chandler2024" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Conor Chandler, Irina
Proskorovsky. Uncertain about uncertainty in matching-adjusted indirect
comparisons? A simulation study to compare methods for variance
estimation. Research Synthesis Methods. 2024;15(6):1094–110.
doi:[10.1002/jrsm.1759](https://doi.org/10.1002/jrsm.1759)</span>

</div>

</div>
