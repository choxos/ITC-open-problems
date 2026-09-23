# Miscoding the shared component of a bridged network costs
identifiability, not accuracy; miscoding an internal component biases
the bridged estimate
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Component network meta-analysis parses treatment labels
into components deterministically ([1](#ref-rucker2020cnma)), and a
disconnected network is bridged when its subnetworks share a component.
Catalog problem CMP-06 asks what a coding error does there: perturb an
estimate, or change what is estimable.

**Methods.** Two subnetworks linked only by component A; the target is
the effect of a component observed only across the gap. Codings in the
second subnetwork were wrong independently with probability up to 0.3,
either coding the shared A as a distinct agent (connectivity-changing)
or dropping an internal component (connectivity- preserving).
Deterministic fits with a rank screen, coding sensitivity and
probabilistic coding; 2000 replicates per cell.

**Results.** Coding the shared component as distinct removed the
bridge’s information from that trial: the target became non-estimable in
9.5% of replicates at the highest rate, which the rank screen detected
exactly, and otherwise stayed unbiased with coverage 0.943 given a
miscoding. Dropping an internal component biased the target by -0.105
and cut coverage to 0.826 given a miscoding, with the row space
unchanged. Probabilistic coding restored coverage (0.967 or more);
coding sensitivity did too but returned the whole line whenever a
plausible coding broke the bridge.

**Conclusion.** For a real bridge, the dangerous miscoding is the one
that leaves the network’s shape intact. A rank screen over the plausible
codings is free and catches the other kind; propagating coding
uncertainty handles the biasing kind.

# The problem

A target contrast is estimable if it lies in the row space of the design
implied by the component coding. Coding a shared component as two
distinct agents can remove the only path across the gap; omitting a
component from an arm leaves the row space unchanged but attributes that
component’s effect to the others. The two errors are different in kind,
and which one a plausible miscoding produces is computable before
fitting.

# Design

Registered protocol: `protocol.md`. Subnetwork 1: X vs X+A (two trials),
X vs X+C. Subnetwork 2: Y+A vs Y+B+D (two trials), Y vs Y+D. Component
effects A $-0.3$, B $-0.2$, C $-0.1$, D $-0.15$; each contrast has
variance 0.01. The target, the effect of B, is identified under the true
coding only through A. Each subnetwork-2 trial is miscoded with
probability $p$: A coded as a distinct A2, or D dropped from the Y+B+D
arm. Coding sensitivity takes the union of the intervals over every
plausible coding of those two trials, or the whole line if one of them
leaves B unidentified. Probabilistic coding mixes the plausible codings’
estimates by their prior probability (at least 0.05 per trial).

# Results

<div id="tbl-main">

Table 1: 2000 replicates per cell; deterministic coverage is conditional
on the target being estimable under the coding used. Coverage MCSE at
most 0.008.

| miscoding | $p$ | target non-estimable | deterministic coverage | given a miscoding | bias given a miscoding | sensitivity coverage (bounded) | probabilistic coverage (bounded) |
|----|---:|---:|---:|---:|---:|---:|---:|
| shared A coded as distinct | 0.00 | 0.0% | 0.951 |  |  | 1.000 (0.0%) | 0.952 (100.0%) |
| shared A coded as distinct | 0.05 | 0.4% | 0.952 | 0.945 | -0.021 | 1.000 (0.0%) | 0.957 (100.0%) |
| internal D dropped | 0.05 | 0.0% | 0.944 | 0.868 | -0.095 | 0.980 (100.0%) | 0.967 (100.0%) |
| shared A coded as distinct | 0.15 | 2.3% | 0.951 | 0.944 | 0.001 | 1.000 (0.0%) | 0.965 (100.0%) |
| internal D dropped | 0.15 | 0.0% | 0.923 | 0.840 | -0.103 | 0.979 (100.0%) | 0.969 (100.0%) |
| shared A coded as distinct | 0.30 | 9.5% | 0.952 | 0.943 | 0.004 | 1.000 (0.0%) | 1.000 (0.0%) |
| internal D dropped | 0.30 | 0.0% | 0.885 | 0.826 | -0.105 | 0.983 (100.0%) | 0.967 (100.0%) |

</div>

The registered primary was refuted for inference
(<a href="#tbl-main" class="quarto-xref">Table 1</a>): when the bridge
is real, coding the shared component as distinct in one trial costs that
trial’s bridging information but not accuracy, and coding it so in both
makes the target non-estimable, which the rank screen reports without
fitting. The second null control failed, and that is the finding: the
miscoding that leaves the row space intact was the one that biased the
estimate, by about 0.8 of its standard error, because the omitted
component’s effect was attributed to B. Both uncertainty methods covered
it. Coding sensitivity paid for this with uninformative output in every
connectivity-changing cell, since its plausible set always included a
coding without the bridge; probabilistic coding stayed bounded unless
that coding carried more than 5% prior probability.

A false bridge, a distinct agent coded as the shared component, is the
reverse error. The target is then not identified under the true coding,
so every fitted interval is a model extrapolation whose error is the
effect difference between the two agents; this was not simulated, and no
coding method fitted to the data can detect it.

# What this does not answer

One hand-built network, contrast-level fixed-effect fits, no covariate
adjustment, synergy or Bayesian arm, independent miscoding within a
two-trial plausible set. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-rucker2020cnma" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Gerta Rücker, Maria Petropoulou,
Guido Schwarzer. Network meta-analysis of multicomponent interventions.
Biometrical Journal. 2020;62(3):808–21.
doi:[10.1002/bimj.201800167](https://doi.org/10.1002/bimj.201800167)</span>

</div>

</div>
