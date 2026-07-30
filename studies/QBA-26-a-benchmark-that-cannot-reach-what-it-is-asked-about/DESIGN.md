# QBA-26 design: scaling a single-variable benchmark to composite omitted structure

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note calls this a strong early simulation because it has clear truth, measurable
diagnostic performance and **an important negative result if calibration fails.**
Section 2 says the negative result is the likely one and gives the reason, which
makes the study a measurement of how badly rather than a search for whether.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a held-out benchmark is limited to what happened to be
measured, so it says how strong an **observed** variable is and never how strong the
unobserved structure is; an omitted composite factor can be stronger than any single
measured variable, so the familiar argument that no measured covariate produces bias
as large as the assumed value establishes nothing without an explicit assumption
linking unmeasured structure to the measured covariates; and no procedure scales a
single-variable benchmark to composite or multivariate omitted structure.

**Refuting sentence:** *in realistic covariate sets the strongest measured variable
is a reasonable upper bound on plausible unmeasured structure, so the familiar
argument is empirically sound even if it is not logically valid.*

## 2. The mechanism: a maximum over singletons is not a bound on a sum

Let the omitted structure be a linear combination $u = \sum_{j\in\mathcal{U}}
\gamma_j x_j$ of $q$ unmeasured variables. Its transport bias is driven by
$\mathrm{Var}(u)$ and by its imbalance, and

$$\mathrm{Var}\Big(\sum_j \gamma_j x_j\Big) \;=\; \sum_j \gamma_j^2\mathrm{Var}(x_j) \;+\; 2\sum_{j<k}\gamma_j\gamma_k\mathrm{Cov}(x_j,x_k),$$

which **exceeds the largest single term whenever the components are positively
correlated and share sign**, and grows roughly as $q$ times the average term when
they are independent. Three consequences:

1. **The held-out benchmark measures $\max_j$ over measured singletons; the omitted
   structure is a sum over unmeasured ones.** A maximum over singletons bounds a sum
   only when $q=1$. **So the familiar argument fails for a reason that is arithmetic
   rather than empirical**, and the refuting sentence can only be true by accident
   of magnitudes.
2. **The gap grows with $q$ and with correlation.** So the design's axes are the
   number of omitted variables and their correlation, and **the benchmark's
   understatement should grow predictably**, which makes it a measurable curve
   rather than a yes-or-no finding.
3. **A scaling rule is derivable if one is willing to assume a link between
   unmeasured and measured structure.** For instance, assuming the unmeasured
   variables have the same average strength and correlation as the measured ones
   gives a multiplier of roughly $\sqrt{q(1+(q-1)\bar\rho)}$ on the single-variable
   benchmark. **That is an explicit assumption rather than a hidden one**, and
   evaluating whether it calibrates is the study's constructive half.

**The negative-control route has a different limit.** It detects rather than
quantifies: a signal may reflect failure of the negative-control assumptions, and a
null signal does not establish absence of bias. **In an unanchored PAIC the
comparator is published aggregate data in which no negative-control outcome is
typically reported**, so the diagnostic is usually unavailable on the side where it
is needed. The design carries it as a second arm with that availability as a factor,
and does not pretend the conversion to a bias range exists.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect after unanchored
adjustment, by quadrature at an order fixed by P1.

**The residual bias is known by construction**, which is what makes diagnostic
performance measurable.

**Two derived estimands.** The **benchmark's implied bias range**, from the held-out
procedure, and the **scaled range** under section 2 consequence 3's assumption.
**Calibration of each against the true residual bias is the primary outcome**, and
an interval that contains by being wide is reported with its width.

## 4. Data-generating mechanism, and what it makes invisible

Unanchored comparison with measured and unmeasured prognostic structure.

### Factors

| factor | levels | why |
|---|---|---|
| number of omitted variables $q$ | 1, 3, 6 | **consequence 2**; $q=1$ is where the familiar argument is valid |
| correlation among omitted variables | 0, 0.3, 0.6 | the other half of consequence 2 |
| omitted strength relative to the strongest measured variable | 0.5, 1, 2 | whether the benchmark's premise even holds per variable |
| prevalence of omitted binary factors | 0.1, 0.4 | the entry's own axis |
| negative-control validity | valid; invalid, sharing no confounding; **unavailable** | consequence 3's second route, with unavailability as a level |
| overlap | good, poor | the adjustment layer |

### What the mechanism makes true, and therefore what the study cannot see

- **The omitted structure is generated, so its strength is known.** In practice
  nobody knows it, which is the entire problem; **the study measures how far a
  benchmark is from a truth the analyst cannot see**, and cannot tell them what to
  assume.
- The held-out benchmark is run by **rerunning the whole PAIC procedure**, per the
  catalog's instruction, accounting for the held-out variable's scale, prevalence,
  role and correlation with the retained ones. **A benchmark that only refits the
  outcome model is a different and weaker procedure** and is carried as a comparator
  so the difference is visible.
