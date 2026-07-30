# DEC-17 design: the sensitivity question needs no new theory and settles the rest

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note says do not run this first for PAIC, **because the contribution quantity itself
needs definition before uncertainty around it is interpretable.** That is right, and it is
why this design's primary is a sensitivity computation on **existing** measures rather than
an interval for a quantity nobody has defined for population-adjusted contrasts.

**The omission is stated by the original derivation's own authors.** Deriving percentage
study weights, they record that the derivation **ignores uncertainty in variance parameter
estimates**, assumes the information matrix for the mean parameters is **independent** of
that for the residual and between-study variances, and holds variance components **fixed at
their full-model values** when the per-study information matrices are formed, adding that
**further consideration of the issue is needed.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** every measure used to attribute a network estimate to its
sources is computed with the between-study variance and residual variances fixed at their
point estimates, so **the reported provenance of a contrast is a conditional quantity whose
own uncertainty is neither propagated nor reported**, and nothing is known about how far
attributed shares move across the plausible range of $\tau$.

**Refuting sentence:** *contribution shares are stable over the plausible $\tau$ range, so
conditioning on a point estimate is harmless and the omission is technical.*

## 2. The mechanism: a nonlinear function of a badly determined variance

Contribution measures are functions of the weight matrix $W(\tau) = (V + \tau^2 I)^{-1}$.
Three consequences:

1. **$W$ depends on $\tau$ nonlinearly and non-monotonically in its effect on shares.** As
   $\tau$ grows, weights flatten toward equality, so **studies with small within-study
   variance lose share and large ones gain.** **The direction of movement therefore differs
   by study**, which is why a single sensitivity number cannot summarize it and why the
   identity of the top contributor can change rather than merely its share.
2. **$\tau$ is badly determined in exactly the networks contribution tables are read for.**
   Its distribution is skewed with few studies, **so a delta-method interval would be
   deployed where the delta method is least trustworthy.** That is why the entry's own
   proposal starts with a range rather than an interval.
3. **There are three candidate target quantities and they license different statements**:
   the contribution at $\hat\tau$, its posterior distribution, or its range over a plausible
   $\tau$ interval. **The design computes all three and reports which statements each
   supports**, because choosing one silently is how the current convention arose.

**The Bayesian case has no hat matrix**, so flow-based machinery **cannot simply be
evaluated draw by draw without first being redefined.** That redefinition is the piece the
note says must come before uncertainty, and **this design specifies it as a draw-specific
weight matrix** — which, if it works, delivers a posterior for the contribution directly and
**gives the component-network measures an interval at the same time.**

## 3. Estimand, with its true value defined

**Primary.** The **movement of contribution shares across the plausible $\tau$ range**, and
**the frequency with which the leading contributor changes.**

**True values are available because the design generates $\tau$**: contributions at the true
$\tau$ are computable exactly, so the point-estimate version's error is measurable rather
than merely its instability.

**The three candidate quantities of consequence 3 are computed for every network**, so their
disagreement is a reported result rather than a choice.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| true heterogeneity $\tau$ | 0, small, large | the axis |
| **study count** | 4, 8, 16 | how badly $\tau$ is determined; consequence 2 |
| within-study variance spread | equal; 5:1 | **consequence 1's differential movement**, which needs unequal within-study variances to exist |
| heterogeneity-prior informativeness | vague; weakly informative; empirically derived | what drives the posterior when the data do not |
| network structure | star; loop-rich | how much borrowing there is to attribute |

**Study count crossed with within-study variance spread is the design**, because together
they determine whether shares can move and whether $\tau$ is determined well enough to
pin them.

### What the mechanism makes true, and therefore what the study cannot see

- **The contribution quantity for a population-adjusted target-specific contrast is not
  defined**, per the note, and **this design does not define it.** It works on the existing
  measures for network contrasts and states that the PAIC extension is CMP-24's and OVL-02's
  territory.
- Contributions are read as **descriptive summaries rather than estimates**, which the entry
  says is why nobody attached uncertainty to them. **The design reports both the descriptive
  range and the inferential interval and says which is which.**
- A nonparametric bootstrap must refit the network and re-estimate $\tau$ per replicate;
  **that cost is measured rather than assumed prohibitive**, since the entry lists it as an
  obstacle.
- One outcome family.

## 5. Methods, including one that can win

