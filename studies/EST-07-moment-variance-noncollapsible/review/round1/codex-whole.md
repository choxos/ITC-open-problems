VERDICT: unsound

### The central probe compares the variance of one statistic with the derivative of another
SEVERITY: fatal
QUOTE: What the variance of the estimand requires is the gradient of the estimand.
PROBLEM: The superpopulation estimand is fixed across replicates. Sampling variance from estimated target moments is governed by the gradient of the actual MAIC estimator, not by how the estimand changes along a chosen parametric family of covariate laws. A mismatch between those gradients indicates identification bias, not an incorrect variance for the MAIC estimator.
WHY IT MATTERS: P3 does not establish that either published variance estimator is wrong, so the central proposition and all claimed variance ratios lack their stated interpretation.
WOULD BE WRONG IF: The point estimator were the plug-in statistic \(\Delta(F_{\hat m,\hat s})\) whose gradient P3 computes; the code instead estimates a moment-balanced MAIC contrast.

### P3 combines gradients and covariance matrices expressed in different coordinates
SEVERITY: fatal
QUOTE: The ported gradient is wrong on a curved link, and its direction differs by link.
PROBLEM: `delta_gradient()` differentiates with respect to means and SDs, while `estimator_gradient()` differentiates with respect to means and raw second moments, and `Omega_normal()` is the covariance of means and raw second moments. P3 compares and multiplies these vectors without the required Jacobian. Applying the transformation changes the logit reference variance from \(6.066\times10^{-5}\) to \(8.125\times10^{-5}\), reducing the displayed ratios to about 0.989 to 1.074 rather than 1.324 to 1.438. For cloglog it changes \(5.849\times10^{-5}\) to \(4.147\times10^{-5}\), putting the ratios above one rather than below one.
WHY IT MATTERS: The headline gap, its size, and its link-specific direction are artifacts of a unit mismatch that the identity control cannot reveal because the identity-link SD gradient is zero.
WOULD BE WRONG IF: `target_reported$m` contained SDs, or the code transformed the estimand gradient to raw-moment coordinates; it contains raw squares and performs no transformation.

### The registered truth is not the estimand returned by the methods
SEVERITY: fatal
QUOTE: Primary. The target-superpopulation marginal effect, \(\Delta(F_T) = g(\int \mu_1 dF_T) - g(\int \mu_0 dF_T)\).
PROBLEM: `delta_superpopulation()` and `delta_sample()` compute only the transported A-versus-C contrast. Every MAIC and STC point estimate instead returns A-versus-C minus the sampled B-versus-C effect. No function constructs the corresponding true anchored A-versus-B superpopulation or finite-target contrast.
WHY IT MATTERS: Bias and coverage cannot be calculated against the stated truth; comparing the indirect estimators with the implemented \(\Delta\) would include the entire B-versus-C effect as apparent bias.
WOULD BE WRONG IF: An unlisted runner constructs both true arm contrasts and subtracts them before analysis; no such code exists in the study.

### The shared target-trial variance is approximately fourfold too small
SEVERITY: fatal
QUOTE: All four MAIC variants share one weight fit and one sandwich, so they differ in the variance they report and in nothing else, which makes the paired comparison a comparison of intervals.
PROBLEM: Every interval uses `var_theta_BC()`, which assumes equal arms, hard-codes \(p=0.5\), and applies incorrect delta-method formulas. At \(n_T=300\), \(k=0.25\), the DGM implies a logit variance near 0.0545 while the code returns 0.0133; for cloglog it implies about 0.0252 while the code returns 0.00641. The identity formula also omits outcome variation induced by covariates.
WHY IT MATTERS: All methods will substantially undercover for a reason unrelated to target-moment uncertainty, invalidating the primary coverage comparisons and the identity falsifier.
WOULD BE WRONG IF: The B-versus-C estimate were fixed or its variance were supplied externally; the code samples target outcomes and estimates it anew in every replicate.

### The target-moment and target-effect covariance is omitted
SEVERITY: fatal
QUOTE: The omitted variance is set by \(n_T\) and the retained variance by \(n_S\).
PROBLEM: Target moments and the B-versus-C effect are calculated from the same target participants, so their covariance contributes to the variance of the anchored difference. The code merely adds `V_BC` and `V_T`. It defines the identity-link expression \((1-2k)\operatorname{Var}_T(\tau)/n_T\), which contains this covariance, but never calls it. Consequently the implemented correction is independent of the operative \(k\) mechanism.
WHY IT MATTERS: Even a correctly calculated positive target-summary term would not produce the registered interval variance except at special settings such as \(k=0\).
WOULD BE WRONG IF: The covariate summaries and B-versus-C effect came from independent target samples; `sample_replicate()` derives both from the same `xt`.

