# Bias mechanisms in an unanchored MAIC do not add
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Quantitative bias analyses for unanchored comparisons
usually vary one bias mechanism at a time. Catalog problem DIA-13 asks
whether mechanisms acting together produce the sum of their separate
biases, and whether a one-at-a-time analysis bounds the joint bias.

**Methods.** Exact population-level calculation for an unanchored MAIC
with a binary outcome, under an omitted confounder (outcome log odds
ratio $-1$ to 1, prevalence 0.3 against 0.5), misclassification of the
comparator’s reported outcome (sensitivity down to 0.8) and measurement
error in the matched covariate (reliability down to 0.6): 45
combinations.

**Results.** Where the confounder and misclassification acted together,
the interaction was up to 0.163 on the log odds ratio scale; where
either was absent it was at most 0.005. The median interaction was 29%
of the sum of the separate biases. With both at their largest the joint
bias was 0.156 against a sum of 0.314; with the confounder reversed, the
joint bias was 0.101 against a sum of -0.051, the opposite sign. The
joint bias exceeded the largest single-mechanism bias in 22 of 36
combinations.

**Conclusion.** One-at-a-time bias analyses neither add up to nor bound
the joint bias. Mechanisms that change the outcome rate on which another
mechanism acts interact strongly; these should be analyzed jointly,
while mechanisms acting on different parts of the estimator can be
combined additively.

# The problem

An unanchored MAIC ([1](#ref-signorovitch2010)) compares A’s outcome,
reweighted to the target, with B’s published outcome. An omitted
confounder shifts A’s transported rate; comparator misclassification
distorts B’s reported rate by an amount that depends on the true rate;
measurement error in a matched covariate under-corrects A’s rate. On the
log odds scale each mechanism’s bias depends on the rates the others
have moved, so the joint bias is not the sum. Standard bias-analysis
practice treats mechanisms separately or combines them by simulation
([2](#ref-lash2021)) without reporting the interaction.

# Design

Registered protocol: `protocol.md`.
$\operatorname{logit}P(Y = 1) = -1 + 0.5x + g_uU + \text{treatment}$
with B’s effect $-0.4$; source $x \sim N(0, 1)$,
$U \sim \text{Bern}(0.3)$; target $x \sim N(0.5, 1)$,
$U \sim \text{Bern}(0.5)$. Misclassification: reported proportion
$(1 - m)p + (m/2)(1 - p)$. Measurement error: MAIC on the error-prone
covariate moves the latent mean by the reliability times 0.5. Exact
80-point Gauss-Hermite quadrature. Interaction: joint bias minus the
three single-mechanism biases.

# Results

<div id="fig-joint">

![](figures/fig1-joint.png)

Figure 1: Joint bias against the sum of the single-mechanism biases for
combinations of two or three mechanisms. The dashed line is additivity.

</div>

Combinations involving measurement error with only one other mechanism
lay on the additivity line
(<a href="#fig-joint" class="quarto-xref">Figure 1</a>); every
combination of the confounder with misclassification lay off it.
Misclassification pulls a reported proportion toward the middle by an
amount that depends on the proportion itself, and the confounder changes
which proportion B’s arm has, so the two mechanisms compose rather than
add. Both additivity and bounding failed; the median relative
interaction is inflated where the separate biases cancel, so absolute
interactions are the better summary.

# What this does not answer

Population-level only: no estimation, no bias-analysis procedure, no
false reassurance or tipping sets (DIA-14 scores those). Three
mechanisms; selection, correlated sensitivity parameters and overlap
were not varied. Peer review has not been done.

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

<div id="ref-lash2021" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Matthew P. Fox, Richard F.
MacLehose, Timothy L. Lash. Applying quantitative bias analysis to
epidemiologic data. 2nd ed. Cham: Springer; 2021.
doi:[10.1007/978-3-030-82673-4](https://doi.org/10.1007/978-3-030-82673-4)</span>

</div>

</div>
