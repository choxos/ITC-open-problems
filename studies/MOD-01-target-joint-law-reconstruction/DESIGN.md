# MOD-01 design: the joint law standardization needs and publications do not print

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is blunt that the headline claim is closed: parametric g-computation
(Remiro-Azócar, Heath and Baio 2022) and multiple imputation marginalization
(2024) standardize the fitted model over the target covariate distribution, and
`outstandR` ships both on CRAN. **Rebuilding that would be a weak study.** What
remains is the input those methods need, and section 2 shows it reduces to one
scalar that published marginals do not determine.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** standardization needs the target **joint** covariate
law; publications report marginals; implementations condition on reported means
and standard deviations as known constants; and the reconstruction of the joint
law from marginals materially affects the standardized contrast.

**Refuting sentence:** *the reconstruction is immaterial, because the
standardized contrast depends on the joint law only through quantities the
marginals already fix.*

**Section 2 shows exactly when the refuting sentence is true, and it is true more
often than the catalog implies.** That is worth establishing precisely: it tells
an analyst when they may stop worrying, which is a more useful deliverable than a
warning.

## 2. The mechanism: the copula enters through one scalar

For a conditional logistic model $\eta = \alpha + \gamma^\top x + \tau(x)A$, the
target marginal log odds ratio expands, to second order about the target mean, as
a function of the **prognostic index** $u = \gamma^\top x$:

$$\Delta(F_T) \;\approx\; \bar\tau_T \cdot \big\{1 - c\,\mathrm{Var}_T(u)\big\}, \qquad \mathrm{Var}_T(u) = \gamma^\top \Sigma_T\, \gamma .$$

**Published marginals fix the diagonal of $\Sigma_T$ and say nothing about the
off-diagonal.** So the reconstruction error in the standardized contrast is

$$\Delta(\hat F_T) - \Delta(F_T) \;\approx\; -\,c\,\bar\tau_T\;\gamma^\top(\hat\Sigma_T - \Sigma_T)\,\gamma \;=\; -\,c\,\bar\tau_T \sum_{i \neq j}\gamma_i\gamma_j\big(\hat\Sigma_{T,ij} - \Sigma_{T,ij}\big).$$

Four consequences, each a prediction:

1. **Assuming independence sets every off-diagonal to zero**, so its error is
   $+c\,\bar\tau_T\sum_{i\neq j}\gamma_i\gamma_j\Sigma_{T,ij}$: a weighted sum of
   the true covariances with weights given by products of prognostic
   coefficients. **This is computable, and an analyst who knows the sign pattern
   of $\gamma$ and a plausible correlation range can bound it without any new
   method.**
2. **Mixed signs in $\gamma$ make positive correlations cancel.** The error is not
   monotone in "how correlated the covariates are", and a study that varies
   correlation without varying the sign pattern would report a monotone
   relationship that does not exist.
3. **On a collapsible scale the reconstruction matters much less, but not zero.**
   An earlier version of this prediction said $c = 0$ made it *irrelevant*.
   Section 8 records why that is wrong: collapsibility fixes the relationship
   between the marginal and the mean conditional effect, not the dependence of
   that mean on the joint law. Measured, the risk-difference arm carries about a
   quarter of the log odds ratio's reconstruction error rather than none of it.
4. **Nonlinear effect modification adds terms the second moment does not
   capture**, so the copula family, not only the correlation matrix, matters
   there. That separates "get the correlations right" from "get the joint law
   right", which the catalog conflates.

**This is the same scalar COV-03 identifies.** COV-03 asks what to balance;
MOD-01 asks what to reconstruct. If both run, the shared quantity is derived once.

## 3. Estimand, with its true value defined

**Primary.** The marginal log odds ratio in the aggregate study's population.

**True value** by quadrature over the true target joint law at an order fixed by
P1, using the true outcome model. Not from the conditional coefficient, which is
the very error the closed part of this entry is about.

**Two estimands are carried and labeled**, because the catalog records GPT-5.6
Sol's point and it is correct: target-summary uncertainty is a genuine omission
when the estimand indexes a superpopulation and may properly be conditioned on
when it indexes the realized finite target sample. **Every uncertainty statement
in this study names which estimand it is for**, and EST-07 owns the sampling-error
question itself.

## 4. Data-generating mechanism, and what it makes invisible

Anchored two-trial geometry with identical published means and standard
deviations across arms of the design, so **the only thing varying is the joint
law behind them**. That constancy is the design's central control: two cells with
the same published summaries and different truths.

