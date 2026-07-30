# CMP-24 design: an influence ranking that is exact in the case nobody is worried about

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is precise about where the approximation actually sits, and it
corrects a plausible misreading in doing so: under random effects the fitted
$\tau^2$ **is** included in the weights, so the residual approximation comes from
not re-estimating $\tau$ under perturbation rather than from ignoring shrinkage.
That distinction determines what the reference calculation has to be, and getting
it wrong would make the whole study measure something else.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** `edge_influence()`'s diagonal-weight calculation is
exact for two-arm common-effect models and approximate for multi-arm studies and
under random effects; the dropped structure can change an influence ranking; and
the diagnostic matters precisely because it answers a question that overlap and
weight diagnostics cannot, so an incorrect ranking undermines the one tool that
answers it.

**Refuting sentence:** *the approximation preserves the ranking even where it
misstates the values, so the diagnostic's actual use, identifying which edges
carry the cross-gap contrast, is unaffected.*

**This refutation is the likely one and it is the useful one to establish.** An
influence measure is read as an ordering, not as a set of numbers, and a study
that reports value error without ranking error would answer the wrong question.

## 2. The mechanism: two dropped terms, with different behavior

Edge influence asks how much a given IPD edge contributes to a requested
target-specific contrast. The diagonal calculation treats each edge's
contribution through its own inverse-variance weight $w_e$, which under a random
effects fit already contains $\hat\tau^2$. Two things are dropped.

**The multi-arm term.** A multi-arm study's contrasts have a non-diagonal
within-study covariance $V_s$. The correct weight matrix is block-structured, so
the study's information does not decompose edge by edge:

$$W_s = V_s^{-1} \neq \mathrm{diag}(1/V_{s,ee}).$$

Because $V_s^{-1}$ has negative off-diagonals for a shared reference arm, the
diagonal calculation **overstates** each edge's independent contribution and
therefore compresses differences between the edges of a multi-arm study. Its
effect on a ranking is systematic, not random, and its direction is predictable:
multi-arm edges rise relative to two-arm edges.

**The heterogeneity re-estimation term.** Removing an edge changes $\hat\tau^2$,
which changes **every** weight in the network, not only the removed edge's. So

$$\frac{\partial(\text{contrast})}{\partial(\text{edge }e)} \;=\; \underbrace{\frac{\partial}{\partial e}\bigg|_{\tau \text{ fixed}}}_{\text{computed}} \;+\; \underbrace{\frac{\partial}{\partial \tau^2}\cdot\frac{\partial \hat\tau^2}{\partial e}}_{\text{dropped}} .$$

The dropped term is largest where $\hat\tau^2$ is poorly determined, which is
where the network is small, and it is **zero when $\tau^2 = 0$ is fixed**. So the
two dropped terms have separable null conditions, and section 8 uses exactly that
to test them one at a time.

**Why this diagnostic and not another.** The catalog's strongest sentence is that
this tool exposes edges with excellent effective sample size that nonetheless
carry no weight for the cross-gap contrast, which standard MAIC overlap and
weight diagnostics cannot answer. **That is the same structural point OVL-01 and
DIA-03 make from the other side**: weight statistics are functions of covariates
and weights, and contribution to a *particular contrast* is a row-space property.
An influence measure is the only member of the panel that is.

## 3. Estimand, with its true value defined

**Primary.** Each IPD edge's influence on the requested target-specific
population-adjusted contrast.

**True value by an operational reference, and this is the design's key choice.**
Influence is defined here as the change in the target contrast's estimate and
variance when the edge is removed and the model **fully refitted, including
re-estimation of $\tau^2$ and the weights**. That is leave-one-edge-out
refitting, it is expensive, and it is exactly what the approximation approximates.
Rücker et al.'s variance-reduction definition of study importance is the
established form of this and is adopted rather than reinvented.

**A reference that shares the approximation's assumptions is not a reference**,
which is why the refit re-estimates $\tau$: fixing $\tau$ in the reference would
make the second dropped term invisible and the study would report that half of
the approximation is exact.

