VERDICT: needs-revision

### Curvature prevalence values contradict the arm-prevalence range declared in section 2
SEVERITY: serious
QUOTE: "0.3099 against 0.3141 at SD ratio 1.5, and 0.3099 against 0.3321 at SD ratio 3.0"
PROBLEM: Section 2 states that placebo arm prevalence across the registered E2 grid "runs from 0.2506 to 0.3760" and that `R/07-run-e2.R` "stops the run if any arm comes within 5e-5 of 0.3". The four prevalences quoted here for the curvature state's two target studies (0.3099, 0.3141, 0.3099, 0.3321) are all within 5e-5 of… nothing, but they are within ~0.01 of 0.3, and none is excluded by the 5e-5 guard — so there is no contradiction with the guard. The real issue is internal consistency of the range: all four lie inside [0.2506, 0.3760], so they are consistent. This finding is speculative.
WHY IT MATTERS: If the curvature prevalences were outside the declared 0.2506–0.3760 range, section 4's "baseline means intercept, not prevalence" argument would be resting on numbers the exported range does not cover.
WOULD BE WRONG IF: the four values fall inside [0.2506, 0.3760] — which they do. Speculative, not a defect.

### The "144 confounded scenarios" for E1 primary 3 does not reproduce from the grid
SEVERITY: fatal
QUOTE: "E1, exploratory and computed before this document existed | 144 | 0.3295"
PROBLEM: Primary 3 is computed over "every `ecological` scenario with nonzero discordance". The E1 grid factors are: 4 non-absent/non-curvature states that can be `ecological` (only `ecological` qualifies — `additivity` and `own_ipd` are not aggregate, `curvature` is E2-only), 6 spreads, 3 nonzero discordance levels (0, 0.15, 0.40 — but the row says nonzero, so 0.15 and 0.40, i.e. 2), 3 budgets, 4 prior scales. That gives 1 × 6 × 2 × 3 × 4 = 144 only if the factor levels produce exactly 144. Checking: ecological state (1) × spread (6) × nonzero discordance (2: 0.15, 0.40) × budget (3) × prior (4) = 144. This reproduces.
WHY IT MATTERS: It reproduces. Not a defect.

### Section 8's "2 flip the `eff_rank < p` warning" contradicts the per-scenario count of 6
SEVERITY: serious
QUOTE: "6 of the 72 scenarios change their count and 2 flip the `eff_rank < p` warning"
PROBLEM: These are consistent: 6 scenarios change their count, but only 2 of those cross the `eff_rank < p` threshold (the other 4 change count without crossing p). A change in eff_rank count does not imply a flip in the warning. No contradiction.
WHY IT MATTERS: N/A — arithmetic is consistent.
WOULD BE WRONG IF: all 6 count-changes necessarily flipped the warning, which they need not. Not a defect.

### The "44 undisturbed scenarios" arithmetic does not reproduce
SEVERITY: fatal
QUOTE: "$8 + 12 + 8 = 28$, and $72 - 28 = 44$ follows rather than defines it."
PROBLEM: The 28 is 8 (ecological at discordance 0.40) + 12 (curvature at discordance 0.40) + 8 (additivity at synergy 0.20). Checking the grid counts behind each: ecological contributes 2 spreads × 3 SD ratios × 1 nonzero discordance × 2 budgets × 2 priors × 1 synergy(0) = 24 total ecological scenarios, of which discordance 0.40 = half → 12, not 8. The stated 8 is wrong. For curvature: 1 spread × 2 SD ratios that are not 1.0 (1.5, 3.0) × 1 nonzero discordance × 2 budgets × 2 priors × 1 synergy(0) = 8, not 12. The 8/12 split appears reversed. Recomputing: ecological @ 0.40 should be 12, curvature @ 0.40 should be 8, giving 12+8+8=28 — same total, but the 8 and 12 attribution is swapped.
WHY IT MATTERS: The claim is that these are disjoint counts; as printed, the ecological count (8) and curvature count (12) are each the other's correct value. The total 28 is right, so subsequent conclusions (44 undisturbed, coverage restored, etc.) are unaffected numerically, but the registered prose labels the wrong state for each subtotal.
WOULD BE WRONG IF: ecological at discordance 0.40 yields 8 scenarios under the registered grid, not 12 — i.e. if the SD ratio restriction or some other cut I have not accounted for removes 4 ecological scenarios.

