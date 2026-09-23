# A misclassified modifier needs correcting in the weights as well as
the outcome model
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A binary effect modifier recorded with error enters
population adjustment through the balancing step and through the outcome
model. Catalog problem QBA-06 asks whether correcting the outcome model
alone is enough.

**Methods.** Anchored transport of an A-versus-C contrast with a
misclassified binary modifier (prevalence 0.3 in the source and 0.5 in
the target), four assay scenarios (identical good, identical poor, worse
in the source, worse in the target) and two modification strengths: 8
scenarios, 1000 replicates each. MAIC on the recorded covariate, with
prevalence correction, and with latent-prevalence weights; STC on the
recorded covariate, with only its outcome model corrected, and fully
corrected. Assay sensitivity and specificity were known.

**Results.** MAIC on the recorded covariate was biased even when both
studies used the same assay (-0.130 to -0.032), and correcting the
target prevalence alone did not help (up to -0.130). Correcting only
STC’s outcome model left -0.051 to -0.012. Full correction of STC and
MAIC with latent-prevalence weights were unbiased (at most 0.006 and
0.006).

**Conclusion.** Balancing a misclassified covariate does not balance the
true one, whatever the assays, because reweighting recorded categories
leaves each category’s true composition at the source’s. Both paths need
correcting: the outcome model and the population it is averaged over, or
for MAIC, weights chosen on the latent prevalence.

# The problem

With recorded $X^\star$, MAIC ([1](#ref-signorovitch2010)) reweights the
$X^\star = 1$ and $X^\star = 0$ categories to match the target’s
reported prevalence. The weighted source’s true prevalence is then
$\sum_{x^\star}s(x^\star)P_S(X = 1 \mid x^\star)$, which depends on the
source’s prevalence through Bayes’ rule and does not equal the target’s.
DESIGN.md said identical assays make balance on $X^\star$ imply balance
on $X$; they do not. An outcome model on $X^\star$ is attenuated
([2](#ref-carroll2006)), and correcting it still averages over the wrong
population if the target’s reported prevalence is used as the true one.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([3](#ref-morris2019)). Source trial 400 per arm;
$\operatorname{logit}P(Y = 1) = -1 + 0.5X + A(-0.5 + bX)$,
$b \in \{0.5, 1\}$; the target reports the prevalence of $X^\star$ from
800 patients. Latent-prevalence MAIC chooses the weight share $s$ of
$X^\star = 1$ with
$s\,P_S(X = 1 \mid X^\star = 1) + (1 - s)P_S(X = 1 \mid X^\star = 0)$
equal to the target’s corrected prevalence. The corrected STC is a
latent-class logistic likelihood with the known source assay.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias by method and assay scenario with 95% Monte Carlo
intervals.

</div>

The naive MAIC and STC behaved identically
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>): with one binary
covariate both average the same category-specific effects. Their bias
grew with modification strength and with a poorer source assay. Each
partial correction fixed one path and left the other.

# What this does not answer

Known assay parameters, so validation-substudy and prior uncertainty
were not propagated; a single binary covariate; no interval assessment.
Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-signorovitch2010" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">James E. Signorovitch, Eric Q. Wu,
Andrew P. Yu, Charles M. Gerrits, Evan Kantor, Yanjun Bao, Shiraz R.
Gupta, Parvez M. Mulani. Comparative effectiveness without head-to-head
trials: A method for matching-adjusted indirect comparisons applied to
psoriasis treatment with adalimumab or etanercept. PharmacoEconomics.
2010;28(10):935–45.
doi:[10.2165/11538370-000000000-00000](https://doi.org/10.2165/11538370-000000000-00000)</span>

</div>

<div id="ref-carroll2006" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Raymond J. Carroll, David Ruppert,
Leonard A. Stefanski, Ciprian M. Crainiceanu. Measurement error in
nonlinear models: A modern perspective. 2nd ed. Boca Raton: Chapman;
Hall/CRC; 2006.
doi:[10.1201/9781420010138](https://doi.org/10.1201/9781420010138)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
