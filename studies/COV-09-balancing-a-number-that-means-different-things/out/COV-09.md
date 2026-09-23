# Matching a covariate measured by different instruments: a reliability
correction is not enough
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** MAIC balances a covariate by name. When the source trial
and the target publication measured it with different instruments, the
matched means agree on paper while the underlying populations do not.
Catalog problem COV-09 asks how MAIC is biased and whether a reliability
correction repairs it.

**Methods.** Latent effect modifier recorded in the source and reported
by the target through linear instruments with offsets, slopes and
measurement error. Five instrument pairs, source reliability 1, 0.8 or
0.6, modification 0, 0.3 or 0.6: 45 scenarios, 1000 replicates each.
Naive MAIC, MAIC with a reliability correction, and an envelope of
corrected intervals over declared instrument differences.

**Results.** Naive bias followed its closed form (slope 0.992). With a
shared instrument the reliability correction removed the bias (at most
0.011). With differing instruments it left bias up to 0.176 and could
increase it: at reliability 0.6 a target offset and the attenuation
cancelled in the naive analysis (bias -0.018), and the correction undid
the cancellation (0.172). The envelope over declared instrument
differences covered 0.967 or more at 1.4 to 2.9 times the naive width.

**Conclusion.** A balance table cannot show instrument differences, and
no source-side correction identifies them. Where instruments may differ,
report a bounded analysis over declared differences.

# The problem

The source records $X_S = a_S + b_SX + e_S$ and the target reports the
mean of $X_T = a_T + b_TX + e_T$. MAIC ([1](#ref-signorovitch2010))
tilts the source on $X_S$ to the reported mean. For a normal source the
latent mean moves by $\kappa = b_S/(b_S^2 + \operatorname{Var}e_S)$
times the shift in $X_S$, so with effect modification $\beta$ the
transported effect is biased by
$\beta\{\mu_T - \kappa(a_T + b_T\mu_T - a_S)\}$. With one shared
instrument the bias is attenuation by the source reliability, and
dividing by a known reliability repairs it. With different instruments
the bias has either sign, and nothing in the source data identifies
$a_T$ or $b_T$.

# Design

Registered protocol: `protocol.md`; ADEMP structure
([2](#ref-morris2019)). Latent $X \sim N(0, 1)$ in the source (200 per
arm) and $N(0.5, 1)$ in the target; $y = 0.5X + A(-0.4 + \beta X) + e$.
Instrument pairs $(a_S, b_S, a_T, b_T)$: same $(0,1,0,1)$; same, shifted
$(0.3, 0.8, 0.3, 0.8)$; target offset $(0,1,0.3,1)$; target slope
$(0,1,0,0.8)$; target offset and slope $(0,1,-0.3,1.2)$. The corrected
analysis disattenuates the target point assuming one instrument and a
known reliability. The bounded analysis takes the envelope of corrected
intervals over target offsets in $[-0.3, 0.3]$ and slopes in
$[0.8, 1.2]$ relative to the source instrument, a range that contains
every simulated pair.

# Results

<div id="fig-bias">

![](figures/fig1-bias.png)

Figure 1: Simulated bias against the closed form, for naive and
reliability-corrected MAIC, modification 0.3 and 0.6.

</div>

Naive bias matched the closed form in all 45 scenarios
(<a href="#fig-bias" class="quarto-xref">Figure 1</a>), and with no
modification it was zero whatever the instruments. The reliability
correction moved shared-instrument scenarios onto zero and left
differing-instrument scenarios where the instrument difference put them.
Coverage of the corrected interval fell to 0.847 for differing
instruments.

The bounded analysis contains the truth whenever the declared range
contains the true instrument difference, which it did here by
construction; its cost was width. It does not protect against
differences outside the declared range.

# What this does not answer

Identity link and linear instruments; cut-point misclassification of
binary covariates and correction from a bridging sample measured on both
instruments were not run. The target’s reported mean was its population
value, so target sampling error is absent. Peer review has not been
done.

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
