# Which evidence drives a network contrast changes across the plausible
range of heterogeneity
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Contribution tables attribute a network meta-analysis
contrast to its studies and comparisons ([1](#ref-papakonstantinou2018))
and feed certainty assessments. They are computed at the point estimate
of the between-study SD $\tau$. Catalog problem DEC-17 asks whether they
are stable across its plausible range.

**Methods.** Three-treatment star and loop networks of 4, 8 or 16
two-arm studies, with equal or 5:1 within-study variances and true
$\tau$ of 0, 0.1 or 0.25; absolute hat-matrix contribution shares for
the indirect-or-mixed contrast, evaluated across the REML profile
interval for $\tau$; 1000 networks per cell.

**Results.** In the loop network with four studies and unequal
within-study variances, the leading contributing comparison changed
across the $\tau$ interval in 38% to 42% of networks, and some study’s
share moved by 0.152 to 0.159 on average. With equal within-study
variances shares did not move at all. The REML estimate of $\tau$ was
zero in 30% to 67% of four-study networks and the interval’s upper end
reached the grid’s cap in up to 62%.

**Conclusion.** A contribution table is conditional on one value of
$\tau$. With few studies of unequal precision it should be reported
across the plausible range of $\tau$, or stated as conditional on the
point estimate.

# The problem

Contribution shares are functions of the weights $(V + \tau^2I)^{-1}$.
As $\tau$ grows the weights flatten, so precise studies lose share and
imprecise ones gain, and the leading study or comparison can change.
With few studies $\tau$ is poorly determined, so the share reported at
$\hat\tau$ is one point in a wide range. With equal within-study
variances the weights are proportional at every $\tau$ and shares cannot
move.

# Design

Registered protocol: `protocol.md`. Treatments A, B, C; two-arm studies
of AB and AC (star) or AB, AC and BC (loop), allocated in turn;
within-study variances 0.04, or 0.02 to 0.10 assigned at random; target
contrast C versus B. $\tau^2$ by REML on a grid over $[0, 1]$ with its
95% profile-likelihood interval. A study’s share is its absolute entry
in the target row of the hat matrix over their sum; a comparison’s share
sums its studies’. In the star network the target needs both comparisons
with coefficient one, so comparison-level shares are exactly 50% at
every $\tau$ and only study-level shares are informative (the
comparison-level entries for the star in `results/decision.md` are ties
broken by rounding and are not results).

# Results

<div id="fig-leading">

![](figures/fig1-leading.png)

Figure 1: Share of networks whose leading contributor changes across the
$\tau$ interval, 5:1 within-study variance spread.

</div>

<div id="tbl-main">

Table 1: 5:1 within-study variance spread; with equal variances no share
moved in any cell. 1000 networks per cell.

| network | studies | true $\tau$ | leading comparison changes | leading study changes | mean largest share movement | leading study at $\hat\tau$ differs from true $\tau$ | $\hat\tau = 0$ |
|----|---:|---:|---:|---:|---:|---:|---:|
| star | 4 | 0.00 | tie | 0% | 0.125 | 0% | 65% |
| loop | 4 | 0.00 | 42% | 42% | 0.159 | 6% | 67% |
| star | 8 | 0.00 | tie | 15% | 0.095 | 2% | 62% |
| loop | 8 | 0.00 | 35% | 31% | 0.104 | 7% | 61% |
| star | 16 | 0.00 | tie | 14% | 0.050 | 2% | 58% |
| loop | 16 | 0.00 | 1% | 10% | 0.058 | 3% | 56% |
| star | 4 | 0.10 | tie | 0% | 0.126 | 0% | 57% |
| loop | 4 | 0.10 | 41% | 41% | 0.157 | 11% | 55% |
| star | 8 | 0.10 | tie | 18% | 0.096 | 5% | 48% |
| loop | 8 | 0.10 | 35% | 30% | 0.103 | 10% | 50% |
| star | 16 | 0.10 | tie | 16% | 0.054 | 4% | 36% |
| loop | 16 | 0.10 | 2% | 13% | 0.061 | 5% | 35% |
| star | 4 | 0.25 | tie | 0% | 0.122 | 0% | 37% |
| loop | 4 | 0.25 | 38% | 38% | 0.152 | 15% | 36% |
| star | 8 | 0.25 | tie | 18% | 0.093 | 8% | 19% |
| loop | 8 | 0.25 | 31% | 27% | 0.101 | 10% | 17% |
| star | 16 | 0.25 | tie | 16% | 0.048 | 4% | 4% |
| loop | 16 | 0.25 | 0% | 6% | 0.055 | 1% | 5% |

</div>

The registered primary was confirmed
(<a href="#fig-leading" class="quarto-xref">Figure 1</a>,
<a href="#tbl-main" class="quarto-xref">Table 1</a>). Instability was
greatest where $\tau$ is least determined and precision most unequal:
four- and eight-study loop networks. With sixteen studies the interval
for $\tau$ narrowed and the leading comparison was stable in almost
every network, but the leading study still changed in 6% to 13% of them.
Taking shares at $\hat\tau$ rather than at the true $\tau$ changed
individual shares by only 0.01 to 0.05 on average; the problem is not
that $\hat\tau$ is badly biased but that the data cannot distinguish
values of $\tau$ that attribute the contrast differently.

# What this does not answer

One contribution measure (absolute hat-matrix row), not the
shortest-path or random-walk flow decompositions; three treatments,
two-arm studies; frequentist only, so no posterior distribution of
contributions, information-matrix interval or bootstrap. Peer review has
not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-papakonstantinou2018" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Theodoros Papakonstantinou,
Adriani Nikolakopoulou, Gerta Rücker, Anna Chaimani, Guido Schwarzer,
Matthias Egger, Georgia Salanti. Estimating the contribution of studies
in network meta-analysis: Paths, flows and streams. F1000Research.
2018;7:610.</span>

</div>

</div>
