# Peer review: Separating within-trial from across-trial component effect modification

Study aimed at catalog problem **CMP-13**, also bearing on IDN-06.

Two independent reviewers, two rounds. Reports, author responses and the
editorial decision are reproduced in full and unedited. Reviewers were
given the manuscript, the protocol registered before the run, and the
prespecified decision as evaluated; in round two they additionally saw
round one's reports and the authors' response.

## Reviewers

| | Reviewer | Round 1 | Round 2 |
| --- | --- | --- | --- |
| R1 | GPT-5.6 Sol (maximum reasoning effort) | major-revision | major-revision |
| R2 | GLM-5.2 (via Ollama) | minor-revision | major-revision |
| invited | Kimi K3 (via Ollama) | not run | not run |

## Round 1

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

This protocol-led simulation compares a shared component interaction with within-between split and IPD-anchored estimators across a large factorial design. It demonstrates that a model constrained to γW = γB can have severe undercoverage when data are generated with γB = ργW, while correctly specified split estimators generally perform well. It does not establish that aggregate data are irrelevant to the catalog mechanism: all-IPD bias only shows that aggregate data are not necessary, while the reported gradient as IPD is removed is consistent with aggregate data worsening the pull, and the prespecified refutation threshold was not met. The model-to-software mapping, finite-sample aggregation, causal identification, post-run amendment, and numerical reporting require major revision before the claimed answer to CMP-13 or IDN-06 is supported.

**Strengths.**

- The manuscript clearly distinguishes within-trial effect modification from a non-randomized between-study association and gives a useful algebraic decomposition.
- The factorial design is unusually extensive, with 2000 replicates per scenario, negative controls, multiple prevalence spreads, and both mild and severe discordance.
- Adding a bundled network addresses the legitimate concern that an isolating network would test ordinary rather than component meta-regression.
- The no-B-IPD regime directly exposes non-identification that would be hidden by reporting only conventional mixed-IPD scenarios.
- Failures, non-estimability, and failure-as-noncoverage are distinguished rather than silently conditioning on successful fits.
- The authors transparently report that the sandwich estimator failed its controls, that the mechanism refutation threshold was missed, and that the numerical results do not directly transfer to Bayesian multinma.

**Comments.**

**Major 1** (Abstract; Is the cause the aggregate data?; What this answers). The mechanism conclusion answers a stronger question than CMP-13 as quoted. Finding bias with all trials providing IPD shows that aggregate data are not necessary for bias under this fitted model; it does not show that aggregate studies do not pull the estimate or amplify the problem. Indeed, Table 2 shows median standardized bias rising from 0.15 with all IPD to 0.22-0.29 with less IPD, alongside markedly worse minimum coverage. Moreover, the registered refutation threshold was not met. Calling the direction unambiguous and saying the mechanism is corrected therefore exceeds both the evidence and the decision rule.

*What would satisfy this:* Classify the registered mechanism test as inconclusive or not supported but not refuted, distinguish structural susceptibility from the incremental effect of replacing IPD with aggregate data, and estimate matched contrasts in bias or pseudo-true values as otherwise identical trials are changed from IPD to aggregate form. Revise the title, abstract, and discussion accordingly unless a direct incremental-effect analysis demonstrates the stronger claim.

**Major 2** (The problem; Estimand and methods). Equation 1 is an identity, but it does not by itself prove that every component ML-NMR implementation identifies a distinct between-study coefficient and forces it to equal the within-trial coefficient. That consequence also depends on restrictions placed on study-by-treatment or study-by-component effects. With free study-arm intercepts, the study-constant γ(p_s-0.5) term can be absorbed; random treatment effects can also change the pseudo-true shared coefficient. The shared and IPD-anchored methods differ in their nuisance intercept structures as well as in interaction parameterization, so the all-IPD comparison does not isolate the shared interaction alone.

*What would satisfy this:* Write the complete likelihood and nuisance-effect structure for every method, show algebraically which restrictions produce the claimed equality, and map those equations to the actual fixed-effect and random-effect multinma specifications targeted by CMP-13. Include a comparator that changes the interaction decomposition while holding the study-treatment nuisance structure fixed, or narrow all claims to the particular fixed-effect analogue actually simulated.

**Major 3** (Data-generating mechanism). The qualitative result is built into the DGM through q_c(p_s) = γB,c(p_s-0.5), γB = ργW. For every ρ other than one, the shared model is deliberately misspecified, while the split model is correctly specified except under the nonlinear pattern. Simulation can usefully quantify the resulting loss, but it cannot establish the existence, direction, or realistic magnitude of such discordance. The clinically decisive γW values are not reported, making even that quantification uninterpretable because coverage loss depends on absolute discordance, prevalence spread, information, and sample size, not on ρ alone.

*What would satisfy this:* Report every γW value and all null, between-only, and nonlinear functions; justify them on an interpretable treatment-effect scale; and present results against absolute |γB-γW|. Reframe the study as a calibrated stress test, or add sensitivity analyses varying interaction magnitude, imperfect correlation between q and prevalence, independent study heterogeneity, and more realistic departures from the fitted model.

**Major 4** (Data-generating mechanism: aggregate arms). The statement that a Poisson draw with the integrated mean is exactly the distribution of the sum of individual outcomes is true only if the numbers of X=0 and X=1 individuals are fixed at the stated proportions. If individual covariates are independently sampled from Bernoulli(p_s), integrating over X produces a mixture of Poisson distributions and additional variation; the sum is not Poisson with only the integrated mean. The protocol does not say whether p_s is an exact finite-sample stratum proportion, a study-superpopulation prevalence, or an arm-specific realized proportion. This is precisely a realized-sample versus superpopulation distinction and may affect standard errors and coverage.

*What would satisfy this:* Specify how individual X values and arm allocations are generated and what the aggregate likelihood conditions on. Either generate one finite individual-level dataset and obtain aggregate arms by literal aggregation, or condition on fixed stratum counts and state that design explicitly. If the current simulation used superpopulation integration while describing finite sampled individuals, rerun the affected scenarios with the coherent DGM.

**Major 5** (Estimand and methods; no-B-IPD construction). The stated coefficient is an internally coherent conditional estimand under the additive log-rate DGM, but its causal identification is overstated. X is not randomized; randomization identifies a treatment-by-X interaction through differences in treatment contrasts across baseline-X strata, not through an outcome slope inside a single arm. The claim that one arm containing B identifies γW,B once β is known relies on a common prognostic slope transported across arms or studies, not solely on randomization. In bundled networks, interpreting a component coefficient causally additionally requires component additivity, consistency, and suitable randomized component contrasts.

