VERDICT: needs-revision

<!-- ASSEMBLED FROM 4 OF 4 PARTS after the whole-document review timed out twice. A part cannot see a contradiction with a section it was not shown, so cross-section findings are weaker in this round than in one reviewed whole. -->


<!-- PART 1: 1. The problem, 2. The model and the five in, 3. Estimand, 4. The diagnostics compared -->
VERDICT: unsound

### Section 2 defines a Gaussian identity model that cannot be the E2 / curvature model
SEVERITY: fatal
QUOTE: "$$E[y] = \alpha_s + c'\delta + x\,(\beta + c'\Gamma), \qquad \operatorname{Var}(y) = \sigma^2 .$$"
PROBLEM: Section 2 is titled "The model and the five information states" and prints a single outcome model with identity mean and constant variance. The same part states that `curvature` lives only on a nonlinear link, that E2 is "an asymptotic calculation from the Fisher information of a logistic component model", and that with unequal SDs the target "is estimable on the logit link". Under the printed equation, \(E[y]\) is the linear predictor and \(\operatorname{Var}(y)=\sigma^2\); neither is true for a logistic component model. The part therefore asserts one model and, in the same breath, an experiment that requires another.
WHY IT MATTERS: Every E2 claim that depends on "the model" (including estimability of `curvature`, Fisher information, and any approximate posterior used for `contraction` / `eff_rank`) is undefined relative to the only model equation this part provides. The five-state design cannot be interpreted as states of a single registered model.
WOULD BE WRONG IF: The displayed formula is only a linear predictor shared by both experiments, and the part elsewhere (still within what was given) redefines \(E[y]\) and \(\operatorname{Var}(y)\) for E2. It does not.

### `eff_rank` is not the single CMP-14 summary it is labeled as, and part of it is post-hoc
SEVERITY: fatal
QUOTE: "`eff_rank` | likelihood-to-prior information ratio along the target's coordinate, plus the whole-model count of directions where the data outweigh the prior | **what CMP-14 asks for**"
PROBLEM: CMP-14 is quoted as asking for "an **effective likelihood rank**". Section 4 registers under that heading two different objects: a continuous likelihood-to-prior information ratio, and a whole-model count of directions. The registration block separately concedes that "round 3 rebuilt [E2's rules] after E2's output had been read, to cover the whole-model rank count". So a post-data addition is packed into a diagnostic sold as what CMP-14 asked for. A ratio is also not a rank.
WHY IT MATTERS: The primary confirmatory-sounding comparison ("do the two summaries CMP-14 asks for tell the analyst what they need?") is uninterpretable: pass/fail and narrative for `eff_rank` can be driven by a rebuilt whole-model count that is not the CMP-14 target and was not locked before E2 was seen.
WOULD BE WRONG IF: CMP-14's "effective likelihood rank" is explicitly defined (in this part) as exactly that ratio-plus-count pair, and the whole-model count was fixed before any E2 output. The given CMP-14 quote and the round-3 concession say otherwise.

### Only one threshold is registered for a two-part `eff_rank` rule
SEVERITY: fatal
QUOTE: "Registered thresholds: `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`, `SOURCE_OK = 0.50`, in `R/00-config.R`."
PROBLEM: Section 4 defines `eff_rank` as a coordinate-wise information ratio **plus** a whole-model direction count. The registered threshold list supplies `EFF_RATIO_OK` for a ratio only. No cutpoint, decision rule, or even inequality direction is given for the whole-model count half of the same named rule, nor are the inequalities stated for the three named cutpoints (whether "OK" means \(\le\) or \(\ge\)).
WHY IT MATTERS: A registered analysis that cannot be scored from the protocol is not a registered analysis. Any later claim that `eff_rank` passed or failed in a state is free to use whichever half of the definition is convenient.
WOULD BE WRONG IF: This part defined a single scalar that `EFF_RATIO_OK` applies to, and defined the comparison direction for each threshold. It defines two quantities and one ratio cutpoint.

