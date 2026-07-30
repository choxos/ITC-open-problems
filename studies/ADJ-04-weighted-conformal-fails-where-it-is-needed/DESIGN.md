# ADJ-04 design: the repair for covariate shift needs the thing that is broken

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog narrows this itself, twice. **Ordinary split-conformal prediction does
not detect unsupported covariate profiles**, since an interval can keep the same
width far outside source support, and **the covariate-shift repair already
exists**: Tibshirani, Barber, Candès and Ramdas restore the guarantee by
likelihood-ratio weighting, which is the natural route with PAIC weights. So the
open work is adapting a shift-aware method, not inventing a diagnostic.

Section 2 finds that the adaptation has a circularity the entry gestures at and
does not state sharply.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no published STC or ML-NMR analysis uses BART or a
Gaussian process as the outcome surface; standardizing a fitted surface over a
target distribution with mass outside the source support is extrapolation however
flexible the learner; and BART's behavior outside the observed support is
prior-driven rather than evidential.

**Refuting sentence:** *weighted conformal prediction restores a valid coverage
statement under the transport shift, so flexible standardization can be used with
an honest interval and the support problem is solved.*

## 2. The mechanism: weighted conformal degrades exactly where support does

Weighted split-conformal replaces exchangeability with a likelihood-ratio
reweighting of the calibration scores by $r(x) = f_T(x)/f_S(x)$. The guarantee
holds, but its **effective calibration sample** is the weighted one, and by the
same identity that governs MAIC,

$$\mathrm{ESS}_{\text{cal}} \;=\; \frac{\left(\sum r_i\right)^2}{\sum r_i^2} \;=\; \frac{n_{\text{cal}}}{1 + \chi^2(F_T\|F_S)} .$$

Three consequences:

1. **The repair's precision is governed by the same chi-square divergence that
   measures the overlap failure it is repairing.** As support deteriorates, the
   weighted conformal interval is calibrated on an effective handful of points and
   becomes uselessly wide or unstable. **So it does not fail silently, which is
   good, but it cannot certify the region where certification is needed**, and the
   refuting sentence is therefore false in the regime that matters.
2. **Where support is absent, $r$ is undefined, not merely large.** No reweighting
   of source calibration points can produce a valid statement about a region
   containing none. **The honest output there is abstention**, which is OVL-01's
   subject and this design's link to it.
3. **A flexible learner's interval and a conformal interval answer different
   questions.** BART's posterior interval outside support reflects its prior;
   weighted conformal's reflects the calibration set's residuals reweighted. **Both
   are computable and only one claims frequentist coverage**, so reporting them
   together makes the prior-driven component visible rather than smoothed over,
   which is what the entry asks for.

**Fitted interactions are predictive structure, not identified effect
modification**, and the entry says so; the design forbids reading them causally and
does not report them as modifier estimates.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio, by quadrature at an
order fixed by P1.

**Two derived estimands.** **Support-diagnostic operating characteristics**:
sensitivity and false-positive rate for unsupported target profiles, where
"unsupported" is defined by the generating law and known. And **conditional
coverage of the prediction interval by target region**, since marginal coverage can
be met while the unsupported region is badly covered, and marginal coverage is what
a conformal guarantee provides.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| modifier overlap | 0.9 down to 0.2 | the entry's own range |
| outcome-surface nonlinearity | linear; moderate; threshold | where flexibility should pay |
| interaction strength | 2 levels | the multiplier |
| density-ratio estimation error | none; moderate | **section 2 consequence 1 assumes $r$ is known; in practice it is estimated**, and the repair inherits that error |
| target mass outside source support | 0%, 5%, 20% | consequence 2, where $r$ is undefined |

### What the mechanism makes true, and therefore what the study cannot see

- **One flexible learner, not three.** The note says to narrow the BART,
  Gaussian-process and weighted-conformal components to one primary comparison.
  **BART is chosen** because the entry cites direct evidence about its
  extrapolation behavior, so the prediction in section 2 consequence 3 is
  checkable against a published result. Gaussian processes are named and deferred;
  the entry notes their cost collides with ML-NMR's integration burden anyway.
- The density ratio is estimable in the base arm. **Where support is absent it is
  not**, and that is a factor level rather than an assumption.
- Conformal guarantees are marginal by construction. **Conditional coverage is not
  claimed by the method and is measured here as a property, not as a failure of the
  guarantee.**