### Factors

| factor | levels | why |
|---|---|---|
| true correlation | 0, 0.3, 0.6 | the off-diagonal that marginals do not fix |
| $\gamma$ sign pattern | all positive; mixed | **section 2 prediction 2**; without this the study reports a monotonicity that is an artifact |
| copula family | Gaussian; Clayton; Gumbel | tail dependence, invisible to the correlation matrix |
| effect modification | linear; nonlinear | prediction 4 |
| scale | log OR; risk difference | prediction 3, the falsifier |
| overlap | good, poor | how far standardization extrapolates |
| covariate dimension | 2, 5 | the off-diagonal count grows quadratically |

### What the mechanism makes true, and therefore what the study cannot see

- Reported marginals are **exact**, so nothing here is sampling error in the
  moments. EST-07 and MIS-03 own that, and mixing the two would make neither
  interpretable.
- The outcome model is correctly specified in the IPD trial. MOD-02 owns
  misspecification, and standardizing a wrong model over a right law is a
  different failure.
- Covariates are continuous. Categorical covariates constrain the joint law far
  more tightly than continuous ones do, so the reconstruction problem is
  different and easier there; that is stated rather than left implied.
- One aggregate comparator. The multi-comparator version is COV-14's subject.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| conventional STC at target means | the plug-in conditional quantity | the closed problem, carried only as a reference point and labeled as such |
| g-computation, true joint law | oracle | the ceiling; isolates reconstruction from everything else |
| g-computation, independence | marginals only, zero off-diagonal | the default when nothing is reported, **and the maximum-entropy law given the marginals** |
| g-computation, Gaussian copula | correlation borrowed from the IPD trial | what implementations do in practice, **and the maximum-entropy law given the marginals plus a covariance** |
| **reconstruction interval** | the contrast reported over the set of joint laws consistent with the marginals and a declared correlation range | the honest output when the law is unknown |

> **Correction, made at implementation.** This table previously listed maximum
> entropy as a sixth arm, distinct from independence. **They are the same
> distribution.** Maximizing differential entropy subject to fixed marginals
> gives the product of those marginals, because $H(f) \le \sum_i H(f_i)$ with
> equality exactly under independence; adding a covariance constraint gives the
> Gaussian. So the two reconstructions here are not competing heuristics, they
> are the maximum-entropy solutions under the two information sets an analyst can
> have. The study therefore cannot report that maximum entropy beat independence,
> and any result claiming so would be an arithmetic error rather than a finding.

**The comparator that can win is independence.** If it matches the oracle across
the realistic grid, the residual the catalog names is not material and the
recommendation is that reported marginals suffice. Registered as such, and
section 2 says it should win in exactly the mixed-sign and collapsible cells.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE, interval width, per method per cell, with MCSE.

**The registered mechanism check:** regress observed bias on
$c\,\bar\tau_T\,\gamma^\top(\hat\Sigma_T-\Sigma_T)\gamma$ across all cells. Slope
1 confirms section 2; a slope elsewhere means the second-order expansion is not
what drives the error at these strengths and the study reports that instead of
the recommendation.

**The bound's usefulness is a registered outcome:** the fraction of cells in
which the analytically computable bound of section 2 consequence 1 contains the
realized bias. **A bound an analyst can compute from published data is worth more
than a method they cannot run**, and its performance is measured rather than
asserted.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias in the target marginal log odds ratio under the
independence reconstruction, in nonlinear-modification cells with all-positive
$\gamma$ and correlation 0.6, where section 2 predicts the error is largest.

**Decision rule.**

- Independence biased by more than 0.05 on the log OR while copula or maximum
  entropy is not: the reconstruction matters and the deliverable is a
  recommendation plus the reporting request for a correlation matrix.
- All reconstructions within Monte Carlo error of the oracle: the residual is not
  material and the study reports that the closed part of this entry closes the
  whole of it.
- Copula family mattering beyond the correlation matrix, in the nonlinear cells
  only: prediction 4 is confirmed, and the recommendation distinguishes the two.

**The reconstruction-interval arm is judged two-sided.** An interval that always
covers by spanning implausible laws is not a result, and its width is reported
beside its coverage.

## 8. Three controls, each of which can fail

