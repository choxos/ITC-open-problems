**Study `studies/DIA-03-diagnostics-as-classifiers`, run and decided against a rule registered
before the run.** 128 cells, 4000 replicates each, four estimators, ten diagnostic rules.

**Conclusion: the panel does not classify realized error at the thresholds in use.** Material
error, meaning the transported effect wrong by more than 0.20, occurs on **0.479** of fitted
MAIC replicates under the deployment weights, so the target is close to a coin flip and a
useful diagnostic has room to be informative.

Operating points are reported *within* misspecification strata, so no assumed mixture of
misspecification frequencies enters the headline. In the well-specified stratum the rules
divide into two useless families: high specificity with little sensitivity (`ess` 0.326/0.923,
`max_w` 0.350/0.919, `bias_hat` 0.099/0.962), or high sensitivity bought with false alarms
(`smd_pre` 0.822/0.408, `ess_pct` 0.742/0.623). The matched standardized difference,
`smd_matched`, fires on **no replicate at all** (sensitivity 0.000, specificity 1.000): after
matching it is zero by construction and carries no information about error. The pattern is
essentially unchanged when a modifier is omitted.
