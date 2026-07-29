VERDICT: unsound

### The analytic experiments put \(\gamma\) on placebo and study a different DGM
SEVERITY: fatal
QUOTE: "**The covariate is a pure effect modifier, not a prognostic factor**, and version 3 said otherwise. Checked: placebo survival at $t=12$ is 0.4356 at $x=-2$, $0$ and $+2$, because $\gamma_{\text{PBO}} = 0$."
PROBLEM: The E3 generator correctly sets placebo `gamma = 0`, but E1, E2, `cell_properties()`, the graft calculation, and the anchoring truth all construct placebo with `gamma = cc$gamma` or `GAMMA`. Those calculations therefore make \(x\) prognostic under placebo and remove it from each active-versus-placebo conditional contrast. For example, the registered placebo RMST is 10.5162, not the 9.5966 used by the anchoring diagnostic; its fitted value 10.625 is therefore high by 0.109 months, not 1.028.
WHY IT MATTERS: E1, E2, D3, the PH-test powers, the 0.0116-month graft bound, and the claimed flexible-ML-NMR absolute-curve bias are measurements of a different mechanism from E3 and the registered DGM.
WOULD BE WRONG IF: `make_arm()` ignored `gamma` for placebo arms, or the registered DGM actually set \(\gamma_{\text{PBO}}=\gamma\).

### Common random numbers are analyzed as 840 independent observations
SEVERITY: fatal
QUOTE: "**Estimator comparisons are paired on the replicate**, since all seven are computed on the same simulated network, and reported with paired intervals. Common random numbers are used across censoring regimes within a cell."
PROBLEM: The new `param_id` seeding correctly reuses one latent network across two or three censoring conditions, but `paired_contrast()`, `coverage_table()`, and `calibration_table()` still compute standard errors as though every condition-replicate row were independent. The 840 rows contain only 400 parameter-cell-by-replicate blocks, with within-block covariance that is neither estimated nor retained in the analysis data.
WHY IT MATTERS: Every primary paired interval, the pooled coverage interval, and the operating-characteristic claims such as \(P(\text{calibrated})=0.995\) use the wrong Monte Carlo variance.
WOULD BE WRONG IF: Outcomes from differently censored versions of the same latent network had exactly zero covariance, or the analysis used a cluster-aware variance over `param_id × rep`.

### ML-NMR alone receives sampled target summaries
SEVERITY: fatal
QUOTE: "**Target summaries are supplied to every method as the true superpopulation values** $(0.60, 1.00)$, identically."
PROBLEM: `sim_network()` computes arm-specific sample means and SDs from the generated aggregate patients, and `build_net()` passes those realized values to ML-NMR. MAIC, STC, and target prediction instead use the fixed \(0.60,1.00\). Thus target-summary sampling error and random arm imbalance enter only the ML-NMR fits.
WHY IT MATTERS: The identical-input claim is false, and primary comparisons can attribute target-summary noise to method family.
WOULD BE WRONG IF: `build_net()` replaced the realized `agd_summ` moments with \(0.60,1.00\), or every method used the same realized summaries and was scored against that target.

### The registered paired tests change the outcome to mean absolute error
SEVERITY: fatal
QUOTE: "The registered comparisons are each tested as a paired difference with a confidence interval, and they are **not of equal standing**."
PROBLEM: `paired_contrast()` calculates `abs(est_a - truth) - abs(est_b - truth)`. That is a paired difference in per-replicate absolute error, not a difference in mean absolute cell bias, RMSE, coverage, or time-specific calibration. It combines bias and variance and duplicates none of the four registered primary outcomes.
WHY IT MATTERS: The primary method comparisons answer an unregistered question, while the registered outcomes receive no paired confidence intervals.
WOULD BE WRONG IF: Mean absolute per-replicate error were registered as the comparison estimand, or separate paired intervals were implemented for each registered outcome.

