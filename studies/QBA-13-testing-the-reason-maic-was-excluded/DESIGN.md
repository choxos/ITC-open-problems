# QBA-13 design: the authors gave a reason for restricting to STC, and it is checkable

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note says this is a weak single-study target unless narrowed to a
direct STC-versus-MAIC experiment with explicit assumptions. **The narrowing has an
obvious focal point**: Ren et al. restrict their simulated-covariate QBA to STC and
give a specific, falsifiable reason. A MAIC extension "would suffer extreme
effective-sample-size loss and might fail to produce feasible weights."

**That is a claim about a linear program's feasibility and about a weight
functional, both of which are computable.** Testing it is the study.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** the simulated-covariate route is embedded in an STC and
g-computation workflow and does not transfer to weighting, one-stage or network
estimators; the authors rule out the direct MAIC extension on effective-sample-size
and feasibility grounds; and the claim that no additional assumptions are required
cannot be read literally, since target marginals, dependence, source-to-target
outcome associations, copula form and regression form are all assumed.

**Refuting sentence:** *the MAIC extension is feasible across the realistic range,
its effective-sample-size loss is comparable to the precision the STC route pays
elsewhere, and the restriction was a conservative choice rather than a necessary
one.*

## 2. The mechanism: two separate reasons, and they fail at different points

Simulating an omitted covariate adds a dimension to what MAIC must balance. Two
consequences follow and they are not the same claim.

**Feasibility.** The method-of-moments calibration has a finite solution only if
the target mean vector lies in the convex hull of the source covariate rows. Adding
a simulated covariate adds a coordinate, and **adding a coordinate can only shrink
or preserve the set of achievable target means**, never enlarge it. So feasibility
is monotone in the number of balanced moments and the authors' concern is
structurally correct in direction. **Whether it binds at realistic configurations
is a linear-program question with a yes-or-no answer per replicate**, which is
exactly the instrument OVL-02 builds.

**Effective sample size.** $n/\mathrm{ESS} = 1 + \mathrm{CV}^2(w) =
\mathbb{E}_S[r^2]$, the chi-square divergence between target and source. Adding a
balanced coordinate raises the divergence unless the new coordinate is already
balanced. **So ESS loss is also monotone in direction, and its magnitude depends on
how far the simulated covariate's assumed target mean sits from the source's.**
That is set by the analyst's assumption, not by the data, which makes the ESS loss
a function of the sensitivity parameter itself.

**The consequence that matters:** as the sensitivity parameter is swept, the MAIC
route's precision degrades along the sweep, so **the sensitivity curve's width is
not constant across the curve.** A curve whose intervals widen toward one end can
look like robustness at that end purely because the estimate has become
uninformative. **No published sensitivity curve reports its own effective sample
size along the sweep**, and doing so is one of this design's deliverables.

**On "no additional assumptions."** The route assumes target marginals, a
dependence structure, source-to-target outcome associations, a copula form and a
regression form. **Each is a factor here**, so the design measures which of the
five the answer is actually sensitive to, which converts an overstated sentence
into a ranked list.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal log odds ratio, by quadrature at an
order fixed by P1.

**Two derived estimands.** **Feasibility**, the exact linear-program answer per
replicate with and without the simulated covariate. And **the sensitivity curve's
decision reading**, reported against a **declared clinical or decision threshold**
rather than against a significance boundary, since the catalog notes the case study
read a significance-crossing value off the curve and that is a different and worse
object.

## 4. Data-generating mechanism, and what it makes invisible

Unanchored comparison with one covariate measured in the IPD and unreported by the
comparator.

### Factors

| factor | levels | why |
|---|---|---|
| omitted-covariate prevalence or mean gap | small, moderate, large | drives both feasibility and ESS loss |
| correlation with measured modifiers | 0, 0.3, 0.6 | the assumed dependence, and it changes how much the simulated coordinate adds |
| treatment interaction of the omitted covariate | absent; present | whether omission biases at all |
| source-to-target transport error in the assumed association | none; moderate | the input the authors assume holds in the target and cannot check |
| copula form | correct; misspecified | one of the five assumptions |
| regression form | correct; misspecified | another; and it is the one no covariate-omission analysis can repair |
| overlap | good, poor | the feasibility axis |

### What the mechanism makes true, and therefore what the study cannot see

- **One omitted covariate.** The entry asks for the extension to multiple
  correlated omitted variables and treatment-specific associations; that is named
  as the next step and is not attempted, because the STC-versus-MAIC comparison is
  what the note narrows this to.
- **The underlying estimator's requirements are inherited and are not repaired by
  any sensitivity analysis.** A sufficiently correct outcome model and adequate
  overlap are preconditions, and the misspecification levels exist to show that a
  covariate-omission QBA does not fix them, not to fix them.
- The assumed associations are correct in the base arm, which is favorable to the
  method; the transport-error factor is what removes that favor.
