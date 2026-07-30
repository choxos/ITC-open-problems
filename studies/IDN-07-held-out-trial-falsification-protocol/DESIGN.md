# IDN-07 design: writing the protocol, then calibrating its threshold

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's instruction is unusually direct: **write the protocol rather than
the method.** The design is coherent; what is missing is an identifiability
precondition, a discrepancy metric, a threshold with known operating
characteristics, and full propagation of the uncertainties the predictive interval
has to absorb.

It also records that **neither auditor could certify the absence claim**. This
design therefore asserts no absence; it cites the two adjacent works and
calibrates.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** leave-one-trial-out prediction is a coherent
falsification design only when removal leaves the required contrast identifiable
and the withheld population's target covariate distribution can be specified
without using its outcome contrast; there is no pass or fail rule; and a
discrepancy is ambiguous between an estimand mismatch and a genuine transport
failure.

**Refuting sentence:** *with an externally prespecified target the estimand
mismatch disappears, and a standardized residual with nominal calibration is
adequate, so the missing object is a convention rather than a calibration
problem.*

**Section 2 shows the first half of that refutation is exactly right**, which is
what makes external prespecification a protocol requirement rather than a
preference.

## 2. The mechanism: two nuisances, one of which is removable by fiat

The discrepancy is $D = \hat\Delta_{\text{pred}} - \hat\Delta_{\text{obs}}$ with

$$\mathrm{Var}(D) = \mathrm{Var}(\hat\Delta_{\text{pred}}) + \mathrm{Var}(\hat\Delta_{\text{obs}}) - 2\,\mathrm{Cov},$$

and the covariance is nonzero because the withheld trial's covariate summaries are
used in the prediction even when its outcomes are not.

**Nuisance one, and it is removable.** Withholding a trial changes the evidence
base and can change the implied target population, so $\hat\Delta_{\text{pred}}$
and $\hat\Delta_{\text{obs}}$ may estimate quantities in different populations and
$\mathbb{E}[D] \neq 0$ **under the null**. The catalog's own qualifier is the fix:
this does not happen **when the target is externally prespecified**. So

> **fixing the target externally makes the null exactly $\mathbb{E}[D] = 0$**,

and any protocol that does not require it is testing a composite null it cannot
interpret. That is a protocol requirement derived rather than chosen, and it is
this design's first deliverable.

**Nuisance two, and it is not removable.** $\mathrm{Var}(D)$ must absorb weight
estimation, target-moment uncertainty and between-study heterogeneity. Each
omitted component inflates type I error, and the inflation is multiplicative in
the omitted variance share. **A rule calibrated with any of them omitted will
falsify correct models**, which is worse than having no rule, since a no-go
decision is what the rule licenses.

**The identifiability precondition is a rank check**, not a judgment: removing the
trial must leave the contrast in the row space of the reduced design. **A network
where it does not is not a failed test; it is a test that was never run**, and
conflating the two is the commonest way a low-power check reports a high pass
rate.

**Power is structurally low** because networks contain few trials, and the verdict
depends on which trial is withheld. So the study reports operating characteristics
**per withheld trial position**, not averaged, since the average is not what any
analyst faces.

## 3. Estimand, with its true value defined

**Primary.** The withheld trial's **target-standardized** treatment contrast, at
the externally prespecified target, computed by quadrature at an order fixed by
P1. Target-standardized on both sides is what makes prediction and observation
comparable, and it is a protocol requirement from section 2.

**Two derived estimands.** The **discrepancy** $D$ and its null distribution; and
**the correct verdict**, whether the transport restriction is in fact violated,
which is known by construction.

## 4. Data-generating mechanism, and what it makes invisible

Networks restricted to configurations where leave-one-trial-out removal leaves the
contrast identifiable, verified per replicate by P2's rank check. **Restricting to
identifiable configurations is the catalog's own instruction and it is what keeps
this from being framed as a universal falsification standard.**

### Factors

| factor | levels | why |
|---|---|---|
| transport violation magnitude | 0, small, moderate, large | the power curve; 0 is the size |
| network connectivity | sparse; dense | how much the removal changes the evidence base |
| between-study heterogeneity | 0, moderate | one of the variance components the interval must absorb |
| overlap | good, poor | weight-estimation variance |
| target-moment uncertainty | exact; $n_T = 300$ | the component nothing propagates |
| withheld trial position | central; peripheral; the only trial informing a contrast | **reported separately, never averaged** |
| target specification | externally prespecified; implied by the reduced network | **section 2's removable nuisance, switched on and off** |

### What the mechanism makes true, and therefore what the study cannot see

- Only identifiable removals are simulated. **The frequency with which real
  networks admit an identifiable removal at all is not estimated here** and is a
  separate empirical question; the protocol requires the check, and how often it
  passes in practice is unknown.
- Study-level held-out prediction only. **Patient-level cross-validation answers a
  different question** and the catalog is explicit that current practice conflates
  them; this design keeps them distinct and does not evaluate the latter.
- One violation mechanism at a time, from IDN-01's declared list, so a failure can
  be attributed.
- The externally prespecified target is available to the simulation. In practice
  declaring one requires the target-declaration discipline the field does not
  enforce, which is EST-11's subject.

## 5. Methods, including one that can win

