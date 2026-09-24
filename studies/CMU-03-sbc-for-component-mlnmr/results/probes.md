# Probes

## P1 simulator against multinma's coded likelihood

- R coded log-likelihood minus multinma's, over 20 prior draws: SD 3.8e-13 (a constant offset is the dropped normalizing terms)

## Smoke run

| cell | construction | Q | margin | identification | implementation | sampler | CPU s | Pareto k | contrast PIT | log-lik PIT |
|---:|---|---:|---|---|---|---|---:|---:|---:|---:|
| 1 | coded | 64 | normal | strong | correct | is | 2.1 | 0.49 | 0.983 | 0.033 |
| 3 | e2e | 16 | normal | strong | correct | is | 1.3 | 0.56 | 0.819 | 0.968 |
| 7 | e2e | 64 | skewed | strong | correct | is | 1.5 | 0.21 | 0.786 | 0.054 |
| 15 | coded | 64 | normal | strong | prior | is | 1.0 |  | 0.321 | 1.000 |
| 16 | coded | 64 | normal | strong | sign | is | 1.6 | 0.10 | 1.000 | 0.000 |
| 17 | coded | 64 | normal | strong | correct | nuts | 9.1 |  | 0.580 | 0.476 |
| 5 | e2e | 512 | normal | strong | correct | is | 2.9 | 0.42 | 0.063 | 0.477 |

## Controls (KS p-values; the registered run uses 1000 replicates per cell)

| cell | implementation | replicates | seed | contrast | log-lik | smallest parameter p (which) | max Pareto k | CPU s |
|---:|---|---:|---:|---:|---:|---|---:|---:|
| 1 | correct | 100 | 101 | 0.672 | 0.52 | 0.1579 (beta[.trtB:x1]) | 1.17 | 163 |
| 15 | prior | 20 | 115 | 0.884 | 0 | 0.0207 (mu[S2]) |  | 20 |
| 16 | sign | 20 | 116 | 0.032 | 0 | 0.0000 (mu[S4]) | 0.98 | 49 |

With 15 quantities per cell, the chance that some quantity has p < 0.001 under a correct null is about 1.5%; the registered null threshold is p >= 0.001 per quantity at 1000 replicates.

## Unit cost

- CPU per importance-sampling replicate 1.6 s (coded, Q 64); NUTS replicate 9.1 s; Q 512 replicate 1.5 s
- total CPU: 16 IS cells x 1000 + 200 NUTS replicates, about 7.8 hours (user time under load average 143.39; an upper bound)

