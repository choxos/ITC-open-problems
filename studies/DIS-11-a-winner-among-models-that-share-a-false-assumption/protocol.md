# Protocol: a predictive winner among models that share a false bridge

**Target problem.** DIS-11. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Leave-one-out compares candidates by their fit to observed units. If every candidate shares a bridge
assumption, the bridge's error is common and drops out of the ranking, so the criterion returns a winner
whose cross-gap error is arbitrary. Candidates that differ only in an observationally equivalent bridge
have identical predictive scores by definition. **Refuting sentence:** models that differ in bridge
assumption also differ in within-subnetwork fit enough that predictive criteria rank them correctly.

## 2. Design

Two disconnected subnetworks of 8 trials (A versus B; C versus D) linked by exchangeable baselines, with a
design nuisance of 0, 0.2 or 0.5 on subnetwork 2's baselines that the bridge carries into C versus A.
Within subnetworks the contrast varies with a trial covariate (slope 0 or 0.3) plus heterogeneity (SD
0.1). Candidates sharing the bridge: common effect, random effects, meta-regression on the covariate.
Leave-one-trial-out log predictive density picks a winner. 6 cells, **1000 replicates**.

## 3. Decision

**Refuting sentence fails** if, at each covariate-slope level, the distribution of winners does not depend
on the bridge error (chi-square $p > 0.01$) while the cross-gap bias ranges across the nuisance levels.

## 4. Departures from DESIGN.md

Study-level summaries and frequentist predictive densities rather than LOO-PSIS on an ML-NMR fit; no
grouped leave-subnetwork-out or synthetic-deletion arm; population comparison not simulated.