*What would satisfy this:* Give a formal identification argument separating randomization-based information from parametric cross-arm or cross-study restrictions. Define no within-trial information in terms of randomized treatment contrasts that change the component, or explicitly label the weaker model-based identification being used. Also distinguish the conditional γW estimand from the marginal population-adjusted treatment effects normally delivered by ML-NMR and evaluate the latter if claims extend to population adjustment.

**Major 6** (Results; Protocol amendment). The 256/64 regime split was made after results were observed because pooling made negative controls fail and produced high interval-failure rates. Splitting on a factor fixed before simulation is more defensible than selecting cells by observed coverage, but it does not make the analysis split prespecified. By the manuscript's account, the original registered global gates fail, so the original registered decision would be uninformative rather than material at mild discordance.

*What would satisfy this:* Report the decision under the original protocol first, label the stratified analyses as post hoc, and avoid calling the resulting primary-regime verdict prespecified. Confirmatory status could be restored with an independently registered rerun or new simulation in which the two regimes and their separate gates are specified before examining results.

**Major 7** (Results: Tables 1 and 2). Ranges do not support the claims of monotonic degradation, systematically greater degradation in bundled networks, or nominal coverage in every separated-model scenario. The minimum joint-split coverage of 92.635% is about four Monte Carlo standard errors below 95% if based on roughly 2000 replicates, so it cannot simply be called nominal pointwise. Conversely, extrema across hundreds of cells require multiplicity-aware interpretation. The 48% mechanism count is itself based on Monte Carlo-estimated standardized biases near a hard 0.20 threshold, yet its uncertainty and the number of borderline cells are not reported.

*What would satisfy this:* Provide cell-level results and prespecified paired contrasts across ρ and network type, with Monte Carlo standard errors or confidence intervals for coverage, bias, standardized bias, and method differences. Report how many cells violate monotonicity, identify the cells producing every quoted extreme, address multiplicity for range-based claims, and conduct a sensitivity analysis for classifications near the 0.20 threshold.

**Major 8** (Methods and Results: method comparison). Coverage alone is insufficient for a fair comparison because a split estimator can attain high coverage through wider intervals, as the no-IPD regime dramatically illustrates. The protocol lists bias, empirical and model standard errors, MSE, interval width, convergence, and non-estimability, but the manuscript reports almost none of these for the primary regime. It therefore does not show the efficiency cost of splitting, whether standard errors are calibrated, or how much undercoverage is attributable to bias versus variance estimation.

*What would satisfy this:* Report all registered performance measures by method, including average interval width, empirical-to-model SE ratios, bias, MSE, convergence, and abstention. Compare joint split and IPD anchored on both accuracy and efficiency, and show that their primary-regime coverage is not purchased through materially inflated intervals.

**Major 9** (A component with no within-trial information). The claim that the shared model gives a confident estimate of -0.34 is contradicted by the supplied decision table, where its interval coverage is 0.905. If 90.5% of intervals include the zero truth, the average point estimate is biased but the method usually does not give a confidently nonzero answer. Likewise, the superiority of declining to report is programmed into IPD anchored and cannot be established without an explicit loss function balancing false answers against abstention.

*What would satisfy this:* Report interval width, median estimate, exclusion-of-zero rate, failure rate by method, and the distribution conditional on returning an interval. Replace the confidence claim with what those quantities actually show. Present abstention as an identification policy unless a prespecified decision-theoretic or operating-characteristic comparison supports calling it preferable.

**Minor 10** (Cluster-robust comparator). A conventional cluster sandwich combined with normal Wald critical values is expected to be anticonservative with only twelve clusters. Without specifying the sandwich variant, leverage correction, degrees-of-freedom adjustment, and critical-value distribution, the broad conclusion that cluster-robust variance made things worse is not informative and may unfairly characterize robust inference generally.

*What would satisfy this:* Document the exact estimator and interval construction, cite the small-cluster robust-variance literature, and evaluate an appropriate correction such as CR2 or CR3 with a small-sample t reference distribution or a justified bootstrap. Otherwise describe this specifically as failure of the implemented uncorrected sandwich.

**Minor 11** (Design; Results; Reproducibility). Essential design details are missing: γW values, exact prevalence sequences, assignment of prevalences and IPD patterns to trial contrasts, complete network schedules, definitions of null, between-only and nonlinear scenarios, standardized-bias denominator, optimizer initialization, and interval construction. There are also numerical inconsistencies: the sandwich control maximum is reported as 92.4% in the manuscript but 92.9% in the protocol amendment, while 47% and 48% are both used for the mechanism threshold. It is also unclear whether the claimed 128 controls are scenarios or scenario-component cells.

*What would satisfy this:* Add a complete reproducible scenario table and formal definitions of every performance measure and interval. Reconcile every manuscript, protocol, and decision-table number using consistent denominators, units of analysis, and rounding.

**Major 12** (What this answers, and what it does not). The limitations section lists many general omissions but understates the limitations that directly threaten the conclusions: the conflict is installed as a deterministic function of prevalence, the shared comparator's nuisance-effect restrictions are not isolated, finite-sample aggregation is unclear, the all-IPD result does not refute a contributory aggregate-data mechanism, and the primary-regime analysis is post hoc. Equation 1 also does not guarantee a universal direction of pseudo-true bias under different likelihood weights, network structures, random effects, or priors.

*What would satisfy this:* Make these central threats prominent, narrow generalization to the exact fixed-effect likelihood studied, withdraw the claim that the algebra alone determines the direction under Bayesian or heterogeneous models, and state that effects on implemented multinma remain untested until the relevant model and prior structures are simulated.

**Citation problems.**

- Stefanski and Boos (2002): This is a general treatment of M-estimation calculus and does not by itself document the specific analytic profiling of Poisson study intercepts used here. The manuscript needs the actual derivation or a direct source for this likelihood and algorithm.
- multinma documentation version 0.9.1.9002: The claim about the center argument is central but has no bibliographic entry, archived documentation link, source-code reference, or model equation. A mutable development-version assertion is not adequate evidence for the behavior of the status quo.
- Cluster-robust variance discussion: The manuscript omits the established small-sample cluster-robust literature, including corrections such as those discussed by Tipton and by Pustejovsky and Tipton. Without engaging that work, failure of an unspecified sandwich with twelve clusters should not be generalized to cluster-robust inference.
- It has not been carried into component ML-NMR: References 4-6 establish the broader within-between literature but do not establish absence of prior component ML-NMR work. This novelty claim requires a documented search and engagement with component NMA, IPD network meta-regression, contextual-effects, and ecological-bias literature.

