# Protocol: interaction coefficients have their own consistency equation

**Target problem.** COV-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Treatment-by-covariate interactions satisfy a consistency equation of their own,
$\beta_{BC} = \beta_{AC} - \beta_{AB}$. A network can be consistent in effects and inconsistent
in interactions, and then direct and indirect paths can carry interactions that cancel in
the pooled meta-regression. The effect-consistency check compares effects, not
interactions, so it has no power against this. **Refuting sentence:** cancellation requires
opposing interactions of similar magnitude, a knife-edge configuration, so the demonstration
is a constructed curiosity.

**Correction from the probe.** DESIGN.md says averaging opposing precise estimates gives "a
precise estimate of nothing". The pooled interaction is zero on average, but its model-based
SE assumes consistent interactions; under inconsistency the estimate scatters across
analyses far more than that SE (0.17 against 0.05 in the probe), so a Wald test of the
interactions often rejects. The masking shows in the pooled coefficient's value, not in
selection.

## 2. Design

Triangle A, B, C with $M \in \{2, 4, 8\}$ studies per comparison, SE 0.1, covariate means
$N(0.5, \text{SD}^2)$ with SD 0.3 or 1. Effects $d_{AB} = -0.3$, $d_{AC} = -0.5$,
$d_{BC} = -0.2$ plus an effect-loop shift of 0 or 0.2. Path interaction slopes
$(a B, B, c B)$ for AB, AC, BC with $B = 0.3$: consistent $(a, c) = (0, 1)$; partly opposing
$(-0.5, -0.5)$, pooled $b_C = B/3$; cancelling $(-1, -1)$, pooled $b_B = b_C = 0$ in expectation
although every path carries modification of size $B$. 36 cells, **2000 replicates**.

Analyses: consistency meta-regression with $b_B, b_C$; modifier selected if the Wald test of
$b_B = b_C = 0$ has $p < 0.10$, otherwise the network without the covariate; interaction
consistency test (direct BC slope against $b_C - b_B$ from AB and AC); effect consistency
(Bucher) test at the mean covariate. Target: C versus A at covariate 1.5, truth from the AC
path.

## 3. Decision

- **Blindness confirmed** if the effect-consistency check flags at its null rate (at most
  0.10 plus Monte Carlo error) in every interaction-inconsistent cell without an effect loop.
- **Refuting sentence fails** if the partly opposing scenario (not the balance point) leaves
  target bias after selection beyond 3 MCSE and 0.1 in some cell.
- Power of the interaction-consistency check by studies per path and covariate spread.

**Controls.** Consistent interactions: selection and target estimate correct; interaction
check at its null rate.

## 4. Departures from DESIGN.md

Stylized triangle networks with continuous study estimates; frequentist fixed-effect
meta-regression; the design-by-treatment interaction model is not run; one network size.
