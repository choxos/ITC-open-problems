VERDICT: unsound

### P3 compares estimator variance with movement of a different quantity
SEVERITY: fatal
QUOTE: What the variance of the *estimand* requires is the gradient of the estimand.
PROBLEM: The superpopulation estimand is fixed across replicates. Target-moment sampling variance is governed by the gradient of the MAIC estimator, not by how the truth changes across a parametric family of target laws. `DESIGN.md` explicitly revokes this interpretation, but the protocol and P3 still call the resulting ratio a variance error.
WHY IT MATTERS: The central variance ratios, coverage prediction, link comparison, and claimed practical consequence do not follow from P3.
WOULD BE WRONG IF: The estimator were the plug-in statistic whose functional derivative P3 computes, or the superpopulation estimand itself varied across replicates.

### The cell gate screens on the wrong variance fraction
SEVERITY: fatal
QUOTE: **124 of 288 realized cells clear a 0.07913633 floor** and are run; the rest are dropped rather than run, because a cell whose effect cannot be distinguished from zero at 2000 replicates consumes budget and returns nothing.
PROBLEM: P2 calculates `v_omit / (v_omit + v_src)` using the revoked estimand gradient. It excludes the target B-versus-C variance and its covariance with the target moments, even though both enter the anchored interval. It also does not use `corr_assumed`, and its nominal `k` input does not enter the gradient.
WHY IT MATTERS: The 0.07913633 coverage mapping applies to a fraction of total variance, not P2's partial quantity. The 124-cell run grid, power claim, and budget therefore do not follow from the stated criterion.
WOULD BE WRONG IF: The target-effect variance and cross-covariance were zero, correlation setting were irrelevant, and the estimand gradient equaled the estimator gradient in every cell.

### A failed sixth probe is omitted from the protocol
SEVERITY: fatal
QUOTE: Five probes ran before this document existed.
PROBLEM: P6 also ran. The current export records `p6_ok = false`; its worst share plus MCSE is 0.0962 against the registered 0.07913633 floor. The implementation consequently added an unlisted `maic_xcov` arm, and the analyzer uses it, but neither the failed probe nor this method appears in the protocol.
WHY IT MATTERS: A measured cross-term large enough to confound absolute coverage and attribution has been suppressed from the preregistration, together with the data-dependent method added to address it.
WOULD BE WRONG IF: P6 were unrun or nonoperative, its result cleared the floor, or production code did not consume `maic_xcov`.

### The promised finite-target estimand is never computed
SEVERITY: fatal
QUOTE: Both are computed on every replicate.
PROBLEM: `truth_anchored_finite()` exists but has no caller. `R/15-run.R` computes only `truth_anchored_superpop`, writes one `truth`, one `error`, and one coverage indicator, and `R/16-analyze.R` analyzes only those fields.
WHY IT MATTERS: The study cannot make its promised distinction between an interval that is too narrow and an interval targeting a different estimand.
WOULD BE WRONG IF: Another declared runner writes and analyzes finite-target truth; no such code path or result artifact exists here.

### The registered success rule cannot support its conclusion
SEVERITY: fatal
QUOTE: If it restores nominal coverage across the grid on the logit scale, the catalog's porting claim is supported, this study's second prediction is wrong, and the study says so.
PROBLEM: `DESIGN.md` has already withdrawn prediction 2. Moreover, nominal coverage alone cannot establish a correct variance estimator: identification bias, overwide intervals, the omitted cross-term, and other variance errors can cancel. A filtered logit grid also cannot establish the catalog's broader claim or identify reconstructed correlation as the residual component.
WHY IT MATTERS: The preregistered rule can declare support under compensating errors.
WOULD BE WRONG IF: Support additionally required negligible bias, agreement of mean SE with empirical SD, valid correlation attribution, and an explicitly limited scope.

### The null control is false on the curved links
SEVERITY: fatal
QUOTE: With no effect modification, $\beta_{EM} = 0$, section 2 makes the omitted variance exactly zero at every $n_T$ and on every scale, because the estimand no longer depends on $F_T$.
PROBLEM: With nonzero prognostic effects, a constant conditional log odds ratio or log cumulative-hazard ratio still yields a marginal contrast that depends on the target covariate law. This is non-collapsibility itself. Its target-moment variance and covariance with the direct target effect therefore need not vanish when $\beta_{EM}=0$.
WHY IT MATTERS: Correct curved-link behavior can fail the registered stopping control and be mislabeled a source-variance implementation defect.
WOULD BE WRONG IF: The link were identity, prognostic heterogeneity were absent, or the marginal contrast were otherwise law-invariant.

