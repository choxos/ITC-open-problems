# Protocol: the half-standard-error rule for pooling within- and across-trial interactions

**Target problem.** MOD-15. Committed before the registered computation. Design:
[`DESIGN.md`](DESIGN.md). Individual-level check: [`results/check.md`](results/check.md).

## 1. Claim and correction

The published criterion pools within-trial and across-trial interaction information
when $\lvert\hat\beta_W - \hat\beta_A\rvert < \tfrac12 s_A$. Under equality the
difference has SD $\sqrt{s_W^2 + s_A^2}$, so the rule's pass probability is
$P(\lvert Z\rvert < 0.5\,s_A/\sqrt{s_W^2+s_A^2}) \le P(\lvert Z\rvert < 0.5) = 0.383$.
**It refuses valid pooling at least 61.7% of the time in every regime.** DESIGN.md
said the rule is "not necessarily strict" and loosest with few trials; it is strict
in every regime, least strict when $s_A \gg s_W$. **Refuting sentence:** the rule's
operating characteristics are adequate at realistic network sizes.

## 2. Computation

$\hat\beta_W \sim N(\beta, s_W^2)$ and $\hat\beta_A \sim N(\beta + \delta, s_A^2)$ are
independent, so pass probability, and the bias, RMSE and coverage of the estimate each
policy reports (pooled on a pass, within-trial on a failure), including coverage of
the pooled interval conditional on a pass, are bivariate normal integrals. They are
computed exactly (`R/00-model.R`, `R/02-compute.R`). $s_W$ and $s_A$ come from a
network of $K$ trials of 200 (1:1) with trial covariate means spread with SD `disp`,
within-trial covariate SD 1, residual SD 1; `R/01-check.R` verifies the formulas and
the exact pass and conditional-coverage values against 2000 individual-level networks
in four configurations.

| factor | levels |
|---|---|
| trials $K$ | 5, 10, 20 |
| dispersion of trial means | 0.25, 0.75 |
| ecological bias $\delta$ | 0, 0.1, 0.2, 0.4 |

Policies: never pool; always pool; the half-$s_A$ rule; a size-5% test on the
difference ($\lvert D\rvert < 1.96\sqrt{s_W^2+s_A^2}$); a size-20% test ($1.28$).

## 3. Decision

- **Refuting sentence fails** if the half-$s_A$ rule's pass probability at
  $\delta = 0$ is below 0.5 in every configuration, or if its conditional coverage
  given a pass is below 0.90 at any $\delta \le 0.2$.
- **Recommendation:** the policy with the lowest RMSE across $\delta \in \{0, 0.1, 0.2\}$
  in the most configurations, reported with its worst coverage.

No Monte Carlo error applies to the registered computation; the check reports its
own.

## 4. Departures from DESIGN.md

Computed exactly rather than simulated, with an individual-level check. The target
effect is represented by the interaction, since the transported effect's error is the
interaction's error times the target shift plus independent error in the reference
effect. Overlap is not a factor, and the ML-NMR arm is not run.
