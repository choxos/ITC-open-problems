# Protocol: a support diagnostic integrated over a target law reconstructed from marginals

**Target problem.** OVL-03. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

**Already answered, by OVL-01.** With a known target law, G-computation's interval widened where the source
was thin and still covered 0.70 when the modification bent in the unsupported region, so prediction variance
does not represent misspecification; an alignment-weighted score beat weight diagnostics (AUROC 0.59 to 0.66
against 0.48 to 0.52). **Open, and targeted here:** how a support diagnostic should be aggregated over a
target law known only through published marginals (mean against tail functionals), and how the
reconstruction's error propagates into that diagnostic. MOD-01 owns its propagation into the estimate.

When the unsupported region is a joint set, its target mass depends on a correlation that a table of means
and SDs does not report, and a diagnostic integrated over the maximum-entropy reconstruction (independence)
cannot see it. **Refuting sentence:** a diagnostic integrated over the reconstructed law discriminates failure
as well as the same diagnostic integrated over the true law, so reconstruction is a nuisance, not a limit.

## 2. Design

Source A versus C, 300 per arm, $x \sim N(0, I)$ truncated to $s = x_1 + x_2 \le 2$. Target
$x \sim N((\mu, \mu), \Sigma_\rho)$ with unit SDs; the publication gives $\mu$ and the SDs only.
$\mu \in \{0.3, 0.6\}$, $\rho \in \{-0.7, 0, 0.7\}$: true unsupported mass $P(s > 2)$ runs 0.035 to 0.332,
while independence reports 0.161 or 0.286 whatever $\rho$ is. $y = 0.5s + A\,\tau(x) + e$,
$\tau = -0.5 + 0.3s + H(s - 2)_+$, $H \in \{0, 1\}$ (linear; bent beyond the support). Linear G-computation,
$y \sim A \times (x_1 + x_2)$, standardized over the target: on this scale the estimate depends on the law only
through its means, so reconstruction cannot move it. Estimand: target mean difference, closed form; limit
bias $-H\,E_T(s - 2)_+$, 0 to $-0.404$.

Diagnostics, each integrated over the true law and over the independence reconstruction (2000 common target
draws): **hull**, mass outside the source's convex hull (a tail functional); Mahalanobis distance to the
source, **mean** and **95th percentile**; **extrapolated modification**, the mean amount by which the fitted
modification index leaves its range over the source; mean prediction SD of the fitted $\tau(x)$; and the
contrast's own SE. The modification is aligned with the unsupported direction, OVL-01's favorable case, so
what is lost is attributable to the reconstruction. Failure: the 95% interval excludes the truth (secondary:
$|$error$| > 0.2$). AUROC is pooled across cells: within a cell every covariate diagnostic is at chance by
construction (OVL-01), so the gap is a between-cell quantity driven by $\rho$ and by the target mean. 12 cells,
**1000 replicates**: coverage MCSE at most 0.016 per cell; AUROC over 6000 bent-cell analyses has bootstrap SE
about 0.005 (0.022 in a 50-replicate pilot). Measured cost 0.06 CPU-hours.

## 3. Decision

**Primary** (bent cells pooled, interval failure): hull-mass AUROC over the true law minus over the
independence reconstruction, paired bootstrap SE. **Confirmed** (reconstruction limits the diagnostic) if
at least 0.10; **refuted** if below 0.03; otherwise partial, reported as a near miss. Predicted at cell level
(P3): 0.841 against 0.588, gap 0.254. Its size is set by the declared correlation range, which is a design
choice; the registered claim is that the loss is material at a range of $\pm 0.7$, not its magnitude.

**Aggregation** (registered secondary): over the true law, 95th percentile minus mean Mahalanobis AUROC;
tail better if at least 0.05, mean better if at most $-0.05$, otherwise equivalent. **Comparator that can
win:** the contrast's SE or the mean prediction SD over the reconstruction within 0.02 of the reconstructed
hull AUROC means the model's own variance flags as well as the geometry an analyst can compute.

**Null control:** linear cells, failure 0.03 to 0.07 in each and every AUROC 0.45 to 0.55. **Second null:**
$\rho = 0$ cells, true-law and reconstructed diagnostics identical (P2: difference 0). **Positive control:**
$\mu = 0.6$, $\rho = 0.7$, bent: $|$bias$| \ge 0.3$ (exact 0.404), failure at least 0.6, hull mass
understated by at least 0.02 (exact 0.046).

## 4. Departures from DESIGN.md

Continuous outcome, so only the truth and the diagnostic see the joint law; the log odds ratio scale, where
the estimate also moves, is MOD-01's. Gaussian dependence only; no tail-dependent copula or skewed margins;
no density-ratio, conformal or anomaly scores; no mapping of flags to abstention or redefinition. The
diagnostic's range over a declared correlation interval is computed exactly (P1) but not scored: it does not
depend on the true correlation, so it cannot restore discrimination across it. Profile-weighting and
modification-strength factors dropped; 1000 rather than 2000 replicates. **Set after probes:** the
correlation range widened from $\pm 0.5$ to $\pm 0.7$ after a 20-replicate pilot put the primary gap at 0.102
(SE 0.029) against a cell-level 0.134, too close to the threshold to decide; a 50-replicate pilot at $\pm 0.7$
gave 0.196 (SE 0.022). A diagnostic envelope over correlations was dropped from the replicates after P1 showed
it cannot vary with the true correlation.
