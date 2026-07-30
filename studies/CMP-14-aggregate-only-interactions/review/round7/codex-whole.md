VERDICT: unsound

### The implemented data-generating truth sets every interaction to 0.4
SEVERITY: fatal
QUOTE: "| $\Gamma_k$ for components 1, 2, 4 | 0 |"
PROBLEM: `theta_true()` assigns `GAMMA_W` to all four interaction coordinates, while the exporter separately hard-codes `gamma_other = 0`. The verifier therefore certifies a truth the simulation does not use. Direct recomputation with the declared zeros changes E1 coverage by as much as 0.440 and changes 11 failure classifications.
WHY IT MATTERS: E1 bias and coverage, and E2 information, contraction, coverage, and diagnostic performance, were calculated under the wrong data-generating mechanism.
WOULD BE WRONG IF: `theta_true()` overwrote interactions 1, 2, and 4 with zero before evaluation, or the intended registered truth were 0.4 for all four interactions.

### E2 evaluates information at theta-star while registering theta-true
SEVERITY: fatal
QUOTE: "**Contraction in E2 is contraction of a normal approximation whose covariance is $(I(\theta_{\text{true}}) + P_0)^{-1}$**, the expected Fisher information at the true parameter plus the prior precision."
PROBLEM: `evaluate_e2()` and `gap_for()` add the departure to form $\theta^*$ and call `logit_info()` at $\theta^*$. The protocol previously defines $\theta^*=\theta_{\text{true}}+\text{shift}\,e_{\Gamma_3}$, so the two symbols cannot denote the same parameter in the 28 aliased scenarios. The verifier compounds the defect by requiring the document to contain the stale $I(\theta_{\text{true}})$ formula.
WHY IT MATTERS: The registered E2 contraction formula does not describe the quantity actually calculated for 28 of 72 scenarios.
WOULD BE WRONG IF: $\theta_{\text{true}}$ were explicitly redefined to include the alias shift, or the implementation evaluated information at the unshifted parameter.

### The reported Laplace gap is not calculated from a Laplace Hessian
SEVERITY: fatal
QUOTE: "**The gap is measured rather than admitted.** `R/09-contraction-gap.R` solves for the mode under data at their expectation, $U(\theta;\,\mathbb{E}[y \mid \theta_{\text{true}}]) = P_0\theta$, by Newton iteration and recomputes the contraction there, at $\theta^{*}$ where a departure acts."
PROBLEM: The script computes the comparison covariance from `logit_info()` at the mode. For an aggregate arm, that function supplies only the Fisher term $n gg'/[p(1-p)]$. The actual Hessian away from the data-generating parameter also contains a term proportional to the arm residual times the derivative of $g/[p(1-p)]$. A proper prior moves the mode, so those residuals are generally nonzero. The iteration is consequently Fisher scoring, and `sd_lap` is a Fisher-at-mode covariance, not a Laplace covariance.
WHY IT MATTERS: The claimed 0.0882 absolute and 14.64% relative bounds do not measure the limitation they are said to measure.
WOULD BE WRONG IF: the full aggregate log-likelihood Hessian were used, or every aggregate arm had zero expected residual at the posterior mode so the omitted curvature term vanished.

### Primary 2 has no registered outcome
SEVERITY: fatal
QUOTE: "**Primary 2.** `additivity` against `ecological`, matched on spread, total patient budget and prior scale, with synergy off."
PROBLEM: This registers a matched set but does not say which quantity is compared, what contrast is reported, or what constitutes a result. The implementation subsequently selects pairs whose contraction differs by less than an unregistered 0.02 and reports their maximum coverage gap.
WHY IT MATTERS: A primary analysis can be chosen after inspecting E1 because the protocol does not determine its estimand or decision rule.
WOULD BE WRONG IF: the protocol elsewhere registered the exact outputs of `state_pairs()`, including the 0.02 filter and coverage-gap summary.

