# COV-14 design: four contrasts adjusting for four different things

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Fawsitt et al. 2025 supply the mechanism and, unusually, the consequence in the
same paper: refitting every comparison on a common all-covariates model left
three of four overall-survival comparisons and two of four progression-free
comparisons no longer statistically significant. Section 2 says why that happens
and predicts something the paper did not test.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** when one IPD trial is compared against several
aggregate comparators, each contrast conditions on whatever that comparator
happened to report, so the contrasts rest on different residual-confounding
assumptions, are printed side by side, and are read as a ranking that no single
contrast supports.

**Refuting sentence:** *per-comparator maximal adjustment minimizes each
contrast's own bias, so the ranking built from them is at least as good as one
built from a common intersection set, which throws away information the sponsor
holds.*

**The refuting sentence is the field's default position and section 2 predicts it
is wrong for rankings specifically.** That is the study.

## 2. The mechanism, algebraically, and it predicts an inversion

Let contrast $k$ be adjusted for set $S_k$, and let $\mathcal{M}$ be the true
modifier set. The transport bias of contrast $k$ is carried by the modifiers it
could not adjust for:

$$b_k \;=\; \sum_{m \in \mathcal{M}\setminus S_k} \beta_m \, d_{m,k}, \qquad d_{m,k} = \bar x_{m,\text{comparator }k} - \bar x_{m,\text{IPD}} .$$

A ranking is built from **differences** between contrasts, and the difference
between contrasts $k$ and $j$ is

$$\hat\Delta_k - \hat\Delta_j \;=\; \underbrace{(\Delta_k - \Delta_j)}_{\text{true efficacy difference}} \;+\; \underbrace{b_k - b_j}_{\text{adjustment heterogeneity}} .$$

Two regimes follow, and they point in opposite directions:

1. **Maximal per-comparator sets minimize each $|b_k|$ individually** and leave
   $b_k - b_j$ arbitrary, because the sets differ.
2. **A common intersection set makes $S_k = S_j = S$ for all $k$.** Each $b_k$ is
   then *larger*, since fewer modifiers are adjusted, but the omitted modifiers
   are the same ones, so $b_k - b_j = \sum_{m\notin S}\beta_m(d_{m,k}-d_{m,j})$
   collapses to a difference in comparator imbalances rather than a difference in
   which variables were used. **When the comparators' populations are similar,
   this difference is small even when each $b_k$ is large.**

**The prediction: the maximal set wins on per-contrast bias and the intersection
set wins on ranking accuracy, and both are true at once.** No published analysis
reports both, so the field is optimizing the first while reading the second. If
this inversion holds, the recommendation is not "use the intersection" but "use
both, and report which question each answers", which is a different and better
deliverable.

**On non-collapsible scales there is a second, separate defect**, stated by the
catalog: two contrasts conditioning on different sets are not estimands of the
same kind even in one population. Marginal standardization to a common target
repairs this **only if every set is sufficient**; where a nominated modifier is
missing, it does not, because the residual confounding is inside the
standardization. The design carries a collapsible arm precisely so this component
is separable from the bias-difference component above.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect for each of the four
IPD-versus-comparator contrasts, log hazard ratio in the survival arm.

**The ranking is a derived estimand and needs its own truth.** The true ordering
of the four comparators by target-population effect, computed from the generating
model. **Ranking error, not contrast bias, is the quantity the reading of these
tables actually depends on**, and it is what section 2 predicts inverts.

**True values** by quadrature over the target law at an order fixed by P1.

## 4. Data-generating mechanism, and what it makes invisible

One IPD trial, four aggregate comparators, mirroring the Fawsitt et al. geometry
rather than an invented one: nine candidate covariates, with reporting gaps
placed where that analysis found them (one covariate unreported by two
comparators, a block of four unreported by a third).

### Factors

| factor | levels | why |
|---|---|---|
| reporting pattern | Fawsitt-like; missing-at-random; adversarial (the strongest modifier unreported by the strongest comparator) | the adversarial arm is the one that decides whether this can flip a decision |
| effect-modification strength | 3 levels | the multiplier on every $b_k$ |
| comparator population similarity | similar; dispersed | **section 2's key axis**: similarity is what makes $b_k-b_j$ small under the intersection |
| true efficacy separation | comparators well separated; two nearly tied | ranking error is only interesting when the ranking is close |
| overlap | moderate; poor | the usual axis, held as a modifier of everything else |
| scale | collapsible (risk difference); non-collapsible (log HR) | separates the two defects in section 2 |

### What the mechanism makes true, and therefore what the study cannot see

- The true modifier set is known to the simulation and nominated correctly. What
  varies is only whether a comparator **reported** each one. The study therefore
  says nothing about modifier selection, which is COV-01's subject, and its
  results are optimistic for that reason.
- Comparator trials are exchangeable apart from their covariate distributions and
  their true efficacies. Inconsistency, differing follow-up and differing outcome
  definitions are absent, so every difference observed is adjustment
  heterogeneity by construction.
