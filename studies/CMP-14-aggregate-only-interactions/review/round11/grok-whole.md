The full protocol was truncated mid-document; I'll load the complete text from the session prompt file so the review covers every section.VERDICT: needs-revision

### Primary 1’s estimability screen result is predetermined by the class definitions
SEVERITY: serious
QUOTE: "No threshold on contraction, on either effective-rank reading, or on the estimability screen separates failing coverage from nominal coverage. Those four are what primary 1 registers"
PROBLEM: As registered, `rank_screen` is a binary estimability flag that alarms when the coordinate is "not estimable". A scenario with no likelihood identification has data-independent posterior equal to the prior, so its coverage of a fixed truth is 0 or 1 and cannot land in the nominal band "within `COVER_TOL = 0.01` of 0.95". Every nominal scenario is therefore estimable. Failing scenarios include both non-estimable cells (for example `absent` under a narrow prior) and estimable-but-confounded cells (ecological discordance), which the design exists to study. The failing range therefore always includes "estimable" and the nominal range is only "estimable", so the ranges always overlap. Primary 1’s rank_screen clause is a consequence of the class definitions plus the presence of estimable coverage failures; it is not a result the grid can falsify.
WHY IT MATTERS: Primary 1 is sold as a four-statistic existence claim and "the study's central negative result". One of the four legs cannot fail under the registered definitions, so the breadth of that claim is overstated.
WOULD BE WRONG IF: `rank_screen` were a continuous identification measure whose values among nominal scenarios need not nest inside the failing range, or if non-estimable scenarios could be classified nominal under the registered coverage definition.

### Universal claim that E2 secondary rules “perform far better” is false for the candidate
SEVERITY: serious
QUOTE: "On E2 the same rules perform far better, which is a result rather than a footnote:"
PROBLEM: The table that immediately follows reports `source_survival` E1 Youden 0.2585 versus E2 Youden 0.2424, and E2 false-alarm rate 0.3333 against 0 for the other four rules. That is slightly worse on Youden, not “far better”, and it is the only rule with a nonzero E2 false-alarm rate. The sentence quantifies over “the same rules” and then presents all five rows without restricting the claim to the CMP-14 summaries.
WHY IT MATTERS: The secondary comparison is the place the document contrasts E1 and E2 operating characteristics. A blanket superiority claim that the table itself contradicts misstates the candidate’s E2 behavior and overstates how cleanly the nonlinear arm improves the warning rules.
WOULD BE WRONG IF: “the same rules” were explicitly limited to `contraction`, `target_ratio`, `eff_rank`, and `rank_screen`, excluding `source_survival`, or if the E2 Youden for `source_survival` were greater than 0.2585.

### Stratum-agreement wording denies the measurements just given
SEVERITY: minor
QUOTE: "all three are positive and the strata agree with the pooled reading, which is now asserted rather than observed."
PROBLEM: The same paragraph reports the E1 stratum correlations 0.2232 and 0.5119 and the pooled value 0.3295. Shared sign among those three numbers is observed in the text. Calling it “asserted rather than observed” either withdraws the status of the printed measurements or leaves residual repair wording that confuses registration language with measurement language.
WHY IT MATTERS: Primary 3’s only E1 cross-check that the pooled sign is not an aggregation artifact sits in this sentence; muddling asserted versus observed makes that check’s epistemic status unreadable.
WOULD BE WRONG IF: the stratum values were no longer computed or reported and the shared-sign statement were only a registration label without those numbers.
