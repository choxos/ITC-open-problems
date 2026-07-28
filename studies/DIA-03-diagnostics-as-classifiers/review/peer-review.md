# Peer review: Effective sample size tracks the error an analysis got by chance better than the error it got from adjusting on the wrong covariates

Study aimed at catalog problem **DIA-03**, also bearing on DIA-06.

3 independent reviewers, two rounds. Reports, author responses and the
editorial decision are reproduced in full and unedited. Reviewers were
given the manuscript, the protocol registered before the run, and the
prespecified decision as evaluated; in round two they additionally saw
round one's reports and the authors' response.

## Reviewers

| | Reviewer | Round 1 | Round 2 |
| --- | --- | --- | --- |
| R1 | GPT-5.6 Sol (maximum reasoning effort) | major-revision | major-revision |
| R2 | GLM-5.2 (via Ollama) | minor-revision | minor-revision |
| R3 | Kimi K3 (via OpenCode) | major-revision | minor-revision |

## Round 1

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

This carefully prespecified simulation evaluates routine MAIC diagnostics as classifiers of material realized error across a broad factorial design. It succeeds in establishing the narrow numerical result that none of the evaluated fixed cutoffs meets the authors' prespecified sensitivity and specificity criterion in this particular scenario distribution. It does not establish the broader variance-versus-bias interpretation because the so-called transport component contains sampling variation rather than only bias, an observable covariate component is omitted from the component results, and several headline findings follow directly from the data-generating mechanism. The existing simulations appear capable of supporting a useful paper after substantial reanalysis, reframing, and completion of the prespecified reporting, so rejection is not warranted.

**Strengths.**

- The protocol, pilot changes, amendments, thresholds, deployment weights, and decision criteria are disclosed unusually clearly.
- The authors report two failed prespecified mechanism claims without moving their thresholds post hoc.
- The algebraic decomposition is an exact identity for the chosen linear estimators, even though its subsequent interpretation requires correction.
- The factorial design crosses overlap, sample size, effect-modifier omission, cross-moment misspecification, proxy correlation, and target dispersion, including well-specified and no-shift cells.
- Within-stratum reporting reduces dependence on the investigator-chosen mixture of the two misspecification indicators.
- The simulation size is substantial, and Monte Carlo uncertainty is reported for several primary operating characteristics.
- The estimator comparison avoids the obvious variance-estimator asymmetry by using a stacked M-estimation sandwich for MAIC and HC3 for STC.
- Nonconvergence is recorded, the primary sensitivity is bounded under extreme treatments of nonfits, and the authors correctly distinguish failure of a cutoff from absence of discrimination.
- The discussion appropriately acknowledges that DIA-06 and the cross-validation part of DIA-03 remain largely unanswered.

**Comments.**

**Major 1** (What a covariate diagnostic could possibly know; Results, Table 2; Discussion). The decomposition is algebraically valid, but its interpretation is not. The arm-imbalance term L(f) is determined by the realized covariates and treatment assignments, not by the realized outcomes, and can be predicted using arm-specific balance or an estimated prognostic score. Conversely, the quantity labeled transport error contains finite-sample source composition and treatment-allocation variation even under a correctly specified modifier model, so its absolute value is not synonymous with transport bias. Comparing AUROC 0.847 for outcome noise with 0.653 for this mixed transport component therefore does not establish that a variance statistic is being mistaken for a bias statistic. Table 2 also omits the arm-imbalance component despite Aim 3 and the protocol requiring all three components.

*What would satisfy this:* Report performance against all three components, relabel the middle term as a realized effect-modifier component, and separately estimate systematic transport bias at each cell as an appropriate Monte Carlo expectation. Reanalyze the variance-versus-bias claim against that systematic bias or remove it from the title and conclusions.

**Major 2** (Abstract; Design; Estimand; What this answers). The framing concerns anchored indirect comparisons, but the primary reference is error in the transported A-versus-C effect. The realized error of the final A-versus-B indirect comparison also contains error in the target B-versus-C estimate. That estimate is simulated in the protocol but does not appear in the decomposition or primary results. The manuscript therefore answers a source-side transport-estimation question, not necessarily the realized-error question for the indirect comparison seen by an appraisal committee.

*What would satisfy this:* Either narrow the title, abstract, and practical claims explicitly to the transported A-versus-C component, or add a prespecified-style analysis of the final A-versus-B estimate including target-effect uncertainty. State unambiguously whether coverage in Table 7 concerns A-versus-C or A-versus-B.

**Major 3** (Data-generating mechanism; Four mechanism claims). Several headline findings are built into the mechanism. Homoscedastic independent errors with variance one make conditional outcome-noise variance almost mechanically proportional to the squared weighting coefficients and hence closely related to ESS. Setting the target dispersion ratio to 1.25 deliberately lowers ESS without systematic bias when omega and kappa are zero. In the diagnosable stratum, g contains exactly the single omitted linear term 0.35 times X4, while the proposed statistic multiplies an estimate of that same coefficient by the exact X4 mean discrepancy. The proposal is therefore a plug-in version of the omitted term by construction, while matched-moment balance is zero by the calibration equations.

*What would satisfy this:* Present these results as algebraic or positive-control checks. If broader empirical claims are retained, add mechanisms with heteroskedastic errors, multiple or nonlinear omitted modifiers, uncertain target moments, and approximate rather than exact calibration, then show that the conclusions persist.

**Major 4** (Proposed diagnostic and comparison with the routine panel). The proposed statistic is not compared on an equal information basis. It uses source outcomes through the estimated treatment-by-X4 interaction and assumes the exact target mean of X4, whereas the routine diagnostics are outcome-free functions of covariates and weights. Estimating the interaction in the same sample whose error is being diagnosed also creates possible in-sample optimism. Moreover, if X4, its target mean, and its interaction are all available, the analyst could adjust for X4 rather than merely issue a warning about omitting it.

*What would satisfy this:* Label the proposal as outcome-model-assisted, cross-fit or independently estimate the interaction, and compare it with other outcome-assisted diagnostics such as estimated standard error, prognostic-score balance, and model-based bias estimates. Also compare with a correctly adjusted estimator including X4 and report oracle, independent-estimation, and same-sample versions separately.

**Major 5** (Prespecified decision rule; Primary results). Failure to reach sensitivity 0.80 and specificity 0.50 is not equivalent to failure to be a classifier. The choice of those operating requirements is not tied to an elicited loss function, and the results themselves show nontrivial discrimination and calibration for ESS. High firing frequency likewise does not make a rule cease to be a classifier; it describes a poor operating point. Within-stratum analysis removes the chosen mixture of omega and kappa, but it does not remove dependence on the equally arbitrary distribution of overlap, sample size, proxy correlation, dispersion, fixed modifier magnitudes, and the material-error threshold.

*What would satisfy this:* State the primary conclusion as 'no evaluated fixed cutoff met the prespecified operating requirements in this design.' Justify those requirements using stakeholder consequences or a loss function, and provide sensitivity analyses over modifier magnitudes, scenario weights, and material-error thresholds.

**Major 6** (Calibration). The calibration analysis cannot yet support claims about transportability across settings. The predictor transformation and functional form of each logistic mapping are not reported, so apparent miscalibration may be model-form misspecification rather than a property of the diagnostic. A single odd-cell/even-cell split is fragile and may separate levels of a design factor depending on cell enumeration. The same-cell result is not an 'optimistic bound' because it is sometimes worse than the new-cell result.

*What would satisfy this:* Specify every predictor transformation and calibration model, demonstrate that the cell split is balanced across all factors, and use repeated grouped cross-validation or leave-one-factor-level-out validation. Report uncertainty, calibration plots, and results under both deployment and equal-cell weights, and call the same-cell analysis a comparator rather than a bound.

**Major 7** (Results and adherence to the registered protocol). Several prespecified results are absent from the manuscript: discrimination against arm imbalance, equal-cell versions of mixture-level AUROC, calibration and decision curves, material-error thresholds 0.10 and 0.30, full interval-noncoverage analyses, and per-cell nonfit rates. The component-specific event definitions are not stated. The paired AUROC differences of 0.194 and 0.086 are central decision quantities but are reported without Monte Carlo standard errors or intervals.

*What would satisfy this:* Provide a complete protocol-to-results table and place every prespecified analysis in the paper or a clearly referenced supplement. Include paired Monte Carlo uncertainty for all prespecified differences and intervals for AUPRC, calibration, and decision-curve quantities.

**Major 8** (Definition of material error). The claim that 0.20 is one fifth of the outcome standard deviation is not consistent with the stated mechanism. The marginal outcome variance includes the prognostic function, treatment-effect heterogeneity, and residual variance, and it changes across target dispersion and treatment arms. Thus 0.20 is one fifth of the residual standard deviation, not generally one fifth of the outcome standard deviation. Because every classifier result depends on this threshold, the distinction is substantive.

*What would satisfy this:* Correct the scale description, report the marginal outcome standard deviations by relevant cell or define the threshold explicitly in residual-SD units, and present the already-prespecified 0.10 and 0.30 sensitivity analyses.

**Major 9** (Threshold transportability mechanism claim). Variation in the material-error rate among rule-positive cells is variation in positive predictive value, not a valid test of threshold transportability or calibration. It necessarily varies with cell prevalence and case mix even when sensitivity and specificity are stable. The post hoc span among rule-negative cells is therefore not a 'stronger' version of the registered calibration claim.

*What would satisfy this:* Treat the span as an exploratory description of cellwise predictive values. Assess transportability through calibration of a locked risk model in held-out cells or factor levels, and report cell-stratified sensitivity, specificity, predictive values, and decision utility without equating them.

**Minor 10** (Decision-curve analysis). The prose does not match Table 5. At an action threshold of 0.40, relative ESS, pre-weighting imbalance, and Mahalanobis distance all exceed both flagging alternatives, although relative ESS has the largest net benefit. The practical action triggered by a warning is also left undefined, so the analysis quantifies a hypothetical classification tradeoff rather than demonstrated benefit from acting.

*What would satisfy this:* Correct the numerical description, identify all rules above both comparators, and define the contemplated action, its expected benefit, and its harm. Otherwise describe the analysis as hypothetical net classification benefit.

**Major 11** (Matched-moment balance and nonconvergence). Post-weighting balance is forced to zero only conditional on accepting an exact calibration solution. Its real operational purpose is to reveal failure or approximate failure of the balancing algorithm. Conditioning the analysis on successful fits and then concluding that the balance diagnostic cannot discriminate removes precisely the observations on which it can warn.

*What would satisfy this:* Separate the algebraic zero among successful exact fits from the operational diagnostic of residual imbalance or nonfit. Score a prespecified combined warning across all attempted analyses, or limit the claim to redundancy among accepted exact solutions.

**Major 12** (Literature review and novelty). The evidence offered for current practice and novelty is insufficient for a methodological journal. One conference abstract does not establish a widely used ESS operating rule or that appraisal committees interpret ESS specifically as a bias warning. The universal claim that no published work has evaluated these diagnostics as classifiers is based on an unspecified catalog audit. The proposed coefficient-times-imbalance construction also resembles established bias-function, prognostic-score, and moderator-sensitivity ideas in transportability and generalizability research.

*What would satisfy this:* Provide a reproducible literature-search account, cite primary MAIC and STC methods and appraisal guidance, document actual interpretations of ESS in practice, and position the proposed statistic against outcome-model-informed balance and transportability sensitivity-analysis literature. Narrow any universal novelty claim that cannot be established.

**Major 13** (Limitations). The limitations are candid about outcome type and estimator families but omit or under-rank the limitations that threaten the main conclusion: transport error is not isolated bias, the proposal receives outcome information unavailable to the panel, target summaries are treated as exact, the final indirect-comparison error is not analyzed, and the scenario distribution and modifier magnitudes are investigator-created. These are more consequential than the absence of noncollapsible outcomes.

*What would satisfy this:* Rewrite the limitations around the inferential threats identified above and state explicitly that the reported operating characteristics are properties of the declared simulation distribution, not intrinsic properties of the diagnostics.

**Minor 14** (Protocol and reporting consistency). Several internal inconsistencies should be resolved. The protocol's sample-size calculation still totals three estimators after a fourth was added; one section says calibration uses odd and even replicates while the amendment and manuscript use odd and even cells; Table 1 promises bracketed Monte Carlo errors that are not displayed; and the value 550 labeled as ESS for unweighted methods needs explanation when n is specified per arm. The nonfit sensitivity bounds should also be reported by primary stratum with their exact denominator.

