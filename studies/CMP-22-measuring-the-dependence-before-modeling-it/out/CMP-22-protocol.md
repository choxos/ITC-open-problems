# Protocol: which trials supply individual data, and what selection on it does

**Target problem.** CMP-22. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

Individual data carry the within-trial evidence on effect modification. If which trials supply
it depends on their own effect modification, the within-trial evidence is a selected sample.
Selection on observed trial variables is modelable; selection on the latent interaction is not
identifiable from the network, and a leave-IPD-out diagnostic measures dependence without
revealing it. **Refuting sentence:** availability depends on sponsorship and data-sharing policy
rather than effect-relevant characteristics, so it is ignorable given observed trial variables.

## 2. Design

Twelve trials of A versus C, 200 per arm; trial covariate means uniform on $[-1, 1]$;
$y = x + A(-0.5 + \beta_kx) + e$ with $\beta_k = 0.3 + u_k$, $u_k \sim N(0, 0.15^2)$; an observed trial
variable $z_k$ correlated with the covariate mean. IPD available with probability
$\operatorname{logit}^{-1}(a + s_{\text{obs}}z_k + s_{\text{lat}}u_k/0.15)$, $a$ set for the expected IPD share.
Factors: share 0.25, 0.5, 0.75; $s_{\text{obs}} \in \{0, 1.5\}$; $s_{\text{lat}} \in \{0, 1, 2\}$. 18 cells,
**1000 replicates**. Estimands: mean interaction 0.3 and the effect at covariate 1.

Estimators: pooled within-trial interaction from the IPD trials (DerSimonian-Laird); a combined
estimator averaging it with the across-trial meta-regression slope of all trials' effects on their
covariate means. Diagnostic: leave-IPD-out influence, the largest change in the combined target
estimate when one IPD trial is treated as aggregate.

## 3. Decision

- **Refuting sentence fails as a general claim** if selection on the latent interaction biases the
  within-trial estimate beyond 3 MCSE and 0.05 in some cell (it is not a claim about how often
  availability is selected this way, which a simulation cannot say).
- Bias with selection on observed variables only; bias reduction from combining.
- Whether the influence diagnostic tracks the bias (its correlation with absolute bias across cells).

## 4. Departures from DESIGN.md

Pairwise meta-analysis with a continuous outcome rather than component ML-NMR, so estimability
questions do not arise; no selection-model sensitivity analysis; one network size.
