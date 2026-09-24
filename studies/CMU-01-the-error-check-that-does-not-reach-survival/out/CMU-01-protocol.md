# Protocol: does multinma's split-chain check see material integration error in a survival contrast?

**Target problem.** CMU-01. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

multinma's `int_check` runs half the chains at $Q$ integration points and half at $Q/2$ and attributes a pooled
R-hat or ESS failure to integration. It is relative: two orders that are wrong in the same direction agree and
pass. So a flexible survival ML-NMR can pass the check while its contrast carries material integration error.
**Refuting sentence:** the split-chain check already catches insufficient integration, so an analyst who cuts
points is warned and a cumulative-error plot is a convenience.

## 2. Design

One IPD study (P vs A, 200 per arm) and $S \in \{4, 12\}$ aggregate studies (P vs B, 100 per arm, individual event and
censoring times, 5 covariates published as means and SDs, study means spread over $[-0.5, 0.5]$). Weibull event
times, shape 1.3, log hazard ratio $x'b + d_k + g_k x_1$ with $b = 0.3$, $g_A = 0.2$, $g_B = 0.3$; uniform censoring on (5, 40).
Fitted by multinma 0.9.1 with a Weibull or M-spline (7 knots) baseline, fixed effects, $\sim (x_1 + \dots + x_5) + x_1$:trt.
**Estimand:** the conditional log hazard ratio B vs A at target $x_1 = 0.5$, $c(\theta)$. **Integration error, defined:**
on multinma's own log density (`rstan::log_prob` on a `Fixed_param` stanfit), the posterior mode at every $Q$ in
{4, 8, ..., 512} and at $Q_{ref} = 1024$; Sobol points are extensible, so each smaller set is a prefix of the reference
set. $r(Q) = (c(Q) - c(1024)) / \mathrm{SD}$, SD the Laplace posterior SD of $c$ at $Q$ 128. **Material:** $|r| \ge 0.25$, which moves a
posterior probability of benefit by up to 10 points and a 95% interval's miss rate from 5.0% to 5.7%.
**The check, emulated:** every quantity multinma saves (parameters, per-observation log-likelihood and deviance,
lp__) is compared between the $Q$ and $Q/2$ modes in units of its Laplace SD; the check fires when the largest shift
reaches $\delta^*$, the shift at which multinma's own R-hat and ESS rules fire on half of 400 sets of ideal chains
(`dstar()`; the probe's 100 sets gave 0.357 SD, firing probability 0.09 at 0.30 and 0.89 at 0.40). **Candidate check:** the Laplace prefix difference $|c(Q) - c(Q/2)| / \mathrm{SD} \ge 0.25$. Cells: {Weibull,
M-spline} x $S$ {4, 12}, 50 datasets each; an integration-free null cell (published covariate SDs zero) of 50; a
validation cell of 10 datasets (Weibull, $S = 4$) where the real check runs at default chains, $Q$ 8 and 16.
Classifier unit: (dataset, $Q$), $Q$ 8 to 512, MCSE by dataset-clustered bootstrap. **Datasets:** 50 per cell give 350
pairs; with a third material, sensitivity carries an MCSE near 0.04 (0.031 when the analysis ran on synthetic
output of that shape), so the 0.5 and 0.9 thresholds sit 10 MCSE apart. **Cost** (probes, user time under
load average 193, an upper bound): 49 CPU s per Weibull $S = 4$ dataset, 144 s per M-spline $S = 12$ dataset (165
parameters, every L-BFGS-B fit converged in at most 146 evaluations), 1631 s per validation dataset; 9.7 CPU hours
in all, one worker (the probe's R heap peaked at 4.5 GB).

## 3. Decision

**Primary cell:** M-spline, 12 aggregate studies. **Confirmed** if the sensitivity of the emulated check to material
residual error, pooled over $Q$, is below 0.5; **refuted** if at least 0.9; otherwise mixed. False-alarm rate and the
$Q = 64$ slice are reported with it. The rule is not evaluable, and reported as such, if the emulator agrees with
the real check in fewer than 80% of validation fits or the primary cell has fewer than 20 material pairs.
**Comparator that can win:** the split-chain check itself; a sensitivity of at least 0.9 refutes the claim.
**Positive control:** in the primary cell, material error at $Q = 16$ in at least half of datasets; if not, cutting
points is harmless here and the concern does not arise. **Null control:** with zero covariate SDs every order
integrates exactly: every $|r|$ and every shift at most 0.01. **Second null control:** $|r(512)| \le 0.05$ in at least 95%
of datasets per cell, so the reference is a reference. **Falsifier for consequence 2:** Spearman correlation of the
largest per-arm log-likelihood error with $|r|$ at least 0.9 means a scalar summary suffices. Runtime per order is
reported against residual error in either branch.

## 4. Departures from DESIGN.md

Error is measured at the Laplace level (modes and a Laplace SD), not from posterior means, because a sampled
M-spline fit with 12 aggregate studies costs CPU hours; the real check is run only in the cheapest validation cell.
The emulation uses ideal independent chains, the check's best case. Estimand is a conditional log hazard ratio,
not marginal RMST or milestone survival. Adaptive integration is the candidate prefix check read as a stopping
rule; within-chain parallelization is not evaluated (not in multinma 0.9.1). The Gaussian closed-form control is
replaced by the zero-SD network. Censoring, covariate dimension and knot count are fixed; 50 datasets per cell.
Probe P5 ran the real check at 4 x 300 iterations only to prove the pipeline; at that length the within-order ESS
rule attributes warnings to the sampler, so the validation cell uses the default 4 x 2000.
