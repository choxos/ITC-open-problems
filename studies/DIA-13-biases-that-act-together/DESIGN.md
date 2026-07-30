# DIA-13 design: the cells a proponent has no incentive to run

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note orders this after a smaller classification-focused experiment,
which is **DIA-14**. That ordering is structural rather than convenient: DIA-14
establishes how to score a QBA honestly under one bias mechanism, and this design
uses that scoring across several. Running them in the other order would mean
inventing the metric and the crossing at once.

The catalog also rules out a Cartesian factorial explicitly: **the scenario set is
chosen by estimand, plausible mechanisms and the interactions that could change
the conclusion.** This design does that and says which cells it drops.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** QBA for unanchored PAIC has not been evaluated over a
design crossing bias mechanisms with the primary data-generating factors; the
decisive cells are the ones nobody runs, namely truth outside the elicited range,
cancelling biases, a misspecified bias model, non-confounding biases acting
jointly with omitted-variable bias, and correlated sensitivity parameters.

**Refuting sentence:** *biases combine approximately additively at plausible
magnitudes, so a one-at-a-time analysis bounds the joint effect and the crossed
design confirms what the marginal analyses already imply.*

## 2. The mechanism: bias composition is not addition

Let $\Delta$ be the target effect and let two bias mechanisms be indexed by
$\gamma_1$ and $\gamma_2$. The observed estimator converges to

$$\Delta^\star(\gamma_1,\gamma_2) \;=\; \Delta + b_1(\gamma_1) + b_2(\gamma_2) + b_{12}(\gamma_1,\gamma_2),$$

and the interaction term is generally nonzero because the mechanisms act on the
same estimator through different channels. Selection bias changes which units
enter the weighting; omitted-variable bias changes the conditional mean within
those units; the two therefore compose through the weights.

Four consequences, each naming a cell:

1. **Cancellation.** $b_1$ and $b_2$ can have opposite signs, so total bias can be
   small where each is large. **A one-at-a-time analysis reports two large
   sensitivities and the joint truth is fine; a joint analysis reports fine and the
   truth is fine for the wrong reason.** Either way the analyst learns something
   false about robustness.
2. **Reinforcement.** They can share a sign and the interaction can add to it, so
   the joint bias exceeds the sum of the marginals. **The one-at-a-time analysis
   is then anti-conservative**, which is the failure mode that matters for a
   decision.
3. **A misspecified bias model translates the whole sensitivity region**, as
   QBA-11's section 2 establishes for outcome-model misspecification: the region's
   width is right and its location is wrong.
4. **Correlated sensitivity parameters shrink the joint region** relative to an
   independent one, so a probabilistic QBA assuming independence can be either
   conservative or anti-conservative depending on the sign of the correlation and
   of the $b$'s. **That sign combination is enumerable and small**, so the design
   covers it exhaustively rather than sampling it.

**This is the same structure CMP-21 finds for one MNAR parameter entering three
layers**, and QBA-22 owns it as a general claim. If either has run, its framework
is imported; this design supplies the crossed evidence for unanchored PAIC
specifically.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect in an unanchored
comparison, by quadrature at an order fixed by P1.

**Derived, and imported from DIA-14 rather than redefined:** the robustness
classification, false reassurance, false fragility, and the tipping **set**.

**New here:** the **interaction term** $b_{12}$, with its true value computed from
the generating model, so section 2's claim is measured rather than inferred from
whether the joint result differs from the marginals.

## 4. Data-generating mechanism, and what it makes invisible

**Cells are chosen, not crossed.** The selection rule is declared in advance: a
cell is included if it can change a conclusion that a marginal analysis would
reach. The dropped cells are listed in the protocol with the reason, because a
"selected scenario set" without that list is indistinguishable from a convenient
one.

### The mechanism axis

| mechanism | why included |
|---|---|
| omitted confounder | the base case and the only one the leading paper treats |
| selection into the comparator source | acts through the weights, so it composes with the first non-additively |
| outcome misclassification | acts after the weights, a different channel again |
| differential censoring | the survival-relevant one |

Pairs are run, not all subsets: **omitted confounder with each of the other
three**, plus one triple. **That is four joint cells rather than fifteen**, chosen
because the entry's decisive claim is about composition rather than about
saturation.

### The crossed factors

| factor | levels |
|---|---|
| bias magnitudes | reinforcing; cancelling; one dominant |
| elicitation correctness | truth inside the region; truth outside |
| bias-model correctness | correct; misspecified |
| sensitivity-parameter dependence | independent; correlated, both signs |
| overlap | good, poor |

### What the mechanism makes true, and therefore what the study cannot see

- **Bias mechanisms are generated at declared magnitudes and are unidentifiable
  from the data.** Every result is sensitivity analysis by construction.
- The elicitation model is assumed, as in DIA-14, and results are reported as a
  function of it. **No empirical basis for it exists** and QBA-02 owns creating
  one.
