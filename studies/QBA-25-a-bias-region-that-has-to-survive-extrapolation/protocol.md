# Protocol: a bias region carried through survival extrapolation into net benefit

**Target problem.** QBA-25. Numerical decision-model study. Committed before the computation.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A bias parameter specified on the observed hazard ratio acts on a decision that depends mostly on the
extrapolated period, through an extrapolation model that is itself uncertain. **Refuting sentence:**
propagating a corrected point estimate with its interval into the economic model reproduces the decision
surface adequately, so a shared parameter space is unnecessary.

## 2. Design

Control survival Weibull (shape 1.3, median 4 years), or 30% cured plus the same Weibull. Follow-up 3 years;
reported log hazard ratio $\log 0.75$, SE 0.10; bias $b$ on the log hazard ratio (reported = true + $b$), elicited
uniform on $[-0.15, 0.15]$. Treatment-effect extrapolation after 3 years: proportional hazards, linear waning
to no effect by year 8, or cure (effect on the uncured only). Economic model: 25 years, 3.5% discounting,
utility 0.75, treatment cost for the first 3 years alive (set to 90% of the break-even price under
proportional hazards at the reported estimate, so the base case is favorable), background cost 5000 per
year alive, threshold 30000 per QALY. 4000 probabilistic draws.

Methods: point propagation (sampling uncertainty in the log hazard ratio, proportional hazards, $b = 0$);
scenario analysis (INB at $b = \pm0.15$ under proportional hazards, and each family at $b = 0$, per current
guidance); the shared-parameter reference (sampling, $b$ and family drawn jointly, family uniform), and the
same per family.

## 3. Decision

**Primary:** probability that INB is negative (decision reversal) under point propagation against the
joint reference. **Confirmed** if the joint probability is at least 1.5 times the point-propagation
probability; **refuted** otherwise. Reported: scenario INBs, per-family joint probabilities, and the lowest
INB over the one-at-a-time cross against the joint region of $b$ and family at the reported estimate.

## 4. Departures from DESIGN.md

Population-level decision model with a declared data-generating curve rather than fitted extrapolations;
three extrapolation families, not splines; one bias parameter; no PSA over costs or utilities; no tipping
surface summary for several bias parameters. QBA-24 (the prerequisite) is published.
