# OVL-01 design: unsupported mass only matters where the effect is modified

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's own framing separates two things the field runs together. Weak
overlap **can** produce variable weights, low effective sample size and unstable
inference; those are consequences that may occur. What no estimator can fix is
the nonparametric identification failure where target covariate mass is absent
from the source. Section 2 shows the second is governed by a quantity no support
diagnostic can contain, and that is the study.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** where target covariate mass is absent from the
source, reporting an effect requires stronger assumptions, target redefinition,
sensitivity analysis or abstention; the failure is not reliably visible in
reported diagnostics; and there is no accepted trimming rule or effective sample
size threshold, so the same data can be made to look adequate or hollow by
undocumented choices.

**Refuting sentence:** *a battery of support diagnostics computed from the
covariates and the weights orders the analyses that fail, so the missing object
is a threshold rather than a new kind of information.*

## 2. The mechanism: support is a covariate property, bias is an outcome-weighted one

Split the target into the region $\mathcal{S}$ the source supports and its
complement $\mathcal{U}$. The transport bias contributed by the unsupported part
is

$$b \;=\; \int_{\mathcal{U}} \big\{\hat\tau(x) - \tau(x)\big\}\,dF_T(x) \;=\; F_T(\mathcal{U}) \cdot \mathbb{E}_{F_T}\!\big[\hat\tau - \tau \,\big|\, \mathcal{U}\big].$$

**A product of two things, and every reported diagnostic sees only the first.**

1. **If $\tau$ is constant on $\mathcal{U}$ and the fit recovers that constant,
   $b = 0$ no matter how much mass is unsupported.** A target region the source
   never observed costs nothing when the effect does not vary there.
2. **Conversely, a small unsupported mass sitting exactly where modification is
   strongest can dominate the bias.** So the ordering of analyses by $F_T(\mathcal{U})$,
   by Kish ESS, by density-ratio maps or by leverage is an ordering by the first
   factor alone.
3. **Every statistic in the reported battery is a function of covariates, the
   assignment and the weights, and uses no outcome information.** So none of them
   can contain the second factor. **This is not an empirical claim about how well
   they perform; it is a statement about what they are functions of**, and DIA-03
   found exactly this pattern: effective sample size discriminated the components
   that are functions of covariates and weights at AUROC 0.847 and 0.813, and the
   transport component adjustment exists to remove at 0.653.

**The prediction that follows and that this design is built to test:** the
alignment between unsupported directions and true effect modification is a
factor, and diagnostic performance should collapse as alignment varies **at fixed
overlap**. A design that varies overlap without varying alignment cannot see this,
and no existing overlap factorial varies it.

**Kish ESS is additionally not the precision it is read as.** Phillippo et al.
2018 record that it is likely an underestimate because the weights are estimated
and correlated with the outcome, and Remiro-Azócar et al. 2021 record that the
robust sandwich underestimates variability where effective sample sizes are
small. **Two known biases in opposite directions**, both in the region this study
is about, so the design measures the realized quantities rather than trusting
either.

## 3. Estimand, with its true value defined

**Primary.** The target marginal treatment effect, log odds ratio.

**True value** by quadrature over the whole target law, **including $\mathcal{U}$**,
at an order fixed by P1. That is the point: the estimand is defined on a
population the data do not cover, which is what makes abstention a legitimate
answer rather than a failure.

**Two derived estimands the deliverable rests on.** The **restricted estimand** on
$\mathcal{S}$ only, which is what a trimming rule silently switches to; and
**abstention correctness**, defined as declining to report when the realized error
would have exceeded a declared material threshold. **Trimming without declaring
the estimand change is the specific practice the catalog calls out, and carrying
the restricted estimand explicitly is what makes it visible.**

## 4. Data-generating mechanism, and what it makes invisible

Extends the existing 162-scenario anchored programme rather than starting fresh,
so overlap levels and covariate structure are comparable to the published
benchmark.

### Factors

