# Protocol: the same total sample size in different topologies and IPD placements

**Target problem.** DIA-07. Exact numerical calculation (no sampling). Committed before the computation.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Whether a decision contrast is identified in the population-adjusted sense depends on where the
individual data sit in the network, not on total information. **Refuting sentence:** estimator performance
depends on topology only through total information, so results from a two-trial template transfer once
total information is matched.

## 2. Design

Treatments A, B, C, D; effect of $k$ against A at covariate $x$: $d_k + g_kx$ with $d = (0, -0.1, -0.2, -0.15)$ and
$g = (0, G, 3G, 2G)$, $G \in \{0.05, 0.1, 0.2\}$. Decision contrast D versus A in a target with covariate mean
$M_T \in \{0.5, 1\}$; every trial population has covariate mean 0 and SD 1. Four topologies: line A-B-C-D,
star from A, a loop A-B-C with tail C-D, and two paths A-B-D and A-C-D. 1200 patients split equally over the
trials; outcome SD 1. One trial has individual data (each edge in turn, or none) and is standardized to the
target by regression, unbiased with variance inflated by $1 + M_T^2$; the others report their own
population's effect. Fixed-effect network meta-analysis by generalized least squares. Bias, SD, 95%
coverage and decision error (probability the estimate's sign differs from the truth's) are exact.

## 3. Decision

**Refuting sentence fails** if, for some $(G, M_T)$, decision error differs by more than 0.10 across topology
and placement at the same total size; otherwise it holds. Reported for every configuration: bias, SD,
coverage, decision error and the individual-data trial's share of the absolute hat-matrix row.

## 4. Departures from DESIGN.md

Exact calculation for a continuous outcome with linear modification and a fixed-effect model; four
hand-built topologies rather than a generated family; one individual-data trial; no ML-NMR, no
component networks, no articulation-treatment enumeration, no estimability map beyond the bias.
