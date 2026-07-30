# SFW-08 design: an elpd that is not comparable across analyses

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note supplies the reframing that makes this a clean study: **around distinct
predictive estimands rather than a search for one agreed unit.** There is no single
natural held-out unit in a hierarchical model, so looking for one is looking for
something that does not exist.

The catalog also narrows the entry's four items to one. **Exposing log-prior
evaluations so `priorsense` power-scaling works is plumbing against a published
prescription. SUCRA credible intervals are arithmetic on the mean-rank posterior,
which `posterior_ranks()` already provides.** Those are implementation requests, not
methodological gaps, and this design says so rather than studying them.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the ML-NMR log-likelihood mixes patient-level IPD,
arm-level aggregate and study-level contrast contributions, so the leave-one-out unit
is heterogeneous, no unit selection or exact-refit fallback is exposed, and no
convention fixes which unit answers which predictive question.

**Refuting sentence:** *the mixed-unit elpd behaves monotonically with model quality
in practice, so it ranks models correctly even though its unit is heterogeneous, and
the ambiguity costs nothing.*

## 2. The mechanism: the elpd's scale depends on the data's granularity

The reported elpd is $\sum_i \log p(y_i \mid y_{-i})$ over whatever units the
log-likelihood enumerates. In ML-NMR those units are patients in IPD studies and arms
or contrasts in aggregate studies. Three consequences:

1. **The number of terms depends on the IPD proportion, not on the evidence.** Two
   analyses of the same network with different IPD availability sum over different
   numbers of terms, so **their elpd values are on different scales and are not
   comparable.** That is not a subtlety about interpretation; it is an arithmetic
   fact, and it means a reported elpd cannot be carried between analyses.
2. **Within one analysis the comparison can still be valid**, because the unit set is
   fixed across the models being compared. **So the refuting sentence may hold for
   model selection and fail for reporting**, and the design separates those two uses.
3. **The four candidate units answer four different questions.** Leaving out a patient
   asks about a new patient in a represented study; an arm asks about a new arm;
   a study asks about a new study; a treatment asks about a new treatment. **Only the
   last two speak to the transportability a PAIC analysis is for**, and the default is
   the first.

**Pareto-$k$ failure is a statement about the approximation, not about the model**,
and the entry insists on that. **A user who discards a valid fit because importance
sampling degraded has been misled by the diagnostic**, so the design reports refit
agreement wherever $k$ fails rather than treating failure as evidence.

## 3. Estimand, with its true value defined

**Four primaries, one per unit**: expected log predictive density for a new patient,
a new arm, a new study and a new treatment, each with its own held-out structure.

**True values by exact refit**, which is the reference the approximation is scored
against and is why the note says exact refits make this slower than a quick win.

**Model-selection accuracy is the derived estimand** for consequence 2: whether the
approximation ranks a known-better model above a known-worse one, per unit.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| IPD proportion | 1 of 8 studies; half; all | **consequence 1**, the scale problem |
| study heterogeneity | none, moderate, large | where study-level prediction is hard |
| leverage | one influential study; none | where Pareto-$k$ degrades |
| aggregate-data contribution | small; dominant | the unit mixture |
| model pair to select between | correctly and incorrectly specified interaction structure | consequence 2 |

### What the mechanism makes true, and therefore what the study cannot see

- **The three plumbing items are out of scope**, per the catalog: log-prior exposure,
  SUCRA intervals and the prior-versus-posterior plot are implementation against known
  prescriptions and studying them would spend the budget on solved problems.
- Exact refits are expensive, so **the grid is small and the study is deep rather than
  wide**, which the note anticipates.
- One network geometry, so the unit definitions are not confounded with topology;
  DIA-07 owns that.
- A treatment-level held-out unit requires the treatment to be droppable while the
  contrast remains estimable, **which is a rank condition checked per replicate** and
  is the same probe IDN-07 and CMP-06 need.

## 5. Methods, including one that can win

| method | role |
|---|---|
| default `loo` over the mixed unit | current behavior |
| **grouped PSIS-LOO at each of the four units** | the proposal |
| **exact refit at each unit** | the reference |
| **grouped fallback where Pareto-$k$ fails** | the missing safety net |

