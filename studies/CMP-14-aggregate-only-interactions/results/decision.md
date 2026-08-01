# Decision

**Conclusion: no diagnostic in the panel separates failing from nominal
scenarios, on either arm.**

**Standing: EXPLORATORY ON BOTH ARMS, and this is not a hedge.** E1 ran
before `protocol.md` existed, and every E2 rule was rebuilt after E2's
output had been read. Neither arm is confirmatory and the E2 arm is not the
safer of the two. Nothing here confirms anything; each number is a
measurement whose grid and outcome definitions were chosen with earlier
numbers already seen. A reader wanting a confirmatory version of this
result needs a fresh study with these outcomes registered in advance.

## Classification

A scenario **fails** if coverage is below 0.90, is **nominal** if coverage
is within 0.01 of 0.95, and is **neither** otherwise. Gross overcoverage
sits in `neither`: it is a real defect of an interval and it is not the
defect this study measures, so it is excluded rather than reclassified.

| arm | failing | nominal | neither | total |
| --- | ---: | ---: | ---: | ---: |
| E1, exact | 251 | 169 | 84 | 504 |
| E2, nonlinear | 41 | 12 | 19 | 72 |

## Primary 1 on E1, the exact arm: does any statistic separate the two classes?

Compared over the **comparison set**, the 251 failing plus the 169 nominal
scenarios. The intermediate and over-covering bands belong to neither
side and are excluded from the denominator as well.

| statistic | failing range | nominal range | overlaps |
| --- | --- | --- | :---: |
| `contraction` | 0.007444 to     1 | 0.007169 to 0.634 | **yes** |
| `target_ratio` |     0 to 1.804e+04 | 1.444 to 1.946e+04 | **yes** |
| `eff_rank` |    10 to    14 |    12 to    14 | **yes** |
| `prec_within` |     0 to  3113 |     0 to  3113 | **yes** |
| `prec_between` |     0 to  1875 |     0 to  1875 | **yes** |
| `surv_between` |     0 to     1 |     0 to     1 | **yes** |
| `surv_sd` |     1 to     1 |     1 to     1 | **yes** |

**7 of 7 statistics overlap.** An overlap means at least one value is
taken by both a failing and a nominal scenario, so no threshold on that
statistic can separate them, whatever weighting is applied to the grid.

## Primary 1 on E2, the nonlinear arm: does any statistic separate the two classes?

Compared over the **comparison set**, the 41 failing plus the 12 nominal
scenarios. The intermediate and over-covering bands belong to neither
side and are excluded from the denominator as well.

| statistic | failing range | nominal range | overlaps |
| --- | --- | --- | :---: |
| `contraction` | 0.08338 to     1 | 0.05837 to 0.285 | **yes** |
| `target_ratio` |     0 to 142.8 | 11.31 to 292.3 | **yes** |
| `eff_rank` |    10 to    14 |    14 to    14 | **yes** |
| `prec_within` |     0 to 292.3 |     0 to 292.3 | **yes** |
| `prec_between` |     0 to     0 |     0 to     0 | **yes** |
| `surv_between` |     0 to     1 |     0 to     1 | **yes** |
| `surv_sd` |     0 to     1 |     0 to     1 | **yes** |

**7 of 7 statistics overlap.** An overlap means at least one value is
taken by both a failing and a nominal scenario, so no threshold on that
statistic can separate them, whatever weighting is applied to the grid.

## The state-separation rules

`results/e2-verdict.rds` evaluates whether any diagnostic separates the
information states it was proposed to distinguish.

| rule | separates |
| --- | :---: |
| contraction separates additivity from ecological | **no** |
| target_ratio separates additivity from ecological | **no** |
| eff_rank separates additivity from ecological | **no** |
| contraction separates additivity from curvature | **no** |
| target_ratio separates additivity from curvature | **no** |
| eff_rank separates additivity from curvature | **no** |

Any state separation at all: **no**.

## What this does and does not establish

It establishes, on this grid, that the panel's statistics take overlapping
values on scenarios that cover and scenarios that do not, so a practitioner
reading them as a screen is reading noise. It does not establish that no
diagnostic could work, that the overlap persists off this grid, or anything
confirmatory whatsoever, for the reason stated at the top.

