# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART F OF 7: what this cannot settle, and the change log across five rounds

You are reviewing a protocol revised four times. Round one returned `unsound`,
round two `unsound`, round three `unsound`, round four `unsound`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
`round4_resolution` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

## 11. The decision model behind the 0.50-month threshold

A treatment is recommended if its target-population RMST gain over the comparator at 18 months
exceeds the gain that justifies its cost, set at 0.50 months. It is declared before the run and
every conclusion that depends on it is labeled as depending on it. It now enters in exactly two
places: **D3**, where it is the tolerance the plug-in hazard ratio's across-regime range is judged
against, and the **secondary decision-loss appendix** of section 10.0. Version 4 also used it in
D1, which is withdrawn.

**Sensitivity: D3 and the decision-loss appendix are both recomputed at thresholds of 0.40 and 0.60
months** and reported, since the number is a stipulation and not an estimate. D3's verdict is
insensitive to this: its worst range of 1.3805 months exceeds even the 0.60 tolerance by more than
a factor of two, so the failure is not an artifact of where the threshold was set.

## 12. What this cannot settle

- One covariate. Multiplicity across covariates is not measured.
- Weibull and Gompertz only. Multistate mechanisms cross in ways these families cannot produce, and
  the entry names them.
- No separate one-step exact-likelihood survival NMA estimator. Stated as an omission; no
  equivalence claim is made.
- Independent censoring, varied **between studies**. Arm-differential censoring within a comparison
  is not varied.
- Target summaries treated as known, deliberately; see MIS-03.
- Digitization error in reconstructing aggregate survival curves is assumed away entirely.
- Shared effect modification holds by construction; its failure is IDN-05's subject.
- Fixed-effect synthesis throughout, on a two-study network where heterogeneity is not identified.
- **The novelty claim is not a systematic review.** "No simulation study compares these estimators"
  reflects the searches recorded in the catalog entry's verification trail and no more; round 2 was
  right that no reproducible search strategy supports it, and it is downgraded to a statement about
  what was found rather than what exists.
- **The marginal-scale mechanism is not new and this study does not claim it is.** That a marginal
  hazard ratio drifts under exact conditional proportional hazards, because the risk set selects on
  a prognostic covariate, is established: Hernán, *The hazards of hazard ratios*
  (doi:10.1097/EDE.0b013e3181c1ea43); Aalen, Cook and Røysland
  (doi:10.1007/s10985-015-9335-y); Stensrud and Hernán (doi:10.1001/jama.2020.1267). Round 2 was
  right that version 2's "nobody appears to have quantified it" overclaimed against exactly this
  literature. What is offered here is narrower and is stated narrowly: the **censoring-regime
  dependence** of that drift, sized exactly against the non-proportionality pathway on a common
  scale, and the finding that under the shared-effect-modifier assumption these methods require it
  is an order of magnitude the smaller of the two.

## 12b. OUT-11 remains open after this study

Stated plainly because round 3 asked for it plainly. The catalog entry asks for general-likelihood
ML-NMR and a separate one-step exact-likelihood estimator, against proportional-hazards MAIC and
STC, across Weibull, Gompertz **and multistate** mechanisms, plus missing component-PAIC
functionality. This study runs two of the three mechanism families, does not implement the one-step
estimator, and adds nothing to component PAIC. It is a partial benchmark. **After it is published,
OUT-11 should remain marked open**, with its verification trail recording which part this study
closed and which parts it did not. Version 3 argued the one-step omission away on the grounds that
ML-NMR fits the same exact likelihood; round 2 was right that this is not an estimator-level
equivalence argument, and the claim is withdrawn rather than restated.

## 13. What changed after each critique round

Round 1, both reviewers, resolved in version 2 and unchanged since: the treatment contrast
depended on the study baseline (fatal, confirmed numerically at a spread of $-0.2764$, mechanism
rebuilt, invariance verified to $4.4\times10^{-16}$); $\kappa$ did not isolate non-proportionality
(fixed by the same reparameterization, verified to $5.3\times10^{-16}$); the centerpiece experiment
demonstrated a known theorem (accepted, reframed as sizing); $\tau$ as a follow-up quantile would
move with censoring (fixed at 18); the marginal hazard was defined as an average of conditional
hazards (corrected).

