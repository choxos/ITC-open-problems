# ADJ-15 design: the one moment-uncertainty problem where the correction is exact

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog narrows two claims and both matter. **A correctly calibrated privacy
guarantee does not cease to hold because an arm is small**; utility rather than
validity is the casualty. And **the assertion that no governance framework exists in
evidence synthesis was not verifiable by any auditor**, so this design makes no
governance-vacuum claim. The note also separates governance into a standards project;
this is the estimator-and-privacy simulation.

Section 2 finds that differential privacy has a property no other entry in this queue
has, and it makes the study easier rather than harder.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no work calibrates a privacy budget for the target
moments PAIC needs, and no PAIC estimator treats released summaries as noisy inputs
and propagates that noise into the transported effect; trial arms are small, so
aggregate quantities computed on them have high sensitivity and need large noise.

**Refuting sentence:** *at budgets that preserve the guarantee, the injected noise is
small relative to the sampling error already present in a reported moment, so
propagation adds nothing beyond what EST-07's machinery already covers.*

## 2. The mechanism: privacy noise has a known variance, and sampling error does not

A differentially private release of a mean adds noise with a **variance the data
holder computes and can publish**: for the Laplace mechanism on a mean over an arm of
size $n$ with covariate range $R$, the scale is $R/(n\varepsilon)$ and the variance is
$2R^2/(n\varepsilon)^2$. Three consequences:

1. **This is the only moment-uncertainty problem in the queue whose variance is
   known exactly.** EST-07, MIS-03 and COV-12 all face uncertainties that must be
   estimated or bounded. **Here the correction is a plug-in with no estimated
   nuisance**, so if propagation ever works cleanly it works here, and a failure
   would indicate something other than the uncertainty being unknown.
2. **The noise variance scales as $1/(n\varepsilon)^2$ while sampling variance scales
   as $1/n$.** So privacy noise dominates sampling error when $n\varepsilon^2 \lesssim
   R^2$, which at a 40-patient arm and a modest budget it does. **That gives the
   crossover an analytic form and it is the study's central quantity**: the budget at
   which privacy noise stops being the dominant source.
3. **Sensitivity grows with the number of released moments.** A budget split across
   $p$ moments gives each $\varepsilon/p$, so the per-moment noise grows as $p^2$ in
   variance. **Richer summaries are therefore not free**, and the entry's premise
   that privacy would let holders publish *richer* summaries has a limit that is
   computable rather than rhetorical.

**Consequence 3 is the design's most useful output.** There is an optimal number of
released moments: too few and the adjustment is incomplete; too many and each is too
noisy to use. **Nobody has located it, and it follows from quantities a data holder
knows.**

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, by quadrature at an
order fixed by P1.

**True value** against the **true** target moments, not the privatized ones. Defining
truth against the released summaries would make the privacy mechanism part of the
estimand.

**The utility-privacy frontier is the derived deliverable**: achieved coverage and
interval width as a function of $\varepsilon$ and the number of released moments,
with the crossover from consequence 2 marked.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| arm size | 40, 150, 500 | the entry's own concern; 40 is the small-arm regime |
| privacy budget $\varepsilon$ | 0.5, 1, 4, and no privacy | the frontier's axis |
| **number of released moments** | means only; means and SDs; plus correlations | **consequence 3** |
| covariate overlap | good, poor | the adjustment layer |
| release mechanism | Laplace; Gaussian | different noise variances at matched guarantee |
| estimator treatment of the release | **noise ignored**; noise propagated | the entry's specific gap |

### What the mechanism makes true, and therefore what the study cannot see

- **Governance is out of scope**, per the note, and no vacuum is claimed, per the
  auditors' inability to verify one.
- **The guarantee is assumed correctly calibrated.** Section 1's narrowing is that a
  correct guarantee holds regardless of arm size, so the design does not test the
  guarantee; **it measures utility**, which is the casualty the catalog names.
- Federated settings are not simulated. FedECA delivers federated weighted
  external-control analysis without pooling, and **the entry's point is that standard
  federated privacy analyses assume per-site samples far larger than a 40-patient
  arm**; that mismatch is noted, not modeled.
- One target trial. Multi-source releases would compose budgets and are named.

## 5. Methods, including one that can win

