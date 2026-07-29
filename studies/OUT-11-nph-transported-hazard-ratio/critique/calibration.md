# Calibration measured before the design was fixed

Two things a simulation of non-proportional hazards can get wrong before it starts: pick a
violation so large that no method could miss it, and pick a network so expensive that the
replicate count cannot resolve anything. Both were measured rather than assumed.

## The exact truth agrees with brute force

`verify_truth()` compares the Gauss-Hermite and Gauss-Legendre truth against 4,000,000 simulated
draws. Absolute disagreement: RMST 0.0019 and 0.0025, milestone survival 0.00021 and 0.00021.
The simulation's own Monte Carlo error at that size is about 0.005 on RMST and 0.00025 on a
survival probability, so the quadrature agrees to the precision of the check. The check runs at
analysis time, not once by hand.

## How much non-proportionality is realistic

The treatment acts on the Weibull shape through $\phi$. At $\phi = 0$ the conditional model is
exactly proportional hazards. The question is which values of $\phi$ a competent analyst would
plausibly fail to detect, because those are the only interesting ones: if a standard test catches
the violation, the analyst does not report a constant hazard ratio and the problem does not
arise.

Measured over 200 replicates at 200 per arm, with a Grambsch-Therneau test on the treatment
coefficient at the 0.05 level:

| $\phi$ | true marginal HR swing | true RMST diff | true $\Delta S(12)$ | hazards cross at | PH test rejects | fitted Cox HR |
|---:|---:|---:|---:|---:|---:|---:|
| −0.45 | 6.65 | −1.699 | −0.085 | 7.5 | 0.92 | 1.23 |
| −0.25 | 3.17 | −1.114 | −0.058 | 9.2 | 0.47 | 1.15 |
| −0.12 | 1.81 | −0.726 | −0.038 | 12.2 | 0.17 | 1.11 |
| **0** | **1.01** | −0.367 | −0.018 | never | **0.04** | 1.07 |
| +0.12 | 1.91 | −0.012 | +0.003 | 5.5 | 0.12 | 1.04 |
| +0.25 | 4.22 | +0.367 | +0.027 | 7.2 | 0.45 | 1.00 |
| +0.45 | 17.47 | +0.926 | +0.067 | 8.5 | 0.91 | 0.98 |

Three things follow, and they fix the design.

**The $\phi = 0$ row is a working negative control.** The test rejects at 0.04 against a nominal
0.05, so the proportional-hazards cell really is proportional and any advantage the PH methods
show there is theirs to keep.

**$|\phi| \geq 0.45$ is a stress test, not a scenario.** A 17-fold swing in the marginal hazard
ratio is not a plausible oncology trial, and the test catches it 91% of the time. Running only
that level would produce a result about arithmetic. It is retained, labelled as a stress test,
and excluded from the deployment mixture.

**The interesting region is $|\phi| \leq 0.25$**, where the test rejects between 12% and 47% of
the time, which is to say an analyst misses the violation more often than not.

**The row that carries the paper is $\phi = +0.25$.** The fitted constant Cox hazard ratio is
**1.00**, which reads as "no difference between the treatments", while the true target RMST
difference is **+0.367 months in B's favour** and the true marginal hazard ratio ranges from 0.41
to 1.35 across follow-up. A standard proportional-hazards test would flag that fewer than half
the times it was run.

## The marginal hazard ratio moves even under proportional hazards

At $\phi = 0$ the conditional model is a proportional-hazards model and the conditional hazard
ratio is constant by construction. The **marginal** hazard ratio in the target population still
drifts, from 1.05 to 1.06 across follow-up. The drift is small here, and it should be, but it is
not zero, and it is exactly the risk-set selection the auditors described when they corrected the
catalog entry's framing. It is measured rather than asserted.

## What one fit costs

Flexible survival ML-NMR, mspline likelihood, `aux_by = c(.study, .trt)`, 2 chains of 1,000
iterations, all converged with maximum $\hat R \leq 1.008:

| network | rows | integration points | knots | seconds |
|---|---:|---:|---:|---:|
| 250 IPD/arm, 200/arm $\times$ 5 aggregate | 2,500 | 32 | 3 | 327 |
| 200 IPD/arm, 150/arm $\times$ 3 aggregate | 1,300 | 32 | 3 | 118 |
| 200 IPD/arm, 150/arm $\times$ 3 aggregate | 1,300 | 16 | 3 | 76 |

Cost is close to linear in rows and in integration points. The replicate count follows from this
rather than the other way round: two Stan fits per replicate, three workers, so a design of eight
cells at forty replicates costs about seven hours at 32 integration points and about four and a
half at 16.

Study 5 found that moving from 64 to 256 integration points flipped 8.3% of its verdicts, and
concluded that under-integrating is a real and under-reported error source. Dropping to 16 points
here to buy replicates would repeat in this study the mistake that study reported. The main run
therefore uses 32 points and pays the time, with an integration-sensitivity arm at 64 points on a
prespecified subset.