Round 2, this version:

| Finding | Severity | Resolution |
|---|---|---|
| Censoring absent from the cell matrix, replicate total and runtime | **fatal** | **Confirmed.** Regimes assigned to experiments explicitly: four in E1 and E2, two in E3; matrix, replicate total and runtime recomputed |
| DGM not numerically locked | **fatal** | **Confirmed.** Every parameter registered in `R/00-config.R` and transcribed in section 3; crossing times, PH-test power, event fractions and at-risk fractions reported per cell in section 8 |
| 0.5-month threshold does not justify a 0.5-month bias tolerance | **fatal** | **Confirmed against version 2's own numbers.** Rule restated as recommendation error; $\beta_B$ solved so cells straddle the boundary; absolute pooled bias replaced by weighted mean absolute cell bias |
| MAIC and STC cannot consume three aggregate studies | fatal | **Confirmed.** Network reduced to two studies so the identical-evidence claim is true |
| PH-versus-flexible columns changed likelihood and basis too | serious | Rows rebuilt on one basis each, toggling only treatment-by-time terms; weighted Cox retained as a separate labeled row |
| Equal knot counts do not equate RP and M-spline flexibility | serious | Matched-flexibility claim withdrawn; knot placement specified; complexity-sensitivity arm added |
| Superpopulation estimand versus MAIC's realized-sample target | serious | Target summaries supplied as known superpopulation values to every method |
| No time-indexed calibration outcome | serious | Pointwise survival-difference bias and coverage at 6, 12, 18 |
| Coverage cannot be resolved at 240 replicates; no inconclusive region | serious | Arithmetic corrected to 0.014; Monte Carlo intervals and an explicit inconclusive verdict |
| D2 underspecified: statistic, weights, allocation, baseline | serious | All specified in D3; fixed baseline curve; range statistic; labeled a PH plug-in procedure |
| No priors, prior sensitivity, bootstrap interval type or resampling unit | serious | All registered in section 7.2 |
| $\hat R$ alone is not a sampler policy | serious | ESS, divergences, treedepth and a refit-and-record escalation registered |
| Integration order cited from IDN-05 argues against the choice it justified | serious | **Confirmed.** Order measured on this network; section 14 |
| Runtime omitted censoring regimes and bootstrap | serious | Recomputed in section 14 from measured timings |
| Two sources called "exactly separable" | serious | **Confirmed by the computed table**; reported as a factorial with interaction, with only the two exact ablations claimed |
| Study 5 unidentified; novelty claim unsourced; one-step equivalence unestablished | citation | IDN-05 named and linked; novelty claim downgraded; equivalence claim withdrawn |
| Broad title overstates a partial benchmark | limitation | Title and abstract scoped to Weibull and Gompertz |

Round 3, this version. Three reviews: one on the whole protocol, two on halves because the second
reviewer has an input-size ceiling.