### The interval-direction labels are reversed
SEVERITY: serious
QUOTE: **nothing is conservative on either scale**: `logit` spans 1 and `cloglog` sits modestly above it.
PROBLEM: P3 defines the ratio as `v_ported / v_true`. A ratio above one means the ported variance is larger and the interval is conservative. Thus the entire cloglog range 1.077 to 1.172 is conservative under the document's own interpretation, while the logit range contains both directions. The exporter and verifier encode the reverse mapping.
WHY IT MATTERS: The practical consequence stated beside correctly generated numbers is exactly backward.
WOULD BE WRONG IF: The ratio were `v_true / v_ported`; the code explicitly computes the opposite.

### The four MAIC variants do not share one fit and sandwich
SEVERITY: serious
QUOTE: All four MAIC variants share one weight fit and one sandwich, so they differ in the variance they report and in nothing else, which makes the paired comparison a comparison of intervals.
PROBLEM: `maic_perturb` resamples source observations, perturbs target summaries, refits weights 800 times, and reports percentile limits with no standard error. It is a different procedure, not another variance from the shared fit. The implementation also contains the unlisted fifth MAIC arm `maic_xcov`.
WHY IT MATTERS: Differences involving `maic_perturb` cannot be attributed solely to variance formulas, and the registered method set is incomplete.
WOULD BE WRONG IF: `maic_perturb` reused the common fit and generated a Wald interval from a shared sandwich.

### The identity-link guard does not perform the validation claimed
SEVERITY: serious
QUOTE: The gap between estimator and estimand gradient falls by a factor of 6.7 across $n_S$ = 500 to 8000, reaching within one Monte Carlo standard error of zero.
PROBLEM: The convergence loop records no Monte Carlo SE and tests only whether the maximum gap shrinks by a factor of three. It does not test the complete identity-link variance, either published port, the target-effect covariance, or convergence to the known coefficient.
WHY IT MATTERS: An implementation with an $n_S$-dependent error can pass, as can the missing variance components already found elsewhere.
WOULD BE WRONG IF: The guard stored and tested the final MCSE, convergence to $\beta_{EM}$, and the complete closed-form interval variance.

### The resample-count sentence describes an obsolete measurement
SEVERITY: serious
QUOTE: At $B = 800$ the 90th-percentile resampling error is inside the across-replicate spread of the standard error itself (0.01891), so more resamples buy nothing a coverage number can see.
PROBLEM: Current P5 computes no 90th-percentile resampling error, and the percentile method has no standard error. The exported 0.01891 is now `sd(width) / mean(width)` for the $B=3200$ reference intervals. The actual $B=800$ criteria are a paired coverage difference plus one MCSE below 0.01 and absolute width bias below 1%.
WHY IT MATTERS: The dominant computational constant is justified in the protocol by a measurement of something else.
WOULD BE WRONG IF: `P5_spread` still came from the old standard-error convergence probe; current code explicitly overwrites it with relative interval-width spread.

### The promised clustering across correlation settings is absent
SEVERITY: serious
QUOTE: Common random numbers across corr_assumed, variance_method, so **Monte Carlo error is clustered on the replicate block**.
PROBLEM: Correlation settings receive different `cell_id` values. `paired_contrast()` splits by `cell_id`, so it never pairs across `corr_assumed`; the pooled calculation then explicitly assumes cells are independent even though those cells share replicate data by construction.
WHY IT MATTERS: The uncertainty needed for the true-versus-borrowed-versus-independence attribution is unavailable or incorrectly pooled.
WOULD BE WRONG IF: The analyzer grouped by a block key excluding `corr_assumed`, or correlation settings shared one cell identifier.

### The registered ADEMP analysis is not implemented
SEVERITY: serious
QUOTE: Per cell: bias against the superpopulation estimand and against the finite-target estimand separately; empirical SD; mean estimated SE; the ratio of the two; 95% interval coverage and its two-sided departure from nominal; interval width; convergence rate.
PROBLEM: `R/16-analyze.R` reports only one-estimand bias, coverage, width, and a defective convergence fraction. It does not calculate empirical SD, mean SE, their ratio, finite-target results, or the registered bootstrap MCSE for the ratio.
WHY IT MATTERS: The software lacks the diagnostics needed to distinguish correct coverage from compensating bias and variance errors.
WOULD BE WRONG IF: A separate declared analysis program computes and writes these registered measures; none is present.

