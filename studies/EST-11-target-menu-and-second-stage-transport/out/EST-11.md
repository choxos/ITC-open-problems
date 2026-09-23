# Scored against its own target, the unadjusted comparison ranked best;
against a declared target it ranked worst
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** An estimator’s error against a declared decision target
is its error against its own implicit (native) target plus the
difference between the two targets. Simulation studies that score each
method against its native target see only the first part. Catalog
problem EST-11 asks whether that changes which method is recommended.

**Methods.** An anchored binary-outcome comparison with individual data
on A versus C and a published B versus C trial; declared targets at
three covariate means; B sharing A’s effect modification or not. Bucher,
MAIC and STC (native target: the B trial’s population) and a two-stage
STC carried to the declared target. The target mismatch was computed
exactly; 1000 replicates per cell.

**Results.** The best method under the native metric differed from the
best under the declared metric in 5 of 6 cells. The unadjusted Bucher
comparison had the smallest error against the quantity it estimates,
because it has the least variance, and a bias of 0.044 to 0.253 against
the declared targets. When B’s modification differed from A’s, methods
native to the B trial’s population missed a declared target one
covariate SD away by 0.109, and the two-stage transport, which assumed
shared modification, did not remove it.

**Conclusion.** Method comparisons should score every method against one
declared target. Scoring each against its own target rewards the
estimator that answers the wrong question most precisely.

# The problem

