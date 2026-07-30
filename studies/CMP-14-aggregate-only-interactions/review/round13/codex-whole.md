VERDICT: needs-revision

### Saved E2 candidate verdict still detaches its post-hoc standing
SEVERITY: serious
QUOTE: "Every outcome that reports it says so on the row."
PROBLEM: `R/07-run-e2.R` saves `results/e2-verdict.rds` with one detached `candidate_standing` field and bare candidate fields including `curvature_surv`, `ecological_surv`, `surv_sd_curvature`, `surv_sd_ecological`, and `surv_sd_separates`. Round 12 labeled the printed lines and wrapped these values in the later JSON export, but it did not repair the saved verdict itself. The verifier checks only the wrapped export, so all 221 assertions pass without detecting this.
WHY IT MATTERS: The saved E2 verdict still packages post-hoc candidate results beside registered state-separation rules without carrying the candidate’s standing on each result, so the protocol’s output-standing guarantee is false.
WOULD BE WRONG IF: `results/e2-verdict.rds` is not a saved study outcome, or each candidate field in that artifact itself carries `post-hoc-candidate` rather than relying on the detached field.
