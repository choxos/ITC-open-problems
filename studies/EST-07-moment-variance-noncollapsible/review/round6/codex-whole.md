VERDICT: unsound

### The moment-matched truth is not MAIC's convergence target
SEVERITY: fatal
QUOTE: **moment_matched**: the contrast under a law carrying the target's REPORTED moments and the analyst's assumed Gaussian copula, which is what a moment-matching method converges to.
PROBLEM: MAIC converges to an exponential tilt of the source distribution. Its weights never use `corr_assumed`, yet `truth_moment_matched()` constructs a Gaussian law using `corr_assumed`. The identical MAIC point estimate is therefore scored against different supposed limits in the true, borrowed, and independence cells.
WHY IT MATTERS: `covered_mm` and the claimed signature of prediction 1 do not measure whether MAIC covers the quantity it targets.
WOULD BE WRONG IF: MAIC's point fit actually used the assumed Gaussian copula, or the registered truth were derived from the limiting exponential tilt of the source law.

### The growth ladder removes the persistent-bias mechanism
SEVERITY: fatal
QUOTE: That is what the two registered estimands separate and what the growth ladder measures.
PROBLEM: The ladder fixes `shape = mvnorm`, `corr_assumed = true`, and `modifier_span = inside`. In that cell the Gaussian reconstruction is correctly specified, and its sample moments converge to the true Gaussian law. Consequently, the moment-matched and superpopulation contrasts converge to each other; their gap is sampling error rather than persistent identification bias.
WHY IT MATTERS: The primary falsification experiment can approach nominal coverage even when the claimed persistence remains true under the non-normal conditions where moments fail to identify the law.
WOULD BE WRONG IF: The ladder retained a non-normal or otherwise unidentified target law, or it were explicitly registered as a correctly specified negative control rather than the prediction-1 test.

### The ladder analysis pools away the prediction it claims to test
SEVERITY: fatal
QUOTE: The analysis reports it as the prediction-1 test rather than pooling it with the powered grid.
PROBLEM: `R/16-analyze.R` averages ladder coverage by `nT` across identity, logit, cloglog, anchored, and unanchored cells. It then calls `sqrt(2) * COVERAGE_MCSE_AT_N` a paired error although `nT` is part of the seed key, so different rungs are independent, and each displayed value is itself an average over several cells.
WHY IT MATTERS: Opposing trajectories can cancel, and the stated uncertainty does not describe the statistic being tested. The resulting reading cannot accept or refute prediction 1.
WOULD BE WRONG IF: The analysis tested each curved-link and contrast-specific ladder separately using an uncertainty calculation for those actual aggregated contrasts.

### A complete run is guaranteed to receive “NO VERDICT”
SEVERITY: fatal
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices in these conditions.
PROBLEM: The registered grid has 356 cells, including 18 ladder cells. The analyzer removes the ladder before its powered-grid decision, leaving 338 cells, but requires at least `0.95 * 356 = 338.2`. Thus even a complete 356-cell run fails the completeness check. Conversely, `n_expected` is derived from observed output rather than the registered grid, so some incomplete runs can face a smaller denominator.
WHY IT MATTERS: The software cannot issue either registered substantive conclusion on the complete study.
WOULD BE WRONG IF: Completeness used the registered powered-cell count of 338 and separately verified all 18 ladder cells.

### Order 16 fails in a registered outside cell
SEVERITY: fatal
QUOTE: Registered order **16**, forced by the `cloglog` / `mvnorm` cell.
PROBLEM: P1 probes only the three-covariate parameterization. Applying the same implemented one-dimensional reduction to the registered four-covariate `outside`, cloglog, `k = 0.5`, zero-shift cell gives a contrast differing by 0.001136 between orders 16 and 128. Orders 64 and 128 differ by about 0.000001, so this is convergence error, not reference noise. It exceeds the registered 0.0001 tolerance elevenfold.
WHY IT MATTERS: Coverage in outside cells is scored against an inadequately integrated truth.
WOULD BE WRONG IF: An exact evaluation of that registered cell shows order 16 within 0.0001 of a converged independent reference.

