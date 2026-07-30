# DIA-08 design: when the generator picks the winner

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog corrects its own premise twice and both corrections shape the
design.** Non-normal, bimodal and Gamma covariates and deliberate positivity
violations are already in this literature (Phillippo et al. 2020;
Serret-Larmande et al. 2025; NORTA copula generation in Ren et al. 2025). And
matching the full mean vector and covariance matrix of a nonsingular multivariate
normal **fixes the joint law**, so the matched-moments failure mode comes from
balancing a finite set of reported moments rather than from Gaussianity as such.

So the covariate half is largely answered. **What survives is the
effect-modification half**, and section 2 says why that half is the one that
decides comparisons.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** data generated under shared linear effect
modification cannot evaluate robustness to departures from it, so on the question
that matters most the comparison is decided by the generator rather than by the
methods; and the departures that matter, treatment-specific, component-specific,
nonlinear-threshold and subnetwork-varying modification, plus decoupling of the
within-study interaction from the between-study gradient, are absent from every
published generator.

**Refuting sentence:** *the method ordering under shared linear modification
survives every departure, so existing simulations rank methods correctly even
though they cannot demonstrate why.*

**That is the study's primary outcome and it is a rank-reversal question**, which
is a sharper thing to test than "results differ".

## 2. The mechanism: a generator that makes a restriction true

Every method in this literature imposes some structure on effect modification.
Shared-interaction ML-NMR imposes one $\beta$ across a class; MAIC imposes that
matching the modifier moments suffices; STC imposes a functional form.

**Under a shared-linear generator, several of those restrictions are exactly
true.** A method that imposes a true restriction is correctly specified and gains
efficiency for free, so it wins, and the win is a property of the generator:

$$\text{true model} \in \bigcap_{\text{methods}} \text{model spaces} \;\;\Longrightarrow\;\; \text{ranking is by efficiency alone.}$$

Three consequences:

1. **Under shared-linear generation the comparison measures efficiency, not
   robustness**, and efficiency ordering is not the ordering a reader takes from
   it. **The catalog's own correction matters here: a shared-linear generator can
   still separate methods on efficiency, variance and finite-sample behavior**, so
   such studies are not worthless; they answer a narrower question than they are
   read as answering.
2. **A departure removes the restriction for the methods that impose it and
   leaves the others alone**, so the ranking should change in a direction that is
   predictable from which restriction each method imposes. **That prediction is
   testable and it is what separates this study from "we tried harder scenarios".**
3. **Within-study versus between-study decoupling requires multiple studies with
   varying covariate distributions**, so a single-pair template cannot represent
   aggregation bias at all. CMP-13 established the algebra; a generator without
   that structure cannot exhibit it regardless of what methods are compared.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, at a declared
target, on both a collapsible and a non-collapsible scale.

**True value** by quadrature over the target law with the true, possibly
nonlinear, modification surface, at an order fixed by P1. **Under a threshold
modification surface the marginal effect has no closed form**, which is precisely
why generators avoid such surfaces, and computing it correctly is the design's
first technical requirement rather than an afterthought.

**The derived estimand that carries the contribution:** the **method ordering**
by RMSE within each generator, and the rank correlation between the ordering
under shared-linear generation and under each departure.

## 4. Data-generating mechanism, and what it makes invisible

**This study's product is the generator**, so the generator is the object being
designed and it must be reusable by others. It is built as a package with the
existing non-normal, bimodal and copula machinery reused rather than rewritten,
and the new control surfaces added.

### Factors: the effect-modification departures

| departure | specification | which restriction it breaks |
|---|---|---|
| shared linear | one $\beta$, linear | none; the reference generator |
| treatment-specific | $\beta_k$ differs by treatment | the shared-interaction restriction |
| nonlinear threshold | modification switches at a covariate value | every linear form |
| modifier-by-modifier | interaction between two modifiers in the treatment effect | additive modifier structure |
| subnetwork-varying | $\beta$ differs between subnetworks | class-level pooling |
| **within/between decoupled** | within-study interaction differs from the between-study gradient | the conflation CMP-13 formalized |

### Factors: held as a reduced grid

Covariate law (normal; bimodal; Gamma, all from the existing generators), overlap
(good, poor), reported-moment set (means only; means and SDs), network geometry
(single pair; multi-study), scale (risk difference; log OR).

**Reported covariate moments are held fixed across departures**, so a departure
changes only the modification structure and nothing an analyst would see. That
constancy is the design.

### What the mechanism makes true, and therefore what the study cannot see

- **Participation-only variables and trial-engagement effects need an explicit
  selection model**, which the catalog names and this design does **not** build.
  That is a scope decision: a selection model changes identification, not just
  modification, and it would confound the rank-reversal question. **It is named as
  the largest remaining gap and left to a separate study**, rather than gestured
  at.
- The covariate half is imported, not extended. Local support gaps at matched
  moments are a real capability the catalog asks for, and **it is included only
  because it is cheap given the existing NORTA machinery**; its absence would not
  affect the primary outcome.
- Every departure is generated one at a time. Compounded departures are what real
  data have and are not covered.
- Methods are fitted at their standard specifications. A method that could be
  respecified to survive a departure is not given that chance, which is
  conservative toward the departures and is stated.

## 5. Methods, including one that can win

