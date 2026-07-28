# Protocol: what the split-interaction check on shared effect modification is worth

**Problem:** IDN-05, *The shared effect modifier check has low and uncalibrated power*
**Registered:** 27 July 2026, before any replicate of the reported design was run
**Reporting:** ADEMP (Morris, White & Crowther 2019, doi:10.1002/sim.8086)

---

## 1. Aims

Population adjustment across a network usually assumes **shared effect modification**: that a
covariate modifies the effect of every active treatment in a class in the same way. Phillippo
et al. (2023, doi:10.1177/0272989X221117162) published the only within-network empirical check
on that assumption and implemented it in `multinma`. The procedure is: fit the model with a
single interaction shared across the class; refit with treatment-specific interactions **one
covariate at a time**; compare the posteriors of the treatment-specific interactions and
compare model fit by DIC.

Their own statement is that "it is likely that this approach to assessing the shared effect
modifier assumption has low power, particularly when data are lacking." Nobody has measured
it. There is no threshold, no stability metric, and no statement of what a pass licenses.

This study measures four things.

**A1.** What a pass licenses: the probability that a transported estimate is materially wrong
given that the check did not fire.

**A2.** The check's power and type I error against the hypothesis it is designed to test, the
treatment-specific interaction violation, across network size, ecological information,
treatment-effect heterogeneity and drift magnitude.

**A3.** Whether the check's verdict transports: does a threshold calibrated in one setting
carry the same meaning in another it has not seen?

**A4.** What an analyst should do instead: three strategies scored on the target estimand.

## 2. Data-generating mechanism

Individual $i$ in study $j$ on treatment $k$, binomial outcome, logit link:

$$\mathrm{logit}\, p_{ijk} = \mu_j + \boldsymbol\beta' x_{ijk} + \mathbb{1}\{k \neq \text{PBO}\}\left(d_k + \delta_{jk} + \boldsymbol\gamma_k' x_{ijk}\right)$$

- **Covariates.** $K = 2$. Within study $j$, $x \sim N(\boldsymbol\delta_j, \Sigma)$ with unit
  variances and correlation $\rho = 0.25$. Study covariate means
  $\boldsymbol\delta_j \sim N(0, \tau_x^2 I)$ where $\tau_x$ is the **spread** factor.
- **Prognostic effects.** $\boldsymbol\beta = (0.40, 0.40)$.
- **Treatments.** Reference PBO, and two active treatments **A** and **C** in one class, which
  is what makes the shared-interaction restriction bind. $d_A = d_C = 0.70$.
- **Effect-modifier drift** is carried by $x_1$ only, and the parameter **is the contrast**:
  $$\gamma_A[x_1] = 0.30 + \tfrac{\text{drift}}{2}, \qquad \gamma_C[x_1] = 0.30 - \tfrac{\text{drift}}{2}, \qquad \gamma_A[x_1] - \gamma_C[x_1] = \text{drift}.$$
  $x_2$ is shared exactly: $\gamma_A[x_2] = \gamma_C[x_2] = 0.30$. Every replicate therefore
  supplies a power observation on $x_1$ and a type I error observation on $x_2$ from the same
  four fits.
- **Treatment-effect heterogeneity.** $\delta_{jk} \sim N(0, \tau_{\mathrm{re}}^2)$,
  independent across studies and treatments.
- **Study intercepts.** $\mu_j \sim N(\mu_0, 0.15^2)$ with $\mu_0$ set so the marginal placebo
  risk at the network centre is exactly 0.30.

### Network

Two-arm, placebo-anchored studies. **One** study contributes individual data and always
compares PBO with A; the rest contribute arm-level summaries (covariate means and SDs, events,
sample size). So A is the treatment whose interaction is estimable within a study, and C
appears only in aggregate studies, where its interaction is identified through between-study
contrasts of covariate means and through the curvature of the aggregate likelihood. That
asymmetry is the situation population adjustment exists for.

Aggregate studies alternate starting with C, so the aggregate-only treatment never has fewer
studies than the other:

| $J$ | aggregate studies | A, including IPD | C |
|---|---|---|---|
| 6 | 5 | 3 | 3 |
| 12 | 11 | 6 | 6 |

250 patients per arm in the individual-level study, 200 per arm in aggregate studies.

