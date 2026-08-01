I'll read the full offloaded protocol text, then issue the VERDICT and findings directly from it.VERDICT: unsound

### Gate criterion is derived for anchored-interval composition, then selects only unanchored cells
SEVERITY: fatal
QUOTE: "The denominator is the whole variance of the anchored contrast. The gate previously screened on the omitted variance over omitted-plus-source, leaving out the target trial's own variance and its covariance with the reported moments, both of which are in the interval." … "Of the 332 cells placed clearly above the floor, 332 are unanchored; every anchored cell in the realized grid falls clearly below it, and not one is even borderline."
PROBLEM: The floor is justified by a coverage-shift formula for an interval whose total variance includes target-trial variance and the cross term. The document then reports that every clear cell is unanchored, so those terms are not in the interval being powered. Either the gate still uses the anchored total on unanchored cells (wrong denominator for the criterion named), or it switches denominator by arm (so the written derivation is not the rule that produced the 332). The same section cannot both require target-trial and cross "because they are in the interval" and place only unanchored cells above the floor.
WHY IT MATTERS: Cell selection is the study's power allocation. If the powered grid is built with the wrong total variance, the 0.0791 floor does not mean a 0.01 coverage shift for the intervals that will actually be scored, and the claim that the design is "solved from the criterion" is false for the cells that run.
WOULD BE WRONG IF: Unanchored cells still use an interval for theta_AC − theta_BC (so target-trial and cross remain in every scored interval), and "anchored = False" means something other than dropping the target-trial arm from the estimand and its variance.

### Variance-share gate preferentially keeps identity and drops the non-collapsible links prediction 1 is about
SEVERITY: fatal
QUOTE: "So the prediction is: reported-moment methods target the moment-matched contrast, and their coverage of Delta(F_T) fails by an amount that persists as nT grows." … Shares by link medians: identity 0.0852, logit 0.0233, cloglog 0.0406; floor f = 0.0791.
PROBLEM: Prediction 1 is an identification claim under a non-collapsible link. The run-set is chosen by omitted-variance share, which is largest on identity (median above the floor) and below the floor on both curved links at the median. That is the opposite weighting of the factor the prediction needs. The ladder is exempt, but the 356-cell grid is not a prediction-1 grid; it is a high moment-share grid dominated by the collapsible link.
WHY IT MATTERS: Grid-wide coverage results will mostly answer the variance-omission story (MIS-03 style), not whether moment-matched methods miss Delta(F_T) under non-collapsibility. Reporting prediction 1 from "the grid" will overstate support or falsification on the wrong cells.
WOULD BE WRONG IF: Most of the 356 run cells are still logit/cloglog (despite those medians), or prediction 1 is pre-specified to be tested only on the ladder and never summarized over the gated grid.

### Grid-wide entropy success is offered as a negative result on prediction 1
SEVERITY: fatal
QUOTE: "If it reaches the registered coverage band across the grid, the moment term suffices in these conditions and the study reports that as a negative result about its own prediction."
PROBLEM: Prediction 1 is falsified if coverage of the superpopulation estimand approaches nominal as nT grows (identification bias does not vanish). Entropy covering well on a gate-selected grid of high moment-share, mostly unanchored, identity-heavy cells would show that the ported moment variance can restore coverage where variance omission was large. That is not a negative result on persistent identification failure under non-collapsibility, and the sentence does not even say which estimand's coverage counts as success.
WHY IT MATTERS: A registered analysis path can "falsify" prediction 1 by succeeding at a different scientific question on a different subset of the design.
WOULD BE WRONG IF: The registered analysis defines entropy success only as superpopulation coverage on the ladder (or only on curved-link cells), and "across the grid" is not an operative decision rule.

### Catalog effect called immaterial when anchored from variance share alone
SEVERITY: fatal
QUOTE: "So the effect the catalog entry names is material without an anchor and immaterial with one, on the curved links as well as the collapsible one."
PROBLEM: The evidence is median moment-term share of interval variance (unanchored vs anchored). EST-07 / prediction 1 also includes identification bias: methods centered on the moment-matched contrast can miss Delta(F_T) even when the omitted variance share is tiny. Share below 0.0791 means dropping the moment term moves coverage by less than 0.01 under a pure variance-omission model; it does not measure whether coverage of Delta(F_T) is near nominal under anchoring.
WHY IT MATTERS: The study drops every anchored cell from the clear set, then reads the probe share table as answering the catalog problem for anchored practice, which is the setting many baseline-table ITCs use.
WOULD BE WRONG IF: The catalog entry and this study's estimands are pre-specified to be only about variance undercoverage of moment uncertainty, with identification bias declared out of scope for anchored cells.