### Provenance claims every printed number is export-verified; this part prints numbers that are not from that export
SEVERITY: serious
QUOTE: "Every number this document prints is exported from the code that computes it by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export, currently **123** assertions."
PROBLEM: The same part prints CMP-13's "93.8% to 17.2%" coverage figures as results of another study. Those are numbers this document prints, and they are not quantities computed by this study's `R/05-export.R` unless the export is re-stating foreign results (which is not what the sentence claims: "the code that computes it").
WHY IT MATTERS: The lock between prose and code is the only integrity mechanism this pre-registration offers for already-computed E1. An absolute provenance claim that is already false inside Part 1 means export-assertion counts cannot be taken as a guarantee that printed quantities match this study's code.
WOULD BE WRONG IF: "Every number" is restricted to numbers produced by this study's analyses, and the CMP-13 figures are outside that class by an explicit exception in this part. No such exception is stated.

### Control verification is calibrated to the values that made weakened controls pass
SEVERITY: serious
QUOTE: "The four controls in section 5 are asserted against the values that made them pass, not merely described, because section 8 concedes that two of them were weakened after they failed."
PROBLEM: After controls failed and were weakened, the automated check stores and re-asserts the passing values. That freezes the weakened behavior as the expected output; it does not independently re-test the scientific property the control was written for.
WHY IT MATTERS: Category-5 failure: the guards no longer certify what their names suggest. Any later reliance on "section 5 controls passed" or on the 123 assertions as evidence that design invariants hold is circular for those two weakened controls.
WOULD BE WRONG IF: The assertions encode the original, pre-weakening criteria, or encode an independent oracle for the same invariant rather than "the values that made them pass". The quoted sentence says the opposite.

### The `additivity` row marks randomization as conditional on an identifying assumption
SEVERITY: serious
QUOTE: "| **additivity** | only inside the combination $1{+}k$, alongside an arm for 1 alone, so the slope difference is exactly $\Gamma_k$ | yes, if additivity holds | ✓ | ✓ |"
PROBLEM: The column is "randomized?". Whether a trial randomized treatment does not depend on whether the additivity assumption is true. If additivity fails, the design is still randomized; the slope difference is simply not \(\Gamma_k\). The table confuses design randomization with a structural identification assumption, while `ecological` and `curvature` are correctly marked **no** as unrandomized between-study routes.
WHY IT MATTERS: The study's contrast is causal warrant of routes (randomized within-study vs unrandomized between-study). Mis-coding `additivity` scrambles that contrast and can make CMP-14-style summaries look better or worse for the wrong reason when states are grouped by the "randomized?" column.
WOULD BE WRONG IF: The column is defined as "randomized *and* identifies \(\Gamma_k\)" rather than "randomized?". The header says only "randomized?".

### Estimand is within-study \(\Gamma_{W,3}\); the model only has a single \(\Gamma\)
SEVERITY: serious
QUOTE: "The **causal within-study component interaction** $\Gamma_{W,3}$, on the conditional scale."
PROBLEM: Section 2's parameter is \(c'\Gamma\) with no within/across split. The same part cites CMP-13 as showing coverage of the causal within-trial interaction collapsing "from 93.8% to 17.2% as the within-trial and across-trial coefficients diverge". This protocol therefore names CMP-13's within-study estimand while specifying a model in which that divergence cannot occur.
WHY IT MATTERS: If the open join with CMP-13 / CMP-14 is about component routes to the causal within-study interaction, a one-\(\Gamma\) model answers a different question (prior-vs-likelihood for a single shared coefficient), and results cannot be read as diagnostics for \(\Gamma_{W,3}\) under within/across divergence.
WOULD BE WRONG IF: The registered estimand is defined to equal the model's single \(\Gamma_3\) under the maintained assumption within = across, and CMP-13 is cited only as motivation, not as estimand alignment. The estimand line still writes \(\Gamma_{W,3}\), not \(\Gamma_3\).