- Covariates are continuous and low-dimensional so support is well defined; in high
  dimension the notion changes and nothing here transfers.

## 5. Methods, including one that can win

| method | role |
|---|---|
| parametric STC | the baseline |
| ML-NMR | the integrating baseline |
| **BART standardization** | the flexible arm |
| BART + weighted conformal | the shift-aware interval |
| BART + ordinary split conformal | included to show it does **not** detect unsupported profiles, which the entry states and nobody has demonstrated |
| support diagnostics: density ratio, convex-hull distance, leverage | the detection question |

**The comparator that can win is parametric STC.** If it matches BART on bias while
retaining nominal coverage across the overlap range, flexibility buys nothing here
and the adaptation is unnecessary. Registered as such, and MOD-02 makes the same
registration for the same reason.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, RMSE and interval coverage of the target contrast per method per cell, with
MCSE; **coverage decomposed by target region**, supported and unsupported, since
that split is where section 2 consequence 1 lives.

**Effective calibration sample size along the overlap axis**, reported beside
weighted conformal's coverage. **That pairing is the study's most portable output**:
it shows the repair's precision collapsing on the same axis as the problem.

**Support diagnostics scored as classifiers** of the known unsupported profiles,
with sensitivity and false-positive rate, following DIA-03.

$n_{sim} = 2000$ per cell; BART's own posterior sampling is inside each replicate
and its cost is measured in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Weighted conformal's interval width and conditional coverage
in the unsupported region, across the overlap axis.

**Decision rule.**

- Width growing and conditional coverage failing as overlap falls, with effective
  calibration sample size tracking it: **section 2 is confirmed**, and the
  deliverable is that weighted conformal must be reported with its effective
  calibration size and cannot substitute for abstention.
- Coverage holding with usable width throughout: the refuting sentence holds and
  flexible standardization has an honest interval.
- **Ordinary split conformal's failure to detect unsupported profiles is reported
  in either branch**, because the entry asserts it and no one has shown it.

## 8. Three controls, each of which can fail

**Null control.** At full overlap, $r \equiv 1$, weighted and ordinary conformal
coincide exactly and both must be nominal. **Algebraic, and it validates the
weighting implementation before it is used to show failure.**

**Second null control.** With a linear surface and no unsupported mass, BART and
parametric STC must agree to Monte Carlo error. **A difference there is a fitting
artifact, not a flexibility gain.**

**Positive control.** At 20% unsupported target mass, BART's posterior interval
must differ materially from weighted conformal's, since one is prior-driven and the
other residual-driven. **If they agree, the prior is not doing what the cited
result says it does**, and section 2 consequence 3 fails.

**Falsifier for the study's own headline.** The expected headline is that weighted
conformal cannot certify the unsupported region. Its falsifier is the estimated
density-ratio arm: if the repair works well with a *known* ratio and fails only
with an estimated one, **the problem is density-ratio estimation rather than
support**, which is a different and more fixable diagnosis.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Inventing a diagnostic the literature already has | Weighted conformal adapted, not derived | removed |
| Three flexible components at once | One learner, per the note; the others named and deferred | removed |
| Marginal coverage reported as if conditional | Coverage decomposed by region | removed |
| Fitted interactions read as effect modification | Forbidden and not reported as modifier estimates | removed |
| Density ratio assumed known | Estimation error is a factor and the falsifier | removed |
| High-dimensional support | Out of scope, stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | hours |
| **P2** unsupported-mass construction | Target laws with a declared share of mass outside source support, verified | **The grid**; and whether $r$ is undefined rather than merely large there | days |
| **P3** BART tuning protocol | A fixed protocol declared before any result | Whether the flexible arm is fairly represented | hours |
| **P4** unit cost | Per-replicate cost with BART posterior sampling inside; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

BART inside each replicate at 2000 replicates across a five-factor grid. The
learner is the multiplier and it is measured, not assumed cheap.

---

## Relationship to the rest of the queue

- **OVL-01** owns abstention, which section 2 consequence 2 says is the honest
  output where $r$ is undefined.
- **MOD-02** owns adversarial surfaces and flexible learners in PAIC generally;
  this design is the standardization-and-interval half and the two share a
  generator.
- **DIA-06** owns family failure signatures on the same divergence axis.
- **OVL-02** and **DIA-02** own the support diagnostics scored here.