### The perturbation method is not the cited perturbation algorithm
SEVERITY: fatal
QUOTE: `maic_perturb` (the perturbation port)
PROBLEM: The cited algorithm resamples the source observations, perturbs the target summaries, refits the estimator, and uses empirical percentile limits. The implementation fixes the source data, perturbs only target moments, takes their variance, and forms a normal interval. It also reports `pv + V_BC`, omitting the source sandwich variance that the protocol says every MAIC method carries. See the cited method’s [Algorithm 1 description](https://asset.library.wisc.edu/1711.dl/V7ZSLM5ROCECY8B/R/file-e2208.pdf).
WHY IT MATTERS: `maic_perturb` cannot test whether the published port succeeds, and P4 and P5 measure the cost and resampling error of a different procedure.
WOULD BE WRONG IF: A cited variant proved target-only perturbation plus the source variance equivalent and the code added that source variance; neither condition holds.

### The allegedly complete study software cannot run the registered study
SEVERITY: fatal
QUOTE: The design is in `DESIGN.md`, the code and all five probes are complete.
PROBLEM: There is no replicate runner, result writer, analysis program, clustered MCSE calculation, performance-measure implementation, control-arm implementation, or ML-NMR implementation. `estimate_all()` returns only four MAIC rows and STC.
WHY IT MATTERS: The registered grid, both truths, decision rule, controls, ML-NMR comparison, and final analyses cannot currently be executed.
WOULD BE WRONG IF: Those components exist as declared parts of the registration outside this study directory; none are referenced by the protocol or local code.

### The interval-direction labels are reversed
SEVERITY: serious
QUOTE: An analyst reading a logit MAIC would see intervals too narrow while one reading a Weibull MAIC would see them too wide.
PROBLEM: The displayed ratio is `v_ported / v_true`. Ratios of 1.324 to 1.438 mean the ported variance is larger and its intervals wider; ratios of 0.7641 to 0.8321 mean it is smaller and its intervals narrower. The exporter and verifier encode the opposite mapping.
WHY IT MATTERS: The document states the reverse of the direct practical consequence of its own generated numbers.
WOULD BE WRONG IF: The ratio were `v_true / v_ported`; the code explicitly calculates `v_ported / v_true`.

### The identity probe does not perform the validation attributed to it
SEVERITY: serious
QUOTE: The identity-link case behaves as it must, which is what makes the above evidence about curvature rather than about the implementation.
PROBLEM: P3 only requires the maximum gradient gap to shrink by a factor of three. It never checks the full MIS-03 variance, the target-effect covariance, interval coverage, or either port. Its convergence loop also records no Monte Carlo SE, despite the claim that the final gap is within one SE.
WHY IT MATTERS: The actual wrong target variance and missing covariance pass this guard, so it cannot distinguish curvature from an incorrect port.
WOULD BE WRONG IF: A separate executable check compares each complete interval variance with the identity-link closed form and records the final gap’s MCSE; no such check exists.

### The cell gate measures the wrong effect and ignores two registered factors
SEVERITY: serious
QUOTE: 176 of 288 realized cells clear a 0.04 floor and are run; the rest are dropped rather than run, because a cell whose effect cannot be distinguished from zero at 2000 replicates consumes budget and returns nothing.
PROBLEM: P2 gates on the positive quantity \(J^\top\Omega J/n_T\). It does not include the covariance with the target B-versus-C estimate, so it is effectively independent of \(k\), and it never uses `corr_assumed`. This is not the net variance omission or coverage effect that the sentence says was screened.
WHY IT MATTERS: Cells can be retained when the net omission is zero or negative and dropped when correlation misspecification is consequential. The registered 176-cell grid does not follow from the registered scientific criterion.
WOULD BE WRONG IF: The gate were explicitly defined as the positive target-summary component alone rather than detectable interval error; the protocol defines it through coverage detectability.

### A four-percent variance share does not imply a one-point coverage shift
SEVERITY: serious
QUOTE: The floor is derived: a coverage Monte Carlo SE of 0.005 makes 0.01 the smallest coverage shift worth claiming, which needs roughly a 0.04 variance share.
PROBLEM: Under the favorable normal-Wald calculation, omitting 4% of total variance gives coverage \(2\Phi(1.96\sqrt{0.96})-1=0.9452\), a shift of only 0.0048. A one-percentage-point shift requires about a 7.9% omitted share.
WHY IT MATTERS: The threshold and resulting grid are approximately a factor of two more permissive than the stated derivation.
WOULD BE WRONG IF: A measured mapping under this DGM showed that a 4% share produces a 0.01 shift; no coverage measurement was used to set the floor.

### Nominal coverage alone cannot establish that the entropy port is correct
SEVERITY: serious
QUOTE: If it restores nominal coverage across the grid on the logit scale, the catalog's porting claim is supported, this study's second prediction is wrong, and the study says so.
PROBLEM: Coverage combines bias, estimated variance, sampling variance, and distributional approximation. Incorrectly wide intervals can offset estimand bias or another omitted variance and produce 95% coverage. The stated success rule does not also require negligible bias and agreement between mean SE and empirical SD.
WHY IT MATTERS: A compensating-error result would be declared evidence for porting even though the variance estimator remained wrong.
WOULD BE WRONG IF: Support required both nominal coverage and separate bias and SE-calibration criteria; the quoted rule requires coverage alone.

### Order 48 is not stable at the registered tolerance
SEVERITY: serious
QUOTE: True value. By Gauss-Hermite quadrature at order 48, which is probe P1's output and is not defaulted.
PROBLEM: P1 uses order 64 from the same slowly converging sequence as its reference. Reproducing the code at higher orders gives 0.679493 at order 48, 0.679624 at 128, and 0.679663 at 256 for mixed/cloglog. The changes from order 48 are \(1.31\times10^{-4}\) and \(1.70\times10^{-4}\), both exceeding the \(10^{-4}\) tolerance.
WHY IT MATTERS: The declared truth for the cell that determines the global order fails its own numerical-accuracy criterion.
WOULD BE WRONG IF: Order 64 were independently known to be within \(10^{-4}\) of the limiting integral; the continuing higher-order movement disproves that.

### The resample-count criterion does not bound coverage error
SEVERITY: serious
QUOTE: At \(B = 50\) the 90th-percentile resampling error is inside the across-replicate spread of the standard error itself (0.1774), so more resamples buy nothing a coverage number can see.
PROBLEM: Between-replicate heterogeneity is not a tolerance for Monte Carlo error added to every interval. P5 measures the target-only perturbation component, not total interval width or coverage, and still finds a 14.14% 90th-percentile relative SE error at \(B=50\).
WHY IT MATTERS: The dominant computational constant is selected without demonstrating that its Monte Carlo noise is small relative to the registered coverage MCSE.
WOULD BE WRONG IF: A derivation or direct coverage probe linked the 0.1774 comparison to a coverage-error bound below 0.005; none is present.

### The “outside” modifier remains inside the matched set
SEVERITY: serious
QUOTE: modifier span | inside, outside
PROBLEM: `make_pars("outside")` appends a fourth modifier, but `sample_replicate()` includes that covariate in source `h`, target means, target second moments, and MAIC balancing. It is therefore reported and matched, not outside the matched-moment span. This arm also contradicts the claim that three covariates are held fixed.
WHY IT MATTERS: The registered identification-bias arm does not induce the bias it is supposed to test.
WOULD BE WRONG IF: `h_of()` or `target_reported$m` excluded the fourth covariate; both include every column.

### The mixed arm does not preserve the registered overlap
SEVERITY: serious
QUOTE: Held fixed: 3 covariates, overlap at a standardized mean difference of 0.4, anchored throughout.
PROBLEM: In the mixed arm, the primary modifier is set to `as.numeric(Z[,1] > 0)` in both populations. Its mean is 0.5 in both source and target populations, so its SMD is zero, not 0.4. P2 nevertheless evaluates that binary covariate using mean 0.4 and SD 1, although its actual SD is 0.5.
WHY IT MATTERS: The shape contrast is confounded with a change in overlap on the primary modifier, and the mixed-cell variance shares are calculated from impossible binary moments.
WOULD BE WRONG IF: The binary threshold changed with the source-target mean shift or overlap were defined only for the continuous covariates; neither is true.

### The oracle correlation is not the true observed correlation
SEVERITY: serious
QUOTE: `maic_oracle` (fixed moments with the true correlation supplied)
PROBLEM: `assumed_R("true")` returns the latent Gaussian equicorrelation. Nonlinear lognormal transformation and binary thresholding change Pearson correlations of the observed covariates. For example, latent correlation 0.3 becomes about 0.239 for a mixed binary-normal pair.
WHY IT MATTERS: The oracle arm does not isolate correlation misspecification in the non-normal cells, so the registered attribution rule cannot work there.
WOULD BE WRONG IF: “True correlation” were explicitly defined as the latent Gaussian parameter rather than the correlation of the reported target covariates.

### The survival arm is not a Weibull time-to-event experiment
SEVERITY: serious
QUOTE: Weibull PH throughout, so nothing separates moment uncertainty from non-proportionality.
PROBLEM: The DGM generates one Bernoulli survival-status indicator at an implicit horizon. It generates no event times, Weibull shape or scale, censoring, risk sets, or survival-model fit. The STC arm then uses R's standard event-probability cloglog link on an outcome whose coded probability is survival, the complement of that inverse link.
WHY IT MATTERS: Results from this arm cannot support claims about Weibull PH MAIC, hazard-ratio inference, or separation from non-proportional hazards.
WOULD BE WRONG IF: The target were explicitly only a fixed-horizon binary survival-probability contrast and no time-to-event or Weibull claim were made.

### STC cannot report the registered interval as specified
SEVERITY: serious
QUOTE: `maic_fixed` (status quo), `maic_entropy` (the entropy-balancing port), `maic_perturb` (the perturbation port), `maic_oracle` (fixed moments with the true correlation supplied), `stc`, and ML-NMR.
PROBLEM: STC always simulates a multivariate normal target law, even in lognormal and mixed cells. Its SE is merely `vcov(fit)["A","A"]`, which is the conditional treatment coefficient variance, not the delta-method variance of the marginalized contrast and its interactions.
WHY IT MATTERS: STC point estimates ignore registered shape in two arms, and its interval coverage is not coverage of the reported marginalized estimand.
WOULD BE WRONG IF: STC were excluded from the shape arms and used a full marginalization-gradient or bootstrap SE; neither restriction exists.

### The claimed 81.9-percent saving cannot be caused by reducing \(B\) from 200 to 50
SEVERITY: serious
QUOTE: Cost: 18.6 core-hours for the MAIC and STC arms at `N_PERTURB = 50`, against 102.6 at the typed 200, a 81.9% saving.
PROBLEM: Quartering the only changed resampling count can save at most 75% even if every second scales with \(B\); non-perturbation work makes the attainable saving smaller. The 102.6 value is a hard-coded historical number, while 18.6 is a current timing, so their difference includes uncontrolled timing or implementation changes.
WHY IT MATTERS: The budget comparison does not estimate the causal saving from the registered design change.
WOULD BE WRONG IF: Additional measured changes beyond \(B\) are intentionally included in “saving” and reported as such; the sentence attributes the comparison to `N_PERTURB`.

### The claimed no-typed-number safeguard does not exist
SEVERITY: serious
QUOTE: Every number below is generated from `results/registered-design.json` by `review/emit-protocol.py`. None is typed.
PROBLEM: The generator directly types numerical claims including 5,308,416, 48, four covariates, \(4.1\times10^{-15}\), 0.01, and orders 8 to 16. The exporter also hard-codes 102.6. Byte identity proves only that the current generator produced the document, not that each number came from JSON.
WHY IT MATTERS: The supposedly impossible defect class remains possible, and several unsupported numeric claims bypass all 19 verifier assertions.
WOULD BE WRONG IF: The claim were explicitly limited to selected templated fields; it says every number and none typed.

### The named design authority contradicts the generated protocol
SEVERITY: serious
QUOTE: The design is in `DESIGN.md`.
PROBLEM: `DESIGN.md` still states that the probes have not run, describes 216 realized cells rather than 288, and registers a P3 closed-form check the code never performs. The protocol treats this file as the normative design while presenting different current facts.
WHY IT MATTERS: It is unclear which grid, probes, and checks become binding at registration, creating exactly the cross-section revocation problem the workflow is meant to prevent.
WOULD BE WRONG IF: `DESIGN.md` were explicitly archival and non-normative; the protocol names it as the design.
