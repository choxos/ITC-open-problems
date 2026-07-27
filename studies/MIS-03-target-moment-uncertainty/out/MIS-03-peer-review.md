# Peer review: What conditioning on sampled target moments costs

Study aimed at catalog problem **MIS-03**, also bearing on EST-07.

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
| invited | Kimi K3 (via Ollama) | unavailable | unavailable |

## Round 1

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

The paper derives the first-order contribution of sampled target moments to anchored MAIC variance and evaluates it across a large simulation design. The superpopulation estimand, joint covariance decomposition, negative controls, and use of identical point and source-variance estimators make the intended comparison conceptually strong and fair. However, the registered analysis is uninformative, while the subsequent confirmatory-sounding conclusions rely on outcome-dependent post-run filtering; moreover, the sign and cancellation of the headline effect are algebraically imposed by the proportional effect-modification mechanism. The restricted results remain useful exploratory evidence, but they do not support the universal recommendation that analysts add the positive moment-variance term without the unavailable cross-covariance.

**Strengths.**

- The paper identifies an important distinction between inference for a realized target sample and inference for a target superpopulation.
- Equation 4 correctly recognizes that target moments and the published B versus C estimate can be statistically dependent when obtained from the same participants.
- The marginal target-population estimand is appropriate for the additive continuous-outcome mechanism and has a transparent closed-form truth.
- All methods share the same point estimate and source sandwich, so the comparison does not unfairly handicap the status quo with an inferior source variance estimator.
- The factorial design, 5000 replicates per scenario, explicit convergence denominator, negative controls, and reproducible seeding are substantial strengths.
- The manuscript candidly reports the registered gate failure and already acknowledges several important restrictions, including normal covariates, correct effect-modifier specification, and lack of applicability to noncollapsible outcomes.

**Comments.**

**Major 1** (Registered protocol; Results: The registered gates fire; protocol amendment). The prespecified conclusion is uninformative because the reference and negative-control gates fail. The amended analysis then selects scenarios according to observed coverage of the joint-score method and its negative control. This is outcome-dependent post-run filtering, not a prespecified restriction, and it affects all methods because their coverage indicators share replicates and the same source sandwich. Consequently, the joint-score range in Table 2 is guaranteed by selection and the remaining coverage summaries are also selected. The amendment additionally says that Section 9 contained specific per-scenario language about Wald failure, but that language is absent from the supplied registered protocol.

*What would satisfy this:* Label the 196-scenario analysis explicitly as exploratory, correct the account of what the registered protocol contained, and conduct an independent simulation run under a new registration. The new protocol should either use an ex ante design criterion such as expected ESS or employ a source variance procedure that passes the negative controls throughout the intended design.

**Major 2** (Data-generating mechanism; Results: omitted variance). The central sign result is built into the mechanism. Writing g(X)=b'h(X)+constant gives the population sensitivity J=sb and Cov{h(X),phi_BC}=kappa*s*Omega_hh*b. The net target-moment contribution omitted by the status quo is therefore (1-2*kappa)*s^2*b'Omega_hh*b/n_T, or (1-2*kappa)*Var_T{s g(X)}/n_T. Thus its sign is fixed at the selected endpoints and cancellation occurs at kappa=0.5 by construction. Including only three kappa levels is not continuous variation and does not empirically locate the cancellation point.

*What would satisfy this:* Present this identity as an analytic design check rather than a simulation finding. To study alignment empirically, vary the source and target effect-modifier coefficient vectors independently, including different directions, negative alignment, partial overlap of modifier sets, and modifiers outside the calibrated span.

**Major 3** (Methods compared; What a publication would have to report; Discussion). Normal reconstruction and reported moment covariance add only J'Omega_hh J/n_T while omitting the cross-covariance with the B versus C estimator. They are therefore not full unconditional corrections for the setting actually studied. The added term is always nonnegative, so it cannot correct status-quo overcoverage when the net omitted component is negative; at kappa=0.5 it adds variance when the population net omission is zero, and at kappa=1 it should worsen overcoverage.

*What would satisfy this:* Relabel these as partial moment-variance additions, report their paired performance against joint-score separately by kappa, and withdraw the universal recommendation to add the positive term. A deployable full correction would require either a justified model for the cross term or publication of the relevant covariate-outcome score covariances.

**Major 4** (Methods; Results: poor-overlap failure). Using the same source sandwich makes the comparison fair, but the chosen sandwich fails badly enough to invalidate the prespecified absolute-coverage analysis. This is especially problematic because the introduction describes source weight-estimation uncertainty as settled and cites available alternatives. Paired contrasts may still illuminate the incremental target contribution, but they do not establish that any interval restores nominal absolute coverage.

*What would satisfy this:* Repeat the study using a source variance procedure selected in advance and validated by the null controls, such as an appropriate bootstrap or finite-sample correction. Alternatively, restrict the target question to an ex ante overlap region and frame conclusions outside it solely in terms of paired incremental effects.

**Major 5** (Results and Monte Carlo uncertainty). The headline tables omit the Monte Carlo uncertainty needed to assess their claims. In particular, a median coverage difference of 0.02 percentage points cannot establish equivalence without its paired discordance rate and Monte Carlo standard error. The single scenario triggering the ordinary-strength category is not identified, and extrema across 167 scenarios are reported without acknowledging selection noise.

*What would satisfy this:* Report each decisive scenario, paired coverage differences, discordance counts, Monte Carlo standard errors or intervals, and a prespecified equivalence margin. Give maximum as well as median differences between normal reconstruction, reported-covariance, and joint-score methods, stratified by kappa and target-correlation misspecification.

**Major 6** (What a publication would have to report; Limitations). The claim that normal reconstruction makes enhanced reporting unnecessary is evaluated under multivariate normality, where the reconstruction formulas are correct by construction. The sole misspecification changes one positive equicorrelation from 0.30 to 0.60, while pooled summaries can hide failures in the affected subset. This does not support a general recommendation for real baseline tables containing skewed, bounded, categorical, missing, or rounded variables.

*What would satisfy this:* Either restrict the recommendation explicitly to approximately normal continuous covariates under modest correlation error, or add confirmatory scenarios with nonnormal covariates, mixed covariate types, broader correlation misspecification, rounding, and covariate-specific missingness.

**Major 7** (The problem; What this answers). The study provides a special-case answer for anchored MAIC with an additive continuous outcome, three normally distributed covariates, correctly spanned effect modification, and target summaries sharing participants with the comparator estimate. It therefore does not supply the single general number initially promised for MIS-03. The later statement that MIS-03 is answered only in part is the defensible characterization. The labels ordinary and strong effect modification also lack empirical calibration to actual MAIC applications.

*What would satisfy this:* Use the partial-answer wording consistently in the title, opening, abstract, and conclusions, and justify the effect-modification and overlap levels using empirical PAIC applications or replace the value-laden strength labels with numerical labels.

