# Protocol: the same covariate name, two instruments

**Target problem.** COV-09. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

The source records $X_S = a_S + b_S X + e_S$ and the target reports the mean of
$X_T = a_T + b_T X + e_T$. MAIC tilts the source on $X_S$ to the reported mean. For a
normal source this moves the latent mean by $\kappa = b_S/(b_S^2 + \mathrm{Var}\,e_S)$
times the shift in $X_S$, so the transported effect is biased by
$\beta\{\mu_T - \kappa(a_T + b_T\mu_T - a_S)\}$. With one shared instrument the
adjustment is attenuated by the source reliability and a known reliability repairs it
exactly; with differing instruments the bias has either sign and no source-side
quantity identifies it. The balance table shows the recorded mean matched in every
case. **Refuting sentence:** nondifferential error attenuates predictably, so one
correction factor recovers the transported effect. The probe matches the closed form
cell by cell.

## 2. Design

Latent $X \sim N(0,1)$ in the source (200 per arm) and $N(0.5, 1)$ in the target;
continuous outcome $y = 0.5X + A(-0.4 + \beta X) + e$.

| factor | levels |
|---|---|
| instruments $(a_S, b_S, a_T, b_T)$ | same (0,1,0,1); same shifted (0.3,0.8,0.3,0.8); target offset (0,1,0.3,1); target slope (0,1,0,0.8); target both (0,1,-0.3,1.2) |
| source reliability | 1, 0.8, 0.6 |
| modification $\beta$ | 0, 0.3, 0.6 |

45 cells, **1000 replicates** (1.3 core-hours). Methods: naive MAIC on the reported
mean; reliability-corrected MAIC (disattenuated target point, assuming one
instrument and a known reliability); a bounded interval, the envelope of
reliability-corrected intervals over declared target-instrument offsets
$[-0.3, 0.3]$ and slopes $[0.8, 1.2]$ relative to the source instrument.

## 3. Decision

- Mechanism: slope of naive bias on the closed form.
- **Refuting sentence** judged separately for shared-instrument cells (holds if the
  corrected bias is within 3 MCSE everywhere) and differing-instrument cells (fails
  if the corrected bias exceeds 0.05 in any).
- Bounded interval: coverage and width relative to the naive interval.

**Null control.** $\beta = 0$: naive unbiased within 3 MCSE whatever the instruments.

## 4. Departures from DESIGN.md

Identity link only; cut-point misclassification and bridge-sample correction are not
run; the target's reported mean is its population value.
