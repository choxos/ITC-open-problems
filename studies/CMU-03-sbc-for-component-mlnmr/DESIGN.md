# CMU-03 design: two simulation-based calibrations, and the gap between them is the integration error

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog identifies an unstated design choice inside SBC for ML-NMR and says
that a passing rank histogram means different things under the two options.
Section 2 goes further: **the two options differ by exactly the quantity the
integration approximation introduces, so running both turns SBC from a code check
into a measurement.** That is what makes this worth more than a compliance
exercise, and it is the answer to the catalog's own warning that a pass can be
presented as scientific validation.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no simulation-based calibration study exists for
Bayesian component ML-NMR or bridge models; parameter-rank uniformity alone
cannot detect a posterior equal to the prior, which is CMU-02's failure mode, so
data-dependent test quantities are required; and the choice between an end-to-end
replicate and one drawn from the coded approximate likelihood is unstated,
unprescribed and consequential.

**Refuting sentence:** *the two replicate constructions agree to within Monte
Carlo error at production integration settings, so the choice is immaterial and
SBC is the routine code check it is usually treated as.*

**That refutation is a real possibility and it is worth establishing**, because
production integration orders were chosen to make integration error small. If it
holds, the deliverable is a clean statement that the choice does not matter at
settings in use, which is more useful than a warning.

## 2. The mechanism: what each replicate construction actually validates

SBC rests on an exact identity. If $\theta \sim \pi$ and $y \sim p(\cdot\mid
\theta)$, then the rank of $\theta$ among draws from $p(\theta\mid y)$ is uniform,
**provided the $p$ used to simulate is the same $p$ the posterior conditions on.**

For an ML-NMR aggregate arm the coded likelihood is an approximation:

$$\tilde p(y_j \mid \theta) \;=\; \ell\!\left(y_j;\; \tfrac{1}{Q}\textstyle\sum_{q=1}^{Q} \mu(x_{jq};\theta)\right) \;\approx\; \ell\!\left(y_j;\; \textstyle\int \mu(x;\theta)\,dF_j(x)\right) \;=\; p(y_j\mid\theta)$$

with quadrature error at order $Q$, and $F_j$ itself reconstructed from published
marginals through assumed parametric margins and a copula.

**Two SBC constructions therefore exist and they are not the same test.**

- **Coded-likelihood SBC.** Simulate $y$ from $\tilde p$. The simulating and the
  conditioning likelihood are then identical by construction, so ranks are
  uniform **whenever the sampler and the code are correct, regardless of how bad
  the integration is.** This variant is blind to integration and reconstruction
  error by construction, and that is not a limitation to note in passing; it is
  the reason a pass here says almost nothing about the model as applied.
- **End-to-end SBC.** Simulate individual covariates and outcomes from the true
  individual-level model, aggregate them as a publication would, reconstruct
  $F_j$, and fit. Now the simulating $p$ and the conditioning $\tilde p$ differ,
  and the ranks are uniform only if that difference is negligible.

**The prediction:** end-to-end rank non-uniformity, measured against the
coded-likelihood variant as its own control, **is the integration and
reconstruction error expressed in calibration units.** It should shrink as $Q$
grows and should be larger for skewed margins and stronger interactions.

If that holds, this study delivers something the field lacks: a way to ask
whether an integration order is adequate **for inference**, rather than whether
the integral is numerically accurate. OUT-11 measured the latter directly and
found the arm-differential mattered; this is the former.

**On the Modrak point.** Parameter-rank uniformity cannot detect a posterior equal
to the prior, which is exactly CMU-02's subject. Data-dependent test quantities,
the joint log-likelihood in particular, are therefore added, and **the design
includes a deliberately broken implementation in which the likelihood is dropped
entirely**, so that the claim "ranks alone would pass this" is demonstrated rather
than cited.

## 3. Estimand, with its true value defined

SBC has no estimand in the usual sense; it tests a distributional identity. What
is estimated here is the **departure from uniformity**, and it needs a definition.

