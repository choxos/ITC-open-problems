# Protocol: pooled versus arm-separate matching in anchored MAIC

**Target problem.** MOD-16. ADEMP reporting. Committed before any replicate of the
registered grid. Design rationale: [`DESIGN.md`](DESIGN.md). Probe output:
[`results/probes.md`](results/probes.md).

## 1. Claim

DESIGN.md: arm-separate matching (each individual-data arm weighted to the
corresponding aggregate arm) can introduce confounding through unmatched
covariates, with bias equal to the product of their prognostic strength and the
aggregate trial's arm imbalance; pooled matching (one weight function for both
arms) preserves randomization. **Refuting sentence:** arm-separate matching is
uniformly better, as its introducing paper found.

## 2. Mechanism, corrected

Continuous outcome $y = \alpha + \gamma_X x + \gamma_U u + \delta_t + \beta x\,\mathbb 1[t \ne C] + e$,
matched covariate $X$ reported by arm, unmatched prognostic $U$ not reported.
Condition on an aggregate-trial imbalance $\kappa = \bar x_B - \bar x_C$, with $U$
following $X$ through the target correlation $\rho_T$; the source correlation is
$\rho_S$. Then

$$\text{bias}_{\text{pooled}} = \kappa\,(\beta/2 + \gamma_X + \gamma_U\rho_T),\qquad
\text{bias}_{\text{arm-separate}} = \kappa\,\gamma_U\,(\rho_T - \rho_S).$$

Pooled matching preserves randomization in the individual-data trial but cannot
remove the aggregate trial's own imbalance, which enters the anchored contrast
whole. Arm-separate matching reproduces that imbalance in the individual-data
contrast, so it cancels on the matched covariate and on everything correlated with
it the same way in both trials. **The design's product is incomplete**: arm-separate
bias needs an unmatched prognostic covariate *and* a correlation with the matched
covariate that differs between trials; with a shared structure it is zero at any
imbalance. Averaged over randomization ($\kappa$ random) both are unbiased and the
question is variance. The probes confirm both formulas to within 1 MCSE in four
cells.

## 3. Data-generating mechanism

Source: A versus C, 300 per arm, $(X, U)$ standard bivariate normal with correlation
$\rho_S$. Target: B versus C, 300 per arm, means $(0.5, 0.5)$, correlation $\rho_T$;
the B arm's $X$ mean is set exactly to $0.5 + \kappa$ and the C arm's to $0.5$, with
$U$ drawn given $X$. $\gamma_X = 0.5$, $\delta_A = -0.4$, $\delta_B = -0.2$,
residual SD 1.

| factor | levels |
|---|---|
| imbalance $\kappa$ | 0, 0.1, 0.2 SD imposed; random (no imposition) |
| $\gamma_U$ | 0, 0.25, 0.5 |
| $(\rho_S, \rho_T)$ | (0, 0), (0.5, 0.5), (0.5, 0), (0, 0.5) |
| modification $\beta$ (shared by A and B) | 0, 0.3 |

96 cells, **1000 replicates** each (1.7 core-hours). $\kappa = 0.2$ is 2.4 standard
errors of a 300-per-arm mean difference: a large but real chance imbalance.

**Estimand:** mean difference B versus A in the target population,
$\delta_B - \delta_A = 0.2$ under shared modification.

## 4. Methods

Unadjusted Bucher; pooled MAIC (one weight vector to the pooled aggregate mean of
$X$); arm-separate MAIC (A to the B arm mean, C to the C arm mean); two-stage MAIC
(within-trial inverse propensity weights times pooled weights). Sandwich variances
with weights treated as fixed. Per-arm ESS and the weighted difference in $U$
between arms, which is DESIGN.md's candidate diagnostic.

## 5. Outcomes, controls, decision

Bias, empirical SE, coverage, RMSE with MCSE; common random numbers.

**Mechanism checks.** Across imposed-imbalance cells, regress each of pooled and
arm-separate cell bias on its section 2 prediction; slope 1 expected.

**Controls.** *Null:* $\kappa = 0$ imposed: pooled and arm-separate unbiased within 3
MCSE. *Second null:* $\gamma_U = 0$: arm-separate unbiased within 3 MCSE at every
$\kappa$. *Positive:* $\kappa = 0.2$, $\gamma_U = 0.5$, mismatched correlation:
arm-separate bias beyond 3 MCSE with the predicted sign.

**Decision.**

- **Design's product claim refuted** if in every shared-correlation cell with
  $\gamma_U > 0$ and $\kappa > 0$ the arm-separate bias is within 3 MCSE of zero.
- **Confirmed as stated** if arm-separate bias beyond 3 MCSE appears in those cells.
- Separately, **which method to prefer**: in the random-$\kappa$ cells the RMSE ratio
  (arm-separate over pooled) with its MCSE; in imposed cells, the share of cells where
  $\lvert\text{bias}\rvert$ is smaller for arm-separate.
- **Diagnostic:** correlation across imposed cells between the mean weighted $U$
  difference and the arm-separate bias. Section 2 predicts the diagnostic reads
  $\rho_S\kappa$, which is unrelated to the bias $\gamma_U\kappa(\rho_T - \rho_S)$.

## 6. Departures from DESIGN.md

1. Mechanism corrected (section 2).
2. Continuous outcome only; the non-collapsible case is not run.
3. The "pooled plus prognostic adjustment" arm is dropped: $U$ is unreported in the
   aggregate trial, so no individual-data adjustment can remove its imbalance there.
4. Number of unmatched covariates and overlap levels are not factors; one of each.
5. $n_{sim} = 1000$.