### Thresholds are called "registered" for computations the registration block says were not cleanly pre-committed
SEVERITY: minor
QUOTE: "Registered thresholds: `CONTRACT_OK = 0.50`, `EFF_RATIO_OK = 1.00`, `SOURCE_OK = 0.50`, in `R/00-config.R`."
PROBLEM: The registration block states that E1's "grid, estimands, diagnostics and thresholds were fixed in `R/00-config.R` and `R/04-analyze.R`, but earlier probes were read while choosing them, and the analysis was run before this protocol existed", and that "Every part of E2 is exploratory" after rules were rebuilt post-output. Calling the cutpoints "Registered thresholds" in section 4 reintroduces confirmatory language the front matter withdrew.
WHY IT MATTERS: Readers (and later write-ups) can treat thresholded pass/fail tables as pre-registered confirmation when the same document classifies both experiments as exploratory.
WOULD BE WRONG IF: "Registered" here means only "stored in config for reproducibility", with no pre-data confirmatory claim. In a pre-registration framed around ADEMP and confirmatory-vs-exploratory status, that reading is not the natural one.


<!-- PART 2: 5. E1, 6. Outcomes -->
VERDICT: unsound

### Primary 2 arm size contradicts the patient-budget factor
SEVERITY: fatal
QUOTE: "every state has twelve arms, 250 patients per arm and an identical background"
PROBLEM: Twelve arms at 250 patients per arm imply 3000 patients per network. The E1 grid also levels total patients at 1000 and 10000, which cannot be 12 × 250. The protocol states these as joint facts about the matched design.
WHY IT MATTERS: Primary 2 is defined by matching on total patient budget under equal arm counts. The printed per-arm size is arithmetically incompatible with two of the three registered budgets, so the registered design of the matched comparison is not self-consistent.
WOULD BE WRONG IF: The "250" figure is only an example for the 3000-patient level and the protocol elsewhere states that per-arm size is budget/12 at every level (it does not).

### Primary 2 omits discordance from matching while claiming a pure evidence-route gap
SEVERITY: fatal
QUOTE: "matched on spread, **total patient budget** and prior scale, with synergy off" … "the gap is now attributable to the evidence route alone rather than partly to a bigger background network"
PROBLEM: Ecological scenarios vary discordance over 0.00, 0.15, 0.40; additivity has no discordance factor (implicitly the zero case). Matching is specified only on spread, budget, prior scale, and synergy off. Nonzero ecological discordance changes the target contrast relative to additivity, so coverage gaps need not be due only to aggregate versus individual-data routing or only to the former arm-count imbalance.
WHY IT MATTERS: The registered Primary 2 claim that contraction-matched pairs can diverge in coverage by up to 0.951 "attributable to the evidence route alone" is not supported by the matching factors as written.
WOULD BE WRONG IF: Pairs are formed only at discordance 0.00 (or discordance is otherwise fixed and identical across members of each pair) even though that restriction is not stated in the matching list.

### "Any registered quantity" is supported only by three named movements
SEVERITY: serious
QUOTE: "the largest movement in any registered quantity across the whole grid is **0.0005 in coverage, 0.0001 in contraction and 0.0000 in the source survival fraction**"
PROBLEM: The sentence claims a bound for every registered quantity, but only coverage, contraction, and source survival fraction are given. Primary 1 also registers both forms of effective rank (per-parameter ratio and whole-model count), and later outcomes include other grid summaries. Those are not shown to respect the same bound.
WHY IT MATTERS: The claim that nuisance prior scale "is doing no work" underpins treating interaction prior scale as the only prior factor. If rank or other registered summaries move more than 0.0005 when the nuisance scale changes, that control is overstated.
WOULD BE WRONG IF: The only registered quantities for this sensitivity check are exactly those three, and the rank summaries used in Primary 1 are excluded by definition from "registered quantity" here.

