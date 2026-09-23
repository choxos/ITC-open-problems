# A transported control-arm check carries no information about the
anchored contrast
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** When an anchored population-adjusted comparison shares a
control arm, the control-arm outcome transported from the
individual-data trial can be compared with the one the target trial
observed. Agreement is read as support for the analysis. Catalog problem
IDN-10 asks what the check’s operating characteristics are.

**Methods.** Anchored MAIC with a binary outcome. Between the two trial
populations we shifted, independently, an unmeasured prognostic
covariate $u$ and an unmeasured modifier $v$ of the individual-data
treatment’s effect, over 18 scenarios with 1000 replicates each, and
recorded the check’s $z$-statistic and the anchored contrast’s error.

**Results.** A shift in $u$ raised the check’s alarm rate to 0.478 while
the contrast stayed essentially unbiased (-0.028); a shift in $v$ biased
the contrast by 0.297 on the log odds ratio scale and cut coverage to
0.778 while the alarm rate stayed at 0.044. Pooled over all replicates,
$\lvert z\rvert$ separated biased from unbiased analyses with an AUROC
of 0.502, and at every threshold its detection rate equaled its
false-alarm rate.

**Conclusion.** The check tests prognostic transport; the anchored
contrast depends on effect-modification transport. In an anchored
comparison it is a test of the wrong assumption and should not be
reported as support for the relative effect.

# The problem

The control arm transports when the prognostic structure does; the
relative effect transports when the effect-modification structure does.
In an anchored comparison a purely prognostic imbalance cancels between
arms, so the relative effect is protected from exactly the failure the
check detects, and unprotected from the one it cannot see: a modifier of
the treatment effect that does not move control-arm outcomes. The check
has been used in hidden-truth benchmarks of external controls
([1](#ref-gupta2025)); its operating characteristics as a screen for
relative-effect bias had not been measured.

# Design

Registered protocol: `protocol.md`. Individual data on A versus C (300
per arm) in the source; arm counts on B versus C in the target (200 or
500 per arm). Binary outcome with
$\operatorname{logit} p = \operatorname{logit}(0.3) + 0.5x + 0.6u + \text{treatment}$,
A’s effect $-0.6 + 0.3x + 0.6v$, B’s $-0.4 + 0.3x$. MAIC balances the
measured $x$ (target mean 0.5); $u$ and $v$ are unmeasured, with target
means $\mu_u, \mu_v \in \{0, 0.3, 0.6\}$. Estimand: the anchored
B-versus-A marginal log odds ratio in the target. The check is
$z = (\operatorname{logit}\hat p_C^{\text{transported}} - \operatorname{logit}\hat p_C^{\text{observed}})/\text{SE}$.

# Results

<div id="fig-check">

![](figures/fig1-check.png)

Figure 1: Each scenario’s check alarm rate against its contrast bias.
The dashed line is the nominal 5% rate.

</div>

Alarm rate moved with $u$ and bias moved with $v$
(<a href="#fig-check" class="quarto-xref">Figure 1</a>). The design’s
four cases held in every scenario:

|  | control arm transports | contrast unbiased | alarm rate, target 500 per arm |
|----|:--:|:--:|---:|
| no shift | yes | yes | 0.040 |
| prognostic shift only | no | yes | 0.478 |
| modifier shift only | yes | no | 0.044 |
| both | no | no | 0.489 |

Across thresholds on $\lvert z\rvert$ the check flagged unbiased and
biased analyses at the same rate: 0.206 against 0.207 at 1.96, 0.524
against 0.530 at 1. The AUROC of 0.502 is chance. A prognostic shift
slightly reduced the contrast bias when combined with a modifier shift
(for example 0.282 to 0.243 at 200 per arm), through the
non-collapsibility of the odds ratio, but did not change the conclusion.

# What this does not answer

Binary outcome only; the survival-curve and RMST versions are not run.
In an unanchored comparison the relative effect does depend on
prognostic transport, and there the check targets a relevant assumption;
that case, and offsetting prognostic mechanisms, are not simulated.
Outcome-definition and follow-up differences, which also move control
arms, are absent. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-gupta2025" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Ashwini Gupta, others.
Quantitative bias analysis for single-arm trials with external control
arms. JAMA Network Open. 2025.
doi:[10.1001/jamanetworkopen.2025.2152](https://doi.org/10.1001/jamanetworkopen.2025.2152)</span>

</div>

</div>
