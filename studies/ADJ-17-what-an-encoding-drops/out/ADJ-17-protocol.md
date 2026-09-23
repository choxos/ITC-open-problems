# Protocol: what a reconstruction-objective encoding drops

**Target problem.** ADJ-17. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

An encoding learned to reconstruct the covariates keeps the directions of largest variance, not the
directions that modify the treatment effect, so it can drop a modifier while reconstructing the
covariates well. **Refuting sentence:** reconstruction and interaction-preservation checks detect modifier
loss reliably enough that a learned encoding can be audited as well as a declared mapping.

## 2. Design

Twenty covariates, $x \sim N(0, \Sigma)$ with five strong directions (variance 3) and fifteen weak ones (0.1) under
a fixed rotation; outcome $y = x'b + a(-0.5 + 0.4\,s) + e$ with $s$ the standardized score along one direction $v$,
strong (high variance share) or weak (low); 300 per arm. Target mean shifted by 0.5 or 1 SD along $v$ and by
0.5 SD along an unrelated strong direction; estimand $-0.5 + 0.4 \times \text{shift}$. Methods, each linear STC with
treatment interactions standardized at the target means: all 20 covariates; the first $k \in \{2, 5, 10\}$
principal components of the source covariates (reconstruction objective); and a declared mapping (the
analyst's modifier score plus all main effects). 12 cells, **1000 replicates**.

## 3. Decision

**Primary:** principal-component STC with $k = 5$ and the modifier on a weak direction. **Confirmed** if its bias
is at least 0.1 in absolute value while the components reconstruct at least 80% of the covariate variance;
otherwise not. Reported for every cell and method: bias, coverage, RMSE and the variance reconstructed.

## 4. Departures from DESIGN.md

Linear encoder only (principal components); no treatment-effect-preserving encoder, nonlinear
heterogeneity, measurement shift or overlap factor; one or no modifier sparsity level; continuous outcome.
