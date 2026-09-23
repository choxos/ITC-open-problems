# Protocol: outcome ascertainment in an external comparator

**Target problem.** QBA-07. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A trial detects progression at scheduled visits with adjudication; routine care detects it at
irregular visits and may miss it. With noninformative visits and every event bracketed, an
interval-censored likelihood removes the grid difference (OUT-14). Missed detections and visits
whose timing depends on risk are different mechanisms. **Refuting sentence:** the interval-censored
likelihood covers the practically important case, so the remaining mechanisms are refinements that
do not change a decision. DESIGN.md predicts informative visiting also biases it.

## 2. Design

Unanchored RMST(24) difference, trial arm A (visits every 2 months, perfect detection) against an
external arm B (visits about every 3 months). Weibull event times (shape 1.2, A's median 12 months)
with frailty $e^{0.6Z}$. In B: regular visits or informative visits (spacing $\propto e^{-0.5Z}$, higher-risk
patients seen more often); per-visit detection probability 1, 0.85 or 0.7, with missed events found at
a later visit or not at all. B's median equal to A's or 3 months longer. 12 cells, **1000 replicates**.
Estimand from true event times.

Methods: Kaplan-Meier on recorded times; midpoint between the last negative and the detecting visit;
interval-censored Weibull with the event in (last negative visit, detecting visit].

## 3. Decision

**Refuting sentence fails** if the interval-censored estimate is biased by more than 0.25 months beyond
3 MCSE in some cell with detection sensitivity 0.85 or 0.7. Its bias under informative visiting with
perfect detection is reported against DESIGN.md's prediction.

## 4. Departures from DESIGN.md

No recording lag or linkage parameter, no false-positive events; one frailty strength; no sensitivity
analysis over the detection parameter; no covariates or population adjustment.