### Pooled Primary 3 was repaired only in the exporter
SEVERITY: fatal
QUOTE: "**Primary 3, one correlation over the confounded family.** The rank correlation between contraction and coverage across every `ecological` scenario with nonzero discordance, **pooled, not stratified by discordance level**."
PROBLEM: `R/04-analyze.R` still prints `anticorrelation(d)` and saves that stratified result as `anti`; it never prints or saves `anticorrelation_pooled(d)`. The pooled value is calculated only by the exporter. Moreover, `results/e1-analysis.rds` predates the repaired analysis code and is omitted from the exporter’s artifact-staleness list.
WHY IT MATTERS: The designated E1 analysis output does not contain the registered Primary 3, and rerunning the normal analysis path would still produce only the two stratified correlations.
WOULD BE WRONG IF: the normal analysis saved the pooled result and `results/e1-analysis.rds` were regenerated and covered by the staleness guard.

### E2’s separation rules are absent from the protocol
SEVERITY: serious
QUOTE: "**E2 has no confirmatory standing either.** Its separation rules were rebuilt in round 3 after its output had been read. **Every part of E2 is exploratory.**"
PROBLEM: No later section states those rules. The code privately defines six range-separation comparisons, excludes equal-SD curvature rows, and withdraws E1 if any comparison separates. Those choices appear nowhere in the protocol.
WHY IT MATTERS: The E2 verdict and the condition for withdrawing E1 cannot be reconstructed from the preregistration.
WOULD BE WRONG IF: the protocol enumerated all six comparisons, the curvature exclusion, and the `any()` withdrawal criterion.

### The placebo-prevalence guard measures an unregistered slice
SEVERITY: serious
QUOTE: "runs from **0.2913 to 0.3291** across the registered states."
PROBLEM: `R/07-run-e2.R` obtains that range using only `spread = 0.6` and `sd_ratio = 2.0`; 2.0 is not even a registered SD ratio. Across the actual registered levels, the marginal placebo prevalences run from approximately 0.2506 to 0.3760. The quoted curvature pair 0.3099 versus 0.3194 likewise comes from the unregistered ratio 2.0; registered ratios produce 0.3099 versus 0.3099, 0.3141, or 0.3321.
WHY IT MATTERS: The numerical model description is false, and the guard claimed to cover registered arms does not enumerate the registered grid.
WOULD BE WRONG IF: the registered grid were restricted to `spread = 0.6` and `sd_ratio = 2.0`, or a full-grid calculation reproduced the quoted range.

### The post hoc candidate is not marked exploratory in its outputs
SEVERITY: serious
QUOTE: "Every outcome that reports it says so on the row."
PROBLEM: The exported overlap row for `surv_between`, the warning row for `source_survival`, and the E2 candidate outputs have no standing or status field. They use the same schema as the CMP-14 rules.
WHY IT MATTERS: A post hoc statistic is packaged indistinguishably from the registered summaries despite the protocol expressly denying it equal standing.
WOULD BE WRONG IF: every exported candidate row carried an explicit exploratory or post-hoc marker, or the downstream table added and verified that marker.

### The nuisance-prior check does not implement its stated rule
SEVERITY: serious
QUOTE: "The rule: rerun the whole grid at nuisance scales 3 and 30, and take the worst absolute move in each reported quantity against the registered scale of 10."
PROBLEM: The probe retains only coverage, contraction, and `surv_between`. It does not compare effective rank, target ratio, warning classifications, overlap results, matched-pair outputs, or the pooled correlation. It then judges a contraction movement using the unrelated 0.05 coverage scale rather than checking distance from the contraction threshold or whether any registered decision changes.
WHY IT MATTERS: The measurements cannot support the conclusion that the nuisance prior “moves nothing this study decides on.”
WOULD BE WRONG IF: all registered raw and derived outcomes were recomputed at scales 3 and 30 and shown not to cross their own thresholds or change their registered conclusions.

### Overcoverage is simultaneously a failure and neither class
SEVERITY: serious
QUOTE: "Both bands are two-sided: gross overcoverage is not nominal, it is a different failure."
PROBLEM: The implementation defines `failed` only as coverage below 0.90 and defines overcovering scenarios as `neither`. The next protocol paragraph likewise excludes overcoverage from both failure and nominal sets. Thus neither band is implemented as the quoted sentence states.
WHY IT MATTERS: The registered outcome class is internally inconsistent, affecting the interpretation of Primary 1, sensitivity, false-alarm rate, and Youden index.
WOULD BE WRONG IF: the code classified a registered upper-tail coverage band as failure, or the sentence explicitly said overcoverage belongs to neither registered class.
