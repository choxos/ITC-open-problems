VERDICT: unsound

### E2’s grid was registered only after E2 had been inspected
SEVERITY: fatal
QUOTE: "Its four separation rules were committed before it ran and are confirmatory with respect to it."
PROBLEM: The rules existed, but the current 72-scenario grid did not. Before the first E2 run, the committed configuration specified a different fitted design with 200 replicates and 24 scenarios. The current grid and implementation were committed after the initial E2 artifact was created, in a commit whose message already reports the E2 results. A later rerun cannot restore confirmatory status after the first results were seen.
WHY IT MATTERS: Range separation depends directly on the chosen spreads, SD ratios, budgets and priors. None of the four E2 separation results is confirmatory.
WOULD BE WRONG IF: An immutable pre-run record contains the exact current 72-scenario grid and establishes that the earlier E2 output was not inspected before that grid was fixed.

### E2 uses the model Fisher information where misspecification requires a sandwich calculation
SEVERITY: fatal
QUOTE: "what *is* closed form is the information, and from it the large-sample posterior covariance and the large-sample sampling distribution of the mode."
PROBLEM: Discordance and synergy make the true Bernoulli probability differ from the fitted probability. Then the score variance is not the model Fisher information, and for aggregate logistic-normal means the expected Hessian is not that information either. The code nevertheless uses `(I + P0)^{-1} I (I + P0)^{-1}`. Under the correct first-order Hessian and score variance, a registered curvature scenario changes from 0.9400 coverage to 0.6898, crossing both the nominal and failure boundaries.
WHY IT MATTERS: E2 coverage, failure labels and every withdrawal rule conditioned on those labels are invalid.
WOULD BE WRONG IF: Every registered E2 scenario were correctly specified so that the Hessian, score variance and Fisher information coincide, or the implementation used the appropriate misspecification-robust calculation.

### The E2 withdrawal rule is not implemented as registered
SEVERITY: fatal
QUOTE: "If, on the logit link, **contraction or either form of effective rank separates `additivity` from `ecological` or from `curvature` at any threshold** across the E2 scenarios, then E1's central claim is an artifact of the identity link and **is withdrawn**."
PROBLEM: The executable verdict checks contraction and `target_ratio` only; it never checks the whole-model effective-rank count. It also does not compare the complete state distributions. It retains only failing aggregate scenarios and nominal additivity scenarios, discarding nominal aggregate rows, failing additivity rows and the intermediate band. Curvature comparisons additionally include equal-SD rows that the protocol says contain no curvature identification.
WHY IT MATTERS: A registered separation can occur without triggering withdrawal, so the claim that neither requested summary separates the states is unsupported.
WOULD BE WRONG IF: Another executable analysis checks both effective-rank forms over every registered row of each state and controls the withdrawal decision. None does.

### The target effective-rank ratio contains prior-assisted identification
SEVERITY: fatal
QUOTE: "`eff_rank` | likelihood-to-prior information ratio along the target's coordinate, plus the whole-model count of directions where the data outweigh the prior"
PROBLEM: `target_ratio` is calculated by marginalizing the posterior precision with all nuisance priors present and subtracting only the target prior precision. It is therefore not likelihood-only information. In the equal-SD curvature control, the likelihood cannot estimate the target, yet the formula returns a positive ratio because the nuisance prior resolves part of the target-nuisance confounding.
WHY IT MATTERS: Primary 1 and the E2 withdrawal rules analyze a prior-assisted posterior precision increment as though it were effective likelihood information.
WOULD BE WRONG IF: Target and nuisance coordinates were likelihood-orthogonal in every scenario, or the statistic were explicitly registered as prior-assisted marginal learning rather than likelihood information.

### The three-way source share is not an information decomposition
SEVERITY: fatal
QUOTE: "Holding the aggregate SDs equal at their average removes the second and leaves the first, so the difference measures the curvature route."
PROBLEM: Curvature studies already have identical covariate means. Equalizing their SDs therefore leaves two identical equations and no identifiable mean-gradient route. The code still obtains positive “mean” precision because it computes a prior-regularized marginal precision. Subtracting two such Schur complements, then clipping negative differences to zero, is not an additive decomposition of Fisher information.
WHY IT MATTERS: The 0.933–0.969 shares and the claim that the proposed replacement cleanly decomposes three evidence routes are not supported by the stated measurement.
WOULD BE WRONG IF: A prior-free additive decomposition left an identifiable mean-gradient contribution in the flattened curvature design and reproduced the reported shares.

