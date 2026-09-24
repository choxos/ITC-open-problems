# Protocol: does the tail's reconstruction error reach a downstream comparison?

**Target problem.** CMP-17. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md). The publication model is
OUT-13's `R/00-model.R`, sourced read-only; `reconstruct()` is redefined here.

## 1. Claim

**Already answered.** OUT-13 (one arm, 13 cells, 300 replicates): a single Guyot reconstruction's error was 2%
to 8% of the sampling SD for RMST to 24 months and 11% to 26% for Weibull survival extrapolated to 48 months,
so the error lives in the extrapolated tail; observation-model draws overstated it for RMST (variance
calibration ratio 2.1 to 13.1) and 12-month survival (1.1 to 3.5) and understated it at 48 months (0.15 to
0.77, with 90% intervals covering the true-data value in 42% to 77%); analyst variants carried a deterministic
offset from sparse digitization. DIA-10: reconstructing one arm changed no method ranking for RMST. Neither
reconstructs both arms of a trial, carries the error through a downstream likelihood, or measures survival
late in follow-up where few remain at risk. This protocol targets that remainder and does not assume the draws
are calibrated.

**Claim** (DESIGN.md section 2): the at-risk count shrinks along the curve, so reconstruction error grows
toward the tail; the two arms come from different curves, so their errors do not cancel; and an exact
likelihood fitted to the reconstruction reports precision the data do not support. **Refuting sentence:**
reconstruction error averages out over a curve's many points, so it perturbs the fitted survival function far
less than sampling error does and propagating it would change no interval materially.

## 2. Design

Network A, B, C. Study 1: individual data, A versus C. Study 2: B versus C, published as a Kaplan-Meier figure
of both arms with a risk table and event totals and reconstructed arm by arm (Guyot's algorithm, IPDfromKM
0.1.10). Weibull events, shape 1.2, control median 18 months; hazard ratios versus C of 0.7 (A) and 0.8 (B);
OUT-13's accrual and censoring, spread or with 30% dropping out before 6-monthly visits; 250 per arm in both
studies. Estimands, A versus B in study 2's population, true values in closed form: log hazard ratio; RMST
difference to 24 months; survival differences at 12 months, 30 months (late: control survival 0.28, a quarter
still in follow-up under spread censoring) and 48 months (extrapolated).

Three downstream routes on the same data: **joint, study-specific shapes** (Weibull likelihood over both
studies; study 2's extrapolation rests on its reconstructed rows alone); **joint, common shape**; **anchored
Kaplan-Meier** ($(\hat A - \hat C)_1 - (\hat B - \hat C)_2$ for RMST and 12 and 30 months with Greenwood
variances, and a stratified Cox log hazard ratio). Upstream reference, **arm**: study 2's control arm alone,
Weibull survival at 48 months by OUT-13's `functionals()`. Methods on each route: **oracle** (study 2's true
data); **single** reconstruction of each arm (current practice, the comparator that can win); **draws**, 10
per arm from OUT-13's observation model, refitted and pooled by Rubin's rules, carried as the existing
propagation device and expected from OUT-13 to under-propagate the tail. Cells: coarse 300 by 200 figure with
a 6-monthly or no table by spread or clustered censoring (4, the primary cells); null control (fine figure,
monthly table, spread); second null (all hazard ratios 1; coarse, no table, clustered); large trial (coarse,
no table, clustered, 1000 per arm). 7 cells, **500 replicates**, common random numbers: coverage MCSE 0.0097
at nominal, so 0.925 lies 2.6 MCSE below 0.95. Cost: probe P3.

## 3. Decision

**Materiality:** RMSE of a reconstruction's estimate about the oracle's over the oracle's SD across
replicates. **Precision survival**, for every estimand: calibrated, $1/\sqrt{1 + \text{materiality}^2}$ (what
honest propagation would leave of the single interval's precision, independent of any ensemble), and as the
draws deliver it (single width over draws width). **Primary:** 48-month survival difference, joint route with
study-specific shapes, in the four primary cells. **Propagation needed** if single coverage is below 0.925 in
a primary cell, reported with whether the draws cover 0.93 to 0.97 there; **refuting sentence holds** if
single coverage is 0.925 to 0.975 in all four; **not assessable** if the oracle is outside 0.921 to 0.979 (3
MCSE); otherwise mixed. **Registered secondaries**, same rule: 48 months with a common shape, and 30 months on
the Kaplan-Meier route. **Null control:** single materiality below 0.10 for the log hazard ratio, RMST and
12-month estimands on every route, and width within 5% of the oracle's for all. **Second null:** every route,
method and estimand unbiased within 3 MCSE. **Positive control** (the error exists upstream): arm route,
single materiality at least 0.10 in every primary cell, where OUT-13 measured 0.15 to 0.26; downstream over
upstream materiality is reported as the dilution. **Large trial:** the primary estimand's coverage and
materiality at 1000 per arm. **Mechanism check** (DESIGN.md section 2): the single reconstruction's relative
RMS error in study 2's number at risk larger at 33 than at 15 months (midway between table times) in every
primary cell. **Tail falsifier:** on the Kaplan-Meier route, the absolute reconstruction RMSE at 12 months at
least that at 30 in a primary cell, which would place the error in pixel reading rather than in the at-risk
counts. On the joint routes every estimand shares one parametric channel, so the ratio of 48 to 12-month
materiality is registered as expected within 0.8 to 1.25 and reported. Dropped replicates and ensemble sizes
are counted; a near miss is reported as one.

## 4. Departures from DESIGN.md

No population-adjustment layer: reconstructed data carry no covariates and an adjustment of study 1 enters the
A versus B contrast additively (DIA-10's argument). One treatment per node; no RESOLVE-IPD labeling ensemble,
Bayesian measurement model or case-study reanalysis; no at-risk rounding, censoring marks or delayed effect;
trial size 250, and 1000 in one cell, not 150 and 400; coarse figure except in the null control (OUT-13 and
DIA-10 vary resolution); an at-risk check instead of a regression on $1/n_j$; maximum likelihood, not a
posterior; 500 replicates. `reconstruct()` is redefined with the arm size as an argument and a CPU-time guard
in place of OUT-13's 20-second wall-clock guard, which lost replicates under load. Changed after probing and
after OUT-13 was published: the Kaplan-Meier route was added when probe P2 showed the common-shape route
giving every estimand the same materiality; the study-specific-shape route was added and made primary so that
study 2's extrapolation is not pinned by study 1 (P2 then found both joint routes near 0.09); the positive
control moved upstream to the arm, since P2 put downstream materiality near 0.10 even at 1000 per arm, and the
large-trial cell stays as a secondary; the primary cells widened from the two clustered cells to all four,
with the threshold moved from 0.93 to 0.925; the tail falsifier moved from materiality to absolute error,
because P2 showed the oracle's SD growing in the tail with the error, which keeps materiality flat; the draws
fell from 20 to 10 per arm because OUT-13 showed them miscalibrated, so they are a secondary comparator, not a
reference.
