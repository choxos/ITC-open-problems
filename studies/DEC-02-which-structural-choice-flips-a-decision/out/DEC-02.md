# Which analysis choice flips a population-adjusted decision
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A population-adjusted analysis involves choices made at
different stages, and their effects on the recommendation are rarely
compared. Catalog problem DEC-02 asks which choice most often flips a
decision.

**Methods.** Re-scoring of 32,000 stored replicates from DIA-08
(anchored binary-outcome comparisons under linear and nonlinear effect
modification at three overlap levels). Decision: adopt B when its
estimated log odds ratio against A is below a threshold 0.1 or 0.3 from
the truth. For four choices we counted how often the two options gave
different decisions within the same replicate. Changing the target
population, which changes the question, was reported separately.

**Results.** Near the threshold, adjusting or not flipped the decision
in 0.363 of analyses, weighting against an outcome model in 0.202,
linear against quadratic STC in 0.132 and MAIC on means against means
and SDs in 0.073. Far from the threshold the rates were 0.284, 0.143,
0.090 and 0.056. Moving the target covariate mean from 0.3 to 1.2
changed the true log odds ratio by 0.39 to 0.59 across the modification
patterns.

**Conclusion.** The choices are ordered, not dominated by one: whether
to adjust, then which estimator family, then model form and moment set.
The target population moves the true answer more than any estimator
choice moves the estimate, and should be declared as the question rather
than varied as a sensitivity.

# The problem

A reversal between two analyses can mean two different questions (two
target populations) or two answers to one question (two estimators).
Only the second is sensitivity. Within one question the estimator
choices are nested: whether to adjust at all, whether to weight or model
the outcome, and then the specification within a family.

# Design

Registered protocol: `protocol.md`, committed before any scoring;
DIA-08’s estimation results were already known. Replicates carried the
five methods’ estimates for the same data, so a flip is a
within-replicate disagreement. ADEMP structure of the source study
([1](#ref-morris2019)).

# Results

<div id="fig-flips">

![](figures/fig1-flips.png)

Figure 1: Share of analyses in which the two options of each choice give
different decisions, by threshold distance and target covariate mean
(normal covariates).

</div>

The ordering held at every overlap level
(<a href="#fig-flips" class="quarto-xref">Figure 1</a>). Flip rates rose
with the target’s distance from the source, where the options’ estimates
diverge and their variances grow, and fell by more than half when the
threshold was 0.3 rather than 0.1 from the truth. The unadjusted
analysis flipped most because it is biased, not because it is noisy; the
within-family choices flipped through sampling disagreement between
correlated estimates.

# What this does not answer

No prior or bridge factor, since the source replicates contain no
Bayesian or disconnected analysis; the decision is on the relative
effect alone, not a net-benefit model; one outcome type. Peer review has
not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
