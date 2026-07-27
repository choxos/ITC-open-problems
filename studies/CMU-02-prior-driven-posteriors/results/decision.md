# Decision

**Conclusion: diagnostics fail at the thresholds the literature suggests**

Prespecified in `protocol.md` section 7. 120 scenarios, 2000 replicates each, two contrasts. Operating characteristics are computed per replicate, pairing each warning with whether that replicate's interval missed.

Intervals missed on 56,210 of 480,000 replicate-contrasts. Harmful scenarios: **34 of 240**, of which 18 lie outside the engineered positive controls.

## Operating characteristics, per replicate

| rule | sensitivity | false-alarm rate |
| --- | ---: | ---: |
| Contraction | 0.363 (0.002) | 0.141 (0.001) |
| Prior-only benchmark | 0.209 (0.002) | 0.128 (0.001) |
| Power-scaling | 0.209 (0.002) | 0.130 (0.001) |
| Tight and loose refit | 0.698 (0.002) | 0.526 (0.001) |
| Composite (2 of 4) | 0.366 (0.002) | 0.158 (0.001) |

## Excluding the engineered positive controls

| rule | sensitivity | false-alarm rate |
| --- | ---: | ---: |
| Contraction | 0.122 | 0.016 |
| Prior-only benchmark | 0.017 | 0.024 |
| Power-scaling | 0.007 | 0.003 |
| Tight and loose refit | 0.830 | 0.531 |
| Composite (2 of 4) | 0.127 | 0.025 |

## Threshold-free discrimination

The statistics carry ranking information that the thresholds do not exploit.

| statistic | AUC, all | AUC, controls excluded |
| --- | ---: | ---: |
| contraction | 0.711 | 0.749 |
| prior_sens | 0.766 | 0.781 |
| lik_sens | 0.505 | 0.627 |
| h2 | 0.578 | 0.511 |
| refit_sd | 0.653 | 0.762 |

## Prespecified measures previously unreported

- Structural rank screen fires on 0.150 of replicates overall, 0.175 among misses and 0.147 among covered. It fires only where a contrast is genuinely outside the row space, and never false-alarms.
- Confident decisions on the wrong side of zero: 0.016 of replicates overall, 0.085 among misses.
- Composite recomputed WITHOUT the amended power-scaling component: sensitivity 0.365, false alarm 0.146, against 0.366 and 0.158 with it. The post-run amendment did not drive the verdict.
- Where the zero-centred prior happens to be correct the composite fires on 0.190 of covered replicates, against 0.119 where it is wrong.

## Where coverage fails

| geometry | prior | gamma_C | mu | n | contrast | coverage | composite | rank screen |
| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: |
| disconnected | tight | 0.40 | 0.00 | 100 | gamma_C | 0.000 | 0.983 | 0.000 |
| disconnected | tight | 0.40 | 0.00 | 400 | gamma_C | 0.000 | 0.009 | 0.000 |
| disconnected | tight | 0.40 | 0.75 | 100 | gamma_C | 0.000 | 0.984 | 0.000 |
| disconnected | tight | 0.40 | 0.75 | 400 | gamma_C | 0.000 | 0.012 | 0.000 |
| agd-flat | tight | 0.40 | 0.00 | 100 | gamma_C | 0.000 | 1.000 | 1.000 |
| agd-narrow | tight | 0.40 | 0.00 | 100 | gamma_C | 0.000 | 1.000 | 0.000 |
| agd-flat | tight | 0.40 | 0.00 | 400 | gamma_C | 0.000 | 1.000 | 1.000 |
| agd-narrow | tight | 0.40 | 0.00 | 400 | gamma_C | 0.000 | 1.000 | 0.000 |
| agd-flat | tight | 0.40 | 0.75 | 100 | gamma_C | 0.000 | 1.000 | 1.000 |
| agd-narrow | tight | 0.40 | 0.75 | 100 | gamma_C | 0.000 | 1.000 | 0.000 |