| Finding | Severity | Resolution |
|---|---|---|
| STC stored Gauss-Hermite weights and never used them, marginalizing over an implied SD of 5.568 against a target of 1.000 | **fatal** | **Confirmed by measurement** (0.4609 against 0.4753 correct and 0.4753 by Monte Carlo). Fixed; the pilot it invalidated was rerun; a registered "anticipated mechanism" built on it is withdrawn as an artifact; `verify_quad()` now blocks the failure class |
| Forcing STC through MAIC's marginal graft is invalid and handicaps it | **fatal** | **Confirmed.** Each method now gets the strongest valid transport its own structure supports: MAIC keeps the graft as its own declared limitation, STC transports conditionally and marginalizes last |
| The aggregate study was analyzed as individual patient data | **fatal** | **Confirmed.** Covariate column deleted at generation; only reconstructed event times and reported summaries survive |
| Excess-over-own-floor divides out variance, so an arbitrarily noisy estimator passes | **fatal** and independently **serious** from the second reviewer | **Confirmed.** Replaced; then the replacement was killed by measurement too, since a constant rule beats every estimator. Estimation quality is now primary and paired, needing no threshold |
| All non-proportionality sits on the aggregate side, where MAIC and STC do not act, so the comparison the entry asks for is never exercised | serious | **Confirmed, and not visible to me.** $\kappa_A$ becomes a design factor; the contrast still carries no covariate term |
| The 0.10 cutoff was calibrated on the pilot it was tested against | **fatal** | Moot: paired comparison requires no cutoff |
| Integration acceptance threshold 0.02 sits below its own standard error 0.024 | **fatal** and independently serious | **Confirmed**, and my own earlier caution was warranted: the 64-to-128 gap is $+0.063$ in one replicate and $-0.007$ in the next. Rule becomes an uncertainty bound; 256 must be shown converged, not assumed |
| E1 and E2 not in the locked configuration; `N_INT` still `NA`; `N_REP` cut unspecified | **fatal** | All move into `R/00-config.R` and freeze before any replicate runs |
| The study cannot settle OUT-11 | **fatal** | Accepted; section 12b states OUT-11 remains open afterward |
| D1 cell mixture irreconcilable between the 6-cell pilot and the 8-cell rule | serious | Moot with the threshold removed |
| Prior-sensitivity and knot-complexity arms absent from the runtime table | serious | Same omission class as a round-2 fatal; both enter section 14 |
| "Four chains cost the same wall clock" | serious | **False, measured**: 166.9 s against 74 s. Two chains suffice, since the derived estimand reaches ESS above 2000 |
| No cell produced an in-window hazard crossing | serious | **Confirmed against version 2.** Resolved as a side effect of solving $\beta_B$ to a decision margin; crossings now at 6 to 14 months, section 8 |
| The 500-resample bootstrap is plausibly the dominant cost and was called "cheap" unmeasured | serious | **Confirmed, and it is.** Measured at 0.658 s per resample, which is 11.0 hours against roughly 3 hours of Stan; section 14 |
| Comparator authorship uncited, so the fairness guarantee is unauditable | citation | Six attributions added and CrossRef-verified, section 7.2 |
| "Nobody appears to have quantified it" overclaims against the marginal-HR literature | citation | **Confirmed.** Hernán 2010, Aalen et al. 2015 and Stensrud and Hernán 2020 cited; the claim narrowed to the censoring-regime dependence, section 12 |
| $\gamma$'s role ambiguous between prognostic and treatment-specific | minor | $\gamma$ stated as shared across A and B, with the consequence that it cancels from the B-versus-A contrast, section 3 |
| MAIC mean-matching transports a same-variance normal exactly, unremarked | minor | Recorded in section 7.2, with the reason both moments are matched anyway |

Round 4, this version. Two reviews, the second split into halves for an input-size ceiling; a third
returned empty and is recorded as not obtained rather than counted as agreement. **Three of the
findings were defects I introduced while fixing round 3**, which is the specific failure this round
existed to catch.

