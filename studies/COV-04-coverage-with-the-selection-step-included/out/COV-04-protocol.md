# Protocol: coverage of shrinkage and selection priors on interactions

**Target problem.** COV-04. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A posterior interval from a model whose interactions were selected or shrunk on the same data is not
automatically honest. **Refuting sentence:** continuous shrinkage does not select, so there is no
selection event to condition on and the posterior interval is honest by construction. DESIGN.md's
counterargument: the shrinkage strength is fitted to the same data, so a strong interaction is shrunk under
a scale estimated partly from the weak ones, giving bias the interval does not carry.

## 2. Design

Source trial A versus C with $n \in \{100, 300\}$ per arm and eight independent $N(0, 1)$ covariates;
$y = 0.5\sum x + A(-0.5 + \sum_m\beta_mx_m) + e$ with one strong modifier (0.5) or three moderate (0.25).
Target covariate means 0.5. Estimand: $-0.5 + 0.5\sum\beta_m$. 4 cells, **1000 replicates**. The whole
procedure, including the fitted shrinkage or selection, is rerun in every replicate.

Priors on the eight interactions (main effects flat, residual SD plugged in): flat; normal with its scale
set by maximizing the marginal likelihood (empirical-Bayes ridge); normal with its scale integrated over a
half-Cauchy(0, 0.5) prior (hierarchical); spike-and-slab with exact averaging over all 256 inclusion
patterns (slab SD 0.5, inclusion prior 0.5); and the median-probability model's conditional posterior
(selection). Central 95% posterior intervals.

## 3. Decision

**Refuting sentence fails** if a continuous-shrinkage interval (empirical-Bayes ridge or hierarchical
normal) covers below 0.93 beyond Monte Carlo error in some cell. Coverage, bias and width are reported for
every prior; the selection interval is DEC-11's mechanism in Bayesian form.

## 4. Departures from DESIGN.md

Continuous outcome with conjugate normal priors (no MCMC), so the regularized horseshoe, heredity
constraints and projection-predictive selection are not run; residual SD plugged in; no IPD network.
