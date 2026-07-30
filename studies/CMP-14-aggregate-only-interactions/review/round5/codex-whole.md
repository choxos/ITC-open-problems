VERDICT: unsound

### The equal-SD guard silently assumes identical study baselines

SEVERITY: fatal  
QUOTE: "Equal SDs give two identical equations and identify nothing on either link."  
PROBLEM: The registered model has study-specific intercepts, $\alpha_s$, but E2 sets every intercept to the same `base_alpha()`. With different target-study baselines, the equal-SD logit information changes from rank 13 to rank 14 and $\Gamma_3$ becomes estimable. `R/08-routes.R` reproduces this counterexample, but the protocol and verification pipeline ignore it.  
WHY IT MATTERS: This invalidates the equal-SD negative control, the claimed curvature mechanism, and the three-route taxonomy supporting E2.  
WOULD BE WRONG IF: Equal target-study baselines were an explicit registered restriction and every curvature conclusion were limited to that special case, or differing baselines were proved unable to identify $\Gamma_3$.

### E2 was not run on the current implementation

SEVERITY: fatal  
QUOTE: "**E2 has been run and none of the three conditions fires.**"  
PROBLEM: The saved E2 artifacts predate the arm-network change in `build_state()`. They contain the old `own_ipd` contraction range, 0.0536 to 0.7591; the current implementation produces approximately 0.0584 to 0.7843. The exporter and verifier reuse the stale RDS instead of rerunning E2.  
WHY IT MATTERS: The E2 verdict, withdrawal decision, and claimed nonlinear robustness are not bound to the implementation being preregistered.  
WOULD BE WRONG IF: A current end-to-end rerun produced the saved E2 artifact from the present source and recorded that source-artifact binding.

### E2's claimed route comparison also changes arm allocation

SEVERITY: fatal  
QUOTE: "The claim under test is that `curvature` and `ecological` are the same kind of evidence, both unrandomized between-study contrasts differing only in which moment carries them, and that no summary of the information matrix should or does separate them from each other while all of them fail to separate either from `additivity`."  
PROBLEM: Current `curvature` has ten arms, while `ecological` and `additivity` have twelve. At a 3,000-patient budget this gives curvature 300 patients per arm and the other states 250, including different sizes in their shared background studies. The states therefore differ in more than the identifying moment.  
WHY IT MATTERS: E2 cannot attribute separation or nonseparation to mean-gradient, curvature, or additivity evidence alone.  
WOULD BE WRONG IF: E2 matched target and background arm allocations across these states, or target diagnostics were proved invariant to the differing background information.

### E2's current rules are falsely called registered

SEVERITY: fatal  
QUOTE: "It was run after these rules were committed, so the rules are registered with respect to it even though E1's are not."  
PROBLEM: The registration-status section concedes that the current rules were rebuilt after E2's output was read. The saved E2 verdict was also generated before the commit containing those rules. Rerunning a deterministic calculation cannot restore prospective registration.  
WHY IT MATTERS: The withdrawal decision and no-separation verdict have exploratory standing only, contrary to the authority claimed here.  
WOULD BE WRONG IF: An immutable record contained the current six rules, current statistic definitions, and current row exclusions before any E2 output was inspected.

### `SOURCE_OK` is still interpreted as a contribution share

SEVERITY: fatal  
QUOTE: "Its 0.50 is a stipulation, chosen as the point at which randomized evidence stops being the majority contributor, and the secondary table is the only outcome that depends on it."  
PROBLEM: The implementation computes precision surviving after aggregate rows are deleted. It explicitly is not an additive contribution share. When sources identify a parameter only jointly, a survival ratio of 0.50 has no interpretation as a majority contribution.  
WHY IT MATTERS: The registered `SOURCE_OK` warning rule, and therefore its sensitivity, false-alarm rate, and Youden index, have no stated meaning.  
WOULD BE WRONG IF: The statistic were proved to equal additive source contributions summing to one, or the threshold were redefined solely as a survival criterion without majority language.

### The nuisance-prior check does not measure every registered quantity

