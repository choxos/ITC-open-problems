VERDICT: needs-revision

### 0.04 variance-share floor does not follow from the stated 0.01 coverage shift
SEVERITY: fatal
QUOTE: "The floor is derived: a coverage Monte Carlo SE of 0.005 makes 0.01 the smallest coverage shift worth claiming, which needs roughly a 0.04 variance share."
PROBLEM: Under a normal approximation, omitting fraction \(f\) of variance and reporting SE \(\sqrt{1-f}\) times truth gives coverage \(2\Phi\!\big(1.96\sqrt{1-f}\big)-1\). For \(f=0.04\), coverage is about 0.945 (shift ≈ 0.005, one MC SE), not 0.01. A 0.01 undercoverage needs \(f\approx 0.08\). The floor is therefore not derived from the criterion named in the same sentence; it matches a quieter 0.005 target that the text does not adopt.
WHY IT MATTERS: Cell inclusion, budget, and every "detectable primary arm" claim hang on this floor. As written, either they keep cells too weak for the 0.01 claim they say is worth making, or the derivation text is false while the code uses an unexplained 0.04.
WOULD BE WRONG IF: The 0.04 floor is derived from a different, stated estimand of detectability (for example a one-MC-SE coverage shift, or a non-normal coverage calculation that is shown), not from a 0.01 shift.

### Success rule for `maic_entropy` does not match the proposition under test
SEVERITY: fatal
QUOTE: "If it restores nominal coverage across the grid on the logit scale, the catalog's porting claim is supported, this study's second prediction is wrong, and the study says so."
PROBLEM: The proposition under test is two-part (porting works; residual is reconstructed-correlation uncertainty). The refuting sentence is identification: the target marginal is not a function of reported moments, so no moment-indexed variance can be correct for \(\Delta(F_T)\). Restoring coverage for one ported variance method on a filtered logit subset cannot simultaneously (a) vindicate the catalog port, (b) falsify an unnamed "second prediction," and (c) leave identification and correlation residual unaddressed. The document never defines what the "second prediction" is.
WHY IT MATTERS: This is the registered win/lose rule. If entropy "wins," the write-up is pre-committed to a conclusion the design does not logically entail.
WOULD BE WRONG IF: "Second prediction" is explicitly the refuting sentence, coverage is defined only for a moment-identified estimand, and the registration states that entropy success means the identification claim is false rather than that porting plus correlation residual both hold.

### Claim that all four MAIC variants differ only in reported variance
SEVERITY: fatal
QUOTE: "All four MAIC variants share one weight fit and one sandwich, so they differ in the variance they report and in nothing else, which makes the paired comparison a comparison of intervals."
PROBLEM: The same section defines `maic_perturb` as a perturbation interval (not a sandwich SE) and `maic_oracle` as fixed moments with the true correlation supplied (which changes the targets entering the weight fit whenever correlation is part of the moment vector). Those two cannot share "one weight fit and one sandwich" and differ "in the variance they report and in nothing else."
WHY IT MATTERS: The paired ADEMP comparison is justified as pure interval comparison. If point estimates or estimating equations differ, coverage and CI-width contrasts are confounded and the methods factor is mis-specified.
WOULD BE WRONG IF: The implementation freezes one weight vector for all four labels, oracle correlation never enters the fit (only a variance formula), and "sandwich" is only a shared code path not used for `maic_perturb` reporting; all of that would need to be stated and reconciled with the method definitions.

### Gradient-gap probe used as if it measured applied MAIC interval error by link
SEVERITY: serious
QUOTE: "the same porting claim covers both scales, but an analyst reading a logit MAIC would see intervals too narrow while one reading a Weibull MAIC would see them too wide."
PROBLEM: The evidence offered is worst relative gradient gap and a variance ratio under `logit` and `cloglog` links for estimator vs estimand gradients. That is not a measurement of published MAIC interval widths, package output, or end-to-end coverage. The leap to "Weibull MAIC" also renames the measured `cloglog` factor using §7's Weibull PH DGP without showing that the probe exercised the Weibull/MAIC pipeline analysts run.
WHY IT MATTERS: This is presented as the probe finding with the clearest practical consequence. If the measurement is only a gradient mismatch under a simulation link, the sentence overclaims what analysts would see.
WOULD BE WRONG IF: The probes ran the actual ported entropy/perturbation variance estimators (or the published formulae as shipped) through to interval half-widths under the Weibull-MAIC analysis path, and "variance ratio" is defined as that interval-variance ratio.

