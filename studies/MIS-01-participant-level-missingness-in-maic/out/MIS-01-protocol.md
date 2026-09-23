# Protocol: missing covariate values in the individual-data trial of a MAIC

**Target problem.** MIS-01. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

Complete-case MAIC matches the target on the records it keeps, so balance tables look
perfect whatever deletion did. DESIGN.md: the bias is an unmatched covariate's
outcome effect times the deletion-induced shift in it, and mechanism, not rate,
decides it. **Refuting sentence:** at realistic missingness rates complete-case
deletion shifts the matched population negligibly.

**Correction.** The within-trial contrast weights both arms identically, so a shift in
an unmatched covariate $u$ that is common to both arms cancels unless $u$ modifies the
effect; a shift confined to one arm does not cancel even when $u$ is purely
prognostic. So complete case is unbiased under MCAR, under missingness driven by
observed matched covariates, and **under missingness driven by the missing covariate
itself** (the conditional law of everything else given the matched covariates is
untouched); it is biased when missingness depends on a modifying $u$, on $u$ in one
arm only, or on the outcome. The probe matches every one of these, and shows the
MAR-based repairs biased in the MNAR case where complete case is not.

## 2. Design

Individual-data trial, 250 per arm; $x_1$ (matched, partly missing), $x_2$ (matched,
observed), $u$ (unmatched, observed in the trial, $u = 0.5x_1 + $ noise). Continuous
outcome $y = 0.5(x_1 + x_2 + u) + A(-0.4 + 0.3x_1 + \beta_u u) + e$; target means of
$x_1, x_2$ are 0.5 and $u$ follows $x_1$ in the target as in the source.

| factor | levels |
|---|---|
| missingness rate | 15%, 30%, 50% |
| mechanism | MCAR; on $x_2$; on $u$; on $u$ in arm A only; on $y$; on $x_1$ itself (MNAR) |
| $\beta_u$ | 0, 0.3 |

36 cells, **1000 replicates** (about 2.5 core-hours). Methods: complete case; Fang et
al. weighting (observation probability from $(x_2, u, y)$ interacted with arm,
multiplied into the matching weights); multiple imputation (5 imputations, normal
regression with parameter draws) with a congenial model (every predictor interacted
with arm) or a generic one (no arm terms), MAIC per imputation, Rubin's rules.

## 3. Decision

- **Mechanism claim confirmed** if complete-case bias is within 3 MCSE of zero in
  every cell predicted unbiased (MCAR, $x_2$, MNAR on $x_1$, and $u$ or $y$ with
  $\beta_u = 0$) and beyond 3 MCSE in every predicted-biased cell at 15% missingness.
  That also refutes the rate-based refuting sentence.
- **Repairs:** bias and coverage of the weighting and imputation arms under each
  mechanism; registered prediction that they are biased under MNAR on $x_1$.

**Control.** MCAR: every method unbiased within 3 MCSE.

## 4. Departures from DESIGN.md

Missing outcomes, overlap levels, STC and the MNAR pattern-mixture sensitivity arm are
not run; 5 imputations rather than more; continuous outcome only.
