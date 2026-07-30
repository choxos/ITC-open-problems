# CMP-20 design: the exposure-rate covariance the Poisson aggregate likelihood assumes away

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

This is the cheapest decisive study in the queue, and the reason is section 2:
the bias has an exact closed form in three quantities, so the simulation
*verifies an identity* rather than exploring a space. The catalog's own note says
to run it very early despite its lower priority rating. That is right.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** for an aggregate Poisson arm, multiplying total
exposure by the mean modeled rate under an *unweighted* covariate integration
distribution is exact only when exposure has zero covariance with the modeled
individual rate; publications essentially never report the exposure-weighted
summaries that would make it exact; and the resulting error is material at
plausible levels of differential follow-up.

**Refuting sentence:** *the omitted covariance cancels in the contrast that is
actually reported, so the error is a property of each arm's absolute rate and not
of the target rate ratio.*

**The refutation is live, and section 2 shows it is exactly half right.** That is
what makes this worth running rather than asserting.

## 2. The mechanism, algebraically, and it is exact

For an aggregate arm of $n$ participants with exposure $T_i$ and individual rate
$\lambda(x_i)$, the true expected event count is

$$\mathbb{E}[Y] \;=\; n\,\mathbb{E}[T\lambda(x)] \;=\; n\big\{\mathbb{E}[T]\,\mathbb{E}[\lambda(x)] + \mathrm{Cov}(T, \lambda(x))\big\}.$$

The likelihood as implemented computes $T_{\text{total}}\cdot\bar\lambda$, where
$T_{\text{total}} = n\mathbb{E}[T]$ and $\bar\lambda = \int\lambda(x)\,dF(x)$
under the reported unweighted moments. So it computes the first term and drops
the second, and the multiplicative error is

$$\boxed{\;\frac{\mathbb{E}[Y]_{\text{true}}}{\mathbb{E}[Y]_{\text{model}}} \;=\; 1 + \rho_{T,\lambda}\;\mathrm{CV}(T)\;\mathrm{CV}(\lambda)\;}$$

**three quantities, no approximation.** The bias in that arm's log rate is
$\log\{1+\rho\,\mathrm{CV}(T)\,\mathrm{CV}(\lambda)\}$.

Two consequences, and they are the study:

1. **The contrast bias is a difference, so it cancels when the association is
   common to both arms.**
   $$\text{bias}(\log \mathrm{RR}) = \log\frac{1+\rho_1\mathrm{CV}_1(T)\mathrm{CV}_1(\lambda)}{1+\rho_0\mathrm{CV}_0(T)\mathrm{CV}_0(\lambda)}$$
   The refuting sentence in section 1 is therefore correct for the *common* part
   and wrong for the *differential* part. **The quantity that matters is not the
   exposure-rate covariance; it is the difference in that covariance between
   arms**, and no source states this. If the study establishes only that, it has
   changed what should be reported.

2. **Exposure-weighted moments make the likelihood exactly correct, provably.**
   Integrating against $dG(x) \propto \mathbb{E}[T\mid x]\,dF(x)$ gives
   $\int\lambda\,dG = \mathbb{E}[T\lambda]/\mathbb{E}[T]$, so
   $T_{\text{total}}\int\lambda\,dG = n\,\mathbb{E}[T\lambda] = \mathbb{E}[Y]$
   exactly. This is a theorem, not a simulation finding, and the simulation's job
   is to confirm the implementation attains it, not to discover it.

**What differential follow-by-prognosis does.** Sicker patients contribute less
follow-up and have higher rates, so $\rho < 0$ within an arm. If the effect is
protective, treatment reduces both the rate and the dropout, so $\rho$ differs
between arms and the difference does not cancel. That is the realistic case and
it is a design factor rather than an assumption.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal rate ratio between the two active
treatments.

**True value.** $\mathbb{E}_T[T\lambda_1(x)]/\mathbb{E}_T[T\lambda_0(x)]$ over the
declared target population, computed by exact numerical integration of the joint
exposure-covariate law used to generate the data, at an order fixed by P1.

