# DIA-10 design: how much of measured method failure is a data-access artifact

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

Two of the entry's claims need the narrowing the catalog itself supplies. **A
simulate-digitize-reconstruct evaluation design for digitization error already
exists**; what is missing is its propagation into PAIC estimator performance. And
**a sponsor holding IPD for its own trial makes access treatment-dependent without
making it depend on the study-specific treatment effect**, so an explicit
availability model is needed only when inference generalizes over studies and
availability depends on effect-relevant characteristics.

The note also narrows the scope: the target-summary experiment deserves an early
run, and the full access-mechanism programme is too broad. **But target-summary
uncertainty is EST-07's and MIS-03's subject**, so running it here would duplicate
two studies. This design takes the part neither covers: **the attribution
question.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** PAIC simulations vary none of the access mechanisms, so
access-driven error goes unmeasured and **is attributed to method failure by
default.**

**Refuting sentence:** *access-driven error is small relative to the method
differences these simulations report, so the published rankings would survive its
inclusion and the attribution concern is theoretical.*

**That is a quantitative claim about existing results and it is answerable**, which
is what makes this a study rather than a complaint.

## 2. The mechanism: a generator that omits a mechanism assigns its error elsewhere

A simulation reports estimator $m$'s error as $\hat e_m$. If the generator omits an
access mechanism $A$ that would contribute $e_m^A$, then the reported quantity is
$e_m - e_m^A$, and **the ranking of methods is preserved only if $e_m^A$ is common
across $m$.** Three consequences:

1. **Access error is not common across methods.** Reconstruction error enters an
   exact survival likelihood differently from a weighted Kaplan-Meier; informative
   censoring enters an outcome model differently from a weighting estimator. **So
   omitting it changes the ranking, not just the level**, and the size of that
   change is the study's primary outcome.
2. **The direction is predictable for at least one mechanism.** Methods that use
   individual event times are more exposed to reconstruction error than methods
   using summary quantities, so **reconstruction error should penalize the exact
   likelihood most**, which is the opposite of the ordering those likelihoods earn
   on clean data. **That is a falsifiable prediction and it is uncomfortable for
   the more sophisticated method.**
3. **Informative availability is a selection problem over studies, not within
   them.** It matters only when inference generalizes over studies, per the entry's
   own narrowing, so the design carries it as a separate arm with a stated scope
   rather than as a general factor.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, by quadrature at an
order fixed by P1.

**The attribution shares are the derived estimands**: for each method and each
access mechanism, the change in that method's error when the mechanism is switched
on, and the change in the **ranking** across methods. **The ranking change is the
quantity that decides the refuting sentence** and it is registered as primary.

## 4. Data-generating mechanism, and what it makes invisible

**The base generator is the published benchmark's**, held fixed, so the attribution
is against results the field actually cites rather than against a new mechanism.
Access mechanisms are then switched on one at a time.

### Access mechanisms

| mechanism | how simulated | narrowing |
|---|---|---|
| reconstruction error | the existing simulate-digitize-reconstruct design, **adopted not invented** | its propagation into estimator performance is the new part |
| informative censoring | censoring depends on prognosis | OUT-07 owns it as a subject; here it is a factor |
| differential loss to follow-up | arm-dependent dropout | |
| selective baseline reporting | a covariate omitted from the publication when imbalanced | |
| MNAR covariate missingness | declared magnitude | MIS-01 owns it as a subject |
| **informative IPD availability** | availability depends on an effect-relevant study characteristic | **carried as a separate arm**, per the entry's narrowing |

**Target-summary sampling error is carried at two levels only**, because EST-07 and
MIS-03 own it and re-running it here would duplicate two studies while adding a
factor to an already wide design.

### What the mechanism makes true, and therefore what the study cannot see

- **One mechanism at a time.** Real access failures compound, and QBA-22 owns
  non-additive composition. The attribution here is marginal and is labeled as
  such.
- The base generator's own limitations are inherited, including its restricted
  effect-modification structure, which **DIA-08 owns.**
- The informative-availability arm requires a stated model coupling access to
  study characteristics, and **no data informs that model**; it is declared and
  results are reported as a function of it.
- Overlap and outcome-model correctness are **held fixed**, per the sketch, so
  access error is not confounded with the primary causal assumptions.

