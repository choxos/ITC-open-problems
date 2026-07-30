# OUT-02 design: the diagnostic that counts patients when the likelihood counts events

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog narrows its own source in two useful ways. A double-zero study
carries no conditional odds-ratio information that any likelihood choice can
recover, so no estimator arm should be built as if it might. And rare-event
machinery already exists in unweighted network meta-analysis (Evrenoglou et al.,
penalized likelihood regression); the missing half is its composition with the
weighting and integration steps population adjustment adds.

Section 2 supplies the concrete deliverable the catalog asks for and nobody has
defined: **an effective event sample size**.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** reweighting concentrates the effective sample without
reducing covariate dimension, so the weighted binary likelihood flattens exactly
where population adjustment is most needed; where a prior or penalty then supplies
identification the interval is finite and reads as evidence; and the reported
effective sample size, computed from weights alone, cannot detect that the weights
landed on patients contributing no events.

**Refuting sentence:** *patient effective sample size and event risk are
sufficient together, so a diagnostic built on events adds nothing that
$\mathrm{ESS} \times \hat p$ does not already give.*

**That refutation has a closed form and section 2 says exactly when it is true.**

## 2. The mechanism, algebraically, and the diagnostic it defines

For a weighted proportion $\hat p = \sum_i w_i y_i / \sum_i w_i$, the variance is
$p(1-p)/\mathrm{ESS}$ with Kish's $\mathrm{ESS} = (\sum w_i)^2/\sum w_i^2$. On the
log-odds scale and for small $p$, $\mathrm{Var}(\log\mathrm{odds}) \approx
1/(\mathrm{ESS}\cdot p)$, against $1/e$ for $e$ unweighted events. So the naive
answer is $\mathrm{ESS}\times p$, which is the refuting sentence.

**It is right only when the weights are independent of the events.** They are not:
weights are a function of covariates, covariates predict the outcome, so the
weight mass and the event mass need not coincide. The quantity that governs the
information is Kish's ESS computed *on the events*:

$$\boxed{\;\mathrm{EESS} \;=\; \frac{\left(\sum_i w_i y_i\right)^2}{\sum_i w_i^2 y_i}\;}$$

which equals $\mathrm{ESS}\times p$ exactly when weights and events are
independent, and is **strictly smaller whenever the weights concentrate away from
the event-carrying patients.** That is the whole diagnostic, it costs nothing to
compute, and it is testable against the refuting sentence directly: if
$\mathrm{EESS}$ and $\mathrm{ESS}\times\hat p$ have the same discrimination for
realized failure, the catalog's gap is not real.

**Separation follows the same quantity.** Separation is a small-sample event, and
the weighted likelihood's effective sample for a logistic fit with $d$ covariates
is governed by events per covariate. **The prediction is that separation
probability is a function of $\mathrm{EESS}/d$ and not of $\mathrm{ESS}/d$**, and
that gives a second, sharper test than coverage alone.

**Where the penalty does the identifying.** When the likelihood is flat, the
posterior is the prior. CMU-02 measured the operating characteristics of
prior-to-posterior contraction for exactly this situation, and CMP-14 supplies a
prior-free precision that is exactly zero where a coordinate is unidentified.
Both are imported rather than rebuilt; **this study's contribution is the event
currency, not the diagnostics of prior dominance.**

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio.

**True value** by quadrature over the target law with the true risk model, at an
order fixed by P1. Rare events make the marginal and conditional effects diverge
less than at common risk, but not identically, so both are computed.

**Realized failure is a derived estimand**, defined for the classifier analysis
as absolute error exceeding a declared material threshold, or interval
non-coverage. The threshold is set in P2 from the decision context.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| event risk | 0.005, 0.02, 0.10 | the rare-event axis |
| weight concentration | 3 levels, set by source-target overlap | **varied independently of event risk**, which is what lets ESS and EESS diverge |
| weight-event alignment | weights concentrate on high-risk patients; on low-risk patients; independent | **the axis that makes EESS differ from ESS × p**, and the one no study has |
| covariate dimension | 3, 8 | events per covariate is what drives separation |
| nominal sample size | 300, 1000 | so event count varies independently of risk |
| zero structure | none; single-zero arm; double-zero study | the catalog's own distinction; double-zero carries no information and is included to show that, not to rescue it |
| true effect | null; moderate | type I error needs the null |

Event risk crossed with concentration and alignment fully; the rest reduced by
P2.

### What the mechanism makes true, and therefore what the study cannot see

- The risk model is correctly specified, so separation is a small-sample event
  rather than a misspecification artifact. MOD-02 owns the latter.
- One aggregate comparator; no network. The composition with network synthesis is
  named as out of scope, which matters because the rare-event machinery being
  borrowed was built for networks.
- Covariates are continuous and the weights are method-of-moments MAIC weights.
  Trimming and truncation are **not** applied in the base arm, because trimming
  changes the estimand and would confound the diagnostic comparison; a trimmed arm
  is carried separately.
- Double-zero studies are included so their behavior is documented, not so a
  method can be shown to handle them. **The catalog is explicit that no likelihood
  choice recovers information that is not there**, and any arm appearing to do so
  is reporting its prior.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| ordinary weighted logistic | robust sandwich | the status quo, and the one that separates |
