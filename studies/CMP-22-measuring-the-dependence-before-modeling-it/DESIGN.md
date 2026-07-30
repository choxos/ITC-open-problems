# CMP-22 design: leave-IPD-out first, because it measures what no model can identify

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The premise has empirical support: a survey of 31 IPD meta-analyses found **16 (52%) did
not obtain all the individual participant data requested**, five of those **did not mention
it as a limitation**, and **only six examined how the trials without IPD might affect
conclusions.**

The catalog is careful that **nonrandomness has to be demonstrated or posited as a
sensitivity assumption rather than assumed categorically**: availability can be modeled
where it depends on observed trial-level variables, and **only selection on unobserved
IPD quantities is unidentified.** The note orders this after more identifiable problems
for the same reason.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** component PAIC conditions on the supplied IPD with neither a
selection model nor grouped leave-IPD-out validation; **the IPD edges are the ones that
get population-adjusted and the ones that inform interaction parameters**, so a selection
mechanism propagates into which parts of covariate space are informed by causal evidence
rather than by aggregate association.

**Refuting sentence:** *availability depends on sponsorship and data-sharing policy rather
than on effect-relevant characteristics, so it is ignorable given observed trial variables
and the unidentified case is a theoretical residue.*

## 2. The mechanism: selection determines which coordinates are causally informed

IDN-06's decomposition applies directly. An interaction's information splits into a
within-study term from IPD studies and a between-study term from aggregate ones. **So the
set of IPD studies determines which interaction coordinates carry within-study evidence**,
and a selection mechanism on availability is a selection mechanism on that set. Three
consequences:

1. **Selection on observed trial-level variables is modelable**, by weighting or by
   including those variables, and this is the identified half. **The design measures
   whether the adjustment works rather than assuming it.**
2. **Selection on unobserved IPD quantities cannot be estimated from within the network**,
   because the trials with unobserved IPD are precisely the ones that would identify it.
   **That is a closed argument, not a gap to be filled**, and the design does not offer a
   correction for it; it offers a sensitivity assumption with a stated selection model.
3. **Grouped leave-IPD-out measures the dependence without identifying the mechanism**,
   which is why the entry says implement it first. **It answers "how much do conclusions
   depend on which trials contributed individual data", which is a different and
   answerable question**, and it is the design's primary.

**The estimability consequence is specific to component models.** Which cross-gap
contrasts are estimable depends on which edges carry IPD, so **a selection mechanism can
change what is estimable at all**, not merely how precise it is. That is the rank
condition CMP-06 and DIA-07 also turn on, and it is checked per replicate.

## 3. Estimand, with its true value defined

**Primary.** The target-population component and treatment contrasts, by quadrature at an
order fixed by P1, **reported conditional on estimability** as in CMP-06.

**Two derived estimands.** **Leave-IPD-out influence**: the movement of the target
contrast when each IPD study's individual data are withheld and it reverts to aggregate;
and **the diagnostic's ability to flag influential IPD subsets**, scored against the
generated selection strength.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| proportion of trials supplying IPD | 1/4, 1/2, 3/4 | how much is missing |
| **selection on observed trial variables** | none; moderate; strong | consequence 1's identified half |
| **selection on latent effect modification** | none; moderate; strong | consequence 2's unidentified half |
| covariate overlap | good, poor | the adjustment layer |
| network size | 8, 16 studies | how much redundancy absorbs a missing IPD study |

**The two selection axes crossed is the design**, because the entry's whole point is that
one is modelable and the other is not, and a design varying only one could not show the
difference.

### What the mechanism makes true, and therefore what the study cannot see

- **Selection on unobserved quantities is unidentified**, and the design reports what a
  stated sensitivity model gives rather than a correction. **No arm claims to recover it.**
- **Federated approaches are the only route that addresses the cause rather than the
  symptom**, and they require access or assumptions currently unavailable. Named, not
  simulated.
- The selection mechanism is known to the simulation; **an analyst's is not**, so the
  study measures what a diagnostic would see, not what they should assume.
- One outcome family.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive analysis conditioning on supplied IPD | current practice |
| **observed-variable selection adjustment** | consequence 1's identified half |
| **grouped leave-IPD-out diagnostic** | consequence 3, the entry's stated first step |
| sensitivity model over latent selection strength | consequence 2's honest form |

