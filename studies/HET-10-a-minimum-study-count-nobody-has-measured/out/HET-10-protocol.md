# Protocol: interval coverage for population-adjusted synthesis with few studies

**Target problem.** HET-10. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Random-effects intervals rest on a large-sample approximation in the number of studies, and in
population-adjusted synthesis one individual-data trial often supplies the adjusted contrast for
several aggregate trials, so the contrasts share its error. **Refuting sentence:**
population-adjusted network intervals are conservative enough at small study counts that the
undercoverage documented for aggregate-data methods does not appear.

## 2. Design

One individual-data trial of A versus C (300 per arm, $x \sim N(0, 1)$) and $K$ aggregate trials of
B versus C (200 per arm) in the target population ($x$ mean 0.5). Continuous outcome; A's effect
$-0.3 + 0.4x$, transported by MAIC to the target; B's effect $-0.5 + u_k$, $u_k \sim N(0, \tau^2)$.
Estimand: B versus A in the target. $K \in \{2, 3, 4, 6, 8, 12\}$, $\tau \in \{0, 0.1, 0.2\}$: 18 cells,
**2000 replicates**.

Methods: naive random-effects meta-analysis of the $K$ adjusted contrasts, each with its own variance
(DerSimonian-Laird; Hartung-Knapp); two-step analysis pooling the B-versus-C trials first
(DerSimonian-Laird; Hartung-Knapp with $t_{K-1}$) and subtracting the transported A-versus-C estimate
once.

## 3. Decision

- **Refuting sentence fails** if coverage of the naive or two-step DerSimonian-Laird interval is below
  0.93 at some study count from two to four.
- The minimum study count from which each method's coverage stays within 0.93 to 0.97 at every
  heterogeneity level.

## 4. Departures from DESIGN.md

One individual-data trial and a pairwise synthesis rather than a network; continuous outcome;
no one-stage or Bayesian route; one overlap level and one modification strength.
