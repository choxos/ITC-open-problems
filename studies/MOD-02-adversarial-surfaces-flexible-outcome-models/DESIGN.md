# MOD-02 design: an adversarial benchmark for flexible outcome models in PAIC

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog corrects its own source and that correction is the starting point.**
The source said misspecification bias is a problem "especially in STC" and cited
Hatswell, Freemantle and Baio 2020. That paper evaluated unanchored **MAIC** only,
never STC, and found MAIC unbiased across a range of misspecification scenarios,
biased only when important characteristics were omitted from the matching.
Phillippo et al. 2020 cuts the other way: ML-NMR and STC eliminated bias when
their assumptions held while MAIC performed poorly in nearly all scenarios.

So the study does **not** set out to show that STC is fragile. The defensible open
part is narrower: flexible outcome models have never been benchmarked against
parametric baselines in PAIC under adversarial data-generating mechanisms.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** under response surfaces containing thresholds,
splines, nonlinear effect modification and covariate-covariate interaction,
parametric STC incurs transport bias that flexible outcome models remove, and
they remove it at an interval-validity cost that has never been measured.

**Refuting sentence:** *flexibility trades transparent misspecification for
opaque misspecification: the flexible arms are no less biased where it matters,
because the region that drives transport bias is the region with no data, and
regularization there is a modeling assumption exactly like a functional form.*

**The refutation is the catalog's own stated worry and it is the more likely
outcome.** A benchmark that assumed flexibility wins would be worth nothing.

## 2. The mechanism, algebraically: which misspecifications bite

Let $\mu_a(x)$ be the true conditional mean under treatment $a$ and $\hat\mu_a$
the fitted one. The transported contrast is

$$\Delta_T \;=\; g\!\left(\int \mu_1\,dF_T\right) - g\!\left(\int \mu_0\,dF_T\right).$$

**Identity link.** $g$ is the identity and the integrals separate:
$\Delta_T = \int(\mu_1-\mu_0)\,dF_T$. A misspecification **common to both arms**,
say a prognostic nonlinearity $h(x)$ omitted from both, cancels exactly. Only
misspecification of the *difference* $\tau = \mu_1-\mu_0$ transports into bias.
This is the catalog's "not every omission bites", made exact.

**Curved link.** $g$ is applied *after* integration, so a common prognostic
nonlinearity no longer cancels: it changes each arm's integrated mean, and $g$
maps the two shifts unequally. **Prognostic misspecification becomes harmful
purely through non-collapsibility**, with no change to the interaction at all.

That gives a taxonomy of adversarial surfaces that is derived rather than
assembled by taste:

| surface | what is wrong | predicted to bite |
|---|---|---|
| **A** prognostic threshold or spline | $h(x)$ common to both arms | not at identity; yes at logit |
| **B** nonlinear effect modification | $\tau(x)$ has a threshold or spline | on every scale; the worst case |
| **C** covariate-covariate interaction inside $\tau$ | $\tau$ depends on $x_1x_2$ | on every scale, and only if the *joint* target law is used |
| **D** treatment-nonlinear interaction | $\tau$ not additive in the modifier | on every scale |

**And the extrapolation prediction, which is the reason this is a PAIC problem
and not a regression problem.** The bias is
$\int\{\hat\tau - \tau\}\,dF_T$, and $\hat\tau$ is fitted on $F_S$. Where $F_T$
puts mass outside the support of $F_S$, the integrand is set entirely by whatever
the fit does off-support: a polynomial's tail, a spline's boundary behavior, or a
learner's prior. **Overlap and misspecification therefore interact
multiplicatively, not additively**, and a factorial that varies each alone cannot
see it. Testing that interaction is what makes this an adversarial benchmark
rather than a rerun.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, log odds ratio for
the binary arm and mean difference for the continuous arm.

**True value.** By quadrature over the true target law using the true $\mu_a$, at
an order fixed by P1. Both a marginal and a conditional truth are computed so the
collapsibility component of any error is separable from the misspecification
component; without that, surface A's logit-link effect is indistinguishable from
a fitting failure.

