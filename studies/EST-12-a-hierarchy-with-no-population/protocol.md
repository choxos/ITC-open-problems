# Protocol: treatment hierarchies across target populations

**Target problem.** EST-12. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Ranking metrics are functionals of every relative effect, so they inherit each contrast's
population dependence; two treatments swap ranks between targets exactly when the targets lie
on opposite sides of their zero-difference boundary. **Refuting sentence:** rank movement across
plausible targets is small relative to rank movement from sampling variability, so a target
referent changes nothing a reader would act on.

## 2. Design

Star network: treatments B to F each compared with A in $M \in \{2, 5\}$ trials with covariate
means uniform on $[-1, 1]$; trial estimates $\delta_t + \beta_t\bar x + e$, SE 0.1. Effects
$\delta = s(0, 1, 2, 3, 4)$ with spacing $s \in \{-0.05, -0.15\}$ (lower is better);
modification $\beta_t = \text{spread}\cdot(2, 1, 0, -1, -2)/2$, spread $\in \{0, 0.2, 0.4\}$. Targets at
covariate means $-w, 0, w$ with $w \in \{0.5, 1\}$. 24 cells, **1000 replicates**.

Analysis: fixed-effect meta-regression per treatment, P-scores at each target. Rank movement is
the mean absolute rank change per treatment: across the two outer targets within a replicate,
and across two independent replicates at the middle target.

## 3. Decision

- **Refuting sentence fails** if, in every cell where the true ranking changes across targets,
  the estimated movement across targets exceeds the movement across replicates beyond 3 MCSE.
- Movement across targets where the true ranking does not change (spurious movement through the
  slope estimates) and the probability of naming the wrong best treatment at the middle and an
  outer target are reported.

## 4. Departures from DESIGN.md

Star network with study-level meta-regression rather than ML-NMR on individual data; P-scores
only (SUCRA and probability-best not computed); one covariate; fixed-effect.
