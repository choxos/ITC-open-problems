# Protocol: what each transitivity screen can see

**Target problem.** IDN-01. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A screen is a function of the observed data; a violation whose projection onto what the
screen responds to is zero is detected at the screen's size. For the usual screens the
blind spots can be constructed: covariate dissimilarity sees only reported covariates,
the loop inconsistency test sees only violations that break the loop, and heterogeneity
sees only within-comparison variation. A violation in which an unreported modifier makes
one treatment look better in every comparison that includes it closes the loop, varies no
reported covariate and adds no within-comparison variation, so no screen sees it.
**Refuting sentence:** the available screens, run together, have adequate power against
the violations that occur and agree on which mechanism failed.

## 2. Design

Triangle network A, B, C with $M \in \{2, 5\}$ studies per comparison, each estimating its
contrast with SE 0.15 and reporting the mean of a measured modifier.
$d_B = -0.3$, $d_C = -0.5$ against A. Mechanisms of size $V \in \{0.1, 0.2, 0.4\}$:

| mechanism | construction | visible to |
|---|---|---|
| none | | nothing |
| measured modification | C's effect modified by the measured covariate ($V/0.5$ per unit), whose means differ by comparison (0, 0.5, 1) | dissimilarity; adjusted by meta-regression |
| unmeasured, loop-consistent | C's contrasts against A and B both shifted by $-V$ (an unreported modifier where C was tested) | none, by construction |
| loop break | B-versus-C studies shifted by $V$ | inconsistency |
| drift | study-specific shifts $N(0, V^2)$ | heterogeneity |

26 cells, **2000 replicates**. Screens at $p < 0.10$: ANOVA of the modifier means across
comparisons; Bucher direct-versus-indirect test; Cochran's $Q$ within comparisons. Estimand:
B versus C in the declared target (measured modifier 0.5, no unreported shift). Estimator:
fixed-effect consistency NMA, with meta-regression on the measured modifier when its study
means vary.

## 3. Decision

- **Refuting sentence fails** if at $V = 0.4$ the loop-consistent unmeasured mechanism is
  flagged by any screen no more often than under no violation plus 0.05, while the target
  contrast is biased by more than 0.1, at both network sizes.
- Detection of each mechanism by each screen and by their union; bias and coverage.
- Mechanism identification from the flag pattern (dissimilarity read as measured
  modification, inconsistency as loop break, heterogeneity alone as drift, nothing as no
  violation), scored as a confusion table.

**Controls.** No violation: each screen near 0.10. Measured modification: the adjusted
estimate unbiased while dissimilarity fires, a flag that does not indicate bias.

## 4. Departures from DESIGN.md

Stylized triangle networks rather than tracenma geometries; continuous study-level
estimates; calendar-time drift represented as random study shifts; no abandonment
records scored (section 11 of DESIGN.md), which need the published protocols.
