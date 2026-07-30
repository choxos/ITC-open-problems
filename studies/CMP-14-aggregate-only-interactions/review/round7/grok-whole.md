The protocol text was truncated in the prompt; reading the full offloaded file so the review can cover the complete document.VERDICT: unsound

### E2 Fisher information is registered at two incompatible parameter points
SEVERITY: fatal
QUOTE: "Contraction in E2 is contraction of a normal approximation whose covariance is $(I(\theta_{\text{true}}) + P_0)^{-1}$, the expected Fisher information at the true parameter plus the prior precision."
PROBLEM: The same section also registers coverage and bias from information at the aliased parameter: "Everything is evaluated at $\theta^{*}$, including the information" with $I^{*}$ in the bias formula, and the contraction-gap procedure is described as recomputing contraction "at $\theta^{*}$ where a departure acts." Under discordance or synergy, true arm probabilities equal the model at $\theta^{*}=\theta_{\text{true}}+\text{shift}\cdot e_{\Gamma_3}$, not at $\theta_{\text{true}}$. On the logit link, $I$ depends on those probabilities, so $I(\theta_{\text{true}})$ is not the expected Fisher of those scenarios' DGM. The protocol therefore defines E2 contraction and E2 coverage from different information matrices whenever shift $\neq 0$ (the 28 scenarios the study exists to examine). The gap story then attributes the full 14.64% only to mode-versus-truth displacement, while part of any $I(\theta_{\text{true}})$ versus $I(\theta^{*})$/mode comparison is a parameter-point mismatch the prose does not isolate.
WHY IT MATTERS: Invalidates every E2 contraction figure under departure, the registered contraction–coverage relationship for those scenarios, the interpretation of the 0.0882 / 14.64% gap, and any E2 Primary 3 that correlates contraction with coverage under nonzero discordance.
WOULD BE WRONG IF: For every E2 scenario (including the 28 with shift $\neq 0$), the implemented contraction, coverage, and gap all use one and the same $I$ (either always $I(\theta^{*})$ or always $I(\theta_{\text{true}})$), and the $\theta_{\text{true}}$ / $\theta^{*}$ sentences are only loose wording for that single choice.

### Gap score equation is written at $\theta_{\text{true}}$ while the surrounding claim evaluates departures at $\theta^{*}$
SEVERITY: fatal
QUOTE: "`R/09-contraction-gap.R` solves for the mode under data at their expectation, $U(\theta;\,\mathbb{E}[y \mid \theta_{\text{true}}]) = P_0\theta$, by Newton iteration and recomputes the contraction there, at $\theta^{*}$ where a departure acts."
PROBLEM: The displayed estimating equation conditions on $\mathbb{E}[y\mid\theta_{\text{true}}]$ with no departure, but the clause "at $\theta^{*}$ where a departure acts" requires expected data under the aliased DGM, i.e. $\mathbb{E}[y\mid\theta^{*}]$ (or $\mathbb{E}[y\mid\theta_{\text{true}},\text{departure}]$). As written, those are the same only when shift $=0$. For the 28 aliased scenarios the protocol just restored, the printed equation and the prose specify different expected data.
WHY IT MATTERS: Makes the registered gap analysis (max abs 0.0882, median 0.00413, max rel 14.64% on all 72 scenarios) uninterpretable as specified; a reader cannot tell which expectation the Newton step is required to use.
WOULD BE WRONG IF: The symbol $\theta_{\text{true}}$ in that display is defined to include the departure (so it is what the rest of section 8 calls $\theta^{*}$), and the code's expectation always matches that definition.

