VERDICT: unsound

### The cell gate uses the wrong covariance for nonnormal moments
SEVERITY: fatal
QUOTE: **356 of 792 realized cells** are run: those whose omitted-variance share reaches 0.0791, plus a growth ladder retained regardless of share.
PROBLEM: `R/02-probe-grid.R` uses `Omega_normal()` for `lognormal` and `mixed` cells. That matrix lacks their required third and fourth moments. For the registered shifted-lognormal margin with mean 0.4 and SD 1, the actual Cov(X, X²) and Var(X²) are 1.565625 and 4.925074; `Omega_normal()` supplies 0.8 and 2.64. The generated shares are therefore working-normal corrections, not the true omitted-variance fractions to which the coverage formula applies.
WHY IT MATTERS: The retained grid, dropped cells, link summaries, anchored headline, and budget are selected using the wrong quantity.
WOULD BE WRONG IF: `Omega_normal()` equaled the actual sampling covariance of the reported moment vector under both transformed laws, or the gate were explicitly defined as a working-model screen without translating it into actual coverage.

### The growth ladder removes the persistent-bias mechanism
SEVERITY: fatal
QUOTE: The ladder holds every other factor at its middle and walks the target size, and the analysis reports it as the prediction-1 test rather than pooling it with the powered grid.
PROBLEM: The ladder fixes `shape = mvnorm`, true correlation, `modifier_span = inside`, and equal source and target covariance. As nT grows, the reported moments converge to those of the true target Gaussian, and an entropy tilt of the Gaussian source then converges to that target law. The structural moment-matched versus superpopulation gap therefore vanishes. The analyzer also averages the ladder across the identity falsifier, both curved links, and both anchoring settings.
WHY IT MATTERS: The central falsification experiment can approach nominal coverage because it was constructed where the claimed persistent identification bias disappears, not because the prediction is generally false.
WOULD BE WRONG IF: The ladder retained a nonnormal or outside-modifier law with a persistent unidentified component, or the Gaussian entropy tilt remained distinct from the registered target Gaussian in the limit.

### The analysis can call a partial run complete
SEVERITY: fatal
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices *in these conditions* and the study reports that as a negative result about its own prediction.
PROBLEM: `R/16-analyze.R` calculates `n_expected` from the cell IDs present in the run files, not from the registered P2 grid. Missing cells therefore reduce both the observed and expected counts. Cells where `maic_entropy` produces no rows are also absent from its convergence denominator. One successful powered cell can satisfy `complete = TRUE`.
WHY IT MATTERS: The software can issue the preregistered substantive verdict from an incomplete or selectively converged subset.
WOULD BE WRONG IF: Completeness were checked against every registered powered cell and every expected method-replicate result, including wholly absent cells and methods.

### Coverage alone cannot establish that the moment term suffices
SEVERITY: fatal
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices *in these conditions* and the study reports that as a negative result about its own prediction.
PROBLEM: The executable verdict is simply `all(ent$in_band)`. It does not require negligible superpopulation bias, agreement between estimated and empirical variance, or exclusion of cancellation involving identification bias, the cross term, and the misspecified nonnormal moment covariance. `maic_entropy` can attain nominal coverage by widening an interval around the wrong quantity.
WHY IT MATTERS: The primary rule can declare the variance correction sufficient and the prediction false under compensating errors.
WOULD BE WRONG IF: Success also required correct centering and variance calibration, with the oracle and cross-term decompositions ruling out cancellation.

### The claimed no-typed-number guarantee is false
SEVERITY: serious
QUOTE: Every number below is interpolated from `results/registered-design.json` by `review/emit-protocol.py` and checked by `review/verify-protocol.py`.
PROBLEM: `review/emit-protocol.py` contains literal measured results, including the six anchored-by-link and unanchored-by-link median shares. Those values are not fields in `registered-design.json`. The verifier only confirms that the document matches the generator, so it will accept these literals unchanged after the underlying probe results move.
WHY IT MATTERS: The exact stale-number defect the generation system claims to make impossible remains possible for headline measurements.
WOULD BE WRONG IF: Those table entries were derived from exported fields or separately asserted against the current P2 table.

