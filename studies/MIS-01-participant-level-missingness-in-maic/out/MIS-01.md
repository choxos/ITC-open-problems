# Missing covariates in the individual-data trial of a MAIC: the
mechanism decides, and the repairs can make it worse
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** When a matched covariate is missing for some patients in
the individual-data trial, complete-case MAIC matches the target on the
records it keeps, so the balance table looks perfect whatever deletion
did. Catalog problem MIS-01 asks when this is biased and whether
weighting or imputation repairs it.

**Methods.** Continuous-outcome anchored MAIC with a partly missing
matched covariate $x_1$, an observed matched covariate $x_2$ and an
unmatched covariate $u$ correlated with $x_1$. Missingness of 15%, 30%
or 50% driven by nothing, $x_2$, $u$, the outcome, $u$ in one arm only,
or $x_1$ itself; $u$ prognostic only or also modifying: 36 scenarios,
1000 replicates each. Complete case, observation weighting
([1](#ref-fang2026)) and multiple imputation with and without arm
interactions.

**Results.** Complete-case bias followed the mechanism, not the rate:
unbiased in all 24 scenarios predicted unbiased, including missingness
driven by $x_1$ itself, and biased already at 15% where predicted (for
example -0.338 with arm-specific missingness). When missingness depended
on $x_1$ itself, weighting and imputation, which assume the data missing
at random, were biased by up to 0.221 while complete case stayed within
0.035. When 95% of one arm was missing, weighting and arm-interacted
imputation failed (bias -0.978 and -0.193). Otherwise imputation with
arm interactions was the most reliable repair under missing at random.

**Conclusion.** Report the missingness mechanism, not the rate. Complete
case is the right analysis when missingness depends only on the matched
covariates, including the missing one; imputation with arm interactions
when it depends on unmatched variables or the outcome.

# The problem

MAIC ([2](#ref-signorovitch2010)) gives both arms of the individual-data
trial the same weights, so a shift in an unmatched covariate $u$ that
deletion causes in both arms cancels in the contrast unless $u$ modifies
the effect. A shift confined to one arm does not cancel, even for a
purely prognostic $u$. Deletion driven by the matched covariates
themselves, including the missing one, leaves the conditional law of
everything else given the matched covariates unchanged, so MAIC on the
complete cases still targets the right population. Weighting and
imputation assume the data missing at random given observed variables,
which fails exactly when missingness depends on $x_1$ itself.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([3](#ref-morris2019)). 250 per arm; $u = 0.5x_1 + \text{noise}$;
$y = 0.5(x_1 + x_2 + u) + A(-0.4 + 0.3x_1 + \beta_uu) + e$,
$\beta_u \in \{0, 0.3\}$; target means of $x_1, x_2$ 0.5. Missingness
logistic in the driver with an intercept set to the rate; for the
arm-specific mechanism all missingness falls in arm A at twice the rate
(95% at most). Observation weighting models the probability of a
complete record on $x_2$, $u$ and $y$ interacted with arm; imputation
uses five draws, normal regression, and Rubin’s rules
([4](#ref-rubin1987)).

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias by missingness mechanism, method and rate. Arm-specific
missingness produced complete-case bias below the plotted range.

</div>

<a href="#fig-bias" class="quarto-xref">Figure 1</a> shows the pattern.
Missingness driven by $u$ or $y$ biased complete case only when $u$
modified the effect (-0.105 and -0.131 at 30%). Missingness in one arm
driven by $u$ biased it whether or not $u$ modified (-0.652 at 30% with
$u$ prognostic only).

Under missing at random, imputation with arm interactions was within 3
MCSE of zero in 24 of 24 scenarios; imputation without arm terms had
small systematic bias (up to 0.041), since it ignores the modification
of $x_1$’s relation to $y$ by arm. Observation weighting was unbiased
except under arm-specific missingness, where 60% to 95% of arm A was
missing and weights became extreme (bias -0.146 at 30% and -0.780 at
50%).

When missingness depended on $x_1$ itself, the repairs were biased by
0.079 (weighting) and 0.095 (imputation) at 30%, against -0.006 for
complete case.

# What this does not answer

Missing outcomes, binary outcomes, STC, overlap levels and a
pattern-mixture sensitivity analysis for missingness not at random were
not run. The mechanisms are single-driver; mixtures make the choice
between complete case and imputation depend on their relative weight,
which the data cannot reveal. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-fang2026" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Fang, Li, Lai, He. Missing data
handling in the application of matching-adjusted indirect comparison.
Therapeutic Innovation & Regulatory Science. 2026;60(4):1103–11.
doi:[10.1007/s43441-026-00914-2](https://doi.org/10.1007/s43441-026-00914-2)</span>

</div>

<div id="ref-signorovitch2010" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">James E. Signorovitch, Eric Q. Wu,
Andrew P. Yu, Charles M. Gerrits, Evan Kantor, Yanjun Bao, Shiraz R.
Gupta, Parvez M. Mulani. Comparative effectiveness without head-to-head
trials: A method for matching-adjusted indirect comparisons applied to
psoriasis treatment with adalimumab or etanercept. PharmacoEconomics.
2010;28(10):935–45.
doi:[10.2165/11538370-000000000-00000](https://doi.org/10.2165/11538370-000000000-00000)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-rubin1987" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">Donald B. Rubin. Multiple
imputation for nonresponse in surveys. New York: Wiley; 1987.</span>

</div>

</div>