### The outside arm does not compute all three promised estimands
SEVERITY: serious
QUOTE: **Three**, and all are computed on every replicate by `R/15-run.R`.
PROBLEM: The outside arm has four outcome-model coefficients but reports only three covariates. `truth_moment_matched()` passes the three reported means and SDs into the four-coefficient truth calculation, causing a non-conformable quadratic form. The runner catches the error and writes `truth_mm = NA`.
WHY IT MATTERS: Moment-matched coverage is unavailable precisely in the arm designed to represent an unreported modifier, and the analysis silently removes it with `na.rm = TRUE`.
WOULD BE WRONG IF: The current outside calculation explicitly integrates the unreported covariate and returns a finite moment-matched truth.

### The gate uses a normal covariance as the truth in non-normal cells
SEVERITY: serious
QUOTE: **356 of 792 realized cells** are run: those whose omitted-variance share reaches 0.0791, plus a growth ladder retained regardless of share.
PROBLEM: P2 computes the moment term with `Omega_normal()` for every shape. For the registered shifted-lognormal marginal with mean 0.4 and SD 1, the true `Cov(X, X^2)` is 1.565625 and `Var(X^2)` is about 4.9251; the normal formula supplies 0.8 and 2.64. Supplying the transformed Pearson correlation does not recover the missing third and fourth moments.
WHY IT MATTERS: Lognormal and mixed cells are retained or dropped using the ported model's proposed correction, not their actual omitted-variance share.
WOULD BE WRONG IF: `Omega_normal()` equals the true covariance of the complete reported-moment vector under both transformed laws.

### P6 turns an upper uncertainty bound into evidence of exceedance
SEVERITY: serious
QUOTE: The worst cell reaches **0.0962** including Monte Carlo error against the 0.0791 threshold, so **the cross term is above the threshold and cannot be ignored**.
PROBLEM: The largest measured share is 0.07729, below 0.0791. The 0.0962 value is the estimate plus one approximate MCSE, which establishes only that the probe cannot rule out exceedance. Moreover, the worst cross term is negative, so omitting it widens intervals; a 0.01 overcoverage shift requires solving with `sqrt(1 + f)`, giving about 0.09799, not 0.0791. Even 0.0962 misses that reference.
WHY IT MATTERS: The stated P6 result and its justification for the correction arm do not follow from the measurement.
WOULD BE WRONG IF: The stored 0.0962 were a lower confidence bound for a positive variance omission, rather than an upper one-SE bound for a negative cross term.

### STC fits the complementary cloglog model
SEVERITY: serious
QUOTE: `stc` | conditional outcome model, marginalized over the reported law.
PROBLEM: The DGM generates `Y = 1` with survival probability `exp(-exp(eta))` and defines `g(S) = log(-log(S))`. STC fits R's binomial `cloglog`, whose inverse is `1 - exp(-exp(eta))`, directly to that survival-coded outcome.
WHY IT MATTERS: STC is conditionally misspecified throughout the cloglog arm, so its performance is not that of the registered outcome model.
WOULD BE WRONG IF: `Y = 1` encoded failure rather than survival, or STC used the corresponding log-log survival link.

### The registered correlation block does not share data
SEVERITY: serious
QUOTE: Cells differing only in the assumed correlation see identical data.
PROBLEM: `crn_seed()` includes the derived `ladder` column. The true-correlation middle cells have `ladder = TRUE`, while the corresponding borrowed and independence cells have `ladder = FALSE`. Their seed strings therefore differ even after `corr_assumed` is removed.
WHY IT MATTERS: The affected correlation contrasts are analyzed as paired despite being based on different simulated data.
WOULD BE WRONG IF: `ladder` and other derived classification fields were excluded from the seed key or were identical across each correlation block.

### Pooled Monte Carlo errors ignore remaining cross-cell dependence
SEVERITY: serious
QUOTE: Monte Carlo error for every method contrast is therefore computed from the **per-replicate difference**.
PROBLEM: Within-cell differences are paired correctly, but the pooled calculation then declares cells independent and combines their standard errors without covariance terms. Many cells differing only in `corr_assumed` intentionally reuse replicate data.
WHY IT MATTERS: The pooled uncertainty can be materially understated or overstated and is not clustered on the registered randomization block.
WOULD BE WRONG IF: Pooling first formed replicate-level block contrasts or otherwise included covariance between CRN-linked cells.

