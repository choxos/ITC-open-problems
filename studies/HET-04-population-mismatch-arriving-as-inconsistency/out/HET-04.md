# Node splitting reads a population difference as inconsistency unless
the split is adjusted
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Node splitting compares direct and indirect evidence for
a contrast. If the studies supplying the two paths differ in an effect
modifier, the difference arrives as inconsistency. Catalog problem
HET-04 asks how often the unadjusted split flags a population difference
or misses a real conflict that the difference cancels.

**Methods.** Triangle networks with two or four studies per comparison,
a covariate gap of 0, 0.5 or 1 SD between the direct and indirect study
sets, modification 0, 0.2 or 0.4 and true loop inconsistency of −0.2, 0
or 0.2: 54 scenarios, 2000 replicates each. Unadjusted node split
against a meta-regression-adjusted split with a loop-specific
inconsistency term.

**Results.** With no true inconsistency the unadjusted split flagged
0.141 to 0.982 of analyses where populations differed, and the adjusted
split 0.041 to 0.058. Where the gap cancelled a real inconsistency the
unadjusted split flagged 0.058 to 0.105, its null rate, and the adjusted
split up to 0.254. Adjustment cost precision: its SE for the
inconsistency rose from 0.099 to 0.302 as the gap grew, because the
inconsistency and the interaction are separated only by the covariate
spread within each study set.

**Conclusion.** An unadjusted node split tests a composite of
inconsistency and population mismatch. Adjust the split for the
modifiers whose distribution differs between the paths; its power then
falls with the gap, which should be reported.

# The problem

Under linear modification the node-split statistic ([1](#ref-dias2010))
is
$w = \iota + \beta(\bar x_{\text{direct}} - \bar x_{\text{indirect}})$.
With $\iota = 0$ it is the population mismatch; with
$\iota = -\beta\Delta\bar x$ a real conflict disappears. An adjusted
split estimates the interaction from the study-level covariates and the
inconsistency beyond it.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Study estimates with SE 0.1; AB and AC studies
with covariate means $N(0, 0.2^2)$, BC studies $N(\text{gap}, 0.2^2)$.
C’s effect against A is modified by $\beta x$ with consistent
interactions; BC studies carry $\iota$. Both splits at $p < 0.05$.

# Results

<div id="fig-flags">

![](figures/fig1-flags.png)

Figure 1: Proportion flagged by the unadjusted and adjusted node splits
by covariate gap, for each true inconsistency.

</div>

The unadjusted flag rate followed
$\lvert\iota + \beta\cdot\text{gap}\rvert$
(<a href="#fig-flags" class="quarto-xref">Figure 1</a>): it rose with
the gap when inconsistency was absent or had the same sign, and fell to
the null rate when they cancelled. It was above nominal even with no gap
(0.101), because study-level covariate variation under modification adds
between-study heterogeneity that a fixed-effect split ignores. The
adjusted split held nominal size throughout, and its power against an
inconsistency of 0.2 fell from 0.542 with no gap to 0.123 with a gap of
1.

# What this does not answer

Continuous study estimates, so the marginal and conditional
inconsistency factors coincide and marginalization to a named target was
not needed; one loop; no Bayesian node split. Peer review has not been
done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-dias2010" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Sofia Dias, Nicky J. Welton,
Deborah M. Caldwell, A. E. Ades. Checking consistency in mixed treatment
comparison meta-analysis. Statistics in Medicine. 2010;29(7-8):932–44.
doi:[10.1002/sim.3767](https://doi.org/10.1002/sim.3767)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
