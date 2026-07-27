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