### P6 applies the variance-omission coverage floor to the cross term
SEVERITY: fatal
QUOTE: "The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored."
PROBLEM: f = 0.0791 is solved from coverage 2Φ(1.96√(1−f))−1 when a positive fraction f of variance is omitted and the SE is too small. The cross term enters as −2Cov; the grid median cross contribution is −0.001462 (negative). Dropping a negative contribution makes the reported variance larger (conservative), not smaller. Comparing a cross-term magnitude to the undercoverage floor reuses a number that does not map to a 0.01 undercoverage shift for that term, and "including Monte Carlo error" does not state whether 0.0962 is the estimate, the estimate plus SE, or a lower bound.
WHY IT MATTERS: The study mandates an oracle xcov arm and attributes entropy−xcov differences as if the probe proved undercoverage-relevant omission. If the typical effect of dropping the cross is overcoverage, the arm answers a different defect than the one the floor was built to detect.
WOULD BE WRONG IF: The 0.0962 figure is the share of a positive contribution to variance in the worst cell (not |cross|/total), and the registered claim is only that the absolute SE error can exceed the same numerical size as a 0.01-shift variance fraction, without claiming the same coverage direction.

### Section 7 lists scope limits but omits that the powered grid is entirely unanchored
SEVERITY: serious
QUOTE: "The dropped cells. 436 of 792 cells fall below the floor and are not run. The study therefore says nothing about most conditions where the omitted variance is small, with one deliberate exception: the growth ladder..."
PROBLEM: The limitations section never states the sharper fact already established in §4: every clearly above-floor cell is unanchored, and no anchored cell is even borderline. The omitted scope is not only "small omitted variance" but almost all anchored comparisons.
WHY IT MATTERS: Readers and later reporting will treat the 356-cell results as speaking to anchored MAIC with published baseline tables unless this is registered as a hard limit.
WOULD BE WRONG IF: Anchored cells are restored in the run set by another rule not stated here, or the ladder fully crosses anchoring and is the only reported surface for anchored claims.

### Prediction 1 falsification is not an operational criterion
SEVERITY: serious
QUOTE: "It is falsified if coverage of the superpopulation estimand approaches nominal along the ladder."
PROBLEM: "Approaches nominal" is not tied to the registered band (0.932–0.968), a slope test, a maximum gap between nT levels, or a comparison of coverage deficits. With three nT values and MC error 0.004873, many trajectories can be called either persistent failure or approach.
WHY IT MATTERS: The only dedicated prediction-1 instrument can be read either way after the results are known.
WOULD BE WRONG IF: R/16-analyze.R already encodes a single pre-specified ladder decision rule that this document simply failed to quote.

### P5 declares B = 800 as the smallest grid value meeting a two-part rule the table cannot check
SEVERITY: serious
QUOTE: "A B is sufficient when two conditions hold together: the paired coverage difference from the reference, plus that difference's Monte Carlo error, is inside the 0.01 shift the study is willing to interpret; and the mean width is within 1% of the reference width. ... 800 is the smallest value in the grid meeting both."
PROBLEM: The table gives paired coverage differences and mean widths but not the MCE of those paired differences and not the B = 3200 reference width. At B = 400 the paired difference is already −0.005; whether |diff| + MCE exceeds 0.01 is unknowable from the stated numbers. The 1% width tolerance is asserted, not derived from the 0.01 coverage-shift criterion or a measured width noise floor.
WHY IT MATTERS: B is "the study's whole budget lever" and drives a 551% cost increase. If 400 already meets the coverage prong and width is within 1% of reference, the registered B is not the smallest value meeting the stated rule.
WOULD BE WRONG IF: The unshown MCE and reference width place 400 outside both prongs and 800 as the first pass, and the 1% width rule is separately justified elsewhere in the registration package as binding.