| rule | specification | role |
|---|---|---|
| standardized residual | $D$ divided by an SE with all components propagated | the natural rule |
| standardized residual, naive SE | weight and target-moment variance omitted | **what an implementation would do today**, included so the inflation is measured |
| predictive-tail probability | the observed contrast's position in the posterior predictive | the Bayesian rule |
| decision-scale discrepancy | whether the discrepancy changes the decision at a declared threshold | the rule that matches what falsification is for |
| conditional-moment falsification test | Hussain et al.'s machinery adapted | **the closest formal template, adapted rather than reinvented**, as the catalog instructs |

**The comparator that can win is the decision-scale rule.** If a discrepancy that
does not change the decision never matters, then calibrating a statistical
threshold is beside the point and the protocol should ask a decision question
directly. Registered as the outcome most likely to overturn the expected headline.

## 6. Performance measures, MCSE, and $n_{sim}$

Type I error and power per rule, per violation magnitude, **per withheld-trial
position**; coverage of the held-out contrast's predictive interval; and the
**variance-component decomposition**, reporting how much of $\mathrm{Var}(D)$ each
omitted component contributes, so the naive rule's inflation is attributable
rather than merely observed.

**The estimand-mismatch measure**, which is section 2's first nuisance made
visible: $\mathbb{E}[D]$ under the null with and without external target
prespecification. **That difference is the evidence for the protocol requirement**
and is a registered outcome.

$n_{sim} = 4000$ networks per cell, derived from resolving type I error of 0.05 to
within 0.007, since a rule that licenses abandoning an analysis must have its size
known to better than the difference between 5% and 8%.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Type I error of each rule at zero violation, by withheld-trial
position, with the target externally prespecified.

**Decision rule.**

- A rule holding nominal size across positions and reaching power $\geq 0.80$ at
  moderate violation: **that rule with that threshold is the protocol's
  deliverable**, with its power curve published so a user knows what a pass
  licenses.
- Every rule holding size but with power below 0.50 at large violation: the check
  is coherent and underpowered, and **the deliverable is the statement that a pass
  licenses very little**, which is more useful than a threshold.
- The naive rule's size inflated: quantified and reported, because that is what an
  implementation using it today is doing.

**"A pass does not establish transportability" is part of the registered output**,
following IDN-01.

## 8. Three controls, each of which can fail

**Null control.** Zero violation, exact target moments, no heterogeneity, external
target: every fully propagated rule must hold nominal size. **Failure here means
the variance is wrong before any interesting component is added.**

**Second null control, and it is section 2's mechanism.** Zero violation with the
target **implied by the reduced network** rather than prespecified: $\mathbb{E}[D]$
must be **nonzero** and size must be inflated. **A control that must fail is
unusual and it is the point**: if size is nominal there too, the estimand mismatch
is not operative and the protocol requirement is unnecessary.

**Positive control.** Large violation, dense network, central trial withheld: power
must be high. If the check cannot detect a large violation in its most favorable
configuration, it is not a falsification design and the study reports that.

**Falsifier for the study's own headline.** The expected headline is that a
calibrated threshold is achievable. Its falsifier is the peripheral-trial position:
if size or power there is unusable regardless of rule, then the check's verdict
depends on which trial is withheld to a degree that makes a single threshold
meaningless, and the honest deliverable is a per-position table rather than a rule.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Repeating an absence claim neither auditor could certify | Not repeated; adjacent work cited and adapted | removed |
| Non-identifiable removals counted as passes | Rank precondition checked per replicate; non-identifiable configurations excluded and counted | removed |
| Estimand mismatch confounded with transport failure | Target specification is a factor; second null control isolates it | removed |
| Variance components omitted silently | Decomposition reported; naive rule carried deliberately | removed |
| Operating characteristics averaged over withheld position | Reported per position | removed |
| Study-level and patient-level cross-validation conflated | Only the former; stated | removed |
| Framing as a universal falsification standard | Restricted to identifiable configurations, per the catalog's note | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Target-standardized truths for the withheld contrast | The definition of truth | hours |
| **P2** identifiability precondition | The rank check per network and removal, before any fitting | **The grid.** This is the same probe IDN-06, CMP-06 and CMP-14 need, and CMP-14 shipped a rank-deficient state for four rounds by skipping it | hours |
| **P3** variance-component sizes | The analytic or pilot share of $\mathrm{Var}(D)$ from each component, so the decomposition is resolvable | $n_{sim}$ | hours |
| **P4** unit cost | Per-network cost across five rules at $n_{sim}=4000$; total computed not typed | The grid | hours |

## 11. Cost

Every replicate refits the network with and without the withheld trial, across five
rules. Priced in P4; no total quoted.

---

## Relationship to the rest of the queue

- **IDN-01** owns screen calibration generally and supplies the violation
  mechanisms; this is one screen taken to protocol depth.
- **IDN-08** and **DIA-16** own curated benchmarks for bridged and bridge-deletion
  validation, which is where a calibrated threshold would be applied to real data.
- **DIA-17** owns held-out IPD as a benchmark against truth.
- **EST-11** owns the target declaration this design requires.
- **EST-07** and **MIS-03** own target-moment uncertainty, one of the components
  the interval must absorb.