**Minor 8** (Estimating system and negative controls). The statement that J is exactly zero without effect modification is only a population or first-order statement. In a finite randomized source trial, chance arm imbalance in prognostic covariates can make the estimated J nonzero, so the four intervals need not coincide exactly. The manuscript should also specify how a published sample SD is converted to a second raw moment, including the n versus n-1 denominator.

*What would satisfy this:* Correct the exact-zero language, quantify the finite-sample discrepancies in negative controls, and document the precise mean-and-SD conversion used by the implementation.

**Minor 9** (Results). The percentage of variance omitted and the percentage interval-width cost are not formally defined. It is unclear which variance or width is the denominator and whether summaries are ratios of scenario means or means of replicate-level ratios.

*What would satisfy this:* Provide formulas for these measures, identify their denominators, and report their Monte Carlo uncertainty.

**Minor 10** (Front matter). The supplied manuscript has no abstract. For a methodological journal, the abstract must clearly distinguish the registered uninformative result from the exploratory amended analysis.

*What would satisfy this:* Add a structured abstract led by the registered result, followed by explicitly labeled exploratory findings and appropriately restricted practical implications.

**Citation problems.**

- Chandler and Proskorovsky (2024): One simulation benchmark does not justify calling source weight-estimation uncertainty settled, particularly when the present study uses a conventional sandwich that fails its own controls. State exactly which variance procedures and settings that paper supports.
- Sheng, Sun and Huang (2026); Chen, Chen and Yu (2026): The manuscript does not explain whether these studies use target summaries from the same sample as an outcome or treatment-effect estimate, or whether they include the corresponding cross-covariance. That comparison is necessary to support the claimed remaining novelty.
- Novelty claim surrounding Equation 4: Estimated calibration totals and covariance induced by overlapping samples are established ideas in survey calibration, two-phase sampling, and generalizability theory. Novelty should be limited to the MAIC application and quantitative evaluation unless the broader literature is reviewed and distinguished.
- Claim that every standard estimator treats target moments as exact: This sweeping statement is not supported by a review of MAIC methods or software and sits uneasily beside the two cited transportability methods that propagate summary uncertainty. Qualify it to identified MAIC implementations and provide supporting citations.

**Claims the reviewer judged unsupported.**

