# DIS-03 design: a baseline term that carries the bridge and absorbs the nuisance

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog corrects the source's reading of its own citation.** Beliveau et al. is not
the cautionary result it was presented as: across the two disconnected datasets it
examined it found random baseline treatment effects **appropriate**, while warning that
normality and exchangeability could be inappropriate in datasets it did not observe.

The cautionary evidence is elsewhere and is quantitative. Thom et al. measured
disconnected-treatment bias from **−0.16 to 0.392 for aggregate-level matching and −0.102
to 0.40 for reference prediction, with coverage of 0.30 to 0.82 and 0.64 to 0.94**, and
recommended reference prediction **on coverage grounds**. The note says existing evidence
already shows severe misspecification risk, which is why this ranks below unevaluated
questions; **section 2 identifies the specific structural reason, which is not yet
isolated.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** an observed control-arm risk depends on prognosis, endpoint
definition, follow-up, ascertainment, care context and calendar time, so it is not
intrinsically exchangeable; **where a single baseline parameter both carries the cross-gap
bridge and absorbs study-level nuisance variation, nothing inside a disconnected graph
separates the two roles**, so a difference in endpoint definition can be absorbed as a
difference in prognosis and propagated into the relative effect.

**Refuting sentence:** *the baseline term's two roles are separable in practice because
design differences leave a signature in observable baseline heterogeneity, so a
well-specified model with design covariates recovers the bridge.*

## 2. The mechanism: two roles, one parameter, no internal separation

Write study $s$'s baseline as $\mu_s = \mu + b_s + \nu_s$, where $b_s$ is the
prognostic deviation the bridge is meant to transport and $\nu_s$ is study-level nuisance
from endpoint definition, follow-up and ascertainment. **The likelihood sees only
$\mu_s$.** Three consequences:

1. **$b_s$ and $\nu_s$ are not separately identified within a disconnected graph**, because
   the contrast that would distinguish them spans the gap. **So the bridge transports
   $b_s + \nu_s$**, and any $\nu$ is propagated into the relative effect as though it were
   prognosis.
2. **Design covariates identify $\nu$ only where they are measured, overlap, and are
   correctly modeled.** The catalog is careful here: conditioning reference prediction on
   design covariates improves things **under those conditions rather than
   automatically**. **So the refuting sentence is conditionally true**, and the design's
   job is to measure how conditional.
3. **Regression to the mean and measurement error in the baseline term add distortion
   invisible in the fitted output**, because a shrunk baseline looks like a well-behaved
   posterior. **A commensurate prior down-weights the bridge when source and target
   baselines conflict**, which is the entry's proposal and the one arm that responds to
   the conflict rather than assuming it away.

**The deliverable follows from consequence 1.** Since the two roles cannot be separated
internally, the honest output is **an explicit posterior decomposition of how much the
baseline bridge moves each treatment contrast**, so a reader can see how much of the
answer is bridge rather than evidence. **That is computable and nothing reports it.**

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect for a cross-gap contrast, by
quadrature at an order fixed by P1.

**The bridge contribution is the derived deliverable**: the change in the contrast when the
baseline link is removed and the subnetworks are fitted separately, which is exactly the
quantity consequence 1 says is unidentified from within and which is computable by
comparison.

**Posterior dependence on the baseline bridge** is reported per contrast.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| cross-study prognostic imbalance $b_s$ | small, large | the quantity the bridge should transport |
| **endpoint or follow-up shift $\nu_s$** | none, moderate, large | **consequence 1's confound** |
| design covariates measured | yes; no | consequence 2's condition |
| baseline measurement error | none; moderate | consequence 3 |
| commensurability of source and target baselines | high; low | where a commensurate prior should act |

**$b_s$ crossed with $\nu_s$ is the design**, because their confounding is the mechanism
and no existing study separates them.

### What the mechanism makes true, and therefore what the study cannot see

- **No check inside a disconnected graph reaches the cross-gap counterfactual**, which is
  what the bridge supplies. Observed baseline heterogeneity and design associations can be
  examined and are, **but a pass licenses nothing**, which is DIS-11's finding applied here.
- Reference prediction's better relative coverage in one simulation is **a conditional
  preference under stated assumptions**, not evidence that disconnected networks are
  solved, and the design does not treat it as a benchmark to beat.
- The unanchored single-arm case additionally requires **a common conditional baseline
  risk across study populations**, described as highly restrictive and unlikely to be
  plausible in most applications. **That case is carried as one arm and its assumption is
  stated rather than tested.**
