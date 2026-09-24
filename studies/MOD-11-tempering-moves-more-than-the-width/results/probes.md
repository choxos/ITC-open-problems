# Probes

## P3 flat-model tempering (second null control)

- mean shift at eta 0.5: 1.1e-08 posterior SD; variance ratio 2.000000 (exact: 0 and 2)

## Smoke run (one replicate per listed cell)

| cell | arm | predictive 95% | log score | mean contrast | K | co-clustering | tau | IPD share |
|---:|---|---|---:|---:|---:|---:|---:|---:|
| 1 | re_1 | -0.53 to 0.97 | 0.11 | 0.192 |  |  | 0.16 | 0.42 |
| 1 | re_0.5 | -0.74 to 1.06 | -0.13 | 0.150 |  |  | 0.16 | 0.35 |
| 1 | t_1 | -0.58 to 1.12 | 0.04 | 0.226 |  |  |  |  |
| 1 | dp_1 | -0.59 to 1.02 | 0.08 | 0.204 | 2.23 | 0.57 |  |  |
| 1 | dp_0.5 | -0.84 to 1.03 | -0.22 | 0.119 | 2.23 | 0.57 |  |  |
| 1 | dplo_1 | -0.53 to 0.98 | 0.16 | 0.200 | 1.50 | 0.81 |  |  |
| 1 | dphi_1 | -0.61 to 1.01 | 0.13 | 0.211 | 3.44 | 0.30 |  |  |
| 3 | re_1 | -0.67 to 2.13 | -0.76 | 0.757 |  |  | 0.57 | 0.89 |
| 3 | re_0.5 | -0.59 to 2.11 | -0.62 | 0.815 |  |  | 0.49 | 0.80 |
| 3 | t_1 | -1.01 to 2.44 | -0.80 | 0.743 |  |  |  |  |
| 3 | dp_1 | -0.41 to 1.87 | -0.65 | 0.746 | 2.84 | 0.36 |  |  |
| 3 | dp_0.5 | -0.40 to 1.89 | -0.59 | 0.825 | 2.65 | 0.43 |  |  |
| 3 | dplo_1 | -0.42 to 1.88 | -0.65 | 0.772 | 1.87 | 0.64 |  |  |
| 3 | dphi_1 | -0.47 to 2.04 | -0.65 | 0.737 | 3.88 | 0.19 |  |  |
| 10 | re_1 | -0.06 to 0.72 | 0.61 | 0.325 |  |  | 0.08 | 0.77 |
| 10 | re_0.5 | -0.19 to 0.82 | 0.37 | 0.314 |  |  | 0.09 | 0.74 |
| 10 | t_1 | -0.07 to 0.75 | 0.70 | 0.341 |  |  |  |  |
| 10 | dp_1 | -0.11 to 0.77 | 0.55 | 0.328 | 2.70 | 0.59 |  |  |
| 10 | dp_0.5 | -0.16 to 0.83 | 0.32 | 0.325 | 2.54 | 0.62 |  |  |
| 10 | dplo_1 | -0.08 to 0.73 | 0.51 | 0.319 | 1.45 | 0.87 |  |  |
| 10 | dphi_1 | -0.18 to 0.85 | 0.55 | 0.339 | 4.79 | 0.30 |  |  |
| 12 | re_1 | -1.10 to 2.34 | -2.00 | 0.619 |  |  | 0.80 | 0.95 |
| 12 | re_0.5 | -1.11 to 2.30 | -1.96 | 0.590 |  |  | 0.77 | 0.90 |
| 12 | t_1 | -1.39 to 2.67 | -2.28 | 0.720 |  |  |  |  |
| 12 | dp_1 | -0.96 to 1.80 | -1.22 | 0.594 | 3.60 | 0.36 |  |  |
| 12 | dp_0.5 | -0.99 to 1.89 | -1.39 | 0.590 | 3.46 | 0.38 |  |  |
| 12 | dplo_1 | -0.92 to 1.72 | -1.27 | 0.610 | 2.56 | 0.47 |  |  |
| 12 | dphi_1 | -0.97 to 1.91 | -1.35 | 0.595 | 5.40 | 0.22 |  |  |

- prior-dependence ratio (co-clustering) per smoke cell: cell 1 0.98, cell 3 0.86, cell 10 1.09, cell 12 0.49

## Null control, 6 replicates (one cluster, 12 studies, half IPD)

- mean log score: dp_0.5 0.366, dp_1 0.503, dphi_1 0.449, dplo_1 0.506, re_0.5 0.455, re_1 0.535, t_1 0.532; dp minus re -0.032 (registered: within 0.05 at 400 replicates)

## Unit cost

- CPU per replicate (7 fits): 8.5, 8.8, 13.0, 15.4 s for cells 1, 3, 10, 12
- total CPU for 12 cells x 400 replicates: about 15.2 hours (user time, measured under load average 869; an upper bound)