| method | role |
|---|---|
| non-private analysis | the ceiling |
| private release, noise ignored | **the specific failure the entry names** |
| private release, noise propagated by plug-in | the fix, exact by consequence 1 |
| private release with the budget split optimized | consequence 3's deliverable |
| EST-07's sampling-error correction, applied without the privacy term | the check that the two sources are separable |

**The comparator that can win is ignoring the noise.** If coverage is nominal
without propagation at budgets that would actually be used, the refuting sentence
holds and the estimator work is unnecessary. Registered as such, and consequence 2
says whether that happens is an arithmetic question with an answer.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, interval width and effective sample size per method per cell, with
MCSE.

**Utility against the non-private analysis**, as the ratio of interval widths, which
is the quantity a data holder trades against $\varepsilon$.

**The registered crossover check:** the budget at which privacy-noise variance
equals sampling variance, predicted analytically from consequence 2 and compared with
the observed crossover in coverage degradation. **Agreement makes the frontier
computable in advance**, which is the deliverable a data holder can use.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the target effect with the noise ignored, at a
40-patient arm across the budget axis.

**Decision rule.**

- Coverage materially below nominal at usable budgets, restored by plug-in
  propagation: **confirmed**, and the deliverable is the propagation plus the
  frontier.
- Coverage nominal throughout: **refuted**, and privacy noise is dominated by
  sampling error at usable budgets, which would be a clean and encouraging finding
  for data holders.
- **The optimal moment count is reported in either branch**, because consequence 3
  determines what a holder should release and does not depend on whether the
  estimator propagates.

## 8. Three controls, each of which can fail

**Null control.** With no privacy noise, every method must coincide with the
non-private analysis. **Exact, and it checks the propagation term vanishes when the
noise does.**

**Second null control.** With privacy noise but **no effect modification**, the
target moments do not affect the estimand, so no amount of noise can bias it.
**Every method must be unbiased at every budget.** That is the same algebraic control
EST-07 uses and it separates "noisy inputs" from "noisy inputs that matter".

**Positive control.** 40-patient arm, $\varepsilon = 0.5$, correlations released,
strong effect modification: ignoring the noise must undercover materially. **If it
does not, the small-arm concern is not reachable at guarantees anyone would use.**

**Falsifier for the study's own headline.** The expected headline is that
propagation is needed. Its falsifier is consequence 3 turning the problem around:
**if the optimal release is means only, then the richer summaries the entry hopes
privacy would enable are not obtainable at any useful budget**, and the honest
conclusion is that differential privacy does not solve the problem it was proposed
for. That is a real possibility at a 40-patient arm and the design must reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming a guarantee fails at small arms | The narrowing carried: validity holds, utility is the casualty | removed |
| Claiming a governance vacuum | Not claimed; unverifiable per the auditors | removed |
| Truth defined against privatized moments | Defined against the true ones | removed |
| Privacy noise conflated with sampling error | Separable by construction; one arm applies only the sampling correction | removed |
| Federated assumptions imported | Noted as mismatched, not modeled | disclosed |
| Budget composition across sources | Named, out of scope | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and the analytic crossover | Target truth per cell and consequence 2's crossover budget | **The budget levels**, which must straddle the crossover | hours |
| **P2** sensitivity calculation | The correct sensitivity of each released moment for the chosen mechanism, since a wrong sensitivity breaks the guarantee rather than the utility | **The whole privacy layer.** A miscalibrated mechanism would make every result about a guarantee that does not hold | days |
| **P3** optimal split | The moment count minimizing total error at each budget, analytically | The deliverable | hours |
| **P4** unit cost | Per-replicate cost; total computed not typed | The grid | minutes |

**P2 is the one that must be right.** This design measures utility under a correct
guarantee, and a wrong sensitivity would silently make it measure something else.

## 11. Cost

Weighting fits with a noise-injection step; small.

---

## Relationship to the rest of the queue

- **EST-07** and **MIS-03** own target-moment sampling error; this is the same
  propagation with a known variance, and consequence 1 makes it the easiest case.
- **COV-12** owns moments that were never reported at all, the opposite extreme.
- **DEC-11** owns what belongs in an interval; privacy noise is sampling-like with a
  known variance and belongs inside one.
- **DIA-10** owns data access as a simulated mechanism, of which a privacy release is
  one.