### P6 converts an inconclusive upper bound into evidence that the term is above threshold
SEVERITY: serious
QUOTE: The worst cell reaches **0.0962** including Monte Carlo error against the 0.0791 threshold, so **the cross term is above the threshold and cannot be ignored**.
PROBLEM: The stored 0.0962 is `share + mcse`. Its underlying largest point estimate is 0.07729, below the 0.079136 threshold, with MCSE 0.01889. This establishes that the probe cannot certify the term as safely below threshold; it does not establish that the term is above threshold. P6 also examines only anchored, inside, multivariate-normal cells at unregistered nT values 150 and 600, not the unanchored cells that dominate the powered grid.
WHY IT MATTERS: A failed safety test is reported as a positive finding about the magnitude and worst location of the cross term.
WOULD BE WRONG IF: 0.0962 were a point estimate or lower confidence bound over the registered production grid rather than a one-MCSE upper value from the restricted probe.

### P6 applies a one-sided variance-omission threshold to a signed cross term
SEVERITY: serious
QUOTE: The comparison is therefore stated without that word.
PROBLEM: The 0.0791 floor was derived for omitting a positive variance component, which narrows an interval. The worst P6 term is negative, so omitting it widens the interval. Equal absolute shares do not produce equal coverage shifts: at 0.079136 the positive-omission formula gives about 0.9400 coverage, while omitting a negative term of that absolute share gives about 0.9583.
WHY IT MATTERS: Even a precisely measured cross-term share cannot be judged against this floor without deriving the criterion for its sign.
WOULD BE WRONG IF: The floor had been separately derived for signed cross terms under the study’s two-sided coverage criterion.

### P1's independent check is too noisy to certify the registered tolerance
SEVERITY: serious
QUOTE: P1 stops and registers no order if they ever disagree by more than three.
PROBLEM: The Monte Carlo SE is 7.08e-05, so the three-SE acceptance radius is 2.124e-04, more than twice the registered 1e-04 quadrature tolerance. The check therefore permits errors the truth definition says are unacceptable. It also checks an inside mixed configuration, not the outside cloglog/mvnorm configuration that forces order 24.
WHY IT MATTERS: Numerical truth error can pass the independent guard and then appear as estimator bias or failed coverage.
WOULD BE WRONG IF: A separate independent reference with uncertainty well below 1e-04 certified every configuration that can determine the production order.

### P1 does not probe the target-trial truths it claims to protect
SEVERITY: serious
QUOTE: Registered order **24**, forced by the `cloglog` / `mvnorm` cell.
PROBLEM: P1 evaluates a source A-versus-C contrast at a synthetic mean vector and does not vary `pars_T` or the registered baseline shift. Its outside-arm loop varies `k`, but `make_pars(k)` leaves the source outcome parameters unchanged, which is why all four outside rows are identical. The target comparator, where `k` and baseline shift actually operate, is never tested.
WHY IT MATTERS: Order 24 is not established over all integrals used to construct the registered anchored and unanchored truths.
WOULD BE WRONG IF: A derivation showed that the probed source contrast uniformly bounds quadrature error for every target-trial parameterization and baseline shift.

### The withdrawn second prediction remains operative in P3
SEVERITY: serious
QUOTE: It was registered as a test of the withdrawn second prediction and is retained only for what it does measure: whether the two gradients agree, which is a statement about identification.
PROBLEM: `R/03-probe-closed-form.R` still computes ported-to-“true” variance ratios, declares whether the “headline survives,” and interprets a 5% variance discrepancy. The exporter still records those fields, while the runner requires `P3_MAX_REL_ERR`. Conversely, `probes_done()` does not require `P3_identity_ok` to pass.
WHY IT MATTERS: A revoked variance interpretation remains a production prerequisite, while the identity implementation control described as essential cannot actually stop production.
WOULD BE WRONG IF: The variance-ratio and headline logic were removed and the runner instead enforced the identification control’s pass result.