`multinma` reconstructs the joint covariate distribution for aggregate studies from a copula
using a correlation matrix estimated from the individual-level studies. The distance between
that estimate and the truth is reported per cell.

### Design factors

| Factor | Levels |
|---|---|
| `drift`, $\gamma_A[x_1] - \gamma_C[x_1]$ | 0, 0.30, 0.60, 1.20; **0.15 added by amendment, see 10** |
| `n_studies` $J$ | 6, 12 |
| `spread` $\tau_x$ | 0.25, 0.60 |
| `tau_re` | 0, 0.15 |

$4 \times 2 \times 2 \times 2 = 32$ cells, **50 replicates each**, plus the eight amendment
cells of section 10. Fifty rather than the 200 first written down: the estimator is a Bayesian
ML-NMR fitted four times per replicate, and measured throughput on this machine is 21 seconds
per replicate on three usable cores, so the registered design costs about four hours. Precision
follows the level at which each quantity is reported. The primary quantity pools all 32 cells
at one displacement, about 1,500 observations, Monte Carlo standard error near 0.011. Type I
error pools the 8 null cells over both covariates, 800 observations, standard error 0.008.
(The figure first written here was 720, which assumed the original eligibility rule would drop
about a tenth of replicates. That rule was amended before the run, as recorded below, so no
replicate is dropped and the count is $8 \times 50 \times 2 = 800$. Two reviewers found the
stale figure; it is corrected rather than left as registered, because it was arithmetic and not
a design choice.)
Power is reported by stratum, four cells pooled, standard error 0.032. Per cell it is 0.065,
which is why no per-cell difference below about 0.13 is claimed and why nothing here is read
off a single cell.

Cells are enumerated with `drift` varying fastest. Every held-out fold in the calibration
analysis is defined by a **factor level**, never by a cell index, and all four target
displacements from one simulated dataset carry the same dataset identity and stay in the same
fold. Study 4 of this program published a calibration analysis confounded by exactly this.

### Target populations

The check reads only the fitted network, so its output cannot depend on the population an
analyst later transports to. One set of fits is therefore scored at every displacement, and
that invariance is the mechanism under test. Target covariate mean $(s, 0)$ for
$s \in \{0, 0.5, 1.0, 1.5\}$ standard deviations along the drifting covariate.

Because $x_1$ is prognostic, displacing the target would also slide the placebo risk along the
logistic curve, from 0.30 to 0.42, and risk differences at different displacements would be
compared at different points on that curve. The reference intercept is therefore **solved
separately for each displacement** to hold the marginal placebo risk at 0.30 exactly, so
displacement moves the treatment contrast and nothing else.

## 3. Estimands

**Decision scale, primary.** The marginal risk difference for C versus A in the target
population, obtained by integrating the fitted individual-level model over the target covariate
distribution. The true marginal reference risk is supplied to the estimator, so no
baseline-risk estimation error enters; this is a simplification in the check's favour.

**Mechanism scale.** The population-average **conditional** log-odds effect,
$d_k + \boldsymbol\gamma_k'\boldsymbol\delta_T$: the mean over the target of individual
conditional log-odds ratios. It is not the marginal log-odds ratio and is not reported as one.
Under the shared-interaction restriction the C-versus-A value of this quantity is exactly
$\hat d_C - \hat d_A$, independent of the target, so the truth moves with displacement and the
estimate does not.

**The contrast** is C versus A: an aggregate-only treatment against the treatment with
individual data.

Truth is computed exactly by Gauss-Hermite quadrature of the true model, not by simulation.

| drift | $s$ | true marginal RD, C − A | material at 0.03 |
|---|---|---|---|
| 0 | any | 0.0000 | no |
| 0.30 | 0.0 / 0.5 / 1.0 / 1.5 | −0.0032 / −0.0310 / −0.0587 / −0.0858 | no / yes / yes / yes |
| 0.60 | 0.0 / 0.5 / 1.0 / 1.5 | −0.0063 / −0.0617 / −0.1168 / −0.1704 | no / yes / yes / yes |
| 1.20 | 0.0 / 0.5 / 1.0 / 1.5 | −0.0117 / −0.1210 / −0.2282 / −0.3302 | no / yes / yes / yes |

Nine of sixteen combinations carry systematic material error. Displacement 0 never does, which
makes it the corner where the restriction costs nothing and is reported as such.

