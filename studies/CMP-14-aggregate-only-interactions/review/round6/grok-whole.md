VERDICT: needs-revision

### Title says two CMP-14 summaries; body registers three
SEVERITY: fatal
QUOTE: "Protocol: what would the two summaries CMP-14 asks for actually tell an analyst?"
PROBLEM: Section 5 labels three distinct diagnostics as “what CMP-14 asks for”: `contraction`, `target_ratio`, and `eff_rank`. The protocol never says which two are “the two summaries,” so the target question of the study is not fixed.
WHY IT MATTERS: Every primary claim about whether “the summaries” separate good from bad coverage is undefined until the set of registered summaries is unique.
WOULD BE WRONG IF: CMP-14 literally asks for exactly those three and the title’s “two” is only loose wording for “the summaries,” with the three named rules jointly being the registered set (still a direct title/body contradiction as written).

### “Three forms” of the candidate statistic never defined
SEVERITY: fatal
QUOTE: "The candidate statistic is post hoc in all three of its forms. None was registered in advance."
PROBLEM: The only candidate named later is `source_survival`. No second or third form is defined, formulaed, thresholded, or tied to Primary 1–3 / secondary analyses.
WHY IT MATTERS: A registered (even exploratory) analysis object that is not specified cannot be run, reproduced, or distinguished from ad hoc variants after numbers are seen.
WOULD BE WRONG IF: The three forms are identical to three named section-5 rules, but then those rules are not all “the candidate” (`contraction` / `target_ratio` / `eff_rank` are attributed to CMP-14, not introduced here).

### Primary 1 treats every statistic the same, including the post hoc candidate
SEVERITY: fatal
QUOTE: "Primary 1, an existence claim no weighting can move. For each statistic, does the range of values taken by failing scenarios overlap the range taken by nominal ones?"
PROBLEM: Section 1 and section 5 mark `source_survival` as this study’s exploratory candidate, post hoc, with a stipulated threshold. Primary 1 still says “for each statistic” with no exclusion list and no split between CMP-14 summaries and the candidate. That is confirmatory packaging of a conceded post hoc quantity.
WHY IT MATTERS: An overlap/separation claim for `source_survival` cannot carry the same registered primary status as pre-specified CMP-14 summaries when the document itself says the candidate was not registered in advance and E1/E2 are exploratory.
WOULD BE WRONG IF: A later clause (not present here) restricts Primary 1 to `contraction`, `target_ratio`, and `eff_rank` only, and treats `source_survival` as secondary/exploratory only.

### E2 forbids coverage under misspecification; Primary 2–3 need confounded coverage
SEVERITY: fatal
QUOTE: "Coverage is reported only where the model is correctly specified, since under misspecification the score variance is not the Fisher information and the aggregate arm's expected Hessian is not either."
PROBLEM: Primary 2 compares `additivity` to `ecological`. Primary 3 is rank correlation of contraction with coverage “within the confounded family.” Confounding is discordance \(\Gamma_B-\Gamma_W\) on the ecological route (section 6), which is misspecification of the single-\(\Gamma\) model (section 2). Under the section-8 rule, E2 supplies no coverage there, so those primaries cannot be computed for E2 as specified.
WHY IT MATTERS: Either E2 does not support the registered primaries, or coverage will be reported in cells section 8 says are invalid to report; both make the E2 primary outputs uninterpretable.
WOULD BE WRONG IF: Primary 2–3 are explicitly E1-only (not stated), or “confounded family” for E2 is defined without using coverage (not stated).

### Twelve equal arms cannot match the registered patient budgets
SEVERITY: fatal
QUOTE: "Every state's target studies carry three arms, so every state has twelve arms, an identical shared background and the same per-arm size at a given budget."
PROBLEM: With twelve arms and equal per-arm size, arm size is \(N/12\). For \(N\in\{1000,3000,10000\}\) that is \(83.\overline{3}\), \(250\), \(833.\overline{3}\). Two of three registered budgets are not integers. The protocol never says \(n\) is continuous information weight rather than a patient count.
WHY IT MATTERS: The E1 grid’s “total patients per network” levels are not jointly realizable with the arm geometry as written; exported \(n\) and information scale are then ambiguous.
WOULD BE WRONG IF: Arm sizes are allowed to be non-integer throughout (pure expected-information scaling), and “patients” is only a label for that scale.

### Own-IPD background, ecological-only target, and fixed twelve-arm geometry are not jointly specified
SEVERITY: fatal
QUOTE: "Components 1, 2 and 4 stay in `own_ipd`. **Every state's target studies carry three arms**, so every state has twelve arms, an identical shared background and the same per-arm size at a given budget."
PROBLEM: Ecological identification is “only in aggregate studies, via the between-study contrast in covariate means,” which needs at least two aggregate studies that differ in means and do not supply own IPD on component 3. Holding 1, 2, and 4 in `own_ipd` requires IPD-bearing studies for those components. The text also forces every state to the same twelve arms and identical background. No arm/study map is given that satisfies all four constraints at once (e.g., 3 IPD components × 3 arms already use 9 arms, leaving one 3-arm block for a between-study mean contrast).
WHY IT MATTERS: The information states are the design. If the arm geometry cannot implement `ecological` (and likewise `curvature`) while keeping 1/2/4 as `own_ipd`, state contrasts and Primary 2 are not defined.
WOULD BE WRONG IF: An unstated but fixed map exists in which the same twelve arms realize own-IPD for 1/2/4 and multi-study aggregate-only identification for 3 without leaking IPD on 3 (not present in this text).

