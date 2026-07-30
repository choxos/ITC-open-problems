# CMP-11 design: pooling contrasts that live in different populations

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

`cpaic` already labels its two-stage output "only partially target-adjusted",
which is honest and, as the catalog says, does not remove the mixture. Section 2
gives the mixture a formula and finds **two** bias terms with different null
conditions, which is what the design is built around.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** in two-stage component MAIC and STC only IPD edges
are reweighted to the target, so under effect modification the pooled component
parameters combine contrasts with different population referents; component STC
additionally mixes target-profile conditional coefficients with usually marginal
published aggregate contrasts; and one-stage component ML-NMR would remove both
but does not exist.

**Refuting sentence:** *at realistic population separations the mixture is small
relative to the extra estimation error a one-stage integrated likelihood incurs,
so the two-stage route with its label is the better practical choice.*

## 2. The mechanism: two terms, two nulls

A component parameter is estimated by pooling edge contrasts. Under linear
modification, edge $e$'s contrast in population $F$ is $\Delta_e(F) = \delta_e +
\beta_{EM}^\top \bar x_F$. A two-stage fit transports the IPD edges to the target
and leaves the rest in their own study populations, so

$$\hat\beta_c \;=\; \sum_{e \in \mathcal{I}} w_e\big\{\delta_e + \beta_{EM}^\top \bar x_T\big\} \;+\; \sum_{e \notin \mathcal{I}} w_e\big\{\delta_e + \beta_{EM}^\top \bar x_{S_e}\big\}$$

against a target-referent truth using $\bar x_T$ throughout. **Term one:**

$$b_1 \;=\; \beta_{EM}^\top \sum_{e \notin \mathcal{I}} w_e\,\big(\bar x_{S_e} - \bar x_T\big),$$

a product of effect-modification strength and the weighted population separation
of the **un-transported** edges. It is exactly zero when either factor is zero,
which is the catalog's "the incompatibility disappears when the relevant effects
are transportable" written down. **Its three factors are exactly the three the
design sketch names**, and it does not shrink with sample size.

**Term two, and it is separate.** Component STC produces a **conditional**
coefficient at the target covariate profile and pools it with published aggregate
contrasts that are **marginal**. On a non-collapsible scale those differ by the
collapsibility gap even when $\bar x_{S_e} = \bar x_T$ exactly:

$$b_2 \;=\; \sum_{e \notin \mathcal{I}} w_e\big\{\Delta_e^{\text{cond}}(\bar x_T) - \Delta_e^{\text{marg}}(F_{S_e})\big\},$$

which is **nonzero at zero population separation** and **zero on a collapsible
scale**. So the two terms have orthogonal null conditions, and section 8 switches
each off independently. A design that could not separate them would report "the
two-stage route is biased" without saying which repair is needed, and the repairs
are different: transporting the aggregate edges fixes $b_1$; marginalizing the
STC coefficient fixes $b_2$.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment contrast for a regimen the
component structure implies, computed by quadrature over the declared target law
at an order fixed by P1.

**The pooled component parameter is the second estimand**, with its true value
defined **at the target referent**. Naming that referent is the point: the
catalog's complaint is that the two-stage estimate has no single one, so a study
that leaves the truth's referent implicit would be unable to state what is being
biased.

## 4. Data-generating mechanism, and what it makes invisible

Component networks with a mix of IPD and aggregate edges, two subnetworks and a
shared component so a cross-gap contrast exists.

### Factors

| factor | levels | why |
|---|---|---|
| proportion of IPD edges | 1/4, 1/2, 3/4 | the weight on the un-transported sum in $b_1$ |
| population separation of aggregate edges | 0, moderate, large | the other factor in $b_1$; **0 is $b_1$'s null and $b_2$'s positive control** |
| effect-modification strength | 0, moderate, strong | $b_1$'s other null |
| scale | risk difference (collapsible); log OR | **$b_2$'s null and its positive control** |
| accuracy of reconstructed aggregate covariate distributions | exact; moderately wrong; badly wrong | what the imputation route would have to survive |
| network size | 8, 16 edges | how much the un-transported edges dominate the pool |

### What the mechanism makes true, and therefore what the study cannot see

- The component structure is correctly specified and additive. CMP-03 owns
  whether additivity is clinically false and CMP-06 owns miscoding; both would
  confound the population-referent question with an identification one.
- Aggregate edges' covariate distributions are known to the simulation, which is
  what makes the imputation arm scorable. **In practice they are typically
  reported only as marginal summaries or not at all**, and that is the reason the
  two-stage route has nothing to transport them with; the imputation arm's
  results are therefore optimistic and the paper must say so.
- One target population per replicate, declared. EST-11 owns the menu.
- No random treatment-effect heterogeneity, so pooling weights are inverse
  variance only.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| two-stage cMAIC | IPD edges reweighted, aggregate edges as published | the status quo |
| two-stage cSTC | IPD edges re-fitted at target profile, aggregate edges as published | the status quo, carrying $b_2$ as well |
| **two-stage cSTC, marginalized** | STC coefficients standardized to marginal before pooling | removes $b_2$ only, isolating it |
| **two-stage + imputed aggregate distributions** | multiple imputation of the aggregate covariate laws, all edges transported, uncertainty propagated | removes $b_1$ only |
| **one-stage component ML-NMR** | the integrated likelihood, built for this study | the coherent alternative the catalog says does not exist |
| non-component ML-NMR | where the network permits it | the reference architecture that already works |

