# Decision

**Conclusion: diagnostics fail**

Prespecified in `protocol.md` section 7. 120 scenarios, 2000 replicates each, two contrasts.

Harmful scenarios (coverage below 0.90): **34 of 240**, of which 18 are outside the engineered positive controls.

## Operating characteristics, all scenarios

| rule | sensitivity | false-warning rate |
| --- | ---: | ---: |
| Contraction | 0.324 (0.080) | 0.149 (0.026) |
| Prior-only benchmark | 0.118 (0.055) | 0.117 (0.023) |
| Power-scaling | 0.176 (0.065) | 0.144 (0.026) |
| Tight and loose refit | 0.882 (0.055) | 0.548 (0.036) |
| Composite (2 of 4) | 0.324 (0.080) | 0.170 (0.027) |

## Excluding the engineered positive controls

| rule | harmful n | sensitivity | clean n | false-warning rate |
| --- | ---: | ---: | ---: | ---: |
| Contraction | 18 | 0.111 | 112 | 0.018 |
| Prior-only benchmark | 18 | 0.000 | 112 | 0.000 |
| Power-scaling | 18 | 0.000 | 112 | 0.000 |
| Tight and loose refit | 18 | 1.000 | 112 | 0.509 |
| Composite (2 of 4) | 18 | 0.111 | 112 | 0.018 |

## Where coverage fails

| geometry | prior | gamma_C | mu | n | coverage | composite fires | contraction |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| disconnected | tight | 0.40 | 0.00 | 100 | 0.000 | 0.983 | 0.198 |
| disconnected | tight | 0.40 | 0.00 | 400 | 0.000 | 0.009 | 0.267 |
| disconnected | tight | 0.40 | 0.75 | 100 | 0.000 | 0.984 | 0.198 |
| disconnected | tight | 0.40 | 0.75 | 400 | 0.000 | 0.012 | 0.267 |
| agd-flat | tight | 0.40 | 0.00 | 100 | 0.000 | 1.000 | 0.000 |
| agd-narrow | tight | 0.40 | 0.00 | 100 | 0.000 | 1.000 | 0.025 |
| agd-flat | tight | 0.40 | 0.00 | 400 | 0.000 | 1.000 | 0.000 |
| agd-narrow | tight | 0.40 | 0.00 | 400 | 0.000 | 1.000 | 0.049 |
| agd-flat | tight | 0.40 | 0.75 | 100 | 0.000 | 1.000 | 0.000 |
| agd-narrow | tight | 0.40 | 0.75 | 100 | 0.000 | 1.000 | 0.025 |
| agd-flat | tight | 0.40 | 0.75 | 400 | 0.000 | 1.000 | 0.000 |
| agd-narrow | tight | 0.40 | 0.75 | 400 | 0.000 | 1.000 | 0.049 |

## The accidentally-correct prior

Where the truth agrees with the zero-centered prior (gamma_C = 0), coverage is 0.908 to 1.000 and the composite fires in 0.183 of scenarios. A prior-driven analysis is right there for the wrong reason, and a diagnostic that stays silent has not earned credit.

