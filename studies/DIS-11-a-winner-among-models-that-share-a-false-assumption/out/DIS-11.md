# Leave-one-out picks a winner among models that share a false bridge,
whatever the bridge’s error
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Disconnected-network analyses are checked with
predictive criteria such as leave-one-out cross-validation. Catalog
problem DIS-11 asks whether such criteria can rank models by the error
of the bridge that links the subnetworks.

**Methods.** Two subnetworks of eight trials linked by exchangeable
baselines, with a design nuisance of 0, 0.2 or 0.5 that the bridge
carries into the cross-gap contrast; three candidate models sharing the
bridge (common effect, random effects, meta-regression on a trial
covariate) ranked by leave-one-trial-out log predictive density (6
scenarios, 1000 replicates each).

**Results.** The cross-gap bias was -0.007 to 0.499 for every candidate
alike. The leave-one-out winner was set by the within-subnetwork
structure (meta-regression won 0.72 of analyses when the covariate
mattered, the common-effect model 0.72 when it did not), and its
distribution did not change with the bridge error.

**Conclusion.** A predictive criterion computed on observed trials
cannot see an error that all candidates share, and cannot separate
candidates whose bridges are observationally equivalent. Its winner says
nothing about the cross-gap contrast; validation of a bridge needs
evidence that crosses the gap.

# The problem

Leave-one-out ([1](#ref-vehtari2017)) scores each candidate by its
predictions of observed units. Write a candidate’s cross-gap error as
its within-network error plus the bridge’s; when the bridge is shared,
the second term is common and drops out of the ranking. Candidates that
differ only in an observationally equivalent bridge fit the observed
data identically, so their scores are equal by definition.

# Design

Registered protocol: `protocol.md`. Study-level log odds summaries as in
DIS-03, with within-subnetwork contrasts varying with a trial covariate
(slope 0 or 0.3) and heterogeneity SD 0.1. Predictive densities use each
candidate’s fit to the other trials of the same subnetwork. The first
launch stopped on a naming error in the runner before producing any
result; it was fixed and rerun.

# Results

<div id="fig-win">

![](figures/fig1-winners.png)

Figure 1: Share of analyses won by each candidate at each size of the
bridge’s error.

</div>

The bars are the same at every bridge error
(<a href="#fig-win" class="quarto-xref">Figure 1</a>): the criterion
answered a within-subnetwork question correctly, choosing
meta-regression when trial covariates changed the contrast, and was
silent on the bridge.

# What this does not answer

Frequentist predictive densities on study summaries rather than LOO-PSIS
on an ML-NMR fit; grouped leave-subnetwork-out and synthetic deletion,
which do cross something like a gap, were not run; population-comparison
checks were not simulated. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-vehtari2017" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Aki Vehtari, Andrew Gelman, Jonah
Gabry. Practical bayesian model evaluation using leave-one-out
cross-validation and WAIC. Statistics and Computing. 2017;27(5):1413–32.
doi:[10.1007/s11222-016-9696-4](https://doi.org/10.1007/s11222-016-9696-4)</span>

</div>

</div>
