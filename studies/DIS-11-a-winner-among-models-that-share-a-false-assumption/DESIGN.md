# DIS-11 design: cross-validation returns a winner either way

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note calls this a clean diagnostic-discrimination question with direct consequences
for every PAIC family, and the checks under test **are shipping**: `multinma`'s
disconnected-network pull request lists LOO-PSIS cross-validation and
`compare_populations()` as the tests accompanying those fits.

The entry also supplies two qualifiers the design must carry. **Predictive checks can
falsify observable restrictions**, and validation using external cross-gap evidence or
synthetic deletion **does** have leverage. And **population comparison is not logically
required for component, class or mechanistic bridges**, so a similarity table is not
even the right check for some of them.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** predictive criteria computed on observed within-subnetwork
units cannot establish the correctness of an unobserved cross-gap extrapolation, and
**leave-one-out will still return a winner when every candidate shares a false bridge
assumption**; population comparison is computed over reported covariates while the
bridge requires exchangeability with respect to every variable creating cross-study
outcome differences.

**Refuting sentence:** *models that differ in bridge assumption also differ in
within-subnetwork fit enough that predictive criteria rank them correctly, so the check
has more leverage than the argument allows.*

## 2. The mechanism: a relative criterion cannot see a shared error

Leave-one-out compares candidates by fit to **observed** units. Write each candidate's
cross-gap error as $e_m = e_m^{\text{obs}} + e^{\text{bridge}}$, where the second term
is common when every candidate shares the assumption. Then

$$\arg\min_m \widehat{\mathrm{elpd}}_m \;=\; \arg\min_m e_m^{\text{obs}},$$

**and $e^{\text{bridge}}$ drops out of the ranking entirely.** Three consequences:

1. **The criterion returns a confident winner whose cross-gap error is arbitrary**, and
   nothing in the output signals it. **A ranking reads as validation to a user who does
   not check what was held out.** This is the same structure CMU-01 finds for the
   split-chain integration check and MOD-15 finds for the pooling rule: **a relative
   comparison passes when both sides are wrong in the same direction**, and it recurs
   often enough in this queue to be a pattern rather than a coincidence.
2. **Grouped validation at the study or subnetwork level comes closer**, because
   holding out a subnetwork forces a prediction across something like the gap. **It is
   unimplemented in the tools the auditors inspected**, and SFW-08 owns the unit
   question generally.
3. **Synthetic deletion has real leverage** precisely because the deleted contrast is
   observed. IDN-08 owns whether that leverage transfers to a real gap; **this design
   establishes that it exists**, which IDN-08 presupposes.

**Population comparison has a different failure.** It is computed over **reported**
covariates while the bridge needs exchangeability over every variable creating
cross-study outcome differences, **so it cannot rule out unmeasured prognostic or design
differences.** And a favorable similarity table is easy to produce and looks like
evidence, so it is presented as justification **even for bridges whose assumption is not
about population overlap at all** — which is the component and mechanistic case, where
it is not merely weak but irrelevant.

## 3. Estimand, with its true value defined

**Primary.** The marginal treatment effect in a held-out population, by quadrature at an
order fixed by P1.

**The derived estimand is diagnostic discrimination**: each check's ability to rank
models by **cross-population bias and interval coverage**, which is the quantity that
matters and which the checks are not computed on.

**The truth is available because the design deletes a link whose contrast is observed**,
so the cross-gap answer is known. That is the only reason discrimination is measurable
at all.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| measured effect-modifier imbalance | small, large | what population comparison can see |
| **unmeasured effect-modifier imbalance** | none, moderate, large | **what it cannot**, and the design's core contrast |
| bridge misspecification | correct; misspecified in one direction; **misspecified identically across all candidates** | **consequence 1**, generated directly |
| overlap | good, poor | the adjustment layer |
| bridge type | population-exchangeability; component; mechanistic | where population comparison is not even the right check |

**The shared-misspecification level is the design.** Without it, consequence 1 cannot be
observed, and no existing study generates it.

### What the mechanism makes true, and therefore what the study cannot see

- **The deleted link's contrast is observed**, which is what makes truth available and
  is also the limitation IDN-08 owns: whether a cut link resembles a real gap.
- **Predictive checks can falsify observable restrictions**, and the design keeps them
  labeled as model comparison rather than as validation, per the entry.
- The prediction unit is usually left implicit in software output; **this design
  declares it for every check**, since criteria computed at different units answer
  different questions and are not comparable.
- One network family; DIA-07 owns topology.

## 5. Methods, including one that can win

