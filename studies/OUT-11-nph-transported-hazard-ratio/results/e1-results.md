# E1: the censoring dependence of the transported anchored hazard ratio, computed

Run: `Rscript R/05-e1-decomposition.R`. Results in `results/e1-decomposition.rds`.

**No simulation anywhere.** Every number is Gauss-Hermite quadrature plus a root-find, so none of it
carries Monte Carlo error and none of it can be made more precise by running longer. E2 checks these
values against simulation independently and reproduces them to 0.0141 on the log scale with nominal
interval coverage.

## What is computed, and two corrections to what it used to be

The quantity is the **anchored indirect** contrast: a least-false Cox coefficient from an
A-versus-placebo study, a second from a separate B-versus-placebo study, combined by Bucher. Each
leg is evaluated **in its own study**, under that study's baseline hazard and its own censoring
regime, and the two regimes are **crossed independently** over all four, giving a 4x4 grid.

Two things about that sentence were wrong in earlier versions, and both changed the numbers.

**Version 4 computed `cox_limit(A, B)`**, the coefficient a direct head-to-head trial would report,
and defended that framing explicitly. Round 4 found the defense wrong. Least-false Cox coefficients
are not transitive under non-proportional hazards: each leg is a censoring- and event-weighted
average of its own time-varying contrast, weighted by its own risk sets, and the difference of two
such averages is not the average a direct comparison produces. Measured, the two quantities differ by
0.93% to 1.78% and the gap varies with censoring.

**The first anchored rewrite evaluated both legs at the target study's baseline**, calling it
"population adjustment assumed perfect". That is stronger than perfect population adjustment and no
method delivers it: MAIC reweights the IPD study's patients and fits there, STC fits a conditional
model there, and neither transports a baseline hazard. Since the least-false projection is weighted
by risk sets and the baseline determines those, leg A converges under the IPD study's baseline.
Measured, the difference reaches 2.86% on the hazard-ratio scale at $\kappa_A = 0.30$ and varies from
2.86% to 1.38% across regimes. Correctly evaluated, leg A's own censoring spread at
$\kappa_A = 0.30$ is **16.08%**; the target baseline had overstated it at 17.27%.

Version 4 also could not express **differential follow-up between the two studies** at all, having
only a single shared censoring survival. That is the case the OUT-11 entry names.

## E1.1 Factorial: the two sources do not add

$\beta_B$ is re-solved at every $(\kappa_B, \gamma)$ so the true target RMST difference stays at the
registered 0.75 months. Spread is $(\max - \min)/\min$ of the anchored hazard ratio over the 4x4
regime grid, in percent, Weibull.

| $\kappa_B$ | $\gamma = 0$ | $0.15$ | $0.30$ | $0.50$ |
|---:|---:|---:|---:|---:|
| 0.00 | $2.6\times10^{-9}$ | 0.488 | 1.648 | 3.261 |
| 0.15 | 8.817 | 8.967 | 9.707 | 10.77 |
| 0.30 | 17.39 | 17.14 | 17.41 | 17.88 |

Round 2 was right that the least-false root is nonlinear, so the two pathways do not add, and the
table shows it sharply: raising $\gamma$ from 0 to 0.50 adds **3.26 points** of spread at
$\kappa_B = 0$ but only **0.49 points** at $\kappa_B = 0.30$. Under additivity both increments would
be 3.26. Only the ablations below are claimed as clean separations.

Gompertz behaves the same way: 0 to 4.069 at $\kappa_B = 0$, and 17.17 to 17.07 at $\kappa_B = 0.30$.

## E1.2 Ablations, which must be exactly zero

| ablation | spread |
|---|---:|
| $\kappa_A = \kappa_B = 0$ **and** $\gamma = 0$ | $2.6\times10^{-9}$ |
| $\gamma = 0.30$, $\kappa_A = \kappa_B = 0$, covariate spread collapsed to zero | $2.1\times10^{-9}$ |

Both ingredients are required. Removing either gives numerically zero movement, which is the only
part of the decomposition claimed as exact.

## E1.3 Per registered cell, with the legs separated

Spread across the regime grid, in percent.

