VERDICT: unsound

### The live protocol fails its own verifier

SEVERITY: fatal  
QUOTE: Every number below is interpolated from `results/registered-design.json` by `review/emit-protocol.py` and checked by `review/verify-protocol.py`.  
PROBLEM: The current verifier exits with `registered-design.json predates the code in R/` because `R/00-config.R` and `R/02-probe-grid.R` are newer than the export. The document matches its generator, but the generator is reading an export the verifier rejects as stale.  
WHY IT MATTERS: The 350-cell grid, shares, and related conclusions are not the verified output of the current implementation.  
WOULD BE WRONG IF: Those R changes are reverted or every affected probe, export, and protocol is regenerated before this document is treated as current.

### The growth ladder does not implement the prediction's falsification test

SEVERITY: fatal  
QUOTE: It is falsified if coverage of the superpopulation estimand approaches nominal along the ladder.  
PROBLEM: `R/16-analyze.R` merely averages `maic_entropy` coverage by nT across all three links and both anchored settings, then prints three numbers. It defines neither “approaches nominal” nor a trend, tolerance, uncertainty calculation, or verdict. Pooling the identity falsifier with curved links and pooling two different interval constructions can conceal opposite trajectories.  
WHY IT MATTERS: The study's primary prediction cannot be accepted or falsified by the registered software.  
WOULD BE WRONG IF: A registered analysis not present here evaluates the trajectory separately by link and arm with a prespecified criterion and Monte Carlo uncertainty.

### The “partial closure” verdict never measures closure

SEVERITY: fatal  
QUOTE: If it closes part of the deficit and not all, the split is the contribution.  
PROBLEM: The analyzer returns “moment term closes part of the deficit and not all” whenever any `maic_entropy` cell is inside the coverage band. That branch never compares `maic_entropy` with `maic_fixed`, despite computing their paired contrast elsewhere. It can declare partial closure when fixed already covered, when entropy worsened coverage, or when there was no deficit.  
WHY IT MATTERS: One of the two registered substantive conclusions is not the conclusion the software computes.  
WOULD BE WRONG IF: The verdict were based on the paired change from `maic_fixed`, including its direction and Monte Carlo error.

### An incomplete run can receive a substantive verdict

SEVERITY: fatal  
QUOTE: 2000 replicates per cell.  
PROBLEM: `read_run()` rejects extra cell IDs but does not require every registered cell, every replicate, or every method. The decision then ignores convergence and absent method-cell combinations. A partial run containing one successful entropy cell can reach either substantive branch.  
WHY IT MATTERS: Interrupted runs and complete method failure can be reported as scientific results.  
WOULD BE WRONG IF: A wrapper independently proves completion and the analyzer verifies that manifest before making any decision.

### The gate excludes the anchored study on an unmeasured classification margin

SEVERITY: fatal  
QUOTE: Every cell that clears the floor is unanchored ... The largest share reached by ANY anchored cell is 0.0777, against a floor of 0.0791.  
PROBLEM: P2 estimates shares from only 120 calibration replicates and calculates no MCSE, confidence bound, or rerun stability for the gate. The decisive anchored margin is only 0.0014. Several denominator components, including a covariance, are Monte Carlo estimates.  
WHY IT MATTERS: Calibration noise can decide that no anchored cell is worth powering, even though anchoring is central to the target problem. Selection also induces winner's-curse bias among retained cells.  
WOULD BE WRONG IF: An exact calculation or replicated calibration establishes every anchored share below the floor by a margin exceeding the gate's measured uncertainty.

### P2 gates non-normal cells on a normal-model correction, not their omitted variance

SEVERITY: serious  
QUOTE: 350 of 792 realized cells are run: those whose omitted-variance share reaches 0.0791, plus a growth ladder retained regardless of share.  
PROBLEM: P2 computes the numerator with `Omega_normal()`. For `lognormal` and `mixed` covariates, the sampling covariance of means and raw second moments depends on third and fourth joint moments that `Omega_normal()` does not contain. Supplying the transformed Pearson correlation does not repair that.  
WHY IT MATTERS: Non-normal cells are retained or dropped using the ported model's proposed term, while the coverage threshold was derived for the true omitted fraction. The shape comparison is selected on the wrong quantity.  
WOULD BE WRONG IF: `Omega_normal()` is exactly the covariance of the registered moment vector under both transformed laws, or the protocol redefines the gate as screening the model-reported correction rather than actual omission.

### The claimed no-literal-number guarantee does not exist

