VERDICT: unsound

### The named design authority describes a different study

SEVERITY: fatal  
QUOTE: The design is in `DESIGN.md`.  
PROBLEM: `DESIGN.md` says the probes have not run, registers order 48, 176 cells, a 4% floor, `B = 50`, an anchored-only design, an operative second prediction, and ML-NMR. The generated protocol says the opposite on each point. These are active design sections, not a historical appendix.  
WHY IT MATTERS: There is no unique preregistration to freeze. After results, either document could be invoked as the governing design.  
WOULD BE WRONG IF: `DESIGN.md` were explicitly archived and the protocol named a different, internally consistent design authority.

### The retained study is unanchored and includes an undisclosed baseline-shift factor

SEVERITY: fatal  
QUOTE: The contrast is anchored: theta_AC(m_hat) - theta_BC_hat, on the link's own scale.  
PROBLEM: `R/00-config.R` and `build_grid()` cross `anchored = TRUE, FALSE` and `baseline_shift = 0, 0.5`, although neither factor appears in the protocol table. More decisively, `results/xcov.rds` is generated from the unique retained P2 combinations and contains 164 keys, all with `anchored = FALSE`, including baseline-shifted keys. The actual estimator is therefore theta_A minus the target B-arm mean, not the stated anchored contrast.  
WHY IT MATTERS: The grid no longer studies the anchored PAIC problem. The baseline shift also creates a separate absolute-risk transport bias that can be mistaken for moment-identification failure.  
WOULD BE WRONG IF: The saved calibration were not derived from the current `P2_grid`, or that grid actually retained anchored cells despite `xcov_combos()` taking all its unique target-side combinations.

### The runner cannot execute retained `outside` cells

SEVERITY: fatal  
QUOTE: Two, and **both are computed on every replicate** by `R/15-run.R`.  
PROBLEM: `modifier_span = "outside"` gives `pars$beta_em` four elements. The runner nevertheless calls `population_means(shape = ...)` with its default three covariates and passes `sigma = rep(1, N_COVARIATE)`, also length three, into the superpopulation truth. The normal-law truth then attempts matrix operations between a four-element coefficient vector and a 3 by 3 covariance matrix. Retained `outside` combinations are present in the saved calibration.  
WHY IT MATTERS: The registered run stops when it reaches an `outside` cell, before producing the promised grid.  
WOULD BE WRONG IF: The runner supplied `p = length(pars$beta_em)` and a matching sigma vector, or no `outside` cell were retained.

### The withdrawn variance interpretation remains operative

SEVERITY: fatal  
QUOTE: A mismatch between those two gradients indicates identification bias, not an incorrect variance.  
PROBLEM: Later sections of `DESIGN.md` still assert that the gradient difference is exactly the ported variance error. `R/03-probe-closed-form.R` still computes `v_ported / v_true`, decides whether the “headline survives,” and writes that decision. The exporter still records interval-direction labels. The runner only requires a finite `P3_MAX_REL_ERR`; it does not require the identity check or withdrawn headline decision to pass.  
WHY IT MATTERS: The same measurement has two incompatible registered interpretations, allowing the eventual result to be called either variance failure or identification failure.  
WOULD BE WRONG IF: The variance interpretation and its decision fields were explicitly historical, removed from the active design and software, and unable to affect reporting.

### P7 measures a component contrast, not the registered anchored estimand

SEVERITY: fatal  
QUOTE: **That is false on both curved links**, and a correct implementation would have failed it.  
PROBLEM: P7 calls `delta_gradient()` for one trial’s marginal treatment contrast. It never constructs the anchored truth, Delta_AC(F_T) minus Delta_BC(F_T). With beta_EM set to zero, baseline shift zero, and otherwise identical source and target parameters, the implemented anchored truth is Delta(pars) minus itself and is exactly zero on every link. Moreover, an estimand gradient does not measure the estimator’s omitted sampling variance, as the protocol’s withdrawal already concedes.  
WHY IT MATTERS: The probe revokes a potentially valid anchored null control and announces a substantive finding from a measurement of another quantity.  
WOULD BE WRONG IF: The registered control concerned the single source-trial contrast rather than the anchored contrast, or the two trial contrasts remained different under the stated null.

### P2 selects the run grid using the wrong target-moment covariance

