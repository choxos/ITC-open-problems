# EST-07 design: target-moment uncertainty where the linear theory stops working

**Status: design. Not registered.** The probes in section 10 have not been run.
Written against `studies/DESIGN-STANDARD.md`.

**This study starts where MIS-03 stopped.** MIS-03 asked what conditioning on
published target moments costs interval coverage and answered it analytically:
the omitted variance is $(1-2k)\,\mathrm{Var}_T(\tau)/n_T$ to first order, where
$k$ measures how far the target trial's own effect is modified by the same
covariates as the source trial's. The sign is set by $k$, which the usual inputs
do not identify, and the two corrections an analyst can actually deploy add only
the positive term, so they beat doing nothing only when $k < 1/4$.

That result is derived and measured under an identity link with an additive
effect, where the marginal and conditional effects coincide. **Every outcome type
MAIC is actually used for violates that.** This study is about what happens when
it does.

---

## 1. The claim, restated as something that can be false

The catalog entry bundles four sources of "target moment uncertainty" and its own
statement already separates them: only sampling error in the reported moments is
variance; reconstructed correlations are model uncertainty, inclusion-criteria
ambiguity is estimand ambiguity, and secular change is transport bias. It then
asserts that the sampling-error component is **solved outside ITC** and needs
only porting, citing Sheng, Sun and Huang (arXiv:2603.02474) for an
entropy-balancing variance estimator and Chen, Chen and Yu
([doi:10.1002/sim.70358](https://doi.org/10.1002/sim.70358)) for perturbation
intervals.

**Proposition under test:** the published target-summary variance results
transfer to PAIC as a porting exercise, and the residual unaddressed component is
reconstructed-correlation uncertainty.

**Refuting sentence:** *on a non-collapsible scale the target marginal effect is
not a function of the reported moments at all, so no variance estimator indexed
by those moments can be correct, and the failure is one of identification rather
than of variance.*

The study is powered to detect the refutation. That is the point of it: MIS-03
already established the affirmative case under the conditions where the linear
theory holds, so a study that could only confirm would add nothing.

## 2. The mechanism, algebraically

Write the target marginal estimand as a functional of the target covariate law
$F_T$, not of its moments:

$$\Delta(F_T) \;=\; g\!\left(\int \mu_1(x)\,dF_T(x)\right) - g\!\left(\int \mu_0(x)\,dF_T(x)\right)$$

for a link $g$ and arm-specific conditional means $\mu_a$.

**Identity link, additive effect (MIS-03's case).** $g$ is the identity and
$\mu_1 - \mu_0 = \tau(x)$ is linear in $x$, so

$$\Delta(F_T) = \int \tau(x)\,dF_T(x) = \tau_0 + \beta_{EM}^\top \bar{x}_T .$$

The estimand depends on $F_T$ **only through $\bar x_T$**. The reported moment is
therefore a sufficient input, the delta method applies with derivative exactly
$\beta_{EM}$, and MIS-03's $(1-2k)\mathrm{Var}_T(\tau)/n_T$ follows. Matching
means is not an approximation; it is exact.

**Non-collapsible link.** $g$ is $\mathrm{logit}$ or a log hazard, so the integral
sits inside a nonlinear function and

$$\Delta(F_T) = \mathrm{logit}\!\int \mathrm{expit}\{\eta_0(x)+\tau(x)\}dF_T - \mathrm{logit}\!\int \mathrm{expit}\{\eta_0(x)\}dF_T$$

which depends on **every moment of $F_T$**, not the first two. Expanding to second
order about $\bar x_T$ introduces a term in $\mathrm{Var}_T(x)$ multiplied by the
curvature of $\mathrm{expit}$, and at third order the skewness, each weighted by
derivatives that do not vanish. Three consequences follow, and they are the
study's predictions before anything is simulated:

1. **Two matched moments do not determine the estimand.** There is a residual
   bias term set by the unmatched shape of $F_T$, present even with $n_T =
   \infty$ and moments reported exactly. This is not variance and no variance
   estimator can address it.
2. **The derivative with respect to the reported moments picks up a term with no
   linear analogue.** $\partial\Delta/\partial\bar x_T \neq \beta_{EM}$; it
   carries the curvature-weighted contribution, so a variance estimator derived
   under a collapsible estimand plugs in the wrong gradient.
3. **The joint covariance of the covariates enters at first order.** Under the
   identity link with linear $\tau$, the estimand is free of
   $\mathrm{Cov}_T(x)$; under a curved link it is not. **This is why
   reconstructed-correlation uncertainty is invisible in MIS-03 and expected to
   dominate here**, and it makes the catalog's ordering of the four components
   testable rather than asserted.

**What the algebra predicts:** the sampling-error component behaves as MIS-03
describes plus a curvature correction, while a *new* term appears which is a bias
rather than a variance and which grows with the curvature of the link, the
dispersion of the linear predictor, and the discrepancy between the assumed and
true target correlation.

**Prediction 2 is now measured rather than argued**, before any replicate has run,
because the gradient is computed from the estimand functional by central
differences instead of from a per-link derivation. `R/02-gradient.R` returns both
the gradient and its distance from $\beta_{EM}$, so a collapsible derivation's
error is a number: **0.189 on logit and 0.337 on cloglog**, against a $\beta_{EM}$
of 0.6, with a dispersion gradient of **0.101 and 0.201** that a collapsible
derivation omits entirely. The step size is checked by halving, which moves the
gradient by 8.6e-09; a central difference that has not converged looks exactly
like one that has, and that is the failure this study cannot afford in the
quantity its second prediction is about.

If prediction 3 fails, the catalog's claim that correlations are "the genuinely
unaddressed component" is what is wrong, and that is a reportable result.

## 3. Estimand, with its true value defined

**Primary estimand.** The target-superpopulation marginal log odds ratio,
$\Delta(F_T)$ as above, in the superpopulation from which the target trial
sampled.

**True value.** Not available in closed form. Computed by Gauss-Hermite
quadrature over the true target covariate law at an order fixed by probe P1,
using the true $\eta_0$ and $\tau$. The quadrature order is a registered
constant and its error is bounded by P1 rather than assumed small; OUT-11's
integration order moved a primary contrast and was only caught because it was
measured.

**The finite-target contrast is the second estimand, and the pair is the point.**
$\Delta(\hat F_T)$, in the realized target sample, is a different quantity, and
under it the reported moments carry no sampling error by construction, so the
omission is exactly zero. Both are computed on every replicate. **A design that
carries only one cannot distinguish "the interval is too narrow" from "the
interval is for a different estimand", which is the distinction the catalog entry
itself draws and which no PAIC paper reports.**

## 4. Data-generating mechanism, and what it makes invisible

Anchored indirect comparison, standard two-trial PAIC geometry: source trial with
IPD on treatments A and C, target trial reporting aggregate summaries on B and C.

### Factors

| factor | levels | why |
|---|---|---|
| outcome scale | binary logit; time-to-event Weibull PH | the two non-collapsible cases MAIC is used for; both are absent from MIS-03 |
| target size $n_T$ | 100, 300, 1000 | sampling error in reported moments scales $1/n_T$ |
| source size $n_S$ | **500, 2000, 8000** | Pinning it at 500 was an error probe P2 caught: the omitted variance is set by $n_T$ and the *retained* variance by $n_S$, so with $n_S$ fixed the source term dominates and the primary arm sits at **2.6%** of total variance, below the floor at which 2000 replicates can resolve anything. Measured on logit at $n_T = 100$, $k = 0$: 2.6%, 9.5%, 29.8%, 50.9% at $n_S$ = 500, 2000, 8000, 20000 |
| alignment $k$ | 0, 0.25, 0.5, 1.0 | MIS-03's parameter; 0.25 is its registered cancellation point, and it had **no interior $k$** to test with, which is exactly what left its recommendation silent between 1/4 and 1/2 |
| covariate shape | multivariate normal; lognormal (skew); mixed binary and normal | non-normality is untested in MIS-03 and is the assumption its correction is derived under |
| assumed correlation | true; borrowed-from-source; independence | the reconstructed-correlation component, and `cpaic` borrows exactly this way |
| modifier span | modifiers inside the matched moment set; one modifier outside it | MIS-03 has effect modification exactly in the span of matched moments, so it is a variance result under correct identification and says nothing about bias |

Fully crossed on the first four within each outcome scale; covariate shape,
assumed correlation and modifier span are crossed with $k$ and $n_T$ at the
middle level of the others, to keep the grid from growing without adding
information. Exact cell count is fixed by probe P2 and is a registered constant.

**Held fixed:** three covariates, one of them the primary modifier; source and
target overlap set to the moderate level of the Phillippo et al. 2020 grid so the
result is comparable to the published benchmark; anchored comparison throughout;
no missing modifiers except in the `modifier span` arm.

### What the mechanism makes true, and therefore what the study cannot see

- Conditional constancy holds by construction except where `modifier span`
  switches it off, so this is a study of variance and of one named bias, not of
  transitivity failure generally.
- The target moments and the target treatment effect come from the same trial.
  MIS-03 flagged that as the common case but not the only one; it stays fixed
  here so that this study's added factors are not confounded with it.
- Reported moments are unbiased estimates of the target law's moments. Reporting
  error, rounding and inclusion-criteria drift are **not** simulated; the catalog
  entry classifies them as estimand ambiguity and transport bias rather than
  sampling error and this study accepts that classification rather than testing
  it.
- The Weibull arm has proportional hazards, so nothing here separates
  moment uncertainty from non-proportionality. That is OUT-11's subject and the
  two must not be confounded.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| MAIC, fixed moments | method-of-moments weights, robust sandwich, target moments as constants | status quo, the thing under test |
| MAIC, entropy-balancing variance | the Sheng, Sun and Huang asymptotic variance with the target-summary term | the port the catalog says is all that is needed |
| MAIC, perturbation interval | Chen, Chen and Yu resampling | the second published port, different route to the same target |
| MAIC, oracle correlation | fixed moments but the true target correlation supplied | isolates the correlation component from the moment component |
| STC | conditional outcome model centered on target means, marginalized by simulation | different failure mode; the catalog lists it and MIS-03 omitted it |
| ML-NMR | `multinma`, integration over the assumed target law | the only method whose *inputs* include the correlation matrix explicitly |

**The comparator that can win is the entropy-balancing variance estimator.** If
it restores nominal coverage on the logit scale across the grid, the catalog is
right that this is a porting exercise, section 2's prediction 2 is wrong, and the
study says so. That is the outcome that would most weaken the expected headline
and it is registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Per cell: bias against the superpopulation estimand and against the
finite-target estimand separately; empirical SD; mean estimated SE; the ratio of
the two; 95% interval coverage and its two-sided departure from nominal; interval
width; convergence rate.

**Every measure carries an MCSE.** Coverage MCSE is
$\sqrt{\hat c(1-\hat c)/n_{sim}}$. The variance-ratio MCSE is obtained by the
nonparametric bootstrap over replicates rather than a delta-method
approximation, because it is a ratio of two quantities estimated on the same
replicates.

**Common random numbers across the assumed-correlation arm and the
fixed-versus-corrected variance arms**, since those differ only in an analysis
choice applied to identical data. **MCSE is therefore clustered on the replicate
block**, which is the correction OUT-11 needed and did not have until it was
found.

$n_{sim}$ is set so the coverage MCSE is at most 0.005 at $c = 0.95$, giving
$n_{sim} = 1900$, rounded to **2000 per cell**. The target is 0.005 because the
effects MIS-03 measured span 92.1% to 96.2% and a 0.005 MCSE resolves that range
into distinguishable levels.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the 95% interval for the target-superpopulation
marginal log odds ratio, by method, in the binary arm, at $k = 0.25$ and $k =
0.5$, under the borrowed-correlation setting. That is the cell where section 2
predicts the published ports fail and where MIS-03 had nothing to say.

**Decision rule.**

- If the entropy-balancing and perturbation intervals both reach 93.5% to 96.5%
  in every primary cell, the catalog's porting claim is **supported** and
  prediction 2 is withdrawn.
- If either falls outside that band in a majority of primary cells while its
  oracle-correlation counterpart stays inside, the failure is attributed to
  **correlation misspecification** and the catalog's ordering of the four
  components is supported.
- If both fall outside in a majority of primary cells and the oracle-correlation
  arm does too, the failure is attributed to **non-collapsibility** and the
  catalog's porting claim is refuted.
- Any other pattern is reported as unresolved, with the cells named.

**Two-sided.** Overcoverage at 98% is a failure of the same rule as undercoverage
at 90%. CMP-14 registered this one-sided and counted 76 over-covering scenarios
as successes for two rounds.

**Near misses are reported as near misses.** CMP-13 missed its refutation
threshold at 47% against 50% and reported it rather than moving the threshold.

## 8. Three controls, each of which can fail

**Null control.** With no effect modification, $\beta_{EM} = 0$, section 2 makes
the omitted variance **exactly zero at every $n_T$ and on every scale**, because
the estimand no longer depends on $F_T$. All methods must be nominal and the
fixed-moment interval must be no narrower than the corrected ones by more than
Monte Carlo error. *This control is where MIS-03's registered analysis died:* its
Wald sandwich undercovered by up to 7 points at poor overlap in exactly these
cells, which is a source-variance failure and not a target-moment one. Overlap is
therefore held at moderate here, and if the control still fails the study stops
and reports a source-variance problem rather than proceeding to the primary.

**Positive control.** At $n_T = 100$, $k = 0$ and maximal effect modification,
the fixed-moment interval must undercover by at least 3 points. If it does not,
the design has no signal to detect and no comparison downstream is
interpretable.

**Falsifier for the study's own headline.** The expected headline is that
non-collapsibility breaks the ports. Its falsifier is the identity-link arm run
at the same settings: there the ports must succeed. If they fail there too, the
failure is in the implementation or the geometry, not in collapsibility, and the
headline is withdrawn. **This arm is not decoration; it is the only thing
separating "curvature breaks it" from "we ported it wrong".**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| The correction is measured under the assumption it is derived from | Non-normal covariate arm added | removed for skew and mixed types; still normal-family within each |
| $k$ is uninterpretable outside MIS-03's proportional construction | Modifier-span arm makes the source and target modifier sets differ in support, not just in scale | partly removed; modifier sets differing in *direction* remain untested |
| Coverage differences attributed to variance are really bias | Both estimands computed per replicate; bias against each reported separately | removed |
| The port is evaluated against an implementation I wrote | Both published estimators implemented from their papers; agreement with the identity-link closed form checked in P3 | disclosed: no reference implementation exists to check against |
| Non-collapsibility and non-proportional hazards confounded in the survival arm | Weibull PH throughout | removed by construction; the interaction with NPH is out of scope and named |
| Curvature and overlap both grow with the linear predictor's spread | Overlap held fixed; spread varied only through the covariate-shape arm | disclosed, not removed |

**Design choices made after seeing a number**, each with the number that caused
it. This table is the reason an exploratory precursor is interpretable; CMP-14's
eleven-row version is the model.

| after | what changed | the number |
|---|---|---|
| **P1** | Quadrature order registered at **48**, not the 16 or 32 an eye would have picked | The `mixed` covariate arm needs 48 on `cloglog` and 32 on `logit` to reach $10^{-4}$, against 8 to 16 for every continuous law. A thresholded binary covariate is a step function and Gauss-Hermite converges on it slowly. At order 16 the `mixed`/`cloglog` cell is still 4.8e-4 from its own reference, five times the tolerance |
| **P1** | No arm dropped | Every link and shape reached the tolerance at some order, so the lognormal arm survives. Had it not, section 10 required dropping it |
| **gradient check** | Prediction 2 confirmed, and strengthened: **non-modifier covariates acquire a nonzero gradient** on a curved link | Under the identity link $\partial\Delta/\partial\bar x_T$ is $\beta_{EM}$ to 1.5e-12 and $\partial\Delta/\partial s_T$ is exactly 0. Under logit the mean-gradient is $(0.411, -0.041, -0.027)$ against $\beta_{EM} = (0.6, 0, 0)$, a gap of **0.189**, and the SD-gradient is **0.101** where a collapsible derivation says it is zero. Under cloglog the gap is **0.337** and the SD-gradient **0.201**. So covariates that modify nothing still carry target-moment variance once the link is curved, which the design predicted only for the matched moments |
| **P3, twice** | The identity-link check was rewritten twice before it was right, and neither wrong version was a code defect | First it compared the two gradients against an absolute **1e-3** and reported FAILURE. The per-replicate SD of each gradient component is 0.07 to 0.10, so at 40 replicates the standard error is 0.012 and the threshold sat **ten times below the noise floor**. Second it used 3 standard errors at one source size and reported FAILURE at **z = 3.49**; the estimator gradient is a nonlinear function of the data through $A^{-1}$ and carries an $O(1/n)$ finite-sample bias, which a point comparison cannot distinguish from a wrong implementation |
| **P3** | The identity-link check is a **convergence test** | The gap falls 0.0287, 0.0190, 0.0043 as $n_S$ goes 500, 2000, 8000, a factor of **6.7**, reaching within one Monte Carlo SE of zero. A wrong implementation produces a gap that does not move. At the registered $n_S = 500$ the residual is a real finite-sample bias of about **0.029 against a $\beta_{EM}$ of 0.6**, which is disclosed rather than buried and is an order of magnitude below the effect the study is about |
| **P3** | **The expected headline survives**, and its size is now known before the run | On curved links the ported gradient is wrong by up to **38% relative**, 22.9 Monte Carlo SE, and the variance it produces is off by a factor of **0.76 to 1.44**. The ports are anti-conservative on logit, by up to 44%, and conservative on cloglog, by up to 24%. **The direction differs by link**, which no part of the design predicted |
| **P2** | **The source size became a factor.** It had been pinned at 500 | On the study's own primary arm, logit at $n_T = 100$ and $k = 0$, the omitted variance is **2.6%** of the total at $n_S = 500$ and 9.5%, 29.8%, 50.9% at 2000, 8000, 20000. At the registered size a 44% error in the omitted term moves coverage by far less than the 0.005 MCSE the design budgets for, so **the primary arm could not have detected its own headline**. This is the pilot mistake MIS-03 documented and this design repeated by reading "the magnitude tracks the ratio" as licence to pin the source |
| **P2, rerun** | With $n_S$ crossed the primary arm becomes detectable and the grid is **176 cells** | The logit link's omitted share reaches **0.298** where the pinned source capped it at 0.036, identity reaches 0.714 and cloglog 0.494. Every dropped cell is a small-source, large-target one, which is where the source variance dominates by construction. So the repair is not a grid enlargement: it moved the grid to where the quantity under study is measurable |
| **P2** | Grid cut from 216 realized cells to those clearing a 4% floor | The floor is derived, not typed: a coverage MCSE of 0.005 makes 0.01 the smallest coverage shift worth claiming, which needs roughly a 4% variance share. Under the pinned source only **60 of 216** cells cleared it, and the shares by link were identity 0.00 to 0.22, cloglog 0.002 to 0.082, **logit 0.0002 to 0.036** |
| **P2** | **MAIC matches one moment for a binary covariate, not two** | With $x$ binary, $x^2 = x$ identically, so `cbind(x, x^2)` is rank deficient and the sandwich Jacobian is singular: measured rank 5 of 6, and **every replicate in the `mixed` shape arm failed**. This is a fact about MAIC rather than about this code, and an implementation that always forms two columns per covariate cannot fit the mixed-type baseline table most applications have |
| **P1** | Cost of truth confirmed affordable | $48^3 = 110{,}592$ nodes evaluates in **0.24 s**, and truth is computed once per cell rather than once per replicate, so the order that the hardest cell needs is used everywhere. One order for the study means no between-cell difference can come from the integration rule |

**A cheaper exact route exists for the `mixed` arm and is deliberately not taken.**
The binary covariate could be enumerated over its two states with the continuous
pair integrated conditionally, which would be exact in that dimension instead of
slowly convergent. It is not done because the conditional law of the remaining
covariates given a *truncated* latent is not Gaussian when they are correlated,
so the exact route needs a second approximation to justify, and a measured 0.24 s
does not need saving.

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** integration order | Quadrature order at which the true $\Delta(F_T)$ is stable to $10^{-4}$, on the most skewed covariate law in the grid | The definition of truth; if no order is stable, the skew arm is dropped | minutes |
| **P2** grid and cell count | The realized cell count and the analytic omitted-variance fraction in each, from section 2's expansion | The grid. Cells where the predicted omission is below Monte Carlo resolution are dropped rather than run | minutes |
| **P3** closed-form agreement | Whether the two ported estimators reproduce MIS-03's $(1-2k)\mathrm{Var}_T(\tau)/n_T$ exactly under the identity link, **and whether the estimator gradient equals the estimand gradient there** | Whether either is implemented correctly. **A port that does not reproduce the known case is not evidence about the unknown one** | hours |
| **P4** unit cost and budget | Wall clock per replicate per method at production settings, and the grand total | The grid size. Computed in `R/10-budget.R` and asserted against this document; never typed |

**P3 is the load-bearing probe.** Two of this program's fatal findings were
estimators that behaved plausibly and were implemented wrongly, and the identity
link gives a case where the right answer is known in closed form.

**P3 has a second half that makes prediction 2 an identity rather than a
comparison.** MIS-03 obtains its gradient by the implicit function theorem on the
stacked MAIC score, $J = -c'A^{-1}C$: that is the gradient of the **estimator**
with respect to the reported moments, and it is what every published variance
formula propagates. `R/02-gradient.R` obtains the gradient of the **estimand** by
differentiating $\Delta(F_T)$ itself. Under the identity link the two must
coincide, and both must equal $\beta_{EM}$; the estimand gradient already does,
to 1.5e-12.

**Under a curved link they cannot coincide, and their difference is exactly the
error in the ported variance.** That reframes prediction 2 from "the ports use
the wrong gradient" to a quantity computable per cell without running a single
replicate: $\|J_{\text{estimator}} - J_{\text{estimand}}\|$, with the ported
variance in error by $J_{\text{est}}'\Omega J_{\text{est}} -
J_{\text{true}}'\Omega J_{\text{true}}$. **P3 therefore reports the size of the
defect the study exists to demonstrate before the study runs**, and if that
difference is negligible across the grid the expected headline is withdrawn on a
probe rather than after 2000 replicates per cell.

## 11. Cost

Unmeasured until P4. The shape: MAIC and STC arms are seconds per replicate;
the ML-NMR arm dominates and is the only reason the grid is restricted rather
than fully crossed. The perturbation interval multiplies its arm by the
resampling count, which is the line item OUT-11 called cheap without measuring
and which then dominated its run.

No total is quoted here. A budget total that does not follow from a measured unit
cost has produced two fatal findings in this program and both were quoted the
same way.

---

## Relationship to the rest of the queue

- **MIS-03** is the predecessor and its analytic result is imported, not
  re-derived. Its standing recommendation of major revision was for a fresh
  registered run with an ex ante overlap restriction; this design carries that
  restriction.
- **OUT-11** owns non-proportional hazards. The survival arm here is
  proportional so the two do not overlap.
- **COV-12** owns median-based covariate summaries, which is a different failure
  of the same input.
- **CMP-15** owns the target joint covariate distribution being only
  approximately known, which is the correlation component at network scale; if
  that study runs first, this one imports its finding rather than repeating it.
