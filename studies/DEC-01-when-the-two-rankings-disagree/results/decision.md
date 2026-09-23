# Decision

**Primary (near threshold, poor overlap, symmetric loss): mean Spearman rho between RMSE and expected-loss rankings 0.45 (95% bootstrap interval 0.29 to 0.60) over 24 cell-threshold strata: CONFIRMED.**

RMSE-best method also loss-best in 38% of primary strata.

| near threshold | poor overlap | loss ratio | mean rho | share with the same best method |
|:--:|:--:|---:|---:|---:|
| FALSE | FALSE | 1 | 0.44 | 0.42 |
| TRUE | FALSE | 1 | 0.34 | 0.36 |
| FALSE | TRUE | 1 | 0.65 | 0.46 |
| TRUE | TRUE | 1 | 0.45 | 0.38 |
| FALSE | FALSE | 2 | 0.40 | 0.45 |
| TRUE | FALSE | 2 | 0.31 | 0.39 |
| FALSE | TRUE | 2 | 0.66 | 0.50 |
| TRUE | TRUE | 2 | 0.43 | 0.38 |
| FALSE | FALSE | 5 | 0.44 | 0.49 |
| TRUE | FALSE | 5 | 0.28 | 0.41 |
| FALSE | TRUE | 5 | 0.64 | 0.58 |
| TRUE | TRUE | 5 | 0.40 | 0.42 |

Wrong-decision probability for methods with |bias| > 0.05, by whether the bias points away from the threshold:

| near | bias away from threshold | wrong-decision probability |
|:--:|:--:|---:|
| FALSE | FALSE | 0.341 |
| FALSE | TRUE | 0.029 |
| TRUE | FALSE | 0.635 |
| TRUE | TRUE | 0.114 |

Null control (far from threshold, good overlap: shift 0, ratio 1, symmetric loss): largest wrong-decision probability 0.081.