SEVERITY: fatal  
QUOTE: **340 of 792 realized cells** clear a floor of 0.0791 and are run.  
PROBLEM: P2 calculates `v_omit` with `Omega_normal()` using latent rho = 0.3 and the mean and SD from the first calibration replicate. That covariance formula is valid for normal moments. It is not the sampling covariance of means and raw second moments under the `lognormal` law, nor of binary and continuous moments under `mixed`; those require different third and fourth moments and different observed correlations.  
WHY IT MATTERS: The quantity used to retain or discard every non-normal cell is not its true omitted-variance share. The 340-cell grid, its link summaries, and its cost can all be wrong.  
WOULD BE WRONG IF: The gate were explicitly intended to use a normal working-model variance rather than the true omitted sampling variance, or `Omega_normal()` were valid for all three generated laws.

### The registered conclusion has no executable decision rule

SEVERITY: fatal  
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices *in these conditions* and the study reports that as a negative result about its own prediction.  
PROBLEM: “Across the grid” is not defined as every cell, a majority, a primary subset, or a pooled contrast. `DESIGN.md` supplies an older primary-cell rule, but `R/16-analyze.R` does not implement it. Its performance output discards link, k, correlation, anchoring, and baseline-shift fields, then merely counts in-band cells and averages contrasts over the whole retained grid.  
WHY IT MATTERS: The software can produce summaries but cannot determine the preregistered verdict. The success criterion can be chosen after inspecting results.  
WOULD BE WRONG IF: Another declared analysis program applies an exact primary-cell and aggregation rule to the saved results.

### P6’s stated verdict is numerically reversed

SEVERITY: serious  
QUOTE: Measured against the same floor: **the worst cell reaches 0.0962 including Monte Carlo error, against a floor of 0.0791. It does not clear it.**  
PROBLEM: 0.0962 exceeds 0.0791 by 0.0171. `R/13-probe-crosscov.R` defines this value as `share + mcse` and prints “AT OR ABOVE THE FLOOR; the cross term must be carried.” `p6_ok = false` means the negligibility check failed. The generator and verifier convert that failure into the opposite prose.  
WHY IT MATTERS: A correctly generated number is being cited as evidence for the reverse conclusion, precisely the remaining failure mode the generator cannot prevent.  
WOULD BE WRONG IF: 0.0962 were below 0.0791, or “does not clear” were explicitly defined to mean “does not establish that the term is below the floor.”

### P6’s “worst cell” is not a registered-grid cell

SEVERITY: serious  
QUOTE: The term is largest on the identity link when the target shares the source’s modification in full, and it does **not** shrink as the target grows.  
PROBLEM: P6 examines only 18 anchored, inside, multivariate-normal cells at nT = 150 or 600, nS = 2000, and k in 0, 0.25, or 1. Neither target size is registered, and the probe omits k = 0.5, both non-normal shapes, `outside`, baseline shift, and the wholly unanchored retained grid. Production `maic_xcov` instead uses Cov(m, g_mu_B) in those unanchored cells.  
WHY IT MATTERS: The probe neither finds the worst registered cell nor measures the covariance correction actually used by the retained study.  
WOULD BE WRONG IF: Those 18 cells formed a proven upper bound for every registered arm and the anchored and unanchored covariance shares were invariant.

### P1’s claimed independent validation does not exist

SEVERITY: serious  
QUOTE: The rule is validated against **independent Monte Carlo**, not against itself: it sits within one Monte Carlo standard error of a 4e7-draw estimate.  
PROBLEM: P1 contains no Monte Carlo calculation, estimate, standard error, or saved Monte Carlo artifact. Its executable reference is another application of the same quadrature at order 128. The 4e7 claim appears only in comments and generated prose, and the verifier does not check it. P1 also tests only three-covariate component contrasts at one parameter setting, not the four-covariate `outside`, baseline-shifted, or unanchored truths.  
WHY IT MATTERS: The registered tolerance for the simulation truth is unsupported in important retained arms. Bias from numerical truth could be reported as method bias.  
WOULD BE WRONG IF: A reproducible 4e7-draw artifact with its standard error existed and the untested arms had a demonstrated convergence bound at order 16.

### B = 800 is selected by an asserted one-cell width rule

SEVERITY: serious  
QUOTE: **800** comes from measuring the corrected interval against an independent B = 3200 reference.  
PROBLEM: B = 400 already passes the coded coverage criterion: absolute difference plus one MCSE is 0.008951, below 0.01. It is rejected only because its estimated width bias is 1.154%, just beyond the typed `WIDTH_TOL = 1%`. No MCSE is computed for that width comparison and the 1% threshold is not derived from a measured noise floor. P5 also uses one anchored, inside, multivariate-normal logit cell, while the retained grid is unanchored and spans other links, shapes, source sizes, and target sizes.  
WHY IT MATTERS: The study’s dominant cost lever and 598.8 core-hour budget rest on an unregistered threshold measured in the wrong arm.  
WOULD BE WRONG IF: The 1% width tolerance were independently derived and uncertainty-adjusted, and this cell were proven to upper-bound resampling error over the retained grid.

