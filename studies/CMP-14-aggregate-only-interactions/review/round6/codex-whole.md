VERDICT: unsound

### E2 misclassifies estimand aliasing as likelihood misspecification
SEVERITY: fatal
QUOTE: "Coverage is reported **only where the model is correctly specified**, since under misspecification the score variance is not the Fisher information and the aggregate arm's expected Hessian is not either."
PROBLEM: The code defines correct specification as `discord == 0 && synergy == 0`, but every nonzero departure is exactly representable by the fitted model. In `ecological` and `curvature`, component 3 appears only in aggregate rows, so setting fitted $\Gamma_3=\Gamma_W+\text{discord}$ reproduces every observed probability. In `additivity`, it appears only in the $1+3$ arm, so $\Gamma_3=\Gamma_W+\text{synergy}$ does the same. Direct recomputation gave maximum discrepancies of 0 and $2.2\times10^{-16}$. These are estimand mismatches, not likelihood misspecification.
WHY IT MATTERS: E2 suppresses coverage for precisely the discordance and additivity-violation scenarios the study is meant to investigate, based on an inapplicable sandwich argument.
WOULD BE WRONG IF: A departure affected some target-bearing rows but not others in the same scenario, so no single fitted $\Gamma_3$ could reproduce the data.

### The curvature state has ten arms, not twelve
SEVERITY: fatal
QUOTE: "Every state's target studies carry three arms, so every state has twelve arms, an identical shared background and the same per-arm size at a given budget."
PROBLEM: `build_state_nl("curvature", ...)` gives each target study only placebo and component 3. Its network therefore has six background arms plus four target arms, totaling ten. Other E2 states have twelve. At a budget of 3000, curvature receives 300 patients per arm while the others receive 250.
WHY IT MATTERS: E2 comparisons involving curvature change background information and patient allocation as well as the evidence route, invalidating route-specific separation claims.
WOULD BE WRONG IF: The sentence were explicitly limited to E1 and E2 separately equalized the curvature state's background and per-arm sizes.

### E2 contraction is not calculated from a Laplace approximation
SEVERITY: fatal
QUOTE: "Contraction in E2 is contraction of a Laplace approximation, not of a posterior, and the gap is bounded by nothing measured here."
PROBLEM: The code evaluates Fisher information at the true parameter and uses $(I(\theta_{\mathrm{true}})+P_0)^{-1}$. A Laplace covariance uses the posterior Hessian at the posterior mode. Those points differ materially under the deliberately tight prior. For one registered ecological scenario, the implemented contraction was 0.863725, while the expected-posterior Laplace calculation was 0.832440.
WHY IT MATTERS: Every E2 contraction value, range comparison, and threshold interpretation is for a different approximation than the protocol names.
WOULD BE WRONG IF: The Hessian were evaluated at the posterior mode, or the information were parameter-invariant or the mode equaled the truth.

### The secondary `eff_rank` result is actually `target_ratio`
SEVERITY: fatal
QUOTE: "| `target_ratio` | the likelihood's own marginal precision over the prior's, along the target coordinate | what CMP-14 asks for, per parameter |"
PROBLEM: The protocol distinguishes `target_ratio` from whole-model `eff_rank`. Nevertheless, `warnings_from()` creates the output named `eff_rank` from `d$target_ratio < EFF_RATIO_OK`; it never uses `d$eff_rank`. The exported warning table consequently has an `eff_rank` row containing target-ratio performance and no `target_ratio` row.
WHY IT MATTERS: The registered sensitivity, false-alarm, and Youden outputs for two central diagnostics are either mislabeled or absent.
WOULD BE WRONG IF: The `eff_rank` warning used the whole-model count under a registered decision rule and `target_ratio` had its own correctly labeled output.

### The curvature candidate reports loss, not survival
SEVERITY: fatal
QUOTE: "| `source_survival` | fraction of the target's marginal likelihood precision surviving deletion of a source | **this study's candidate, exploratory** |"
PROBLEM: E1's `share_within` has the stated survival orientation. E2's curvature form instead computes `1 - precision_without_SD_contrast / precision_full`, the fraction lost after flattening SDs. Thus a curvature value of 1 means zero survival, whereas the protocol says it means complete survival. The executable registry and exported warning also retain the withdrawn name `source_share`.
WHY IT MATTERS: The candidate's E2 separation, direction, and `SOURCE_OK` interpretation cannot be mapped to the registered diagnostic.
WOULD BE WRONG IF: `share_curv` were excluded from the candidate or were replaced by `precision_without_SD_contrast / precision_full` with a documented source deletion.

### Primary 3 computes stratified correlations instead of the registered correlation
SEVERITY: fatal
QUOTE: "**Primary 3.** Within the confounded family, the rank correlation between contraction and coverage."
PROBLEM: `anticorrelation()` splits the confounded scenarios by discordance and reports separate correlations for 0.15 and 0.40. It never computes the single correlation over the confounded family specified here.
WHY IT MATTERS: Stratified and pooled rank correlations can differ in magnitude or sign, so the registered primary output is absent.
WOULD BE WRONG IF: The protocol explicitly defined “within the confounded family” as one correlation within each discordance level.

