# Decision

**Registered primary: NOT CONFIRMED.** Proportional-odds bias when the violation and the utility increments are at the same end: -0.025, -0.047; at opposite ends: 0.026, 0.024.

Null control (proportional odds true: bias within 3 MCSE and coverage 0.93 to 0.97 for the proportional-odds fit): TRUE.

| violation | utility | method | truth | bias | MCSE | RMSE | coverage | SE ratio |
|---|---|---|---:|---:|---:|---:|---:|---:|
| po | bottom_heavy | po | 0.078 | 0.000 | 0.001 | 0.023 | 0.965 | 1.03 |
| po | top_heavy | separate | 0.095 | -0.000 | 0.001 | 0.028 | 0.978 | 1.06 |
| po | top_heavy | po | 0.095 | 0.000 | 0.001 | 0.027 | 0.968 | 1.04 |
| po | bottom_heavy | separate | 0.078 | -0.000 | 0.001 | 0.024 | 0.955 | 1.01 |
| bottom | bottom_heavy | separate | 0.093 | 0.001 | 0.001 | 0.022 | 0.950 | 1.04 |
| bottom | bottom_heavy | po | 0.093 | -0.025 | 0.001 | 0.032 | 0.810 | 1.05 |
| bottom | top_heavy | separate | 0.061 | -0.001 | 0.001 | 0.029 | 0.953 | 1.04 |
| bottom | top_heavy | po | 0.061 | 0.026 | 0.001 | 0.037 | 0.850 | 1.05 |
| top | top_heavy | po | 0.171 | -0.047 | 0.002 | 0.056 | 0.672 | 0.99 |
| top | bottom_heavy | separate | 0.080 | 0.000 | 0.001 | 0.025 | 0.940 | 1.03 |
| top | bottom_heavy | po | 0.080 | 0.024 | 0.001 | 0.035 | 0.828 | 1.00 |
| top | top_heavy | separate | 0.171 | 0.000 | 0.002 | 0.032 | 0.930 | 0.96 |

