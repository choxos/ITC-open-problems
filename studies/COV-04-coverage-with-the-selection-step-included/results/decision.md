# Decision

**Refuting sentence (continuous shrinkage does not select, so its posterior interval is honest): FAILS.** Coverage: empirical-Bayes ridge 0.794 to 0.948; hierarchical normal 0.868 to 0.959; spike-and-slab averaging 0.908 to 0.974; median-probability model 0.785 to 0.931; flat 0.939 to 0.955.

| n per arm | pattern | prior | bias | coverage | width |
|---:|---|---|---:|---:|---:|
| 100 | one_strong | eb_ridge | -0.109 | 0.896 | 0.813 |
| 100 | one_strong | flat | -0.002 | 0.939 | 1.004 |
| 100 | one_strong | hier_normal | -0.105 | 0.926 | 0.862 |
| 100 | one_strong | median_model | -0.030 | 0.885 | 0.664 |
| 100 | one_strong | spike_slab | -0.036 | 0.955 | 0.829 |
| 300 | one_strong | eb_ridge | -0.045 | 0.948 | 0.523 |
| 300 | one_strong | flat | 0.003 | 0.955 | 0.562 |
| 300 | one_strong | hier_normal | -0.042 | 0.959 | 0.534 |
| 300 | one_strong | median_model | -0.004 | 0.931 | 0.372 |
| 300 | one_strong | spike_slab | -0.005 | 0.974 | 0.450 |
| 100 | three_moderate | eb_ridge | -0.191 | 0.794 | 0.784 |
| 100 | three_moderate | flat | -0.007 | 0.954 | 1.003 |
| 100 | three_moderate | hier_normal | -0.181 | 0.868 | 0.869 |
| 100 | three_moderate | median_model | -0.127 | 0.785 | 0.686 |
| 100 | three_moderate | spike_slab | -0.138 | 0.908 | 0.865 |
| 300 | three_moderate | eb_ridge | -0.093 | 0.856 | 0.511 |
| 300 | three_moderate | flat | -0.004 | 0.942 | 0.563 |
| 300 | three_moderate | hier_normal | -0.088 | 0.891 | 0.542 |
| 300 | three_moderate | median_model | -0.037 | 0.840 | 0.418 |
| 300 | three_moderate | spike_slab | -0.056 | 0.914 | 0.505 |