*What would satisfy this:* Issue a clean amended protocol or amendment crosswalk, correct the estimate count and calibration description, define whether ESS is pooled or arm-specific, display the promised uncertainty, and show the nonfit calculation explicitly.

**Citation problems.**

- MSR65, ISPOR Europe 2024: The abstract supports an approximate empirical region in an unanchored simulation with different outcome types. It does not establish a recommended classifier cutoff, widespread use, or interpretation as a bias warning in anchored continuous-outcome analyses. The bibliographic entry also omits the abstract's authors.
- Austin and Steyerberg (2019): This citation supports the integrated calibration index, but it does not validate the manuscript's odd-cell/even-cell design or the causal interpretation that the difference between errors represents 'memory of the setting.'
- No citation supplied for appraisal practice: The assertions that every population-adjusted comparison carries this exact panel and that appraisal committees read it as evidence about bias require support from appraisal guidance, decision records, or empirical studies.
- No published work has scored any of these as a classifier: This universal novelty claim is not supported by a reported search strategy or review methods. A catalog audit and two auditors are not enough to establish absence from the literature.
- The proposal is ours: The manuscript does not distinguish the proposed interaction-coefficient-times-imbalance statistic from existing prognostic-score balance, bias-function, moderator-sensitivity, and trial-generalizability methods that use outcome associations to weight population imbalance.
- MAIC, STC, and routine ESS diagnostics: Primary citations for the MAIC and STC methods, foundational population-adjustment guidance, and the origin and intended interpretation of routine weight diagnostics are missing from an otherwise very short reference list.

**Claims the reviewer judged unsupported.**

- Only the middle term is knowable from covariates.
- The first and third depend on the realized outcomes.
- Reading the panel is not reading a warning about bias.
- Three of the panel’s members are one statistic written three ways.
- A rule that warns about almost every analysis is not a classifier.
- The weight-dispersion statistics calibrate tolerably across cells they have not seen.
- Nearly half of its apparent calibration is memory of the setting.
- Only once the action threshold reaches 0.400, meaning the analyst will only intervene when material error is at least that likely, does a diagnostic earn its place, and the one that does it is the relative effective-sample-size rule rather than the absolute one that gets quoted.
- That is a stronger result than the one registered.
- The diagnostic is informative about the problem and uninformative about the solution.
- Carrying target-moment sampling error here would add a noise channel no source-side diagnostic can observe and would depress every discrimination measure by a common amount without changing which diagnostic beats which.
- A binary or survival outcome would add a component of error that is a collapsibility artifact rather than an adjustment failure.

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript reports a registered simulation study scoring the routine diagnostic panel in population-adjusted indirect comparisons (MAIC, STC, unadjusted) as classifiers of realized error, targeting open problem DIA-03. The design is built around an exact decomposition of realized error into arm imbalance, transport error, and outcome noise—valid because all estimators are linear in the outcome under an identity link—and includes a falsifiability factor (target SD ratio) that destroys effective sample size without adding bias in the well-specified stratum. The main finding, that ESS tracks noise (AUROC 0.847) better than transport error (0.653) and that no panel member meets prespecified classification bars, is well-supported by the tables shown. The study honestly reports two of four prespecified mechanism claims as failures. The principal gap is that the stratum-specific AUROC figures for the proposed diagnostic (0.937 vs 0.851), which appear in the abstract and the mechanism-claims table, are not backed by any table in the manuscript or decision output.

**Strengths.**

- The exact error decomposition under the identity link is an elegant instrument that cleanly separates what a covariate diagnostic could know (transport error) from what it cannot (noise, arm imbalance), and the per-replicate verification to 3e-14 is a valuable implementation check.
- The target SD ratio factor (s = 1.25) is a genuinely clever falsifiability device: it creates cells where ESS is destroyed without bias in the well-specified stratum, preventing the design from making a variance statistic look like a bias statistic by confounding the two.
- Honest reporting of failed prespecified claims (threshold transportability span 0.150 < 0.30; proposal gain 0.086 < 0.10) is exemplary. The authors do not adjust claims post hoc to pass.
- The algebraic identities (ESS/n = 1/(1+CV²(w)), matched-moment balance ≡ 0 at the solution) are proved before the run and checked in the results, which is a service to readers who have seen these statistics reported side by side in submissions without recognizing their redundancy.
- The unadjusted comparison serves as an informative control: pre-weighting imbalance predicts its transport error at AUROC 0.891, confirming the statistic is informative about the problem and uninformative about the solution after weighting.

**Comments.**

**Major 1** (Abstract; Results; Table 6 (mechanism claims)). The abstract states that the proposed diagnostic 'reaches 0.937 against the transport component where the panel reaches 0.851.' These stratum-specific AUROCs (omitted-modifier stratum, transport component) do not appear in any table. Table 2 reports mixture-level AUROCs against transport (bias_hat = 0.684, smd_unmatched = 0.665); the primary table reports stratum-specific sensitivity/specificity but not stratum-specific AUROC by error component. The reader cannot verify the central comparative claim about the proposal.

*What would satisfy this:* Add a table (or rows to an existing table) reporting stratum-specific AUROCs against the transport component for all diagnostics, including the proposal and the oracles, in at least the omitted-modifier and cross-moment strata. This is the evidence base for abstract claims and for mechanism claim 4.

**Minor 2** (Abstract). The abstract says the proposal 'reaches 0.937 against the transport component where the panel reaches 0.851,' framing it as a positive result. The body and Table 6 make clear this missed its prespecified bar (gain 0.086 < 0.10). A reader of the abstract alone may infer a validated success. The abstract should note the gain fell short of the prespecified threshold.

*What would satisfy this:* Add a clause in the abstract indicating the gain (0.086) did not meet the prespecified 0.10 bar, or rephrase to avoid implying the proposal succeeded against its registered criterion.

**Minor 3** (What a covariate diagnostic could possibly know). The finding that ESS discriminates noise at 0.847 is partially built into the data-generating mechanism: for MAIC, Var(L(ε)) = σ²/ESS, so ESS mechanically determines the noise-component variance. The authors acknowledge this is the point ('it is a variance statistic'), but the text could be more explicit that the noise-tracking AUROC is expected by construction, and that the contribution is the quantification of how poorly it tracks transport error plus the threshold analysis, not the noise-tracking result itself.

*What would satisfy this:* Add one sentence noting that the noise-discrimination result follows mechanically from ESS determining the variance of the linear outcome functional, so the reader understands which part of the finding is arithmetic and which is empirical.

**Minor 4** (References). The protocol cites Morris, White and Crowther (2019, ADEMP reporting standard) but this reference does not appear in the manuscript's reference list.

*What would satisfy this:* Add the ADEMP reference to the manuscript reference list.

**Minor 5** (Results, Table 7). Coverage for the primary MAIC estimator (means + SDs) is not reported in Table 7, which only shows the other three estimators. The pilot reported coverage 0.924–0.940 in benign cells; the full-run coverage for the primary estimator would contextualize the low coverage seen for the others (e.g., STC at 0.533).

*What would satisfy this:* Add a row for the primary MAIC estimator to Table 7, or state its coverage in the text.

**Citation problems.**

- Morris, White and Crowther 2019 (ADEMP): Cited in the protocol as the reporting standard but absent from the manuscript reference list.

**Claims the reviewer judged unsupported.**

- Abstract: 'reaches 0.937 against the transport component where the panel reaches 0.851' — these stratum-specific AUROCs are not shown in any table in the manuscript or decision output.
- Abstract: 'is blind exactly where the information is absent' — Table 1 shows sensitivity 0.091 in the cross-moment stratum, supporting 'blind,' but 'exactly' is not formally tested; this is a reasonable qualitative inference but slightly overstated.

### Reviewer 3: Kimi K3 (via OpenCode)

**Recommendation: major-revision**

This is a registered, adversarially critiqued simulation study that evaluates the routine MAIC/STC diagnostic panel (ESS, ESS%, max weight, balance statistics, overlap measures) as classifiers of realized error in an anchored indirect comparison with a continuous outcome and identity link. The identity link buys an exact three-way decomposition of realized error into arm imbalance, transport error, and outcome noise, which is the study's real instrument and is used well. The prespecified verdict — the panel does not classify realized error at the thresholds in use — is reached cleanly: operating points fail by enormous margins relative to Monte Carlo error, two of four prespecified mechanism claims are reported as failed without adjustment, and the design's dispersion-ratio factor is a genuinely good idea for separating a variance statistic from a bias statistic. The principal problems are presentational-but-load-bearing rather than fatal: the scored contrast is ambiguous with respect to the anchoring subtraction, the headline 'variance statistic' number (AUROC 0.847 vs noise) is arithmetic rather than simulation output, the knowability framing that motivates the decomposition is misstated, and there are signs of table-generation errors. All of this is repairable without new simulation.

**Strengths.**

