I'll read the full offloaded protocol text and review it for defects, focusing on round-9 repair shapes.VERDICT: needs-revision

### Central negative result includes the post-hoc candidate; primary 1 then excludes it
SEVERITY: serious
QUOTE: "No threshold on contraction, on either effective-rank reading, on the estimability screen or on the candidate separates failing coverage from nominal coverage. That is the study's central negative result"
PROBLEM: The sentence that defines the study's central negative result treats `source_survival` as a peer of the CMP-14 summaries. The next paragraph withdraws that standing: "Primary 1 covers the three CMP-14 rules and `rank_screen`. `source_survival` appears in the same table and is not a primary result." Section 1 also marks both forms of the candidate as post hoc. The registered centre of the study cannot both include and exclude the same statistic.
WHY IT MATTERS: Primary 1 is later called "E1's conclusion" and the registered bridge to E2. If the candidate is inside the central claim, an exploratory post-hoc rule is carrying confirmatory packaging; if it is outside, the central-result sentence overstates primary 1's scope.
WOULD BE WRONG IF: Primary 1 is officially defined as the broader five-statistic claim, and the later "not a primary result" line only limits secondary export labels rather than the registered claim.

### Secondary false-alarm figures are E1-only in a dual-arm outcomes section
SEVERITY: serious
QUOTE: "the contraction rule's false-alarm rate falls from 0.3043 to 0.0355 under the corrected denominator"
PROBLEM: Section 7 is the joint outcomes section for both arms and already states E2's primary-1 counts (41 failing, 12 nominal) in the same section. The false-alarm arithmetic uses 169 nominal, 84 middle-band, and 6/169, which are the E1 primary-1 counts (251 + 169 + 84 = 504), not E2's. Unlike primary 2's 0.951, which is explicitly labeled "On E1", these rates never name the arm. That is the same missing-attribution shape round 9 fixed for the primary-2 gap.
WHY IT MATTERS: A reader can attach 0.0355 (and the 71/84, 6/169 support) to the whole study or to E2, where the denominators do not exist.
WOULD BE WRONG IF: An earlier sentence in that paragraph binds every following secondary rate to E1 only, or E2 is defined to reuse E1's 169/84 counts (it is not).

### Primary 2 called untestable on E2 after E2 returns a numeric gap of 0
SEVERITY: serious
QUOTE: "One of three reproduces, one is untestable on the grid as registered, and one goes the other way."
PROBLEM: Section 7 already runs the registered primary-2 rule on E2 and reports a result: "16 matched pairs, of which 1 is close, with a coverage gap of 0." Section 9 first says primary 2 is "untested" there, then escalates to "untestable on the grid as registered." A grid that yields one close pair and a defined maximum gap is not untestable; it is underpowered for confirming 0.951. That is the revoked-or-replaced-claim shape: section 7's careful "absence of evidence" is overwritten by a stronger, false status word.
WHY IT MATTERS: The registered multi-arm summary of what reproduces is wrong. Primary 2 on E2 is computable, was computed, and returned 0; it is not in the same category as a statistic the grid cannot form.
WOULD BE WRONG IF: "Untestable" is defined only as "cannot confirm or refute the E1 magnitude 0.951," not as "the registered primary-2 analysis cannot run," and that narrower sense is what the section is using throughout.

### Smoke bias check N is unexplained against the registered E1 grid
SEVERITY: minor
QUOTE: "E1's exact Gaussian bias, computed with no aliasing algebra in it at all, equals the same shift - [(I+P0)^{-1}P0θ*]_{Γ3} expression to 1.06e-15 over 40 scenarios, and mean_true equals Xθ* pointwise to 1.78e-15 over all 504 E1 scenarios."
PROBLEM: The E1 aliasing/estimand establishment is split into a full-grid check (504) and a 40-scenario bias check with no statement of which 40, whether they cover the 216 shifted cells (ecological discordance or additivity synergy), or how 40 is obtained from `build_grid_e1()`. After a round that removed a mean_true figure produced by a scratch script, an unexplained 40 is the same residue: a precision quoted beside a guard whose coverage of the registered grid is not stated.
WHY IT MATTERS: The bias identity is what justifies coverage under shift on E1. If the 40 omit structural cells, the quoted 1.06e-15 does not underwrite the full arm.
WOULD BE WRONG IF: The 40 are a registered, factor-complete subset exported next to the number, or the document only claims the 504-scenario mean_true identity as the E1 establishment and treats the 40 as an extra smoke.

### Dual vocabulary for E1's main results invites a false contradiction
SEVERITY: minor
QUOTE: "The E1 finding does not reproduce on the nonlinear arm."
PROBLEM: Section 8 and the preceding section-9 bullet use "E1's conclusion" / primary 1 for the claim that does reproduce ("every statistic overlaps on E2"). Section 7 and this bullet use "the E1 finding" for primary 3's sign inversion, which does not. The lead clause is false of primary 1 and true only of primary 3; the body disambiguates, but the dual labels are the layered-rewrite inconsistency the protocol itself names as the recurring defect.
WHY IT MATTERS: Section 9 can be read as retracting the registered bridge (primary 1) that section 8 just asserted.
WOULD BE WRONG IF: The protocol defines "E1 finding" only as primary 3 everywhere it appears, and no primary-1 claim ever uses that phrase (section 7 does use it for primary 3 only, but a reader has no glossary).