> **Correction, made before the run and after checking the algebra numerically.**
> An earlier version of this section registered the risk-difference arm as an
> **exact** null control, on the reasoning that a collapsible scale sets $c = 0$
> and makes the reconstruction irrelevant. **That is wrong, and the run would
> have failed a control that was never true.** Collapsibility says the marginal
> risk difference equals the *mean conditional* risk difference; it does not say
> that mean is fixed by the marginals. The conditional risk difference of a
> logistic model, $\mathrm{plogis}(\alpha + \gamma^\top x + \tau) -
> \mathrm{plogis}(\alpha + \gamma^\top x)$, is a nonlinear function of the
> prognostic index, so its expectation still moves with $\mathrm{Var}_T(u)$.
> Measured at $d = 5$, all-positive $\gamma$, linear modification, moving the
> correlation from 0 to 0.6 moves the marginal risk difference by **-0.0249**,
> half of the material threshold, against **-0.1012** on the log odds ratio.
> The scale effect is real and large; the identity is not.
>
> The arm is retained and **reclassified as a registered prediction**: the
> reconstruction error on the collapsible scale should be several times smaller
> than on the log odds ratio, and the measured ratio is a reported outcome. Two
> exact null controls replace it below.

**Null control, exact.** With one covariate there is no off-diagonal, so the
joint law *is* the marginal and every reconstruction coincides with the truth by
definition. Any disagreement between methods at $d = 1$ is an implementation
fault. Cheap, exact, and it catches a whole class of error. Copula constructors
reject `dim = 1`, so `draw_target()` handles this case before any copula is
built, which is why the control is runnable at all.

**Second null control, exact up to integration error.** At correlation zero the
true law *is* the independence law, so the oracle and the independence
reconstruction integrate the same distribution and must agree to the integration
error P1 sized. This one also checks the three copula families collapse onto each
other there, since all three reduce to the independence copula.

**Registered prediction replacing the withdrawn control.** On the risk-difference
scale the reconstruction error must be materially smaller than on the log odds
ratio, in every cell. The ratio is reported. If it is near one, non-collapsibility
is not the mechanism and section 2's account is wrong about *why* the
reconstruction matters even where it is right that it does.

**Positive control.** All-positive $\gamma$, correlation 0.6, nonlinear
modification, five covariates: independence must be biased by at least three
MCSEs. If not, the reconstruction cannot be made to matter within the realistic
range and that is the answer.

**Falsifier for the study's own headline.** The expected headline is that the
joint law must be reconstructed carefully. Its falsifier is the mixed-sign arm:
section 2 predicts cancellation there, so independence should be **fine** despite
strong correlations. If independence is biased there too, the cancellation
mechanism is wrong and the recommendation cannot be conditioned on the sign
pattern, which is most of its practical value.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Rebuilding the closed estimand result | Conventional STC carried as a labeled reference only; the paper says the mismatch is solved | removed |
| Correlation varied without sign pattern, giving a spurious monotonicity | Sign pattern is a registered factor and the falsifier | removed |
| Reconstruction error confounded with moment sampling error | Marginals exact; EST-07 named as owner | removed |
| Copula effects attributed to correlation | Three families at matched correlation | removed |
| The reconstruction interval wins by being wide | Two-sided rule and width reported | removed |
| Estimand ambiguity between finite target and superpopulation | Both carried and labeled on every uncertainty statement | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The true marginal contrast per joint law; the realized $c$ | The definition of truth | minutes |
| **P2** matched-marginal construction | Joint laws with **identical** marginals across correlation and copula levels, verified numerically | **The grid.** The design's central control is that published summaries are constant across cells; if the construction does not achieve that, every comparison is confounded by a marginal difference | hours |
| **P3** bound computability | Whether the section 2 bound is computable from the information a publication actually prints | Whether the study's most deployable output exists | hours |
| **P4** unit cost | Per-replicate wall clock; total computed not typed | The grid | minutes |

**P2 is the design.** Two cells that differ in their reported summaries are not a
test of the joint law.

## 11. Cost

Small; GLM fits and quadrature. Quoted after P4 only.

---

## Relationship to the rest of the queue

- **COV-03** shares the prognostic-index-variance scalar; if both run it is
  derived once and cited.
- **EST-07** and **MIS-03** own sampling error in reported moments, switched off
  here.
- **CMP-15** owns the target joint distribution at network scale, which is this
  question for ML-NMR's integration rather than for STC's standardization.
- **COV-12** owns marginals that were never reported at all.
- **SFW-12** owns `outstandR` being pairwise only, which is where the
  implementation of any recommendation would land.