### P7 repeats the gradient-to-variance inference that the protocol withdrew
SEVERITY: serious
QUOTE: The omitted variance is J' Omega J / nT, which is a positive definite form in that gradient, so a gradient bounded away from zero implies an omitted variance bounded away from zero.
PROBLEM: P7 computes `delta_gradient()`, the estimand gradient along a parametric law, while the interval’s omitted sampling variance uses `estimator_gradient()`. The protocol withdrew prediction 2 precisely because the former does not determine the latter. P7 also evaluates one trial’s marginal contrast rather than the registered anchored difference.
WHY IT MATTERS: The probe establishes sensitivity of an estimand, not the claimed omitted variance or the null behavior of the anchored estimator.
WOULD BE WRONG IF: P7 computed the estimator gradient for the applicable anchored or unanchored contrast and contracted it with the actual covariance of reported moments.

### The moment-matched truth is not guaranteed on every replicate
SEVERITY: serious
QUOTE: **Three**, and all are computed on every replicate by `R/15-run.R`.
PROBLEM: `truth_moment_matched()` can fail its weight fit; the runner catches the error and stores `NA`. The analyzer silently removes those values with `na.rm = TRUE` and reports no moment-truth convergence count. Its fixed pseudo-source size of 40,000 is also not supported by a convergence or numerical-error probe.
WHY IT MATTERS: Prediction 1’s signature can be calculated from a selective subset and against an unquantified Monte Carlo approximation.
WOULD BE WRONG IF: Every registered fit were proven to succeed and the 40,000-draw approximation error were bounded below the analysis tolerance.

### The promised correlation common random numbers are broken by derived grid fields
SEVERITY: serious
QUOTE: Common random numbers block `corr_assumed, variance_method`, so cells differing only in the assumed correlation see identical data.
PROBLEM: `crn_seed()` removes `corr_assumed` but retains every other grid column, including `ladder` and `class`. At the middle configuration the true-correlation cell has `ladder = TRUE`, while the otherwise identical borrowed and independence cells have `ladder = FALSE`; their seed strings therefore differ.
WHY IT MATTERS: The correlation contrast merges results by replicate and applies a paired MCSE to data that are not paired.
WOULD BE WRONG IF: Derived classification fields were excluded from the seed key or were identical throughout each correlation block.

### Pooled Monte Carlo errors ignore the remaining common-random-number dependence
SEVERITY: serious
QUOTE: Monte Carlo error for every method contrast is therefore computed from the **per-replicate difference**, not from an independence formula.
PROBLEM: Within-cell method differences are paired, but the pooled calculation explicitly declares cells independent and combines cell MCSEs without covariance terms. Correlation-setting cells intentionally share replicate data whenever the seed bug does not break the block.
WHY IT MATTERS: Precision for the primary pooled method contrasts can be understated or overstated despite the blanket clustering claim.
WOULD BE WRONG IF: Pooling were performed at the replicate-block level or included covariance between all CRN-linked cells.

### P5 does not ensure that production receives 800 usable resamples
SEVERITY: serious
QUOTE: **800** is the smallest value in the grid meeting both.
PROBLEM: P5 evaluates one benign logit/mvnorm cell. In production, failed perturbation refits are silently discarded, and `limits_from_draws()` accepts an interval with only 20 finite draws. Neither the estimator nor the analyzer records the effective resample count. The additional 1% width tolerance is asserted rather than derived from a downstream noise floor.
WHY IT MATTERS: A difficult registered cell can report a heavily inward-biased percentile interval while being labeled as a successful B = 800 run.
WOULD BE WRONG IF: Every production cell were shown to retain essentially all 800 draws and the 1% width criterion were tied to a registered inferential tolerance.

