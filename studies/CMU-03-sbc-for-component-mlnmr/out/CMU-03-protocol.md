# Protocol: two simulation-based calibrations of ML-NMR, and the gap between them

**Target problem.** CMU-03. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

An SBC replicate for an ML-NMR aggregate arm can be drawn from the coded integrated likelihood, which the fit
conditions on exactly and which is therefore blind to integration and reconstruction error, or end to end, from
simulated individuals re-aggregated and re-integrated. The choice is unstated and consequential; and parameter
ranks alone cannot detect a posterior equal to the prior, so a data-dependent test quantity is required.
**Refuting sentence:** the two constructions agree within Monte Carlo error at production integration settings, so
the choice is immaterial and SBC is the routine code check it is treated as.

## 2. Design

One IPD study (P vs A) and four aggregate studies (P vs B), 200 per arm; covariates $x_1, x_2$ independent, SD 1;
aggregate study means $(-0.6, -0.2, 0.2, 0.6)$ (strong identification of the B interactions) or all 0.3 (weak).
Binomial logit ML-NMR in multinma 0.9.1: fixed effects, full interactions, `center = FALSE`, `QR = FALSE`; priors
$\mu_j \sim N(0, 1)$, $d \sim N(0, 1)$, six regression terms $\sim N(0, 0.5^2)$, and $\theta$ is drawn from exactly these.
**Coded construction:** aggregate $r \sim \mathrm{Bin}(n, \bar p)$, $\bar p$ the mean of $\mathrm{logit}^{-1}\eta$ over multinma's own stored
integration points. **End-to-end:** individuals drawn from the true covariate law (normal, or standardized
exponential with skewness 2), outcomes drawn, then summarized to $(r, n$, means, SDs$)$ and integrated at $Q$.
**Posterior:** importance sampling on multinma's own log density (`rstan::log_prob` on a `Fixed_param` stanfit),
multivariate $t_5$ proposal at the Laplace fit, 4000 draws, Pareto-smoothed weights, rerun at 16,000 draws and
$t_3$ if $\hat k > 0.7$; one cell repeats the null with multinma's NUTS (2 x 1000, thinned to 100). **Test quantities:**
PIT of the 13 parameters, of the decision contrast (B vs A at target covariates 0.5) and of the joint coded
log-likelihood of the replicate's data. **Broken implementations:** the prior returned as the posterior; the
aggregate covariate means passed with the wrong sign. Cells: coded null x {strong, weak}; end-to-end x $Q$
{16, 64, 512} x margin {normal, skewed} x {strong, weak}; the two breaks; the NUTS null: 17 cells, **1000
replicates** per importance-sampling cell and 200 for NUTS. At 1000, with $z = \Phi^{-1}(\mathrm{PIT})$ and the test below, a
location shift of 0.14 posterior SD and an SD ratio of 1.1 are each detected with power 0.90 or more. **Cost**
(probes, user time under load average 143, an upper bound): 1.6 CPU s per importance-sampling replicate, 9.1 s per
NUTS replicate, 7.8 CPU hours in all. **Probes:** multinma's log density minus the R simulator's coded log-likelihood
was constant to SD $3.8 \times 10^{-13}$ over 20 prior draws; the coded null passed at 100 replicates (smallest p 0.16;
the first 20 alone had given 0.0002 for $d_A$); one of 100 replicates kept Pareto $\hat k = 1.17$ after the rerun,
and such replicates are kept and counted, never dropped.

## 3. Decision

A cell **departs** if the contrast or the joint log-likelihood has $p < 0.005$ on the Bonferroni combination of
three tests on $z$: mean zero, variance one (chi-square) and uniform PIT (Kolmogorov-Smirnov). **Primary:** end-to-end cells at $Q = 64$, multinma's default.
**Consequential** if any departs while the coded null holds; **immaterial at these settings** if no end-to-end cell at
$Q \ge 64$ departs; otherwise mixed. **Stop** if the coded null fails: no integration conclusion is then drawn.
Mechanism, reported in either branch: departure at $Q$ 16 but not 512 with normal margins is integration error;
departure at every $Q$ with skewed margins only is reconstruction error. **Null control:** coded cells, every
quantity $p \ge 0.001$. **Positive controls:** prior as posterior, the joint log-likelihood departs while no parameter or
contrast does (Modrak's split, a theorem demonstrated rather than cited); sign error, some quantity departs.
**Falsifier:** normal margins at $Q = 512$ depart, so the gap is not integration error. **Comparator that can win:**
parameter ranks alone; wherever they detect what the log-likelihood detects, the added quantity is unnecessary.

## 4. Departures from DESIGN.md

Standard ML-NMR in multinma, not component ML-NMR or a bridge model: cpaic is not installed and mlumr is
unreleased and changing; the aggregate-arm integrated likelihood under test is the same one they use. The
posterior is exact importance sampling on multinma's log density, not NUTS, except in one null cell, so the study
validates the coded model and the construction, not the sampler at scale. Binary outcome only; no survival or
Kaplan-Meier reconstruction case (the largest instance of the mechanism, stated as absent). $Q$ {16, 64, 512}
rather than {32, 128, 512}; P2's power count replaced by the stated detectable shifts.
