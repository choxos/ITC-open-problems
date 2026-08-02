# Decision

**Registered primary (DESIGN.md section 7): REFUTED: the panel discriminates as well as the geometric diagnostics**

**Cross-arm control (DESIGN.md section 8), quantified: CONFIRMED: no panel member separates the two placements (best 0.505, within 0.0046 of chance) while ess_region separates them at 1.000**

These two disagree. "Why the two readings disagree", below, says why, and
neither is discarded.

Every number here is computed from `results/analysis.rds` by
`R/05-decision.R`; nothing is transcribed.

## What the controls left standing

Two of three controls failed on part of the grid. `R/04-analyze.R` drops
the failing strata on the controls' own evidence rather than on the
results, so the surviving subgrid would move by itself if the study were
rerun with more source records or a different balancing set.

| control | requirement | outcome |
| --- | --- | --- |
| null | material error with no hole at most 0.02, per stratum | passed in dim3/good, dim8/good; **failed** elsewhere |
| matched multiset | every panel member agreeing across arms to 2% | passed for balancing set `none`; **failed** for the other |
| positive | material error with a hole at a substantial rate | passed, 0.1062 in the strong-modification arm |

Surviving subgrid: **12 of 48 cells**, 24,000 replicates.

Per-stratum null rates, which is what forced the first restriction:

| stratum | P(material error) with no hole |
| --- | ---: |
| dim3/good | 0.0005 |
| dim3/moderate | 0.0213 |
| dim8/good | 0.0026 |
| dim8/moderate | 0.2885 |

The failure at `dim8/moderate` is not a property of any diagnostic. At
eight covariates and a 0.60 mean shift the weights concentrate enough that
MAIC's own sampling error exceeds the 0.03 material threshold on 0.288 of
replicates with no support hole at all. `N_SOURCE` was registered from a
floor measured at the middle of the grid, and the middle is not the worst
corner. That is the same defect IDN-05 documented and it is worth naming
again: a threshold below its own measurement noise reads as a finding.

## The manipulation, as a measurement

Both support arms remove the same mass at the same threshold on
exchangeable standard normal coordinates, differing only in which
coordinate carries the hole: the one that modifies the treatment effect, or
a purely prognostic one.

| hole | modification | bias | mean abs error | P(material) | modification mass in hole |
| --- | --- | ---: | ---: | ---: | ---: |
| high_modification | moderate | 0.00552 | 0.00932 | 0.00900 | 0.22 |
| low_modification | moderate | -0.00013 | 0.00809 | 0.00375 | 0.10 |
| none | moderate | 0.00008 | 0.00731 | 0.00175 | 0.00 |
| high_modification | strong | 0.01639 | 0.01702 | 0.10625 | 0.22 |
| low_modification | strong | -0.00009 | 0.00837 | 0.00450 | 0.10 |
| none | strong | 0.00028 | 0.00757 | 0.00250 | 0.00 |

A hole in the modifying coordinate biases the estimate; a hole of identical
size in a prognostic coordinate does not, to five decimal places. That is
the contrast the rest of the study scores diagnostics against.

## Registered primary: AUROC against material error, within the high-modification arm

Direction is declared rather than fitted, so a value below 0.5 means the
statistic is actively misleading in the direction practitioners read it.

| statistic | family | AUROC | SE |
| --- | --- | ---: | ---: |
| `ess_region` | geometric | 0.592 | 0.012 |
| `ot_cost` | geometric | 0.577 | 0.014 |
| `max_weight` | panel | 0.574 | 0.013 |
| `hull_gap` | geometric | 0.560 | 0.013 |
| `ess_kish` | panel | 0.510 | 0.013 |
| `ess_pct` | panel | 0.510 | 0.014 |
| `entropy_eff` | panel | 0.491 | 0.013 |
| `top_share` | panel | 0.481 | 0.014 |
| `balance_omitted` | geometric | 0.465 | 0.014 |

Best panel member 0.574; best geometric 0.592 (`ess_region`); gap 0.018 against a
registered materiality of 0.10.

## Cross-arm control: can any statistic tell the two placements apart?

Both arms are matched on every panel member to within 2%, and one is
unbiased while the other is not. `separation` is `max(AUROC, 1 - AUROC)`,
because here the question is whether the arms are distinguishable at all.

| statistic | family | AUROC | separation | SE |
| --- | --- | ---: | ---: | ---: |
| `ess_region` | geometric | 0.0001 | 1.000 | 0.0000 |
| `ot_cost` | geometric | 0.7260 | 0.726 | 0.0043 |
| `balance_omitted` | geometric | 0.4653 | 0.535 | 0.0047 |
| `max_weight` | panel | 0.4954 | 0.505 | 0.0045 |
| `hull_gap` | geometric | 0.5029 | 0.503 | 0.0047 |
| `ess_kish` | panel | 0.5016 | 0.502 | 0.0044 |
| `ess_pct` | panel | 0.5016 | 0.502 | 0.0045 |
| `entropy_eff` | panel | 0.5008 | 0.501 | 0.0045 |
| `top_share` | panel | 0.5001 | 0.500 | 0.0047 |

## Why the two readings disagree

Section 7 registered the within-arm outcome, and every replicate in that
arm shares one hole placement. The only thing varying across those
replicates is sampling noise, so the outcome asks which replicate drew a
bad sample, not where the support sits. A concentration measure answers the
first question about as well as anything, which is why the panel is
competitive there and why the registered rule reads REFUTED.

The proposition is about the second question, and answering it requires
comparing analyses at DIFFERENT placements. That comparison is section 8's
control, and at 16,000 replicates every panel member sits within 0.0046 of chance
with a standard error of 0.0047, so the blindness is measured rather than
merely unrejected.

**The registered primary outcome was the wrong measurement for the
proposition, and the study's own control was the right one.** That is a
finding about the design, and it is recorded rather than repaired by
relabeling the cross-arm test as primary after the fact.

## The comparability defect, quantified

Three ESS definitions computed on identical data. The complaint is that
two analyses of the same evidence can report incomparable numbers, and its
size had not been measured.

Median spread **1.55 times**, 90th percentile 3.50, maximum 15.48.

## What this does and does not establish

The invariance is algebraic and was never in question: every panel member
is a symmetric function of the weights. What the run establishes is that it
BITES, meaning two analyses differing by 0.0163 in bias can be built at a panel
matched to 2% in an ordinary covariate law, rather than only in
contrived configurations. The refuting sentence in section 1 fails.

Four things it does not establish.

1. **`hull_gap` is geometric and blind anyway** (separation 0.503). It takes a
   maximum over coordinates, and both arms remove an identical wedge, so
   the maximum is identical. Reading position is not enough; a diagnostic
   that aggregates over coordinates inherits the same defect.
2. **`balance_omitted` was never given a chance to see anything.** The
   design registered it as the cheap comparator most likely to overturn the
   headline, and the cells where it has something to see are exactly the
   `one_modifier_second_moment` cells the matched-multiset control
   eliminated. Its separation of 0.535 here is the tautological zero its own
   code comment predicted, and the comparison the design wanted was not
   run. That is a live threat to the headline, not a settled one.
3. **`ess_region` requires choosing a region.** The choice here is the
   effect modifier's upper decile, which an analyst has, because MAIC
   already requires naming the modifiers. It is not knowledge of where the
   hole is: in the prognostic-hole arm the hole lies elsewhere and the
   statistic correctly reads near-normal. But the region is a choice, and a
   calibrated decision rule would have to register it.
4. **No diagnostic here is calibrated.** Separating two placements is not a
   threshold, and this study does not provide one.

