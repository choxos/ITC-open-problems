VERDICT: needs-revision

### E2 never registers the covariate distribution that determines its results
SEVERITY: serious
QUOTE: "on a curved link the arm-level value integrates the covariate distribution through $\operatorname{expit}$, so it depends on each study's covariate mean and SD"
PROBLEM: Means and SDs do not determine this integral. The implementation silently assumes a Normal covariate distribution using 64-point Gauss-Hermite quadrature, but the protocol never registers that distribution or the quadrature approximation.
WHY IT MATTERS: E2 prevalence ranges, aggregate-route identification, Fisher information, contraction, and coverage all depend on the full covariate distribution. The E2 analysis is therefore conditional on an unstated data-generating assumption.
WOULD BE WRONG IF: The protocol explicitly registered the Normal covariate law and quadrature rule, or these E2 quantities were invariant to distributional shape at fixed mean and SD.

### The sole E2 primary-2 pair contains no confounding
SEVERITY: serious
QUOTE: "Primary 2 **does not**: its one close E2 pair gives 0.0001286 against E1's 0.951"
PROBLEM: The sole E2 pair passing `PAIRS_CLOSE_TOL` has `discord = 0`. The protocol itself says fixing discordance at zero removes the confounding this contrast exists to price. Thus 0.0001286 describes the unconfounded null control, not a close randomized-versus-confounded comparison.
WHY IT MATTERS: The claim that primary 2 fails to reproduce on E2 is unsupported. E2 contains no close confounded pair capable of testing that cross-arm claim.
WOULD BE WRONG IF: The sole close E2 pair had nonzero discordance, or reproduction were explicitly defined as comparing formal maxima regardless of whether the retained pair contains the mechanism primary 2 targets.

### The repaired candidate output combines one statistic's values with the other statistic's verdict
SEVERITY: serious
QUOTE: "source SURVIVAL, curvature: 0 | ecological: 0 | separates them: TRUE"
PROBLEM: The displayed zeros come from `curvature_surv` and `ecological_surv`, which are `surv_between`. The `TRUE` comes from `surv_sd_separates`; its actual ranges are 0 for curvature and 1 for ecological. The line therefore reports identical displayed values beside a separation verdict computed from different, undisplayed values.
WHY IT MATTERS: The analyst-facing E2 candidate output cannot identify which registered candidate form separates the routes.
WOULD BE WRONG IF: The displayed ranges were taken from `surv_sd`, or the separation verdict were computed from `surv_between`.

### The E2 candidate's sensitivity denominator is misstated
SEVERITY: serious
QUOTE: "the whole E2 secondary rests on 41 failing and 12 nominal cells"
PROBLEM: `source_survival` has 16 undefined E2 values, covering the eight `absent` cells and the eight unidentified `curvature` negative controls. Its sensitivity therefore uses 33 failing cells, not 41; only its nominal denominator remains 12.
WHY IT MATTERS: The reported candidate sensitivity and Youden index are presented with the wrong supporting sample, obscuring their different analysis population.
WOULD BE WRONG IF: `source_survival` were defined for all 41 failing cells, or that row were explicitly excluded from “the whole E2 secondary.”

### The new secondary table again drops the candidate's post-hoc standing
SEVERITY: serious
QUOTE: "| `source_survival` | 0.2585 | 0.2424 | 0.5758 | 0.3333 |"
PROBLEM: This newly added outcome row contains no `post-hoc-candidate` label, despite the protocol's promise that every candidate outcome carries that standing on its row. The verifier passes by checking a detached standing field and unrelated CMP-14 rule rows, not this displayed row.
WHY IT MATTERS: The candidate is packaged alongside the requested summaries and existing screen with indistinguishable authority.
WOULD BE WRONG IF: This displayed row itself carried the post-hoc standing, or the protocol withdrew its row-level labeling promise.

### The reviewer provenance sentence is stale
SEVERITY: minor
QUOTE: "GLM contributed only in round 8, having been unavailable before it."
PROBLEM: `CHANGES.md` records GLM reviews in rounds 8, 9, and 10, including one accepted serious finding in round 10.
WHY IT MATTERS: The protocol's account of who contributed to its 168-finding history is inaccurate.
WOULD BE WRONG IF: “contributed” meant only “first became available,” or the round-9 and round-10 GLM entries were not actual reviews.
