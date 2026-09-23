# Protocol: MAIC variance with the weighting step, and the estimand trimming targets

**Target problem.** SFW-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claims

(a) Stacking the weight and outcome estimating equations gives the variance that the
fixed-weight sandwich misses, and the missing term's sign depends on how the outcome
aligns with the balancing covariates. **Refuting sentence:** existing guidance already
identifies an estimator that performs well (Chandler and Proskorovsky found the
ESS-based conventional variance accurate across most scenarios), so stacking adds
nothing. (b) Trimming breaks the calibration, so a trimmed analysis estimates the
effect in the population its capped weights induce, $w_{\text{cap}}(x)f_S(x)$, not the
declared target.

The probe at poor overlap already contradicts the expectation in (a): both sandwich
variances understated the empirical SD (stacked 0.39, fixed 0.44, empirical 0.47)
and the ESS-based variance was closest (0.49).

## 2. Design

Individual-data trial A versus C, 200 per arm, three independent normal covariates,
binary outcome $\operatorname{logit} p = \operatorname{logit}(\pi) + 0.5\sum_j x_j + A(-0.5 + \beta x_1)$,
MAIC on means to a target $N(s\mathbf 1, I)$.

| factor | levels |
|---|---|
| target shift $s$ (overlap) | 0.2, 0.5, 0.8 |
| control risk $\pi$ at the source mean | 0.1, 0.3 |
| modification $\lvert\beta\rvert$ | 0, 0.5, 1 |
| alignment | $\beta > 0$ (with the prognostic direction), $\beta < 0$ |
| trimming | none; cap at the 99th percentile; at the 95th |

90 cells, **1000 replicates** (0.7 core-hours). Truths: the declared target's marginal
log OR, and the induced population's, each by Monte Carlo over 400,000 draws with
population-level weights.

**Variance estimators:** fixed-weight sandwich; ESS-based conventional
($1/(\mathrm{ESS}_a\,p_a(1-p_a))$ per arm); stacked sandwich; stacked with the
$n/(n-k)$ correction. Stacking applies to untrimmed analyses only, since capped
weights solve no estimating equation.

## 3. Outcomes and decision

Per cell: bias against both truths, empirical SD, mean of each SE, coverage per
estimator, with MCSE.

- **Primary (a):** across untrimmed cells, coverage of each variance estimator. The
  refuting sentence holds if the ESS-based variance has coverage within
  $[0.93, 0.97]$ in at least as many cells as the stacked sandwich.
- **Sign:** the ratio of stacked to fixed SE, per cell; the sign claim is confirmed if
  the ratio exceeds 1 beyond Monte Carlo error in some cells and falls below 1 in
  others.
- **Primary (b):** in trimmed cells, the gap between the declared and induced truths,
  and bias against each; trimming is reported as changing the estimand if bias against
  the induced truth is smaller than against the declared truth in most trimmed cells.

**Controls.** $s = 0.2$, $\beta = 0$, untrimmed: every variance estimator's coverage
within $[0.93, 0.97]$ and bias within 3 MCSE.

## 4. Departures from DESIGN.md

No bootstrap arm; ESS levels are produced by the shift rather than set separately;
continuous-outcome and parallelization items are not run. $n_{sim} = 1000$.
