# Sharing one heterogeneity parameter across a bridged network cost
little; the interval method mattered more
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** A bridged network contrast pools two subnetworks, and a
single between-study SD $\tau$ lends one subnetwork’s heterogeneity to
the other. Catalog problem CMP-16 asks whether that breaks the bridged
contrast’s interval and whether a stratified $\tau$ does better at
realistic study counts.

**Methods.** A bridged contrast formed as the sum of two subnetworks’
pooled effects; heterogeneity ratio 1, 2 or 5 in the bridging or the
other subnetwork; 3, 6 or 12 studies each; shared, stratified and shrunk
REML heterogeneity with Wald intervals, and Hartung-Knapp intervals;
2000 replicates per cell.

**Results.** With the non-bridging subnetwork five times as
heterogeneous, the shared model’s Wald interval covered 0.906, 0.911 and
0.932 at 3, 6 and 12 studies per subnetwork, against 0.917, 0.927 and
0.943 for the stratified model: at most 0.016 apart. Every Wald interval
undercovered at few studies, and Hartung-Knapp intervals covered 0.974
to 0.997 at three studies, at 1.5 times the width.

**Conclusion.** For a contrast that sums both subnetworks, a shared
$\tau$ overstates one part’s variance and understates the other’s, and
the errors largely offset. The undercoverage comes from ignoring
uncertainty in $\tau$, not from sharing it.

# The problem

A shared $\tau$ inflates the homogeneous subnetwork’s variance and
deflates the heterogeneous one’s. For a contrast that uses only one
subnetwork this misstates its interval directly; for a bridged contrast
that sums both, the two errors enter with opposite signs. Stratifying
$\tau$ fixes the structure but estimates two poorly determined variances
instead of one.

# Design

Registered protocol: `protocol.md`. $K$ studies of component A against
its backbone (effect $-0.3$) and $K$ of B against A (0.1); the target is
their sum. Within-study SE uniform on 0.1 to 0.25; between-study SDs
0.05 in one subnetwork and $0.05R$ in the other. Shared, stratified and
shrunk (weight $K/(K+4)$ toward the shared value) REML heterogeneity;
Wald intervals, and Hartung-Knapp intervals ([1](#ref-hartung2001)) for
shared and stratified.

# Results

<div id="fig-coverage">

![](figures/fig1-coverage.png)

Figure 1: Coverage of the bridged contrast at a 5:1 heterogeneity ratio.

</div>

<div id="tbl-main">

Table 1: Coverage of 95% intervals, 2000 replicates per cell (MCSE at
most 0.007).

| ratio | heterogeneous | studies each | shared | stratified | shrunk | shared, Hartung-Knapp | stratified, Hartung-Knapp |
|---:|----|---:|---:|---:|---:|---:|---:|
| 1 | bridging | 3 | 0.955 | 0.960 | 0.958 | 0.997 | 0.997 |
| 2 | bridging | 3 | 0.944 | 0.951 | 0.948 | 0.991 | 0.992 |
| 5 | bridging | 3 | 0.897 | 0.906 | 0.903 | 0.978 | 0.979 |
| 2 | other | 3 | 0.941 | 0.957 | 0.948 | 0.997 | 0.997 |
| 5 | other | 3 | 0.906 | 0.917 | 0.913 | 0.974 | 0.974 |
| 1 | bridging | 6 | 0.951 | 0.957 | 0.957 | 0.979 | 0.978 |
| 2 | bridging | 6 | 0.943 | 0.950 | 0.947 | 0.976 | 0.973 |
| 5 | bridging | 6 | 0.925 | 0.939 | 0.932 | 0.967 | 0.966 |
| 2 | other | 6 | 0.950 | 0.961 | 0.958 | 0.978 | 0.977 |
| 5 | other | 6 | 0.911 | 0.927 | 0.922 | 0.964 | 0.960 |
| 1 | bridging | 12 | 0.954 | 0.955 | 0.955 | 0.968 | 0.968 |
| 2 | bridging | 12 | 0.950 | 0.951 | 0.952 | 0.968 | 0.967 |
| 5 | bridging | 12 | 0.930 | 0.935 | 0.934 | 0.957 | 0.948 |
| 2 | other | 12 | 0.942 | 0.945 | 0.947 | 0.961 | 0.961 |
| 5 | other | 12 | 0.932 | 0.943 | 0.942 | 0.965 | 0.956 |

</div>

The registered rule returned mixed: in the registered cells
(non-bridging subnetwork heterogeneous) the shared model never covered
below 0.90, and the shrunk model was not nominal where the shared one
fell short (<a href="#tbl-main" class="quarto-xref">Table 1</a>); the
lowest shared coverage, 0.897, was with the bridging subnetwork
heterogeneous. Across the grid the three structures differed by at most
0.016 in coverage and a few percent in width
(<a href="#fig-coverage" class="quarto-xref">Figure 1</a>). The gap to
nominal was driven by the heterogeneity ratio and the study count, not
by the structure: at a 5:1 ratio and three studies per subnetwork every
Wald interval covered 0.90 to 0.92, rising to 0.93 to 0.94 at twelve.
The shared estimate of $\tau$ sat between the two true values, as it
must, and the bridged contrast’s variance, which sums both subnetworks,
was close to right on average.

# What this does not answer

The bridged contrast here sums both subnetworks; a contrast drawing on
one subnetwork only would carry the shared $\tau$’s error without the
offset. Frequentist REML without priors; no residual-variance arm, IPD
studies or sparse network. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-hartung2001" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Joachim Hartung, Guido Knapp. On
tests of the overall treatment effect in meta-analysis with normally
distributed responses. Statistics in Medicine. 2001;20(12):1771–82.
doi:[10.1002/sim.791](https://doi.org/10.1002/sim.791)</span>

</div>

</div>