- Two-trial pairwise only. Network and one-stage extensions are named as the
  broader gap and are out of scope.

## 5. Methods, including one that can win

| method | role |
|---|---|
| simulated-covariate QBA on STC | Ren et al.'s published route |
| **simulated-covariate QBA on MAIC** | the extension the authors excluded, built and tested |
| MAIC with feasibility screening | the extension plus OVL-02's linear program, declining where infeasible |
| sensitivity-adjusted MAIC via a bias parameter on the estimate | the cheaper route that does not add a balanced coordinate |
| no QBA | the floor |

**The comparator that can win is the STC route.** If MAIC's extension is infeasible
or ruinously imprecise across the realistic range, the authors' restriction is
vindicated, and **that is a useful result: it converts a stated concern into
evidence** and tells the field not to spend effort there. Registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage, RMSE and interval width per method per cell, with MCSE.

**Feasibility rate** with and without the simulated coordinate, and **ESS along the
sensitivity sweep**, reported as a curve beside the estimate curve. **That pairing
is the study's most portable output**, because it makes visible when apparent
robustness is really loss of information.

**Assumption sensitivity, ranked:** the change in the decision reading induced by
each of the five assumed inputs, on a common scale, so "no additional assumptions"
is replaced by an ordering.

**Calibration failure**, meaning the rate at which the sensitivity region excludes
the truth, following DIA-14's measures rather than redefining them.

$n_{sim} = 2000$ per cell.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Feasibility rate and interval width of the MAIC extension
across the sensitivity sweep, at moderate overlap.

**Decision rule.**

- Infeasibility at a substantial rate, or width growth making the curve
  uninformative over part of the sweep, **confirms** the authors' restriction and
  the deliverable is the quantified reason plus the ESS-alongside-curve reporting
  requirement.
- Feasible and comparably precise throughout **refutes** it, and the extension
  becomes available, which is what the entry asks for.
- Feasible but with width growing along the sweep: **both are true**, and the
  recommendation is the extension **with** the ESS curve reported, since without it
  the sweep would be misread.

## 8. Three controls, each of which can fail

**Null control.** With the omitted covariate having no treatment interaction, its
omission cannot bias the target effect, so every method must be unbiased at every
sensitivity-parameter value and the curve must be flat. **A sloping curve there
means the QBA is manufacturing sensitivity**, which is the cheapest possible check
on a sensitivity analysis and is not standard practice.

**Second null control.** With the simulated covariate's assumed target mean equal
to the source's, adding the coordinate changes nothing: feasibility and ESS must
be unchanged to numerical precision. **This isolates the coordinate-addition
mechanism from the assumed-mean mechanism**, which section 2 says are different.

**Positive control.** Large mean gap, poor overlap, strong interaction: the MAIC
extension must show either infeasibility or substantial ESS loss. If neither
appears, the authors' concern is unreachable in this generator and the study
reports that its refutation is conditional on the configurations simulated.

**Falsifier for the study's own headline.** The expected headline is that the
restriction was justified. Its falsifier is the feasibility-screened arm: if
declining where infeasible leaves a usable method on the remaining replicates, the
restriction was unnecessary and the right answer is a screen rather than an
exclusion. **That arm exists because it is the outcome that would overturn the
expected result.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Taking "no additional assumptions" at face value | Five assumed inputs are factors and are ranked | removed |
| Reading the sensitivity curve at a significance boundary | Decision reading against a declared threshold | removed |
| Apparent robustness from lost precision | ESS reported along the sweep beside the estimate | removed |
| A covariate-omission QBA credited with repairing misspecification | Misspecification levels present and explicitly not repaired | removed |
| Feasibility asserted rather than computed | Linear program per replicate, from OVL-02 | removed |
| Multiple omitted covariates | Named as next step, out of scope | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | minutes |
| **P2** feasibility reachability | The infeasibility rate with the added coordinate across the planned grid, before any fitting | **Whether the primary outcome has a signal.** If infeasibility never occurs, the design must move to the ESS half or change the grid | hours |
| **P3** reproduction | That the implemented STC route reproduces Ren et al.'s published behavior on their own conditions | Whether the base arm is a comparator or a confound | days |
| **P4** unit cost | Per-replicate cost across the sweep; total computed not typed | The sweep resolution | hours |

## 11. Cost

The sensitivity sweep multiplies every arm. Modest overall, since these are
weighting and GLM fits, but the sweep resolution is the term to set in P4 rather
than by eye.

---

## Relationship to the rest of the queue

- **OVL-02** supplies the convex-hull feasibility linear program used here.
- **DIA-14** supplies the calibration and classification measures.
- **QBA-22** owns joint bias composition; this design has one mechanism.
- **QBA-11** owns what double robustness does not cover, and shares the point that
  a sensitivity analysis cannot repair a misspecified retained model.
- **MOD-01** owns the copula reconstruction whose form is one of the five assumed
  inputs here.
