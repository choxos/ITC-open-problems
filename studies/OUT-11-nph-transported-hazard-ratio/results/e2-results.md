# E2: finite-sample behavior of the anchored transported hazard ratio

Run: `Rscript R/06-e2-scatter.R`. Configuration frozen in `R/00-config.R`; results in
`results/e2-scatter.rds`.

Six cells crossing $\kappa_A \in \{0, 0.30\}$ with $\kappa_B \in \{0, 0.15, 0.30\}$, each at 2,000
replicates per leg per censoring regime, with the two studies' regimes crossed independently over
all four, giving 96 registered regime pairs. $\beta_B$ is re-solved per cell so the true target RMST
difference is 0.75 months everywhere; nothing below is an effect-size difference.

Each replicate builds **two independent two-arm studies**, fits one unadjusted Cox model in each,
and combines them by Bucher. Leg A is the IPD study at 250 per arm under its own baseline hazard;
leg B is the aggregate study at 200 per arm under the target baseline. Both are drawn at the target
covariate law, which is the perfect-covariate-adjustment idealization. Common random numbers are
used across regimes *within* a leg and never between legs.

## Result 1: the E1 analytic limit is what finite samples reach

E1 computes the anchored contrast by quadrature and root-finding. E2 checks it by simulation.

Both columns report the **worst** of the 16 regime pairs in the cell. An earlier version of this
table printed each cell's worst bias next to its *best* coverage, which took opposite extremes in
the same row.
No conclusion changes, because every cell is near nominal on either summary, but the best coverage
in a row is not a companion to the worst bias in it. Best coverage is kept as a separate column
rather than dropped, so the spread within a cell is still visible.

| $\kappa_A$ | $\kappa_B$ | worst \|bias\| vs the E1 limit | worst coverage | best coverage |
|---:|---:|---:|---:|---:|
| 0.00 | 0.00 | 0.0032 | 0.946 | 0.957 |
| 0.30 | 0.00 | 0.0081 | 0.942 | 0.954 |
| 0.00 | 0.15 | 0.0135 | 0.943 | 0.957 |
| 0.30 | 0.15 | 0.0092 | 0.944 | 0.959 |
| 0.00 | 0.30 | 0.0101 | 0.941 | 0.955 |
| 0.30 | 0.30 | 0.0059 | 0.941 | 0.955 |

Worst discrepancy over all 96 regime pairs is **0.0135** on the log scale, at most **2.84** times
its own Monte Carlo standard error, and the Bucher 95% interval covers the E1 limit **0.941 to
0.959** of the time against a nominal 0.95.

**Both variance estimators are recorded.** Round 5 objected that E2 used the model-based Cox variance
while under non-proportional hazards the ordinary inverse-information variance need not estimate the
sampling variance of a least-false coefficient, so the coverage could be an artifact of that choice.
The objection is right in general and does not bite here: the robust sandwich gives **0.940 to
0.957** against the model-based 0.941 to 0.959, with a mean robust/model SE ratio of **0.9956**.

**This is a check on E1, not on the estimator.** A Wald interval around a least-false parameter is
correctly centered on that parameter and on nothing else. It says nothing about whether the interval
covers the estimand; under non-proportional hazards it does not, which is the whole problem.

An earlier 30-replicate pass showed an apparent bias of $-0.055$ to $-0.081$, which looked like a
defect and was not: at 2,000 replicates it falls to $-0.0045 \pm 0.0033$. The per-leg Cox fits were
separately checked against their own analytic limits at 200, 1,000 and 20,000 per arm and were
unbiased at every size. Recording this because the intermediate result would have justified a search
for a bug that does not exist.

## Result 2: the movement is nearly one sampling standard deviation, and nobody would see it

The sampling standard deviation of a single reported anchored log hazard ratio is 0.142 to 0.228.
Against that, the regime-induced shift relative to the matched reference case:

| $\kappa_A$ | $\kappa_B$ | worst shift, in single-estimate SDs | P(two analysts call it significant) |
|---:|---:|---:|---:|
| 0.00 | 0.00 | 0.167 | 0.060 |
| 0.00 | 0.15 | 0.439 | 0.064 |
| 0.00 | 0.30 | 0.769 | 0.094 |
| 0.30 | 0.00 | 0.707 | 0.086 |
| 0.30 | 0.15 | 0.656 | 0.082 |
| 0.30 | 0.30 | 0.692 | 0.088 |

Two readings matter.

**The shift reaches 0.769 sampling standard deviations, and the test for it has almost no power.**
Two analysts each holding an independent evidence set, conducted under different follow-up, would
call their anchored estimates significantly different at most 9.4% of the time against a nominal
size of 5%. A systematic movement about three quarters the size of the noise on any single estimate,
and the obvious check for it fires roughly one time in eleven. That combination is what lets this
failure mode survive review.

**IPD-side non-proportionality alone produces most of the effect.** At $\kappa_A = 0.30$,
$\kappa_B = 0$ the shift is 0.707 SDs against a worst case of 0.769. Version 3 fixed $\kappa_A$ at zero in
every cell, so this half of the effect was invisible to it. Round 3 identified that as a design
defect on the grounds that MAIC and STC only ever act on the IPD side; this measures what it was
hiding.

**The fully proportional cell is no longer at zero, and that is a consequence of the round-6
placebo correction.** At $\kappa_A = \kappa_B = 0$ the shift is 0.167 SDs, where the previous
version reported 0.057. Under the registered mechanism the covariate is a pure effect modifier, so
it acts on the active arm and not on placebo, and each leg's marginal contrast is therefore
non-proportional even with $\kappa = 0$. The earlier version made the covariate prognostic under
placebo as well, which cancelled most of that. Only the control cell, where $\gamma = 0$ too, is
genuinely free of movement.

Crossed follow-up moves the contrast further than matched (0.769 against 0.736), consistent with
E1's exact computation: when both legs are followed alike, their movements partly cancel in the
Bucher difference.

## What E2 does not show

- It says nothing about population adjustment, which is idealized away here and is E3's subject.
- The coverage figures are coverage of a least-false parameter, not of the estimand.
- The detection probability is for the specific comparison two analysts would actually make. It is
  not a claim that no diagnostic could detect the movement; a Grambsch-Therneau test on each leg
  would, and its power at these sample sizes is reported in `cell_properties()`.