| Finding | Severity | Resolution |
|---|---|---|
| E1 and E2 evaluate a direct head-to-head coefficient, but OUT-11 concerns a transported **anchored indirect** comparison, and least-false Cox coefficients are not transitive under non-proportional hazards | **fatal** | **Confirmed, and version 4 had defended the wrong framing explicitly.** Both experiments rebuilt on the anchored contrast with each leg under its own study's censoring and the two regimes crossed independently. Measured gap between the two quantities: 0.93% to 1.78%, and it varies with censoring. Consequences were large: D3 moves from 0.697 (pass) to **1.3805 (fail)** |
| Section 10.3's pilot table still carried the pre-fix STC columns | **fatal**, found as "not distinguished from the withdrawn artifact" and worse on inspection | **Confirmed and worse than reported.** Twelve values from deleted code; every STC-flex entry had the wrong sign. One claimed finding (STC-PH's biases cancelling at $\kappa_B{=}0.15$) rested entirely on the artifact and is **withdrawn**, section 10.3 |
| D1 is claimed replaced but section 10.2 still registers it as "the primary outcome" with its 0.10 cutoff and the conceded gaming claim | **fatal**, both reviewers independently | **Confirmed.** Deleted rather than demoted, section 10.2b. Contradiction with sections 10.0 and 10.1 removed |
| The bootstrap budget contradicts the protocol's own unit cost by roughly eightfold | **fatal** | **Confirmed by direct measurement**, which also showed the unit cost itself was wrong: 0.711 s, not 0.658 s, and the "6.4 h" line implied about 62 rather than 500 resamples per replicate. Section 14 rebuilt |
| The Stan unit cost (227 s for both arms) is below the measured cost of one 128-point fit (296.2 s) | serious | **Confirmed.** Re-measured directly at the exact production configuration, section 14 |
| Sections 8, 9 and 10.2 quote replicate arithmetic the freeze had superseded | serious | **Confirmed.** Counts restored to 40 per cell and 500 resamples on the instruction to prioritize robustness over schedule, and propagated by machine check rather than by rereading |
| "Method family across rows at matched flexibility" is registered as a primary contrast on a premise round 2 **withdrew** | **fatal** | **Confirmed.** Those three contrasts demoted to descriptive; effective degrees of freedom recorded per replicate so the eventual paper can report the flexibility gap instead of assuming it away, section 10.1 |
| Scoring MAIC through a knowingly invalid graft while STC gets a valid conditional transport cannot support a method-family comparison | **fatal** | **Confirmed as a legitimate objection and answered by measurement.** The graft's structural error is exactly computable: at most **0.0116 months**, 1.6% of MAIC-PH's pilot bias, and exactly zero when $\gamma=0$. STC's conditional transport is exact to machine precision. The objection does not bite on this design, section 7.2 |
| D3's estimand stated three incompatible ways across sections 2, 5 and 10 | **fatal** | **Confirmed.** Defined once in section 10.3; other sections refer to it |
| The 256-point sensitivity arm is costed at 128-point prices | serious | **Confirmed.** Recosted at measured 256-point timings, section 14 |
| The coverage rule's operating characteristics are stated only as "the region is wide" | limitation | Tabulated under both a calibrated and a miscalibrated truth, section 10.3. This is also what showed the replicate restoration matters: P(calibrated) rises from 0.733 to 0.953 |
| The refit escalation has no budget line | minor | Capped and costed at 41.3 h, section 14 |

Four further defects were found by the author while implementing the above, before round 5 saw any
of it. They are listed here because a change log that records only what reviewers caught understates
how much of a protocol is still wrong at each revision.

| Found while fixing | Severity | Resolution |
|---|---|---|
| The rebuilt anchored computation evaluated **both legs at the target study's baseline**, which is stronger than perfect population adjustment and which no method delivers | **fatal** | Leg A moved to the IPD study's own baseline. Worth 2.86% on the hazard-ratio scale at $\kappa_A = 0.30$, varying by regime; D3's worst range moves from 1.4332 to **1.3805**, section 2 |
| Every timing the study had taken was inflated roughly twofold by machine contention, because the check for a quiet machine grepped for `Rscript` while the process is named `R` | **fatal** | Re-measured on a verified-quiet machine with the load recorded. This overturned the cost figure that had justified `N_INT = 128`, and the order is now **256**, section 14 |
| E3's censoring factor spanned only 45% of E1's range and only **one direction**: both conditions put the heavier censoring on the aggregate study, so an offsetting bias would read as accuracy | **fatal** | A mirrored condition registered, taking coverage to 87% and making the factor two-sided. The two `ipd-nph` cells, where the effect is largest, previously had no differential-follow-up condition at all, which is the same quarantine defect round 3 found for $\kappa_A$ |
| E2's per-cell seed stride was 1,000 with 2,000 replicates, so cells with identical leg-A parameters drew the same 1,000 datasets | minor | Stride raised above the replicate count, with a guard. Nothing reported was affected, since every E2 figure is computed within a cell |

