# Protocol: a benchmark discrepancy separated before it becomes a residual-bias prior

**Target problem.** QBA-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered:** nothing in this program; no finished study lists QBA-02 and no note covers it. The
entry has two halves. Whether concealing the randomized answer changes analysts' discrepancies needs
analysts and data governance and is **not simulated**. The other half is DESIGN.md section 2: a benchmark
discrepancy $D = b + \varepsilon + m$ folds sampling error and estimand mismatch into its spread, so it can
inform a residual-bias prior only after they are separated. This study targets that half, the pre-gate
step (G0, G3) that needs no new data.

In the Gupta et al. design each emulated comparison reuses the trial's experimental arm, so
$\mathrm{Var}(\varepsilon) = 1/E_c + 1/E_e$; the sum of the two reported squared SEs adds $2/E_x$.
**Refuting sentence:** the raw discrepancy distribution is an adequate residual-bias prior at the benchmark
sizes in use, because its sampling component is small beside the systematic one.

Arithmetic on the published summary (P2): per-comparison discrepancies $-0.229$ to 1.205 over 15
comparisons imply an SD of about 0.413 (variance 0.171); with per-comparison sampling variance 0.01 to 0.04,
77% to 94% of it would be systematic. The per-trial SEs are not in this repository, so that bracket is
declared, not computed.

## 2. Design

A benchmark of $K \in \{15, 40\}$ comparisons; events per arm uniform on 25 to 150 (per-comparison SEs 0.12
to 0.28); per-arm log-hazard errors $N(0, 1/E)$; systematic bias $b_k \sim N(0.1, \tau^2)$,
$\tau \in \{0, 0.1, 0.3\}$; mismatch SD $\sigma_m \in \{0, 0.1\}$. Priors $N(\hat\mu, \hat\tau^2)$: **raw**
(mean and variance of $D$); **naive** (variance minus the mean of both squared SEs, truncated at 0);
**shared** (variance minus the mean of $1/E_c + 1/E_e$); **REML** random effects with the shared-arm
within variances, predictive, $t_{K-2}$ and $\mathrm{se}(\hat\mu)^2$ added. A new unanchored submission,
$\hat\theta = \theta + b_{\text{new}} + e$, SE 0.15, same bias law, no mismatch; its bias-adjusted 95%
interval $\hat\theta - \hat\mu \pm q\sqrt{0.15^2 + \hat\tau^2}$. Estimand: $\theta$, known; coverage given
the prior is a normal probability, computed exactly and averaged over benchmark programs. Also reported:
half-width over the oracle's (known $\mu$ and $\tau$) and the bias of $\hat\tau^2$. Limits at $K = 15$
without mismatch (P1): raw 0.997, 0.993, 0.972; naive 0.950, 0.897, 0.909; shared 0.950 at each $\tau$.

Common random numbers across mismatch levels. 12 cells, **2000 replicates** (benchmark programs): the SD of conditional coverage across programs was at
most about 0.12 in the smoke, so coverage MCSE is at most 0.003. Measured cost 0.16 CPU-hours.

## 3. Decision

**Primary** ($K = 15$, no mismatch, $\tau = 0, 0.1, 0.3$). **Confirmed** if raw coverage exceeds 0.975 at
$\tau = 0$ and 0.1 and REML coverage lies in 0.925 to 0.975 at $\tau = 0.1$ and 0.3; **refuted** if raw
coverage lies in 0.925 to 0.975 at all three; otherwise mixed. REML's band excludes $\tau = 0$ because any
variance estimate truncated at zero is biased upward there; its coverage there is reported. **Secondary:**
subtracting both squared SEs over-corrects if naive coverage is at most 0.925 at $\tau = 0.1$ or 0.3.

**Null control:** $\tau = 0$, $\sigma_m = 0$: $\mathrm{var}(D)$ minus the true sampling variance,
untruncated, within 3 MCSE of 0. **Positive control:** at $\tau = 0.1$ and 0.3 and both $K$, REML's bias in
$\hat\tau^2$ with $\sigma_m = 0.1$ minus its bias with $\sigma_m = 0$ is at least 0.005 (expected 0.01), since a
mismatch of variance 0.01 cannot be subtracted; the difference removes the upward bias that truncation alone
gives at small $\tau$.

## 4. Departures from DESIGN.md

The concealed-then-revealed comparison, stratification across diseases and outcomes, tipping-conclusion
agreement and the governance survey are not run; G0 on the published per-trial values is replaced by
arithmetic on the published range; log hazard ratio errors are normal with known event counts rather than
fitted survival data; one submission SE; the submission shares the benchmark's bias law, so a calibration's
transportability, which DESIGN.md calls unverifiable, is assumed. **Set after probes:** the positive control
was restated as a difference between mismatch levels after the pipeline test showed REML's $\hat\tau^2$ biased
upward by about 0.005 at $\tau = 0$ from truncation alone.
