**Study `studies/CMU-02-prior-driven-posteriors`, run and decided against a rule registered
before the run.** 120 scenarios, 2000 replicates each, two contrasts; 480,000
replicate-contrasts, of which intervals missed on 56,210. Harmful scenarios: 34 of 240, and 18
of those lie outside the engineered positive controls, so the phenomenon is not only an
artifact of the controls.

**Conclusion: the diagnostics fail at the thresholds the literature suggests.** Per replicate,
pairing each warning with whether that replicate's interval actually missed:

| rule | sensitivity | false-alarm rate |
|---|---:|---:|
| contraction | 0.363 | 0.141 |
| prior-only benchmark | 0.209 | 0.128 |
| power-scaling | 0.209 | 0.130 |
| tight-and-loose refit | 0.698 | 0.526 |

Excluding the engineered controls the picture is worse: contraction falls to 0.122 sensitivity,
power-scaling to 0.007. The only rule with real sensitivity, the tight-and-loose refit, fires
on more than half of all replicates.

**The statistics are not worthless, the thresholds are.** Threshold-free, contraction reaches
AUC 0.711 and prior sensitivity 0.766 (0.749 and 0.781 excluding controls). The ranking
information is there; the cutoffs in use do not exploit it.