### ADEMP true values for the estimand and DGM are not registered
SEVERITY: fatal
QUOTE: "The estimand is the within-study effect modification \(\Gamma_W\) in the data-generating mechanism"
PROBLEM: Coverage, failure (`COVER_BAD = 0.90`), and nominal (within `0.01` of `0.95`) are registered outcomes, but the grid never states the true \(\Gamma_W\), \(\delta\), \(\beta\), \(\sigma^2\), study intercepts, or (for E2) the full linear predictor beyond “placebo arms sit at prevalence 0.3.” Discordance is given as \(\Gamma_B-\Gamma_W\), not the level of \(\Gamma_W\).
WHY IT MATTERS: Without a stated truth, “coverage” is not a defined performance measure under ADEMP; failing vs nominal sets for Primary 1–3 cannot be reproduced from the protocol alone.
WOULD BE WRONG IF: All truth values are fixed constants exported into the document elsewhere in this same text (they are not).

### E2 has no registered grid, factors, or scenario count
SEVERITY: fatal
QUOTE: "E2: the nonlinear arm"
PROBLEM: E1 registers a full factorial (504 scenarios) with explicit factors and levels. E2 only states link, asymptotic information, Laplace contraction, and a coverage restriction. No states × spreads × \(N\) × prior × discordance (or other) grid is given, and curvature appears only in the state table for E2.
WHY IT MATTERS: An experiment with no design cannot be run “as registered” or checked for the same primary comparisons.
WOULD BE WRONG IF: E2 is defined to reuse the E1 grid plus curvature with named levels (not stated here).

### Posterior covariance identity assumes a coefficient-only Gaussian model with known information
SEVERITY: serious
QUOTE: "The posterior covariance is \((I + P_0)^{-1}\), which does not involve the outcomes, so these summaries depend on the data only through the realized covariate design."
PROBLEM: That identity holds for a linear Gaussian model with known \(\sigma^2\) (or information not depending on \(y\)) and Gaussian prior on coefficients. The protocol writes \(\operatorname{Var}(y)=\sigma^2\) but does not register \(\sigma\) known vs estimated, nor how \(I\) is formed when \(\sigma\) is free. If \(\sigma\) is estimated, posterior uncertainty for \(\Gamma\) is not simply that coefficient-block formula independent of outcomes.
WHY IT MATTERS: The justification for an “exact” non-Monte-Carlo E1 arm and for design-only dependence of the summaries collapses if the registered model does not match that algebra.
WOULD BE WRONG IF: \(\sigma^2\) is fixed and known in the registered E1 computation (not stated).

### “Fails” means undercoverage only, but overcoverage is also called a failure
SEVERITY: serious
QUOTE: "A scenario **fails** if coverage is below `COVER_BAD = 0.90` [...] gross overcoverage is not nominal, it is a different failure."
PROBLEM: Primary 1’s failing set is only undercoverage. Over-covering cells are excluded from both sides, not counted as “failing scenarios.” The same word “failure” is used for a set that is not the Primary 1 failure set.
WHY IT MATTERS: Readers (and any automated classification) can put overcoverage into the failing range for separation analyses, changing Primary 1 and secondary sensitivity/false-alarm rates.
WOULD BE WRONG IF: “Different failure” is only informal prose and the only operational fail predicate is coverage \(< 0.90\) (then the prose is still misleading as written).

### Nuisance-prior “inertness is measured” is an unregistered E1 result used as design fact
SEVERITY: serious
QUOTE: "the interaction prior applies to the **interactions only**; nuisance coefficients carry a fixed `PRIOR_SD_NUISANCE = 10`, and its inertness is measured rather than asserted."
PROBLEM: Section 1 says E1 ran before the protocol and is exploratory. Presenting measured inertness as a settled property of the design treats a post-data check as if it were a registered guarantee, without defining the inertness estimand, tolerance, or pass rule.
WHY IT MATTERS: Downstream claims that interaction-prior results are unconfounded by the nuisance prior rest on an analysis that is neither specified nor exploratory-labeled here.
WOULD BE WRONG IF: Inertness measurement is fully specified as an exploratory diagnostic with a fixed rule in this document (it is not).

### “Every precision here is prior-free” cannot cover contraction
SEVERITY: minor
QUOTE: "Every precision here is prior-free, meaning \(1/[I^{-1}]_{gg}\) from the likelihood alone and exactly zero where the likelihood does not identify the coordinate."
PROBLEM: `contraction` is posterior SD over prior SD. Posterior SD uses \(I+P_0\), not the prior-free likelihood precision alone. The blanket sentence is false if it scopes all section-5 diagnostics, or at best equivocates on “precision.”
WHY IT MATTERS: Reviewers can think contraction is a pure likelihood diagnostic; it is not, and that is central to CMP-14’s prior-driven question.
WOULD BE WRONG IF: “Precision here” refers only to inputs of `target_ratio`, `eff_rank`, `rank_screen`, and `source_survival`, not to contraction (not scoped that way in the sentence).

### `additivity` cell under “randomized?” answers validity, not randomization
SEVERITY: minor
QUOTE: "`additivity` | only inside the combination \(1{+}k\), alongside an arm for 1 | yes, if additivity holds"
PROBLEM: The column header is “randomized?”. A combination trial can be randomized whether or not additivity holds. The cell mixes assignment mechanism with identification assumption.
WHY IT MATTERS: The thesis that aggregate routes are non-randomized is blurred if “randomized?” already means “valid route.”
WOULD BE WRONG IF: The column is defined as “route valid under randomization and stated assumptions” (header says only “randomized?”).