**The comparator that can win is the default mixed unit.** If it ranks models
correctly across the grid, consequence 2 holds, the refuting sentence is right for
selection, and **the deliverable narrows to a reporting warning about
comparability**, which is much cheaper than four diagnostics. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**Bias in expected log predictive density** of each approximation against its exact
refit, per unit; **Pareto-$k$ failure rate**, and, where it fails, **the agreement
between the approximation and the refit**, which is what tells a user whether a $k$
warning means anything for their model.

**Model-selection accuracy** per unit, which is consequence 2.

**The scale demonstration**, which is consequence 1: the same network analyzed at
three IPD proportions, with the elpd reported, showing directly that the values are
not comparable. **That is a two-line result and it is the most immediately usable
thing here.**

$n_{sim} = 200$ networks per cell, low because every replicate carries exact refits;
the count is derived in P2 from the refit cost rather than chosen.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of grouped PSIS-LOO against exact refit, at the **study**
unit, with a dominant aggregate contribution and one influential study.

The study unit is primary because consequence 3 says it is one of the two that speak
to transportability, and it is the one most likely to break the approximation.

**Decision rule.**

- Grouped PSIS-LOO approximating the refit well at every unit: **the deliverable is
  the four diagnostics plus the unit convention**, and the exact-refit fallback is
  needed only where $k$ fails.
- Grouped PSIS-LOO biased at the study unit: **exact refit or a grouped fallback is
  required there**, and the deliverable includes that requirement.
- **The scale non-comparability is reported in either branch**, because it is an
  arithmetic property and does not depend on the approximation's accuracy.

## 8. Three controls, each of which can fail

**Null control.** With all studies supplying IPD and no heterogeneity, the patient
unit is the natural one and the default `loo` must match its exact refit. **That is
the regime the approximation was built for**, and failure there is implementation.

**Second null control.** With one study only, every unit above the patient level
coincides, so all four diagnostics must agree. **Cheap, exact, and it checks the unit
definitions are implemented as described.**

**Positive control.** One influential study with large heterogeneity: Pareto-$k$ must
fail at the study unit in a substantial fraction of replicates. **If it never fails,
the fallback has nothing to fall back from** and the design has not reached the regime
the entry is about.

**Falsifier for the study's own headline.** The expected headline is that the unit
must be chosen deliberately. Its falsifier is consequence 2: **if all four units rank
the model pair identically in every cell, then for the use that actually matters,
model selection, the choice of unit is immaterial**, and the recommendation reduces to
the reporting warning.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Searching for one agreed unit | Reframed around four predictive estimands, per the note | removed |
| Studying the three plumbing items | Out of scope; identified as implementation against published prescriptions | removed |
| Pareto-$k$ failure read as a statement about the model | Refit agreement reported where $k$ fails | removed |
| A treatment-level unit that leaves the contrast unidentified | Rank condition checked per replicate | removed |
| Approximation scored without a reference | Exact refits throughout; $n_{sim}$ derived from their cost | removed |
| Unit definitions confounded with topology | One geometry; DIA-07 named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** unit definitions | What leaving out a patient, an arm, a study and a treatment means in this likelihood, written down before implementation | **The four estimands.** Implementing before defining is how a heterogeneous unit arose in the first place | days |
| **P2** refit cost and $n_{sim}$ | Cost of an exact refit per unit, from which the replicate count follows | The whole budget | days |
| **P3** rank condition | That a treatment can be dropped with the contrast still estimable in the planned geometry | Whether the fourth unit exists | hours |
| **P4** unit cost | Total, computed not typed | The grid | hours |

## 11. Cost

Exact refits dominate: one per held-out unit per replicate. **This is the most
refit-heavy design in the queue** and $n_{sim}$ is derived from that rather than
chosen.

---

## Relationship to the rest of the queue

- **CMP-24** owns leave-one-edge-out influence, which is the same unit question for a
  different purpose and shares the refit machinery.
- **EST-12** owns SUCRA's population referent; the SUCRA-interval item here is
  plumbing and that entry is the methodological one.
- **CMU-02** owns prior sensitivity, of which the power-scaling item is the
  implementation.
- **DIA-07** owns topology, held fixed here.