- Unanchored comparisons only.
- The dropped cells are dropped by a declared rule, so the study cannot claim
  completeness. **It claims coverage of the interactions that could change a
  conclusion**, which is what the catalog asks for and is a weaker claim.

## 5. Methods, including one that can win

| method | role |
|---|---|
| one-at-a-time deterministic QBA | current practice, and the thing under test |
| joint deterministic QBA over the product region | the obvious extension |
| probabilistic QBA, independent priors | the interval-producing route |
| probabilistic QBA, correlated priors | section 2 consequence 4 |
| tipping-set reporting | DIA-14's comparator, carried forward |
| no QBA | the floor |

**The comparator that can win is one-at-a-time QBA.** If the marginal analyses
bound the joint bias across the selected cells, the refuting sentence holds, the
crossed design confirms rather than corrects, and the practical recommendation is
unchanged. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

DIA-14's classification measures, imported: false reassurance, false fragility,
truth inclusion, tipping-set cardinality, interval calibration, decision reversal,
expected regret.

**Plus the composition measures, which are this study's own:** observed $b_{12}$
against its analytic value; the **bounding rate**, the fraction of joint cells in
which the one-at-a-time region contains the joint truth; and the **direction of
failure**, since consequence 2's anti-conservative case is the one that matters
and consequence 1's is merely uninformative.

$n_{sim} = 4000$ per cell, following DIA-14's derivation from a false-reassurance
rate resolvable to 0.007.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The bounding rate of one-at-a-time QBA in the reinforcing
cells with the truth inside the elicited region.

**Decision rule.**

- Bounding rate materially below one **confirms** that marginal analyses are
  anti-conservative under reinforcement, and the deliverable is that joint
  analysis is required when mechanisms are known to act through different
  channels.
- Bounding rate at one across the selected cells **refutes** the proposition and
  the study says so.
- **The cancellation cells are reported separately in either branch**, because a
  high bounding rate achieved through cancellation is not reassurance, and
  reporting one number over both regimes would hide exactly the phenomenon in
  section 2 consequence 1.

## 8. Three controls, each of which can fail

**Null control.** With a single mechanism at zero magnitude, every QBA must
declare robust and no false fragility above nominal. This is also the check that
the composition machinery adds nothing when there is nothing to compose.

**Second null control, and it isolates additivity.** With two mechanisms that act
through the **same** channel, $b_{12}$ should be near zero and one-at-a-time should
bound the joint effect. **That cell establishes that the non-additivity found
elsewhere comes from channel difference and not from the magnitudes**, which is
the mechanistic claim.

**Positive control.** Two reinforcing mechanisms through different channels at
large magnitudes: $b_{12}$ must be materially nonzero and the one-at-a-time region
must fail to bound. If it does not fail there, non-additivity is unreachable and
the study says so.

**Falsifier for the study's own headline.** The expected headline is that joint
analysis is necessary. Its falsifier is the cost: joint analysis over a product
region grows exponentially in the number of mechanisms, and **if the joint region
is so wide that it is uninformative for every decision, then it is not a usable
alternative and the honest recommendation is tipping-set reporting instead.**
Region width is therefore reported beside every coverage result.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| An uninformative scenario catalog, which the note warns against | Cells chosen by a declared rule; dropped cells listed with reasons | removed |
| Non-additivity inferred rather than measured | $b_{12}$ computed analytically and compared | removed |
| Cancellation and reinforcement pooled into one bounding rate | Reported separately | removed |
| Joint region wide and useless, reported as successful | Width reported beside coverage | removed |
| Redefining DIA-14's metrics | Imported | removed |
| Completeness implied by a selected cell set | Claim restricted to conclusion-changing interactions | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P0** DIA-14 | The classification metrics. This design does not start until they exist | Everything | a study |
| **P1** truths and $b_{12}$ | The analytic marginal and interaction bias terms per cell | **The cell selection.** A pair whose analytic $b_{12}$ is negligible is not a conclusion-changing interaction and is dropped before running | days |
| **P2** cell-selection rule | The declared rule applied, with the dropped list | The design, and its honesty | hours |
| **P3** region width | The joint region's width at plausible magnitudes, to check the falsifier before committing | Whether joint analysis is a usable alternative at all | hours |
| **P4** unit cost | Per-replicate cost across the joint grid; total computed not typed | The grid | hours |

## 11. Cost

The joint region multiplies the QBA grid, and the grid was already this design's
largest multiplier in DIA-14. Priced in P4.

---

## Relationship to the rest of the queue

- **DIA-14** is a hard prerequisite and supplies every classification metric.
- **QBA-22** owns non-additivity of total bias as a general claim; this design is
  its unanchored-PAIC evidence, and if QBA-22 runs first its framework is
  imported.
- **QBA-11** owns what double robustness does not cover and supplies the
  region-translation result used in section 2 consequence 3.
- **CMP-21** finds the same composition structure for one parameter entering
  three layers.
- **QBA-02** owns the elicitation model this design has to assume.
