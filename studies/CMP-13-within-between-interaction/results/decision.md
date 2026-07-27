# Decision

**Conclusion: material at mild discordance**

**Catalog mechanism claim: not supported, and short of the prespecified refutation threshold**

Prespecified in `protocol.md` section 7. 320 scenarios, 2000 replicates each, split into a primary regime of 256 scenarios in which every component has within-trial information, and 64 scenarios in which one component has none. The split is on a factor level fixed before the run, not on an observed outcome.

## Gates, primary regime

| gate | pass |
| --- | --- |
| convergence | yes |
| denominators | yes |
| shared_controls | yes |
| split_controls | yes |
| anchored_controls | yes |

The cluster-robust comparator fails its own negative controls in 128 of 128 control scenarios (coverage 0.754 to 0.924), so it is reported but not used as the status quo.

## Coverage by discordance, primary regime

| discordance | shared | shared + cluster sandwich | joint split | IPD anchored |
| --- | --- | --- | --- | --- |
| rho1 | 0.939 to 0.958 | 0.754 to 0.924 | 0.938 to 0.960 | 0.938 to 0.959 |
| rho0.5 | 0.882 to 0.959 | 0.767 to 0.918 | 0.938 to 0.961 | 0.938 to 0.962 |
| rho0 | 0.655 to 0.963 | 0.583 to 0.925 | 0.936 to 0.960 | 0.939 to 0.961 |
| rho-0.5 | 0.386 to 0.956 | 0.415 to 0.917 | 0.937 to 0.960 | 0.936 to 0.960 |
| rho-1 | 0.172 to 0.960 | 0.271 to 0.921 | 0.926 to 0.960 | 0.931 to 0.963 |
| null | 0.941 to 0.962 | 0.761 to 0.923 | 0.939 to 0.962 | 0.938 to 0.962 |
| between-only | 0.677 to 0.960 | 0.592 to 0.929 | 0.941 to 0.963 | 0.941 to 0.963 |
| nonlinear | 0.649 to 0.956 | 0.581 to 0.924 | 0.944 to 0.962 | 0.943 to 0.963 |

## The mechanism test: all 12 trials supply individual data

CMP-13 says aggregate studies cause the pull. Across 80 discordant scenario-components with complete individual data, absolute standardized bias of the shared model has median 0.15 and maximum 2.03, 0.47 of them exceed 0.20, and coverage falls as low as 0.447.

The prespecified support threshold required absolute standardized bias below 0.10 everywhere, which fails. The prespecified refutation threshold required more than half above 0.20, which is not quite met. The claim is therefore not supported, and the direction of the evidence is that the conflation is a property of the parameterization rather than of the data type.

## A component with no within-trial information

The IPD-anchored method declined to report that component in 1.00 of replicates. The shared and joint models are near-unidentified there: they fail to return an interval on 0.111 of replicates against 0.000 elsewhere.

In the `between-only` pattern the true within-trial interaction for that component is 0. The shared model reported a mean of -0.340 with coverage 0.905; the joint split reported -0.185 with coverage 0.999, its intervals so wide that coverage approaches one.

## Ten worst shared-model coverages, primary regime

| network | pattern | ipd | n | spread | par | coverage | MCSE | split | anchored |
| --- | --- | --- | ---: | --- | --- | ---: | ---: | ---: | ---: |
| bundled | rho-1 | four | 400 | wide | gWA | 0.172 | 0.008 | 0.948 | 0.946 |
| bundled | rho-1 | four-low | 400 | wide | gWA | 0.182 | 0.009 | 0.951 | 0.949 |
| bundled | rho-1 | six | 400 | wide | gWA | 0.337 | 0.011 | 0.952 | 0.948 |
| bundled | rho-0.5 | four | 400 | wide | gWA | 0.386 | 0.011 | 0.952 | 0.949 |
| bundled | rho-0.5 | four-low | 400 | wide | gWA | 0.421 | 0.011 | 0.952 | 0.950 |
| bundled | rho-1 | all | 400 | wide | gWA | 0.447 | 0.011 | 0.955 | 0.953 |
| bundled | rho-0.5 | six | 400 | wide | gWA | 0.538 | 0.011 | 0.950 | 0.950 |
| isolating | rho-1 | four | 400 | wide | gWA | 0.572 | 0.011 | 0.940 | 0.941 |
| isolating | rho-1 | four-low | 400 | wide | gWA | 0.642 | 0.011 | 0.944 | 0.944 |
| bundled | nonlinear | four | 400 | wide | gWA | 0.649 | 0.011 | 0.947 | 0.947 |
