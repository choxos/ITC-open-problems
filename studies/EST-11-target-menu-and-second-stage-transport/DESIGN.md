# EST-11 design: crossing the target menu with the transport that carries you there

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

**The catalog refutes its own source's blanket claim and the design must start
from the refutation.** Chandler and Ishak's ML-UMR simulation
([arXiv:2606.20341](https://arxiv.org/abs/2606.20341)) already treats the target
population as a design factor, crosses it with effect-modification strength,
overlap and covariate dependence including a misspecified between-population
correlation, uses two effect measures, and computes true marginal effects
externally from populations of ten million. So "no published PAIC simulation
varies the target" is false, and the count of eight factors is not defensible as
exact or orthogonal.

What is genuinely unmapped is narrower: **the interaction between a wider target
menu and the correctness of the second-stage transport, with uncertainty in the
reported target moments, and truth judged against a declared decision estimand
rather than against the estimator's own implicit target.**

The catalog's note also says this should follow smaller studies because the
design and interpretation are too large for a credible short execution. This
design accepts that: it is a fractional factorial by construction, not a full
crossing dressed up as one.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a simulation that defines truth by the estimator's
own implicit target makes target-mismatch error invisible, so an estimator that
answers the wrong question scores as unbiased; and no study crosses the full
target menu with second-stage transport correctness and target-moment
uncertainty.

**Refuting sentence:** *target-mismatch error and estimation error move together
across the realistic menu, so scoring against each estimator's native estimand
gives the same method ranking as scoring against a declared decision estimand,
and the extra factors change nothing that matters.*

**Because comparative simulations are the main evidence used to recommend
methods, this metric choice propagates directly into method-selection guidance.**
That is the reason the study is worth its size.

## 2. The mechanism: two errors that a native-estimand metric adds together

Let $\Delta(F)$ be the marginal effect in population $F$. Write $F_D$ for the
declared decision target, $F_E$ for the estimator's native target, and
$\hat\Delta_E$ for its estimate. Then

$$\hat\Delta_E - \Delta(F_D) \;=\; \underbrace{\big\{\hat\Delta_E - \Delta(F_E)\big\}}_{\text{estimation error}} \;+\; \underbrace{\big\{\Delta(F_E) - \Delta(F_D)\big\}}_{\text{target-mismatch error}} .$$

Three consequences:

1. **Scoring against $F_E$ measures only the first term and returns zero for the
   second by construction.** An estimator with a native target far from the
   decision target is then unbiased by definition. That is the catalog's central
   point and it is an identity, not an empirical claim.
2. **The mismatch term is a property of the populations and the modification
   structure, not of the sample size**, so it does not shrink with $n$ and will
   not appear in any coverage statement that conditions on the native target.
   **A method can be consistent and wrong.**
3. **Second-stage transport is what maps $F_E$ to $F_D$**, so its correctness
   determines whether the second term is removed or replaced by a different one.
   Crossing the menu against transport correctness is therefore crossing "how far
   apart are the two targets" against "does the machinery that closes the gap
   work", and section 2 predicts a strong interaction: correct transport should
   flatten the mismatch term across the whole menu, and misspecified transport
   should make it worse than doing nothing for the most distant targets.

**Prediction 3 is the study**, and it is testable in a way that reporting bias
against a native estimand can never be.

## 3. Estimand, with its true value defined

**Primary.** The marginal treatment effect in the **declared decision target
population**, fixed in advance and independent of any estimator.

**True value computed externally**, following Chandler and Ishak: from simulated
populations large enough that Monte Carlo error in the truth is negligible
relative to the smallest effect difference the design must resolve. **The
population size is derived in P1 from that requirement rather than copied**; ten
million is their number for their design, not a constant of nature.

**Every estimator's native estimand is also defined and its truth computed**, so
the two terms in section 2 are reported separately. **This is the study's
methodological contribution and it is a reporting structure, not an estimator**:
report each method's error for its own native estimand *and* against the declared
decision estimand, so target-mismatch error and estimation error can be read
apart.

## 4. Data-generating mechanism, and what it makes invisible

**Chandler and Ishak's design is held fixed and extended**, so the increment is
identifiable and the results are comparable to theirs rather than to a new
mechanism. Their factors keep their levels; the new factors are added.

### Factors carried over

Effect-modification strength, population imbalance, covariate dependence
including a misspecified between-population correlation, two effect scales.

### Factors added

| factor | levels | why |
|---|---|---|
| target menu | index; comparator; pooled; registry; overlap population | the wider menu; the last three are absent from every published design |
| second-stage transport | correct; misspecified in the covariate model; misspecified in the target moments | **the crossing that does not exist** |
| target-moment uncertainty | exact; $n_T = 500$; $n_T = 100$ | **no study varies this at all** |
| effect-modification **form** | linear; nonlinear | the catalog's instruction to separate form from sharing rather than treating four levels as mutually exclusive |
| effect-modification **sharing** | shared across treatments; treatment-specific | the other half of that separation |

**Fractional factorial, resolution declared.** A full crossing is not run and the
design says which interactions are aliased with which. **The catalog explicitly
criticizes the source's eight-factor count as neither exact nor orthogonal, so
this design must not repeat that**: the alias structure is stated in the protocol,
and any interaction the primary outcome depends on is estimable in the chosen
fraction. P2 verifies that.

### What the mechanism makes true, and therefore what the study cannot see

- Target choice, overlap and distributional difference **cannot always be varied
  independently**; the catalog says so and it is true. The fraction is chosen so
  that the confounded pairs are known and named, and no interaction between two
  non-independent factors is interpreted.
- Network geometry, baseline risk and censoring are held fixed. The catalog names
  them as equally material and they are not in this study; that is a scope
  statement, not an oversight, and DIA-07 owns topology.
- ML-UMR only, following the source design. Extending the menu across estimator
  families as well would multiply an already large design and is DIA-06's and
  MOD-09's territory.
- The declared decision estimand is chosen by the design, which presupposes the
  target-declaration discipline the field does not enforce. **That presupposition
  is the point**: the study measures what is lost by not having it.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| ML-UMR, native target | as in the source | the baseline |
| ML-UMR + second-stage transport, correct | transport to the declared target | the intended workflow |
| ML-UMR + second-stage transport, misspecified | two misspecification modes | the realistic workflow |
| no second stage, declared target ignored | report the native estimand and call it the answer | **current practice, and the thing being measured** |
| target-moment propagation | EST-07's variance route applied to the second stage | whether the third new factor is handled by existing machinery |

**The comparator that can win is "no second stage".** If reporting the native
estimand gives the same method ranking as the declared-estimand metric across the
menu, then the metric choice does not propagate into guidance, the refuting
sentence holds, and the field's current practice is defensible. Registered as
such, and it is the outcome that would make this study a negative result worth
publishing.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, RMSE and coverage **against the declared decision estimand** for every
method, and **separately** each estimator's error against its own native
estimand. The two are reported side by side in every table; reporting only one is
the practice under test.

**The registered decomposition:** the share of total RMSE attributable to
target-mismatch versus estimation, per cell, from section 2's split. That share is
what tells a reader whether choosing the right target matters more than choosing
the right estimator, which is the guidance question underneath all of this.

**Method ranking agreement** between the two metrics, as a rank correlation
across methods within each cell, is the primary outcome's currency.

Common random numbers across methods and across transport-correctness levels;
MCSE clustered on the replicate block. $n_{sim} = 1000$ per cell, following the
source's 500 doubled, with the coverage MCSE stated.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Rank correlation between the method ordering under the
native-estimand metric and under the declared-decision-estimand metric, across
the target menu, at misspecified second-stage transport.

**Decision rule.**

- Rank correlation materially below 1 in a substantial fraction of cells
  **confirms** that the metric choice changes guidance, and the deliverable is
  the dual-reporting requirement.
- Rank correlation at or near 1 throughout **refutes** it; the field's practice is
  vindicated on this axis and the study says so plainly.
- **The mismatch share from section 6 is reported in either branch**, because it
  answers the guidance question independently of which metric wins.

## 8. Three controls, each of which can fail

**Null control.** When the declared decision target **is** the estimator's native
target, section 2 makes the mismatch term exactly zero and the two metrics must
coincide identically, not approximately. A discrepancy there is an implementation
fault in the truth computation, which is the most likely place for one in a design
that computes several truths.

**Second null control.** With **no effect modification**, $\Delta(F)$ is constant
across populations, so every target in the menu has the same truth and the whole
menu collapses. Every method must be unbiased against every target. **This is the
cheapest possible check that the menu is implemented as a set of genuinely
different populations rather than as relabeled copies.**

**Positive control.** At the most distant menu member (registry or overlap
population) with strong treatment-specific modification, the native-estimand
metric must score a method as unbiased that the declared-estimand metric scores as
badly biased. **If that inversion cannot be produced, section 2's identity is not
reachable at realistic magnitudes and the study's premise fails.**

**Falsifier for the study's own headline.** The expected headline is that the
menu and transport correctness interact. Its falsifier is correct second-stage
transport: there the mismatch term should be removed across the whole menu, so
the two metrics should agree. If they disagree even under correct transport, the
transport is not doing what it is supposed to and the interpretation changes
entirely.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Repeating the source's blanket claim that no study varies the target | Stated as refuted in the header; Chandler and Ishak's design is the base | removed |
| An eight-factor count presented as orthogonal when it is not | Fractional factorial with a declared resolution and named aliases; P2 verifies estimability of the interactions used | removed |
| Truth defined by an estimator's implicit target | Declared decision estimand fixed independently; native estimands also computed | removed |
| Truth's own Monte Carlo error | External population size derived in P1 from the smallest difference to resolve | removed |
| Effect modification as four mutually exclusive levels | Split into form and sharing, per the catalog | removed |
| Factors that cannot be varied independently, interpreted as if they could | Confounded pairs named; no interaction between them interpreted | removed |
| Design too large to summarize, so results become a table nobody reads | Primary outcome is a single rank correlation; the decomposition is the secondary | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** external truth precision | The population size at which truth's Monte Carlo error is below a declared fraction of the smallest effect difference the design must resolve | The truth computation, and the whole design's resolution | hours |
| **P2** fraction estimability | That every interaction the primary outcome depends on is estimable in the chosen fraction, and which factor pairs are non-independent | **The design.** A fractional factorial whose key interaction is aliased answers nothing, and the catalog has already caught one factor count that did not survive scrutiny | days |
| **P3** menu realizability | That the five menu members are genuinely different populations at the chosen overlap levels, verified by their truths differing | The menu. Two menu members with the same truth are one member | hours |
| **P4** unit cost | Per-replicate cost across the fraction; total computed not typed | The fraction's size | hours |

## 11. Cost

The largest design in the queue by cell count even as a fraction, which is why
the catalog says it should follow smaller studies. **This design agrees and the
ordering is part of it**: EST-07 should have run first, because its target-moment
variance machinery is imported here rather than rebuilt.

No total quoted until P2 and P4.

---

## Relationship to the rest of the queue

- **EST-07** and **MIS-03** own target-moment uncertainty and supply the machinery
  for this design's third new factor; they run first.
- **DIA-06** and **MOD-09** own cross-family estimator comparison, which this
  study deliberately does not attempt.
- **DIA-07** owns network topology in scenario grids, held fixed here.
- **EST-12** owns treatment hierarchies without a declared target referent, which
  is the ranking-level version of section 2's identity.
- **DIA-08** owns the observation that PAIC simulations generate only shared,
  linear effect modification, which is exactly why this design splits form from
  sharing.
