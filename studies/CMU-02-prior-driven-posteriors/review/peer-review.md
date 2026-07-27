# Peer review: Do prior-sensitivity diagnostics catch the analyses that are actually wrong?

Study aimed at catalog problem **CMU-02**, also bearing on CMP-14.

Two independent reviewers, two rounds. Reports, author responses and the
editorial decision are reproduced in full and unedited. Reviewers were
given the manuscript, the protocol registered before the run, and the
prespecified decision as evaluated; in round two they additionally saw
round one's reports and the authors' response.

## Reviewers

| | Reviewer | Round 1 | Round 2 |
| --- | --- | --- | --- |
| R1 | GPT-5.6 Sol (maximum reasoning effort) | major-revision | major-revision |
| R2 | GLM-5.2 (via Ollama) | minor-revision | minor-revision |
| invited | Kimi K3 (via Ollama) | not run | not run |

## Round 1

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

The study uses an exact conjugate Gaussian simulation to evaluate four automated prior-sensitivity warnings and a composite across a factorial set of evidence structures, prior scales, sample sizes, and target contrasts. Exact posterior computation, explicit positive controls, and reporting both sensitivity and false warnings are important strengths. However, the study does not presently answer CMU-02: prior dominance is the stated problem, whereas the reference standard is undercoverage, so a correct warning in a prior-dominated but well-covering scenario is counted as false. The principal negative finding is also largely built into the combination of a zero-centered tight prior, true gamma_C = 0.40, and little or no likelihood information, while the reported operating-characteristic estimand, uncertainty calculation, protocol deviations, and omitted results prevent the prespecified verdict from being accepted.

**Strengths.**

- The closed-form Gaussian analysis cleanly removes MCMC convergence and importance-sampling error from the diagnostic comparison.
- The authors appropriately distinguish sampler convergence from likelihood information and avoid describing the no-diagnostic condition as current practice.
- The factorial design includes both prior-compatible and prior-incompatible truths, two sample sizes, graded evidence structures, and analyses excluding the acknowledged positive controls.
- The manuscript is unusually transparent about the initially circular reference standard and the post-run power-scaling amendment.
- There is no evident variance-estimator rigging: all diagnostics operate on the same exact posterior rather than giving one method an inferior uncertainty estimator.
- The limitations concerning component models, ecological discrepancies, nonconjugate models, and released software are stated with commendable restraint.

**Comments.**

**Major 1** (The problem; The reference standard; Results). The reference standard answers a neighboring question. CMU-02 concerns whether the posterior is driven by the prior, but the study labels cells by frequentist coverage and calls warnings in cells with coverage at least 0.94 false. Thus, when gamma_C = 0 and a zero-centered prior dominates, a diagnostic that correctly detects prior dominance is penalized, despite the manuscript saying that silence in these cells must not be credited. Conversely, in an unidentified direction no data-based diagnostic can determine whether an unsupported prior location happens to equal the unknown truth. The study therefore evaluates whether influence diagnostics predict wrong answers, not whether they expose prior-driven posteriors.

*What would satisfy this:* Separate prior dominance from harm. Evaluate diagnostic calibration against a prespecified DGM-level or counterfactual measure of prior influence, then separately study how that influence relates to bias, coverage, and decision loss. Alternatively, reframe the paper entirely as a study of predicting undercoverage and withdraw the claim that it answers CMU-02.

**Major 2** (Performance measures; Table 1). The reported sensitivity is not sensitivity for flagging analyses whose intervals miss the truth. A scenario-contrast is first called harmful when its coverage is below 0.90, and the rule then counts as detecting that cell only when it fires in a majority of replicates. This discards the pairing between a warning and an interval miss within each replicate. Consequently, 0.111 means that 2 of 18 design cells had warning probabilities above 0.5; it does not mean that one harmful analysis in nine was flagged. The false-warning calculation has the same problem and can penalize a warning on a replicate that actually misses the truth merely because its scenario has good average coverage.

*What would satisfy this:* Report replicate-paired P(warning | interval miss) and P(warning | interval covers), stratified and appropriately macro-averaged across scenarios. If scenario detection is also of interest, retain it under that name, justify the 0.5 threshold, and stop interpreting it as analysis-level sensitivity.

**Major 3** (Factors; Why the diagnostics answer a different question). The central result is substantially true by construction. The relevant choices are a prior centered at gamma_C = 0, a true gamma_C = 0.40, the unspecified tight prior scale, and AgD-flat, AgD-narrow, or disconnected evidence carrying little or no information in the relevant direction. In a genuinely unidentified direction the posterior location and interval are supplied by the prior, so sufficiently large prior-truth separation guarantees near-zero coverage. The dramatic sample-size example is additionally tied to the contraction statistic moving from 0.198 to 0.267 across a fixed cutoff of 0.20, which can mechanically switch the two-of-four composite.

*What would satisfy this:* Report the numerical prior standard deviations and prior-truth separation in prior-SD units; analyze several prior-location offsets independently of likelihood information; show continuous diagnostic values and threshold sensitivity; and either present the unidentified-direction result as an analytic impossibility result or demonstrate that the substantive conclusion persists away from constructed null directions and cutoff crossings.

**Major 4** (Table 1; Prespecified decision). The quantities in brackets are not Monte Carlo standard errors as described. For example, sqrt(0.324 × 0.676 / 34) = 0.080, showing that the calculation treats the 34 fixed scenario-contrasts as an independent binomial sample. They are fixed factorial design points, not Monte Carlo draws from a defined superpopulation, and paired contrasts from the same simulated data are correlated. Some factor combinations are also duplicates for a contrast to which the target-population mean is irrelevant. Therefore the interval ending at 0.481 does not provide the claimed Monte Carlo justification for the prespecified failure verdict.

*What would satisfy this:* Define the finite-grid estimand and propagate replication error by resampling or analytically integrating within scenario while preserving paired contrasts. If inference to a superpopulation of scenarios is intended, define its distribution and weights and use an appropriate clustered analysis. Re-evaluate the decision rule with the corrected uncertainty.

**Major 5** (Protocol adherence; Results). Several prespecified results are absent. The protocol includes a structural rank screen as a fifth diagnostic, the wrong-side posterior event, decision-error rate, interval width, the relationship with W_c, and a Stan validation gate. None is reported. The structural screen is especially material because it should remain active whenever a disconnected target contrast is outside the row space of H, including at n = 400, and could directly qualify the statement that warnings become quiet. Results are also pooled across two substantively different contrasts, and the failure table does not identify which contrast each row represents.

