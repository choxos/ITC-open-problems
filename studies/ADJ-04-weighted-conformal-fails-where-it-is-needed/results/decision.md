# Decision

**Refuting sentence (weighted conformal restores a valid coverage statement, so the support problem is solved): FAILS.** Weighted conformal coverage overall 0.904 to 0.919; in the target region beyond the source's range 0.704 to 0.991, with 0.0% to 83.3% of intervals there infinite.

| target mean | method | coverage | coverage beyond the source's range | infinite intervals | infinite beyond range | median width | calibration ESS | n / (1 + chi-square) |
|---:|---|---:|---:|---:|---:|---:|---:|---:|
| 0.5 | unweighted | 0.899 | 0.684 | 0.000 | 0.000 | 3.34 | 234.7 | 233.6 |
| 1.0 | unweighted | 0.893 | 0.656 | 0.000 | 0.000 | 3.34 | 118.6 | 110.4 |
| 1.5 | unweighted | 0.878 | 0.627 | 0.000 | 0.000 | 3.33 | 50.7 | 31.6 |
| 0.5 | weighted | 0.904 | 0.704 | 0.000 | 0.000 | 3.38 | 234.7 | 233.6 |
| 1.0 | weighted | 0.905 | 0.830 | 0.001 | 0.113 | 3.44 | 118.6 | 110.4 |
| 1.5 | weighted | 0.919 | 0.991 | 0.059 | 0.833 | 3.58 | 50.7 | 31.6 |
| 0.5 | weighted_est | 0.904 | 0.705 | 0.000 | 0.000 | 3.38 | 234.7 | 233.6 |
| 1.0 | weighted_est | 0.905 | 0.834 | 0.002 | 0.140 | 3.44 | 118.6 | 110.4 |
| 1.5 | weighted_est | 0.918 | 0.988 | 0.061 | 0.823 | 3.58 | 50.7 | 31.6 |