### STC does not marginalize over the registered mixed law or correlation setting
SEVERITY: serious
QUOTE: `stc` | conditional outcome model, marginalized over the reported law
PROBLEM: `stc_estimate()` always reconstructs a multivariate normal sample using `assumed_R("borrowed")`. In `mixed` cells this turns the reported binary covariate into an unbounded continuous variable, and in cells labeled `true` or `independence` it still uses the borrowed correlation.
WHY IT MATTERS: STC rows are mislabeled by the correlation factor and do not implement the reported-law reconstruction claimed for the mixed arm.
WOULD BE WRONG IF: STC were excluded from those cells or reconstructed the registered margins using each cell’s `corr_assumed` value.

### The clear-borderline-below classification has no calibrated confidence level
SEVERITY: serious
QUOTE: Each cell's share now carries a bootstrap standard error and cells fall into three classes.
PROBLEM: P2 calls a cell clear when `share - share_se` exceeds the floor and below when `share + share_se` does not. A one-standard-error interval is not a derived confidence rule, and no allowance is made for classifying 792 cells.
WHY IT MATTERS: Random calibration noise can still determine which cells are run and support the claim that every anchored cell is clearly below threshold.
WOULD BE WRONG IF: The one-SE rule had a preregistered error guarantee appropriate to the grid-wide selection decision.

### The stated true correlation is the latent correlation, not the covariate correlation
SEVERITY: serious
QUOTE: Held fixed: 3 covariates (4 in the `outside` arm, which is crossed with `mvnorm` only), overlap at a standardized difference of 0.4 on **every** covariate, and a true covariate correlation of 0.3.
PROBLEM: The code sets the latent Gaussian correlation to 0.3 before transforming covariates. The protocol later acknowledges that mixed-law covariate correlations are about 0.238 and that the lognormal map also changes them.
WHY IT MATTERS: Shape is confounded with actual correlation, and the scope claim that the study examines one true correlation is false.
WOULD BE WRONG IF: “True covariate correlation” were explicitly defined as the latent Gaussian parameter throughout, including in the oracle and scope sections.

### The anchored median range is generated from the wrong stratum
SEVERITY: serious
QUOTE: The moment term's median share ranges from 0.0233 to 0.0852 across links.
PROBLEM: Those values are the by-link medians over the entire realized grid, mixing anchored and unanchored cells. The immediately preceding anchored table gives anchored medians of 0.0079, 0.0100, and 0.0395.
WHY IT MATTERS: A correctly generated number is used to describe the wrong analysis population and overstates the moment contribution in the anchored setting.
WOULD BE WRONG IF: The sentence were explicitly returning to the combined-arm grid and were not offered as evidence about the anchored decomposition.

### A Gaussian tilt does not determine the finite target empirical contrast
SEVERITY: serious
QUOTE: Under normal covariates MAIC's limit tracks the finite-target contrast, as a Gaussian tilt of a Gaussian must.
PROBLEM: The entropy tilt matches reported marginal means and raw second moments. Those do not determine the target sample’s empirical joint law, empirical correlations, or higher moments. The tilted law is Gaussian, while the finite-target empirical law is discrete, so the stated consequence does not follow merely because the source law is Gaussian. No saved probe tests this assertion.
WHY IT MATTERS: The claimed pre-run validation of the three estimands and prediction 1’s signature rests on an unmeasured relationship.
WOULD BE WRONG IF: “Tracks” had a registered quantitative definition and a probe demonstrated it at the required tolerance, or `finite_target` were a Gaussian reconstruction rather than the empirical target law.

### The authoritative protocol does not specify the realized factorial
SEVERITY: serious
QUOTE: `anchored` is crossed with the whole core rather than varied around a middle.
PROBLEM: “Core” is undefined. The code fully crosses link, nT, nS, k, anchoring, and baseline shift only at mvnorm, true correlation, and inside modification. Shape, assumed correlation, and modifier span are varied one at a time with nS and baseline shift fixed. Neither the factor table nor `registered-design.json` contains the complete realized grid.
WHY IT MATTERS: Readers cannot reconstruct the 792 cells or know which interactions are estimable from the document declared to be the design of record.
WOULD BE WRONG IF: The exact crossing and every middle-level restriction were included in the authoritative protocol or exported as the complete registered cell table.