**Ranking truth is the derived estimand:** the ordering of edges by the reference
influence, and the identity of the single most influential edge.

## 4. Data-generating mechanism, and what it makes invisible

Component networks with two subnetworks joined by a shared component, IPD on some
edges, so that a target-specific cross-gap contrast exists and edges differ in
their contribution to it.

### Factors

| factor | levels | why |
|---|---|---|
| multi-arm structure | all two-arm; one three-arm; two three-arm and one four-arm | the first dropped term |
| heterogeneity | $\tau^2 = 0$ fixed; small; large | **the second dropped term, and $\tau^2=0$ is its null** |
| network size | 8 studies, 16 studies | how well $\hat\tau^2$ is determined |
| topology | star; ladder; one bridging edge only | whether influence is concentrated or spread |
| covariate overlap | good, poor | the population-adjustment layer, which is what makes this contrast target-specific |
| edge influence spread | edges nearly equal; one dominant | **a ranking is only at risk when edges are close**, and a grid without close edges cannot detect ranking error |

### What the mechanism makes true, and therefore what the study cannot see

- The frequentist CNMA fit is correctly specified. Influence under
  misspecification is a different question and mixing them would be
  uninterpretable.
- Only IPD edges are perturbed, matching the diagnostic's scope. Aggregate-edge
  influence is a related but separate object.
- One requested contrast per network. In practice an analyst asks about several,
  and whether a single edge ordering serves all of them is not tested.
