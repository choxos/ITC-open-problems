VERDICT: unsound

### The stated target and the powered study use different estimands
SEVERITY: fatal
QUOTE: The contrast is anchored: theta_AC(m_hat) - theta_BC_hat, on the link's own scale.
PROBLEM: The design crosses anchored and unanchored contrasts, and the protocol states that every cell clearing the floor is unanchored. The powered decision therefore concerns theta_A minus the target B-arm mean, not the anchored contrast registered in the estimand section.
WHY IT MATTERS: The eventual primary conclusion cannot answer the stated anchored PAIC question. Anchoring is not merely a factor level here; it changes the estimand.
WOULD BE WRONG IF: Anchored and unanchored contrasts were explicitly registered as separate co-primary estimands with separate decision rules, and the anchored conclusion were based on anchored production cells.

### The growth ladder tests a regime where the claimed deficit should close
SEVERITY: fatal
QUOTE: The ladder holds every other factor at its middle and walks the target size, and the analysis reports it as the prediction-1 test.
PROBLEM: The ladder fixes nS at 2000 and uses `mvnorm` with the true population correlation. In that setting, means, variances, and correlation identify the target normal law, while target-moment uncertainty shrinks as 1/nT and source variance remains fixed. The relevant omission should therefore disappear as nT grows. The analyzer further averages ladder coverage across identity, logit, cloglog, anchored, and unanchored cells, with no trend criterion or MCSE.
WHY IT MATTERS: The only registered test of “does not close” is constructed to show closing and cannot identify which link or estimand produced its average.
WOULD BE WRONG IF: The ladder preserved nonparametric underidentification, scaled nS with nT as required by the prediction, and analyzed curved links and contrast types separately under a defined trend rule.

### P2 gates cells using a covariance that is not their sampling covariance
SEVERITY: fatal
QUOTE: 350 of 792 realized cells are run: those whose omitted-variance share reaches 0.0791, plus a growth ladder retained regardless of share.
PROBLEM: P2 always uses `Omega_normal()` with correlation 0.3. That is not the covariance of means and raw second moments under the lognormal or mixed laws, and 0.3 is latent rather than the observed mixed-law correlation. P2 also ignores `corr_assumed`, so even independence cells are screened using the true-correlation matrix. It evaluates this matrix using one calibration replicate’s moments.
WHY IT MATTERS: The quantity deciding which 442 cells are discarded is not the variance fraction those cells or their registered methods actually have. The run grid, link summaries, and budget do not follow from the coverage criterion.
WOULD BE WRONG IF: P2 used each DGM’s true moment covariance and each cell’s registered correlation setting, or the protocol explicitly defined the gate as a working-normal quantity without translating it into actual coverage.

### The registered conclusion can pass an incomplete or selectively converged run
SEVERITY: fatal
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices in these conditions.
PROBLEM: `read_run()` rejects extra cell IDs but accepts missing cells, incomplete files, and reused IDs whose factor assignments changed. Failed replicates produce no row, resume advances from the largest successful replicate number, and coverage is calculated only among finite intervals. The final decision applies `all(ent$in_band)` without requiring complete cells or acceptable convergence.
WHY IT MATTERS: The software can declare success “across the grid” after difficult cells or consequential replicates disappear.
WOULD BE WRONG IF: A pre-analysis guard required every current grid cell, every replicate index, matching factor values, and a registered convergence threshold before evaluating coverage.

### Residual noncoverage is not an identification decomposition
SEVERITY: fatal
QUOTE: The difference from `maic_entropy` is the cross term, and what remains is what identification has to explain.
PROBLEM: After adding the calibrated cross term, residual coverage error can still arise from finite-sample weighting bias, source-sandwich error, Wald approximation, target-effect variance estimation, nonnormal moment-covariance misspecification, failed fits, and calibration error. Coverage differences are also nonlinear and do not form an additive variance decomposition.
WHY IT MATTERS: The study’s central interpretation can label ordinary estimator and interval errors as failure of moment identification.
WOULD BE WRONG IF: Every non-identification component had been independently validated as negligible at the relevant noise floor and the decomposition were performed on an additive bias or variance scale rather than coverage.

### P7 measures neither the registered contrast nor its omitted variance
SEVERITY: serious
QUOTE: This is also a finding rather than a repair: on a curved link, target-moment uncertainty does not need effect modification to bite.
PROBLEM: P7 calls `delta_gradient()` for the single A-versus-C estimand. It does not construct either full anchored or unanchored contrast and does not use the estimator gradient that governs sampling variance. Section 1 has already withdrawn the interpretation of the estimand gradient as variance evidence.
WHY IT MATTERS: The revised null control and the substantive “no effect modification needed” conclusion are inferred from a measurement of another object.
WOULD BE WRONG IF: The control were explicitly limited to local dependence of the single-trial estimand, without claiming anything about omitted variance or the registered contrast.

