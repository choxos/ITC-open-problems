# Protocol: does the change-versus-endpoint choice interact with population adjustment?

**Target problem.** OUT-06. ADEMP reporting. Committed before the registered run.
Design rationale: [`DESIGN.md`](DESIGN.md). Probe output: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

DESIGN.md: when baseline modifies the treatment effect, change-score and endpoint
analyses carry different modification structures and diverge after reweighting to a
target with a different baseline distribution, in proportion to the product of the
interaction and the baseline shift.

Baseline $Y_0$ is measured before treatment, so for any target law
$E_T[Y_1(b) - Y_1(a)] = E_T[(Y_1 - Y_0)(b) - (Y_1 - Y_0)(a)]$: the two
representations have the same target estimand whatever the adjustment. A linear
outcome model with $Y_0$ as a covariate returns the same treatment and
treatment-by-$Y_0$ coefficients for $Y_1$ and for $Y_1 - Y_0$. MAIC that matches the
baseline mean makes the weighted baseline equal the target's exactly. So:

- adjusted estimators agree exactly on the individual-data side, and in an anchored
  comparison differ only by the aggregate trial's chance baseline imbalance, zero in
  expectation;
- an unadjusted unanchored comparison has endpoint bias $(b + \beta)s$ and change bias
  $(b + \beta - 1)s$ for baseline slope $b$, interaction $\beta$ and shift $s$: they
  differ by exactly $s$, **independent of $\beta$**.

The prediction is that the product structure does not exist.

## 2. Design

Individual-data trial A versus C with $Y_0 \sim N(0,1)$; aggregate trial B versus C
with $Y_0 \sim N(s,1)$ reporting arm means of $Y_1$ and of $Y_1 - Y_0$ and of $Y_0$.
$Y_1 = bY_0 + \delta_t + \beta Y_0\mathbb 1[t = A] + e$, $e \sim N(0, 1-b^2)$,
$\delta_A = -0.4$, $\delta_B = -0.2$, 300 per arm. Factors: anchored or unanchored;
$s \in \{0, 0.5, 1\}$; $\beta \in \{0, 0.3\}$; $b \in \{0.4, 0.8\}$ (the control-arm
baseline to follow-up correlation). 24 cells, **1000 replicates** (0.4 core-hours).
Estimand $E_T[Y_1(B) - Y_1(A)] = \delta_B - \delta_A - \beta s$.

Methods, each in both representations: naive (no adjustment), MAIC matching the
baseline mean, G-computation with a linear model in $Y_0$ (and treatment, anchored).

## 3. Outcomes and decision

Bias with MCSE per method and representation; the per-replicate representation
difference (endpoint minus change estimate) with MCSE.

- **DESIGN.md's claim refuted** if the representation difference is within 3 MCSE of
  zero for MAIC and G-computation in every cell, including $\beta = 0.3$, $s = 1$; and
  if across naive unanchored cells a regression of the difference on $s$ and
  $\beta s$ gives a slope on $s$ within 3 SE of 1 and a coefficient on $\beta s$
  within 3 SE of 0.
- **Confirmed** if an adjusted method's difference exceeds 3 MCSE and grows with
  $\beta s$.

**Controls.** Null: $s = 0$, every method unbiased within 3 MCSE. Positive: naive
unanchored at $s = 1$, both representations biased beyond 3 MCSE with the predicted
values.

## 4. Departures from DESIGN.md

The joint baseline-and-follow-up model and the responder-probability estimand are not
run: the first is the G-computation arm here, and the second is a different estimand
for the two representations by definition (a threshold on change is not a threshold
on follow-up). Overlap and baseline prognostic strength are not separate factors:
$b$ is the prognostic strength. $n_{sim} = 1000$.
