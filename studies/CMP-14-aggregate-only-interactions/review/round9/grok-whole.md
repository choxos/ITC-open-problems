The full protocol was truncated in the message; reading the offloaded file for the complete text before producing the verdict.VERDICT: needs-revision

### Six comparisons still withdraw a conclusion the text just revoked
SEVERITY: fatal
QUOTE: "But state separation is not E1's conclusion, and calling this rule a withdrawal criterion for E1 was wrong." / "`eff_rank` is one of the six comparisons that can withdraw E1's conclusion, so this is a limitation of that verdict and not a footnote." / "and `eff_rank` is one of the six comparisons that can withdraw E1's conclusion."
PROBLEM: Section 8 revokes state separation (the six comparisons) as a withdrawal criterion for E1's conclusion, then immediately reassigns that role to primary 1 on E2. The same section still asserts, earlier, that `eff_rank` is one of the six comparisons that can withdraw E1's conclusion, and section 9 repeats that assertion with no qualifier. That is the same layered inconsistency the preamble says was eliminated ("Every position is now stated once"): one registered interpretive claim is both denied and kept.
WHY IT MATTERS: The E1–E2 bridge is uninterpretable as written. A reader cannot tell whether non-separation, an `eff_rank` Hessian flip, or primary 1's overlap test is what would overturn or limit E1's central negative result.
WOULD BE WRONG IF: "Withdraw E1's conclusion" were redefined to mean something other than the six range-separation comparisons (for example, only primary 1 on E2), and both leftover sentences were updated to that definition; they are not.

### Placebo-prevalence guard does not catch the failure mode used to justify it
SEVERITY: serious
QUOTE: "An earlier version stopped only on exact equality, which floating point makes almost inert: every arm could sit at 0.2999 with the guard silent and this sentence false." / "`R/07-run-e2.R` computes the range over the registered grid and **stops the run if any arm comes within 5e-5 of 0.3**, which is the precision this document quotes it to."
PROBLEM: The motivating counterexample is prevalence 0.2999. |0.2999 − 0.3| = 1×10⁻⁴, which is not within 5×10⁻⁵, so the new guard is also silent on that case. Separately, the printed range is **0.2506 to 0.3760** (resolution 1×10⁻⁴), not 5×10⁻⁵, so "the precision this document quotes it to" does not match the quoted figures.
WHY IT MATTERS: The guard is offered as the reason the claim "placebo arms sit at prevalence 0.3" cannot slip back into the document. As specified, it still allows values the text treats as the old failure mode, and it misstates the precision of its own quoted range.
WOULD BE WRONG IF: The implemented tolerance were ≥ 1×10⁻⁴ (so 0.2999 trips the guard), or the text did not present 0.2999 as the problem the new rule fixes and did not equate 5×10⁻⁵ with the quoted precision.

### Primary 2's headline gap is E1-only arithmetic presented without an arm
SEVERITY: serious
QUOTE: "Within that matched set, take the pairs whose **contraction differs by less than `PAIRS_CLOSE_TOL = 0.02`** and report the **maximum absolute coverage gap** across them, which is **0.951**." / "Over the 15 display-identical pairs the maximum coverage gap is **0.95**, against **0.951** over all 54." / "Primary 2 was never blocked by it: primary 2 matches `additivity` against `ecological` with synergy off ... so its eight scenarios per state sat at discordance zero"
PROBLEM: Section 7 states primary 2 and the numbers 0.951, 54, and 15 with no arm label, in a section that explicitly covers both arms. Those pair counts only fit E1: E2 has at most 8 synergy-off `additivity` cells × 2 ecological discordances = 16 matched pairs, so "54" cannot be E2. Section 8 then affirms that primary 2 runs on E2 ("eight scenarios per state") but never reports E2's max coverage gap under the same rule.
WHY IT MATTERS: A primary outcome is either study-level or arm-specific. As written, the only numeric primary-2 claim reads as general while being E1-only, and the E2 analysis the text says exists has no registered result line.
WOULD BE WRONG IF: Primary 2 were explicitly restricted to E1 in section 7, or E2 also contributed 54 close pairs and a 0.951 gap (impossible under the stated E2 grid size).

### Source-survival exclusion counts are E1-only, in the shared diagnostics section
SEVERITY: serious
QUOTE: "Both now report undefined and exclude the row, so the candidate's comparison runs on 402 scenarios with **18** excluded and its warning on the same basis with **72** excluded."
PROBLEM: These counts appear in section 5 (shared diagnostics), with no arm label. They fit E1 only: E1 comparison set = 251 failing + 169 nominal = 420; 420 − 18 = 402; E1 `absent` = 4 states' factorial share = 6 × 3 × 4 = 72, matching the warning exclusions. They do not describe a joint E1+E2 grid (576 rows) or E2 alone (72 rows total, with additional undefined cells at `curvature` SD ratio 1.0).
WHY IT MATTERS: A registered rule for when `source_survival` enters primary-1-style comparisons and warnings is pinned to numbers that only one arm can produce, while the prose presents them as the study's diagnostic rule.
WOULD BE WRONG IF: Section 5 labeled the 402/18/72 figures as E1-only, or a different documented scenario set summed to those counts on both arms.

### "Every position is now stated once" is already false inside this draft
SEVERITY: minor
QUOTE: "**Every position is now stated once**, and what it replaced is in the history."
PROBLEM: The withdrawal role of the six E2 comparisons is stated as both wrong and still operative (see first finding). The meta-claim that layering is gone is therefore false on the face of the current text.
WHY IT MATTERS: It overstates the reliability of the document as a single-source registration and encourages reviewers to treat residual duplicates as intentional restatements rather than defects.
WOULD BE WRONG IF: No two passages asserted incompatible positions on the same registered object; they do.
