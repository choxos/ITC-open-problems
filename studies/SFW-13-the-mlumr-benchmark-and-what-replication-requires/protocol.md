# Protocol: mlumr against an independent g-computation and an analytic omitted-covariate bias

**Target problem.** SFW-13. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).
**Conflict of interest:** mlumr and cpaic are written by this catalog's author (mlumr at the pinned commit
also lists a second author). This is a self-run benchmark with committed generator, seeds and raw outputs;
it is not independent replication and does not claim to be. Package: mlumr as installed, DESCRIPTION
0.1.0.9000, RemoteSha 006b604 (18 September 2026); the catalog cites 0.2.0 at b2e24ce (1 June 2026), an
earlier commit with a higher version string. cpaic is CMP-26's subject; at its commit cf27b1a `cmlnmr()`
already has marginal standardization (`R/marginal_effects.R`), which the catalog lists as missing.

## 1. Claim

mlumr's ML-UMR transports the index treatment's absolute outcome to the comparator's population. Under the
shared prognostic factor assumption with the comparator's intercept free, the aggregate arm informs only
that intercept, so the posterior for the index treatment's response probability there is the g-computation
of the individual-data model over the comparator's declared covariate law. That gives a second route to the
same number. **Refuting sentence:** the implementation is correct and its bias under a violated unanchored
assumption is exactly the identification failure theory predicts, so the only gap is the untestable
assumption.

## 2. Design

Unanchored, binary outcome, logit link. Individual data on 300 patients given A: $x_1 \sim N(0,1)$,
$x_2 \sim \text{Bern}(0.4)$, $u \sim N(0,1)$. Comparator B, 300 patients, publishing events and the mean and SD
of $x_1$ and the proportion with $x_2 = 1$: $x_1 \sim N(m_1, 1)$, $x_2 \sim \text{Bern}(0.5)$, $u \sim N(1,1)$.
$\operatorname{logit}P(Y=1) = \alpha_t + 0.6x_1 + 0.5x_2 + b_u u$, $\alpha = (-0.3, -0.6)$; $u$ is never reported.
Cells: $b_u \in \{0, 0.25, 0.5\}$ (no, moderate, strong omitted prognostic covariate) $\times$ $m_1 \in \{0.3, 1\}$
(overlap). **Estimand:** A's response probability in B's population (primary), and the marginal log odds
ratio there. **Analytic bias (P1):** the least-false logistic fit of $y$ on $(x_1, x_2)$ in the IPD population,
standardized over B's declared law, minus the truth: $-0.052$ to $-0.056$ (moderate) and $-0.098$ to $-0.106$
(strong) on the probability scale. Methods: **mlumr** SPFA, default priors, 2 chains, 2000 iterations, 256
integration points, declared correlation 0 (its true value); **witness**, an independent g-computation (glm
on the IPD, exact quadrature over the declared law, delta-method SE, no mlumr code); **mlumr::stc()**;
**mlumr::naive()**. 6 cells, **200 replicates** (bias MCSE about 0.002, coverage MCSE 0.015). About 24.5 CPU
hours, extrapolated from one smoke fit at 13% CPU share (probes).

## 3. Decision

Checks on mlumr: **agreement**, posterior mean within 0.25 posterior SD of the witness in at least 95% of
replicates in every cell; **reduction**, in the IPD's own population the posterior mean within 0.25 posterior
SD of the IPD proportion in at least 95% (the second null control: no transport); **null control**, with no
omitted covariate $|\text{bias}| \le \max(3\,\text{MCSE}, 0.005)$ and coverage 0.915 to 0.985 (about 2.3 MCSE); **positive control**,
under strong omission the bias equals the analytic value within $\max(3\,\text{MCSE}, 0.005)$ (an estimator
unbiased there is not doing unanchored comparison). **Primary verdict:** *implementation defect indicated* if
agreement, reduction or the null control fails; *bias beyond the known identification failure* if strong-omission
bias exceeds the analytic value by more than the tolerance; *behaves as the theory says on the checkable
part* if all pass; otherwise mixed. A failed agreement check is localized before any claim, prior shrinkage
first (refits with flat priors on the failing replicates), then integration error, then the sampler. Reported for every method and cell: bias, coverage, empirical SD, mean SE,
failure rate; for mlumr, share of fits with Rhat above 1.01 or any divergence. A near-miss is reported as one.

## 4. Departures from DESIGN.md

No `multinma` overlap check: multinma 0.9.1 refuses single-arm studies in `set_ipd()`, so no unanchored
problem lies in both packages' scope, and the refuting sentence has an internal witness only. Binary outcome
only; SPFA only (the relaxed model's comparator slopes are informed by the aggregate likelihood alone); one
omitted-covariate mechanism; target the comparator's population only (the IPD's own population enters as a
check, no external target); no omitted effect modifier, prior-sensitivity calibration (P3), QBA arm or
published-example reproduction; cpaic's marginal-standardization gap not studied. **Probe finding
(P2):** at mlumr's default 64 integration points the index probability is shifted by $-0.0045$ ($-0.0037$ to
$-0.0056$, one sign in every dataset, about 0.17 posterior SD), because the point set is deterministic; the
registered run uses 256 ($-0.0010$).