### P2 hard-cuts noisy pilot shares without measuring their uncertainty

SEVERITY: serious  
QUOTE: The floor is **solved from the criterion, not asserted to follow from it**.  
PROBLEM: The floor itself is derived, but the share compared with it is estimated from only 120 calibration replicates. Its source variance, cross covariance, average gradient, and target variance receive no MCSE, confidence bound, or stability analysis before cells are retained or dropped. `N_CAL_REP = 120` is asserted rather than sized.  
WHY IT MATTERS: Cells near 0.0791 can be included or excluded by pilot noise, making the registered grid and selective scope unstable.  
WOULD BE WRONG IF: Every cell were demonstrably far enough from the floor that uncertainty could not change its classification.

### The registered coverage controls cannot stop the run

SEVERITY: serious  
QUOTE: If it does not, the design has no signal to detect and no comparison downstream is interpretable.  
PROBLEM: The runner and analyzer never evaluate the positive-control undercoverage rule, the identity-link coverage falsifier, or the original source-variance null control. No production cell sets the source beta_EM to zero; k = 0 only removes target-trial modification. `probes_done()` does not require P7 or a passing P3 identity result.  
WHY IT MATTERS: Results can be interpreted after the controls that were supposed to invalidate them have failed or were never run.  
WOULD BE WRONG IF: A declared pre-analysis guard evaluates all three controls and aborts interpretation on failure.

### Failed replicates disappear from convergence and coverage

SEVERITY: serious  
QUOTE: 2000 replicates per cell.  
PROBLEM: A failed replicate or estimator returns no row. Resume advances from the maximum successful replicate index, so an earlier failed index is never revisited. The analyzer then sets `n_rep = nrow(z)` and computes convergence among those surviving rows, rather than against 2000 attempts. It also accepts missing cells and incomplete cell files.  
WHY IT MATTERS: A method failing on consequential data can report 100% convergence and coverage conditional on success, with an understated MCSE.  
WOULD BE WRONG IF: Every method emitted an explicit success or failure record for every registered cell and replicate, and completeness were asserted before analysis.

### The registered ADEMP analysis is still absent

SEVERITY: serious  
QUOTE: Per cell: bias against the superpopulation estimand and against the finite-target estimand separately; empirical SD; mean estimated SE; the ratio of the two; 95% interval coverage and its two-sided departure from nominal; interval width; convergence rate.  
PROBLEM: `R/16-analyze.R` does not calculate empirical SD, mean estimated SE, their ratio, or the registered bootstrap MCSE for that ratio. It computes finite-target bias and coverage but supplies no MCSE for either, despite the separate claim that every measure carries one.  
WHY IT MATTERS: Coverage cannot be decomposed into bias, variance-estimation error, and compensating over-width, which is essential to the study’s proposed attribution.  
WOULD BE WRONG IF: A separate declared analyzer produces and saves all registered measures and MCSEs.

### Correlation-setting MCSE is neither paired nor correctly pooled

SEVERITY: serious  
QUOTE: Common random numbers block `corr_assumed, variance_method`, so cells differing only in the assumed correlation see identical data. Monte Carlo error for every method contrast is therefore computed from the **per-replicate difference**.  
PROBLEM: Correlation settings have different `cell_id` values. `paired_contrast()` splits on `cell_id`, so it never forms true-versus-borrowed-versus-independence differences. The pooled calculation then explicitly assumes cells are independent, although correlation-setting cells share data and are correlated by construction.  
WHY IT MATTERS: The MCSE needed for the claimed correlation attribution is unavailable, while the pooled MCSE can be wrong.  
WOULD BE WRONG IF: Analysis grouped correlation settings under a block key that excludes `corr_assumed` and retained their replicate pairing.

### The perturbation method is put into the paired test it is said to avoid

SEVERITY: serious  
QUOTE: **`maic_perturb` is not in that set and is not in the paired test.**  
PROBLEM: `R/16-analyze.R` explicitly includes `c("maic_perturb", "maic_entropy")` in the list passed to `paired_contrast()`. No separate perturbation test exists.  
WHY IT MATTERS: The registered distinction between a variance-formula comparison and a procedure comparison is revoked in executable analysis.  
WOULD BE WRONG IF: That contrast were removed from `paired_contrast()` and analyzed under a separately specified procedure-level rule.

### STC’s interval is not for its marginalized estimator

