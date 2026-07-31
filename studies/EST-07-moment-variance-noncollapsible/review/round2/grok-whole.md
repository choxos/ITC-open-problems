VERDICT: unsound

### Design fixes 3 covariates; truth-reduction claim uses 4
SEVERITY: fatal
QUOTE: "Held fixed: 3 covariates" / "the product rule's order^p collapses to order: 65,536 nodes to 16 at four covariates"
PROBLEM: Under a product Gauss–Hermite rule, 16^4 = 65,536 and 16^3 = 4,096. The design freezes three covariates, but the registered true-value reduction is written for four. One of the design, the truth engine, or the reduction check is wrong; they cannot all be true together.
WHY IT MATTERS: Every bias and coverage result is defined against the quadrature truth. If dimension or node count is wrong, the “true value” is not the estimand’s value under the stated design, and ADEMP performance is not identifiable.
WOULD BE WRONG IF: “Four covariates” is only informal wording and the implemented law is three-dimensional with 16^3 nodes (and 65,536 is not the product-rule count being claimed).

### “Nothing is conservative” contradicts the same table’s logit ratios
SEVERITY: fatal
QUOTE: "Corrected, nothing is conservative on either scale: logit spans 1 and cloglog sits modestly above it."
PROBLEM: The table gives logit variance ratios 0.9886 to 1.074 with direction **mixed**, and labels cloglog (1.077 to 1.172) **anti-conservative**. If ratio > 1 is anti-conservative (ported variance too small), then ratio < 1 is conservative. Logit therefore includes conservative cells; the prose revokes the table’s mixed direction.
WHY IT MATTERS: Direction of variance error is the probe result used to demote the study’s strong claim and to pre-interpret the primary arm. A false “never conservative” summary will mis-register what the simulation is allowed to conclude.
WOULD BE WRONG IF: “Variance ratio” is defined so that values below 1 are not conservative intervals (e.g., a different numerator/denominator than the anti-conservative cloglog labeling implies).

### Refuting identification claim is not what the probes measured
SEVERITY: fatal
QUOTE: "on a non-collapsible scale the target marginal effect is not a function of the reported moments at all, so no variance estimator indexed by those moments can be correct, and the failure is one of identification rather than of variance."
PROBLEM: Probes report a finite estimator-vs-estimand **gradient gap** and a **variance ratio near 1**. That is evidence about delta-method linearization error, not about non-identification. Under `mvnorm` (and any law fixed by the reported moment structure), Δ(F_T) is a function of those moments; non-collapsibility does not make that map nonexistent. The probe results (small gap; identity gap → 0) actively cut against “not a function of the moments at all.”
WHY IT MATTERS: Section 1 sets the scientific proposition and its refutation. If the refutation is identification but the evidence and design only stress-test variance transport, the study cannot confirm or refute what it claims to test.
WOULD BE WRONG IF: “Reported moments” is defined to exclude the full moment structure that determines F_T in the design (e.g., only means, never second moments/correlations), and the probes were run under that incomplete indexing.

### Gradient-implied variance ratio is used as if it were coverage
SEVERITY: serious
QUOTE: "On the primary logit arm the ported variance is within about 1% to 7% of correct, which is unlikely to break coverage. Section 5 registers that outcome as the one supporting the catalog."
PROBLEM: The measurement is a gradient/variance-ratio probe, not empirical coverage, bias, or interval calibration under sampling. “Within about 1% to 7%” also does not match a ratio range of 0.9886–1.074 under a consistent ported-vs-correct reading (errors are not a clean 1–7% band on the ported SE). Coverage can still fail from bias, non-normality, weight variability, or correlation misspecification.
WHY IT MATTERS: The document pre-registers the catalog-supporting interpretation from a surrogate that was not a coverage experiment, before the replicate runner exists.
WOULD BE WRONG IF: An unstated probe already estimated coverage (or a tight analytic map from these ratios to coverage under the exact MAIC sampling distribution), and “1% to 7%” refers to that map rather than the tabled ratios.

### Primary “across the grid on logit” fights the cell-dropping rule
SEVERITY: serious
QUOTE: "If it restores nominal coverage across the grid on the logit scale, the catalog's porting claim is supported" / "124 of 288 realized cells clear a 0.07913633 floor and are run; the rest are dropped"
PROBLEM: Omitted-variance share on logit has median 0.0465 (below the floor) and max 0.362. Most logit cells will fail the floor if shares look like that table, so the runnable set is enriched for cells where moment uncertainty is large. That is not “across the grid on the logit scale,” and it is not an unbiased test of the porting claim where the catalog would actually be used.
WHY IT MATTERS: Supporting or rejecting the catalog on a selected high-share subset can overstate harm from ignoring target-moment variance and understate performance on typical logit cells.
WOULD BE WRONG IF: After applying the floor, essentially all logit factor combinations remain (the share table is not the analysis grid), or “across the grid” is explicitly redefined as “across cells retained by the floor.”

