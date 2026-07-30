VERDICT: needs-revision

### No fatal finding; the candidate’s cross-arm Youden comparison is reversed
SEVERITY: serious
QUOTE: "**The candidate does not**: its Youden index is slightly *worse* on E2, 0.2424 against 0.2585"
PROBLEM: The saved E1 output gives sensitivity \(136/233=0.583691\) and false-alarm rate \(60/169=0.355030\), hence Youden \(0.228661\), exported as 0.2287. E2’s 0.2424 is therefore slightly higher, not lower. The quoted 0.2585 appears nowhere in the current export, yet the verifier passes because it does not check this E1 table cell.
WHY IT MATTERS: This reverses the stated cross-arm conclusion for the post-hoc candidate and makes both the sentence and its table row stale.
WOULD BE WRONG IF: The registered E1 candidate calculation produced 0.2585, or the table explicitly referred to a different candidate definition or experiment.

### The repaired rank-screen leg is falsifiable
SEVERITY: serious
QUOTE: "A coordinate the likelihood does not identify has a posterior equal to its prior, so its coverage is deterministic: **0 or 1, never within 0.01 of 0.95**. Every nominal scenario is therefore estimable, while failing scenarios include both non-estimable cells and estimable-but-confounded ones. `rank_screen`'s two ranges consequently overlap **by construction**, and the grid cannot falsify that leg."
PROBLEM: `rank_screen` tests whether the target coordinate is fully estimable, not whether the likelihood contains no information involving it. A non-estimable target can occur in an identified linear combination and therefore contract under the proper nuisance priors. The saved E2 equal-SD curvature controls demonstrate this: they are non-estimable but have contractions from 0.998888 to 0.999991 rather than 1 and nonzero sampling SDs. Moreover, the new smoke test separately checks that an estimable scenario actually fails. That is a measured result required for overlap, not a consequence of the class definitions. Without an estimable failure, the binary screen would separate failing from nominal scenarios.
WHY IT MATTERS: The observed rank-screen overlap remains true, but the claim that it could not have failed is false. Excluding that leg from primary 1’s informative evidence is therefore unsupported.
WOULD BE WRONG IF: Non-estimability meant the target was absent from every likelihood-identified combination, and the existence of an estimable failure followed from the registered definitions without inspecting the results.

### The repaired E2 candidate outputs still omit their post-hoc standing
SEVERITY: serious
QUOTE: "Neither was registered in advance, and neither carries the standing of the two summaries CMP-14 asks for. Every outcome that reports it says so on the row."
PROBLEM: `R/07-run-e2.R` prints separate `surv_between` and `surv_sd ... separates them` result lines without marking either post hoc. Its saved verdict and JSON likewise place the candidate measurements in bare fields beside one detached `candidate_standing` field. That is not standing carried on each reported row or result.
WHY IT MATTERS: The candidate’s separation output is still packaged with the authority of the registered CMP-14 comparisons despite being exploratory.
WOULD BE WRONG IF: Each printed and saved candidate result itself carried `post-hoc-candidate`, or those verdict lines were not study outcomes.

### The reviewer provenance repair already omits round 11
SEVERITY: minor
QUOTE: "GLM was unavailable in rounds 5 to 7, reviewed in rounds 8, 9 and 10, and has contributed **one** accepted serious finding across those three"
PROBLEM: `CHANGES.md` and the round-11 manifest record a completed GLM review in round 11. The exhaustive-looking list should therefore include rounds 8 through 11 and refer to four rounds.
WHY IT MATTERS: The protocol’s account of its own eleven-round review history is stale.
WOULD BE WRONG IF: The round-11 GLM result was not an actual completed review or was intentionally excluded from the stated review history.
