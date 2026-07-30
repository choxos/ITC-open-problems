# CMP-16 design: the heterogeneity parameter that decides how strong the bridge looks

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog is careful that this is **a field-level convention rather than a package
idiosyncrasy**: a common $\tau$ is the near-universal default in `netmeta` and
`multinma` too. It is also careful that the shared residual scale is narrower than
first stated, since aggregate arms use their own supplied standard errors and the
two-stage routes fit study-specific regressions.

The note calls this a useful second-wave study, less decisive than the covariance
and shared-$\Gamma$ problems. **Section 2 finds one place where it is sharper than
that**, and the design leads with it.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** one $\tau$ borrows strength across parts of a network
that may not be exchangeable, so a heterogeneous subnetwork can inflate uncertainty
in a homogeneous one and vice versa; one residual scale across IPD studies that
differ in instruments, populations and follow-up transfers weight between studies;
and structured heterogeneity immediately runs into identifiability in sparse
networks.

**Refuting sentence:** *with the study counts these networks have, a stratified
$\tau$ is so weakly identified that its posterior is its prior, so the shared
default is the better bias-variance choice even when it is wrong.*

**That refutation is strong and the design must give it a fair hearing**, which is
why the identifiability diagnostic in section 5 is a deliverable in its own right.

## 2. The mechanism: in a disconnected network, $\tau$ sets the bridge's apparent support

In a connected network a mis-specified $\tau$ mostly moves interval widths. **In a
disconnected one it does more**, and this is the sharp case.

The cross-gap contrast is identified only through the shared component, and its
posterior precision carries $\tau$ in the denominator: the component effect is
pooled across studies with weights $1/(s_i^2 + \tau^2)$, so

$$\mathrm{Var}(\hat\beta_{\text{shared}}) \;\approx\; \left(\sum_i \frac{1}{s_i^2+\tau^2}\right)^{-1},$$

and the bridged contrast inherits it directly. Three consequences:

1. **A heterogeneous subnetwork inflates the shared $\tau$, which widens the bridge
   even though the heterogeneity is elsewhere.** The bridge looks weaker than the
   evidence supporting it.
2. **A homogeneous subnetwork deflates it, and the bridge looks stronger than its
   own evidence supports.** **That direction is the dangerous one**, because it
   produces confident cross-gap contrasts, and nothing in the output says the
   confidence was borrowed from a different part of the network.
3. **The size of the effect is set by how unequal the subnetwork heterogeneities
   are and by how few studies the bridging subnetwork has**, both of which are
   computable from the network before fitting. **So a pre-fitting flag is possible**
   and is this design's cheapest deliverable.

**The residual-scale problem has the same shape one level down.** One $\sigma$
across IPD rows makes the implied weights wrong between studies with genuinely
different precision, so model-based intervals are wrong even where the mean model
is right. **Its null is equal true residual variances**, which is a separate control
from $\tau$'s.

## 3. Estimand, with its true value defined

**Primary.** The target-population cross-gap treatment contrast, by quadrature at
an order fixed by P1.

**The variance components are second estimands with known truths**, since the
design generates them: subnetwork-specific $\tau_k$ and study-specific $\sigma_i$.
**Recovery of the variance components is reported separately from the treatment
effect**, because a model can get the effect right by accident while the variance
structure it implies is wrong, and it is the variance structure that carries into
the bridge.

## 4. Data-generating mechanism, and what it makes invisible

Disconnected component network, two subnetworks joined by a shared component.

### Factors

| factor | levels | why |
|---|---|---|
| **subnetwork heterogeneity contrast** | equal $\tau$; 2:1; 5:1 | **section 2 consequences 1 and 2**; equal is the null |
| which subnetwork is heterogeneous | the bridging one; the other | consequence 2's direction depends on this and no study has separated them |
| studies per subnetwork | 3; 6; 12 | identifiability, and the refuting sentence's regime |
| residual-variance spread across IPD studies | equal; 3:1 | the $\sigma$ half, with its own null |
| number of IPD studies | 1; 3 | how much the shared $\sigma$ can bite |
| network sparsity | dense; sparse | the shrinkage regime |

### What the mechanism makes true, and therefore what the study cannot see

- **The mean model is correct throughout.** Every interval failure is a variance
  failure, which is what makes attribution possible and is also the limit: real
  networks fail both ways at once.
- Heterogeneity is Gaussian on the contrast scale. Heavy-tailed heterogeneity is
  named by the entry as a reason for robust residual distributions and is carried
  only in one arm.
- The shared component's constancy holds, so nothing here is confounded with a
  bridge-validity failure; **IDN-08 and DIS-11 own that.**
- Priors are the package defaults plus two alternatives, since the entry's own
  concern is that prior dependence returns once shrinkage is needed.

## 5. Methods, including one that can win

| method | role |
|---|---|
| shared $\tau$, shared $\sigma$ | the field-level default and the thing under test |
| stratified $\tau$ by subnetwork | the obvious fix, expected to be weakly identified |
| **hierarchically shrunk $\tau$ across strata** | the fix that survives sparsity |
| study-specific $\sigma$, hierarchically shrunk | the residual half |
| robust residual distribution | heavy tails, one arm |
| **identifiability diagnostic** | a variance component's prior-free marginal precision, flagging one driven entirely by its prior |

