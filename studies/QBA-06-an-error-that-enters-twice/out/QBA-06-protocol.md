# Protocol: a misclassified covariate that is both balanced and a modifier

**Target problem.** QBA-06. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

A misclassified binary covariate enters population adjustment through the balancing step
and through the outcome model. **Refuting sentence:** correcting the outcome model is
sufficient, because the weights' error is second order.

**Correction.** DESIGN.md says that with the same sensitivity and specificity in both studies,
balance on the recorded covariate implies balance on the true one. It does not: reweighting the
recorded categories leaves the true mix within each category at the source's proportions, so
the weighted source's true prevalence is $\sum_{x^\star} s(x^\star)P_S(X = 1 \mid x^\star)$, not the
target's. The probe shows MAIC on the recorded covariate biased with identical assays. A correct
MAIC chooses the category weights so that this implied true prevalence equals the target's
corrected prevalence; that arm is added.

## 2. Design

Source trial A versus C, 400 per arm; true binary $X$ with prevalence 0.3 (source) and 0.5
(target); $\operatorname{logit}P(Y = 1) = -1 + 0.5X + A(-0.5 + bX)$, $b \in \{0.5, 1\}$. The target reports
the prevalence of the recorded $X^\star$ from 800 patients. Assays (sensitivity, specificity)
source then target: same and good (0.9, 0.95 both); same and poor (0.75, 0.85 both); source
worse (0.75, 0.85 against 0.95, 0.98); target worse (the reverse). 8 cells, **1000 replicates**.
Estimand: marginal log odds ratio, A versus C, in the target's true covariate law.

Methods (known assay parameters where corrected): MAIC balancing $X^\star$ to the reported
prevalence; MAIC balancing $X^\star$ to the prevalence the source's assay would show at the
target's corrected true prevalence; MAIC with latent-prevalence weights; STC on $X^\star$;
latent-class STC averaged over the reported $X^\star$ prevalence (outcome model corrected only);
latent-class STC averaged over the corrected true prevalence.

## 3. Decision

- **Refuting sentence fails** if the outcome-only correction is biased beyond 3 MCSE and 0.03 in
  some cell.
- MAIC on $X^\star$ with identical assays: bias beyond 3 MCSE confirms the correction in section 1.
- Bias of the two full corrections.

## 4. Departures from DESIGN.md

Known assay parameters (no validation substudy or priors-only arm); binary covariate only;
anchored transport of the A-versus-C contrast; no interval assessment.
