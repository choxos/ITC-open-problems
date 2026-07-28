# Response to the pre-run critique

GPT-5.6 Sol, maximum reasoning effort, given the design and nothing else, before any
replicate was run. Six fatal findings, nine serious, and one omission named as the most
important. **Every finding below was verified numerically before it was accepted**, and the
verification is reproducible from the commands recorded here. The design changed
substantially: two of the four design factors, the number of covariates, the number of
treatments, the parameterization of the drift, the target baseline, the verdict rule, and
three of the four mechanism claims.

The design that was critiqued is `design-for-critique.md`, unedited. What follows is what
happened to it.

---

## Fatal 1. Several relaxed fits were structurally unidentified

> The proposed rotation gives ... $J=6, n_{\mathrm{IPD}}=1$: five aggregate studies,
> allocated 2,2,1. Depending on rotation phase, an aggregate-only treatment may again have
> one study.

**Verified, and worse than stated.** Enumerating the rotation exactly:

| $J$ | $n_{\mathrm{IPD}}$ | aggregate studies | A | B | C |
|---|---|---|---|---|---|
| 6 | 1 | 5 | 2 | 2 | **1** |
| 6 | 2 | 4 | 2 | **1** | **1** |
| 12 | 1 | 11 | 4 | 4 | 3 |
| 12 | 2 | 10 | 4 | 3 | 3 |

Every six-study cell gave an aggregate-only treatment exactly one study. The fully relaxed
model gives that treatment a main effect and three interactions, four coefficients, from one
placebo-anchored contrast. Sixteen of the thirty-two cells would have reported the prior and
been read as the check's power.

**Changed.** Three active treatments became two, A and C, with A in the individual-level
study and C aggregate-only. Aggregate studies alternate starting with C, so the
aggregate-only treatment never has fewer studies than the other:

| $J$ | aggregate | A (incl. IPD) | C |
|---|---|---|---|
| 6 | 5 | 3 | 3 |
| 12 | 11 | 6 | 6 |

With two covariates the fully relaxed model gives each treatment three coefficients, so the
small network is exactly identified with no redundancy and the large one has redundancy of
three. That is thin at the small end **by design**, because thin is the regime the problem is
about, and prior-posterior contraction is now recorded for every coefficient so a fit that
reported the prior can be distinguished from one that reported the data. The first smoke test
after the change found contraction of **0.162** for the aggregate-only treatment's interaction
in a six-study network: the posterior standard deviation was 84% of the prior's.

## Fatal 2. The posterior rule was degenerate

> If you select the pair with the largest posterior mean difference and then inspect that
> pair's ordinary 95% interval, selection invalidates the nominal 95% interpretation.

**Correct on the selection point.** The implementation ranked the three pairwise differences
by $|\text{mean}|/\text{sd}$ and reported the winner's interval as a 95% interval.

On the second half, that "the posterior probability of a nonzero difference is exactly one":
correct as the design document worded it, but the code computed
$\max\{P(z>0), P(z<0)\}$, a directional probability in $[0.5, 1]$. The prose was wrong, not
the arithmetic. Both are fixed.

**Changed.** With two active treatments there is exactly one interaction contrast per
covariate, $\gamma_A[x] - \gamma_C[x]$, so nothing is selected and the interval keeps its
nominal coverage. Sol's suggested margin rule is adopted alongside the point-null rule, with
the margin set by consequence rather than taste: $\varepsilon$ is the interaction contrast
that makes the C-versus-A marginal risk difference exactly material at displacement 1, solved
to $\varepsilon = 0.1531$.

## Fatal 3. The verdict tested the diagnostic against errors it is not designed to detect

> A perfect shared-modification diagnostic can fail your rule ... $P(\text{material error} \mid
> \text{pass})$ ... is much more relevant than $P(\text{pass} \cap \text{material error})$.

**Accepted.** The joint probability moves with the prevalence of error rather than with the
check's information.

**Changed.** The primary quantity is now $P(\text{material error} \mid \text{the check
passed})$, which is what a committee is actually relying on when it reads a pass. Power and
type I error against the diagnostic's own hypothesis, the interaction violation, are reported
separately and are not thresholded.

## Fatal 4. "Every stratum" was a rule no finite simulation can pass

> Even if every stratum's true sensitivity were exactly 0.80, an observed estimate will fall
> below 0.80 roughly half the time. Requiring every observed estimate to clear the boundary
> therefore has effectively zero joint probability.

**Accepted, and this is a defect this program has repeated.** Study 4 used the same
every-stratum form.

**Changed.** The verdict is a single confidence statement on a single pooled quantity: the
upper 95% bound on $P(\text{material error} \mid \text{passed})$ under the deployment
distribution at displacement 1.0, against 0.10. Per-stratum results are reported with Monte
Carlo intervals and are descriptive.

## Fatal 5. M2 was not identified by the design

> There is only one DIC decision for `split-x1`; it has no treatment-specific "power involving
> A" or "power involving C".

**Correct.** The claim asked for a power difference between treatments from a statistic that
has no treatment index.

**Changed.** M2 now compares **prior-posterior contraction** for $\gamma_A[x_1]$ against
$\gamma_C[x_1]$. That is a per-treatment quantity, it is exactly the thing the claim was
reaching for, and the smoke test suggests it is large.

