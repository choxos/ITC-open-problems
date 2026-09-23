# Decision

**Registered primary: BOTH FAR FROM ONE: no ensemble here is an imputation.**

Variance calibration ratio for RMST at a 6-month risk table (cells 3, 4, 9, 10): analyst variants 44.30, 31.79, 39.55, 34.04; observation-model draws 7.50, 2.35, 11.24, 2.30.

Non-uniformity: largest to smallest width inflation across estimands at least 2 in 12 of 12 main cells (registered: non-uniform if at least 7).

Null control (single reconstruction RMSE below 10% of the sampling SD for RMST and 12-month survival): TRUE; RMSE/SD rmst24 0.020, s12 0.050, s48 0.134.

Positive control (cell 12, single-reconstruction RMSE at least 25% of the sampling SD for 12-month survival): FALSE (0.131).

Replicates dropped per cell: 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 139.

| cell | resolution | table | censoring | estimand | method | error bias | error RMSE / sampling SD | variance ratio (MCSE) | MSE ratio | reconstruction coverage 0.90 | population coverage | width vs oracle |
|---:|---|---:|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | fine | 3 | spread | rmst24 | draws | -0.0025 | 0.010 | 2.52 (0.21) | 1.98 | 0.967 | 0.940 | 1.000 |
| 1 | fine | 3 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.940 | 1.000 |
| 1 | fine | 3 | spread | s48 | single | -0.0003 | 0.115 |  |  |  | 0.940 | 1.000 |
| 1 | fine | 3 | spread | s12 | variants | 0.0060 | 0.215 | 5.76 (0.50) | 1.04 | 0.833 | 0.953 | 1.025 |
| 1 | fine | 3 | spread | s12 | draws | -0.0002 | 0.029 | 1.11 (0.15) | 1.06 | 0.517 | 0.950 | 1.001 |
| 1 | fine | 3 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 1 | fine | 3 | spread | rmst24 | single | 0.0033 | 0.020 |  |  |  | 0.940 | 1.000 |
| 1 | fine | 3 | spread | s48 | variants | 0.0069 | 0.335 | 2.19 (0.24) | 0.80 | 0.670 | 0.960 | 1.090 |
| 1 | fine | 3 | spread | s48 | draws | 0.0001 | 0.105 | 0.22 (0.02) | 0.22 | 0.580 | 0.943 | 1.002 |
| 1 | fine | 3 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.943 | 1.000 |
| 1 | fine | 3 | spread | s12 | single | -0.0000 | 0.043 |  |  |  | 0.943 | 1.001 |
| 1 | fine | 3 | spread | rmst24 | variants | 0.1731 | 0.337 | 51.80 (4.37) | 0.53 | 0.913 | 0.950 | 1.028 |
| 2 | coarse | 3 | spread | rmst24 | variants | 0.1773 | 0.349 | 33.66 (3.25) | 0.45 | 0.593 | 0.947 | 1.022 |
| 2 | coarse | 3 | spread | rmst24 | draws | -0.0000 | 0.010 | 2.05 (0.19) | 2.06 | 0.953 | 0.947 | 1.001 |
| 2 | coarse | 3 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.943 | 1.000 |
| 2 | coarse | 3 | spread | rmst24 | single | 0.0194 | 0.069 |  |  |  | 0.953 | 1.000 |
| 2 | coarse | 3 | spread | s12 | variants | 0.0081 | 0.309 | 3.20 (0.24) | 0.89 | 0.787 | 0.937 | 1.043 |
| 2 | coarse | 3 | spread | s12 | draws | 0.0001 | 0.080 | 1.87 (0.15) | 1.87 | 0.993 | 0.937 | 1.008 |
| 2 | coarse | 3 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.933 | 1.000 |
| 2 | coarse | 3 | spread | s48 | single | -0.0009 | 0.135 |  |  |  | 0.953 | 1.000 |
| 2 | coarse | 3 | spread | s48 | variants | -0.0016 | 0.224 | 1.86 (0.19) | 1.72 | 0.873 | 0.953 | 1.053 |
| 2 | coarse | 3 | spread | s48 | draws | 0.0019 | 0.147 | 0.72 (0.08) | 0.53 | 0.717 | 0.960 | 1.015 |
| 2 | coarse | 3 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.953 | 1.000 |
| 2 | coarse | 3 | spread | s12 | single | 0.0009 | 0.126 |  |  |  | 0.937 | 1.002 |
| 3 | fine | 6 | spread | rmst24 | single | 0.0069 | 0.020 |  |  |  | 0.950 | 0.999 |
| 3 | fine | 6 | spread | rmst24 | variants | 0.1745 | 0.317 | 44.30 (4.20) | 0.52 | 0.900 | 0.950 | 1.027 |
| 3 | fine | 6 | spread | rmst24 | draws | -0.0008 | 0.005 | 7.50 (0.58) | 6.92 | 1.000 | 0.947 | 1.000 |
| 3 | fine | 6 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.947 | 1.000 |
| 3 | fine | 6 | spread | s12 | single | 0.0001 | 0.034 |  |  |  | 0.930 | 1.000 |
| 3 | fine | 6 | spread | s12 | variants | 0.0059 | 0.209 | 6.26 (0.53) | 1.04 | 0.820 | 0.933 | 1.023 |
| 3 | fine | 6 | spread | s12 | draws | -0.0001 | 0.024 | 1.11 (0.09) | 1.10 | 0.463 | 0.930 | 1.001 |
| 3 | fine | 6 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.930 | 1.000 |
| 3 | fine | 6 | spread | s48 | single | -0.0002 | 0.137 |  |  |  | 0.933 | 0.994 |
| 3 | fine | 6 | spread | s48 | variants | 0.0057 | 0.298 | 1.43 (0.15) | 0.70 | 0.633 | 0.947 | 1.070 |
| 3 | fine | 6 | spread | s48 | draws | 0.0002 | 0.127 | 0.25 (0.03) | 0.25 | 0.693 | 0.937 | 0.996 |
| 3 | fine | 6 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.937 | 1.000 |
| 4 | coarse | 6 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 4 | coarse | 6 | spread | rmst24 | single | 0.0153 | 0.064 |  |  |  | 0.940 | 0.999 |
| 4 | coarse | 6 | spread | rmst24 | variants | 0.1753 | 0.328 | 31.79 (2.29) | 0.46 | 0.633 | 0.943 | 1.021 |
| 4 | coarse | 6 | spread | rmst24 | draws | -0.0001 | 0.009 | 2.35 (0.19) | 2.36 | 0.987 | 0.950 | 1.000 |
| 4 | coarse | 6 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 4 | coarse | 6 | spread | s12 | single | 0.0008 | 0.126 |  |  |  | 0.937 | 1.000 |
| 4 | coarse | 6 | spread | s12 | variants | 0.0070 | 0.275 | 3.01 (0.27) | 0.91 | 0.753 | 0.957 | 1.033 |
| 4 | coarse | 6 | spread | s12 | draws | 0.0001 | 0.072 | 2.28 (0.25) | 2.29 | 0.990 | 0.953 | 1.007 |
| 4 | coarse | 6 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.933 | 1.000 |
| 4 | coarse | 6 | spread | s48 | single | -0.0012 | 0.145 |  |  |  | 0.927 | 0.990 |
| 4 | coarse | 6 | spread | s48 | variants | -0.0014 | 0.193 | 1.81 (0.18) | 1.70 | 0.870 | 0.940 | 1.046 |
| 4 | coarse | 6 | spread | s48 | draws | 0.0015 | 0.159 | 0.51 (0.06) | 0.46 | 0.763 | 0.923 | 1.006 |
| 5 | fine | 0 | spread | rmst24 | draws | -0.0010 | 0.004 | 13.08 (1.15) | 9.48 | 1.000 | 0.953 | 1.039 |
| 5 | fine | 0 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.943 | 1.000 |
| 5 | fine | 0 | spread | rmst24 | single | 0.0064 | 0.017 |  |  |  | 0.953 | 1.037 |
| 5 | fine | 0 | spread | rmst24 | variants | 0.1806 | 0.357 | 50.82 (3.88) | 0.48 | 0.830 | 0.940 | 1.036 |
| 5 | fine | 0 | spread | s12 | draws | 0.0000 | 0.030 | 3.48 (0.49) | 3.49 | 1.000 | 0.953 | 1.050 |
| 5 | fine | 0 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.947 | 1.000 |
| 5 | fine | 0 | spread | s12 | single | 0.0003 | 0.061 |  |  |  | 0.963 | 1.048 |
| 5 | fine | 0 | spread | s12 | variants | 0.0060 | 0.223 | 5.16 (0.43) | 0.87 | 0.853 | 0.953 | 1.041 |
| 5 | fine | 0 | spread | s48 | draws | 0.0006 | 0.246 | 0.16 (0.01) | 0.15 | 0.417 | 0.940 | 0.997 |
| 5 | fine | 0 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.937 | 1.000 |
| 5 | fine | 0 | spread | s48 | single | 0.0001 | 0.243 |  |  |  | 0.930 | 0.992 |
| 5 | fine | 0 | spread | s48 | variants | 0.0089 | 0.684 | 0.62 (0.08) | 0.47 | 0.503 | 0.923 | 1.017 |
| 6 | coarse | 0 | spread | rmst24 | variants | 0.1808 | 0.362 | 39.49 (2.92) | 0.42 | 0.620 | 0.963 | 1.029 |
| 6 | coarse | 0 | spread | rmst24 | draws | 0.0005 | 0.010 | 2.40 (0.20) | 2.38 | 0.987 | 0.973 | 1.038 |
| 6 | coarse | 0 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.967 | 1.000 |
| 6 | coarse | 0 | spread | rmst24 | single | 0.0383 | 0.082 |  |  |  | 0.973 | 1.034 |
| 6 | coarse | 0 | spread | s12 | variants | 0.0077 | 0.308 | 3.25 (0.31) | 0.78 | 0.747 | 0.957 | 1.052 |
| 6 | coarse | 0 | spread | s12 | draws | 0.0001 | 0.078 | 2.33 (0.20) | 2.33 | 0.990 | 0.967 | 1.055 |
| 6 | coarse | 0 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.957 | 1.000 |
| 6 | coarse | 0 | spread | s12 | single | 0.0020 | 0.135 |  |  |  | 0.970 | 1.046 |
| 6 | coarse | 0 | spread | s48 | variants | -0.0018 | 0.490 | 1.30 (0.15) | 1.28 | 0.890 | 0.913 | 1.041 |
| 6 | coarse | 0 | spread | s48 | draws | 0.0003 | 0.254 | 0.24 (0.02) | 0.24 | 0.523 | 0.923 | 0.995 |
| 6 | coarse | 0 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.947 | 1.000 |
| 6 | coarse | 0 | spread | s48 | single | -0.0026 | 0.260 |  |  |  | 0.923 | 0.977 |
| 7 | fine | 3 | clustered | rmst24 | single | 0.0026 | 0.023 |  |  |  | 0.947 | 1.004 |
| 7 | fine | 3 | clustered | rmst24 | variants | 0.1863 | 0.354 | 34.76 (3.22) | 0.51 | 0.810 | 0.940 | 1.036 |
| 7 | fine | 3 | clustered | rmst24 | draws | -0.0058 | 0.015 | 3.69 (0.33) | 1.72 | 0.963 | 0.947 | 1.005 |
| 7 | fine | 3 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.943 | 1.000 |
| 7 | fine | 3 | clustered | s12 | single | 0.0005 | 0.062 |  |  |  | 0.947 | 1.006 |
| 7 | fine | 3 | clustered | s12 | variants | 0.0060 | 0.220 | 3.65 (0.32) | 0.82 | 0.790 | 0.950 | 1.026 |
| 7 | fine | 3 | clustered | s12 | draws | -0.0000 | 0.040 | 1.86 (0.19) | 1.86 | 0.933 | 0.953 | 1.007 |
| 7 | fine | 3 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.953 | 1.000 |
| 7 | fine | 3 | clustered | s48 | single | -0.0006 | 0.120 |  |  |  | 0.960 | 1.006 |
| 7 | fine | 3 | clustered | s48 | variants | 0.0090 | 0.390 | 1.83 (0.18) | 0.63 | 0.630 | 0.970 | 1.108 |
| 7 | fine | 3 | clustered | s48 | draws | 0.0000 | 0.109 | 0.23 (0.02) | 0.23 | 0.567 | 0.957 | 1.009 |
| 7 | fine | 3 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 8 | coarse | 3 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 8 | coarse | 3 | clustered | rmst24 | single | 0.0147 | 0.067 |  |  |  | 0.953 | 1.004 |
| 8 | coarse | 3 | clustered | rmst24 | variants | 0.1684 | 0.334 | 34.89 (3.16) | 0.50 | 0.797 | 0.947 | 1.026 |
| 8 | coarse | 3 | clustered | rmst24 | draws | -0.0003 | 0.011 | 2.31 (0.16) | 2.31 | 0.980 | 0.953 | 1.005 |
| 8 | coarse | 3 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 8 | coarse | 3 | clustered | s12 | single | 0.0006 | 0.119 |  |  |  | 0.940 | 1.006 |
| 8 | coarse | 3 | clustered | s12 | variants | 0.0066 | 0.272 | 2.72 (0.28) | 0.88 | 0.753 | 0.940 | 1.035 |
| 8 | coarse | 3 | clustered | s12 | draws | -0.0000 | 0.080 | 1.90 (0.20) | 1.90 | 0.967 | 0.937 | 1.012 |
| 8 | coarse | 3 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.957 | 1.000 |
| 8 | coarse | 3 | clustered | s48 | single | -0.0014 | 0.163 |  |  |  | 0.967 | 1.003 |
| 8 | coarse | 3 | clustered | s48 | variants | -0.0004 | 0.242 | 2.11 (0.22) | 2.11 | 0.897 | 0.963 | 1.072 |
| 8 | coarse | 3 | clustered | s48 | draws | 0.0018 | 0.164 | 0.77 (0.08) | 0.63 | 0.767 | 0.970 | 1.022 |
| 9 | fine | 6 | clustered | rmst24 | draws | -0.0040 | 0.010 | 11.24 (0.95) | 3.55 | 0.997 | 0.977 | 1.011 |
| 9 | fine | 6 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.973 | 1.000 |
| 9 | fine | 6 | clustered | rmst24 | single | 0.0029 | 0.020 |  |  |  | 0.977 | 1.011 |
| 9 | fine | 6 | clustered | rmst24 | variants | 0.1850 | 0.383 | 39.55 (3.16) | 0.52 | 0.809 | 0.960 | 1.043 |
| 9 | fine | 6 | clustered | s12 | draws | -0.0002 | 0.032 | 3.03 (0.36) | 2.83 | 0.997 | 0.980 | 1.015 |
| 9 | fine | 6 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.977 | 1.000 |
| 9 | fine | 6 | clustered | s12 | single | -0.0001 | 0.059 |  |  |  | 0.980 | 1.014 |
| 9 | fine | 6 | clustered | s12 | variants | 0.0059 | 0.239 | 4.85 (0.60) | 0.90 | 0.822 | 0.977 | 1.033 |
| 9 | fine | 6 | clustered | s48 | draws | 0.0004 | 0.171 | 0.15 (0.02) | 0.15 | 0.564 | 0.940 | 1.008 |
| 9 | fine | 6 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.936 | 1.000 |
| 9 | fine | 6 | clustered | s48 | single | -0.0001 | 0.185 |  |  |  | 0.936 | 1.005 |
| 9 | fine | 6 | clustered | s48 | variants | 0.0073 | 0.341 | 1.58 (0.17) | 0.64 | 0.617 | 0.963 | 1.093 |
| 10 | coarse | 6 | clustered | rmst24 | variants | 0.1730 | 0.312 | 34.04 (3.27) | 0.43 | 0.673 | 0.933 | 1.030 |
| 10 | coarse | 6 | clustered | rmst24 | draws | -0.0008 | 0.010 | 2.30 (0.18) | 2.27 | 0.983 | 0.943 | 1.011 |
| 10 | coarse | 6 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.940 | 1.000 |
| 10 | coarse | 6 | clustered | rmst24 | single | 0.0351 | 0.070 |  |  |  | 0.947 | 1.010 |
| 10 | coarse | 6 | clustered | s12 | variants | 0.0069 | 0.263 | 2.62 (0.26) | 0.88 | 0.753 | 0.950 | 1.045 |
| 10 | coarse | 6 | clustered | s12 | draws | -0.0001 | 0.078 | 1.84 (0.16) | 1.84 | 0.973 | 0.950 | 1.020 |
| 10 | coarse | 6 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.940 | 1.000 |
| 10 | coarse | 6 | clustered | s12 | single | 0.0016 | 0.131 |  |  |  | 0.947 | 1.014 |
| 10 | coarse | 6 | clustered | s48 | variants | -0.0012 | 0.195 | 2.15 (0.23) | 2.05 | 0.850 | 0.943 | 1.057 |
| 10 | coarse | 6 | clustered | s48 | draws | 0.0015 | 0.172 | 0.53 (0.06) | 0.48 | 0.697 | 0.947 | 1.017 |
| 10 | coarse | 6 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.943 | 1.000 |
| 10 | coarse | 6 | clustered | s48 | single | -0.0021 | 0.173 |  |  |  | 0.927 | 0.998 |
| 11 | fine | 0 | clustered | rmst24 | single | 0.0069 | 0.016 |  |  |  | 0.927 | 1.020 |
| 11 | fine | 0 | clustered | rmst24 | variants | 0.1913 | 0.346 | 43.33 (3.47) | 0.46 | 0.707 | 0.927 | 1.018 |
| 11 | fine | 0 | clustered | rmst24 | draws | -0.0008 | 0.003 | 11.29 (1.02) | 9.50 | 1.000 | 0.927 | 1.022 |
| 11 | fine | 0 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.923 | 1.000 |
| 11 | fine | 0 | clustered | s12 | single | 0.0002 | 0.062 |  |  |  | 0.950 | 1.032 |
| 11 | fine | 0 | clustered | s12 | variants | 0.0065 | 0.230 | 4.64 (0.48) | 0.84 | 0.820 | 0.937 | 1.024 |
| 11 | fine | 0 | clustered | s12 | draws | 0.0000 | 0.032 | 3.12 (0.47) | 3.13 | 1.000 | 0.947 | 1.035 |
| 11 | fine | 0 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.937 | 1.000 |
| 11 | fine | 0 | clustered | s48 | single | 0.0002 | 0.197 |  |  |  | 0.913 | 0.964 |
| 11 | fine | 0 | clustered | s48 | variants | 0.0129 | 0.754 | 0.79 (0.05) | 0.51 | 0.487 | 0.910 | 1.044 |
| 11 | fine | 0 | clustered | s48 | draws | 0.0007 | 0.189 | 0.26 (0.03) | 0.25 | 0.610 | 0.917 | 0.969 |
| 11 | fine | 0 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.913 | 1.000 |
| 12 | coarse | 0 | clustered | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.963 | 1.000 |
| 12 | coarse | 0 | clustered | rmst24 | single | 0.0390 | 0.078 |  |  |  | 0.960 | 1.019 |
| 12 | coarse | 0 | clustered | rmst24 | variants | 0.1736 | 0.337 | 33.80 (2.95) | 0.46 | 0.697 | 0.937 | 1.010 |
| 12 | coarse | 0 | clustered | rmst24 | draws | 0.0004 | 0.010 | 2.16 (0.19) | 2.16 | 0.967 | 0.967 | 1.022 |
| 12 | coarse | 0 | clustered | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.960 | 1.000 |
| 12 | coarse | 0 | clustered | s12 | single | 0.0017 | 0.131 |  |  |  | 0.960 | 1.032 |
| 12 | coarse | 0 | clustered | s12 | variants | 0.0070 | 0.278 | 2.75 (0.30) | 0.80 | 0.733 | 0.953 | 1.031 |
| 12 | coarse | 0 | clustered | s12 | draws | 0.0001 | 0.079 | 1.91 (0.18) | 1.91 | 0.980 | 0.963 | 1.039 |
| 12 | coarse | 0 | clustered | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.947 | 1.000 |
| 12 | coarse | 0 | clustered | s48 | single | -0.0026 | 0.233 |  |  |  | 0.937 | 0.955 |
| 12 | coarse | 0 | clustered | s48 | variants | 0.0025 | 0.540 | 1.38 (0.11) | 1.34 | 0.883 | 0.937 | 1.057 |
| 12 | coarse | 0 | clustered | s48 | draws | 0.0010 | 0.217 | 0.40 (0.04) | 0.40 | 0.653 | 0.950 | 0.976 |
| 13 | fine | 1 | spread | s48 | draws | 0.0001 | 0.130 |  |  |  | 0.950 | 1.010 |
| 13 | fine | 1 | spread | s12 | oracle | 0.0000 | 0.000 |  |  |  | 0.944 | 1.000 |
| 13 | fine | 1 | spread | rmst24 | single | -0.0044 | 0.020 |  |  |  | 0.932 | 1.001 |
| 13 | fine | 1 | spread | rmst24 | variants | 0.1761 | 0.330 |  |  |  | 0.932 | 1.029 |
| 13 | fine | 1 | spread | rmst24 | draws | -0.0085 | 0.020 |  |  |  | 0.925 | 1.001 |
| 13 | fine | 1 | spread | s48 | oracle | 0.0000 | 0.000 |  |  |  | 0.950 | 1.000 |
| 13 | fine | 1 | spread | s12 | single | -0.0003 | 0.050 |  |  |  | 0.944 | 1.002 |
| 13 | fine | 1 | spread | s12 | variants | 0.0066 | 0.240 |  |  |  | 0.950 | 1.025 |
| 13 | fine | 1 | spread | s12 | draws | -0.0004 | 0.038 |  |  |  | 0.944 | 1.002 |
| 13 | fine | 1 | spread | rmst24 | oracle | 0.0000 | 0.000 |  |  |  | 0.932 | 1.000 |
| 13 | fine | 1 | spread | s48 | single | -0.0005 | 0.134 |  |  |  | 0.950 | 1.007 |
| 13 | fine | 1 | spread | s48 | variants | 0.0102 | 0.481 |  |  |  | 0.981 | 1.114 |

