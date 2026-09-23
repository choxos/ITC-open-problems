# Selecting effect modifiers on the analyzed data narrows the STC
interval; resampling the whole procedure restores it
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Effect modifiers for a simulated treatment comparison
(STC) are often chosen by testing interactions on the same data, and the
interval then treats the chosen model as fixed. Catalog problem DEC-11
asks how much coverage this costs and whether the interval should
include the selection step.

**Methods.** G-computation STC with six candidate modifiers, one or
three of them real, 100 to 1000 patients per arm, binary outcome, target
covariate means shifted by 0.4 SD: 6 scenarios, 400 replicates each.
Rules: all six interactions, the true ones, none, those with $p < 0.2$,
and lasso; the significance rule was also paired with a bootstrap that
repeats the selection.

**Results.** After significance selection the naive interval covered
0.887 to 0.927, its SE 7% to 20% smaller than the estimate’s spread. The
whole-procedure bootstrap covered 0.938 to 0.968. Lasso at the
one-standard-error penalty kept almost no interactions (at most 0.15 on
average) and behaved like dropping them all: coverage 0.333 with three
real modifiers at 1000 per arm. Fitting all six interactions covered
0.930 to 0.963.

**Conclusion.** An interval after data-driven modifier selection must
include the selection, by resampling the whole procedure; otherwise fit
all candidate interactions. Penalized selection tuned for prediction can
remove real modifiers and leave the transported effect biased.

# The problem

Conditioning on a model chosen from the data makes the naive interval
too narrow unless the selection is part of the variance
([1](#ref-berk2013)). In STC the selected interactions determine how the
effect is transported, so both the point estimate and its interval
depend on the selection.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Six independent normal candidates;
$\operatorname{logit}p = -0.5 + 0.3\sum_jx_j + A(-0.5 + 0.3\sum_{m \in M}x_m)$
with $M$ the first one or three; target covariate means 0.4. Estimand:
target marginal log odds ratio (Monte Carlo over $10^6$ draws).
G-computation from a logistic model with all six main effects and the
selected interactions; delta-method intervals; whole-procedure bootstrap
with 60 resamples. Lasso ([3](#ref-tibshirani1996)) penalized the
interactions only, with the penalty chosen by 5-fold cross-validation
(one-standard-error rule).

# Results

<div id="fig-cov">

![](figures/fig1-coverage.png)

Figure 1: Coverage of the 95% interval by selection rule and sample
size.

</div>

The significance rule’s shortfall came from variance, not bias (bias at
most 0.046): selection sometimes kept a modifier and sometimes not, and
the naive SE saw only one of those models
(<a href="#fig-cov" class="quarto-xref">Figure 1</a>). With three
modifiers the shortfall was not monotone in sample size, as registered:
it was largest at 300 per arm, where selection was most unstable (all
true modifiers kept in 0.26 of analyses). Omitting the interactions
biased the effect by about 0.2 with three modifiers, and the lasso rule
inherited that bias because its cross-validated penalty favored
prediction of the outcome, to which the interactions contribute little.

# What this does not answer

STC only; MAIC-based selection, overlap levels, larger candidate sets
and uncertainty in the target summaries were not run; 400 replicates and
60 bootstrap resamples per analysis. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-berk2013" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Richard Berk, Lawrence Brown,
Andreas Buja, Kai Zhang, Linda Zhao. Valid post-selection inference. The
Annals of Statistics. 2013;41(2):802–37.
doi:[10.1214/12-AOS1077](https://doi.org/10.1214/12-AOS1077)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-tibshirani1996" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Robert Tibshirani. Regression
shrinkage and selection via the lasso. Journal of the Royal Statistical
Society Series B. 1996;58(1):267–88.
doi:[10.1111/j.2517-6161.1996.tb02080.x](https://doi.org/10.1111/j.2517-6161.1996.tb02080.x)</span>

</div>

</div>