### The bias correction retains a floor comparable to the effects of interest
SEVERITY: fatal
QUOTE: "The correction is standard: $\mathbb{E}[\hat b^2] = \mu^2 + \mathrm{se}^2$, so $|\mu|$ is estimated by $\sqrt{\max(0, \hat b^2 - \mathrm{se}^2)}$."
PROBLEM: Subtracting \(\mathrm{se}^2\) before taking a square root does not remove the absolute-value floor. Even with normally distributed \(\hat b\), known SE, and true bias zero, the proposed statistic has expectation \(0.3426\,\mathrm{SE}\). At the registered SE of \(0.75/\sqrt{40}=0.1186\), its residual floor is 0.0406 months.
WHY IT MATTERS: The “corrected” primary bias remains approximately the same size as the flexible-row pilot biases of 0.043 to 0.046 months and can still rank estimators by variance.
WOULD BE WRONG IF: The corrected statistic had zero expectation under zero bias, or it were explicitly registered as a biased plug-in diagnostic rather than an estimate corrected for its Monte Carlo floor.

### The ML-NMR within-row contrast still changes pooling and priors
SEVERITY: fatal
QUOTE: "The study intercepts absorb it exactly, so the pooled spline is not misspecified here and the primary within-row ML-NMR contrast does isolate proportionality."
PROBLEM: `MLNMR-PH` uses study-indexed baseline splines through `aux_by = .study`, whereas `MLNMR-flex` uses treatment-indexed, cross-study pooled splines through `aux_regression = ~ .trt`. Pure level shifts show only that both model classes contain the population truth. They do not make the finite-sample likelihoods, parameter sharing, or priors equivalent.
WHY IT MATTERS: Differences in RMSE, coverage, or finite-sample bias within the ML-NMR row cannot be attributed solely to proportionality, invalidating the registered Primary 2 mechanism claim.
WOULD BE WRONG IF: The two parameterizations were algebraically equivalent for finite samples under this DGM, or a calibration established that the pooling change contributes nothing to every registered outcome.

### Calibration over time is omitted from production and mislabeled for frequentist rows
SEVERITY: fatal
QUOTE: "Bias and pointwise 95% interval coverage of the target-standardized survival difference $\bar S_B(t)-\bar S_A(t)$ are therefore reported at $t \in \{6, 12, 18\}$, alongside the RMST primary, with the time grid registered here."
PROBLEM: `R/08-analyze.R::main()` never invokes or saves `load_calibration()` or `calibration_table()`. Moreover, frequentist `pack()` selects the nearest point from `seq(0.05,18,length.out=200)`, so values labeled 6 and 12 are evaluated at 6.0033 and 11.9565, then compared with truths evaluated at exactly 6 and 12.
WHY IT MATTERS: A registered primary outcome is absent from the production analysis, and its available frequentist implementation would mix time-grid error into reported calibration bias.
WOULD BE WRONG IF: A mandatory production entrypoint saved the calibration table and evaluated or interpolated every estimator at the exact registered times.

### The sampler policy monitors RMST but not the registered survival differences
SEVERITY: fatal
QUOTE: "The second correction stands: the ESS criterion binds on the **derived estimand**, the target-standardized $\Delta_{\text{RMST}}(18)$ and the survival differences on the time grid, which is what the study actually uses."
PROBLEM: `sampler_ok()` receives diagnostics only from `target_rmst_diff()`. `target_surv_diff()` computes no R-hat, bulk ESS, or tail ESS. A failed survival prediction is stored as `NULL` but does not make the fit fail if RMST diagnostics pass.
WHY IT MATTERS: Pointwise survival intervals and their coverage can be accepted despite missing output or inadequate tail mixing.
WOULD BE WRONG IF: The pass rule evaluated diagnostics separately for every registered survival difference and failed when any prediction or diagnostic was unavailable.

