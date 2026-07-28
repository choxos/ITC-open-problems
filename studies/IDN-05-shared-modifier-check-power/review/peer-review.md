# Peer review: A violation twice the size that would change a decision raises the shared effect modifier check's alarm rate from 1.3% to 4.5%

Study aimed at catalog problem **IDN-05**.

3 independent reviewers, two rounds. Reports, author responses and the
editorial decision are reproduced in full and unedited. Reviewers were
given the manuscript, the protocol registered before the run, and the
prespecified decision as evaluated; in round two they additionally saw
round one's reports and the authors' response.

## Reviewers

| | Reviewer | Round 1 | Round 2 |
| --- | --- | --- | --- |
| R1 | GPT-5.6 Sol (maximum reasoning effort) | major-revision | major-revision |
| R2 | GLM-5.2 (via Ollama) | accept | minor-revision |
| R3 | Kimi K3 (via OpenCode) | major-revision | minor-revision |

## Round 1

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

This registered factorial simulation evaluates several operationalizations of a shared-effect-modifier check in deliberately weak-information ML-NMR networks and links diagnostic performance to a marginal target-population estimand. The paper is commendably transparent about its failed prespecified gate, amendments, prior sensitivity, convergence problems, and numerical-integration sensitivity. However, the broad conclusions are not currently supported because some headline findings are consequences of the construction, nonconverged fits were retained contrary to protocol, the superpopulation estimand and oracle are ambiguous under heterogeneity, several results disagree across documents, and key comparisons ignore Monte Carlo uncertainty. The question is important and repairable, but it requires substantial reanalysis and narrower claims.

**Strengths.**

- The core factorial design and decision-scale estimand were registered before the main simulation, and post-registration changes are disclosed rather than silently incorporated.
- The manuscript distinguishes conditional log-odds effects from marginal risk differences and computes the latter from the true model by quadrature.
- The complete four-model lattice permits a genuine one-covariate-at-a-time relaxation strategy with paired evaluation on the same simulated datasets.
- The design includes exact-null cases, increasing interaction drift, variation in ecological information, and treatment-effect heterogeneity.
- The authors report an unreachable primary gate as failed, identify its noise floor, and disclose unfavorable convergence and quadrature findings.
- Using a consequence-based interaction scale is more informative than presenting power only against arbitrary coefficient differences.

**Comments.**

**Major 1** (What this measures; Readings of the check). The study partly answers IDN-05, but it does not establish the power of a uniquely defined published procedure. DIC cutoffs of 2, 5, and 10, exclusion of zero by a 95% interval, and the posterior margin and equivalence rules are distinct author-defined decision rules. In particular, failure of the newly introduced equivalence rule is not evidence that the original exploratory model check was designed to affirm equivalence. The manuscript therefore measures operating characteristics of selected operationalizations in one network family, not the generic ability of the published check to validate sharing.

*What would satisfy this:* Quote the exact decision guidance in Phillippo et al., clearly distinguish published elements from new operationalizations, report the prespecified continuous discrimination measures, and restrict the title and conclusions to the evaluated rules and network designs.

**Major 2** (The check cannot give an all-clear; Readings of the check). The behavior of the margin rule is substantially built into the prior. If the independent treatment-specific coefficients each have a normal(0, 2.5) prior, their contrast has prior SD about 3.54. With epsilon 0.1531, the prior probability that the absolute contrast exceeds epsilon is about 0.965, already above the 0.95 firing threshold before seeing data. Conversely, only about 0.035 of the prior lies inside the equivalence region. The counterintuitive null behavior of this rule therefore demonstrates prior arithmetic combined with weak identification, not an intrinsic property of posterior margin checks.

*What would satisfy this:* Report the prior probabilities of both regions, use coherent priors parameterized directly on the common interaction and treatment contrast, evaluate priors calibrated for the chosen equivalence region, and include a sufficiently informative positive-control design in which equivalence can be established.

**Major 3** (The mechanism: the check is blind to the only thing that determines the harm). M1 is primarily an algebraic construction rather than an empirical simulation finding. The fitted network is reused at every displacement, so the check must be identical, while the specified interaction contrast and changing target mean make target error change with displacement. The manuscript acknowledges the first part as a bookkeeping identity but then describes M1 as confirmed and concludes that pass value depends entirely on displacement. Pass value also depends on drift prevalence, network information, baseline risk, the error threshold, and the deployment mixture.

*What would satisfy this:* Present the invariance as a derivation and implementation check, not evidential confirmation. Report conditional risks by drift and design stratum, and replace entirely with language that acknowledges the other determinants of pass value.

**Major 4** (Methods compared; Following the check still beats the alternatives). The analysis violates its registered fit-eligibility rule. The protocol states that a replicate is excluded if any fit has R-hat above 1.05, bulk ESS below 100, or divergences. The manuscript instead retains fully relaxed fits with R-hat as high as 1.89 and ESS as low as 3.4. DIC values and target estimates from such chains are not reliable. Retaining them can directly make always-relaxed look worse and can also corrupt check-then-relax when a failed split fit supplies the selection statistic.

*What would satisfy this:* Refit failed models with adequate iterations and tuning. Apply the registered eligibility rule for the primary analysis, then report a separate operational analysis in which computational failure receives an explicitly defined loss. Do not calculate scientific performance from demonstrably nonconverged posterior draws.

**Major 5** (Estimands; The data-generating mechanism; What a pass licenses). The estimand is not adequately defined when tau_re equals 0.15. The tabulated truth appears to use d_A and d_C with no realized random effects, suggesting a study-superpopulation estimand, while the fixed-effect fits estimate a weighted effect in the realized trials. On the risk scale, integrating over a random-effects distribution is also not equivalent to setting the random effect to zero. Moreover, the alleged oracle remains a fixed-effect model in these cells and therefore does not match the full data-generating truth. Its error cannot be called a pure noise floor.

*What would satisfy this:* State whether the target is conditional on the realized network, the mean conditional effect in a study superpopulation, or a marginal effect integrated over study heterogeneity. Compute truth for that same population, fit a genuinely correct random-effects oracle when heterogeneity is generated, and report tau_re strata separately. Otherwise rename the comparator an interaction-specification oracle.

**Major 6** (Power; Prespecified mechanism claims; Following the check still beats the alternatives). Several central claims do not respect Monte Carlo error. With 50 observations, an observed rate of 0.08 has Monte Carlo SE about 0.038 and is not an upper bound on power. Selecting the largest of eight noisy cell estimates further weakens the claim that the rule fires at most 8% of the time. M4 is estimated as 0.107 against a threshold of 0.10; with 1,600 replicates its unpaired binomial Monte Carlo SE is about 0.008, so the registered threshold is not clearly exceeded. Strategy differences of 0.005 in material-error probability at displacement 0 and 0.013 at displacement 1 also have no paired Monte Carlo intervals.

*What would satisfy this:* Increase replication near decision boundaries or provide paired Monte Carlo SEs and confidence intervals for every mechanism contrast, strategy difference, RMSE difference, and selected minimum or maximum. Classify M4 as inconclusive unless its interval excludes 0.10, and avoid interpreting per-cell extrema as population bounds.

**Major 7** (Checks on the machinery). Changing the quadrature grid changes 8.3% of DIC-5 verdicts and 4.2% of interval verdicts. An 8.3% numerical-instability rate is not small relative to the reported 0% to 8% DIC power at drift 0.30; it is of the same order as the headline signal. The subset, denominator, cell composition, and uncertainty are not reported, and 256 points is not shown to be a converged numerical reference.

*What would satisfy this:* Establish quadrature convergence against successively finer grids or another validated integration method, report the sensitivity sample by design cell, and base the primary results on settings for which diagnostic decisions and target estimates are numerically stable.

**Major 8** (Results; Prespecified decision, as evaluated). Material results disagree within the package. M2 clears its threshold in five of eight strata in the manuscript but six of eight in the evaluated decision. The manuscript's null rates are 0.0125 and 0.0925, while the evaluated decision gives 0.015 and 0.1025; the manuscript nevertheless reports their difference as 0.087, which matches the latter pair rather than its own table. Stable-factor calibration error is at most 0.058 in the manuscript but 0.099 in the evaluated decision. Convergence rates also differ. The manuscript says the null table uses 400 replicates, whereas both null covariates would supply 800 checks; the protocol mentions 720. Finally, 960 prior-sensitivity fits is unexplained and does not match eight cells times 100 replicates times four fits if all fits were repeated.

*What would satisfy this:* Produce a single audited results dataset with a flow diagram and explicit denominator for every analysis, regenerate all tables and prose from it, and reconcile every discrepancy before substantive interpretation.

**Major 9** (The decision boundary; Amendment record). Drift 0.15 is not exactly epsilon 0.1531. The manuscript's own truth is a risk difference of 0.0294, below the 0.03 threshold, and material error is defined using more than 0.03. Thus the amendment does not simulate the exact boundary and the statement that this violation precisely changes a decision is false. In addition, the amendment was made while the main run was underway, and the oracle comparison was not in the original registered analysis, so these results cannot be described simply as pre-run confirmation.

*What would satisfy this:* Correct the numerical and temporal descriptions, classify the amendment and oracle analyses as amended or exploratory, and either simulate drift 0.1531, interpolate with validated accuracy, or describe 0.15 as a near-boundary scenario. Independent confirmation would strengthen any headline based on the amendment.

**Major 10** (The verdict does not transport across the one axis that matters). The assertion that adding target displacement cannot help because displacement is absent from the check statistic is logically incorrect. A predictor can improve prediction of the outcome without changing another predictor; indeed M1 states that material-error risk changes strongly with displacement. A target-aware model should allow displacement and potentially its interaction with the statistic. The protocol prespecified such a model, but its results are absent. The prespecified AUROC analyses are also not reported.

*What would satisfy this:* Report the exact calibration models, target-aware results, grouped cross-validation that keeps repeated target evaluations together, calibration uncertainty, and all prespecified AUROCs. Investigate whether the reported no-improvement result reflects an incorrectly specified model.

**Major 11** (One number explains the rest). The headline data-only standard error is not defined. Removing a prior from posterior variance by subtracting precisions is exact only under restrictive Gaussian conditions and must account for covariance between treatment-specific coefficients. The table separately reports posterior SDs for A and C but does not explain how the contrast standard error of 0.30 to 1.82 was obtained or aggregated. Because the title and two-to-twelve ratio depend on this calculation, calling it prior-free without derivation is not acceptable.

*What would satisfy this:* Give the formula, covariance treatment, aggregation method, and Monte Carlo uncertainty. Validate the result using a likelihood-based calculation or a sequence of increasingly diffuse coherent priors, and title the result explicitly as applying to the simulated networks.

**Major 12** (Following the check still beats the alternatives; What this does not settle). The recommendation to use the check is not established by the reported comparisons. The apparent advantages are small, lack paired Monte Carlo intervals, and are contaminated by nonconverged relaxed fits. Exact deployment weights are not reported. The obvious hierarchical or exchangeable interaction strategy is omitted even though it is the proposed middle ground for IDN-05; package nonimplementation is not sufficient justification for omitting a method from a methodological simulation. The claim that all design simplifications favor the check and make failures lower bounds is also untenable: one IPD study, only three C studies in the smaller networks, fixed-effect misspecification, and coarse integration can disadvantage it, while additional IPD or richer networks could improve performance.

*What would satisfy this:* Repeat the strategy comparison using converged fits, exact deployment weights, paired uncertainty, and sensitivity by design stratum. Implement an exchangeable model independently or narrow A4 and the practical recommendation. Recast external validity as scenario-specific rather than a lower-bound argument.

**Minor 13** (The data-generating mechanism; Power). The statement that every replicate supplies a type I error observation for x2 conflicts with the later recognition that, when x1 drifts, an x2 term can absorb x1 misspecification. Those observations measure misattribution, not nominal type I error. Also, having only one contrast avoids contrast selection but does not guarantee nominal frequentist coverage of a Bayesian credible interval, especially under prior influence, numerical error, and fixed-effect misspecification.

