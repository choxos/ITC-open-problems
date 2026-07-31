VERDICT: unsound

### Prediction 1 still confuses identification with variance, and never names which estimand the ladder tests
SEVERITY: fatal
QUOTE: "So no variance indexed by the reported moments can be correct for it, and the deficit does not close as the target grows." / "the analysis reports it as the prediction-1 test"
PROBLEM: The premise is that Delta(F_T) is not a functional of the reported moments (identification / wrong target). That does not imply that every moment-indexed variance estimator is an incorrect variance for what the estimator actually targets. The document already withdrew Prediction 2 for exactly this category error ("a mismatch between those two gradients indicates identification bias, not an incorrect variance"), yet Prediction 1 still packages identification failure as a variance claim. The ladder is the registered test of non-closure, but the protocol never states whether ladder coverage is scored against superpopulation Delta(F_T), finite_target, or a moment-reconstructed functional. Those three yield different "deficits" as nT grows (projection bias can persist; omitted-moment share falls; finite_target moves with the sample).
WHY IT MATTERS: A prediction that can be scored two or three incompatible ways is not pre-registrable. After the run, either branch (coverage recovers vs not) can be narrated as success by switching estimand or by switching "variance error" vs "identification."
WOULD BE WRONG IF: Prediction 1 is explicitly only about coverage of one named estimand, and "no variance can be correct" is rewritten as a claim about coverage/bias for that estimand rather than about the algebraic correctness of a variance formula.

### Section 7 revokes the ladder’s purpose
SEVERITY: fatal
QUOTE: "442 of 792 cells fall below the floor and are not run, so the study says nothing about conditions where the omitted variance is small."
PROBLEM: P2 states the opposite design commitment: the growth ladder is retained regardless of share precisely because the gate drops large-nT / small-share cells, and "the analysis reports it as the prediction-1 test." Ladder cells are run when the omitted share is small. Section 7 therefore either erases the ladder or misstates the study’s scope.
WHY IT MATTERS: Readers, analysts, and any automated "what did we claim" check will treat small-share behavior as out of scope while the only registered test of Prediction 1 lives exactly there. That is a claim revoked in one section and still operative in another.
WOULD BE WRONG IF: The ladder is not actually retained in the run set, or Section 7 is rewritten to say the study speaks only along the ladder path (not the full 442-cell complement) when the share is small.

### Headline anchored result is already concluded from probes and then gated out of the experiment
SEVERITY: fatal
QUOTE: "Every cell that clears the floor is unanchored." / "That is the study's first result and it came out of the probe phase, before any replicate was run."
PROBLEM: The protocol presents "moment share is material unanchored and immaterial anchored" as a study result, then states that every floor-clearing cell is unanchored. With the powered grid restricted to cells that clear the floor, anchored cells are not in the confirmatory experiment (unless the ladder crosses `anchored`, which is not specified; the ladder "holds every other factor at its middle," and a binary factor has no stated middle). The result is locked in during design exploration on the same DGM and is not set up as a falsifiable registered comparison on the grid.
WHY IT MATTERS: Pre-registration is supposed to separate design-time measurement from confirmatory claims. Here the lead substantive finding is both pre-known and structurally prevented from being re-tested where the study spends its replicates.
WOULD BE WRONG IF: Anchored cells are forced into the run set (or the ladder fully crosses both anchored levels), and the probe table is labeled a design input rather than a study result.

### Gate power is misaligned with the non-collapsible claim
SEVERITY: fatal
QUOTE: Shares by link (median): identity 0.0928, logit 0.0224, cloglog 0.0392, against floor 0.0791; Prediction 1 is about a non-collapsible link.
PROBLEM: The cell gate keeps cells with omitted-share ≥ 0.0791. By the document’s own table, the median identity share clears the floor while median logit and cloglog do not. The powered grid will therefore be dominated by the collapsible link, while the curved links (the ones Prediction 1 names) are mostly discarded except for upper-tail cells and whatever the ladder fixes as "middle."
WHY IT MATTERS: The study’s primary scientific claim is about non-collapsibility. A design that spends most powered cells on identity cannot fairly confirm or refute that claim; a negative or positive grid result will mainly describe the collapsible case.
WOULD BE WRONG IF: The run-set composition is constrained to power curved links (e.g. per-link floors, stratified retention, or an explicit non-collapsible ladder), and the document shows that the retained grid is not identity-heavy.

### "About 1%" does not follow from the anchored shares the document reports
SEVERITY: serious
QUOTE: "In an anchored comparison the target trial's own effect carries about 83% of the interval's variance and the moment term about 1%."
PROBLEM: The anchored median moment shares reported two lines above are 0.0395 (identity), 0.0100 (cloglog), and 0.0079 (logit). Identity is about 4%, not 1%. "About 1%" matches only the curved-link medians, while the sentence states the claim for anchored comparison generally ("on the curved links as well as the collapsible one" is the preceding sentence’s scope).
WHY IT MATTERS: This is the failure mode the generator-based design leaves open: the numbers can be correct while the sentence claims something they do not support. Reviewers will take "1%" as the magnitude that justifies calling the anchored case immaterial.
WOULD BE WRONG IF: The 1% is a different, stated estimand (e.g. a pooled median across links, or only curved links) and the identity 0.0395 is excluded with an explicit reason.

### "Every cell that clears the floor is unanchored" is not established by the evidence offered
SEVERITY: serious
QUOTE: "Every cell that clears the floor is unanchored."
PROBLEM: Support is median anchored shares (all below 0.0791) and overall min/median/max by link that do not separate anchored from unanchored. A universal claim over cells requires a maximum (or a proof from the variance decomposition), not a median. Identity’s overall max share is 0.786; nothing reported bounds the anchored identity max below the floor.
WHY IT MATTERS: This sentence justifies dropping the entire anchored half of a factor that "changes what the study is." If any anchored cells clear the floor, the run set and the interpretation of the first result both change.
WOULD BE WRONG IF: The design records show max anchored omitted-share < 0.0791 on every link, and that bound is what the sentence cites.

