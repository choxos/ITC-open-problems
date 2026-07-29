VERDICT: unsound

### E2 is specified as both MCMC and non-MCMC
SEVERITY: fatal
QUOTE: "**E2 is confirmatory and is registered blind.** It has not been run. It tests the same claims in the setting where they cannot be deduced: a nonlinear link, where aggregate curvature carries real information, fitted by MCMC rather than solved."
PROBLEM: Section 7 says no model is fitted and no MCMC is involved, while `R/00-config.R` still registers 200 replicates and 24 scenarios for a fitted arm. These are incompatible analyses.
WHY IT MATTERS: There is no unambiguous registered E2 procedure, so its confirmatory result cannot be interpreted.
WOULD BE WRONG IF: The MCMC sentence and obsolete replicate settings referred explicitly to a separate future experiment rather than E2.

### The registered E2 comparison cannot be performed
SEVERITY: fatal
QUOTE: "If, on the logit link, **contraction or either form of effective rank separates `additivity` from `ecological` or from `curvature` at any threshold** across the E2 scenarios, then E1's central claim is an artifact of the identity link and **is withdrawn**."
PROBLEM: `R/06-nonlinear.R` only evaluates estimability for SD ratios 1 and 2. It defines no E2 scenario grid, coverage calculation, contraction comparison, effective-rank comparison, source-share comparison, or withdrawal analysis. The E2 constants in `R/00-config.R` are unused.
WHY IT MATTERS: The confirmatory arm and its central decision rule cannot be run as registered.
WOULD BE WRONG IF: A fixed, referenced implementation containing those analyses existed at registration outside the supplied `R/` directory.

### One E2 decision result was observed before registration
SEVERITY: fatal
QUOTE: "Verified rather than asserted (`R/06-nonlinear.R`): with equal SDs the target is not estimable on either link, because the two studies give identical equations; with unequal SDs it is not estimable on the identity link and **is** estimable on the logit link."
PROBLEM: The saved `curvature-rank.rds` result is quoted before E2 is called blind, yet equal-SD estimability is subsequently registered as an E2 withdrawal condition.
WHY IT MATTERS: That E2 condition is exploratory, not blind or confirmatory.
WOULD BE WRONG IF: The rank probe were explicitly excluded from confirmatory E2 and the already-observed equal-SD condition were not presented as a registered test.

### E1's result-informed disclosure remains incomplete
SEVERITY: fatal
QUOTE: "Recorded because E1 was computed before this document existed, and a disclosure list is the only thing that makes an exploratory exact computation interpretable. Round 1 found the first version of this list incomplete; it now covers changes made both before and after that review."
PROBLEM: `DESIGN.md`, written after three numerical probes, proposed IPD fraction, per-component states, AUC, a target-population estimand, and a three-way source decomposition. These were later removed or replaced, but section 8 still lists none of them.
WHY IT MATTERS: By the document's own standard, the incomplete selection history makes exploratory E1 uninterpretable.
WOULD BE WRONG IF: `DESIGN.md` predated the numerical probes or those items were never design choices, contrary to its stated status and contents.

### A hidden 0.94 cutoff replaces nominal 0.95 coverage
SEVERITY: fatal
QUOTE: "With no discordance, no synergy and a prior that is not itself the problem, no scenario covers below nominal."
PROBLEM: `NOMINAL` is 0.95, but the saved null minimum is 0.9474. Both the guard and Primary 1 silently use `NOMINAL - 0.01`, so sub-nominal scenarios are accepted and classified as nominal.
WHY IT MATTERS: The null control is false as written, and Primary 1 compares failures against the wrong reference class.
WOULD BE WRONG IF: Nominal coverage had been registered as at least 0.94, or the registered subset actually had minimum coverage at least 0.95.

### Primary 2 matches the wrong sample-size quantity
SEVERITY: fatal
QUOTE: "**Primary 2.** `additivity` against `ecological`, matched on spread, arm size and prior scale, with synergy off."
PROBLEM: `state_pairs()` matches `n`, which is the total patient budget. Because `additivity` has 12 arms and `ecological` has 10, their per-arm sizes are `n/12` and `n/10` and are not matched.
WHY IT MATTERS: The software cannot perform the registered matched comparison, so Primary 2 is not the analysis described.
WOULD BE WRONG IF: `n` were per-arm size or the two states had the same number of arms.