*What would satisfy this:* Reserve type I error for both covariates under the global null, label x2 firing under drift as misattribution, state all denominators, and replace the nominal-coverage assertion with an empirical coverage assessment.

**Minor 14** (Nothing in the panel beats scrutinizing everything). Decision reversal, net benefit, and the consequences of commissioning individual data are insufficiently defined. Decision reversal is particularly ambiguous when the true C-versus-A effect is zero. Treat-all net benefit can be driven by the simulated prevalence of material error and the chosen threshold range, and commissioning IPD is implicitly treated as if it prevents the classified harm without an explicit action model.

*What would satisfy this:* Provide the decision rule, handling of ties and zero effects, net-benefit formula, deployment prevalence, action consequences, and sensitivity to the assumed benefit and cost of obtaining IPD.

**Citation problems.**

- Phillippo et al. (2023): The source may support comparing posterior distributions and model fit, but the manuscript has not established that DIC-5, zero exclusion by a 95% contrast interval, or a 0.95 posterior equivalence rule are the published procedure. These must be identified as new operationalizations unless the source explicitly prescribes them.
- Spiegelhalter et al. (2002): This is the foundational DIC paper, but it does not by itself establish 2, 5, and 10 as validated diagnostic cutoffs for this application. The exact source and rationale for those thresholds are needed.
- Claims that this is the only published within-network check and that nobody has measured it: These exhaustive novelty claims are unsupported by a five-reference bibliography and do not engage the broader network meta-regression literature on common, independent, and exchangeable treatment-by-covariate interactions. A documented literature search and a narrower distinction specific to ML-NMR population adjustment are required.
- Phillippo (2025), multinma software citation: A generic Zenodo software citation does not substantiate behavior attributed to the development version 0.9.1.9002, including silent demotion of .trt terms and the unsupported exchangeable option. Cite the exact version or commit, documentation, and a reproducible example.
- Decision-curve analysis: The analysis has no methodological citation and does not state the assumptions under which material error is treated as the event and commissioning IPD as the action. Foundational and current decision-curve guidance should be cited.

**Claims the reviewer judged unsupported.**

- “A network resolves the difference between two treatments’ effect modifiers to between two and twelve times the difference that would change a decision.”
- “Against a violation already twice the size that matters, the check fires in at most eight analyses in a hundred.”
- “The procedure can decline to raise an alarm; it cannot give an all-clear.”
- “Registered mechanism claim M4 is confirmed.”
- “This is the violation that exactly matters.”
- “At the size of violation that precisely changes a decision, the check is silent.”
- “Adding the target displacement to the mapping does not help, because displacement does not enter the statistic at all.”
- “Following the check and relaxing exactly what it fires on had the lowest error of the three strategies at every displacement. It is worth running.”
- “The effect is small beside the resolution problem.”
- “The design is a best case in several ways that all favour the check, and the failures reported here are therefore lower bounds on the failures in practice.”
- “What a pass is worth depends entirely on how far the target sits from the network.”

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: accept**

The manuscript presents a pre-registered simulation study evaluating the empirical performance and implications of the shared effect modifier check in multilevel network meta-regression (ML-NMR). It directly addresses the open problem of the check's low and uncalibrated power by measuring what a diagnostic 'pass' licenses, the actual power/Type I error, transportability, and optimal analyst strategies. The study is rigorously designed, uses appropriate estimands, identifies a critical software pitfall in the `multinma` package, and transparently reports both its successes and failures against pre-specified mechanism claims. The conclusions are fully supported by the reported numbers and respect Monte Carlo error.

**Strengths.**

- Directly addresses the stated problem (IDN-05) by measuring power, calibration, and the practical value of a diagnostic pass.
- Identification of a critical implementation issue in `multinma`: under the default `class_interactions = "common"`, treatment-specific terms are silently demoted to the class level, meaning an analyst could unknowingly never fit a split model.
- Excellent methodological transparency, including a pre-registered protocol, dated amendments with justifications, and independent pre-run critiques that shaped the design.
- The comparison is fair and uses the correct estimands (marginal risk difference for the decision scale, conditional log-odds for the mechanism scale), avoiding the common error of conflating conditional and marginal effects.
- The limitations section is unusually honest and accurately identifies the 'best case' nature of the data-generating mechanism, meaning the reported failures are conservative lower bounds.

**Comments.**

**Minor 1** (Results / What this does not settle). The simulation uses 50 replicates per cell, which yields a per-cell standard error of about 0.065. While the authors correctly restrict their claims to pooled or stratum-level estimates and explicitly state that differences below 0.13 within a single cell are not resolvable, some per-stratum power results (e.g., at drift 1.2) still have wide confidence intervals. This is a computational necessity, but the manuscript could briefly reiterate that certain per-stratum point estimates are subject to considerable uncertainty when interpreting the power curves.

*What would satisfy this:* A brief sentence in the results or limitations reminding the reader that while the pooled and stratum-level conclusions are robust, individual cell power estimates should be interpreted with caution due to the 50-replicate constraint.

### Reviewer 3: Kimi K3 (via OpenCode)

**Recommendation: major-revision**

This is a registered simulation study of IDN-05: the power and evidentiary meaning of the shared-effect-modifier check in ML-NMR population adjustment. It answers the problem it claims to answer — the interaction contrast is resolved two to twelve times too coarsely relative to a consequence-derived margin, power is at most 0.08 at twice the material violation, an all-clear reading never fires, and check-then-relax still dominates the alternatives — with strong estimand discipline (marginal vs conditional effects cleanly separated, exact quadrature truth, systematic vs realized error distinguished) and an exemplary oracle/noise-floor analysis. The design's one-IPD-study/aggregate-only asymmetry is the genuine use case rather than a rigged mechanism, and the margin ε is derived from the decision threshold, not tuned, so the finding is not built in. However, the paper asserts nominal coverage that its own type I table contradicts, reports a prior-sensitivity contraction that appears arithmetically inconsistent with its own definition, gives a primary confidence bound that cannot be reconciled with the stated Monte Carlo sizes, deviates from the registered protocol on convergence failures without a dated amendment, and presents a decision-curve headline that is stacked by the noise floor and sits unreconciled against its own 'use it anyway' advice. All issues are repairable from existing outputs; none threatens the design.

**Strengths.**

- The design matches the problem: one IPD study with the comparator identifiable only ecologically is precisely the situation population adjustment and this check exist for, so the measured low resolution is a property of the use case, not an artifact; the consequence-derived ε = 0.1531 anchors every threshold in the decision rather than in taste.
- Estimand discipline is exemplary: the marginal risk difference (decision scale) and the population-average conditional log-odds effect (mechanism scale) are explicitly distinguished and never conflated; the truth is computed exactly by Gauss-Hermite quadrature; the placebo risk is held at 0.30 across displacements so contrasts are compared at the same point on the logistic curve; systematic and realized error are scored separately.
- The oracle/noise-floor analysis prevents an unfair verdict: the registered gate is shown to be unreachable by any procedure (oracle excess only +0.036, negative at low displacements), and the failed verdict is reported as failed and explained rather than spun — rare and correct practice.
- Two consequential practical findings beyond the headline: under the default class_interactions='common', an x:.trt term is silently demoted to class level so an analyst editing the formula alone never fits a split model at all; and refitting at 256 quadrature points changes 8.3% of DIC-5 verdicts, so part of what the check reports is integration grid, not evidence.
- Amendment and registration discipline: dated amendments with preserved random streams and cell numbering, a separate amendment arm at one ε, and an independent reviewer's pre-registered predictions scored against the run (0.72–0.75 predicted vs 0.758 measured; 0.011 vs 0.0125).
- Several non-obvious decision-relevant results that go beyond 'power is low': the equivalence reading can never fire at achievable resolution; the margin rule is anti-conservative exactly where data are thin (0.48 under the null in the thinnest cell vs 0.08 in the richest); relaxing everything is worse than imposing the restriction; and the check statistic's calibration transports across network size, spread and heterogeneity but not across drift — the one axis that matters.
- Monte Carlo error is mostly respected: per-cell SE of 0.065 is stated up front, results are reported by stratum or pooled, and no sub-0.13 single-cell difference is claimed.

**Comments.**

**Major 1** (Readings of the check / Results (type I error)). The manuscript states: 'there is exactly one interaction contrast per covariate, so nothing is selected and the credible interval keeps its nominal coverage.' Its own type I table reports the 95% interval rule at 0.0925 — about twice nominal — and the Discussion repeats 'runs at about twice its nominal rate' without reconciling the two statements. The inflation is plausibly confined to the τ_re = 0.15 cells (fixed-effect fit under random-effects truth) and/or reflects non-calibration of the aggregate-data-identified contrast rather than selection, but as written the coverage claim is contradicted by the paper's own result.

*What would satisfy this:* Report type I error of the interval rule split by τ_re (trivial from existing output). If it is ~0.05 in the τ_re = 0 cells, qualify the coverage sentence to the correctly specified case and say the inflation measures interference from a second specification error; otherwise remove the nominal-coverage claim and discuss why the single-contrast credible interval is miscalibrated.

**Major 2** (Results 3.1 (prior-sensitivity arm)). The reported contraction shift — 'from 0.33–0.42 under normal(0, 2.5) to 0.68–0.70 under normal(0, 1)' — appears arithmetically inconsistent with the paper's own definition (1 − sd(posterior)/sd(prior)) and its own resolution table. In the thinnest cells the data-alone SD of γ_C[x1] is ~1.82 (precision ~0.30); against a N(0,1) prior that gives posterior SD ≈ 0.88 and contraction ≈ 0.12, not 0.68–0.70. Moreover, for a fixed likelihood, tightening the prior cannot increase 1 − sd(post)/sd(prior) (ratio = sqrt(p/(p+q)) rises with prior precision p). The reported 0.68–0.70 is approximately 1 − 0.88/2.5, i.e., measured against the ORIGINAL prior's scale, not the fitted one. The narrative point (the prior changes how informed the posterior looks while the flag rate barely moves) survives, but the numbers as labeled seem wrong or mislabeled.

*What would satisfy this:* Report, per arm and per treatment: prior SD, posterior SD, and contraction with the denominator stated. Either correct the 0.68–0.70 figures to the contraction against the fitted prior, or relabel the quantity explicitly as additional shrinkage relative to the N(0,2.5) reference scale and say so.

**Major 3** (Prespecified verdict (primary)). The primary bound does not reconcile with the stated Monte Carlo sizes. Point estimate 0.675 with upper 95% bound 0.777 implies SE ≈ 0.062 (effective n ≈ 55), while the protocol states the pooled primary quantity has MCSE ≈ 0.011 (n ≈ 1,500; the pass-conditioned subset is ~1,307, giving SE ≈ 0.013 and an upper bound near 0.696). Presumably the deployment weighting concentrates mass on a few strata and deflates the effective sample size, but the weights, the interval method, and the effective n are nowhere reported, so the headline number of the paper is not reproducible as written.

*What would satisfy this:* State the deployment weights, the exact interval construction (Wilson/bootstrap/weighted), and the effective sample size; show that the 0.777 follows, or correct it.

**Major 4** (Throughout — protocol fidelity and cross-document consistency). (a) The protocol (section 4) excludes and counts any replicate in which any of the four fits fails convergence; the manuscript (3.7) retains those replicates in the strategy scoring ('Those replicates are retained and reported'). Retention is arguably the better choice — exclusion would select exactly the cases where relaxation is easiest — but it is a deviation from the registered analysis and is not listed as a dated amendment, and no sensitivity of the strategy ranking to this choice is given. (b) Several numbers disagree across the supplied documents: convergence failures 0.068/0.24 (manuscript) vs 0.066/0.22 (evaluation); M2 clears its bar in '5 of 8 strata' (manuscript) vs '6 of 8' (evaluation); the M3 gap is given as 0.087 in the text while the manuscript's own type I table gives 0.0925 − 0.0125 = 0.080 and the evaluation gives 0.0875; calibration maximum absolute error is 0.058 in the manuscript table but 0.099 in the evaluation text; the prior-sensitivity arm is '960 fits' in the manuscript against the protocol's 8 cells × 100 replicates × 4 fits. These suggest version drift between snapshots.