## 5. Methods

MAIC, STC, ML-NMR, and no adjustment, at the benchmark's specifications, plus for
the survival mechanism an exact-likelihood arm and a summary-based arm so
consequence 2 is testable.

**The comparator that can win is the published ranking.** If it survives every
mechanism, the refuting sentence holds and the field's comparative evidence is
robust to access. Registered as such, and it is the outcome that would most
reassure.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE and decision error per method per mechanism, with MCSE;
**the ranking of methods, and its change from the no-mechanism baseline**, as a
rank correlation with a bootstrap MCSE.

**Attribution is reported as a share:** for each method, the fraction of its total
error attributable to each access mechanism, at declared magnitudes. **The shares
are conditional on those magnitudes and the design says so**, following the same
discipline QBA-20 applies to its layer attribution.

Common random numbers across mechanisms and methods; MCSE clustered on the
replicate block. $n_{sim} = 2000$; ML-NMR reduced by P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The rank correlation between the method ordering with and
without reconstruction error, in the survival arm at realistic reporting
resolution.

**Decision rule.**

- Ranking materially changed by at least one mechanism: **confirmed**, and the
  deliverable is that comparative simulations must state which access mechanisms
  they omit.
- Ranking preserved by every mechanism: **refuted**, and the published comparative
  evidence is robust to access, which is worth establishing.
- **Ranking preserved but levels shifted**: methods are ranked correctly and all
  are optimistic, which is a third finding and a different recommendation.

## 8. Three controls, each of which can fail

**Null control.** With every mechanism off, the harness must reproduce the
published benchmark's reported ordering. **A generator study that cannot reproduce
the literature is measuring itself**, and DIA-08 registers the same control for the
same reason.

**Second null control.** With a mechanism on but at zero magnitude, results must be
identical to the baseline. **Cheap, and it catches a mechanism implementation that
perturbs something even when switched off**, which is easy to write and hard to
notice.

**Positive control.** Reconstruction from a coarse at-risk table with a mature
survival curve must degrade the exact-likelihood arm measurably. **If it does not,
consequence 2 is unreachable and the study's most interesting prediction has no
signal.**

**Falsifier for the study's own headline.** The expected headline is that omitting
access mechanisms misattributes error. Its falsifier is the common-shift case: **if
every method degrades by the same amount, the omission changes levels and not
rankings, and comparative simulations are doing their job.** That is the
third-branch outcome and the design reports it as such rather than as a weaker
version of the first.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming digitization error has no evaluation design | The existing design is adopted; only its propagation is new | removed |
| Treating sponsor IPD ownership as automatically informative | Informative availability is a separate arm with a stated scope, per the entry | removed |
| Duplicating EST-07 and MIS-03 | Target-summary error at two levels only; owners named | removed |
| Access error confounded with causal assumptions | Overlap and model correctness held fixed | removed |
| Attribution shares presented as unconditional | Declared magnitudes stated with every share | removed |
| Mechanisms compounding | One at a time; QBA-22 named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** benchmark reproduction | That the harness reproduces the published ordering with all mechanisms off | **Everything** | days |
| **P2** realistic magnitudes | Reporting resolutions, censoring dependence and missingness rates from the applied literature, fixed before the run | **The materiality verdict** | days |
| **P3** availability model | A declared coupling between access and effect-relevant study characteristics, written before results | Whether that arm is interpretable | hours |
| **P4** unit cost | Per-replicate cost across methods and mechanisms; total computed not typed | The ML-NMR replicate count | hours |

## 11. Cost

Four methods times six mechanisms times the benchmark grid. Wide rather than deep,
and the ML-NMR arm sets the budget.

---

## Relationship to the rest of the queue

- **DIA-08** owns whether the generator decides the comparison on the
  effect-modification axis; this is the same question on the access axis, and the
  two share the benchmark-reproduction control.
- **CMP-17**, **OUT-13** and **OUT-14** own reconstruction and observation-process
  error as subjects; this study propagates them into estimator rankings.
- **MIS-01** owns missingness; **OUT-07** owns informative censoring;
  **EST-07** and **MIS-03** own target-summary error.
- **QBA-22** owns composition, which this design's one-at-a-time attribution
  explicitly does not cover.
