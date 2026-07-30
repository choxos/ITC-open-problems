# OVL-03 design: no weights to inspect, and an aggregation that inherits its own uncertainty

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Three overlap entries precede this one and it must not repeat them. **DIA-03** scored
the weight panel as classifiers. **OVL-01** owns whether unsupported mass matters,
which depends on its alignment with modification. **OVL-02** owns calibration
feasibility and computability. **DIA-02** owns the multiset invariance.

**All four are about weighting.** This entry is about the case where there are no
weights, and the note orders it after simpler diagnostic work because **reconstructing
the target distribution is itself an unresolved source of sensitivity** — which
section 2 shows is not merely a nuisance here but a circularity.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** outcome-regression PAIC can rely on predictions at target
profiles sparsely represented or unsupported in the source, and weight-concentration
summaries do not diagnose that; general support diagnostics exist but do not aggregate
cleanly to a target-standardized marginal contrast integrated over a distribution
known only through published marginals.

**Refuting sentence:** *prediction variance rises with leverage, so the model's own
interval already widens where the design is extrapolating, and no separate diagnostic
is needed.*

**The entry answers half of that already**: prediction variance does rise with
leverage in linear and generalized linear models, **but no model-based interval
represents misspecification or nonidentification.** So the refuting sentence is true
about variance and false about the thing that matters, and the design must separate
them.

## 2. The mechanism: a well-behaved prediction, and a diagnostic that needs the same integral

**Why weights are the wrong instrument here.** A regression produces no weights, so a
positivity violation appears as a numerically well-behaved prediction. **There is
nothing to look extreme.** The diagnostic has to come from the covariate geometry or
from the fitted surface, not from the estimator's output.

**The aggregation problem, stated precisely.** Support diagnostics are per-profile
functions $s(x)$. The estimand is $\Delta(F_T) = \int \tau(x)\,dF_T(x)$, so the
relevant diagnostic is not $s$ at one profile but

$$\bar s \;=\; \int s(x)\,dF_T(x),$$

**integrated over the same $F_T$ that is itself reconstructed from published
marginals.** Three consequences:

1. **The diagnostic inherits the reconstruction uncertainty it is meant to guard
   against.** CMP-15 shows the reconstruction error lives above the second moment and
   grows with link curvature; **$\bar s$ is computed over the same reconstructed law**,
   so a diagnostic reporting adequate support may be integrating over a region the
   true target does not occupy, or missing one it does. **That is a circularity, not
   a nuisance**, and no amount of improving $s$ removes it.
2. **The right aggregation is not the mean.** $\bar s$ averages good support against
   bad, so a target with 90% well-supported mass and 10% entirely unsupported can
   report a comfortable average. **A tail functional is the correct summary**, and
   which one is a design question this study answers rather than assumes.
3. **Weighting the diagnostic by $\tau$'s variation reproduces OVL-01's finding one
   level over:** unsupported mass matters in proportion to how far the effect is
   modified there, so **$\int s(x)\,|\nabla\tau(x)|\,dF_T(x)$ should outperform
   $\bar s$.** That is a falsifiable prediction and the design's candidate
   contribution.

**Conformal and out-of-distribution scores inherit exchangeability-type assumptions
that fail precisely under the shift they are meant to detect**, which ADJ-04
establishes quantitatively, and **they deliver predictive coverage or novelty rather
than identification of a causal contrast.** They are carried in weighted or
anomaly-score form only, per the entry.

## 3. Estimand, with its true value defined

**Primary.** The target-standardized marginal log odds ratio, by quadrature over the
**true** target law at an order fixed by P1.

**Material failure** is the classifier truth: absolute error above a declared
threshold, or coverage below nominal, or failed extrapolation defined as prediction
outside the outcome's plausible range.

**The reconstructed-versus-true aggregation gap is a second estimand**: $\bar s$
computed over the reconstructed law against $\bar s$ over the true one, which
quantifies consequence 1 directly.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| source-to-target support | full; thin tails; a hole in the target | the axis |
| **alternative joint distributions sharing the same published moments** | Gaussian copula; tail-dependent; skewed | **consequence 1**, and it is the entry's own sketch |
| target profile weighting | uniform; concentrated where modification is strong | consequence 3 |
| outcome-model nonlinearity | linear; threshold | whether extrapolation is dangerous |
| effect-modification strength | moderate, strong | the multiplier |

### What the mechanism makes true, and therefore what the study cannot see

- **The entry's own counterweight is carried.** Parametric g-computation is reported
  as more precise and more accurate than MAIC particularly when overlap is poor, so
  **extrapolation is not framed as pure hazard**; the design measures when it pays and
  when it does not.
- `plot_leverage()` in the development package is **DIC point leverage from posterior
  deviance variance**, a model-fit diagnostic, not the covariate-support diagnostic
  proposed here. **The design says so rather than treating an existing function as
  partial coverage.**
