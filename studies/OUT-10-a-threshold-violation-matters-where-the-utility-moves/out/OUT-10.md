# A proportional-odds violation biases an expected-utility difference in
both directions, depending on where the utility increments sit
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Target-standardized category probabilities from a
proportional-odds model feed decision models with category utilities.
Catalog problem OUT-10 asks whether a proportional-odds violation
reaches the decision only through the utility increment at the violated
cut-point, and whether relaxing the assumption changes the standardized
decision quantity.

**Methods.** A trial with a four-category outcome and a treatment effect
that was proportional, concentrated at the bottom cut-point, or
concentrated at the top; utilities with their increments at the bottom
or top; proportional-odds regression and separate cut-point logistic
regressions, each standardized over a shifted target; 400 replicates per
cell.

**Results.** Under a violation the proportional-odds estimate of the
expected-utility difference was biased whichever end carried the utility
increments: by -0.025 and -0.047 when the increments sat at the violated
cut-point, and by 0.026 and 0.024 when they sat at the other end, with
coverage 0.67 to 0.85. The separate cut-point models were unbiased with
coverage 0.93 to 0.98 in every cell.

**Conclusion.** The single proportional-odds coefficient is a compromise
that understates the effect at the violated cut-point and overstates it
at the others, so the decision is biased whichever way the utilities
fall. A proportional-odds check must be read against the utilities, and
the relaxed model costs little.

# The problem

The expected-utility difference is
$\sum_k (u_{k+1} - u_k)\,\Delta P(Y > k)$. A proportional-odds fit
([1](#ref-mccullagh1980)) replaces the cut-point-specific treatment
effects by one least-false value. The catalog’s design predicted that
the error reaches the decision in proportion to the utility increment at
the violated cut-point. That requires the other cut-points’ errors to be
small; the least-false averaging makes them not small but opposite in
sign.

# Design

Registered protocol: `protocol.md`.
$\operatorname{logit}P(Y > k) = \alpha_k + 0.8x + a\beta_k$,
$\alpha = (1.2, 0, -1.2)$, $\beta = (0.5, 0.5, 0.5)$, $(1.2, 0.3, 0.2)$
or $(0.2, 0.3, 1.2)$; 300 per arm; target $x \sim N(0.5, 1)$; utilities
$(0, 0.6, 0.8, 1)$ or $(0, 0.2, 0.4, 1)$; G-computation standardization
with 60-resample bootstrap SEs.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the expected-utility difference.

</div>

<div id="tbl-main">

Table 1: 400 replicates per cell; bias MCSE at most 0.002.

| violation | utility increments | truth | proportional odds: bias (coverage) | separate models: bias (coverage) |
|----|----|---:|----|----|
| po | bottom | 0.078 | 0.000 (0.965) | -0.000 (0.955) |
| po | top | 0.095 | 0.000 (0.968) | -0.000 (0.978) |
| bottom | bottom | 0.093 | -0.025 (0.810) | 0.001 (0.950) |
| bottom | top | 0.061 | 0.026 (0.850) | -0.001 (0.953) |
| top | top | 0.171 | -0.047 (0.672) | 0.000 (0.930) |
| top | bottom | 0.080 | 0.024 (0.828) | 0.000 (0.940) |

</div>

The registered primary was not confirmed
(<a href="#tbl-main" class="quarto-xref">Table 1</a>,
<a href="#fig-bias" class="quarto-xref">Figure 1</a>): the bias with the
utility increments at the opposite end was about as large as with them
at the violated cut-point, and of opposite sign, instead of being small.
The one exception in magnitude was the top violation, where the aligned
bias was about twice the misaligned one. Under proportional odds both
models were unbiased and nominal.

# What this does not answer

One individual-data trial rather than an ML-NMR network; separate
logistic regressions as the relaxed model (no partial proportional odds
or monotonicity constraint); fixed utilities; no
dichotomized-publication arm. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-mccullagh1980" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Peter McCullagh. Regression models
for ordinal data. Journal of the Royal Statistical Society Series B.
1980;42(2):109–42.
doi:[10.1111/j.2517-6161.1980.tb01109.x](https://doi.org/10.1111/j.2517-6161.1980.tb01109.x)</span>

</div>

</div>
