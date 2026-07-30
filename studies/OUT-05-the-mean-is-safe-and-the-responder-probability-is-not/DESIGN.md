# OUT-05 design: where the residual distribution enters, and where it does not

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog rejects the stronger form of its own source's claim, and the rejection is the
design's organizing principle.** Under an identity-link normal model the target-standardized
mean is the target expectation of the fitted conditional mean and **does not contain the
residual variance**, so heteroscedasticity affects **likelihood weighting, uncertainty,
shrinkage, predictive distributions and responder probabilities** rather than that marginal
mean.

**The sketch names the resulting contrast as the test**: stable mean estimates alongside
distorted responder estimates. **That is a within-analysis dissociation and it is exactly
the shape of a decisive experiment.**

The note requires selecting one bounded endpoint and one non-mean estimand, which this
design does.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** individual-level normal likelihoods use one residual standard
deviation for all IPD, which mis-weights studies with genuinely different dispersion and
misstates uncertainty; **where the estimand is a responder probability, a predictive
quantity or a tail summary rather than a mean, the residual distribution enters the reported
number and not only its interval**; and bounded instruments make the bias from ignoring
truncation itself population-dependent.

**Refuting sentence:** *responder probabilities computed under a pooled normal residual are
close enough to the truth at realistic dispersion differences and boundary masses that the
distinction is formal.*

## 2. The mechanism: a marginal mean that is safe, and everything else that is not

**The safe part.** With identity link and correctly specified conditional mean,

$$\Delta(F_T) \;=\; \int \{\mu_1(x) - \mu_0(x)\}\,dF_T(x),$$

which contains no residual variance term. **So a pooled $\sigma$ cannot bias the
target-standardized mean**, and any design reporting bias there would be reporting a
misspecified mean model rather than heteroscedasticity.

**The unsafe parts, and there are three:**

1. **Weighting.** A pooled $\sigma$ gives every IPD study the same per-observation
   precision, so studies with genuinely small dispersion are under-weighted and large ones
   over-weighted. **The mean stays unbiased and its interval does not**, and shrinkage of
   study-level parameters moves with it.
2. **Responder probabilities.** $P(Y > c \mid x) = \Phi\{(\mu(x)-c)/\sigma\}$ **contains
   $\sigma$ directly**, so a pooled value biases the reported probability even where the
   mean is exact. **And the bias direction depends on which side of the threshold the
   conditional mean sits**, so it does not average out over a population.
3. **Bounded scales.** Floor and ceiling masses are not tail heaviness; **a robust or skew
   density on the real line does not represent a boundary**, which the entry says
   explicitly. **And population adjustment shifts the covariate distribution relative to
   the floor or ceiling**, so the truncation bias is itself population-dependent: **the
   same model is more wrong in the target than in the source**, or less, depending on which
   way the shift goes.

**Consequence 3 is the PAIC-specific part.** Truncation bias in a single trial is a known
problem; **truncation bias that changes when you reweight is not**, and it is what makes
this more than an ordinary likelihood-choice question.

**The restriction is specific to the individual-level likelihood.** Aggregate contrast
synthesis ordinarily carries study-specific standard errors already, so the problem does not
arise there, and the design does not claim it does.

## 3. Estimand, with its true value defined

**Two primaries, deliberately paired.** The target-standardized **mean** contrast, and the
target-standardized **responder probability** contrast at a declared threshold, both by
quadrature over the true covariate law with the true conditional and residual structure.

**The pairing is the design.** Section 2 predicts the first is robust and the second is not,
and **a study reporting only one could not show the dissociation.**

## 4. Data-generating mechanism, and what it makes invisible

One bounded endpoint, per the note.

### Factors

| factor | levels | why |
|---|---|---|
| study-specific variance ratio | 1, 2, 5 | consequence 1 |
| skewness | none; moderate | shape, separate from dispersion |
| **floor or ceiling mass** | 0%, 10%, 25% | consequence 3 |
| **source-target overlap** | good, poor | **consequence 3's population dependence**, since the shift is what makes truncation bias move |
| responder threshold position | near the mean; in the tail | consequence 2's direction dependence |

**Boundary mass crossed with overlap is the design's PAIC-specific manipulation.**

### What the mechanism makes true, and therefore what the study cannot see

- **Aggregate publications report means and standard deviations only**, so **skewness and
  boundary piling in the comparator trial cannot be identified**, although **known scale
  bounds and extreme moments can flag a problem without identifying the distribution.**
  The design measures what a flag would catch and states that the distribution is not
  recoverable.
