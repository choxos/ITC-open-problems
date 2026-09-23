# Decision

**Registered primary: RECONSTRUCTION SENSITIVITY MATERIAL.** Mean range of the estimate across the five reconstructions, Clayton target: 0.050, 0.049 (threshold 0.05).

| target copula | source correlation | mean range (all) | correlation choices only | margin family only |
|---|---:|---:|---:|---:|
| gaussian | 0.5 | 0.052 | 0.023 | 0.029 |
| clayton | 0.5 | 0.050 | 0.023 | 0.028 |
| gaussian | 0.1 | 0.049 | 0.022 | 0.020 |
| clayton | 0.1 | 0.049 | 0.022 | 0.021 |

| target copula | source correlation | reconstruction | truth | bias | MCSE | empirical SD | RMSE |
|---|---:|---|---:|---:|---:|---:|---:|
| gaussian | 0.5 | default | -0.167 | -0.035 | 0.013 | 0.259 | 0.261 |
| gaussian | 0.5 | gamma | -0.167 | -0.006 | 0.013 | 0.258 | 0.258 |
| gaussian | 0.5 | gamma_target | -0.167 | -0.006 | 0.013 | 0.258 | 0.257 |
| gaussian | 0.5 | rho_target | -0.167 | -0.035 | 0.013 | 0.259 | 0.261 |
| gaussian | 0.5 | rho_zero | -0.167 | -0.056 | 0.013 | 0.265 | 0.270 |
| clayton | 0.5 | default | -0.165 | -0.018 | 0.012 | 0.244 | 0.244 |
| clayton | 0.5 | gamma | -0.165 | 0.009 | 0.012 | 0.243 | 0.243 |
| clayton | 0.5 | gamma_target | -0.165 | 0.009 | 0.012 | 0.243 | 0.243 |
| clayton | 0.5 | rho_target | -0.165 | -0.018 | 0.012 | 0.244 | 0.245 |
| clayton | 0.5 | rho_zero | -0.165 | -0.038 | 0.012 | 0.250 | 0.252 |
| gaussian | 0.1 | default | -0.167 | -0.055 | 0.012 | 0.242 | 0.248 |
| gaussian | 0.1 | gamma | -0.167 | -0.035 | 0.012 | 0.240 | 0.242 |
| gaussian | 0.1 | gamma_target | -0.167 | -0.011 | 0.012 | 0.237 | 0.237 |
| gaussian | 0.1 | rho_target | -0.167 | -0.038 | 0.012 | 0.239 | 0.241 |
| gaussian | 0.1 | rho_zero | -0.167 | -0.059 | 0.012 | 0.243 | 0.250 |
| clayton | 0.1 | default | -0.165 | -0.038 | 0.012 | 0.240 | 0.243 |
| clayton | 0.1 | gamma | -0.165 | -0.018 | 0.012 | 0.240 | 0.240 |
| clayton | 0.1 | gamma_target | -0.165 | 0.005 | 0.012 | 0.236 | 0.236 |
| clayton | 0.1 | rho_target | -0.165 | -0.022 | 0.012 | 0.236 | 0.237 |
| clayton | 0.1 | rho_zero | -0.165 | -0.043 | 0.012 | 0.241 | 0.245 |