### Placebo-arm prevalence is not 0.3
SEVERITY: serious
QUOTE: "placebo arms sit at prevalence 0.3."
PROBLEM: The code sets $\alpha=\operatorname{logit}(0.3)$, which gives conditional risk 0.3 only at $x=0$. With $\beta=0.3$ and the registered covariate distributions, marginal placebo prevalence ranges from about 0.30366 to 0.33209; the two curvature studies at SDs 1 and 3 have prevalences 0.30992 and 0.33209.
WHY IT MATTERS: The stated E2 calibration is false. If “baseline risk” means arm-level prevalence, the curvature design also fails its equal-baseline restriction.
WOULD BE WRONG IF: “Prevalence” were explicitly defined as the conditional probability at $x=0$, rather than placebo-arm prevalence.

### Overcoverage is called a failure but analyzed as success
SEVERITY: serious
QUOTE: "Both bands are two-sided: gross overcoverage is not nominal, it is a different failure."
PROBLEM: Failure is implemented solely as `coverage < 0.90`, which is one-sided. Overcovering scenarios are excluded from Primary 1 but enter the secondary false-alarm denominator through `!failed`, where they are treated as successful scenarios.
WHY IT MATTERS: The registered failure definition and the sensitivity, false-alarm, and Youden calculations use incompatible outcome classes.
WOULD BE WRONG IF: The code classified gross overcoverage as failure, or the prose described it as non-nominal but neither failing nor successful.

### Correctly specified E2 coverage disappears from the summaries
SEVERITY: serious
QUOTE: "Coverage is reported **only where the model is correctly specified**"
PROBLEM: Coverage is stored as `NA` elsewhere, but both the E2 reporter and exporter call `min()` and `max()` without `na.rm = TRUE`. Consequently, the exported coverage ranges for `additivity`, `ecological`, and `curvature` are all `NA`, even though each contains rows the code labels correctly specified.
WHY IT MATTERS: The promised E2 coverage output is not reported for three of five states.
WOULD BE WRONG IF: Row-level RDS values alone were the registered report, or the summaries filtered to correctly specified rows before computing ranges.

### Three examples do not establish “any” nuisance heterogeneity
SEVERITY: serious
QUOTE: "On a curved link, **any** between-study heterogeneity in a nuisance parameter identifies the interaction."
PROBLEM: `R/08-routes.R` checks one selected contrast each in covariate mean, covariate SD, and intercept. It supplies neither a general rank argument nor checks over all nuisance parameters or nonzero contrast values.
WHY IT MATTERS: The universal route claim and the thesis derived from it are stronger than the registered evidence.
WOULD BE WRONG IF: The nuisance-parameter space were explicitly limited to exactly these three quantities and an analytic proof covered every nonzero contrast.

### The claimed provenance chain does not generate or verify every number
SEVERITY: serious
QUOTE: "Every number here is exported from the code that computes it by `R/05-export.R`, emitted into the document by `review/emit-tables.py`, and asserted back by `review/verify-protocol.py`, currently **87** assertions."
PROBLEM: The emitter only attempts to replace a nuisance-sensitivity sentence that no longer exists; it does not emit the grid, thresholds, prevalence, arm count, or diagnostic table. The verifier hard-codes route expectations, ignores the exported diagnostic registry, and excludes `R/05-export.R` from freshness checks even though that file produces the export. It passed 87/87 despite the arm-count and diagnostic mismatches above.
WHY IT MATTERS: The stated protection against stale or contradictory registration content is not operative.
WOULD BE WRONG IF: The protocol were generated from the export and the verifier derived every checked value from its implementing computation, including freshness of the exporter itself.

### The null-control justification contains stale counts and endpoints
SEVERITY: minor
QUOTE: "Tested two-sided as its name promised, it failed: five scenarios overcover at 0.962 to 0.986."
PROBLEM: The current E1 export reports four such scenarios, ranging from 0.961 to 0.983.
WHY IT MATTERS: The numerical evidence offered for weakening the null control does not describe the current design.
WOULD BE WRONG IF: These values explicitly referred to a versioned historical artifact rather than the current registered design.

### The tight-prior recovery figures are stale
SEVERITY: minor
QUOTE: "measured, coverage recovers to 0.938, 0.875 and 0.798 at the largest budget as the likelihood wins."
PROBLEM: The current export gives 0.938 for `additivity`, 0.735 for `ecological`, and 0.725 for `own_ipd`.
WHY IT MATTERS: The quantitative justification for restricting the prior-domination control to the smallest budget is not current.
WOULD BE WRONG IF: The quoted values were explicitly tied to an archived earlier design that reproduces them.

### The bias figures and their printed spread are stale
SEVERITY: minor
QUOTE: "The tight prior's mean bias runs $-0.114$, $-0.177$ and $-0.278$ across states, a spread of 0.165 against a truth of 0.40."
PROBLEM: Current values are $-0.114$, $-0.204$, and $-0.306$ for the three informed states, giving a spread of 0.192.
WHY IT MATTERS: The measurement used to justify withdrawing “alike” no longer matches the registered run.
WOULD BE WRONG IF: The sentence were explicitly historical and its corresponding old artifact reproduced those values.

### The reported critique total does not reconcile with its table
SEVERITY: minor
QUOTE: "Five rounds of critique returned 45 findings between two reviewers"
PROBLEM: The change-history table prints 46 fatal and 39 serious findings, totaling 85 before any minor findings. No deduplication or restriction explaining 45 is stated.
WHY IT MATTERS: The document's own arithmetic does not support its headline provenance count.
WOULD BE WRONG IF: Forty-five is a separately documented deduplicated count or is explicitly limited to the fifth round rather than all five rounds.
