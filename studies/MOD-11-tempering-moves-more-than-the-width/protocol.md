# Protocol: a mixture over study populations in a transported contrast, and what tempering moves

**Target problem.** MOD-11. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A Dirichlet-process (DP) mixture over study populations can transport a contrast to a new target population
better than a normal random-effects model when populations cluster; and tempering the likelihood by a learning
rate $\eta < 1$ moves posterior location and shrinkage, not only width. **Refuting sentence:** at the study counts
an ITC supplies, the mixture's clustering is determined by its concentration parameter, so its output restates
its prior. The tempering claim's falsifier: location moves by an amount negligible against the interval.

## 2. Design

$J \in \{6, 12\}$ studies report a log odds ratio $y_j \sim N(\delta_j, s_j^2)$, $s_j \sim U(0.1, 0.3)$, with covariate
mean $\bar x_j \sim U(0, 1)$ and $\delta_j = -0.3 + 0.4\bar x_j + \phi_j$, $\phi_j$ = a cluster center plus $N(0, 0.05^2)$;
centers $\{0\}$ (one cluster) or $\{-D, 0, D\}$ equally likely, $D = 0.3$ (small) or $0.9$ (large). IPD from one study
or from half of them adds a within-study interaction $b_j \sim N(0.4, (2s_j)^2)$. Target covariate 1.5, outside
every study. **Estimand:** the target population's own contrast $\theta_T = 0.3 + \phi_T$, $\phi_T$ drawn from the same
law, scored by 95% predictive coverage, width and log predictive density; the mean target contrast 0.3 is
reported with bias and coverage.

Methods, all with $\delta_j = \beta\bar x_j + \phi_j$, $\beta \sim N(0, 1)$, and the IPD interactions: random effects
$\phi_j \sim N(\mu, \tau^2)$, $\mu \sim N(0,1)$, $\tau \sim HN(0.5)$, exact on a 401-point $\tau$ grid; heavy-tailed
$\phi_j \sim \mu + \tau t_4$ (Gibbs); DP mixture of normals, $\phi_j \sim N(\psi_{c_j}, \omega^2)$, $\psi \sim G$,
$G \sim DP(a, N(\mu, s_0^2))$, $s_0 \sim HN(0.5)$, $\omega \sim HN(0.25)$ (collapsed Gibbs, 3000 iterations, 1000 burn-in),
at $a \in \{0.3, 1, 3\}$. Random effects and the DP at $a = 1$ are refitted tempered at $\eta = 0.5$, exactly
$s_j^2 \to s_j^2/\eta$ and $v_j \to v_j/\eta$ with priors untouched. 12 cells (3 heterogeneity x 2 study counts x 2
IPD shares), **400 replicates**: coverage MCSE at most 0.011; a log-score gain of 0.05 is 3 MCSE if the per-replicate
SD of the gain is 0.3. Measured cost 15.2 CPU hours (probes, user time under load average 869, an upper bound).

## 3. Decision

**Prior-dependence ratio** $R$: mean pairwise co-clustering probability at $a = 0.3$ minus that at $a = 3$, over the
same difference under the prior ($1/1.3 - 1/4$); 1 means the partition moves one-for-one with the prior, 0 that
the data fix it. **Primary cell:** three clusters, small separation, 6 studies, one IPD study. **Established** if
the DP ($a = 1$) log-score gain over random effects is at least 0.05 and above 2 MCSE, its predictive coverage is
0.93 to 0.97, and $R \le 0.5$; **refuting sentence holds** if the gain is not established and $R \ge 0.5$;
otherwise mixed. A near miss is reported as one. **Comparator that can win:** the heavy-tailed model; if its log
score is within 0.05 of the DP's with coverage 0.93 to 0.97, the recommendation is the heavy-tailed model.
**Null control:** one cluster, 12 studies, half IPD: DP and random effects within 0.05 in log score, both
coverages 0.93 to 0.97. **Positive control:** three well-separated clusters, 12 studies, half IPD: $R \le 0.5$ and
gain at least 0.05; if it fails, the extension has no regime in this design. **Second null control** (probe P3,
passed): in a flat Gaussian model tempering at 0.5 moved the mean by $1.1 \times 10^{-8}$ SD and doubled the variance.
**Tempering (registered secondary):** random effects, 6 studies, half IPD, each heterogeneity level: median
standardized shift of the mean target contrast between $\eta = 1$ and 0.5 at least 0.1 SD in all three means
location moves materially; below 0.1 in all three means technically right, practically immaterial. Reported with
the width ratio against $\sqrt 2$, the $\tau$ ratio, the IPD share of $\beta$'s posterior precision and the change in
occupied clusters.

## 4. Departures from DESIGN.md

Two-stage Gaussian study summaries replace ML-NMR with aggregate-data integration, so consequence 3 appears only
as the IPD share of the interaction's precision and no integral is tempered. Normal base measure, not the
regularized horseshoe of Disher et al. Prior dependence is the co-clustering ratio, not CMP-14's prior-free
precision; the ratio on the expected number of clusters is reported but not used, because a DP posterior on the
number of components is inconsistent (Miller and Harrison) and splits true clusters at large $a$. That choice
followed the first probe, where the ratio on clusters was 0.82 to 0.97 in every smoke cell, well-separated
clusters included. The positive-control threshold $R \le 0.5$ was fixed before the co-clustering probe, whose single
replicate in that cell gave 0.49; the control can fail, and a failure is reported as the extension having no regime
here, not repaired by widening the separation. Two cluster
counts (1, 3), one target overlap (poor), $\eta \in \{1, 0.5\}$, tempered fits at $a = 1$ only. 400 replicates, not 1000.
No Stan: no DP package is installed and a stick-breaking Stan model mixes poorly over labels; Gibbs chains run a
fixed length without per-fit diagnostics.
