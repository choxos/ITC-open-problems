# A negative-control outcome calibrates transport bias only when it
shares the primary outcome’s bias exactly
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Negative-control outcomes detect and calibrate
confounding within one data source. Catalog problem IDN-09 asks whether
they transfer to transport bias in indirect comparisons, where the bias
comes from population differences between studies.

**Methods.** Unanchored MAIC with an unmeasured covariate $V$ shifted by
0.5 SD between populations or not; a negative-control outcome with no
treatment effect whose dependence on $V$ was none, half, equal to or
twice the primary outcome’s; and $V$ either modifying A’s effect or not:
16 scenarios, 2000 replicates each. A control test and a calibrated
contrast (primary minus control) were compared with naive MAIC.

**Results.** The control test held its size without a shift (0.039 to
0.056) and flagged the shift in 0.043 to 0.834 of analyses depending on
the control’s dependence on $V$. Calibration removed the bias only when
the control’s dependence equaled the primary’s and $V$ did not modify
the effect (bias 0.001 against 0.229 naive). With modification it left
0.170; with a control twice as dependent it overcorrected to -0.183, and
with modification it happened to cancel (-0.003).

**Conclusion.** For transport a negative control must share the primary
outcome’s bias exactly, including any modification of the treatment
effect, which an outcome with no treatment effect cannot do. Use a
control signal to detect population differences, not to correct for
them.

# The problem

A negative control ([1](#ref-lipsitch2010)) shares the confounding
pathway of the primary outcome within one population. Across studies the
bias is a transport gap: an unmeasured covariate distributed differently
between populations. It biases an unanchored MAIC
([2](#ref-signorovitch2010)) through its prognostic effect on the
outcome and through any modification of the treatment effect. A control
outcome with no treatment effect can share only the first, and only if
its prognostic dependence matches.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([3](#ref-morris2019)). Individual data on 500 patients of A; the target
publishes B’s (500) proportions for the primary outcome $Y$ and the
control $N$ and the mean of a measured covariate. $Y$:
$\operatorname{logit} = -1 + 0.5x + 0.5V$, with B’s effect $-0.4$ and
A’s effect $\beta V$; $N$: $\operatorname{logit} = -1 + 0.5x + g_NV$.
MAIC balances $x$. The calibrated contrast subtracts the control
contrast and adds its variance.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Bias of the naive and calibrated contrasts with a population
shift, by the control’s dependence on the unmeasured covariate. The
dotted line marks a control matching the primary.

</div>

Calibration moved the estimate by the control’s bias whatever the
primary’s was (<a href="#fig-bias" class="quarto-xref">Figure 1</a>).
The naive bias came from two sources, prognosis and modification; the
control could carry only the first, in proportion to its own dependence
on $V$. The control test’s power rose with that dependence, so the
controls that are easiest to detect with are the ones most likely to
overcorrect.

# What this does not answer

One control outcome rather than a bank with empirical calibration;
unanchored comparisons only; how often suitable control outcomes are
reported in appraisal submissions was not surveyed. Peer review has not
been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-lipsitch2010" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Marc Lipsitch, Eric Tchetgen
Tchetgen, Ted Cohen. Negative controls: A tool for detecting confounding
and bias in observational studies. Epidemiology. 2010;21(3):383–8.
doi:[10.1097/EDE.0b013e3181d61eeb](https://doi.org/10.1097/EDE.0b013e3181d61eeb)</span>

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

</div>