| check | role |
|---|---|
| observation-level LOO-PSIS | what ships, and what consequence 1 is about |
| **leave-one-study LOO** | grouped, closer to the gap |
| **leave-one-subnetwork LOO** | grouped, closest |
| covariate-balance / `compare_populations()` | the population screen |
| **synthetic link deletion** | the check with leverage |
| external cross-gap evidence where available | the strongest, and rarest |

**The comparator that can win is leave-one-subnetwork LOO.** If it discriminates
cross-gap bias as well as synthetic deletion, **then the leverage is available from a
grouped criterion and no deletion exercise is needed**, which would be a much cheaper
recommendation. Registered as such, and consequence 2 gives a reason it might.

## 6. Performance measures, MCSE, and $n_{sim}$

Each check scored on **rank correlation with true cross-population bias** and with true
coverage, across candidate models within a replicate, with a bootstrap MCSE since the
candidates are dependent.

**The shared-misspecification demonstration**, which is consequence 1: in cells where
every candidate carries the same false bridge, **the reported elpd difference and the
cross-gap error are reported side by side.** A confident winner with arbitrary cross-gap
error is a two-column table and it is the study's most quotable output.

**Population comparison's coverage of the relevant variables**: the fraction of
cross-study outcome difference attributable to variables it inspects, which is
computable because the generator sets it.

$n_{sim} = 1000$ networks per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Rank correlation between observation-level LOO and true
cross-population bias, in cells with shared bridge misspecification and unmeasured
imbalance.

**Decision rule.**

- Rank correlation near zero while LOO reports a clear winner: **confirmed**, and the
  deliverable is that ordinary predictive criteria be labeled model comparison and that
  grouped validation matched to the cross-gap question be implemented.
- Rank correlation high: **refuted**, and the criteria have more leverage than the
  argument allows.
- **Population comparison's variable coverage is reported in either branch**, because
  it bounds what that screen can do regardless of how the predictive checks perform.

## 8. Three controls, each of which can fail

**Null control.** With a correct bridge and no unmeasured imbalance, every check must
rank models by their observable fit and cross-gap bias must be small for all. **There is
nothing to discriminate**, and a check that appears to discriminate there is
discriminating noise.

**Second null control.** With bridge misspecification that **differs** across candidates,
$e^{\text{bridge}}$ is not common, so consequence 1's cancellation does not apply and
predictive criteria should have some leverage. **That cell separates "LOO is blind to
bridges" from "LOO is blind to shared errors"**, and only the second is what the algebra
supports.

**Positive control.** Shared misspecification with large unmeasured imbalance: LOO must
return a confident winner whose cross-gap error is large. **If it does not, consequence
1 is not reachable.**

**Falsifier for the study's own headline.** The expected headline is that predictive
criteria cannot validate a bridge. Its falsifier is the second null control: **if
criteria discriminate whenever candidates differ in their bridge, then the limitation is
narrower than "cannot validate" and is precisely "cannot detect an error every candidate
shares"** — which is a sharper and more useful statement, and the design should prefer
it if the data support it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming predictive checks have no leverage at all | The entry's qualifier carried; the second null control tests where they do | removed |
| Population comparison judged where it is not the right check | Bridge type is a factor; component and mechanistic bridges included | removed |
| Prediction unit implicit | Declared for every check; SFW-08 named | removed |
| Deletion leverage assumed | Established here; transfer to a real gap is IDN-08's | removed |
| Shared misspecification hoped for | Generated as a factor level | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The held-out population truth per cell | The definition of truth | hours |
| **P2** shared-misspecification construction | Candidate model sets that all carry the same false bridge while differing in observable fit | **The design's core cell**; without it consequence 1 is untestable | days |
| **P3** grouped LOO implementation | Whether leave-one-study and leave-one-subnetwork validation can be computed for these fits, or need exact refits | Whether the comparator that can win exists; SFW-08 shares this | days |
| **P4** unit cost | Per-network cost across six checks; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Grouped LOO may require refits, which is the multiplier; P3 settles it and SFW-08 shares
the answer.

---

## Relationship to the rest of the queue

- **IDN-08** owns whether deletion-based leverage transfers to a real gap and
  presupposes that the leverage exists, which this design establishes.
- **SFW-08** owns the held-out unit and shares P3.
- **DIS-21** owns the match threshold, which is one bridge choice this design's checks
  would be asked to validate.
- **IDN-01** owns transitivity screens, of which population comparison is one.
- **CMU-01** and **MOD-15** share the structural point that a relative criterion passes
  when both sides are wrong the same way.
