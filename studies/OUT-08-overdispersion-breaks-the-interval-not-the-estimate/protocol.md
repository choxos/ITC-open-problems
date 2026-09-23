# Protocol: overdispersed and zero-inflated counts transported by G-computation

**Target problem.** OUT-08. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claims

Two separable failures. (1) With negative-binomial dispersion and a correct mean, the
Poisson estimate is consistent and its model-based SE too small; a sandwich repairs
it. (2) A structural-zero fraction that differs between source and target changes the
target's absolute rate, which no count model fitted to the source can transport, and
no dispersion parameter repairs; for the rate ratio the zero fraction cancels unless
it interacts with effect modification through the at-risk composition. **Refuting
sentence:** a sandwich repairs the uncertainty and the mean is what transports, so the
missing likelihoods are a convenience.

## 2. Design

Individual-data trial A versus C, 300 per arm, one covariate $x \sim N(0,1)$; target
$x \sim N(0.5, 1)$. Counts: structural zero with probability
$\operatorname{logit}^{-1}(z_{\text{pop}} + 0.8x)$, otherwise NB with mean
$1.2\exp(0.4x + A(-0.4 + bx))$. Part A (no structural zeros): dispersion $\theta \in
\{\infty, 2, 0.7\}$. Part B (Poisson counts): structural-zero fraction at $x = 0$ of
(source, target) = (0.2, 0.2), (0.2, 0.4), (0.2, 0), (0, 0.2). Both parts cross
$b \in \{0, 0.4\}$. 14 cells, **500 replicates** (about 2.6 core-hours; coverage MCSE
0.0097 at nominal). The target reports its control arm's proportion with no events.
Truths by quadrature.

Methods (G-computation over the target law, delta-method SEs): Poisson; Poisson with a
sandwich; negative binomial; zero-inflated Poisson; zero-inflated Poisson with the
zero-part intercept recalibrated to reproduce the target's reported zero proportion.

## 3. Decision

- **Failure one confirmed** if, in overdispersed part-A cells, the Poisson rate-ratio
  bias is within 3 MCSE, its model-based coverage below 0.93, and the sandwich's at
  least 0.93.
- **Failure two confirmed** if, in part-B cells where the fractions differ, the
  absolute log-rate bias of the Poisson, negative binomial and uncalibrated
  zero-inflated fits all exceed 3 MCSE.
- Registered prediction: with $b = 0$ the rate ratio is unbiased whatever the zero
  fractions.

## 4. Departures from DESIGN.md

Frailty and exposure-weighting routes are not run (CMP-20 owns the latter); recurrent
events and zero-inflated negative binomial are not fitted; one covariate.
$n_{sim} = 500$.
