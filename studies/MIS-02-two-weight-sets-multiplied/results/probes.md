# Probes

Truths (target RMST difference to 24 months) and weight structure, 30 replicates per cell.

| cell | censored before 24 (declared) | target x1 mean | kappa | control | truth | censored (observed) | cor(w_part, w_cens) | ESS part | ESS cens among uncensored | ESS product | uncensored n |
|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|
| 1 | 0.25 | 0.5 | 1.2 | none | 1.851 | 0.260 | 0.26 | 339 | 348 | 216 | 370 |
| 2 | 0.60 | 0.5 | 1.2 | none | 1.851 | 0.602 | 0.21 | 337 | 99 | 55 | 199 |
| 3 | 0.25 | 1.2 | 1.2 | none | 0.903 | 0.252 | 0.27 | 112 | 350 | 72 | 374 |
| 4 | 0.60 | 1.2 | 1.2 | none | 0.903 | 0.598 | 0.22 | 105 | 98 | 22 | 201 |
| 5 | 0.25 | 0.5 | -1.2 | none | 1.851 | 0.252 | -0.33 | 336 | 307 | 287 | 374 |
| 6 | 0.60 | 0.5 | -1.2 | none | 1.851 | 0.596 | -0.24 | 331 | 82 | 119 | 202 |
| 7 | 0.25 | 1.2 | -1.2 | none | 0.903 | 0.247 | -0.25 | 111 | 322 | 110 | 377 |
| 8 | 0.60 | 1.2 | -1.2 | none | 0.903 | 0.597 | -0.18 | 115 | 65 | 90 | 202 |
| 9 | 0.00 | 1.2 | 1.2 | no_censoring | 0.903 | 0.000 | NaN | 113 | 500 | 113 | 500 |
| 10 | 0.60 | 1.2 | 0.0 | independent | 0.903 | 0.605 | -0.23 | 112 | 140 | 62 | 198 |

Unit cost with 100 bootstrap resamples: 7.7 s elapsed (1.9 s CPU) per replicate on a shared machine; 10 cells x 500 replicates is about 2.6 CPU hours.