SEVERITY: serious  
QUOTE: Every number below is interpolated from `results/registered-design.json`.  
PROBLEM: `review/emit-protocol.py` contains substantive literal measurements, including the anchored-share table, 83%, 0.001, 0.238, 0.9933, and the 3200 reference. `R/12-export.R` also hard-codes the historical 102.6 core-hours. The verifier checks equality with the generator, not whether numerical claims came from the export.  
WHY IT MATTERS: The exact stale-number defect the provenance system claims to eliminate remains possible.  
WOULD BE WRONG IF: Those values are generated fields in the live emitter rather than literal text, or an additional audit rejects substantive numeric literals.

### P1's independent check cannot resolve the registered tolerance

SEVERITY: serious  
QUOTE: The rule is validated against independent Monte Carlo ... P1 stops and registers no order if they ever disagree by more than three.  
PROBLEM: The Monte Carlo SE is 7.08e-05, so the three-SE acceptance radius is 2.124e-04, more than twice the 1e-04 quadrature tolerance. The observed quadrature-minus-Monte-Carlo difference is already 1.0321e-04. The tighter stability comparison uses order 128 from the same quadrature implementation.  
WHY IT MATTERS: P1 can register a rule whose independent-reference error exceeds the tolerance used to define truth.  
WOULD BE WRONG IF: A separate independent reference with uncertainty comfortably below 1e-04 certifies the registered order.

### P1 does not establish that its test point is the hardest registered cell

SEVERITY: serious  
QUOTE: Registered order 16, forced by the `cloglog` / `mvnorm` cell.  
PROBLEM: P1 evaluates one fixed parameter vector at means `(0.5, 0.2, 0)`. That is not a registered target population, and the probe does not vary baseline shift, the target-trial parameterization, or the four-covariate outside arm. No analytic bound proves this synthetic point dominates them.  
WHY IT MATTERS: A truth calculation outside the probe's narrow configuration may require a higher order.  
WOULD BE WRONG IF: A derivation establishes that quadrature error is maximized at the probed parameters over the entire registered grid.

### P5 sizes the whole study from one non-representative cell

SEVERITY: serious  
QUOTE: 800 is the smallest value in the grid meeting both.  
PROBLEM: P5 tests only an anchored, logit, mvnormal middle cell with nS 2000 and nT 300. The production grid spans three links, three shapes, source sizes from 500 to 8000, an outside arm, and is overwhelmingly unanchored. Percentile-quantile bias and tail density need not be worst in the P5 cell.  
WHY IT MATTERS: B = 800 can still create method-specific undercoverage elsewhere, which the study would misattribute to the method.  
WOULD BE WRONG IF: A distributional argument makes the quantile error universal after scaling, or a worst-case grid validation shows this cell bounds all registered cells.

### P6 converts an upper uncertainty bound into a point conclusion

SEVERITY: serious  
QUOTE: The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored.  
PROBLEM: The measured worst share is 0.07729, below 0.0791. The 0.0962 figure is the point estimate plus one approximate MCSE, so it supports “cannot establish that it is below,” not “is above.” The worst cross term is negative, meaning omission widens intervals. Under the protocol's own normal-coverage calculation, a 0.01 overcoverage shift requires a share about 0.09799, above even 0.0962.  
WHY IT MATTERS: The asserted P6 finding and the rationale for the oracle correction do not follow from the measurement.  
WOULD BE WRONG IF: The rule were explicitly a conservative non-exclusion rule and the threshold were registered independently of the claimed coverage-shift derivation.

### P6 measures different cells from those to which its conclusion is applied

SEVERITY: serious  
QUOTE: The term is largest on the identity link when the target shares the source's modification in full.  
PROBLEM: P6 evaluates only anchored, mvnormal, inside, zero-shift cells at nT 150 and 600. Neither target size is registered, and the powered grid is almost entirely unanchored with nT 100, 300, or 1000. The later calibration stores covariances for more cells but never evaluates their shares or materiality.  
WHY IT MATTERS: A result from off-grid anchored cells is used to justify correction and attribution throughout a materially different grid.  
WOULD BE WRONG IF: Per-registered-cell calibration also evaluates the signed share and its uncertainty against an appropriate threshold.

### P7 reintroduces the withdrawn estimand-gradient inference

SEVERITY: serious  
QUOTE: The omitted variance is J' Omega J / nT, which is a positive definite form in that gradient, so a gradient bounded away from zero implies an omitted variance bounded away from zero.  
PROBLEM: P7 computes `delta_gradient()`, the gradient of the estimand. Section 1 explicitly says that gradient is about identification and that the estimator's gradient governs its sampling variance. P7 never computes `estimator_gradient()`, and it evaluates a single marginal treatment contrast rather than either registered anchored or unanchored contrast.  
WHY IT MATTERS: The table does not establish that any implemented interval omits a nonzero variance term at beta_EM = 0.  
WOULD BE WRONG IF: The estimator gradient is analytically proven identical to the displayed gradient in these cells and the contrast tested by P7 is the registered contrast.

