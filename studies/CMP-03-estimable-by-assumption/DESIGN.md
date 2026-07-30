# CMP-03 design: the screen returns estimable for exactly the extrapolations that are assumption

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note requires narrowing to omitted-interaction sensitivity for one outcome family
and network design, and this design does that. **But the entry contains something
sharper than its own headline, and the design leads with it.**

**Under strict additivity a never-administered regimen lies inside the row space**, so
an estimability screen returns *estimable* for it. Its estimate, interval and rank are
then printed exactly like a randomized regimen's. **The screen is doing its job and
the output is indistinguishable from evidence.** Applied reviews act on this: one
component analysis estimates 27 daratumumab-based regimens, states that some have never
been reported, and **recommends a never-reported one in its abstract**; another reports
and recommends a specific three-component package while stating that **no trial arms
used that combination.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** strict additivity can be clinically false; interaction CNMA
relaxes it but data-driven selection of interaction structures performs poorly in
disconnected networks; no method bounds how far an omitted component interaction could
move a target cross-gap contrast; and additivity is what makes a never-administered
combination estimable, so **every estimability screen returns estimable for exactly the
extrapolations that are most assumption-driven.**

**Refuting sentence:** *the interactions that additivity omits are small enough at
realistic magnitudes that a de novo regimen's predicted effect is close to its true
one, so the reporting concern is about presentation rather than about accuracy.*

## 2. The mechanism: additivity is what reconnects the network and what licenses the extrapolation

**Why the screen cannot help.** With component design matrix $C$, a regimen $r$'s effect
under additivity is $\sum_{k \in r}\beta_k$, which is in the row space of $X(C)$
whenever every component appears somewhere. **So estimability is a statement about
component coverage, not about combination evidence**, and a regimen whose components
were never co-administered is estimable by exactly the same computation as one that was.

**A provenance quantity is definable and is the design's deliverable.** For regimen
$r$, the fraction of its predicted effect carried by component pairs never
co-administered:

$$\rho(r) \;=\; \frac{\sum_{\{j,k\}\subset r,\ \text{never co-administered}} |\hat\beta_j + \hat\beta_k|}{\sum_{\{j,k\}\subset r} |\hat\beta_j + \hat\beta_k|}$$

or a variance-weighted analogue fixed in P1. **$\rho$ is computable from the design
matrix alone, before any outcome data**, and it separates a regimen whose combination
has been observed from one assembled entirely by assumption. **Nothing currently
reports it.**

**Three further consequences:**

1. **Adding interaction terms consumes the degrees of freedom the bridge depends on.**
   Additivity is what reconnects a disconnected network, so relaxing it removes the
   reconnection. **The contrasts that would discriminate between candidate interaction
   structures are the ones spanning the gap**, which is why data-driven selection was
   found to recover the right model rarely and to fall back on sparse additive models
   even when additivity is violated.
2. **Therefore prespecification and heredity constraints, not selection.** The entry
   says so and the design does not re-test forward selection except as the known-bad
   comparator.
3. **An omitted-interaction bound is the missing object.** How far a target cross-gap
   contrast could move under unmodeled synergy is not computable from any current
   method, and **deriving it is the study's second deliverable**: a bound over a
   declared range of interaction magnitudes, given the observed combination structure.

## 3. Estimand, with its true value defined

**Primary.** The target-population cross-gap regimen contrast, by quadrature at an order
fixed by P1.

**Two derived estimands.** **$\rho(r)$**, whose truth is a property of the design matrix
and is exact; and the **fraction of the contrast determined by shrinkage rather than by
likelihood information**, using CMP-14's prior-free marginal precision, which the entry
asks for explicitly.

**The omitted-interaction bound is a third**, with its truth being the actual movement
under the generated synergy.

## 4. Data-generating mechanism, and what it makes invisible

One outcome family and one network design, per the note.

### Factors

| factor | levels | why |
|---|---|---|
| interaction magnitude | 0, mild, strong synergy | the violation |
| **observed component combinations** | all pairs observed; **some pairs never co-administered** | **the mechanism in section 2**, and the case the applied reviews are in |
| interaction hierarchy | respects heredity; does not | whether a constraint helps |
| interaction sparsity | one pair; several | how much is omitted |
| covariate overlap | good, poor | the adjustment layer |
| subnetwork drift | absent; present | the bridge's other assumption |

### What the mechanism makes true, and therefore what the study cannot see

- **Additivity cannot be assessed statistically in disconnected networks**, which the
  entry states. **So no arm here tests additivity across the gap**; the design measures
  what an untestable violation costs and what a bound would say.
- The global-plus-drift decomposition needs reference or zero-mean constraints to
  separate the global and drift terms; **P2 fixes them**, because an unidentified
  decomposition would make every drift result an artifact of the parameterization.
