# Protocol: repeated older-to-newer holdouts, and what their error against calendar gap measures

**Target problem.** DIA-18. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

The error in predicting a later trial is sampling error plus ordinary heterogeneity plus design change
plus drift; regressed on calendar gap without subtraction, it fits a decay rate to the sum. Proposition:
after sampling error and heterogeneity are subtracted, a temporal component remains that grows with gap.
**Refuting sentence:** once sampling error and ordinary heterogeneity are removed, the systematic temporal
component is too small to detect, so trial age is not a useful selection criterion. DESIGN.md expects the
refutation; no finished study bears on it.

## 2. Design

**Data.** Five aggregate networks with publication years, all shipped in installed packages:
`atrial_fibrillation` (stroke; prior-stroke proportion per trial) and `hta_psoriasis` (PASI 75) from
multinma 0.9.1 (GPL-3); `Linde2015` (depression response) and `Baker2009` (COPD exacerbation) from netmeta
3.6-1 (GPL-2 or later); `dat.hasselblad1998` (smoking cessation) from metadat 1.6-0 (GPL-2 or later).
Trial counts and calendar spans: probes.

**Model.** Random-effects NMA on arm empirical logits (0.5 correction), fixed study intercepts, τ² by REML.
In the atrial fibrillation network one shared interaction with prior stroke standardizes each prediction to
the held-out trial's population.

**Holdouts.** Unit (j, L): train on every trial published at least L years before trial j, L in {0, 3, 6,
10, 15}, keeping distinct training sets; gap is year of j minus the latest training year. The contrasts of j
are predicted from the training component containing its treatments; a holdout outside that row space is
counted as non-estimable and never scored.

**Decomposition.** z² = e'(V_pred + V_obs + τ̂²H)⁻¹e / df removes the sampling error of prediction and
observation and ordinary heterogeneity; e² = e'e / df is the raw error. **S** is the OLS slope of z² on gap;
**S_raw** the slope of e² on gap.

**Null and positive control, on each network's own design.** Outcomes simulated on the same trials, arms,
sizes and years from the network's full-data fit and the whole holdout pipeline rerun: **400 replicates**
with no drift (the 95th percentile's tail probability then has MCSE 0.011), and **200** with every effect
against control drifting 0.03 log odds ratio per year, sign random per treatment (power MCSE at most
0.035). The null absorbs what makes a naive test invalid here: overlapping holdouts, small early training
sets, τ² estimated at zero. Cost: probes.

## 3. Decision

Per network, **drift is detected** if S exceeds the 95th percentile of its own null. A network is
**informative** if its power at 0.03 per year is at least 0.5. **Primary:** drift is established for each
network where detected, as a context-specific result with no universal decay rate; if none detects drift
and at least 2 are informative, **the refuting sentence holds on these networks**; otherwise
uninformative. S and S_raw are reported in every branch, with the drift per decade and its SE from the
full-data model with one common drift term.

**Consequence 2.** Confirmed if the naive one-sided OLS test of S_raw rejects in at least 10% of no-drift
replicates in at least 3 of the 5 networks: raw error against gap is then not a drift estimate. **Null
control.** On the real data, mean z² over same-era holdouts (gap at most 2 years) lies inside the central
95% of the same quantity in the network's own no-drift replicates; this tests the subtraction of sampling
error and heterogeneity. A fixed band around 1 is not used because sparse networks sit far below it with
no drift at all. Networks with fewer than 5 same-era holdouts are not assessed. **Second null control.**
Non-estimable holdouts are counted and none is scored. **Positive control.** The power above; a network
failing it is evidence of nothing, which is DESIGN.md's falsifier (heterogeneity swamps drift).

## 4. Departures from DESIGN.md

- **Aggregate data only**: no IPD holdouts and no arm-level prediction. Population adjustment is one
  study-level covariate in one network; the others carry none.
- Design and outcome-definition change is not modeled (no recorded design variables), so any drift found
  is an upper bound.
- No hierarchical temporal model across holdouts; the full-data common-drift term is its simplest form
  and is secondary. Drift in the positive control is linear in year.
- Normal approximation to arm logits; holdout lags fixed at five values.
- The drift size 0.03 per year and all thresholds were set before any holdout statistic of the real
  outcomes was computed; probes ran on simulated replicates only. In those 8 probe replicates the drift
  median separated from the null range clearly only in the depression network, so the uninformative
  branch is live and is not a failure of the run.