SEVERITY: serious  
QUOTE: `stc` | conditional outcome model, marginalized over the reported law.  
PROBLEM: The marginalized contrast depends on the intercept, treatment coefficient, prognostic coefficients, interactions, and target-law simulation. STC reports only `sqrt(vcov(fit)["A","A"] + V_target)`, omitting the other coefficient covariances, target-summary uncertainty, and integration noise. For the survival arm it also fits R’s `cloglog`, which models log[-log(1-p)], to a response generated with p equal to survival, while the study’s estimand uses log[-log(p)].  
WHY IT MATTERS: STC coverage is not coverage of its reported marginal estimand and cannot be interpreted as a comparator result.  
WOULD BE WRONG IF: The marginal contrast reduced exactly to coefficient A and the survival indicator were event-coded, or a full delta method or bootstrap supplied the interval.

### The “true correlation of 0.3” is latent, and the oracle is not an oracle off normality

SEVERITY: serious  
QUOTE: Held fixed: 3 covariates (4 in the `outside` arm, which is crossed with `mvnorm` only), overlap at a standardized difference of 0.4 on **every** covariate, and a true covariate correlation of 0.3.  
PROBLEM: The code fixes the latent Gaussian correlation at 0.3. The protocol itself later reports that dichotomization yields observed correlations near 0.238, and the lognormal transformation also changes Pearson correlations. Supplying the observed correlation to `Omega_normal()` still does not supply the true covariance of raw moments under lognormal or mixed laws because its third- and fourth-moment formulas remain Gaussian.  
WHY IT MATTERS: Covariate shape changes correlation as well as shape, and `maic_oracle` cannot isolate correlation misspecification from higher-moment covariance misspecification.  
WOULD BE WRONG IF: All transformations preserved Pearson correlation 0.3 and the oracle supplied the complete true covariance of the reported moment vector.

### Residual noncoverage is not uniquely attributable to identification

SEVERITY: serious  
QUOTE: The difference from `maic_entropy` is the cross term, and what remains is what identification has to explain.  
PROBLEM: After adding the oracle cross term, residual noncoverage can still arise from finite-sample weighting bias, source-sandwich error, target-effect delta approximation, non-normal Wald behavior, noisy cross-covariance calibration, failed fits, the hidden baseline shift, and the incorrect non-normal moment covariance. None is independently cleared at the relevant noise floor.  
WHY IT MATTERS: The planned decomposition can label ordinary interval or DGM defects as evidence that target moments fail to identify the estimand.  
WOULD BE WRONG IF: Every non-identification component had a validated control showing negligible contribution in each interpreted cell.

### The claimed verifier is currently failing

SEVERITY: serious  
QUOTE: Every number below is interpolated from `results/registered-design.json` by `review/emit-protocol.py` and checked by `review/verify-protocol.py`.  
PROBLEM: The generator currently reproduces `protocol.md` byte-for-byte, but running the full verifier exits with status 1 before its assertions because `registered-design.json` predates `R/15-run.R`. Its message says every assertion would therefore be checked against a stale export.  
WHY IT MATTERS: Byte identity does not establish that the protocol describes the current implementation, and the project’s own freshness guard presently rejects that claim.  
WOULD BE WRONG IF: The artifacts were regenerated from the current code and the verifier then exited successfully.

### The mixed quadrature node count is understated

SEVERITY: minor  
QUOTE: The product rule is used only for the non-normal shapes, at 4,096 nodes for the 3 covariates the design fixes.  
PROBLEM: At order 16, lognormal uses 16 cubed = 4,096 nodes, but `mixed` uses `split_normal_rule()`, which returns 2n nodes for its first coordinate. Its count is therefore 32 times 16 times 16 = 8,192.  
WHY IT MATTERS: The stated computational explanation is wrong for one of the two non-normal arms.  
WOULD BE WRONG IF: The 4,096-node statement were explicitly limited to the smooth lognormal arm.

### The method count is internally inconsistent

SEVERITY: minor  
QUOTE: The data-generating mechanism, both truths, the gradient machinery, five of six methods, seven probes, the replicate runner, the analysis with clustered Monte Carlo error, and the export and verification harness.  
PROBLEM: The protocol’s method table lists six implemented methods: four shared-fit MAIC variants, perturbation, and STC. ML-NMR is an additional missing method. On the protocol’s own terminology, that is six of seven, not five of six.  
WHY IT MATTERS: It obscures whether `maic_xcov` is a registered method, a diagnostic decomposition, or an uncounted post-design addition.  
WOULD BE WRONG IF: The counting convention explicitly classified one listed row as something other than a method.
