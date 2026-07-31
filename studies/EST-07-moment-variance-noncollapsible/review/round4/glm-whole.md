VERDICT: needs-revision

### The P6 "cannot be ignored" verdict relies on one worst cell with Monte Carlo error folded in
SEVERITY: serious
QUOTE: "The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored."
PROBLEM: The threshold 0.0791 was solved from a coverage criterion as the smallest omitted-variance *share* worth detecting ("the smallest coverage shift worth claiming is 0.01, which needs f = 0.0791"). That is a share of the *whole variance of the contrast* (per the denominator correction in §2). The value 0.0962 is stated as the cross term including Monte Carlo error, but the document never states it as a share of the same denominator, nor that the Monte Carlo error used to inflate it is the same one the band tolerates. The "including Monte Carlo error" construction lets a quantity whose point estimate may sit below 0.0791 cross the threshold via noise — the mirror image of the 0.04 floor collapse it criticises — and a single worst cell out of the grid is being used to license the entire `maic_xcov` arm across all cells.
WHY IT MATTERS: The cross-term arm exists because of this one sentence, and it is presented as settling whether the deficit is identification rather than omission. A threshold crossed only by adding noise to a worst-case cell is a guard that cannot fail only because it was inflated past the bar.
WOULD BE WRONG IF: 0.0962 is the point-estimate share (not the MC-error-inflated upper bound) of the cross term in the *whole-variance* denominator used to solve 0.0791, and the worst cell is representative rather than cherry-picked.

### P7's 0.019 and 0.0307 are gradient magnitudes being read as "the omitted variance is nonzero", which they do not establish
SEVERITY: serious
QUOTE: "With beta_EM = 0 the conditional contrast is constant in the covariates, but the marginal contrast still depends on the target law through the prognostic term. That is non-collapsibility itself." [and the table of "max abs gradient at beta_EM = 0"]
PROBLEM: The quantities reported are max absolute *gradients* of the marginal contrast w.r.t. the target law (an identification-direction quantity, per the P3 redefinition). A nonzero gradient of the estimand along the target law at beta_EM = 0 establishes that the estimand *depends on* the target law — i.e. identification of the *mean*. It does not, by itself, establish that the *variance of the reported-moment plug-in* is nonzero; that is a second derivative / Jacobian-outer-product quantity, which is what non-collapsibility produces but which this probe does not measure. The sentence "target-moment uncertainty does not need effect modification to bite" is a variance claim supported by a gradient measurement.
WHY IT MATTERS: P7 is titled a null control and presented as a finding that the catalog entry's expectation is wrong. Cataloguing a *dependence* finding as proving a *variance* finding overstates exactly what the probe measures, echoing the P3 redefinition the document itself insists on.
WOULD BE WRONG IF: the probe actually evaluates the variance of the plug-in under resampled target moments at beta_EM = 0, and the gradient magnitudes are shorthand for that variance estimate.

### The 1% width condition for B is a saturated-quantity guard reintroduced into the selection rule after being diagnosed as defective
SEVERITY: serious
QUOTE: "the mean width is within 1% of the reference width. The second condition exists because the first saturated once, on an interval so over-wide that coverage could not move."
PROBLEM: The document concedes that the saturation event it is guarding against was itself a coverage criterion evaluated on an over-wide interval, and chooses to fix it by adding a *width* criterion. But the width criterion can only fail when the interval is over- or under-wide, which is the same defect the coverage condition already misses exactly because it saturates; a width test against a reference whose width is itself drawn from the same B=3200 reference set is a comparison of two biased-quantile estimators, both biased inward at finite B. The selection rule therefore names a guard whose failure mode is the one the rule was created to catch.
WHY IT MATTERS: B = 800 is the study's whole budget lever (§5 "99% to 100% of the cost"). If the 1% width test is a saturated guard by construction, the chosen B is not the smallest grid value meeting two independent conditions but the smallest value where two correlated conditions agree.
WOULD BE WRONG IF: the 1% width test is applied against a width reference derived independently of the same nested-subsample draw set, or the two conditions demonstrably fail independently across the grid.

### The "every cell that clears the floor is unanchored" inference is drawn from median shares, not from the gating rule applied
SEVERITY: serious
QUOTE: "**Every cell that clears the floor is unanchored.** Median share of the interval's variance carried by the moment term ... | identity | unanchored 0.3612 | anchored 0.0395 |"
PROBLEM: The medians are reported as evidence for a universal ("Every cell") statement. A median unanchored share of 0.3612 and anchored of 0.0395 across the cells does not entail that *no* anchored cell exceeds 0.0791; it entails it is atypical. The gate is a per-cell threshold, and the universal claim requires the *maximum* anchored share (or an explicit statement that all anchored cells are below 0.0791), not the median. The same P2 elsewhere insists on reporting min/median/max for exactly this reason; here only the median is given.
WHY IT MATTERS: The §4 first result ("the effect the catalog entry names is material without an anchor and immaterial with one") and the crossing decision for `anchored` rest on this sentence. A single anchored cell above 0.0791 would be a cell that the gate run, contradicting "Every cell that clears the floor is unanchored" and the implied design to drop all anchored cells.
WOULD BE WRONG IF: the anchored share is bounded above by 0.0791 cell-wise and the medians are stated only for brevity, with the max available elsewhere.

