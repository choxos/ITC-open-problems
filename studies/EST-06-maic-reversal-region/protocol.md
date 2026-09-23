# Protocol: how often swapping the individual-data trial reverses a MAIC

**Target problem.** EST-06. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Two sponsors analyze the same two trials, A versus C in population $F_A$ and B versus
C in $F_B$; each holds its own individual data and weights it to the other trial.
Their B-versus-A estimates target $\Delta(F_B)$ and $\Delta(F_A)$. With linear
modification of B by $x_1$, $\Delta(F) = d_B - d_A + \beta\,\bar x_{1,F}$, so the true
targets have opposite signs exactly when the zero-effect point
$x_1^* = -(d_B - d_A)/\beta$ lies between the two populations. **Refuting sentence:**
configurations producing reversal are extreme, and observed disagreements are better
explained by sampling error and differing adjustment sets. Under linearity the average
of the two native effects equals the effect in the population with the midpoint
covariate mean, so a committee's naive average is not arbitrary there.

## 2. Design

Two covariates, prognostic coefficients 0.5; $F_A$ and $F_B$ have $x_1$ means
$\mp\text{sep}/2$. Continuous outcome, residual SD 1.

| factor | levels |
|---|---|
| separation of $x_1$ means (SD) | 0.5, 1, 1.5 |
| modification $\beta$ of B by $x_1$ | 0.2, 0.4, 0.6 |
| position of $x_1^*$ | between (0.1 sep), at $F_A$'s mean, outside (sep/2 + 0.5) |
| trial sizes per arm | 200 and 200; 300 (A) and 100 (B) |
| adjustment sets | common ($x_1, x_2$); differing (sponsor B adjusts for $x_2$ only) |

108 cells plus 3 controls ($\beta = 0$, or no separation). **1000 replicates**
(0.9 core-hours). Estimands: $\Delta(F_A)$, $\Delta(F_B)$ and $\Delta(F_D)$ for a declared
decision population $F_D$ with covariate means 0, all closed form.

**Methods.** Sponsor A (A's data weighted to $F_B$'s means); sponsor B (B's data
weighted to $F_A$'s); transport of both trials to $F_D$ using both individual data
sets; the average of the two sponsors' estimates. Sandwich variances, weights fixed.

## 3. Outcomes and decision

Per cell: bias of each method against its native target and against $\Delta(F_D)$,
RMSE, coverage, with MCSE; the probability that the two sponsors' estimates have
opposite signs; the correlation of their estimates; the reversal probability predicted
by a bivariate normal with the empirical means, SDs and correlation, and with the
correlation set to zero.

- **Target difference as a driver:** for each (sep, $\beta$, sizes, sets), the reversal
  probability with $x_1^*$ between the populations minus with $x_1^*$ outside. If the
  difference exceeds 0.20 in more than half of the common-set configurations, target
  difference is a material cause of disagreement and the refuting sentence fails.
- **Plausible range:** reversal probability in between cells with sep $\le 1$ and
  $\beta \le 0.4$, reported in full.
- **Differing sets:** sponsor B's bias against $\Delta(F_A)$ when it omits the modifier.
- **Remedies:** RMSE against $\Delta(F_D)$ of transport-to-$F_D$ and of the average.
- **Formula:** absolute difference between simulated and bivariate-normal reversal
  probability, with and without the correlation.

**Controls.** $\beta = 0$: every method unbiased for $\Delta(F_D)$ within 3 MCSE and no
true reversal. Sep 0: the two sponsors' targets are equal.

## 4. Departures from DESIGN.md

The arbitrated indirect comparison (Fang and He) is not implemented; the transport to
$F_D$ and the average are the remedies compared. Overlap is not a separate factor
(separation sets it). The measurement-difference explanation arm is not run.
$n_{sim} = 1000$ rather than 4000.