### Null control is labeled "does not undercover" while its minimum is below 0.95
SEVERITY: serious
QUOTE: "The null control does not undercover, and it is *not* claimed to be nominal" … "null control, minimum coverage | 0.9468"
PROBLEM: Minimum coverage 0.9468 is below the nominal 0.95 level that the rest of the protocol uses as the coverage target. Calling this "does not undercover" while also disclaiming nominal coverage makes the control’s pass criterion strictly weaker than 95% calibration, and the printed minimum is the kind of post hoc floor the provenance warns about ("asserted against the values that made them pass").
WHY IT MATTERS: Control 2 is one of the four run-stopping guards for E1. If it only locks in the exploratory minimum (or anything near 0.9468) rather than a pre-stated non-coverage standard, it no longer independently certifies that the null is well calibrated.
WOULD BE WRONG IF: "Undercover" is defined a priori as coverage below a threshold ≤ 0.9468 (for example 0.94 or COVER_BAD), stated as such, and not chosen as the observed minimum after the run.

### Primary 1 overstates what range overlap implies about the grid
SEVERITY: serious
QUOTE: "A single value compatible with both a nominal and a badly failing scenario establishes that **no threshold separates them**, whatever the grid contains."
PROBLEM: Overlap of the failing and nominal ranges shows that no threshold on that statistic separates those two sets on this grid. It does not show that no separating threshold exists for every possible grid, nor that the intermediate scenarios the design chose cannot matter for other decision rules. "Whatever the grid contains" upgrades a finite-grid fact into a grid-invariant one.
WHY IT MATTERS: Primary 1 is the headline claim that the CMP-14 summaries cannot threshold failing versus nominal scenarios. The stronger wording overclaims what the registered comparison actually delivers.
WOULD BE WRONG IF: "Whatever the grid contains" is only rhetoric about the intermediate band being excluded from the comparison set, not a claim of invariance to the factorial design (the sentence as written asserts the stronger reading).

### Controls are locked to passing outputs rather than independent criteria
SEVERITY: serious
QUOTE: "The four controls in section 5 are asserted against the values that made them pass, not merely described, because section 8 concedes that two of them were weakened after they failed."
PROBLEM: A control whose software assert is the value that first passed is a reproducibility pin on the exploratory run, not an independent design check. Combined with Control 2’s printed minimum of 0.9468 and the withdrawal of equal-magnitude pulling in Control 3, the suite can pass while only weakly constraining the pathologies it narrates.
WHY IT MATTERS: The protocol says all four controls "must hold or the run stops" as if they validate E1. If two were weakened to the numbers that passed, a green run does not mean the original scientific guards held.
WOULD BE WRONG IF: Each control still has an a priori inequality (for example contraction > 0.999, coverage ≥ 0.95, signed orderings, group-level always/never coverage) and the exported values are only confirmations, not the thresholds themselves.

### "Coverage recovered" at the largest budget is still under 0.95 for every informed state listed
SEVERITY: minor
QUOTE: "tight prior, coverage recovered at the largest budget, `additivity` | 0.938" … "`ecological` | 0.735" … "`own_ipd` | 0.725"
PROBLEM: "Recovered" suggests restoration of adequate coverage under the tight prior at the largest budget. All three printed values remain below 0.95; additivity is only near nominal, and the other two remain deep undercoverage.
WHY IT MATTERS: Readers can take Control 3’s table as evidence that more patients fix tight-prior failure in additivity. The numbers show improvement at best, not recovery to the study’s nominal target.
WOULD BE WRONG IF: "Recovered" is defined only as "coverage at the largest budget under the tight prior" with no implication of return to ~0.95.