**The distinction that must not be blurred:** the truth integrates the *joint*
law of $(T, x)$. Defining truth as $\int\lambda\,dF$ would build the very
assumption under test into the definition of the answer, which is how a study
confirms itself.

## 4. Data-generating mechanism, and what it makes invisible

Two-arm aggregate Poisson arms in a small network with one IPD study, the
smallest geometry in which a target marginal rate ratio is defined.

### Factors

| factor | levels | why |
|---|---|---|
| within-arm exposure-rate correlation $\rho_0$ | $0$, $-0.2$, $-0.4$, $-0.6$ | the mechanism; negative because sicker patients drop out |
| differential correlation $\rho_1 - \rho_0$ | $0$, $0.2$, $0.4$ | **section 2's real driver**, and the axis no source names |
| exposure dispersion $\mathrm{CV}(T)$ | 0.3, 0.6, 1.0 | one of the three factors in the identity |
| rate dispersion $\mathrm{CV}(\lambda)$, driven by effect-modification strength | 0.2, 0.4, 0.8 | the third factor |
| arm size | 250, 1000 | to show the bias does not shrink with $n$; it is not a variance problem |

Fully crossed: 216 cells, each a Poisson fit measured in seconds. **Total exposure
is held fixed across cells** so that a difference between cells is the covariance
and not the amount of person-time.

### What the mechanism makes true, and therefore what the study cannot see

- The rate model is correctly specified apart from the integration weighting, so
  every error observed is attributable to the omitted covariance. That is the
  point and it is also the limit: nothing here speaks to Poisson models that are
  wrong for other reasons.
- Exposure is generated from a parametric joint law with the covariates, so
  $\mathbb{E}[T\mid x]$ exists and is smooth. Administrative censoring at a fixed
  date, which induces exposure variation *unrelated* to prognosis, is included
  only through $\mathrm{CV}(T)$ and not as a separate mechanism.
- No overdispersion. OUT-08 owns overdispersed counts and recurrent events, and
  mixing the two would confound a likelihood-weighting error with a
  variance-model error.
- Reported moments are exact. COV-12 owns reconstruction error in reported
  summaries and EST-07 owns their sampling error; both are switched off here.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| unweighted integration | status quo; reported unweighted moments | the thing under test |
| exposure-weighted integration | the true exposure-weighted moments supplied | section 2's theorem; **must be unbiased everywhere or the implementation is wrong** |
| joint exposure-covariate model | exposure modeled alongside covariates so the weighting is generated | the deployable fix where weighted moments are unavailable |
| sensitivity calculation | the closed form of section 2 evaluated at a declared range of $\rho$ | what an analyst can do with published data only |

**The comparator that can win is the sensitivity calculation.** If evaluating the
closed form over a plausible $\rho$ range brackets the true bias in essentially
every cell, then no new estimator is needed and the deliverable is a formula plus
a reporting request. That is a better outcome for the field than a new method,
and it is registered as the expected-headline-weakening result.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target marginal rate ratio; bias of each arm's absolute
rate, reported separately so the cancellation in section 2 is visible rather than
inferred; the **realized** $\rho\,\mathrm{CV}(T)\,\mathrm{CV}(\lambda)$ per
replicate, so the identity is checked against the data rather than assumed.

**The identity check is a registered outcome.** Regress observed log-contrast
bias on the closed form across all cells. A slope of 1 confirms the mechanism;
anything else means the derivation is wrong and every downstream claim is
suspect. MIS-03 did exactly this and got a slope of 1.003 (SE 0.042), which is
what let it separate an analytic result from a simulation artifact.

Common random numbers across integration methods within a cell; MCSE clustered on
the replicate block.

$n_{sim} = 2000$ per cell, from a coverage MCSE target of 0.005. Affordable here
in a way it is not elsewhere: these are Poisson fits, not Stan runs.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage and bias of the target marginal rate ratio under
unweighted integration, across the differential-correlation axis.