- One bounded endpoint and one non-mean estimand, per the note.
- The conditional mean is correctly specified throughout, so **every effect observed is
  residual-structure and not mean-model misspecification**; MOD-02 owns the latter.
- Aggregate contrast synthesis is out of scope, since it already carries study-specific
  standard errors.

## 5. Methods, including one that can win

| likelihood | role |
|---|---|
| common normal residual | the default under test |
| **study-specific residual variances with hierarchical shrinkage** | the entry's first proposal, for small study counts |
| skew-normal | shape without support |
| **support-respecting likelihood with point masses at the bounds** | consequence 3's remedy, which a skew density on the real line is not |

**The comparator that can win is the common normal residual.** Section 2's safe part says it
is correct for the mean, **so if responder probabilities are also close at realistic
boundary masses the refuting sentence holds** and the default is adequate. Registered as
such.

## 6. Performance measures, MCSE, and $n_{sim}$

**For the mean contrast:** bias, coverage and interval width. **Section 2 predicts bias near
zero and coverage failing**, so reporting both is what shows the split.

**For the responder contrast:** bias, coverage and width, **which section 2 predicts fails on
all three.**

**The dissociation measure**, which is the study's central output: the ratio of responder
bias to mean bias per cell. **A ratio far from one is the finding**, and a ratio near one
would mean the residual structure is reaching the mean and something in section 2 is wrong.

**Truncation bias against overlap**, which is consequence 3: the change in responder bias
when the target shifts relative to the boundary, at fixed boundary mass.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target-standardized **responder probability**
contrast under the common-normal likelihood, at 25% ceiling mass with poor overlap, against
the **mean** contrast in the same cells.

**Decision rule.**

- Responder bias material while mean bias is not: **the dissociation is confirmed**, and the
  deliverable is that the likelihood choice matters for the estimand and not for the mean,
  with the estimand deciding whether it matters at all.
- Both small: **refuted**, and the default is adequate for both.
- **Mean coverage is reported in every branch**, because section 2's safe part concerns the
  point estimate and not the interval, and a correct mean with a wrong interval is still a
  reporting failure.

## 8. Three controls, each of which can fail

**Null control.** With equal variances, no skew and no boundary mass, every likelihood must
coincide. **A difference is implementation.**

**Second null control, and it is section 2's safe part stated as a control.** With unequal
variances but no boundary mass and no skew, the **mean** contrast must be unbiased under the
common-normal likelihood **while its interval is wrong.** **Both halves must hold**, and if
the mean is biased there the catalog's correction is wrong and the whole design's framing
changes.

**Positive control.** 25% ceiling mass with poor overlap and a tail threshold: the
common-normal responder contrast must be biased by at least three MCSEs. **If not,
consequence 3 is unreachable.**

**Falsifier for the study's own headline.** The expected headline is that the estimand
decides whether the likelihood matters. Its falsifier is the flagging question: **if known
scale bounds and extreme reported moments reliably identify the cells where responder
estimates fail, then an analyst can detect the problem from published summaries and no new
likelihood is needed for the decision to be safe** — only for the number to be right. That
distinction is reported.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming the residual variance biases the standardized mean | Corrected in the header; the second null control tests it | removed |
| A skew density offered as a boundary model | Support-respecting likelihood carried separately; the entry's distinction kept | removed |
| Truncation treated as population-independent | Boundary mass crossed with overlap | removed |
| Aggregate contrast synthesis included | Out of scope; it already carries study-specific errors | removed |
| Distributional shape assumed recoverable from published summaries | Stated as unidentifiable; flagging measured instead | removed |
| Mean-model misspecification confounded | Conditional mean correct by construction | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Mean and responder truths per cell under the true residual structure | The definition of both truths | hours |
| **P2** boundary construction | Distributions with the requested boundary mass, skew and variance ratio that are jointly realizable | **The grid** | hours |
| **P3** flagging check | Whether known bounds and reported moments identify the failing cells, computed from summaries alone | **The falsifier**, and the cheapest deliverable | hours |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | minutes |

## 11. Cost

Small: normal and bounded-likelihood fits at 2000 replicates. **The cheapest study in this
batch**, which is why the note calls the component feasible.

---

## Relationship to the rest of the queue

- **CMP-16** owns the shared residual scale as a specification defect; **this owns what it
  costs and for which estimand.** They share a generator.
- **OUT-06** owns change scores and responder thresholds as estimand choices and shares the
  responder-probability machinery.
- **DIA-09** owns outcome families beyond the mean.
- **MOD-02** owns mean-model misspecification, held correct here.
