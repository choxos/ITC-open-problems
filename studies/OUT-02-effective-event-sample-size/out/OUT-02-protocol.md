# Protocol: effective sample size counted in events

**Target problem.** OUT-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

MAIC reports Kish's ESS, computed from the weights alone. With rare binary outcomes
the information in a weighted log odds is carried by events. For a weighted
proportion the sandwich variance of its log odds is, for small risks,
$\sum_i w_i^2 y_i / (\sum_i w_i y_i)^2 = 1/\mathrm{EESS}$ with
$\mathrm{EESS} = (\sum w_i y_i)^2/\sum w_i^2 y_i$. So EESS is what the sandwich already
reports. Against the weights-only reading,

$$\frac{E[\mathrm{EESS}]}{\mathrm{ESS}\cdot\bar p} = \frac{E_w[w]\,E_w[p]}{E_w[wp]},$$

below 1 when weights concentrate on high-risk patients and above 1 when on low-risk
patients. **DESIGN.md said EESS is smaller when weights concentrate away from
event-carrying patients; the sign is the reverse.** The probe gives median ratios
0.48 (target at higher risk), 2.36 (lower risk) and 1.01 (shift in a non-prognostic
covariate), and EESS times the sandwich variance of 1.01 to 1.04.

## 2. Design

Source trial A versus C, three independent normal covariates, only $x_1$ prognostic
($\gamma = 1$ on the logit scale); MAIC to target means with a shift of size $s$ in
$x_1$ upward (aligned: weights on high-risk patients), downward (misaligned), or in
$x_2$ (independent). Target control-arm marginal risk 0.005, 0.02 or 0.10;
$s \in \{0.3, 0.6, 0.9\}$; 300 or 1000 per arm; conditional log OR 0 or $-0.5$. 108
cells, **1000 replicates** (1.4 core-hours). Estimand: marginal log OR of A versus C
in the target, by quadrature. Estimator: weighted log OR with sandwich variance; no
estimate when either arm has no events.

## 3. Outcomes and decision

Per replicate: EESS, $\mathrm{ESS}\cdot\hat p$ and ESS (each combined over arms as
$1/(1/a_1 + 1/a_0)$), failure (no estimate, or interval not covering). Per cell:
bias, coverage, no-estimate rate, with MCSE.

- **Registered prediction:** median $\mathrm{EESS}/(\mathrm{ESS}\cdot\hat p)$ below 1 in
  every aligned cell and above 1 in every misaligned cell.
- **Primary:** per-replicate AUROC for failure, pooled over cells, EESS against
  $\mathrm{ESS}\cdot\hat p$ (low values read as risk), with bootstrap SE. EESS better
  by at least 0.05: **confirmed**. Within 0.02: **refuted**, the weights-only
  reading is adequate. Otherwise **borderline**.
- **Secondary:** cell-level failure rate against the cell median of each diagnostic
  (log scale), variance explained; no-estimate rate against expected events.

**Controls.** Independent-direction cells: the ratio within 0.05 of 1. Null: at
$s = 0.3$, risk 0.10, $n = 1000$, coverage in $[0.93, 0.97]$.

## 4. Departures from DESIGN.md

Direction of the mechanism corrected. Methods reduced to the weighted estimator: the
Firth, penalized, Bayesian and fail-closed arms are not run, since the question is
the diagnostic and EESS is shown to be the sandwich's own information. Dimension is
fixed at 3; zero-structure levels are not run. $n_{sim} = 1000$.
