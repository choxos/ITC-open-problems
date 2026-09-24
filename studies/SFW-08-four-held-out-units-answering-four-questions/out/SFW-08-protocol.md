# Protocol: which held-out unit a mixed-likelihood elpd answers, and when PSIS approximates it

**Target problem.** SFW-08. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).
The catalog's three plumbing items (log-prior exposure for priorsense, SUCRA intervals, the
prior-versus-posterior plot) are not studied. IDN-07 (a withheld trial's prediction must target its own
population and include heterogeneity) and DIS-11 (a predictive criterion on observed trials cannot rank
models by an error they share) bear on this entry; neither measured PSIS at a grouped unit.

## 1. Claim

multinma's `loo()` sums one term per IPD patient and one per aggregate arm, so its unit is a patient in
IPD studies and an arm elsewhere: the total depends on the IPD proportion and is not comparable across
analyses, and it answers a different predictive question from a held-out study. **Refuting sentence:** the
mixed-unit elpd chooses models as the study-level predictive target does and PSIS approximates each unit
well, so the heterogeneous unit costs nothing for model selection.

## 2. Design

Six two-arm studies (A vs B three times, A vs C twice, B vs C), 100 per arm; $x \sim N(m_j, 1)$;
$y = \mu_j + 0.5x + d_k - d_b + 0.4x([k \ne A] - [b \ne A]) + \delta_j[k \ne b] + e$, $e \sim N(0,1)$,
$\delta_j \sim N(0, \tau^2)$, $d = (0, -0.5, -0.3)$. Non-IPD studies contribute arm means with their covariate
means (ML-NMR's integral is exact under the identity link). Residual SD and $\tau$ known, priors
$N(0, 10^2)$, so the posterior is exactly Gaussian. **Estimand:** the exact leave-unit-out elpd, by Gaussian
conditioning, of M1 (true interaction) and M0 (none) at three units: **pointwise** (multinma's); **arm**, each
arm held out and its mean predicted; and **study**, each study's non-baseline arm held out and its mean
predicted given everything else including its own baseline arm: a new study's contrast, free of the prior on
its baseline. Predicting the arm mean rather than the joint density of its patients gives one scalar per
study whatever the data type, so the study-level total does not scale with the IPD proportion. A treatment
unit does not exist here: without C's arms $d_C$ is not estimable (P3). **Approximation:** PSIS on 2000
exact posterior draws per model, $r_{\text{eff}} = 1$: importance ratios from the held-out group's likelihood,
the arm mean's density averaged under them (`loo::E_loo`; for a single aggregate arm this is `loo::loo`),
so its error is importance sampling alone. Factors: IPD in 1,
3 or 6 studies; $\tau$ 0 or 0.3; leverage none or one (S6 with 400 per arm at covariate mean 2). 12 cells,
**400 replicates** (MCSE of a share at most 0.025; of the primary mean absolute error about 0.13, from a probe SD of 2.6).
About 2.4 CPU hours (probes).

## 3. Decision

**Primary:** study unit, one IPD study, $\tau = 0.3$, one influential study, M1: the mean over networks of
$|\text{elpd}_{\text{PSIS}} - \text{elpd}_{\text{exact}}|$, and the share of networks in which PSIS and exact
agree on the sign of $\text{elpd}_{M1} - \text{elpd}_{M0}$. **PSIS adequate at the study unit** if at most 0.5
and at least 0.95; **exact refit or a grouped fallback required** if at least 1 or below 0.90; otherwise
intermediate, reported as a near-miss. **Null control:** all IPD, $\tau = 0$, no leverage, pointwise: mean
absolute error below 0.25 and under 1% of units with Pareto $k > 0.7$. **Positive control:** in the primary
cell some study-unit $k > 0.7$ in at least 25% of networks; otherwise the fallback has nothing to fall back
from. **Falsifier:** if the pointwise and study-unit exact elpd choose the same model in at least 95% of
networks in every cell, the unit is immaterial for selection and the deliverable reduces to a reporting
warning. **Scale:** the pointwise elpd at 1, 3 and 6 IPD studies, reported in every branch (probe: 210, 606
and 1200 terms against 6 at the study unit). Where $k > 0.7$,
the absolute error per flagged unit is reported against that of unflagged units. **Probe (10 networks):** in
the primary cell PSIS misses the exact study-unit elpd by 5.9 per network (SD 2.6) with $k > 0.7$ in 80% of
study units, because the held-out arm is the only information on its $\delta_j$ and the weights must carry
it from posterior to prior; the registered run measures how far this extends across cells and whether it
changes the selected model. The PSIS error has a known repair (integrating $\delta_j$ out of the weights),
not implemented here.

## 4. Departures from DESIGN.md

Identity link, known residual SD and $\tau$, so every refit is closed form: the study measures the unit and
the importance-sampling error, not MCMC, integration or heterogeneity-estimation error. PSIS runs on exact
posterior draws, not multinma's sampler; multinma's own unit is confirmed on one fit (probe). Treatment unit
dropped (P3). One geometry of two-arm studies (DIA-07 owns topology); aggregate contribution is the
complement of the IPD proportion, not a separate factor; the single-study null control is dropped, since with
one study the arm and study units hold out the same rows and it tests nothing; no case study.
