# Decision

**Primary (consequence 1, marginal screen fires under a valid bridge): CONFIRMED.** Valid bridge, G = 1.5: marginal minus conditional abstention 0.077 (SE 0.016), 0.113 (SE 0.017) (K = 4, 10). Standardized within 0.03 of conditional: TRUE.

| K | G | drift | size | control | abstain cond | abstain marg | abstain std | bias in gap | coverage, all | coverage, passed |
|---:|---:|---|---:|---|---:|---:|---:|---:|---:|---:|
| 4 | 0.5 | none | 0.15 | none | 0.102 | 0.106 | 0.102 | 0.002 | 0.947 | 0.947 |
| 10 | 0.5 | none | 0.15 | none | 0.099 | 0.097 | 0.098 | -0.002 | 0.956 | 0.956 |
| 4 | 1.5 | none | 0.15 | none | 0.113 | 0.190 | 0.112 | 0.004 | 0.937 | 0.939 |
| 10 | 1.5 | none | 0.15 | none | 0.124 | 0.237 | 0.114 | -0.004 | 0.947 | 0.944 |
| 4 | 0.5 | observed_and_gap | 0.15 | none | 0.221 | 0.216 | 0.216 | -0.280 | 0.181 | 0.178 |
| 10 | 0.5 | observed_and_gap | 0.15 | none | 0.238 | 0.225 | 0.230 | -0.286 | 0.008 | 0.007 |
| 4 | 1.5 | observed_and_gap | 0.15 | none | 0.201 | 0.266 | 0.192 | -0.276 | 0.266 | 0.255 |
| 10 | 1.5 | observed_and_gap | 0.15 | none | 0.204 | 0.303 | 0.190 | -0.280 | 0.015 | 0.011 |
| 4 | 0.5 | gap_only | 0.15 | none | 0.106 | 0.103 | 0.107 | -0.306 | 0.112 | 0.110 |
| 10 | 0.5 | gap_only | 0.15 | none | 0.092 | 0.103 | 0.089 | -0.297 | 0.001 | 0.001 |
| 4 | 1.5 | gap_only | 0.15 | none | 0.111 | 0.178 | 0.113 | -0.298 | 0.202 | 0.202 |
| 10 | 1.5 | gap_only | 0.15 | none | 0.082 | 0.192 | 0.079 | -0.303 | 0.004 | 0.004 |
| 4 | 0.5 | observed_and_gap | 0.30 | none | 0.570 | 0.579 | 0.577 | -0.561 | 0.000 | 0.000 |
| 10 | 0.5 | observed_and_gap | 0.30 | none | 0.665 | 0.651 | 0.660 | -0.572 | 0.000 | 0.000 |
| 4 | 1.5 | observed_and_gap | 0.30 | none | 0.502 | 0.507 | 0.503 | -0.532 | 0.003 | 0.000 |
| 10 | 1.5 | observed_and_gap | 0.30 | none | 0.567 | 0.610 | 0.566 | -0.559 | 0.000 | 0.000 |
| 4 | 0.5 | gap_only | 0.30 | none | 0.111 | 0.103 | 0.109 | -0.598 | 0.000 | 0.000 |
| 10 | 0.5 | gap_only | 0.30 | none | 0.110 | 0.110 | 0.109 | -0.599 | 0.000 | 0.000 |
| 4 | 1.5 | gap_only | 0.30 | none | 0.099 | 0.176 | 0.096 | -0.603 | 0.000 | 0.000 |
| 10 | 1.5 | gap_only | 0.30 | none | 0.092 | 0.220 | 0.106 | -0.599 | 0.000 | 0.000 |
| 10 | 1.5 | none | 0.15 | identical | 0.099 | 0.104 | 0.103 | 0.000 | 0.957 | 0.954 |
| 10 | 1.5 | none | 0.15 | rd | 0.117 | 0.117 | 0.117 | -0.001 | 0.950 | 0.955 |
| 10 | 1.5 | observed_and_gap | 0.60 | positive | 0.995 | 0.990 | 0.997 | -1.105 | 0.000 | 0.000 |

Gap-only drift minus valid bridge, conditional abstention: -0.007, 0.011, -0.042, -0.032, 0.004, 0.009, -0.002, -0.014 (the logical half; equal in distribution by construction).

Controls: identical environments, abstention 0.099/0.104/0.103 (nominal 0.10); risk-difference valid bridge, marginal 0.117; positive control, minimum 0.990.