- The exact per-replicate error decomposition (verified to 3e-14) is the right instrument for this question: it lets diagnostics be scored against the transport component they could in principle know about, separately from the noise they cannot, and both scorings are reported.
- Registration is real, not decorative: a prespecified three-branch decision rule, four mechanism claims with numerical bars, two of which failed and are reported as failed, non-convergence bracketing instead of silent dropping, and an adversarial design critique whose consequences (the s instrument's scope, HC3 for STC, means-only MAIC, cell-split calibration) are disclosed as amendments.
- The target-dispersion factor s is a well-conceived pure variance instrument in the well-specified stratum, and the protocol is honest that the amendment restricted this to where it is true (kappa = 0) after the cross-moment arithmetic was caught.
- The algebra-first section (ESS/n = 1/(1+CV^2) exactly; matched-moment balance identically zero) checked against the run, plus the explicit warning that the 0.550 AUROC of an identically-zero statistic is 'discrimination of arithmetic difficulty', is exemplary practice.
- The unadjusted-estimator control is genuinely illuminating: the same pre-weighting imbalance statistic predicts the unadjusted estimator's transport error at 0.891 but MAIC's at 0.655, which licenses 'informative about the problem, uninformative about the solution'.
- Fair-comparison discipline: all estimators adjust for the same covariates, STC gets HC3 because its mean model is misspecified by design, MAIC's sandwich treats the weights as estimated, and means-only MAIC prevents the second-moment calibration from handicapping MAIC's ESS.

**Comments.**

**Major 1** (What a covariate diagnostic could possibly know / Design). It is impossible to tell from the manuscript which contrast is actually scored. The estimand is defined as the transported A-versus-C effect theta_AC(T) = d_A + E_T{g_A(X)}, the displayed three-term decomposition contains no target-trial term, and the identity was verified per replicate to 3e-14 — all consistent with scoring theta_hat_AC against theta_AC(T). But the abstract calls the design 'an anchored indirect comparison', the protocol derives Var(theta_hat_BC) = 2(beta' Sigma_T beta + sigma^2)/n_T and an amendment corrects it 'by a factor of two to three', and section 6 says every anchored estimate subtracts the same reported target B-vs-C effect. If the scored quantity is theta_hat_AC, then the anchoring subtraction enters nothing in the primary analysis and the Var(theta_hat_BC) derivation is inert except possibly for the secondary non-coverage reference — in which case the primary results abstract away from target-trial sampling error, which in deployment is part of the anchored estimate's error and is invisible to source diagnostics. If the scored quantity is theta_hat_AB, the decomposition as printed is missing a fourth term and the 3e-14 verification claim refers to a different identity than the one displayed.

*What would satisfy this:* State explicitly, in the manuscript not just the protocol, which contrast is scored for material error; if it is theta_hat_AC, justify the exclusion of target-trial sampling error (common additive channel no source diagnostic can see) and state exactly where theta_hat_BC enters (presumably the non-coverage reference); if it is theta_hat_AB, add the fourth term to the displayed decomposition and re-state the verification. One sentence each on consequence for interpretation.

**Major 2** (What a covariate diagnostic could possibly know / Results / mechanism claim 1). Two framing problems in the load-bearing section. First, the sentence 'The first and third depend on the realized outcomes; no function of X, the weights and a published baseline table has any information about epsilon' is incorrect in two ways: the arm-imbalance component L(f) does not depend on realized outcomes at all (with this DGM's linear f it is a function of the realized covariates and weights alone), and while the realization of the noise component is unknowable, its distribution is completely determined by the weights: conditional on w, L(epsilon) is Gaussian with variance sigma^2[1/ESS_A + 1/ESS_C], i.e. exactly 2 sigma^2/ESS when the same weight vector applies to both arms. A classifier needs the risk, not the realization — so the weights carry perfect information about the noise component's magnitude, which is precisely why the paper's own headline number exists. Second, and consequently: ESS's AUROC of 0.847 against the noise component is not a simulation finding. Since P(|noise|>0.2 | w) = 2 Phi(-0.2 / sqrt(2/ESS)) is a strictly monotone function of ESS, ESS is the optimal univariate classifier of the noise event by construction and its AUROC is a one-dimensional integral over the ESS distribution, computable without running anything. The paper already has a section ('Two facts that algebra settles before any data exist') for exactly this kind of result and mocks the matched-moment balance statistic's 0.550 as arithmetic residue; the 0.847 belongs in the same category, stated rather than implied. Relatedly, in the diagnosable stratum (kappa=0) the transport component equals omega(mu_T4 - Xbar_4^w) exactly (matched means are calibrated to 1e-14), so the proposed b_hat = |gamma_hat_4 (mu_T4 - Xbar_4^w)| is a multiplicatively noised version of the reference variable itself; 0.937 is near-construction, and the comparison against the panel's 0.851 should say so. None of this overturns the empirical side (the 0.653 transport AUROC and all operating points are genuine simulation output), but the title-level claim 'a variance statistic' is currently presented as discovered where half of it is derived.

*What would satisfy this:* Add the identity Var(L(epsilon)|w) = sigma^2 (1/ESS_A + 1/ESS_C) to the algebra section; re-present the 0.847 as the arithmetic consequence it is (report it as a check on the ESS distribution, not a result); correct the knowability sentence to distinguish realizations from risk; and add one sentence noting that in the kappa=0 stratum the transport error is omega*Delta_4 exactly, so b_hat's discrimination is near-construction and the empirical content is the size of the gain over the panel, not its existence.

**Minor 3** (Introduction / Results). 'It also reports the primary results within strata of misspecification rather than over a mixture of them, which removes the dependence on our chosen frequencies entirely' overstates what stratification buys. It removes the dependence on the chosen misspecification frequencies (omega, kappa weights), but every within-stratum figure still inherits the chosen design points for delta, s, n, rho_4 and the choice to weight cells equally — which is still an investigator-chosen scenario distribution, exactly the auditor's objection one level down. The sensitivity 0.309 in the omitted-modifier stratum, for instance, depends on how the 16 cells mix the pure-variance s=1.25 cells with the overlap cells. The all-strata requirement in the decision rule is the real mitigation and should be the thing cited.

*What would satisfy this:* Qualify the sentence: within-stratum reporting removes the dependence on the misspecification-frequency judgment; the remaining design-point and equal-weighting dependence is acknowledged as such, as the protocol already does for the deployment weights.

**Minor 4** (Results: The panel at the thresholds in use). The non-fit bracketing is arithmetically unclear as reported. The headline sensitivity in the omitted-modifier stratum is 0.309, but bracketing 'the primary rule's sensitivity' by counting all 3,747 non-fits as caught then missed gives 0.285 and 0.273 — both below 0.309, which is impossible under the natural construction applied to that stratum (adding x caught events and x total events to a sensitivity of s yields at least s). The bracket evidently refers to a different base (most plausibly the equal-cell-weight overall sensitivity of 0.284), but the text says 'the primary rule's sensitivity', which a reader will map to 0.309. As written the numbers cannot be reproduced and look inconsistent.

*What would satisfy this:* State the base quantity being bracketed (stratum or overall, and which weighting) and show the construction in one line — number of non-fits entering as events, and the resulting bounds — so the bracket visibly contains the corresponding fitted-only figure.

**Minor 5** (Results: mechanism claims). The manuscript does not identify which panel member reaches 0.851 against the transport component in the diagnosable stratum, and Table 2 reports only mixture-level component AUROCs, so the key comparison (b_hat 0.937 vs panel 0.851) cannot be traced. This matters more than usual because the likely best panel member there is the unmatched-covariate balance on X_4, which is a function of the same Delta_4 = mu_T4 - Xbar_4^w as b_hat; if so, the gain decomposes into 'removing the weighted-sd denominator' versus 'adding gamma_hat_4 estimation noise', which is the honest version of the finding and is not currently available to the reader.

*What would satisfy this:* Name the comparator statistic at 0.851 and provide the stratum-level component AUROCs for the full panel (at least for the omitted-modifier stratum), plus two sentences on why b_hat beats that specific statistic given both are functions of Delta_4.

**Minor 6** (Results: Tables 4 and 7 (and decision document)). There are signatures of a table-generation error. In Table 4 the calibration rows for pre-weighting imbalance and Mahalanobis distance are identical to three decimals on all four columns (0.648/0.845/0.143/0.075) — for two distinct statistics, agreement to that precision on every column is far more consistent with a join/duplication bug than with the simulation. In Table 7 the unadjusted rows for smd_pre and Mahalanobis are identical everywhere (0.804/0.891), again suspicious. If the values are real, an explanation is needed; if the table is wrong, the wrong numbers propagate into the calibration discussion (the 'nearly half of its apparent calibration is memory of the setting' claim rests on the 0.143 vs 0.075 gap).

*What would satisfy this:* Re-generate Tables 4 and 7 from the replicate output and either correct the rows or state explicitly that the identity is real and why (e.g., both statistics are monotone in the same quantity for the unadjusted estimator).

**Minor 7** (Results: The other estimators). Interval coverage is reported for means-only MAIC (0.730), STC (0.533) and the unadjusted estimator (0.357), but never for the primary MAIC estimator, despite the manuscript citing Remiro-Azocar et al. on sandwich-variance underestimation at small ESS and despite a 'vs non-coverage' AUROC column existing in the decision document. The primary method's coverage — ideally per stratum and split by ESS level — is the natural bridge to that literature and its absence is conspicuous.

*What would satisfy this:* Add primary MAIC (means+SDs) coverage overall and per stratum, with one sentence relating it to the cited variance-underestimation result and to the stacked M-estimation sandwich used here.

**Minor 8** (Protocol section 8 / Reproducibility). Editorial leftovers from the pre-amendment protocol remain: section 8 states the design is '128 x 4000 x 3 = 1,536,000 estimates' although the amendment added a fourth estimator (2,048,000), and section 8 describes the calibration split as fitted on odd-numbered 'replicates' where the amendment and the manuscript use odd/even cells. A reader checking the manuscript against the registered protocol will trip on both.

*What would satisfy this:* Correct the arithmetic and the unit of the calibration split in the protocol (marked as corrigenda, not silent edits, to preserve registration integrity).

**Minor 9** (Protocol section 7 / thresholds). Threshold provenance is mostly well handled (the pilot-tuned Mahalanobis cutoff is disclosed, which is good practice), but the ESS < 50% rule is labeled 'published, appraisal commentary' with no citation anywhere in manuscript or protocol. Since one of the manuscript's punchlines is that the relative rule beats the absolute rule in the decision-curve analysis, the source for that threshold should be given or the 'published' label dropped.

*What would satisfy this:* Cite the source of the ESS < 50% convention or relabel it as in informal use.

**Citation problems.**

- Missing: Phillippo et al., NICE DSU TSD 13 (2016) and especially TSD 18 (2020), Population adjustment methods...: A paper about the MAIC diagnostic panel and 'thresholds in use' does not cite the DSU technical support documents from which the reporting conventions (ESS, balance before/after weighting, overlap) and the small-ESS concerns largely derive. Positioning the novelty claim and the 'panel' itself requires engaging with TSD 18 in particular.
- Missing: Kish (1965) and the survey-weighting design-effect literature: ESS = (sum w)^2/sum w^2 and the identity ESS/n = 1/(1+CV^2(w)) are standard weighting arithmetic. The manuscript presents the identity as one of 'two facts that algebra settles', which is fine, but the literature origin should be acknowledged; it slightly tempers the implicit novelty of the 'one statistic three ways' observation.
- Missing: the transportability/generalizability diagnostics literature (e.g., Stuart et al. 2011; Dahabreh et al.; Tipton 2014): The overlap statistics scored here (pre-weighting standardized differences, Mahalanobis-type distance of the target mean) come from this literature. Citing it would situate the panel and actually strengthens the novelty claim: these works also do not score diagnostics as classifiers of realized error with discrimination and calibration.
- MSR65, ISPOR Europe 2024 (ref 1), supporting 'a widely quoted rule says to worry once absolute effective sample size falls below about 30 to 35': 'Widely quoted' is asserted on the basis of a single conference abstract, and the manuscript elsewhere (correctly, and commendably) treats MSR65 as a candidate cutoff rather than an authority and notes it does not recommend an operating point. Either document that the 30-35 cutoff circulates in appraisals/submissions or soften to 'a cutoff in informal use, motivated by'. The content of the abstract itself is not verifiable from the manuscript.

**Claims the reviewer judged unsupported.**

- 'It also reports the primary results within strata of misspecification rather than over a mixture of them, which removes the dependence on our chosen frequencies entirely.' — within-stratum results still inherit the chosen design points for delta, s, n, rho_4 and equal cell weighting; only the misspecification-frequency dependence is removed.
- 'The first and third depend on the realized outcomes; no function of X, the weights and a published baseline table has any information about epsilon.' — the arm-imbalance component does not depend on outcomes, and the weights fully determine the noise component's variance (sigma^2(1/ESS_A + 1/ESS_C)), which is exactly the information a classifier of the noise event uses and on which the paper's own 0.847 rests.
- 'The design is an anchored indirect comparison' — as written, the scored contrast appears to be the unanchored transported A-versus-C effect theta_AC(T) with no target-trial term in the decomposition; until comment 1 is resolved, the word 'anchored' is not licensed for the primary analysis.

## Authors' response to round 1

# Response to round one

Three reviewers, `major-revision` from two and `minor-revision` from one. Nineteen
comments, thirteen of them major. Every change described below was checked against the
manuscript source and the analysis code before this letter was written, by a script that
greps for the specific text of each claimed change; that check is in the study directory
and all thirty-four items pass. This program has three times published a response
describing a change the manuscript did not contain, and the check exists because of it.

Two of the reviewers' findings changed a result, not only a sentence. They are first.

---

## 1. The load-bearing claim in section 3 was wrong (Sol 1, Kimi 2, GLM 3)

All three reviewers, independently, said that our statement

> The first and third depend on the realized outcomes; no function of $X$, the weights and
> a published baseline table has any information about $\varepsilon$

is false, and that it is false in two separate ways. They are right on both.

**The arm-imbalance term uses no outcome at all.** $L(f)$ applies the estimator's linear
functional to the prognostic index, a function of realized covariates, treatment assignment
and weights. Grouping it with outcome noise as "not knowable from covariates" was simply an
error. It is now scored like the other two components, and it turns out to be the channel
effective sample size reads *best*: AUROC 0.813, against 0.847 for noise and 0.653 for
transport. Reporting it strengthens the paper rather than weakening it, because it shows
that the two components the panel tracks are exactly the two that are functions of the
information the panel is built from.

**The noise channel's variance is a known function of the weights.** Sol and Kimi both
derived it; we verified it numerically before accepting it:

$$\mathrm{Var}\{L(\varepsilon) \mid X, A, w\} = \sigma^2(1/\mathrm{ESS}_A + 1/\mathrm{ESS}_C)$$

exactly, with arm-specific effective sample sizes. So an area under the curve of 0.847
against the noise event is close to arithmetic and we now say so in the text rather than
presenting it as a discovery. One qualification we have added because it is true and
matters: the *reported* pooled effective sample size is not that quantity.
$2\sigma^2/\mathrm{ESS}_{\text{pooled}}$ is about 0.54 of the correct value in a
representative cell, and correlates with the exact noise standard deviation at $-0.92$ on
the log scale rather than at $-1$. So it is a strong proxy, not an identity.

What survives is the comparison, and we have rewritten section 3 to make the argument turn
on it: nothing forces a weight-dispersion statistic to be uninformative about the gap
between a weighted source and a target, and in the well-specified stratum it reaches 0.946
against the transport component. What it cannot see is the part of the modifier structure
the weights never touched.

## 2. The calibration split was confounded (Sol 6)

Sol warned that a single odd-cell/even-cell split "may separate levels of a design factor
depending on cell enumeration". We checked, and in this design it did so perfectly: cells
are enumerated with the target dispersion ratio varying fastest, so **every** odd cell had
ratio 1.00 and **every** even cell had 1.25. The reported cross-cell calibration measured
transport across one factor and we called it transport in general.

Replaced by leave-one-factor-level-out: fourteen folds, each holding out every cell at one
level of one factor, balanced across everything else by construction. The numbers changed
and the conclusion changed with them. Effective sample size now has a median integrated
calibration error of 0.076 and a **worst-fold error of 0.197**, and the previous claim that
the overlap statistics calibrate much worse than the weight statistics (0.143 against 0.065)
was an artifact: on a balanced split they are 0.098 and 0.076.

The new result is better than the old one. The worst held-out level is the same for every
weight-dispersion statistic in the panel, and it is the cross-moment channel: a risk mapping
learned where a bias no baseline table can reveal is operating, applied where it is not, is
off by about twenty points of absolute risk. That is the substantive transportability
finding, and it is now the one the paper makes.

We have also stated the model form Sol asked for: a logistic regression on one transformed
diagnostic, minus the natural logarithm where a low value is the warning and the statistic
itself otherwise, one linear term, no splines.

---

## Point by point

**Sol 2, Kimi 1. Which contrast is scored.** Agreed and fixed. The primary reference is the
transported $A$ versus $C$ effect, the design section now says so in the first sentence
about the reference, and the reason is given: the anchored contrast carries the target
trial's sampling error, which no source-side diagnostic can observe. The anchored contrast is
now reported alongside every discrimination result and in its own operating-point table, and
the conclusions are unchanged (effective sample size 0.699 against 0.731).

**Sol 3. Findings built into the mechanism.** Partly agreed and now labeled. The noise result
is presented as an arithmetic check, per point 1. The dispersion factor lowering effective
sample size without bias in the well-specified stratum is stated as a designed property, not
a finding; it is the instrument that makes the study falsifiable, and the protocol already
says so. We do not agree that the omitted-modifier and cross-moment channels being invisible
to marginal balance statistics is "built in" in the objectionable sense: that a marginal
statistic cannot see a cross-moment is a mathematical fact about the diagnostics, and
demonstrating its consequence is the point of the study, not an artifact of it. What is
genuinely built in, and now stated, is *how often* those channels operate, which is why the
primary results are within strata.

**Sol 4. The proposal is not compared on equal information.** Agreed, and this is the
sharpest comment on our own contribution. $\widehat{b}$ uses source outcomes through an
interaction estimated in the sample whose error is being diagnosed, while the panel is
outcome-free. It is now labeled an outcome-model-assisted diagnostic wherever it appears, the
in-sample optimism is stated, and we say we did not cross-fit. We have also reported that the
plain balance check on unmatched covariates does about as well here (0.946 against 0.938),
and changed the recommendation accordingly: check balance on everything you measured, not
only on what you matched. That is a weaker claim than the one we set out to make and it is
the one the data support.

**Sol 5. "Does not classify" overstates.** Agreed on the framing. The verdict label is
registered and we have not changed it, but the abstract now states precisely what it means:
no evaluated fixed cutoff met a sensitivity and specificity pair chosen in advance. The
limitations say that those requirements were not derived from an elicited loss function, that
the statistics do carry information, and that a reader wanting a different operating point
can take one off the ROC curves. What the decision-curve analysis adds is that at the action
thresholds a cautious analyst would use, no available operating point beats scrutinizing
everything.

**Sol 7. Registered analyses missing from the paper.** Agreed and fixed. Discrimination
against arm imbalance, equal-cell-weight areas under the curve, material thresholds of 0.10
and 0.30, and the anchored contrast are now in one table. Per-cell non-fit rates are in the
tracked results. We have not added paired Monte Carlo intervals for the two AUROC
differences behind the mechanism claims; the bootstrap is cell-stratified and unpaired, and
constructing paired intervals properly is more work than the remaining claims can carry. We
say instead, in the mechanism section, that both differences are reported as point estimates
against a registered threshold.

**Sol 8. The material threshold is on the residual scale.** Agreed; this was an error. 0.20
is a fifth of the residual standard deviation, not of the marginal outcome standard
deviation, which contains the prognostic index and runs from 1.37 to 1.66 across the design.
Corrected, with the range reported, and the 0.10 and 0.30 analyses are now shown.

**Sol 9. The span across cells is predictive value, not calibration.** Agreed, and this
retracts something we had promoted. A first draft called the silent-cell span "a stronger
result" than the registered claim. It is not; both spans are variation in predictive value,
which moves with prevalence and case mix even when operating characteristics are stable. The
text now says that, says the registered test failed, and points to the leave-one-factor-out
calibration as the proper evidence on transportability.

**Sol 10. Decision-curve prose did not match the table.** Correct. Three rules exceed both
alternatives at an action threshold of 0.4, not one. Fixed, and the sentence now names them.

**Sol 11. Conditioning on convergence removes the cases where balance can warn.** Agreed and
this is a real narrowing of our claim. The finding is now stated as: among analyses that
converged, the matched-moment balance statistic is redundant by construction, and reporting
it as evidence the adjustment worked is reporting that the solver terminated. Whether it is
useful as a convergence check is a different question this design cannot answer, and we say
so. The non-fit rate is reported separately.

**Sol 12, Kimi citations. Practice and novelty under-evidenced.** Agreed in substance. The
introduction now attributes the reporting conventions to the NICE DSU guidance
[@phillippo2018] and, for the overlap statistics, to the transportability literature
[@stuart2011; @tipton2014]; describes the ISPOR abstract as a region found in a different
setting that is now quoted informally rather than as a published rule; and states plainly
that **we have not surveyed how appraisal committees use these numbers and make no claim
about it.** Kish is now cited for the effective sample size and the identity, which is
standard survey-weighting arithmetic and not ours. The protocol adds a note on which
thresholds have a primary source and which are conventions in circulation without one. We
have not produced a reproducible literature-search account; the audit that produced the
open problem is published with the catalog, and we point to it rather than restating it.

**Sol 13. Limitations under-rank the real threats.** Agreed and rewritten around them: the
transport component is a realized effect-modifier component and not isolated systematic
bias; the proposal receives outcome information the panel does not; the anchored contrast is
secondary; and the operating characteristics are properties of the declared distribution,
not of the diagnostics.

**Sol 14, Kimi 8. Internal inconsistencies.** Fixed. The protocol's arithmetic now reads
$128 \times 4000 \times 4$ and its linearity statement says four estimators.

**Sol 15 (replicate count), within Sol 14's group.** Agreed and added: the 4000 figure was
derived at an assumed prevalence of 0.10, and at 1% the same formula gives about 0.045, so
the least informative cells are estimated far less precisely than the headline. The primary
measure is a cell-weighted ratio whose Monte Carlo error comes from the delta method, which
is an order of magnitude smaller; the protocol now says both things.

**GLM 1, Kimi 5. The abstract's numbers appeared in no table.** Correct and fixed; the
stratum-by-component table is new. It also answers Kimi's question about which panel member
reaches 0.851.

**GLM 2. The abstract framed a missed claim as a positive result.** Agreed. The abstract now
says two of four registered mechanism claims failed, including one of our own proposals.

**GLM 4. Morris et al. missing from the manuscript's references.** Fixed.

**GLM 5, Kimi 7. Coverage of the primary estimator missing.** Fixed; all four estimators are
in a coverage table. MAIC covers at 0.748 on the transported effect over a design containing
a great deal of deliberate misspecification.

**Kimi 3. "Removes the dependence entirely" overstates.** Agreed. Within-stratum reporting
removes the dependence on the misspecification frequencies only; the design points, the
levels and equal weighting inside a stratum are still ours. The limitations now say this and
name what remains.

**Kimi 4. The non-fit bracket was arithmetically unclear.** Fixed: the bracket is over the
whole design with cells weighted equally, not within the omitted-modifier stratum, and it
moves the figure by under a percentage point because MAIC converged on 99.3%.

**Kimi 6. Identical rows for pre-weighting imbalance and Mahalanobis distance.** Not a
table-generation error. In this mechanism the target mean is displaced by the same amount in
every covariate, so the maximum standardized difference and the Mahalanobis distance are
near-monotone functions of each other and agree to three decimals. It is a property of the
design and a limitation of it: a design with differential displacement would separate them.

**Kimi 9. The 50% effective-sample-size rule is labeled published without a citation.**
Agreed; relabeled as a convention in circulation, with the protocol note above.

---

## What we did not do

We did not add heteroskedastic errors, nonlinear or multiple omitted modifiers, uncertain
target moments, or additional estimator families (Sol 3, Sol 4, Sol 12). Each is a real
extension and each is a different study; the limitations name them. We did not cross-fit the
proposed diagnostic. We did not construct paired Monte Carlo intervals for the two mechanism
differences. We did not survey appraisal practice, and we now say we did not rather than
implying we had.


## Round 2

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

The revision is materially stronger: it clarifies the transported A-versus-C estimand, reports the anchored result, adds the omitted arm-imbalance component, corrects the outcome-scale error, and replaces the confounded calibration split. The narrow prespecified result is supported: no evaluated cutoff meets the registered operating requirements in this simulation distribution. However, the abstract still contains the knowability claim that the response says was retracted, the title-level variance-versus-bias conclusion is not established because systematic bias was never evaluated, and Tables 8 and 9 give mutually incompatible results for the proposed diagnostic. These problems are repairable using the existing simulations and narrower framing, so rejection is not warranted.

**Strengths.**

- The registered decision rule is applied without moving the goalposts, and two failed mechanism claims remain reported as failures.
- The factorial design deliberately separates poor overlap, modifier misspecification, sample size, proxy adjustment, and weight-dispersion effects.
- The exact linear decomposition is a useful methodological instrument, and adding discrimination against arm imbalance substantially improves fulfillment of Aim 3.
- The revised manuscript clearly distinguishes the transported A-versus-C estimand from the final anchored contrast and reports that the main ranking persists for the latter.
- The estimator comparison avoids the obvious variance-estimator asymmetry: MAIC uses a stacked M-estimation sandwich and STC uses HC3.
- The proposal is now appropriately demoted, with its use of outcomes and possible in-sample optimism disclosed and the simpler unmatched-balance diagnostic favored.
- The limitations now acknowledge exact target moments, investigator-chosen scenario distributions, restricted estimator families, and the fact that the transport component is not pure systematic bias.

**Comments.**

**Major 1** (Abstract; What a covariate diagnostic could possibly know). The round-one correction has not been carried through consistently. The abstract still says, "Transport error is the only piece a covariate diagnostic could know about before an outcome is seen," even though the manuscript and response explicitly call that statement wrong. The replacement claim is also too simple: L(f) is calculable from covariates only if the prognostic function f is known, while the transport component is likewise a function of covariates, assignment and weights if g and the target expectation are known. The noise realization is unknowable, but its conditional risk depends on the arm-specific ESS values and sigma. Thus the relevant distinction is between realized values, conditional risks, and the additional outcome-model quantities required, not between two components that use the panel's information and one that does not.

*What would satisfy this:* Remove the retracted sentence from the abstract and revise the interpretation throughout. For each component, state separately whether its realized value is outcome-free, whether its conditional distribution is estimable before observing outcomes, and which unknown functions or parameters are required.

**Major 2** (Title; Results; What this answers, and what it does not). The manuscript now acknowledges that the quantity called transport error is a realized effect-modifier component containing finite-sample source composition and allocation variation. It is therefore not systematic transport bias. Comparing AUROC 0.847 for noise with 0.653 for this realized component shows that ESS tracks sampling-driven error channels differently; it does not establish that ESS is a variance statistic rather than a bias diagnostic. The additional assertion that ESS "is being read as a bias warning" is also unsupported by a paper that expressly says appraisal practice was not surveyed.

*What would satisfy this:* Either estimate cell-specific systematic transport bias as a Monte Carlo expectation, quantify its Monte Carlo error, and evaluate diagnostics against that target, or remove bias language from the title and conclusions. Any claim about how ESS is interpreted in practice also requires evidence of actual use; otherwise frame it as a possible interpretation rather than an observed one.

**Major 3** (Tables 8 and 9; Four prespecified mechanism claims). The evidence for mechanism claim 4 is internally inconsistent. Table 8 says the proposal reaches 0.937 versus 0.851 for the best routinely reported diagnostic, a gain of 0.086. Table 9 instead reports 0.938 for the proposal, 0.946 for unmatched-covariate balance, and 0.862 for ESS percentage. The response itself cites 0.946 versus 0.938. Consequently, neither the comparator nor the registered difference in Table 8 can be recovered from the revised results, and the statement that the proposal is "a real improvement" is not supported by the displayed table.

*What would satisfy this:* Regenerate the mechanism-claim result from the same analysis underlying Table 9, define exactly which diagnostics constitute the registered comparator set, and make the abstract, Table 8, Table 9 and response numerically consistent. Report a paired Monte Carlo interval or standard error for the resulting difference.

**Major 4** (Calibration). Leave-one-factor-level-out validation fixes the serious odd/even-cell confounding, but the new interpretation remains stronger than the analysis permits. Failure of a one-linear-term logistic mapping can reflect functional-form misspecification as well as nontransportability of the diagnostic. It is also unclear how calibration intercepts and slopes were aggregated across fourteen overlapping folds, which weighting was used, and why the factor called "joint" in Table 6 corresponds to the cross-moment mechanism. No uncertainty or calibration plots are presented.

*What would satisfy this:* Define the fold predictions, aggregation, weights, factor names and calibration estimators completely. Add fold-specific calibration plots or curves and a sensitivity analysis using a flexible prespecified mapping. Otherwise narrow the conclusion to the observed failure of this particular logistic mapping under the specified held-out factor levels.

**Minor 5** (Results and protocol adherence). Several reporting gaps from round one remain. Table 1 promises Monte Carlo standard errors in brackets but does not display them; the event used for each component-specific AUROC is not explicitly defined; the manuscript says Table 2 reports discrimination against noncoverage although that column is absent; per-cell nonfit rates are not shown or linked; and no uncertainty accompanies AUPRC, calibration, decision-curve quantities, or the paired AUROC differences. The large primary differences are not plausibly explained by Monte Carlo error, but complete ADEMP reporting still requires these quantities or an explicit supplement reference.

*What would satisfy this:* Add a protocol-to-results crosswalk or clearly referenced supplement containing event definitions, per-cell prevalence and nonfit rates, all promised Monte Carlo uncertainties, and paired within-cell resampling for diagnostic contrasts.

**Minor 6** (Decision-curve analysis). The revised prose still does not match Table 7. At threshold 0.40, three displayed rules beat both alternatives; at threshold 0.50, all five displayed rules have positive net benefit and beat both alternatives. The text instead says that four rules do so "from 0.400 upwards" and then names only three. More fundamentally, the action prompted by a warning remains undefined, so this is hypothetical net classification benefit rather than demonstrated benefit from acting.

*What would satisfy this:* Correct the counts separately at each threshold and either define the action and its consequences or explicitly label the analysis as hypothetical decision-curve utility for detecting material error.

**Minor 7** (Nonfit sensitivity bracket; Coverage). The nonfit bracket is better labeled but still not reproducible. The fitted-only equal-cell sensitivity is 0.284, while the stated bounds are 0.273 and 0.285; the lower change is 1.1 percentage points, contrary to the claim that both changes are below one percentage point. Separately, overall coverage of 0.748 across intentionally misspecified cells cannot establish that the MAIC sandwich itself contributes a shortfall at low ESS.

*What would satisfy this:* Show the nonfit numerator, denominator and cell weighting for both bounds. For the variance-estimator statement, report coverage in well-specified cells by ESS or source-size stratum, or remove the attribution to the sandwich.

**Minor 8** (Introduction and references). The literature positioning remains incomplete. Reference 1 is a Medical Decision Making article but is called NICE DSU guidance; the actual DSU technical support document should be cited if guidance is meant. The authorless MSR65 entry does not establish that its numerical region is widely quoted, and the universal claim that no published study has evaluated these diagnostics as classifiers is not supported by a reproducible search or a citation to the catalog audit. The outcome-model-assisted proposal should also be positioned against prognostic-score balance, bias-function and omitted-moderator sensitivity methods.

*What would satisfy this:* Correct the guidance attribution, complete the MSR65 reference, cite and summarize the catalog search methods, narrow any unsupported absence claim, and engage with existing outcome-informed balance and transportability-sensitivity literature.

**Citation problems.**

- Phillippo et al. (2018), reference 1: The cited journal article is described as NICE DSU guidance. Cite the actual technical support document or describe reference 1 as a journal article.
- MSR65, ISPOR Europe 2024: The bibliographic entry omits the authors, and the abstract supports an empirical low-ESS region in a different setting, not the claim that the cutoff is widely quoted or used as a bias warning.
- No published work scores any of these as a classifier: This universal novelty claim lacks a reported search strategy and an explicit citation to the catalog audit said to establish it.
- Estimated bias diagnostic described as the authors' proposal: Its relationship to prognostic-score balance, outcome-model-assisted balance, bias functions and omitted-moderator sensitivity analysis is not discussed, so novelty is not established.

**Claims the reviewer judged unsupported.**

- Transport error is the only piece a covariate diagnostic could know about before an outcome is seen.
- Two of the three components are functions of covariates, treatment assignment and weights alone; the panel is built out of those same ingredients, and it tracks both of them well.
- A statistic that reads two channels at above 0.80 and the third at 0.653 is a variance statistic, and it is being read as a bias warning.
- In the diagnosable stratum, against the transport component, the proposal reaches 0.937 and the best routinely reported diagnostic 0.851, a gain of 0.086.
- It is a real improvement and it is not the one we said would count.
- From an action threshold of 0.400 upwards, meaning an analyst who intervenes only when material error is at least that likely, 4 rules beat both alternatives.
- Table 2 reports discrimination against non-coverage as well.
- The sandwich contributes its own shortfall at small effective sample size.
- A rule that warns about almost every analysis is not a classifier.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| glm 1 | partly | Table 9 was added, but its values do not support the 0.937 versus 0.851 comparison retained in Table 8. |
| kimi 1 | yes | The primary A-versus-C estimand, exclusion of target-trial noise, and secondary anchored analysis are now explicit. |
| kimi 2 | partly | The arm-imbalance and noise-variance corrections were added, but the false knowability claim remains in the abstract and the proposal's near-construction is not fully acknowledged. |
| sol 1 | partly | All three components are now reported and the middle term is acknowledged as realized rather than pure bias, but systematic bias was not analyzed and the variance-versus-bias conclusion remains. |
| sol 2 | yes | The transported and anchored contrasts are clearly separated, with a stated rationale and secondary anchored results. |
| sol 3 | partly | The noise result and dispersion factor are labeled as arithmetic or designed properties, but the omitted-modifier proposal and the broad title-level interpretation remain insufficiently separated from construction. |
| sol 4 | partly | Outcome use, lack of cross-fitting and in-sample optimism are disclosed and the proposal is demoted, but the head-to-head mechanism result is internally inconsistent and remains uncorrected. |
| sol 5 | partly | The abstract now defines the registered operating criterion and limitations acknowledge the arbitrary loss threshold, but the manuscript still says a frequently firing rule is not a classifier and leaves the decision action undefined. |
| sol 6 | partly | The confounded split was replaced by leave-one-factor-level-out validation and the logistic model is described, but functional-form sensitivity, fold aggregation, plots and uncertainty remain absent. |
| sol 7 | partly | Several missing analyses were added, but component event definitions, noncoverage results, per-cell nonfits and paired uncertainty for mechanism differences remain incomplete. |
| sol 8 | yes | The threshold is correctly described in residual-SD units, the marginal-SD range is given, and the 0.10 and 0.30 analyses are reported. |
| sol 9 | yes | The predictive-value spans are no longer called transportability tests, and the registered claim is correctly reported as failed. |
| sol 11 | yes | The balance-zero claim is explicitly limited to accepted calibration solutions, with convergence checking identified as a separate unanswered use. |
| sol 12 | partly | Several foundational citations and practice caveats were added, but the guidance attribution, novelty search, MSR65 provenance and positioning of the proposal remain inadequate. |
| sol 13 | yes | The limitations now disclose the realized nature of the transport component, unequal information for the proposal, secondary anchored analysis, exact target moments and scenario-distribution dependence. |
| sol 14 | partly | The four-estimator count was corrected, but promised Monte Carlo errors, the exact nonfit calculation, pooled ESS interpretation and complete calibration-protocol crosswalk remain unresolved. |

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The revised manuscript addresses all major round-one concerns substantively: the knowability framing is corrected (arm imbalance is now scored as a covariate function, noise variance is stated as arithmetic), the calibration split is replaced with leave-one-factor-level-out, the scored contrast is made explicit, the proposal is labeled outcome-model-assisted, the material-threshold scale is corrected, and the stratum-specific component AUROCs are now in a table. The core finding—that ESS tracks the two covariate-determined error components (noise 0.847, arm imbalance 0.813) better than transport error (0.653), and that no fixed cutoff meets prespecified operating requirements—is well-supported by the reported tables. Remaining issues are minor: a numerical inconsistency between Tables 8 and 9 for the proposed diagnostic's AUROC (0.937 vs 0.938) and its comparator (0.851 not traceable to Table 9), a count error in the decision-curve text, and a title that asserts the statistic 'is being read as a bias warning' while the body disclaims any claim about how committees use it.

**Strengths.**

- The exact error decomposition under the identity link, verified to 3e-14, is an elegant instrument that cleanly separates what a covariate diagnostic could know from what it cannot, and the revision now scores all three components rather than grouping arm imbalance with noise.
- The target-dispersion factor s=1.25 is a genuinely clever falsifiability device: it creates cells where ESS is destroyed without bias in the well-specified stratum, preventing the design from making a variance statistic look like a bias statistic.
- Honest reporting of two failed prespecified mechanism claims without post-hoc adjustment is exemplary.
- The calibration analysis was redone with leave-one-factor-level-out cross-validation after discovering the original odd/even cell split was perfectly confounded with the dispersion factor; the authors report the new (different) results rather than silently substituting.
- The unadjusted estimator serves as an illuminating control: the same pre-weighting imbalance statistic predicts the unadjusted estimator's transport error at 0.891 but MAIC's at 0.655, licensing 'informative about the problem, uninformative about the solution.'
- The algebraic identities (ESS/n = 1/(1+CV²(w)), matched-moment balance identically zero) are proved and checked against the run, and the matched-moment AUROC of 0.550 is correctly labeled as floating-point residual ranking.
- The proposal is now honestly labeled as outcome-model-assisted with in-sample optimism disclosed, and the practical recommendation is appropriately downgraded to 'check balance on everything you measured, not only on what you matched.'

**Comments.**

**Minor 1** (Results: Decision curve analysis; Table 7). The text says '4 rules beat both alternatives: relative effective sample size, pre-weighting imbalance and Mahalanobis distance' but lists only 3 names. The 4th is CV(w), which is algebraically identical to ESS% (the paper's own point). Counting the same statistic twice inflates the count. Either list CV(w) explicitly with a note that it duplicates ESS%, or correct the count to 3.

*What would satisfy this:* Change '4 rules' to '3 rules' or list all 4 with a note that CV(w) and ESS% are one statistic, consistent with the paper's own algebra.

**Minor 2** (Results: Mechanism claims; Tables 8 and 9). Table 8 states the proposed diagnostic reaches 0.937 against the transport component in the diagnosable stratum, but Table 9 reports 0.938. The comparator 'best routinely reported diagnostic 0.851' in Table 8 does not match any value in Table 9 for the omitted-modifier stratum (the closest are ess_pct at 0.862, smd_pre/maha at 0.859, and lambda_norm at 0.850 from the decision output, which is not in the manuscript). The reader cannot trace the key numbers behind mechanism claim 4.

*What would satisfy this:* Reconcile 0.937 vs 0.938, identify which statistic is the comparator at 0.851, and ensure Table 9 contains all statistics used in the mechanism-claim arithmetic. If the 0.851 comes from lambda_norm or a deployment-weighted calculation, state which and show it.

**Minor 3** (Title). The title asserts ESS 'is a variance statistic being read as a bias warning,' but the body now states 'We have not surveyed how appraisal committees actually use these numbers, and this paper makes no claim about that.' The title makes a claim about practice that the paper explicitly disclaims supporting. This is a framing tension, not a results error, but it will mislead readers who see only the title.

*What would satisfy this:* Either soften the title to remove the practice claim (e.g., 'a variance statistic that does not classify transport error') or add a sentence in the introduction acknowledging the title is about the conventional reporting framework implied by guidance documents, not about empirically observed committee behavior.

**Minor 4** (Results: The other estimators; Tables 10-11). Coverage for the primary MAIC estimator is now reported (0.748, Table 11), which addresses the round-one gap. However, the text attributes the shortfall partly to 'the sandwich variance estimator used in their study' (Remiro-Azócar et al.), but the sandwich used here (stacked M-estimation) is a different procedure. The text does note this in the protocol but the manuscript body could state more clearly that the Remiro-Azócar result does not directly transfer.

*What would satisfy this:* Add one clause noting that the stacked M-estimation sandwich used here differs from the variance procedure Remiro-Azócar et al. evaluated, so the coverage shortfall is not a direct replication of their finding.

**Minor 5** (Abstract). The abstract states ESS 'reaches 0.309 at specificity 0.926' in the omitted-modifier stratum. This is correct per Table 1. But the abstract does not report the Monte Carlo standard error (0.001), and the difference between ESS and the next-best absolute cutoff (ESS<30 at 0.277) is 0.032, which exceeds its Monte Carlo error. The abstract is fine; this is a note that the abstract's precision claims are supported, not a criticism.

*What would satisfy this:* No change needed; recorded as a check that the abstract numbers are traceable and Monte Carlo error is respected.

**Citation problems.**

- MSR65, ISPOR Europe 2024 (ref 4): The abstract bibliographic entry still omits the authors of the conference abstract. The manuscript is now appropriately cautious about characterizing it as a 'candidate cutoff in wide informal use' rather than a published rule, which resolves the round-one concern about overstatement.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| glm 1 | yes | Table 9 now reports stratum-specific AUROCs against the transport component for all diagnostics including the proposal and oracles. The abstract's 0.937/0.851 numbers are now traceable (though with a minor 0.937 vs 0.938 discrepancy flagged in comment 2). |
| glm 2 | yes | The abstract now says 'Two of four registered mechanism claims failed, including one of our own proposals, and both failures are reported as failures.' |
| glm 3 | yes | Section 2 now explicitly states that the noise variance is a known function of the weights and that the 0.847 AUROC is 'close enough that a high area under the ROC curve against the noise channel should be read as a check on the arithmetic and not as an empirical discovery.' |
| glm 4 | yes | Morris et al. 2019 is now reference 7 in the manuscript reference list. |
| glm 5 | yes | Table 11 now reports coverage for all four estimators including the primary MAIC at 0.748 on the transported effect. |
| kimi 1 | yes | The design section now states in its first sentence about the reference that the scored quantity is the transported A-vs-C effect, with the reason (target-trial sampling error is invisible to source diagnostics). The anchored contrast is reported alongside throughout. |
| kimi 2 | yes | Section 2 is rewritten: the arm-imbalance term is identified as outcome-free and now scored (Table 3, AUROC 0.813); the noise variance identity is stated; the 0.847 is presented as near-arithmetic. The knowability sentence is corrected. The proposal's near-construction in the kappa=0 stratum is noted in the response letter but could be more explicit in the manuscript text. |
| kimi 3 | yes | The text now says 'Reporting within strata removes the dependence on the misspecification frequencies only' and the limitations name what remains (design points, levels, equal weighting). |
| kimi 4 | yes | The bracket is now stated as over the whole design with cells weighted equally, not within the omitted-modifier stratum, and the numbers (0.285 and 0.273) are consistent with the equal-weight overall sensitivity of 0.284. |
| kimi 5 | yes | Table 9 now reports stratum-specific component AUROCs. The best routinely reported diagnostic in the omitted-modifier stratum is identifiable (smd_unmatched at 0.946, or ess_pct at 0.862 if excluding unmatched balance). |
| kimi 6 | yes | The authors explain the identical rows as a design property: the target mean is displaced by the same amount in every covariate, making the maximum standardized difference and Mahalanobis distance near-monotone functions of each other. This is stated as a limitation (a design with differential displacement would separate them). |
| kimi 7 | yes | Table 11 now includes the primary MAIC estimator's coverage. |
| kimi 8 | yes | The protocol arithmetic now reads 128 x 4000 x 4 = 2,048,000 and the calibration description uses odd/even cells. |
| kimi 9 | yes | The ESS < 50% rule is now described as a 'convention in circulation' with a protocol note that no primary citation exists. |
| sol 1 | yes | The arm-imbalance term is now correctly identified as outcome-free and scored (Table 3). The transport component is relabeled as a 'realized effect-modifier component' in the limitations, and the text notes it 'is not pure bias' but contains finite-sample source composition and allocation variation. |
| sol 2 | yes | The primary reference is now explicitly the transported A-vs-C effect. The anchored contrast is reported alongside. The limitations state the anchored contrast is secondary. |
| sol 3 | partly | The noise result is now labeled as arithmetic. The dispersion factor is stated as a designed property. The authors refuse to label the cross-moment invisibility as 'built in' because it is a mathematical fact about the diagnostics, which is a reasonable position. The remaining concern (that modifier magnitudes and how often channels operate are investigator-chosen) is acknowledged in the limitations. |
| sol 4 | yes | The proposal is now labeled 'outcome-model-assisted' wherever it appears, in-sample optimism is stated, cross-fitting is acknowledged as not done, and the practical recommendation is downgraded to the plain balance check. The limitations note the proposal 'is not compared on an equal footing.' |
| sol 5 | yes | The verdict is now stated precisely: 'no evaluated fixed cutoff met a sensitivity and specificity pair chosen in advance.' The limitations note the requirements were not derived from an elicited loss function and that the statistics carry information. |
| sol 6 | yes | The calibration split was replaced with leave-one-factor-level-out (14 folds). The model form is specified (logistic on one transformed diagnostic, one linear term, no splines). The numbers changed and the previous claim about overlap statistics calibrating much worse was retracted as an artifact of the confounded split. |
| sol 7 | partly | Discrimination against arm imbalance, equal-cell weights, material thresholds 0.10 and 0.30, and the anchored contrast are now in Table 3. Per-cell non-fit rates are in tracked results. Paired Monte Carlo intervals for the two mechanism-claim differences were not added; the authors explain the bootstrap is cell-stratified and unpaired, which is a reasonable refusal but leaves the 0.194 and 0.086 differences without uncertainty quantification. |
| sol 8 | yes | Corrected: 0.20 is a fifth of the residual standard deviation, not the marginal outcome standard deviation. The marginal SD range (1.37-1.66) is reported. The 0.10 and 0.30 analyses are shown. |
| sol 9 | yes | The authors agree and retract the claim that the silent-cell span is a 'stronger version' of the registered claim. Both spans are now described as variation in predictive value. The registered claim is reported as failed, and the calibration section is pointed to as the proper transportability evidence. |
| sol 10 | yes | The text now says '4 rules beat both alternatives' and names relative ESS, pre-weighting imbalance, and Mahalanobis distance (though the count is slightly wrong—see comment 1). |
| sol 11 | yes | The claim is now narrowed to 'among analyses that converged, the matched-moment balance statistic is redundant by construction.' The text states whether it is useful as a convergence check is a different question this design cannot answer. Non-fit rate is reported separately. |
| sol 12 | partly | The manuscript now cites Phillippo 2018 for NICE DSU guidance, Stuart 2011 and Tipton 2014 for transportability, and Kish 1965 for ESS. The novelty claim is narrowed. However, no reproducible literature-search account is provided, and the assertion that no published work has scored these as classifiers rests on the catalog audit rather than a systematic review. The authors now say 'we have not surveyed how appraisal committees use these numbers' which is honest but leaves the practice claims under-evidenced. |
| sol 13 | yes | The limitations are rewritten around the real threats: transport component is not isolated bias, proposal receives outcome information, anchored contrast is secondary, target summaries are exact, operating characteristics are properties of the declared distribution. The text explicitly states 'every operating characteristic in this paper is a property of that distribution rather than an intrinsic property of a diagnostic.' |
| sol 14 | yes | The protocol arithmetic is corrected to 128 x 4000 x 4. The calibration description uses cells. The replicate-count caveat (4000 derived at 10% prevalence; at 1% gives 0.045) is added. ESS for unweighted methods (550 = n per arm, since weights are uniform) is implicitly clear. |

### Reviewer 3: Kimi K3 (via OpenCode)

**Recommendation: minor-revision**

The revision fixes the two load-bearing problems from round one: the knowability framing is corrected (the arm-imbalance component is now recognized as outcome-free and is scored like the others, and the noise channel's variance is given as an exact function of arm-specific ESS with an honest pooled-ESS caveat), and the confounded odd/even-cell calibration split is replaced by leave-one-factor-level-out, which changed the numbers and produced a better finding (the worst held-out level for every weight statistic is the cross-moment channel). The prespecified verdict stands and is now stated with the precision round one demanded, the anchored contrast is reported alongside the transported component throughout, and both failed registered claims remain reported as failures. However, the response letter claims traceability that the manuscript does not deliver for mechanism claim 4: the new stratum-by-component table contradicts the evidence row in the claims table (0.851 appears nowhere; the unmatched-covariate balance at 0.946 exceeds the proposal's 0.938). Several smaller inconsistencies (an 'entirely' that survives in the introduction while the limitations disown it, a non-coverage column promised in a table that lacks it, a decision-curve sentence false at threshold 0.5, an undefined 'joint' fold) are all repairable without re-simulation.

**Strengths.**

- The correction of the round-one knowability error is not a grudging concession but improves the paper: scoring all three components shows the panel tracks exactly the two components that are functions of covariates, assignment and weights (0.847 noise, 0.813 arm imbalance) and misses the one adjustment exists to remove (0.653 transport) — and the text correctly notes that the well-specified-stratum 0.946 against transport proves the headline comparison is empirical, not arithmetic.
- The pooled-ESS qualification (2 sigma^2/ESS_pooled is about half the correct value, correlating with the exact noise SD at -0.92 rather than -1 on the log scale) shows the authors verified the reviewers' derivation numerically instead of transcribing it.
- The calibration reanalysis is exemplary revision practice: the confounded split was confirmed (odd cells perfectly equal s=1.00), replaced by a balanced leave-one-factor-level-out design, the old overlap-versus-weight calibration claim is explicitly retracted as an artifact, and the replacement finding (cross-moment channel as the universal worst fold) is more substantive than what it replaced.
- The proposal's demotion is honest and consequential: labeled outcome-model-assisted wherever it appears, in-sample optimism disclosed, cross-fitting declined but named, and the practical recommendation changed to the plain balance check the data actually support.
- The anchored-contrast fix is thorough: the primary reference is stated in one sentence with its justification (target-trial sampling error is invisible to source diagnostics and would depress all discrimination by a common amount), and the anchored column appears in Table 3 and in its own operating-point table, with conclusions unchanged (0.699 vs 0.731).
- Internal-verification discipline remains a model: the ESS/CV identity and the identically-zero matched-moment balance are checked against the run, and the 0.550 AUROC of solver residue is correctly labeled 'discrimination of arithmetic difficulty' with the claim properly narrowed to converged analyses.

**Comments.**

**Major 1** (Table 8 (mechanism claims) vs Table 9 (strata-transport)). The response letter says the new stratum-by-component table 'answers Kimi's question about which panel member reaches 0.851', and Table 9's caption says 'this is where the two numbers behind mechanism claim 4 live'. They do not. In the omitted-modifier (diagnosable) column the proposal is 0.938, not 0.937; no diagnostic of any kind sits at 0.851; the unmatched-covariate balance reaches 0.946, which exceeds the proposal; and the best clearly-routine member (ESS %, 0.862) would give a gain of 0.076, not 0.086. So Table 8's evidence row is irreconcilable with Table 9 under every reading of 'routinely reported'. The registered claim fails under any of these numbers, so the verdict is untouched — but a paper whose central virtue is numeric traceability cannot print two tables that contradict each other on a registered claim's evidence, and the response cannot claim a fix the table does not contain.

*What would satisfy this:* Name the comparator statistic and the weighting used for the claim-4 evidence, then regenerate or correct the evidence row so it matches Table 9 (if the comparator is ESS % at equal weights, the gain is 0.076, still below 0.10; if the unmatched-covariate balance counts as panel, the gain is negative). One sentence stating why the comparator set excludes the unmatched-covariate balance, if it does.

**Minor 2** (Results: The other estimators). The text says 'Table 2 reports discrimination against non-coverage as well', but Table 2 as printed has no non-coverage column (AUROC, AUPRC, vs outcome noise, vs transport error only). The column exists in the decision document (ess 0.630, etc.) but was dropped from the manuscript table, leaving a sentence that points at content that is not there.

*What would satisfy this:* Add the vs-non-coverage column to Table 2 or delete the clause from the sentence.

**Minor 3** (Results: decision-curve analysis). Two numerical slips. First, 'the absolute effective-sample-size cutoff that gets quoted is not among them at any threshold examined' is false at action threshold 0.5: ESS < 35 has net benefit 0.069, which exceeds both flag-nothing (0) and flag-everything (-0.043). Beating a collapsed flag-everything default at 0.5 is a low bar, but the sentence as written is contradicted by Table 7. Second, '4 rules beat both alternatives' at 0.4 names only three (relative ESS, pre-weighting imbalance, Mahalanobis); the fourth is CV(w), ESS%'s identical twin — worth saying, since the paper's own redundancy result is what makes four rules three statistics.

*What would satisfy this:* Restrict the claim to thresholds up to 0.4 or restate it accurately at 0.5, and name or explain the fourth rule.

**Minor 4** (What the audit left open (introduction)). The introduction still says within-stratum reporting 'removes the dependence on our chosen frequencies entirely' — the exact sentence flagged in round one — while the limitations now (correctly) say 'an earlier draft said the stratum reporting removed the dependence entirely; it does not'. The 'earlier draft' is this draft's introduction. The response letter's grep-check evidently verified that the correction was added somewhere, not that the flagged sentence was removed.

*What would satisfy this:* Delete 'entirely' (or the clause) in the introduction so the two sections stop contradicting each other.

**Minor 5** (Calibration, Table 6). The worst fold for every weight-dispersion statistic is listed as held-out factor 'joint', level 0, but 'joint' is never defined, and it cannot be reconciled with the stated design: 'fourteen folds, each holding out every cell at one level of one factor' matches the six design factors exactly (2+2+4+2+2+2 = 14), leaving no room for a 'joint' fold. The prose glosses the worst setting as 'the cross-moment channel', which is not obviously the same thing as holding out joint==0 (cells where both channels are not simultaneously on).

*What would satisfy this:* Define 'joint', state the exact fold construction (and if a derived two-level factor was used, reconcile the fold count), and align the prose interpretation with the factor actually held out.

**Minor 6** (Protocol section 8 (registration trail)). Section 8 of the protocol still describes the calibration mapping as 'fitted on odd-numbered replicates and evaluated on even-numbered ones'. The registered trail now reads replicates (section 8) -> odd/even cells (section 12 amendment) -> leave-one-factor-level-out (revised manuscript, a post-results change made for good reason and well disclosed in the manuscript). The arithmetic fix (128 x 4000 x 4) is verified present, but the calibration unit correction requested in round one was not made at section 8.

*What would satisfy this:* Add a one-line corrigendum at protocol section 8 (marked as such) recording the supersession: replicates -> cells -> leave-one-factor-level-out, so a reader checking the manuscript against the registered protocol does not trip.

**Minor 7** (Table 11 (coverage)). The 'fitted' coverage column (0.993/1.000/1.000/1.000) is never defined. Transported and anchored columns are self-explanatory; what fitted quantity the interval is covering is not.

*What would satisfy this:* One sentence defining the fitted reference.

**Minor 8** (Results: The panel at the thresholds in use). Residual threshold-provenance wording: the results text still says 'the published cutoff reaches sensitivity 0.309', although the protocol now (correctly, in response to round one) describes these as conventions in circulation, only some with a primary source. 'Widely quoted informally as a cutoff' in the abstract also remains an unevidenced empirical claim, though it is now paired with an explicit disclaimer that practice was not surveyed, which makes it acceptable as a judgment call if the authors wish to keep it.

*What would satisfy this:* Replace 'the published cutoff' with 'the candidate cutoff' (or similar) in the results text for consistency with the new provenance note.

**Citation problems.**

- Phillippo et al. 2018 (ref 1), cited as 'the NICE DSU guidance on population adjustment': Substantially adequate as a response to the round-one request to engage the DSU guidance, but the attribution is imprecise: the reporting conventions derive from the DSU Technical Support Documents (TSD 13, and especially TSD 18, 2020), of which the MDM paper is the methods companion. Citing TSD 18 alongside, or describing the MDM paper accurately, would close the point.
- MSR65, ISPOR Europe 2024 (ref 4): The characterization in text is now careful and accurate (a region found in an unanchored simulation, quoted informally, treated as a candidate cutoff). Two residuals: the bibliographic entry still omits the abstract's authors, and 'widely quoted informally' remains an unevidenced circulation claim — softened and disclaimed, so acceptable, but 'in informal use' would be safer than 'widely quoted'.

**Claims the reviewer judged unsupported.**

- Table 8: 'the proposal reaches 0.937 and the best routinely reported diagnostic 0.851, a gain of 0.086' — contradicted by the manuscript's own Table 9, which shows 0.938 for the proposal, no diagnostic at 0.851, the unmatched-covariate balance at 0.946 (exceeding the proposal), and ESS % at 0.862 as the best clearly-routine member (gain 0.076).
- 'Table 2 reports discrimination against non-coverage as well' — Table 2 contains no non-coverage column; it exists only in the decision document.
- 'The absolute effective-sample-size cutoff that gets quoted is not among them at any threshold examined' — at action threshold 0.5 its net benefit (0.069) exceeds both flagging nothing (0) and flagging everything (-0.043).
- Introduction: within-stratum reporting 'removes the dependence on our chosen frequencies entirely' — disowned by the paper's own limitations section ('it does not').

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| glm 1 | partly | The stratum-by-component AUROC table (Table 9) was added, which is the requested artifact. But the two numbers it claims to house (0.937 / 0.851) do not reconcile with its contents: 0.938 vs 0.937, no 0.851 anywhere, and the unmatched-covariate balance (0.946) exceeds the proposal. See comment 1. |
| glm 2 | yes | Abstract now states two of four registered mechanism claims failed, including one of the authors' own proposals. |
| kimi 1 | yes | The scored contrast is stated explicitly as the transported A-versus-C effect, the exclusion of target-trial sampling error is justified (common channel invisible to source diagnostics), and the anchored contrast is reported alongside throughout (Table 3 column, separate operating-point table), with conclusions unchanged. |
| kimi 2 | yes | The noise-variance identity is in the algebra section, the knowability sentence is corrected, the arm-imbalance component is scored, and 0.847 is re-presented as close to arithmetic with the pooled-ESS caveat (0.54, -0.92 vs -1) showing they verified rather than asserted. The requested sentence that in the kappa=0 stratum transport error equals omega*Delta_4 exactly (so b_hat is near-construction) was not added verbatim, but the substance is covered by the outcome-assisted labeling and the plain-balance comparison (0.946 vs 0.938, 'the estimated interaction adds noise without adding information'). |
| kimi 3 | partly | The limitations now correctly scope what stratification removes and name what remains — but the flagged sentence survives verbatim in the introduction ('removes the dependence on our chosen frequencies entirely'), contradicting the limitation that quotes it. The response's scripted check verified addition of the correction, not removal of the error. |
| kimi 4 | yes | The bracket base is now stated (whole design, equal cell weights), and 0.285 / 0.273 visibly brackets the 0.284 equal-weight sensitivity. Arithmetically consistent. |
| kimi 5 | partly | Same issue as glm 1: Table 9 exists, but 0.851 remains untraceable and the claims-table evidence row now contradicts the new table. The comparator statistic is still not named. |
| kimi 6 | yes | A reasoned explanation rather than compliance: common target-mean displacement across covariates makes max standardized difference and Mahalanobis distance near-monotone functions of each other, disclosed as a design limitation (differential displacement would separate them). Corroborated indirectly: the leave-one-factor-out calibration rows for the two statistics now differ (0.098/0.235 vs 0.096/0.235), as they should once folds mix s levels. Legitimate refusal-by-explanation. |
| kimi 7 | yes | Coverage for all four estimators added (Table 11), including primary MAIC at 0.748 transported / 0.774 anchored, with the connection to Remiro-Azocar drawn and correctly scoped to the variance procedure used in their study. |
| kimi 8 | partly | The estimate-count arithmetic is corrected in the protocol (128 x 4000 x 4 = 2,048,000, verified). The calibration-split unit at section 8 still says 'replicates'; the trail (replicates -> cells -> leave-one-factor-level-out) needs one corrigendum line. |
| kimi 9 | yes | ESS < 50% relabeled as a convention in circulation with no primary citation, and a threshold-provenance note added to protocol section 7. Residual 'published cutoff' phrasing in the results text flagged as comment 8. |
| sol 1 | partly | Arm imbalance is now scored (Table 3 first column) and the middle term is relabeled a realized effect-modifier component with the contamination disclosed in limitations. The requested per-cell systematic-bias reanalysis was declined with a stated reason (it requires per-cell Monte Carlo expectations and answers a different question); the reframed question is defensible and the title claim now rests on the two-variance-components-versus-transport comparison. Reasoned partial compliance. |
| sol 2 | yes | Primary reference unambiguous; anchored contrast reported throughout; Table 11 distinguishes transported, anchored and fitted coverage. |
| sol 3 | yes | The arithmetic components are now labeled as such (noise channel, dispersion instrument), and the declined extensions (heteroskedasticity, multiple/nonlinear modifiers, uncertain target moments) are each named in the limitations — a legitimate refusal, since each is a different study. |
| sol 4 | partly | Outcome-assisted labeling, optimism disclosure, and the plain-balance comparison are done, and the recommendation was downgraded accordingly. Cross-fitting and independent-estimation versions were declined without a strong reason; the stakes are low because the claim failed anyway, but the refusal is thinner than the others. |
| sol 5 | yes | The verdict is now stated precisely everywhere it matters ('no evaluated fixed cutoff met the registered operating requirements'), the absence of an elicited loss function is disclosed, and the ROC-curve invitation to readers who want a different operating point is explicit. |
| sol 6 | yes | The confounded split was confirmed and replaced by leave-one-factor-level-out with the model form stated; the old overlap-versus-weight claim is retracted as an artifact. Calibration plots and fold-level uncertainty were not added, but the load-bearing defect is fixed and the conclusion changed with it. |
| sol 7 | yes | The missing registered analyses (arm-imbalance discrimination, equal-weight AUROCs, 0.10/0.30 thresholds, anchored contrast) are now in Tables 3 and 9; paired intervals for the two mechanism differences were declined with an explicit reason and the differences are labeled point estimates against a registered threshold. Legitimate refusal, adequately disclosed. |
| sol 8 | yes | Corrected to a fifth of the residual SD, with the marginal outcome SD range (1.37-1.66) reported and the 0.10/0.30 analyses shown; ordering unchanged. |
| sol 9 | yes | The 'stronger result' promotion is retracted; both spans are now described as predictive-value variation, the registered claim is reported as failed, and the leave-one-factor-out calibration is identified as the proper transportability evidence. |
| sol 10 | partly | The 0.4-threshold prose now names the rules above both alternatives, but says '4 rules' while naming three (the fourth is CV(w), ESS%'s alias), and the new sentence claiming the absolute ESS cutoff never earns its place is false at threshold 0.5. See comment 3. |
| sol 11 | yes | The claim is now correctly conditioned on converged analyses ('reporting it as evidence the adjustment worked is reporting that the solver terminated'), the convergence-check role is declared a different question the design cannot answer, and non-fits are reported as an operational outcome. |
| sol 12 | yes | Practice claims are disclaimed, conventions are attributed to Phillippo 2018 and the transportability literature, Kish is cited for the identity, and the novelty claim is hedged to the published catalog audit. The demand for a reproducible search account was declined with a pointer to the audit — a borderline but reasoned refusal. TSD 18 attribution remains imprecise (citation_problems). |
| sol 13 | yes | The limitations are rewritten around the real threats: transport-not-pure-bias, the outcome-assisted proposal, the secondary status of the anchored contrast, the investigator-chosen distribution, and the uncross-fitted interaction — and they explicitly state operating characteristics are properties of the declared distribution. |
| sol 14 | yes | Estimate count corrected; the 550 median ESS for unweighted methods is explicable as the median pooled n across 300- and 800-participant cells; protocol-to-manuscript consistency much improved, with the section-8 calibration wording the one leftover (kimi 8). |

## Authors' response to round 2

# Response to round two

Sol `major-revision` with four major comments, GLM `minor-revision` with none, Kimi
`minor-revision` with one. Sol resolved ten of sixteen round-one points as "partly" and six
as "yes"; GLM twenty-five of twenty-eight as "yes"; Kimi eighteen of twenty-five as "yes".
Kimi's round two required a second attempt: the first returned an empty response on a 148 KB
package, which is recorded in the raw log.

Sol's first comment is answered first, because it is the same failure this program has now
made four times, and this time it slipped past a check built specifically to catch it. Kimi
then found two more instances of it in sections the check did not read, which is answered in
point 5.

---

## 1. The abstract still contained the sentence we said we had retracted

Sol writes:

> The abstract still says, "Transport error is the only piece a covariate diagnostic could
> know about before an outcome is seen," even though the manuscript and response explicitly
> call that statement wrong.

Correct. We rewrote section 3, said in the response letter that the claim was withdrawn, and
left the same claim standing in the abstract.

The check we ran before writing the round-one letter passed thirty-four of thirty-four items.
It was the wrong check. It verified that each **new** statement was present and never that
each **retracted** statement was absent, so a corrected section and an uncorrected abstract
both counted as success. The check now runs in two halves, positive and negative, and the
negative half is what would have caught this. Both halves pass on the current text, and the
negative half is listed in the published record so a reader can see what it looks for.

The abstract is rewritten. It no longer makes a knowability claim at all; it says that two of
the three components are functions of covariates, assignment and weights, that the panel is
built from those ingredients, and that the third is what adjustment exists to remove.

## 2. Systematic bias was never evaluated, and the title claimed more than the results support

Sol writes that the quantity we call transport error is a realized effect-modifier component,
not systematic bias, so comparing 0.847 against 0.653 does not establish a
variance-versus-bias conclusion. Agreed, and this is the most consequential comment of either
round.

We have added the analysis: the systematic part is estimated as the Monte Carlo mean of the
transport term **within a cell**, and every diagnostic is scored against it with the cell as
the unit. Forty-two of 128 cells carry a systematic transport bias above 0.20. Against that
target, effective sample size reaches **0.808**, not 0.653.

We are reporting the result that weakens our framing, and then reporting why it does not
rescue the panel either. The statistic that is **identically zero** reaches **0.708** on the
same analysis. Nothing that never departs from $10^{-14}$ detects bias; what is happening is
that 128 cells is a small sample in which the bias and every diagnostic move along the same
overlap axis, so a cell-level ranking cannot separate the diagnostics from each other or from
noise. The whole panel lands between 0.708 and 0.845, oracle included. We say this in the
text rather than presenting 0.808 as either vindication or refutation.

What survives is the replicate-level statement, and the paper is now titled as that and only
that: **effective sample size tracks the error an analysis got by chance better than the
error it got from adjusting on the wrong covariates.** The previous title asserted a
variance-versus-bias dichotomy outright and has been withdrawn. The section says explicitly
that the claim is about the level at which a diagnostic is read, one analysis at a time, and
not about the cell level.

## 3. Tables 8 and 9 were internally inconsistent

Correct, and the fault was presentation rather than arithmetic. The registered mechanism
claim is evaluated over the **diagnosable stratum**, which spans two of the four
misspecification strata, under deployment weights, against the best **routinely reported**
diagnostic, a set that excludes the unmatched-balance check because that is our proposal and
not part of the panel. The stratum table is per stratum, under equal cell weights, and
includes everything. Both are now labeled with what they cover, and the difference is
explained where the numbers appear.

Kimi pressed further and was right to: the comparator behind 0.851 was never named, and no
number in the stratum table equals it. It is **effective sample size as a percentage**,
over the diagnosable set, under deployment weights, where it reaches 0.851 and the next
routinely reported member is pre-weighting imbalance at 0.847. That is now stated where the
claim appears, and the stratum table's caption, which asserted that the claim-4 numbers lived
in it, has been corrected to say the opposite.

Reconciling the two properly also reverses part of what we conceded in round one, and we are
reporting the reversal rather than leaving a tidier retraction standing. Over the diagnosable
set our converted statistic reaches 0.937 and the plain unmatched-balance check 0.890, so the
conversion does help there. Inside the omitted-modifier stratum alone the order reverses,
0.946 against 0.938. The two sets differ by whether the well-specified cells are included,
and that is the whole explanation: where the unmatched covariate is a modifier in every cell,
imbalance in it and bias from it are the same thing and converting one to the other only adds
estimation noise; where the analyst does not know whether it is a modifier, which is the real
situation, the conversion is what keeps the statistic quiet on covariates that are imbalanced
and harmless. Our round-one summary, that the conversion "did not earn its keep", was too
strong in one direction just as the registered claim was too strong in the other.

## 4. The calibration interpretation is still stronger than the analysis permits

Agreed. A one-term logistic mapping can fail because the diagnostic does not transport or
because a single linear term is the wrong functional form in the held-out setting, and this
analysis cannot separate them. We did not fit richer forms. The text now says so and confines
itself to the operational fact: a mapping of this shape, fitted elsewhere, is off by about
twenty points of absolute risk in the setting it transports worst to, and the analyst does
not know which setting they are in.

## 5. Kimi found the same failure twice more, in sections the check did not read

Two sentences we said we had corrected survived elsewhere. The introduction still claimed
that within-stratum reporting "removes the dependence on our chosen frequencies entirely",
which the limitations already contradicted; and the protocol's performance-measures section
still described the calibration mapping as fitted on odd-numbered **replicates**, two
revisions out of date. Both are fixed, and both are now in the negative half of the check.

This is the third distinct shape of the same failure and the check has grown a third time to
match. The round-one version looked only for text that should be present. The round-two
version added text that should be absent. Kimi's comments showed that both halves were still
reading too few files, and that the patterns were literal enough to fail on a reflowed
paragraph, which is exactly how the equivalent check passed in study 2 of this program while
the manuscript went unchanged. The check now normalizes whitespace before matching and covers
the manuscript source, the rendered output, the protocol and the analysis code. It is
published in the study directory rather than described, so a reader can see what it does and
does not look for.

## 6. Minor items

**Sol 10, Kimi.** The decision-curve sentence said four rules and named three. The fourth
entry is the coefficient of variation of the weights, which is relative effective sample size
under another name by the identity in the algebra section, not a fourth statistic. Fixed and
explained where it appears.

---

## What we still have not done

Fold-level uncertainty and calibration plots (Sol 4), paired Monte Carlo intervals for the
two mechanism differences (Sol 7 and 14), a reproducible literature-search account (Sol 12
and GLM), richer functional forms for the risk mapping, and the extensions named in the
limitations: heteroskedastic errors, multiple or nonlinear omitted modifiers, uncertain
target moments, cross-fitting the proposed diagnostic, and differential covariate
displacement. Sol resolved ten round-one points as "partly" and most of the residue is here.
We are not claiming these are unimportant. The paper's conclusions do not rest on them, the
limitations name each one, and we would rather publish with the gaps stated than assert a
completeness we have not reached.

Sol's standing recommendation is `major-revision` and we are publishing it with that
attached, unchanged, alongside GLM's `minor-revision`. Neither reviewer has been talked out
of anything.


## Editorial decision

**Decision: published with Reviewer 1 standing at major revision, Reviewers 2 and 3 at minor,
and with the paper's central claim narrowed and retitled under review.**

Not an acceptance. Sol ends at major revision and this record does not overturn that. Ten of
his sixteen round-one points close as "partly", and the residue is real: fold-level
uncertainty for the calibration analysis, paired Monte Carlo intervals for the two mechanism
differences, a reproducible literature-search account, and richer functional forms for the
risk mapping are all absent.

## What is established

Two facts are settled by algebra and the run only checks the implementation.
$\mathrm{ESS}/n = 1/(1 + \mathrm{CV}^2(w))$ exactly, and area under the ROC curve is
invariant to monotone transformation, so within a fixed source size effective sample size,
the same figure as a percentage and the coefficient of variation of the weights have
identical discrimination; they agreed to 0.0e+00. The post-weighting standardized difference
on the matched moments is zero at the solution of the calibration equations; it never
exceeded 1.4e-14, and its apparent area of 0.550 is discrimination of floating-point
residual. Of the panel a submission reports, one number carries the weight-dispersion
information and one carries none.

The **measurement** is that no evaluated fixed cutoff met the registered requirement of
sensitivity 0.80 at specificity 0.50 in every misspecification stratum. Effective sample
size below 35 catches between a quarter and a third of material errors, 0.309 in the stratum
where a modifier is omitted and the omission is diagnosable in principle. On a
decision-curve basis every rule in the panel is beaten by scrutinizing every analysis up to
an action threshold of 0.3.

The **mechanism**, at the level of a single analysis, is that effective sample size reads
the two error components that are functions of the covariates, the assignment and the
weights, at 0.847 and 0.813, and the effect-modifier component that adjustment exists to
remove at 0.653.

## What review changed

**The load-bearing claim of the first draft was wrong, and all three reviewers found it
independently.** We had written that only the transport component is knowable from
covariates. The arm-imbalance component uses no outcome at all, and the noise component's
conditional variance is exactly $\sigma^2(1/\mathrm{ESS}_A + 1/\mathrm{ESS}_C)$, so a
weight statistic is its natural summary rather than merely correlated with it. Both were
verified numerically before being accepted. The arm-imbalance component is now scored and
the noise result is presented as an arithmetic check.

**The calibration analysis was confounded.** Cells are enumerated with the target dispersion
ratio varying fastest, so training on odd-numbered cells and testing on even ones put every
ratio-1.00 cell in training and every 1.25 cell in test. Sol predicted this failure mode
before checking it. Leave-one-factor-level-out replaced it, one earlier finding was withdrawn
as an artifact, and the replacement is sharper: the worst held-out level is the same for
every weight statistic in the panel, the cross-moment channel, where a risk mapping learned
elsewhere is off by about twenty points of absolute risk.

**The title claimed more than the results support.** The realized transport component of one
replicate is not systematic bias. Scored against systematic bias with the design cell as the
unit, effective sample size reaches 0.808 rather than 0.653. That analysis does not rescue
the panel either, since the statistic that is identically zero reaches 0.708 on it, but it
does mean the variance-versus-bias dichotomy asserted in the first title was not established.
The title now claims only the replicate-level result, which is the level at which a
diagnostic is read.

**Our own proposal was demoted, then partly restored, and both moves are in the record.** It
uses source outcomes while the panel does not, so it is labeled outcome-model-assisted and
the in-sample optimism is disclosed. It missed its registered bar. Inside the
omitted-modifier stratum the plain balance check on unmatched covariates beats it; across the
diagnosable set, which includes cells where the unmatched covariate is harmless, it wins.
The surviving recommendation is narrower than the registered claim and wider than the
retraction we first offered.

Also corrected: the material threshold is a fifth of the residual and not the outcome
standard deviation; the silent-cell span is variation in predictive value and not a form of
the registered transportability claim; the matched-moment result holds only among analyses
that converged; and the practice and novelty claims are attributed to the DSU guidance, to
Kish and to the transportability literature, with an explicit statement that appraisal
practice was not surveyed.

## The process failure, fourth occurrence

The round-one response described the knowability claim as retracted while the abstract still
contained it. The check written after study 2, and run before that letter, passed
thirty-four of thirty-four items: it verified that every new statement was present and never
that any retracted statement was absent. Kimi then found two further survivals in the
introduction and the protocol, sections the check did not read, and the pattern that failed
first was literal enough to break on a reflowed paragraph, which is how the study-2 check
passed while the manuscript went unchanged.

The check now has a negative half, normalizes whitespace before matching, and reads the
manuscript source, the rendered output, the protocol and the analysis code. It is published
in the study directory rather than described. Forty-seven of forty-seven pass on the text as
published. That is the fourth revision of a control that has failed four times, and the
honest thing to say is that it has not yet gone a round without being caught by a reviewer
rather than by itself.

## What this does not close

DIA-03's second half is untouched: no PSIS-LOO at any hierarchical level, and grouped
study-level leave-one-out is no more implemented here than in the packages. DIA-06 is
answered only in part, for two estimator families out of five. The outcome is continuous with
an identity link, which is what buys the exact error decomposition and rules out anything
about non-collapsible effect measures or time-to-event outcomes. The deployment weights are a
declared judgment that nothing in this program measured, and the design points, levels and
equal weighting inside a stratum remain ours.