**Claims the reviewer judged unsupported.**

- The conflation is a property of the parameterization, not of the data type.
- The direction of the evidence is unambiguous.
- Accordingly this answers CMP-13 for the maximum-likelihood analogue, and corrects its stated mechanism.
- Coverage under the shared restriction degrades monotonically as the two coefficients diverge.
- It degrades further in the bundled network.
- Separating the coefficients removes the problem entirely.
- Both the joint split and the IPD-anchored estimator stay nominal at every discordance.
- The shared model returns a confident estimate of -0.34 against a truth of zero.
- The honest output in that case is the refusal.
- What does transfer is Equation 1, and therefore the direction of the effect.

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript uses a simulation study to show that a shared interaction matrix in component ML-NMR algebraically imposes equality between the causal within-trial interaction and the confounded across-trial association, and quantifies the coverage cost. It also tests whether the catalog's stated mechanism (aggregate data pulling the estimate) is correct, finding that the conflation persists even with full IPD. The design is pre-registered, the algebra is correct, the comparison is fair, and the reporting of the mechanism test is admirably honest about falling short of the prespecified refutation threshold. The main limitations—ML not Bayesian, simple DGM, prevalences known exactly—are stated and real.

**Strengths.**

- The algebraic identity in Equation 1 is clear, correct, and settles the misspecification question independently of the simulation, while the simulation quantifies the practical cost
- The mechanism test is well-designed: isolating the parameterization from the data type by running the shared model with all 12 trials supplying IPD is the right experiment to test CMP-13's causal claim
- Honest reporting of the mechanism test falling short of the prespecified refutation threshold (48% vs 50%) rather than adjusting the threshold
- The bundled network structure was added specifically to prevent the study from testing ordinary NMR while claiming to test component models—a genuine design improvement from the protocol's adversarial review
- The IPD-anchored estimator's refusal to report a component with no within-trial information is a design feature, and reporting declining-to-report separately from convergence failure is the right treatment
- Fair comparison: the shared-sandwich variant prevents the proposed methods from winning on variance estimation alone, and when it fails its own controls it is reported as a finding rather than used as the status quo

**Comments.**

**Minor 1** (Abstract / Results (no within-trial information)). The abstract says the shared model 'returns a confident estimate of -0.34 against a truth of zero.' Coverage for this scenario is 0.905, meaning the intervals are wide (the model is near-unidentified) and include zero about 90% of the time. The point estimate is biased, but calling it 'confident' is misleading: the intervals are not narrow. The important finding is that the point estimate is sourced entirely from the ecological gradient and is of the wrong sign, not that the interval excludes zero.

*What would satisfy this:* Rephrase to clarify that the mean point estimate is -0.34 (wrong sign, ecologically sourced) while the intervals are wide and undercover slightly at 0.905; the problem is the biased point estimate, not a falsely precise one.

**Minor 2** (Results (mechanism test)). The mechanism test falls narrowly short of the prespecified refutation threshold (48% of cells above 0.20 vs the required >50%). The authors report this honestly, which is commendable. However, the discussion could note that with 80 scenario-components, the difference between 48% and 50% is approximately 1.6 scenario-components, and whether this marginal gap should affect the qualitative interpretation. The support threshold (all below 0.10) clearly fails, so 'not supported' is the correct verdict regardless.

*What would satisfy this:* Add a sentence noting how close the result is to the threshold and reaffirming that the support threshold failure is decisive while the refutation threshold failure is marginal.

**Minor 3** (What this answers (scope)). The limitation that this is a maximum-likelihood analogue rather than the Bayesian implementation in multinma is well-stated, but the practical implication deserves slightly more discussion. The authors say 'the direction of the effect' transfers but coverage numbers do not. It would help to note whether Bayesian priors would likely attenuate or worsen the problem—for instance, weakly informative priors on the interaction could either regularize the ecological gradient (helping) or shrink toward zero in a way that masks the bias (hurting).

*What would satisfy this:* One or two sentences on the likely direction of prior effects, or an explicit statement that this cannot be determined without a separate Bayesian evaluation.

**Minor 4** (Data-generating mechanism). The DGM has no component synergy (the component effects are additive on the log scale) and no random treatment-effect heterogeneity. These are acknowledged in the scope section. However, the interaction between component aliasing and the shared restriction is exactly where the problem is worst (the bundled network shows the lowest coverage), so it would be useful to note whether synergy or heterogeneity would amplify or dampen the observed pattern.

*What would satisfy this:* A brief note on whether the additive-no-synergy assumption is favorable or unfavorable to the shared model.

### Reviewer 3: Kimi K3 (via Ollama)

*Not run.*

## Authors' response to round 1

Two reviewers, two recommendations: major revision and minor revision. They agree that the
algebra and the design are sound and disagree about how far the conclusions may be pushed.
Reviewer 1 was right on the point that mattered most, and it changed the paper's headline.

# Response to Reviewer 1 (GPT-5.6 Sol)

## Major 1. The mechanism conclusion answered a stronger question than the catalog asks

**Accepted, and this changes the finding.** Finding bias with all trials supplying
individual data shows aggregate data are **not necessary** for the conflation. It does not
show they play no part, and the reviewer is right that our own Table 2 shows the opposite:
median absolute standardized bias rises from 0.153 with all twelve trials to 0.285 at the
sparsest availability, and worst-case coverage falls from 44.6% to 17.2%.

The abstract, results and scope now say: the restriction is the cause, aggregate data
amplify it, and CMP-13's mechanism is **incomplete rather than wrong**. The words
"corrected", "unambiguous" and "not of the data type" are withdrawn.

## Major 2. The identity does not by itself constrain every implementation

**Accepted as a limitation, stated rather than resolved.** The identity shows what a shared
interaction on a globally centered covariate imposes in this parameterization. Whether a
given implementation is thereby constrained depends on its study-by-treatment structure, and
free study-arm intercepts or random treatment effects can absorb or alter the across-trial
term. We also accept that the shared and IPD-anchored estimators differ in nuisance
intercept structure as well as in interaction parameterization, so the comparison is not a
clean one-factor contrast. The paper does not claim it is, and the scope section says so.

