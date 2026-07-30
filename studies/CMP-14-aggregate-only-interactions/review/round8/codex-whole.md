VERDICT: unsound

### Primary 1's code does not test range overlap
SEVERITY: fatal
QUOTE: "**Primary 1, an existence claim no weighting can move.** For each statistic, does the range of values taken by failing scenarios overlap the range taken by nominal ones? One value compatible with both establishes that no threshold separates them."
PROBLEM: `overlap_table()` checks only one necessary endpoint inequality. When low values are reassuring, it tests `min(failing) <= max(nominal)` but omits `min(nominal) <= max(failing)`; the high-is-reassuring branch has the analogous omission. It can therefore declare two disjoint, oppositely ordered ranges overlapping. The current E1 ranges happen to satisfy the omitted inequalities, but the registered procedure and implemented procedure are still different.
WHY IT MATTERS: Primary 1 can claim that no threshold separates failure from nominal coverage when a separating threshold exists.
WOULD BE WRONG IF: The omitted endpoint inequality were guaranteed by a registered invariant for every admissible result, or the code tested both endpoints.

### The whole-model rank still uses the supposedly coordinate-only threshold
SEVERITY: serious
QUOTE: "**`EFF_RATIO_OK` governs `target_ratio` only.** The whole-model `eff_rank` rule carries no scale threshold, which is what keeps the two rank summaries separate after round 6 found them fused."
PROBLEM: Both `diag_eff_rank()` and the E2 evaluator call `eff_rank(..., thresh = EFF_RATIO_OK)`. The named threshold therefore directly controls which generalized eigenvalues are counted in `eff_rank`; it does not govern `target_ratio` only.
WHY IT MATTERS: One of the three CMP-14 rules, including its E2 separation comparisons, is implemented with a dependency that the registration expressly denies.
WOULD BE WRONG IF: Neither `eff_rank` calculation read `EFF_RATIO_OK`, or the protocol explicitly registered that constant as the inner eigenvalue cutoff for both diagnostics.

### The claimed export-to-verifier chain still omits quoted quantities
SEVERITY: serious
QUOTE: "`R/05-export.R` writes every quantity this document quotes to `results/registered-design.json`."
PROBLEM: The quoted 0.44 coverage change and 11 reclassified scenarios are not exported or asserted. The aggregate-route table is produced in `results/routes.rds`, but the exporter does not read that artifact; the verifier instead hardcodes the desired route outcomes. These values currently reproduce, but they can become stale while every verifier assertion still passes.
WHY IT MATTERS: The stated safeguard against the exact stale or typed-number defect found in round 7 does not cover all of round 7's new claims.
WOULD BE WRONG IF: Those quantities and route results were read from their producing computations into the JSON and compared against the protocol by the verifier.

### Effective rank changes under the comparator said not to affect it
SEVERITY: serious
QUOTE: "Effective rank is unaffected, being a property of the information matrix directly."
PROBLEM: Recomputing rank from the observed likelihood Hessian at the expected-data posterior mode, the comparator defined immediately above this sentence, changes `eff_rank` in 6 of the 72 E2 scenarios and flips the `eff_rank < p` warning in 2 scenarios.
WHY IT MATTERS: `eff_rank` is one of the six comparisons that can withdraw E1's conclusion. The document presents numerical robustness as fact without measuring it correctly.
WOULD BE WRONG IF: “Unaffected” meant only that the study elects not to construct a Laplace analogue for rank, rather than that its values are unchanged, and the text stated that definitional exemption explicitly.

### Primary 2's tolerance does not mean equality to two decimals
SEVERITY: serious
QUOTE: "The tolerance is a reporting resolution, not a fitted quantity: two contractions within 0.02 are the same number to anyone reading a diagnostic to two decimals."
PROBLEM: Only 15 of the 54 pairs passing the `< 0.02` filter actually round to the same value at two decimals. The pair producing the maximum coverage gap has contractions 0.0677709 and 0.0813214, which display as 0.07 and 0.08. Restricting the comparison to values that genuinely display identically also changes the maximum coverage gap.
WHY IT MATTERS: Primary 2's strongest pair does not support its registered interpretation that apparently identical diagnostic readings can have that coverage difference.
WOULD BE WRONG IF: The outcome were explicitly defined as absolute closeness independent of displayed rounding, or the filter required equality after rounding to two decimals.