- All comparisons are unanchored, following the application. Anchored
  multi-comparator analyses have a common comparator that changes the algebra and
  are not covered.
- Reported summaries are exact. COV-12 and EST-07 own their reconstruction and
  sampling error.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| maximal per-comparator | each contrast on its own largest available set | the defensible default and current practice |
| common intersection | all contrasts on the intersection of the available sets | the coherent alternative |
| union with partial identification | where a comparator omits a nominated modifier, report **bounds** over a plausible range of its arm mean rather than dropping the term | the catalog's proposal, and the only arm that is honest about what is unknown |
| single network model | one covariate specification for all comparisons where summaries permit | ML-NMR's structural answer; available only in the reporting patterns that allow it, and that restriction is the point |

**The comparator that can win is the maximal per-comparator set.** If it beats the
intersection on ranking accuracy as well as on contrast bias, section 2's
inversion is wrong and current practice is vindicated. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Per contrast: bias, coverage, interval width, with MCSE.

**Per analysis, which is the level a reader works at:** probability the estimated
ranking of the four comparators differs from the truth; probability the top-ranked
comparator is wrong; and the **adjustment-heterogeneity diagnostic**, the
difference between maximal and intersection contrast sets, scored as a *predictor*
of ranking error with discrimination and calibration, following DIA-03.

The bounds arm is scored on interval coverage of the true contrast and on width,
since a bound that always covers by being uninformative is not a result.

Common random numbers across methods within a replicate; MCSE clustered on the
replicate block.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Probability of an incorrect top rank, maximal versus
intersection, in the adversarial reporting pattern with similar comparator
populations and close efficacies.

**Decision rule.**

- Intersection lower on ranking error **while** higher on per-contrast bias
  confirms section 2's inversion, and the deliverable is the paired-report
  recommendation.
- Maximal lower on both refutes the proposition and vindicates current practice.
- Intersection lower on both means the maximal set has no advantage at all, which
  section 2 says should not happen and would indicate the bias model is wrong.

**The diagnostic rule, registered separately.** The maximal-minus-intersection
difference is useful only if it reaches AUROC 0.75 for ranking error. Below that
it is reported as not fit for the purpose, since proposing a diagnostic and not
scoring it is what DIA-03 found the field already does.

## 8. Three controls, each of which can fail

**Null control.** With complete reporting, every method coincides and every
contrast is unbiased. Any divergence is an implementation fault.

**Second null control.** With reporting gaps but **zero effect modification**,
$\beta_m = 0$ makes every $b_k$ exactly zero, so the adjustment sets cannot
matter on any scale. Both methods must be unbiased and their difference must be
Monte Carlo noise. **This is the exact control that separates "different sets" from
"different sets that matter".**

**Positive control.** Adversarial reporting, strong modification, dispersed
comparator populations: the maximal set's ranking error must exceed the
intersection's by a detectable margin, or the design contains no case where the
mechanism bites and the study reports that as its answer.

**Falsifier for the study's own headline.** The expected headline is that
coherence beats accuracy for rankings. Its falsifier is the dispersed-population
cell: there $b_k - b_j$ under the intersection is **not** small, so the
intersection should lose. If the intersection wins even there, the advantage is
not the mechanism in section 2 and the explanation must be found rather than
assumed.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Ranking error measured without a true ranking | Truth computed per replicate from the generating model | removed |
| Intersection favored by a grid where comparators are always similar | Similarity is a registered factor with a dispersed level, and it is the falsifier | removed |
| Modifier selection confounded with reporting availability | True modifier set known and correctly nominated; only reporting varies | removed |
| Non-collapsibility confounded with residual confounding | Collapsible arm carried alongside | removed |
| The bounds arm wins by being uninformative | Width reported and a two-sided coverage rule applied | removed |
| Result specific to the Fawsitt geometry | Two further reporting patterns crossed | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and ranking | Per-contrast truths and the true ordering; whether the "nearly tied" level is tied enough to make ranking error informative and not so tied that it is a coin flip | The efficacy separation levels | minutes |
| **P2** bias budget | The analytic $b_k$ and $b_k-b_j$ per cell from section 2, before any fitting | **The grid.** Cells where the predicted inversion is below Monte Carlo resolution are dropped rather than run and reported as null | hours |
| **P3** bounds construction | Whether the partial-identification interval is computable at the survival scale and how wide it is at plausible ranges | Whether that arm is reportable | hours |
| **P4** unit cost | Per-replicate wall clock; total computed not typed | The grid | minutes |

## 11. Cost

Modest; weighting and parametric survival fits. Quoted after P4 only.

---

## Relationship to the rest of the queue

- **COV-01** owns modifier selection, held correct here.
- **COV-02** owns how the modifier set changes across effect scales, which
  interacts with the non-collapsible arm.
- **DEC-02** owns which analytic choice most often flips a decision; this is one
  such choice measured on its own.
- **EST-12** owns treatment hierarchies lacking a declared target referent, which
  is the population half of the same incoherence.
- **DEC-11** owns intervals omitting selection error, which is where the bounds
  arm's philosophy belongs.
