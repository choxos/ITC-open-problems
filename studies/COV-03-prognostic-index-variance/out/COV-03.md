# Anchored MAIC on the odds ratio scale must balance the spread of
prognosis, not only effect modifiers
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Guidance for anchored population adjustment says only
effect modifiers need balancing, because purely prognostic covariates
cancel in the relative effect. On the log odds ratio scale that is
false: the marginal odds ratio depends on the spread of prognosis in the
population (Remiro-Azócar 2024, doi:10.1002/sim.10111). Catalog problem
COV-03 asks whether this matters in practice.

**Methods.** Anchored and unanchored binary-outcome comparisons, 500 per
arm, three purely prognostic covariates. We varied the variance of the
prognostic index in the target, its ratio between source and target, the
target mean shift and effect modification: 108 scenarios, 1000
replicates each. MAIC on means, MAIC on means and variances, MAIC on
means and the variance of an estimated prognostic index, and
G-computation.

**Results.** In the 12 primary anchored scenarios without effect
modification, MAIC on means was biased by 0.049 to 0.108 on the log odds
ratio scale, beyond 0.05 in 9; balancing variances cut it to 0.022 or
less in 11 scenarios (0.079 in the one with an effective sample size of
44). The unadjusted bias matched the exact population bias (slope
0.981). The price was effective sample size: when the source’s
prognostic spread was half the target’s, balancing variances left 44 to
284 of 1000 and raised RMSE above that of MAIC on means. G-computation
was unbiased (at most 0.010) with the lowest RMSE in every primary
scenario.

**Conclusion.** On a non-collapsible scale an anchored comparison must
account for differences in the spread of prognosis between trials.
G-computation does so without losing precision; with MAIC, balancing
variances helps when the source’s prognostic spread exceeds the target’s
and costs more than it gains when it is smaller.

# The problem

With prognostic index $u = \gamma^\top x$ and no effect modification,
the marginal log odds ratio in population $F$ is
$\operatorname{logit}\int\operatorname{expit}(\alpha + u + \delta)\,dF - \operatorname{logit}\int\operatorname{expit}(\alpha + u)\,dF$,
which moves toward zero as $\operatorname{Var}_F(u)$ grows and also
depends on the index mean. The A versus C effect in the source differs
from the one in the target even with no modification, and MAIC
([1](#ref-signorovitch2010)) on means leaves the difference in spread
untouched. DESIGN.md claimed the effect depends on $F$ only through
$\operatorname{Var}(u)$; the probe showed a mean shift alone moves it by
0.004 to 0.018.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Source A versus C with $x \sim N(0, rI_3)$;
target B versus C reporting arm events and covariate means and SDs,
$x \sim N(s\mathbf 1, I_3)$.
$\operatorname{logit}P(y = 1) = \operatorname{logit}(0.3) + g\sum_jx_j + \delta_t + \beta x_1\mathbb 1[A]$.
Factors: $\operatorname{Var}_T(u) = 3g^2 \in \{0.25, 1, 4\}$;
$r \in \{0.5, 1, 2\}$; $s \in \{0, 0.3, 0.6\}$; $\beta \in \{0, 0.4\}$;
anchored or unanchored. G-computation fits the logistic model in the
source and marginalizes over normals with the published moments. Primary
scenarios: anchored, no modification, $r \ne 1$,
$\operatorname{Var}_T(u) \ge 1$.

# Results

<div id="fig-primary">

![](figures/fig1-primary.png)

Figure 1: Bias with 95% Monte Carlo intervals and RMSE in the 12 primary
anchored scenarios.

</div>

MAIC on means removed none of the bias that the unadjusted Bucher
comparison carried when prognostic spread differed
(<a href="#fig-primary" class="quarto-xref">Figure 1</a>): both were
biased in the direction the exact calculation predicted, negative when
the source was more dispersed. Balancing variances or the index variance
removed it in all 12 scenarios.

Effective sample size decided whether that removal paid. With the source
less dispersed than the target, variance balancing had to up-weight the
few extreme source patients, and its RMSE exceeded that of MAIC on means
in 6 of 6 scenarios. With the source more dispersed, it cost little:
balancing the index variance lowered RMSE in 6 of 6 scenarios and
balancing every variance in 3, the rest within 0.01. Balancing only the
estimated index variance kept more effective sample size than balancing
every variance (522 against 361 on average) with similar bias.

With effect modification present the same pattern held (largest
MAIC-on-means bias 0.118). Unanchored, every adjustment beat the
unadjusted comparison, whose bias reached 1.533, and G-computation was
again unbiased. Controls held: with identical populations every method
was unbiased, and the positive control was biased as predicted.

# What this does not answer

Independent normal covariates and a correctly specified logistic model,
which favor G-computation; with a misspecified outcome model its
advantage can reverse. Hazard ratios, skewed covariates and augmented
estimators were not run. MAIC intervals treat the weights as fixed. Peer
review has not been done.

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

</div>