### The source-share falsifier cannot fire
SEVERITY: fatal
QUOTE: "If **`source_share` separates `curvature` from `ecological`**, then the claim that they are the same kind of evidence is wrong and the statistic is measuring something narrower than advertised; that is reported as a defect in the proposed replacement, not hidden."
PROBLEM: `source_share` partitions rows only into IPD and aggregate. In both `curvature` and `ecological`, every target-bearing row is aggregate and the other IPD rows have a zero target column. Both states therefore receive source share zero by construction.
WHY IT MATTERS: This registered safeguard is decorative and cannot reveal the proposed replacement's advertised defect.
WOULD BE WRONG IF: E2 decomposed aggregate information into mean-gradient and curvature contributions, or either state contained target-bearing IPD rows.

### The largest-budget coverage number does not reproduce
SEVERITY: serious
QUOTE: "The first version asserted collapse at the tight prior in every state; measured, coverage recovers to 0.94, 0.84 and 0.80 at the largest budget as the likelihood wins"
PROBLEM: Recomputing the registered tight-prior, zero-discordance, zero-synergy subset at 10,000 patients gives state maxima of 0.938, 0.875, and 0.798, rounding to 0.94, 0.87, and 0.80. No scenario in that subset rounds to 0.84.
WHY IT MATTERS: The numerical evidence offered to justify weakening the prior-domination guard is stale or taken from an unspecified analysis.
WOULD BE WRONG IF: A different preregistered subset producing 0.84 were identified.

### The reported fraction is not a fraction of the grid
SEVERITY: serious
QUOTE: "Reported as the most reassuring failure, the least reassuring success, and the fraction of the grid lying between them."
PROBLEM: `overlap_table()` first removes intermediate scenarios and then computes `mean(...)`. Its denominator is 493 retained scenarios, not the full 504-scenario grid.
WHY IT MATTERS: The registered Primary 1 fraction does not measure what the protocol says it reports.
WOULD BE WRONG IF: The fraction were computed over all 504 scenarios or “grid” were explicitly defined as the filtered comparison subset.

### The claimed numerical provenance is not implemented
SEVERITY: serious
QUOTE: "**Provenance.** Every number this document prints is exported from the code that computes it by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export, currently **72** assertions."
PROBLEM: The export and verifier omit numerous printed quantities, including the five-scenario overcoverage range, the bias values, the 0.400-versus-0.240 comparison, and the largest-budget recovery values. The incorrect 0.84 therefore passes verification.
WHY IT MATTERS: The advertised protection against stale copied numbers does not exist for several control justifications.
WOULD BE WRONG IF: Every printed numerical claim had a corresponding exported value and equality assertion.

### The tight-prior guard excludes a registered state
SEVERITY: serious
QUOTE: "**The tight prior pulls every state toward zero, and hurts the least-informed state most.**"
PROBLEM: The guard explicitly removes `absent`, then tests state-averaged bias only for `additivity`, `ecological`, and `own_ipd`. `absent` is the actual least-informed state.
WHY IT MATTERS: The run does not stop when the “every state” assertion or the stated least-information ordering fails.
WOULD BE WRONG IF: The claim said “every non-absent state,” or another guard directly tested absent-state bias and the full ordering.

### The equal-SD verification omits the identity-link half
SEVERITY: serious
QUOTE: "Equal SDs give two identical equations and identify nothing on either link."
PROBLEM: The `mechanism holds` expression checks equal-SD non-estimability only on the logit link. The protocol verifier repeats that omission and never asserts the exported equal-SD identity result.
WHY IT MATTERS: The state could cease to be nonlinear-only on the identity link while both advertised safeguards still pass.
WOULD BE WRONG IF: Either check explicitly required equal-SD identity-link non-estimability.

### The nuisance prior is declared inert without measuring it
SEVERITY: minor
QUOTE: "Nuisance coefficients now carry a fixed weak `PRIOR_SD_NUISANCE = 10`, which is not a factor and must not be doing work."
PROBLEM: No registered sensitivity analysis or guard measures whether changing this prior affects coverage, contraction, target ratio, or source share.
WHY IT MATTERS: The claim that results belong only to the interaction-prior factor is unverifiable as registered.
WOULD BE WRONG IF: A registered sensitivity analysis or an orthogonality proof established invariance within a stated tolerance.

### A novel threshold cannot already be conventional
SEVERITY: minor
QUOTE: "**The thresholds are the conventional ones**, taken from how such summaries are described rather than tuned."
PROBLEM: `source_share` is introduced as this study's new candidate replacement, so its `SOURCE_OK = 0.50` threshold has no cited prior convention.
WHY IT MATTERS: The secondary operating characteristics would be presented as convention-based when one threshold is study-created.
WOULD BE WRONG IF: A cited pre-existing source defined the same statistic and 0.50 rule.
