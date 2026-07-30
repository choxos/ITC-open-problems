The protocol was truncated mid-document; reading the full offloaded prompt so the review can cover every section.VERDICT: unsound

### Synergy is described as an arm-level add-on but aliased as a pure Γ₃ shift
SEVERITY: fatal
QUOTE: "Synergy adds its amount to arms holding components 1 and 3 together, and in `additivity` the target appears in no other arm. In both cases every row the departure touches carries the target and every target-bearing row is touched, so a **single shifted coefficient reproduces the truth exactly**: … θ* = θ_true + shift · e_Γ₃."
PROBLEM: The “so” does not follow. Touching only target-bearing rows is necessary for a one-parameter reparameterization, not sufficient. Discordance is described as adding to the target *modification* (same functional role as Γ₃). Synergy is described as adding an *amount to arms* (the usual main-effect additivity violation on η). A constant (or main-effect) add-on on combination arms is collinear with an intercept/main-effect direction, not with the individual-level column x·c₃, so it is not absorbed by shift · e_Γ₃ for all x. The same section says the identity is checked “pointwise in the covariate” with worst gap 2.22e-16; that numerical claim and the arm-level synergy wording cannot both be true under a standard main-effect synergy.
WHY IT MATTERS: The registered reason coverage is reported on all 72 scenarios, including the 8 synergy scenarios, is that departure is aliasing rather than misspecification. If synergy is not a pure Γ₃ shift, those scenarios are misspecified, the coverage formula and the “28 scenarios gain a coverage figure” repair are wrong, and the E2 performance measures for additivity-with-synergy are uninterpretable as registered.
WOULD BE WRONG IF: Synergy is implemented as an interaction-shaped term (an add-on to the x·c₃ contribution, or otherwise exactly equal to ΔΓ₃ · x · c₃ on combination rows for every x), so that “adds its amount to arms” is only loose wording for a Γ-level departure.

### Section 7 says every number is E1, then reports an E2 primary result
SEVERITY: fatal
QUOTE: "**Every number in this section is an E1 number and E1 is exploratory.**"
PROBLEM: The same section’s Primary 3 table reports “**E2** | 8 | **-0.5952**” and builds the split finding that “the E1 finding does not reproduce on the nonlinear arm” on that number. The global sentence is false in the section that contains it.
WHY IT MATTERS: This is the programme’s dominant failure mode (a claim in one place contradicted in another). Readers are told all Section 7 numbers share E1’s standing and provenance; −0.5952 does not. It also undermines the document’s own rule that E1 and E2 must not be fused under one heading.
WOULD BE WRONG IF: The quoted sentence is restricted (in the document) to a subset of Section 7 that excludes the Primary 3 table, or −0.5952 is not a Section 7 number (it is).

### “Section 8 establishes … on both arms” but Section 8 only measures E2
SEVERITY: fatal
QUOTE: "the likelihood is satisfied exactly at Γ_W + shift, and the size of the resulting error is what the study measures. Section 8 establishes that this holds to machine precision on both arms."
PROBLEM: Section 8 is the nonlinear arm. The machine-precision identity (worst gap 2.22e-16, tolerance 1e-12) is an E2 check in `R/07-run-e2.R`. E1 is the “exact arm”; nothing in Section 8 establishes the same pointwise identity for E1. Elsewhere the document uses “arm” for E1 vs E2 (“exact arm”, “nonlinear arm”, Primary 3 table), so “both arms” reads as E1 and E2, not as two treatment arms inside E2.
WHY IT MATTERS: The estimand story (fitted Γ estimates Γ_W + shift; coverage error is the object of study) is foundational for both experiments. Pinning E1’s version of that story on an E2-only measurement reintroduces the typed-from-the-wrong-place class of defect Round 7 already killed for the truth table.
WOULD BE WRONG IF: “Both arms” is defined in-document as two treatment arms inside the E2 check only, and E1’s aliasing identity is established elsewhere by a reported measurement (it is not), or E1 is not claimed to rely on that identity (it is).

### 20.11% is sold as the non-Gaussian caveat but measures Gaussian vs Gaussian
SEVERITY: serious
QUOTE: "**E2's contraction figures describe a Gaussian approximation** to a non-Gaussian posterior, and section 8 measures how far it sits from its Laplace analogue: up to **20.11%** in relative terms. That is the largest single caveat on any E2 number."
PROBLEM: Section 8’s 20.11% is the gap between the registered Fisher-at-θ* contraction and a Laplace contraction from the observed Hessian at the mode. Both are Gaussian approximations. That gap does not measure distance from either approximation to the true non-Gaussian posterior. The sentence chains “non-Gaussian posterior” to “20.11%” and then calls that the largest E2 caveat, which treats the wrong reference quantity as the bound on reading E2 contractions.
WHY IT MATTERS: Every E2 contraction, and any E2 conclusion that uses contraction (Primary 3, separation rules, Primary 2 matching), is caveated with a number that does not answer the non-Gaussian worry the bullet names.
WOULD BE WRONG IF: The document only claimed 20.11% as the Fisher-at-θ* vs Laplace gap and separately stated that error vs the true posterior is unmeasured (the “largest single caveat” line ties the 20.11% to the non-Gaussian framing).

