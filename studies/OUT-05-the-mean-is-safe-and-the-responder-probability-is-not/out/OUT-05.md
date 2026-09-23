# Transporting a continuous outcome: the mean is safe under a pooled
residual, the responder probability is not
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Continuous outcomes are transported by G-computation
from normal linear models, often with one residual SD. The target mean
does not involve the residual, but a responder probability does. Catalog
problem OUT-05 asks how large the difference is and whether floor
effects on bounded scales make it depend on the target population.

**Methods.** Source trial of 300 per arm, residual SD equal in both arms
or twice as large under treatment, normal or skewed errors, a floor
holding 0%, 10% or 25% of the control arm, and a target shifted by 0.3
or 1 SD: 24 scenarios, 1000 replicates each. Estimands: the target mean
difference and the difference in the probability of exceeding the target
control arm’s median or 90th percentile. Methods: normal model with
pooled or arm-specific SD, Tobit with arm-specific scales, and logistic
regression of the responder indicator.

**Results.** Without a floor the pooled-SD model’s mean contrast was
unbiased (at most 0.031) while its responder contrasts were biased by up
to 0.102 when the SDs differed, with opposite signs at the two
thresholds (for example 0.022 and -0.102). Arm-specific SDs removed that
bias for normal errors but not with a floor (up to 0.058) or skew. Tobit
handled the floor (at most 0.003) but not skew. Logistic regression of
the responder indicator was unbiased in every scenario (at most 0.006).
The floor biased the linear model’s mean contrast by at most 0.070, more
at the larger target shift, but under 2% of the effect.

**Conclusion.** Report responder probabilities from a model of the
responder indicator, or at least with arm-specific dispersion and a
model for the floor; a pooled normal residual biases them in a direction
set by the threshold, even where the mean is right.

# The problem

With an identity link and a correct mean model, the target mean contrast
$\int\{\mu_1(x) - \mu_0(x)\}dF_T$ contains no residual term. A responder
probability $\Phi\{(\mu(x) - c)/\sigma\}$ contains $\sigma$: a pooled
value too small for the treated arm overstates response when the
conditional mean is above the threshold and understates it below, so the
error does not average out. A floor adds a point mass that a normal
model spreads below the boundary; censored regression
([1](#ref-tobin1958)) models it, and how much it matters depends on how
close the target sits to the floor.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Latent $Y^* = 20 + 5x + A(4 + 2x) + \sigma_Ae$
with $\sigma_C = 6$, $\sigma_A = 6r$, $r \in \{1, 2\}$; $e$ normal or
standardized Gamma(4); $Y = \max(Y^*, \text{floor})$. Truths from
$4\times10^5$ Monte Carlo draws.

# Results

<div id="fig-resp">

![](figures/fig1-responder.png)

Figure 1: Bias of the responder-probability difference by method, floor
mass and error distribution, SD ratio 2.

</div>

The dissociation registered as the primary outcome held
(<a href="#fig-resp" class="quarto-xref">Figure 1</a>): the same fitted
mean model gave an unbiased mean contrast and biased responder
contrasts. The direction reversed between the median and the tail
threshold, so averaging over thresholds would hide it. Each parametric
repair fixed the feature it models and missed the others; the direct
binary model needed no distributional assumption for the outcome and
paid in variance (RMSE 0.031 against 0.023 for the correct normal model
at the tail).

# What this does not answer

One source trial with arm-specific dispersion rather than several
studies with study-specific dispersion; no ceiling; bias and RMSE only,
without intervals; no ML-NMR. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-tobin1958" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">James Tobin. Estimation of
relationships for limited dependent variables. Econometrica.
1958;26(1):24–36.
doi:[10.2307/1907382](https://doi.org/10.2307/1907382)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
