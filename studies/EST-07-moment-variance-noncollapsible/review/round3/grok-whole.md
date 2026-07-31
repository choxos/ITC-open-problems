VERDICT: unsound

### P6 says the cross term fails the floor while its own number exceeds it
SEVERITY: fatal
QUOTE: "the worst cell reaches 0.0962 including Monte Carlo error, against a floor of 0.0791. It does not clear it."
PROBLEM: Under the document's own P2 usage, "clear a floor of 0.0791" means the share is large enough to matter (cells at or above 0.0791 are run). 0.0962 is greater than 0.0791, so the measurement supports that the term clears the floor, not that it fails it. The following decision ("carried rather than argued away") matches the inequality; the verdict sentence contradicts it.
WHY IT MATTERS: This is the exact failure mode the generator-based design still allows: a correct interpolated number wrapped in a false comparison, which then muddies whether the cross term is in scope by criterion or by taste.
WOULD BE WRONG IF: "Clear the floor" is defined for P6 as the opposite of P2 (e.g. get below 0.0791 to justify dropping the term), and 0.0962 is not the share being compared to 0.0791 but some other quantity the text does not name.

### The run grid is gated on omitted-moment share, which the curved-link probes show mostly sits below the gate
SEVERITY: fatal
QUOTE: "340 of 792 realized cells clear a floor of 0.0791 and are run." together with "Shares by link (min, median, max): … `logit` … median 0.0224 … `cloglog` … median 0.0392"
PROBLEM: The study is titled and claimed as a non-collapsible-scale problem. The same section reports that on logit and cloglog the median omitted share is far below 0.0791 (0.0224 and 0.0392), while identity's median (0.0928) sits above it. Unless the 340 cells are shown to be mostly curved-link, the gate preferentially retains collapsible-link cells and only the upper tail of the non-collapsible ones.
WHY IT MATTERS: Replicates will answer "what moment uncertainty costs when the share is large," which on the reported medians is largely the identity/MIS-03 regime, not EST-07's non-collapsible claim.
WOULD BE WRONG IF: The 340-cell subset is predominantly logit/cloglog despite those medians (e.g. a few very high curved-link cells dominate the count), and that composition is what the study will report as primary.

### Prediction 1's "does not close as the target grows" is screened out by the cell floor
SEVERITY: fatal
QUOTE: "the deficit does not close as the target grows" and "452 of 792 cells fall below the floor and are not run, so the study says nothing about conditions where the omitted variance is small."
PROBLEM: Prediction 1's distinctive content is that failure remains after target-moment sampling noise becomes small. The floor drops exactly the cells where omitted moment variance is a small fraction of the total. Large nT pushes that fraction down (target-moment and target-trial pieces fall with nT; source does not), so the asymptotic half of Prediction 1 is outside the run set by construction.
WHY IT MATTERS: The registered grid can show large deficits where moment uncertainty is already large; it cannot test whether a deficit remains when that uncertainty is negligible, which is what Prediction 1 asserts.
WOULD BE WRONG IF: "Omitted variance" in the floor is not the target-moment sampling piece that shrinks with nT, but a quantity that stays large under pure identification failure at large nT, so high-nT identification cells still clear 0.0791.

### P6's scaling argument for "does not shrink with nT" contradicts the P2 total-variance denominator
SEVERITY: serious
QUOTE: "it does not shrink as the target grows, because both sides of the ratio scale with 1/nT."
PROBLEM: The floor and the P6 comparison are framed as a fraction of the whole anchored-contrast variance, which P2 decomposes as omitted + source + target-trial + cross. Source variance is governed by nS, not nT. As nT grows, cross and target-trial fall while source remains, so the cross share of the total should shrink, not stay put. The "both sides scale with 1/nT" argument would apply only to a ratio that excludes the source term, which is the denominator the document just rejected.
WHY IT MATTERS: A central reason for carrying `maic_xcov` across the nT grid is unsupported by the variance decomposition the design itself adopts.
WOULD BE WRONG IF: Empirical cross shares are flat in nT for a reason the text does not give, and "the ratio" is explicitly not the P2 total-variance share.

### Inventory says five of six methods exist while the methods table presents six
SEVERITY: serious
QUOTE: "five of six methods" and the methods table listing `maic_fixed`, `maic_entropy`, `maic_oracle`, `maic_xcov`, `maic_perturb`, `stc`
PROBLEM: The preamble asserts only five of six methods exist; the design section specifies six operational arms. ML-NMR is separately declared absent, so it is not the missing sixth in that table. The document never names which of the six is unimplemented.
WHY IT MATTERS: Pre-registration must state which analyses will actually run. A silent missing arm makes ADEMP rows and planned contrasts non-executable as written.
WOULD BE WRONG IF: "Six methods" counts ML-NMR and one table row is known scaffolding only, with that row named as non-run in a place this draft omitted.

