# outstandR’s G-computation estimate moved by about 0.05 on the log odds
ratio across defensible target reconstructions
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** outstandR ([1](#ref-outstandr)) standardizes an
individual-data trial’s outcome model over a pseudo-population simulated
from the aggregate trial’s published means and SDs, by default with
normal margins and a Gaussian copula whose correlation is taken from the
individual data. Catalog problem SFW-12 asks how far its estimate
depends on that reconstruction.

**Methods.** Skewed target covariates (gamma margins) joined by a
Clayton or Gaussian copula at correlation 0.5; individual data with the
same or a lower correlation; an anchored binary-outcome comparison; the
package’s G-computation routine under five reconstructions; 400
replicates per cell.

**Results.** Within a dataset the estimate ranged over 0.049 to 0.052 on
the log odds ratio scale across the five reconstructions, at the
registered materiality threshold of 0.05, and about a fifth of the
estimate’s sampling SD (0.24 to 0.26). The default’s bias was -0.055 to
-0.018; specifying gamma margins removed most of it (-0.011 to 0.009
with the target’s correlation). Whether the true copula was
tail-dependent changed the range by at most 0.002.

**Conclusion.** The reconstruction moves an outstandR estimate by an
amount comparable to a materiality threshold but small against its
sampling error. The margin family matters more than the copula;
reporting the estimate across reconstructions is cheap with the
package’s own arguments.

# The problem

G-computation integrates the fitted outcome model over the target’s
covariate law, which a publication describes only by marginal summaries.
The package fills the gap with an assumption: normal margins unless told
otherwise, and the individual data’s correlation. Each is an analyst
choice that the published output does not display.

# Design

Registered protocol: `protocol.md`. Target
$x_1 \sim \text{Gamma}(2, 2)$, $x_2 \sim \text{Gamma}(4, 4)$, Clayton or
Gaussian copula at Pearson 0.5; individual data from
$\text{Gamma}(2, 2.5)$ and $\text{Gamma}(4, 5)$ with a Gaussian copula
at 0.5 or 0.1; 300 per arm per trial;
$\operatorname{logit}p = -1 + 0.5x_1 + 0.5x_2 + a(\delta + 0.6x_1 + 0.4x_2)$
with $\delta = -0.5$ (A) and $-0.7$ (B). The package’s internal
`gcomp_ml_means()` was called directly with 20000 pseudo-patients and no
bootstrap.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the anchored estimate under each reconstruction.

</div>

<div id="tbl-main">

Table 1: Mean over 400 replicates of the within-dataset range.

| target copula | IPD correlation | mean range across reconstructions | from the correlation choice | from the margin family |
|----|---:|---:|---:|---:|
| gaussian | 0.5 | 0.052 | 0.023 | 0.029 |
| clayton | 0.5 | 0.050 | 0.023 | 0.028 |
| gaussian | 0.1 | 0.049 | 0.022 | 0.020 |
| clayton | 0.1 | 0.049 | 0.022 | 0.021 |

</div>

The registered primary called the sensitivity material, and it sat on
the threshold in every cell
(<a href="#tbl-main" class="quarto-xref">Table 1</a>). The margin family
and the correlation each accounted for about half of the range
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>). Normal margins
on skewed covariates biased the estimate by 0.02 to 0.06; independence
was worst; using the individual data’s correlation when the target’s
differed added bias. The copula’s tail dependence changed the range by
at most 0.002, which agrees with CMP-15’s finding that the family’s
effect on the logit scale is a few hundredths.

# What this does not answer

Pairwise anchored comparison, two covariates, a correctly specified
outcome model, point estimates only; no Bayesian G-computation,
multiple-imputation marginalization or network use. Peer review has not
been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-outstandr" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Nathan Green, Chengyang Gao,
Antonio Remiro-Azócar. <span class="nocase">outstandR</span>:
Model-based standardisation for indirect treatment comparison with
limited subject-level data \[Internet\]. 2026. Available from:
<https://CRAN.R-project.org/package=outstandR></span>

</div>

</div>
