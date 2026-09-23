# Protocol: an invariance screen for a bridging assumption, scored as a classifier

**Target problem.** ADJ-09. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A stability check across observed environments can refute a bridge but cannot confirm
it, because the bridge is used in a gap with no data. **Refuting sentence:** instability
where the data are strongly predicts bridge failure where they are not. The design's
sharp prediction (consequence 1): a screen on marginal log odds ratios fires under a
valid bridge wherever populations differ, through non-collapsibility, and screening on
the conditional or standardized scale removes this.

## 2. Design

$K$ trials (environments) with feature $z_k \in [-1, 1]$ and a gap at $z = 2$. Trial $k$:
$x \sim N(0.6 z_k, s_k^2)$ with $s_k \in \{0.5, 1, 1.5\}$ cycling, baseline
$\operatorname{logit}$ risk $\operatorname{logit}(0.3) + N(0, 0.3^2)$, 300 per arm,
$\operatorname{logit} p = a_k + G x + A(-0.6 + \text{drift}(z_k))$. Estimand: conditional
log odds ratio in the gap. Drift: none (valid bridge); linear in $z$, visible in the
trials and extending to the gap; zero across the trials and nonzero only in the gap.

Screen: Cochran's $Q$ across trial estimates, abstain at $p < 0.10$, on three scales:
marginal log OR from arm counts; conditional log OR from a per-trial logistic model;
per-trial marginal log OR standardized by G-computation to $x \sim N(0, 1)$. The
transported estimate is the inverse-variance pooled conditional log OR.

Factors: $K \in \{4, 10\}$, $G \in \{0.5, 1.5\}$, drift $\in$ {none, observed and gap,
gap only}, drift size 0.15 or 0.3 per unit $z$ (20 cells), plus 3 controls at $K = 10$:
identical environments; a linear risk model with a valid bridge (collapsible scale);
large visible drift (0.6). **1000 replicates per cell**; abstention MCSE at most 0.016.

## 3. Decision

- **Primary.** In valid-bridge cells with $G = 1.5$, marginal minus conditional
  abstention. **Confirmed** if at least 0.05 with its 95% Monte Carlo interval above 0 at
  both $K$; **refuted** (the published marginal screen transfers) if at most 0.02 at both.
  The standardized screen is judged as a remedy if within 0.03 of the conditional.
- **Refuting sentence.** Gap-only drift is equal in distribution to a valid bridge
  within the observed trials, so abstention cannot differ; this cell demonstrates the
  logical half and is not an empirical finding. The empirical half is sensitivity to
  visible drift by $K$ and size.
- **Workflow.** Coverage of the transported estimate among analyses that pass the
  conditional screen, against all analyses.
- **Controls.** Identical environments: every screen within 0.08 to 0.12. Risk-difference
  model: the marginal screen within 0.08 to 0.12. Large drift: every screen at least 0.95.

## 4. Departures from DESIGN.md

$K \in \{4, 10\}$ rather than 3, 6, 12; one event-count level; no measurement shift, so
the false-flag decomposition covers sampling error and non-collapsibility only; Cochran's
$Q$ in place of a sign-stability rule and a formal invariance test; 1000 rather than 4000
replicates.