| factor | levels | why |
|---|---|---|
| overlap | strong, moderate, weak, absent in one direction | the classical axis |
| **alignment of unsupported directions with modification** | orthogonal; partial; full | **section 2's second factor**, and the axis no existing study has |
| covariate dimension | 3, 8 | unsupported mass grows with dimension at fixed marginal overlap |
| outcome model misspecification | correct; misspecified on $\mathcal{U}$ only | separates extrapolation error from support absence |
| effect-modification strength | 2 levels | the multiplier |
| method | MAIC, STC, ML-NMR, ML-UMR, NMI | the families the catalog names |

Overlap × alignment is fully crossed and is the design.

### What the mechanism makes true, and therefore what the study cannot see

- The support boundary is defined by the generating law and is therefore known to
  the simulation. **An analyst does not know it**, so every diagnostic is scored
  on estimated support while truth uses the real one. That asymmetry is the
  realistic one and is stated rather than quietly removed.
- Covariates are continuous with a known joint law, so $\mathcal{U}$ is well
  defined. In high dimension with categorical covariates the notion is different
  and nothing here transfers.
- Conditional constancy holds. IDN-01 owns its failure, and a study confounding
  support failure with transitivity failure would be uninterpretable.
- Anchored comparisons. Unanchored transport has a different identification
  structure and QBA owns it.

## 5. Methods, including one that can win

Estimators as above, plus the diagnostic and rule set, which is where the
contribution is:

| diagnostic or rule | role |
|---|---|
| Kish ESS, ESS/n | the quoted default; DIA-03 proved these are one statistic |
| local ESS, density-ratio map | where the weight mass sits |
| leverage, influence-function variance | estimator-specific precision, which the catalog asks for instead of Kish alone |
| weighted event information | the survival-relevant currency, and OUT-02's subject |
| **extrapolation score** | target mass outside the source's fitted support, computed from the outcome model | the outcome-model analogue the weight battery lacks |
| **alignment-aware score** | unsupported mass **weighted by the source-estimated interaction**, so it carries outcome information | **section 2's missing second factor, made computable** |
| trimming with declared estimand | trimmed analysis reported against the restricted estimand | the honest version of current practice |
| **abstention rule** | decline where the alignment-aware score exceeds a threshold | the catalog's proposal, scored |

**The comparator that can win is the plain density-ratio map.** If it orders
failures as well as the alignment-aware score across the alignment axis, then
outcome information is not needed, section 2 prediction 3 is wrong in practice,
and the recommendation is a threshold on an existing statistic. Registered as
such.

**DIA-03's analogous construction missed its registered margin at 0.086 against
0.10 and the miss was reported.** The same margin discipline applies here.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE, interval width and convergence per estimator per cell, with
MCSE; the realized ESS against the realized precision, so the two known biases in
section 2 are measured rather than assumed; **sandwich variance performance
specifically at small ESS**, since that is where it is documented to fail.

**Diagnostics scored as classifiers of realized material error**, at the level of
a single analysis, with AUROC, calibration and decision curves, following DIA-03.

**The abstention rule is scored on both errors:** missed-failure rate and
**false-abstention rate**, the proportion of analyses declined whose answer would
have been fine. **A rule that abstains always is safe and useless**, and reporting
only one of the two is how such a rule gets recommended.

Common random numbers across estimators and diagnostics within a replicate; MCSE
clustered on the replicate block. $n_{sim} = 2000$ per cell, reduced for the
ML-NMR and NMI arms by P4 and reported at their own counts.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** AUROC of the alignment-aware score against realized material
error, compared with Kish ESS, **across the alignment axis at fixed overlap**.

**Decision rule.**

- Kish ESS's discrimination falling as alignment rises while the alignment-aware
  score holds, with a gap of at least 0.10 AUROC at full alignment, **confirms**
  section 2 and establishes that support diagnostics need outcome information.
- Both holding across alignment **refutes** the mechanism; the refuting sentence
  in section 1 is then correct and the deliverable is a threshold.