### Overcoverage mechanism is given as one SD pair for four scenarios
SEVERITY: minor
QUOTE: "null control, scenarios overcovering | 4" … "the shrinkage causing it: posterior SD against sampling SD | 0.536 against 0.453"
PROBLEM: Four scenarios overcover, but only a single posterior-SD versus sampling-SD pair is printed, with no statement that it is the minimum, maximum, mean, or a chosen example.
WHY IT MATTERS: Control 2’s claim that overcoverage is confined to ordinary shrinkage depends on that mechanism check; a single unlabeled pair does not document the check for all four scenarios.
WOULD BE WRONG IF: All four overcovering scenarios share those exact SD values, or the table footnote (not in this part) defines the pair as a bound that covers all four.


<!-- PART 3: 7. E2 -->
VERDICT: unsound

### "None of the three conditions fires" contradicts the share_curv fire and the next paragraph
SEVERITY: fatal
QUOTE: "E2 has been run and none of the three conditions fires."
PROBLEM: The three registered conditions include the source-share separation rule. The fire table marks ``share_curv` separates `curvature` from `ecological` | **yes**`, and the next paragraph states "But the source-share condition fired". Those cannot all be true.
WHY IT MATTERS: The central E2 result table and the narrative of which registered conditions fired are mutually inconsistent, so any registered decision that depends on which conditions fire (including whether the replacement statistic is defective) is uninterpretable from this text.
WOULD BE WRONG IF: "the three conditions" excludes source-share, and both the fire-table row for `share_curv` and the sentence "the source-share condition fired" are not about those three conditions (the text gives no such exclusion).

### Section 7 re-grants E2 confirmatory registration after the document withdrew it
SEVERITY: fatal
QUOTE: "It was run after these rules were committed, so the rules are registered with respect to it even though E1's are not."
PROBLEM: The registration status at the top states "E2 has no confirmatory standing, and the earlier claim that it had some is withdrawn", "Every part of E2 is exploratory", and that round 3 "rebuilt them after E2's output had been read". Section 7 then asserts the opposite: rules committed before the run and therefore registered with respect to E2.
WHY IT MATTERS: Whether E2's non-firing of the additivity-separation rules can support "E1's conclusion is not withdrawn" as a registered result depends on this standing. The document asserts both "exploratory throughout" and "registered with respect to it".
WOULD BE WRONG IF: "registered with respect to it" is only a chronological note that a later re-run used frozen code and is not meant to restore confirmatory standing (the "so" clause and the contrast with E1 claim standing, not mere chronology).

### Source-share rows are labeled "registered rule" while the prose denies any registered rule over them
SEVERITY: fatal
QUOTE: "The source-share results are exploratory throughout, they are not covered by any registered rule, and the only registered thing about them is that E2 must report whether they separate the two aggregate routes, which it does."
PROBLEM: The fire table is headed `registered rule | fires?` and includes ``share_within` separates...` and ``share_curv` separates...`, with `share_curv` marked **yes**. That presents the separation itself as a registered rule outcome, which the prose says is not covered by any registered rule.
WHY IT MATTERS: Readers (and any automated assertion of the protocol) will treat `share_curv` firing as a registered confirmatory result rather than as an exploratory report of a mandatory diagnostic.
WOULD BE WRONG IF: the table header "registered rule" is only a loose label for "rule mentioned above" and the yes/no column is defined solely as the mandatory report, not as a registered test firing (the table does not say that).

### "Four states" non-separation claim exceeds the comparisons shown
SEVERITY: fatal
QUOTE: "E1's conclusion is not withdrawn: neither summary CMP-14 asks for separates any of these four states from any other, on the nonlinear link as on the linear one."
PROBLEM: The fire table only reports additivity vs ecological and additivity vs curvature for contraction / `target_ratio` / `eff_rank`. It does not report those summaries for ecological vs curvature, nor for any pairing involving `own_ipd` or `absent`. The leave-one-out table later lists five states (`own_ipd`, `additivity`, `ecological`, `curvature`, `absent`). "These four states" is never defined, and "any ... from any other" is stronger than the pairwise checks printed.
WHY IT MATTERS: The registered non-withdrawal of E1's conclusion is justified by a universal non-separation claim that the printed E2 checks do not establish.
WOULD BE WRONG IF: "these four states" names a set of four for which every pair was checked on the CMP-14 summaries, and those checks exist but are only summarized by the additivity rows (not shown in this part).