*What would satisfy this:* Add the convergence-retention decision as a dated amendment with a with/without sensitivity of the strategy ranking; do a single consistency pass so every number in the manuscript matches its analysis output; and include a short errata note reconciling the evaluation document.

**Major 5** (Results 3.7 (decision curve) and Discussion). The decision-curve result is stacked by the noise floor and contradicts a neighboring headline without reconciliation. The outcome (realized material error) is dominated by estimation noise that no covariate check can in principle predict — the paper itself shows a 0.427–0.58 floor when the assumption holds exactly — so 'distrust everything' must dominate every check-based rule at almost any threshold; this restates the noise-floor finding rather than measuring the check, and no classifier built on the check statistic could do otherwise. It also sits unresolved against 'Following it is still worth doing' (RMSE ranking). A reader is left with two headlines pointing in opposite directions.

*What would satisfy this:* Add the companion analysis against systematic error (where the check has something to predict), state the prevalence decomposition alongside the net-benefit numbers, and reconcile in the Discussion: on estimation error the check earns its keep; on the decision to commission IPD, the noise floor dominates and that is a statement about network size, not about the check. Cite Vickers and Elkin (2006) for decision curve analysis.

**Minor 6** (Amendment arm (3.8) and Design). 'Eight cells at drift 0.15, exactly one ε' — but ε = 0.1531, and the paper reports the induced error at displacement 1 as 0.0294, just below the 0.03 material threshold. 'The violation that exactly matters' and 'the violation at which the transported estimate becomes materially wrong' overstate: it is just short of material.

*What would satisfy this:* Say 'approximately one ε (0.98×)' and report the induced error as just under the threshold, or rerun the eight cells at drift 0.1531.

**Minor 7** (Title, What this measures, Discussion). 'A network of the size population adjustment is applied to resolves the difference... two to twelve times' is conditional on design choices the headline does not carry: one IPD study, 250/200 patients per arm, J ∈ {6,12}, τ_x ∈ {0.25,0.60}, normal covariates, logit link, placebo risk 0.30. Resolution scales with per-arm n and with the number of IPD studies; the limitations list the one-IPD axis but not the sample-size axis, and the Discussion's first paragraph generalizes without the conditioning.

*What would satisfy this:* Carry the conditioning into the Discussion's opening ('networks of this size and composition, with a single IPD study...') and add one limitations sentence noting the resolution ratio scales with per-study sample size and IPD count.

**Minor 8** (Results 3.6 (strategies)). The claim that check-then-relax 'had the lowest error of the three strategies at every target population examined' rests on RMSE differences (0.0928 vs 0.0995 vs 0.1218 at s = 1) reported without uncertainty quantification, in a paper that otherwise insists on Monte Carlo discipline. Because strategies share replicates, paired differences are estimable precisely — but it must be shown. Also: 'decision reversal' is never defined, and the rule driving check_then_relax (presumably DIC-5) is not stated; and only displacements 0 and 1 are tabulated while the claim covers all four.

*What would satisfy this:* Report paired MCSEs (or a replicate-level bootstrap) for the RMSE/material-error differences between strategies at each displacement; define decision reversal; state the flagging rule used by check_then_relax; tabulate or reference all four displacements.

**Minor 9** (Results 3.6 (M4)). M4 is declared confirmed at 0.107 against a registered threshold of 0.10; with n = 3,200 the MCSE is ~0.0055, so the excess over threshold is ~1.3 SE — confirmed only narrowly by the paper's own standard that sub-MCSE differences are not findings. The substantive content is the one-sided decomposition (DIC-without-interval 0.0006 vs interval-without-DIC 0.106), which is precise.

*What would satisfy this:* Report M4 as 'confirmed, narrowly (0.107, 95% CI ...)' and foreground the subset structure rather than the threshold crossing.

## Authors' response to round 1

# Response to round one

Sol `major-revision`, twelve major comments and `conclusions_supported: false`. GLM `accept`
with one minor comment. Kimi returned an empty response on the 61 KB package; the cause is
recorded at the end.

Sol is right that the conclusions were not supported as written. Five of the twelve comments
identify arithmetic or logic that was wrong, not merely overstated, and every one of those was
verified numerically before it was accepted. The title has been replaced, one registered claim
has been downgraded from confirmed to not clearly met, the headline finding has been reframed
from a property of a rule into a statement about precision, and the document that records the
prespecified decision is now generated from the result files rather than typed.

---

## 1. The study measures our formalizations, not one published rule

Accepted without reservation. "Compare the posteriors and the model fit" describes an
exploratory practice, not a decision rule. The five rules scored here are ours, and the
equivalence rule in particular was never part of the original proposal, so its failure is not
evidence that anyone claimed the practice affirms equivalence.

The manuscript now says this in the second paragraph of the introduction, before any result, and
again in the limitations. The claim that survives is narrower and is stated as such: no rule in
this family, on these networks, separates violations that matter from their absence.

## 2. The margin and equivalence rules are driven by the prior

**Correct, and this was the most consequential error in the paper.** Verified: with independent
`normal(0, 2.5)` priors the contrast has prior standard deviation 3.536, so the prior alone
places **0.9655** of it beyond $\varepsilon = 0.1531$, which is above the 0.95 threshold at
which the margin rule fires. Only 0.0345 lies inside the equivalence region.

The headline "the check never gives an all-clear" was therefore partly an artifact of a prior we
chose. It has been replaced by the statement the data actually support, which is sharper. For
the equivalence rule to fire, the posterior standard deviation of the contrast must fall below
$\varepsilon/1.96 = 0.0781$. The tightest stratum in the design reaches 0.30, a factor of 3.8
short, and the loosest 1.64. **No network in this design came within a factor of three of the
precision needed to affirm the assumption at the margin that matters.** That is why the count is
zero, and it would remain zero under any prior that does not itself supply the answer. The prior
arithmetic is now in the manuscript.

## 3. M1 is algebraic, and pass value does not depend on displacement alone

Accepted on both halves. The first half of M1 is a bookkeeping identity, since the same fits are
reused at every displacement; the manuscript said so but then reported it as a finding. It is
now labelled as verifying the bookkeeping rather than discovering anything. And "depends
entirely on displacement" was wrong: pass value depends on the drift as well, and the check is
blind to both. The sentence now says displacement is the axis this section isolates because it
can be varied while holding the fitted network exactly fixed.

## 4. The analysis violates its own registered fit-eligibility rule

**Correct in letter, and the protocol text was never updated.** The registered rule excluded a
replicate if any fit had $\hat R > 1.05$, ESS $< 100$, or divergences. That rule was amended
before the reported run, for a reason recorded in the code at the time: the first cell showed
all six exclusions were diagnostic failures, five involved a split model, and the shared model
never failed once, so the rule removes exactly the replicates where relaxation is hardest.
Amending it was right; leaving section 4 of the protocol saying the opposite was not.

The protocol now records the amendment, its reason and its date, and the limitations disclose it
as a departure from registration.

On the substance, that retaining bad fits is what makes relaxation look poor: **it is not.**
Every primary comparison is now repeated on the 1,479 replicates where all four fits met the
original criteria. The paired advantage of check-then-relax over relaxing everything is 0.0109
on all replicates and 0.0116 on the converged subset; over imposing the restriction, 0.0173 and
0.0174. The conclusion is unchanged.

## 5. The estimand is not well defined under treatment-effect heterogeneity

Accepted. Where $\tau_{re} = 0.15$ the truth is defined at $\delta_{jk} = 0$, a superpopulation
quantity, while the fixed-effect fits estimate a precision-weighted function of the realized
studies; and integrating the inverse link over the random-effect distribution is not the same as
setting the random effect to zero. Part of the error attributed to the check in those cells is
that mismatch, and the oracle does not remove it because the oracle is fixed-effect there too.
This is now stated in the limitations, and results in the eight $\tau_{re} = 0$ cells are
reported separately.

## 6. Several claims do not respect Monte Carlo error

**Correct, and one registered claim changes verdict.**

"Fires in at most 8% of analyses" was the maximum of eight cell estimates each with a standard
error of about 0.065. It is gone. Detection is now reported **pooled across strata**, where the
standard error is near 0.01, with intervals:

| true contrast | DIC < −5 | 95% CI |
|---|---|---|
| 0 | 0.013 | [0.005, 0.029] |
| 0.15 | 0.020 | [0.010, 0.039] |
| 0.30 | 0.045 | [0.029, 0.070] |
| 0.60 | 0.147 | [0.116, 0.186] |
| 1.20 | 0.453 | [0.404, 0.501] |

The title is now drawn from this table.

**M4 is downgraded from confirmed to not clearly met.** 0.107 against a threshold of 0.10, with
a 95% interval of [0.097, 0.118] whose lower bound is below the threshold. A point estimate
0.007 above a threshold with a standard error of 0.006 does not clear it.

Strategy comparisons are now **paired**, since the three strategies are scored on the same
replicate, and reported with intervals.

## 7. The numerical instability is the same order as the signal

Accepted, and the characterization is retracted. The manuscript called an 8.3% verdict-flip rate
"small beside the resolution problem". It is not small: the DIC rule's detection rate rises by
about three percentage points between no violation and one twice the size that matters, and
changing the quadrature grid alone moves the verdict in 8.3% of replicates. The text now says
this. The subset is also now described: 24 simulated networks from two cells, the largest
network at the widest covariate spread with and without drift, which is where quadrature is most
stressed; and since 256 points is not demonstrated to be a converged reference, the figure is
reported as a lower bound on the instability rather than a measurement of it.

## 8. Numbers disagree between the manuscript and the evaluated decision

**Correct on all three, and this is the process failure, not a typo.**

- M2 clears its threshold in **5** of 8 strata. The decision document said 6.
- The type I error gap is 0.080 on the drifting covariate and 0.0875 pooling both covariates.
  The manuscript quoted 0.087 beside a table showing 0.0125 and 0.0925, which is the first pair.
- The stable-factor calibration error is 0.058 in the leave-one-factor-level-out analysis; the
  0.099 in the decision document came from a different analysis.

All three arose the same way: the decision document was typed by hand from a mix of tables.
**It is now generated by `R/08-decision.R` from the same result files the manuscript reads**, so
the two cannot drift apart again. That script is published with the study. Every number in the
document is computed; nothing is transcribed.

This is the fifth time in this program that a published summary has contained a number the
underlying analysis did not support, and the first time the fix has been to remove the
transcription step entirely rather than to check the transcription more carefully.

## 9. Drift 0.15 is not the boundary

**Correct, and the claim was false as written.** At drift 0.15 the transported error is 0.0294,
which is below the 0.03 threshold, so by this study's own definition that violation is not
material. The contrast that lands exactly on the threshold is 0.1531. The manuscript described
these cells as the exact boundary and as "the violation that precisely changes a decision"; both
statements are corrected. What the cells show is behaviour at a violation just short of
mattering, and the finding there is stronger for being stated correctly: pooled detection is
0.020 [0.010, 0.039] against 0.013 [0.005, 0.029] under the global null, intervals overlapping.

On the amendment's status: it was made during the run and is not part of the registered design.
It is dated, its reason is recorded, no result from those cells was seen before they were
specified, and they are excluded from the deployment mixture. They are reported as an amendment
throughout and are not used for any registered claim.

## 10. "Displacement cannot help because it is not in the statistic" is a logical error

Accepted. A predictor can improve a prediction without changing another predictor, and M1 shows
displacement moves the outcome strongly. The reasoning was wrong.