### Primary 3 is both an E1 result and an E2 analysis, with only the E1 instance specified
SEVERITY: fatal
QUOTE: "Primary 3, one correlation over the confounded family. The rank correlation between contraction and coverage across every `ecological` scenario with nonzero discordance, **pooled, not stratified by discordance level**. It is $\rho = 0.3295$ over 144 scenarios."
PROBLEM: 144 is exactly E1's ecological $\times$ nonzero discordance count ($6\times 2\times 3\times 4$), and $\rho=0.3295$ is a computed E1 number (section 1: E1 ran before the protocol). Section 8 then says the old coverage restriction "left primaries 2 and 3 uncomputable on E2," so Primary 3 is also an E2 deliverable. E2 ecological with nonzero discordance is 8 scenarios, not 144; no E2 $N$, pooling rule across its discordance coding, or statement that $0.3295$ is E1-only appears. The primary is therefore specified as a known exploratory E1 answer while also being required as an unspecified E2 analysis.
WHY IT MATTERS: Primary 3 is not a usable registered analysis for the arm that has not been settled (E2), and packaging a pre-protocol E1 number as "Primary 3 / It is $\rho=\ldots$" violates the section 1 rule that E1 has no confirmatory standing.
WOULD BE WRONG IF: Primary 3 is explicitly E1-only (and section 8's "primaries 2 and 3 … on E2" is false), or the protocol also registers a separate E2 Primary 3 with its own $N$ and does not present $0.3295$ as that analysis's value.

### Claimed repair of assignment-versus-validity is not present in the table cell
SEVERITY: fatal
QUOTE: "The two are now separated in the cell, which matters because the study's thesis is that the aggregate routes are non-randomized rather than merely assumption-laden."
PROBLEM: The additivity cell in the same table still reads "randomized, valid under additivity." Validity of the route is again inside the column the document says is "about assignment, not validity." This is an incomplete repair of the exact conflation the paragraph claims to have fixed.
WHY IT MATTERS: The study's thesis turns on non-randomization of aggregate routes as distinct from identification assumptions; the registration table still fuses those for the only randomized non-IPD route, so the registered contrast is mis-labeled at the point of definition.
WOULD BE WRONG IF: "valid under additivity" is not in the third column of the registered table (e.g. only in a fourth column or footnote), contrary to the protocol text as given.

### Over-broad "So" claim: target is aggregate-only in every state
SEVERITY: serious
QUOTE: "So components 1, 2 and 4 are in `own_ipd` while component 3 is aggregate-only, inside a fixed twelve-arm geometry, with no leakage."
PROBLEM: The preceding sentence correctly limits "no individual data on the target" to aggregate-only states. The "So" drops that limit. In `own_ipd`, studies 4–5 are IPD on `PBO, 1, 3`; in `additivity`, IPD on `PBO, 1, 1+3`; only `ecological` / `curvature` make component 3 aggregate-only.
WHY IT MATTERS: Misstates the registered design for three of five states and overstates the "no leakage / aggregate-only target" geometry as universal.
WOULD BE WRONG IF: That sentence is scoped only to `ecological` and `curvature` in the export/verifier, and the protocol wording is not meant to cover `own_ipd`, `additivity`, or `absent`.

### Primary 2 was not made uncomputable by the old E2 coverage restriction
SEVERITY: serious
QUOTE: "The restriction had removed exactly the scenarios the study exists to examine, and it left primaries 2 and 3 uncomputable on E2."
PROBLEM: Primary 2 is "`additivity` against `ecological`, matched on spread, total patient budget and prior scale, with synergy off." It does not require nonzero discordance. E2 still had eight synergy-off additivity scenarios and eight ecological scenarios at discordance $0$ inside the old 44; those match on the listed factors. Primary 3 needs nonzero discordance; Primary 2 does not. The sentence treats both as blocked by the same restriction.
WHY IT MATTERS: Overstates the necessity of the coverage-restoration argument for Primary 2 and misdescribes what the 44-scenario subset could and could not support.
WOULD BE WRONG IF: Primary 2 is defined (in code or a sentence not given) to require nonzero discordance or to use only scenarios the old restriction dropped.

### Single threshold name for two different CMP-14 rank summaries
SEVERITY: serious
QUOTE: "Registered thresholds: `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`, `SOURCE_OK = 0.50`."
PROBLEM: Section 5 registers three CMP-14 implementations: `contraction`, `target_ratio` (per parameter), and `eff_rank` (model level), and states that conflating the last two was a round-6 defect. Only one non-contraction, non-source threshold is named, `EFF_RATIO_OK = 1.00`, which is a natural cutoff for either "data precision / prior precision $\ge 1$" or "effective rank $\ge 1$." The protocol never binds that threshold to one rule, nor gives a second threshold for the other.
WHY IT MATTERS: Secondary sensitivity, false-alarm rate, and Youden "at the registered thresholds" are not defined for both rank summaries; the round-6 whole-model versus per-parameter confusion is not actually closed in the registration.
WOULD BE WRONG IF: Elsewhere in the same document (not in the provided text) `EFF_RATIO_OK` is bound to exactly one of `target_ratio` or `eff_rank` and the other has its own named threshold, or one of those two rules is explicitly not thresholded.

### Threshold alarm direction never stated
SEVERITY: serious
QUOTE: "Registered thresholds: `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`, `SOURCE_OK = 0.50`. The first two are conventional."
PROBLEM: The protocol never states whether a scenario alarms when the statistic is above or below each cutoff. Other sentences imply opposite directions: low `contraction` is reassuring; high `source_survival` is reassuring; high precision ratio / rank is reassuring. Without explicit inequalities, "conventional" does not specify the decision rule.
WHY IT MATTERS: Secondary operating characteristics at those thresholds, and any exported warning table driven by them, are not registered as decision rules.
WOULD BE WRONG IF: A single unambiguous inequality per threshold is registered in this document (e.g. warn if contraction $>0.50$) in text omitted from the excerpt; as given, it is not.

### `absent` is included in the twelve-arm claim but omitted from the arm map
SEVERITY: serious
QUOTE: "Every state's target studies carry three arms, so every state has twelve arms, an identical shared background and the same per-arm size at a given budget."
PROBLEM: The map that is supposed to show the twelve-arm geometry is jointly satisfiable gives columns only for `own_ipd`, `additivity`, and `ecological` / `curvature`. The `absent` state is in both E1 and E2 grids with route "nothing," but its study-level arm contents are never specified. Whether it still has two three-arm target studies (and thus twelve arms) cannot be checked from the registration text.
WHY IT MATTERS: The equal-arm-count / equal-per-arm-size invariant enforced by `R/06-nonlinear.R` is not inspectable for `absent`; if `absent` drops target arms, the "every state has twelve arms" claim fails.
WOULD BE WRONG IF: `absent` is defined to reuse one of the mapped arm layouts with identification removed by another mechanism, and that definition is part of the registered design even though it is not in the map.

### Section 7 states E1 operating numbers with primary/secondary authority while section 1 strips confirmatory standing
SEVERITY: serious
QUOTE: "the contraction rule's false-alarm rate falls from 0.3043 to 0.0355 under the corrected denominator"
PROBLEM: Section 1 states E1 is exact and exploratory and was computed before the protocol. Section 7 still reports E1 FAR (and Primary 3's $\rho$) as the study's primary/secondary numeric outcomes without labeling those sentences as pre-protocol exploratory results. The denominator correction is disclosed as flattering; the confirmatory packaging is not.
WHY IT MATTERS: Readers of the outcomes section can treat exploratory, already-seen E1 numbers as registered confirmations, which is the failure mode section 1 says the document is written to prevent.
WOULD BE WRONG IF: Every such numeric outcome in section 7 is explicitly marked exploratory/E1-only in the same sentence or table row in the full document, not only by a global section 1 disclaimer.

### "Any link" for the mean route exceeds the existence evidence the next paragraph admits
SEVERITY: minor
QUOTE: "The mean route works on any link and is the classical ecological one; the other two are nonlinear-only."
PROBLEM: The following paragraph states that "any" is stronger than what was checked: one nonzero contrast per nuisance quantity on a fixed geometry, identity and logit only, no general rank argument. The mean-route sentence still asserts "any link."
WHY IT MATTERS: Overstates the registered routes table (an existence result on two links) as a link-universal theorem.
WOULD BE WRONG IF: "Any link" is used only in the informal sense "identity and logit" and the document never treats it as a general claim; the adjacent walk-back already limits the thesis, but the sentence as written remains too strong.