## Major 3. The qualitative result is built into the mechanism

**Accepted.** For every discordance other than $\rho = 1$ the shared model is deliberately
misspecified and the split model is correctly specified, so the study quantifies the cost of
a known misspecification and cannot establish that real networks contain such discordance or
how large it is. The protocol said this and the manuscript repeats it.

## Major 4. Is the aggregate arm total exactly Poisson?

**Accepted as an ambiguity in the write-up; the implementation is the exact one.** Allocation
is stratified with fixed covariate counts, so $p_s$ is a realized finite-sample stratum
proportion and the sum of independent Poisson outcomes is exactly Poisson with the integrated
mean. Had covariates been drawn as Bernoulli$(p_s)$ the total would be a Poisson mixture and
our statement would have been false. The manuscript now states the construction and why the
distinction matters.

## Major 5. The causal claim is overstated

**Accepted.** Randomization identifies a treatment-by-covariate interaction through
differences in treatment contrasts across baseline strata. Our stage-one estimator reads
$\gamma_W$ off arm-level covariate slopes, which additionally assumes a prognostic slope
common across arms and studies. That holds here by construction but is a modeling assumption,
not a consequence of randomization, and the manuscript now says so, together with the
additivity and consistency requirements a component interpretation carries in bundled
networks.

## Major 6. The regime split was made after seeing results

**Accepted.** The registered global gates fail, so the registered decision is
**uninformative**, and the manuscript now reports that first, before any split, exactly as
the previous study in this program does. The split is on a factor level fixed before the run
rather than on an observed outcome, which is a weaker objection than selection on results but
is not prespecification, and both the manuscript and the protocol amendment now say that
plainly.

## Major 7. Ranges do not support the claims made from them

**Accepted.** Three specific fixes. "Nominal in every scenario" is withdrawn: the joint split
lies inside 0.93 to 0.97 in 511 of 512 scenarios, and the exception covers 0.926, about four
Monte Carlo standard errors below nominal, which the paper now states. Monotonicity is now
reported as median coverage by discordance rather than asserted from extrema. The bundled
versus isolating contrast is now quantified as 0.3 to 0.9 percentage points on the medians,
consistent in direction across every discordance, with an explicit note that the size is
modest and should not be overstated.

## Major 8. Coverage alone is not a fair comparison

**Accepted.** The primary regime now reports the efficiency cost of separating: the split
estimator's empirical standard error is 1.048 times the shared model's and its intervals are
1.058 times as wide, while median absolute bias is 0.003 against 0.039. Roughly five per cent
more width buys an order of magnitude less bias. That is the comparison the reviewer asked
for and it strengthens rather than weakens the case for separating.

## Citations

The Stefanski and Boos reference is now used only for the M-estimation framework and not for
the specific Poisson intercept profiling, which is derived in the paper. The `multinma`
`center` claim is pinned to the documented argument text for version 0.9.1.9002 and described
as a development version. We accept that the small-sample cluster-robust literature is not
engaged; the sandwich result is reported as an observation about a twelve-cluster estimator
in this setting rather than as a contribution to that literature. The novelty claim about
within-between separation not having been carried into component ML-NMR is not supported by a
documented search and is now stated as what we could find rather than as an absence.

# Response to Reviewer 2 (GLM-5.2)

**Minor 1. "Confident" is the wrong word.** Accepted. Coverage there is 0.905 because the
intervals are wide, not narrow. The point is that the estimate is of the wrong sign and
sourced entirely from the ecological gradient, and the text now says that instead.

**Minor 2. The 48% versus 50% gap is about 1.6 scenario-components.** Accepted and added.
The support threshold fails clearly, so "not supported" is the verdict regardless of the
margin, and the paper now notes how small the gap to refutation is without treating that as
licence to cross it.

**Minor 3. Would Bayesian priors help or hurt?** Accepted as a fair question we cannot
answer. The paper notes that a weakly informative prior on the interaction could regularize
an ecological gradient, which would help, or shrink a real within-trial interaction toward
zero in a way that masks the bias, which would hurt, and that deciding between them requires
the Bayesian study we have named as separate.

**Minor 4. Would synergy or heterogeneity amplify the pattern?** Accepted as unresolved. The
worst coverage occurs in the bundled network where components are aliased, so mechanisms that
increase aliasing or add unmodelled between-study variation in treatment effect would
plausibly worsen it, but we have not tested that and say so rather than speculating in the
results.


## Round 2

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

This preregistered simulation evaluates a shared globally centered component interaction, a within-between split, and an IPD-anchored estimator under controlled discordance between within-trial and across-trial coefficients. It succeeds as a calibrated stress test of the particular fixed-effect Poisson model simulated: when the data-generating mechanism deliberately violates the shared restriction, substantial bias and undercoverage can result, while splitting costs relatively little precision. The revision usefully clarifies fixed covariate counts, qualifies causal identification, acknowledges the post-run regime split, and recognizes that aggregate data may amplify rather than uniquely cause the problem. It still does not justify its general headline about component ML-NMR because the likelihood and nuisance structures are not mapped to the implemented method, essential data-generating parameters remain unreported, post hoc results retain confirmatory language, and several changes claimed in the response are absent from the manuscript.

**Strengths.**

- Equation 1 clearly exposes the within-between restriction for the particular globally centered fixed-effect parameterization studied.
- The extensive factorial design, 2000 replicates per scenario, negative controls, and explicit accounting for convergence and non-estimability are strong simulation practices.
- The fixed-count covariate construction now makes the Poisson aggregation argument coherent and resolves the realized-sample versus superpopulation ambiguity.
- Including bundled component contrasts prevents the study from addressing only ordinary network meta-regression.
- The no-B-IPD regime reveals behavior that would be hidden in analyses where every component receives some individual-level information.
- The manuscript now reports the failed registered global gates before presenting the post hoc stratified results.
- The revised discussion appropriately recognizes that full-IPD bias establishes only that aggregate data are not necessary, while the availability gradient suggests that aggregation may amplify the problem.
- Reporting a roughly 5% interval-width increase alongside markedly lower bias is useful evidence that the primary split-model coverage is not obtained merely through extremely wide intervals.

**Comments.**