### P6’s threshold comparison is ambiguous about the role of Monte Carlo error
SEVERITY: serious
QUOTE: "The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored."
PROBLEM: "Including Monte Carlo error" can mean (estimate − MCE), (estimate + MCE), or "estimate is 0.0962 and there is also MCE." Only a lower bound still above 0.0791 supports "above the threshold." If 0.0962 is an upper bound or a point estimate without a clear one-sided comparison, the conclusion does not follow.
WHY IT MATTERS: This probe decides whether `maic_xcov` is mandatory in the method set and whether residual coverage gaps can be attributed. A soft comparison cannot carry that design weight.
WOULD BE WRONG IF: 0.0962 is explicitly the Monte Carlo lower bound (or a bias-corrected lower confidence limit) for the worst-cell share, and that bound exceeds 0.0791.

### B = 800 is declared the smallest value meeting a rule whose MCE term is not shown
SEVERITY: serious
QUOTE: "A B is sufficient when two conditions hold together: the paired coverage difference from the reference, plus that difference's Monte Carlo error, is inside the 0.01 shift... 800 is the smallest value in the grid meeting both."
PROBLEM: The table gives paired coverage differences (−0.005 at B = 400, −0.00125 at B = 800) and widths, but not the paired-difference MCE or the B = 3200 reference width. Without those, the dual rule cannot be checked, and B = 400 may already satisfy both conditions (difference 0.005 plus a small MCE can sit inside 0.01; width 1.006 may be within 1% of the reference).
WHY IT MATTERS: B is "the study's whole budget lever" and drives a 531% cost increase. If 400 already meets the stated rule, the registered cost and the undercoverage story at smaller B are mis-set.
WOULD BE WRONG IF: The missing MCE and reference width are stated and show that 400 fails at least one condition while 800 is the first pass.

### "Seven probes" while only six are specified
SEVERITY: serious
QUOTE: "What exists. ... seven probes..."
PROBLEM: The probe section defines P1, P2, P3, P5, P6, P7. P4 is absent. The inventory claims seven; the design of record delivers six labeled probes.
WHY IT MATTERS: Either a registered probe is missing from the protocol (so it cannot be audited), or the inventory is false. Both break the "design of record" claim.
WOULD BE WRONG IF: P4 exists elsewhere in the same authority chain and is intentionally omitted with a one-line disposition (e.g. withdrawn with reason), and the count is corrected.

### Cell counts by source size conflict with the stated gate scaling
SEVERITY: serious
QUOTE: "the moment term scales with 1/nT while the source term scales with 1/nS, so the gate drops the large-target cells first" together with "Cells by source size: 500: 48, 2000: 231, 8000: 71."
PROBLEM: Holding other components fixed, larger nS shrinks the source variance and raises the omitted share of the total, so more cells should clear a minimum-share gate at nS = 8000 than at nS = 2000. The retained counts do the reverse (71 vs 231). No compensating mechanism (unbalanced realized factorial, ladder placement, anchored mass, numerical failure) is given.
WHY IT MATTERS: Either the gate is not the share of total variance described, the realized grid is not what the factor table implies, or the run-set enumeration is wrong. Any of those undercuts P2’s claim that the floor is "solved from the criterion" and applied as stated.
WOULD BE WRONG IF: The document explains the 48/231/71 split with the actual cell-generation rules and shows it is consistent with the share definition (e.g. most nS = 8000 cells are anchored and fall below the floor by construction).

### "About 83%" target-trial share is not tied to a reported decomposition
SEVERITY: minor
QUOTE: "the target trial's own effect carries about 83% of the interval's variance"
PROBLEM: Median components are given (target-trial 0.02373, etc.), but not an anchored-only decomposition that yields 83%. From the overall medians, target-trial / sum is about 84% only if one treats the listed terms as an anchored mixture and ignores that the sentence is specifically about anchored comparison.
WHY IT MATTERS: Same class as the 1% claim: a round number in prose that is not clearly the same measurement as the table.
WOULD BE WRONG IF: 83% is the documented anchored median target-trial share from the same export as the share table.

### Registered coverage band is not derived from the stated "shift worth claiming"
SEVERITY: minor
QUOTE: "The smallest coverage shift worth claiming is 0.01" vs "The registered coverage band is 0.935 to 0.965"
PROBLEM: The gate uses a 0.01 coverage shift (~2× targeted MCE). The method pass band is ±0.015 around 0.95. The protocol never derives 0.015 from the same noise-floor logic, so a third width sits beside the two that were carefully justified.
WHY IT MATTERS: Methods can "pass" while still showing a shift the study elsewhere calls worth claiming, or fail for overcoverage by a margin that was never calibrated.
WOULD BE WRONG IF: The band width is explicitly derived (e.g. from MCE and a multiple) and related to the 0.01 criterion.

### CRN blocking list may not match the method contrast plan
SEVERITY: minor
QUOTE: "Common random numbers block `corr_assumed, variance_method`"
PROBLEM: Four MAIC variance methods already share one fit and one point estimate; `maic_perturb` is declared not paired with them. Blocking on `variance_method` is either redundant for the shared-fit arms or suggests perturb is included in a CRN block the analysis then refuses to pair, which is confusing at best.
WHY IT MATTERS: Clustered MCE and "tested separately" rules must match the randomization structure, or standard errors will be computed under the wrong dependence.
WOULD BE WRONG IF: `variance_method` in the blocker is only the shared-fit set, and perturb is generated under a stated separate stream.
