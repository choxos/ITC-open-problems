# Probes

## E1 corners and null control (one timing each)

| cell | outcome | S | Q | p | regression | ms per gradient | setup CPU s | replicate CPU s | parameters |
|---:|---|---:|---:|---:|---|---:|---:|---:|---:|
| 1 | binomial | 4 | 32 | 2 | TRUE | 0.100 | 0.4 | 2.3 | 11 |
| 20 | binomial | 16 | 512 | 5 | TRUE | 1.681 | 1.0 | 2.5 | 26 |
| 21 | mspline | 4 | 32 | 2 | TRUE | 4.111 | 0.7 | 2.2 | 66 |
| 40 | mspline | 16 | 512 | 5 | TRUE | 244.000 | 10.4 | 12.4 | 213 |
| 81 | binomial | 16 | 32 | 2 | FALSE | 0.085 | 0.3 | 1.6 | 19 |
| 82 | binomial | 16 | 512 | 2 | FALSE | 0.078 | 0.3 | 1.6 | 19 |
| 6 | binomial | 16 | 32 | 2 | TRUE | 0.174 | 0.3 | 1.7 | 23 |

- null control, regression-free network: t_grad at Q 512 over Q 32 = 0.91 (registered: 0.8 to 1.25)
- positive-control preview, M-spline S 16 p 5: rows ratio 512/32 = 16 against the S 4 p 2 corner; t_grad ratio 59.4

## P2 timing repeatability (binomial, S 16, Q 128, p 2)

- ms per gradient, same stanfit: 0.4527, 0.4284, 0.4494, 0.4348, 0.4369; fresh networks: 0.4195, 0.4374, 0.4299
- SD of log t_grad 0.025; with 5 repeats per cell the MCSE of a log-log slope over Q 32 to 512 (4 doublings, 5 levels) is 0.005

## E2 smoke fit (binomial, S 16, Q 32, fixed effects, 2 x 1000)

- CPU 9.3 s; leapfrog 32701 (sampling 15952); bulk ESS 879, tail ESS 749; R-hat 1.001; divergence rate 0.0000; mean treedepth 3.9; gradients per effective draw 18
- in-sampler CPU per gradient 0.2855 ms against E1's 0.1740 ms at the same configuration (cell 6)

## Budget

- E1: 82 cells x 5 repeats, about 0.5 CPU hours (interpolated from the measured corners)
- E2: 8 cells x 3 repeats, about 0.7 CPU hours (extrapolated: t_grad interpolated on rows between measured E1 corners, times the smoke fit's leapfrog count, doubled for random effects)
- per E2 cell, CPU hours per replicate: binomial/fixed/Q32 0.00; binomial/fixed/Q128 0.00; binomial/fixed/Q512 0.02; binomial/random/Q32 0.00; binomial/random/Q128 0.01; binomial/random/Q512 0.03; mspline/fixed/Q32 0.04; mspline/fixed/Q128 0.15
- load average during probes: 849; all CPU is user time of one process, an upper bound on a quiet machine

