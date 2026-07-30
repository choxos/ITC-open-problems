VERDICT: unsound

### E2's current rules were written after E2 was inspected
SEVERITY: fatal
QUOTE: "- **E2 is partly confirmatory and partly not, and the split is stated in section 7.** Its four separation rules were committed before it ran and are confirmatory with respect to it."
PROBLEM: The current implementation has six separation rules, not four. Git history records the initial E2 run before later commits redefined `target_ratio`, replaced the source statistic, added the whole-model effective-rank rules, changed the comparison population, and rebuilt the withdrawal rule. Rerunning the same deterministic scenarios cannot make those revised rules confirmatory.
WHY IT MATTERS: The current E2 no-separation verdict and the decision not to withdraw E1 are exploratory, not confirmatory.
WOULD BE WRONG IF: An immutable record showed the current six rules, current statistic definitions, and current row exclusions were fixed before any E2 output was inspected.

### The equal-SD mechanism silently requires equal study baselines
SEVERITY: fatal
QUOTE: "Equal SDs give two identical equations and identify nothing on either link."
PROBLEM: The stated model has study-specific intercepts, $\alpha_s$. On a marginal logit scale, two studies with equal covariate means and SDs but different $\alpha_s$ do not give identical treatment equations. Their gradients with respect to $\delta_3$ and $\Gamma_3$ differ. The code obtains nonestimability by silently setting every intercept to the same `base_alpha()`. Recomputing the full information with different target-study intercepts changes its rank from 13 to 14 and makes $\Gamma_3$ estimable.
WHY IT MATTERS: The equal-SD guard, the claim that variance is the unique nonlinear aggregate route, and the proposed three-route classification do not hold under the model as stated.
WOULD BE WRONG IF: Equal target-study intercepts were an explicit registered restriction and every curvature conclusion were limited to that restriction, or marginalization were proven to eliminate $\alpha_s$.

### The proposed source share is neither the registered share nor a decomposition
SEVERITY: fatal
QUOTE: "| `source_share` | share of the target's marginal likelihood precision contributed by **randomized within-study rows** rather than by the between-study gradient | **this study's candidate replacement** |"
PROBLEM: The code now computes precision surviving after deleting aggregate rows and precision lost after flattening SDs. Those are leave-one-out robustness quantities, not additive contributions. Marginal precision is a nonlinear Schur complement. In the saved ecological and curvature cases, within-only precision and aggregate-only precision are both zero while full precision is positive. No mean-gradient contribution is computed, and the quantities do not form a three-way decomposition.
WHY IT MATTERS: `SOURCE_OK = 0.50` cannot mean that randomized evidence is the majority contributor, and this statistic cannot replace a likelihood-to-prior diagnostic. The registered candidate and its secondary performance output are invalid.
WOULD BE WRONG IF: The implementation produced three additive route contributions summing to one, proved equivalence to the stated share, and evaluated both information source and information magnitude relative to the prior.

### Primary 1 omits a registered diagnostic
SEVERITY: fatal
QUOTE: "**Primary 1, and the only one no weighting can move.** For each statistic, does the range of values taken by *failing* scenarios overlap the range taken by *nominal* ones?"
PROBLEM: `rank_screen` is one of the four registered diagnostics, but `overlap_table()` analyzes only contraction, target ratio, whole-model effective rank, and `share_within`. The estimability screen appears only in the secondary warning table.
WHY IT MATTERS: Primary 1 does not compare every registered diagnostic and does not establish whether the proposed replacement improves on the screen `cpaic` already ships.
WOULD BE WRONG IF: Primary 1 explicitly excluded `rank_screen`, or the implementation added its estimability values to the overlap analysis.

