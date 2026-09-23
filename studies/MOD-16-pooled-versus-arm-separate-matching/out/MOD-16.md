# Arm-separate matching cancels the aggregate trial’s chance imbalance;
pooled matching carries it
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** An anchored MAIC can weight the individual-data trial
with one weight function (pooled) or weight each arm to the
corresponding aggregate arm (arm-separate) ([1](#ref-petto2019)).
Catalog problem MOD-16’s design predicted that arm-separate matching is
biased by the product of an unmatched covariate’s prognostic strength
and the aggregate trial’s arm imbalance.

**Methods.** Continuous outcome, one matched covariate $X$ reported by
arm and one unreported prognostic covariate $U$, 96 scenarios crossing
an imposed aggregate-arm imbalance in $X$ (0 to 0.2 SD, or chance),
$U$’s prognostic strength, the $X$-$U$ correlation in each trial, and
shared effect modification; 1000 replicates each. Unadjusted, pooled,
arm-separate and two-stage ([2](#ref-remiroazocar2022)) MAIC.

**Results.** Conditional on an imbalance $\kappa$, pooled matching was
biased by $\kappa(\beta/2 + \gamma_X + \gamma_U\rho_T)$ (slope of
simulated on predicted bias 1.004) and arm-separate matching by
$\kappa\gamma_U(\rho_T - \rho_S)$ (slope 0.958). With the $X$-$U$
correlation shared between trials, arm-separate bias was within Monte
Carlo error of zero in all 16 scenarios with an unmatched prognostic
covariate. Arm-separate matching had smaller bias than pooled in every
scenario with an imposed imbalance, and under chance imbalance its RMSE
was 10% to 27% lower.

**Conclusion.** The design’s product claim is wrong. Arm-separate
matching reproduces the aggregate trial’s chance imbalance inside the
individual-data contrast, so it cancels in the anchored difference; it
is biased only when an unmatched prognostic covariate relates to the
matched one differently in the two trials. Pooled matching preserves the
individual trial’s randomization but leaves the aggregate trial’s
imbalance in the answer.

# The problem

Write the outcome as
$y = \gamma_X x + \gamma_U u + \delta_t + \beta x\,\mathbb 1[t \ne C] + e$.
The aggregate B-versus-C estimate contains the trial’s chance imbalance,
$\gamma_X\kappa + \gamma_U(\bar u_B - \bar u_C)$, with
$E[\bar u_B - \bar u_C] = \rho_T\kappa$. Pooled matching weights both
individual-data arms to the pooled aggregate mean, which removes nothing
of this, so the anchored contrast is biased by
$\kappa(\beta/2 + \gamma_X + \gamma_U\rho_T)$. Arm-separate matching
weights arm A to the B-arm mean and arm C to the C-arm mean, which
builds the same imbalance into the individual-data contrast,
$\gamma_X\kappa + \gamma_U\rho_S\kappa$, and it cancels except for
$\kappa\gamma_U(\rho_T - \rho_S)$. DESIGN.md’s product of $\gamma_U$ and
$\kappa$ omits the correlation mismatch the bias needs.

# Design

Registered protocol: `protocol.md`. Individual-data trial A versus C and
aggregate trial B versus C, 300 per arm; $(X, U)$ bivariate normal with
correlation $\rho_S$ in the source and $\rho_T$ in the target (means
0.5); the aggregate B arm’s $X$ mean set to $0.5 + \kappa$ exactly, with
$U$ drawn given $X$. $\gamma_X = 0.5$, $\gamma_U \in \{0, 0.25, 0.5\}$,
$(\rho_S, \rho_T) \in \{(0,0), (0.5,0.5), (0.5,0), (0,0.5)\}$,
$\beta \in \{0, 0.3\}$ shared by A and B, $\kappa \in \{0, 0.1, 0.2\}$
or chance. Estimand: $\delta_B - \delta_A = 0.2$. Sandwich variances
with weights fixed.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Simulated against predicted bias for pooled and arm-separate
matching, imposed-imbalance scenarios.

</div>

Both formulas held
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>). At
$\kappa = 0.2$, $\gamma_U = 0.5$ and $\beta = 0.3$, pooled bias was
0.128 to 0.188 and arm-separate bias -0.050 to 0.051, the extremes being
the two mismatched-correlation structures. Two-stage MAIC behaved like
pooled matching: it corrects the individual trial’s chance imbalance,
not the aggregate trial’s.

Under chance imbalance every method except the unadjusted one was
unbiased, and the difference was precision: arm-separate RMSE over
pooled 0.728 to 0.904. Its sandwich interval overcovered (0.965 to
0.991) because it adds the two trials’ variances while their imbalances
are positively correlated. The design’s candidate diagnostic, the
weighted difference in $U$ between individual-data arms, estimates
$\rho_S\kappa$ and cannot see $\rho_T$; its correlation with
arm-separate bias was -0.414, with the sign set by which trial has the
stronger correlation.

# What this does not answer

Continuous outcome and linear model; one matched and one unmatched
covariate; shared effect modification. On a non-collapsible scale
arm-separate matching compares arms in different populations and its
estimand needs separate treatment. The arm-separate interval’s
conservatism is not repaired here. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-petto2019" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Helmut Petto, Zbigniew Kadziola,
Alan Brnabic, Daniel Saure, Mark Belger. Alternative weighting
approaches for anchored matching-adjusted indirect comparisons via a
common comparator. Value in Health. 2019;22(1):85–91.
doi:[10.1016/j.jval.2018.06.018](https://doi.org/10.1016/j.jval.2018.06.018)</span>

</div>

<div id="ref-remiroazocar2022" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Antonio Remiro-Azócar. Two-stage
matching-adjusted indirect comparison. BMC Medical Research Methodology.
2022;22:217.
doi:[10.1186/s12874-022-01692-9](https://doi.org/10.1186/s12874-022-01692-9)</span>

</div>

</div>
