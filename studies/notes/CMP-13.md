**Study `studies/CMP-13-within-between-interaction`, run and decided against a rule registered
before the run.** 320 scenarios, 2000 replicates each, split before the run into a primary
regime of 256 scenarios where every component carries within-trial information and 64 where one
component carries none. The split is on a factor level fixed in advance, not on an observed
outcome.

**Conclusion: material at mild discordance.** Coverage of the shared model degrades with
discordance while the alternatives hold nominal throughout:

| discordance | shared | joint split | IPD anchored |
|---|---|---|---|
| rho = 1 | 0.939 to 0.958 | 0.938 to 0.960 | 0.938 to 0.959 |
| rho = 0 | 0.655 to 0.963 | 0.936 to 0.960 | 0.939 to 0.961 |
| rho = -1 | **0.172 to 0.960** | 0.926 to 0.960 | 0.931 to 0.963 |

The worst cell reaches **0.172** coverage. Note also that the cluster-robust comparator fails
its own negative controls in **128 of 128** control scenarios (coverage 0.754 to 0.924), so it
is reported but cannot serve as the status quo.

**The catalog's mechanism claim is not supported, and this is the useful part.** This entry
attributes the pull to aggregate studies. The study tested that directly by giving **all twelve
trials individual data**: across 80 discordant scenario-components with complete individual
data, the shared model still shows median absolute standardized bias 0.15, maximum **2.03**,
with 0.47 of them above 0.20 and coverage as low as 0.447. The registered support threshold
(bias below 0.10 everywhere) fails; the registered refutation threshold (more than half above
0.20) is not quite met. So the claim is recorded as not supported, and the direction of the
evidence is that **the conflation is a property of the parameterization, not of the data
type** — which relocates the problem this entry describes.