## Fatal 6. The aggregate covariate distribution was underspecified

> Means and SDs are insufficient for multivariable logistic ML-NMR when covariates are
> correlated.

**Half accepted.** `multinma` does not assume independence; `add_integration` reports "Using
weighted average correlation matrix computed from IPD studies" and reconstructs the joint
distribution from a copula with that correlation matrix. So the correlation is *estimated*
from the individual-level studies, not ignored. Sol could not have known this from the design
document, which did not say so, and the document was wrong to leave it out.

The residual point stands: the estimate carries error, and with one individual-level study
that error is not negligible. **Changed:** the mechanism is now stated explicitly, and the
analysis reports the distance between the estimated correlation matrix and the truth per cell,
so any contribution from this source is visible rather than assumed away.

## Serious findings accepted

**Drift was half the contrast it appeared to name.** With deviations $(+\Delta, 0, -\Delta)$
the A-versus-C contrast is $2\Delta$, so every reported drift level meant twice what it said.
The parameter is now the contrast itself: $\gamma_A - \gamma_C = \text{drift}$, at levels
0, 0.30, 0.60, 1.20.

**`relative_effects(newdata =)` is not a marginal odds ratio.** Correct. It is the population
mean of individual conditional log-odds ratios. It is now labelled that and never called
marginal; the marginal risk route is the aggregate-response prediction, which is what the
decision estimand uses.

**The bias formula was incomplete.** Correct: the main effects absorb slope error, so the
transported error is $(\hat d_C - \hat d_A) + \text{drift} \times s$ and not
$\text{drift} \times s$. Confirmed in the smoke test, where the shared-interaction fit gave a
nonzero C-versus-A contrast at displacement 0. The exact-bias language is withdrawn.

**Displacing the target moved the baseline risk.** Correct: because $x_1$ is prognostic,
displacement moved the placebo risk from 0.32 to 0.45 and compared risk differences at
different points on the logistic curve. **Changed:** the reference intercept is now solved
separately for each displacement to hold the marginal placebo risk at 0.30 exactly, so
displacement moves the treatment contrast and nothing else.

**M1 was partly tautological and partly impossible.** Correct on both halves. The check's
output is *identical* across displacements, not merely close, so the 0.02 tolerance was
meaningless; and the required 0.20 rise in a joint probability is impossible wherever the pass
rate is below 0.20. **Changed:** the invariance is now stated as a bookkeeping identity whose
observed value must be exactly zero, and the rise is required of the *conditional* probability.

**Type I error was contaminated under drift.** Correct: with correlated covariates a
treatment-specific $x_2$ term can absorb $x_1$ misspecification. **Changed:** nominal type I
error is estimated only under the global null, and the drift-present case is reported
separately as misattribution.

**Five models were not the complete lattice.** Correct. With two covariates the four fits
**are** the complete lattice, so check-then-relax now relaxes exactly the covariates that
flagged, rather than jumping to the least identified model whenever anything fires.

**Calibration omitted the deployment variable.** Accepted. All four displacements from one
simulated dataset now carry the same dataset identity and stay in the same fold. The primary
calibration is deliberately target-blind, because the check is target-blind and that is the
finding; a mapping that includes displacement is reported alongside to show what the check
would need to know.

**Fit checks were inadequate.** Accepted. "Has draws" is now the first of four criteria:
$\hat R \leq 1.05$ and bulk ESS $\geq 100$ on all treatment effects and regression
coefficients, and zero divergences. A replicate in which any of the four fits fails is
excluded and counted. An integration-sensitivity check against a larger number of integration
points is run on a subset.

## The most important omission: treatment-effect heterogeneity

> The ecological interaction signal for one treatment has between-study SD approximately
> $\Delta\tau$ ... A treatment-effect heterogeneity SD of 0.10 to 0.20 would equal or dominate
> that signal.

**Accepted, and this is the change that cost a design factor.** The arithmetic is right: at
drift 0.30 and spread 0.25 the ecological signal has SD 0.075, and a random effect of SD 0.15
is twice that. A design without it would have been a best case presented as a measurement.

**Changed.** `tau_re` $\in \{0, 0.15\}$ is now a factor. To pay for it without doubling the
run, `n_ipd` was dropped and fixed at one individual-level study, which is the situation
population adjustment exists for. That is a real loss: IPD availability was named in the
original design sketch, and the study can no longer speak to it. It is declared as a
limitation rather than quietly dropped.

## Findings not accepted

None were rejected outright. Two were narrowed: fatal 6, because `multinma` does estimate the
correlation matrix rather than assume independence, and fatal 2's second half, because the
implementation already computed a directional probability rather than the degenerate
$P(\neq 0)$.

## What the critique did not reach

Sol did not see the code, so it could not find the defect that would have made every check
fire never: with `class_interactions` left at its default `"common"`, an `x:.trt` term in the
regression formula is silently demoted to the class level, and the "split" fit is the shared
fit under another name with the same parameter names and a DIC that differs only by Monte
Carlo error. That was found in the pilot, before the critique, and every split fit now asserts
that treatment-specific coefficients exist before any statistic is computed from it.
