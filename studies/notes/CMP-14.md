**Study `studies/CMP-14-aggregate-only-interactions`, decided by `R/11-decision.R`
from the run's own result files.** 504 scenarios on the exact arm, 72 on the
nonlinear arm.

**Conclusion: no diagnostic in the panel separates failing from nominal scenarios,
on either arm.**

| arm | failing | nominal | neither | total |
|---|---:|---:|---:|---:|
| E1, exact | 251 | 169 | 84 | 504 |
| E2, nonlinear | 41 | 12 | 19 | 72 |

A scenario fails if coverage is below 0.90 and is nominal if coverage is within
0.01 of 0.95; gross overcoverage sits in neither class, being a real defect of an
interval but not the defect this study measures.

All seven statistics overlap on both arms: `contraction`, `target_ratio`,
`eff_rank`, `prec_within`, `prec_between`, `surv_between` and `surv_sd` each take
at least one value shared by a failing and a nominal scenario. An overlap is an
existence claim no weighting can move, so no threshold on any of them separates
the two classes whatever mixture of scenarios a practitioner faces. All six
state-separation rules likewise return no separation.

**Standing: exploratory on both arms, and that is not a hedge.** E1 ran before the
protocol existed and every E2 rule was rebuilt after E2's output had been read, so
neither arm is confirmatory and the nonlinear arm is not the safer of the two. The
result is a measurement whose grid and outcome definitions were chosen with earlier
numbers already seen; a confirmatory version needs a fresh study with these
outcomes registered in advance.
