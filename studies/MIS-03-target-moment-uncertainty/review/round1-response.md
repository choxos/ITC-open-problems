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
