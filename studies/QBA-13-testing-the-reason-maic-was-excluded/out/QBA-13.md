# A simulated-covariate bias analysis works by MAIC as well as by STC
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A simulated-covariate bias analysis for unanchored
comparisons imputes an unmeasured covariate from assumed relations and
adjusts for it. Its authors restricted it to STC, arguing that a MAIC
version would lose too much effective sample size or fail to find
weights. Catalog problem QBA-13 tests that reason.

**Methods.** Unanchored transport with an unmeasured binary covariate
(prevalence 0.3 in the source), independent of or dependent on a
measured covariate, and an outcome association known to the analyst. The
analysis swept the assumed target prevalence from 0.1 to 0.9, imputing
the covariate ten times from its posterior given the measured covariate
and outcome, and adjusted by STC or by MAIC balancing its mean (2
scenarios, 500 replicates each).

**Results.** MAIC weights were feasible in 0.998 to 1.000 of replicates
at every sweep point. Effective sample size fell from about 231 to 85 of
300 at the extreme, and MAIC’s reported SE was 1.03 to 1.14 times STC’s.
Both routes were unbiased (at most 0.009). Their reported SEs widened
toward the extremes (to 0.282) while the estimates’ spread stayed near
0.134, so coverage rose to 1.000.

**Conclusion.** The restriction to STC was a conservative choice, not a
necessity: the MAIC extension is feasible and nearly as precise. Both
routes, combined over imputations, report intervals that widen along the
sweep faster than the estimate’s real uncertainty, so a curve should
show its effective sample size and not be read as more robust where it
is merely wider.

# The problem

Adding a simulated covariate adds a balancing constraint to MAIC
([1](#ref-signorovitch2010)): feasibility can only shrink and effective
sample size only fall as its assumed target mean moves from the
source’s. Both are computable. For a binary covariate the constraint is
feasible whenever both categories occur in the source, and the loss
depends on how far the assumed prevalence is from the source’s, which is
the sensitivity parameter itself.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). 300 patients of A; target mean of the measured
covariate 0.5; outcome log odds ratio of the unmeasured covariate 0.8;
dependence on the measured covariate 0 or 0.8 on the log odds scale.
Estimand at each sweep point: A’s marginal log odds in a target with
that prevalence. Imputations combined by Rubin’s rules
([3](#ref-rubin1987)).

# Results

<div id="fig-se">

![](figures/fig1-se.png)

Figure 1: Reported SE of the STC and MAIC routes and the MAIC estimate’s
empirical SD along the sweep.

</div>

<a href="#fig-se" class="quarto-xref">Figure 1</a> shows the two routes’
reported SEs tracking each other and both departing from the empirical
spread toward the extremes. The between-imputation variance grows as the
assumed prevalence moves away from the source’s, but the imputations are
drawn from a model the analyst holds fixed, so that variance is not
uncertainty about the target estimate under the stated assumption.

# What this does not answer

One binary unmeasured covariate with a logistic dependence (no copula
factor); the analyst’s assumed relations are correct; unanchored A side
only; no decision-threshold reading of the curve. Peer review has not
been done.

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

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-rubin1987" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Donald B. Rubin. Multiple
imputation for nonresponse in surveys. New York: Wiley; 1987.</span>

</div>

</div>