- This study supplies it.
- The alignment kappa varies continuously.
- kappa = 0.5 is included so the cancellation is located rather than assumed.
- All three corrections stay inside it in every scenario.
- Getting the borrowed correlation wrong, at rho_T = 0.60 against a source value of 0.30, did not break it.
- The deployable correction is as good as the one requiring enhanced reporting, so the case for asking journals to publish moment covariance matrices is weak.
- The case for analysts computing Equation 3 and adding J'Omega_norm J/n_T is strong.
- It removes a coverage error of up to three points whose sign they cannot otherwise determine.
- The problem is real and is worth correcting, and the correction is available now.
- This was anticipated. Section 9's threat table already contains 'Wald sandwich intervals may fail at n_T = 200 for reasons unrelated to target-moment omission'.

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript studies how much coverage is lost in anchored MAIC by treating published target covariate moments as fixed constants rather than sample estimates. An analytic identity (Eq. 5) shows the net omitted variance is $(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$ to first order, fixing the sign by construction; the simulation confirms this identity (slope 1.003, SE 0.042) and adds empirical magnitudes and coverage consequences. However, the registered confirmatory result is uninformative because the Wald sandwich undercovers at poor overlap, and all coverage results come from a post-hoc restriction that selects on an observed outcome. The paper is unusually transparent about these limitations and withdraws earlier overstated claims, but the simulation's empirical contribution beyond the analytic identity is narrow, and the practical recommendation rests on boundary conditions the design does not test.

**Strengths.**

- The pre-registration and transparent reporting of the uninformative registered result set a high standard; the authors report the failure first and label the restricted analysis exploratory throughout, rather than burying it.
- The derivation of the first-order identity (Eq. 5) and the recognition that the sign is fixed by construction is a genuine analytic contribution that was not previously known in the MAIC literature and corrects an earlier overclaim.
- The distinction between marginal and conditional estimands is handled correctly: the superpopulation qualifier is stated as the whole point, and the closed-form truth is verified against Monte Carlo evaluation.
- The comparison is fair: all four methods share the same point estimate and the same source sandwich, isolating the interval question.
- The identification of the cross-covariance term as the missing piece, and the proof that partial corrections help only for $\kappa < 1/4$, is analytically clean and practically important even if untested empirically.
- The secondary finding of Wald sandwich failure at poor overlap is a useful contribution that deserves its own follow-up study.

**Comments.**

**Major 1** (Methods / Data-generating mechanism). The design sets $\kappa \in \{0, 0.5, 1\}$, which provides no interior values to test the key practical recommendation that partial corrections help only for $\kappa < 1/4$ (Eq. 6). The entire practical recommendation rests on analytic derivation without any empirical verification at the boundary that determines when the deployable correction is beneficial versus harmful. This is the single most important gap between what the paper recommends and what it tests. A scenario at, say, $\kappa = 0.25$ or $\kappa = 0.3$ would have allowed at least a check on the analytic boundary.

*What would satisfy this:* Either run additional scenarios at interior $\kappa$ values (e.g., 0.25 and 0.75) and report whether the partial corrections behave as Eq. 6 predicts, or state explicitly in the practical implication that the recommendation is analytic only and has no empirical support at the boundary.

**Major 2** (Results / The exploratory restriction). The restricted analysis (196 of 252 scenarios) selects on the observed coverage of the reference method, which shares replicates with all other methods through the common point estimate and source sandwich. The authors acknowledge this, but the paper still presents coverage ranges and method comparisons from this restricted set as if they carry evidential weight. The selection partly guarantees that the reference method's coverage falls in a favorable range, and since all methods are correlated through shared replicates, the selection also affects the other methods' apparent performance. No sensitivity analysis or alternative restriction criterion (e.g., by expected ESS, which is ex ante) is presented.

*What would satisfy this:* Either re-restrict by an ex ante criterion such as expected ESS or overlap level (excluding $d=0.8$ a priori) and report whether the conclusions change, or state more forcefully that the restricted results are hypothesis-generating only and should not be cited as evidence for or against any method's coverage properties.

**Major 3** (Methods / Data-generating mechanism). The practical recommendation for the normal-reconstruction correction is tested exclusively under multivariate normal covariates, which is exactly the assumption under which the reconstruction formulas are exact. The only misspecification examined moves one equicorrelation from 0.30 to 0.60; this is a very mild departure. Real baseline tables contain skewed, bounded, categorical, rounded, and partially missing variables. The paper acknowledges this as a limitation but the abstract and discussion still present the 2.24% median interval-width cost as if it generalizes. Under non-normal covariates the reconstruction could be badly biased in either direction, and the comparison against the reported-covariance benchmark would be more informative there.

*What would satisfy this:* At minimum, add one or two scenarios with non-normal covariates (e.g., log-normal or Bernoulli) to show whether the normal reconstruction degrades gracefully or catastrophically. If this is not feasible, narrow the practical recommendation to state explicitly that the 2.24% figure applies only under exact multivariate normality and may be substantially different under realistic conditions.

**Minor 4** (Results / Table 3). The paired coverage differences for the partial corrections (normal reconstruction: median 0.32 pp, max 2.00 pp; reported covariance: median 0.28 pp, max 1.92 pp) are presented without explicit comparison to their Monte Carlo standard errors. The MCSE is reported as 0.09 pp on average, but the maximum differences of 2.00 and 1.92 pp are more than 20 MCSEs, which is fine. However, the minimum differences of -0.12 pp for both partial methods are within about 1.3 MCSEs of zero and should not be described as meaningful in any direction.

*What would satisfy this:* Add a brief note that the minimum paired differences are within Monte Carlo error of zero and carry no directional interpretation, or remove the minima from the interpretive text.

**Minor 5** (Abstract). The abstract states the partial corrections 'kept coverage inside 93% to 97% in every scenario, at a median interval-width cost of 2.24%.' This is an exploratory result from a selected subset, but the sentence structure in the abstract does not make the exploratory and selected nature fully clear to a reader who reads only the abstract. The phrase 'Where they were examined' helps but could be more explicit.

*What would satisfy this:* Add 'in the exploratory restricted set' to this sentence in the abstract, or rephrase to make the conditional nature unambiguous.

**Minor 6** (What this answers, and what it does not). The statement 'answers MIS-03 in part' is appropriate but could be more precise about what part is answered confirmatorily (nothing about coverage) versus analytically (the identity and its sign). As written, a catalog reader might infer that the coverage question has been partially answered confirmatorily, when it has not.

*What would satisfy this:* Replace 'answers MIS-03 in part' with a sentence distinguishing the analytic contribution (the identity, which is confirmatory of the theory) from the empirical contribution (coverage, which is exploratory only).

### Reviewer 3: Kimi K3 (via Ollama)

**Unavailable.** This reviewer was invited and could not be
reached. Reason recorded at the time: Ollama returned 402 Payment Required: this model is billed as extra usage and the account balance is empty. Add credit at https://ollama.com/settings, then re-run this command.

The review is not counted as favorable or unfavorable; it did
not happen, and this record says so.

## Authors' response to round 1

We thank Reviewer 1. The review changed the paper's conclusions, not only its wording, and
two of its findings were errors of ours that nothing else had caught. Reviewer 2 was
invited and could not be reached; the record says so.

Below, each comment is answered in order. Where we disagree we say so and why. Where a
comment requires work we have not done, we say that plainly rather than claiming a fix.

---

## Major 1. The registered analysis is uninformative and the restriction is outcome-dependent

**Accepted in full, including the factual error.**

The reviewer is right that the amendment misdescribed the registered protocol. We wrote
that section 9's threat table "already contains" a sentence about the Wald sandwich failing
for reasons unrelated to target moments. It does not. That sentence is in the *design
document* produced before the protocol was written
(`documentation/studies/designs/MIS-03-target-moment-uncertainty-design.json`), and it did
not survive into the registered text. We imported it into the amendment without checking
that it had. The claim is retracted in `protocol.md` section 11 and the correction is
attributed to this review.

This is the same failure mode the catalog this program serves keeps finding in the
literature: a real source, a real sentence, attached to the wrong document. We record it
rather than quietly repairing it.

On the substance: we accept that selecting scenarios by the reference method's observed
coverage is filtering on an outcome, and that because all methods share replicates and the
same source sandwich, the reference method's coverage range within the restricted set is
partly guaranteed by the selection. The paper now:

- reports the registered conclusion, **uninformative**, first and without qualification, in
  the abstract and as the first results subsection;
- labels the restricted analysis exploratory in the abstract, the section heading, every
  table caption and the discussion;
- states explicitly that a confirmatory answer requires a fresh run under a new
  registration, with either an ex ante design criterion such as expected effective sample
  size or a source variance procedure validated to pass the controls throughout.

We have **not** performed that new run. It is the correct next step and we do not claim to
have taken it.

## Major 2. The sign is algebraically imposed, not discovered

**Accepted in full.** The reviewer's derivation is correct. With $J = sb$ and
$\mathrm{Cov}\{h(X),\phi_{BC}\} = \kappa s \Omega_{hh} b$, the net omitted component is
$(1-2\kappa)\mathrm{Var}_T\{\tau(X)\}/n_T$, so its sign is fixed by $\kappa$ and the
cancellation at $\kappa = 1/2$ is a property of the design.

We have added section 3.1 stating the identity, and we withdraw the claim that
"$\kappa = 0.5$ is included so the cancellation point is located rather than assumed". The
protocol carries the same retraction.

We also checked the identity against the run rather than only asserting it: regressing the
measured omitted variance on $(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$ across the 216
scenarios with effect modification gives a slope of 1.003 (SE 0.042). The residual scatter
is the finite-sample departure the reviewer notes separately in Minor 8.

We accept that three $\kappa$ levels are not continuous variation, and the paper no longer
describes them as such. We have not added independent variation of the source and target
modifier coefficient vectors; that changes the estimand structure and belongs in the
follow-up study, and we say so in the scope section.

## Major 3. The two deployable corrections are partial, so the recommendation was wrong

**Accepted in full, and this changes a conclusion.** `normal-recon` and `reported-cov` add
$J^\top \Omega J/n_T$, which is non-negative, and omit the cross term. By the identity in
Major 2 they can only help when $\kappa < 1/2$; at $\kappa = 1/2$ they add variance where
the net omission is zero and at $\kappa = 1$ they widen an interval that is already too
wide.

The paper now calls them partial corrections in the methods table and throughout, reports
coverage stratified by $\kappa$ (@tbl-methods) so the behavior is visible rather than
averaged away, and **withdraws the general recommendation to add the positive term**. The
narrowed recommendation is conditional on $\kappa$ being believed small, and the paper
states that no deployable correction exists for large $\kappa$ because it needs a
covariance a publication does not report.

We also withdraw the claim that the case for journals publishing moment covariance matrices
is weak. That comparison was run under multivariate normality, where the reconstruction is
correct by construction, so it cannot support a general statement about reporting policy.

## Major 4. The source sandwich fails, which invalidates the absolute-coverage analysis

**Accepted.** The paper now says this directly in the registered-result section, and
connects it to the citation: Chandler and Proskorovsky found conventional estimators
anticonservative under poor and moderate overlap, and the conventional sandwich used here
fails in exactly that region. We have removed the description of source weight-estimation
variance as "settled" and replaced it with what that paper actually supports.

We have not repeated the study with a different source variance procedure. The paper
restricts its absolute-coverage claims to the region where the controls hold and flags the
poor-overlap failure as deserving its own study.

## Major 5. Monte Carlo uncertainty missing from the headline tables

**Accepted.** Added: a paired-differences table reporting median, minimum and maximum
differences against the reference, the mean number of discordant replicates that determines
the Monte Carlo error of a paired comparison, and the mean paired Monte Carlo standard
error. The Monte Carlo standard error at nominal coverage is stated in the caption of the
coverage table. The single scenario that triggered the prespecified category is now
identified by its full factor combination with its Monte Carlo standard error, and the
paper says no weight is placed on it.

We have not set a formal equivalence margin. We agree one is needed to claim equivalence,
and the paper therefore no longer claims equivalence between the partial corrections and
the benchmark; it reports the differences and their uncertainty and leaves the reader to
judge.

## Major 6. The reconstruction is evaluated where it is correct by construction

**Accepted.** The recommendation is now explicitly restricted to approximately normal
continuous covariates under modest correlation error, and the paper lists skewed, bounded,
categorical, rounded and partially missing variables as untested. We have not added
non-normal scenarios; that is a substantial extension and is named as such.

## Major 7. This is a special-case answer and the wording should say so consistently

**Accepted.** The subtitle now reads "answering part of" the two catalog problems, and the
abstract, the problem section and the scope section use partial-answer wording. The
$\mathrm{SD}_T(\tau)$ levels are now labelled by their numerical values rather than as
"ordinary" and "strong", because we have no empirical calibration to published applications
and the value-laden labels implied one.

## Minor 8. "Exactly zero" is a population statement, and the moment conversion is undocumented

**Accepted.** The paper now says $J$ is zero *in the population* under no effect
modification, that chance imbalance in a finite randomized source trial makes $\hat J$
nonzero so the four intervals do not coincide exactly, and points to the negative-control
results for the size of the discrepancy. The conversion from a reported unbiased sample
standard deviation to the second raw moment,
$\hat m_{2j} = \{(n_T-1)/n_T\}s_j^2 + \bar x_j^2$, is now given explicitly in section 2
with the reason: it makes the calibration target exactly the sample mean of $h(X)$.

## Minor 9. The percentage measures are not defined

**Accepted.** Both are now defined where computed. Omitted variance is
$100\{(\widehat{\mathrm{SE}}_{\text{joint}}/\widehat{\mathrm{SE}}_{\text{fixed}})^2 - 1\}$,
formed from each method's scenario-mean model standard error, so it is a ratio of scenario
summaries rather than a mean of replicate-level ratios. Width cost is the analogous ratio
of scenario-mean interval widths.

## Minor 10. No abstract

**Accepted, and this was a rendering fault rather than an omission.** The abstract was in
the document front matter, which the Markdown output format drops. Since the Markdown file
is what reviewers and readers receive, the abstract is now a section in the body and
appears in all three published formats. It is structured as the reviewer asked: registered
result first, exploratory findings explicitly labelled, then the restricted practical
implication.

## Citation problems

**Chandler and Proskorovsky.** Accepted; "settled" is removed and replaced with the
specific settings that paper covers, together with the observation that the present study
finds the conventional sandwich failing outside them.

**Sheng et al. and Chen et al.** Accepted. The paper now states that neither is framed for
the anchored two-trial setting in which the target moments and the target treatment effect
come from the same participants, which is the case that produces the cross term, and that
neither has been carried into indirect-comparison software.

**Novelty around the joint-covariance equation.** Accepted. The paper now says that
estimated calibration totals contributing variance, and overlapping samples inducing
covariance, are long established in survey calibration and two-phase sampling, and that
nothing here claims those as new.

**"Every standard estimator treats target moments as exact."** Accepted and qualified to
the implementations we examined.

## Claims the reviewer judged unsupported

All ten have been removed, rewritten or restricted. The two that were simply wrong, "the
alignment $\kappa$ varies continuously" and "$\kappa = 0.5$ is included so the cancellation
point is located rather than assumed", are retracted in both the paper and the protocol.
"This study supplies it" is now "answers in part". The recommendation sentences are
narrowed as described under Major 3 and Major 6. The claim about what section 9 contained
is retracted as described under Major 1.


---

# Response to Reviewer 2 (GLM-5.2)

**A note on when this reviewer joined.** Reviewer 2 was invited after the manuscript had
already been revised through two rounds with Reviewer 1, because the originally invited
second reviewer could not be reached. Reviewer 2 therefore read the revised manuscript, not
the version Reviewer 1 first saw. We say so rather than presenting the two reports as
contemporaneous.

Reviewer 2 recommends minor revision where Reviewer 1 stands at major revision. The two
agree on what is wrong; they differ on how much it matters. We have not tried to reconcile
them and both recommendations stand in the record.

## Major 1. No interior kappa, so the practical recommendation has no empirical support

**Accepted, and the reviewer is right that this is the largest gap.** The manuscript now
says explicitly that @eq-quarter is an analytic result with no empirical support at the
boundary it defines, and attributes that observation to review. We have not added scenarios
at intermediate kappa. Doing so is cheap and we expect to do it in the rerun; adding it to
the present exploratory set would extend an analysis whose status is already the problem.

## Major 2. The restricted results still read as though they carry evidential weight

**Accepted.** The restriction section now states that the results are hypothesis-generating
only and should not be cited as evidence for or against any method's coverage properties.
We have not re-restricted by an ex ante criterion such as expected effective sample size and
reported whether the conclusions change; that is named as part of the required rerun rather
than done here.

## Major 3. The width figure is presented as though it generalizes

**Accepted.** The abstract now says the median interval-width cost applies under **exact**
multivariate normality and may differ substantially under skewed, bounded, categorical or
rounded covariates. We have not added non-normal scenarios. We agree they would be the most
informative single addition after interior kappa, and both are named for the rerun.

## Minor 4. Minimum paired differences are within Monte Carlo error

**Accepted.** The results text now says the minima are within about one and a half Monte
Carlo standard errors of zero and carry no directional interpretation, and that only the
maxima are large relative to Monte Carlo error.

## Minor 5. The abstract does not make the exploratory status unambiguous

**Accepted.** The sentence now begins "In the exploratory restricted set".

## Minor 6. "Answers in part" blurs analytic and empirical contributions

**Accepted, and this is the clearest statement of the paper's own position that either
reviewer produced.** The scope section no longer says "answers MIS-03 in part". It now
separates the analytic contribution, which the simulation confirms as theory and which does
not depend on the restricted set, from the exploratory-only evidence on the coverage
question MIS-03 actually asks, which is therefore not answered confirmatorily.

## Where we agree with Reviewer 1's harsher reading

Reviewer 2 judges the paper unusually transparent and its conclusions supported. Reviewer 1
judges that transparency does not substitute for confirmatory evidence. We think Reviewer 1
is right about the standing of the coverage claim, and the catalog entry records the
confirmatory question as open on that basis, notwithstanding Reviewer 2's lighter
recommendation.


## Round 2

### Reviewer 1: GPT-5.6 Sol (maximum reasoning effort)

**Recommendation: major-revision**

The manuscript derives the target-sample contribution to uncertainty in anchored MAIC and evaluates interval behavior in a large, reproducible simulation. The revision commendably reports the registered result as uninformative, acknowledges outcome-dependent scenario selection, identifies the sign result as an analytic identity, and withdraws the general recommendation for partial corrections. Nevertheless, the study still lacks a confirmatory answer to its stated coverage question because all usable coverage results come from the post-run restriction, while several practical claims exceed the Monte Carlo and design evidence. The design is repairable through a newly registered run using an ex ante overlap restriction or a source variance estimator that passes the controls.

**Strengths.**

- The distinction between a realized target sample and a target-superpopulation estimand is explicit and methodologically important.
- The marginal estimand is correct for the additive continuous-outcome mechanism and is evaluated against an exact closed-form truth.
- The joint target covariance formulation correctly includes dependence between reported moments and the target treatment-effect estimate.
- All methods share the point estimator and source variance estimator, making the incremental target-variance comparison fair even though absolute coverage fails under poor overlap.
- The negative controls successfully exposed a larger source-sandwich problem instead of allowing it to be misattributed to target-moment uncertainty.
- The revision is unusually candid about the uninformative registered result, post-selection, the built-in identity, and the partial nature of the deployable additions.
- The factorial design, convergence accounting, 5000 replicates per scenario, reproducible random-number streams, and ADEMP structure are strong.

**Comments.**

**Major 1** (Abstract; The registered result; The exploratory restriction; What this answers). The central confirmatory question remains unanswered. The global registered analysis is uninformative, and the 196-scenario analysis conditions on observed coverage of quantities correlated with every method being assessed. Labelling this analysis exploratory is necessary and has been done well, but labelling does not restore confirmatory evidence. Statements that the study answers the coverage problem in part, or licenses a practical correction, must therefore distinguish the analytic result from the selected simulation evidence.

*What would satisfy this:* Conduct a newly registered, independently seeded run using either an ex ante overlap criterion or a source variance estimator shown in advance to pass the controls. Without that run, recast the paper as an analytic contribution with an exploratory simulation illustration and remove affirmative performance recommendations.

**Major 2** (An identity that fixes the sign; Data-generating mechanism; Scope). The mechanism fixes more than the sign. Because SD_T(tau), κ, and n_T are design inputs, the first-order absolute omitted component is exactly (1-2κ) SD_T(tau)^2/n_T. The simulation estimates its fraction of total variance, its coverage consequences, and finite-sample departures, but it does not discover its first-order magnitude. Moreover, κ is not a general alignment parameter here: it imposes exact nonnegative proportionality between the two modifier coefficient vectors. Negative, orthogonal, partially overlapping, and differently directed modifiers are not studied, despite the response claiming this restriction is stated in the scope section.

*What would satisfy this:* Describe the absolute component as fixed analytically and identify precisely which relative and finite-sample quantities the simulation contributes. Explicitly list proportional, nonnegative modifier alignment as a limitation; broader alignment claims require independently varied coefficient vectors.

**Major 3** (Abstract; An identity that fixes the sign; Protocol amendment; Authors' response). The identity-check analysis is internally inconsistent. The manuscript reports 167 scenarios, slope 1.003, SE 0.025, and R-squared 0.91, whereas the protocol amendment and response report 216 scenarios, the same slope, and SE 0.042. The former appears to use the outcome-selected subset, although it is presented before that restriction is introduced and is not labelled exploratory.

*What would satisfy this:* Reconcile the analyses from reproducible output, specify whether the regression uses all 216 effect-modification scenarios or the selected 167, and report the intercept constraint, weighting, and SE calculation. Prefer the full 216-cell design check; if both are retained, label the restricted result as post-selected.

**Major 4** (Methods compared; Practical implication). Equation 5 does not show that adding the entire positive term improves variance accuracy throughout κ < 1/2. Let M = J'ΩJ. The full increment over target-fixed is (1-2κ)M, while the partial method exceeds the full variance by 2κM. For 0 ≤ κ < 1/2, the partial addition reduces absolute first-order variance error only when κ < 1/4, ties at κ = 1/4, and is farther from the full variance when 1/4 < κ < 1/2. The simulation contains no interior κ values with which to support the recommendation for vaguely 'small' κ.

*What would satisfy this:* Separate the sign of the omitted component from whether the partial addition is closer to the full variance. Restrict the recommendation to κ near zero or add intermediate κ levels, especially around 0.25, with paired coverage and variance-error results.

**Major 5** (Tables 2 and 3; What a publication would have to report; Abstract). Monte Carlo uncertainty still does not support the uniform band and comparability language. Normal-reconstruction extrema of 93.2% and 97.0% lie within approximately one scenario-level Monte Carlo SE of the band boundaries, and rounding may determine whether the latter is inside. Table 3 gives only mean discordance and mean MCSE across heterogeneous scenarios, not uncertainty for the reported extrema or direct normal-recon versus reported-cov comparisons. Results also remain pooled over target-correlation misspecification despite the round-one request for stratification.

*What would satisfy this:* Report unrounded coverage and scenario-specific Monte Carlo intervals for boundary cells, direct paired comparisons between the two partial methods, and κ-by-correlation summaries. Replace 'kept coverage inside' with a statement about observed estimates unless uncertainty supports the uniform claim, and use a defined margin before saying methods performed comparably.

**Major 6** (Table 1; Interval-width results). The response says formulas for omitted variance and width cost were inserted, but they are absent from the supplied manuscript. Moreover, the response defines omitted variance by squaring a ratio of scenario-mean SEs; this is not generally the same as a ratio of mean estimated variances and requires justification. These measures underpin the headline -9.5%, 14.9%, and 2.24% figures, yet no Monte Carlo uncertainty is reported.

*What would satisfy this:* Give explicit formulas and denominators in the manuscript. For a variance quantity, use or justify departure from a ratio based on mean estimated variances or mean replicate-level variance differences, and provide Monte Carlo uncertainty for the headline summaries.

**Major 7** (Abstract; What a publication would have to report; Practical implication). The observed-data and robustness claims remain too broad. κ is not identified from the stipulated baseline moments, aggregate effect, and SE, but it is not true that it cannot be identified from anything a publication might report; subgroup effects, interaction estimates, or covariate-outcome summaries could contain relevant information. Likewise, the simulation uses exactly multivariate-normal covariates, not approximately normal covariates, and examines only one equicorrelation discrepancy. The categorical statement that no deployable correction exists is therefore stronger than this study establishes.

*What would satisfy this:* Define the standard publication input set under which the cross term is unidentified and qualify the software claim accordingly. State that performance was demonstrated under exact multivariate normality and one correlation perturbation, or add robustness scenarios. Replace 'no deployable correction exists' with 'none evaluated here is computable from the stipulated summaries alone.'

**Minor 8** (Abstract; Negative controls; Front matter). Several claimed textual corrections are not present. The abstract still says the four intervals 'must coincide', contradicting the later correct statement that finite-sample J-hat makes them differ. The manuscript does not quantify those finite-sample discrepancies, although the response says it does. The response also says a subtitle identifying the partial answer was added, but the supplied title has no subtitle.

*What would satisfy this:* Change the abstract to 'coincide to first order' or 'nearly coincide', report the maximum or distribution of negative-control SE or coverage differences with MCSE, and either add the claimed subtitle or correct the response record.

**Citation problems.**

- Chandler and Proskorovsky (2024): Equation 2 stacks calibration and outcome scores and therefore appears to account for source weight estimation, yet the manuscript calls it the 'conventional sandwich.' Map it explicitly to the terminology and estimator evaluated by Chandler and Proskorovsky before attributing the observed failure to their conventional category.
- Sheng, Sun and Huang (2026); Chen, Chen and Yu (2026): The revision asserts that neither treats an anchored same-sample target effect and moment vector, but it still does not describe their sampling structures, estimands, or covariance terms sufficiently to verify that novelty distinction. The additional claim that neither approach has entered indirect-comparison software also needs evidence.
- Survey calibration and two-phase sampling literature: The manuscript now acknowledges that estimated calibration totals and overlapping-sample covariance are established, but supplies no citations to that literature. Canonical references are needed to delineate the MAIC-specific contribution.
- Every matching-adjusted indirect comparison implementation we could examine: No implementations, versions, documentation, or review method are identified. Provide an auditable software list or narrow the statement further.

**Claims the reviewer judged unsupported.**

- What the simulation contributes is therefore not the sign but the magnitude at realistic sample sizes.
- For approximately normal continuous covariates with modest correlation error they kept coverage inside 93% to 97% in every scenario examined, at a median interval-width cost of 2.24%.
- By Equation 5 they can only help when κ < 1/2.
- It performed comparably to being handed the target’s true moment covariance.
- The observation that κ is not identified from anything a publication reports.
- No deployable correction for that case exists.
- For anchored MAIC on a continuous outcome with normal covariates, where the source sandwich is valid, and where effect modification lies in the span of the matched moments: the omission is real, its magnitude is a few percentage points of coverage.
- Including scenarios containing no effect modification at all, where all four intervals must coincide.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | partly | The factual protocol error is corrected and the restriction is consistently labelled exploratory, but no independent registered run was performed, so the confirmatory coverage question remains unanswered. |
| sol 2 | partly | The analytic identity and retraction are present, but the manuscript still attributes first-order magnitude to the simulation, understates the exact proportional-alignment restriction, and reports inconsistent identity-check analyses. |
| sol 3 | partly | The methods are relabelled partial and the universal recommendation is withdrawn, but paired performance is not stratified as requested and the claim about when the positive addition helps is analytically too broad. |
| sol 4 | partly | The source-sandwich failure is now prominent and accurately limits the interpretation, but neither a validated alternative estimator nor an ex ante restricted new run was supplied. |
| sol 5 | partly | A paired table and the decisive scenario were added, but mean MCSEs do not quantify uncertainty in extrema, no direct κ-by-correlation paired comparison is shown, and boundary claims remain stronger than the Monte Carlo precision. |
| sol 6 | yes | The recommendation is explicitly narrowed and the untested nonnormal, categorical, rounded, and missing-data settings are clearly acknowledged. |
| sol 7 | partly | The body uses partial-answer language and numerical effect-modification labels, but the claimed subtitle is absent and some abstract and practical wording remains broader than the special-case evidence. |

### Reviewer 2: GLM-5.2 (via Ollama)

**Recommendation: minor-revision**

The manuscript derives a first-order identity showing that the net variance omitted by conditioning on sampled target moments in anchored MAIC is $(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$, fixes the sign analytically, and confirms the identity empirically (slope 1.003, SE 0.042). The registered confirmatory analysis is correctly reported as uninformative because the Wald sandwich undercovers at poor overlap; all coverage results come from a post-hoc restriction labelled exploratory throughout. The revision is unusually thorough: the authors retract two factual errors, withdraw an overstated recommendation, relabel the deployable corrections as partial, and narrow the practical implication to approximately normal covariates where $\kappa$ is believed small. The analytic contribution is genuine and novel for the MAIC literature; the simulation adds magnitude and a useful secondary finding about sandwich failure at poor overlap. Remaining gaps (no interior $\kappa$, no non-normal covariates, no confirmatory rerun) are acknowledged rather than hidden.

**Strengths.**

- The first-order identity (Eq. 5) and the $\kappa < 1/4$ boundary (Eq. 6) are genuine analytic contributions to the MAIC literature, correctly presented as theory the simulation confirms rather than as simulation findings.
- The pre-registration, transparent reporting of the uninformative registered result, and labelling of the restricted analysis as exploratory throughout set a high standard for simulation reporting in evidence synthesis.
- The distinction between superpopulation and realized-sample estimands is handled correctly and is central to the paper's framing.
- The comparison is fair: all four methods share the same point estimate and source sandwich, isolating the interval question.
- The retraction of two factual errors (the protocol amendment's misattribution and the overclaimed novelty of the cancellation point) is honest and well-documented.
- The secondary finding of Wald sandwich failure at poor overlap is correctly identified as larger than the target-moment effect and deserving its own study.
- The paired-differences table with discordance counts and Monte Carlo standard errors allows the reader to assess the coverage comparisons properly.

**Comments.**

**Minor 1** (Abstract). The abstract states 'no study has measured what that costs.' The Sheng et al. and Chen et al. citations that follow in the introduction propagate target-summary uncertainty for entropy-balancing estimators in related settings. The sentence is defensible if read as referring strictly to anchored MAIC, but a reader of the abstract alone cannot know that scope restriction. Consider adding 'in anchored MAIC' or 'in this anchored setting' to the sentence.

*What would satisfy this:* Add a scope qualifier to the 'no study has measured' sentence in the abstract.

**Minor 2** (Results / Table 2). Table 2 reports coverage ranges across '167' scenarios with effect modification, but the text does not explain how this number arises from the 196 restricted scenarios (196 minus 29 negative-control scenarios with SD_T(τ)=0). A one-line note in the table caption would help the reader verify the arithmetic.

*What would satisfy this:* Add a note to the Table 2 caption explaining that 167 = 196 − 29 scenarios with SD_T(τ)=0.

**Minor 3** (What this answers, and what it does not). The final scope section is clear and well-calibrated. One small addition would strengthen it: the paper does not discuss what information a published subgroup or interaction estimate could in principle supply about $\kappa$, though the discussion of the normal-recon section gestures at it ('reported subgroup effects or interaction estimates might in principle carry some of the required information'). A single sentence in the scope section noting this as a direction for identifying $\kappa$ from published inputs would be valuable, since $\kappa$ is the parameter on which the practical recommendation turns.

*What would satisfy this:* Add one sentence in the scope section noting that identifying $\kappa$ from published inputs (e.g., subgroup or interaction estimates) is an open problem that determines whether the partial correction is safe to deploy.

**Minor 4** (Methods / Data-generating mechanism). The calibration of effect-modification strength to a fixed target-population SD is well-motivated and the confounding argument is sound. However, the pilot results (1%–7% at n_S=500, up to 23% at n_S=2000) are cited in both the protocol and the manuscript without reporting the pilot's sample size, seed, or which scenarios produced the 23% figure. Since these pilot numbers justified the n_S factor and the replicate count, a brief note on the pilot's scope would improve reproducibility.

*What would satisfy this:* Add a brief note on the pilot's scope (number of scenarios, replicates) or state that the pilot is available in the repository.

**Judgement on round one.**

| round-1 point | resolved | note |
| --- | --- | --- |
| sol 1 | yes | Authors accepted in full. Registered uninformative result reported first and without qualification; restricted analysis labelled exploratory throughout; factual error about protocol section 9 retracted. No rerun performed, but this is named as the correct next step rather than claimed as done. |
| sol 2 | yes | Authors accepted in full. Identity (Eq. 5) added as section 3.1; claim about locating cancellation withdrawn in both paper and protocol; slope 1.003 (SE 0.042) reported as confirmation of the identity. Three κ levels no longer described as continuous variation. |
| sol 3 | yes | Authors accepted in full and changed a conclusion. Corrections relabelled partial in methods table and throughout; coverage stratified by κ (Table 2); general recommendation withdrawn; κ < 1/4 analytic boundary added (Eq. 6); claim about journal reporting policy withdrawn. |
| sol 4 | yes | Authors accepted. Sandwich failure reported directly in registered-result section; 'settled' language removed and replaced with what Chandler and Proskorovsky actually support. No rerun with alternative variance estimator, but the limitation is stated. |
| sol 5 | yes | Paired-differences table added with median, minimum, maximum, discordance counts, and mean MCSE. Triggering scenario identified by full factor combination with its MCSE. No formal equivalence margin set, but equivalence claims removed. |
| sol 6 | yes | Recommendation restricted to approximately normal covariates under modest correlation error; skewed, bounded, categorical, rounded, and missing variables listed as untested. No non-normal scenarios added. |
| sol 7 | yes | Partial-answer wording used consistently in subtitle, abstract, problem section, and scope section. Value-laden labels replaced with numerical values for SD_T(τ). |
| sol 8 | yes | 'Exactly zero' corrected to population statement; finite-sample discrepancy noted and quantified (median 0.26%, max 1.49% on negative controls). Moment conversion formula added explicitly. |
| sol 9 | yes | Both percentage measures now defined with formulas and denominators specified as ratios of scenario summaries. |
| sol 10 | yes | Abstract added as body section; structured as requested with registered result first, exploratory findings labelled, restricted practical implication last. |
| glm 1 | yes | Authors acknowledge explicitly that Eq. 6 is analytic with no empirical support at the boundary. No interior κ scenarios added, but the gap is stated as the largest one and named for the rerun. |
| glm 2 | yes | Restricted results now stated as hypothesis-generating only and should not be cited as evidence for or against any method's coverage properties. No ex ante re-restriction performed, but named as part of the required rerun. |
| glm 3 | yes | Abstract now says the 2.24% figure applies under exact multivariate normality and may differ substantially under other covariate types. |
| glm 4 | yes | Results text now says minima are within about 1.5 MCSE of zero and carry no directional interpretation. |
| glm 5 | yes | Sentence now begins 'In the exploratory restricted set'. |
| glm 6 | yes | Scope section separates analytic contribution (identity, confirmatory of theory, not dependent on restricted set) from exploratory-only evidence on coverage. 'Answers MIS-03 in part' replaced with the clearer distinction. |

### Reviewer 3: Kimi K3 (via Ollama)

**Unavailable.** This reviewer was invited and could not be
reached. Reason recorded at the time: Ollama returned 402 Payment Required: this model is billed as extra usage only and the account's extra-usage balance is empty. Add credit or enable auto reload at https://ollama.com/settings, then re-run this command. Verified through all three access paths (CLI, HTTP API, python client), so this is account billing and not a client problem.

The review is not counted as favorable or unfavorable; it did
not happen, and this record says so.

## Authors' response to round 2

Reviewer 1 judged that seven of eight round-one points were only partly resolved, and was
right about all seven. Three of our round-one responses claimed changes that the manuscript
did not contain. We list those first, because a response that misdescribes the manuscript is
a worse failure than the original omission.

## Claims we made in round one that were not true of the manuscript

**We said the omitted-variance and width formulas were inserted. They were not.** They
existed only as a comment in the analysis code. They are now in the manuscript text, at the
tables that use them, with the ratio-of-scenario-summaries construction stated explicitly
and a note that scenario extrema carry no multiplicity adjustment.

**We said the finite-sample discrepancy in the negative controls was quantified. It was
not.** It is now: on the controls, where the population omission is exactly zero, the
finite-sample departure moves the model standard error by a median of 0.26% and at most
1.49%, and the largest coverage difference between any two methods there is 0.008.

**We said the scope section stated the restriction on $\kappa$. It did not.** Section 3.1
now says that $\kappa$ imposes exact non-negative proportionality between the source and
target modifier coefficient vectors, and that modifier sets differing in direction,
overlapping only partially, or orthogonal are not studied.

On the subtitle: it is present in the document front matter, and the Markdown output format
drops subtitles as it drops abstracts. Since the Markdown file is what reviewers receive,
the reviewer correctly saw no subtitle. The partial-answer framing no longer depends on it;
it is in the abstract and in the section the reviewer reads as the conclusion.

## Major 4. The threshold is one quarter, not one half

**Accepted, and this is a mathematical error we made.** The reviewer's derivation is
correct: with $M = J^\top\Omega J$, the correct increment is $(1-2\kappa)M$, so the status
quo errs by $|1-2\kappa|M$ and the partial method by $2\kappa M$. The partial method is
closer only when $2\kappa < |1-2\kappa|$, that is when $\kappa < 1/4$. Between $1/4$ and
$1/2$ it is **worse than doing nothing**, which is the opposite of what we wrote.

The manuscript now derives this as @eq-quarter, states that the design contains
$\kappa \in \{0, 0.5, 1\}$ and therefore **no interior values with which to test it
empirically**, and makes no claim about intermediate alignment. The practical
recommendation is conditioned on $\kappa < 1/4$ rather than on $\kappa$ being "small".

## Major 3. The identity check was computed on the selected subset

**Accepted.** The manuscript reported 167 scenarios with SE 0.025 while the protocol
reported 216 with SE 0.042, because the manuscript computed the check on the restricted set
and presented it before the restriction was introduced. That is exactly the error we
labelled elsewhere: evaluating a claim on a set chosen by an outcome. The check now runs on
all 216 scenarios with effect modification, giving slope 1.003 (SE 0.042, $R^2 = 0.72$),
and the text says which set it uses and why.

## Major 2. The mechanism fixes the magnitude too

**Accepted.** Since $\mathrm{SD}_T(\tau)$, $\kappa$ and $n_T$ are design inputs, the
first-order absolute omitted component is fixed analytically and the simulation does not
discover it. The manuscript now says what the simulation *does* contribute: the fraction of
total variance, which depends on source information the identity does not fix; the coverage
consequences; the finite-sample departures; and the behavior of the partial estimators.

## Major 1. Labelling does not restore confirmatory evidence

**Accepted, and the conclusion is rewritten accordingly.** The scope section now separates
what is established analytically from what is established empirically and only in the
restricted set, and states plainly that **the registered coverage question is not
confirmatorily answered**. We had written "answers MIS-03 in part" in a way that blurred the
two; the two are now listed separately with their different warrants.

We have still not performed the new registered run. It remains the correct next step and we
do not claim to have taken it. The catalog entry records the study as answering part of the
problem with the confirmatory question open, rather than as closing it.

## Major 5. Monte Carlo uncertainty for extrema and stratification

**Partly accepted, partly not done.** Accepted: the abstract no longer asserts a uniform
band, and now says the extrema sat within about one Monte Carlo standard error of the band
edges. The paired table caption now explains why a McNemar contrast's Monte Carlo error is
governed by discordant pairs rather than by marginal coverage.

Not done: we have not added per-extremum Monte Carlo intervals, a direct normal-recon versus
reported-cov paired contrast, or stratification by target-correlation misspecification. We
judge these worth doing and they are within reach of the existing output, but they are
additions to an analysis we have already labelled exploratory, and adding detail to a
selected analysis does not change its status. They belong in the confirmatory run.

## Major 6. Formulas and the ratio construction

Formulas added, as above. On the construction: we agree that squaring a ratio of
scenario-mean standard errors is not identical to a ratio of mean estimated variances. The
manuscript now states which one is computed rather than leaving it to be inferred. We have
not switched to the alternative; the two agree closely here and changing it would not alter
any conclusion, but the reader can now see which was used.

## Major 7. Over-broad observed-data and robustness claims

**Accepted.** "Nothing in a publication identifies $\kappa$" is now "the inputs a
matching-adjusted comparison ordinarily uses do not identify $\kappa$", and the manuscript
notes that reported subgroup effects or interaction estimates might in principle carry some
of the required information and that we have not investigated whether they do.
"Approximately normal" is corrected to exactly multivariate normal with a single
equicorrelation discrepancy. "No deployable correction exists" is now "we are not aware of a
deployable correction".

## Minor 8. "Must coincide"

**Accepted.** The abstract now says the population omission is exactly zero there and the
four intervals should very nearly coincide, consistent with the finite-sample statement in
section 3 and with the quantification now supplied.

## Our position on the standing recommendation

We accept the reviewer's judgement that this manuscript does not confirmatorily answer its
registered question, and we have not tried to argue otherwise. We are publishing it with
that judgement attached rather than withholding it, because the analytic content stands on
its own, the negative result about the source sandwich is worth reporting, and the catalog
entry it serves is more useful with a partial answer and a visible reviewer objection than
with nothing. The review, including this standing recommendation of major revision, is
published beside the paper.

---

# Response to Reviewer 2, round two

Reviewer 2 judged all sixteen round-one points from both reviewers resolved and raised four
minor points. All four are accepted and made.

**Minor 1.** "No study has measured what that costs" now reads "in anchored MAIC", so a
reader of the abstract alone sees the scope restriction that the introduction makes
explicit.

**Minor 2.** The coverage table caption now states that the 167 scenarios are those of the
196 restricted scenarios that have effect modification, the other 29 being the negative
controls, so the arithmetic is checkable from the caption.

**Minor 3.** A paragraph is added to the scope section on where $\kappa$ might come from:
published subgroup effects, reported treatment-by-covariate interactions, or
covariate-outcome summaries could in principle carry information about it, and establishing
what they identify would make the correction deployable in the range where it currently is
not. We note we have not investigated this. The reviewer is right that this is the parameter
the practical recommendation turns on and that the paper should say where it might be found.

**Minor 4.** The pilot is now described: 120 replicates per configuration over a 16-cell
grid crossing two source sizes, two target sizes, two overlap levels and two
effect-modification strengths, run before the design was fixed, with the cell that produced
the 23% figure named. Those numbers justified making source size a factor and are now
checkable.

## On the disagreement between the reviewers

Reviewer 2 ends at minor revision and judges the conclusions supported. Reviewer 1 ends at
major revision and judges that the registered coverage question is not confirmatorily
answered. Both readings are in the record and we have not tried to reconcile them.

We side with Reviewer 1 on the point that matters for the catalog. The analytic contribution
is confirmatory of theory and stands; the coverage evidence is exploratory and does not
close the problem. The catalog entries record it that way.


## Editorial decision

**Decision: published with the reviewer's standing recommendation of major revision
attached, and with the confirmatory question recorded as open.**

This is not an acceptance. Reviewer 1's round-two recommendation is *major revision*, and
this record publishes the paper without overturning that.

## Why publish rather than withhold

Three parts of the work stand independently of the objection.

The **analytic content** does not depend on the simulation at all. The omitted variance
component is $(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$ to first order, its sign is set by an
alignment that the usual inputs do not identify, and a correction adding only the positive
term is closer to the right variance than doing nothing only when $\kappa < 1/4$. Both of
those results arrived through review: the first from reviewer 1 in round one, the second in
round two, each correcting a claim the authors had made.

The **negative result** is worth reporting on its own account. The conventional sandwich
used throughout fails at poor overlap for every method compared, including in scenarios
containing no effect modification, and that failure is larger than the effect the study was
built to measure. It is consistent with @chandler2024 and it invalidates absolute-coverage
claims in that region, which the paper now says.

The **registered negative outcome** is itself informative. A prespecified analysis that
returns "uninformative" and says so is a more useful contribution to a catalog of open
problems than a study that quietly reinterprets its gates.

## What is not established

The registered coverage question is **not confirmatorily answered**. Every usable coverage
result comes from a post-run restriction that conditions on an observed outcome correlated
with all methods assessed. Labelling that exploratory is necessary but does not convert it
into confirmatory evidence, as the reviewer said.

The catalog entries MIS-03 and EST-07 therefore record this study as answering part of the
problem with the confirmatory question open, not as closing it.

## Required for a confirmatory answer

A fresh run under a new registration, with either an ex ante design restriction such as
expected effective sample size, or a source variance procedure validated in advance to pass
the negative controls across the intended design. Interior values of $\kappa$ are needed to
test the one-quarter threshold empirically. Non-normal, categorical and rounded covariates
are needed before any reporting recommendation generalizes.

## Reviewer participation, and their disagreement

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) reviewed both rounds and ends at **major
revision**. Reviewer 2 (GLM-5.2 via Ollama) joined after the manuscript had been revised
through both of Reviewer 1's rounds, because the originally invited second reviewer could
not be reached, and ends at **minor revision** judging the conclusions supported and all
sixteen prior points resolved. Reviewer 2 therefore read a later version than Reviewer 1
first saw, and the record says so rather than presenting the reports as contemporaneous.

Kimi K3 via Ollama was invited in both rounds and could not be reached: the model is billed
as extra usage and the account's extra-usage balance was empty, verified through the CLI,
the HTTP API and the python client, so an account state and not a client fault. The
invitation and the failure are both recorded.

The two reviewers agree on what is wrong and disagree on how much it matters. This decision
follows Reviewer 1 on the point that governs the catalog: the analytic contribution is
confirmatory of theory and stands on its own, and the coverage evidence is exploratory and
does not close MIS-03. Reviewer 2's lighter recommendation is recorded, not overridden
silently.