**A second derived estimand:** the fraction of transport bias contributed by
target mass outside the source's support, computed by splitting the integral at a
declared support boundary. That number is what tells the reader whether a
flexible fit failed at extrapolation or at interpolation, and it is the quantity
the existing literature never reports.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| adversarial surface | none; A; B; C; D | section 2's taxonomy, one at a time so attribution is possible |
| link | identity; logit | the prediction that separates A from B |
| overlap | good; moderate; poor | the multiplicative interaction; the axis that makes misspecification transport |
| effect-modification strength | 2 levels | the multiplier on every bias term |
| source size | 300, 1000 | flexible learners need events; this is where "HTA-scale trials rarely have enough" is tested rather than asserted |
| event rate (binary arm) | 0.1, 0.3 | the same constraint in the currency that binds |

Surface × link × overlap fully crossed; the rest at reduced levels fixed by P2.

### What the mechanism makes true, and therefore what the study cannot see

- One adversarial feature at a time. Real surfaces mix them, and the study says
  nothing about how they compound. That is deliberate: a mixed surface would make
  every result unattributable, and attribution is the deliverable.
- The modifier set is known and correctly specified in every arm. **Omitted
  modifiers are the one failure Hatswell et al. actually found**, and including
  them here would reproduce a known result while confounding the new one. COV-01
  owns that.
- Anchored comparisons throughout, so the cancellation in section 2 is available.
  Unanchored PAIC has no common arm and the taxonomy changes; that is a separate
  study.
- Covariates are continuous with a known joint law, so the support boundary used
  for the extrapolation split is well defined. It would not be in high dimension
  and the study claims nothing there.

## 5. Methods, including one that can win

**The learner set is deliberately small and the catalog's own note is why:**
valid inference across several flexible learners substantially enlarges the
workload, and a benchmark with six half-tuned learners is worse than one with
three properly handled.

| arm | specification | role |
|---|---|---|
| parametric STC | linear main effects and interactions, marginalized by simulation | the baseline the source impugned without evidence |
| spline STC | natural splines on continuous covariates, both main and interaction terms | flexibility with a transparent form; the honest middle |
| BART | full surface learned, both arms | the flexible arm |
| **structured BART** | BART on the prognostic part, **parametric interaction imposed** | the catalog's own recommendation: treat a flexible fit as a nuisance estimator with causal structure imposed rather than learned |
| doubly robust | augmented weighting with the spline outcome model | the hybrid |
| ML-NMR | `multinma`, correctly specified | the method that integrates rather than centers |

**The comparator that can win is structured BART.** If imposing the causal
structure recovers the flexible arm's bias reduction without its interval failure,
the recommendation is concrete and the "flexibility is opaque" worry is answered
rather than merely confirmed. Registered as the outcome most likely to overturn
the expected headline.

**Inference route is a factor, not a fixed choice**, because the catalog is
explicit that cross-fitting is not a universal requirement: each flexible arm is
run with (i) cross-fitting, (ii) a resampling scheme that **repeats the full
tuning procedure** inside each resample, and (iii) the model's own posterior for
BART. Reporting a flexible point estimate with a naive interval is not among the
options; that comparison would be rigged.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, RMSE, coverage, interval width, convergence, per arm per cell, with MCSE.
The extrapolation-split bias fraction from section 3. Calibration of the
transported prediction, not only the contrast, since a surface can be right on
average and wrong everywhere.

**The registered interaction test:** bias regressed on surface × overlap with the
interaction term, which is section 2's multiplicative prediction. A significant
interaction confirms that this is a transport problem rather than a regression
problem; its absence means the existing single-axis factorials were adequate and
the study says so.

Common random numbers across arms within a cell; MCSE clustered on the replicate
block.

$n_{sim} = 1000$ per cell. Lower than the cheap studies in this program because
every flexible arm carries a resampling or cross-fitting loop; the coverage MCSE
is 0.007 at $c = 0.95$ and is stated rather than hidden behind a round number.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target-population marginal effect
under surface B (nonlinear effect modification) at poor overlap, on the logit
scale: the cell section 2 predicts is worst and where flexibility should pay if it
ever does.

**Decision rule.**

- Flexible arms with materially lower bias **and** coverage in 93.5% to 96.5%
  where parametric STC is biased: flexibility is established for PAIC and the
  inference route that achieved it is named.
