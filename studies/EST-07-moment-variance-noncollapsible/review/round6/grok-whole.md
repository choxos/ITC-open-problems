The review needs the full protocol text from the offloaded prompt; I'll load that and score claims against the stated probe evidence only.VERDICT: unsound

### Prediction 1 tests law non-identifiability, not the cost of treating sample moments as known
SEVERITY: fatal
QUOTE: So the prediction is: **reported-moment methods target the moment-matched contrast, and their coverage of Delta(F_T) fails by an amount that persists as nT grows.** That is what the two registered estimands separate and what the growth ladder measures. It is falsified if coverage of the superpopulation estimand approaches nominal along the ladder.
PROBLEM: The opening frames EST-07 as the cost of treating moments estimated from nT in {100, 300, 1000} as known constants (a variance omission that the document’s own P2 math says scales like 1/nT and therefore shrinks along the ladder). The registered prediction and its falsification rule instead track a structural gap between Delta(F_T) and the moment-matched / Gaussian-copula completion. That gap remains even if the reported moments equal the true population moments exactly; it is not the sampling uncertainty EST-07 names. The ladder therefore confirms or falsifies moment non-identifiability under the reconstruction, not the cost of freezing m_hat.
WHY IT MATTERS: The study can “support Prediction 1” via shape/copula non-identifiability while never isolating what EST-07 asks, or can “falsify” it on cells where moments identify Delta even though treating m_hat as known still understates variance at finite nT.
WOULD BE WRONG IF: Prediction 1 is intentionally only about moment non-identifiability, EST-07 has been redefined that way, and the variance cost of freezing m_hat is registered as a separate, method-and-estimand-specific claim (e.g. entropy vs fixed on moment_matched along the same ladder).

### Variance-share gate drops every anchored cell, so Prediction 1 is powered only where omitted variance is large
SEVERITY: fatal
QUOTE: Of the 332 cells placed clearly above the floor, 332 are unanchored; **every anchored cell in the realized grid falls clearly below it, and not one is even borderline.**
PROBLEM: The run grid is selected by omitted-moment-variance share (P2), while Prediction 1 is an identification/centering claim about covering Delta(F_T). Identification bias on curved links can remain when the moment-variance share is small; anchored cells are the natural place to see a coverage deficit that is not driven by a large missing variance term. The design removes that setting from the powered grid (and from all “clear” cells). Decomposition via maic_xcov/maic_entropy then operates almost only in unanchored cells where the moment term is a large share of interval variance (unanchored medians 0.0961 to 0.3612).
WHY IT MATTERS: Coverage failures on the registered grid confound omitted variance, the cross term, and identification. The usual anchored use case is left to a probe table about shares, not to the ADEMP coverage estimand the prediction is about.
WOULD BE WRONG IF: The ladder and primary analyses are explicitly anchored (or both), and Prediction 1 is pre-specified only for unanchored MAIC with no claim about anchored practice.

### Entropy “negative result” uses an unspecified estimand and can invert Prediction 1
SEVERITY: fatal
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices *in these conditions* and the study reports that as a negative result about its own prediction.
PROBLEM: Section 3 states that covering moment_matched while missing superpopulation is Prediction 1’s signature. maic_entropy is the ported variance that should make intervals honest for the moment-matched target. Hitting the band on moment_matched is therefore compatible with (and partly required by) Prediction 1; a negative result for Prediction 1 would be honest coverage of superpopulation Delta(F_T). The sentence does not say which estimand’s coverage triggers the negative result.
WHY IT MATTERS: As written, the analysis can report “prediction fails, moment term suffices” when the data show the prediction’s intended signature.
WOULD BE WRONG IF: “Reaches the registered coverage band” is elsewhere locked to superpopulation only, and moment_matched coverage is reported as a separate variance check.

### Ladder Prediction-1 test never names the method
SEVERITY: serious
QUOTE: the analysis reports it as the prediction-1 test rather than pooling it with the powered grid.
PROBLEM: Falsification is “coverage of the superpopulation estimand approaches nominal along the ladder,” but no method is named. maic_fixed, maic_entropy, maic_xcov, maic_perturb, and stc answer different questions (variance omission vs identification vs procedure). Under maic_fixed, undercoverage can persist or fade for variance reasons alone as shares change with nT; under maic_entropy, residual superpopulation undercoverage is the identification claim.
WHY IT MATTERS: Two analysts can run the registered ladder test, condition on different arms, and reach opposite conclusions about Prediction 1 while both following the protocol.
WOULD BE WRONG IF: A later analysis section (not in this draft) fixes a single primary arm and estimand for the ladder, with the others secondary.

### P6 reuses the variance-omission floor for a signed cross term without a matching coverage derivation
SEVERITY: serious
QUOTE: The worst cell reaches **0.0962** including Monte Carlo error against the 0.0791 threshold, so **the cross term is above the threshold and cannot be ignored**.
PROBLEM: f = 0.0791 was solved from understating a positive variance fraction (SE → sqrt(1−f)·truth → coverage 0.94). The cross term is −2 Cov(·,·), has median contribution −0.001462 in P2 (often variance-reducing if dropped), and is not a fraction of variance omitted from an SE in the same sense. “0.0962 including Monte Carlo error” also does not say whether the comparison uses a lower bound, upper bound, or point estimate plus noise.
WHY IT MATTERS: The study commits an arm and calibration budget to a term whose “must carry” warrant does not follow from the cited threshold theory; worst-cell exceedance of a mismatched floor is not a coverage-shift proof.
WOULD BE WRONG IF: 0.0962 is a well-defined share of total variance whose omission maps to ≥0.01 coverage error under the same Wald derivation, and the MC error handling is a one-sided bound in the anti-conservative direction.

