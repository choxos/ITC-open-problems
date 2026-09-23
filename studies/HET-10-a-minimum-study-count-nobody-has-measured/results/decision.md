# Decision

**Refuting sentence (population-adjusted intervals are conservative enough at small study counts): FAILS.** Coverage at two to four trials: naive DerSimonian-Laird 0.774 to 0.888, two-step DerSimonian-Laird 0.909 to 0.962, two-step Hartung-Knapp 0.994 to 1.000.

Smallest study count from which coverage stays within 0.93 to 0.97 at every heterogeneity level: naive_dl none; naive_hk none; twostep_dl 4; twostep_hk none.

| K | tau | method | coverage | width | bias |
|---:|---:|---|---:|---:|---:|
| 2 | 0.0 | naive_dl | 0.888 | 0.473 | -0.001 |
| 2 | 0.0 | naive_hk | 0.912 | 1.613 | -0.001 |
| 2 | 0.0 | twostep_hk | 1.000 | 3.571 | -0.001 |
| 2 | 0.0 | twostep_dl | 0.953 | 0.595 | -0.001 |
| 3 | 0.0 | twostep_hk | 1.000 | 1.156 | 0.001 |
| 3 | 0.0 | naive_dl | 0.836 | 0.377 | 0.001 |
| 3 | 0.0 | twostep_dl | 0.962 | 0.550 | 0.001 |
| 3 | 0.0 | naive_hk | 0.835 | 0.498 | 0.001 |
| 4 | 0.0 | twostep_hk | 0.999 | 0.832 | -0.001 |
| 4 | 0.0 | twostep_dl | 0.958 | 0.528 | -0.001 |
| 4 | 0.0 | naive_hk | 0.734 | 0.327 | -0.001 |
| 4 | 0.0 | naive_dl | 0.787 | 0.324 | -0.001 |
| 6 | 0.0 | twostep_dl | 0.961 | 0.505 | -0.004 |
| 6 | 0.0 | naive_hk | 0.610 | 0.224 | -0.004 |
| 6 | 0.0 | twostep_hk | 0.989 | 0.652 | -0.004 |
| 6 | 0.0 | naive_dl | 0.707 | 0.262 | -0.004 |
| 8 | 0.0 | naive_hk | 0.518 | 0.180 | -0.002 |
| 8 | 0.0 | naive_dl | 0.638 | 0.227 | -0.002 |
| 8 | 0.0 | twostep_dl | 0.954 | 0.495 | -0.002 |
| 8 | 0.0 | twostep_hk | 0.980 | 0.591 | -0.002 |
| 12 | 0.0 | twostep_hk | 0.976 | 0.540 | -0.004 |
| 12 | 0.0 | naive_hk | 0.425 | 0.138 | -0.004 |
| 12 | 0.0 | twostep_dl | 0.954 | 0.484 | -0.004 |
| 12 | 0.0 | naive_dl | 0.556 | 0.184 | -0.004 |
| 2 | 0.1 | twostep_hk | 1.000 | 3.872 | 0.002 |
| 2 | 0.1 | twostep_dl | 0.946 | 0.632 | 0.002 |
| 2 | 0.1 | naive_hk | 0.930 | 2.108 | 0.002 |
| 2 | 0.1 | naive_dl | 0.875 | 0.506 | 0.002 |
| 3 | 0.1 | twostep_hk | 1.000 | 1.246 | 0.002 |
| 3 | 0.1 | twostep_dl | 0.950 | 0.583 | 0.002 |
| 3 | 0.1 | naive_hk | 0.868 | 0.660 | 0.002 |
| 3 | 0.1 | naive_dl | 0.821 | 0.405 | 0.002 |
| 4 | 0.1 | naive_hk | 0.805 | 0.435 | 0.002 |
| 4 | 0.1 | naive_dl | 0.774 | 0.345 | 0.002 |
| 4 | 0.1 | twostep_hk | 0.997 | 0.884 | 0.002 |
| 4 | 0.1 | twostep_dl | 0.943 | 0.553 | 0.002 |
| 6 | 0.1 | naive_hk | 0.694 | 0.297 | -0.001 |
| 6 | 0.1 | naive_dl | 0.688 | 0.277 | -0.001 |
| 6 | 0.1 | twostep_hk | 0.987 | 0.683 | -0.001 |
| 6 | 0.1 | twostep_dl | 0.953 | 0.524 | -0.001 |
| 8 | 0.1 | twostep_hk | 0.982 | 0.613 | 0.000 |
| 8 | 0.1 | twostep_dl | 0.951 | 0.510 | 0.000 |
| 8 | 0.1 | naive_hk | 0.614 | 0.242 | 0.000 |
| 8 | 0.1 | naive_dl | 0.622 | 0.237 | 0.000 |
| 12 | 0.1 | twostep_hk | 0.970 | 0.555 | 0.001 |
| 12 | 0.1 | twostep_dl | 0.946 | 0.495 | 0.001 |
| 12 | 0.1 | naive_hk | 0.529 | 0.187 | 0.001 |
| 12 | 0.1 | naive_dl | 0.546 | 0.192 | 0.001 |
| 2 | 0.2 | twostep_hk | 1.000 | 4.745 | 0.002 |
| 2 | 0.2 | naive_hk | 0.940 | 3.295 | 0.002 |
| 2 | 0.2 | twostep_dl | 0.909 | 0.755 | 0.002 |
| 2 | 0.2 | naive_dl | 0.827 | 0.629 | 0.002 |
| 3 | 0.2 | naive_dl | 0.811 | 0.507 | 0.005 |
| 3 | 0.2 | naive_hk | 0.904 | 0.986 | 0.005 |
| 3 | 0.2 | twostep_hk | 1.000 | 1.465 | 0.005 |
| 3 | 0.2 | twostep_dl | 0.921 | 0.675 | 0.005 |
| 4 | 0.2 | twostep_hk | 0.994 | 1.028 | 0.003 |
| 4 | 0.2 | naive_dl | 0.779 | 0.440 | 0.003 |
| 4 | 0.2 | twostep_dl | 0.932 | 0.636 | 0.003 |
| 4 | 0.2 | naive_hk | 0.885 | 0.665 | 0.003 |
| 6 | 0.2 | twostep_hk | 0.988 | 0.771 | -0.002 |
| 6 | 0.2 | twostep_dl | 0.937 | 0.589 | -0.002 |
| 6 | 0.2 | naive_hk | 0.825 | 0.458 | -0.002 |
| 6 | 0.2 | naive_dl | 0.752 | 0.362 | -0.002 |
| 8 | 0.2 | twostep_dl | 0.946 | 0.561 | 0.006 |
| 8 | 0.2 | naive_hk | 0.774 | 0.370 | 0.006 |
| 8 | 0.2 | twostep_hk | 0.979 | 0.677 | 0.006 |
| 8 | 0.2 | naive_dl | 0.708 | 0.313 | 0.006 |
| 12 | 0.2 | naive_hk | 0.691 | 0.285 | -0.003 |
| 12 | 0.2 | naive_dl | 0.639 | 0.256 | -0.003 |
| 12 | 0.2 | twostep_dl | 0.957 | 0.532 | -0.003 |
| 12 | 0.2 | twostep_hk | 0.979 | 0.598 | -0.003 |

