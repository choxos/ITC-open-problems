# Design for adversarial critique: the power and calibration of the split-interaction check

**Status: not yet run. Nothing below has been executed. Attack it.**

## The object under study

Population adjustment across a network usually assumes *shared effect modification*: a
covariate modifies the effect of every active treatment in a class in the same way. Phillippo
et al. (2023, doi:10.1177/0272989X221117162) published the only within-network empirical check
on this assumption and implemented it in `multinma`. The procedure is:

1. Fit ML-NMR with `class_interactions = "common"` (one interaction per covariate, shared by
   all treatments in the class).
2. Refit with `class_interactions = "independent"` **for one covariate at a time**, giving
   treatment-specific interactions for that covariate.
3. Compare the posteriors of the treatment-specific interactions, and compare model fit by DIC.

Their own words: "It is likely that this approach to assessing the shared effect modifier
assumption has low power, particularly when data are lacking." Nobody has measured it. There
is no threshold, no stability metric, and no statement of what a pass licenses.

This study measures it.

## What we already found before designing anything

`multinma` 0.9.1.9002 documents `class_interactions = c("common", "exchangeable",
"independent")`. Calling it with `"exchangeable"` raises **"Exchangeable treatment class
interactions (class_interactions = "exchangeable") not yet supported"**. Our own catalog entry
for IDN-05 states that the hierarchical relaxation "ships in multinma"; that is wrong for this
version and will be corrected. Only `common` and `independent` are fittable, so the check is a
binary comparison and the hierarchical middle ground is unavailable.

Also: with `chains = 1`, `nma()` fails to initialize the Stan sampler
(`nint_vec` dimension mismatch, raised during integration-convergence checking) and returns an
object that *looks like* a fit; `dic()` then errors. We use `chains = 2` throughout and check
every fit for draws before using it.

## Data-generating mechanism

Individual-level model, binomial outcome, logit link, for individual $i$ in study $j$ on
treatment $k$:

$$\mathrm{logit}\,p_{ijk} = \mu_j + \boldsymbol{\beta}'x_{ijk} + \mathbb{1}\{k \neq \text{PBO}\}\left(d_k + \boldsymbol{\gamma}_k' x_{ijk}\right)$$

- 3 covariates, $x \sim N(\delta_j, \Sigma)$ within study $j$, $\Sigma$ with unit variances and
  exchangeable correlation 0.25.
- Prognostic effects $\boldsymbol{\beta} = (0.40, 0.40, 0.40)$; study intercepts
  $\mu_j \sim N(-0.85, 0.15^2)$ so placebo response is near 0.30.
- Treatments: reference PBO, and three active treatments A, B, C **in one class**, which is
  what makes the shared-interaction restriction bind.
- Main effects $d_A = d_B = d_C = 0.70$.
- **Effect-modifier drift** is carried by $x_1$ only:
  $\gamma_A[x_1] = \gamma_0 + \Delta$, $\gamma_B[x_1] = \gamma_0$, $\gamma_C[x_1] = \gamma_0 - \Delta$,
  with $\gamma_0 = 0.30$.
  $x_2$ and $x_3$ are **truly shared**: $\gamma_k[x_2] = \gamma_k[x_3] = 0.30$ for all $k$.
  So every replicate supplies one power observation ($x_1$, when $\Delta > 0$) and two type I
  error observations ($x_2$, $x_3$) from the same fits.

## Network

- $J$ studies, all two-arm and placebo-anchored.
- $n_{\text{IPD}} \in \{1, 2\}$ studies contribute individual data; the rest contribute
  arm-level summaries (mean and SD of each covariate, events, sample size).
- **The IPD studies always compare PBO with A.** So A is the treatment for which
  treatment-specific interactions are estimable within a study; B and C appear only in
  aggregate studies and their interactions are identified only through between-study contrasts
  of covariate means, which is the ecological route.
- Aggregate studies rotate over A, B, C.
- Study covariate means $\delta_j \sim N(0, \tau^2 I)$ with $\tau$ the **covariate spread**
  factor. $\tau$ is what carries ecological information about interactions.
- 400 patients per arm in IPD studies, 250 per arm in aggregate studies.

## Design factors (fitting cells)

| Factor | Levels |
|---|---|
| `drift` $\Delta$ | 0, 0.15, 0.30, 0.60 |
| `n_ipd` | 1, 2 |
| `n_studies` $J$ | 6, 12 |
| `spread` $\tau$ | 0.25 (low), 0.60 (high) |

$4 \times 2 \times 2 \times 2 = 32$ cells, 300 replicates each.

**The target population is not a fitting factor.** The check reads only the fitted network; its
output cannot depend on the population an analyst later transports to. So one set of fits is
scored at every target displacement, and that is itself the mechanism this study is built
around. Target covariate mean $\delta_T = (s, 0, 0)$ with $s \in \{0, 0.5, 1.0, 1.5\}$ standard
deviations along the drifting covariate.

## Models fitted per replicate

Five fits, the complete lattice of the published procedure with $K = 3$:

1. `common` — the restriction.
2. `split-x1`, 3. `split-x2`, 4. `split-x3` — independent interactions for one covariate at a
   time, which is the published check.
5. `split-all` — independent interactions for every covariate, the full relaxation an analyst
   would use if they abandoned the restriction.