### The common fitted-curve Cox projection has no implementation
SEVERITY: fatal
QUOTE: "One prespecified Cox projection functional (section 5) is applied to every method's fitted target survival curves, so the constant summaries being compared are the same functional of different fits."
PROBLEM: `cox_limit()` is used only for analytic DGM arms in E1 and E2. E3 never applies it to estimator fits, and its checkpoints discard the fits and full curves, retaining only RMST and three survival-difference summaries.
WHY IT MATTERS: The registered common constant-hazard-ratio output cannot be calculated after the run.
WOULD BE WRONG IF: Another registered analysis path saved every fitted target curve and applied the section-5 functional to all seven rows.

### The sensitivity program is neither executable nor fully budgeted
SEVERITY: fatal
QUOTE: "Each runs on the same prespecified subset of two primary cells at **25 replicates per cell, 50 in total**, which is the count `n_sens` in `R/10-budget.R` and what the costs above are computed from."
PROBLEM: No two cell identifiers are registered, `R/07-run.R` has no sensitivity pass, and knot counts and prior scales are hardcoded. The budget also prices only one 50-replicate fit set for “halved and doubled” priors and one for “2 and 5” knots. At 442.4 seconds per replicate, each pair costs about 12.3 hours, not 6.1. The sensitivity total is therefore at least 35.2 hours before frequentist knot bootstraps, not 22.9. Even the printed components \(10.6+6.1+6.1\) equal 22.8, not 22.9.
WHY IT MATTERS: Registered sensitivity analyses cannot be launched as specified, and the frozen total understates their minimum cost by over 12 hours.
WOULD BE WRONG IF: A registered driver identified the cells and exposed both variations, and both alternative settings could genuinely be evaluated for the price of one model fit.

### The refit cap and all-passed analysis are not implemented
SEVERITY: fatal
QUOTE: "If it exceeds the cap, the excess fits are recorded as failures and the all-passed subset analysis carries them, rather than the budget being revised mid-run."
PROBLEM: `fit_mlnmr()` refits every first-attempt failure and has no global 20% counter. The rate is only printed after all refits have occurred. On the all-passed subset, `R/08-analyze.R` reruns only `bias_table()`; it omits coverage, calibration, and every registered paired comparison.
WHY IT MATTERS: The run can exceed its frozen refit budget, and its registered failure-sensitivity analysis is incomplete precisely when failures occur.
WOULD BE WRONG IF: An external registered scheduler enforced the cap before refitting and a downstream step repeated every primary outcome and comparison on the all-passed subset.

### Bootstrap endpoint Monte Carlo error is discarded
SEVERITY: fatal
QUOTE: "The inner Monte Carlo error of a 500-resample percentile interval is reported rather than assumed negligible."
PROBLEM: `freq_boot()` retains only percentile endpoints and `n_ok`; the bootstrap draws are discarded, and no endpoint Monte Carlo error is calculated or propagated to `R/08-analyze.R`.
WHY IT MATTERS: The promised uncertainty on intervals used in the primary coverage outcome cannot be reported or reconstructed.
WOULD BE WRONG IF: Endpoint Monte Carlo errors were computed before discarding the draws and returned in every checkpoint.

### The 512-point decision rule has uncovered outcomes
SEVERITY: fatal
QUOTE: "If the paired $512-256$ difference has a 95% interval lying inside $\pm 0.02$ months, the integration error is declared bounded below the smallest effect the study interprets and nothing changes. If the interval excludes zero and its magnitude exceeds 0.02, the primary ML-NMR results are reported **with the measured integration bias stated alongside every ML-NMR absolute bias**, and any conclusion resting on a difference smaller than that bias is withdrawn."
PROBLEM: The two branches are not exhaustive. An interval such as \([-0.03,0.01]\) crosses zero but is not contained in \(\pm0.02\), so neither rule applies. “Its magnitude” is also undefined for intervals such as \([0.005,0.025]\).
WHY IT MATTERS: The registered sensitivity arm can finish with no prespecified interpretation or action.
WOULD BE WRONG IF: A third inconclusive branch and an unambiguous interval-based magnitude rule were registered.

