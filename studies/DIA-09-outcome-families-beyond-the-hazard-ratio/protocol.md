# Protocol: competing risks, where a correct hazard ratio gives a wrong cumulative incidence

**Target problem.** DIA-09 (competing-risks family). ADEMP reporting. Committed before
the registered run. Design: [`DESIGN.md`](DESIGN.md). Probes:
[`results/probes.md`](results/probes.md).

## 1. Claim

Population adjustment operates on the covariate distribution, but the target quantity a
decision uses may depend on processes the adjustment does not touch. For competing
risks the cumulative incidence of the event of interest depends on the competing
cause's hazard in the target. **Refuting sentence:** population adjustment is
indifferent to the outcome family, so hazard-ratio results transfer and the missing
families are a reporting gap. DESIGN.md consequence 1 predicts a method can be unbiased
for every cause-specific hazard ratio and biased for the cumulative incidence.

## 2. Design

Source trial A versus C, 300 per arm, $x \sim N(0, 1)$; target $x \sim N(\mu_T, 1)$.
Exponential cause-specific hazards: event of interest
$h_1 = 0.3\exp\{0.5x + A(-0.5 + bx)\}$; competing $h_2 = K\cdot0.2\exp(0.5x)$ with $K = 1$ in
the source and $K_T$ in the target, the competing risk the measured covariate does not
explain. Administrative censoring at 3. The target publishes covariate means and SDs and
the proportion of its control arm (300) with a competing event by $\tau = 2$.

Factors: $K_T \in \{0.5, 1, 2, 4\}$, $b \in \{0, 0.4\}$, $\mu_T \in \{0.5, 1\}$: 16 cells,
**1000 replicates** (0.23 core-hours).

Estimands at $\tau = 2$ in the target, by quadrature: cumulative incidence of the event
for A (absolute), and its A minus C difference; and the cause-1 conditional log hazard
ratio at the target mean.

Methods: MAIC on the covariate mean with weighted proportions; STC from exponential
cause-specific models for both causes, integrated over the target law (delta-method
SE); STC with the competing-cause intercept recalibrated to reproduce the target's
reported competing-event proportion (SE ignores that proportion's sampling error).

## 3. Decision

- **Consequence 1 confirmed** if the cause-1 log hazard ratio is unbiased within 3 MCSE
  in every cell while A's cumulative incidence from MAIC and STC is biased beyond 3 MCSE
  and 0.05 in every cell with $K_T \ne 1$. That also refutes the refuting sentence.
- Bias and coverage of the recalibrated analysis; registered prediction that it is
  unbiased and under-covers.
- The difference A minus C is reported beside the absolute incidence.

**Control.** $K_T = 1$: every method unbiased within 3 MCSE.

## 4. Departures from DESIGN.md

Only the competing-risks family is run. OUT-11 covers non-proportional survival; cure
fractions, recurrent events, ordinal outcomes and the joint net-benefit arm are not run.
No ML-NMR or ML-UMR arm; exponential hazards; one covariate.