- One outcome family.

## 5. Methods, including one that can win

| model | role |
|---|---|
| fully exchangeable baselines | the default |
| **separate baseline distributions for connected, disconnected and single-arm evidence** | the entry's first proposal |
| **commensurate baseline prior** | down-weights the bridge on conflict; consequence 3 |
| reference prediction conditioned on design covariates | consequence 2, under its conditions |
| fixed study effects with hierarchical pooling | the sensitivity form recommended for the single-arm case |
| subnetworks fitted separately | the no-bridge floor, so the bridge's contribution is visible |

**The comparator that can win is the fully exchangeable default.** If its bias and coverage
match the structured alternatives across the $\nu_s$ axis, the structural concern is not
material at realistic design differences. **Registered as such**, and Beliveau et al.'s
finding on two real datasets is the reason it is live.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and **decision error** of the cross-gap contrast per model per cell, with
MCSE.

**The bridge contribution** per contrast, and **posterior dependence on the baseline
bridge**, which is the entry's requested decomposition.

**The registered confounding check:** observed bias regressed on $\nu_s$ at fixed $b_s$.
**Consequence 1 predicts a slope near one**, meaning nuisance is transported as prognosis
one-for-one, and a slope near zero would refute the mechanism.

$n_{sim} = 1000$ per cell, Stan-limited.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias and coverage of the cross-gap contrast under fully exchangeable
baselines, across the $\nu_s$ axis at fixed $b_s$, with design covariates unmeasured.

**Decision rule.**

- Bias tracking $\nu_s$ with coverage falling, and the commensurate prior or separate
  distributions repairing it: **confirmed**, and the deliverable is those specifications
  plus the required decomposition.
- Bias flat in $\nu_s$: **refuted**, and the baseline term is not absorbing design
  differences at realistic magnitudes.
- **The bridge-contribution decomposition is reported in either branch**, because it tells a
  reader how much of the answer is assumption regardless of which model wins.

## 8. Three controls, each of which can fail

**Null control.** With $\nu_s = 0$ and measured design covariates, the baseline term carries
only prognosis, so every model must be unbiased and the exchangeable default must be most
efficient. **A bias there is misspecification of something else.**

**Second null control.** With $b_s = 0$ and $\nu_s$ large, the bridge has nothing true to
transport and everything false, so **bias must be maximal and entirely attributable to
$\nu_s$.** That is consequence 1 in its purest form and it isolates the confound.

**Positive control.** Large $\nu_s$, unmeasured design covariates, low commensurability:
the exchangeable default must be biased by at least three MCSEs. If not, the mechanism is
unreachable.

**Falsifier for the study's own headline.** The expected headline is that the baseline
bridge propagates design differences as prognosis. Its falsifier is the decomposition:
**if the bridge contribution is small for every contrast, then the baseline link is barely
load-bearing and its misspecification cannot matter much**, which would reconcile the
entry's concern with Beliveau et al.'s reassuring finding.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting Beliveau et al. as cautionary | Corrected in the header | removed |
| Reference prediction treated as a solved benchmark | Framed as a conditional preference | removed |
| Prognostic and nuisance baseline variation confounded in the design too | Crossed; second null control isolates | removed |
| A passing baseline-heterogeneity check read as validation | Stated as reaching nothing across the gap; DIS-11 named | removed |
| The single-arm common-baseline assumption tested | Carried with its assumption stated, not tested | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | Cross-gap truths per cell | The definition of truth | hours |
| **P2** confound construction | $b_s$ and $\nu_s$ varied independently at matched observed baselines | **The design's crossing**; if observed baselines cannot be matched, the confound is not isolable | days |
| **P3** decomposition computability | That the bridge contribution is computable from the fitted posteriors rather than only by refitting | Whether the deliverable is cheap or expensive | hours |
| **P4** unit cost | Per-fit cost across six models; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Six Bayesian models across a five-factor grid at 1000 replicates; moderate and bounded by
SFW-06.

---

## Relationship to the rest of the queue

- **DIS-11** owns what can validate a bridge and establishes that within-subnetwork checks
  do not reach the gap.
- **DIS-21** owns the matching bridge's threshold; **IDN-08** and **DIA-16** own deletion
  validation, which is the only empirical check on any of these bridges.
- **CMP-16** and **HET-03** own the variance structures that interact with a shared
  baseline.
- **DIA-18** owns calendar-time drift, one source of $\nu_s$.