**The comparator that can win is naive analysis.** If availability's effect on the target
contrast is small across the realistic grid, the refuting sentence holds and the
recommendation is the leave-IPD-out diagnostic as a reporting item rather than a
correction. **Registered as such**, and it is the outcome the note's ordering anticipates.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target contrasts per method per cell, **conditional on
estimability**, with MCSE; **the estimability rate itself**, since consequence 2's
last paragraph says selection can change what is estimable.

**Leave-IPD-out influence** and its **correlation with the generated selection strength**,
which is the diagnostic's operating characteristic and the primary.

**The identified-versus-unidentified split**: adjustment performance under observed-variable
selection against under latent selection, reported separately. **Pooling them would report
a correction working where it cannot.**

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Correlation between leave-IPD-out influence and the target contrast's
bias, under latent selection at half IPD availability.

**Decision rule.**

- Influence tracking bias: **the diagnostic works as a warning even where no correction
  exists**, and the deliverable is grouped leave-IPD-out as a required output.
- Influence uncorrelated with bias: the diagnostic measures something else and should not
  be recommended as a warning, which is worth establishing before it is implemented.
- **Observed-variable adjustment's performance is reported separately in either branch**,
  since it is the half that can be corrected.

## 8. Three controls, each of which can fail

**Null control.** With random IPD availability, every method must be unbiased and
leave-IPD-out influence must reflect information loss only, not bias. **A correlation
between influence and bias there means the diagnostic is picking up precision rather than
selection.**

**Second null control.** With selection on observed trial variables only, the adjustment
must remove the bias entirely. **That is the identified case and confirming it licenses
the claim that the latent case differs.**

**Positive control.** Strong latent selection at quarter IPD availability: naive analysis
must be biased and no method may fully correct it. **If some method corrects latent
selection, the identifiability argument in consequence 2 is wrong**, which would be a
major finding and the design must be able to detect it.

**Falsifier for the study's own headline.** The expected headline is that grouped
leave-IPD-out should be implemented. Its falsifier is redundancy: **in a network with
enough aggregate evidence, withholding one study's IPD may move nothing, so the diagnostic
returns zero influence while the selection bias is real and shared across all IPD
studies.** **Selection acts on the set, and leave-one-out probes one member at a time**,
which is a structural limitation the design must report rather than discover.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Assuming nonrandom availability categorically | Both selection axes are factors including a none level | removed |
| Offering a correction for the unidentified case | Sensitivity model only, with the argument stated | removed |
| Identified and unidentified selection pooled | Reported separately | removed |
| Bias averaged over non-estimable replicates | Conditional on estimability; rate reported | removed |
| Leave-one-out probing a set-level mechanism | Stated as the falsifier in section 8 | disclosed |
| Federated routes | Named, not simulated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and estimability map | Target truths and which contrasts are estimable under each IPD configuration, before fitting | **The grid and the conditioning** | hours |
| **P2** selection constructibility | That observed-variable and latent selection can be varied independently at matched availability rates | **The design's crossing** | days |
| **P3** leave-one-out sensitivity | Whether withholding one study's IPD moves the contrast detectably at the planned network sizes | **The falsifier**, checked before the run | hours |
| **P4** unit cost | Per-fit cost times IPD studies for the leave-out loop; total computed not typed | $n_{sim}$ | hours |

**P3 is cheap and could establish that the primary diagnostic is inert**, which would
redirect the study toward the set-level question instead.

## 11. Cost

The leave-IPD-out loop refits once per IPD study per replicate, so the IPD count
multiplies the design. Priced in P4.

---

## Relationship to the rest of the queue

- **IDN-06** supplies the within-versus-between decomposition that makes IPD placement
  determine which coordinates are causally informed.
- **DIA-07** owns placement at fixed information as a topology question; **this owns
  placement chosen by a mechanism.**
- **DIA-10** owns informative IPD availability as one of several access mechanisms and
  shares the availability model.
- **CMP-06** and **SFW-08** own the estimability and leave-one-out-unit machinery.
- **MIS-01** owns participant-level missingness, the same idea one level down.
