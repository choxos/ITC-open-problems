Critique this simulation design before it runs. Rank findings fatal/serious/minor. Be quantitative.

GOAL: measure the power and calibration of the published within-network check on shared effect modification (Phillippo 2023, multinma): fit ML-NMR with one interaction shared across a treatment class, refit with treatment-specific interactions one covariate at a time, compare posteriors and DIC.

DGM: binomial outcome, logit link. logit p = mu_j + beta'x + 1{active}(d_k + delta_jk + gamma_k'x). Two covariates correlated 0.25, beta = (0.4, 0.4). Reference PBO plus two active treatments A and C in ONE class, d_A = d_C = 0.7. Drift is the contrast: gamma_A[x1] = 0.3 + drift/2, gamma_C[x1] = 0.3 - drift/2. x2 shared exactly at 0.3. delta_jk ~ N(0, tau_re^2).

NETWORK: ONE individual-level study, always PBO vs A, 250/arm. The rest aggregate (means and SDs only), 200/arm, alternating C then A so C never has fewer studies. J=6 gives 3 studies each; J=12 gives 6 each.

FACTORS: drift {0, 0.3, 0.6, 1.2}; J {6, 12}; covariate-mean spread {0.25, 0.6}; tau_re {0, 0.15}. 32 cells, 50 replicates.

FITS: the complete lattice for two covariates: common, split x1, split x2, split both.

TARGET: not a design factor, because the check reads only the network. One set of fits scored at displacements 0, 0.5, 1.0, 1.5 SDs along x1. The reference intercept is solved separately per displacement to hold marginal placebo risk at exactly 0.30.

ESTIMAND: marginal risk difference C minus A in the target, true baseline supplied. Material error = 0.03 absolute risk.

VERDICT: the check earns its reassurance if the upper 95% bound on P(material error | the check did not fire), pooled with deployment weights at displacement 1.0, is below 0.10. Reported both against realized error and against the cell's systematic error.

CLAIMS: M1 the check's output is identical at every displacement (bookkeeping identity) while P(material | passed) rises by >= 0.20 from displacement 0 to 1.5. M2 prior-posterior contraction for the aggregate-only treatment's interaction is >= 0.20 below the individual-data treatment's. M3 the DIC-5 rule and the 95% posterior rule differ in type I error by >= 0.05 under the global null. M4 the two rules disagree in >= 10% of replicates.

What is wrong with this? What is the most important thing it leaves out?