SEVERITY: fatal  
QUOTE: "Every scenario is re-evaluated with the nuisance scale at 3 and at 30, an order of magnitude either side, and the largest movement in any registered quantity across the whole grid is **0.0005 in coverage, 0.0001 in contraction and 0.0000 in the source survival fraction**. The interaction prior is the only prior doing work, within that tolerance."  
PROBLEM: `nuis_move` checks only those three columns. It omits bias, posterior SD, sampling SD, effective rank, and the primary analyses. Recomputing the current formulas shows an omitted bias movement of about 0.0019, already larger than the claimed maximum. Comparing scales 3, 10, and 30 also does not establish equivalence to removing the nuisance prior.  
WHY IT MATTERS: The attribution of E1 behavior solely to the interaction prior is unsupported.  
WOULD BE WRONG IF: Every registered output were compared, and a zero-precision nuisance-prior calculation or valid bound established the claimed inertness.

### Primary 1 prints stale scenario counts

SEVERITY: fatal  
QUOTE: "That drops the nominal count from 241 to 165 and the comparison set from 493 to 417; every statistic still overlaps."  
PROBLEM: The current E1 analysis contains 169 nominal scenarios and 420 compared scenarios, not 165 and 417. The current failed count is 251, and 251 plus 169 reproduces 420.  
WHY IT MATTERS: Two printed primary-outcome quantities do not describe the registered analysis, despite the provenance guarantee.  
WOULD BE WRONG IF: These numbers were explicitly labeled as historical counts from an earlier grid rather than current Primary 1 output.

### The null-control guard permits the mechanism it claims to reject

SEVERITY: fatal  
QUOTE: "some scenarios overcover, all of them `ecological` at the smallest between-study spread where the posterior SD exceeds the sampling SD of its own centre."  
PROBLEM: The smallest registered spread is 0.3, but both `R/03-run-e1.R` and the smoke test accept overcoverage at any `spread <= 0.6`. A violation at the second-smallest spread therefore passes. The verifier does not check the overcovering spreads.  
WHY IT MATTERS: The weakened control does not enforce the mechanism used to explain away null overcoverage.  
WOULD BE WRONG IF: The intended condition explicitly included both 0.3 and 0.6, or the guard required `spread == 0.3`.

### An undefined source statistic is analyzed as zero

SEVERITY: fatal  
QUOTE: "`absent` is undefined rather than zero, because a parameter the likelihood does not identify at all has no shares to apportion."  
PROBLEM: `overlap_table()` replaces absent-state `NA` values with zero, and `warnings_from()` turns them into source warnings. Thus Primary 1 ranges and the secondary classifier analyze a numeric value the protocol says does not exist.  
WHY IT MATTERS: The registered source-survival overlap and threshold-performance outputs are not analyses of the defined statistic.  
WOULD BE WRONG IF: Undefined cases were excluded from numerical summaries or handled as a separately preregistered categorical outcome.

### E2 directly contradicts itself about which conditions fired

SEVERITY: serious  
QUOTE: "**E2 has been run and none of the three conditions fires.**"  
PROBLEM: The following table reports that `share_curv` separates `curvature` from `ecological`, and the next paragraph explicitly says the source-share condition fired. That is one of the three preceding conditions.  
WHY IT MATTERS: The document gives incompatible outcomes for its E2 decision rules.  
WOULD BE WRONG IF: “Three conditions” referred to a separately defined set excluding source separation; no such set is defined.

### Source survival is not strictly more informative than the requested summaries

SEVERITY: serious  
QUOTE: "One does, it costs nothing, and it is strictly more informative than either summary CMP-14 asked for."  
PROBLEM: Source survival is prior-free and normalized by full likelihood precision. It discards the absolute information magnitude and the prior scale, so scenarios with radically different prior domination can have identical survival values. Conversely, contraction cannot recover evidence route. Neither statistic contains the other.  
WHY IT MATTERS: The proposed statistic may complement contraction or effective rank, but it cannot replace them or claim strict informational dominance.  
WOULD BE WRONG IF: The proposed output jointly included route survival, full likelihood precision, and prior precision and was shown to determine the requested summaries.

