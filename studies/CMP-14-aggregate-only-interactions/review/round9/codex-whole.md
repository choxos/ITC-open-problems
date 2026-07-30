VERDICT: unsound

### The withdrawn E1 criterion is still executable
SEVERITY: fatal  
QUOTE: "`eff_rank` is one of the six comparisons that can withdraw E1's conclusion, so this is a limitation of that verdict and not a footnote."  
PROBLEM: Section 8 later correctly says those six comparisons test state separation, not E1's primary conclusion, and therefore cannot withdraw it. Yet `e2_verdict()` still defines `withdraw_e1 = any(rules$separates)`, exports that field, and prints “E1's conclusion is withdrawn.” The stale claim also remains in section 9 and the subsection heading.  
WHY IT MATTERS: A future state separation could make the software withdraw E1 while the actual E2 primary-1 overlap test says E1 reproduces. The registered inter-arm verdict would then be contradictory.  
WOULD BE WRONG IF: E1's conclusion explicitly included state separation, or the six comparisons no longer controlled any `withdraw_e1` output and only primary 1 determined reproduction.

### The claimed E1 pointwise check does not exist
SEVERITY: serious  
QUOTE: "**E1's version is established separately**, in `R/09-smoke.R`: E1's exact Gaussian bias, computed with no aliasing algebra in it at all, equals the same $\text{shift} - [(I+P_0)^{-1}P_0\theta^{*}]_{\Gamma_3}$ expression to **1.6e-15** over 40 scenarios, and `mean_true` equals $X\theta^{*}$ to **1.8e-15**."  
PROBLEM: `R/09-smoke.R` checks only the scalar bias identity. It never computes or asserts `max(abs(mean_true - X %*% theta_star))`; the 1.8e-15 value appears only in prose. Independent recomputation over all 504 scenarios gives 1.776e-15, so the number is arithmetically credible, but the stated software evidence is nonexistent.  
WHY IT MATTERS: The foundational claim that E1 is exact estimand aliasing rather than another departure is not protected by the guard cited as establishing it.  
WOULD BE WRONG IF: `R/09-smoke.R` actually executed and asserted the pointwise mean identity, or another exported and verified computation supplied the 1.8e-15 result.

### The E2 candidate still lacks row-level exploratory standing
SEVERITY: serious  
QUOTE: "Every outcome that reports it says so on the row."  
PROBLEM: E2 scenario rows and every `e2_by_state` row report `surv_between` without a standing field. The repair adds one detached global value, `e2_candidate_standing`, rather than attaching standing to those rows. The verifier compounds this by checking standings on `e2_rules`, whose rows concern the three CMP-14 summaries, not the candidate.  
WHY IT MATTERS: The post hoc candidate remains packaged beside ordinary E2 outputs without the row-level exploratory label the protocol promises.  
WOULD BE WRONG IF: Those E2 rows were non-reportable intermediates, or every exposed row containing a candidate value carried `post-hoc-candidate` directly.

### The claimed complete export omits quoted evidence
SEVERITY: serious  
QUOTE: "`R/05-export.R` writes every quantity this document quotes to `results/registered-design.json`."  
PROBLEM: The JSON does not contain the quoted 0.44 coverage movement, 11 reclassifications, or E1 gaps of 1.6e-15 and 1.8e-15. It also does not read or require `results/routes.rds`; the verifier hardcodes the desired route-table entries instead of comparing them with that computation. I independently reproduced 0.439945 and 11 reclassifications, so the immediate arithmetic is right, but the claimed safeguard does not cover it.  
WHY IT MATTERS: The stated defense against stale or invented repair numbers omits several repair numbers and the aggregate-route table underlying the thesis.  
WOULD BE WRONG IF: Those quantities and `routes.rds` were exported and verified against the protocol, or the provenance claim were explicitly narrowed to a listed subset.

### The verifier ignores changes to the exporter
SEVERITY: serious  
QUOTE: "the verifier refuses to run when the export is older than the code."  
PROBLEM: `review/verify-protocol.py` explicitly excludes `R/05-export.R` from its newest-code calculation. That file directly computes and writes `registered-design.json`, including the new E2 overlap result. Editing it after the JSON was generated would therefore leave a stale export that the verifier accepts.  
WHY IT MATTERS: Derived definitions or values can change in their producer while all 175 assertions still run against the previous export.  
WOULD BE WRONG IF: The verifier included `R/05-export.R` in the export-age check or tracked its content through an equivalent dependency hash.

### Seventy-two of the claimed binary classifications are undefined
SEVERITY: minor  
QUOTE: "The decisions are the failure label, the nominal label and all five warning rules, which is **3,528** binary classifications across the grid."  
PROBLEM: The arithmetic 504 × 7 does equal 3,528 slots, but `source_survival` is `NA` in 72 absent scenarios. There are therefore 3,456 binary classifications and 72 undefined slots. The flip calculation uses `na.rm = TRUE` rather than reporting this distinction.  
WHY IT MATTERS: The registered denominator and the description of what the nuisance-prior check compares are false.  
WOULD BE WRONG IF: All 3,528 entries were nonmissing binary values, or the document called them slots and separately registered the 72 exclusions.

### The 148 findings came from three reviewers, not two
SEVERITY: minor  
QUOTE: "Eight rounds of critique returned **148** fatal and serious findings between two reviewers, counted as returned rather than deduplicated."  
PROBLEM: The change-history table names Codex, Grok, and GLM. Codex plus Grok contribute 143 findings; GLM's four fatal and one serious finding raise the total to 148. The same history explicitly calls GLM “a third reviewer.”  
WHY IT MATTERS: The document misstates its review provenance while claiming that provenance is computed from the table.  
WOULD BE WRONG IF: GLM's five findings were excluded from 148 or GLM were not a distinct reviewer.

### Runtime output still calls survival a share
SEVERITY: minor  
QUOTE: "**`source_survival` is not a share and asking for one is ill-posed.**"  
PROBLEM: `R/07-run-e2.R` still prints the runtime label “source share,” and the E1 nuisance output uses the same label. The stored field names were repaired, but the analyst-facing output was not.  
WHY IT MATTERS: Running the registered software reintroduces exactly the additive-attribution interpretation the protocol rejects.  
WOULD BE WRONG IF: Those console lines were guaranteed to be inaccessible internal diagnostics or were relabeled as survival.