### The withdrawn P3 variance prediction remains operative in code

SEVERITY: serious  
QUOTE: P3 is retained below as an identification probe, which is what it measures.  
PROBLEM: `R/03-probe-closed-form.R` still computes “ported” versus “true” variance ratios, applies an asserted 5% `headline_survives` threshold, describes itself as able to end the study, and exports direction fields. The runner still requires a P3 output to be finite.  
WHY IT MATTERS: The machine-readable design continues to produce and require the inference the protocol says was withdrawn.  
WOULD BE WRONG IF: Those variance, direction, and headline fields are removed and P3 is limited to its identification measurement.

### The gate's denominator is not generally anchored

SEVERITY: serious  
QUOTE: The denominator is the whole variance of the anchored contrast.  
PROBLEM: P2 explicitly switches to `aI_un`, `J_un`, and `var_g_mu_B` for unanchored cells. All 340 cells above the floor are unanchored, so the denominator selecting the powered grid is chiefly the unanchored contrast's variance.  
WHY IT MATTERS: The sentence assigns the generated shares to the wrong reference quantity.  
WOULD BE WRONG IF: The gate is rerun using the anchored contrast for every cell or the sentence is changed to “each arm's own contrast.”

### The anchored median-share sentence uses the wrong subset

SEVERITY: serious  
QUOTE: In an anchored comparison ... the moment term's median share ranges from 0.0224 to 0.0928 across links.  
PROBLEM: Those are the overall link medians exported from all anchored and unanchored cells. The anchored medians printed immediately above are 0.0079, 0.0100, and 0.0395.  
WHY IT MATTERS: The sentence overstates the moment term in the anchored arm and contradicts the evidence offered for the study's first result.  
WOULD BE WRONG IF: `omitted_share_by_link` is recomputed on anchored cells only and genuinely yields 0.0224 to 0.0928.

### True covariate correlation is not held at 0.3

SEVERITY: serious  
QUOTE: Held fixed: ... a true covariate correlation of 0.3.  
PROBLEM: The DGM fixes the latent Gaussian correlation at 0.3. Transformation changes Pearson correlation in the observed covariates; the protocol itself reports about 0.238 for pairs involving the binary covariate.  
WHY IT MATTERS: Shape is confounded with true observed correlation, contrary to the factor definition and any shape-only interpretation.  
WOULD BE WRONG IF: “True correlation” is explicitly defined as the latent copula parameter rather than observed covariate correlation.

### Section 3 declares the wrong contrast for half the design

SEVERITY: serious  
QUOTE: The contrast is anchored: theta_AC(m_hat) - theta_BC_hat, on the link's own scale.  
PROBLEM: `anchored = False` is a registered core arm. Its code reports `theta_A - g_mu_B` and uses different superpopulation and finite-target truths. Thus the study has two population targets crossed with two contrast structures, not simply the two estimands section 3 defines.  
WHY IT MATTERS: Coverage is pooled and interpreted across different estimands while the estimand section declares only one.  
WOULD BE WRONG IF: The unanchored arm is removed or both contrast-specific estimands are formally registered.

### STC uses the complementary cloglog model

SEVERITY: serious  
QUOTE: `stc` | conditional outcome model, marginalized over the reported law.  
PROBLEM: The DGM generates Y = 1 with survival probability `exp(-exp(eta))` and defines `g(S) = log(-log(S))`. STC fits R's binomial `cloglog`, whose inverse models event probability `1 - exp(-exp(eta))`, directly to that survival-coded response.  
WHY IT MATTERS: STC is misspecified throughout the cloglog arm, so its bias and coverage are not performance of the registered conditional model.  
WOULD BE WRONG IF: Y is recoded as an event indicator or STC uses the corresponding log-log link for survival.

### STC does not implement two registered design dimensions

SEVERITY: serious  
QUOTE: Every method reconstructs the target law from moments assuming a Gaussian copula.  
PROBLEM: In mixed cells STC uses `mvrnorm()`, turning the known binary covariate into an unbounded continuous normal variable rather than using a Gaussian copula with a binary margin. It also hard-codes `assumed_R("borrowed")` in cells labeled `true` and `independence`.  
WHY IT MATTERS: STC rows are mislabeled by correlation setting and do not marginalize over the registered mixed reconstruction.  
WOULD BE WRONG IF: STC is excluded from those factor levels or its reconstruction preserves the registered margins and uses the cell's correlation setting.

### The oracle does not isolate correlation in non-normal cells

