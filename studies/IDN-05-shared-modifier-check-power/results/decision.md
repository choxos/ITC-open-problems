# The prespecified decision, as evaluated

**Every number in this file is computed by `R/08-decision.R` from the same result files the
manuscript reads.** The first version was typed by hand and a reviewer found three figures in
it that disagreed with the manuscript. Nothing here is transcribed.

## Primary verdict

**Registered rule.** The check earns the reassurance it is read as giving if the upper 95%
confidence bound on P(material error | the check did not fire), pooled over the deployment
distribution at target displacement 1.0, is below 0.10. Material error is a C-versus-A
marginal risk difference wrong by more than 0.03 absolute risk. The rule is the DIC cut at 5.

**Result: FAILS.** Upper bound 0.697 against a threshold of 0.10 on realized error, and 0.563
on systematic error. Point estimates 0.675 and 0.563, deployment-weighted.

**Qualification, and it is the important one.** An oracle that knows which specification is
true, fitted to the same replicates, is materially wrong 0.639 of the time at the same
displacement. The check's excess over that oracle is **0.036**, and at displacements 0 and
0.5 the excess is negative (-0.019 and -0.014). A perfect check would also have failed this gate.
The threshold was unreachable by any procedure: with a 0.03 absolute-risk threshold the
estimation error of a six-study network exceeds it in 0.460 to 0.580 of replicates when the
assumption holds exactly.

## Mechanism claims

| Claim | Registered threshold | Result | Verdict |
|---|---|---|---|
| **M1** decoupling | pass rate identical across displacement; conditional risk rises >= 0.20 | identical to 0; rise 0.296 | **confirmed** |
| **M2** identification asymmetry | contraction gap >= 0.20, widening as the network shrinks | gap 0.047 to 0.558, widens monotonically, clears 0.20 in **5 of 8** strata | **partly** |
| **M3** the two rules differ on the null | type I error gap >= 0.05 | 0.080 on the drifting covariate (DIC 0.013, interval 0.092); 0.087 pooling both covariates | **confirmed** |
| **M4** the two rules disagree | >= 10% of replicates | 0.107, 95% CI [0.096, 0.118], clustered by replicate | **not clearly met** |

M4 is reported as not clearly met. The point estimate 0.107 exceeds 0.10 but the lower 95%
confidence bound is 0.096, below the registered threshold. The first version of this file
called it confirmed; a reviewer pointed out that a point estimate 0.007 above a threshold with
a standard error of 0.006 does not clear it, and that is right.

M2 clears its bar in 5 of 8 strata and misses in the largest network at the widest
covariate spread. A pre-run critique had already pointed out that contraction is measured
against a prior we chose, so the threshold is partly a modelling choice. The ratio of the two
posterior standard deviations, 1.65 to 6.87, is offered as the measure that should have
been registered instead. It is not prior-free either, since both posteriors shrink toward the
same prior, but it needs no subtraction of prior from posterior precision and so avoids the
instability that demoted the derived data-only column.

M3 is confirmed on either pooling. The disagreement behind M4 is nearly one-sided: the DIC
rule fires without the interval rule in 0.0006 of replicates and the interval rule fires
without DIC in 0.106, so the DIC cut is very nearly a strict subset of the interval rule
rather than a second opinion.

## Secondary measurements, not thresholded

- **Power on the drifting covariate, DIC cut 5.** 0.00 to 0.08 at drift 0.30, 0.00 to 0.30 at drift 0.60,
  0.06 to 0.86 at drift 1.20. Per-cell Monte Carlo standard error is about 0.065 at 50 replicates,
  so these ranges are the spread of noisy estimates and not bounds.
- **Type I error under the global null**, drifting covariate: DIC cut 2 0.055, cut 5 0.013,
  cut 10 0.000, 95% interval 0.092, margin rule 0.235.
- **The equivalence reading fired 0 times in 3,200 covariate-checks.** This is a statement
  about precision, not about the rule: it can only fire when the posterior standard
  deviation of the contrast falls below 0.078, and the tightest cell in the design reaches
  0.30. The rule is also prior-sensitive in the other direction, since the prior alone
  puts 0.965 of the contrast beyond the margin, above the 0.95 firing threshold.
- **Threshold-free discrimination (prespecified, and omitted from the first two drafts).**
  Ranking a violated network above an intact one by -DDIC: AUROC 0.557 [0.517, 0.596] at a contrast of
  0.30, 0.681 at 0.60 and 0.843 at 1.20. Against material error itself it reaches 0.666 at
  displacement 1. No cut recovers a ranking the statistic does not contain.
- **Strategies at displacement 1.0.** RMSE 0.0928 for check-then-relax, 0.0995 for imposing the
  restriction, 0.1218 for relaxing everything. The ordering is loss-dependent: on RMSE at
  displacement 0 imposing the restriction is better (0.0422 against 0.0426). On PAIRED absolute
  error check-then-relax wins at all four displacements with every interval excluding zero.
- **Net benefit.** Distrusting every analysis beats every rule at every action threshold
  from 0.05 to 0.60.
- **Calibration.** A mapping from the check statistic to the probability of material
  error transports across network size, covariate spread and heterogeneity, absolute
  error 0.013 to 0.058, and fails across drift, error up to 0.469.
- **Misattribution.** When a violation is present the interval rule fires on the
  covariate that is shared exactly in up to 0.388 of replicates.
- **Convergence.** The fully relaxed model fails its sampler criteria in 0.068 of replicates
  overall, with R-hat to 1.89 and effective sample size to 3.41; the shared model never
  fails. These replicates are RETAINED, which departs from the registered eligibility rule;
  the amendment and the sensitivity analysis are in the protocol and the manuscript.
  The worst diagnostic reached by ANY model is R-hat 5.13 and ESS 1.03, both in the split_x2 fit;
  at least one fit misses its criteria in 0.076 of replicates. Earlier drafts quoted the
  fully relaxed model's figures as though they were the worst in the study; they are not.

## Corrections made after round-two review

- **The primary bound was computed for the wrong quantity.** The registered gate is on the
  DEPLOYMENT-WEIGHTED risk. Earlier drafts reported 0.777, the one-sided Wilson bound on the
  UNWEIGHTED risk of 0.758, beside the weighted point estimate of 0.675. The weighted bound is
  0.697. The verdict FAILS either way, by a factor of about seven.
- **Contraction was divided by the wrong prior.** R/02-fit.R used the main design's prior
  standard deviation for every arm, including the prior-sensitivity arm fitted under
  normal(0, 1). This inverted the reported direction: contraction FALLS when the prior
  tightens, as it must. A reviewer derived the error from the published numbers alone.
- **The prior-sensitivity arm ran at 30 replicates per cell, not the registered 100.**
  8 cells, 240 replicates, 960 fits against the 3200 registered. Undisclosed until a reviewer
  showed the published fit count could not come from the registered design.
- **The null-table denominator is 800, not the 720 the protocol first stated.**
- **The prespecified AUROC analyses were computed and then omitted.** They are reported above.

## Amendment

Eight cells at drift 0.15 were added by dated amendment during the run. That drift gives a
systematic C-versus-A error of 0.029 at displacement 1, which is just BELOW the material
threshold of 0.03 rather than at it; the contrast that sits exactly on the threshold is
0.153. The first version of this file and of the manuscript described these cells as the
exact boundary, which a reviewer showed is false, and the description is corrected.
At that violation the DIC rule fires in 0.00 to 0.04 of analyses and the interval rule in
0.00 to 0.18.