### P6 turns uncertainty about the threshold into evidence of exceeding it
SEVERITY: serious
QUOTE: The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored.
PROBLEM: The largest point share is 0.07729, below 0.0791. The reported 0.0962 is `share + mcse`, which means the probe cannot establish negligibility, not that the term is above the threshold. Establishing “above” would require a lower uncertainty bound above the cutoff. The worst cross term is also negative, while 0.0791 was derived for omitting positive variance; a 1% overcoverage shift requires a different fraction, about 0.098. The coded covariance MCSE is itself only a product-of-SDs approximation and ignores covariance among components and uncertainty in the denominator.
WHY IT MATTERS: The measurement does not support the affirmative claim that motivated the oracle cross-covariance arm.
WOULD BE WRONG IF: A valid signed uncertainty analysis placed the lower bound above the correctly derived overcoverage or undercoverage threshold.

### P6 does not measure the cross term used by the powered grid
SEVERITY: serious
QUOTE: The term is largest on the identity link when the target shares the source’s modification in full.
PROBLEM: P6 examines anchored, inside, multivariate-normal cells at nT 150 and 600, neither of which is registered. It omits unanchored contrasts, baseline shifts, nonnormal shapes, outside modifiers, and nT 100, 300, and 1000. Every floor-clearing powered cell is unanchored and uses Cov(m, g_mu_B), not the Cov(m, theta_BC) measured by P6.
WHY IT MATTERS: “Largest” is not established over the registered grid, and the probe does not justify carrying the term in the study’s primary arm.
WOULD BE WRONG IF: Those probe cells were proven upper bounds and the anchored and unanchored covariance shares were invariant.

### P1’s claimed independent Monte Carlo validation does not exist
SEVERITY: serious
QUOTE: The rule is validated against independent Monte Carlo, not against itself: it sits within one Monte Carlo standard error of a 4e7-draw estimate.
PROBLEM: P1 contains no Monte Carlo calculation, estimate, standard error, or saved Monte Carlo artifact. Its executable reference is order 128 from the same quadrature implementation.
WHY IT MATTERS: The numerical truth is certified by the same machinery being tested, so quadrature bias could appear as method bias.
WOULD BE WRONG IF: A reproducible 40-million-draw artifact and its standard error existed and were tied to the current implementation.

### P5’s supposedly nested comparison redraws part of every interval
SEVERITY: serious
QUOTE: The limits at every B [are] read from nested subsamples of one draw set so the comparison is paired.
PROBLEM: The transported-effect draws are nested, but every call to `draw_anchored()` generates a new independent target-effect noise vector. Consequently, the B = 50 through 800 intervals are not prefixes of the B = 3200 anchored-contrast draw set.
WHY IT MATTERS: The advertised paired comparison contains extra resampling noise precisely where B is selected near a threshold.
WOULD BE WRONG IF: The target-effect draws were generated once at B = 3200 and the same prefixes were used for every smaller B.

### The global B is sized in one nonprimary cell using an asserted width cutoff
SEVERITY: serious
QUOTE: 800 is the smallest value in the grid meeting both.
PROBLEM: P5 uses one anchored, inside, multivariate-normal logit cell, while the powered grid is unanchored and spans other links, shapes, and sample sizes. B = 400 already passes the coverage criterion; it is rejected only because estimated width bias is 1.154% against a typed 1% cutoff. No MCSE or measured noise-floor derivation is supplied for that width comparison, and B = 3200 is not itself shown to have converged.
WHY IT MATTERS: The constant responsible for virtually the entire 647.7 core-hour budget is selected by evidence from the wrong arm and an uncertainty-free threshold.
WOULD BE WRONG IF: The chosen cell were demonstrated to upper-bound resampling error across the grid and the width tolerance and reference size were independently derived and uncertainty-adjusted.

### B = 800 means attempted draws, not usable draws
SEVERITY: serious
QUOTE: `maic_perturb` | percentile interval from resampling, B = 800.
PROBLEM: Failed perturbation refits become NA, are silently removed, and `limits_from_draws()` accepts an interval with as few as 20 finite draws. Neither P5 nor production records or enforces the number of successful draws.
WHY IT MATTERS: Difficult cells can report an interval based on far fewer than 800 selected successful refits, invalidating both the quantile precision calculation and convergence reporting.
WOULD BE WRONG IF: Every registered cell had 800 successful draws or a guard required and reported a prespecified minimum close to 800.