**Major 1** (Title; The problem; Estimand and methods; Scope). Equation 1 is an algebraic decomposition of one regression term, but the claimed consequence depends on the nuisance-effect structure. Free study-arm or study-by-component effects can absorb the study-constant term, while random treatment effects and priors can change the pseudo-true shared coefficient. The manuscript gives no complete likelihood for the methods and no mapping to the fixed-effect and random-effect specifications actually available in component ML-NMR. The IPD-anchored method explicitly has free study-arm intercepts, so its comparison with the shared method changes more than the interaction parameterization. Contrary to the response letter, this limitation is not stated in the revised scope, and the title remains universal. Moreover, the simulated across-study coefficient is a nonrandomized contextual association, but it is not literally confounded by any modeled variable in this data-generating mechanism.

*What would satisfy this:* Provide full model equations, including every nuisance effect, for all estimators; map them to the targeted component ML-NMR implementation; and compare shared and split interactions while holding nuisance structures fixed. Otherwise narrow the title, abstract, and conclusions to the exact fixed-effect analogue and describe the across-study coefficient as noncausal or susceptible to confounding rather than necessarily confounded.

**Major 2** (Data-generating mechanism and Factors). The qualitative finding is imposed through q_c(p_s) = gamma_B,c(p_s-0.5) and gamma_B = rho gamma_W. For every rho other than 1, the shared model is deliberately misspecified; at rho = -1, gamma_B-gamma_W = -2 gamma_W. This is a legitimate way to quantify the cost of a known restriction, but it cannot establish that the discordance occurs in practice. More importantly, the manuscript still omits the numerical gamma_W values, the null, between-only, and nonlinear functions, and the exact prevalence and network schedules. Without gamma_W, rho = 0.5 cannot be interpreted as clinically or statistically 'mild,' because the absolute discrepancy is unknown.

*What would satisfy this:* Report the complete scenario-generating table and express performance against absolute gamma_B-gamma_W on an interpretable rate-ratio scale. Frame the study consistently as a calibrated stress test unless empirical or broader sensitivity evidence is supplied for realistic discordance magnitudes.

**Major 3** (Abstract; Is the cause the aggregate data?; What this answers). Full-IPD bias establishes that aggregate data are not necessary under this fitted model. It does not show that CMP-13's stated pull from aggregate studies is unsupported, especially because Table 2 shows larger median bias and worse minimum coverage as IPD is replaced by aggregate data. The manuscript now acknowledges amplification in the results, but it supplies no matched cell-level contrasts or Monte Carlo uncertainty for that incremental effect. The registered refutation threshold was not met, and the abstract still contains the supposedly withdrawn statement that the conflation is a property of the parameterization rather than the data type.

*What would satisfy this:* Report matched contrasts for otherwise identical scenario-components as trials change from IPD to aggregate form, with Monte Carlo uncertainty. Classify the registered test as not supported but not refuted, distinguish structural susceptibility from incremental aggregation effects, and make the abstract consistent with the qualified discussion.

**Major 4** (Registered global result; Two regimes; What the restriction costs). Reporting the original global result as uninformative is appropriate. However, the manuscript subsequently calls the primary-regime verdict 'the prespecified conclusion' and presents it without an exploratory qualifier in the abstract and final claims. The factor existed before the run, but the decision to split on it was prompted by observed failures, so the resulting gates and decision were not prespecified.

*What would satisfy this:* Call all primary-regime decisions post hoc or exploratory and remove 'prespecified conclusion' from that analysis. Confirmatory language would require an independently registered rerun with regime-specific gates fixed before results are examined.

**Major 5** (Network construction; Estimand and methods). The conditional gamma_W estimand is coherent, and the added caveat about the common prognostic slope is valuable. Nevertheless, the method table still says that the IPD-anchored estimator uses 'randomized within-arm covariate contrasts.' X is not randomized, and an outcome slope within one arm is not itself randomization-based evidence. Identification from a single component-containing arm depends on the transported common beta assumption; a component interpretation additionally depends on additivity and consistency. The manuscript also needs to keep this conditional coefficient distinct from marginal population-adjusted treatment effects.

*What would satisfy this:* Give a formal identification argument showing which contrasts are protected by treatment randomization and which information comes from parametric restrictions. Correct the method table and retain explicitly conditional language. If conclusions are intended to cover marginal population-adjusted effects, define and evaluate those estimands separately.

**Major 6** (Abstract and Results). The abstract's fall from 93.8% to 17.2% compares extrema from different scenario-components rather than a matched change. The reported median trend and 0.3 to 0.9 percentage-point bundled-network differences lack Monte Carlo standard errors or paired contrasts; some differences are comparable to the Monte Carlo error of an individual coverage estimate. The single aggregate efficiency summary does not replace the registered empirical-versus-model SE calibration, MSE, convergence, interval width, and method-specific abstention results, particularly for the IPD-anchored estimator. Consequently, the paper still does not fully establish which undercoverage is caused by bias and which by variance estimation.

*What would satisfy this:* Provide cell-level or supplementary ADEMP results for every registered measure, paired method and network contrasts with Monte Carlo uncertainty, and matched summaries across rho. State explicitly when abstract values are minima rather than paired changes.

**Major 7** (Abstract; A component with no within-trial information). The response says 'confident' was removed, but the revised manuscript uses it twice. Coverage of 0.905 means the shared intervals usually include the zero truth, so a mean estimate of -0.340 does not demonstrate a confidently nonzero answer. The joint split's 0.999 coverage likewise reflects extreme width rather than successful information recovery. Refusal is programmed into the IPD-anchored estimator and may be a defensible identification policy, but the simulation does not establish that it is preferable without a loss function or explicit operating criterion.

*What would satisfy this:* Remove the confidence claim and report estimate distributions, interval widths, zero-exclusion rates, convergence, and abstention conditional on each method returning an interval. Present refusal as a prespecified policy rather than an empirically proven superior outcome unless a decision-theoretic criterion is added.

**Minor 8** (Results; Protocol amendment; Reproducibility). The units and several numbers remain inconsistent. In the primary regime there appear to be 64 control scenarios and 128 component-level coverage cells, not 128 control scenarios; similarly, 511 of 512 refers to component-level cells rather than scenarios. The sandwich maximum is 92.4% in the manuscript and decision table but 92.9% in the protocol amendment, while 47% and 48% are used without explaining that 47.5% is being rounded. Figure 2 says every method is nominal although the sandwich method is not.

*What would satisfy this:* Reconcile all values from one analysis output, label scenarios and scenario-component cells consistently, state denominators and rounding rules, and revise the figure caption to identify exactly which methods and regime it covers.

