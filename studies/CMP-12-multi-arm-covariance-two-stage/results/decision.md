# Decision

**Primary: coverage of d_BC at modification 0.6, shift 0.8.**

| alignment | shared-arm ratio | method | coverage | MCSE |
|---|---:|---|---:|---:|
| same | 0.5 | stacked | 0.952 | 0.007 |
| same | 0.5 | split | 0.965 | 0.006 |
| same | 0.5 | stacked_trial | 0.936 | 0.008 |
| same | 0.5 | split_trial | 0.983 | 0.004 |
| opposite | 0.5 | stacked | 0.943 | 0.007 |
| opposite | 0.5 | split | 0.960 | 0.006 |
| opposite | 0.5 | stacked_trial | 0.933 | 0.008 |
| opposite | 0.5 | split_trial | 0.996 | 0.002 |
| same | 1.0 | stacked | 0.939 | 0.008 |
| same | 1.0 | split | 0.951 | 0.007 |
| same | 1.0 | stacked_trial | 0.925 | 0.008 |
| same | 1.0 | split_trial | 0.975 | 0.005 |
| opposite | 1.0 | stacked | 0.953 | 0.007 |
| opposite | 1.0 | split | 0.961 | 0.006 |
| opposite | 1.0 | stacked_trial | 0.932 | 0.008 |
| opposite | 1.0 | split_trial | 0.989 | 0.003 |
| same | 2.0 | stacked | 0.947 | 0.007 |
| same | 2.0 | split_trial | 0.957 | 0.006 |
| same | 2.0 | stacked_trial | 0.933 | 0.008 |
| same | 2.0 | split | 0.957 | 0.006 |
| opposite | 2.0 | split_trial | 0.983 | 0.004 |
| opposite | 2.0 | stacked | 0.947 | 0.007 |
| opposite | 2.0 | split | 0.957 | 0.006 |
| opposite | 2.0 | stacked_trial | 0.941 | 0.007 |

**Sign test (DESIGN.md prediction 2): WITHDRAWN (one-sided).** Split trial-alone d_BC coverage above 0.95 beyond 3 MCSE in 29 cells, below in 0, of 30.

Covariance recovery (estimated / Monte Carlo): stacked 0.76 to 1.15; weights-fixed 0.73 to 1.12. Shared-weighting term (stacked minus fixed) as a share of the Monte Carlo covariance: -0.219 to 0.152.

Dropping the trial: network d_AB interval width over stacked, 1.29 to 1.91 (median 1.53); above the 1.10 materiality in 30 of 30 cells.