### Coverage band 0.935–0.965 is asserted, not derived from the measured Monte Carlo error
SEVERITY: serious
QUOTE: "**The registered coverage band is 0.935 to 0.965**, two-sided: an interval that is too wide fails it exactly as an interval that is too narrow do"
PROBLEM: The document is otherwise strict that thresholds must be solved from the noise floor (it rejects an asserted 0.04 floor and asserts-derived 0.0791 in P2, and rejects a 0.01 shift asserted for the B criterion by measuring against 0.005 MCSE). The ±0.015 band around 0.95 is stated, not derived from the 0.004873 delivered MC error or the 0.005 targeted one. ±0.015 corresponds to ~3.08 MCSE on each side under the delivered error — a choice of tolerance, not a noise floor. Nothing in the text ties the width of this band to the measured uncertainty the way the 0.0791 and B-criteria are tied.
WHY IT MATTERS: This is the principal study outcome (coverage against the band). A band asserted rather than solved from the noise floor is the same defect class that §2 labels serious when it appears in P2's 0.04 floor.
WOULD BE WRONG IF: 0.015 each side is derived elsewhere from the 0.005 MCSE times a documented multiplier (e.g. 3), which is not in the visible text.

### 0.004873 is presented as the MC error coverage claims are judged against, but is a per-point number used to justify 0.01 shift interpretation
SEVERITY: serious
QUOTE: "the error 2000 replicates actually deliver is 0.004873, and that is the figure any claim about resolving a coverage difference is judged against."
PROBLEM: 0.004873 is the MCSE of a single coverage estimate under 2000 reps and CRN at the per-replicate level. The criterion used in P5 ("paired coverage difference ... plus that difference's Monte Carlo error, is inside the 0.01 shift") is a paired-difference standard error, which under CRN is smaller than the single-coverage MCSE by a factor that depends on the correlation ρ across arms (sqrt(2(1-ρ))). The text asserts 0.004873 is "the figure any claim about resolving a coverage difference is judged against", but paired differences are governed by a different quantity. Using the larger one to license the 0.01 interpretability bar is the wrong reference quantity — the mirror of comparing against omitted-plus-source in P2.
WHY IT MATTERS: It inflates the apparent resolution of coverage-difference claims: a paired difference can resolve 0.01 more finely than 0.004873 suggests (if positively correlated) or less finely (if anti-correlated), and the correct figure is the paired MCSE, which is not in the document.
WOULD BE WRONG IF: 0.004873 is explicitly the paired-difference MCSE under the CRN block, not the single-coverage MCSE; the text's wording is just imprecise.

### The oracle's "target population correlation" from the sampler law contradicts "the target's population correlation" being non-identifiable from a published table
SEVERITY: serious
QUOTE: "The oracle arm supplies the target **population** correlation, measured from the law the sampler uses."
PROBLEM: `maic_oracle` is defined in §5 and its correction in the probe phase says the latents-to-covariates attenuation was wrong; the fix supplies "the population correlation measured from the law the sampler uses". For the `lognormal` and `mixed` shapes the sampler law is not the same as the moment-matched Gaussian copula that every method reconstructs, so the supplied oracle correlation is the *true-target* correlation, while the method's reconstruction continues to assume a Gaussian copula. P1 says lognormal/mixed are non-normal *exactly to vary the truth away from the reconstruction assumption*. The oracle therefore isolates a quantity defined on a basis the other methods do not share, and the "correlation contribution" attributed to the residual (§5 last paragraph: "maic_oracle say how much of the residual is the cross term and the correlation") measures a swap-of-copula effect, not the correlation component alone.
WHY IT MATTERS: `maic_oracle` is used to partition the residual deficit; a misnamed decomposition reads "correlation is worth X cells" when the quantity is "switching to the true copula law is worth X cells".
WOULD BE WRONG IF: for all non-normal shapes the oracle continues to reconstruct under the Gaussian copula and supplies only the correlation under that same assumption.

