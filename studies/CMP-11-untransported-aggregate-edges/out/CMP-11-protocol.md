# Protocol: two-stage pooling of edges that live in different populations

**Target problem.** CMP-11. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Two-stage component MAIC and STC reweight only the individual-data edges to the target, so under effect
modification the pooled component parameter mixes population referents (bias $b_1$), and component STC
adds a conditional-versus-marginal gap on non-collapsible scales ($b_2$). **Refuting sentence:** at
realistic population separations the mixture is small relative to the extra estimation error of carrying
every edge to the target, so the two-stage route is the better practical choice.

## 2. Design

Eight trials estimate one component's effect; a share (1/4, 1/2, 3/4) supply individual data (population
mean $0.5 - s/2$), the rest publish their own-population effect (mean $0.5 - s$); target mean 0.5; separation
$s \in \{0, 0.5, 1\}$; effect modification $\beta \in \{0, 0.3\}$; continuous (collapsible) or binary (log odds
ratio) outcome from $0.5x + a(-0.3 + \beta x)$; 200 per arm per trial. Estimand: the component's marginal effect
in the target. Methods, pooling edges by inverse variance: two-stage with marginal (G-computation) IPD
edges; two-stage with conditional IPD edges at the target mean profile; transported, where aggregate edges
are also carried to the target with the modification estimated from the pooled IPD (their covariate law
known; the common shift enters the pooled estimate once, its covariance with the IPD edges ignored). 36
cells, **1000 replicates**.

## 3. Decision

**Refuting sentence holds** if the two-stage (marginal) RMSE is no larger than the transported RMSE in every
cell with $\beta = 0.3$ and $s = 0.5$; it fails otherwise. Reported: bias against the predicted $b_1$ (aggregate
edges' precision share times their own-population minus target effect, a regression slope near 1 confirming
the mechanism), $b_2$ as the conditional minus marginal two-stage bias, coverage, SE ratio and RMSE.
Nulls: $b_1 = 0$ at $\beta = 0$ or $s = 0$; $b_2 = 0$ on the continuous scale.

## 4. Departures from DESIGN.md

Eight trials of one component rather than a component network with subnetworks; no one-stage component
ML-NMR (not fitted here), so the transported arm stands for the coherent alternative; aggregate covariate
laws known exactly; no reconstruction-accuracy factor; one network size.
