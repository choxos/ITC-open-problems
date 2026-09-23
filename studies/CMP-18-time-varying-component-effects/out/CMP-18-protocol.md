# Protocol: time-constant component effects when the components' effects vary in time differently

**Target problem.** CMP-18. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A time-constant component effect is a least-false summary weighted by the study's own event times, so the
sum of two components' summaries from studies with different follow-up need not be the combination's
summary. **Refuting sentence:** a time-constant component effect is an adequate summary for the estimands
decisions use.

## 2. Design

Control hazard Weibull (shape 1.2, scale 3 years); component log hazard ratios constant ($-0.4$ each), both
delayed ($-0.5(1 - e^{-t/0.7})$), or different (A delayed, B waning $-0.5e^{-t/0.7}$). Trials of A versus control and B
versus control, 300 per arm, administrative censoring at 3 and 3 years, or 1.5 and 3 years (different profiles
only). Estimand: RMST to 3 years of A+B (log hazard ratios add) minus control, by numerical integration.
Models, stratified by trial with additive components: time-constant Cox, and Cox with separate effects
before and after 1 year; prediction from trial 1's control-arm Nelson-Aalen cumulative hazard times the
fitted hazard ratios; SEs from a 60-resample bootstrap within trial arms. 4 cells, **500 replicates**.

## 3. Decision

**Primary:** different profiles with follow-up 1.5 and 3 years. **Extension established** if the time-constant
model covers below 0.90 while the piecewise model covers at least 0.93; **refuting sentence holds** if the
time-constant model covers at least 0.93 in every cell; otherwise neither is nominal where it matters.
Reported: bias, MCSE, coverage, SE ratio, RMSE per cell and model.

## 4. Departures from DESIGN.md

Two single-component trials rather than a component network, no disconnection or population adjustment,
one piecewise extension (not flexible splines or fractional polynomials), RMST at one horizon only.