### Primary 1 treats gross overcoverage as nominal
SEVERITY: fatal
QUOTE: "**Nominal means nominal.** The first version contrasted failing scenarios with merely non-failing ones, which lumps a scenario covering at 0.91 in with one covering at 0.950."
PROBLEM: The implementation defines nominal as `coverage >= 0.94`, with no upper limit. It therefore admits 76 scenarios above 0.96, including 100% coverage. Those prior-only scenarios set the reported “least reassuring success” to contraction 1 and target ratio 0. A genuine 0.95 ± 0.01 definition retains 165 nominal scenarios rather than 241 and changes the reported boundaries substantially.
WHY IT MATTERS: The registered primary comparison, its endpoints and its unclassifiable fraction are not computed for the population described in the protocol.
WOULD BE WRONG IF: “Nominal” were explicitly registered as one-sided coverage of at least 0.94 and 100% coverage were intentionally classified as nominal.

### The three-way source-share result is post hoc but is not labeled exploratory
SEVERITY: serious
QUOTE: "The resulting share separates the two states cleanly: **0.933 to 0.969 in `curvature` against 0.000 in `ecological`**, with no overlap."
PROBLEM: Section 8 establishes that this statistic was invented after the original E2 source-share condition failed by construction. It was then evaluated on the same E2 surface. Unlike the equal-SD result, the reported separation is not labeled exploratory in the registration-status statement or result.
WHY IT MATTERS: The proposed replacement is presented with confirmatory authority that the registration chronology does not support.
WOULD BE WRONG IF: The exact three-way formula was fixed before any E2 output was inspected, or the result were explicitly and consistently labeled exploratory.

### Substitution of expected information is not an expectation of the outcomes
SEVERITY: serious
QUOTE: "E1 represents each individual-data arm by its Gauss-Hermite nodes, which is the **expected** covariate design, so every E1 number is exact for a study whose covariate distribution is realized exactly and is an expectation otherwise."
PROBLEM: The code computes diagnostics and coverage at the expected information matrix. Matrix inversion, square roots and normal coverage probabilities are nonlinear, so evaluating them at expected information does not equal averaging them over realized covariate designs.
WHY IT MATTERS: E1 does not estimate the expected operating characteristics of studies with randomly realized covariates; it describes an idealized fixed pseudo-design.
WOULD BE WRONG IF: Covariates were fixed at the quadrature design, or every registered output were affine in the realized information matrix.

### The nuisance-prior sensitivity claim exceeds what was tested
SEVERITY: serious
QUOTE: "Every scenario is re-evaluated with the nuisance scale at 3 and at 30, an order of magnitude either side, and the largest movement in any registered quantity across the whole grid is **0.0007 in coverage, 0.0002 in contraction and 0.0000 in the source share**."
PROBLEM: Relative to the registered scale 10, values 3 and 30 are roughly threefold changes, not tenfold changes on either side. The check also measures only coverage, contraction and `share_within`; it omits registered quantities including `target_ratio`. Independent recomputation shows `target_ratio` moves by as much as 0.717.
WHY IT MATTERS: The conclusion that the interaction prior is the only prior doing work is not established for all registered diagnostics.
WOULD BE WRONG IF: “An order of magnitude either side” meant only a tenfold total range and every omitted registered output were separately shown invariant.

### The claimed numeric provenance can certify stale artifacts
SEVERITY: serious
QUOTE: "Every number this document prints is exported from the code that computes it by `R/05-export.R`, and `review/verify-protocol.py` asserts the document against that export, currently **108** assertions."
PROBLEM: The exporter does not recompute E1 or E2; it reads existing ignored RDS artifacts. The verifier then reads the existing JSON export. Several printed numbers are not actually matched, including the reported 0.933–0.969 curvature-share range; only its separation boolean is checked. Nevertheless the verifier reports 108/108.
WHY IT MATTERS: Changed code, stale RDS files or a mistyped active number can pass the advertised provenance guard.
WOULD BE WRONG IF: A mandatory wrapper regenerated every artifact from the exact committed source, bound it to that source, and asserted every printed value at its specific location.

### The fourth control checks existence, not “essentially always”
SEVERITY: serious
QUOTE: "The absent state must cover the truth essentially always under a wide prior and essentially never under a tight misplaced one."
PROBLEM: The guard takes the maximum absent-state coverage within each prior level and then compares the minimum and maximum across levels. It neither binds the low result to the tight prior nor requires all scenarios under the wide prior to cover. One covering wide-prior scenario is sufficient for that half to pass.
WHY IT MATTERS: A partially broken absent state could pass the positive control and distort the diagnostic sensitivity and false-alarm comparison.
WOULD BE WRONG IF: A separate enforced invariant proved that every absent scenario has identical coverage within each prior level and that coverage is ordered by prior width.