**The comparator that can win is the two-stage route with imputation.** If it
matches one-stage ML-NMR across the grid, the coherent architecture is not needed
and the recommendation is an imputation step inside the existing workflow, which
is far cheaper to adopt. Registered as the outcome most likely to overturn the
expected headline.

**Building one-stage component ML-NMR is the largest implementation cost in this
design and it must be scoped before registering**, which is probe P3. If it
cannot be built reliably, the study runs without it and reports the comparison it
can make rather than a comparison it cannot.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of both estimands; interval width; convergence. **Bias
decomposed into $b_1$ and $b_2$** using the isolating arms, and the observed
decomposition regressed on the analytic forms in section 2, with slope 1
expected. That regression is a registered outcome: MIS-03's analogous check gave
a slope of 1.003 (SE 0.042) and is what let it separate an analytic result from a
simulation artifact.

**Which edges were transported and which were not is reported per replicate**,
because the catalog's own recommendation is that this accompany every pooled
component parameter, and a study proposing it should demonstrate it.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 1000$ per cell, Stan-limited by the one-stage arm.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the target-population marginal contrast
under two-stage cMAIC, across the (IPD proportion × population separation ×
modification strength) grid, on the log OR scale.

**Decision rule.**

- Bias tracking $b_1$'s analytic form, absent at either null, and removed by the
  imputation arm: the mechanism is established and the deliverable is the
  imputation recommendation plus the transported-edge reporting requirement.
- Bias present at zero effect modification or zero separation: section 2 is wrong
  and the study reports that rather than keeping the recommendation.
- One-stage component ML-NMR beating imputation materially: the architecture
  matters and building it is the recommendation, with its cost stated.

**$b_2$ is decided separately and is a cleaner test:** on the log OR scale at
**zero** population separation, unmarginalized cSTC must be biased and the
marginalized arm must not. That is a two-cell comparison with an exact null and
it does not depend on the primary outcome at all.

## 8. Three controls, each of which can fail

**Null control.** Zero effect modification: $b_1 = 0$ exactly, and on a
collapsible scale $b_2 = 0$ too. Every method must be unbiased. This is the
catalog's own stated condition for the incompatibility to disappear and it is
checked rather than assumed.

**Second null control.** All edges IPD: nothing is un-transported, so both sums
are empty and two-stage must equal one-stage to Monte Carlo error. **Cheap, exact,
and it catches the class of implementation error where the "transported" flag is
not doing what it says.**

**Positive control.** Quarter IPD edges, large separation, strong modification,
log OR: two-stage cMAIC must be biased by at least three MCSEs. If not, the
mixture is immaterial at reachable magnitudes and that is the answer.

**Falsifier for the study's own headline.** The expected headline is that the
one-stage architecture is needed. Its falsifier is the imputation arm succeeding,
which would make it unnecessary. It is included for that reason. **A second
falsifier is built into the imputation arm's own accuracy factor**: if imputation
only works when the reconstructed distributions are near-exact, then it works
only where the problem does not arise, and the "badly wrong" level is what shows
that.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Two bias terms reported as one | Isolating arms with orthogonal nulls; decomposition is a registered outcome | removed |
| Truth's population referent left implicit | Declared for both estimands | removed |
| Imputation scored under conditions it would never meet | Reconstruction accuracy is a registered factor with a "badly wrong" level | removed |
| One-stage arm built by me and possibly favored | P3 scopes it; the two-stage arms use the existing package; disagreement between my one-stage arm and non-component `multinma` on networks where both apply is a stop condition | removed |
| Additivity and miscoding confounded with the referent question | Both held correct; owners named | removed |
| Aggregate covariate laws known, which they are not in practice | Stated as making the imputation arm optimistic | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and quadrature order | Target-referent truths for both estimands; the analytic $b_1$ and $b_2$ per cell | The grid; cells where either term is below Monte Carlo resolution are dropped | hours |
| **P2** collapsibility gap size | Whether $b_2$ is detectable at the chosen event rates and covariate spreads | Whether the $b_2$ half of the study exists | hours |
| **P3** one-stage feasibility | Whether a component ML-NMR integrated likelihood can be implemented and validated against non-component `multinma` on networks where both apply | **The study's most expensive arm.** An unvalidated one-stage implementation is not a comparator, it is a confound | days |
| **P4** unit cost | Per-fit wall clock; total computed not typed | $n_{sim}$ and the grid | hours |

## 11. Cost

Dominated by the one-stage arm, which must first be built and validated. Unpriced
until P3 and P4; no total quoted.

---

## Relationship to the rest of the queue

- **CMP-13** established the within/across conflation in component ML-NMR, a
  different defect in the same architecture.
- **CMP-15** owns the target joint covariate distribution being approximately
  known, which is what the imputation arm has to reconstruct.
- **CMP-16** owns `cpaic` sharing one tau and one IPD-row residual variance.
- **MOD-01** owns the conditional-versus-marginal mismatch in STC generally,
  which is $b_2$ in a two-trial setting; its standardization machinery is
  imported for the marginalized arm rather than rebuilt.
- **MIS-04** owns model and bridge selection uncertainty entering the interval.