- One outcome family, per the note.
- **Data-driven forward selection is carried only as the known-bad comparator**, since
  its failure is established and re-establishing it would waste the budget.

## 5. Methods, including one that can win

| method | role |
|---|---|
| strict additive CNMA | the status quo, and what makes de novo regimens estimable |
| **prespecified interaction CNMA** | interactions chosen for estimability given observed combinations |
| **heredity-constrained sparse selection** | the constrained alternative |
| forward selection | the known-bad comparator |
| **additive fit reported with $\rho$ and the shrinkage share** | the reporting proposal, requiring no new estimator |

**The comparator that can win is the additive fit with provenance reporting.** If
strict additivity's bias is tolerable and $\rho$ successfully separates the regimens
where it is not, **then the fix is a reporting requirement rather than a model**, which
is far cheaper to adopt. **Registered as such, and it is the outcome the design most
expects.**

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and interval width of the cross-gap contrast per method per cell, with
MCSE, **reported separately for regimens whose combinations were observed and for de
novo ones.** Pooling them would average the case the entry is about into the case it is
not.

**$\rho$ scored as a predictor of de novo regimen error**, with AUROC and calibration
following DIA-03. **If $\rho$ does not discriminate, the provenance quantity is not the
right one and the design says so rather than recommending it.**

**The shrinkage share** for every cross-gap contrast, per the entry's request.

**Bound tightness and containment** for the omitted-interaction bound.

$n_{sim} = 1000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the strict additive fit for **de novo
regimens whose component pairs were never co-administered**, at strong synergy.

**Decision rule.**

- Material bias with intervals that do not cover, while the screen reported the regimen
  estimable: **confirmed in its sharpest form**, and the deliverable is $\rho$ plus a
  requirement that a de novo regimen's provenance be reported beside its estimate.
- Bias tolerable: **refuted**, and the reporting concern is about presentation, which
  the study says plainly.
- $\rho$ failing to discriminate: the provenance quantity needs redefining, and the
  variance-weighted alternative from P1 is reported instead.

## 8. Three controls, each of which can fail

**Null control.** With zero interaction, additivity is true, so every method must be
unbiased **including for de novo regimens**, and $\rho$ must not predict error because
there is none. **That is the case in which extrapolating to a never-administered
combination is legitimate**, and establishing it is what makes the failure elsewhere
attributable to synergy rather than to extrapolation as such.

**Second null control.** With all pairs observed, $\rho = 0$ for every regimen and the
de novo distinction disappears. **Every method must behave as it does in an ordinary
CNMA.** Cheap, and it isolates the combination-coverage mechanism from the interaction
magnitude.

**Positive control.** Strong synergy on a pair never co-administered, in a regimen the
screen reports estimable: bias must exceed three MCSEs **and** the estimability screen
must report estimable. **Both halves are required**, because the second is the entry's
central observation and a design that only showed bias would have missed it.

**Falsifier for the study's own headline.** The expected headline is that provenance
must be reported. Its falsifier is the null control extended: **if de novo regimens are
no worse than observed ones once synergy is present in both, then the problem is synergy
and not novelty**, and $\rho$ is measuring the wrong thing.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming interaction CNMA does not exist | Credited; prespecified interactions are an arm | removed |
| Re-establishing that forward selection fails | Carried as the known-bad comparator only | removed |
| De novo and observed regimens pooled | Reported separately | removed |
| A provenance quantity recommended without scoring it | Scored as a classifier; an alternative definition is pre-registered | removed |
| Unidentified global-plus-drift decomposition | Constraints fixed in P2 | removed |
| Testing additivity across a gap | Not attempted; the entry says it cannot be done | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** provenance definition | Both candidate forms of $\rho$ on the planned designs, before any outcome data | **The deliverable's definition**, and it is free | hours |
| **P2** decomposition constraints | Reference or zero-mean constraints separating global from drift terms, verified to identify | **Every drift result** | days |
| **P3** estimability confirmation | That the screen does return estimable for the planned de novo regimens | **The entry's central observation**, checked before it is built on | hours |
| **P4** unit cost | Per-fit cost; total computed not typed | $n_{sim}$ | hours |

**P3 costs an hour and confirms the premise**, which makes it the first thing to run.

## 11. Cost

Component network fits, mostly frequentist; modest. The prespecified-interaction and
heredity arms add parameters rather than expense.

---

## Relationship to the rest of the queue

- **CMP-06** owns miscoding, which changes the row space discretely; this owns what the
  row space licenses when the coding is right.
- **CMP-14** supplies the prior-free precision for the shrinkage share.
- **CMP-18** owns time-varying component effects, another way additivity in the fitted
  summaries can fail while holding in truth.
- **IDN-08** and **DIS-11** own bridge validation, which is what would let additivity be
  checked across a gap.
- **EST-12** owns rankings, which is where a de novo regimen's rank is printed beside a
  randomized one's.