### Pooled share medians are reported as the study’s magnitude while the run grid is unanchored
SEVERITY: serious
QUOTE: The moment term's median share ranges from 0.0233 to 0.0852 across links. An earlier draft rounded that to "about 1%", which understates the identity arm. That is the study's first result
PROBLEM: Those figures match the P2 all-cell medians (identity 0.0852, logit 0.0233, cloglog 0.0406), which mix anchored cells the gate discards with unanchored cells it keeps. The same section’s unanchored medians are 0.3612 / 0.1570 / 0.0961. The quoted range is not the magnitude on the cells the Monte Carlo will actually run.
WHY IT MATTERS: Readers and the catalog take away “a few percent of variance” for a grid whose clear cells are unanchored and much larger; the generated numbers are right, the sentence’s referent is not.
WOULD BE WRONG IF: The 0.0233–0.0852 range is explicitly the all-cell design census, and the pre-registered headline magnitude for interpretation is the unanchored column.

### P5’s B-selection evidence is described as both independent and nested-paired
SEVERITY: serious
QUOTE: **800** comes from measuring the corrected interval against an independent B = 3200 reference, with the limits at every B read from nested subsamples of one draw set so the comparison is paired
PROBLEM: An independent reference draw set is not the same object as nested subsamples of one draw set. Nested B in a single set of 3200 draws gives paired limits without an independent reference; a separate 3200 stream is independent but not nested-paired unless a third structure is defined. The table also omits the reference width and the Monte Carlo error of the paired coverage difference that the selection rule requires.
WHY IT MATTERS: B = 800 is the dominant cost lever (96%–99% of 663.1 core-hours). If the decision rule cannot be reconstructed from the stated design, the registration does not pin down why 400 fails and 800 passes.
WOULD BE WRONG IF: The probe uses independent Monte Carlo replicates of the whole experiment, each with nested B inside one resampling pool of 3200, and “independent” only means independent of the main grid (with MCSE and reference width recorded in the design object).

### Residual after maic_xcov is attributed only to identification
SEVERITY: serious
QUOTE: the difference from `maic_entropy` is the cross term, and what remains is what identification has to explain.
PROBLEM: After adding the cross term, residual superpopulation coverage error can still come from correlation misspecification, Gaussian-copula reconstruction, finite-sample MAIC behavior, or STC model misspecification. maic_oracle is said to isolate correlation, but the sentence assigns everything left to identification.
WHY IT MATTERS: The registered attribution path over-claims what the arm contrasts identify and revives, in prose, the identification-versus-variance slide the second prediction withdrew.
WOULD BE WRONG IF: “Identification” is defined operationally as “anything not fixed by moment term, cross term, and supplied population correlation,” and that definition is what the analysis reports.

### Anchored / baseline-shift factors are declared design-changing but leave Prediction 1’s ladder factors unspecified
SEVERITY: serious
QUOTE: The ladder holds every other factor at its middle and walks the target size
PROBLEM: `anchored` is binary and `target baseline shift` was added because without it “the two estimands coincided exactly.” Neither has a unique “middle.” Given that no anchored cell is clear of the floor, the ladder’s anchored and baseline-shift settings decide whether Prediction 1 is tested in a regime where estimands separate and where moment variance is large or small.
WHY IT MATTERS: The primary falsification path is not design-identified; different middle conventions change the scientific object.
WOULD BE WRONG IF: The design JSON fixes explicit ladder levels for every non-nT factor, including anchored and baseline shift, and the protocol states those levels in prose.

### Coverage band is two-sided for methods, but Prediction 1 is one-sided undercoverage from bias
SEVERITY: minor
QUOTE: It is two-sided: an interval that is too wide fails it exactly as an interval that is too narrow does
PROBLEM: A bias-driven failure of coverage for Delta(F_T) is directional undercoverage. A two-sided band is fine as an MC-noise tolerance, but Prediction 1’s success criterion should not treat overcoverage of superpopulation as the same scientific outcome as undercoverage without a separate estimand (e.g. width or bias).
WHY IT MATTERS: Conservative intervals can fail the band and be discussed as if they falsify the same claim as anti-conservative ones.
WOULD BE WRONG IF: Band failure is only a screen for “not nominal within MC error,” and Prediction 1 is judged on signed coverage error and bias, not band membership alone.

### Probe numbering skips P4 while the header counts “six probes”
SEVERITY: minor
QUOTE: the six probes set out in section 2
PROBLEM: Section 2 labels P1, P2, P3, P5, P6, P7. Harmless if intentional, but it suggests a deleted P4 still referenced in code or DESIGN.md.
WHY IT MATTERS: Review and code paths that key on probe IDs can desynchronize.
WOULD BE WRONG IF: No P4 ever existed in software or superseded docs, and the numbering is fixed in the design object.
