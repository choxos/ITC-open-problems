# Protocol: a masked-IPD benchmark scored against its own estimand and at the arm level

**Target problem.** DIA-17. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A transport model predicts absolute arm outcomes; its relative effect is a difference of two predictions
and can agree with a randomized benchmark while both predictions miss. **Refuting sentence:** where the
anchored relative effect agrees with the masked trial's randomized result, the arm-level predictions agree
too, so arm-level calibration adds nothing to relative-effect validation. Finished studies bear on this
only in simulation: IDN-10 showed a transported control-arm check tests prognostic, not modifier,
transport; IDN-07 calibrated a held-out-trial rule. This study scores both halves on masked IPD.

## 2. Design

**Data.** `plaque_psoriasis_ipd` from multinma 0.9.1 (GPL-3; Phillippo 2019): simulated individual data
constructed to resemble UNCOVER-1, UNCOVER-2 and UNCOVER-3. Outcome PASI 75; covariates durnpso,
prevsys, bsa, weight and psa, the effect modifiers of Phillippo et al. (2020); rows missing any are dropped.

**Units.** Source S in {UNCOVER-1, UNCOVER-2, UNCOVER-3} supplies IPD on A (ixekizumab Q2W or Q4W) versus
placebo. Masked trial M in {UNCOVER-2, UNCOVER-3}, M not S, is reduced by one fixed function to what a
publication of etanercept versus placebo reports: arm sizes, responders and covariate means over those
two arms. M's A arm is withheld from every method. 8 main units. Target: M's population. **Estimand:**
marginal log odds ratio of A versus etanercept in M.

**Methods.** Bucher (unadjusted); MAIC (method of moments on the five means); STC conditional
(main-effects logistic model in S, treatment coefficient minus M's etanercept versus placebo log odds
ratio); STC marginal (the same model averaged over the MAIC-weighted S covariates).

**References, paired before any estimate is seen.** From M's full IPD: the marginal log odds ratio of A
versus etanercept for Bucher, MAIC and STC marginal; for STC conditional, its own functional evaluated in M
(conditional A versus placebo log odds ratio from the same main-effects model fitted to M, minus M's
marginal etanercept versus placebo log odds ratio). The **collapsibility gap** is the difference of the two
references. **Arm level:** each marginal method's predicted logit of M's placebo and A response against M's
observed arms; count logits carry a 0.5 correction (UNCOVER-2's placebo arm has 4 responders).

**Uncertainty.** Joint bootstrap: S and M resampled within arm and the whole pipeline rerun; the SE of each
discrepancy is the interquartile range of its own bootstrap distribution over 1.349, so arms shared by
estimate and reference cancel; z is discrepancy over SE. **B = 1000** gives the SE to 3.7% relative MCSE
(1.16 over the square root of B), so a z within 0.07 of a threshold is reported as a near miss. Cost:
probe P4.

## 3. Decision

**Primary: MAIC in the 8 main units.** A unit is discordant if relative |z| <= 1.96 and an arm-level
|z| > 2.24 (0.05 split over two arms). **Confirmed** if at least 2 units are discordant (probability
about 0.05 under exact absolute transport, units taken as independent); **refuted** if none is discordant,
at least 4 agree on the relative effect and the positive control passes; if the positive control fails,
"no discordance detected" without refutation; otherwise inconclusive. Reported for every method and unit: z,
collapsibility gap, whether STC conditional's verdict changes between its own and the marginal reference,
effective sample share.

**Null control.** Four self units (S = M): Bucher must reproduce the reference and both arms exactly in
every bootstrap draw (tests masking and bookkeeping); MAIC relative |z| <= 1.96. No collapsible-scale null
control is registered: with the covariates held fixed, the regression-adjusted risk difference sat at a
fixed offset from the crude one under a logistic truth (probe P3), so it does not isolate the pairing; the
risk-difference gap is reported descriptively. **Positive control.** Two semi-synthetic units (S
UNCOVER-1, A Q2W, M UNCOVER-2 or UNCOVER-3): every arm of M regenerated from a main-effects logistic model
fitted to M plus 1 logit, a baseline shift that moves every arm and leaves the relative effect nearly
intact; MAIC must be discordant in at least one. Probe P5: discordant in both (relative z -1.77 and 1.67;
worst arm z -2.48 and -4.62).

## 4. Departures from DESIGN.md

- **Simulated IPD shipped with multinma, not trial records.** No public multi-trial IPD with a shared arm
  was found; agreement patterns reflect Phillippo's simulation model as much as the trials. One network,
  one outcome; the G3 dataset survey is not done.
- Target is the masked trial's own population; no external target.
- No ML-NMR, ML-UMR or NMI: Stan fits are not affordable on the shared machine. multinma's vignette fits
  ML-NMR to these data, so it can be added as a method later without changing the units.
- Masking reports means only, not SDs; MAIC matches means.
- STC uses main effects only: with 4 placebo responders an interaction model separates.
- IXORA-S (no placebo arm) is not used; rotation covers 3 sources and 2 masked trials.
- The positive control was changed before registration. M restricted to weight >= 100 kg was probed on
  the real outcomes (shift units only, no main unit): unadjusted arm-A z -0.52 and 0.56, so it could not
  fire; it was replaced by the baseline shift above.
- DESIGN.md's second null control (conditional and marginal references coinciding on a collapsible
  scale) is not registered; section 3 gives the reason.
- Units share arms, so the 8 verdicts are not independent and the 0.05 calibration is approximate.
