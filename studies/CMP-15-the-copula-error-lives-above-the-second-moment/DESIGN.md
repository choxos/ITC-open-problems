# CMP-15 design: calibrating the correlation cannot fix an error that is not in the correlation

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note narrows this to the copula-misspecification experiment and
defers posterior reconstruction uncertainty and robust partial identification.
**That narrowing is what makes the study decisive**, and section 2 explains why the
upstream fix does not reach the remaining problem.

`multinma` 0.6.0 adjusts the correlation matrix used to generate integration points
to the underlying Gaussian copula, so output correlations better match the
requested inputs. **That is a real fix to a real problem and this design adopts it
rather than re-deriving it.** What it cannot fix is the subject here.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a Gaussian copula imposes symmetric, tail-independent
dependence which may be wrong however well the correlation is calibrated; errors in
dependence and tails propagate through a nonlinear inverse link into standardized
outcomes with no target IPD to check against; and reconstruction uncertainty is not
propagated in any implementation.

**Refuting sentence:** *once the correlation is calibrated, the residual copula
error is a higher-order effect too small to move a standardized contrast at
realistic link curvatures.*

## 2. The mechanism: the correlation is the second moment, and the error is above it

MOD-01 establishes that for a curved link the target marginal contrast depends on
the covariate law, to second order, only through the variance of the prognostic
index $\gamma^\top\Sigma_T\gamma$. **Calibrating the correlation matrix fixes
exactly that quantity.** So the upstream fix is complete at second order, and any
residual copula error must live above it.

Expanding further, the third-order term involves the joint third moments, and for a
copula those are governed by **asymmetry**; the fourth involves tail behavior,
governed by **tail dependence**. A Gaussian copula sets both to their symmetric,
tail-independent values. Three consequences:

1. **The residual error grows with link curvature**, since the higher-order terms
   are weighted by higher derivatives of the inverse link. At an identity link it
   is exactly zero, which is the design's null control.
2. **It grows with how far the integration reaches into the tails**, which is set
   by the quasi-Monte Carlo point set and by the covariate marginals' spread.
   **So the error interacts with the integration order**, and an analysis using
   more integration points is not thereby more accurate: it is sampling more of a
   distribution that is wrong in the tails.
3. **Matching the rank correlation does not help either**, because rank correlation
   is also a second-order-like summary that many copulas share. **So the design
   holds reported margins *and* rank correlation fixed and varies only the copula
   family**, which isolates exactly the residual.

**That last point is the design.** Any comparison that let the correlation move
would be measuring the thing the upstream fix already handles.

**A separate mechanical problem the entry names:** the latent-to-observed
correlation transformation has a closed form only for special margin combinations,
so mixed and discrete margins need numerical inversion that component
implementations currently approximate, with a warning. **The approximation's error
is measurable** and is a second, cheap outcome here.

## 3. Estimand, with its true value defined

**Primary.** The target-standardized marginal contrast, by quadrature over the
**true** joint law at an order fixed by P1.

**Truth is defined against the generating copula**, never against a
well-reconstructed one, since the gap between them is the question.

**The envelope is a second estimand:** the range of the contrast over a declared
family of joints consistent with the reported margins and rank correlation, with
**containment of the true estimand** as its performance measure. An envelope that
always contains by being wide is not a result, so width is reported beside
containment.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| true copula | Gaussian; Clayton (lower tail); Gumbel (upper tail); a skewed vine | the residual, with margins and rank correlation held fixed |
| outcome-model nonlinearity | identity; logit; log hazard | **section 2 consequence 1**; identity is the null control |
| integration points | 64, 256, 1024 | **consequence 2**, and the surprising interaction |
| margin types | all continuous; mixed continuous and binary; discrete | the numerical-inversion approximation |
| covariate dimension | 3, 6 | the copula's degrees of freedom grow quickly |
| effect-modification strength | 2 levels | the multiplier on any reconstruction error |

**Margins and rank correlation are held numerically equal across copula levels**,
verified by P2, which is the design's central control.

### What the mechanism makes true, and therefore what the study cannot see

- **Posterior reconstruction uncertainty is deferred**, per the note. COV-12 owns
  propagating reconstruction into the posterior and this design treats the
  reconstruction as fixed, which is current practice.
- **Robust partial identification is carried only as the envelope arm**, not as a
  full treatment; the entry's robust-moment-class proposal is named and deferred.
- The correlation calibration is adopted from upstream and assumed correct; **P3
  verifies it on this design's margins** rather than trusting the release note.
- There is no target IPD to validate against, by construction. That is the
  problem's defining feature and the study inherits it: **every result is about the
  gap between two assumed joints, not about reality.**

