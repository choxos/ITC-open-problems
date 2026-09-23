# Decision

**Refuting sentence (failure rates are low enough that conditioning on success is immaterial): FAILS.** Where more than 10% of resamples failed, coverage given success 0.288 to 0.645 and unconditional 0.136 to 0.560.

| n | assumed target mean | original fit feasible | resamples failed | ESS | bias | coverage given success | coverage unconditional | width |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 100 | 1.0 | 1.000 | 0.000 | 38.4 | 0.003 | 0.928 | 0.928 | 0.592 |
| 100 | 1.5 | 1.000 | 0.012 | 14.6 | 0.003 | 0.892 | 0.892 | 0.930 |
| 100 | 2.0 | 0.868 | 0.265 | 5.4 | 0.009 | 0.645 | 0.560 | 0.950 |
| 100 | 2.5 | 0.472 | 0.670 | 2.6 | 0.047 | 0.288 | 0.136 | 0.575 |
| 300 | 1.0 | 1.000 | 0.000 | 114.6 | -0.005 | 0.934 | 0.934 | 0.348 |
| 300 | 1.5 | 1.000 | 0.000 | 42.1 | -0.010 | 0.916 | 0.916 | 0.548 |
| 300 | 2.0 | 0.998 | 0.013 | 13.7 | -0.013 | 0.874 | 0.872 | 0.938 |
| 300 | 2.5 | 0.832 | 0.317 | 4.5 | -0.021 | 0.606 | 0.504 | 0.957 |