- The two auditors' failure to find conformal or out-of-distribution applications to
  STC, ML-NMR or g-computation is **a negative search result rather than a verified
  absence**, and no absence is claimed.
- **No score certifies that a transported causal effect is identified**, and the whole
  battery is framed as diagnostic so a passing score is never read as certification.

## 5. Methods, including one that can win

| diagnostic | aggregated how | role |
|---|---|---|
| model prediction variance | mean and tail over $F_T$ | the refuting sentence's candidate |
| covariate distance to source | mean and tail | geometric |
| convex-hull membership | proportion of target mass outside | geometric, binary per profile |
| density ratio | tail | the closest to a weighting analogue |
| classical leverage | mean and tail | the regression's own |
| **modification-weighted support** | $\int s\,\lvert\nabla\tau\rvert\,dF_T$ | **consequence 3, the candidate contribution** |
| weighted conformal / anomaly score | tail | carried in the forms the entry permits |

**The comparator that can win is model prediction variance.** It is free, it is
already reported, and if it discriminates material failure as well as any geometric
measure the refuting sentence holds for practical purposes. Registered as such.

**Every flag is tied to a stated response** in the reporting: abstention, target
redefinition, or an explicit sensitivity model with declared bounds. **Interval
widening is not among them**, because widening without a bound or prior does not
repair nonidentification, which the entry states and this design does not soften.

## 6. Performance measures, MCSE, and $n_{sim}$

Each aggregated diagnostic scored as a classifier of material failure at the level of
a single analysis, with AUROC, calibration and decision curves, following DIA-03.

**The aggregation comparison**: mean against tail functionals, and unweighted against
modification-weighted, reported as a matrix so the two aggregation choices are
separable.

**The circularity measure, which is consequence 1**: the classifier's AUROC when
computed over the reconstructed law against over the true law. **The gap is what
reconstruction costs the diagnostic**, and it has never been measured.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** AUROC of the modification-weighted tail support measure against
material failure, computed over the **reconstructed** target law, compared with model
prediction variance.

**Decision rule.**

- Modification-weighted support materially better, and its reconstructed-law AUROC
  close to its true-law AUROC: **confirmed**, and the deliverable is that measure with
  its aggregation and its response mapping.
- Prediction variance comparable: **refuted**, and the model's own interval suffices
  for flagging even though it does not represent nonidentification.
- **The circularity gap is reported in either branch**, because it bounds what any
  diagnostic built on a reconstructed target can achieve.

## 8. Three controls, each of which can fail

**Null control.** At full support with a linear surface, every diagnostic must be at
chance for material failure, because there is none. **A diagnostic discriminating
there is discriminating noise**, which DIA-03 found for the balance statistic.

**Second null control.** With zero effect modification, consequence 3's weighting
factor vanishes and the weighted and unweighted measures must coincide exactly.
**Algebraic, and it checks the weighting is doing what it is supposed to.**

**Positive control.** A hole in the target where modification is strong: material
failure must occur at a substantial rate. If not, the design has not built the case
the entry describes.

**Falsifier for the study's own headline.** The expected headline is that support
diagnostics can be aggregated usefully. Its falsifier is consequence 1: **if the gap
between reconstructed-law and true-law AUROC is large, then every aggregated
diagnostic is limited by a reconstruction it cannot check**, and the honest
recommendation is that the flag be reported together with a reconstruction sensitivity
rather than alone.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Repeating the weighting entries | Scoped to the no-weights case; their results imported | removed |
| Extrapolation framed as pure hazard | The entry's counterweight carried; when it pays is measured | removed |
| An existing leverage plot treated as partial coverage | Identified as a model-fit diagnostic; stated | removed |
| A negative search result reported as absence | No absence claimed | removed |
| A passing score read as certification | Framed as diagnostic throughout | removed |
| Interval widening offered as a response | Excluded; responses are abstention, redefinition or a bounded sensitivity model | removed |
| Diagnostic computed over the true law an analyst lacks | Both computed; the gap is a primary outcome | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target-standardized truth per joint law | The definition of truth | hours |
| **P2** matched-moment joints | Alternative joints sharing the same published moments, imported from CMP-15's construction | **The circularity factor**; if CMP-15 has run, this is free | days |
| **P3** material threshold and failed-extrapolation definition | Both declared from the decision context before the run | Every classifier result | hours |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | hours |

## 11. Cost

Regression fits plus quadrature per diagnostic; modest. The cost is in P2, and it is
shared with CMP-15.

---

## Relationship to the rest of the queue

- **OVL-01**, **OVL-02**, **DIA-02** and **DIA-03** own the weighting side; this owns
  the regression side.
- **CMP-15** and **MOD-01** own the reconstruction whose uncertainty consequence 1
  inherits, and supply P2.
- **ADJ-04** owns weighted conformal and establishes why it degrades on the same axis.
- **MOD-02** owns adversarial surfaces, which is what makes extrapolation dangerous.
