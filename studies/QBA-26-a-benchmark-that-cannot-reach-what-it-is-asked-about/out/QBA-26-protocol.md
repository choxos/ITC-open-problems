# Protocol: a single-covariate benchmark against omitted composite structure

**Target problem.** QBA-26. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A held-out benchmark measures how much the estimate moves when one measured covariate is
dropped; the familiar argument then says no unmeasured structure is stronger. The omitted
structure is a sum over several unmeasured variables, and a maximum over single measured
variables bounds a sum only when one variable is omitted. **Refuting sentence:** in
realistic covariate sets the strongest measured variable is a reasonable upper bound on
plausible unmeasured structure.

**Correction.** DESIGN.md proposes scaling the benchmark by $\sqrt{q\{1 + (q - 1)\bar\rho\}}$,
the standard deviation of a sum of $q$ correlated terms. When the omitted variables are shifted
in the same direction between populations, their biases add, and the right multiplier is
nearer $q$. Both scalings are scored.

## 2. Design

Unanchored: individual data on 400 patients of A; the target reports covariate means.
Measured $x_1, \dots, x_4$ independent $N(0, 1)$, target means 0.3, outcome coefficients
0.6, 0.4, 0.3, 0.2. Unmeasured $u_1, \dots, u_q$ with pairwise correlation $\rho$ (one latent
factor), each shifted by 0.3 in the target, each with coefficient $0.6s$. Binary outcome,
$\operatorname{logit}p = -1 + x^\top\gamma_x + u^\top\gamma_u$. Estimand: A's marginal log odds in
the target. MAIC balances the measured means; its residual bias (limit minus truth) is
computed from $10^6$ Monte Carlo draws.

Factors: $q \in \{1, 3, 6\}$, $\rho \in \{0, 0.3, 0.6\}$ (one level when $q = 1$),
$s \in \{0.5, 1, 2\}$: 21 cells, **1000 replicates**.

Benchmark: the largest absolute change in the MAIC estimate from dropping one measured
covariate. Rules: plain; times $\sqrt q$ (the unmeasured assumed as independent as the
measured); times $\sqrt{q\{1 + (q - 1)\rho\}}$ with the true $\rho$ (oracle); times $q$. The
true $q$ is given to the scaled rules, which favors them.

## 3. Decision

Coverage: the share of analyses whose benchmark is at least the true residual bias.

- **Refuting sentence fails** if with $q \ge 3$ and $s \le 1$ (each omitted variable no
  stronger than the strongest measured one) the plain benchmark covers in fewer than half of
  analyses in every such cell.
- Coverage of each scaled rule by cell.

**Control.** $q = 1$, $s = 0.5$: the plain benchmark covers.

## 4. Departures from DESIGN.md

Continuous latent-factor correlation rather than binary omitted factors; one overlap level;
the negative-control route is not run (usually unavailable for the aggregate comparator).