### "The gate drops the large-target cells first" is asserted against the wrong scaling once the denominator is the whole variance
SEVERITY: serious
QUOTE: "the share falls as the target grows, because the moment term scales with 1/nT while the source term scales with 1/nS, so the gate drops the large-target cells first: exactly the ones the prediction is about."
PROBLEM: §6 of the document self-corrects exactly this sentence for the P6 cross term: "The share does move with the target size ... because the source component scales with 1/nS rather than 1/nT." The denominator in P2 is now the *whole variance of the contrast* (omitted + source + target-trial + cross). In that denominator the dominant term is the target-trial's own variance (median 0.02373 vs source 0.00463 vs omitted 0.001276), which scales with 1/nT. So share = omitted/whole = (1/nT)/(C/nT + 1/nS); its behaviour with nT is governed by the target-trial term, not by a clean 1/nT vs 1/nS contrast as quoted. The explanation given for why the gate drops large-target cells rests on a denominator that has since changed.
WHY IT MATTERS: This is the reason the ladder is exempt from the gate and retained regardless, which is the design's central procedural decision. An explanation built on the old denominator still operative despite the §6 correction is the document-as-its-own-contradiction pattern the sibling study found repeatedly.
WOULD BE WRONG IF: the omitted term's 1/nT scaling dominates the *target-trial-reduced* share in the regime where the gate is set, or the target-trial term is in fact subtract or cancels.

### "Coverage = 0.95" at B=400 is reported to 2 significant digits inconsistent with the precision claimed elsewhere
SEVERITY: minor
QUOTE: "| 400 | 0.95 | 1.006 | -0.005 |"
PROBLEM: Every other row reports coverage to four significant figures (0.9225, 0.9362, 0.9462, 0.9538). The B=400 row is 0.95 exactly. Paired with a difference of -0.005 against a B=3200 reference of 0.95, the row implies a reference coverage of exactly 0.955, which would be the first coverage number in the table not at a clean 0.0001 grid and contradicts the implied paired reference (it should be 0.955). The B=400 row reading cleanly as 0.95 with differ -0.005 against implied reference 0.955 would be the only saturated-reference value in the table.
WHY IT MATTERS: It weakens the paired-coverage case by introducing a number that reads as a rounded or nominal value where the criterion is *supposed* to be sensitive (the difference at B=400 is one MCSE of the band's 0.004873). If the 0.95 is rounded, B=400 may not be the smallest value inspected; the "800 is the smallest value in the grid meeting both" claim may not hold.
WOULD BE WRONG IF: the underlying coverage estimate at B=400 also lands exactly on 0.95 to four digits, with the reference exactly 0.955.

### 83% and 1% moments are introduced as a finding with no anchored-analysis denominator stated
SEVERITY: minor
QUOTE: "In an anchored comparison the target trial's own effect carries about 83% of the interval's variance and the moment term about 1%. That is the study's first result and it came out of the probe phase, before any replicate was run."
PROBLEM: 83% + 1% = 84%, leaving 16% for source + cross + covariance, but no share is given for those. The §2/§4 tables give only the moment-term share under anchored. Presenting "the first result" as two numbers summing to 84% without accounting for the balance treats a two-component split as the whole story. The §6 halves that the source and cross terms are real and large (cross term up to 0.0962 of the whole).
WHY IT MATTERS: The "first result" reads as a clean conclusion (anchored → trivial), but withholding the source/cross remainder lets the MOM hold dominate without a stated 100% reconciliation.
WOULD BE WRONG IF: the remaining 16% the source/cross/covariance terms exactly stack to 16% with the moment 1%, target-trial 83%; just not stated.

### "A nonzero identity gradient is an implementation defect" may be a guard that cannot fail under the floating-point regime that produces 5.55e-14
SEVERITY: minor
QUOTE: "A nonzero identity gradient is an implementation defect; nonzero curved gradients are the subject of the study."
PROBLEM: The vanishing identity gradient is reported as 5.55e-14, which is near machine-epsilon rounding and well below any tolerance the document specifies. To say "nonzero identity gradient is an implementation defect" without naming a tolerance below which the gradient is accepted as zero (or the same Monte Carlo floor) makes the guard either trivially always-failing (5.55e-14 ≠ 0) or vacuously always-passing (any finite tolerance). It is asserted rather than derived from the noise floor the rest of the document is so careful about.
WHY IT MATTERS: It is a registered interpretation rule for the control, and a guard without a tolerance cannot fire unambiguously.
WOULD BE WRONG IF: a tolerance exists that 5.55e-14 passes/is-zero and which is named outside this section.

---

### Notes on what I deliberately did *not* raise
- I did not hunt for stale numbers; the generator/verifier makes that class inert, per instructions.
- I did not flag the 99%–100% perturbation cost or the 531% cost increase as defects: both are reported honestly with their comparators.
- I did not flag the second-prediction withdrawal in §1 as a contradiction; it is correctly revoked and P3 redefined.
- I did not flag the "outside" arm being crossed with mvnorm only as a scope error; §2 states the consequence (no 65,536-node cost) and it is consistent with §4.