$32 \times 300 \times 5 = 48{,}000$ ML-NMR fits, 2 chains, 1000 iterations, 64 integration
points. Measured cost 2.5 s per fit; about 5 hours on 7 workers.

## Estimands

1. **Mechanism scale.** Population-average relative effect in the target,
   $\theta_k(T) = d_k + \boldsymbol{\gamma}_k' \delta_T$, on the log-odds scale, via
   `relative_effects(fit, newdata = target)`. Linear in $x$, so the truth is exact and the bias
   from imposing sharing is exactly $(\hat{\gamma} - \gamma_k)'\delta_T$.
2. **Decision scale.** Marginal risk difference in the target population, via
   `predict(fit, newdata = target, type = "response", level = "aggregate")` with the *true*
   target baseline supplied. Truth by exact numerical integration of the true model over the
   target covariate distribution. Supplying the true baseline is a deliberate simplification
   that favors the check.
3. **The decision contrast** is C versus A: an aggregate-only treatment against the IPD
   treatment, which is the situation population adjustment exists for.

## Operational readings of the check

There is no agreed threshold, so we report all of them.

- **DIC rule.** Flag covariate $k$ if $\mathrm{DIC}(\text{split-}x_k) < \mathrm{DIC}(\text{common}) - c$,
  for $c \in \{2, 5, 10\}$.
- **Posterior rule.** Flag if the 95% credible interval for the largest pairwise difference
  among $\{\gamma_A[x_k], \gamma_B[x_k], \gamma_C[x_k]\}$ excludes zero.
- **Continuous score.** $\Delta\mathrm{DIC}$ and the posterior probability of a nonzero
  difference, both scored as classifiers by AUROC against realized error, so the study reports
  a curve rather than pretending a cutoff exists.

## Prespecified primary outcome and verdict rule

**Material error**: the estimated marginal risk difference for C versus A in the target differs
from the truth by more than 0.03 absolute risk.

**The check is fit for the reassurance it is read as giving** if and only if, in every design
stratum and at every target displacement, the DIC rule at $c = 5$ reaches sensitivity $\geq
0.80$ for material error at specificity $\geq 0.50$. We expect this to fail. Registering it
means the failure is a measurement, not a narrative.

## Prespecified mechanism claims, with thresholds that permit failure

- **M1, decoupling.** The check's power is invariant to target displacement (max power
  difference across $s \in \{0, 0.5, 1.0, 1.5\}$ below 0.02, since the fits are identical),
  while the false reassurance rate $P(\text{check passes} \cap \text{material error})$ rises by
  at least 0.20 from $s = 0$ to $s = 1.5$. This is close to a theorem; the run checks the
  implementation and quantifies the size.
- **M2, IPD asymmetry.** At $\Delta = 0.30$, power to detect drift is at least 0.15 lower when
  the contrast involves the aggregate-only treatment C than when it involves the IPD treatment
  A.
- **M3, multiplicity.** Family-wise type I error over the three covariates exceeds the
  per-covariate rate by at least 0.03.
- **M4, disagreement.** The DIC rule and the posterior rule disagree in at least 10% of
  replicates, so "compare posteriors and model fit" is not one procedure.

## Strategy comparison

Three strategies an analyst could follow, scored on the target estimand under a declared
deployment distribution over cells: **always common**, **always independent** (`split-all`),
and **check then relax** (use `split-all` if the DIC rule flags any covariate, else `common`).
Reported as RMSE, decision reversal rate, and net benefit across action thresholds.

## Calibration

Does "the check passed" mean the same thing in a setting the analyst has not seen? Fit a
one-term logistic mapping from the check statistic to $P(\text{material error})$ in all cells
but one level of one factor, evaluate absolute risk error in the held-out level.
Leave-one-factor-level-out over all four factors.

## Known limitations, stated before the run

Covariates are normal with known target moments; outcomes are binomial with a logit link;
studies are two-arm and placebo-anchored; conditional constancy holds; only $x_1$ drifts and it
drifts linearly; there is no random-effects heterogeneity in the treatment effects; the target
baseline risk is supplied rather than estimated; `exchangeable` interactions cannot be fitted
in this version so the hierarchical middle ground is absent.

---

## What we want from you

Find the errors. In particular:

1. **Is any quantity above arithmetically wrong?** Check that $\Delta = 0.15$ on the log-odds
   scale actually produces a material (0.03 absolute risk) error at $s = 1.0$, and that the
   drift levels span the interesting range rather than all being detectable or all being
   invisible. Compute it.
2. **Is the drift parameterization confounded with anything?** $\gamma_C = \gamma_0 - \Delta$
   changes both the spread among treatments and treatment C's own modifier strength. Does that
   contaminate the C-versus-A contrast?
3. **Is the estimand right?** Is `relative_effects(newdata =)` in `multinma` the
   population-average effect we claim it is for a logit-link ML-NMR, or something else?
4. **Is the network identified?** With one IPD study on PBO/A and aggregate studies on B and C,
   are treatment-specific interactions for B and C estimable at all, or is `split-x1` fitting a
   prior?
5. **Are the design cells enumerated in an order that confounds a later split?** Study 4 of this
   program had exactly this defect.
6. **Is anything about the verdict rule rigged** so that it must fail regardless of the truth?
7. **What is the most important thing this design leaves out?**

Answer from your own knowledge. Be specific, quantitative where possible, and rank findings by
severity. We will verify each numerically before accepting it.
