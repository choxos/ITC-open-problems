# Protocol: DIA-02, two analyses with identical diagnostics and different support

**Target problem.** DIA-02 *The reported overlap panel cannot see where support is missing.*

**This study was never registered as a separate protocol document.** Its design of
record is [`DESIGN.md`](DESIGN.md) as committed in `837f8b4` on 2026-07-30, and the
constants that the design left to probes were fixed in code, in `R/00-config.R`,
in commit `3051558` at 11:53 on 2026-08-01, before the first replicate was drawn.
This file records what was fixed when, so a reader can see which choices preceded
the data and which did not. It is written after the run and says so.

## What was fixed before the run

| item | where | value |
| --- | --- | --- |
| proposition and refuting sentence | `DESIGN.md` section 1 | as written there |
| factors and levels | `R/00-config.R`, `LEVELS` | dimension 3, 8; hole none, low modification, high modification; overlap good, moderate; omitted moment none, one modifier's second moment; modification moderate, strong. 48 cells |
| replicates | `N_REP` | 2000 per cell |
| source size | `N_SOURCE` | 16000, from a noise floor measured at the middle of the grid (the table is in `R/00-config.R`) |
| material error | `MATERIAL_ERROR` | 0.03 on the marginal risk difference |
| hole definition | `HOLE_QUANTILE` | upper 0.10 of a standard normal coordinate |
| matched multiset tolerance | `PANEL_MATCH_TOL` | 0.02 relative, on every panel member |
| primary outcome | `DESIGN.md` section 7 | AUROC of each diagnostic against material error in the high-modification arm |
| controls | `DESIGN.md` section 8 | null, matched multiset, positive |

## What was fixed during or after the run

| item | commit | when | relation to the data |
| --- | --- | --- | --- |
| runner and classifier analysis | `326e12e` | 2026-08-01 11:58 | run started 11:57; no cell complete |
| decision program | `9a42276` | 2026-08-01 12:35 | cells were landing; no analysis had been read |
| restriction derived from the controls, cross-arm reading | `d8495c9` | 2026-08-02 06:47 | **after the full run was complete and read** |
| boundary sensitivity, region-ESS caveat | `5ca4a5c` | 2026-08-02 | after |
| floor probe for the removed strata | `1c7ae4e` | 2026-08-02 | after |

The restriction rule (drop a stratum whose null control fails; drop a balancing
set whose matched-multiset control fails) is mechanical and would move by itself
on a rerun, but it was written after the results existed, and the cross-arm
separation that carries the study's positive finding is the second null control
read as a number, not the registered primary. Both facts are stated in the
manuscript's first results section.

## Deviations from `DESIGN.md`

- The design asked for probe P1 (quadrature order for truth). Truth is instead a
  Monte Carlo mean over 400,000 target draws per dimension and modification level,
  cached with a fixed seed; its Monte Carlo error is far below the material
  threshold but is a fixed offset shared by every replicate in a cell.
- The design listed three competing ESS definitions. As implemented, the Kish and
  coefficient-of-variation forms are algebraically the same statistic when the
  weights are normalized to a fixed mean, so the measured spread is between the
  Kish and entropy forms only.
- The design asked that the matched-multiset control hold at numerical precision.
  The construction matches the multiset in distribution rather than replicate by
  replicate, so the control was implemented with the 2% relative tolerance above.
- Optimal-transport cost is a sliced approximation on 20 fixed directions, and
  convex-hull distance is a coordinatewise approximation. Both are named as
  approximations in `R/02-panel.R`.
- `HIGH_MOD_SHARE` registered that a high-modification hole holds at least 25% of
  the target's effect-modification mass. The realized share is 0.22, measured on
  the run and never checked against the constant before it; the hole is weaker
  than its registered definition.
- Peer review has not yet been done.
