# Protocol: what target-moment uncertainty costs when the scale is non-collapsible

**Target problem.** EST-07 *Reported target moments are treated as known constants*.
Successor to MIS-03, which answered the same question under an identity link.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Registration status: NOT YET REGISTERED.** The design is in `DESIGN.md`, the code
and all five probes are complete, and this document is the draft that critique acts
on. It becomes the registration when critique converges, not before.

**Provenance, and why it is stronger here than in the sibling study.** CMP-14 spent
thirteen rounds of critique and roughly a third of its findings were one defect: a
number typed into the document rather than read from the code. **Every number below
is generated from `results/registered-design.json` by `review/emit-protocol.py`.**
None is typed, so the class of defect that dominated CMP-14 cannot occur; what
remains possible is a number that is generated correctly and *means* something other
than the sentence around it claims, which is what critique is for.

---

## 1. The claim, restated so it can be false

The catalog asserts that the sampling-error component of target-moment uncertainty
is **solved outside ITC** and needs only porting, citing an entropy-balancing
variance estimator and a perturbation interval.

**Proposition under test:** those published results transfer to PAIC as a porting
exercise, and the residual unaddressed component is reconstructed-correlation
uncertainty.

**Refuting sentence:** *on a non-collapsible scale the target marginal effect is not
a function of the reported moments at all, so no variance estimator indexed by those
moments can be correct, and the failure is one of identification rather than of
variance.*

## 2. What the probes already establish, before any replicate

Five probes ran before this document existed. Three of their results bear directly
on the proposition.

**The ported gradient is wrong on a curved link, and its direction differs by link.**
Every published target-summary variance propagates the gradient of the *estimator*
with respect to the reported moments. What the variance of the *estimand* requires is
the gradient of the estimand. Under the identity link these coincide and both equal
$\beta_{EM}$; under a curved link they cannot.

| link | worst relative gradient gap | variance ratio | direction of the error |
|---|---:|---|---|
| `logit` | 0.043 | 0.9886 to 1.074 | **mixed** |
| `cloglog` | 0.0569 | 1.078 to 1.174 | **anti-conservative** |

**No part of the design predicted that the direction differs by link**, and it is the
finding with the clearest practical consequence: the same porting claim covers both
scales, but an analyst reading a logit MAIC would see intervals too narrow while one
reading a Weibull MAIC would see them too wide.

**The identity-link case behaves as it must**, which is what makes the above evidence
about curvature rather than about the implementation. The gap between estimator and
estimand gradient falls by a factor of 6.7 across $n_S$ = 500 to
8000, reaching within one Monte Carlo standard error of zero. A wrong
implementation produces a gap that does not move.

## 3. Estimand

**Primary.** The target-superpopulation marginal effect,
$\Delta(F_T) = g(\int \mu_1 dF_T) - g(\int \mu_0 dF_T)$, a functional of the target
covariate **law** rather than of its moments.

**True value.** By Gauss-Hermite quadrature at order **48**, which is
probe P1's output and is not defaulted. The order is forced by the
`mixed` covariate shape on the `cloglog`
link; a thresholded binary covariate is a step function and Gauss-Hermite converges
on it slowly, while every continuous law is stable by order 8 to 16.

**The integral reduces to one dimension exactly where the covariate law is normal.**
Each arm mean integrates a function of a single linear combination of $x$, which is
normal when $x$ is, so the product rule's $\text{order}^p$ collapses to
$\text{order}$: 5,308,416 nodes to 48 at four covariates, agreeing to 4.1e-15.

**The finite-target contrast is the second estimand and the pair is the point.** Both
are computed on every replicate. A design carrying only one cannot distinguish "the
interval is too narrow" from "the interval is for a different estimand".

## 4. Design

| factor | levels |
|---|---|
| link | identity, logit, cloglog |
| target size $n_T$ | 100, 300, 1000 |
| source size $n_S$ | 500, 2000, 8000 |
| alignment $k$ | 0, 0.25, 0.5, 1 |
| covariate shape | mvnorm, lognormal, mixed |
| assumed correlation | true, borrowed, independence |
| modifier span | inside, outside |

Held fixed: 3 covariates, overlap at a standardized mean difference
of 0.4, anchored throughout.

**The source size is a factor because probe P2 found that pinning it made the primary
arm undetectable.** The omitted variance is set by $n_T$ and the retained variance by
$n_S$, so with $n_S$ fixed the source term dominates. The omitted-variance share by
link, over the realized grid:

| link | min | median | max |
|---|---:|---:|---:|
| `identity` | 5.22e-24 | 0.176 | 0.714 |
| `logit` | 0.00074 | 0.0345 | 0.298 |
| `cloglog` | 0.00616 | 0.077 | 0.494 |

**176 of 288 realized cells clear a
0.04 floor** and are run; the rest are dropped rather than run,
because a cell whose effect cannot be distinguished from zero at 2000
replicates consumes budget and returns nothing. The floor is derived: a coverage
Monte Carlo SE of 0.005 makes 0.01 the smallest coverage shift
worth claiming, which needs roughly a 0.04 variance share.

**MAIC matches one moment for a binary covariate, not two.** With $x$ binary
$x^2 = x$ identically, so a balancing function that always forms two columns per
covariate is rank deficient and the sandwich Jacobian is singular. That is a fact
about MAIC rather than about this implementation, and it is why the `mixed` arm
matches five moments where the others match six.

## 5. Methods

`maic_fixed` (status quo), `maic_entropy` (the entropy-balancing port),
`maic_perturb` (the perturbation port), `maic_oracle` (fixed moments with the true
correlation supplied), `stc`, and ML-NMR.

All four MAIC variants share one weight fit and one sandwich, so they differ in the
variance they report and in nothing else, which makes the paired comparison a
comparison of intervals.

**The comparator that can win is `maic_entropy`.** If it restores nominal coverage
across the grid on the logit scale, the catalog's porting claim is supported, this
study's second prediction is wrong, and the study says so.

## 6. Replicates, error and cost

**2000 replicates per cell**, set so the coverage Monte Carlo SE at 0.95 is
at most 0.005. Common random numbers across
corr_assumed, variance_method, so **Monte Carlo error is clustered on the replicate block**.

**Cost: 18.6 core-hours** for the MAIC and STC arms at
`N_PERTURB = 50`, against **102.6** at the
typed 200, a **81.9%** saving. The perturbation interval is
88% to 94% of the total, which is the line item the design named as the one a
sibling study called cheap without measuring.

**`N_PERTURB` is derived, not chosen.** At $B = 50$ the
90th-percentile resampling error is inside the across-replicate spread of the standard
error itself (0.1774), so more resamples buy nothing a coverage number can
see.

**ML-NMR is not in that total** and no figure covering it is quoted until its per-fit
cost is measured.

## 7. What this cannot settle

- **Nothing here is registered yet**, per the status note above.
- The aliasing of curvature with overlap is disclosed, not removed.
- Weibull PH throughout, so nothing separates moment uncertainty from
  non-proportionality; that is OUT-11's subject.
- Reporting error, rounding and inclusion-criteria drift are not simulated. The
  catalog classifies them as estimand ambiguity and transport bias, and this study
  accepts that classification rather than testing it.
- **The quadrature and the normal reduction condition every result on a covariate
  law.** The `mixed` and `lognormal` arms vary the shape; nothing here measures a
  covariate law outside those three.
