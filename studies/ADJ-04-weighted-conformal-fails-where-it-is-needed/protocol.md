# Protocol: weighted conformal prediction under covariate shift

**Target problem.** ADJ-04. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Weighted split-conformal prediction restores coverage under covariate shift by reweighting calibration scores by
the density ratio. Its effective calibration size is $n/\{1 + \chi^2(F_T \Vert F_S)\}$, so it degrades exactly as
overlap does, and where support is absent the density ratio is undefined and the honest output is an infinite
interval. **Refuting sentence:** weighted conformal prediction restores a valid coverage statement under the
transport shift, so flexible standardization can be used with an honest interval and the support problem is solved.

## 2. Design

Source $x \sim N(0, 1)$, 300 patients to fit and 300 to calibrate; target $x \sim N(\mu, 1)$, $\mu \in \{0.5, 1, 1.5\}$,
1000 target patients per replicate. $y = 1 + 0.5x + 0.4\max(x - 1, 0)^2 + e$, $e \sim N(0, 1)$, with the curvature where
the source is thin. Natural spline model with 3 degrees of freedom. Nominal coverage 0.9. 3 cells, **500 replicates**.

Intervals: ordinary split conformal; weighted conformal with the true density ratio; weighted conformal with the
ratio estimated by logistic regression of 1000 unlabeled target draws against the calibration points.

## 3. Decision

**Refuting sentence fails** if the weighted interval's coverage among target patients beyond the source's largest
$x$ is below 0.85 at some shift, or if more than 5% of its intervals there are infinite. Coverage overall, width and
the effective calibration size against $n/(1 + \chi^2)$ are reported.

## 4. Departures from DESIGN.md

Continuous outcome and prediction intervals for individual outcomes rather than a marginal log odds ratio; no BART
or Gaussian process arm; one covariate; no support diagnostic operating characteristics.
