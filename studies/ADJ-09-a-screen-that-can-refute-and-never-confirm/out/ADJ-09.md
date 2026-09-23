# A stability screen for a bridging assumption refutes rarely and cannot
confirm
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A bridging assumption carries an effect into a gap where
no trial exists. Checking the stability of effects across the trials
that do exist can refute the bridge but never confirm it. Catalog
problem ADJ-09 asks how such a screen performs and whether screening
marginal effects creates false alarms through non-collapsibility.

**Methods.** Four or ten trials whose covariate laws and baseline risks
differ, and a gap environment beyond them. The conditional log odds
ratio was constant (valid bridge), drifted with an environment feature
visibly across the trials and into the gap, or drifted only in the gap.
Cochran’s $Q$ screen abstaining at $p < 0.10$, on marginal, conditional
or standardized log odds ratios: 20 scenarios and 3 controls, 1000
replicates each.

**Results.** Under a valid bridge with strong prognostic covariates the
marginal screen abstained in 0.190 to 0.237 of analyses against 0.113 to
0.124 on the conditional scale; standardizing first removed the excess.
Drift visible across the trials that biased the gap estimate by about
0.28 was flagged in only 0.201 to 0.238 of analyses, and drift of twice
that size in 0.502 to 0.665. Drift confined to the gap was never flagged
above the null rate. Among analyses that passed, coverage in the gap was
no better than among all analyses.

**Conclusion.** Run stability screens on conditional or standardized
effects. Treat a pass as uninformative about the gap and a failure as a
prompt for sensitivity analysis: with realistic numbers of trials the
screen misses most drift it could in principle see.

# The problem

Invariance across the observed environments is a property of those
environments. A bridge can fail in the gap while every observed trial
agrees, so a stability screen, like invariant-prediction methods
generally ([1](#ref-peters2016)), can only refute. Whether a failed
screen predicts failure in the gap depends on whether the mechanism that
varies across trials is the one the bridge relies on. A second problem
is a design artifact: on the odds ratio scale the marginal effect varies
with the covariate distribution and baseline risk even when the
conditional effect is constant, so a screen on marginal effects fires
wherever trial populations differ.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Trial $k$ at environment feature
$z_k \in [-1, 1]$, 300 per arm, $x \sim N(0.6z_k, s_k^2)$ with
$s_k \in \{0.5, 1, 1.5\}$, baseline
$\operatorname{logit}(0.3) + N(0, 0.3^2)$,
$\operatorname{logit}p = a_k + Gx + A\{-0.6 + \text{drift}(z_k)\}$. Gap
at $z = 2$; estimand the conditional log odds ratio there. Drift: none;
linear in $z$ at 0.15 or 0.3 per unit; or zero on $[-1, 1]$ and rising
only beyond. Screen: Cochran’s $Q$ ([3](#ref-cochran1954)) across trial
estimates. The transported estimate is the pooled conditional log odds
ratio. Controls: identical trials; a linear risk model with constant
risk difference, where the marginal scale is collapsible; large visible
drift.

# Results

<div id="fig-abstain">

![](figures/fig1-abstain.png)

Figure 1: Proportion of analyses abstaining by screen scale and
scenario. The dashed line is the nominal 0.10.

</div>

The non-collapsibility artifact was confirmed
(<a href="#fig-abstain" class="quarto-xref">Figure 1</a>): with
$G = 1.5$ the marginal screen’s false abstention exceeded the
conditional one’s by 0.077 to 0.113, growing with the number of trials.
With $G = 0.5$ the scales agreed. On the collapsible risk-difference
scale the marginal screen stayed at 0.117, and with identical trials
every screen was near nominal. The conditional screen itself ran
slightly above nominal with strong prognosis (up to 0.124).

Sensitivity to visible drift rose with its size and slightly with the
number of trials but stayed low: a pooled estimate biased by about 0.28
in the gap was reported without abstention in about four of five
analyses. Large drift (0.6 per unit, the positive control) was flagged
in 0.995 of analyses. Gap-only drift was indistinguishable from a valid
bridge, as it must be, while biasing the gap estimate by up to 0.60.

Screening did not improve the analyses that were reported: coverage
among passed analyses differed from coverage among all by at most 0.011.

# What this does not answer

One event-rate level, no measurement shift between trials, and Cochran’s
$Q$ rather than a sign-stability rule or a formal invariance test.
Environments were valid by construction; in practice establishing that
trials are exchangeable environments is the hard part. Peer review has
not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-peters2016" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Jonas Peters, Peter Bühlmann,
Nicolai Meinshausen. Causal inference by using invariant prediction:
Identification and confidence intervals. Journal of the Royal
Statistical Society Series B. 2016;78(5):947–1012.
doi:[10.1111/rssb.12167](https://doi.org/10.1111/rssb.12167)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-cochran1954" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">William G. Cochran. The
combination of estimates from different experiments. Biometrics.
1954;10(1):101–29.
doi:[10.2307/3001666](https://doi.org/10.2307/3001666)</span>

</div>

</div>