**Primary.** The rank distribution's departure from uniform for the decision
contrast and for the joint log-likelihood, summarized by the max-deviation
statistic of the empirical CDF against its simultaneous confidence band at the
replicate count used.

**Its true value under a correct implementation is exactly uniform**, which makes
this one of the few designs in the program where the null is exact rather than
approximate, and the deviation's sampling distribution is known.

**The derived estimand that carries the contribution:** the difference in
departure between the end-to-end and coded-likelihood constructions at matched
settings, which section 2 identifies with the integration and reconstruction
error.

## 4. Data-generating mechanism, and what it makes invisible

Parameters drawn from **the exact prior used in fitting**, which is the
requirement that makes SBC valid and the one most often violated in practice.
Hierarchical and constrained priors are drawn from directly rather than
approximated, and P1 verifies the draw matches the fitted prior.

### Factors

| factor | levels | why |
|---|---|---|
| replicate construction | end-to-end; coded likelihood | **the unstated choice**, and the design's whole point |
| integration points $Q$ | 32, 128, 512 | section 2 predicts the gap shrinks in $Q$ |
| marginal shape | normal; skewed | reconstruction error is worst where margins are skewed, which is COV-12's subject |
| identification strength | strong; weak (a coordinate with little likelihood information) | Modrak's failure mode, and CMU-02's |
| model | component ML-NMR; a bridge model | the two implementations the catalog names |
| implementation | correct; **deliberately broken (prior returned as posterior)**; **deliberately broken (sign error in the interaction)** | so the test's power is measured rather than assumed |

**The broken implementations are not decoration.** A calibration test that has
never been shown to fail is not evidence, and CMP-14 shipped a statistic that
could not fire for two rounds.

### What the mechanism makes true, and therefore what the study cannot see

- **SBC validates code and computation, not scientific assumptions.** The
  catalog is explicit and the paper's abstract must be too: a pass says the
  implementation recovers its own generative model and says nothing about whether
  that model is right for any real network. Pairing with misspecification
  simulations is named as necessary and is **not** done here.
- Target covariates enter as fixed design inputs and are not simulated, since
  their uncertainty is not modeled by the estimator. EST-07 and CMP-15 own that
  uncertainty.
- The survival case would require the Kaplan-Meier reconstruction step inside
  every end-to-end replicate. That is included only if P3 shows it is affordable;
  if not, its absence is stated, because **a replicate drawn from the coded
  likelihood cannot see reconstruction error at all** and omitting the survival
  case silently would hide the largest instance of the study's own mechanism.
- Cost forces a reduced model. Which reductions were made and what they exclude
  is listed rather than described as "a simplified model".

## 5. Methods, including one that can win

The comparison is between test constructions rather than between estimators:

| arm | specification | role |
|---|---|---|
| parameter ranks only | Talts et al. | the standard practice |
| **plus joint log-likelihood** | Modrak et al. | the fix the catalog requires |
| plus decision-contrast ranks | the quantity a user reports | calibration where it is read |
| end-to-end construction | full pipeline | validates model plus integration plus reconstruction |
| coded-likelihood construction | as implemented | validates the code only |

**The comparator that can win is parameter ranks only.** If it detects both broken
implementations at the replicate counts affordable, the Modrak addition is
unnecessary in practice for these models and the recommendation simplifies.
Registered as such; section 2 predicts it will fail on the prior-equals-posterior
break specifically, and that prediction is falsifiable here.

## 6. Performance measures and replicate count

Rank uniformity by parameter and by test quantity, with simultaneous bands;
**detection rate of each deliberately broken implementation**, which is the test's
power and is the measure that decides whether any of this is worth recommending;
compute cost per SBC replicate, reported prominently, because the catalog asks
for it so anyone repeating the work can see the trade-off.

**The replicate count is derived from the power requirement, not from coverage.**
To detect a specified departure at 80% power with a simultaneous band, P2 gives
the count; SBC's usual advice of a few hundred is not adopted without checking it
against this design's break sizes.

