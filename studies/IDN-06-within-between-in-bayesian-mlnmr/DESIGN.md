# IDN-06 design: what identifies an interaction when the treatment has no IPD

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**Two completed studies bound this one.** CMP-13 established the within-versus-
between conflation algebraically, in a *component* model, frequentist, Poisson
with a log link, and said explicitly that its coverage numbers do not transfer to
`multinma` because implemented ML-NMR is Bayesian and priors matter most exactly
where interactions are weakly identified. CMU-02 measured the operating
characteristics of prior-driven-posterior diagnostics and said explicitly that
IDN-06 "is not addressed at all because this design contains no within-versus-
between structure."

The gap between those two sentences is this study: **the within/between
conflation in standard Bayesian ML-NMR, where the prior is what fills the hole.**

---

## 1. The claim, restated as something that can be false

The catalog entry carries an auditor disagreement that still stands. The
literature auditor found each claim confirmed near-verbatim by the ML-NMR
authors, who report that the secukinumab interaction estimates rest solely on
aggregate data and that the shared-interaction restriction was *required* to
identify the model
([doi:10.1177/0272989X221117162](https://doi.org/10.1177/0272989X221117162)). The
source-code auditor judged the diagnostic void overstated, because `cpaic`
already labels whether a row is identified by IPD, by between-study gradients or
by neither.

**Proposition under test:** where a treatment appears in no IPD study, its
interaction is identified only by between-study covariate variation, is therefore
confounded with everything else that differs across studies, and the existing
identification flags detect this.

**Refuting sentence:** *the shared-interaction restriction transfers enough
IPD-borne information that the aggregate-only treatment's interaction is neither
prior-driven nor ecologically confounded, and the flags fire on analyses that are
in fact fine.*

The study is powered for both directions, because the flags have a false-positive
rate and nobody has measured it. **A flag that fires on everything is as useless
as one that fires on nothing, and only the second failure mode has been
considered.**

## 2. The mechanism, algebraically

For a linear predictor $\eta = \mu_i + \gamma^\top x + (\delta_k + \beta_k^\top
x)\mathbb{1}[\text{trt}=k]$, the Fisher information for $\beta_k$ separates by
data type. An IPD study $i$ contributes through **within-study** covariate
variation; an aggregate study $j$ enters only through its reported summary, so
after integration it contributes through the **between-study** contrast of those
summaries:

$$\mathcal{I}(\beta_k) \;\propto\; \underbrace{\sum_{i \in \mathcal{I}_k} n_i\,\mathrm{Var}_i(x)}_{\text{within, causal}} \;+\; \underbrace{\sum_{j \in \mathcal{J}_k} n_j\,(\bar x_j - \bar x_{\cdot})^{\otimes 2}}_{\text{between, confounded}}$$

Three consequences, each a prediction made before simulating:

1. **If $\mathcal{I}_k = \emptyset$ the first term is exactly zero.** The
   posterior for $\beta_k$ is then a function of between-study contrasts and the
   prior, and no amount of aggregate data restores the within-study term. This is
   a rank statement, not a precision statement, and it is why prior-to-posterior
   contraction is the right diagnostic family: CMU-02 measured those diagnostics
   but on a design with no within/between structure to detect.
2. **The shared-interaction restriction $\beta_k \equiv \beta$ for all $k$ in a
   class makes the model identified without adding information about $k$.** It
   moves $k$'s interaction onto the pooled estimate, so the posterior contracts
   and the fit improves while the quantity being reported is a different
   treatment's interaction. **Contraction therefore rises exactly where trust
   should fall**, which is why a contraction diagnostic alone cannot decide this
   and why the identified-by flag has to be a rank computation.
3. **Between-study contrasts in covariate *means* are only one route.** CMP-14's
   route table establishes that on a curved link, between-study heterogeneity in
   covariate *variances* and in *baseline risk* also identify an interaction,
   with no randomization behind any of the three. IDN-06 is the mean route; this
   study fits the flags against all three, because a flag that reports
   "identified by between-study gradients" while the identifying gradient is a
   baseline-risk difference is telling the analyst the wrong thing.

**Prediction 3 is imported from CMP-14 and must not be re-derived here.** If
CMP-14 has not cleared review when this runs, the route arm is dropped and the
study says so rather than asserting the taxonomy.

## 3. Estimand, with its true value defined

**Primary.** The within-person effect modification coefficient $\beta_k$ for the
treatment with no IPD, on the conditional log-odds scale. True value set by the
generating model.

**Secondary.** The target-population marginal treatment effect for $k$ versus the
network reference, at a declared target covariate distribution. True value by
Gauss-Hermite quadrature over the target law at an order fixed by probe P1, since
the marginal effect of a logistic model is not available in closed form and a
"true marginal effect" read off the conditional coefficients is the
non-collapsibility mistake.

**Both are reported.** The conditional coefficient is where the mechanism acts;
the marginal contrast is what a decision uses. CMP-13 found these can diverge
badly, and reporting only the first would understate the practical cost while
reporting only the second would blur the mechanism.

## 4. Data-generating mechanism, and what it makes invisible

Nine-study network, roughly the psoriasis geometry the ML-NMR authors used, so
the result is comparable to the published application rather than to an invented
one. One continuous effect modifier plus one prognostic covariate.

### Factors

| factor | levels | why |
|---|---|---|
| IPD placement | $k$ has 0, 1, or 2 IPD arms | the whole mechanism; 0 is the reported secukinumab situation |
| within/between discordance | $\beta_k^{within} - \beta^{between} \in \{0, 0.5, 1.0\}$ in SD units | CMP-13's axis, carried over so the two studies' results are on one scale |
| identifying route | mean contrast; variance contrast; baseline-risk contrast | CMP-14's taxonomy, tested against the flags |
| prior scale on interactions | 0.5, 1.0, 2.5 (the `multinma` default family) | where the posterior comes from when the likelihood is silent |
| covariate overlap | moderate, poor | changes how far the integration extrapolates |

Crossed on the first two and the prior scale; route and overlap crossed at the
middle level of the rest. Cell count fixed by probe P2.

**Held fixed:** binary outcome, logit link, fixed treatment effects, conditional
constancy holding for treatments that have IPD, exactly reported study summaries,
correct integration distribution.

### What the mechanism makes true, and therefore what the study cannot see

- Conditional constancy holds for the IPD-supported treatments, so any failure at
  $k$ is attributable to the identification structure and not to a transitivity
  violation elsewhere. The study therefore says nothing about networks where both
  fail together, which is the realistic case.
- Study covariate means are drawn independently of study baselines except in the
  baseline-route arm. This makes the ecological route **unbiased by
  construction** everywhere else, which is favorable to the shared model. IDN-05
  carries the same restriction and named it; the same disclosure applies and the
  results are conservative in the same direction.
- One modifier drifts, linearly. Multiple correlated modifiers and nonlinear
  modification are untested.
- Aggregate integration uses the correct target law. Misspecified integration
  distributions are CMP-15's subject.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| shared interaction | one $\beta$ across the class, `multinma` default priors | status quo, and the specification the ML-NMR authors say was *required* |
| treatment-specific, independent | free $\beta_k$ per treatment | the naive separation; expected to be unidentified at $\mathcal{I}_k=\emptyset$ and that is a result, not a failure |
| treatment-specific, hierarchical | $\beta_k \sim N(\bar\beta, \sigma^2_\beta)$ | **the avenue Phillippo et al. flag as unexplored**; the comparator that can win |
| within-study centered | separate within and between coefficients, IPD centered on study means | CMP-13's fix, ported to a non-component Bayesian model |

**The comparator that can win is the hierarchical treatment-specific model.** If
it is nominal at every discordance level with intervals not much wider than the
shared model's, then the catalog's problem has a deployable answer, the flags
matter less, and the study's headline becomes a recommendation rather than a
warning. That is registered as the outcome most likely to overturn the expected
result.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage for both estimands; interval width; posterior contraction
relative to the prior; the leave-one-source-out marginal precision from CMP-14's
`lik_marginal_precision`, which is exactly zero where a coordinate is
unidentified and is prior-free by construction.

**Flag operating characteristics**, which is the half nobody has measured:
sensitivity and specificity of the identified-by label and of the
prior-reproducing-posterior flag, against a truth defined by the rank computation
in section 2 rather than by the flag's own internals. **Scored as classifiers,
with discrimination and calibration**, following DIA-03, which found that a
panel of diagnostics scored this way behaves very differently from how it reads.

MCSE on everything. Sampler diagnostics recorded per fit and failures reported,
never dropped. The divergence criterion is a **rate**, not a count: OUT-11
registered `divergent == 0` and it would have failed every fit in a production
run.

$n_{sim} = 1000$ per cell, from a target coverage MCSE of 0.007 at $c=0.95$.
Lower than EST-07's 2000 because each replicate is a Stan fit; the target is set
from what the budget in P4 permits and is stated as such rather than presented as
a free choice.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the 95% credible interval for $\beta_k$ under
the shared model, at $\mathcal{I}_k = \emptyset$, across discordance levels.

**Decision rule.**

- Shared-model coverage falling below 90% at nonzero discordance while a
  separated model stays within 93.5% to 96.5% **confirms** the catalog claim for
  Bayesian ML-NMR.
- Shared-model coverage staying within band at every discordance **refutes** it
  and the refutation is reported as the headline.
- Coverage within band only because the interval is wide enough to be
  uninformative is neither: an interval whose width exceeds the prior's central
  95% range is recorded as **prior-dominated** and excluded from the coverage
  claim, with the count reported. CMP-13 saw exactly this, intervals so wide that
  coverage approaches one, and it must not read as a success.

**Flag rule, registered separately.** The identified-by flag is useful only if it
reaches sensitivity 0.80 at specificity 0.80 against the rank truth. Any lower
and it is reported as not fit for the purpose the source-code auditor credited it
with, which is the specific thing the two auditors disagreed about.

## 8. Three controls, each of which can fail

**Null control.** At zero discordance the shared restriction is true, so every
method must be nominal and the flags must not fire above their nominal rate.
Scoped: this is required only at prior scale $\geq 1.0$, because a tight prior on
a weakly identified coordinate produces exactly the behavior the control would
otherwise call a failure. CMP-14's null control failed in 54 scenarios for
precisely this reason and the scope restriction is copied from its repair.

**Positive control.** At $\mathcal{I}_k = \emptyset$, maximal discordance and the
widest prior, the identified-by flag must fire in essentially every replicate.
A flag that cannot fire where the coordinate is provably unidentified is not a
diagnostic, and CMP-14 shipped a statistic with that property for two rounds
before it was caught.

**Falsifier for the study's own headline.** The expected headline is that the
shared restriction fails when discordance is real. Its falsifier is the arm with
2 IPD arms for $k$: there the within-study term is nonzero and the shared model
must recover. If it fails there too, the problem is not the identification
structure but the fitting, and the headline is withdrawn.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Result is a prior artifact | Prior scale is a registered factor, not a fixed choice; prior-dominated intervals excluded from the coverage claim and counted | removed |
| Contraction rises where trust falls, so contraction is a misleading diagnostic | Prior-free leave-one-source-out precision reported alongside it; section 2 prediction 2 states the direction in advance | removed |
| The flags are evaluated against their own definition | Truth for the flag is the rank computation, computed independently of the flag's implementation | removed |
| MCMC error masquerading as a finding | Divergence rate, R-hat and both ESS reported per fit; refits recorded with the code stamp that produced them | removed |
| Route taxonomy asserted rather than computed | Imported from CMP-14's computed table; arm dropped if CMP-14 has not cleared review | disclosed |
| Ecological route unbiased by construction | Stated in section 4; results conservative | disclosed, not removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** integration order | Order at which the true marginal target contrast is stable to $10^{-4}$ | The definition of the secondary truth | minutes |
| **P2** rank map | The Fisher rank and the leave-one-source-out precision for $\beta_k$ in every planned cell, before any fitting | The grid. A cell where $\beta_k$ is identified when the design says it is not is a broken cell, and CMP-14 shipped one for four rounds | hours |
| **P3** shared-model identifiability | Whether `multinma` will fit the independent treatment-specific model at $\mathcal{I}_k=\emptyset$ at all, or rejects it | Whether that arm exists. CMP-14 had two specifications rejected by `multinma` at the Stan level after they were registered | hours |
| **P4** unit cost | Wall clock per Stan fit at production settings; the grand total, computed not typed | $n_{sim}$ and the grid | hours |

**P2 is load-bearing.** The entire design rests on cells where a coordinate is
unidentified, and "unidentified" is a computation, not an intention.

## 11. Cost

Dominated by Stan. Unmeasured until P4; no total quoted. The sensitivity program
is priced **per fit set**, one row per setting, because OUT-11's was priced per
arm and understated by more than twelve hours with "halved and doubled" priors
costed as one fit set when it is two.

---

## Relationship to the rest of the queue

- **CMP-13** owns the algebra in the component, frequentist, log-link case. Its
  identity is imported; its coverage numbers are not.
- **CMU-02** owns the diagnostics generally. Its thresholds are imported; this
  study supplies the within/between structure CMU-02 lacked.
- **CMP-14** owns the route taxonomy. Imported, not re-derived.
- **IDN-05** owns the shared-modifier check's power. Different diagnostic, same
  network geometry; if both run, the geometry is shared code.
- **MOD-15** asks when within- and across-trial interactions may be pooled, which
  is the decision rule this study's operating characteristics would feed.
