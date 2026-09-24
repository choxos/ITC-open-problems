# Protocol: where ML-NMR cost binds, measured as CPU per effective draw

**Target problem.** SFW-06. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

ML-NMR cost grows with total integration rows in a way that does not amortize across iterations, so integration
arithmetic is what constrains repeated fits. **Refuting sentence:** after multinma 0.9.1 reduced the default
integration burden, cost per effective draw at realistic scales is governed by sampler geometry rather than
integration arithmetic, so integration rows are the wrong axis for a scaling map.

## 2. Design

CPU per effective draw factorizes exactly: $\text{CPU}/\text{ESS} = t_{grad} \times G$, with $t_{grad}$ the CPU seconds of one
log-density gradient (arithmetic) and $G$ = leapfrog steps per bulk effective draw of the decision contrast
(geometry, counted by the sampler and independent of machine load). **E1** times $t_{grad}$ on multinma's own
compiled model (a `Fixed_param` stanfit, `rstan::grad_log_prob` repeated until 1 CPU second is used), 5 repeats
per cell in a seeded random order, over integration points $Q \in \{32, 64, 128, 256, 512\}$ x aggregate studies
$S \in \{4, 16\}$ x covariates $p \in \{2, 5\}$ x outcome {binomial logit, survival with the default 7-knot M-spline
baseline} x {fixed, random} effects: 80 cells, plus 2 null cells. **E2** runs NUTS (2 chains x 1000, 500 warmup) at
binomial $S = 16$, $p = 2$, $Q \in \{32, 128, 512\}$, fixed and random, and M-spline $S = 4$, $p = 2$, fixed, $Q \in \{32, 128\}$:
8 cells, 3 repeats. Network: one IPD study (P vs A, 200 per arm) and $S$ aggregate studies (P vs B, 100 per arm;
survival arms carry individual times), covariates $N(m_j, 1)$ with study means spread over $[-1, 1]$,
regression $\sim (x_1 + \dots + x_p) + x_1$:trt; with all $p$ interactions the aggregate-only B interactions made NUTS
diverge in 5.9% of transitions in the first probe, a pathology rather than a computational factor. Rows per gradient: $2SQ$ (binomial), $200SQ$ (survival). multinma 0.9.1
defaults except `int_check = FALSE` and `cores = 1`; CPU is user time of one process. Decision contrast: B vs A
at target $x_1 = 0.5$. Total 90 cells, 434 tasks. **Repeats:** the probe's SD of log $t_{grad}$ over 8 timings was 0.025,
so 5 repeats give a log-log slope MCSE of 0.005 over 5 levels of $Q$; 3 repeats per E2 cell (ESS-based $G$ varies
more). **Cost** (probes, user time under load average 849, an upper bound): E1 0.5 CPU hours, E2 0.7 (extrapolated
from E1 timings and the smoke fit's leapfrog count), 1.2 in all.

## 3. Decision

**Primary:** the elasticity of CPU per effective draw with respect to $Q$, $e_C = e_g + e_G$, the log-log slopes of $t_{grad}$
(E1) and $G$ (E2) over $Q$ 32 to 512 in the binomial $S = 16$, $p = 2$ cells, separately for fixed and random effects.
**Integration rows bind** if $e_C \ge 0.7$ in both; **refuting sentence holds** if $e_C \le 0.3$ in both; otherwise mixed,
reported as measured. **Falsifier:** $e_G \le -0.2$, more points buying mixing. **Factorization check:** in the probe, in-sampler CPU per
gradient was 1.6 times E1's at the smallest E2 cell (setup and adaptation overhead), so the elasticity of whole-fit
CPU per effective draw is reported beside $e_C$ and a difference above 0.2 is reported as a failure of the
factorization, not absorbed into the verdict. **Positive control:** log-log slope of
$t_{grad}$ on $Q$ at least 0.85 for M-spline, $S = 16$, $p = 5$, $Q$ 128 to 512 (the largest rows); if it fails, the linear
cost model is wrong. **Null control:** with no regression multinma integrates nothing, so $t_{grad}$ at $Q$ 512 over
$Q$ 32 must be 0.8 to 1.25 (rows differ 16-fold, so a harness that tracked rows would give about 16; the band is
set wider than the first probe's single-timing 0.86); if not, the harness measures something other than the model. **Comparator that can win:**
the package default $Q = 64$: if the switch point below exceeds 64 in the binomial cells, integration is under half
of each gradient at the default and the refuting sentence holds there, whatever $e_C$ says above it. Registered secondary: product sufficiency,
$t_{grad}(S 4, 4Q) / t_{grad}(S 16, Q)$ within 0.8 to 1.25; and the **switch point** $Q^* = a/c$ from
$t_{grad} = a + cQ$ in each configuration, the order at which integration is half the per-gradient cost, reported
in either branch.

## 4. Departures from DESIGN.md

The feasible frontier and the runtime prediction model are not built: both need portable absolute times, which a
machine at load average 450 to 900 cannot give; CPU hours per 1000 effective draws are reported per E2 cell
instead. Measurement is CPU user time, not wall clock, with no exclusive machine; tasks run in random order so
contention falls alike, and the load average is recorded per task. No cmdstanr arm (multinma 0.9.1 has only
rstan). Normal outcome, 10 covariates and 25 studies dropped; survival sampled only at $S = 4$. E2 runs 2 x 1000,
not the default 4 x 2000, and `int_check = FALSE`. P1 (reproducing OUT-11's production timings) is not run; no
integration-error import; no verdict on a sensitivity program. Two choices followed a probe number: one effect
modifier instead of full interactions, with study means widened from $[-0.5, 0.5]$ to $[-1, 1]$ (divergences), and the
null band set at 0.8 to 1.25 (a single-timing ratio of 0.86).