- Both falling means neither is usable in the aligned regime, which supports
  abstention over diagnosis and is a different recommendation again.

**The abstention frontier is reported in every branch**: missed-failure rate
against false-abstention rate, since that curve is what a committee needs
regardless of which diagnostic wins.

## 8. Three controls, each of which can fail

**Null control.** At strong overlap every estimator must be unbiased and nominal
and no rule may abstain above its nominal rate. A diagnostic firing here is
crying wolf and its false-positive rate is measured, not assumed low.

**Second null control, and it is the algebraic one.** At **orthogonal alignment**
with substantial unsupported mass, section 2 says the unsupported region
contributes no bias. Estimators must remain approximately unbiased **despite poor
overlap**, and any diagnostic that fires there is measuring the wrong factor.
**This control is what converts "poor overlap is dangerous" into "poor overlap
aligned with modification is dangerous", which is a different sentence and a
better one.**

**Positive control.** At full alignment with absent overlap in the modifying
direction, every estimator must fail materially. If some estimator is unbiased
there, it is either extrapolating correctly by luck of a correctly specified model
or the region is not truly unsupported, and P2 must resolve which before the run.

**Falsifier for the study's own headline.** The expected headline is that
abstention is sometimes the right answer. Its falsifier is the misspecification
factor: if the correctly specified outcome model extrapolates into $\mathcal{U}$
without material bias across the grid, then support is recoverable by assumption
and the honest conclusion is that the choice is one of assumption rather than of
abstention. **The catalog says this explicitly and it must not be argued away:
what cannot be restored is assumption-free identification, not information in
general.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Overlap varied without alignment, the flaw in every prior factorial | Alignment is a crossed factor and the second null control | removed |
| Trimming compared against the wrong estimand | Restricted estimand carried explicitly | removed |
| An abstention rule recommended on one error rate | Both rates and the frontier reported | removed |
| Kish ESS assumed to be precision | Realized precision measured beside it; both known biases named | removed |
| Sandwich failure at small ESS attributed to the estimator | Measured separately and reported as a variance-estimator finding | removed |
| Extrapolation framed purely as concealment | The catalog's counterweight carried: g-computation is reported as more accurate at poor overlap, and the misspecification factor is the falsifier | removed |
| Diagnostics scored on true support, which an analyst lacks | Scored on estimated support; truth uses the real one | disclosed, deliberate |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The true target effect including $\mathcal{U}$; the restricted estimand on $\mathcal{S}$ | The definition of both truths | minutes |
| **P2** alignment construction | Covariate laws achieving each (overlap, alignment) pair with matched unsupported mass, and confirmation that the "absent" level really is unsupported rather than merely thin | **The grid.** The whole design is a crossing that must be shown to exist | days |
| **P3** material threshold | The error magnitude a decision would notice, from the decision context | Every classifier and abstention result | hours |
| **P4** unit cost | Per-replicate cost across five estimator families; total computed not typed | The ML-NMR and NMI replicate counts | hours |

**P2 is the largest probe in the queue so far and it should be**, because the
crossing it verifies is the only thing distinguishing this study from the
factorials that already exist.

## 11. Cost

Five estimator families across a crossed grid at 2000 replicates is the dominant
cost, and the ML-NMR arm sets it. Unpriced until P4; no total quoted.

---

## Relationship to the rest of the queue

- **DIA-03** established that the weight battery reads covariate-and-weight
  functions and not the transport component; section 2 explains why and this
  study tests the consequence.
- **DIA-06** owns the estimator-family failure signatures on the same axis; if
  both run they share the divergence machinery and one becomes the other's arm.
- **OVL-02** owns the ESS definition question and the battery's composition;
  **OVL-03** owns aggregating a support diagnostic over a target distribution.
- **MOD-02** owns misspecification, which enters here only as the falsifier.
- **OUT-02** owns event-based information, which is the survival currency in the
  battery.
