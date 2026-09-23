# Protocol: one heterogeneity parameter across two subnetworks that differ in it

**Target problem.** CMP-16. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

One $\tau$ across a disconnected network lends one subnetwork's heterogeneity to the other, so the bridged
contrast's interval can be too wide or too narrow. **Refuting sentence:** with the study counts these networks
have, a stratified $\tau$ is so weakly identified that the shared default is the better choice even when wrong.

## 2. Design

Subnetwork 1 (bridging): $K$ studies of component A against its backbone (effect $-0.3$); subnetwork 2: $K$
studies of B against A (0.1); the bridged target is their sum. Study estimates with within-study SE uniform
on 0.1 to 0.25 and between-study SD 0.05 in one subnetwork and 0.05, 0.1 or 0.25 in the other (ratio 1, 2, 5),
the heterogeneous one being the bridging or the other subnetwork; $K \in \{3, 6, 12\}$. Models: shared $\tau^2$
(REML), stratified $\tau^2$ (REML per subnetwork), and each subnetwork's $\tau^2$ shrunk toward the shared value
with weight $K/(K + 4)$; Wald intervals, and Hartung-Knapp versions of shared and stratified. 15 cells,
**2000 replicates**.

## 3. Decision

**Primary:** coverage of the bridged contrast under shared $\tau$ where the non-bridging subnetwork is the
heterogeneous one. **Confirmed** if shared $\tau$ covers below 0.90 in some such cell while the shrunk model
covers at least 0.93 there; **shared $\tau$ defensible** if it covers at least 0.93 in every cell; otherwise mixed.
Stratified coverage by study count is reported (the refuting sentence's sparse regime), with widths, SE
ratios and the $\tau$ estimates.

## 4. Departures from DESIGN.md

Frequentist REML with no priors, so "posterior equals prior" is examined as REML instability; contrast-level
data; no residual-variance ($\sigma$) arm, IPD studies or sparsity factor; the shrinkage weight is a declared
rule, not an estimated hierarchy.