### Coverage-band false-positive budget is counted per cell, not per scored coverage
SEVERITY: serious
QUOTE: "its half-width is the multiple of the delivered Monte Carlo error, 0.004873, at which the expected number of spurious band failures across all 356 cells stays inside a registered budget of 0.1."
PROBLEM: Each cell has multiple methods (and, for some contrasts, multiple estimands). If the band is applied to each method×cell coverage, the family size is several times 356 and the expected spurious failures scale accordingly. The budget calculation as written only multiplies by 356 cells.
WHY IT MATTERS: The registered "pass band" can look calibrated while admitting far more than 0.1 expected false band failures across the reported table.
WOULD BE WRONG IF: Exactly one coverage per cell is ever tested against the band (all other numbers are descriptive only), matching the "356 cells" budget.

### Full-grid cost is reported as measured though no registered replicate has been run
SEVERITY: serious
QUOTE: "Measured cost: 668.4 core-hours for the MAIC and STC arms, at B = 800" … "No replicate of the registered grid has been run."
PROBLEM: A cost for the MAIC/STC arms at registered B on the study grid cannot be a direct measurement if the registered grid has not been run. It must be a projection from probes or partial timings, but it is reported in the same assertive register as probe outcomes.
WHY IT MATTERS: Cost is used to defend B and design choices ("rose by 551%"). An extrapolation presented as a measurement cannot be audited the way P1–P7 figures can.
WOULD BE WRONG IF: 668.4 core-hours is wall-clock from a complete dry run of all 356 cells × 2000 replicates at B = 800 (even if scientific outputs were discarded), so "no replicate" means only that results were not retained.

### moment_matched truth is a large-source limit while methods use finite nS
SEVERITY: serious
QUOTE: "The quantity is now computed the way MAIC computes it, on a source large enough that the weight fit sits at its limit rather than at a sample of it." … "Covering it well while missing the superpopulation contrast is the prediction's signature"
PROBLEM: Finite-nS MAIC is not yet at the entropy-tilted limit used as moment_matched. Failure to cover moment_matched can be weight-estimation noise; covering moment_matched can still leave a finite-nS gap that is not pure identification of Delta(F_T).
WHY IT MATTERS: The registered signature of prediction 1 (good for moment_matched, bad for superpopulation) is confounded by a second discrepancy the design intentionally built into the truth.
WOULD BE WRONG IF: moment_matched on each replicate is computed from that replicate's source fit (or the analysis treats limit vs finite-nS as a separate, registered decomposition).

### Ladder "middle" levels for link and anchoring are unspecified
SEVERITY: serious
QUOTE: "The ladder holds every other factor at its middle and walks the target size, and the analysis reports it as the prediction-1 test"
PROBLEM: Link has three levels (identity, logit, cloglog) and anchoring is binary. "Middle" is unambiguous only for ordered factors with a defined center; for link, middle-as-logit is the non-collapsible choice, middle-as-identity would not test prediction 1. For anchoring, no middle exists.
WHY IT MATTERS: The sole prediction-1 instrument's factor settings are not pinned down in the design of record, so the ladder can be implemented as a collapsible or unanchored-only walk without contradicting the text.
WOULD BE WRONG IF: registered-design.json fixes ladder constants explicitly (e.g. logit, unanchored) and the protocol is only a gloss of those fixed values.

### P7 table shows gradients; prose treats them as establishing non-zero omitted variance on curved links
SEVERITY: minor
QUOTE: "What the table shows is that d Delta / d m does not vanish on the curved links. The omitted variance is J' Omega J / nT, which is a positive definite form in that gradient, so a gradient bounded away from zero implies an omitted variance bounded away from zero; the table establishes the premise and not the quantity itself."
PROBLEM: The hedge is correct, but the control's scientific punch ("target-moment uncertainty does not need effect modification to bite") still slides from gradient presence to uncertainty biting without reporting the variance share or coverage shift at beta_EM = 0.
WHY IT MATTERS: Mild overclaim relative to the measurement; less severe because the document flags the premise/quantity split.
WOULD BE WRONG IF: A variance or share at beta_EM = 0 is registered and emitted elsewhere in the same protocol and was omitted only from this excerpt.

### finite_target is computed with no registered decision role
SEVERITY: minor
QUOTE: "Three, and all are computed on every replicate" including "finite_target: the same contrast in the target sample actually drawn."
PROBLEM: Superpopulation and moment_matched are tied to prediction 1; finite_target is never given a falsification rule, contrast, or reporting claim.
WHY IT MATTERS: Extra estimand multiplies output and invites post-hoc use.
WOULD BE WRONG IF: A pre-specified finite-target analysis (e.g. diagnostics only) is defined in the analysis script contract cited by the protocol.