- Flexible arms with lower bias but coverage outside band under **every**
  inference route: the catalog's opaque-misspecification worry is **confirmed**,
  and the honest recommendation is the structured arm or none.
- No arm materially better than parametric STC: the benchmark's answer is that
  the parametric baseline is adequate under these surfaces, which is a real
  finding given that the source claimed otherwise without evidence.

**Surface A at the identity link is not part of the primary** and must show no
bias for any arm; it is the null control below.

## 8. Three controls, each of which can fail

**Null control.** Surface "none", good overlap: every arm unbiased and nominal.
Any arm failing here is misimplemented and is withdrawn rather than interpreted.

**Second null control, and it is the algebraic one.** Surface A at the identity
link: section 2 says a common prognostic nonlinearity **cancels exactly**, so
parametric STC must be unbiased despite being misspecified. If it is biased
there, the cancellation is not happening in the implementation and every
attribution in the taxonomy is void. **This control is what makes the taxonomy
evidence rather than a diagram.**

**Positive control.** Surface B at poor overlap with strong modification:
parametric STC must be biased by at least three MCSEs. If the worst adversarial
surface the design can build does not break the parametric baseline, there is
nothing for flexibility to fix and the study reports that.

**Falsifier for the study's own headline.** The expected headline is that
flexible arms buy bias reduction at the cost of interval validity. Its falsifier
is the tuning-repeating resample: if that route restores nominal coverage for
BART, the cost is computational rather than inferential and the headline changes.
**That route is included precisely because it is the one that could refute the
expected result**, not as a robustness check.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reproducing the source's unsupported "especially STC" claim | Stated as corrected in the header; STC is a baseline, not a target | removed |
| Rigging the comparison with naive intervals on flexible fits | Inference route is a factor; naive intervals not among the options | removed |
| Learner tuned until the expected result appears | Tuning protocol declared before the run; the resample repeats it rather than fixing it | removed |
| Too many learners, none handled properly | Three flexible arms only; class-level claims disclaimed in the abstract | removed |
| Omitted modifiers confounded with functional form | Modifier set correct in every arm; COV-01 named as owner | removed |
| Collapsibility read as misspecification | Conditional and marginal truths both computed; the gap subtracted | removed |
| Support boundary is arbitrary | Declared before the run and its definition registered; sensitivity to it reported | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth, quadrature order, collapsibility gap | Marginal and conditional truths per surface; the gap | The definition of truth | minutes |
| **P2** surface calibration | Parameters making each adversarial surface equally severe in a declared metric, so the taxonomy compares like with like | **The grid.** Surfaces tuned to different severities produce a ranking of severities, not of methods | hours |
| **P3** learner cost and tuning | Per-fit wall clock for BART and the resampling loop; whether the tuning-repeating resample is affordable at $n_{sim}$ at all | Whether the falsifier arm exists. **If it cannot be afforded, the study cannot claim the interval failure is inferential** | hours |
| **P4** unit cost and budget | The total, computed not typed | The grid and $n_{sim}$ | hours |

**P2 is load-bearing and easy to get wrong.** Four adversarial surfaces built to
taste differ in how hard they are, and a benchmark that does not equalize
severity reports its own choices.

## 11. Cost

The largest in this batch. Dominated by the flexible arms times the inference
routes times $n_{sim}$; that product is the one OUT-11 got wrong twice by quoting
a total before measuring the unit. No total is quoted until P3 and P4, and the
sensitivity program is priced per fit set.

---

## Relationship to the rest of the queue

- **DIA-06** owns the overlap axis as a family comparison and shares the
  extrapolation mechanism; if both run, the support-split code is shared.
- **COV-01** owns modifier selection, held correct here.
- **COV-03** owns prognostic covariates, whose surface-A behavior this study
  measures under misspecification rather than under correct specification.
- **ADJ-04** owns flexible outcome surfaces and support diagnostics in
  standardization, and is where the learner set could legitimately be widened.
- **MOD-10** owns flexible interaction surfaces inside network synthesis, which
  is this question at network scale.
- **MOD-04** owns post-selection inference, which is the inference-route factor
  taken seriously as its own subject.