### D3 is not insensitive to the alternative thresholds
SEVERITY: serious
QUOTE: "D3's verdict is insensitive to this: at a 0.40 or 0.60 threshold the same four cells still flip, because the implied values span from $-0.062$ to $+1.318$ months while the truth sits at 0.750."
PROBLEM: The exported per-cell bounds give five flipping cells at 0.40 and five at 0.60, versus four at 0.50. At 0.40 the \(\kappa_B=0.30\) margin cell becomes an additional flip; at 0.60 the \(\kappa_A=0.30,\kappa_B=0\) cell does. The margin truths are also 0.35, not 0.750.
WHY IT MATTERS: The claimed threshold-robust cell count is false, although D3 still fails qualitatively.
WOULD BE WRONG IF: A complete per-cell recomputation at both alternative thresholds produced four flipping cells at each threshold.

### The proportional control does not bound non-proportional numerical error
SEVERITY: serious
QUOTE: "Its uncertainty is quadrature error, which the control cell bounds at $1.2\times10^{-10}$. An inconclusive region would be empty by construction."
PROBLEM: The control cell is proportional, so its across-regime cancellation measures numerical cancellation in the easiest case. It does not bound absolute quadrature and root-finding error in non-proportional cells. Refining the registered-mechanism calculation changes difficult-cell implied values by roughly \(10^{-3}\) months, not \(10^{-10}\).
WHY IT MATTERS: The stated numerical certainty and justification for having no inconclusive region do not follow from the cited measurement.
WOULD BE WRONG IF: A formal uniform error bound or a convergence study established \(1.2\times10^{-10}\) accuracy for every non-proportional cell and root.

### Effective degrees of freedom are not recorded
SEVERITY: serious
QUOTE: "The effective degrees of freedom of each fitted survival model is **recorded per replicate** so the paper can report how far apart the flexibilities actually were rather than assuming they matched."
PROBLEM: Neither run pass returns an effective-degrees-of-freedom field. Frequentist bootstrap fits and ML-NMR fit objects are discarded, so the quantity cannot be reconstructed from the checkpoints.
WHY IT MATTERS: The diagnostic expressly required to interpret the descriptive matched-flexibility comparisons will not exist.
WOULD BE WRONG IF: Another registered checkpoint path records effective degrees of freedom for every estimator and replicate before discarding the fits.

### The nine-condition coverage restriction is never reported
SEVERITY: serious
QUOTE: "The nine-condition `primary` restriction is reported alongside it and is never substituted for it."
PROBLEM: Production analysis calls `coverage_table(d)` once on all 21 conditions. It never filters `arm == "primary"` or emits a nine-condition table.
WHY IT MATTERS: One of the two prespecified coverage summaries is absent, defeating the stated guard against selecting the favorable pool after results are seen.
WOULD BE WRONG IF: A mandatory downstream analysis emits the nine-condition restriction without replacing the all-condition result.

### The verifier silently skips missing quoted-value sources
SEVERITY: serious
QUOTE: "`R/09-export-design.R` writes every quoted value out of the code that computes it, and `review/verify-protocol.py` asserts the document against that file, currently **253** assertions"
PROBLEM: `results/dgm-verification.rds` is absent. The exporter includes those values only inside `if (file.exists(...))`, and the verifier checks them only `if key in DESIGN`, so their absence passes silently. The verifier currently reports 253/253 despite the placebo-\(\gamma\) split and despite several unexported operating-characteristic and sensitivity claims.
WHY IT MATTERS: The advertised fail-closed protection against stale or unmeasured numbers is not fail-closed and cannot support the document’s provenance claims.
WOULD BE WRONG IF: Every quoted-value artifact were mandatory and both export and verification stopped when any expected key or source file was absent.