**Divergent transitions are recorded as a rate and fits failing the sampler
policy are reported, never dropped.** A discarded replicate breaks the SBC
identity, which is a subtler failure than it looks: conditioning on convergence
makes the ranks non-uniform even for a correct implementation, so refits must be
handled by the registered policy and the number of them reported.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The difference in rank departure between end-to-end and
coded-likelihood constructions, as a function of $Q$, for the correct
implementation.

**Decision rule.**

- A departure present end-to-end, absent under the coded likelihood, and
  shrinking in $Q$ **confirms** section 2 and establishes SBC as a measure of
  integration adequacy; the deliverable is a recommended construction plus a
  reporting requirement to state which was used.
- No difference at any $Q$ **refutes** the consequential half of the catalog's
  claim: the choice is immaterial at these settings and the paper says so.
- A departure present under **both** constructions means the implementation is
  wrong, and no integration conclusion can be drawn until it is fixed. **That
  branch stops the study**, which is what a calibration check is for.

## 8. Three controls, each of which can fail

**Null control.** Coded-likelihood construction, correct implementation, strong
identification: ranks must be uniform within band for every parameter and test
quantity. This is exact, and failure means the harness or the prior draw is
wrong, most likely the prior draw.

**Positive control.** Both deliberately broken implementations must be detected by
at least one test quantity. **A calibration study whose test never fires has
established nothing**, and section 2 predicts specifically that the
prior-equals-posterior break passes parameter ranks and fails the joint
log-likelihood. If that split does not appear, Modrak's result is not operative
here and the recommendation changes.

**Falsifier for the study's own headline.** The expected headline is that the
construction choice matters. Its falsifier is the highest $Q$ with normal
margins: there the integration error should be negligible and the two
constructions should agree. If they still differ there, the difference is not
integration error and section 2's identification is wrong.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| A pass presented as scientific validation | Stated in the abstract; misspecification simulations named as separate and not done here | removed |
| A test that has never been shown to fail | Two deliberately broken implementations, with a predicted split between them | removed |
| Prior drawn approximately rather than exactly | P1 verifies the draw against the fitted prior | removed |
| Failed replicates dropped, breaking the SBC identity | Registered sampler policy; refits and failures counted and reported | removed |
| Survival reconstruction omitted silently | Included if P3 permits; its absence stated and its significance explained if not | removed |
| Replicate count taken from convention | Derived from a power requirement in P2 | removed |
| Reduced model described vaguely | Reductions listed with what each excludes | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** exact prior draw | That draws from the sampling code match the fitted prior, by comparing a prior-only fit's posterior to the draw distribution | **Whether any rank here is valid.** SBC with an inexact prior draw fails for a reason unrelated to the code under test | hours |
| **P2** power and replicate count | The count needed to detect the two break sizes at 80% power with simultaneous bands | The replicate count, which is the budget | hours |
| **P3** survival feasibility | Cost of an end-to-end replicate including Kaplan-Meier reconstruction | Whether the survival case is in scope | days |
| **P4** total budget | Replicates times per-fit cost, computed not typed; and whether it fits inside SFW-06's feasible frontier | The grid and the model reductions | hours |

**P1 is the load-bearing probe and it is the one most often skipped.** Every
published SBC failure that turned out to be a harness bug was this.

## 11. Cost

The largest per-result cost in the queue: hundreds of refits of a model that is
expensive once. **This study is the concrete example SFW-06 uses to define a
realistic sensitivity program**, and the two should be read together. No total
quoted until P2 and P4.

---

## Relationship to the rest of the queue

- **CMU-02** owns the prior-equals-posterior failure mode; this study uses it as
  a deliberate break and imports its diagnostics.
- **SFW-06** decides whether this study is affordable and uses it as its worked
  example; if both run, SFW-06 runs first.
- **COV-12** owns marginal reconstruction, whose error this study measures in
  calibration units as a by-product.
- **CMP-17** and **OUT-13** own Kaplan-Meier reconstruction uncertainty, which is
  the survival case's other half.
- **SFW-13** owns the fact that `cpaic` and `mlumr` are unreleased and
  independently unvalidated, which is the practical reason this check matters.