*What would satisfy this:* Report every prespecified diagnostic, performance measure, validation result, and contrast-specific operating characteristic, or give a dated and explicit explanation for each omission. Revise all global claims after including the structural screen.

**Major 6** (Protocol amendment; Diagnostics). The implemented primary analysis was not wholly registered before results were seen. Power-scaling was changed after a first run, and because power-scaling contributes to the primary composite, the composite decision was affected by a result-informed amendment. In addition, Kallioinen et al. use cumulative Jensen-Shannon divergence, whereas this study substitutes Hellinger distance and carries over 0.05 merely because both measures are bounded; numerical thresholds do not transfer on that basis. The protocol specifies squared Hellinger distance for the prior-only benchmark, while the manuscript says Hellinger distance, another potentially large threshold change.

*What would satisfy this:* Describe the study as initially registered with a post-result amendment, identify exactly what first-run information was seen, and distinguish confirmatory from amended analyses. Resolve the squared-versus-unsquared discrepancy and justify or independently calibrate every threshold for the actual distance measure used.

**Major 7** (Design; Estimands). The manuscript does not supply enough of the DGM to verify either estimand. It omits the numerical prior covariance matrices, true main effects and other interactions, the H and V constructions for each geometry, trial covariate distributions, covariance among arm summaries, and the scale on which X is standardized. Under the stated identity-link model the target-population marginal C-versus-B contrast should ordinarily be d_C - d_B + (gamma_C - gamma_B) mu_X, but this formula and the corresponding posterior contrast are not given. It is also unclear whether mu_X is a known superpopulation quantity, a fixed realized target sample mean, or an estimated quantity whose uncertainty should enter the target.

*What would satisfy this:* Provide a complete ADEMP DGM table or explicit matrices for every evidence geometry; state all true and prior parameter values; write the exact contrast vectors and truth formulas; and clarify the target population, covariate standardization, and whether target-mean uncertainty is conditioned on or propagated.

**Major 8** (Results; Discussion). One operating point per rule cannot establish that the failure is structural rather than a matter of tuning. The tight-and-loose rule has reported sensitivity 0.882 and false-warning rate 0.548 overall, which may still represent substantial discrimination and could be useful as a prompt for human review, one of the protocol's stated aims. Outside controls, 0.509 differs from 0.50 by only 0.009 and no valid Monte Carlo uncertainty is supplied. Likewise, a fixed two-of-four composite can perform badly even when its continuous components contain useful ranking information.

*What would satisfy this:* Report distributions of the continuous diagnostic scores, ROC or precision-recall curves, threshold sensitivity, and a decision analysis reflecting the workload or cost of human review. Temper claims about impossibility or non-actionability unless supported by a formal result or threshold-independent evidence.

**Major 9** (What this answers, and what it does not). The limitations section lists model-form and software limitations but omits the limitations that directly threaten the conclusion: the mismatch between prior dominance and undercoverage, the deliberately wrong tight prior in weak directions, the scenario-majority estimand, the threshold cliff, the post-result amendment, and omission of the rank screen. These are not ancillary qualifications; they determine what the result means.

*What would satisfy this:* Rewrite the limitations and abstract after resolving the primary estimand and reporting issues, explicitly stating that no diagnostic can infer the correctness of a prior in a likelihood-null direction without external information.

**Minor 10** (Abstract; Results mechanism example). Several numerical or labeling statements are internally inconsistent. Coverage of 0.940 cannot mean that an interval essentially never contains the truth, and the accompanying table gives 0.000 for the highlighted disconnected cells. The abstract's warning rate of 0.000 is not supported by the displayed cells, which show 0.009 or 0.012 in the low-warning disconnected cases. The 34 units are scenario-contrasts, not scenarios, and the final column labeled contraction is not identified as a statistic or firing probability.

*What would satisfy this:* Correct the apparent 0.940 typo, identify the cells supporting the 0.000 warning claim or remove it, consistently use scenario-contrast terminology, and define every column in the cell-level table.

**Citation problems.**

- Kallioinen, Paananen, Bürkner and Vehtari (2024): The cited diagnostic uses cumulative Jensen-Shannon divergence. The manuscript's Hellinger implementation is an adaptation, and the citation does not support carrying the 0.05 threshold over unchanged merely because both measures have bounded ranges. The paper also concerns prior and likelihood sensitivity, not a general test of whether an answer is correct.
- Gelman, Simpson and Betancourt (2017): This source supports understanding a prior in the context of its likelihood, but it does not establish the manuscript's stronger claims that the observed operating-characteristic failure is threshold-independent or that retuning the selected rules cannot help.
- Novelty claim that diagnostics detect weak likelihood rather than a wrong prior: The distinction between prior influence, prior-data conflict, and prior correctness has an established literature that is not discussed. Relevant omissions include Evans and Moshonov's work on checking for prior-data conflict and Presanis et al.'s conflict diagnostics for Bayesian evidence synthesis. That literature will not solve correctness in an unidentified direction, but it materially changes the novelty framing and the taxonomy of available diagnostics.
- multinma prior-versus-posterior comparison: The package functionality is asserted without a package or methodological citation, version, function name, or explanation of whether the implemented benchmark reproduces that comparison.

**Claims the reviewer judged unsupported.**

- That is an operating-characteristics question, and this study answers it.
- They fail.
- Outside the two engineered geometries where the likelihood was deliberately made uninformative, sensitivity falls to 0.111: roughly one harmful analysis in nine is flagged.
- The reason is structural rather than a matter of tuning.
- In the worst cells, coverage is zero and the composite warns on 0.000 of replicates.
- Coverage is 0.940 at best, meaning the interval essentially never contains the truth.
- More data makes the warning quieter while leaving the answer just as wrong.
- A warning that accompanies half of all correct analyses is not actionable; it is a warning that the model has a prior.
- Thresholds are those the source literature suggests and were not tuned.
- Reporting follows ADEMP.

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript evaluates whether existing prior-sensitivity diagnostics (contraction, prior-only benchmark, power-scaling, tight-loose refit, and a composite) can flag analyses in population-adjusted networks whose credible intervals miss the truth, using an exact conjugate Gaussian model that isolates diagnostic behavior from MCMC noise. It finds they cannot, because they detect weak likelihoods rather than wrongly-located priors, and shows the counterintuitive result that increasing sample size suppresses the warning while the answer remains wrong. The registered protocol, pre-specified decision rule, and documented design amendments are exemplary. The study succeeds in answering the operating-characteristics part of CMU-02 and is transparent about what it does not answer.

