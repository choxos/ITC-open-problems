# Decision

**Refuting sentence (correcting the outcome model is sufficient): FAILS.** Outcome-only correction: bias -0.051 to -0.012; full correction -0.006 to 0.006.

MAIC on the misclassified covariate with identical assays in both studies: bias -0.032, -0.062, -0.052, -0.130 (beyond 3 MCSE in 4 of 4 cells).

MAIC with latent-prevalence weights: bias -0.006 to 0.006.

| assay | modification | method | bias | MCSE | RMSE |
|---|---:|---|---:|---:|---:|
| same_good | 0.5 | maic_naive | -0.032 | 0.005 | 0.166 |
| same_good | 0.5 | maic_prev_only | -0.032 | 0.005 | 0.166 |
| same_good | 0.5 | maic_corrected | -0.004 | 0.005 | 0.171 |
| same_good | 0.5 | stc_naive | -0.030 | 0.005 | 0.164 |
| same_good | 0.5 | stc_outcome_only | -0.014 | 0.005 | 0.167 |
| same_good | 0.5 | stc_corrected | -0.002 | 0.005 | 0.170 |
| same_poor | 0.5 | maic_naive | -0.062 | 0.005 | 0.175 |
| same_poor | 0.5 | maic_prev_only | -0.062 | 0.005 | 0.175 |
| same_poor | 0.5 | maic_corrected | 0.002 | 0.006 | 0.199 |
| same_poor | 0.5 | stc_naive | -0.063 | 0.005 | 0.174 |
| same_poor | 0.5 | stc_outcome_only | -0.022 | 0.006 | 0.184 |
| same_poor | 0.5 | stc_corrected | 0.002 | 0.006 | 0.199 |
| source_worse | 0.5 | maic_naive | -0.059 | 0.005 | 0.183 |
| source_worse | 0.5 | maic_prev_only | -0.069 | 0.005 | 0.182 |
| source_worse | 0.5 | maic_corrected | -0.006 | 0.007 | 0.206 |
| source_worse | 0.5 | stc_naive | -0.059 | 0.005 | 0.183 |
| source_worse | 0.5 | stc_outcome_only | -0.013 | 0.006 | 0.202 |
| source_worse | 0.5 | stc_corrected | -0.006 | 0.007 | 0.206 |
| target_worse | 0.5 | maic_naive | -0.028 | 0.006 | 0.179 |
| target_worse | 0.5 | maic_prev_only | -0.012 | 0.006 | 0.182 |
| target_worse | 0.5 | maic_corrected | 0.000 | 0.006 | 0.185 |
| target_worse | 0.5 | stc_naive | -0.029 | 0.006 | 0.177 |
| target_worse | 0.5 | stc_outcome_only | -0.024 | 0.006 | 0.177 |
| target_worse | 0.5 | stc_corrected | -0.000 | 0.006 | 0.183 |
| same_good | 1.0 | maic_naive | -0.052 | 0.005 | 0.171 |
| same_good | 1.0 | maic_prev_only | -0.052 | 0.005 | 0.171 |
| same_good | 1.0 | maic_corrected | 0.001 | 0.005 | 0.171 |
| same_good | 1.0 | stc_naive | -0.053 | 0.005 | 0.168 |
| same_good | 1.0 | stc_outcome_only | -0.022 | 0.005 | 0.165 |
| same_good | 1.0 | stc_corrected | 0.001 | 0.005 | 0.168 |
| same_poor | 1.0 | maic_naive | -0.130 | 0.005 | 0.205 |
| same_poor | 1.0 | maic_prev_only | -0.130 | 0.005 | 0.205 |
| same_poor | 1.0 | maic_corrected | -0.004 | 0.006 | 0.196 |
| same_poor | 1.0 | stc_naive | -0.130 | 0.005 | 0.205 |
| same_poor | 1.0 | stc_outcome_only | -0.051 | 0.006 | 0.186 |
| same_poor | 1.0 | stc_corrected | -0.004 | 0.006 | 0.196 |
| source_worse | 1.0 | maic_naive | -0.104 | 0.005 | 0.191 |
| source_worse | 1.0 | maic_prev_only | -0.124 | 0.005 | 0.200 |
| source_worse | 1.0 | maic_corrected | 0.003 | 0.006 | 0.187 |
| source_worse | 1.0 | stc_naive | -0.104 | 0.005 | 0.190 |
| source_worse | 1.0 | stc_outcome_only | -0.012 | 0.006 | 0.183 |
| source_worse | 1.0 | stc_corrected | 0.002 | 0.006 | 0.187 |
| target_worse | 1.0 | maic_naive | -0.051 | 0.005 | 0.171 |
| target_worse | 1.0 | maic_prev_only | -0.019 | 0.005 | 0.170 |
| target_worse | 1.0 | maic_corrected | 0.006 | 0.005 | 0.173 |
| target_worse | 1.0 | stc_naive | -0.050 | 0.005 | 0.168 |
| target_worse | 1.0 | stc_outcome_only | -0.041 | 0.005 | 0.167 |
| target_worse | 1.0 | stc_corrected | 0.006 | 0.005 | 0.170 |