## 4. Methods compared

The **complete model lattice** for two covariates, four fits per replicate:

| Fit | Regression formula |
|---|---|
| `common` | `~ x1 + x2 + (x1 + x2):.trtclass` |
| `split_x1` | `~ x1 + x2 + (x1):.trt + (x2):.trtclass` |
| `split_x2` | `~ x1 + x2 + (x2):.trt + (x1):.trtclass` |
| `split_all` | `~ x1 + x2 + (x1 + x2):.trt` |

All with `class_interactions = "independent"`, fixed treatment effects, 64 integration points,
2 chains, 1000 iterations with 500 warmup, `normal(0, 2.5)` on regression coefficients,
`normal(0, 10)` on the intercept and treatment effects.

`class_interactions = "independent"` is not optional. Under the default `"common"`, an
`x:.trt` term in the formula is silently demoted to the class level: the "split" fit is the
shared fit under another name, with the same parameter names and a DIC that differs only by
Monte Carlo error. Every split fit asserts that treatment-specific coefficients exist before
any statistic is computed from it.

**Fit eligibility, as registered and as amended.** The registered rule was that a fit is used
only if $\hat R \leq 1.05$ and bulk ESS $\geq 100$ on all treatment effects and regression
coefficients with zero divergent transitions, and that a replicate in which any of the four fits
fails is excluded and counted.

**That rule was amended before the reported run, and the amendment is a departure from
registration.** The first cell showed it excludes selectively: all six exclusions were
diagnostic failures, five of them involved a split model, and the shared-interaction model never
failed once. Excluding on that criterion removes exactly the replicates in which the relaxed
model is weakly identified, which is the phenomenon under study, and leaves a sample enriched
for the cases where relaxing happened to go well. The amended rule records the diagnostics per
fit and excludes only a fit that produced no draws at all. How often each model fails to
converge is reported as a result, and every primary comparison is repeated on the subset where
all four fits met the original criteria.

Returning an object is not a criterion in either version: `multinma` returns one when Stan never
started.

### Strategies

- **always_common** — impose the restriction.
- **always_relaxed** — fit `split_all` regardless.
- **check_then_relax** — relax exactly the covariates the check flagged, which the complete
  lattice makes available.

## 5. Readings of the check

There is no agreed threshold in the literature, so every reading in use is reported rather
than one being chosen. With two active treatments there is exactly **one** interaction
contrast per covariate, $\gamma_A[x] - \gamma_C[x]$, so nothing is selected and the credible
interval keeps its nominal coverage.

- **DIC rule.** Flag covariate $x$ if $\mathrm{DIC}(\text{split}_x) < \mathrm{DIC}(\text{common}) - c$
  for $c \in \{2, 5, 10\}$; $c = 5$ is the rule the verdict uses.
- **Posterior rule.** Flag if the 95% credible interval for $\gamma_A[x] - \gamma_C[x]$
  excludes zero.
- **Margin rule.** $P(|\gamma_A[x] - \gamma_C[x]| > \varepsilon)$ with
  $\varepsilon = 0.1531$, the interaction contrast that makes the C-versus-A marginal risk
  difference exactly material at displacement 1. The margin is set by consequence, not taste.
- **Continuous scores.** $\Delta\mathrm{DIC}$ and the directional posterior probability
  $\max\{P(z>0), P(z<0)\}$, scored as classifiers by AUROC. Not $P(z \neq 0)$, which is
  exactly one under a continuous posterior.

  **Note added 28 July 2026.** These AUROCs were computed from the first run onward but were
  omitted from the first two drafts of the manuscript, which is an undisclosed deviation from
  this section. All three round-two reviewers asked for them. They are now reported in full,
  with Hanley and McNeil intervals, both against material error and against the presence of a
  violation.
- **Prior-posterior contraction**, $1 - \mathrm{sd}(\text{posterior})/\mathrm{sd}(\text{prior})$,
  for each treatment's interaction, so a fit that reported the prior can be told apart from
  one that reported the data.

## 6. Performance measures and the prespecified verdict

### Primary

$$P(\text{the transported estimate is materially wrong} \mid \text{the check did not fire})$$

**The check earns the reassurance it is read as giving if the upper 95% confidence bound on
this probability, pooled over the deployment distribution at displacement 1.0, is below 0.10.**

