# When the trials that share individual data are selected on their own
effect modification
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Individual participant data carry the within-trial
evidence on effect modification, and which trials supply them is not
random. Catalog problem CMP-22 asks what selection on data availability
does and whether a leave-IPD-out diagnostic reveals it.

**Methods.** Twelve trials with trial-specific treatment-by-covariate
interactions. Individual data were available for a quarter, half or
three quarters of trials, selected on an observed trial variable, on
each trial’s latent interaction, or both (18 scenarios, 1000 replicates
each). Interaction and target effect were estimated from the IPD trials’
within-trial interactions alone, or combined with the across-trial
association in all trials.

**Results.** Selection on the observed trial variable left the
within-trial estimate unbiased (-0.003 to 0.003). Selection on the
latent interaction biased it by up to 0.142 (true interaction 0.3), most
when few trials supplied data, and coverage fell to 0.589. Combining
with aggregate trials halved the bias (at most 0.065). Leave-IPD-out
influence did not respond: at half the trials supplying data it
correlated -0.85 with the bias across selection strengths.

**Conclusion.** Availability that depends on a trial’s own effect
modification biases the evidence that population adjustment relies on,
and influence diagnostics cannot see it; only a stated selection model
can address it. Report which trials were missing and use aggregate
evidence alongside.

# The problem

Combined IPD and aggregate meta-analysis ([1](#ref-riley2008)) separates
a within-trial interaction, identified by the IPD trials, from an
across-trial association. If trials with stronger modification are more
likely to share data, the within-trial evidence is a selected sample.
Selection on observed trial variables can be modeled; selection on the
latent interaction cannot be estimated from the network, because the
trials that would reveal it are the ones without data.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Trials of 200 per arm, covariate means uniform
on $[-1, 1]$; $y = x + A(-0.5 + \beta_kx) + e$, $\beta_k = 0.3 + u_k$,
$u_k \sim N(0, 0.15^2)$. IPD available with probability
$\operatorname{logit}^{-1}(a + s_{\text{obs}}z_k + s_{\text{lat}}u_k/0.15)$
with $z_k$ an observed trial variable correlated with the covariate
mean. Within-trial interactions pooled by DerSimonian-Laird; the
combined estimator averages that with the across-trial slope by inverse
variance. Influence: the largest change in the combined target estimate
when one IPD trial is treated as aggregate.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the interaction estimate by strength of selection on
the latent interaction, for each IPD share.

</div>

The bias grew with selection strength and fell as more trials supplied
data, since the selected set then approaches the whole
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>). The across-trial
slope is not selected, so combining diluted the bias in proportion to
its weight. The influence diagnostic changed with the IPD share, because
each trial matters less when more supply data, but not with selection.

# What this does not answer

Pairwise meta-analysis with a continuous outcome rather than component
ML-NMR; no selection-model sensitivity analysis; one network size. Peer
review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-riley2008" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Richard D. Riley, Paul C. Lambert,
Jan A. Staessen, Jiguang Wang, Francois Gueyffier, Lutgarde Thijs,
Florent Boutitie. Meta-analysis of continuous outcomes combining
individual patient data and aggregate data. Statistics in Medicine.
2008;27(11):1870–93.
doi:[10.1002/sim.3165](https://doi.org/10.1002/sim.3165)</span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

</div>
