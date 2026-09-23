# Protocol: parametric and flexible outcome models under adversarial response surfaces

**Target problem.** MOD-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Flexible outcome models could remove transport bias that a parametric STC incurs under nonlinear surfaces.
**Refuting sentence:** flexibility trades transparent misspecification for opaque misspecification: the
flexible arms are no less biased where it matters, because the region that drives transport bias has no
data and regularization there is an assumption like a functional form.

## 2. Design

Source trial A versus C, 300 per arm, $x_1, x_2 \sim N(0, 1)$; binary outcome
$\operatorname{logit}p = -0.6 + 0.5x_1 + 0.3x_2 + \text{PROG} + a(-0.6 + 0.3x_1 + \text{MOD})$ with one adversarial
feature at a time: none; A, a threshold prognostic term $0.8\,\mathbb{1}(x_1 > 1)$; B, hinge modification
$0.8\max(x_1 - 0.5, 0)$; C, covariate-by-covariate modification $0.4x_1x_2$. Target $x_1 \sim N(\mu, 1)$,
$x_2 \sim N(\mu/2, 1)$, $\mu \in \{0.5, 1, 1.5\}$, known through its marginals. Estimand: target marginal log odds
ratio A versus C (anchored comparisons inherit it). 12 cells, **500 replicates**.

Methods, each standardized over the target by G-computation on a 60 by 60 quantile grid, with delta-method
SEs: parametric STC (linear main effects and treatment interactions); GAM with smooth prognostic terms and
smooth treatment interactions (mgcv, REML, Bayesian covariance); structured GAM with smooth prognostic terms
and linear treatment interactions.

## 3. Decision

**Primary:** surface B at $\mu = 1.5$. **Flexibility established** if STC's bias is at least 0.05 in absolute value and
a flexible arm has at most half of it with coverage 0.935 to 0.965; otherwise the refuting sentence holds.
Reported for every cell: bias, MCSE, empirical SD, SE ratio, coverage, RMSE. **Null control:** on the linear
surface every method is unbiased within 3 MCSE with coverage 0.93 to 0.97. Dropped replicates are counted.

## 4. Departures from DESIGN.md

The full GAM was first written with a factor `by` variable plus a common smooth, which is rank
deficient (42 of 44 coefficients identified); it was changed to centered difference smooths (ordered-factor
`by`, full rank) and the run restarted before any result was read. No BART (not installed) and no random forest; GAMs play the flexible and structured roles; no doubly robust
or ML-NMR arm; logit link only; one source size and event rate; model-based intervals only, no
cross-fitting or tuned resampling; individual-data transport of A versus C only.
