# MOD-04: merged into MIS-04, and the one increment it adds

**Status: merge record, not a separate design.**

MOD-04's own catalog note is the instruction followed here:

> This is substantively important but overlaps heavily with MIS-04 and should be
> combined with it or delayed until one concrete selection workflow is chosen.

**The design lives at
`studies/MIS-04-selection-over-models-bridges-and-partitions/DESIGN.md`.** Writing a
second, near-identical design would produce two studies that cannot disagree, which
is the specific waste this program's design standard exists to prevent.

---

## What MOD-04 contributes that MIS-04 does not

The entry contains one narrowing that changes what is being measured, and it is
sharper than the source's own claim.

**The stronger form of the complaint does not hold.** Regularization is not the same
as omitted uncertainty: a Bayesian fit that carries posterior draws through to the
transported effect **does** propagate shrinkage, and the development source does
exactly that. So the interval is not missing the shrinkage.

**What is actually omitted is two things:**

1. **Discrete model-selection uncertainty**, which is MIS-04's subject and is
   covered there.
2. **The prior scale, when the prior scale was itself selected.** A regularizing
   prior whose scale is tuned by cross-validation or by an information criterion is a
   model choice wearing a prior's clothes. **Carrying posterior draws under the
   selected scale propagates shrinkage conditional on that scale and prices nothing
   about the selection of it.** COV-04 measures adaptive shrinkage under a
   *hierarchical* scale, which is a different object: there the scale is a parameter
   with a posterior, and here it is a tuned constant.

**Item 2 is MOD-04's increment and it is added to MIS-04 as a factor level** in the
selected-object axis: *prior scale, selected by cross-validation*, alongside outcome
model, treatment partition and bridge. It is cheap to add because the machinery is
identical, and it closes the gap between COV-04's hierarchical case and MIS-04's
discrete one.

## Two claims MOD-04 must not carry forward

**The word "commonly" is unsupported.** The source did not support the claim that
conditional intervals are commonly reported this way, and the nearest evidence is a
methodological review finding that key methodological aspects of PAIC publications
were reported inconsistently, with appropriate uncertainty measures among the
less-followed recommendations. **MIS-04 cites that and claims no more.**

**Cross-fitting is not the only valid route.** Valid selective inference, resampling
that repeats the selection step, debiasing and full Bayesian model averaging are
alternatives with their own conditions, and MIS-04's method set reflects that rather
than presenting cross-fitting as required.

## Where the PAIC-specific gap actually is

Both auditors searched and found nothing PAIC-specific. The entry states the gap
precisely: **no coverage assessment of an effect-modifier selection procedure has
been run with the selection step included.** That is MIS-04's primary outcome for the
model arm and COV-01's and COV-04's for theirs.

The PAIC-specific complication, which MIS-04 carries: **selection happens in the IPD
trial while the estimand lives in a different population**, and further uncertainty
enters through estimated weights and reported target moments. **So a splitting scheme
that is honest for the source trial is not automatically honest for the transported
effect**, and MIS-04's declared predictive unit is where that is handled.

---

## Relationship to the rest of the queue

- **MIS-04** carries the design.
- **COV-01** owns modifier selection, **COV-04** owns shrinkage-prior calibration
  under a hierarchical scale, **DEC-11** owns propagation and what belongs in an
  interval.
- **IDN-19** owns the treatment-class partition.