**Decision rule.**

- Bias exceeding 0.05 on the log rate ratio, or coverage below 90%, at
  differential correlation $\geq 0.2$ with plausible dispersions, **confirms**
  the problem is material.
- Bias below 0.05 and coverage in band at every differential level **refutes**
  materiality, and the study reports that the assumption is safe in the reported
  contrast even though it is violated in each arm.
- **The covariance threshold at which a conclusion changes is reported as a
  number regardless of which branch fires**, since that is the actionable output
  and it does not depend on the verdict.

Two-sided on coverage.

## 8. Three controls, each of which can fail

**Null control.** At $\rho_0 = \rho_1 = 0$, unweighted integration is exact and
must be unbiased and nominal in every cell. This is not decorative: it is the
direct test of the identity's first term.

**Second null control, and it is the interesting one.** At $\rho_0 = \rho_1 \neq
0$ with equal dispersions, each arm's absolute rate is biased while the contrast
is not. **Both must hold simultaneously.** If the arms are biased and the
contrast is too, the cancellation in section 2 is wrong; if neither is biased, the
mechanism is not firing and the design has no signal.

**Positive control.** At maximal differential correlation and maximal
dispersions, unweighted integration must show bias at least three times its
MCSE while exposure-weighted integration stays nominal. A failure here means the
weighted implementation is not attaining the theorem and the study stops.

**Falsifier for the study's own headline.** The expected headline is that the
error is material through the differential term. Its falsifier is the realistic
end of the grid: if plausible differential follow-up produces bias below the
decision threshold, the honest headline is that the assumption is violated and
harmless, and it is reported that way.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Truth defined using the assumption under test | Truth integrates the joint $(T,x)$ law | removed |
| Bias attributed to weighting is really Poisson misspecification | Rate model correct by construction; no overdispersion | removed, and scope named |
| The closed form is asserted rather than checked | Registered identity regression, slope 1 expected | removed |
| Total exposure varies with the covariance factor | Held fixed across cells | removed |
| A weighted-moment fix that is unavailable in practice | Third arm models the weighting; fourth needs published data only | removed |
| Result specific to `cpaic` | `multinma`'s Poisson offset has the same structure; both fitted | removed if P3 confirms, disclosed otherwise |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and integration order | Order at which $\mathbb{E}_T[T\lambda_a]$ is stable to $10^{-5}$ | The definition of truth | minutes |
| **P2** attainable factor levels | Whether the requested $(\rho, \mathrm{CV}(T), \mathrm{CV}(\lambda))$ triples are jointly attainable by a valid joint law; correlations are constrained by the marginals | **The grid.** A requested cell that no distribution realizes is a cell that will silently be run at different values than the table claims | hours |
| **P3** interface check | Whether `multinma` and `cpaic` accept an exposure-weighted moment set at all, or whether the weighted arm has to be implemented outside the packages | Whether the weighted arm is a package result or a custom one, which changes what the paper can recommend | hours |
| **P4** unit cost | Per-replicate wall clock; the total, computed not typed | The grid, though it is unlikely to bind here | minutes |

**P2 is load-bearing and easy to skip.** A correlation matrix that is not
positive definite, or a $\rho$ unreachable given the marginal CVs, does not throw
an error in most generators; it gets silently projected, and the realized factor
differs from the registered one.

## 11. Cost

Small, and it should be quoted only after P4. Poisson GLM fits at these sizes are
milliseconds; the binding constraint is the ML-NMR arm if P3 forces one. No total
here: OUT-11 produced two fatal findings from totals quoted before the unit cost
was measured.

---

## Relationship to the rest of the queue

- **OUT-08** owns overdispersion and recurrent events, switched off here.
- **COV-12** owns reconstruction of reported summaries; **EST-07** owns their
  sampling error. Both switched off here so the covariance is isolated.
- **CMP-15** owns the target joint distribution being approximately known, which
  is the same class of input error one level up.
- **SFW-06** owns interface labeling, which is where this study's reporting
  recommendation would land.