SEVERITY: serious  
QUOTE: An arm that exists to isolate the correlation component was injecting a correlation the target does not have.  
PROBLEM: Supplying the true Pearson correlation changes only one input to `Omega_normal()`. In lognormal and mixed cells, the covariance of the reported moment vector also depends on non-normal third and fourth joint moments. Those remain misspecified in `maic_oracle`.  
WHY IT MATTERS: Residual differences cannot be divided cleanly into “correlation” and “identification” components as claimed.  
WOULD BE WRONG IF: The oracle supplies the complete population covariance of the reported moment vector, not only its Pearson correlation.

### Residual failure after `maic_xcov` is not uniquely identification

SEVERITY: serious  
QUOTE: What remains is what identification has to explain.  
PROBLEM: `maic_xcov` retains the normal moment-covariance reconstruction, normal interval approximation, plug-in target-trial variance, finite-sample sandwich error, and a Monte Carlo-calibrated cross term whose uncertainty is ignored. Several of these can cause residual coverage error without being identification bias.  
WHY IT MATTERS: The proposed decomposition cannot support its principal causal attribution.  
WOULD BE WRONG IF: Every remaining variance and approximation component is separately verified negligible or a joint oracle arm removes them.

### The CRN seed key breaks the registered correlation block

SEVERITY: serious  
QUOTE: Cells differing only in the assumed correlation see identical data.  
PROBLEM: `crn_seed()` excludes `corr_assumed` but includes every other grid column, including the derived `ladder` flag. At the middle configuration, `true` cells have `ladder = TRUE` while corresponding borrowed and independence cells have `FALSE`, so their seeds and data differ.  
WHY IT MATTERS: Those correlation contrasts do not isolate an analysis choice on identical data as promised.  
WOULD BE WRONG IF: `ladder` is excluded from the seed key or assigned identically across matched correlation cells.

### Pooled Monte Carlo error ignores intentional cross-cell dependence

SEVERITY: serious  
QUOTE: Monte Carlo error for every method contrast is therefore computed from the per-replicate difference.  
PROBLEM: The within-cell paired SE is correct, but the pooled method contrast then asserts that cells are independent and combines their SEs without covariance terms. Cells differing only in `corr_assumed` intentionally share replicate data, except where the ladder bug breaks sharing.  
WHY IT MATTERS: The pooled MCSE can be understated or overstated and is not clustered on the full registered CRN block.  
WOULD BE WRONG IF: The pooled calculation clusters jointly by replicate and the non-blocked factor combination.

### The all-cells coverage rule is not calibrated for multiplicity

SEVERITY: serious  
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices in these conditions.  
PROBLEM: The decision requires every powered entropy cell's observed coverage to lie in 0.935 to 0.965. Even if true coverage is exactly 0.95 in all 332 powered cells, an exact binomial calculation gives roughly a 45% chance that at least one independent cell falls outside purely from Monte Carlo error.  
WHY IT MATTERS: A correct method has approximately coin-flip odds of failing the sufficiency branch before scientific variation is considered.  
WOULD BE WRONG IF: A simultaneous error rule, multiplicity adjustment, or hierarchical criterion replaces the raw all-cells requirement.

### The fractional crossing is not registered in the protocol

SEVERITY: serious  
QUOTE: `anchored` is crossed with the whole core rather than varied around a middle.  
PROBLEM: “Core” is undefined. The code crosses link, nT, nS, k, anchored, and baseline shift at middle shape, correlation, and modifier span, then varies shape, assumed correlation, and modifier span one at a time with nS and baseline shift fixed. The factor table alone suggests a full crossing and does not disclose which interactions are absent.  
WHY IT MATTERS: Readers cannot determine what comparisons or interactions are estimable from the design of record.  
WOULD BE WRONG IF: The exact crossing and fixed-middle restrictions are added to the authoritative protocol.

### The mixed quadrature pays twice the quoted node count

SEVERITY: minor  
QUOTE: The product rule is used only for the non-normal shapes, at 4,096 nodes for the 3 covariates the design fixes.  
PROBLEM: At order 16, the mixed rule uses 32 split nodes for the binary coordinate and 16 for each continuous coordinate, totaling 8,192 nodes. Only the lognormal product rule uses 4,096.  
WHY IT MATTERS: The generated cost description assigns one shape's node count to both non-normal shapes.  
WOULD BE WRONG IF: The quoted count is explicitly restricted to the unsplit lognormal rule.

### P1 hides a tie in the order-forcing cells

SEVERITY: minor  
QUOTE: Registered order 16, forced by the `cloglog` / `mvnorm` cell.  
PROBLEM: The stored P1 table gives stable order 16 to both cloglog/mvnorm and cloglog/lognormal. The exporter uses `which.max()` and reports only the first tied row.  
WHY IT MATTERS: The stated attribution does not follow from the generated evidence.  
WOULD BE WRONG IF: A tie-breaking analysis shows the lognormal cell actually requires less than 16 under the registered criterion.