- The reference is leave-one-edge-out, which is itself a definition of influence
  rather than the definition. Where the published exact decompositions (Yang et
  al.'s pseudo-path hat matrix, the flow-network proportion contribution) apply to
  the unadjusted component effects, they are computed alongside and their
  agreement with the refit reference is reported. **Disagreement there would be a
  finding about the definitions, and it must not be silently averaged away.**

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| diagonal approximation | `edge_influence()` as implemented | the thing under test |
| diagonal + multi-arm covariance | block weights, $\tau$ still fixed | isolates the first dropped term |
| Jacobian/Hessian influence | first-order with $\partial\hat\tau^2/\partial e$ included | the cheap route to the second term |
| **leave-one-edge-out refit** | full refit with $\tau$ re-estimated | the reference |
| exact contribution decomposition | Yang et al. and the flow-network matrix, on the unadjusted component effects where applicable | the published machinery, tested for whether it extends |

**The comparator that can win is the diagonal approximation itself**, on rankings.
If its Spearman correlation with the reference exceeds a registered threshold in
every cell and it identifies the top edge as often as the exact calculation does,
the approximation is fit for its purpose and the recommendation is to report its
approximation status and stop. Registered as the outcome most likely to overturn
the expected headline, and section 2 gives a reason to expect it: the multi-arm
distortion is **systematic**, and a systematic distortion preserves ordering
within each group.

## 6. Performance measures, MCSE, and $n_{sim}$

Influence-value error against the reference, absolute and relative; **Spearman
rank correlation** with the reference ordering; the probability of identifying
the truly most influential edge; and the probability of a **sign error**, meaning
declaring an edge influential when the reference gives it essentially none, which
is the failure the catalog cares about because that is what the diagnostic is
consulted for.

**Decomposed by dropped term**, using the intermediate arms: the multi-arm
correction alone and the $\tau$-re-estimation correction alone, so the study
reports which of the two matters rather than that "the approximation is
approximate".

MCSE on all, clustered on the network replicate since every method is computed on
the same fitted network. $n_{sim} = 1000$ networks per cell; the refit reference
costs $E$ refits per network, and P3 prices that.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Spearman rank correlation between the diagonal
approximation and the leave-one-edge-out reference, in networks with multi-arm
studies, large heterogeneity and closely spaced edge influences.

**Decision rule.**

- Rank correlation below 0.9, **or** the top edge misidentified in more than 10%
  of replicates, in any cell: the approximation is not fit for the ranking use and
  the correction that closes the gap is named from the decomposition.
- Both thresholds met everywhere: the approximation is adequate, and the
  deliverable is the reporting requirement to state its status, which the catalog
  asks for regardless.
- Values badly wrong but rankings preserved: **that is the expected pattern and it
  is reported as the answer**, with the recommendation that influence be reported
  as an ordering rather than as numbers.

**Thresholds are registered now**, because "reasonably close" applied after
seeing a scatter plot is not a decision rule.

## 8. Three controls, each of which can fail

**Null control.** Two-arm studies with $\tau^2 = 0$ fixed: the catalog states the
diagonal calculation is **exact** there, so agreement with the reference must be
to numerical precision, not to Monte Carlo error. **This is the sharpest control
available in the queue**, because an exactness claim either holds to machine
precision or the implementation differs from its description.

**Second null control.** Two-arm studies with $\tau^2$ estimated: only the second
dropped term is active. Multi-arm studies with $\tau^2 = 0$ fixed: only the first.
**Running both isolates the two terms, and the decomposition in section 6 is only
interpretable because these cells exist.**

**Positive control.** Multi-arm studies, large heterogeneity, small network: the
diagonal approximation's value error must exceed a detectable margin. If it does
not, the approximation is adequate everywhere reachable and the study says so.

**Falsifier for the study's own headline.** The expected headline is that the
approximation is safe for ranking. Its falsifier is the closely-spaced-edges cell
combined with multi-arm structure, where section 2's systematic compression
should flip adjacent pairs. **If no flips occur even there, the systematic
distortion never reaches the ordering and the headline strengthens; if flips occur
only there, the recommendation is conditional on edge spacing, which is
something an analyst can check.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reference sharing the approximation's assumption | Reference re-estimates $\tau$; stated as the reason | removed |
| "Approximation is approximate" reported without saying which term | Two intermediate arms isolate the terms | removed |
| Ranking error undetectable because edges are far apart | Edge-influence spread is a registered factor | removed |
| Exactness claim tested at Monte Carlo tolerance | Tested at numerical precision in the two-arm fixed-$\tau$ cell | removed |
| Disagreement among published influence definitions averaged away | Reported as a finding | removed |
| Thresholds chosen after seeing results | Registered in section 7 | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** exactness verification | That the diagonal calculation reproduces the reference to numerical precision in the two-arm fixed-$\tau$ case | **Everything.** If the documented exact case is not exact, the description of the approximation is wrong and the design's decomposition is built on a false premise | hours |
| **P2** edge-spread construction | Networks whose reference influences are close by construction, so ranking error is reachable | The grid | hours |
| **P3** refit cost | Cost of $E$ refits per network times $n_{sim}$ | $n_{sim}$, and possibly a switch to a subsample of edges per network, which would then be declared rather than silent | hours |
| **P4** decomposition applicability | Whether Yang et al.'s and the flow-network decompositions can be evaluated on these networks at all | Whether that arm exists | hours |

**P1 costs almost nothing and can invalidate the study**, which makes it the
first thing to run.

## 11. Cost

The reference dominates: leave-one-edge-out refitting is $E$ fits per network.
Frequentist CNMA fits are fast, so this is likely affordable, but "likely
affordable" is what OUT-11 said about a bootstrap that then dominated its run.
Priced in P3; no total quoted here.

---

## Relationship to the rest of the queue

- **CMP-12** owns multi-arm covariance in the two-stage adjusted estimator, which
  is the same $V_s$ appearing one stage earlier; if both run they share the
  generating mechanism.
- **HET-02** owns multi-arm covariance lost by pairwise adjustment.
- **DIA-03** and **OVL-01** establish that weight and overlap statistics cannot
  answer contrast-specific questions, which is this diagnostic's reason to exist.
- **SFW-08** owns the leave-one-out unit for mixed likelihoods, which is the same
  question about what a unit of evidence is.
- **DIS-21** owns match acceptance thresholds against bridge bias, which is what
  a bridging edge's influence would inform.