### 288 realized cells does not follow from the published factor list
SEVERITY: serious
QUOTE: factor table (link × n_T × n_S × k × shape × corr_assumed × modifier span) / "124 of 288 realized cells"
PROBLEM: The full cross of the listed factors is far larger than 288 (3×3×3×4×3×3×2 = 1,944). Even common reductions (e.g., drop one factor) do not land on 288 without an unstated restriction. The floor and cost are defined on “realized cells,” but the realization rule is not in the protocol.
WHY IT MATTERS: Registration must fix the experimental unit. If software builds a different factorial than 288, cell counts, cost, and “124 cleared” are not the study that was reviewed.
WOULD BE WRONG IF: “Realized grid” is defined elsewhere as a specific 288-cell subset and that definition is part of the registered design the generator emits (not omitted from this text).

### Residual “reconstructed-correlation uncertainty” is asserted, not probe-supported
SEVERITY: serious
QUOTE: "those published results transfer to PAIC as a porting exercise, and the residual unaddressed component is reconstructed-correlation uncertainty."
PROBLEM: The probes that “bear directly on the proposition” are gradient-gap and identity-link sanity checks. They do not measure correlation reconstruction, borrowed vs true vs independence correlation, or the share of error due to correlation. The design varies `assumed correlation`, but the leading claim already names the residual component.
WHY IT MATTERS: Pre-naming the residual steers analysis and interpretation toward correlation even if curvature, overlap aliasing, or finite-target vs superpopulation estimands dominate.
WOULD BE WRONG IF: A probe result (not in this draft’s “three results”) already decomposed error and showed correlation reconstruction dominates after porting.

### Order-16 justification confuses the arm that forces the node count
SEVERITY: serious
QUOTE: "The order is forced by the mvnorm covariate shape on the cloglog link; a thresholded binary covariate is a step function and Gauss-Hermite converges on it slowly, while every continuous law is stable by order 8 to 16."
PROBLEM: `mvnorm` is continuous; the slow case described is the **thresholded binary** piece (mixed arm). The sentence attributes the forced order to `mvnorm`+`cloglog`, then explains a different mechanism. It is unclear which law/order pair is registered for each shape, especially lognormal/mixed where the normal 1-D reduction does not apply.
WHY IT MATTERS: Truth error that depends on shape can masquerade as method bias differently across arms; an under-resolved binary/mixed truth is a systematic confound.
WOULD BE WRONG IF: P1 actually showed `cloglog`+`mvnorm` still needs order 16 for the target tolerance, and binary/mixed use a separately validated rule stated in the design export.

### Study methods and error plan exceed software the draft says does not exist
SEVERITY: serious
QUOTE: "What does not yet exist is the replicate runner, the result writer, the analysis program, the clustered Monte Carlo error calculation, the three controls and the ML-NMR arm." / "stc, and ML-NMR" / "Monte Carlo error is clustered on the replicate block"
PROBLEM: The protocol already specifies ML-NMR as a method, clustered MC error as the uncertainty for comparisons, and “three controls” (never defined in the factor/methods tables). Those analyses cannot be performed as written until components exist; registering them now is aspirational, not operational. Unlike a pure status note, Section 5–6 treat them as part of the study plan.
WHY IT MATTERS: A registration that names analyses the codebase cannot run will either ship incomplete results or silently change the analysis later without re-critique.
WOULD BE WRONG IF: Registration is explicitly gated so that ML-NMR, controls, and clustered MCSE are non-registered until implemented, and the locked protocol will drop them until then.

### “Smallest coverage shift worth claiming” is a policy threshold, not a noise floor
SEVERITY: minor
QUOTE: "a coverage Monte Carlo SE of 0.005 makes 0.01 the smallest coverage shift worth claiming, which needs roughly a 0.07913633 variance share."
PROBLEM: MCSE 0.005 justifies resolution of about 0.01, but “worth claiming” is a preference. The 0.079… floor inherits that preference; cells below the floor may still show real undercoverage that the study chooses not to estimate.
WHY IT MATTERS: Readers may treat the floor as a statistical detectability limit rather than a budget/policy cut.
WOULD BE WRONG IF: 0.01 is derived from a pre-specified decision-theoretic loss or external standard, not chosen as “worth claiming.”

### Identity-link “factor of 6.7” is offered as proof of correctness without a stated null rate
SEVERITY: minor
QUOTE: "The gap between estimator and estimand gradient falls by a factor of 6.7 across n_S = 500 to 8000, reaching within one Monte Carlo standard error of zero. A wrong implementation produces a gap that does not move."
PROBLEM: n_S increases by 16×; pure Monte Carlo noise on estimated gradients would typically shrink by about 4×, not necessarily 6.7×. Without the measured gaps, SEs, and what “does not move” was checked against, the factor is rhetoric more than a named diagnostic test.
WHY IT MATTERS: Over-claimed probe validation can hide an implementation bug that still shrinks with n_S for other reasons.
WOULD BE WRONG IF: P2 defines an explicit wrong-implementation control whose gap is flat in n_S, and 6.7 is the measured ratio of those registered gap estimates.
