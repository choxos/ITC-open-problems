# Protocol: target marginals reconstructed from a median with IQR or range

**Target problem.** COV-12. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

An integration-based adjustment needs the target's whole covariate marginal; a
publication often gives a median with IQR or range. The contrast error is
$\int\tau\,d(\hat F - F)$: under an identity link with linear modification only the
reconstructed mean enters; under a curved link the variance and shape enter as well.
**Refuting sentence:** contrast error is a monotone function of mean-recovery error,
so the median-to-mean estimators already optimize the right thing.

## 2. Design

The target's covariate is lognormal with log-SD `skew`, rescaled to mean 1 and SD 1
(skew 0: normal). The target publication reports the median with quartiles or with
minimum and maximum of $n_T$ patients. The conditional model is held known
(A versus C, $0.8x - 0.6 + \beta x$ on the identity or logit scale, logit baseline
$\operatorname{logit}(0.3)$), so reconstruction is the only error. Truth by integration
over 2000 quantiles of the true law.

| factor | levels |
|---|---|
| link | identity, logit |
| skew | 0, 0.5, 1 |
| reported summary | median and IQR; median and range |
| $n_T$ | 50, 200, 1000 |
| modification $\beta$ | 0.3, 0.8 |

72 cells, **1000 replicates** (0.2 core-hours). Reconstructions: normal with Wan et al.
mean and SD formulas; a shifted lognormal matched to the median and the reported
quantiles (normal when they are not right-skewed). A third arm integrates over the
target's actual sample, the floor any reconstruction faces.

## 3. Decision

Per replicate, regress each reconstruction's contrast error (net of the sample floor)
on $\beta$ times its mean-recovery error, by link. **The refuting sentence holds for a
link** if $R^2 \ge 0.9$, and fails otherwise. Bias and RMSE of each reconstruction per
cell are reported.

## 4. Departures from DESIGN.md

The conditional model is known rather than estimated; one covariate; ML-NMR
integration is represented by direct integration over the reconstructed law.

**Amendment after registration.** The first launch recorded mean-recovery error
against the population mean, inconsistent with the registered regression, which nets
the sample floor out of the contrast error. Two cells had completed; they were deleted
without being read, the regressor was changed to error against the sample mean, and
the run restarted. The commit message for that change says no cell had completed,
which was wrong.
