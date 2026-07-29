VERDICT: unsound

### E2’s confirmatory rule compares the wrong states
SEVERITY: fatal
QUOTE: "If, on a nonlinear link, contraction separates `ecological` from `additivity` at any threshold across the 24 scenarios, then E1's central claim is an artifact of the identity link and is withdrawn."
PROBLEM: E2 is introduced to compare `curvature` with `ecological` using both requested summaries. Its decision rule instead compares `ecological` with `additivity` using contraction alone. It therefore answers a different question.
WHY IT MATTERS: E2 could completely fail to distinguish `curvature` from `ecological` without triggering the registered withdrawal rule, so the confirmatory conclusion would be invalid.
WOULD BE WRONG IF: The intended confirmatory contrast were actually `ecological` versus `additivity` and a separate registered rule covered `curvature` versus `ecological`.

### The claimed E2 implementation and operating rules do not exist
SEVERITY: fatal
QUOTE: "Sampler policy, refit rule and failure handling are registered in `R/00-config.R` alongside the rest."
PROBLEM: `R/00-config.R` contains only E2’s link, five state labels, 200 replicates, 24-scenario count and seed. There is no scenario grid, data-generating mechanism, sample size, prior specification, sampler policy, convergence criterion, refit rule or failure handling. No E2 generator, `multinma` fitter or analysis script exists anywhere in `R/`.
WHY IT MATTERS: At least 4,800 base fits require unregistered design and analysis choices. E2 cannot be run reproducibly as specified and cannot remain confirmatory.
WOULD BE WRONG IF: A fixed, referenced implementation containing all these rules existed outside the supplied `R/` tree and was already part of the registration.

### One aggregate study does not identify the curvature interaction
SEVERITY: fatal
QUOTE: "a single aggregate study on a **nonlinear** link, whose arm mean depends on the covariate variance"
PROBLEM: Dependence on variance does not create another observed outcome. Even if baseline parameters are known, one target-containing aggregate arm supplies one probability for two unknown target parameters, the main effect $\delta_3$ and interaction $\Gamma_3$. Its information for those parameters is rank one, and changes in $\Gamma_3$ can be offset by $\delta_3$.
WHY IT MATTERS: The distinctive `curvature` state remains likelihood-rank deficient rather than providing the claimed randomized route to $\Gamma_3$. That invalidates E2’s central design premise.
WOULD BE WRONG IF: $\delta_3$ were fixed or independently identified, or the registered design supplied at least two independent target-containing aggregate contrasts. No such design is registered.

### E1 replaces random patient covariates with an expected pseudo-design
SEVERITY: fatal
QUOTE: "**Contraction and effective likelihood rank are therefore functions of the design alone, computable before a single patient is enrolled.**"
PROBLEM: For IPD, the information matrix is $X'X/\sigma^2$ and depends on the covariates actually observed after enrollment. The code instead represents each arm by 32 Gauss-Hermite nodes with fractional weights, thereby using expected covariate moments. Its diagnostics are exact only for that deterministic pseudo-design, not for samples of patients from the stated study population.
WHY IT MATTERS: Realized contraction and rank have replicate-level variation even in the Gaussian model. This invalidates E1’s asserted unit of analysis, absence of replicates and interpretation as exact patient-level coverage.
WOULD BE WRONG IF: Patient covariates were deterministically fixed in advance at the Gauss-Hermite nodes and coverage were explicitly defined conditional on that weighted design.

### The interaction-prior factor is applied to every coefficient
SEVERITY: fatal
QUOTE: "| prior SD on interactions | 0.1, 0.5, 1.0, 2.5 |"
PROBLEM: `exact_fit()` constructs `P0 <- diag(1 / prior_sd^2, b$p)`, applying the varied zero-centered prior to study intercepts, component main effects, the prognostic coefficient and interactions alike. `diag_source_share()` does the same. The protocol registers no nuisance-parameter priors, while the true main effects and prognostic coefficient are nonzero.
WHY IT MATTERS: Bias, coverage, contraction, effective rank and the controls can reflect simultaneous shrinkage of nuisance parameters rather than the registered interaction prior. Changing nuisance priors changes the E1 failure count and state summaries.
WOULD BE WRONG IF: The registered factor were intended to vary an identical prior on every coefficient, or all reported results were invariant to separately specified nuisance priors.

### The additivity state has 20% more patients
SEVERITY: fatal
QUOTE: "Every state carries the same total number of patients."
PROBLEM: The code assigns `n` to every arm. `own_ipd`, `ecological` and `absent` each contain ten arms, totaling $10n$ patients. `additivity` contains twelve arms because each target study has placebo, component 1 and combination $1+3$, totaling $12n$.
WHY IT MATTERS: Primary 2 does not isolate evidence structure: its additivity member has more information and more patients than its matched ecological member.
WOULD BE WRONG IF: `n` were a study total divided among arms, but the likelihood code uses it separately as every arm’s sample size.