### Primary 2 claims “arbitrarily” from a finite-grid maximum
SEVERITY: serious
QUOTE: "The claim is that two evidence structures a reader would call identically well identified can differ **arbitrarily** in whether the interval covers."
PROBLEM: The registered analysis reports a maximum absolute coverage gap over matched pairs with contraction difference < 0.02 on a finite grid. A finite maximum does not establish arbitrary difference.
WHY IT MATTERS: This is the stated claim of Primary 2. As worded, the claim cannot be supported by the registered computation even if the max gap is large.
WOULD BE WRONG IF: “Arbitrarily” is replaced by a finite, registered functional of the grid (e.g. that max gap), or the document only claims a large measured gap without “arbitrarily.”

### Primary 2 matching leaves discordance unspecified while E2 text implies discordance 0
SEVERITY: serious
QUOTE: "`additivity` against `ecological`, matched on spread, total patient budget and prior scale, with synergy off."
PROBLEM: Discordance is an ecological-only factor and is not listed as a matching key. The same document later says Primary 2’s “eight scenarios per state sat at discordance zero.” Those cannot both define the same analysis: free discordance yields more than one ecological partner per key and is what would drive large coverage gaps; discordance fixed at 0 is a different, much weaker comparison. The registered pair set is therefore underdetermined.
WHY IT MATTERS: Primary 2 is a primary outcome. If discordance is free, the E2 “eight scenarios… discordance zero” history is wrong; if discordance is fixed at 0, the motivating claim about coverage failure under equally reassuring diagnostics is not the confounded comparison the study elsewhere treats as central.
WOULD BE WRONG IF: A single explicit rule (in config and prose) states whether pairs are formed only at discordance 0 or across all discordance levels, and both the E1 definition and the E2 “eight scenarios” sentence follow that rule.

### E2 “withdraw E1’s conclusion” tests a conclusion E1 never states
SEVERITY: serious
QUOTE: "**E1's conclusion is withdrawn if any of the six separates.** … **None of the six separates**, which is the E2 result."
PROBLEM: E1’s registered primaries are (1) overlap of diagnostic ranges for fail vs nominal, (2) max coverage gap at matched contraction between additivity and ecological, (3) sign of corr(contraction, coverage) in confounded ecological scenarios. None is “the three CMP-14 rules’ ranges fail to separate additivity from ecological/curvature.” Range separation of diagnostics across states is a different proposition. The withdrawal rule therefore does not withdraw any stated E1 primary.
WHY IT MATTERS: The only registered bridge from E2 back to E1 is this withdrawal criterion. As written it cannot do what it claims, so the E2 result does not have the stated consequence for E1.
WOULD BE WRONG IF: “E1’s conclusion” is explicitly defined as non-separation of additivity from ecological (or curvature) on those three diagnostics, and that is one of E1’s registered primaries (it is not).

### Outcomes section reports Primary 3 and FAR but not Primary 1 or Primary 2 results
SEVERITY: serious
QUOTE: "**Primary 1, an existence claim no weighting can move.** For each statistic, does the range of values taken by failing scenarios overlap the range taken by nominal ones?"
PROBLEM: Section 7 is an Outcomes section that prints concrete E1 results (ρ = 0.3295, FAR 0.0355 / 0.3043) and defines Primary 1 and Primary 2 as primary claims, but never states whether Primary 1’s ranges overlap or what Primary 2’s max coverage gap is. The existence claim and the matched-gap claim are the primary deliverables; their answers are missing while secondary and Primary 3 numbers are present.
WHY IT MATTERS: For an exploratory computation that already ran, the registration-plus-outcomes document does not record the primary answers it says the study exists to report, so those claims are not checkable against the export the way ρ and FAR are.
WOULD BE WRONG IF: Primary 1 and Primary 2 numerical answers appear in this document (they do not) or Section 7 is only prospective definition with no results (it reports results for other outcomes).

### Guard against prevalence 0.3 only tests exact equality
SEVERITY: minor
QUOTE: "`R/07-run-e2.R` computes the range and stops the run if any arm hits 0.3 exactly."
PROBLEM: The substantive claim is that placebo *arm* prevalence is not 0.3 and runs from 0.2506 to 0.3760. Stopping only on exact equality to 0.3 is almost inert under floating-point evaluation and does not enforce the reported range, nor “never approximately 0.3.”
WHY IT MATTERS: Round 7’s lesson was that guards must measure what the prose claims. This guard measures a weaker event than the claim it sits next to (the range export is the real check, if it exists).
WOULD BE WRONG IF: The only claim tied to that stop is “no arm equals 0.3 in floating point,” with the range enforced by a separate assertion that fails when min/max leave [0.2506, 0.3760].
