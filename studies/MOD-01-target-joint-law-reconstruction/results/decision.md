# Decision

**MATTERS, AND IS FIXABLE: independence is biased by 0.1261 while a borrowed correlation matrix is not**

**Falsifier: the mixed sign pattern does NOT rescue independence, so section 2's cancellation account is wrong and the recommendation cannot be conditioned on the sign pattern**

Prespecified in `DESIGN.md` section 7 and applied by `R/07-decision.R`.
Every number is computed from `results/analysis.rds`; nothing is
transcribed. 224 cells, 476 replicates each.

## Controls

Both are identities rather than expectations, so a failure is an
implementation fault and not a finding.

| control | what makes it exact | largest disagreement | tolerance | pass |
| --- | --- | ---: | ---: | :---: |
| one covariate | no off-diagonal exists, so every reconstruction is the truth | 0.00548 | 0.00750 | yes |
| zero correlation | the true law IS the independence law | 0.00433 | 0.00750 | yes |

A third control was registered and withdrawn before the run. DESIGN.md
section 8 claimed the risk-difference scale makes the reconstruction
exactly irrelevant; it does not, because collapsibility fixes the
relation between the marginal and the mean conditional effect without
fixing that mean against the joint law. Measured, the collapsible scale
carries 24% to 25% of the log odds ratio's reconstruction shift
rather than none of it, and the arm is reported as a prediction below.

## Registered primary

Bias in the target marginal log odds ratio, in nonlinear-modification
cells with all-positive coefficients and correlation 0.6, where section 2
predicts the error is largest.

| method | mean bias | worst-cell bias | coverage | width |
| --- | ---: | ---: | ---: | ---: |
| gcomp_borrowed | 0.0038 | 0.0165 | 0.944 | 0.689 |
| gcomp_oracle | 0.0057 | 0.0189 | 0.945 | 0.688 |
| stc_means | 0.0293 | 0.1480 | 0.940 | 1.115 |
| recon_interval | 0.0681 | 0.1131 | 0.971 | 1.011 |
| gcomp_indep | 0.1261 | 0.2099 | 0.898 | 0.838 |

Material threshold 0.05 on the log odds ratio.

## The falsifier, in full

Section 2 predicts that positive covariances cancel under a mixed sign
pattern, so independence should be adequate there despite strong
correlation. This is the test that can take most of the practical
recommendation away.

| sign pattern | modification | section 2 scalar | independence minus oracle | worst cell |
| --- | --- | ---: | ---: | ---: |
| mixed | linear | -0.300 | -0.0351 | -0.0455 |
| positive | linear | 0.300 | 0.0571 | 0.1020 |
| mixed | nonlinear | -0.300 | -0.0562 | -0.0767 |
| positive | nonlinear | 0.300 | 0.1204 | 0.1925 |

## Mechanism: is the error linear in section 2's scalar?

| scale | modification | dim | cells | slope | R-squared |
| --- | --- | ---: | ---: | ---: | ---: |
| logOR | linear | 2 | 28 | 0.085 | 0.937 |
| riskdiff | linear | 2 | 28 | 0.020 | 0.923 |
| logOR | nonlinear | 2 | 28 | 0.194 | 0.982 |
| riskdiff | nonlinear | 2 | 28 | 0.047 | 0.982 |
| logOR | linear | 5 | 28 | 0.036 | 0.963 |
| riskdiff | linear | 5 | 28 | 0.009 | 0.965 |
| logOR | nonlinear | 5 | 28 | 0.066 | 0.991 |
| riskdiff | nonlinear | 5 | 28 | 0.016 | 0.991 |

A high R-squared with one slope per block confirms the second-order
account. A poor fit means the expansion is not what drives the error at
these strengths, and the deliverable is the measurement rather than the
mechanism.

## The bound an analyst can compute from published data

Realized gap inside the computable bound in **335 of 448 cells (0.748)**.

The bound uses the proportionality fitted in the mechanism block above, so
this is an in-sample assessment of its SHAPE and not of a constant an
analyst would have to supply independently. A deployable version needs
that constant, and this study does not provide it.

## The scale prediction that replaced the withdrawn control

| scale | cells | mean absolute gap | worst |
| --- | ---: | ---: | ---: |
| logOR | 112 | 0.0444 | 0.1925 |
| riskdiff | 112 | 0.0107 | 0.0467 |

## Prediction 4: the copula family beyond the correlation matrix

All three families are matched on Pearson correlation, so the borrowed
correlation arm has the right second moment and the wrong family. A
difference across families here is dependence the correlation matrix
cannot carry.

| scale | modification | copula | cells | borrowed minus oracle |
| --- | --- | --- | ---: | ---: |
| logOR | linear | clayton | 16 | -0.0043 |
| logOR | linear | gaussian | 16 | 0.0001 |
| logOR | linear | gumbel | 16 | -0.0015 |
| logOR | nonlinear | clayton | 16 | -0.0017 |
| logOR | nonlinear | gaussian | 16 | -0.0005 |
| logOR | nonlinear | gumbel | 16 | -0.0044 |
| riskdiff | linear | clayton | 16 | -0.0011 |
| riskdiff | linear | gaussian | 16 | 0.0000 |
| riskdiff | linear | gumbel | 16 | -0.0003 |
| riskdiff | nonlinear | clayton | 16 | -0.0005 |
| riskdiff | nonlinear | gaussian | 16 | -0.0001 |
| riskdiff | nonlinear | gumbel | 16 | -0.0010 |

## What this does and does not establish

The conditional-versus-marginal mismatch that the catalog entry leads with
is closed in the literature and is not retested here; conventional STC at
target means appears only as a labeled reference point. What is measured
is the residual the entry names and nobody had sized: the error left after
standardizing correctly, caused by not knowing the target's joint law.

Four limits.

1. **The reported marginals are exact.** Nothing here is sampling error in
   the published moments; EST-07 and MIS-03 own that, and mixing the two
   would make neither interpretable.
2. **The outcome model is correctly specified.** MOD-02 owns
   misspecification, and standardizing a wrong model over a right law is a
   different failure with a different fix.
3. **The borrowed correlation arm is optimistic.** The IPD trial here
   shares the target's dependence structure, so borrowing is exactly right
   about correlation and wrong only about the family. In practice the two
   trials' dependence would differ as well, and that arm would do worse.
4. **Covariates are continuous.** Categorical covariates constrain a joint
   law far more tightly than continuous ones, so the reconstruction
   problem is different and easier there.

