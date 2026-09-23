# Decision

**Registered rule (protocol.md section 6): CONFIRMED.**

Primary cells: 12. MAIC means biased beyond 0.05 (95% MC interval) in 9; in each of those a variance-balancing arm is under 0.05: TRUE.

Mean over primary cells (bias as mean absolute bias):

| method | mean abs bias | mean RMSE | mean coverage | mean ESS |
|---|---:|---:|---:|---:|
| gcomp | 0.0048 | 0.1801 | 0.949 | NaN |
| maic_index | 0.0127 | 0.2940 | 0.938 | 522 |
| maic_means | 0.0836 | 0.2500 | 0.924 | 693 |
| maic_meanvar | 0.0139 | 0.3330 | 0.936 | 361 |
| unadjusted | 0.0833 | 0.2131 | 0.925 | 1000 |

Mechanism check: unadjusted anchored bias on exact population bias, slope 0.981 (SE 0.018), over 27 cells.

Design's claim (ratio 1, shift > 0): observed unadjusted bias 0.0088, 0.0072, 0.0124, 0.0084, 0.0109, 0.0134 against exact 0.0035, 0.0121, 0.0121, 0.0065, 0.0182, 0.0069.

Controls: null TRUE; positive TRUE.