### STC uses the wrong survival link
SEVERITY: serious
QUOTE: `stc` | conditional outcome model, marginalized over the reported law.
PROBLEM: The DGM generates Y = 1 with survival probability exp(-exp(eta)) and defines g(S) = log(-log(S)). R’s binomial `cloglog` family instead has inverse link 1 - exp(-exp(eta)), appropriate to an event probability. STC fits that link directly to the survival-coded response.
WHY IT MATTERS: The STC conditional model is misspecified throughout the cloglog arm, so its bias and coverage cannot be interpreted as method performance.
WOULD BE WRONG IF: Y were event-coded as 1 - S or STC used the corresponding log-log link for survival.

### The main pooled MCSE ignores the registered correlation blocks
SEVERITY: serious
QUOTE: Monte Carlo error for every method contrast is therefore computed from the per-replicate difference.
PROBLEM: The dedicated borrowed-versus-true comparison is paired, but the main pooled fixed, entropy, oracle, and xcov contrasts combine cell-level MCSEs under an explicit independence assumption. Cells differing only in `corr_assumed` share the same simulated data and are not independent.
WHY IT MATTERS: Precision for the primary pooled method contrasts can be materially misstated despite the protocol claiming every contrast respects the blocking.
WOULD BE WRONG IF: Pooling clustered all correlation-setting cells by their shared replicate block.

### The coverage decision uses the wrong MC error twice
SEVERITY: serious
QUOTE: The error 2000 replicates actually deliver is 0.004873, and that is the figure any claim about resolving a coverage difference is judged against.
PROBLEM: 0.004873 is the binomial MCSE of one coverage estimate at exactly 0.95. A paired coverage difference has cell-specific MCSE based on the disagreement indicators, which `R/16-analyze.R` calculates separately. The final rule also requires every one of 332 powered cells to fall in a pointwise 0.935 to 0.965 band. Even a truly 0.95 method would have about a 45% chance of at least one failure across 332 independent cells; no simultaneous calibration is provided.
WHY IT MATTERS: Both the detectable-shift rationale and the all-cell verdict have uncontrolled operating characteristics.
WOULD BE WRONG IF: The 0.004873 statement were limited to a single marginal coverage estimate and the across-grid rule had a validated simultaneous error rate.

### The probes advertised as safeguards do not gate production
SEVERITY: serious
QUOTE: A nonzero identity gradient is an implementation defect.
PROBLEM: `probes_done()` requires only four finite scalar fields. It does not require `P3_identity_ok`, P5, P6, or P7 to pass. P1 can record a finite order when one cell is unstable because unstable cells are merely printed and ignored when the maximum is taken. Conversely, the runner still requires `P3_MAX_REL_ERR` from the withdrawn variance interpretation.
WHY IT MATTERS: Production can proceed after the stated falsifiers fail, while a revoked measurement remains an operative prerequisite.
WOULD BE WRONG IF: The runner enforced every applicable probe verdict, stopped on any unstable P1 cell, and removed the withdrawn P3 variance field from its admission checks.

### The claimed number-provenance guarantee is not currently true
SEVERITY: serious
QUOTE: Every number below is interpolated from results/registered-design.json by review/emit-protocol.py and checked by review/verify-protocol.py.
PROBLEM: The generator hardcodes current-result figures including the anchored/unanchored share table, 83%, the 40-million-draw claim, and several historical deviations. They are not read from the JSON. Moreover, the generator currently reproduces the protocol byte-for-byte, but the full verifier exits with status 1 because `registered-design.json` predates `R/16-analyze.R`.
WHY IT MATTERS: Byte identity cannot provide the asserted no-typed-number guarantee, and the project’s freshness guard presently refuses to certify the draft.
WOULD BE WRONG IF: Every scientific numeral were derived or explicitly classified as a fixed design constant, and the complete verifier passed against current code.

### The mixed-arm node count is understated
SEVERITY: minor
QUOTE: The product rule is used only for the non-normal shapes, at 4,096 nodes for the 3 covariates the design fixes.
PROBLEM: At order 16, lognormal uses 16 cubed = 4,096 nodes, but the mixed arm uses 32 nodes for its split coordinate and 16 for each remaining coordinate, totaling 8,192.
WHY IT MATTERS: The computational description is wrong for one of the two nonnormal arms.
WOULD BE WRONG IF: The 4,096-node statement were explicitly limited to the lognormal arm.
