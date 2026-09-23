# Decision

**Registered primary (connectivity-changing miscoding): REFUTED for inference.** Deterministic coverage given estimability 0.952, 0.951, 0.952; probabilistic coding 0.957, 0.965, 1.000.

Null control (no miscoding: deterministic coverage 0.93 to 0.97): TRUE (0.951).

Second null control (connectivity-preserving miscoding leaves inference approximately nominal, 0.93 or more): FALSE (0.944, 0.923, 0.885).

Positive control (connectivity-changing at p = 0.3: target non-estimable in a substantial fraction, at least 5%): TRUE (0.095).

| type | p | non-estimable | deterministic coverage | given a miscoding | bias given a miscoding | sensitivity coverage | sensitivity bounded | probabilistic coverage | probabilistic bounded |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| changing | 0.00 | 0.000 | 0.951 |  |  | 1.000 | 0.000 | 0.952 | 1.000 |
| changing | 0.05 | 0.004 | 0.952 | 0.945 | -0.021 | 1.000 | 0.000 | 0.957 | 1.000 |
| preserving | 0.05 | 0.000 | 0.944 | 0.868 | -0.095 | 0.980 | 1.000 | 0.967 | 1.000 |
| changing | 0.15 | 0.023 | 0.951 | 0.944 | 0.001 | 1.000 | 0.000 | 0.965 | 1.000 |
| preserving | 0.15 | 0.000 | 0.923 | 0.840 | -0.103 | 0.979 | 1.000 | 0.969 | 1.000 |
| changing | 0.30 | 0.095 | 0.952 | 0.943 | 0.004 | 1.000 | 0.000 | 1.000 | 0.000 |
| preserving | 0.30 | 0.000 | 0.885 | 0.826 | -0.105 | 0.983 | 1.000 | 0.967 | 1.000 |

