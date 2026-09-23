# Protocol: matched single-arm studies built against one comparator arm

**Target problem.** HET-02. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

When $m$ single-arm studies are each matched to the same comparator arm C, their pseudo-contrasts
$d_k = \hat\mu_k - \hat\mu_C$ share $\operatorname{Var}(\hat\mu_C)$ pairwise, and entering them as independent
counts the C arm $m$ times. **Refuting sentence:** the induced correlation is small relative to the
variance a network model already carries, so ignoring it changes precision slightly and conclusions
not at all.

## 2. Design

Network A, B, C; continuous outcome, SD 1. Trial 1: B versus C with $n_C$ per arm. Trial 2: A versus
B, 200 per arm. $M$ single-arm studies of A (100 patients each), each matched to trial 1's C arm.
True A versus C 0.15, B versus C 0.3. Fixed-effect network by generalized least squares on the basic
parameters, with the correct covariance (the pseudo-contrasts share trial 1's C-arm mean with each
other and with trial 1's contrast) or with the pseudo-contrasts entered as independent. Estimand: A
versus C. $M \in \{1, 2, 4, 8\}$, $n_C \in \{50, 200\}$: 8 cells, **4000 replicates**.

## 3. Decision

**Refuting sentence fails** if naive coverage is below 0.90 with two or more pseudo-contrasts in some
cell. Reported also: the ratio of naive SE to the estimate's spread, and how often the naive and
correct point estimates differ in sign.

## 4. Departures from DESIGN.md

Continuous outcome and fixed-effect network; no weighting step, so only the shared-arm part of the
covariance (the shared-weight part is CMP-12's); no reconstruction of the Pompe network.
