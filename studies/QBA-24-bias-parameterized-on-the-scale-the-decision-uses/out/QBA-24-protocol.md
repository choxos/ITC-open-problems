# Protocol: does a hazard-scale bias translate proportionally into RMST?

**Target problem.** QBA-24. Numerical study (population-level, no sampling). Committed before
the computation. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A bias acting on the hazard, $h^\star = he^{\gamma}$, changes RMST over $[0, \tau]$ by
$\int_0^\tau[\exp\{-e^{\gamma}H(u)\} - \exp\{-H(u)\}]du$, which depends on the whole baseline
cumulative hazard $H$ and the window, not on $\gamma$ alone. **Refuting sentence:** a
hazard-scale bias parameter induces a monotone, approximately proportional distortion of RMST,
so a hazard-ratio sensitivity analysis can be reinterpreted on the decision scale.

## 2. Design

Baseline shapes: constant hazard, increasing (Weibull 1.5), decreasing (Weibull 0.7) and
bathtub (half Weibull 0.5, half Weibull 3), each scaled so that survival at 24 months is 0.8,
0.5 or 0.2. Bias hazard ratios $e^{\gamma}$ of 1.1, 1.25, 1.5 and 2. Window 24 months. The
proportional reinterpretation predicts $\Delta\text{RMST} = \gamma\cdot\partial\text{RMST}/\partial\gamma|_0$
with slope $-\int_0^\tau S(u)H(u)du$. Integrals by adaptive quadrature (relative tolerance
$10^{-10}$).

## 3. Decision

**Refuting sentence fails** if, at matched survival by 24 months and the same bias, the RMST
change differs by more than 25% between baseline shapes, or if the linear reinterpretation
errs by more than 20% at a bias hazard ratio of 2.

## 4. Departures from DESIGN.md

Only the translation question (section 2 consequences 1 and 2). The unanchored PAIC with an
unmeasured confounder, the pseudo-IPD and curve-based arms, reconstruction error (OUT-13) and
the tipping-set analysis are not run.