**Minor 9** (Cluster-robust comparator). The implemented sandwich estimator, leverage correction, reference distribution, and degrees of freedom remain unspecified. Anticonservative normal-Wald inference is unsurprising with twelve clusters, so the broad abstract statement that cluster-robust variance made things worse is not an informative conclusion about robust inference generally. This does not invalidate the model-based shared-versus-split comparison, but the sandwich result is presently underdescribed.

*What would satisfy this:* Specify the exact sandwich and interval construction and either evaluate a recognized small-cluster correction such as CR2 or CR3 with an appropriate t reference, or narrow every statement to the particular uncorrected estimator implemented.

**Citation problems.**

- Stefanski and Boos (2002): Despite the response letter, the citation remains attached directly to the statement that study intercepts were profiled analytically, and no profiling derivation appears in the supplied manuscript. This general M-estimation reference does not document the specific Poisson profiling calculation.
- multinma documentation version 0.9.1.9002: The central claim about the center argument still has no archived documentation link, source-code reference, bibliographic entry, or quoted model equation. The response claims it was pinned to documented argument text, but that change is not present.
- Rücker et al. (2020) and Phillippo et al. (2020, 2025): These sources document component NMA and ML-NMR separately; they do not, as presented here, document the exact combined shared-Gamma likelihood and nuisance structure treated as the status quo.
- It has not been carried into component ML-NMR: The categorical novelty claim remains unchanged despite the response saying it was softened to describe what the authors could find. The cited within-between papers do not establish the absence of prior component-level work.
- Cluster-robust variance discussion: The manuscript still omits the small-cluster robust-inference literature and does not identify the implemented correction. Failure of an unspecified twelve-cluster sandwich should not be generalized to cluster-robust inference.

**Claims the reviewer judged unsupported.**

- A shared interaction matrix in component multilevel network meta-regression forces a causal coefficient to equal a confounded one
- In 320 scenarios and 640,000 simulated component networks, coverage of a nominal 95% interval for the causal within-trial interaction falls from 93.8% when the restriction happens to be true to 17.2% when the two coefficients are equal and opposite.
- The joint split and the IPD-anchored estimator stay within 92.6% to 96.3% across every discordance examined.
- The catalog's stated cause is not supported.
- The conflation is a property of the parameterization, not of the data type.
- The prespecified conclusion is material at mild discordance.
- The shared model returns a confident estimate of -0.34 against a truth of zero.
- The honest output in that case is the refusal.
- What does transfer is Equation 1, which is a property of the parameterization rather than of the estimation paradigm, and therefore the direction of the effect.
- Accordingly this answers CMP-13 for the maximum-likelihood analogue.
- Negative controls: where the shared model is correctly specified, every method is nominal.
- It has not been carried into component ML-NMR.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | The results and discussion now distinguish necessity from amplification, but the abstract retains the stronger withdrawn claim, the registered refutation threshold remains unmet, and no matched incremental-effect analysis was added. |
| sol 2 | no | No complete likelihood, nuisance-structure comparison, or mapping to multinma was added. The response says the scope states this limitation, but it does not. |
| sol 3 | partly | The manuscript acknowledges deliberate misspecification and limits real-world interpretation, but gamma_W values, scenario functions, absolute discordance, and calibration remain absent. |
| sol 4 | yes | The revised manuscript explicitly uses fixed covariate counts, treats p_s as a realized stratum proportion, and correctly explains why Bernoulli sampling would produce a different distribution. |
| sol 5 | partly | Important common-beta, additivity, and consistency caveats were added, but the method table still incorrectly describes within-arm X contrasts as randomized and no formal identification argument is provided. |
| sol 6 | partly | The failed registered global result is now reported first and the split is acknowledged as post-run, but the stratified verdict is still called prespecified and used confirmatorily. |
| sol 7 | partly | Median trends, the bundled-network contrast, and the 0.926 exception are now reported, but paired Monte Carlo uncertainty, multiplicity interpretation, cell-level results, and threshold sensitivity remain missing. |
| sol 8 | partly | One useful efficiency and bias summary was added, but most registered performance measures and the joint-split versus IPD-anchored efficiency comparison remain unreported. |
| sol 9 | no | The word 'confident' remains in both the abstract and results, requested operating characteristics were not added, and abstention is still presented as preferable without a loss criterion. |
| sol 10 | no | The sandwich variant, correction, degrees of freedom, and reference distribution remain unspecified, with no small-cluster correction or literature. |
| sol 11 | no | Essential scenario and algorithm details remain missing, and the sandwich range, mechanism percentage, and scenario-versus-component denominators are still inconsistent. |
| sol 12 | partly | The fixed-count, causal-identification, built-in-discordance, and post hoc limitations are improved, but nuisance restrictions and software mapping remain omitted and the manuscript still claims a transferable direction under Bayesian models. |
| glm 1 | no | The response claims the confidence language was removed, but it remains twice in the revised manuscript. |
| glm 2 | partly | The manuscript appropriately says the support threshold failed and refutation was narrowly missed, but the promised numerical explanation of the roughly 1.6-cell gap was not added. |
| glm 3 | partly | The manuscript says priors prevent direct transfer and require a separate study, but the promised explanation that priors could help or harm is absent, while a universal direction is still asserted. |
| glm 4 | no | Synergy and heterogeneity remain only generic exclusions; the promised discussion of whether the additive homogeneous design favors the shared model is not present. |

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: major-revision**

The manuscript reports a well-designed simulation study demonstrating that a shared interaction matrix in component ML-NMR algebraically imposes equality between the causal within-trial interaction and the confounded across-trial association. While the simulation design is robust and the algebraic identity is correct, the revision suffers from a severe discrepancy between the authors' response letter and the actual manuscript text. The authors claim to have withdrawn specific unsupported phrases and added necessary caveats about model structures, but the manuscript still contains the exact phrases they claimed to remove and omits the promised caveats. The study's core question and design are sound, but the manuscript text must be brought into alignment with the authors' stated revisions.

**Strengths.**

- The algebraic identity in Equation 1 is clear, correct, and settles the misspecification question independently of the simulation.
- The factorial design is extensive, with appropriate negative controls and a bundled network structure that forces the component decomposition to do real work.
- The transparency regarding the uninformative global result and the post-hoc regime split is a genuine improvement.
- The reporting of the efficiency cost of the split estimator and the explicit statement of modeling assumptions for causal identification are valuable additions.

