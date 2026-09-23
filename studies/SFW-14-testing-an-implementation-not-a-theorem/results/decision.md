# Decision

**Refuting sentence (the implementation is correct and its behavior matches the augmented-weighting literature): FAILS.**

1. drMAIC's doubly robust estimate equals its MAIC estimate in every replicate (largest absolute difference 1.6e-15): TRUE.

2. Weights wrong, outcome model right: drMAIC DR bias 0.066 (MCSE 0.007), 0.013 (MCSE 0.008); correctly augmented estimator 0.004 (MCSE 0.007), 0.001 (MCSE 0.008).

3. drMAIC analytic interval: mean SE 0.028 to 0.029 against an empirical SD of 0.166 to 0.215; coverage 0.198 to 0.260.

4. drMAIC percentile bootstrap interval (200 resamples): coverage 0.793 (n = 150), 0.780 (n = 150).

| weights | outcome model | target x1 mean | truth | bias MAIC | bias drMAIC DR | bias correct augmentation | drMAIC SE | empirical SD | drMAIC coverage | augmentation coverage | ESS |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| right | right | 0.5 | 0.350 | 0.014 | 0.014 | 0.013 | 0.029 | 0.175 | 0.248 | 0.958 | 197 |
| wrong | right | 0.5 | 0.350 | 0.066 | 0.066 | 0.004 | 0.029 | 0.174 | 0.237 | 0.945 | 199 |
| right | wrong | 0.5 | 0.350 | 0.003 | 0.003 | 0.003 | 0.029 | 0.171 | 0.240 | 0.960 | 198 |
| wrong | wrong | 0.5 | 0.350 | 0.068 | 0.068 | 0.075 | 0.029 | 0.166 | 0.260 | 0.930 | 199 |
| right | right | 1.0 | 0.334 | 0.010 | 0.010 | 0.005 | 0.028 | 0.215 | 0.198 | 0.933 | 112 |
| wrong | right | 1.0 | 0.334 | 0.013 | 0.013 | 0.001 | 0.028 | 0.185 | 0.218 | 0.962 | 99 |
| right | wrong | 1.0 | 0.334 | 0.016 | 0.016 | 0.015 | 0.028 | 0.200 | 0.252 | 0.945 | 112 |
| wrong | wrong | 1.0 | 0.334 | 0.011 | 0.011 | 0.021 | 0.028 | 0.191 | 0.240 | 0.940 | 101 |