### Equal-SD estimability is admitted non-confirmatory yet still listed as a registered rule that "fires"
SEVERITY: serious
QUOTE: "This condition was **checked before it was written down**: `R/06-nonlinear.R` was run, its answer read, and the rule then recorded. ... It is retained as a standing guard in `R/07-run-e2.R`, which stops the run if it ever fails, but it cannot be counted as confirmatory evidence."
PROBLEM: The same condition appears in the `registered rule | fires?` table as ``curvature` estimable with equal aggregate SDs | no`, alongside the rules that section 7 treats as the basis for not withdrawing E1. The prose says it is not confirmatory; the table format equates it with the registered separation rules.
WHY IT MATTERS: A pre-data guard that was chosen after seeing the answer is being displayed with the same authority as the separation rules used to retain E1's conclusion.
WOULD BE WRONG IF: the table is explicitly only a run log of guards and registered rules mixed without implying equal epistemic status (the shared header does not distinguish them).

### Withdrawn headline ratio does not reproduce from the two artifacts printed beside it
SEVERITY: serious
QUOTE: "In the curvature state's aggregate rows it returned 0.2275 and 0.0072 for quantities whose prior-free value is **exactly zero**, and the ratio of those two artifacts, 0.933 to 0.969, was reported here as this study's headline."
PROBLEM: The natural ratio or two-part share of 0.2275 and 0.0072 is about 0.969 : 0.031 (or ~31.6 : 1), not 0.933 to 0.969. One of 0.969 is recoverable as 0.2275/(0.2275+0.0072); 0.933 is not recoverable from those two terms by the same construction.
WHY IT MATTERS: Even as a description of a withdrawn headline, the document still prints a numeric relation that does not follow from the terms it cites, which is the same class of defect this programme treats as fatal when the numbers are still in force.
WOULD BE WRONG IF: "0.933 to 0.969" are not claimed to be the ratio (or shares) of 0.2275 and 0.0072 but are two other statistics, and "the ratio of those two artifacts" refers to something other than those two numbers (the grammar identifies them as the artifacts).