### P3's claimed implementation check is neither diagnostic nor enforced
SEVERITY: serious
QUOTE: The gap shrinks monotonically with source size, from 0.02872 to 0.004265, which is what a correct implementation does and a wrong one does not.
PROBLEM: Shrinkage over three sample sizes does not establish convergence to zero; a biased implementation can also shrink. The acceptance threshold is an asserted threefold reduction, not a comparison of the limiting gap against its measured uncertainty. Furthermore, `probes_done()` requires only a finite `P3_MAX_REL_ERR` and never checks `P3_identity_ok`.
WHY IT MATTERS: A failed identity control can still authorize the production run, and the quoted measurements do not prove correctness.
WOULD BE WRONG IF: A prespecified extrapolation established a zero limit within uncertainty and the run stopped whenever that check failed.

### P7 reactivates the withdrawn variance inference
SEVERITY: serious
QUOTE: The omitted variance is J' Omega J / nT, which is a positive definite form in that gradient.
PROBLEM: P7 displays `delta_gradient()`, the gradient of a single estimand contrast. Section 1 explicitly withdraws using that gradient to characterize an implemented estimator's sampling variance. The interval term in `maic_entropy` instead uses `estimator_gradient()`, and P7 computes neither that gradient nor either full registered anchored or unanchored contrast.
WHY IT MATTERS: The probe establishes local sensitivity of a marginal estimand, not that an implemented interval omits a nonzero variance term when effect modification is absent.
WOULD BE WRONG IF: The displayed gradient were analytically identical to the estimator gradient for the registered contrast, with that identity established in the protocol.

### Residual failure is not uniquely identification
SEVERITY: serious
QUOTE: Whatever `maic_xcov` still fails to cover is what identification has to explain.
PROBLEM: `maic_xcov` retains the normal moment-covariance reconstruction, finite-sample sandwich error, normal interval approximation, plug-in target-trial variance, and a first-order cross-term contraction whose calibration uncertainty is ignored. `maic_oracle` replaces only the Pearson correlation, not the non-normal third and fourth moments.
WHY IT MATTERS: Residual coverage error cannot be causally assigned to identification, so the proposed decomposition does not support its central interpretation.
WOULD BE WRONG IF: A joint oracle supplied the true complete moment covariance and exact cross term, while the remaining finite-sample approximations were independently shown negligible.

### P5 sizes a global resample count from one favorable cell
SEVERITY: serious
QUOTE: **800** is the smallest value in the grid meeting both.
PROBLEM: P5 evaluates only one anchored, logit, multivariate-normal middle cell, although the retained grid is overwhelmingly unanchored and spans different links, shapes, source sizes, and overlap behavior. Quantile bias and failed-refit rates are not invariant across those conditions. The B = 3200 reference is also the same nested draw set, not an independently validated asymptotic reference, and the 1% width threshold has no derived downstream consequence.
WHY IT MATTERS: B = 800 can create method-specific coverage error elsewhere that the study would misattribute to the procedure.
WOULD BE WRONG IF: A proof makes this cell worst-case, or a grid-wide validation against a separately converged reference confirms both criteria.

### The anchored share sentence uses the wrong summaries
SEVERITY: serious
QUOTE: The moment term's median share ranges from 0.0233 to 0.0852 across links.
PROBLEM: Those are the all-arm link medians from P2. The anchored medians in the immediately preceding table are 0.0079, 0.0100, and 0.0395.
WHY IT MATTERS: A correct generated number is attached to the wrong population and materially overstates the moment term in the anchored setting.
WOULD BE WRONG IF: The sentence explicitly referred to the full anchored-plus-unanchored grid rather than anchored comparisons.

### Section 3 registers only one of the two contrast structures
SEVERITY: serious
QUOTE: The contrast is anchored: theta_AC(m_hat) - theta_BC_hat, on the link's own scale.
PROBLEM: `anchored = False` is crossed through the core, and its implementation reports `theta_A - g_mu_B` with different truths and target variance. The authoritative estimand section never formally defines that second contrast.
WHY IT MATTERS: Half the design is analyzed against an estimand not registered in the estimand section, while results are later pooled across the two structures.
WOULD BE WRONG IF: The unanchored arm were removed or its three estimands were separately and formally registered.