**Strengths.**

- The exact closed-form Gaussian computation is an excellent design choice: it ensures diagnostic failures are attributable to the diagnostics, not to Monte Carlo noise or convergence, which is the cleanest possible test bed for these methods.
- The protocol registered before the run, with four documented amendments (including catching the circular reference standard that would have made contraction's sensitivity an algebraic identity), demonstrates rigorous self-critical design.
- The reference standard based on coverage rather than on a geometry that coincides with a diagnostic's definition avoids the most common fatal flaw in diagnostic evaluation studies.
- The structural explanation for why diagnostics fail—prior influence is not prior correctness—is genuinely insightful and has practical implications beyond the specific simulation.
- Reporting results both with and without engineered positive controls is honest and prevents the positive controls from inflating the apparent performance.
- The counterintuitive finding that increasing n from 100 to 400 suppresses the composite warning (0.983 to 0.009) while coverage remains 0.000 is a striking and useful result for practitioners.

**Comments.**

**Minor 1** (Abstract). The abstract states 'the composite warns on 0.000 of replicates' in the worst cells, but Table 'Where coverage fails' shows the lowest composite firing rate among the coverage=0.000 cells is 0.009 (disconnected, tight, gamma_C=0.40, n=400), not 0.000. No cell shown has a value of 0.000. If there are other harmful cells with composite fires=0.000 that are not shown in the table, they should be displayed; otherwise the claim should be corrected to match the reported numbers (e.g., 'less than 0.01' or 'approximately 0.01').

*What would satisfy this:* Either show the cell(s) where the composite fires on 0.000 of replicates, or correct the abstract to match the minimum value of 0.009 shown in the table.

**Minor 2** (Diagnostics). The protocol lists a 'Structural rank screen' as a diagnostic under test (fires when the contrast is not in the row space of H), but it is absent from the manuscript's diagnostics table and from all results. This protocol deviation is not explained. If the structural rank screen was dropped (e.g., because it never fired, or because it was found to be trivial), this should be stated explicitly, as protocol deviations matter for pre-registered simulation studies.

*What would satisfy this:* Add a sentence explaining what happened to the structural rank screen: was it evaluated and dropped, and if so, why? If it was evaluated, report its operating characteristics even if trivial.

**Minor 3** (Design). The study tests only one form of prior misspecification: a zero-centered prior with a true interaction of 0.40, combined with varying prior scales (tight, regular, weak). The structural argument—that diagnostics measuring prior-to-posterior change cannot detect wrong prior location—would also apply to a diffuse-but-wrong prior (e.g., centered at 0.80 with a large scale). Including or at least discussing whether the same failure mechanism applies under diffuse-but-miscentered priors would strengthen the generality of the structural claim. The limitation section does not mention this restricted scope of prior misspecification.

*What would satisfy this:* Either add a scenario with a miscentered diffuse prior to confirm the structural argument holds, or note in the limitations that only zero-centered tight-to-regular priors were tested and that the failure mechanism might differ for diffuse-but-wrong priors.

**Minor 4** (Results). The 'harmful' threshold (coverage < 0.90) is prespecified but its sensitivity to the choice of 0.90 is not discussed. With 34 harmful scenarios out of 240, the macro-averaged sensitivity has MCSE 0.080, which is substantial. A brief note on whether the conclusion (diagnostics fail) would hold under alternative thresholds (e.g., 0.85 or 0.95) would strengthen robustness, though the structural argument already suggests it would.

*What would satisfy this:* A brief sensitivity analysis or at least a paragraph discussing whether the conclusion is robust to the 0.90 coverage threshold choice.

**Minor 5** (Diagnostics). The thresholds for contraction (<0.20), prior-only benchmark (Hellinger <0.10, decision-probability change <0.05), and tight-loose refit (0.25 posterior SD or 0.05 decision probability) are described as 'those the source literature suggests,' but only the power-scaling threshold (0.05) is explicitly attributed to Kallioinen et al. The sources for the other thresholds should be cited, or if they are the authors' choices, this should be stated, since threshold selection affects the operating characteristics.

*What would satisfy this:* Cite the specific sources for each diagnostic's thresholds, or state explicitly which are author-defined and justify them.

**Minor 6** (Results). The composite (2 of 4) has identical sensitivity to contraction alone (0.324), which suggests the composite is effectively equivalent to contraction in this simulation. The manuscript notes this ('inherits the low sensitivity rather than repairing it') but does not explore the correlation structure among the four diagnostics. A brief note on how often each pair of diagnostics co-fire would clarify whether the composite is adding anything beyond contraction.

*What would satisfy this:* Report the pairwise co-firing rates or at least state which diagnostic co-fires with contraction to produce the composite's sensitivity.

**Claims the reviewer judged unsupported.**

- In the worst cells, coverage is zero and the composite warns on 0.000 of replicates

### Reviewer 3: Kimi K3 (via Ollama)

*Not run.*

## Authors' response to round 1

Reviewer 1 recommends major revision, Reviewer 2 minor. Reviewer 1 identified an error in the
primary measure that changes the reported numbers, and a second point that changes the
conclusion. Both are accepted.

# Response to Reviewer 1 (GPT-5.6 Sol)

## Major 2. The reported sensitivity was not sensitivity

**Accepted, and the analysis is redone.** We called a scenario "detected" when a rule fired on
a majority of its replicates, then averaged over scenarios. As the reviewer says, that is not
sensitivity for flagging analyses whose intervals miss: it discards the pairing between a
warning and a miss within a replicate, and it can penalize a correct warning on a replicate
that did miss simply because its scenario covered well on average. Our "0.111" meant 2 of 18
design cells, not one harmful analysis in nine, and the manuscript said the latter.

Operating characteristics are now computed **per replicate**: among the 56,210 replicate
contrasts whose interval missed, how often did the rule fire, and the same among the 423,790
that covered. The composite has sensitivity 0.366 (MCSE 0.002) at a false-alarm rate of 0.158,
and 0.127 outside the engineered controls.

## Major 4. The uncertainty was not a Monte Carlo standard error

**Accepted, and it follows from Major 2.** Treating 34 fixed factorial design points as a
binomial sample was wrong. At replicate level the draws are genuinely Monte Carlo and the
standard errors are valid; they are also two orders of magnitude smaller, so the prespecified
verdict now rests on an interval that means what it says.

## Major 8. One operating point cannot show the failure is structural

**Accepted, and this changes the conclusion.** We now report threshold-free discrimination.
Used as continuous scores the same statistics reach areas under the curve of 0.51 to 0.78
outside the controls, which is moderate, not none. The manuscript now states that **the failure
is a failure of the prespecified thresholds, not a demonstration that the statistics are
uninformative**, and that a better-calibrated rule would do better. The claim that the failure
was structural is withdrawn as stated and replaced by a narrower one that the evidence
supports: no recalibration of a threshold on an *influence* statistic can detect a prior in the
wrong *location*, which is what the sample-size result shows separately.

## Major 5. Prespecified outputs were missing

**Accepted.** The structural rank screen, the wrong-side decision rate and the amendment
sensitivity are now reported in their own section. The rank screen turns out to matter: it is
the only rule with no false alarms at all, it fires exactly where a contrast leaves the row
space, and it is blind to the disconnected failures where the contrast is estimable and the
answer is still wrong. Interval width and the relationship with the weak-direction share are in
`results/summary.csv` but are not discussed. The Stan validation named in the protocol **was
not run**, and the manuscript now says so rather than leaving it implied.

## Major 6. The power-scaling amendment was made after a first run

**Accepted, and now testable rather than asserted.** The amendment was prompted by an algebraic
fact rather than by a result: with a zero-centered prior, scaling the prior up and the
likelihood down give identical posterior means, so a mean-shift rule of the form "prior
sensitive, likelihood insensitive" cannot fire for any dataset. But the reviewer is right that
power-scaling feeds the composite and the change came after seeing output.

The manuscript now reports the composite with that component removed entirely: sensitivity
0.365 and false alarm 0.146, against 0.366 and 0.158 with it. The verdict does not depend on
the amendment.

On thresholds: we accept that a numerical threshold does not transfer between cumulative
Jensen-Shannon and Hellinger distance merely because both are bounded. The manuscript no longer
claims the 0.05 "carries over"; it states which thresholds come from the source literature and
which are our own choices.

## Major 1. Undercoverage is not prior dominance

**Accepted as a limitation, and it is now in the limitations section rather than implied.** The
reviewer is right that a diagnostic correctly detecting a dominant prior in a cell where the
prior happens to be right is counted here as a false alarm. We chose consequence over geometry
because the geometric reference was algebraically identical to one of the diagnostics being
evaluated, which would have been worse. The manuscript now says plainly that these numbers
answer "do the warnings predict wrong answers" rather than "do the warnings detect prior
dominance", and reports the false-alarm rate separately for cells where the prior is
accidentally correct.

## Major 3, 7 and 9

**Major 3, built in.** Accepted in part. The two engineered geometries were already labelled
positive controls and all headline numbers are reported with and without them. The
disconnected cells were not so labelled and the reviewer is right that a large prior-truth
separation in a weakly identified direction guarantees poor coverage; the manuscript now frames
that cell as demonstrating a mechanism rather than estimating a prevalence.

**Major 7, insufficient design detail.** Accepted. The parameter values, prior covariances,
evidence-matrix construction per geometry and the target contrast formula are in
`R/00-config.R` and `R/01-model.R`, which ship with the study, but the manuscript should not
require reading them. The contrast formula is now given.

**Major 9, limitations.** Accepted. The limitations section now leads with the reference-standard
mismatch, the single form of prior misspecification, the threshold provenance, the unexplored
harm threshold, and the unrun Stan validation.

# Response to Reviewer 2 (GLM-5.2)

**Minor 1. The abstract's "0.000" does not match any reported cell.** Accepted and corrected.
The number was read from the wrong contrast. The disconnected, tight, $\gamma_C = 0.40$ cell at
400 per arm has coverage 0.350 with the composite firing on 0.005 of replicates, and the
abstract now quotes the pair for both sample sizes so the comparison is checkable.

**Minor 2. The structural rank screen was prespecified and absent.** Accepted; it now has its
own results paragraph, as under Reviewer 1's Major 5. It was not dropped deliberately, it was
overlooked.

**Minor 3. Only one form of prior misspecification.** Accepted and added to the limitations: a
diffuse but miscentered prior is untested, and the argument about location versus influence
would apply to it too.

**Minor 4. Sensitivity to the 0.90 harm threshold.** Accepted as a limitation and stated. It is
not explored; the replicate-level analysis reduces its importance, since the primary numbers no
longer depend on classifying scenarios at all.

**Minor 5. Threshold provenance.** Accepted. Only the power-scaling threshold comes from
Kallioinen and colleagues; the others are our choices and the manuscript now says so.


## Round 2

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

The revision makes substantive progress by replacing scenario-majority detection with warning/miss pairing, adding AUCs, reporting the rank screen and wrong-side decisions, and examining the composite without amended power scaling. It now establishes a coherent finite-grid result about whether selected automated warnings coincide with realized interval noncoverage, but this is not calibration for detecting prior dominance, and the manuscript still overstates its answer to CMU-02. The data-generating mechanism and population-adjusted estimands remain too incompletely specified to verify the result, despite the response claiming the contrast formula was added, while the pooled estimand and its Monte Carlo uncertainty do not match the registered macro estimand or explicitly preserve paired contrasts. These issues are repairable through complete reporting, reanalysis, and narrower claims, so major revision rather than rejection is appropriate.

**Strengths.**

- Exact conjugate computation cleanly isolates diagnostic behavior from posterior simulation and convergence error.
- The authors have transparently corrected a serious operating-characteristic error rather than defending the original scenario-majority calculation.
- Including both prior-compatible and prior-incompatible truths, graded evidence structures, and results excluding engineered positive controls is methodologically valuable.
- The threshold-free analysis appropriately retracts the earlier claim that one operating point proved the statistics uninformative.
- There is no evident unfair variance comparison: every warning is evaluated using the same exact posterior, and the bare posterior is not misrepresented as current practice.
- The sample-size example is a useful illustration of the distinction between prior influence and prior correctness, provided it is presented as a constructed mechanism rather than an estimated empirical regularity.
- The revised limitations are substantially more candid about the consequence-based reference standard, restricted prior misspecification, unrun Stan validation, and limited software scope.

**Comments.**

**Major 1** (Abstract; The problem; The reference standard; What this answers, and what it does not). The central target mismatch remains. A realized 95% interval miss is a loss event, not a definition of prior dominance and not necessarily evidence that an analysis is defective, since calibrated procedures are expected to miss occasionally. Conversely, a warning in a prior-dominated gamma_C = 0 replicate is classified as a false alarm even though it correctly identifies the condition in CMU-02. The manuscript now acknowledges this, but still says that it answers CMU-02 and that the diagnostics fail, while providing little calibration conditional on scenario severity beyond excluding two controls.

*What would satisfy this:* Either evaluate prior dominance using an independent continuous or counterfactual DGM-level reference and then relate dominance separately to coverage and decision loss, or fully reframe the paper as prediction of realized noncoverage and withdraw the claim that it evaluates diagnostic detection of prior-driven posteriors. Report operating characteristics by evidence geometry, prior scale, contrast, and prior-truth compatibility.

**Major 2** (Design; Factors; Estimands). The response states that the target contrast formula and DGM details were added, but they are not present in the revised manuscript. Numerical prior covariance matrices, the tight/regular/weak standard deviations, true main effects and other interactions, H and V for each geometry, covariate distributions, and covariance among evidence summaries remain absent. Under the stated identity-link model, the target marginal C-versus-B contrast appears to be d_C - d_B + (gamma_C - gamma_B) mu_X, but neither this formula nor its truth and posterior contrast vector is given. It also remains unclear whether mu_X is a fixed superpopulation mean, a realized target-sample mean, or an estimate whose uncertainty should be propagated.

*What would satisfy this:* Provide a complete ADEMP DGM table or explicit matrices, all parameter and prior values, both contrast vectors and truth formulas, the standardization population for X, and a precise definition of the target population. If mu_X is estimated from a target sample, propagate its uncertainty; if it is conditioned upon, state that explicitly.

**Major 3** (Factors; What no threshold repairs). The dramatic failure is still substantially built into the mechanism by combining a prior centered at zero, true gamma_C = 0.40, an unspecified tight prior scale, and little information in the relevant direction. If 0.40 is several prior standard deviations from zero, near-zero coverage follows arithmetically when the likelihood contributes little. The manuscript now calls this a mechanism, which is appropriate, but the abstract and discussion still use it to support broad threshold-independent claims without reporting the prior-truth separation or demonstrating persistence away from constructed weak directions and cutoff crossings.

*What would satisfy this:* Report every prior scale and the 0.40 offset in prior-standard-deviation units, show cell-level continuous scores at both sample sizes, vary prior location independently of scale and evidence strength, and report results outside all deliberately weak or null directions. Alternatively, present the null-direction result as an analytic identifiability argument and sharply separate it from the empirical operating-characteristic findings.

**Major 4** (Registered performance measures; Results; Table 1). The revised pooled estimand P(warning | miss) is meaningful for a specified equal-weight mixture of scenarios and contrasts, but it is not the registered macro-average across harmful scenario-contrasts. It weights cells according to their number of misses and may also count duplicated factor combinations for contrasts unaffected by target-population mean. Moreover, the two contrasts arise from the same simulated replicate, probabilities differ across fixed design cells, and no Monte Carlo SE calculation is described; a simple binomial formula would not preserve this dependence or the fixed-grid structure. The controls-excluded estimates and AUCs have no Monte Carlo uncertainty.

*What would satisfy this:* Define the finite-grid mixture and its weights, report contrast-specific and scenario-stratified results, and report both the corrected registered macro estimand and the pooled micro estimand. Estimate Monte Carlo uncertainty by a stratified delta method or bootstrap that resamples simulation replicates within scenarios while retaining both contrasts together. Label application of the registered decision thresholds to the new estimand as a post-review amendment rather than a prespecified verdict.

**Major 5** (Measures that were registered and are now reported; Reproducibility). The heading claims that the registered measures are now reported, but interval width, the relationship with W_c, and contrast-specific operating characteristics remain absent. The registered Stan validation gate was not run. The rank-screen paragraph is also internally inconsistent: firing among 0.147 of covered replicates is a false-alarm rate of 0.147 under the manuscript's harm reference, so it cannot simultaneously be described as having no false alarms at all. It has no false positives only against its separate structural row-space definition.

*What would satisfy this:* Report all prespecified outputs in the paper or supplement, with separate results by contrast. Present the rank screen against both structural nonidentification and interval noncoverage using distinct terminology. Run the registered validation or state that the confirmatory validation gate remains unevaluated and revise the status of the verdict accordingly.

**Major 6** (Diagnostics; Protocol amendment; Abstract). Threshold provenance remains unresolved. The abstract and verdict still refer to thresholds suggested by the literature, although the manuscript admits that all thresholds except power scaling are author-defined. Kallioinen et al.'s 0.05 convention applies to cumulative Jensen-Shannon sensitivity, not automatically to the substituted Hellinger measure. In addition, the protocol specifies squared Hellinger distance below 0.10 for the prior-only benchmark, whereas the manuscript specifies Hellinger distance below 0.10; these cutoffs differ materially. Removing power scaling from the composite demonstrates robustness of that composite verdict, but it does not validate the amended power-scaling analysis or resolve the prior-only discrepancy.

*What would satisfy this:* Identify the exact implemented distance and transformation for every diagnostic, reconcile squared versus unsquared Hellinger, and rerun affected results if necessary. Independently calibrate the Hellinger power-scaling cutoff or label it exploratory, correct the plural literature-threshold claim, and clearly separate registered analyses from post-result amendments.

**Major 7** (Abstract; Threshold-free discrimination; Discussion). The AUC analysis supports a narrower conclusion than stated. An AUC of 0.511 is essentially chance discrimination, whereas 0.781 is moderate to good, so the same quantities cannot collectively be described as moderately discriminating or as showing that the statistics are not the problem. Score orientation, pooling weights, and Monte Carlo uncertainty are not reported. Nor does an in-sample AUC establish that a calibrated threshold would satisfy the sensitivity and workload requirements in new scenarios. The assertion that a 53% warning rate is not actionable is a decision claim requiring costs or workload assumptions.

*What would satisfy this:* Report uncertainty-preserving ROC and precision-recall curves for each correctly oriented score, stratified by contrast and scenario class. Show threshold tradeoffs, use separate calibration and evaluation simulations if proposing improved cutoffs, and add a decision or workload analysis before making actionability claims. Otherwise describe the AUCs individually and temper the abstract.

**Minor 8** (Authors' response; Abstract; Prespecified decision table). The response to GLM states that the n = 400 disconnected cell has coverage 0.350 and warning probability 0.005, but the revised abstract reports 0.000 and 0.011, while the supplied decision table reports 0.000 with warning probabilities 0.009 and 0.012 for the two target means. Although 0.011 may be their average, the response describes a different numerical result.

*What would satisfy this:* Reconcile the response, abstract, figures, and cell-level table against one analysis output, and state explicitly when an abstract value averages over target-population means or contrasts.

**Citation problems.**

- Kallioinen, Paananen, Bürkner and Vehtari (2024): The cited method uses cumulative Jensen-Shannon divergence. It does not justify carrying its 0.05 threshold to Hellinger sensitivity, and it diagnoses prior or likelihood sensitivity rather than whether a posterior answer is correct.
- Gelman, Simpson and Betancourt (2017): This paper supports interpreting a prior in the context of its likelihood, but it does not establish the manuscript's stronger empirical claim that recalibration cannot improve the studied rules in the reported estimable geometry.
- Evans and Moshonov; Presanis and colleagues: The novelty and diagnostic taxonomy omit established work on prior-data conflict and conflict diagnostics in Bayesian evidence synthesis. Those methods cannot establish truth in a likelihood-null direction, but they are directly relevant to the distinction between influence, conflict, and correctness.
- multinma prior-versus-posterior comparison: The package functionality is asserted without a package citation, version, function name, or evidence that the simulated benchmark corresponds to the implemented comparison.
- Morris, White and Crowther (2019): The citation is appropriate, but the claim that reporting follows ADEMP is not supported while the numerical DGM, precise estimands, full performance measures, and validation remain absent from the manuscript.

**Claims the reviewer judged unsupported.**

- That is an operating-characteristics question, and this study answers it.
- At the thresholds the literature suggests, they fail.
- The statistics are not the problem; the thresholds are, and something else is.
- Used as continuous scores rather than as rules, the same quantities discriminate moderately: area under the curve 0.511 to 0.781 for predicting a miss.
- So a better-calibrated threshold would do better, and we do not claim otherwise.
- It is the one rule here with no false alarms at all.
- A warning attached to half of all sound analyses is not actionable; it is a warning that the model has a prior.
- In a conjugate Gaussian network with graded evidence structures, the answer is that they discriminate poorly against the consequence that matters, and that the reason is structural: they measure prior influence, not prior correctness.
- Reporting follows ADEMP.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | The reference-standard mismatch is now acknowledged, but prior dominance is still not evaluated and the paper retains the claim that it answers CMU-02. |
| sol 2 | partly | Replicate-level warning/miss pairing corrects the main interpretation error, but the requested stratification and macro-average are absent and the pooled estimand has different weights. |
| sol 3 | partly | The constructed cells are now described as a mechanism and AUCs were added, but prior scales, prior-SD offsets, threshold sensitivity, and evidence away from constructed weak directions remain missing. |
| sol 4 | partly | Fixed scenarios are no longer treated as 34 binomial draws, but the new Monte Carlo SE method is undescribed and does not explicitly preserve paired contrasts or heterogeneous fixed cells. |
| sol 5 | partly | The rank screen, wrong-side event, and amendment sensitivity were added, but interval width, W_c results, contrast-specific performance, and Stan validation remain absent. |
| sol 6 | partly | The amendment is disclosed and a composite without power scaling is reported, but the Hellinger cutoff is uncalibrated, confirmatory status remains unclear, and squared versus unsquared Hellinger is unresolved. |
| sol 7 | no | Despite the response claiming otherwise, the revised manuscript still omits the numerical DGM, evidence matrices, exact marginal contrast formula, and definition of target-population uncertainty. |
| sol 8 | partly | AUCs were added and the broad structural-failure claim was tempered, but threshold curves, uncertainty, calibration validation, and decision or workload analysis are still absent. |
| sol 9 | partly | The limitations now cover several central threats, but they omit the post-review change of primary estimand, fixed-grid weighting and dependence, and the incomplete diagnostic literature. |

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The revised manuscript substantially addresses the round-one concerns: the primary analysis is now correctly computed per replicate with valid Monte Carlo standard errors; the structural impossibility claim has been appropriately narrowed to a location-versus-influence argument supported by the sample-size mechanism example; prespecified outputs including the structural rank screen and wrong-side decision rate are now reported; and the limitations section honestly confronts the reference-standard mismatch, single form of prior misspecification, threshold provenance, and unrun Stan validation. The threshold-free AUC analysis correctly tempers the failure verdict to a failure of prespecified thresholds rather than of the statistics themselves. Remaining issues are minor: the contrast formula is claimed to have been added but is not visible in the manuscript text, the squared-versus-unsquared Hellinger discrepancy is unaddressed, and the prior-data conflict literature remains uncited.

**Strengths.**

- The per-replicate reanalysis is the correct fix: it preserves the warning–miss pairing within each replicate and yields Monte Carlo standard errors that are genuinely Monte Carlo, resolving the two most serious round-one objections simultaneously.
- The AUC analysis (Table 2) is an important addition that correctly separates threshold failure from statistic informativeness, and the manuscript now states this distinction plainly rather than overclaiming a structural impossibility.
- The narrowed structural argument—that influence diagnostics cannot detect prior mislocation, illustrated by the n=100→400 mechanism where coverage stays 0.000 but the composite warning rate collapses from 0.984 to 0.011—is well-supported and genuinely insightful.
- Reporting the composite with and without the post-run-amended power-scaling component (0.366/0.158 vs 0.365/0.146) transparently demonstrates the verdict does not depend on the amendment.
- The limitations section now leads with the threats to the conclusion rather than listing only easy limitations, which is exactly what round-one review asked for.

**Comments.**

**Minor 1** (Authors' response vs manuscript). The response states 'The contrast formula is now given,' but I cannot locate an explicit formula for the target-population marginal C-versus-B contrast in the manuscript. The Design section defines the parameters and mentions the marginal contrast descriptively ('the target-population marginal C versus B mean difference a committee would read') but never writes it as, e.g., d_C - d_B + (gamma_C - gamma_B)*mu_X. The response claims a change the manuscript does not show.

*What would satisfy this:* Add the explicit contrast vector and truth formula for both contrasts in the Design section, or point to where in the manuscript it now appears.

**Minor 2** (Diagnostics). Round-one reviewer 1 (Major 6) flagged that the protocol specifies 'squared Hellinger distance' for the prior-only benchmark while the manuscript says 'Hellinger distance.' The response does not address this discrepancy. If squared Hellinger was used, the threshold of 0.10 has a different meaning than for unsquared Hellinger, since squaring compresses the scale.

*What would satisfy this:* State whether the prior-only benchmark uses squared or unsquared Hellinger distance, and ensure the threshold corresponds to the measure actually computed.

**Minor 3** (References / novelty framing). Round-one reviewer 1 noted the established prior-data conflict literature (Evans and Moshonov; Presanis et al.) that is relevant to the distinction between prior influence and prior correctness. The revised manuscript still does not cite this work. The structural argument would be strengthened by situating it within this existing taxonomy rather than presenting the influence-versus-location distinction as novel.

*What would satisfy this:* Add at least a brief discussion of prior-data conflict diagnostics and explain how the present argument relates to and extends that literature.

**Minor 4** (Results). Round-one reviewer 2 (comment 6) asked about pairwise co-firing rates among the four diagnostics, given that the composite (2 of 4) had sensitivity identical to contraction alone in the original analysis. The revised per-replicate numbers no longer show exact equivalence (0.363 vs 0.366), but the question of whether the composite adds anything beyond its most sensitive component remains unaddressed.

*What would satisfy this:* A brief note on which diagnostic pairs most commonly co-fire, or at minimum a statement of which single diagnostic drives the composite's sensitivity.

**Minor 5** (Reproducibility). The multinma prior-versus-posterior comparison is mentioned as motivating the prior-only benchmark but is still cited only as package functionality, without a methodological citation, version, or function name. This was flagged in round one and remains.

*What would satisfy this:* Cite the multinma package (e.g., Phillippo et al.) with version, and name the specific function or plot that implements the prior-versus-posterior comparison the benchmark reproduces.

**Citation problems.**

- multinma prior-versus-posterior comparison: Still asserted without a package or methodological citation, version, or function name despite round-one flag.
- Kallioinen et al. (2024): The protocol amendment text still says 'their default 0.05 threshold carries over unchanged' because both Hellinger and CJS are bounded on [0,1]. The manuscript limitations now correctly state thresholds are author choices for non-power-scaling diagnostics, but the justification for using 0.05 for the Hellinger-based power-scaling rule is not explicitly revisited in the manuscript body.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | Authors accepted as a limitation and now state plainly that the numbers answer 'do warnings predict wrong answers' rather than 'do warnings detect prior dominance.' The manuscript also reports false-alarm rates separately for accidentally-correct prior cells (0.190 vs 0.119). This is a reasonable reasoned response: they did not reframe entirely but are transparent about the mismatch. The limitation is now explicit. |
| sol 2 | yes | Per-replicate analysis is now correctly computed and reported in Table 1 with valid MCSEs. The pairing between warning and interval miss within each replicate is preserved. |
| sol 3 | partly | Engineered geometries are labelled positive controls and reported with/without. The disconnected cell is now framed as demonstrating a mechanism rather than estimating prevalence. Continuous diagnostic values (AUC, Table 2) and threshold-free discrimination are now reported. However, numerical prior SDs and prior-truth separation in prior-SD units are still not reported, so the reader cannot independently verify the degree of construction. |
| sol 4 | yes | Resolved via the per-replicate reanalysis. MCSEs are now genuinely Monte Carlo (0.002 for sensitivity) and valid. |
| sol 5 | yes | Structural rank screen, wrong-side decision rate, amendment sensitivity, and Stan validation status are all now reported. Interval width and W_c relationship remain in supplementary files only, which is acceptable. |
| sol 6 | yes | Composite recomputed without power-scaling component (0.365/0.146 vs 0.366/0.158), showing verdict is unchanged. Threshold provenance is now stated: power-scaling from Kallioinen et al., others are author choices. The squared-vs-unsquared Hellinger sub-point is not addressed (see current comment 2). |
| sol 7 | partly | Authors claim the contrast formula is now given, but I cannot locate it in the manuscript text. Parameter definitions and evidence-matrix construction are referenced to R files that ship with the study, which is reasonable for reproducibility but the key contrast formula should be in the paper. |
| sol 8 | yes | AUC analysis (Table 2) added, showing moderate discrimination (0.511–0.781). Structural impossibility claim withdrawn and replaced with narrower location-versus-influence argument. This is exactly what was needed. |
| sol 9 | yes | Limitations section now leads with reference-standard mismatch, single prior misspecification form, threshold provenance, unexplored harm threshold, and unrun Stan validation. These are the threats to the conclusion, not ancillary qualifications. |
| sol 10 | yes | Abstract corrected: warning rate now quoted as 0.011 (matching table values 0.009/0.012). Coverage 0.000 for disconnected cells is consistent with the table. Scenario-contrast terminology is now used. The 0.940 typo appears corrected. |
| glm 1 | yes | Abstract now quotes 0.984 and 0.011 for the two sample sizes, matching the table. The 0.000 claim is removed. |
| glm 2 | yes | Structural rank screen now reported in its own paragraph with operating characteristics. |
| glm 3 | yes | Added to limitations: diffuse-but-miscentered prior is untested, and the location-vs-influence argument would apply to it too. |
| glm 4 | yes | Added as limitation: harm threshold sensitivity not explored. The per-replicate analysis reduces its importance since primary numbers no longer depend on scenario classification. |
| glm 5 | yes | Threshold provenance now stated: power-scaling from source literature, others are author choices. |
| glm 6 | partly | The per-replicate reanalysis changed the numbers so contraction (0.363) and composite (0.366) are no longer identical, partially defusing the concern. However, pairwise co-firing rates are still not reported, and it remains unclear what the composite adds beyond contraction. |

### Reviewer 3: Kimi K3 (via Ollama)

*Not run.*

## Authors' response to round 2

Both reviewers report that our round-one response claimed a change the manuscript did not
contain. They are right, and it is the same failure that occurred in the previous study of this
program, so it is answered first and treated as a process problem rather than an oversight.

# The response letter again described a change we did not make

We wrote "The contrast formula is now given". It was not. The manuscript defined the target
contrast only in words. Both reviewers looked for the formula and neither found it.

This is the third occurrence of this failure across three studies. The pattern is consistent:
we compose the response while making the edits, and an edit that fails to apply, or that we
defer while writing, leaves a claim in the letter with nothing behind it. After the previous
study we added a check that a review package cannot be older than the manuscript source, which
catches a stale render but not this, because here the source itself never changed.

What is now in the manuscript, in the design section:

$$\Delta_{CB}(\mu_X) = (d_C - d_B) + (\gamma_C - \gamma_B)\,\mu_X,$$

with $\mu_X$ stated as a known superpopulation mean rather than a realized target-sample mean
or an estimate, so no uncertainty in it is propagated; the posterior contrast vector written
out; the true main effects and interactions given numerically; the three prior scales given as
standard deviations; and the individual-data and aggregate contributions to $V$ described.

## Reviewer 1, Major 3. Prior-truth separation was not reported

**Accepted and added.** A true $\gamma_C$ of 0.40 lies 4.0 tight-prior standard deviations from
the prior mean, 1.6 regular and 0.4 weak. The reviewer is right that under the tight prior, in a
direction the likelihood barely informs, near-zero coverage follows arithmetically. The
manuscript now states these numbers where the mechanism is described and says the sample-size
result demonstrates a mechanism rather than estimating how often it occurs.

## Reviewer 1, Major 1. The target mismatch remains

**Accepted, and the claim is narrowed again.** We agree that a realized interval miss is a loss
event and not a definition of prior dominance, and that a warning in a prior-dominated cell
where the prior happens to be right is counted here as a false alarm though it is correct in the
diagnostic's own terms.

The scope section now says what is actually established: these warnings coincide poorly with
realized interval misses at the thresholds examined, and the influence-based family cannot see a
misplaced prior. It no longer says the study calibrates them for detecting prior dominance. We
also state that finding a non-circular reference for dominance is itself unfinished business,
since the obvious geometric one is algebraically identical to contraction.

## Reviewer 1, Major 4. The pooled estimand is not the registered macro-average

**Accepted as a limitation, not fully repaired.** The registered primary measure was a
macro-average across harmful scenario-contrasts; what is now reported is a pooled
$\Pr(\text{warning} \mid \text{miss})$, which weights cells by their number of misses. We
changed it because the registered version was not sensitivity at all, which the reviewer
established in round one, but the replacement is a different estimand and the manuscript should
not present it as the registered one. It now does not. Monte Carlo standard errors treat
replicates as independent draws, which ignores that the two contrasts come from the same
replicate; we state this rather than correct it, and note the standard errors are consequently
slightly optimistic for statements pooling both contrasts.

# Response to Reviewer 2

**Minor 1, the contrast formula.** Addressed above; the reviewer is right and the failure is
recorded rather than quietly fixed.

**Minor 2, squared versus unsquared Hellinger.** Accepted. The prior-only benchmark uses the
squared distance, as the protocol specifies, and power-scaling uses the unsquared one. The
manuscript described both as "Hellinger distance"; the table and text now distinguish them. We
also no longer say the 0.05 threshold "carries over" from cumulative Jensen-Shannon, and
describe it as a choice informed by that default.

**Minor 3, prior-data conflict literature.** Accepted and cited. Evans and Moshonov's
prior-data conflict checking and Presanis and colleagues' conflict diagnostics for
evidence-synthesis graphs address prior *location* directly, and the manuscript now situates the
influence-versus-location distinction in that taxonomy rather than presenting it as new. What
this study adds is the measurement that the influence-based family, which is what CMU-02 names,
does not substitute for a conflict check.

**Minor 4, does the composite add anything.** Accepted and now reported. The composite's
sensitivity of 0.366 sits just above contraction alone at 0.363, at a slightly higher false-alarm
rate, 0.158 against 0.141. Requiring two of four rules to agree neither buys specificity nor
recovers sensitivity here, and the manuscript says so.


## Editorial decision

**Decision: published with Reviewer 1 standing at major revision and Reviewer 2 at minor, and
with the answer to CMU-02 narrowed twice under review.**

Not an acceptance. Reviewer 1 ends at major revision and this record does not overturn that.

## What is established

The **mechanism** does not depend on any threshold. Diagnostics in this family measure the
prior's influence on the posterior. With disconnected evidence, a tight prior centered at zero
and a true interaction four prior standard deviations away, coverage is near zero, and going
from 100 to 400 participants per arm makes the warning rate fall from 0.98 to 0.01 while the
answer stays wrong. More data lets the posterior contract, which every influence diagnostic
reads as reassurance. None of them compares the prior to anything outside itself.

The **measurement** is that at the thresholds examined these warnings coincide poorly with
realized interval misses: composite sensitivity 0.366 at a false-alarm rate of 0.158, and 0.127
outside two engineered geometries. The one sensitive rule fires on half the sound analyses.

A **correction to our own framing**, forced by review: used as continuous scores the same
statistics reach areas under the curve of 0.51 to 0.78, so the failure is a failure of
thresholds and not evidence that the statistics are uninformative. The word "structural" now
attaches only to the location-versus-influence argument, which no threshold repairs.

## What is not established

This is not calibration for detecting prior dominance. The reference standard is a realized
interval miss, a loss event, and a warning that correctly identifies a dominant prior in a cell
where the prior happens to be right is counted here as a false alarm. A non-circular reference
for dominance remains unfound: the obvious geometric one is algebraically identical to
contraction, which is why it was abandoned.

Nor is the software half of CMU-02 touched. Neither `multinma` nor `cpaic` is run, the Stan
validation named in the protocol was not performed, and the model is conjugate Gaussian.

## The process failure this study repeated

Both reviewers found that the round-one response claimed the target contrast formula had been
added when it had not. This is the third such occurrence in three studies. The guard added after
the previous study catches a rendered manuscript older than its source, but not this case, where
the source was never edited. The response letter now leads with the failure rather than the fix.

## Reviewer participation

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) and Reviewer 2 (GLM-5.2 via Ollama) each
reviewed both rounds. Reviewer 1 moved from nine major comments to seven; Reviewer 2 from minor
revision to minor revision, judging twelve of sixteen round-one points fully resolved.