### Primary 2 changes the shared background network as well as the target route
SEVERITY: fatal
QUOTE: "**The matching is on the budget and cannot also be on arm size.** The two states have twelve and ten arms, so an equal total means per-arm sizes of $n/12$ and $n/10$. That is unavoidable:"
PROBLEM: It is not unavoidable. Six arms are shared by both designs, yet they receive $n/12$ patients under `additivity` and $n/10$ under `ecological`. This changes information about the prognostic slope, nuisance parameters, and other interactions, all of which couple to the target. Shared-arm sizes can be held equal while a fixed remaining target-subnetwork budget is divided among four or six target arms.
WHY IT MATTERS: Primary 2 cannot attribute differences in contraction or coverage solely to randomized additivity versus ecological identification.
WOULD BE WRONG IF: Target outputs were proven invariant to information in the shared arms, or the estimand were explicitly the cost of these complete allocation policies rather than the effect of information route.

### E2 directly misreports whether its conditions fired
SEVERITY: serious
QUOTE: "**E2 has been run and none of the three conditions fires.**"
PROBLEM: The immediately following table reports that `share_curv` does separate curvature from ecological, and the next paragraph states that the source-share condition fired.
WHY IT MATTERS: The document gives contradictory outcomes for its registered decision conditions.
WOULD BE WRONG IF: “Three conditions” referred to a separately defined set that excluded the source-share condition; no such set is defined.

### E1's expected-design interpretation contradicts itself
SEVERITY: serious
QUOTE: "- **E1's diagnostics are conditional on the expected covariate design.** Individual-data arms are represented by Gauss-Hermite nodes, so every E1 number is exact for a study whose covariate distribution is realized exactly and is an expectation otherwise."
PROBLEM: Section 5 correctly says substituting expected information is not averaging coverage or contraction over realized designs and that the resulting quantities are neither averages nor bounds. Section 9 then calls every E1 number an expectation. Nonlinearity means $f(E[I])$ is not $E[f(I)]$.
WHY IT MATTERS: The population-level interpretation of every E1 coverage and diagnostic result is contradictory.
WOULD BE WRONG IF: Coverage, contraction, and the other outputs were linear in the realized design, or the study actually integrated each reported quantity over realized covariate designs.

### The provenance checker is not exhaustive and is not bound to current results
SEVERITY: serious
QUOTE: "**Provenance.** Every number this document prints is exported from the code that computes it by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export, currently **121** assertions."
PROBLEM: The verifier contains 121 hand-written checks, not a completeness check. For example, it does not assert the printed 165 and 417 counts. It also reads the tracked `registered-design.json` without invoking the exporter or recomputing the ignored E1 and E2 RDS files, so stale code-result combinations can still pass 121/121.
WHY IT MATTERS: The advertised protection against stale or copied numbers does not provide the claimed guarantee.
WOULD BE WRONG IF: Verification regenerated every required result from current source and mapped every numeric protocol occurrence to an exported value before passing.

### Only Primary 1's Boolean is weighting-free
SEVERITY: serious
QUOTE: "Reported as the most reassuring failure, the least reassuring success, and the fraction of the **comparison set** lying between them."
PROBLEM: The overlap Boolean is invariant to positive reweighting of retained scenarios, but the reported fraction is an ordinary mean over grid rows and changes under reweighting or duplication. It is part of Primary 1 as written.
WHY IT MATTERS: A grid-weighted result is presented under the authority of the study's sole weighting-free primary outcome.
WOULD BE WRONG IF: The fraction were explicitly excluded from Primary 1 and labeled as a grid-weighted descriptive result.

### The claimed correctly specified mean contradicts the data-generating mechanisms
SEVERITY: serious
QUOTE: "- Fixed-effect synthesis, known residual variance, correctly specified linear mean."
PROBLEM: Discordance changes the aggregate target interaction away from the fitted common interaction, and synergy adds a covariate-dependent term absent from the fitted additive model. These are deliberate mean-model misspecifications; the implementation itself describes E1 as answering misspecified coverage.
WHY IT MATTERS: The scope statement mischaracterizes the scenarios responsible for the registered coverage failures.
WOULD BE WRONG IF: “Correctly specified” were explicitly limited to the identity link and Gaussian error form while excluding the interaction structure from the term “mean.”
