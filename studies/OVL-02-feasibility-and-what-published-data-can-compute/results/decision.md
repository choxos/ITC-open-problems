# Decision

**Refuting sentence (ESS conventions catch infeasibility): FAILS.**

| detector | AUROC for infeasibility | flags infeasible | flags feasible |
|---|---:|---:|---:|
| ESS (low) | 0.996 | 1.000 | 0.730 |
| max weight | 0.993 |  |  |
| residual imbalance | 1.000 | 0.999 | 0.001 |
| optimizer non-convergence | 0.909 | 0.826 | 0.008 |

ESS flags use ESS below 10% of n; residual flags use residual above 1e-3; optimizer flags use a nonzero convergence code.

Infeasible replicates the optimizer reported as converged: 17.4%.

Easy-shift control (all feasible, residual below 1e-4): TRUE.

