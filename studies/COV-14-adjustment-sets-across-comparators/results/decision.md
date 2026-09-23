# Decision

**Registered rule (protocol.md section 3): MAXIMAL VINDICATED.**

| strength | P(top wrong), maximal | P(top wrong), intersection | difference (MCSE) | mean abs bias, maximal | intersection |
|---:|---:|---:|---:|---:|---:|
| 0.10 | 0.199 | 0.324 | 0.125 (0.013) | 0.029 | 0.119 |
| 0.25 | 0.073 | 0.416 | 0.343 (0.015) | 0.074 | 0.300 |
| 0.50 | 0.006 | 0.373 | 0.367 (0.015) | 0.151 | 0.584 |

Similar populations: intersection lower on top-rank error in 8 of 18 cells. Dispersed: 7 of 18.

Diagnostic max_k |maximal - intersection| against a wrong top rank under the maximal set: AUROC 0.567 (fit for purpose if >= 0.75).

Bounded interval: coverage 0.678 to 1.000, width ratio to the maximal interval 1.00 to 1.08 (median).

Controls: complete reporting TRUE; zero strength TRUE; simulation within 3 MCSE of exact bias in 98.6% of contrasts.

