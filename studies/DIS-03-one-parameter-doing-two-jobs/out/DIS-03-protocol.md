# Protocol: a baseline-risk bridge across a disconnected network

**Target problem.** DIS-03. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

When disconnected subnetworks are linked by assuming exchangeable baseline risks, one baseline
term both carries the bridge and absorbs study-level nuisance (endpoint definition, follow-up,
ascertainment), and nothing inside the graph separates the two. **Refuting sentence:** design
differences leave a signature in observable baseline heterogeneity, so a model with design
covariates recovers the bridge.

## 2. Design

Subnetwork 1: $K$ trials of A versus B; subnetwork 2: $K$ trials of C versus D. Arm-level log
odds $\mu_s + d_t$ with $\mu_s = -1 + b_s + \eta D_s + e_s$: prognostic $b_s \sim N(\text{drift}\cdot\mathbb 1[\text{subnetwork 2}], 0.3^2)$,
a binary design covariate $D_s$ with nuisance effect $\eta$, arm-level sampling error SE 0.15.
$D_s$ equals 1 in subnetwork 2 and 0 in subnetwork 1, except that a share (the overlap) of
trials in each uses the other's definition. $d = (0, -0.3, 0.2, -0.2)$ for A, B, C, D.

Factors: $\eta \in \{0, 0.2, 0.5\}$, overlap 0 or 0.25, drift 0 or 0.2, $K \in \{5, 10\}$: 24
cells, **2000 replicates**. Estimand: $d_C - d_A = 0.2$.

Methods: exchangeable-baseline bridge (difference in mean control-arm log odds between
subnetworks); the same with the control-arm baselines adjusted for $D$, possible only when $D$
varies within a subnetwork.

## 3. Decision

**Refuting sentence fails** if, without overlap and with $\eta > 0$, the bridge is biased by more
than 0.1, or if, with overlap and prognostic drift, the adjusted bridge is biased by more than 0.1.

## 4. Departures from DESIGN.md

Study-level summaries on the log odds scale rather than an arm-based Bayesian model; no
commensurate prior; the bridge contribution is the whole cross-gap contrast here by construction.