**The comparator that can win is the shared default.** The refuting sentence is
plausible and the design registers it: if stratified and shrunk models are no better
on coverage while being more prior-sensitive, the field's convention is defensible
and the deliverable is the diagnostic alone.

**The diagnostic is a deliverable regardless of which model wins**, and the entry
asks for exactly that: report the diagnostic separately from the correction, so an
analyst can see whether stratum-specific heterogeneity is supported **before**
fitting it. **CMP-14's prior-free leave-one-source-out precision is the instrument**
and is imported rather than rebuilt; it is exactly zero where a coordinate is
unidentified, which is the property this needs.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and interval width of the cross-gap contrast per method per cell,
with MCSE; **variance-component recovery**, bias and coverage for each $\tau_k$ and
$\sigma_i$; **prior sensitivity**, the movement of the contrast across the three
prior settings.

**The registered mechanism check:** the shared model's cross-gap interval width
regressed on the analytic prediction from section 2, using the true subnetwork
heterogeneities. **Agreement confirms that the bridge's apparent support is being
set by heterogeneity elsewhere in the network.**

**The diagnostic scored as a classifier**: does the prior-free precision of a
stratified $\tau$ predict whether stratifying improves coverage? Sensitivity and
specificity, following DIA-03.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the cross-gap contrast under the shared-$\tau$
model, in cells where the **non-bridging** subnetwork is the heterogeneous one,
which is section 2 consequence 2's dangerous direction.

**Decision rule.**

- Shared $\tau$ undercovering there while a shrunk stratified model is nominal:
  confirmed, and the deliverable is the shrunk model plus the pre-fitting flag.
- Shared $\tau$ nominal across the grid: the convention is defensible and the
  deliverable is the diagnostic alone.
- Stratified models nominal only at 12 studies per subnetwork: **the refuting
  sentence is confirmed in the sparse regime**, and the recommendation becomes
  conditional on study count, which an analyst can check.

## 8. Three controls, each of which can fail

**Null control.** With equal subnetwork heterogeneities and equal residual
variances, the shared model is correctly specified and must be nominal and most
efficient. **The stratified models must cost only precision**, and if they are
biased there they are misimplemented.

**Second null control.** With $\tau = 0$ imposed and known, the heterogeneity
question disappears and every model must coincide. **Cheap, exact, and it separates
the $\tau$ mechanism from the $\sigma$ one**, which is the design's other half.

**Positive control.** 5:1 heterogeneity contrast with the non-bridging subnetwork
heterogeneous and 3 studies in the bridging one: the shared model's cross-gap
interval must be materially too narrow. **If it is not, consequence 2 is
unreachable and the study says so.**

**Falsifier for the study's own headline.** The expected headline is that
structured heterogeneity is needed. Its falsifier is the identifiability
diagnostic: **if the prior-free precision of a stratified $\tau$ is essentially
zero in every realistic cell, then the correction cannot be estimated from the data
and recommending it would be recommending a prior.** That is the entry's own stated
binding constraint and the design lets it win.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Framing a field-wide convention as a package defect | Stated in the header; `netmeta` and `multinma` named | removed |
| Overstating the shared residual scale | The entry's narrowing carried; aggregate arms and two-stage routes excluded | removed |
| A correction recommended without checking it is estimable | Identifiability diagnostic is a deliverable and the falsifier | removed |
| Prior dependence hidden inside shrinkage | Prior sensitivity is a reported measure across three settings | removed |
| Variance failure confounded with mean-model failure | Mean model correct by construction | removed, scope named |
| Bridge-validity failure confounded with variance structure | Constancy imposed; owners named | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and the analytic width | Cross-gap truth and section 2's predicted interval width per cell | **The grid**; cells where the predicted distortion is below Monte Carlo resolution are dropped | hours |
| **P2** identifiability map | The prior-free precision of a stratified $\tau$ in every planned cell, before any fitting | **Which cells can support the correction at all**, and therefore whether the falsifier already wins | hours |
| **P3** sampler behavior | Whether the shrunk-$\tau$ model samples without pathology at 3 studies per stratum | Whether that arm exists at the sparse levels | days |
| **P4** unit cost | Per-fit cost across six model arms; total computed not typed | $n_{sim}$ | hours |

**P2 may settle the study before it runs**, which would be the cheapest possible
outcome and is worth knowing first.

## 11. Cost

Six model arms times a component ML-NMR fit times 1000 replicates. Priced in P4
against SFW-06's frontier.

---

## Relationship to the rest of the queue

- **CMP-14** supplies the prior-free precision used as the identifiability
  diagnostic.
- **CMU-02** owns prior-driven posteriors generally, which is what a weakly
  identified variance component becomes.
- **HET-03** owns a single shared heterogeneity variance across classes and
  populations, which is this problem stated at network level; if both run they
  share a generator and one becomes the other's arm.
- **CMP-12** and **CMP-24** own the covariance and influence problems the note
  calls more decisive.
- **CMP-11** owns the two-stage routes whose study-specific regressions are why
  the residual-scale claim needed narrowing.
