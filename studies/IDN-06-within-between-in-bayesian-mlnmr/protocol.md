# Protocol: what identifies the interaction of a treatment with no individual data

**Target problem.** IDN-06. Exact normal-normal calculation. Committed before the computation.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A treatment with only aggregate data has its interaction identified by the shared-interaction assumption,
by between-trial gradients (exposed to ecological bias), or by the prior. **Refuting sentence:** the shared
restriction transfers enough individual-data information that the aggregate-only treatment's interaction
is neither prior-driven nor ecologically confounded.

## 2. Design

Treatment $j$: an individual-data trial with within-trial interaction estimate $b_j \sim N(\beta_j, 0.01)$, $\beta_j = 0.3$.
Treatment $k$: $S \in \{1, 2, 4\}$ aggregate trials at covariate means spread 0.3 or 1 around 0.5, each reporting its
effect with variance 0.01, plus an ecological term $E(m_s - \bar m)$, $E \in \{0, 0.1\}$. Truth $\beta_k = \beta_j + D$,
$D \in \{0, 0.15, 0.3\}$. Posteriors for $\beta_k$ (flat priors on intercepts and $\beta_j$): **shared** ($\beta_k = \beta_j$, both
within-trial and gradient information), **separate** (prior $N(0, 0.5^2)$ and the gradient only), **hierarchical**
($\beta_k \sim N(\beta_j, 0.15^2)$). Every posterior mean is linear in normal data, so coverage of the 95% credible
interval is exact.

## 3. Decision

**Confirmed** if shared-model coverage falls below 0.90 at some nonzero discordance (without the ecological
term) while the separate model covers 0.935 to 0.965 wherever it has two or more aggregate trials; otherwise
not confirmed as registered. Reported for every cell and model: bias, posterior SD, coverage and the direct
share of posterior precision (information about $\beta_k$ itself, not borrowed or prior).

## 4. Departures from DESIGN.md

Conjugate normal models on contrast-level data instead of multinma fits; one covariate; fixed prior scales;
no MCMC, so no sampler diagnostics.
