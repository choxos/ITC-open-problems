# The half-standard-error pooling rule for interactions is stated in the
wrong standard error
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** An individual-data network meta-analysis has
within-trial and across-trial information about a treatment-covariate
interaction. The only published criterion for pooling them is that the
within-trial estimate lie within half a standard error of the
across-trial estimate ([1](#ref-freeman2018)), described as relatively
strict and never calibrated.

**Methods.** Under equality the difference of the two estimates has
standard error $\sqrt{s_W^2 + s_A^2}$, not $s_A$, so the rule’s
operating characteristics are bivariate-normal integrals. We computed
them exactly for 24 network configurations (5, 10 or 20 trials of 200;
trial covariate means spread with SD 0.25 or 0.75; ecological bias 0 to
0.4), and checked the standard errors and two exact quantities against
2000 individual-level networks.

**Results.** The rule pools with probability at most
$P(\lvert Z\rvert < 0.5) = 0.383$ under equality; in the configurations
studied 0.314 to 0.374. When it does pool under ecological bias, the
pooled interval’s coverage falls to 0.221. Its RMSE is within 0.3% of
never pooling in every configuration, so it forgoes the 2% to 19% RMSE
reduction pooling offers when the two estimates agree.

**Conclusion.** The rule is strict in every regime, not only some, and
it is strict in the wrong way: it refuses pooling most of the time when
pooling is valid, and when it admits pooling under bias the interval is
not trustworthy. A test on the difference in its own standard error is
the minimal repair; no rule of this kind can detect bias small relative
to the across-trial standard error.

# The problem

Across-trial interaction information is identified only if there is no
trial-level confounding of the association between trial covariate means
and trial effects ([2](#ref-berlin2002),[3](#ref-hua2017)). Pooling it
with the within-trial estimate gains precision at the risk of ecological
bias $\delta$. Write $\hat\beta_W \sim N(\beta, s_W^2)$ and
$\hat\beta_A \sim N(\beta + \delta, s_A^2)$, independent. The rule pools
when $\lvert D\rvert < \tfrac12 s_A$ with
$D = \hat\beta_W - \hat\beta_A \sim N(-\delta, s_W^2 + s_A^2)$. Under
$\delta = 0$,

$$P(\text{pool}) = P\!\left(\lvert Z\rvert < \frac{0.5\,s_A}{\sqrt{s_W^2 + s_A^2}}\right) \le 0.383,$$

approached when $s_A \gg s_W$. The catalog’s design argued the rule is
“not necessarily strict” and loosest with few trials. It is strict
everywhere; the ratio $s_W/s_A$ only decides how strict.

# Methods

Registered protocol: `protocol.md`. Standard errors came from a network
of $K$ trials of 200 (1:1), within-trial covariate SD 1, residual SD 1:
$s_W^2 = 4/(200K)$ and $s_A^2 = (4/200)/\sum_k(\bar x_k - \bar x)^2$.
Conditional on $D$, the within-trial error is normal with mean
$s_W^2(D + \delta)/(s_W^2 + s_A^2)$, so the error of whatever a policy
reports, and its interval’s coverage, integrate exactly over $D$.
Policies: never pool; always pool; the half-$s_A$ rule; tests on $D$ at
size 5% and 20%. The individual-level check (`R/01-check.R`, 2000
networks per row) reproduced the standard errors and the exact pass
probability and conditional coverage, for example a pass rate of 0.366
against 0.374 exact.

# Results

<div id="fig-rule">

![](figures/fig1-rule.png)

Figure 1: Probability of pooling and coverage of the pooled interval
given pooling, by ecological bias.

</div>

<div id="tbl-half">

Table 1: The half-SE rule by configuration and ecological bias.

<div class="cell-output-display">

|   K | dispersion | delta | sW/sA | P(pool) | coverage given pooled | RMSE  |
|----:|-----------:|------:|:------|:--------|:----------------------|:------|
|   5 |       0.25 |   0.0 | 0.224 | 0.374   | 0.950                 | 0.063 |
|  10 |       0.25 |   0.0 | 0.237 | 0.373   | 0.950                 | 0.045 |
|  20 |       0.25 |   0.0 | 0.244 | 0.373   | 0.950                 | 0.032 |
|   5 |       0.75 |   0.0 | 0.671 | 0.322   | 0.950                 | 0.063 |
|  10 |       0.75 |   0.0 | 0.712 | 0.316   | 0.950                 | 0.045 |
|  20 |       0.75 |   0.0 | 0.731 | 0.314   | 0.950                 | 0.032 |
|   5 |       0.25 |   0.1 | 0.224 | 0.354   | 0.949                 | 0.063 |
|  10 |       0.25 |   0.1 | 0.237 | 0.330   | 0.948                 | 0.045 |
|  20 |       0.25 |   0.1 | 0.244 | 0.288   | 0.946                 | 0.032 |
|   5 |       0.75 |   0.1 | 0.671 | 0.223   | 0.909                 | 0.063 |
|  10 |       0.75 |   0.1 | 0.712 | 0.143   | 0.848                 | 0.045 |
|  20 |       0.75 |   0.1 | 0.731 | 0.060   | 0.724                 | 0.032 |
|   5 |       0.25 |   0.2 | 0.224 | 0.301   | 0.947                 | 0.063 |
|  10 |       0.25 |   0.2 | 0.237 | 0.228   | 0.943                 | 0.045 |
|  20 |       0.25 |   0.2 | 0.244 | 0.132   | 0.935                 | 0.032 |
|   5 |       0.75 |   0.2 | 0.671 | 0.074   | 0.781                 | 0.063 |
|  10 |       0.75 |   0.2 | 0.712 | 0.013   | 0.546                 | 0.045 |
|  20 |       0.75 |   0.2 | 0.731 | 0.000   | 0.221                 | 0.032 |
|   5 |       0.25 |   0.4 | 0.224 | 0.155   | 0.939                 | 0.063 |
|  10 |       0.25 |   0.4 | 0.237 | 0.052   | 0.922                 | 0.045 |
|  20 |       0.25 |   0.4 | 0.244 | 0.006   | 0.887                 | 0.032 |
|   5 |       0.75 |   0.4 | 0.671 | 0.001   | 0.343                 | 0.063 |
|  10 |       0.75 |   0.4 | 0.712 | 0.000   | 0.042                 | 0.045 |
|  20 |       0.75 |   0.4 | 0.731 | 0.000   | 0.000                 | 0.032 |

</div>

</div>

The rule pools in about a third of analyses where pooling is valid
(<a href="#tbl-half" class="quarto-xref">Table 1</a>). As ecological
bias grows, pooling becomes rarer but not rare enough: at 20 trials with
dispersed trial means and $\delta = 0.2$ it pools in 0.000 of analyses,
and the pooled interval then covers in 0.221
(<a href="#fig-rule" class="quarto-xref">Figure 1</a>). Averaged over
pooling and not pooling, the rule behaves like never pooling: its RMSE
matches never pooling to within 0.3%. The size-5% test pools more often
under equality and fails similarly under bias; always pooling has the
lowest RMSE without bias and the worst with it. Never pooling had the
lowest worst-case RMSE over $\delta \in [0, 0.2]$ in five of six network
configurations.

# What this does not answer

The two estimates are treated as independent and normal with known
standard errors; between-trial heterogeneity in the treatment effect,
which widens $s_A$, is not modeled, and the network is IPD in every
trial. The ML-NMR case, where aggregate trials inform only the
across-trial component, is not computed. Nothing here tests whether
trial-level confounding is present; no agreement rule can. Peer review
has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-freeman2018" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Suzanne C. Freeman, David Fisher,
Jayne F. Tierney, James R. Carpenter. A framework for identifying
treatment-covariate interactions in individual participant data network
meta-analysis. Research Synthesis Methods. 2018;9(3):393–406.
doi:[10.1002/jrsm.1300](https://doi.org/10.1002/jrsm.1300)</span>

</div>

<div id="ref-berlin2002" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Jesse A. Berlin, Jill Santanna,
Christopher H. Schmid, Lynda A. Szczech, Harold I. Feldman. Individual
patient- versus group-level data meta-regressions for the investigation
of treatment effect modifiers: Ecological bias rears its ugly head.
Statistics in Medicine. 2002;21(3):371–87.
doi:[10.1002/sim.1023](https://doi.org/10.1002/sim.1023)</span>

</div>

<div id="ref-hua2017" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Hairui Hua, Danielle L. Burke,
Michael J. Crowther, Joie Ensor, Catrin Tudur Smith, Richard D. Riley.
One-stage individual participant data meta-analysis models: Estimation
of treatment-covariate interactions must avoid ecological bias by
separating out within-trial and across-trial information. Statistics in
Medicine. 2017;36(5):772–89.
doi:[10.1002/sim.7171](https://doi.org/10.1002/sim.7171)</span>

</div>

</div>
