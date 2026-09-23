# Shared and class-specific heterogeneity cannot be told apart below
about 40 studies per class
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Network analyses usually assume one between-study
variance for all treatment classes. Separate variances are available,
but whether the data can choose between the structures at realistic
network sizes has not been measured. Catalog problem HET-03 asks at what
number of studies per class they become distinguishable.

**Methods.** Two classes of 2 to 40 studies each, with a between-study
variance ratio of 1, 2 or 5; shared and separate REML fits compared by
AIC, BIC and a likelihood-ratio test; 2000 replicates per cell.

**Results.** With a fivefold variance ratio, AIC chose separate
variances in 18% of networks with five studies per class, 40% with
twelve and 79% with forty. Balanced accuracy (choosing correctly under
both truths) reached 0.8 only at 40 studies per class, and only for AIC;
BIC and the likelihood-ratio test did not reach it within 40. With a
twofold ratio no criterion detected the difference in more than 27% of
networks.

**Conclusion.** At the network sizes population-adjusted analyses use,
the heterogeneity structure cannot be chosen from the data. The shared
default is untested rather than supported, and structure should be set
by prior evidence and reported as an assumption.

# The problem

The likelihood information about a class-specific between-study variance
grows with that class’s study count, and with few studies a separate
variance is only nominally identified. Empirical priors for
heterogeneity exist ([1](#ref-turner2012)), but whether the variance
structure itself can be selected from data has not been established for
network sizes typical of population-adjusted analyses.

# Design

Registered protocol: `protocol.md`. Two classes of $m$ studies; study
estimates with within-study SE uniform on 0.1 to 0.25 and between-study
SDs 0.1 and $0.1\sqrt{R}$. REML fits with one or two variances;
selection by AIC, BIC (with $2m - 2$ residual degrees of freedom) and a
5% likelihood-ratio test against $\chi^2_1$.

# Results

<div id="fig-selection">

![](figures/fig1-selection.png)

Figure 1: Share of networks choosing separate variances.

</div>

<div id="tbl-main">

Table 1: 2000 replicates per cell.

| studies per class | AIC: separate chosen, ratio 5 | ratio 2 | ratio 1 (false positive) | balanced accuracy AIC | BIC | LRT |
|---:|---:|---:|---:|---:|---:|---:|
| 2 | 0.019 | 0.009 | 0.006 | 0.507 | 0.539 | 0.500 |
| 3 | 0.098 | 0.040 | 0.024 | 0.537 | 0.555 | 0.503 |
| 5 | 0.184 | 0.087 | 0.049 | 0.568 | 0.566 | 0.518 |
| 8 | 0.295 | 0.119 | 0.086 | 0.605 | 0.584 | 0.550 |
| 12 | 0.404 | 0.149 | 0.103 | 0.650 | 0.610 | 0.585 |
| 20 | 0.568 | 0.190 | 0.143 | 0.712 | 0.668 | 0.660 |
| 40 | 0.789 | 0.271 | 0.146 | 0.821 | 0.766 | 0.784 |

</div>

The registered deliverable is a threshold of 40 studies per class for
AIC and none within 40 for the other criteria
(<a href="#tbl-main" class="quarto-xref">Table 1</a>,
<a href="#fig-selection" class="quarto-xref">Figure 1</a>). Below twelve
studies per class every criterion chose the shared structure in most
networks even when the variances differed fivefold, so a converged
separate-variance fit in a small network says little about the data. BIC
with very few studies chose separate variances more often under the null
than AIC, because its penalty per parameter, $\log(2m - 2)$, is below 2
when $m = 2$.

# What this does not answer

Two classes, contrast-level data and frequentist criteria; no Bayesian
model comparison, informative priors, ML-NMR fit or class-specific
treatment SD. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-turner2012" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Rebecca M. Turner, Jonathan Davey,
Mike J. Clarke, Simon G. Thompson, Julian P. T. Higgins. Predicting the
extent of heterogeneity in meta-analysis, using empirical data from the
Cochrane database of systematic reviews. International Journal of
Epidemiology. 2012;41(3):818–27.
doi:[10.1093/ije/dys041](https://doi.org/10.1093/ije/dys041)</span>

</div>

</div>