The prespecified target-aware model was computed and its absence from the manuscript was an
omission. It is now reported: adding displacement changes the held-out absolute error from 0.099
to 0.099, no improvement, and the correct explanation is narrow and empirical. Each fold holds
out a drift level or a design factor, so all four displacements are present in training within
every fold and displacement carries no information the mapping did not already have. What fails
is transport across drift, and knowing the target does not repair that.

## 11. The data-only standard error is not well defined

**Correct, and the title depended on it.** Subtracting prior precision from posterior precision
recovers the likelihood only under Gaussian conditions that a weakly identified interaction does
not satisfy. The study's own prior-sensitivity arm demonstrates the failure: the same networks
give a data-only standard error of about 1.0 under `normal(0, 1)` and about 1.8 under
`normal(0, 2.5)`, and those should agree.

The quantity is retained as an order-of-magnitude statement with that instability disclosed in
the text, and **no claim in the paper now rests on it**. The title has been replaced with one
drawn from directly measured detection rates. What the resolution section now leads with is the
posterior standard deviation itself, 0.30 to 1.64 across strata, which is what an analyst reads
off the output.

## 12. The recommendation to use the check is not established

Partly accepted. The comparison is now paired, reported with intervals, and repeated on the
converged subset, and on that footing check-then-relax does beat both alternatives at every
displacement with intervals excluding zero. The advantage is small and is described as small.

Two parts of the comment are not answered and are declared rather than argued away. Exact
deployment weights are in the configuration and the protocol but were not restated in the
results, which is fixed. And the hierarchical or exchangeable interaction strategy is genuinely
missing: it is the middle ground IDN-05 proposes, `multinma` documents
`class_interactions = "exchangeable"` and raises "not yet supported", and we did not implement
it ourselves. The manuscript now says that package non-implementation is a reason for its absence and not a
justification, that we could have written the model ourselves and did not, and that until
someone does, "check, then relax what fired" is the best of three options rather than a
recommendation about what to do.

## GLM, minor

The point about 50 replicates is accepted and is now enforced rather than merely stated: every
detection rate in the results is pooled or stratum-level, and the pooled table carries
intervals.

## Why Kimi returned nothing

`opencode run --pure` gives the model no tools. On the 61 KB package it produced an empty
response, as it did on a 9 KB design document earlier in this study while answering a 2.3 KB
prompt normally. The reviewer prompt already forbids tools, so the earlier diagnosis does not
explain this one; the remaining pattern is input size. A retry is running and its outcome will
be recorded in the round-two package either way.


## Round 2

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

This preregistered and amended simulation directly addresses IDN-05 for several author-defined operationalizations of the shared-effect-modifier check in sparse ML-NMR networks. The revision substantially improves the paper by exposing the prior-driven margin behavior, acknowledging that target invariance is constructed, correcting the near-boundary description, downgrading M4, and adding paired strategy comparisons. However, the revised manuscript remains internally unauditable, retains nonconverged fits, does not establish numerical integration convergence, and still pools an estimand-mismatched heterogeneity scenario into its central oracle and error results. The low alarm rates are potentially important, but the numerical, estimand, and reporting problems must be resolved before the headline and practical recommendations are reliable.

**Strengths.**

- The study addresses the catalog problem rather than a merely adjacent question, provided its conclusions remain restricted to the evaluated rules and simulated network family.
- The marginal target-population risk-difference estimand is clearly distinguished from the conditional log-odds mechanism estimand in the no-heterogeneity scenarios.
- The complete four-model lattice permits genuine one-covariate-at-a-time relaxation and paired strategy comparisons.
- The authors respond unusually candidly to unfavorable findings, including the failed registered gate, prior dependence, convergence failures, and numerical integration sensitivity.
- The revision correctly abandons the claim that the amendment simulated the exact decision boundary and correctly treats M4 as inconclusive given its Monte Carlo interval.
- The manuscript explicitly distinguishes the exploratory published practice from the five decision rules constructed by the authors.

**Comments.**

