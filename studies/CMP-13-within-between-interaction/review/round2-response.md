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