### The whole-model effective rank is never analyzed
SEVERITY: fatal
QUOTE: "| `eff_rank` | likelihood-to-prior information ratio along the target's coordinate, plus the whole-model count of directions where the data outweigh the prior | **what CMP-14 asks for** |"
PROBLEM: The code computes the whole-model `eff_rank` count but omits it from `overlap_table()` and every saved primary analysis. The secondary rule labeled `eff_rank` uses only `target_ratio`. Primary 1 also omits `rank_screen`, despite being registered for “each statistic.”
WHY IT MATTERS: One of CMP-14’s two requested summaries is not evaluated, so the study cannot support a conclusion about whether effective likelihood rank distinguishes the states.
WOULD BE WRONG IF: `eff_rank` had been registered as the target ratio alone or the whole-model count appeared in another registered analysis.

### Primary 1 compares failures with nonfailures, not nominal scenarios
SEVERITY: fatal
QUOTE: "For each statistic, does the range of values taken by *failing* scenarios overlap the range taken by *nominal* ones?"
PROBLEM: `overlap_table()` defines the comparison as `failed` versus `!failed`. Thus every scenario with coverage at least 0.90 is treated as nominal, although the code separately defines nominal coverage as 0.95. It also admits 1.00-coverage prior-only scenarios as “nominal.”
WHY IT MATTERS: The central no-threshold result is computed against the wrong reference class and need not establish that the same diagnostic value occurs in both badly failing and nominally calibrated scenarios.
WOULD BE WRONG IF: “Nominal” had been operationally defined as any coverage at least 0.90 rather than 0.95.

### The proposed source share cannot distinguish curvature from ecological information
SEVERITY: serious
QUOTE: "| `source_share` | share of the target's marginal likelihood precision contributed by **randomized within-study rows** rather than by the between-study gradient | **this study's candidate replacement** |"
PROBLEM: `diag_source_share()` partitions rows solely as IPD versus aggregate. Both `curvature` and `ecological` information occur in aggregate rows, so the implemented statistic assigns both to the same “between” source. On a nonlinear link, curvature and between-study information coexist inside the same aggregate likelihood and cannot be separated by this row split.
WHY IT MATTERS: The candidate replacement cannot recognize the very state E2 adds, so its claimed causal provenance interpretation does not extend to the full registered study.
WOULD BE WRONG IF: E2 registered and implemented a separate within-aggregate decomposition that isolates curvature from between-study variation.

### The prior-domination guard does not establish behavior “alike”
SEVERITY: serious
QUOTE: "At the tightest prior and smallest arm size, coverage is below nominal in *every* state alike, which is what shows the mechanism is the prior and not the evidence structure."
PROBLEM: The guard only checks that each state’s maximum coverage is below 0.94. The saved maxima are 0.801 for `additivity`, 0.362 for `own_ipd` and 0.263 for `ecological`; the guard never compares them. Common undercoverage does not show that evidence structure played no role.
WHY IT MATTERS: This weakened positive control cannot support the registered attribution of failure to the prior rather than to prior-by-design interactions.
WOULD BE WRONG IF: “Alike” meant only “all below 0.94” and the protocol did not claim that this ruled out evidence structure, or a separate matched state-invariance check existed.

### The null guard tests only for undercoverage, not nominality
SEVERITY: serious
QUOTE: "**Null control.** With no discordance, no synergy and a prior that is not itself the problem, coverage is nominal."
PROBLEM: The implementation excludes `absent` and stops only when coverage is below 0.94. It has no upper bound and would accept coverage of 1.00, so it tests absence of severe undercoverage rather than nominal calibration.
WHY IT MATTERS: A miscalibrated or overly conservative null design can pass the guard, leaving the claimed validation of the coverage calculation unsupported.
WOULD BE WRONG IF: Nominality were registered as the one-sided condition coverage $\geq 0.94$ and exclusion of `absent` were stated in the protocol.

### Section 8 omits earlier outcome and grid changes
SEVERITY: serious
QUOTE: "**E1 is therefore reported as exact and exploratory**, and section 8 records every design choice that was changed after seeing a number."
PROBLEM: The versioned pre-protocol `DESIGN.md`, written after the three numerical probes, proposed an E1 grid containing IPD fraction and per-component states, an AUC-based failure condition, an effective-rank separation condition and a target-population contrast. The final grid and outcomes replace or remove these choices, but section 8 lists none of them.
WHY IT MATTERS: The disclosure does not provide the complete result-informed selection history it claims, so readers cannot tell which exploratory outcomes were chosen after favorable probes.
WOULD BE WRONG IF: Those documented items were never treated as design choices and were abandoned before any relevant numerical result was inspected.