### Rebuild-after-read is incompatible with "committed before it ran" without a disclosed re-run boundary
SEVERITY: serious
QUOTE: "round 3 rebuilt them after E2's output had been read, to cover the whole-model rank count and the complete per-state distributions."
PROBLEM: Combined with "It was run after these rules were committed, so the rules are registered with respect to it", the only coherent timeline is: run → read → rebuild rules → claim commitment. Unless a clean re-run after the rebuild is stated and treated as non-confirmatory, "committed before it ran" is false of the rules now in force.
WHY IT MATTERS: This is how exploratory, data-dependent redesign is converted back into registered non-withdrawal of E1 ("none of the three conditions fires" → "E1's conclusion is not withdrawn").
WOULD BE WRONG IF: the document elsewhere defines a second E2 run after the round-3 rebuild and treats only that run as "the" run, while still denying confirmatory standing (section 7's "registered with respect to it" still conflicts with the top-level withdrawal of standing).


<!-- PART 4: 8. Every design choice chang, 9. What this cannot settle -->
VERDICT: unsound

### Fourth control still claims “essentially always” while testing mere existence
SEVERITY: fatal
QUOTE: "the fourth control made a group property | It tested only that one scenario of each kind exists, while its words promise "essentially always" | A control carried by a single conforming scenario"
PROBLEM: After the control failed as written, the registered check was reduced to an existence claim (one conforming scenario of each kind). That does not test the property the control’s own words still state. A single convenient scenario can carry the whole control. This is a guard rewritten to pass rather than a restatement that still checks the advertised behavior.
WHY IT MATTERS: Any registered reliance on this control as evidence that the design “essentially always” behaves as claimed is uninterpretable; the control can pass while almost every scenario fails the stated property.
WOULD BE WRONG IF: The control’s wording was also changed to an existence claim only, and nothing in the protocol still treats this control as evidence of near-universal behavior.

### Provenance undercounts how many section-5 controls were weakened after failure
SEVERITY: fatal
QUOTE: "The four controls in section 5 are asserted against the values that made them pass, not merely described, because section 8 concedes that two of them were weakened after they failed."
PROBLEM: Section 8 records multiple post-failure weakenings of distinct controls, not two. At minimum: null-control scope cut to `prior_sd >= 0.5`; null restated from two-sided to “no undercoverage”; prior-domination restated to the smallest budget; “alike” withdrawn from prior-domination; the fourth control reduced to a group/existence property. That is more than two of the four controls, and several of those rows are explicit weakenings after failure.
WHY IT MATTERS: The document’s own account of which confirmatory guards still mean what they say is internally inconsistent. Readers (and the “123 assertions” story) cannot tell which controls were only restated and which were dialed down until they passed.
WOULD BE WRONG IF: Section 5 defines exactly four controls and only two of those objects appear among the failed-and-changed guards, with the other table rows referring only to non-control design or outcome changes.

### “Likelihood wins” overstates partial recovery under the tight prior
SEVERITY: serious
QUOTE: "measured, coverage recovers to 0.938, 0.875 and 0.798 at the largest budget as the likelihood wins."
PROBLEM: 0.875 and especially 0.798 are still large undercoverage relative to a 0.95-class nominal. Calling that recovery “as the likelihood wins” treats residual prior domination as likelihood victory. The same row uses that reading to justify narrowing prior-domination to the smallest budget.
WHY IT MATTERS: The stated reason for weakening the prior-domination control misreads the magnitude of the measurements. The restated control may still pass while large-budget tight-prior states remain far from nominal.
WOULD BE WRONG IF: “Recovers” / “likelihood wins” is defined only as movement away from total collapse, not as approach to nominal, and the protocol never treats 0.798–0.875 as evidence that the likelihood has overcome the prior.

### Pass-value assertions freeze weakened guards instead of testing their properties
SEVERITY: serious
QUOTE: "review/verify-protocol.py asserts each one against the values that made it pass."
PROBLEM: Asserting the post-hoc pass values does not re-check the scientific property the control was written for. After a control is narrowed or redefined until it passes, locking those values in as “assertions” certifies the weakened snapshot, not that the intended guard still holds on the grid.
WHY IT MATTERS: The provenance claim that controls are “asserted… because section 8 concedes that two of them were weakened” offers false assurance: the machine check can stay green while the control no longer tests what the prose still implies.
WOULD BE WRONG IF: The assertions encode the weakened property over the full relevant subset (for example, all null scenarios with `prior_sd >= 0.5` meet the coverage rule), rather than hard-coding the summary numbers that first made the revised control pass.

### Bias “spread of 0.165” does not reproduce from the printed terms
SEVERITY: minor
QUOTE: "The tight prior's mean bias runs $-0.114$, $-0.177$ and $-0.278$ across states, a spread of 0.165 against a truth of 0.40"
PROBLEM: From the three printed figures, max − min is \(0.278 - 0.114 = 0.164\), not 0.165.
WHY IT MATTERS: The figure is used to justify withdrawing uniformity (“alike”) from the prior-domination control. A wrong spread is a small error, but this programme has already treated unreproducible printed arithmetic as fatal when it underwrites a design change.
WOULD BE WRONG IF: “Spread” is not the range of the three printed means (for example, it is computed from unrounded values that truly differ by 0.165, and those unrounded values are the ones the export asserts).