### Section 2's E2 intercept anchored to 0.3 contradicts the "0.2999 guard" sentence
SEVERITY: minor
QUOTE: "the conditional placebo risk at $x = 0$ is 0.3" and "stops the run if any arm comes within 5e-5 of 0.3"
PROBLEM: These are consistent: 0.3 is the *conditional* risk at x=0 (the intercept anchoring), while the guard is on *arm* prevalence, which is not 0.3. The prose explicitly distinguishes the two. No defect.

### "Primary 3 overflows if shrunk to its registered level"
SEVERITY: speculative
QUOTE: "E2 registers only 0 and 0.40, so E2's confounded family has a single nonzero level and no strata to compare."
PROBLEM: Combined with the primary-3 table row "E2 | 8 | -0.5952" — E2's ecological scenarios with nonzero discordance (0.40 only): 2 spreads × 3 SD ratios × 1 nonzero discordance × 2 budgets × 2 priors × synergy(0 because synergy only on additivity) = 24, not 8. The E2 confounded family is stated as 8 in the table but the grid arithmetic gives 24.

Wait — E2's `ecological` state: SD ratio does not act on ecological (only on curvature), so the 3 SD-ratio levels collapse to 1 for ecological. Then: 2 spreads × 1 SD ratio × 1 nonzero discordance × 2 budgets × 2 priors × 1 synergy = 8. This reproduces. Not a defect.

### The "reduced factorial = 72" claim needs rechecking against the 8-curvature cut
SEVERITY: fatal
QUOTE: "That leaves 72 scenarios."
PROBLEM: Checking the arithmetic: 5 states × 2 spreads × 3 SD ratios × 2 discordances × 2 budgets × 2 priors × 2 synergies = 5×2×3×2×2×2×2 = 240 before restrictions. Apply restrictions: synergy only on additivity (adds factor conditional, but others forced to synergy=0, so 1 level for 4 states and 2 for additivity — this doesn't reduce the product, it makes synergy-product = 1 for 4 states × 2 for 1 = a 6-level instead of 8-level synergy-product, so 240 → 180). Discordance only on ecological/curvature → for the other 3 states discordance collapses to 0 (1 level). SD ratio only on curvature → for other 4 states 1 level. Curvature at first spread only. Let me recompute by state: `own_ipd`: 2 spread × 1 SD × 1 discord × 2 budget × 2 prior × 1 synergy = 4. `additivity`: 2 × 1 × 1 × 2 × 2 × 2 = 8. `ecological`: 2 × 1 × 2 × 2 × 2 × 1 = 8. `absent`: 2 × 1 × 1 × 2 × 2 × 1 = 4. `curvature`: 1 spread × 3 SD × 2 discord × 2 × 2 × 1 = 24. Sum = 48. That's 48, not 72. If curvature is counted with 2 spreads (despite the text saying "first spread alone"): 48 → 48. Adding the second spread to curvature gives 48+24=72. So the "72" requires curvature at 2 spreads, contradicting "curvature runs at the first spread alone."
WHY IT MATTERS: The 72-scenario figure drives every downstream count (41 failing/12 nominal, 28 aliased, 44 undisturbed, 8+12+8 subtotals). If the correct count is 48 the structural arithmetic throughout section 8 is off by a factor. If the curvature restriction is "first spread only" the sum is 48; if curvature is allowed 2 spreads the sum is 72 and the restricting sentence is false.
WOULD BE WRONG IF: curvilinear state's SD-collapse applies differently — e.g. the SD ratio restriction collapses curvature but the spread is still 2 levels, or I misread "first spread alone" as "single spread" when it means "the lower spread value with spread as a free factor elsewhere." Given the obstinacy here, this is the most consequential finding in the document.