This is the quantity a committee relies on when it reads a pass. An earlier version of this
protocol used the joint probability $P(\text{pass} \cap \text{material error})$, which moves
with the prevalence of error rather than with the check's information, and required a
sensitivity threshold in every one of 128 stratum-by-displacement combinations, which no
finite simulation can pass even when the truth sits exactly on the threshold. Both were
corrected before the run.

### Secondary

- Power and type I error of each rule, per stratum, with Monte Carlo intervals, not
  thresholded. Nominal type I error is estimated **only under the global null** (drift 0):
  with correlated covariates, a treatment-specific $x_2$ term can absorb $x_1$
  misspecification, so the drift-present case is reported separately as misattribution.
- Prior-posterior contraction by treatment, cell and covariate.
- Bias, RMSE and decision reversal for the three strategies on the target estimand, within
  strata and under deployment weights.
- Net benefit across action thresholds 0.05 to 0.60, where the action is to distrust the
  adjusted estimate and commission individual data.
- Calibration: a one-term logistic mapping from the check statistic to $P(\text{material
  error})$, fitted with one level of one factor held out, evaluated by absolute risk error in
  the held-out level, leave-one-factor-level-out over all four factors. Primary calibration is
  deliberately **target-blind**, because the check is target-blind and that is the finding; a
  mapping that additionally knows the displacement is reported alongside to show what the
  check would need to know.

### Monte Carlo error

50 replicates per cell. A proportion near 0.5 has standard error 0.071 per cell, 0.035 by
stratum, and 0.011 for the pooled primary quantity. Type I error pools the 8 null cells over
both covariates, 800 observations, standard error 0.008 (see section 3: the 720 first written
here assumed an eligibility rule that was amended away before the run). Differences below about
0.13 within a single cell are not resolvable and are not claimed.

## 7. Prespecified mechanism claims

Each carries a threshold that permits failure. Claims that fail will be reported as failures.

- **M1, decoupling.** The check's output is **identical** at every target displacement. This is
  a bookkeeping identity, not an empirical claim: the observed difference must be exactly zero
  and any departure is a coding error. Meanwhile $P(\text{material error} \mid \text{passed})$
  rises by at least 0.20 from displacement 0 to displacement 1.5.
- **M2, identification asymmetry.** Prior-posterior contraction for the aggregate-only
  treatment's interaction is at least 0.20 lower than for the treatment with individual data,
  and the gap widens as the network shrinks.
- **M3, rules disagree on the null.** Under the global null, the DIC rule at cut 5 and the 95%
  posterior rule have type I error differing by at least 0.05.
- **M4, disagreement.** The DIC rule and the posterior rule disagree in at least 10% of
  replicates, so "compare posteriors and model fit" is not one procedure.

## 8. Additional checks

- **Prior sensitivity.** The eight thinnest cells ($J = 6$, spread 0.25) are refitted with
  `normal(0, 1)` on the regression coefficients, 100 replicates each. Where contraction is
  low, the check is reporting the prior, and the size of that dependence is measured rather
  than assumed.

  **Departure, recorded 28 July 2026 after round-two review.** This arm ran at **30 replicates
  per cell, not 100**: eight cells, 240 replicates, 960 fits, against the 800 replicates and
  3,200 fits registered here. The shortfall was not deliberate and was not disclosed in the
  first two drafts of the manuscript. It was found when a reviewer observed that the published
  fit count could not be produced from this section's design and asked for the derivation;
  counting the stored cell files established the true size. The eight cells are the ones
  registered, nothing was re-selected after results were seen, and no registered claim rests on
  this arm. Its per-cell rates carry a Monte Carlo standard error near 0.09 rather than the
  0.05 the registered size implies, so the arm is reported as directional.

  **Correction to how this arm was analyzed, same date.** Contraction was computed by dividing
  by the standard deviation of the *main* design's prior, 2.5, in every arm, including this one,
  which is fitted under `normal(0, 1)`. The published figures were therefore measured against a
  prior that was not used, and the direction of the reported effect was inverted: contraction
  cannot rise when a prior tightens. A reviewer derived the error from the published numbers
  alone. `R/02-fit.R` now takes the prior as an argument and records it; `R/05-analyze.R`
  recomputes the affected quantities exactly from the stored posterior standard deviations, so
  no refit was needed.