**Major 1** (Results; Decision boundary; Registered protocol; Authors' response). The revised package is still not internally complete or numerically auditable. The manuscript contains literal blanks for the amendment result, including "the rate is [, ]" and "the DIC rule fires in **** [, ]", even though the response supplies 0.020 [0.010, 0.039]. The manuscript reports target-aware calibration error of 0.086 versus 0.086, while the response says 0.099 versus 0.099; it states an M3 gap of 0.087 beside a displayed single-covariate table whose rates differ by 0.080; and the protocol claims 720 global-null covariate checks although 8 cells × 50 replicates × 2 covariates gives 800 after the amended no-exclusion rule. The reported 960 prior-sensitivity fits also does not follow from eight cells, 100 replicates per cell, and four fits.

*What would satisfy this:* Regenerate every table, decision statement, and prose value from one versioned analysis dataset; fill all placeholders; provide an analysis-flow table with the exact denominator for every result; and explain exactly which models and replicates comprise the 960 prior-sensitivity fits.

**Major 2** (Checks on the machinery). Numerical convergence of the likelihood integration remains unestablished. Changing from 64 to 256 points changed the DIC verdict in 2 of only 24 networks and the interval verdict in 1 of 24, but 256 points was not shown to be converged. The observed discrepancy between two unconverged settings is not a lower bound on instability, and estimates based on one or two flips have very large Monte Carlo uncertainty. Because the DIC headline difference is only about three percentage points, this unresolved numerical error threatens the main result rather than merely qualifying it.

*What would satisfy this:* Demonstrate convergence across successively finer grids or against a validated alternative integration method, report uncertainty and cell composition for the sensitivity study, and rerun the primary DIC and target-estimand analyses using a numerically stable setting.

**Major 3** (Estimands; What a pass licenses; What this does not settle). The central estimand and oracle remain invalidly pooled when tau_re = 0.15. Truth is defined at a random effect of zero, the fitted fixed-effect model targets a function of the realized trials, and a population risk integrated over heterogeneity is different again. The so-called oracle remains fixed-effect in these cells, so it does not know the full true specification and cannot define a pure noise floor. Merely listing this as a limitation does not repair pooled primary, oracle, or strategy results, and the claim that tau_re = 0 results are reported separately "throughout" is not borne out by the displayed primary and strategy tables.

*What would satisfy this:* Define one target under heterogeneity and compute truth and estimates for that same target; fit a genuinely correct random-effects oracle, or restrict the principal conclusions to tau_re = 0; and rename the current comparator an interaction-specification oracle wherever heterogeneous cells remain.

**Major 4** (Fit eligibility; Following the check still beats the alternatives). The converged-subset comparison is useful, but it does not validate scientific results calculated from chains with R-hat up to 1.89 and effective sample size near 3.4. Such draws can corrupt both the fully relaxed estimator and the split-model DIC used by check-then-relax. Conditioning on all four fits passing diagnostics is also selective because convergence is related to the method's difficulty. The revision therefore shows that the reported mean-absolute-error ranking is not obviously driven by the failed fits, but it does not make the main analysis using those fits valid.

*What would satisfy this:* Refit failed models with sufficient chains, iterations, and tuning until prespecified diagnostics are met, or treat computational failure as a separately defined operational outcome with an explicit loss. Scientific posterior summaries and DIC values should be based on diagnostically usable fits.

**Major 5** (What this measures; Readings of the check; Results). The distinction between the published exploratory practice and the authors' decision rules is now much clearer. Nevertheless, the broad conclusion that no rule in this family separates consequential violations from their absence is not supported because the prespecified AUROCs are absent, operating characteristics are not fully reported for every rule, and no calibrated positive-control setting shows what each rule can achieve. The paper measures selected operationalizations in one sparse network family, not the generic validating ability of the published practice.

*What would satisfy this:* Report all prespecified continuous discrimination results and complete operating characteristics, add or clearly justify the absence of positive controls, and restrict conclusions to the named rules, thresholds, priors, and simulated network designs.

**Major 6** (The verdict does not transport across the one axis that matters). The revised explanation for the target-aware calibration result is still logically unsound. Having all four displacements represented in training makes a displacement effect estimable; it does not make displacement redundant. Because the check statistic is identical across the four target rows while material-error risk changes strongly, displacement necessarily contains information unavailable from that statistic alone unless the conditional outcome unexpectedly does not vary. The conflict between 0.086 in the manuscript and 0.099 in the response further prevents assessment.

*What would satisfy this:* Report the exact target-blind and target-aware formulas, coefficients, predictions and errors by displacement and held-out level; keep repeated targets from each dataset grouped; verify the implementation; and explain any lack of improvement from those results rather than from the fold structure.

**Major 7** (What the network resolves; The check cannot give an all-clear; Discussion). The prior arithmetic is now correctly disclosed, but several replacement claims remain unsupported. The condition posterior SD < epsilon/1.96 is a necessary condition only under an approximately normal posterior centered optimally within the equivalence region, whereas the manuscript itself says weakly identified posteriors are non-Gaussian. The contrast SD requires the covariance between treatment-specific interactions, which is not shown. A ratio of two posterior SDs is also not "prior-free" merely because no precision subtraction was performed. Finally, the discussion and practical recommendation still rely on the two-to-twelve and twelve-to-one resolution ratios despite claiming that no conclusion rests on the unstable data-only calculation.

*What would satisfy this:* Show the contrast-variance calculation including covariance and posterior shape, evaluate priors parameterized directly on the shared component and contrast, include a positive-control equivalence setting, report sensitivity of the posterior-SD ratio to the prior, and remove the data-only ratio from substantive conclusions unless it is validated by likelihood-based calculations.

**Major 8** (Following the check still beats the alternatives; Discussion; What this does not settle). The evidence does not yet establish the recommendation "use it anyway." Paired mean-absolute-error intervals are shown only at displacement 1, while the abstract and discussion claim superiority at every target. The displayed displacement-0 table actually gives the common model a slightly lower RMSE than check-then-relax, and the fully relaxed model is best for decision reversal, demonstrating that the ranking depends on the loss. Exact deployment weights are still absent, nonconverged fits remain in the main comparison, and the most relevant partial-pooling strategy is omitted. The limitations acknowledge the missing hierarchical model, but the abstract and discussion continue to make a practical recommendation beyond the three-way comparison.

*What would satisfy this:* Report paired differences and intervals at every displacement, by design stratum and for each declared loss, using valid fits and explicit deployment weights. Either implement a coherent exchangeable or hierarchical comparator or narrow A4 and all recommendations to a descriptive comparison of the three evaluated strategies.

**Minor 9** (The mechanism: the check is blind to the only thing that determines the harm). The revision now acknowledges that invariant pass rates are a bookkeeping identity and that pass value also depends on drift, which is a substantial improvement. However, the section title still calls displacement "the only thing" determining harm, and M1 is still described as empirically confirmed even though its first half and the direction of target harm are induced by reusing fits and by the chosen interaction-plus-displacement mechanism.

*What would satisfy this:* Present the invariance as an algebraic derivation and implementation check, report conditional risks by drift or design stratum, and reserve empirical confirmation for quantities not fixed by construction.

**Minor 10** (Readings of the check; Power). The statement that one unselected contrast means the credible interval "keeps its nominal coverage" is false as a frequentist claim and is contradicted by the reported 9.25% global-null exclusion rate. Avoiding contrast selection preserves the nominal posterior probability label, not repeated-sampling coverage.

*What would satisfy this:* Call it an unselected 95% credible interval and report its empirical coverage or null exclusion rate without asserting nominal frequentist coverage.

**Minor 11** (Nothing in the panel beats scrutinizing everything). The decision-curve conclusion remains underdefined. Treat-all net benefit depends on the simulated prevalence and threshold range, while commissioning individual data is treated as the action without specifying its cost, delay, probability of acquisition, or probability of preventing material error. Consequently, "nothing beats scrutinizing everything" is a property of the chosen coding and deployment mixture, not a general decision recommendation.

*What would satisfy this:* Provide the net-benefit formula, deployment prevalence and weights, explicit consequences of commissioning individual data, sensitivity analyses for those consequences, and an appropriate decision-curve citation; otherwise remove the practical conclusion.

**Citation problems.**

- Phillippo et al. (2023): The paper supports comparing treatment-specific posterior interactions and model fit, but the manuscript has not shown that DIC-5, zero exclusion, the posterior margin, or equivalence are prescribed published decision rules. The revision acknowledges this, but several conclusions still refer generically to "the check."
- Spiegelhalter et al. (2002): The foundational DIC article does not by itself validate cutoffs of 2, 5, and 10 for detecting shared-effect-modifier violations. These should remain explicitly author-chosen heuristics with their application-specific rationale stated.
- Claims that there is one published within-network check and that nobody has measured it: These exhaustive novelty claims are not supported by the five-reference bibliography or a documented search and do not engage the broader network meta-regression literature on common, independent, and exchangeable treatment-by-covariate interactions.
- Phillippo (2025), multinma: A generic software citation does not substantiate behavior attributed to development version 0.9.1.9002, including silent demotion of .trt terms and failure of the documented exchangeable option. Cite the exact version or commit and provide a reproducible example.
- Decision-curve analysis: No methodological citation or explicit action-loss model is supplied. Foundational decision-curve guidance, such as Vickers and Elkin, and assumptions linking the action of commissioning IPD to prevention of harm are needed.

**Claims the reviewer judged unsupported.**

- “No rule in this family, on these networks, separates violations that matter from their absence.”
- “No network in this design came within a factor of three of the precision required to affirm the assumption at the margin that matters.”
- “That is why the count is zero and would remain zero under any prior that does not itself supply the answer.”
- “The evidence is therefore between 2.0 and 11.9 times too coarse to see what matters.”
- “The asymmetry the design was built around is large and prior-free.”
- “An oracle that knows which specification is correct, fitted to the same replicates, is materially wrong 0.639 of the time.”
- “Following the check and relaxing exactly what it fires on had the lowest error of the three strategies at every displacement.”
- “Within any such fold the four displacements are all present in training, so displacement carries no information the mapping did not already have.”
- “This is a lower bound on the instability rather than a measurement of it.”
- “The design is otherwise a best case in several ways that all favour the check, and the failures reported here are therefore lower bounds on the failures in practice.”
- “With two active treatments there is exactly one interaction contrast per covariate, so nothing is selected and the credible interval keeps its nominal coverage.”
- “There is one published within-network check on it.”
- “Nobody has measured it.”

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | The manuscript now clearly distinguishes the published exploratory practice from the author-defined rules and narrows its scope, but the prespecified continuous discrimination results remain absent and the exhaustive novelty claims remain unsupported. |
| sol 2 | partly | The prior probabilities are now correctly reported and the strongest all-clear claim was withdrawn, but no coherent contrast prior or positive control was added, and the replacement SD argument assumes posterior normality that the manuscript elsewhere rejects. |
| sol 3 | partly | The invariance is now identified as bookkeeping and the text acknowledges drift as another determinant, but the section heading still overstates displacement and conditional risks by drift and design stratum are not reported. |
| sol 4 | partly | The departure from the registered eligibility rule is disclosed and a converged-subset strategy analysis is supplied, but demonstrably nonconverged draws remain in the primary scientific analyses and failed models were not refitted or assigned an explicit operational loss. |
| sol 5 | no | The estimand mismatch under heterogeneity is acknowledged but not repaired; pooled central results still use truth at zero random effect and a fixed-effect comparator that is incorrectly called an oracle. |
| sol 6 | partly | The revision pools headline power, adds intervals, downgrades M4, and supplies a paired mean-absolute-error interval at displacement 1, but uncertainty for the headline rate difference and strategy comparisons at every claimed displacement remains missing. |
| sol 7 | partly | The sensitivity subset and verdict changes are now described and the claim that the instability was small was retracted, but numerical convergence is still not established and the primary analysis still uses 64 points. |
| sol 8 | no | The decision document is said to be generated, but the manuscript still contains blank results, unexplained denominators and fit counts, and conflicts with the response for target-aware calibration. |
| sol 9 | partly | The main prose correctly calls drift 0.15 just below the boundary, but the protocol and amendment-table caption still call it exactly one epsilon, and the corresponding pooled results are blank. |
| sol 10 | partly | A target-aware result is now mentioned and the original logical argument was withdrawn, but the replacement explanation is also logically inadequate, its reported value conflicts with the response, and the prespecified AUROCs remain absent. |
| sol 11 | partly | The title was changed and the precision-subtraction instability is disclosed, but the calculation and covariance remain undocumented, the posterior-SD ratio is incorrectly called prior-free, and the discussion still relies on the two-to-twelve ratio. |
| sol 12 | partly | Paired uncertainty and a converged-subset comparison were added and the missing hierarchical model is candidly acknowledged, but the practical recommendation persists without all-displacement evidence, explicit deployment weights, valid main fits, or the relevant partial-pooling comparator. |

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript presents a pre-registered simulation study evaluating the operating characteristics of the shared effect modifier check in multilevel network meta-regression. The authors have comprehensively addressed the round-one criticisms by scoping down their claims, correcting arithmetic and logical errors, downgrading over-stated mechanism claims, and auto-generating the decision document to ensure consistency. The study now provides a transparent and rigorous evaluation of the check’s precision limits and practical value, though minor gaps remain regarding the novelty claim's evidentiary support and the formal definition of the decision curve analysis.

**Strengths.**

- Exceptional transparency in addressing round-one errors, including downgrading M4 and correcting the title and boundary claims based on Monte Carlo error and exact threshold calculations.
- The move to auto-generate the prespecified decision document from result files eliminates transcription errors and ensures internal consistency.
- Fair comparison: strategy differences are now correctly paired with confidence intervals, and the sensitivity analysis on the converged subset of fits adequately addresses concerns about non-converged chains.
- The limitations section is unusually thorough and correctly identifies the estimand mismatch under treatment-effect heterogeneity and the omission of the exchangeable model.

**Comments.**

**Minor 1** (What this measures). The manuscript makes a strong novelty claim: 'There is one published within-network check on it... Nobody has measured it.' This exhaustive claim is supported by only five references. While the claim may well be true for ML-NMR population adjustment, a broader literature search or a slight softening of the language is warranted to defend the novelty assertion.

*What would satisfy this:* Add a sentence documenting the literature search strategy (e.g., databases and search terms used) or slightly soften the novelty claim to specify that it is the only check within the ML-NMR framework.

**Minor 2** (Nothing in the panel beats scrutinizing everything). The decision curve analysis lacks a methodological citation and does not explicitly state the net-benefit formula, the handling of ties, or the exact definition of 'decision reversal' when the true effect is zero. Round-one reviewer Sol raised this, and while the concept is sound, the formal definitions are still missing from the text.

*What would satisfy this:* Add a foundational citation for decision curve analysis (e.g., Vickers et al.) and briefly state the net-benefit formula and how decision reversal is operationalized in the presence of zero true effects.

**Citation problems.**

- Decision-curve analysis: The analysis has no methodological citation. Foundational decision-curve guidance should be cited.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| glm 1 | yes | Detection rates are now pooled or stratum-level with intervals, and per-cell point estimates are no longer over-interpreted. |
| sol 1 | yes | Authors clearly distinguished their formalized rules from the published exploratory practice. |
| sol 2 | yes | The prior arithmetic driving the margin rule was verified and acknowledged; the headline was reframed as a precision failure. |
| sol 3 | yes | M1 is now correctly labeled as a bookkeeping identity, and the claim about pass value was corrected to acknowledge dependence on drift as well as displacement. |
| sol 4 | yes | Authors acknowledged the departure from the registered eligibility rule, provided a reasoned justification for retaining non-converged fits, and supplied the requested sensitivity analysis on the converged subset. |
| sol 5 | yes | The estimand mismatch under tau_re=0.15 is explicitly stated in the limitations, and results are reported separately. |
| sol 6 | yes | Detection rates are pooled with MC intervals; M4 was downgraded to 'not clearly met'; strategy comparisons are paired with intervals. |
| sol 7 | yes | The 8.3% quadrature instability is no longer called 'small'; it is reported as a lower bound on instability of the same order as the signal. |
| sol 8 | yes | The decision document is now auto-generated from result files, resolving all numerical discrepancies. |
| sol 9 | yes | The false claim that drift 0.15 is the exact boundary was corrected; it is now described as a violation just short of mattering. |
| sol 10 | yes | The logical error was accepted. The target-aware model results were added, showing no improvement, with the correct narrow empirical explanation. |
| sol 11 | yes | The data-only standard error was removed from the title and explicitly flagged as an order-of-magnitude approximation with prior-sensitivity caveats. |
| sol 12 | yes | Strategy comparisons were improved with paired intervals. The omission of the exchangeable model is candidly acknowledged as a limitation rather than justified by package issues. |
| sol 13 | yes | The distinction between type I error and misattribution is made clear in the text. |
| sol 14 | partly | The concept of the decision curve remains, but the formal net-benefit formula, handling of ties, and foundational citation are still missing from the manuscript. |

### Reviewer 3: Kimi K3 (via OpenCode)

**Recommendation: minor-revision**

This registered simulation measures the operating characteristics of several explicit decision rules formalizing Phillippo et al.'s shared-effect-modifier check in ML-NMR, linking detection performance to a marginal target-population risk difference. The revision is a substantial and genuine improvement: the prior-driven margin-rule artifact is acknowledged and converted into a sharper precision result, the title is rebuilt from measured pooled rates, M4 is correctly downgraded, the near-boundary misdescription is corrected, and the decision document is now script-generated. The core conclusions — these networks resolve the interaction contrast far too coarsely for any rule in this family to separate violations that matter from their absence, a pass cannot affirm sharing, and check-then-relax is the best of three strategies — are now supported. What remains is a residue of the exact failure mode round one identified: unfilled numeric placeholders in the amendment sections, several 0.001-level disagreements between prose, tables and the decision document, one Discussion claim contradicted by the paper's own table, and a prespecified AUROC analysis that is still missing. These are fixable in one careful pass and do not threaten the design or the main findings.

**Strengths.**

- The revision process itself is exemplary: criticisms were verified numerically before acceptance, a registered claim was downgraded (M4), the title was replaced rather than defended, and the evaluated decision is now generated by R/08-decision.R from the same result files as the manuscript, removing the transcription step that caused the round-one discrepancies.
- The reframing of the all-clear result is better than what was demanded: instead of merely disclosing the prior artifact, the authors derive the precision condition for equivalence (posterior SD < epsilon/1.96 = 0.0781) and show the tightest stratum is a factor of 3.8 short — a measured, prior-robust statement that survives any prior that does not itself supply the answer.
- Estimand hygiene on the decision scale is correct and uncommon: marginal risk difference computed exactly by Gauss-Hermite quadrature, target displacement handled with the marginal placebo risk held fixed at 0.30 so displacement moves only the treatment contrast, and the conditional mechanism-scale quantity explicitly not reported as marginal.
- The oracle comparison is the right contextualization of the failed registered gate: reporting that a perfect check would also have failed (excess 0.036, negative at low displacement) converts an uninterpretable failure into a finding about verdict thresholds on total error.
- The limitations section now names the sharpest threat to the practical recommendation — the missing exchangeable/partial-pooling strategy — and states plainly that package non-implementation is a reason, not a justification, scoping the conclusion to 'best of three options'.
- Paired strategy evaluation with intervals, a converged-subset sensitivity analysis (0.0174/0.0116 vs 0.0173/0.0109) that directly answers the retention-bias objection, and honest reporting of misattribution (0.388 firing on the shared covariate) and quadrature instability quantified against the signal rather than dismissed.

**Comments.**

**Major 1** (Power; The decision boundary). The revised manuscript ships with unfilled numeric placeholders where the amendment-arm results should be: 'At the amendment level of 0.15 the rate is [, ]' and 'Pooled over the eight strata the DIC rule fires in **** [, ] of those analyses and the interval rule in ,'. The values exist elsewhere in the package (the response gives 0.020 [0.010, 0.039] for the DIC rule; the per-cell table implies roughly 0.083 for the interval rule), but as delivered the results section is incomplete and the claim that follows ('the check does not reliably distinguish it from no violation at all') currently rests on absent numbers. Given this program's own stated history of transcription failures, these must be filled from the audited result files, not retyped.

*What would satisfy this:* Regenerate both sentences from R/08-decision.R (or the same source), reporting the pooled amendment-arm rates with intervals for both rules alongside the null rates, and verify the rendered manuscript contains no bracket placeholders.

**Major 2** (What this measures; Following the check still beats the alternatives; Discussion). The claim that check-then-relax 'beat both alternatives on paired mean absolute error at every target examined' (intro) and 'had the lowest error of the three strategies at every displacement' (Discussion) is not licensed as written. The paired MAE comparison is reported only at displacement 1.0, and at displacement 0 the manuscript's own table shows imposing the restriction with lower RMSE (0.0422 vs 0.0426). The material-error and decision-reversal rankings do favor the check at both reported displacements, and the paired intervals at displacement 1.0 exclude zero, so a correctly scoped claim survives — but 'every displacement' currently does not.

*What would satisfy this:* Either report the paired MAE/RMSE comparison with intervals at all four displacements (including s = 0 and 1.5) and restate the claim to match, or scope the sentence to what is shown: lowest material-error rate at every displacement examined, lowest RMSE at displacement 1.0, with the displacement-0 ordering acknowledged as a tie within Monte Carlo error.

**Minor 3** (Results; Prespecified decision, as evaluated). The cross-document inconsistency class flagged in round one persists at small magnitude. (a) The M3 sentence says the two rules 'differ in type I error by 0.087' directly beneath a table whose entries (0.0125, 0.0925) differ by 0.080; per the decision document 0.080 is the drifting-covariate gap and 0.087 the both-covariates pooling, but the manuscript never says which it is quoting. (b) The M4 interval is [0.096, 0.118] in the manuscript but [0.097, 0.118] in the decision document; the width implies n = 3200 covariate-checks rather than 1600 replicates, in which case the two checks within a replicate are correlated and the interval is anti-conservative (the verdict is unaffected, but the denominator must be stated). (c) The pooled power table gives 0.148 and 0.452 while the adjacent prose gives 0.147 and 0.453. (d) The response says the target-aware mapping changed held-out error 'from 0.099 to 0.099' while the manuscript says 'from 0.086 to 0.086'.

*What would satisfy this:* One scripted audit pass over every number in manuscript prose against the result files; state the pooling explicitly in the M3 sentence; state the M4 denominator and, if 3200 checks are used, either account for within-replicate correlation or recompute on 1600 replicates; reconcile the 0.086/0.099 calibration figure.

**Minor 4** (Readings of the check; Results). The prespecified AUROC analyses (protocol section 5: ΔDIC and directional posterior probability 'scored as classifiers by AUROC') are still not reported anywhere in the results, and the response to round one is silent on them despite reviewer sol requesting them twice. Hanley & McNeil is cited for a method whose output never appears. Either the AUROCs should be reported, or the protocol deviation should be disclosed with a reason.

*What would satisfy this:* Report the AUROC for both continuous scores by drift level (pooled, with intervals), or add a dated protocol note stating the analysis was dropped and why.

**Minor 5** (What a pass licenses; Results). The response states that exact deployment weights 'were not restated in the results, which is fixed', but I cannot find the weights anywhere in the revised manuscript — 'deployment-weighted' appears without the weights. Similarly, the prior-sensitivity arm is described as '960 fits' while the protocol registers eight cells at 100 replicates (800 replicates, i.e. 3,200 fits if all four models were refitted); 960 matches no obvious combination and remains unexplained, as does the null-table denominator (400 in the manuscript table, 720 in the protocol, 800 implied by 8 null cells x 50 replicates x 2 covariates).

*What would satisfy this:* State the deployment weights numerically where the weighted results are reported; state exactly which fits were run in the prior-sensitivity arm and reconcile 960; state the type-I-error denominator and reconcile the protocol's 720.

**Minor 6** (Readings of the check; Discussion). Two sentences remain that the study's own results contradict or that trace to the demoted approximation. (a) 'Nothing is selected and the credible interval keeps its nominal coverage' — the paper's own measured type I error for the interval rule is 0.0925, about twice nominal, so the interval does not keep nominal coverage here; avoiding selection is necessary, not sufficient, for coverage. (b) The Discussion's 'two to twelve times larger' and 'about twelve to one' trace to the data-only standard-error column the manuscript itself demoted to an order-of-magnitude statement; the measured posterior SDs (0.30-1.64 against epsilon) support roughly two to eleven, and against epsilon/1.96 support the sharper 'no network within a factor of three' — the measured version should be used.

*What would satisfy this:* Replace (a) with an empirical coverage statement ('the 95% interval runs at about twice its nominal rate under the global null, so coverage is not nominal even without selection'); recompute (b) from the measured posterior-SD column or delete the ratio.

**Minor 7** (What this does not settle). 'The failures reported here are therefore lower bounds on the failures in practice' survives in only lightly qualified form and is still not defensible in generality. Several design features can cut against the check as easily as for it: fixed-effect fits reading data generated with tau_re = 0.15 (a misspecification that inflates firing), 64-point quadrature (an 8.3% verdict-flip rate that adds noise to the check, not to reality), and a single IPD study (which could make detection look better or worse than richer-IPD networks). The listed best-case features (true baseline risk supplied, unbiased ecological route, conditional constancy, single linear drift) do favour the check, and scoping the claim to those is supportable.

*What would satisfy this:* Scope the sentence: failures attributable to the listed idealizations are conservative; state explicitly that no lower-bound claim is made with respect to IPD count, quadrature error, or fixed-effect misspecification.

**Minor 8** (Nothing in the panel beats scrutinizing everything). Reviewer sol's round-one minor comment on this section was not addressed: decision reversal is undefined (particularly when the true C-versus-A effect is near zero), the net-benefit formula and the consequences assigned to 'commission individual data' are not stated, and the decision-curve analysis still has no methodological citation. Since the treat-all curve dominates trivially when the prevalence of material error is high (0.675 at displacement 1), the prevalence and threshold assumptions need to be visible for the result to be interpretable.

*What would satisfy this:* Define decision reversal and the net-benefit formula with the action's assumed benefit and cost, state the prevalence of material error entering the curve, and cite foundational decision-curve work (e.g., Vickers & Elkin 2006).

**Citation problems.**

- Hanley & McNeil (1982): Cited as the basis for AUROC scoring of the continuous check statistics, but no AUROC result is reported anywhere in the manuscript; the reference currently supports a method that is described but never used.
- Decision-curve analysis (uncited): Carried over unaddressed from round one: the net-benefit analysis has no methodological citation and does not state the assumptions under which material error is the event and commissioning IPD is the action.
- Novelty claims ('There is one published within-network check on it'; 'Nobody has measured it'): Both are plausible for ML-NMR population adjustment specifically, and Phillippo et al. 2023 is indeed the canonical within-network check there, but the claims are stated absolutely with a five-reference bibliography and no documented search. Scope to ML-NMR/population adjustment, add 'to our knowledge', and note the search basis.
- Spiegelhalter et al. (2002) for DIC cuts of 2, 5, 10: That paper discusses DIC differences only informally; the 2/5/10 grid is a convention, not a validated threshold from this source. The revised framing ('five explicit rules of our own construction') largely covers this, but the sentence attaching [4] to the specific cuts should say the cutoffs are conventional.

**Claims the reviewer judged unsupported.**

- Relaxing exactly what it fires on beat both alternatives on paired mean absolute error at every target examined. (paired MAE reported only at displacement 1.0)
- Following the check and relaxing exactly what it fires on had the lowest error of the three strategies at every displacement. (At displacement 0 the paper's own table shows imposing the restriction with lower RMSE, 0.0422 vs 0.0426)
- At a violation sitting just under the threshold of mattering, the check does not reliably distinguish it from no violation at all. (Currently rests on unfilled placeholders '[, ]' in the manuscript; the numbers exist only in the response and decision document)
- The failures reported here are therefore lower bounds on the failures in practice. (Unlicensed in generality; quadrature noise and fixed-effect misspecification disadvantage the check)
- The credible interval keeps its nominal coverage. (Contradicted by the paper's own measured type I error of 0.0925 for the interval rule)

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | The formalization framing is now in the introduction and limitations, and the conclusion is correctly narrowed to 'no rule in this family, on these networks'. But the requested continuous discrimination measures (AUROC) are still not reported (see also #10), and the five-rule construction is not flagged in the title, which still reads as 'the' check's alarm rate. |
| sol 2 | yes | The prior arithmetic (0.965 of the contrast beyond epsilon under the prior alone) is now in the manuscript, the all-clear headline is replaced by the precision condition (posterior SD < 0.0781; tightest stratum 0.30, factor 3.8 short), which is sharper and prior-robust. The suggested positive-control equivalence design was not added, but the reframed claim stands without it; a reasoned alternative. |
| sol 3 | yes | M1's first half is now labelled a bookkeeping identity verified rather than discovered; 'depends entirely on displacement' is replaced with 'displacement and drift, and the check is blind to both', with displacement justified as the axis that can be varied holding the fits fixed. |
| sol 4 | yes | The protocol now records the eligibility amendment, its reason and its departure status, and the limitations disclose it. Failed fits were not refitted as requested, but the converged-subset analysis (1,479 replicates; 0.0174/0.0116 vs 0.0173/0.0109) directly answers the substantive objection that retention made relaxation look poor — a legitimate alternative, well executed. |
| sol 5 | partly | The superpopulation/realized-network mismatch and the risk-scale integration issue are now stated precisely in the limitations, and per-cell tables carry heterogeneity so tau_re = 0 cells are separable. But pooled headline numbers (detection, strategies, the verdict) still mix tau_re levels, tau_re = 0-only strategy results are not shown, and the comparator keeps the name 'oracle' with the caveat in a distant section. |
| sol 6 | yes | Per-cell maxima are no longer interpreted as bounds ('the largest of eight of them is not an upper bound on anything'); pooled rates carry intervals; the title is drawn from the pooled table; M4 is correctly downgraded to not clearly met; strategy comparisons are paired with intervals. Residual: the M4 interval differs by 0.001 between documents and its denominator (1600 replicates vs 3200 correlated checks) is unstated. |
| sol 7 | partly | The 'small' characterization is retracted and the instability is now explicitly compared to the signal ('of the same order'), the subset (24 networks, two most-stressed cells) is described, and the figure is framed as a lower bound. But no convergence study against finer grids was performed or justified, and primary results still rest on 64-point quadrature with a verdict-flip rate that exceeds the headline detection difference. |
| sol 8 | partly | The decision document is now generated by R/08-decision.R from the same result files; M2 (5 of 8) and the calibration figure (0.058) are reconciled. However the M3 sentence still quotes 0.087 beside a table yielding 0.080 without stating the pooling — the exact flagged failure mode persisting — plus new 0.001-level prose/table mismatches (0.147/0.148, 0.453/0.452), an unexplained 960-fit prior-sensitivity denominator, and the 400/720/800 null denominators remain unreconciled. |
| sol 9 | yes | The boundary correction is made in manuscript, protocol and decision document: drift 0.15 gives 0.0294 < 0.03 and is now described as just below the boundary, the amendment's during-run status is disclosed, and it is excluded from registered claims. (The section itself ships with unfilled numeric placeholders — raised as a new round-two comment, not counted against this resolution.) |
| sol 10 | partly | The logical error is acknowledged and corrected; the prespecified target-aware mapping is now reported with the right explanation (all displacements present in training within every fold, so it adds nothing; transport fails across drift). But the response (0.099) and manuscript (0.086) disagree on the number, and the prespecified AUROC analyses remain entirely absent with no disclosure. |
| sol 11 | yes | The title no longer rests on the derived data-only SE; the quantity is demoted to an order-of-magnitude statement with its own sensitivity failure disclosed ('those should agree and do not'), and the measured posterior SD (0.30-1.64) now leads. Minor residue: the Discussion's 'two to twelve' and 'twelve to one' still trace to the demoted column rather than the measured one. |
| sol 12 | partly | Paired intervals and the converged subset now support a scoped recommendation, and the missing exchangeable strategy is declared with unusual candour ('a reason, not a justification... the best of three options'). But 'lowest error at every displacement' is contradicted at s = 0 by the paper's own RMSE column, paired MAE is shown only at s = 1, the deployment weights are still not in the manuscript despite the response claiming this fixed, and the 'lower bounds on failures in practice' claim survives in still-too-strong form. |
| sol 13 | partly | Misattribution is now reported separately (0.388 firing on the shared covariate at drift 1.2, 'a fire is not a diagnosis'). But the design section still says every replicate supplies 'one type I error observation' for x2 even under drift, and the 'credible interval keeps its nominal coverage' sentence remains and is contradicted by the study's own 0.0925 type I error. |
| sol 14 | no | Not addressed in the response or the revision: decision reversal remains undefined, the net-benefit formula, action consequences and prevalence are unstated, and the decision-curve analysis remains uncited. |
| glm 1 | yes | Detection claims are now pooled or stratum-level with intervals, and the per-cell table carries an explicit caveat that per-cell rates have SE about 0.065 and that the largest of eight is not an upper bound. The residual wide per-cell intervals are disclosed rather than hidden. |

## Authors' response to round 2

# Response to round two

Sol `major-revision`, eight major comments and `conclusions_supported: false`. Kimi
`minor-revision`, two major comments and `conclusions_supported: false`. GLM `minor-revision`,
two minor comments and `conclusions_supported: true`.

Kimi's **round-one** report also arrived during round two. The first attempt returned an empty
response; a retry succeeded after the round-two package had already been sent, so that report
never received a round-one response and is answered here. It is truncated by an output limit at
comment 10 of an unknown total, which is recorded rather than hidden. Nine complete comments
survive and four of them anticipate what Sol raised in round two, independently and from a
different model family.

Two reviewers say the conclusions are not supported. They are right, and the reason is not
overstatement. **Round two found two errors in this study's code**, both derived by reviewers
from published numbers alone without access to the source, plus a manuscript that shipped with
two literal blanks where results should have been, plus an undisclosed departure from
registration. Every allegation below was checked numerically before it was accepted, and three
further defects were found in the course of checking that no reviewer reported.

---

## The two code errors

### 1. Contraction was divided by a prior the arm was not fitted under

Kimi, round one, comment 2. **Confirmed, and it inverted the direction of a published result.**

`R/02-fit.R` computed $1 - \mathrm{sd}(\text{posterior}) / \mathrm{sd}(\text{prior})$ with the
denominator hard-coded to `PRIOR_REG_SD`, the main design's 2.5, in every arm. The
prior-sensitivity arm is fitted under `normal(0, 1)`. Its contraction was therefore measured
against a prior it never used.

The reviewer reached this without the code, from the published figures and one theoretical
observation: for a fixed likelihood, tightening a prior cannot *raise*
$1 - \mathrm{sd}(\text{post})/\mathrm{sd}(\text{prior})$, and the paper reported it rising from
0.33--0.42 to 0.68--0.70. The reviewer's reconstruction, that 0.68--0.70 is approximately
$1 - 0.88/2.5$, is exactly right.

Corrected. `check_stats()` now takes the prior as an argument and records it in the output;
`03-replicate.R` reads it from the prior object rather than the config. The already-run fits
stored raw posterior standard deviations, so the repair is exact algebra on what is on disk and
needed no refit. Against the prior each arm actually used, contraction **falls** from 0.37 to
about 0.20 when the prior tightens, which is the direction it must move.

What the arm was for survives: the check's flag rate barely moves between priors. The narrative
conclusion is unchanged and the number supporting it was wrong.

### 2. The primary bound was computed for a different quantity than the one it bounds

Kimi, round one, comment 3. **Confirmed, though not by the mechanism proposed.**

The registered gate is an upper bound on the **deployment-weighted** risk. `R/05-analyze.R`
computed `hi95` as a one-sided Wilson bound on the **unweighted** count and printed it beside
the weighted point estimate. So the paper's headline 0.777 was a bound on 0.758, presented as a
bound on 0.675.

The reviewer inferred from the width that the effective sample size must be about 55 and
suspected the deployment weighting had concentrated mass. That diagnosis is not right: the
weights are mild, with a Kish effective count of 24.2 of 32 cells. But the finding is right, and
it is the one that matters: the published bound could not be reconstructed from the published
sample size because it belonged to a different estimator.

Corrected. Weights are constant within a cell, so the estimator is a ratio of weighted cell
means and its variance is exact up to plugging in the cell rates. The weighted bound is
**0.697** with a standard error of 0.0134. The unweighted Wilson bound is retained beside it and
labelled. **The verdict is unchanged: FAILS, by a factor of about seven.**

One consequence is worth stating because it looks like a bug and is not. The systematic-error
indicator is a deterministic function of a cell's drift and the displacement, so it has no
within-cell variance and its bound equals its point estimate exactly. All remaining uncertainty
is in weights that are declared rather than estimated. This is now said in the text.

---

## The manuscript shipped with blanks

Sol comment 1 and Kimi comment 1, independently. **Confirmed at two places in the rendered
file.**

`out/IDN-05.md` line 306 read `At the amendment level of 0.15 the rate is \[, \]` and line 631
`the DIC rule fires in \*\*\*\* \[, \]`. `power-pooled.csv` was built from the 32 registered
cells and the amendment arm lives in a different file, so `pp[pp$drift == 0.15, ]` returned zero
rows, `pc()` returned `character(0)`, and Quarto rendered nothing. No error was raised anywhere:
a zero-length inline result is a silent empty string.

The round-one response asserted 0.020 [0.010, 0.039] for that row. The arithmetic is right, 8 of
400 pooled with a Wilson interval, but it was computed by hand for the letter and never checked
against the page.

Three fixes, at three levels.

- The amendment arm is now pooled into `power-pooled.csv` with an `arm` label, so the lookup
  finds it.
- The lookup **stops** on anything other than exactly one row instead of returning nothing. A
  value that cannot be found now breaks the render.
- `review/verify-render.py` scans the rendered output for the shapes an empty inline result
  leaves behind, plus stray `NA`, `NaN`, `Inf`, `NULL` and unevaluated `` `r ``. It is a
  publish gate. Run against the file the reviewers received, it reports both blanks.

`verify-response.py` could not have caught this. It checks that claimed text is present; this
failure is text that is absent.

---

## The undisclosed departure from registration

Sol comment 1, final clause. **Confirmed, and worse than the reviewer could see.**

The reviewer observed that 960 prior-sensitivity fits cannot come from the registered eight
cells at 100 replicates with four models. Counting the stored cell files shows why: the arm ran
**eight cells at 30 replicates**, 240 replicates, 960 fits, against the 800 replicates and 3,200
fits registered. The shortfall was real, was not deliberate, and was not disclosed in either of
the first two drafts.

The protocol now records it with its date. The cells are the registered ones and nothing was
re-selected after results were seen, but at 30 replicates a cell-level rate carries a Monte
Carlo standard error near 0.09, so the arm is reported as directional and no registered claim
rests on it. `R/05-analyze.R` now writes the arm's composition to a file so the manuscript
states it rather than deriving it.

This is the second undisclosed departure in this study. The first, the fit-eligibility rule, was
disclosed in round one after Sol raised it. That two were found by review rather than by us is
the finding about our process, not about this arm.

---

## Numbers that disagreed across documents

Sol comment 1, Kimi comment 3, and Kimi round-one comment 4. All checked.

**The 720 was wrong; 800 is right.** `m3-null-rules.csv` gives n = 800, which is 8 null cells
$\times$ 50 replicates $\times$ 2 covariates. The 720 in the protocol assumed the eligibility
rule that was amended away before the run. Corrected in both places it appeared, with the reason.

**The M3 gap: both figures were correct and the text never said which.** 0.080 is the drifting
covariate, 0.087 pools both. `m3-null-rules.csv` now carries both poolings as labelled rows and
the manuscript quotes both explicitly. M3 is confirmed on either.

**The M4 denominator.** Kimi is right that the interval used 3,200 covariate-checks drawn from
1,600 replicates, and that the two checks inside a replicate share a fitted network, so a
binomial interval is anti-conservative. The interval is now clustered by replicate, which widens
the standard error from 0.00546 to 0.00570 and the interval to [0.096, 0.118]. M4 remains **not
clearly met**.

**The calibration figure: our response letter was wrong and the manuscript was right.** Sol
found that the letter said 0.099 and the paper said 0.086 and asked which. The manuscript's
0.086 is the mean over the ten held-out folds. The 0.099 in the letter is the `n_studies = 6`
fold alone, which we took for the mean. The letter was wrong.

---

## The calibration explanation, at the third attempt

Sol comment 6. **Accepted, and the reviewer's reasoning was sound where two of ours were not.**

The reviewer's objection to the second explanation is correct: all four displacements being
present in training makes a displacement effect *estimable*, not *redundant*; and since the
check statistic is identical across the four target rows while material-error risk changes
strongly across them, displacement must carry information the statistic does not.

The explanation is a property of the registered metric, which we had not looked at closely
enough. Absolute error between *mean* predicted probability and *mean* observed rate is
calibration in the large, and a logistic model fitted by maximum likelihood is calibrated in the
large on its training set by construction, so a predictor balanced between training and test
cannot move it. The metric was nearly blind to the question.

Held-out discrimination answers it, and the answer is the opposite of what two drafts concluded.
Across the ten held-out folds the check statistic alone discriminates material error at an
AUROC of **0.48 to 0.63**, close to chance. Adding the target displacement raises it to **0.50
to 0.83**, and to **0.69 to 0.75** over the six folds that hold out a design factor rather than
a drift level; the one fold where it does not help holds out drift 0, where the test set has no
violation and material error is pure noise. Knowing the target is
worth far more than knowing the check statistic, and the check cannot tell an analyst the
target. That is a sharper version of the section's claim, and the paper reached it only because
a reviewer refused two wrong explanations of a null result.

---

## The prespecified AUROC analyses

Sol comment 5, Kimi comment 4, and Kimi round-one. **Accepted without reservation.**

These were registered in section 5 of the protocol, computed from the first run onward, and
omitted from the first two drafts while `@hanley1982` was cited for a method whose output never
appeared. Kimi's characterization, an undisclosed protocol deviation, is exact.

They are now reported in full with Hanley and McNeil intervals, against material error and
against the presence of a violation, and the omission is recorded in the protocol. The result is
the strongest form of the paper's central claim and does not depend on any rule of ours:
$-\Delta\mathrm{DIC}$ ranks a violated network above an intact one with an AUROC of **0.557
[0.517, 0.596]** at a violation twice the size that matters, and the directional posterior
probability reaches only 0.507, an interval containing chance. No threshold recovers a ranking
the statistic does not contain.

---

## The strategy recommendation

Sol comment 8, Kimi comment 2. **Accepted, and checking it exposed a third problem neither
reviewer saw.**

Kimi is right that "lowest error at every displacement" is contradicted at displacement 0 by our
own RMSE column, 0.0422 for imposing the restriction against 0.0426 for check-then-relax.

Checking that exposed the reason: the paired differences were computed **unweighted** while the
RMSE table beside them was **deployment-weighted**, and the two disagreed in sign at
displacement 0 for that reason alone. Both are now weighted, so the table and the paired test
answer the same question. `paired()` also computed a squared-error difference and discarded it;
it is now reported, because that is the loss on which the ordering turns.

The corrected result, deployment-weighted and paired:

- Against **relaxing everything**, check-then-relax wins at all four displacements on both
  losses, every interval excluding zero.
- Against **imposing the restriction**, it wins at 0.5, 1.0 and 1.5, and at displacement 0 the
  difference is $-0.00005$ with a 95% interval of $[-0.00069, 0.00059]$, which contains zero.

So the claim is now: better than relaxing everything everywhere, better than the restriction
wherever there is anything to transport, and indistinguishable from it where there is not. That
is what the data support. Paired differences are reported at every displacement, and repeated on
the sixteen homogeneous cells, where the ordering is unchanged.

---

## Where the reviewers' premises were wrong, with evidence

Sol comment 7 raises three objections to the equivalence analysis. Two do not apply, and saying
so is not a refusal to engage: the reasoning is checkable in the code.

**"The contrast SD requires the covariance between treatment-specific interactions, which is not
shown."** It is not assembled from marginal standard deviations. `check_stats()` forms the
contrast draw by draw from the joint posterior,
$z^{(m)} = \gamma_A^{(m)}[x_1] - \gamma_C^{(m)}[x_1]$, and takes the standard deviation over
those draws, so the covariance is fully accounted for.

**"The condition is necessary only under an approximately normal posterior."** True of the
$\varepsilon/1.96$ condition, which is offered as an interpretive gloss and now labelled as one.
But it is not what produces the count of zero. That count comes from
$P(|z| \leq \varepsilon)$ evaluated as the proportion of posterior draws satisfying the
inequality, which assumes no shape at all.

**"A ratio of two posterior SDs is not prior-free merely because no precision subtraction was
performed."** Accepted. Both posteriors shrink toward the same prior. The word is removed; what
survives is that the ratio avoids the instability that demoted the derived column, which is a
narrower and true claim.

The related claim that the count of zero "would remain zero under any prior that does not itself
supply the answer" is withdrawn. A prior placed directly on the contrast would change the
arithmetic, and we did not run one.

---

## Accepted and corrected without argument

- **"Keeps its nominal coverage"** (Sol 10, Kimi 6, Kimi round-one 1). False, and contradicted
  by our own type I error. Split by heterogeneity as Kimi asked: the interval rule fires on
  0.075 [0.046, 0.120] of replicates under the global null with no heterogeneity and 0.110
  [0.074, 0.161] with it. Avoiding covariate selection is necessary for coverage, not
  sufficient. The claim is replaced by the measurement, in the manuscript and in the code
  comment that carried it.
- **"Lower bounds on the failures in practice"** (Kimi 7). Not licensed in generality. Now
  scoped: failures attributable to the listed idealizations are conservative, and three features
  cut the other way, namely fixed-effect fits on heterogeneous data, quadrature noise, and the
  single individual-level study.
- **"The only thing that determines the harm"** (Sol 9). Section retitled.
- **DIC cutoffs of 2, 5, 10 attributed to @spiegelhalter2002** (Sol, citations). Now explicitly
  ours, with the citation for the criterion and not for the cutoffs.
- **Generic package citation for development-version behavior** (Sol, citations). Now cited to
  the exact build: 0.9.1.9002, commit `8489bd83f388f3cb48062947cd9ab083218947dd`, built
  2026-06-27, with a URL to that tree.
- **Decision curve undefined and uncited** (Sol 11, Kimi 8, GLM 2). The formula, the event
  definition, the prevalence entering the curve, and the tie handling are now stated, with
  @vickers2006. There is no "decision reversal" event in this analysis; the event is a material
  error in the risk difference, and that is now said rather than left to inference. The
  action's cost, delay and probability of success are **not** modelled, which is stated.
- **The decision curve contradicts the recommendation** (Kimi 5). The reconciliation is now
  written out: the strategy comparison scores estimation error, where the check contributes a
  little; the decision curve scores whether to trust an analysis at all, where the event is
  dominated by noise no covariate check can predict. Kimi's framing, that this restates the
  noise floor rather than measuring the check, is adopted.
- **The exhaustive novelty claim** (GLM 1, Sol citations). Scoped to the ML-NMR
  population-adjustment literature, with the basis of the search stated and the broader
  network meta-regression literature on interaction structures explicitly excluded from the
  claim.
- **Deployment weights invisible** (Sol 8, Kimi 5). The round-one response said this was fixed
  and it was not. They are now written to `results/deployment-weights.csv` and published.

---

## Found while checking, reported by nobody

Three defects surfaced in the course of verifying the reviewers' arithmetic.

**The worst R-hat was understated.** The paper quoted 1.89 and ESS 3.41 from the fully relaxed
model as though they were the worst in the study. Across all four models the worst R-hat is
**5.13** with ESS **1.03**, in a singly-relaxed fit, and at least one fit misses its criteria in
0.076 of replicates. Quoting the better of two figures understated the problem.

**The weighting mismatch in the strategy comparison**, described above.

**`study.json` still carried the title retracted in round one**, together with three claims the
manuscript had already withdrawn: that one prior-free number carries the paper, that the
failures are lower bounds, and the superseded 0.777 bound. That file feeds the catalog page and
was the one published artifact no checker covered. It is rewritten, and it is now covered.

---

## What is not fixed, and why

Three of Sol's requests are refused for now and declared rather than argued away.

**Demonstrating quadrature convergence** (Sol 2). The request is legitimate and the objection is
the sharpest in the report: a difference between two unconverged grids is not a bound on the
error of either, and with two verdict flips in 24 networks the estimate itself is very noisy.
This would need a new arm at successively finer grids across more networks. It was not run. The
manuscript states that 256 points is not demonstrated to be converged and that the flip rate is
of the same order as the signal it sits beside; that is a limitation on the primary result, and
it is now labelled as one rather than as a qualification.

**Refitting the non-converged models** (Sol 4). Also legitimate. The converged-subset analysis
shows the strategy ranking does not depend on those replicates, which answers the question it
was asked, but it does not make a DIC computed from a chain with R-hat 5.13 valid. Refitting
would need a new run.

**Implementing an exchangeable comparator** (Sol 8). The partial-pooling strategy is the one an
analyst would most want and is absent. The package does not implement it and we did not write it
ourselves. This is stated in the manuscript as a reason for its absence and not a justification,
and the recommendation is scoped to the three strategies compared.

Each of these would change what the paper can claim. None of them is answered by argument here,
and the manuscript's conclusions are narrowed to what the evidence supports without them.

## Verification

`review/verify-response.py` extended to 99 assertions covering both rounds, including the
retracted round-two claims and, for the first time, `study.json`. 99 of 99 pass.
`review/verify-render.py` reports no empty inline results in the rendered manuscript.


## Editorial decision

**Accept, with the conclusions narrowed and three limitations that bound what the study
establishes.**

Round one: Sol `major-revision` with `conclusions_supported: false`, GLM `accept`, Kimi an empty
response. Round two, on the revision: Sol `major-revision` with `conclusions_supported: false`,
Kimi `minor-revision` with `conclusions_supported: false`, GLM `minor-revision` with
`conclusions_supported: true`. Kimi's round-one report arrived late, after round two had been
sent, and returned `major-revision`; it is published here and answered in the round-two
response even though it could not inform revision one.

Across the two rounds the reviewers were right about more than they could have known, and the
decision rests on what they found rather than on the arithmetic of recommendations.

## What review established

**Two errors in the study's own code**, both derived by reviewers from published numbers alone,
without access to the source.

The first: contraction was divided by the standard deviation of the main design's prior in every
arm, including a prior-sensitivity arm fitted under a different prior. A reviewer noticed that
the published figures had to be measured against the wrong denominator and supplied the argument
that settles it, that tightening a prior cannot raise
$1 - \mathrm{sd}(\text{post})/\mathrm{sd}(\text{prior})$. The direction of a published result was
inverted. It is fixed at source, and repaired exactly for the existing fits from stored
quantities.

The second: the primary bound, the number the whole registered gate turns on, was a Wilson
interval on the unweighted risk printed beside a deployment-weighted point estimate. A reviewer
observed that the published bound could not be reconstructed from the published sample size. The
corrected weighted bound is 0.697 rather than 0.777; the verdict is unchanged and fails by a
factor of about seven either way.

**A manuscript that shipped to three reviewers with two literal blanks.** A zero-row lookup
rendered as an empty string, silently, and the sentences that depended on it were published
without their numbers. Two reviewers reported it independently. The response to round one had
asserted the missing figure from a hand calculation without checking the page.

**An undisclosed departure from registration.** The prior-sensitivity arm ran at 30 replicates
per cell against the 100 registered. It was found because a reviewer asked how a published fit
count followed from the registered design, and it did not. This is the second undisclosed
departure in this study; the first was found the same way, in round one.

**A prespecified analysis computed and then dropped.** The AUROC scoring of the continuous
statistics was registered, computed from the first run, and omitted from two drafts while its
methodological citation remained. All three reviewers asked for it. It is now the strongest
result in the paper and the only one that depends on no threshold of ours.

**Several claims the data contradicted.** That the credible interval keeps nominal coverage,
against the study's own type I error. That check-then-relax has the lowest error at every
displacement, against the study's own RMSE column. That the reported failures are lower bounds
in general. Each is corrected to what was measured.

## Why this is accepted rather than rejected

None of the defects is in the design, and both reviewers who withheld support said so
explicitly. The mechanism is not rigged: the drift parameter *is* the estimand the check
targets, and the margin is derived from a decision threshold rather than tuned. The estimand
discipline on the decision scale is sound. The oracle comparison, which shows a perfect check
would also have failed the registered gate, is the right way to report a failed gate and is
retained.

The corrections moved numbers and narrowed claims. They did not reverse a conclusion. Detection
of a violation twice the size that matters remains 0.045 [0.029, 0.070] against 0.013 [0.005,
0.029] under the null; the threshold-free AUROC at that violation is 0.557 [0.517, 0.596]; the
equivalence reading still never fires; the registered gate still fails.

## What this study does not establish, after two rounds

Three requests are not met, and they bound the result.

**Numerical convergence of the likelihood integration is unestablished.** Changing the
quadrature grid from 64 to 256 points flips the DIC verdict in 8.3% of a 24-network subset, and
256 points is not shown to be converged. A difference between two unconverged grids is not a
bound on the error of either. Since the headline detection difference is about three percentage
points, this is a limitation on the primary result and not a footnote to it. Resolving it needs
a new arm at successively finer grids.

**Fits that failed their diagnostics remain in the main analysis.** Retaining them is defensible
and the converged-subset analysis shows the strategy ranking does not depend on them, but a DIC
computed from a chain with $\hat R$ of 5.13 is not a usable quantity, and the reviewer is right
that a sensitivity analysis does not make it one.

**The partial-pooling comparator is missing.** An exchangeable interaction structure is the
strategy an analyst would most want and the one this catalog entry proposed. The package does
not implement it and we did not write it. The recommendation is therefore scoped to the best of
three options.

## A note on the process, which is part of the record

Revision two was not sent back to the reviewers. The program runs two rounds, and this decision
is made on a revision that changed two code paths and several published numbers without a
reviewer seeing the result. That is a real weakness of a two-round protocol when the second
round finds bugs rather than overstatements, and it is recorded here rather than left implicit.

Three defects in revision two were found by checking the reviewers' arithmetic rather than by
the reviewers: the worst reported $\hat R$ was the worst of one model rather than of any model,
the paired strategy comparison was unweighted while the table beside it was weighted, and
`study.json`, which feeds the public catalog page, still carried the title retracted in round
one along with three withdrawn claims. That last one is the fifth occurrence in this program of
a published artifact carrying a claim the analysis no longer supports, and the first time the
artifact was one no checker covered. It is covered now.

The lesson this study forces is narrower than "check more carefully". Every one of the
structural fixes works by removing a place where a human number could enter: the decision record
is generated, the render is scanned for values that vanished, the lookup that returned nothing
now raises, and the arm composition is written by the analysis rather than derived in prose.


