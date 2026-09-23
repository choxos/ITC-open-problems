# Protocol: how weighting, outcome-model, doubly robust and forest estimators fail as overlap goes

**Target problem.** DIA-06. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered, by DIA-03:** MAIC (two moment sets), STC and no adjustment on identical replicates,
continuous outcome, with the weight panel scored as classifiers of realized error and
$\mathrm{ESS}/n = 1/(1 + \mathrm{CV}^2(w))$ proved. **Open, and targeted here:** a non-collapsible scale;
outcome-model extrapolation separated from weighting variance at fixed divergence; doubly robust and
flexible-learner arms.

Weighting fails through the second moment of the density ratio, $n/\mathrm{ESS} = 1 + \chi^2(F_T \| F_S)$, a
variance functional; a linear outcome model fails through the curvature of the true surface where the target
leaves the source, a bias functional that no weight diagnostic contains. **Refuting sentence:** the failure
onsets of the families coincide on a common divergence axis, so a single overlap statistic orders them all.

## 2. Design

Source A versus C, 500 per arm, $x \sim N(0, 1)$; target $x \sim N(\delta, 1)$, known law, so
$\log(1 + \chi^2) = \delta^2$: the axis, at 0, 0.6, ..., 3.0 (oracle ESS/n from 1 to 0.05). The density
ratio is log-linear, so MAIC on the mean is the exact weight model for every surface. Linear predictor
$0.5x + A\{-0.5 + 0.3x + \beta_2(x^2 - 1)\}$, curvature $\beta_2 \in \{0, 0.1, 0.25\}$; continuous
($+N(0, 1)$) and binary (logit, intercept $-0.5$) scales. Under the source law $x$ and $x^2 - 1$ are
orthogonal, so linear STC's limit bias is exactly $-\beta_2\delta^2$ on the mean-difference scale and is
computed by quadrature on the log odds ratio scale (P2). Common random numbers across curvature: weights,
ESS and every covariate diagnostic are identical across it by construction.

Estimand: target marginal A versus C effect (mean difference; log odds ratio) by 60-point Gauss-Hermite
quadrature. Every method targets the marginal estimand, so the conditional-marginal gap (P1, up to 0.32)
enters no error; in an anchored comparison the target's B versus C estimate adds independent noise only.
Methods: unadjusted; MAIC on the mean, robust SE; STC, linear interaction model standardized over the
target, delta-method SE; **DR**, the STC model plus MAIC-weighted residuals per arm, **the comparator that
can win**; RF, a regression forest per arm (ranger, 200 trees, minimum node 20, fixed before the run)
averaged over a 2000-point quantile grid of the target. DR and RF carry no SE.

Onsets, in $\log(1 + \chi^2)$ and interpolated between levels: bias onset where $|$bias$|$ first reaches 0.1;
variance onset where the SD first reaches twice the same method's SD at complete overlap; a method's onset is
the earlier, its signature whichever came first; 3.6 if neither is reached. Predicted (P2, binary): MAIC
variance onset 1.66, 1.79, 1.87 across curvature; STC bias onset none, 2.07, 0.86. 36 cells, **1000
replicates**: bias MCSE about 0.015 at the largest SD (0.46), SD-ratio relative MCSE 2.2%; onset MCSE by a
bootstrap over replicate indices shared by every cell. Measured cost 2.9 CPU-hours.

## 3. Decision

**Primary, binary scale** (grid step 0.6). **Confirmed** if at strong curvature the STC and MAIC onsets
differ by at least 0.6, STC's onset is at least 0.6 earlier at strong than at moderate curvature, and MAIC's
moves by less than 0.6. **Refuted** if they are within 0.6 at both moderate and strong curvature.
**Separated, mechanism wrong** if they differ by 0.6 somewhere but STC's onset moves by less than 0.6.
Otherwise mixed. Predicted from P2: 1.01, 1.21 and 0.08. A near miss is reported as one. Neither 0.1 nor 2
comes from a decision context: the separation depends on the pair (at an SD ratio of 1.5 MAIC's onset moves
to about 1.2 and the separation to about 0.3), while the movement with curvature does not, so the movement is
the mechanism claim and the separation is conditional on the thresholds. Onsets at bias 0.05 and SD ratio 1.5
are reported as sensitivity, not tested.

**DR wins** if at every curvature its onset is no more than 0.3 earlier than the later of MAIC's and STC's.
**Null control:** at complete overlap unadjusted, MAIC, STC and DR have $|$bias$| \le 0.05$ and MAIC and STC
coverage 0.93 to 0.97; the forest's regularization bias there is reported, not tested. **Positive control:**
at linear curvature STC's $|$bias$| \le 0.03$ at every level on both scales while MAIC's SD ratio reaches 2
at the top level. Reported: bias, SD, RMSE, coverage and failures by cell and
method; continuous-scale onsets; median ESS/n and target mass beyond the source's largest $x$ per level.

## 4. Departures from DESIGN.md

ML-NMR not run: with one IPD trial and a known normal target, its population-average A versus C effect is
the same standardization as STC with the same linear predictor, fitted in Stan, which this shared machine
cannot afford. No survival scale; one source size, so the "variance onset scales with n" prediction is not
tested; effect-modification strength replaced by curvature; one forest with one tuning; onsets by
interpolation rather than isotonic regression; the outcome-model leverage falsifier reduced to reported
target mass beyond the source, which OVL-01 already scored against outcome-model failure. **Set after
probes:** curvature levels moved from 0, 0.05, 0.2 to 0, 0.1, 0.25 after the first onset table, so that
the moderate STC onset falls inside the grid on the binary scale; the forest's target integration moved from
Gauss-Hermite nodes to a quantile grid after a 30-replicate check showed quadrature of a step function doubled
its SD at complete overlap (0.33 against 0.145); the null control excludes the forest for that reason.
