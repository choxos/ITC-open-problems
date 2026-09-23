# Protocol: unsupported target mass matters only where the effect is modified

**Target problem.** OVL-01. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

The transport bias from the target region $\mathcal{U}$ the source does not cover is
$F_T(\mathcal{U})\cdot E_{F_T}[\hat\tau - \tau \mid \mathcal{U}]$. Weight and covariate
diagnostics (Kish ESS, unsupported mass, largest weight share) are functions of the
covariates and weights only, so they see the first factor and not the second.
**Refuting sentence:** a battery of support diagnostics orders the analyses that fail,
so the missing object is a threshold rather than new information.

## 2. Design

Anchored A versus C source trial, 300 per arm; $x_1, x_2 \sim N(0, 1)$ with $x_1$
truncated at $c$, so target mass above $c$ is unsupported. Target $x \sim N(0.4, I)$ with
known law. $y = 0.5(x_1 + x_2) + A\,\tau(x) + e$, $e \sim N(0, 1)$,
$\tau(x) = -0.5 + b\{w_1g(x_1) + w_2g(x_2)\}$.

| factor | levels |
|---|---|
| truncation $c$ (unsupported target mass) | none (0), 1.5 (0.14), 1.0 (0.27) |
| alignment $(w_1, w_2)$ | orthogonal (0, 1); partial (0.5, 0.5); full (1, 0) |
| shape $g$ | linear $g(x) = x$; bent $g(x) = x + 3(x - 1)_+$ |
| strength $b$ | 0.3, 0.6 |

36 cells, **1000 replicates** (1.1 core-hours). The covariate laws do not depend on
alignment, shape or strength, so every covariate-and-weight diagnostic has the same
distribution across them by construction. Estimand: $E_{F_T}\tau(x)$ over the whole
target law, closed form. Restricted estimand: $E_{F_T}[\tau \mid x_1 \le c]$.

**Methods.** MAIC on the target means with a robust variance; G-computation with
natural-spline modification (3 df per covariate), correct within the observed range
and linear beyond it, integrated over the known target law with a delta-method
variance; the same G-computation over the target region inside the source's observed
range (trimmed), scored against the restricted estimand.

**Diagnostics**, larger meaning more risk: Kish ESS/n (negated); target mass outside
the source's observed range; largest weight share; an alignment-aware score,
$\sum_j\lvert\hat\beta_j\rvert\,E_{F_T}[\text{distance beyond the observed range in } x_j]$,
with $\hat\beta_j$ the source's linear interaction estimates, which uses outcome data.

## 3. Decision

Failure: the 95% interval excludes the truth (secondary: absolute error above 0.2).
Diagnostics scored by AUROC within each truncation level, pooled over alignment, shape
and strength, with bootstrap SEs.

- **Primary.** At truncation 1.0, alignment-aware minus Kish ESS AUROC for G-computation
  failure. **Confirmed** if at least 0.10. **Refuted** if both are at least 0.7 at every
  truncation level; **neither usable** if both are below 0.7.
- The abstention frontier (missed failures against false abstentions) is reported for
  every diagnostic.

**Controls.** Null: without truncation every estimator unbiased and near nominal.
Second null: orthogonal alignment with truncation, G-computation unbiased within 3
MCSE. Positive: full alignment, bent, truncation 1.0, both estimators materially
biased. Falsifier: linear modification with full alignment at truncation 1.0,
G-computation unbiased (support recovered by assumption).

## 4. Departures from DESIGN.md

Continuous outcome rather than log odds ratio, so non-collapsibility does not mix
with support; two covariates, not 3 and 8; ML-NMR, ML-UMR and NMI not run; failure
defined by interval non-coverage because no decision context fixes a material
threshold; 1000 rather than 2000 replicates.
