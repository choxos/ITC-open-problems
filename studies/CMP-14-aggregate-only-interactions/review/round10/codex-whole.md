VERDICT: needs-revision

### The registered secondary analysis is absent on E2
SEVERITY: serious
QUOTE: "**Secondary, and grid-weighted.** Sensitivity, false-alarm rate and Youden index at the registered thresholds."
PROBLEM: The software computes these outcomes only for E1. `evaluate_e2()` saves neither warning columns nor `eff_rank_of`, and the exported `warnings` table comes exclusively from E1. Consequently the nearby 0.3043, 0.0355, 71/84 and 6/169 figures are unlabeled E1 results in a section covering both arms. Applying the registered rules to `e2.rds` gives materially different E2 results, including contraction sensitivity 0.8049 and false-alarm rate 0.
WHY IT MATTERS: The registered secondary analysis cannot be reported for the nonlinear arm, and the figures presented as the study's secondary results describe only E1.
WOULD BE WRONG IF: Secondary outcomes were explicitly restricted to E1, or an E2 code path produced and exported all five warning-rule metrics.

### A computed E2 primary is relabeled as untested
SEVERITY: serious
QUOTE: "Primary 2 is **untested** there: 16 matched pairs yield 1 close one, so the E1 gap of 0.951 is neither confirmed nor refuted."
PROBLEM: The registered rule requires at least one pair passing `PAIRS_CLOSE_TOL`, then reports the maximum absolute coverage gap. E2 has one such pair, so the outcome is defined and tested. Its exact gap is 0.0001285636, which the exporter rounds to 0. No minimum acceptable number of close pairs was registered.
WHY IT MATTERS: This invalidates the summary that one primary reproduces, one is untested and one reverses. The grid may be sparse, but that is not the same as the registered outcome being undefined.
WOULD BE WRONG IF: The protocol registered a minimum of more than one close pair, E2 had no close pair, or primary 2 were explicitly restricted to E1.

### The aliasing tolerance is verified against a literal, not the registered constant
SEVERITY: serious
QUOTE: "The worst gap over the grid is **2.22e-16**, against a registered tolerance `E2_ALIAS_TOL` of 1e-12."
PROBLEM: `R/05-export.R` does not export `E2_ALIAS_TOL`. The verifier instead compares the exported gap against its own literal `1e-12` and never checks that the tolerance quoted here equals the value in `R/00-config.R`. The two currently coincide, but the asserted provenance link does not establish that.
WHY IT MATTERS: This threshold is the guard that permits coverage on 28 aliased scenarios. Changing or weakening the implemented tolerance could leave the protocol and verifier agreeing on a stale value.
WOULD BE WRONG IF: The exporter read and emitted `E2_ALIAS_TOL`, and the verifier compared both the prose and measured gap against that exported value.

### Executable output restores the general route claim that the protocol revoked
SEVERITY: serious
QUOTE: "On a curved link any between-study heterogeneity in a nuisance parameter identifies the interaction"
PROBLEM: `R/08-routes.R` still prints this statement. The protocol explicitly says that “any” is unsupported because the computation checks only three fixed nonzero contrasts, with no general rank argument or sweep over contrast sizes.
WHY IT MATTERS: Running the registered route analysis reports a general theorem that its evidence does not establish, overstating the central aggregate-route conclusion.
WOULD BE WRONG IF: The implementation proved the general rank claim or exhaustively checked the relevant nuisance quantities and contrast sizes.

### The E1 aliasing verifier masks a number that disagrees with its artifact
SEVERITY: serious
QUOTE: "E1's exact Gaussian bias, computed with no aliasing algebra in it at all, equals the same $\text{shift} - [(I+P_0)^{-1}P_0\theta^{*}]_{\Gamma_3}$ expression to **1.06e-15** over 40 scenarios"
PROBLEM: `results/e1-aliasing.rds` contains 1.0547118733938987e-15, and the registered export correctly reports 1.05e-15 at three significant figures. The verifier conceals the discrepancy by replacing the literal `1.06e-15` in the protocol with the exported value before testing membership.
WHY IT MATTERS: A check advertised as catching stale numbers is explicitly rewriting this stale number so that it passes.
WOULD BE WRONG IF: The artifact rounded to 1.06e-15 under the stated precision, or the verifier compared the protocol text directly without its replacement.

### The round-level standing repair still misses E2 candidate verdicts
SEVERITY: serious
QUOTE: "Every outcome that reports it says so on the row."
PROBLEM: Candidate standing was added to E2 scenario and by-state rows, but the verdict fields for `surv_between`, `surv_sd` and their separation remain bare, with one detached `candidate_standing` sibling. The intended runtime line also reads nonexistent `v$surv_separates_curvature` instead of `v$surv_sd_separates`, so it cannot report the second-form result correctly. The verifier checks E2 state rows and the unrelated CMP-14 rule rows, not these candidate verdict fields.
WHY IT MATTERS: The post hoc E2 candidate result is either silently omitted or exposed without the row-level exploratory status the protocol promises.
WOULD BE WRONG IF: Every candidate verdict carried its own standing and the runtime referenced the field actually returned by `e2_verdict()`.

### The claimed complete export still omits quoted repair evidence
SEVERITY: serious
QUOTE: "`R/05-export.R` writes every quantity this document quotes to `results/registered-design.json`"
PROBLEM: The quoted claim that the incorrect interaction truth moved E1 coverage by up to 0.44 and reclassified 11 scenarios is neither computed nor exported. Those values occur only in prose and comments, and the verifier has no assertion for them.
WHY IT MATTERS: These numbers are offered as evidence that the truth-table repair materially changed the study, but they remain vulnerable to exactly the stale or invented-number failure the provenance paragraph claims to prevent.
WOULD BE WRONG IF: The counterfactual coverage movement and reclassification count were computed, exported and verified, or the completeness claim were narrowed.

### The E1 primary-2 maximum is not a lower bound of 0.951
SEVERITY: minor
QUOTE: "The claim is that two evidence structures a reader would call identically well identified differ by **at least that much** in whether the interval covers."
PROBLEM: The exact maximum absolute gap in `e1.rds` is 0.9505515516. It rounds upward to the displayed 0.951, but therefore does not establish a difference of at least 0.951.
WHY IT MATTERS: The literal lower-bound wording of primary 2 is arithmetically false, although the qualitative result is unchanged.
WOULD BE WRONG IF: The unrounded maximum were at least 0.951, or “that much” were explicitly presented as an approximate rounded value rather than a bound.

### The old withdrawal name remains in normal runtime output
SEVERITY: minor
QUOTE: "=== the registered withdrawal rules ==="
PROBLEM: `R/07-run-e2.R` still prints this heading over the six state-separation comparisons, immediately before explaining that they are not a withdrawal criterion for E1.
WHY IT MATTERS: The normal run remains self-contradictory and reintroduces the interpretation that round 9 was supposed to remove.
WOULD BE WRONG IF: The heading referred to a different registered withdrawal rule or had been renamed to state-separation comparisons.

### The change history still credits a three-reviewer total to two reviewers
SEVERITY: minor
QUOTE: "Nine rounds of critique returned **157** fatal and serious findings between two reviewers"
PROBLEM: The table names Codex, Grok and GLM. Codex and Grok contribute 152 findings; GLM's five round-8 findings are required to reach 157.
WHY IT MATTERS: The protocol says three reviewers while its referenced change history still gives incompatible provenance for the same total.
WOULD BE WRONG IF: GLM's five findings were excluded from 157 or GLM were not a distinct reviewer.
