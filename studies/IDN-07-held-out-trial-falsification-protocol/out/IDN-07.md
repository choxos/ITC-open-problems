# A held-out-trial check can hold its size, but a pass licenses very
little
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Withholding one trial, predicting its contrast from the
rest of the evidence and comparing the prediction with what the trial
observed is proposed as a falsification check for transport assumptions.
Catalog problem IDN-07 asks for a pass or fail rule with known operating
characteristics.

**Methods.** One individual-data trial and five aggregate trials with a
continuous outcome and linear effect modification. The withheld trial’s
contrast was predicted by G-computation at its reported covariate mean.
Violations of 0, 0.15 or 0.3 (the effect itself is about 0.3),
between-trial heterogeneity 0 or 0.1, two covariate spreads and a
central or peripheral withheld trial: 24 scenarios, 2000 replicates
each. Rules: a standardized discrepancy with all variance components;
the same without heterogeneity; the prediction aimed at the population
implied by the remaining trials; and a sign-disagreement rule.

**Results.** With the prediction aimed at the withheld trial’s own
population the discrepancy had mean zero under the null (at most 0.009),
and the full rule held a size of 0.035 to 0.073; the registered limit of
0.07 was exceeded by 0.003 in one scenario. Omitting heterogeneity
raised size to 0.104. Aiming the prediction at the remaining trials’
population gave a nonzero null mean (up to 0.603) and size up to 0.962
for a peripheral trial. Power was low everywhere: 0.073 to 0.170 at
violation 0.15 and 0.211 to 0.474 at 0.3. The sign-disagreement rule
flagged 0.021 to 0.440 of valid analyses depending on how close the
effect was to zero.

**Conclusion.** A held-out-trial check needs an externally fixed target
(the withheld trial’s own population) and a variance that includes
heterogeneity; with both, its size is controlled. Its power against
violations as large as the effect is below one half, so a pass licenses
very little and should not be reported as validation.

# The problem

The discrepancy $D = \hat\Delta_{\text{pred}} - \hat\Delta_{\text{obs}}$
has mean zero under a valid transport assumption only if both sides
refer to the same population. Its variance must include the prediction’s
sampling error, the observed contrast’s sampling error and between-trial
heterogeneity; the covariance between the two sides is not zero when the
prediction uses the withheld trial’s own covariate summaries. A rule
that omits a variance component rejects valid analyses; one that aims at
the wrong population tests a composite null.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([1](#ref-morris2019)). Individual data: 300 per arm, $x \sim N(0, 1)$.
Aggregate trials: 200 per arm, $x \sim N(\mu_k, 1)$ with
$\mu_k = s\cdot(-0.4, 0, 0.4, 0.8, 1.2)$, $s \in \{1, 2\}$; the third
(central) or fifth (peripheral) is withheld.
$y = 0.5x + A(-0.3 + 0.3x + u_k + v\,\mathbb 1[\text{withheld}]) + e$,
$u_k \sim N(0, \tau^2)$. Heterogeneity is estimated by DerSimonian-Laird
([2](#ref-dersimonian1986)) from the other four trials’ residuals
against their predictions. Rules flag at $\lvert z\rvert > 1.96$.

# Results

<div id="fig-power">

![](figures/fig1-power.png)

Figure 1: Proportion of analyses flagged by violation size, for each
rule and configuration. The dashed line is 0.05.

</div>

The external target removed the estimand mismatch entirely, and the full
variance kept size near nominal; it was conservative for the peripheral
trial at wide spread (0.039), where the prediction’s variance dominated
and its covariance with the observed contrast was positive
(<a href="#fig-power" class="quarto-xref">Figure 1</a>). The one
scenario above 0.07 had heterogeneity estimated from only four trials,
which DerSimonian-Laird underestimates.

Power rose little with any factor. The detectable violation is set by
the sampling error of a single trial’s contrast and of the prediction at
its covariate mean, and a network supplies one withheld trial at a time.
The sign rule is not calibratable: its flag rate is a property of the
effect’s distance from zero, not of the violation.

# What this does not answer

Continuous outcome and G-computation, so MAIC weight-estimation variance
and non-collapsibility are absent; a Bayesian predictive rule and a
conditional-moment test were not run; five aggregate trials only. Peer
review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-dersimonian1986" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Rebecca DerSimonian, Nan Laird.
Meta-analysis in clinical trials. Controlled Clinical Trials.
1986;7(3):177–88.
doi:[10.1016/0197-2456(86)90046-2](https://doi.org/10.1016/0197-2456(86)90046-2)</span>

</div>

</div>
