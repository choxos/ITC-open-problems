# Flexible outcome models reduced but did not remove transport bias
where the target left the data, and could not see a modification they
were not built to see
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Flexible outcome models are proposed to remove the
misspecification bias of parametric simulated treatment comparison
(STC). Catalog problem MOD-02 asks whether they do so under adversarial
response surfaces, and at what cost to interval validity.

**Methods.** A binary-outcome trial with one adversarial feature at a
time (a threshold prognostic effect, a hinge in the treatment effect, or
a covariate-by-covariate modification); targets 0.5, 1 and 1.5 SD from
the source; parametric STC, a generalized additive model with smooth
treatment modification, and one with linear modification, each
standardized by G-computation; 500 replicates per cell.

**Results.** Under the hinge modification at the farthest target, STC
was biased by -0.144 and the smooth-modification GAM by -0.085 (coverage
0.930): a reduction of about 40%, short of the registered halving, with
the same RMSE because its variance was larger. Under the
covariate-by-covariate modification every method was biased by about
-0.175, because additive smooths cannot represent a product. The
threshold prognostic term cancelled in all methods.

**Conclusion.** Flexibility helped only against misspecification in the
shape it could represent and only partly where the target lay beyond the
data. Transport bias from surfaces outside the model’s span is unchanged
by flexibility within it.

# The problem

Transport integrates the fitted outcome model over the target. Where the
target’s covariates fall beyond the source’s, the fitted surface there
is an extrapolation, and a flexible model’s extrapolation is set by its
smoothing penalty ([1](#ref-wood2011)) rather than by data. The
catalog’s refuting sentence says flexibility trades transparent for
opaque misspecification.

# Design

Registered protocol: `protocol.md`. Source $x_1, x_2 \sim N(0, 1)$, 300
per arm;
$\operatorname{logit}p = -0.6 + 0.5x_1 + 0.3x_2 + \text{PROG} + a(-0.6 + 0.3x_1 + \text{MOD})$
with PROG $= 0.8\,\mathbb 1(x_1 > 1)$ (A), MOD $= 0.8\max(x_1 - 0.5, 0)$
(B) or $0.4x_1x_2$ (C). Target $x_1 \sim N(\mu, 1)$,
$x_2 \sim N(\mu/2, 1)$. The smooth-modification GAM has baseline smooths
and centered treatment-difference smooths in each covariate (mgcv,
REML); the structured GAM has smooth prognostic terms and linear
modification. Delta-method SEs; the GAM formula was corrected before any
result was read (`protocol.md`, section 4).

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the target log odds ratio by surface and target
distance.

</div>

<div id="tbl-main">

Table 1: 500 replicates per cell; bias MCSE at most 0.015.

| surface | target mean | STC: bias (coverage) | GAM, smooth modification | GAM, linear modification |
|----|---:|----|----|----|
| none | 0.5 | -0.006 (0.960) | -0.007 (0.958) | -0.005 (0.960) |
| A | 0.5 | 0.005 (0.954) | 0.005 (0.950) | 0.002 (0.950) |
| B | 0.5 | -0.018 (0.950) | -0.009 (0.944) | -0.022 (0.948) |
| C | 0.5 | -0.027 (0.950) | -0.029 (0.952) | -0.027 (0.956) |
| none | 1.0 | -0.000 (0.950) | -0.002 (0.940) | -0.000 (0.952) |
| A | 1.0 | 0.011 (0.950) | 0.007 (0.944) | -0.001 (0.946) |
| B | 1.0 | -0.045 (0.950) | -0.017 (0.942) | -0.055 (0.946) |
| C | 1.0 | -0.081 (0.932) | -0.086 (0.922) | -0.080 (0.926) |
| none | 1.5 | -0.004 (0.940) | -0.012 (0.944) | -0.003 (0.946) |
| A | 1.5 | 0.040 (0.962) | 0.026 (0.942) | 0.008 (0.956) |
| B | 1.5 | -0.144 (0.930) | -0.085 (0.930) | -0.164 (0.904) |
| C | 1.5 | -0.175 (0.904) | -0.183 (0.914) | -0.172 (0.910) |

</div>

The registered primary found the refuting sentence to hold
(<a href="#tbl-main" class="quarto-xref">Table 1</a>,
<a href="#fig-bias" class="quarto-xref">Figure 1</a>). Bias grew with
target distance for every method on surfaces B and C. The
smooth-modification GAM tracked the hinge better than STC at every
distance but still lost most of its advantage to variance at the
farthest target (RMSE 0.314 against 0.318). The structured GAM, which
imposes linear modification, was no better than STC on B. Coverage
stayed near 0.90 to 0.93 in the biased cells because the intervals were
wide (empirical SD about 0.3).

# What this does not answer

No BART, random forest, doubly robust or ML-NMR arm; logit link, one
sample size; model-based intervals only. MOD-10’s question, whether
flexibility helps at low and hurts at high unsupported mass, is read off
these cells in its note. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-wood2011" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Simon N. Wood. Fast stable
restricted maximum likelihood and marginal likelihood estimation of
semiparametric generalized linear models. Journal of the Royal
Statistical Society Series B. 2011;73(1):3–36.
doi:[10.1111/j.1467-9868.2010.00749.x](https://doi.org/10.1111/j.1467-9868.2010.00749.x)</span>

</div>

</div>