| method | role |
|---|---|
| contribution at $\hat\tau$ | current practice |
| **contribution over the $\tau$ confidence or credible interval** | the entry's first proposal, needing no new theory |
| **information-matrix decomposition including the variance block** | the entry's inferential proposal, dropping the independence assumption |
| parametric bootstrap re-estimating $\tau$ | the benchmark for the above |
| **draw-specific weight matrix in the Bayesian fit** | the redefinition that gives a posterior directly |

**The comparator that can win is the contribution at $\hat\tau$.** If shares move little
over the plausible range and the leading contributor is stable, **the refuting sentence
holds** and the convention is defensible. **Registered as such**, and it is the cheapest
outcome.

## 6. Performance measures, MCSE, and $n_{sim}$

**Share movement** across the $\tau$ range, per study and per comparison; **frequency of a
change in the leading contributor**; **error of the point-estimate contribution against the
true-$\tau$ contribution**, which is available because $\tau$ is generated.

**Interval performance** for the two inferential routes, benchmarked against the parametric
bootstrap, with coverage of the true-$\tau$ contribution.

**Agreement among the three candidate quantities** of consequence 3, since their divergence
is what makes the choice consequential.

$n_{sim} = 1000$ networks per cell; the bootstrap arm's replicate count is set by P3.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Frequency with which the leading contributing comparison changes across
the $\tau$ interval, at 4 studies with a 5:1 within-study variance spread.

**Decision rule.**

- Leading contributor changing in a substantial fraction of networks: **confirmed**, and the
  deliverable is that contribution tables used in certainty assessment must carry an interval
  **or an explicit statement that they are conditional on a single heterogeneity estimate,
  in the same way effect estimates are required to carry one.**
- Leading contributor stable: **refuted**, and the convention is defensible, which is a
  useful and cheap result.
- **The three-quantity disagreement is reported in either branch**, because it determines
  what a committee may say and does not depend on the stability result.

## 8. Three controls, each of which can fail

**Null control.** With $\tau = 0$ known and fixed, contributions are exact and every method
must agree. **A disagreement there is implementation.**

**Second null control.** With equal within-study variances, consequence 1's differential
movement is absent: shares are determined by design alone and must be **invariant to
$\tau$.** **That isolates the mechanism** and shows that unequal precision, not heterogeneity
alone, is what makes shares move.

**Positive control.** Four studies with a 5:1 variance spread and large true $\tau$: shares
must move materially across the $\tau$ interval. **If they do not, the sensitivity is
unreachable and the convention is safe by construction.**

**Falsifier for the study's own headline.** The expected headline is that provenance needs
an interval. Its falsifier is consequence 3: **if the three candidate quantities agree, then
the choice among them is immaterial and reporting any one of them with a range suffices**,
which is a smaller and simpler recommendation than an inferential framework.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Defining a PAIC contribution quantity before the field has | Not attempted; existing network measures used; owners named | removed |
| A delta-method interval where the delta method is least trustworthy | Benchmarked against a parametric bootstrap that re-estimates $\tau$ | removed |
| One target quantity chosen silently | All three computed and their agreement reported | removed |
| Bootstrap cost assumed prohibitive | Measured in P3 | removed |
| Descriptive and inferential outputs conflated | Both reported and labeled | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** analytic movement | Share movement across $\tau$ analytically, from $W(\tau)$, before any simulation | **The primary outcome's prediction**, and it is nearly free | hours |
| **P2** draw-specific redefinition | Whether a Bayesian draw-specific weight matrix reproduces the frequentist contribution at $\hat\tau$ | **Whether the redefinition is sound** before it is used | days |
| **P3** bootstrap cost | Refit-and-re-estimate cost per replicate | Whether the benchmark is affordable | days |
| **P4** unit cost | Total, computed not typed | $n_{sim}$ | hours |

**P1 can be done on published networks immediately**, and the entry says so: recompute the
contribution matrix, percentage study weights and borrowing-of-strength across the $\tau$
interval in a set of published networks and report how often the top contributor changes.
**That is a result before any simulation runs.**

## 11. Cost

Frequentist network fits are cheap; the bootstrap and the Bayesian draw-specific arm
dominate. Modest overall.

---

## Relationship to the rest of the queue

- **MOD-18** finds the same defect in a different output: a quantity computed at a point
  estimate of a nuisance parameter and reported as carrying no uncertainty. **The two should
  be read together.**
- **CMP-24** owns edge influence and its multi-arm approximation; **its rankings inherit this
  conditioning** and the two share the weight-matrix machinery.
- **CMP-16**, **HET-03** and **HET-10** own the heterogeneity parameter whose uncertainty this
  design propagates.
- **OVL-02** owns the diagnostic battery a contribution table would join.
