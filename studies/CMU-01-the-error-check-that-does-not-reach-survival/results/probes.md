# Probes

## P1 ladder, Weibull, S 4 (one dataset)

| Q | contrast | r(Q) | prefix r | largest saved shift | lp__ shift | largest arm log-lik error | convergence | evaluations |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 | 0.133 | 0.627 | 0.205 | 1.250 | 1.070 | 2.6 | 0 | 125 |
| 16 | 0.135 | 0.639 | 0.012 | 0.776 | 0.223 | 3.85 | 0 | 105 |
| 32 | 0.081 | 0.355 | -0.284 | 0.697 | 0.323 | 1.87 | 0 | 146 |
| 64 | 0.060 | 0.245 | -0.110 | 0.607 | 0.384 | 0.776 | 0 | 112 |
| 128 | 0.041 | 0.146 | -0.100 | 0.376 | 0.076 | 0.487 | 0 | 108 |
| 256 | 0.026 | 0.066 | -0.080 | 0.264 | 0.111 | 0.177 | 0 | 112 |
| 512 | 0.015 | 0.013 | -0.053 | 0.118 | 0.047 | 0.034 | 0 | 104 |

- CPU 49 s; reference stability |r(512)| = 0.013 SD (registered: at most 0.05); SD of the contrast 0.192; 19 unconstrained parameters

## P3 integration-free null (aggregate covariate SDs published as zero)

| Q | contrast | r(Q) | prefix r | largest saved shift | lp__ shift | largest arm log-lik error | convergence | evaluations |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 3.55e-15 | 0 | 3 |
| 16 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 3.55e-15 | 0 | 4 |
| 32 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 3.11e-15 | 0 | 4 |
| 64 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 4e-15 | 0 | 3 |
| 128 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 4e-15 | 0 | 4 |
| 256 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 4e-15 | 0 | 3 |
| 512 | -0.115 | 0.000 | -0.000 | 0.000 | 0.000 | 4.88e-15 | 0 | 4 |

- largest |r(Q)| 3.4e-06 and largest saved shift 1.1e-05 (exact value 0; the residual is optimizer tolerance)

## P2 firing threshold of the split-chain check (100 sets of ideal chains per shift)

- P(fire) at shift 0, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, 0.24, 0.26, 0.28, 0.3, 0.32, 0.34, 0.36, 0.38, 0.4: 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.01, 0.00, 0.04, 0.09, 0.16, 0.39, 0.52, 0.78, 0.89
- DSTAR = 0.357 posterior SD; the analysis recomputes it with 400 sets (CPU here 37 s)

## P4 ladder, M-spline, S 12 (one dataset; the primary cell)

| Q | contrast | r(Q) | prefix r | largest saved shift | lp__ shift | largest arm log-lik error | convergence | evaluations |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 8 | -0.034 | 0.701 | -0.095 | 0.796 | 0.072 | 1.68 | 0 | 134 |
| 16 | -0.052 | 0.580 | -0.121 | 0.338 | 0.016 | 1.92 | 0 | 121 |
| 32 | -0.097 | 0.288 | -0.292 | 0.595 | 0.179 | 0.951 | 0 | 136 |
| 64 | -0.121 | 0.137 | -0.151 | 0.327 | 0.063 | 0.459 | 0 | 113 |
| 128 | -0.128 | 0.086 | -0.051 | 0.148 | 0.007 | 0.252 | 0 | 123 |
| 256 | -0.135 | 0.046 | -0.039 | 0.120 | 0.019 | 0.121 | 0 | 108 |
| 512 | -0.140 | 0.010 | -0.036 | 0.092 | 0.022 | 0.0221 | 0 | 101 |

- CPU 144 s; 165 unconstrained parameters; reference stability |r(512)| = 0.010 SD

## P5 real int_check fit (Weibull, S 4, Q 8, 4 chains x 300 iterations)

- runs end to end; fired: FALSE; CPU 80 s, so a default 4 x 2000 fit costs about 535 s

## Budget

- per dataset CPU s: Weibull S 4 49, M-spline S 4 and Weibull S 12 about 84 (interpolated), M-spline S 12 144, null 12, validation about 1631
- total: 50 datasets in each of 5 ladder cells and 10 validation datasets, about 9.7 CPU hours (user time under load average 192.84; an upper bound)
- peak R heap of this probe process: 4.5 GB (Stan autodiff memory is outside it)

