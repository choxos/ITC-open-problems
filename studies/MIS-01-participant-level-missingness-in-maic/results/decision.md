# Decision

**Mechanism, not rate, decides complete-case bias: CONFIRMED.** Cells predicted unbiased: 24, all within 3 MCSE: TRUE. Cells predicted biased at 15% missingness: 4, all beyond 3 MCSE: TRUE.

Bias (coverage) by mechanism at 30% missingness:

| mechanism | u modifies | complete case | IPW | MI congenial | MI generic |
|---|---:|---:|---:|---:|---:|
| MCAR | 0.0 | -0.011 (0.941) | -0.004 (0.965) | -0.005 (0.950) | -0.015 (0.953) |
| MCAR | 0.3 | -0.000 (0.944) | -0.004 (0.955) | -0.005 (0.952) | -0.001 (0.954) |
| MAR_x2 | 0.0 | -0.009 (0.933) | -0.010 (0.963) | 0.003 (0.970) | -0.021 (0.964) |
| MAR_x2 | 0.3 | 0.001 (0.941) | 0.010 (0.957) | -0.001 (0.948) | -0.005 (0.956) |
| MAR_u | 0.0 | 0.012 (0.943) | 0.005 (0.960) | 0.001 (0.951) | -0.025 (0.963) |
| MAR_u | 0.3 | -0.105 (0.915) | -0.018 (0.971) | -0.005 (0.951) | -0.006 (0.961) |
| MAR_u_armA | 0.0 | -0.652 (0.272) | -0.146 (0.837) | -0.014 (0.943) | -0.035 (0.947) |
| MAR_u_armA | 0.3 | -0.847 (0.149) | -0.179 (0.799) | -0.020 (0.953) | -0.024 (0.955) |
| MAR_y | 0.0 | -0.006 (0.945) | -0.006 (0.968) | 0.007 (0.959) | -0.036 (0.962) |
| MAR_y | 0.3 | -0.131 (0.893) | -0.029 (0.952) | 0.006 (0.960) | -0.009 (0.958) |
| MNAR_x1 | 0.0 | -0.006 (0.937) | 0.079 (0.949) | 0.095 (0.953) | 0.033 (0.973) |
| MNAR_x1 | 0.3 | -0.007 (0.928) | 0.120 (0.947) | 0.130 (0.941) | 0.103 (0.961) |

Under MAR mechanisms, IPW and MI bias within 3 MCSE in 69 of 90 method-cells.
Under MNAR on the missing covariate: complete case max |bias| 0.035; IPW and MI max |bias| 0.221.

