# Decision

**Registered rule: REFUTED (orderings survive every departure).**

| target mean | ordering under linear against | Spearman rho | bootstrap SE | P(rho < 0.9) |
|---:|---|---:|---:|---:|
| 0.3 | threshold normal | 1.00 | 0.04 | 0.00 |
| 0.3 | interaction normal | 1.00 | 0.05 | 0.00 |
| 0.3 | quadratic normal | 1.00 | 0.05 | 0.00 |
| 0.3 | linear skewed | 0.90 | 0.20 | 0.62 |
| 0.8 | threshold normal | 1.00 | 0.00 | 0.00 |
| 0.8 | interaction normal | 1.00 | 0.00 | 0.00 |
| 0.8 | quadratic normal | 1.00 | 0.00 | 0.00 |
| 0.8 | linear skewed | 1.00 | 0.03 | 0.00 |
| 1.2 | threshold normal | 0.90 | 0.05 | 0.00 |
| 1.2 | interaction normal | 1.00 | 0.00 | 0.00 |
| 1.2 | quadratic normal | 1.00 | 0.00 | 0.00 |
| 1.2 | linear skewed | 1.00 | 0.01 | 0.00 |

| departure | target mean | law | RMSE order, best first |
|---|---:|---|---|
| linear | 0.3 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| threshold | 0.3 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| interaction | 0.3 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| quadratic | 0.3 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| linear | 0.8 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| threshold | 0.8 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| interaction | 0.8 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| quadratic | 0.8 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| linear | 1.2 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| threshold | 1.2 | normal | stc_linear < stc_flexible < maic_means < unadjusted < maic_means_sds |
| interaction | 1.2 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| quadratic | 1.2 | normal | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| linear | 0.3 | skewed | stc_linear < maic_means < stc_flexible < maic_means_sds < unadjusted |
| linear | 0.8 | skewed | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| linear | 1.2 | skewed | stc_linear < stc_flexible < maic_means < maic_means_sds < unadjusted |
| none | 0.8 | normal | unadjusted < stc_linear < stc_flexible < maic_means < maic_means_sds |