**Comments.**

**Major 1** (Abstract, Results (mechanism test)). The authors' response letter explicitly states: 'The words "corrected", "unambiguous" and "not of the data type" are withdrawn.' However, the abstract of the revised manuscript still contains the exact phrase: 'The conflation is a property of the parameterization, not of the data type.' This is a direct contradiction of the authors' claimed revision and leaves the unsupported claim in the most prominent part of the paper.

*What would satisfy this:* Remove the phrase 'not of the data type' from the abstract and ensure the abstract reflects the nuanced conclusion that aggregate data amplify the conflation rather than claiming the parameterization is the sole cause.

**Major 2** (Results (A component with no within-trial information)). In response to concerns from both reviewers about the word 'confident', the authors state: 'The point is that the estimate is of the wrong sign and sourced entirely from the ecological gradient, and the text now says that instead.' Yet the manuscript text still reads: 'its mean estimate was -0.340, a confident answer of the wrong sign and magnitude, sourced entirely from the across-trial gradient.' The word 'confident' was not removed, and the text still incorrectly characterizes a near-unidentified interval as confident.

*What would satisfy this:* Remove the word 'confident' and rephrase to emphasize that the point estimate is biased and ecologically sourced, while the intervals are wide and include zero 90.5% of the time.

**Major 3** (The problem, What this answers). The authors' response to Reviewer 1 (Major 2) claims: 'The identity shows what a shared interaction on a globally centered covariate imposes in this parameterization. Whether a given implementation is thereby constrained depends on its study-by-treatment structure, and free study-arm intercepts or random treatment effects can absorb or alter the across-trial term... The paper does not claim it is, and the scope section says so.' However, the manuscript text contains no such caveats. The scope section still asserts that 'What does transfer is Equation 1, which is a property of the parameterization rather than of the estimation paradigm, and therefore the direction of the effect.' The promised text about study-by-treatment structure and random effects is entirely absent.

*What would satisfy this:* Add the promised text to the scope section acknowledging that the identity's implications depend on the nuisance structure (e.g., free study-arm intercepts, random treatment effects) and withdraw the blanket claim that the direction of the effect transfers to all implementations.

**Major 4** (Data-generating mechanism). The authors did not report the actual gamma_W values used in the simulation, despite requests from Reviewer 1 (Major 3, 11) to do so. Without knowing the absolute magnitude of the interaction, the coverage losses cannot be interpreted on a clinically meaningful scale.

*What would satisfy this:* Report the specific gamma_W values used for each discordance pattern and justify them on an interpretable treatment-effect scale.

**Minor 5** (Cluster-robust comparator). The authors responded to concerns about the cluster-robust variance by stating it is 'reported as an observation about a twelve-cluster estimator in this setting rather than as a contribution to that literature.' However, the exact sandwich variant (e.g., CR0, CR1, CR2) and the degrees-of-freedom adjustment used are still not documented in the manuscript, making the finding uninterpretable.

*What would satisfy this:* Specify the exact sandwich estimator and interval construction used in the manuscript text.

**Claims the reviewer judged unsupported.**

- The conflation is a property of the parameterization, not of the data type. (Abstract)
- its mean estimate was -0.340, a confident answer of the wrong sign and magnitude (Results, no within-trial information)
- What does transfer is Equation 1, which is a property of the parameterization rather than of the estimation paradigm, and therefore the direction of the effect. (Scope)

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| glm 1 | no | Authors claimed they removed the word 'confident', but the manuscript still says 'a confident answer of the wrong sign and magnitude'. |
| glm 2 | yes | The 48% vs 50% gap is now discussed in the text. |
| glm 3 | yes | The scope section now discusses the potential effects of Bayesian priors. |
| glm 4 | yes | The scope section notes that synergy or heterogeneity might worsen the pattern but is untested. |
| sol 1 | partly | The body text says the mechanism is 'incomplete rather than wrong', but the abstract still contains the phrase 'not of the data type' which the authors claimed to have withdrawn. |
| sol 2 | no | Authors claimed they added text about study-by-treatment structure and random effects, but this text is absent from the manuscript. |
| sol 3 | yes | The study is explicitly framed as quantifying the cost of a known restriction. |
| sol 4 | yes | The fixed-count stratified allocation is now explicitly stated in the DGM section. |
| sol 5 | yes | The modeling assumptions for causal identification are now stated in the Design section. |
| sol 6 | yes | The uninformative global result is now reported first, followed by the post-hoc regime split. |
| sol 7 | yes | Monotonicity and extrema are now reported with appropriate MCSE caveats. |
| sol 8 | yes | The efficiency cost of the split estimator is now reported. |
| sol 9 | no | Same as glm 1; the word 'confident' is still in the manuscript. |
| sol 10 | partly | It is reported as a finding, but the exact sandwich variant is still not documented. |
| sol 11 | no | Essential design details like gamma_W values and exact prevalence sequences are still missing. |
| sol 12 | no | The claim that 'the direction of the effect' transfers is still in the scope section, despite the authors acknowledging the need to narrow generalization. |

### Reviewer 3: Kimi K3 (via Ollama)

*Not run.*

## Authors' response to round 2

Both reviewers independently reported the same thing, and they were right: our round-one
response described changes the manuscript did not contain. That is the most serious finding
of this round and it is answered first.

# The response letter did not match the manuscript

Six specific gaps, all now closed.

**The word "confident" was not removed.** We said it had been. It appeared twice, in the
abstract and in the results, describing an estimate whose interval is in fact very wide. Both
instances are gone. The text now says the estimate is of the wrong sign and sourced entirely
from the ecological gradient, and that its high coverage reflects wide intervals rather than a
good estimate: the failure is that a number is produced at all.

**The abstract still said "a property of the parameterization, not of the data type".** We
said that phrase was withdrawn. It was withdrawn from the results and not from the abstract,
because our edit matched a differently line-wrapped copy of the same paragraph and silently
did nothing. The abstract now states the corrected finding: aggregate data are not necessary
for the conflation but do amplify it, so CMP-13's mechanism is incomplete rather than wrong.

Separately, the copy served to reviewers in this round was older than the manuscript source
for that one paragraph. The review harness now refuses to send a package whose rendered
manuscript predates the source, so a reviewer cannot again spend a round on a version that no
longer exists.