### Method failures are removed before convergence is calculated
SEVERITY: serious
QUOTE: 2000 replicates per cell.
PROBLEM: Failed MAIC or STC fits return no row. The analyzer sets its denominator to the rows that remain, then calculates convergence among those rows. A method that fails completely on 10% of replicates can therefore report 100% convergence and coverage conditional on success.
WHY IT MATTERS: Convergence, coverage, and their MCSEs are biased exactly where overlap or numerical failure is consequential.
WOULD BE WRONG IF: The runner emitted an explicit failure row for every method and replicate, or the denominator were the complete registered replicate set.

### The STC interval is not for its marginalized estimator
SEVERITY: serious
QUOTE: `STC | conditional outcome model centered on target means, marginalized by simulation`
PROBLEM: STC estimates a nonlinear marginalized contrast involving every outcome-model coefficient and its interactions, but reports `sqrt(vcov(fit)["A","A"] + V_BC)`. That is only the conditional treatment-coefficient variance. It omits uncertainty from the other coefficients, marginalization, target summaries, and simulation.
WHY IT MATTERS: STC coverage is not coverage of the reported marginal estimand and cannot serve as the registered comparator.
WOULD BE WRONG IF: The marginal contrast reduced exactly to coefficient `A`, or a full delta method or bootstrap supplied its interval.

### The claimed Weibull arm is a fixed-horizon Bernoulli experiment
SEVERITY: serious
QUOTE: Weibull PH throughout, so nothing separates moment uncertainty from non-proportionality.
PROBLEM: The DGM generates only a Bernoulli survival-status indicator at one implicit horizon. It has no event times, Weibull shape or scale, censoring, risk sets, or survival-model fit. STC additionally applies R's event-probability `cloglog` link to an outcome coded with survival probability, whose link in this study is `log(-log(S))`.
WHY IT MATTERS: Results cannot support claims about Weibull time-to-event MAIC, hazard-ratio inference, or separation from non-proportional hazards.
WOULD BE WRONG IF: The estimand were explicitly limited to a fixed-horizon survival-status contrast and the outcome were coded or linked consistently.

### The reported four-dimensional agreement was measured in three dimensions
SEVERITY: serious
QUOTE: 65,536 nodes to 16 at four covariates, agreeing with the product rule to 2.13e-07.
PROBLEM: `R/12-export.R` calculates 65,536 as $16^4$, but its agreement calculation sets `pnum <- 3` and compares two three-covariate integrals. No four-covariate product-rule comparison produces 2.13e-07.
WHY IT MATTERS: The empirical check cited for truth in the four-covariate `outside` arm does not exist.
WOULD BE WRONG IF: The comparison used `pnum = 4` or a separate four-dimensional validation generated the quoted tolerance.

### The binary-covariate explanation no longer explains the selected order
SEVERITY: minor
QUOTE: The order is forced by the `mvnorm` covariate shape on the `cloglog` link; a thresholded binary covariate is a step function and Gauss-Hermite converges on it slowly.
PROBLEM: Current P1 finds that `mvnorm`/`cloglog` forces order 16, while the mixed binary cell is stable by order 12. The current integrator splits at the binary discontinuity specifically to eliminate the slow-convergence problem.
WHY IT MATTERS: The stated causal explanation is stale, although order 16 remains conservative for the mixed arm.
WOULD BE WRONG IF: The mixed cell forced the maximum order or still used unsplit Gauss-Hermite at the discontinuity.

### Three covariates are not held fixed throughout
SEVERITY: minor
QUOTE: Held fixed: 3 covariates, overlap at a standardized mean difference of 0.4, anchored throughout.
PROBLEM: `modifier_span = "outside"` appends a fourth covariate that affects source outcomes but is not reported by the target. The protocol later implicitly acknowledges four covariates in its quadrature claim.
WHY IT MATTERS: The DGM dimension, cost, and interpretation of the modifier-span contrast are misstated.
WOULD BE WRONG IF: The outside arm retained three covariates by moving, rather than appending, the unmatched modifier.