| Firth-penalized weighted | penalized likelihood, weighted | the established rare-event fix |
| penalized likelihood regression | Evrenoglou et al., composed with weighting | **the composition the catalog says is missing** |
| Bayesian weighted binomial | weakly informative prior, arm-based so zero counts enter without correction | the arm that reports prior contribution explicitly |
| fail-closed | refuses to report when separation or non-identification is detected | `cpaic`'s behavior; a null answer is a legitimate output and is scored as one |

**The comparator that can win is the ordinary weighted logistic with a sandwich.**
If it is nominal wherever it converges, and the convergence failures are
themselves detected by the existing patient ESS, then neither a new likelihood nor
a new diagnostic is needed. Registered as such.

**Prior contribution is reported for every Bayesian and penalized arm**, using
CMP-14's prior-free marginal precision, so "the interval is finite" is never
mistaken for "the data identified it".

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, width, separation rate, convergence rate, type I error at the
null, per method per cell, with MCSE. Prior-free precision and contraction for
the penalized and Bayesian arms.

**The diagnostic comparison, which is the study's point.** $\mathrm{EESS}$,
$\mathrm{ESS}\times\hat p$, plain $\mathrm{ESS}$, and $\mathrm{EESS}/d$ scored as
classifiers of realized failure and of separation, with AUROC, calibration and
decision curves, at the level of a single analysis. DIA-03 established that this
scoring gives a very different picture from how such statistics read, and its
machinery is imported.

$n_{sim} = 4000$ per cell. Higher than elsewhere in this program because
separation and non-coverage are rare events themselves at the milder settings,
and a coverage MCSE target of 0.005 is not sufficient to resolve a separation rate
of 0.02. **The replicate count is derived from the rarest outcome measured, not
from coverage**, which is a mistake easy to make in exactly this study.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** AUROC of $\mathrm{EESS}$ against realized material error, at
a single-analysis level, compared with $\mathrm{ESS}\times\hat p$, in the
misaligned-weight cells.

**Decision rule.**

- $\mathrm{EESS}$ exceeding $\mathrm{ESS}\times\hat p$ by at least 0.05 AUROC in
  the misaligned cells, with overlapping performance in the aligned cells,
  **confirms** that the event currency adds information and section 2's
  definition is the deliverable.
- No separation between the two anywhere **refutes** the proposition; the
  refuting sentence in section 1 is then correct and the recommendation is simply
  to report $\mathrm{ESS}\times\hat p$, which is free.
- A gap that appears in the aligned cells too means the two statistics differ for
  a reason other than alignment and the explanation must be found, not assumed.

**A margin is registered rather than "better", because DIA-03 missed a registered
0.10 margin at 0.086 and reported the miss.** The same applies here.

## 8. Three controls, each of which can fail

**Null control.** With weights independent of events, section 2 makes
$\mathrm{EESS} = \mathrm{ESS}\times p$ in expectation, so the two must have
statistically indistinguishable discrimination. **This is an exact algebraic
control**, and if it fails the estimator of EESS is wrong rather than the theory.

**Positive control.** At the strongest misalignment, lowest event risk and
highest dimension, ordinary weighted logistic must separate in a substantial
fraction of replicates. If it never separates, the design does not reach the
regime the problem is about.

**Falsifier for the study's own headline.** The expected headline is that the
event currency is needed. Its falsifier is the type I error comparison: if the
penalized and Bayesian arms hold nominal type I error across the whole grid, then
the estimators already handle what the diagnostic would warn about, and a
diagnostic that warns about a solved problem is not needed. **That makes the
estimator arm and the diagnostic arm capable of refuting each other**, which is
why both are in one study.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| A finite interval read as evidence | Prior-free precision and contraction reported for every penalized and Bayesian arm | removed |
| Double-zero studies apparently rescued | Included and documented; any arm reporting a finite contrast there is reporting its prior, and the report says so | removed |
| Event risk confounded with sample size | Both varied; event count derived and reported | removed |
| Trimming changes the estimand mid-comparison | Base arm untrimmed; trimmed arm separate | removed |
| $n_{sim}$ set from coverage when separation is rarer | Derived from the rarest measured outcome | removed |
| Diagnostic proposed and not scored | Scored as a classifier with a registered margin | removed |
| Absence of prior work asserted | The catalog records the literature auditor could not confirm the absence from a source; **this study repeats no absence claim** and cites only what exists | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Marginal and conditional truths at each risk level | The definition of truth | minutes |
| **P2** attainable misalignment and threshold | Whether weight-event misalignment is achievable at the requested concentrations, and the material-error threshold from the decision context | **The grid.** Misalignment is generated through the covariate-risk relationship and may not be freely variable at fixed overlap | hours |
| **P3** rare-outcome $n_{sim}$ | The realized separation rate at pilot settings, so $n_{sim}$ follows from it rather than from a guess | $n_{sim}$, which at 4000 is the budget driver | hours |
| **P4** unit cost | Per-replicate wall clock, including the penalized regression composition; total computed not typed | The grid | hours |

## 11. Cost

Driven by $n_{sim} = 4000$ times the number of cells times five arms, one of
which is Bayesian. That product is unpriced until P4 and no total is quoted here.

---

## Relationship to the rest of the queue

- **CMU-02** owns prior-driven posteriors and its diagnostics are imported.
- **CMP-14** supplies the prior-free precision used to report penalty
  contribution.
- **DIA-03** supplies the classifier scoring machinery and the warning that such
  statistics read very differently from how they score.
- **OVL-02** owns whether ESS is a sufficient overlap diagnostic; EESS is a
  candidate member of the battery it asks for.
- **OUT-08** owns overdispersed counts, a different rare-outcome regime.