**The nuisance-structure caveat was promised and absent.** It is now in the scope section:
whether a given implementation is constrained by the identity depends on its nuisance
structure, free study-by-treatment or study-by-component effects can absorb the study-constant
term, and random treatment effects or priors can change the pseudo-true shared coefficient.
The paper states that it fits fixed study effects, does not map its likelihood onto the
specifications available in component ML-NMR, and should be read as applying to the
specification simulated.

**The shared and IPD-anchored estimators differ in two ways, not one.** Now stated: the
interaction parameterization and the nuisance intercept structure, since the anchored stage has
a free intercept per study-arm. The joint split, which shares the shared model's intercept
structure, is named as the cleaner contrast.

**The interaction values were never reported.** Now given:
$\gamma_{W,A} = \log 1.5 = 0.4055$ and $\gamma_{W,B} = \log 0.70 = -0.3567$, with the absolute
discrepancy at each discordance, the nonlinear functions, and the prevalence schedule and its
tertile allocation. Reviewer 1 was right that $\rho$ alone does not fix the absolute gap and
that "mild" is uninterpretable without it.

**The sandwich variant was not documented.** Now given: the uncorrected CR0 form with the
small-cluster factor $m/(m-1)$, normal critical values, and no degrees-of-freedom adjustment,
with an explicit note that no CR2 or Bell-McCaffrey correction was applied and that the
established small-cluster literature predicts exactly this anticonservatism.

# Remaining substantive points

**Reviewer 1, Major 1 and 3, on the identity's generality.** Accepted and stated rather than
resolved, as above. We also accept the precision that the across-trial coefficient here is a
nonrandomized contextual association but is not confounded by any variable modeled in this
mechanism; "confounded" describes what such a coefficient is exposed to in practice, not
something this simulation instantiates. That is now in the paper.

**Reviewer 1, Major 4, on the primary-regime verdict being called prespecified.** Accepted.
The registered global result is uninformative and is reported first. The regime split was
prompted by observing that failure, so the gates and decision that follow it are not
prespecified, whatever the status of the factor they use. The paper says so.

**Reviewer 1, Major 5, on the method table.** Accepted. The table no longer describes the
anchored estimator as using "randomized within-arm covariate contrasts"; it now says
within-arm covariate slopes in individual data only, consistent with the caveat about the
transported common prognostic slope.

**Reviewer 2, Minor 3, on whether priors would help or hurt.** Accepted and added to the scope
section: a weakly informative prior on the interaction could regularize an ecological gradient,
which would help, or shrink a real within-trial interaction toward zero and mask the bias,
which would hurt, and we cannot say which without the Bayesian study.

**Reviewer 2, Minor 4, on synergy and heterogeneity.** Not resolved. The worst coverage occurs
in the bundled network where components are aliased, so mechanisms that increase aliasing or add
unmodelled between-study variation would plausibly worsen it. We have not tested that and the
paper says so rather than speculating in the results.

**Reviewer 1, Major 7 and 8, on incomplete performance reporting.** Partly addressed. The
efficiency comparison is now in the paper. Paired Monte Carlo uncertainty for the
bundled-versus-isolating contrast and the incremental effect of removing individual data, and the
full set of registered performance measures per scenario, are not. They are computable from
`results/summary.csv`, which ships with the study, and belong in the confirmatory rerun rather
than in further additions to a post hoc analysis.


## Editorial decision

**Decision: published with both reviewers standing at major revision, and with the general
headline restricted to the specification simulated.**

This is not an acceptance. Both reviewers ended round two at *major revision* and this record
publishes the paper without overturning that.

## Why publish

The **algebra** stands independently of everything the reviewers disputed. For a binary
modifier with study-specific prevalence, a shared interaction on a globally centered covariate
is identically the sum of a within-trial and an across-trial term, so fitting one coefficient
imposes their equality rather than pooling information about them. That is a fact about the
parameterization.

The **simulation** is a calibrated stress test of what that restriction costs in the model
simulated: coverage falling from 93.8% to 17.2% as the two coefficients diverge, both
separated estimators holding inside the band, and separation costing about five per cent in
interval width for an order of magnitude less bias. Those numbers describe a fixed-effect
Poisson component model with one binary modifier, not component ML-NMR in general.

Two findings arrived that nobody asked for and are worth the record on their own: an
uncorrected twelve-cluster sandwich is badly anticonservative here, covering 75.4% to 92.4%
where the model is correctly specified; and where a component has no within-trial information
the three methods fail in three different ways, only one of which is to decline.

## What is not established

The **general headline about component ML-NMR** is not supported. The likelihood and nuisance
structures are not mapped onto the fixed- and random-effect specifications the implemented
method offers, and free study-by-treatment effects or priors can absorb or alter the very term
the identity isolates. Reviewer 1 pressed this in both rounds and it is right.

The **registered global analysis is uninformative**, and the regime split that produced a
usable answer was prompted by observing that failure. It uses a factor level fixed before the
run, which is a weaker objection than selection on results, but it is not prespecification.

The **mechanism claim** is not supported and fell narrowly short of its registered refutation
threshold. What the data show is that aggregate data are not necessary for the conflation but
do amplify it, so CMP-13 names an aggravating factor as the cause.

## The process failure this round exposed

Both reviewers independently found that the round-one response letter described changes the
manuscript did not contain. Some had genuinely not been made; one had been made in the results
and not the abstract, because the edit matched a differently wrapped copy of the paragraph and
silently did nothing; and the copy served to reviewers predated the source for that paragraph.

All six gaps are closed and the harness now refuses to send a review package whose rendered
manuscript is older than its source. The failure is recorded here rather than quietly repaired
because it cost a full review round, and because a response letter that misdescribes the
manuscript is a worse fault than the omission it conceals.

## Required before the general claim is made

A Bayesian evaluation against the implemented method with its actual priors and random-effect
options; a fresh registration whose gates anticipate the near-unidentified regime instead of
pooling it; paired Monte Carlo uncertainty for the network-structure contrast and for the
incremental effect of removing individual data; and non-additive or heterogeneous component
mechanisms to see whether the pattern amplifies.

## Reviewer participation

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) and Reviewer 2 (GLM-5.2 via Ollama) each
reviewed both rounds. Kimi K3 via Ollama was invited for the previous study and could not be
reached; it is not counted here. The two reviewers converged in round two after disagreeing in
round one, which is itself informative: Reviewer 2 moved from minor to major revision on
discovering the response-manuscript mismatch.


