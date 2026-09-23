# Change scores and endpoints do not diverge under population adjustment
Ahmad Sofi-Mahmudi
2026-09-22

# Abstract

**Background.** Catalog problem OUT-06 proposes that when baseline
severity modifies the treatment effect, change-score and endpoint
analyses imply different effect-modification structures and diverge
after population adjustment, in proportion to the product of the
baseline-by-treatment interaction and the baseline shift between
populations.

**Methods.** Because baseline is measured before treatment, the target
contrasts of follow-up and of change are the same quantity under any
adjustment. We tested the implication in 24 scenarios (anchored and
unanchored comparisons, baseline shift 0 to 1 SD, interaction 0 or 0.3,
baseline-to-follow-up correlation 0.4 or 0.8), 1000 replicates each, for
naive comparison, MAIC matching the baseline mean, and G-computation,
each in both representations.

**Results.** For MAIC and G-computation the mean endpoint-minus-change
difference never exceeded 0.0068 and was within 3 Monte Carlo SE of zero
in every scenario; in unanchored comparisons the two representations
were identical to 4e-13 in every replicate. The only divergence was in
naive unanchored comparisons, where the difference was 1.0013 (SE
0.0018) times the shift and 0.0069 (SE 0.0066) times the
interaction-by-shift product.

**Conclusion.** The proposed product structure does not exist. Change
and endpoint analyses diverge only when baseline is left unadjusted
across populations, and then by the baseline shift alone, independent of
effect modification. Where baseline is adjusted for, the choice of
representation affects precision and not the target estimate.

# The problem

Combining trials that report change from baseline with trials that
report follow-up values is generally valid in conventional meta-analysis
([1](#ref-dacosta2013)), because the change contrast equals the
follow-up contrast minus the baseline contrast and randomization makes
the latter zero in expectation. OUT-06 asks whether population
adjustment breaks this: DESIGN.md argued that with baseline as an effect
modifier the two representations “agree at the source and diverge at the
target”.

They cannot diverge at the level of the estimand. Baseline $Y_0$ is
pre-treatment, so $Y_0(1) = Y_0(0)$ and, for any target law $F_T$,

$$E_T[Y_1(b) - Y_1(a)] = E_T[(Y_1 - Y_0)(b) - (Y_1 - Y_0)(a)].$$

Estimators can still differ. A linear model for $Y_1 - Y_0$ with $Y_0$
as a covariate has the same treatment and treatment-by-$Y_0$
coefficients as the model for $Y_1$; only the $Y_0$ coefficient shifts
by one. MAIC that matches the baseline mean makes the weighted baseline
equal the target’s exactly. Without adjustment for baseline, an
unanchored comparison of follow-up is biased by $(b + \beta)s$ and of
change by $(b + \beta - 1)s$, for baseline slope $b$, interaction
$\beta$ and shift $s$: they differ by $s$ whatever $\beta$ is. In an
anchored comparison each trial’s randomization removes the baseline
contrast in expectation.

# Design

Registered protocol: `protocol.md`. Individual-data trial A versus C
with $Y_0 \sim N(0, 1)$; aggregate trial B versus C with
$Y_0 \sim N(s, 1)$ reporting arm means of $Y_0$, $Y_1$ and $Y_1 - Y_0$.
$Y_1 = bY_0 + \delta_t + \beta Y_0\mathbb 1[t = A] + e$,
$e \sim N(0, 1 - b^2)$, $\delta_A = -0.4$, $\delta_B = -0.2$, 300 per
arm. Factors: anchored or unanchored; $s \in \{0, 0.5, 1\}$;
$\beta \in \{0, 0.3\}$; $b \in \{0.4, 0.8\}$. Estimand
$E_T[Y_1(B) - Y_1(A)] = \delta_B - \delta_A - \beta s$. Methods: naive,
MAIC on the baseline mean, and G-computation with a linear model in
$Y_0$, each in both representations. 1000 replicates per scenario.

# Results

<div id="fig-diff">

![](figures/fig1-difference.png)

Figure 1: Mean difference between the endpoint and change estimates. The
dotted line has slope 1.

</div>

Adjusted estimators did not diverge
(<a href="#fig-diff" class="quarto-xref">Figure 1</a>). The anchored
MAIC and G-computation differences are the aggregate trial’s chance
baseline imbalance, mean zero; in unanchored comparisons the
individual-data side is algebraically identical and the difference is at
machine precision. Naive anchored comparisons also agree in expectation
(largest mean difference 0.0050) though both are biased when
$\beta \neq 0$, because neither adjusts for the modifier.

<div id="tbl-bias">

Table 1: Bias (Monte Carlo SE) at shift 1, b = 0.4.

<div class="cell-output-display">

| design | beta | naive_end | naive_chg | maic_end | maic_chg | gcomp_end | gcomp_chg |
|:---|---:|:---|:---|:---|:---|:---|:---|
| anchored | 0.0 | 0.0032 (0.0036) | 0.0013 (0.0040) | 0.0003 (0.0050) | -0.0029 (0.0059) | -0.0015 (0.0043) | -0.0008 (0.0044) |
| unanchored | 0.0 | 0.4042 (0.0026) | -0.5973 (0.0028) | 0.0063 (0.0032) | 0.0063 (0.0032) | 0.0052 (0.0029) | 0.0052 (0.0029) |
| anchored | 0.3 | 0.2951 (0.0038) | 0.2993 (0.0038) | -0.0018 (0.0057) | 0.0026 (0.0055) | -0.0015 (0.0042) | -0.0006 (0.0042) |
| unanchored | 0.3 | 0.6991 (0.0028) | -0.3041 (0.0027) | -0.0032 (0.0033) | -0.0032 (0.0033) | -0.0019 (0.0030) | -0.0019 (0.0030) |

</div>

</div>

In naive unanchored comparisons the endpoint and change estimates are
biased in opposite directions when $b < 0.5$
(<a href="#tbl-bias" class="quarto-xref">Table 1</a>), matching
$(b + \beta)s$ and $(b + \beta - 1)s$. Both registered controls passed:
every method was unbiased at $s = 0$, and the naive unanchored biases
matched their predictions at $s = 1$.

# What this does not answer

A continuous outcome with a linear conditional mean. Under a nonlinear
link (for example a log-transformed outcome analyzed on the original
scale) the equivalence of coefficients fails, although the estimand
identity does not. Responder probabilities defined by a threshold on
change and on follow-up are different estimands by definition and are
not compared. The joint repeated-measures model is represented only by
G-computation with baseline as a covariate. Peer review has not been
done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-dacosta2013" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Bruno R. da Costa, Eveline Nüesch,
Anne W. S. Rutjes, Bradley C. Johnston, Stephan Reichenbach, Sven
Trelle, Gordon H. Guyatt, Peter Jüni. Combining follow-up and change
data is valid in meta-analyses of continuous outcomes: A
meta-epidemiological study. Journal of Clinical Epidemiology.
2013;66(8):847–55.
doi:[10.1016/j.jclinepi.2013.03.009](https://doi.org/10.1016/j.jclinepi.2013.03.009)</span>

</div>

</div>