## 5. Methods, including one that can win

| method | role |
|---|---|
| Gaussian reconstruction with calibrated correlation | current best practice |
| Gaussian without calibration | included to show the upstream fix works, and to size it |
| flexible copula, correctly specified | the ceiling |
| flexible copula, misspecified family | what an analyst who reaches for a vine actually gets |
| **sensitivity envelope over dependence specifications** | the deliverable when nothing can be checked |

**The comparator that can win is calibrated Gaussian reconstruction.** If it is
within Monte Carlo error of the correctly specified copula across the grid, the
refuting sentence holds, the upstream fix is sufficient, and the recommendation is
to stop worrying about copula family. Registered as such, and section 2 gives it a
real chance at low curvature.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and RMSE of the standardized contrast per method per cell, with
MCSE; **envelope containment and width**; **the numerical-inversion error** on
mixed and discrete margins, reported as the discrepancy between requested and
realized observed correlation.

**The registered mechanism check:** residual copula error regressed on link
curvature, with the integration-order interaction included. **Section 2 consequence
2 predicts a positive interaction**, which is counter-intuitive enough that finding
it absent would be informative.

$n_{sim} = 2000$ per cell; the flexible-copula arms add fitting cost, priced in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of calibrated Gaussian reconstruction against the
correctly specified copula, on the log-hazard scale with a tail-dependent truth, at
the highest integration order.

**Decision rule.**

- Bias exceeding the decision threshold: the copula family matters beyond the
  correlation, and the deliverable is the envelope plus a recommendation to report
  it.
- Bias below threshold across the grid: **refuted**, the upstream calibration is
  sufficient, and that is a clean and useful negative result.
- Bias present and **growing with integration order**: consequence 2 is confirmed
  in its most counter-intuitive form, and the deliverable includes the warning that
  more integration points do not buy accuracy against a wrong dependence structure.

## 8. Three controls, each of which can fail

**Null control.** At an identity link with linear modification, section 2 makes the
copula **exactly irrelevant**: every reconstruction must agree to Monte Carlo error.
**This is algebraic and it is the check that the harness is not leaking dependence
into a place it cannot reach.**

**Second null control.** With one covariate there is no copula, so every arm must
coincide identically. Cheap, exact, and it catches a class of implementation error.

**Positive control.** Log-hazard scale, strongly tail-dependent truth, high
dimension: calibrated Gaussian must be biased by at least three MCSEs. If it is
not, the residual is unreachable and the study reports that the upstream fix
suffices at attainable dependence structures.

**Falsifier for the study's own headline.** The expected headline is that copula
family matters. Its falsifier is the misspecified-flexible arm: **if reaching for a
vine and getting the wrong one is worse than staying Gaussian, then the
recommendation is not "use a flexible copula" but "report an envelope",** which is
a different deliverable and the design must be able to reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Re-deriving the upstream correlation calibration | Adopted; verified in P3; its size reported by carrying the uncalibrated arm | removed |
| Correlation allowed to move between copula arms | Margins and rank correlation held numerically equal; P2 verifies | removed |
| An envelope that contains by being wide | Width reported beside containment | removed |
| Flexible copula assumed correctly specified | Misspecified arm carried, and it is the falsifier | removed |
| Reconstruction uncertainty conflated with family error | Deferred per the note; COV-12 named | disclosed |
| No target IPD to validate against | Stated as the problem's defining feature | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The true standardized contrast under each copula, stable to $10^{-4}$ | The definition of truth | hours |
| **P2** matched-margin construction | Copulas with numerically equal margins and rank correlation across families | **The design's central control**; without it every comparison is confounded | days |
| **P3** calibration verification | That the upstream correlation adjustment achieves the requested correlation on these margins, including mixed and discrete | Whether the base arm is what it claims | hours |
| **P4** unit cost | Per-replicate cost including flexible-copula fitting; total computed not typed | The grid | hours |

## 11. Cost

Integration-dominated, and the highest integration order times the largest
dimension is the binding cell. **SFW-06's scaling map bounds it.**

---

## Relationship to the rest of the queue

- **MOD-01** establishes the second-order result this design builds above, and
  shares the prognostic-index scalar.
- **COV-12** owns marginals that were never reported and the propagation this
  design defers.
- **CMP-11**'s imputation arm needs a reconstructed joint and would import this
  study's envelope.
- **QBA-20** requires a joint target law including omitted covariates and names
  this study as a prerequisite.
- **SFW-06** and **CMU-01** own the integration cost that consequence 2 interacts
  with.
