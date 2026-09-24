# Protocol: a bridge-deletion suite with individual data on both sides of the gap

**Target problem.** DIA-16. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A bridged cross-gap comparison can be checked only by deleting a bridge where the randomized answer is
known, and one deletion says little. On a suite with individual data on both sides of every deleted path,
the matching bridge disagrees with the held-out randomized result beyond sampling error often enough that
bridged comparisons are not decision-grade, and the disagreement varies with what is measurable across the
gap. **Refuting sentence:** the matching bridge agrees with the held-out randomized result within sampling
error on nearly every deletion, so a suite adds repeatability and no evidence beyond Beliveau et al. (2017)
and Petropoulou et al. (2023).

## 2. Design

**Data.** multinma 0.9.1 (GPL-3), both simulated individual data: `plaque_psoriasis_ipd` (UNCOVER-1,
UNCOVER-2, UNCOVER-3, IXORA-S; PASI 75; durnpso, prevsys, bsa, weight, psa) and `ndmm_ipd` (Attal 2012,
McCarthy 2012, Palumbo 2014; lenalidomide versus placebo; progression-free survival; age, ISS stage III,
CR or VGPR, sex).

**Units.** Every ordered (S, M, A, B) with S not M, A an arm of both and B another arm of M: 65 psoriasis
and 12 myeloma units (probe P1). The deletion removes every path between S and M: S keeps its A arm; M
keeps B's outcomes and publishes covariate means over its arms other than A; M's A arm is withheld.
**Estimand:** A versus B in M's population (marginal log odds ratio; Cox log hazard ratio). **Reference:**
M's randomized A versus B, which carries sampling error and is not truth. The rank precondition holds by
construction (the bridge carries a whole arm); the estimand precondition holds because reference and
reconstruction share trial, outcome, follow-up and scale.

**Mechanism.** For a binary outcome, bridged minus reference equals logit p_A(S, weighted) minus
logit p_A(M) exactly, since M's B arm cancels: an unanchored bridge's deletion discrepancy is the arm-level
transport error of the carried arm. What is tested is the joint model (adjustment set and exchangeable
absolute outcomes), not the bridge alone.

**Methods.** Naive (S's A arm as observed: the random-baseline assumption without a model); MAIC matching
bridge (S's A arm weighted to M's published means). **Stratifiers, measured before recovery:** separation
(root mean square standardized mean difference between S's A arm and M's published means) and MAIC
effective sample share.

**Uncertainty.** Joint bootstrap within arm, **B = 1000**; SE is the interquartile range of the
discrepancy's bootstrap distribution over 1.349 (relative MCSE 3.7%); a |z| within two MCSE of 1.96 is a
near miss. Cost: probe P5. **Artifact:** `results/suite.csv` publishes each deletion, what M reports and the
reference with its SE, so a new method can be scored without recuration.

## 3. Decision

**Primary:** the share of the 77 main units in which the MAIC bridge has |z| > 1.96. **Not
decision-grade** if at least 0.20 (four times nominal); **consistent with sampling error** if at most 0.10
and the positive control passes; at most 0.10 with a failed positive control is "no excess disagreement
detected", not consistency; otherwise intermediate. Also reported: the naive bridge's share, the share
within a tolerance of log 1.5 (declared here, before any discrepancy is computed), and decision agreement
where the reference excludes zero. The stratification is published in every branch: Spearman correlation
of the absolute MAIC discrepancy with separation and with effective sample share, overall and by network
(the same with |z| is descriptive only, since a low effective sample share lowers |z| through the SE).
**Falsifier of the suite's headline:** both correlations below 0.2 in absolute value, meaning discrepancy
does not vary with what is measurable across the gap and two networks' averages would have sufficed.

**Null control.** Each of 7 trials split at random into halves within arm (40 splits, 200 draws each);
half 1's A arm bridged to half 2 and scored against half 2's own A versus B, at zero separation by
construction. Rejection at 1.96 at most 0.08 for both bridges (MCSE 0.013); this tests the SE machinery.
If MAIC's rejection exceeds 0.08, the primary threshold becomes the 95th percentile of the null's |z| for
MAIC, and the share is reported at both thresholds. **Positive control.** Four units with M restricted to
a prognostic subgroup (psoriasis weight >= 100 kg; myeloma ISS stage III, which then leaves MAIC's
matching set because its published mean of 1 is a boundary method of moments cannot reach): naive |z| >
1.96 in at least one; otherwise the suite contains no hard case. Probe P4 ran these four units on the real
outcomes before registration (no main unit): naive z -0.52 and 0.45 in the psoriasis units, -1.37 and
-3.44 in the myeloma units, so the control passes through one myeloma unit of 28 patients and the
psoriasis half is inert.

## 4. Departures from DESIGN.md

- **Simulated IPD shipped with multinma, not trial records.** Two networks; no curation beyond the package
  and no G2 survey.
- No factorial hidden-cell family: no public factorial IPD is packaged, and CMP-03 answered the
  omitted-interaction question by exact calculation.
- Bridges are naive and MAIC only; no random-baseline model, baseline-risk anchor, STC or ML-NMR.
- Deletion removes whole paths between two trials, not edges inside a larger network; units share arms, so
  the shares describe this suite rather than estimate a population rate.
- Only covariate means are published; extrapolation reliance is proxied by separation and effective sample
  share, not by a model-based index.