MAIC, STC, ML-NMR (shared interaction), ML-NMR (treatment-specific), ML-UMR, NMI,
and no adjustment, all at standard specifications.

**The comparator that can win is the shared-interaction ML-NMR**, which is
expected to lose under the departures that break its restriction. If it holds its
ranking anyway, section 2 consequence 2 is wrong and the refuting sentence in
section 1 stands. Registered as such.

**This study does not aim to identify a best method** and its abstract must say
so. It aims to measure how much of a published ranking is attributable to the
generator. A paper that ends with a recommended method would have answered a
different question with this design's data.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, RMSE, coverage and **decision error** per method per cell, with MCSE.
Decision error is included because the catalog's framing is about what these
simulations are used for, and DEC-01 owns the general form.

**The primary summary is rank correlation** between the RMSE ordering under
shared-linear generation and under each departure, computed within matched cells
so nothing but the modification structure differs.

Common random numbers across methods and, where the departure permits, across
generators, so orderings are paired. **MCSE on a rank correlation is obtained by
the bootstrap over replicates**, not by a formula, since the methods' errors are
dependent within a replicate.

$n_{sim} = 2000$ per cell for the non-Stan arms; ML-NMR arms reduced by P4 and
reported at their own counts.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Rank correlation between the method ordering under
shared-linear generation and under treatment-specific and threshold modification,
at poor overlap on the log OR scale.

**Decision rule.**

- Rank correlation materially below 1, with the reversals falling on the methods
  whose restrictions the departure breaks, **confirms** that the generator decides
  the comparison and the deliverable is the generator plus a recommendation that
  method comparisons report which departures they tested.
- Rank correlation at or near 1 across every departure **refutes** it, and
  existing simulations rank methods correctly despite their restricted generators.
  **That is a genuinely useful negative result** and it is reported as the
  headline.
- Reversals that do **not** fall on the predicted methods mean section 2's
  mechanism is not what drives them, and the study reports the reversals without
  the explanation rather than fitting one afterwards.

## 8. Three controls, each of which can fail

**Null control.** Under shared-linear generation with good overlap, the methods
whose restrictions are true must be unbiased and efficient, and the ordering must
reproduce the published benchmark's ordering. **Failing to reproduce a published
result on its own generator means the harness differs from the literature and no
comparison with it is valid.** This is the single most important control in the
design and it is checkable against Phillippo et al. 2020 directly.

**Second null control.** With **zero** effect modification, every departure
collapses to the same generator, so all six must give identical truths and
statistically indistinguishable method orderings. **This checks that the
departures are implemented as modifications of the modification structure and not
as accidental changes to something else**, which is the easiest way for a
generator study to go wrong.

**Positive control.** Under within/between decoupling in a multi-study network,
the shared-interaction ML-NMR must be biased, because CMP-13 proved it is
algebraically forced to conflate the two. **If it is not biased there, this
design's decoupling is not implemented**, and CMP-13's result is the external
check that says so.

**Falsifier for the study's own headline.** The expected headline is that
generators decide comparisons. Its falsifier is the covariate half: departures in
the covariate law, which the catalog says are already handled, should **not**
reverse rankings. If they do, then rankings are fragile to everything and the
specific claim about effect modification is not what is going on.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Repeating the corrected premise about multivariate normality | Stated as corrected; matched-moment failure attributed to finite reported moments | removed |
| Rebuilding covariate generators that exist | Existing machinery reused; only local support gaps added, and only because they are cheap | removed |
| A departure that changes the truth for reasons other than modification | Reported moments held fixed; zero-modification control | removed |
| Ending with a recommended method, answering a different question | Stated in the abstract that no best method is identified | removed |
| Harness differing silently from the published benchmark | Benchmark reproduction is the null control | removed |
| Selection models gestured at but not built | Named as the largest remaining gap and left out explicitly | disclosed |
| Compounded departures | One at a time; stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths under nonlinear surfaces | The marginal truth under threshold and modifier-by-modifier surfaces, to a declared tolerance | **The departures.** A surface whose truth cannot be computed accurately cannot be a scenario | hours |
| **P2** benchmark reproduction | That the harness reproduces Phillippo et al. 2020's reported ordering on its own generator | **Everything.** A generator study that cannot reproduce the literature is measuring its own harness | days |
| **P3** matched-moment departures | That each departure leaves the reported moments unchanged, verified numerically | The departures | hours |
| **P4** unit cost | Per-replicate cost across seven methods; ML-NMR replicate counts; total computed not typed | The grid | hours |

**P2 is the largest and the one that would be skipped.** It is also the only
thing that lets this study say anything about published comparisons rather than
about itself.

## 11. Cost

Seven methods times six generators times a reduced covariate grid. The ML-NMR
arms dominate. Priced in P4; no total quoted.

---

## Relationship to the rest of the queue

- **CMP-13** supplies the within/between algebra and is this design's positive
  control.
- **DIA-07** owns network topology in scenario grids, held at two levels here.
- **DIA-09** owns narrow outcome families and hazard-ratio-only survival scoring,
  which is the same complaint on the outcome axis; if both run, the generator is
  shared.
- **DIA-06** and **MOD-09** own cross-family estimator comparison, which this
  study deliberately refuses to conclude.
- **DEC-01** owns decision error as the scoring currency.
- **DIA-10** owns data access simulated as benign, which is the selection model
  this design leaves out.