### The curved-link truths do not always separate
SEVERITY: serious
QUOTE: On both curved links all three separate.
PROBLEM: In registered zero-baseline-shift cells with `k = 1`, `pars_T` equals `pars`. Both the anchored contrast and the unanchored treated-arm contrast are therefore exactly zero under the superpopulation, moment-matched, and finite-target laws, including on logit and cloglog.
WHY IT MATTERS: The stated mechanism is absent in registered cells, contradicting the claim that separation is visible before any method runs.
WOULD BE WRONG IF: Those cells were excluded or the target model differed from the source model even at `k = 1` and zero shift.

### Coverage in the band does not show that the moment term suffices
SEVERITY: serious
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices in these conditions.
PROBLEM: The decision checks coverage alone. Bias, variance overestimation, covariance omission, and finite-sample error can compensate to produce nominal coverage. Although the software calculates bias and moment-matched coverage, neither enters this branch.
WHY IT MATTERS: The registered negative conclusion can be returned for a method centered on the wrong target with an offsetting interval-width error.
WOULD BE WRONG IF: Sufficiency jointly required negligible bias, correct empirical variance, and nominal coverage against the intended estimand.

### “True correlation 0.3” names the latent quantity as an observed one
SEVERITY: serious
QUOTE: Held fixed: 3 covariates ... and a true covariate correlation of 0.3.
PROBLEM: The DGM fixes the latent Gaussian correlation at 0.3. The transformations change observed Pearson correlation; the protocol itself reports about 0.238 for pairs involving the binary covariate.
WHY IT MATTERS: The shape comparison changes both marginal shape and observed dependence, so it is not a shape-only comparison as described.
WOULD BE WRONG IF: “true correlation” were explicitly defined as the latent Gaussian-copula parameter rather than the covariates' Pearson correlation.

### The “clear” cell classification has no calibrated confidence level
SEVERITY: serious
QUOTE: Each cell's share now carries a bootstrap standard error and cells fall into three classes: 446 below, 14 borderline, 332 clear.
PROBLEM: P2 calls a cell clear or below using the estimate plus or minus exactly one bootstrap standard error. One SE is not derived from a registered misclassification budget, and no simultaneous adjustment covers 792 classifications.
WHY IT MATTERS: The gate and the headline that every clear cell is unanchored can still be determined by calibration noise while being described as clear.
WOULD BE WRONG IF: The one-SE rule followed a registered loss function or simultaneous confidence procedure with a stated error rate.

### The authoritative protocol does not specify the realized crossing
SEVERITY: serious
QUOTE: `anchored` is crossed with the whole core rather than varied around a middle.
PROBLEM: “Core” is undefined. The code fully crosses link, nT, nS, k, anchored, and baseline shift only at multivariate-normal shape, true correlation, and inside modification. Shape, assumed correlation, and modifier span are then varied one at a time with nS and baseline shift fixed. The factor table and exported level lists do not disclose those missing interactions.
WHY IT MATTERS: Readers cannot reconstruct the 792 realized cells or determine which interactions are estimable from the stated design of record.
WOULD BE WRONG IF: The exact crossing and all middle-level restrictions were added to the authoritative protocol or exported as the complete cell table.

### P1's independent check cannot certify its registered tolerance
SEVERITY: serious
QUOTE: P1 stops and registers no order if they ever disagree by more than three.
PROBLEM: The Monte Carlo SE is 0.0000708, so the three-SE acceptance radius is 0.0002124, more than twice the 0.0001 quadrature tolerance. The observed quadrature-minus-Monte-Carlo difference is already 0.00010321, slightly above that tolerance.
WHY IT MATTERS: The independent guard can accept integration error exceeding the criterion used to define truth.
WOULD BE WRONG IF: An independent reference with uncertainty well below 0.0001 separately certifies the production rule.

### The named first-experiment artifacts are absent
SEVERITY: serious
QUOTE: results/e1.rds plus results/e1-analysis.rds hold what the first experiment produced.
PROBLEM: Neither file exists anywhere under the permitted study directory, and `results/run` contains no result files. Only the probe, cross-covariance, and registered-design artifacts are present.
WHY IT MATTERS: The requested first-experiment outputs and their analysis cannot be checked against either the implementation or the protocol.
WOULD BE WRONG IF: Those artifacts were omitted from the mounted read-only checkout or exist under different paths.
