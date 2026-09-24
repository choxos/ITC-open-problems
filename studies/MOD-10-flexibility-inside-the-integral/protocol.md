# Protocol: a flexible surface inside the integral, with part of the target off the support

**Target problem.** MOD-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered.** MOD-02 (one individual-data trial, binary outcome, targets 0.5, 1 and 1.5 SD away): a
GAM with smooth treatment modification had less bias than parametric STC under a hinge at every distance
(-0.009, -0.017, -0.085 against -0.018, -0.045, -0.144) but more variance, with equal RMSE at 1.5 SD (0.314
and 0.318), and no gain under a covariate product. It left open the network case, a Gaussian-process or BART
surface inside a multilevel likelihood, and the compute burden; it did not set the unsupported target mass
directly or split the bias at the support boundary. This protocol targets the first two and the split. BART is
not installed; mgcv's low-rank Gaussian-process smooth is the flexible device the entry names.

**Claim** (DESIGN.md section 2): the target contrast is $\int_S\hat\tau\,dF_T + \int_U\hat\tau\,dF_T$;
flexibility shrinks the first term's bias and can inflate the second's, so its RMSE advantage on the support
reverses as unsupported mass grows. Off the support the surface follows its basis, not data: the spline
extrapolates its boundary slope linearly, the Gaussian process does nearly the same within its range and
relaxes toward its linear trend beyond it, the parametric surface extends its global slope. **Refuting
sentence:** at the overlap levels real analyses face, the flexible surface is integrated almost entirely over
supported regions, so the amplification is hypothetical and the only real barrier is compute.

## 2. Design

Six studies of A versus C, 150 per arm, one covariate uniform within each study inside $S = [-1, 1]$: two with
individual data, $U(-1, 0.6)$ and $U(-0.6, 1)$; four reporting arm means, on $U(-1, -0.2)$, $U(-0.6, 0.2)$,
$U(-0.2, 0.6)$, $U(0.2, 1)$. $y = \mu_s + 0.3x + A\tau(x) + e$, $e \sim N(0, 1)$, with $\tau$ linear ($-0.5 +
0.3x$), hinge ($+0.8\max(x, 0)$, continuing past $S$) or plateau (the hinge held flat past $x = 1$). Hinge and
plateau coincide on $S$. Target: $(1 - \pi)\,U(0.5, 1) + \pi\,U(1, 2)$, unsupported mass $\pi \in \{0, 0.05,
0.2\}$. Estimand: target mean difference $\int\tau\,dF_T$, exact by midpoint quadrature.

One weighted likelihood over all six studies: with an identity link an arm mean's multilevel likelihood is
exactly the surface averaged over its study's law (64 quadrature points, mgcv's summation convention),
weighted by the arm size. Methods: **parametric** (linear interaction); **spline** (thin-plate, 10 knots
spanning $S$, REML); **Gaussian process** (mgcv `gp`, Matérn 3/2 with range 2, the knot span, same knots,
REML); **gated spline** (held at its boundary value past $S$). Cells: linear at three $\pi$, hinge at three,
plateau at 0.05 and 0.2: 8 cells, **1000 replicates** (coverage MCSE 0.007), common random numbers across
methods.

## 3. Decision

A flexible surface is **better**, **worse** or **tied** in a cell as its RMSE over the parametric RMSE has a
paired-bootstrap 95% interval below 1, above 1, or containing 1. **Primary:** the Gaussian process in three
cells: hinge at $\pi = 0$, hinge and plateau at $\pi = 0.2$. **Crossover confirmed** if better at $\pi = 0$
and worse in a $\pi = 0.2$ cell; **parametric adequate** if not better at $\pi = 0$ and worse in a $\pi = 0.2$
cell; **reversed** if worse at $\pi = 0$ and worse in neither $\pi = 0.2$ cell; otherwise the **refuting
sentence holds**. Registered secondary: the same rule for the spline. Reported: which method has the lowest
RMSE at $\pi = 0.2$ under the hinge and under the plateau, since the data cannot tell them apart; bias on and
off $S$; SE ratio; CPU per fit. **Null control:** linear surface, every $\pi$: parametric, spline and Gaussian
process unbiased within 3 MCSE with coverage 0.93 to 0.97. **Positive control:** plateau at $\pi = 0.2$: the
spline's off-support bias exceeds its on-support bias reduction relative to the parametric surface (probe P2c:
reachable at the registered arm size). A near miss is reported as one.

## 4. Departures from DESIGN.md

Continuous outcome and identity link, so the integral is linear and nonlinear links are not run; one
covariate; one contrast across six studies, so the network feature carried is integration over aggregate
studies, not a second active treatment; common effects, no heterogeneity; no BART; a low-rank rather than full
Gaussian process; frequentist REML rather than a Bayesian ML-NMR; no support diagnostic scored as a classifier
and no sparse-approximation cost frontier (CPU per fit reported, probe P4 times 256 points); arm means
integrate over their study's population law with variance $\sigma^2/n$, omitting the covariate's sampling
contribution; 8 rather than the full factorial of cells. Changed after probing: the hinge's kink moved from
0.5 to 0 (in a test replicate at 0.5, REML shrank both flexible surfaces to the linear fit, leaving nothing to
compare), and the unsupported component widened from $U(1, 1.5)$ to $U(1, 2)$ (at 1.5, the parametric
on-support bias in probe P2 exceeded the largest overshoot a boundary-slope extrapolation of the plateau can
reach, so the positive control could not fire).