- **Integration sensitivity.** A subset is refitted with a larger number of integration points
  and the DIC difference compared.
- **Correlation recovery.** The distance between `multinma`'s estimated covariate correlation
  matrix and the truth, per cell.

## 9. Limitations, stated before the run

Covariates are normal with known target moments. Outcomes are binomial with a logit link.
Studies are two-arm and placebo-anchored. Conditional constancy holds. Only $x_1$ drifts, and
it drifts linearly. There are two active treatments in one class and two covariates; a real
network has more of both, and multiplicity over covariates is therefore not measured here. The
target baseline risk is supplied rather than estimated. Treatment effects are fixed within the
model even when the truth has heterogeneity, which is itself a specification error the check
was not designed to detect and whose interference is part of what is measured.

`class_interactions = "exchangeable"` is documented in `multinma` 0.9.1.9002 but raises
"not yet supported", so the hierarchical middle ground between shared and independent
interactions could not be fitted. The catalog entry for IDN-05 states that this relaxation
ships in the package; that is wrong for this version and will be corrected.

**Only one individual-level study.** IPD availability was a factor in the first version of
this design and was dropped to pay for treatment-effect heterogeneity, which the pre-run
critique identified as the more consequential omission. The study can therefore say nothing
about what a second individual-level trial would buy.

The deployment weights are a declared judgment and nothing in this program measured them,
which is why primary results are reported within strata.

## 10. Amendment record

### Amendment 1, 28 July 2026, made while cells 9 to 16 were running

A second pre-run critique, from a reviewer given a condensed statement of the design, found
that the drift grid skips the region a check has to discriminate in. In units of
$\varepsilon = 0.1531$, the contrast that makes the target estimate exactly material at
displacement 1, the registered levels are 0, 1.96, 3.92 and 7.84. There is nothing between the
null and twice the decision boundary, so the design as registered measures the floor and the
ceiling and not the part in between.

**Eight cells are added at drift 0.15, exactly one $\varepsilon$,** crossing network size,
covariate spread and treatment-effect heterogeneity. They are numbered 33 to 40 and appended,
so cells 1 to 32 keep their numbering, their random streams and their computed results. No
result from the added cells was seen before they were specified. They are excluded from the
deployment mixture, which was registered over the original four levels, and are reported on
their own.

The same critique produced three further changes, none of which alters the data collected:

- **The registered gate is unreachable by any procedure on the realized-error scale.**
  Estimation error alone puts a correctly specified fit over a 0.03 absolute-risk threshold in
  about half of the thin networks; cell 1 measured 0.46 at zero drift, inside the reviewer's
  predicted 0.31 to 0.56. A perfect check would fail a gate it deserves to pass. The gate is
  therefore also reported against **what the oracle model achieves on the same replicates**,
  the oracle being the fit that matches the truth. This uses fits that already exist.
- **Contraction is measured against a prior we chose,** `normal(0, 2.5)` rather than
  `multinma`'s default scale of 10, so M2's threshold is partly a modelling choice. The
  prior-free ratio of posterior standard deviations is now reported beside it.
- **"The check fired" has two readings.** Firing on the innocent covariate removes a replicate
  from the pass set without repairing anything, which can make the conditional risk look better
  because the check fired uselessly. Both readings are reported.

### The original amendment record

This protocol is the second version. The first was submitted to an adversarial reviewer before
any replicate was run and returned six fatal findings, nine serious ones and one named
omission. All were verified numerically before being accepted. The critique, the verification
and the full response are in `critique/`.

The changes: three active treatments became two, because the rotation gave every six-study
network an aggregate-only treatment with exactly one study and the relaxed model would have
reported the prior for four coefficients; three covariates became two, which makes the four
fits the complete lattice; the drift parameter became the contrast rather than half of it; the
target baseline was fixed across displacements; the verdict moved from a joint probability
required in every stratum to a conditional probability with a confidence bound; the posterior
rule stopped selecting the widest of three pairwise differences; treatment-effect
heterogeneity was added as a factor and IPD availability was dropped to pay for it; and three
of the four mechanism claims were rewritten, one of them because it asked for a
treatment-specific power from a statistic with no treatment index.

One defect was found before the critique, in the pilot, and the critique could not have found
it because it did not see code: with `class_interactions` at its default, the split fit is the
shared fit under another name and no check can ever fire.