- Negative-control assumptions are either exactly satisfied or exactly violated. Real
  controls are somewhere between and the design does not represent that.
- One bias mechanism, omitted prognostic structure. QBA-22 owns composition across
  mechanisms.

## 5. Methods, including one that can win

| method | role |
|---|---|
| held-out benchmark, full procedure rerun | Yi and Jiang's route, done as the catalog specifies |
| held-out benchmark, outcome model only | the weaker version, for contrast |
| **scaled benchmark under consequence 3's assumption** | the constructive proposal |
| negative-control detection | the second route, detecting not quantifying |
| E-value | the assumption-free comparator that also does not use the benchmark |
| no diagnostic | the floor |

**The comparator that can win is the unscaled held-out benchmark.** If its implied
range contains the true residual bias across the $q$ and correlation axes, the
refuting sentence holds empirically and no scaling is needed. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

**Calibration**: containment rate of each implied bias range, with width;
**sensitivity and specificity** for the binary question of whether residual bias
exceeds a declared material threshold; **the understatement factor**, the ratio of
true residual bias to the benchmark's implied maximum, **reported against $q$ and
correlation** so consequence 2's curve is visible.

**The registered mechanism check:** the understatement factor against
$\sqrt{q(1+(q-1)\bar\rho)}$. **Agreement would mean the scaling rule is right and
deployable**, which is the best available outcome; disagreement means the assumption
linking unmeasured to measured structure is wrong in a specific way that can be
reported.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** The understatement factor of the held-out benchmark at $q=6$
with correlation 0.6, and the containment rate of the scaled range at the same
settings.

**Decision rule.**

- Understatement growing with $q$ as predicted, and the scaled range calibrating:
  **the deliverable is the scaling rule with its assumption stated**, and the
  familiar single-variable argument is retired.
- Understatement growing but the scaled range failing: **the negative result the
  note anticipates**, and the deliverable is that held-out benchmarking cannot be
  calibrated to composite omitted structure and should be reported as calibration by
  analogy, neither an upper nor a lower bound.
- No understatement at any $q$: refuted, and the familiar argument is empirically
  sound.

## 8. Three controls, each of which can fail

**Null control.** At $q=1$ with the omitted variable's strength equal to a measured
one, section 2 makes the benchmark's premise exactly right, so its implied range
must contain the true bias. **That is the one configuration where the familiar
argument is valid, and confirming it licenses the failure elsewhere.**

**Second null control.** With no omitted structure, every diagnostic must report no
material bias, and the negative-control arm must not fire above its nominal rate.
**A diagnostic that manufactures bias where there is none is worse than one that
misses it**, and its false-positive rate is measured rather than assumed low.

**Positive control.** $q=6$, correlation 0.6, strengths at twice the strongest
measured variable: true residual bias must exceed the material threshold and the
unscaled benchmark must miss it. If it does not miss it, consequence 1 is not
operative at reachable magnitudes.

**Falsifier for the study's own headline.** The expected headline is that the
benchmark understates composite structure. Its falsifier is the correlation axis at
**negative** correlation: **there the components partly cancel and the sum can be
smaller than the largest singleton, so the benchmark would overstate.** That case is
in the grid, because a diagnostic that errs in both directions is a different
problem from one that errs in one, and the recommendation differs.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Benchmark run as an outcome-model refit rather than a full rerun | Both carried; the catalog's version is primary | removed |
| A scaling rule proposed without stating its assumption | The assumption is stated and is what is tested | removed |
| Negative control presented as quantifying | Carried as detection only; unavailability is a factor level | removed |
| Understatement assumed one-directional | Negative correlation in the grid as the falsifier | removed |
| Diagnostic false positives ignored | Second null control measures them | removed |
| Omitted structure known to the design | Stated as the limit; the study measures distance from an invisible truth | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and residual bias | The true residual bias per cell, analytically | The grid; cells below Monte Carlo resolution are dropped | hours |
| **P2** attainable strengths | Whether the requested $(q, \bar\rho, \text{strength})$ triples are jointly realizable with valid covariance matrices | **The grid.** A requested correlation may be infeasible at the given $q$ and would be silently projected | hours |
| **P3** material threshold | The bias magnitude a decision would notice | Every calibration result | hours |
| **P4** unit cost | Per-replicate cost including the full-procedure rerun; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

The full-procedure rerun multiplies each replicate by the number of held-out
variables. That multiplier is the line to price rather than assume.

---

## Relationship to the rest of the queue

- **DIA-14** owns QBA scored as a classifier and supplies the calibration measures.
- **QBA-22** owns composition across bias mechanisms; this design has one mechanism
  with composite structure inside it, which is a different kind of compounding.
- **QBA-11** owns what double robustness does not cover.
- **IDN-09** owns negative controls for ITC generally, including their catalogues
  and power, which is the second route taken seriously.
- **DEC-11** owns what belongs in an interval; a benchmark-implied bias range is
  structural and belongs beside one.