### "288 realized cells" is not the listed design factorial
SEVERITY: serious
QUOTE: "176 of 288 realized cells clear a 0.04 floor and are run"
PROBLEM: The factor table multiplies to \(3\times3\times3\times4\times3\times3\times2=1944\) full cells (or 648 if `assumed correlation` is an analysis arm rather than a data-generation cell). Nothing in the document defines the restriction that yields 288. Without that definition, readers cannot know which links, shapes, or correlation assumptions are eligible before the floor filter.
WHY IT MATTERS: Registration must fix the experimental unit set. An undefined 288-cell "realized grid" makes the study irreproducible as specified and hides whether identity/logit controls are retained.
WOULD BE WRONG IF: `registered-design.json` defines 288 as an explicit sub-factorial and the protocol names that cross (the text does not).

### Logit grid is mostly below the floor the primary arm needs
SEVERITY: serious
QUOTE: "`logit` | 0.00074 | 0.0345 | 0.298" together with "176 of 288 realized cells clear a 0.04 floor"
PROBLEM: The logit median omitted-variance share is 0.0345, below the 0.04 floor, so more than half of logit cells fail inclusion under the document's own rule. Non-collapsibility on the logit scale is the substantive center of EST-07, yet the runnable grid is the upper tail of share (large omitted-variance cells only).
WHY IT MATTERS: Claims that a method restores coverage "across the grid on the logit scale" are then claims about a selected high-share subset, not about logit MAIC generally. Combined with the floor arithmetic error above, the primary scale may be under-powered or compositionally biased.
WOULD BE WRONG IF: The share table is not the cellwise inclusion metric, or logit cells are reweighted/stratified so the runnable set is not the upper tail of that distribution.

### `N_PERTURB` justification measures the wrong noise comparison for coverage
SEVERITY: serious
QUOTE: "At \(B = 50\) the 90th-percentile resampling error is inside the across-replicate spread of the standard error itself (0.1774), so more resamples buy nothing a coverage number can see."
PROBLEM: Coverage Monte Carlo SE is 0.005 on a 0–1 coverage rate. The cited check compares resampling error in the SE to the across-replicate spread of the SE (0.1774). That does not establish that SE noise is negligible relative to coverage estimation error, nor that it cannot flip cover/not-cover at the replicate level in enough draws to move estimated coverage by more than 0.005–0.01.
WHY IT MATTERS: \(B\) dominates cost (88% to 94% of the timed total). If the derivation does not bind to the coverage estimand, the registered \(B=50\) is asserted, not derived from the noise floor that matters.
WOULD BE WRONG IF: The protocol shows a direct calibration: changing \(B\) does not move cellwise coverage by more than a stated fraction of 0.005, and 0.1774 is that coverage-relevant metric (not SE spread).

### ML-NMR is registered as a method without a runnable cost or design commitment
SEVERITY: serious
QUOTE: "`stc`, and ML-NMR." / "ML-NMR is not in that total and no figure covering it is quoted until its per-fit cost is measured."
PROBLEM: Methods lists ML-NMR as a peer of the MAIC variants and STC, but replicates, cell set, and 18.6 core-hour budget explicitly exclude it until a future measurement. A pre-registration cannot both promise the analysis and defer whether it is affordable or how it is allocated.
WHY IT MATTERS: Either ML-NMR is in scope (then cost, cells, and failure modes must be fixed now) or it is exploratory (then it must not sit in the primary methods list).
WOULD BE WRONG IF: Registration text marks ML-NMR as optional/exploratory with a stop rule, not as a primary comparator.