### Entropy success is judged against a "registered coverage band" that is never defined
SEVERITY: serious
QUOTE: "If it reaches the registered coverage band across the grid, the moment term suffices in these conditions"
PROBLEM: No numerical band, cell-wise rule, or aggregation rule (mean coverage, worst cell, simultaneous band, superpopulation vs finite_target) appears in the protocol. The decision tree that follows (negative result vs split of residual into xcov/oracle/identification) therefore has no registered criterion.
WHY IT MATTERS: This is a registered analysis the write-up cannot perform as specified: any later band can be chosen after seeing the grid.
WOULD BE WRONG IF: The band is fully fixed in `registered-design.json` and the protocol is only a prose gloss that is allowed to omit it (still a pre-registration defect for human readers, but not a software gap).

### Dual estimands are computed, but primary coverage target is not registered
SEVERITY: serious
QUOTE: "Reporting both is what separates an interval that is too narrow from an interval aimed at a different quantity. Reporting one cannot distinguish them."
PROBLEM: Distinguishing narrowness from wrong-target is a diagnostic use of two estimands. ADEMP coverage, bias, and "reaches the registered coverage band" still require a primary target per method. The protocol never says which estimand each interval is scored against when the two disagree, nor whether `maic_perturb` percentile limits are aimed at superpopulation or finite_target.
WHY IT MATTERS: Methods can look calibrated on one estimand and fail on the other; without a registered primary, headline coverage is free to switch after results.
WOULD BE WRONG IF: A single primary estimand is fixed elsewhere in the registration materials that this protocol is required to mirror, and every method's interval is already defined only for that estimand.

### B = 800 is shown in a table but not selected by a stated noise-floor rule
SEVERITY: serious
QUOTE: "800 comes from measuring the corrected interval against an independent B = 3200 reference"
PROBLEM: The table is a measurement; it is not a derivation of a threshold. B = 400 already has paired coverage difference −0.005, equal to the coverage Monte Carlo error the design targets (0.005). Nothing states why that is insufficient and 800 (−0.00125) is required (e.g. bias ≤ ½ MCSE). Earlier wrong B values are correctly rejected; the final B is still asserted from a display.
WHY IT MATTERS: B is "the study's whole budget lever" and drove a 484% cost rise. An unstated selection rule leaves the registered budget unjustified and free to move.
WOULD BE WRONG IF: A pre-registered rule (not printed here) maps the paired-difference column to B = 800 uniquely, e.g. the smallest B with |Δcoverage| < 0.002.

### The floor is derived under pure variance omission, then used for a study whose main prediction is not pure variance omission
SEVERITY: serious
QUOTE: "Omitting a fraction f of the variance reports a standard error of sqrt(1-f) times the truth, so coverage becomes 2*Phi(1.96*sqrt(1-f))-1."
PROBLEM: That derivation assumes centered intervals whose only flaw is an understated SE. Prediction 1 and P7 say the non-collapsible problem is that the estimand is not a functional of the reported moments, i.e. identification / wrong functional, not only omitted sampling variance. Cells selected because omitted sampling variance is large are the wrong enrichment set for that failure mode.
WHY IT MATTERS: The design can over-sample variance-omission failures and under-sample the identification failures the claim is about, then attribute residuals to "identification" after the fact (Section 5) without having powered or gated on them.
WOULD BE WRONG IF: The omitted term in the floor is built from the full gradient of Δ(F_T) in a way that stays large under pure moment-identification failure even when sampling variance of moments is tiny.

### Probe count and P4 are inconsistent
SEVERITY: minor
QUOTE: "seven probes" while only P1, P2, P3, P5, P6, P7 are reported
PROBLEM: Six probes are described; P4 is never named; the count "seven" does not match the sections. The user-facing claim that probes establish the design before replicates is therefore incomplete on its face.
WHY IT MATTERS: A missing probe may be a missing guard (overlap, law identity, correlation attenuation, etc.) that the repair narratives assume has been checked.
WOULD BE WRONG IF: P4 exists only as a non-reporting implementation check and "seven" includes a probe not meant for the protocol (still a drafting defect, not a scientific one).