### Undefined source survival is silently converted into a failure
SEVERITY: serious
QUOTE: "| `source_survival` | $<$ `SOURCE_OK` | 0.50 | **a stipulation**, since the statistic is introduced here |"
PROBLEM: In all 72 `absent` scenarios, full target likelihood precision is zero, so source survival is undefined and the diagnostic returns `NA`. `overlap_table()` replaces that `NA` with zero, while `warnings_from()` treats it as an alarm. Neither behavior is the registered rule `source_survival < 0.50`.
WHY IT MATTERS: The candidate's overlap result and warning-performance summaries include invented zero values and alarms for scenarios where the ratio does not exist.
WOULD BE WRONG IF: The protocol explicitly registered undefined survival as zero and as an alarm, or excluded those scenarios from every source-survival analysis.

### Section 7 contradicts itself about E2's standing
SEVERITY: serious
QUOTE: "**Every number in this section is an E1 number and E1 is exploratory.**"
PROBLEM: The same section reports an E2 correlation of -0.5952 over eight scenarios. Unlike the E1 row, the E2 row is not labeled “exploratory,” even though section 1 concedes that all E2 choices were made after reading its output.
WHY IT MATTERS: A post hoc E2 result is presented in the outcomes section without the local exploratory label that the section itself says is necessary.
WOULD BE WRONG IF: The E2 row were moved elsewhere or explicitly labeled exploratory, and the opening sentence were revised to cover both arms.

### E2 candidate outputs still lack row-level exploratory labels
SEVERITY: serious
QUOTE: "Every outcome that reports it says so on the row."
PROBLEM: E2 state summaries and exported fields report `surv_between`, `surv_sd`, and the curvature and ecological candidate values without standing attached to their rows. A separate global standing field does not satisfy the claimed row-level labeling, and the verifier's row checks cover the E1 tables rather than these E2 outputs.
WHY IT MATTERS: The post hoc candidate remains packaged like an ordinary E2 result despite the registered promise that every occurrence will carry its exploratory standing.
WOULD BE WRONG IF: Those E2 fields were non-reportable internal intermediates, or every exposed row containing them explicitly carried the exploratory label.

### Withdrawn “share” terminology remains in the E2 output schema
SEVERITY: minor
QUOTE: "**`source_survival` is not a share and asking for one is ill-posed.**"
PROBLEM: E2 still emits names such as `source_share`, `e2_curvature_share`, and `e2_ecological_share` for survival quantities.
WHY IT MATTERS: Downstream tables or readers can interpret the statistic as an additive attribution, precisely the interpretation the protocol rejects.
WOULD BE WRONG IF: Those names were inaccessible internal aliases with an enforced presentation mapping to “survival,” rather than fields in saved and exported results.

### The stated number of E1 states requiring additivity is unsupported
SEVERITY: minor
QUOTE: "Additivity is assumed in three of four E1 states; the synergy arm prices that conditionality rather than removing it."
PROBLEM: Only the `additivity` state contains the `1+3` combination through which component 3 is identified. The other three states use singleton-component arms, and the grid correspondingly permits synergy only in `additivity`. Neither the design table nor the implementation identifies two additional states whose target route requires additivity.
WHY IT MATTERS: The limitations section misstates how widely the principal structural assumption affects E1.
WOULD BE WRONG IF: Two other states had likelihood contributions or identifying contrasts that depended on a component-additivity assumption despite containing no combination arms.

### The promised section 9 limitation is absent
SEVERITY: minor
QUOTE: "what the split establishes is that **the E1 finding does not reproduce on the nonlinear arm**, which is a limitation of the finding and is carried in section 9."
PROBLEM: Section 9 contains no limitation stating that the E1 correlation reverses sign and does not reproduce in E2.
WHY IT MATTERS: The designated consolidated limitations section omits a limitation that the outcomes section promises it contains.
WOULD BE WRONG IF: Section 9 included an explicit non-reproduction statement.