### The claimed exhaustive provenance check is demonstrably incomplete

SEVERITY: serious  
QUOTE: "**Provenance.** Every number this document prints is exported from the code that computes it by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export, currently **123** assertions."  
PROBLEM: The verifier passes 123 of 123 while missing the stale 165 and 417 counts. It reads a preexisting JSON export, does not regenerate E1 or E2, and ignores `R/08-routes.R` and `results/routes.rds`.  
WHY IT MATTERS: A clean verification result does not establish that the protocol matches current code or results.  
WOULD BE WRONG IF: Verification reran the complete current pipeline and exhaustively mapped every numeric protocol claim to regenerated output.

### E1's expected-design interpretation contradicts itself

SEVERITY: serious  
QUOTE: "Individual-data arms are represented by Gauss-Hermite nodes, so every E1 number is exact for a study whose covariate distribution is realized exactly and is an expectation otherwise."  
PROBLEM: Section 5 correctly states that substituting expected information is not averaging coverage, contraction, or another nonlinear output over realized designs. Therefore the resulting number is not “an expectation otherwise.”  
WHY IT MATTERS: The population interpretation of every E1 diagnostic and coverage result is ambiguous.  
WOULD BE WRONG IF: The reported quantities were linear in the realized design or were actually integrated over the distribution of realized designs.

### Primary 1 contains a grid-weighted quantity

SEVERITY: serious  
QUOTE: "**Primary 1, and the only one no weighting can move.**"  
PROBLEM: Its overlap Boolean and extrema are unaffected by positive scenario weights, but the reported “fraction of the comparison set” is an ordinary row mean. Reweighting or duplicating scenarios changes that fraction.  
WHY IT MATTERS: A grid-weighted result is presented under the authority of the only supposedly weighting-free primary outcome.  
WOULD BE WRONG IF: The fraction were excluded from Primary 1 and explicitly labeled as grid-weighted.

### The per-arm sample-size arithmetic holds at only one budget

SEVERITY: serious  
QUOTE: "every state's target studies now carry three arms, so every state has twelve arms, 250 patients per arm and an identical background."  
PROBLEM: Twelve arms have 250 patients each only when the total budget is 3,000. The registered budgets are 1,000, 3,000, and 10,000, giving 83.333, 250, and 833.333 patients per arm. Two are not even realizable integer patient allocations.  
WHY IT MATTERS: The stated design does not describe two-thirds of the grid and silently treats patient counts as continuous information weights.  
WOULD BE WRONG IF: The sentence were explicitly limited to the 3,000-patient scenario and a rounding or continuous-information-budget rule were registered for the other budgets.

### The mean model is deliberately misspecified in registered scenarios

SEVERITY: serious  
QUOTE: "- Fixed-effect synthesis, known residual variance, correctly specified linear mean."  
PROBLEM: Nonzero discordance changes the aggregate target interaction away from the fitted common interaction, and nonzero synergy adds a covariate-dependent term absent from the fitted additive mean. Those are deliberate mean-model misspecifications.  
WHY IT MATTERS: The scope statement mischaracterizes the scenarios producing the registered coverage failures.  
WOULD BE WRONG IF: “Correctly specified” were explicitly restricted to zero-discordance, zero-synergy scenarios or only to the Gaussian identity-link form rather than the fitted mean.

### The four-state E2 conclusion is broader than the implemented comparisons

SEVERITY: minor  
QUOTE: "neither summary CMP-14 asks for separates any of these four states from any other, on the nonlinear link as on the linear one."  
PROBLEM: `e2_verdict()` checks only `additivity` versus `ecological` and `additivity` versus `curvature`. It does not check `own_ipd` against any state or `ecological` against `curvature`, although four states require six pairwise comparisons.  
WHY IT MATTERS: The broad pairwise statement is not established by the registered E2 rule table.  
WOULD BE WRONG IF: Another registered calculation evaluated every pair among the four intended states.