$\hat\Delta_E - \Delta(F_D) = \{\hat\Delta_E - \Delta(F_E)\} + \{\Delta(F_E) - \Delta(F_D)\}$.
The second term is fixed by the populations and the modification
structure, does not shrink with sample size, and is zero by construction
when a method is scored against its native target. A second-stage
transport maps $F_E$ to $F_D$; it removes the term if its assumptions
hold and replaces it otherwise. Anchored population adjustment is
typically scored in the aggregate trial’s population
([1](#ref-phillippo2020mlnmr)).

# Design

Registered protocol: `protocol.md`.
$\operatorname{logit}p = -0.5 + 0.5x + a_A(-0.5 + 0.3x) + a_B(-0.7 + g_Bx)$;
individual data on A versus C with $x \sim N(0, 1)$, B versus C
published from $x \sim N(0.6, 1)$; 300 per arm. $g_B = 0.3$ (B shares
A’s modification) or $0.6$. Declared targets $x \sim N(m_D, 1)$ with
$m_D = 0, 0.6, 1.2$. The Bucher comparison’s native target mixes the two
trial populations; MAIC and STC target the B trial’s population; the
two-stage STC calibrates B’s effect to the published log odds ratio
under shared modification and carries both contrasts to $F_D$.

# Results

<div id="tbl-rank">

Table 1: Lowest RMSE per cell under each scoring rule; 1000 replicates.

| declared target mean | B’s modification | best by native RMSE | best by declared RMSE |
|---:|---:|----|----|
| 0.0 | 0.3 | bucher | stc |
| 0.6 | 0.3 | bucher | stc |
| 1.2 | 0.3 | bucher | stc_2stage |
| 0.0 | 0.6 | bucher | stc |
| 0.6 | 0.6 | bucher | stc_2stage |
| 1.2 | 0.6 | bucher | bucher |

</div>

<div id="tbl-main">

Table 2: MCSE of bias about 0.008.

| declared target mean | B’s modification | method | mismatch (exact) | RMSE native | RMSE declared | bias declared |
|---:|---:|----|---:|---:|---:|---:|
| 0.0 | 0.3 | bucher | 0.143 | 0.241 | 0.279 | 0.141 |
| 0.0 | 0.3 | maic | 0.002 | 0.274 | 0.274 | 0.001 |
| 0.0 | 0.3 | stc | 0.002 | 0.261 | 0.261 | 0.006 |
| 0.0 | 0.3 | stc_2stage | 0.000 | 0.265 | 0.265 | 0.003 |
| 0.6 | 0.3 | bucher | 0.141 | 0.242 | 0.275 | 0.130 |
| 0.6 | 0.3 | maic | 0.000 | 0.265 | 0.265 | -0.009 |
| 0.6 | 0.3 | stc | 0.000 | 0.251 | 0.251 | -0.010 |
| 0.6 | 0.3 | stc_2stage | 0.000 | 0.251 | 0.251 | -0.010 |
| 1.2 | 0.3 | maic | -0.001 | 0.266 | 0.266 | -0.001 |
| 1.2 | 0.3 | bucher | 0.140 | 0.242 | 0.282 | 0.145 |
| 1.2 | 0.3 | stc_2stage | 0.000 | 0.252 | 0.252 | 0.001 |
| 1.2 | 0.3 | stc | -0.001 | 0.253 | 0.253 | -0.000 |
| 0.0 | 0.6 | maic | 0.113 | 0.272 | 0.294 | 0.112 |
| 0.0 | 0.6 | bucher | 0.254 | 0.246 | 0.353 | 0.253 |
| 0.0 | 0.6 | stc_2stage | 0.000 | 0.281 | 0.281 | 0.111 |
| 0.0 | 0.6 | stc | 0.113 | 0.255 | 0.278 | 0.111 |
| 0.6 | 0.6 | bucher | 0.141 | 0.241 | 0.284 | 0.150 |
| 0.6 | 0.6 | maic | 0.000 | 0.275 | 0.275 | 0.005 |
| 0.6 | 0.6 | stc | 0.000 | 0.254 | 0.254 | 0.005 |
| 0.6 | 0.6 | stc_2stage | 0.000 | 0.254 | 0.254 | 0.005 |
| 1.2 | 0.6 | bucher | 0.032 | 0.248 | 0.251 | 0.044 |
| 1.2 | 0.6 | maic | -0.109 | 0.272 | 0.288 | -0.096 |
| 1.2 | 0.6 | stc | -0.109 | 0.259 | 0.277 | -0.099 |
| 1.2 | 0.6 | stc_2stage | 0.000 | 0.276 | 0.276 | -0.098 |

</div>

The registered primary was confirmed
(<a href="#tbl-rank" class="quarto-xref">Table 1</a>), and one mechanism
drove it: the unadjusted comparison, scored against the mixture of
populations it actually estimates, had the lowest RMSE in every cell,
and against the declared target it was biased by 0.13 to 0.25 in five of
six cells (<a href="#tbl-main" class="quarto-xref">Table 2</a>). Its one
declared-metric win, at the farthest target with unshared modification,
was a coincidence of its mixed target lying near that target.

Among the adjusted methods, RMSE differences were within 0.03 and
dominated by a sampling SD of about 0.25, so their order under either
metric is not informative at this sample size. The mismatch term itself
was large where the design predicted: with B’s modification unlike A’s,
MAIC and STC were off by 0.11 at declared targets one covariate SD from
the B trial’s population. The two-stage transport removed the mismatch
when modification was shared and not when it was not, where its bias
matched MAIC’s; with modification shared, every adjusted method’s target
was already close to every declared target because the B-versus-A
contrast had no conditional modification.

# What this does not answer

Three declared targets, one covariate, one sample size, exact target
moments, four methods; no ML-NMR or ML-UMR arm. Rankings among the
adjusted methods would need larger trials or more replicates to resolve.
Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-phillippo2020mlnmr" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Mark Belger, Alan Brnabic, Alexander Schacht, Daniel Saure,
Zbigniew Kadziola, Nicky J. Welton. Multilevel network meta-regression
for population-adjusted treatment comparisons. Journal of the Royal
Statistical Society Series A. 2020;183(3):1189–210.
doi:[10.1111/rssa.12579](https://doi.org/10.1111/rssa.12579)</span>

</div>

</div>