| arm | $\kappa_A$ | $\kappa_B$ | full grid | matched diagonal | leg A | leg B |
|---|---:|---:|---:|---:|---:|---:|
| primary | 0.00 | 0.00 | 5.594 | 0.3009 | 2.914 | 2.605 |
| primary | 0.00 | 0.15 | 8.598 | 8.598 | 2.914 | 5.523 |
| primary | 0.00 | 0.30 | 16.57 | 16.57 | 2.914 | 13.27 |
| margin | 0.00 | 0.00 | 5.741 | 0.2394 | 2.914 | 2.747 |
| margin | 0.00 | 0.30 | 16.13 | 16.13 | 2.914 | 12.84 |
| control | 0.00 | 0.00 | $2.6\times10^{-9}$ | $2.5\times10^{-9}$ | $2.5\times10^{-9}$ | $1.5\times10^{-10}$ |
| **ipd-nph** | **0.30** | 0.00 | 14.96 | 14.96 | 12.53 | 2.162 |
| **ipd-nph** | **0.30** | **0.30** | 28.85 | 2.273 | 12.53 | 14.51 |
| family (Gompertz) | 0.00 | 0.00 | 6.686 | 0.4167 | 3.429 | 3.148 |
| family (Gompertz) | 0.00 | 0.30 | 15.68 | 15.68 | 3.429 | 11.84 |

**The leg decomposition is exact and is the cleanest check in the study.** Leg A's spread is 0.620%
in every cell with $\kappa_A = 0$ whatever $\kappa_B$ does, and 16.08% in both cells with
$\kappa_A = 0.30$. A leg cannot be moved by the other study's parameters, and this confirms it
rather than assuming it.

**The $\kappa_A = \kappa_B = 0.30$ cell is the sharpest result in E1.** Its full-grid spread is
37.23% while its matched-follow-up diagonal is 2.577%, a factor of 14. Both arms are strongly
non-proportional but the *target contrast* is proportional, because $\kappa_B - \kappa_A = 0$. When
the two studies are followed alike the two legs' movements very nearly cancel in the Bucher
difference and the contrast looks stable; when they are not, they do not cancel at all. Version 3
could not express this cell, and version 4 could not express the crossing that reveals it.

## E1.4 D3: the decision consequence, and it fails

Each leg's least-false hazard ratio is applied to **one fixed target placebo curve**, the truth's
own, and the two implied RMSTs are differenced. No baseline noise enters. This is the performance of
the **PH plug-in decision procedure** and is labeled as such: it is not a general conversion from a
hazard ratio to a non-proportional RMST contrast, which does not exist.

| arm | $\kappa_A$ | $\kappa_B$ | truth | min | max | range | matched-only range |
|---|---:|---:|---:|---:|---:|---:|---:|
| primary | 0.00 | 0.00 | 0.75 | 0.594 | 0.848 | 0.2539 | 0.02059 |
| primary | 0.00 | 0.15 | 0.75 | 0.340 | 0.725 | 0.3849 | 0.3849 |
| primary | 0.00 | 0.30 | 0.75 | -0.010 | 0.708 | 0.7188 | 0.7188 |
| margin | 0.00 | 0.00 | 0.35 | 0.195 | 0.459 | 0.264 | 0.01189 |
| margin | 0.00 | 0.30 | 0.35 | -0.401 | 0.315 | 0.7157 | 0.7157 |
| control | 0.00 | 0.00 | 0.75 | 0.750 | 0.750 | $1.2\times10^{-10}$ | $1.1\times10^{-10}$ |
| **ipd-nph** | **0.30** | 0.00 | 0.75 | 0.677 | 1.289 | 0.6119 | 0.6119 |
| **ipd-nph** | **0.30** | **0.30** | 0.75 | 0.067 | 1.161 | 1.093 | 0.07938 |
| family | 0.00 | 0.00 | 0.75 | 0.589 | 0.840 | 0.2506 | 0.0282 |
| family | 0.00 | 0.30 | 0.75 | -0.018 | 0.557 | 0.575 | 0.575 |

**Worst range 1.3805 months against a 0.50-month tolerance. D3 fails.** It fails by a factor of two
even against the 0.60-month sensitivity threshold, so the verdict is not an artifact of where the
threshold was set.

The failure is driven by which study is more heavily censored, in either direction. At the
$\kappa_A = \kappa_B = 0.30$ cell the extremes are:

| IPD study | aggregate study | implied $\Delta_{\text{RMST}}$ |
|---|---|---:|
| heavy | reference | $-0.062$ |
| reference | reference | $+0.610$ |
| short follow-up | short follow-up | $+0.697$ |
| reference | heavy | $+1.318$ |

against a truth of **0.750**. **The matched-follow-up range is 0.087, which would have passed.**
That is a factor of 16, and it is the reason version 4's shared-regime design reported the whole
study as passing at 0.697 and would have called this cell among the safest in it.

That two-sidedness is also why the E3 cell matrix now carries a mirrored censoring condition. With
only "balanced" and "heavier on the aggregate side", E3 spanned 45% of this range and only its
positive half, so an estimator with an offsetting bias would have read as accurate.

---

The superseded head-to-head computation, and the intermediate anchored version that used the target
baseline for both legs, are not reproduced here. Both are recoverable from the git history of
`R/02b-anchored-limit.R` and `R/05-e1-decomposition.R`, and the corrections are recorded in the
protocol's change log with their measured sizes.
