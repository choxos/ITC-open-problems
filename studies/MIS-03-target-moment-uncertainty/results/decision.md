# Decision

**Conclusion: uninformative**

Prespecified in `protocol.md` section 8, before the run. 252 scenarios, 5000 replicates each.

## Gates

| gate | pass |
| --- | --- |
| convergence | yes |
| bias_not_at_fault | yes |
| reference_valid | NO |
| negative_controls | NO |

Scenarios at ordinary strength (SD_T(tau) <= 0.45) with status-quo coverage outside 0.93 to 0.97: **3 of 144**.
At strong modification (SD_T(tau) = 0.90): **7 of 108**.

## Restricted to scenarios where the gates hold (amendment, 2026-07-27)

The reference interval or its matched negative control fails in 56 of 252 scenarios, all at poor overlap, where the effective sample size collapses and the Wald sandwich undercovers for every method including those with no effect modification at all. Those scenarios are uninformative about target moments. In the remaining **196**:

**Conclusion on the usable scenarios: material at ordinary effect-modification strength**

- Status-quo coverage: min 0.921, median 0.945, max 0.962
- Outside 0.93 to 0.97 at ordinary strength: 1 of 113
- Outside 0.93 to 0.97 at strong modification: 7 of 83

## Ten largest status-quo coverage errors

| nS | nT | d | SD_T(tau) | kappa | rho_T | coverage | error (pp) | MCSE | joint-score |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 500 | 2000 | 0.8 | 0.90 | 0.0 | 0.30 | 0.877 | -7.3 | 0.47 | 0.880 |
| 500 | 2000 | 0.8 | 0.90 | 1.0 | 0.60 | 0.877 | -7.3 | 0.46 | 0.877 |
| 500 | 500 | 0.8 | 0.90 | 0.0 | 0.60 | 0.879 | -7.1 | 0.46 | 0.890 |
| 500 | 2000 | 0.8 | 0.90 | 0.5 | 0.60 | 0.879 | -7.1 | 0.46 | 0.880 |
| 500 | 2000 | 0.8 | 0.90 | 0.0 | 0.60 | 0.881 | -6.9 | 0.46 | 0.885 |
| 500 | 500 | 0.8 | 0.90 | 0.0 | 0.30 | 0.883 | -6.7 | 0.45 | 0.893 |
| 500 | 2000 | 0.8 | 0.90 | 1.0 | 0.30 | 0.885 | -6.5 | 0.45 | 0.884 |
| 500 | 2000 | 0.8 | 0.45 | 0.0 | 0.60 | 0.885 | -6.5 | 0.45 | 0.886 |
| 500 | 2000 | 0.8 | 0.45 | 0.5 | 0.30 | 0.885 | -6.5 | 0.45 | 0.887 |
| 500 | 2000 | 0.8 | 0.90 | 0.5 | 0.30 | 0.885 | -6.5 | 0.45 | 0.887 |

