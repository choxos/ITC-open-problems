# Protocol: is deletion recovery a property of the cut?

**Target problem.** IDN-08. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A benchmark that deletes links and reports one recovery figure averages over cuts, and a real gap is one
particular cut. Proposition: the error of reconstructing a cut link varies across the cuts of one network
beyond sampling error, and the variation is predicted by the population and design separation across the
gap, both measurable from published summaries before any recovery is computed. **Refuting sentence:**
deletion recovery is a stable property of the method rather than of the deleted link, so any cut link
licenses the method for any gap. DIS-11 and DIS-21 (finished) bear on bridges in simulation only.

## 2. Design

**Data.** Four aggregate networks carrying the study summaries that measure separation:
`atrial_fibrillation` (population: prior-stroke proportion; design: year) and `diabetes` (design: follow-up
years) from multinma 0.9.1 (GPL-3); `Linde2015` and `Baker2009` (design: year) from netmeta 3.6-1 (GPL-2 or
later).

**Cuts.** Every split of the treatments into two sets of at least two. A study with arms on both sides
keeps the side with more arms if that side has at least two, and is otherwise removed (ties removed). A
cut is valid if every treatment keeps an arm and each side is connected; networks with fewer than 10 valid
cuts are excluded (none is, by the probe census). The link is the cross-gap pair with the most patients in
removed direct comparisons.

**Reference and bridges.** Reference: the connected random-effects NMA estimate of the link (fixed study
intercepts, τ² by REML), with its own variance; not truth. **rb:** the random-baseline bridge of Beliveau
et al. (2017), exchangeable random study baselines (σ²) plus the same heterogeneity, by REML on the cut
network. **rbx:** rb with the baselines regressed on the separation covariates, a population-adjusted
bridge at the aggregate level. Arm empirical logits with a 0.5 correction. z = (bridge minus reference) /
sqrt(v_bridge + v_reference), conservative because both use the retained studies. **Separation** of a
cut: absolute difference of the two sides' mean study covariate over that covariate's SD across studies.

**Statistics (rb).** T_var, the variance of z across cuts; T_pop and T_des, the slopes of the absolute
error |e| on the two separations entered together. The slopes use |e|, not |z|: the bridge SE varies across
cuts and dividing by it turns bias into precision; the null calibrates |e| for that variation. This choice
was made after probe replicates on simulated outcomes; with the positive control shifting on population
separation alone, 2 of 10 af positive-control replicates exceeded the null maximum for T_pop and 0 of 10
for T_des, so af's power is low, the inconclusive branch is live, and a real-data detection is the only
informative af outcome.

**Null and positive control, on each network's own design.** Outcomes simulated from the network's fit
with exchangeable baselines, the bridge assumption true, and every cut rescored: **200 replicates** (tail
probability at 0.05, MCSE 0.015). Positive control: baselines shifted 0.5 logit per SD of the first
separation covariate (population in af, design elsewhere; shifting on both lets the two signed differences
cancel within a cut), **100 replicates** (power MCSE at most 0.05). Cost: probes.

## 3. Decision

**Primary network: af**, the only one with both separations. **Cut-dependent** if T_var exceeds its null's
95th percentile. **Separation predicts recovery** if T_pop or T_des exceeds its null's 97.5th percentile
(Bonferroni over two slopes). Verdict: separation predicts, so a deletion benchmark is evidence only for
gaps inside the separation its cuts span; cut-dependent only, so one recovery figure misleads but the
measured separations do not locate a gap; neither, with positive-control power at least 0.8, so **the
refuting sentence holds**; neither without that power, inconclusive. The three other networks are scored
the same way on design separation and reported as secondary.

**Null control.** Under the bridge-true null, the mean share of cuts with |z| > 1.96 is at most 0.08;
otherwise per-cut z is not read as a z and only the null-calibrated statistics are interpreted.
**Positive control.** Separation-test power at least 0.8, as above. Also reported: rbx against rb mean
|z|; the share of cuts leaving a side with zero heterogeneity degrees of freedom, where any fit-based
check is vacuous; `results/cuts.csv`, every cut's separations, link, errors and z.

## 4. Departures from DESIGN.md

- **Aggregate networks, not IPD.** Population separation is one study covariate in one network; design
  separation is year or follow-up only. No component NMA or matching bridge (DIS-21 covered the matching
  bridge's threshold in simulation).
- **Real gaps are not located (G2).** No public disconnected network with these covariates is shipped in a
  package; `results/cuts.csv` publishes the separation axis against which a reader can place a real gap.
- DESIGN.md's null control (cutting a link identified by two other paths) cannot exist for a cut that
  disconnects; it is replaced by the bridge-true simulation on each network's own design.
- Cuts overlap, so every statistic is calibrated by its null rather than by independence.
- Normal approximation to arm logits; one removal rule for multi-arm studies spanning the gap.
