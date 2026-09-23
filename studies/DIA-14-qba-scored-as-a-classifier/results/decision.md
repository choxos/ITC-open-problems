# Decision

Exact checks: grid false reassurance with the truth inside the region, 0 replicates (must be 0); at q = 0, 0 (must be 0).

**Primary (q = 0.1, width 0.15, cells with bias):** P(robust | decision flips at true bias), grid 0.008/0.020; probabilistic 0.000/0.000. P(fragile | no flip), grid 0.333/0.279; probabilistic 0.710/0.748 (directions symmetric/understated).

Probabilistic QBA dominates the grid on both rates in some setting: FALSE.

**Refuting sentence (oracle recovery plus a width rule is adequate): FAILS.** Oracle coverage 0.951 to 0.961; grid false reassurance under a zero-anchored region 0.776, 0.370, 0.092 by width 0.05, 0.15, 0.3.

| direction | q | width | excluded | flip | FR grid | FF grid | FR prob | FF prob | QBA MC disagreement |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| symmetric | 0.0 | 0.05 | 0.000 | 0.325 | 0.000 | 0.106 | 0.000 | 0.679 | 0.013 |
| symmetric | 0.0 | 0.15 | 0.000 | 0.325 | 0.000 | 0.329 | 0.000 | 0.733 | 0.011 |
| symmetric | 0.0 | 0.30 | 0.000 | 0.325 | 0.000 | 0.678 | 0.000 | 0.854 | 0.011 |
| symmetric | 0.1 | 0.05 | 0.103 | 0.325 | 0.003 | 0.108 | 0.000 | 0.674 | 0.012 |
| symmetric | 0.1 | 0.15 | 0.101 | 0.325 | 0.008 | 0.333 | 0.000 | 0.710 | 0.013 |
| symmetric | 0.1 | 0.30 | 0.102 | 0.325 | 0.018 | 0.610 | 0.002 | 0.769 | 0.010 |
| symmetric | 0.3 | 0.05 | 0.305 | 0.325 | 0.017 | 0.119 | 0.000 | 0.674 | 0.013 |
| symmetric | 0.3 | 0.15 | 0.300 | 0.325 | 0.048 | 0.352 | 0.003 | 0.672 | 0.011 |
| symmetric | 0.3 | 0.30 | 0.298 | 0.325 | 0.084 | 0.578 | 0.041 | 0.704 | 0.009 |
| understated | 0.0 | 0.05 | 0.000 | 0.325 | 0.000 | 0.106 | 0.000 | 0.679 | 0.013 |
| understated | 0.0 | 0.15 | 0.000 | 0.325 | 0.000 | 0.329 | 0.000 | 0.733 | 0.013 |
| understated | 0.0 | 0.30 | 0.000 | 0.325 | 0.000 | 0.678 | 0.000 | 0.854 | 0.011 |
| understated | 0.1 | 0.05 | 0.100 | 0.325 | 0.006 | 0.057 | 0.000 | 0.692 | 0.012 |
| understated | 0.1 | 0.15 | 0.098 | 0.325 | 0.020 | 0.279 | 0.000 | 0.748 | 0.015 |
| understated | 0.1 | 0.30 | 0.102 | 0.325 | 0.038 | 0.646 | 0.008 | 0.833 | 0.011 |
| understated | 0.3 | 0.05 | 0.299 | 0.325 | 0.040 | 0.048 | 0.000 | 0.696 | 0.013 |
| understated | 0.3 | 0.15 | 0.303 | 0.325 | 0.102 | 0.283 | 0.006 | 0.727 | 0.014 |
| understated | 0.3 | 0.30 | 0.296 | 0.325 | 0.167 | 0.602 | 0.081 | 0.762 | 0.013 |
| zero | - | 0.05 | 1.000 | 0.325 | 0.776 | 0.098 | 0.094 | 0.620 | 0.016 |
| zero | - | 0.15 | 0.750 | 0.325 | 0.370 | 0.288 | 0.056 | 0.667 | 0.015 |
| zero | - | 0.30 | 0.250 | 0.325 | 0.092 | 0.618 | 0.000 | 0.790 | 0.013 |

