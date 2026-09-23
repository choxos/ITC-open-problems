# Decision

**Primary (DR with both models correct against correctly specified single-model estimators, across gamma): CURVES COINCIDE.** Largest |DR - outcome regression| 0.0015; largest |DR - MAIC with correct weights| in any replicate 2.59e-03.

Second null control (gamma = 0, one model wrong: DR unbiased, the wrong single model biased): TRUE.

Positive control (gamma = 1, imbalance 0.3): smallest |bias| 0.101, smallest |bias|/MCSE 37.1.

Falsifier (interaction of misspecification and omitted-variable bias, both models wrong): largest |interaction| 0.008; within 3 MCSE in 16 of 16 cells.

Imbalance 0.3, target mean of x1 0.5:

| gamma | method | bias | location error | region includes truth |
|---:|---|---:|---:|---:|
| 0 | maic_wrong | 0.195 | 0.195 | 0.888 |
| 0 | maic_right | -0.000 | -0.000 | 0.502 |
| 0 | or_wrong | 0.097 | 0.097 | 0.869 |
| 0 | or_right | -0.001 | -0.001 | 0.499 |
| 0 | dr_both_right | -0.000 | -0.000 | 0.502 |
| 0 | dr_w_wrong | -0.001 | -0.001 | 0.499 |
| 0 | dr_o_wrong | -0.000 | -0.000 | 0.502 |
| 0 | dr_both_wrong | 0.195 | 0.195 | 0.888 |
| 1 | maic_wrong | 0.501 | 0.201 | 0.015 |
| 1 | maic_right | 0.302 | 0.002 | 0.488 |
| 1 | or_wrong | 0.403 | 0.103 | 0.132 |
| 1 | or_right | 0.301 | 0.001 | 0.503 |
| 1 | dr_both_right | 0.302 | 0.002 | 0.488 |
| 1 | dr_w_wrong | 0.301 | 0.001 | 0.507 |
| 1 | dr_o_wrong | 0.302 | 0.002 | 0.488 |
| 1 | dr_both_wrong | 0.501 | 0.201 | 0.015 |