### Identity-link "implementation check" does not follow from gap→0 alone
SEVERITY: serious
QUOTE: "The gap between estimator and estimand gradient falls by a factor of 6.7 across \(n_S\) = 500 to 8000, reaching within one Monte Carlo standard error of zero. A wrong implementation produces a gap that does not move."
PROBLEM: The measurement shows the gap shrinks and is near zero at large \(n_S\). It does not measure wrong implementations. A wrong implementation could also shrink with \(n_S\), or a right implementation could be biased in a way that shrinks. The second sentence is a claim about counterfactual bugs, not a consequence of the probe.
WHY IT MATTERS: This is used to underwrite that curved-link gaps are about curvature rather than code error. That separation is weaker than the text asserts.
WOULD BE WRONG IF: There is a stated positive control (injected bug) showing a non-moving gap, or a proof that any implementation error in this codebase yields \(n_S\)-invariant gap.

### Primary estimand is a law functional; coverage estimand for moment-based intervals is unspecified
SEVERITY: serious
QUOTE: "The target-superpopulation marginal effect, \(\Delta(F_T)=\cdots\), a functional of the target covariate law rather than of its moments." / "Both are computed on every replicate."
PROBLEM: Computing two truths is not the same as defining which truth each method's interval is scored against, or how ADEMP coverage is attributed when the interval is built from moment uncertainty alone. Without that map, "restores nominal coverage" is ambiguous between \(\Delta(F_T)\), the finite-target contrast, and a moment-implied pseudo-estimand.
WHY IT MATTERS: The study’s whole point is that those objects come apart on non-collapsible scales. An unspecified scoring rule reintroduces the estimand confusion §3 says the pair exists to prevent.
WOULD BE WRONG IF: A later registered analysis section (not present here) fixes primary coverage as \(P(\Delta(F_T)\in\mathrm{CI})\) and secondary as finite-target coverage for every method.

### Omitted-variance share table is used as if it alone justified factoring \(n_S\)
SEVERITY: minor
QUOTE: "The source size is a factor because probe P2 found that pinning it made the primary arm undetectable. The omitted variance is set by \(n_T\) and the retained variance by \(n_S\), so with \(n_S\) fixed the source term dominates."
PROBLEM: The share table reports min/median/max by link over the realized grid after the design choice, not the pinned-\(n_S\) probe contrast that supposedly forced the factor. The causal "because P2" is fine only if P2's detectability metric is that share (or coverage power); the text never states P2's actual endpoint.
WHY IT MATTERS: Weak provenance for a three-level factor that multiplies cost.
WOULD BE WRONG IF: P2 explicitly measured primary-arm detectability under pinned vs varied \(n_S\) and used this share definition.

### Machine-zero share reported as a real minimum on the identity link
SEVERITY: minor
QUOTE: "`identity` | 5.22e-24 | 0.176 | 0.714"
PROBLEM: \(5.22\times10^{-24}\) is not a meaningful variance share; it is numerical underflow or exact cancellation. Presenting it as the measured minimum implies a real near-zero cell rather than a numeric edge case.
WHY IT MATTERS: Pollutes the interpretation of the identity arm's share range and any "min share" discussion.
WOULD BE WRONG IF: The quantity is a signed or squared analytic expression that can be that small for structural reasons and is interpreted as such.

### Cost saving arithmetic is reported without a cost model that matches both \(B\) points
SEVERITY: minor
QUOTE: "Cost: 18.6 core-hours for the MAIC and STC arms at `N_PERTURB = 50`, against 102.6 at the typed 200, a 81.9% saving. The perturbation interval is 88% to 94% of the total"
PROBLEM: A single linear model cost = fixed + \(cB\) cannot jointly hit (18.6 at 50), (102.6 at 200), and perturbation share 88–94% at both points. The percentages may be at one \(B\) only; the text does not say which, so the "line item" claim is under-specified relative to the saving claim.
WHY IT MATTERS: Minor for science, material for any registered budget or "we cut the expensive line" narrative.
WOULD BE WRONG IF: The two cost totals and the 88–94% share are from the same profiled run configuration with non-linear overhead explained.
