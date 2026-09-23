# Protocol: component network meta-analysis under an omitted interaction

**Target problem.** CMP-03. Exact calculation (normal linear model, no sampling). Committed before the
computation. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

Under strict additivity a regimen never administered is estimable whenever its components appear
somewhere, so an estimability screen reports it like a randomized one. **Refuting sentence:** the
interactions additivity omits are small enough at realistic magnitudes that a de novo regimen's
predicted effect is close to its true one.

## 2. Design

Components A, B, C, D against placebo; eight two-arm trials (P-A, P-B, P-C, P-D, A vs A+B, B vs B+C, C vs
A+C, P vs A+B), each contrast with variance 0.01 (200 per arm, outcome SD 1). Pairs co-administered in some
arm: A+B, B+C, A+C; never: A+D, B+D, C+D. Component effects $-0.3, -0.2, -0.25, -0.15$. Synergy (same sign
as the effects) of magnitude 0.1, 0.2 or 0.3 on A+B only, C+D only, both, or half that magnitude on all six
pairs. Models: additive fixed effect, and additive plus interactions for the three co-administered pairs.
For every two-, three- and four-component regimen: bias, SD and 95% coverage, exact. $\rho(r)$: share of the
regimen's component pairs never co-administered.

## 3. Decision

**Confirmed** if, under the additive fit at synergy 0.2, some regimen never administered (and reported
estimable) has coverage below 0.90; **refuted** otherwise. Reported: bias and coverage for administered and
de novo regimens separately, by model; AUROC of $\rho$ for undercoverage among de novo regimens; leakage of
a co-administered pair's interaction into regimens that do not contain it.

## 4. Departures from DESIGN.md

Exact calculation for a continuous outcome, one hand-built connected network (no disconnection, so no
subnetwork drift), no covariate adjustment layer, no heredity-constrained or forward selection, no
omitted-interaction bound, no shrinkage share.
