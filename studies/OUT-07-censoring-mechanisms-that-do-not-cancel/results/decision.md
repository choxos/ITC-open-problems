# Decision

**Refuting sentence (informative censoring biases both sides alike, so the contrast is protected): FAILS.** Unanchored, mechanisms differing: bias -2.326 to 1.416 months (truth 0.623). Mechanisms equal: bias -0.080 to 0.021.

Anchored: bias -0.202 to 0.219 months (truth 0.623).

Source-side IPCW with a baseline proxy: largest |bias| 2.262 against 2.326 naive.

| design | alpha source | alpha comparator | prevalence | bias | coverage | wrong sign | bias, source IPCW | fragile over delta 0.5 to 2 | median delta reproducing truth | that delta in [0.5, 2] |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| unanchored | 0 | 0 | 0.2 | 0.021 | 0.958 | 0.194 | 0.095 | 0.30 | 1.08 | 0.56 |
| unanchored | 1 | 0 | 0.2 | 0.453 | 0.900 | 0.089 | 0.297 | 0.23 | 0.87 | 0.53 |
| unanchored | 0 | 1 | 0.2 | -0.486 | 0.906 | 0.422 | -0.407 | 0.51 | 1.64 | 0.53 |
| unanchored | 1 | 1 | 0.2 | -0.030 | 0.944 | 0.227 | -0.190 | 0.40 | 1.33 | 0.57 |
| unanchored | 0 | 2 | 0.2 | -0.863 | 0.806 | 0.621 | -0.788 | 0.56 | 2.20 | 0.41 |
| unanchored | 1 | 2 | 0.2 | -0.425 | 0.911 | 0.407 | -0.582 | 0.56 | 1.85 | 0.47 |
| unanchored | 0 | 0 | 0.5 | -0.035 | 0.944 | 0.238 | 0.029 | 0.72 | 0.92 | 0.89 |
| unanchored | 1 | 0 | 0.5 | 1.416 | 0.629 | 0.013 | 0.985 | 0.29 | 0.56 | 0.58 |
| unanchored | 0 | 1 | 0.5 | -1.414 | 0.633 | 0.823 | -1.352 | 0.85 | 1.67 | 0.66 |
| unanchored | 1 | 1 | 0.5 | -0.080 | 0.939 | 0.266 | -0.515 | 0.85 | 1.23 | 0.87 |
| unanchored | 0 | 2 | 0.5 | -2.326 | 0.274 | 0.973 | -2.262 | 0.52 | 2.43 | 0.30 |
| unanchored | 1 | 2 | 0.5 | -0.891 | 0.849 | 0.622 | -1.317 | 0.86 | 1.71 | 0.70 |
| anchored | 0 | 0 | 0.2 | 0.010 | 0.946 | 0.282 | 0.028 | 0.07 | 1.05 | 0.33 |
| anchored | 1 | 0 | 0.2 | -0.027 | 0.948 | 0.281 | 0.008 | 0.06 | 0.95 | 0.42 |
| anchored | 0 | 1 | 0.2 | 0.058 | 0.954 | 0.252 | 0.075 | 0.06 | 1.11 | 0.34 |
| anchored | 1 | 1 | 0.2 | 0.009 | 0.952 | 0.275 | 0.044 | 0.07 | 1.13 | 0.44 |
| anchored | 0 | 2 | 0.2 | 0.064 | 0.944 | 0.259 | 0.085 | 0.06 | 0.82 | 0.37 |
| anchored | 1 | 2 | 0.2 | -0.057 | 0.953 | 0.305 | -0.018 | 0.08 | 0.94 | 0.38 |
| anchored | 0 | 0 | 0.5 | 0.072 | 0.947 | 0.282 | 0.093 | 0.15 | 0.56 | 0.30 |
| anchored | 1 | 0 | 0.5 | -0.202 | 0.954 | 0.378 | -0.056 | 0.14 | 0.54 | 0.26 |
| anchored | 0 | 1 | 0.5 | 0.096 | 0.958 | 0.277 | 0.117 | 0.14 | 0.65 | 0.29 |
| anchored | 1 | 1 | 0.5 | -0.017 | 0.945 | 0.312 | 0.141 | 0.13 | 0.72 | 0.36 |
| anchored | 0 | 2 | 0.5 | 0.219 | 0.948 | 0.255 | 0.240 | 0.16 | 0.62 | 0.40 |
| anchored | 1 | 2 | 0.5 | -0.048 | 0.948 | 0.335 | 0.114 | 0.13 | 0.61 | 0.32 |

