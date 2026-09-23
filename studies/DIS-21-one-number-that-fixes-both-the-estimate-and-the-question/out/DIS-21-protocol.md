# Protocol: the admission threshold of a matched bridge, in units of the within-trial distance

**Target problem.** DIS-21. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

When arms of trials in two disconnected subnetworks are matched on reported covariate means to manufacture
an edge, the admission threshold sets both the bridged contrast's bias and whether the comparison exists.
**Refuting sentence:** bias in the bridged contrast is flat over the range of thresholds anyone would use,
so the cutoff matters only through the comparison set.

## 2. Design

Subnetwork 1: six trials of A versus C; subnetwork 2: six trials of B versus D; 150 patients per arm. Trial
populations have three covariate means drawn from $N(0, 0.3^2)$ (subnetwork 1) or $N(s, 0.3^2)$ (subnetwork 2),
$s \in \{0, 0.5\}$ (good, poor overlap across the gap); arm means add sampling error. Arm outcome means:
a study-level baseline $\alpha_t \sim N(0, \tau^2)$, $\tau \in \{0, 0.1\}$, plus $0.5\bar x_1 + 0.3\bar x_2 + 0.1\bar x_3$,
plus the treatment effect (A $-0.3$, B $-0.1$, C and D 0), plus sampling error. Every cross-gap (C arm, D arm)
pair whose root-mean-square covariate-mean distance is at most $\theta$ is admitted as a pseudo-trial; the
index uses all three covariates or omits the most prognostic. Admitted pairs, A-C trials and B-D trials are
pooled by fixed effect and A versus B is formed through the bridge. $\theta$ is expressed as a multiple (1, 2,
3, 5, 7, 10, 15, 20) of the median distance between the two arms of one trial. 8 cells, **2000 replicates**,
all thresholds on the same data.

## 3. Decision

The bridged A-versus-B contrast (truth $-0.2$). Per cell and threshold: probability the network is
connected, number of admitted pairs, bias and RMSE given connection, coverage of the naive fixed-effect
interval, and sign reversal. **Refuting sentence holds** if, in every poor-overlap cell, the bias varies by
less than 0.02 across the thresholds at which the network is connected in at least 20% of replicates;
otherwise it fails.

## 4. Departures from DESIGN.md

Monte Carlo networks only, no real-network deletions; one distance (root mean square of standardized mean
differences) with two covariate sets and no alternative normalization; no component network meta-analysis
bridge; the reference is the known truth rather than a retained full-network estimate; admitted pairs
that reuse an arm are pooled as if independent, as in practice.
