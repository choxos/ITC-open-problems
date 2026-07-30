# QBA-24 design: a hazard-scale sensitivity parameter does not translate

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note narrows this to an RMST-focused version and defers the
multi-endpoint agenda; this design does that. It also carries the entry's own two
corrections. **Differing follow-up alone does not invalidate a hazard ratio when
proportional hazards holds and that ratio is the prespecified estimand.** And
`cpaic` labels reconstructed rows as pseudo-IPD and discloses that reconstruction
uncertainty is not propagated, **which refutes the blanket claim that current
practice treats reconstructed data as observed IPD.**

Section 2 makes the entry's central point exact, and it is stronger than it looks.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** when proportional hazards is implausible, a QBA
reporting only a hazard ratio does not answer the decision question; sensitivity
should target the survival functional the decision uses; the subject-level
data-augmentation route assumes subject-level data for both groups, which the
comparator side of an unanchored PAIC does not have; and where pseudo-IPD is
reconstructed, its error is a distinct layer.

**Refuting sentence:** *a hazard-scale bias parameter induces a monotone,
approximately proportional distortion of RMST, so a hazard-ratio sensitivity
analysis can be reinterpreted on the decision scale and no new bias model is
needed.*

## 2. The mechanism: the map from hazard bias to RMST is not a function of the bias alone

Let a bias parameter $\gamma$ act on the hazard, $h^\star(t) = h(t)e^{\gamma}$.
Then

$$\mathrm{RMST}^\star(\tau) = \int_0^\tau \exp\left\{-e^{\gamma}\!\int_0^u h(s)\,ds\right\} du,$$

so the induced change in RMST depends on **the entire baseline hazard $h$ and on
the window $\tau$**, not only on $\gamma$. Three consequences:

1. **The same $\gamma$ produces different RMST distortions in two studies with
   different baseline shapes**, so a sensitivity statement calibrated on the hazard
   scale does not transfer to the RMST scale even within one analysis, let alone
   across analyses. The refuting sentence is therefore false in general, and the
   study's job is to measure whether it is false enough to matter.
2. **The distortion saturates.** As $e^{\gamma}$ grows, survival falls toward zero
   inside the window and RMST approaches a floor, so RMST is **less** sensitive to
   large hazard bias than a proportional reading would suggest, and **more**
   sensitive to small bias when events are concentrated early. **The direction of
   the error in a reinterpreted analysis therefore flips with the baseline shape**,
   which is worse than a consistent bias because no correction factor exists.
3. **Under non-proportional hazards there is no single $\gamma$ to begin with.**
   The bias acts on a time-varying quantity, and summarizing it as one number is
   the same least-false-parameter problem OUT-11 solved for the transported hazard
   ratio and CMP-18 finds for component effects. **This entry is that problem in
   the QBA layer**, and the truth is defined accordingly.

**A separate and practical point the entry makes and nobody exploits:** landmark
survival and in-window RMST **can be estimated from a published Kaplan-Meier curve
without reconstructing pseudo-IPD at all.** That removes the reconstruction layer
entirely for those estimands. **So the design carries a curve-based arm alongside
the pseudo-IPD arm**, and comparing them measures exactly what reconstruction
costs when it was not necessary.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference at a declared window, and
landmark survival differences at declared times.

**True value** by exact integration of the generating survival functions over the
target covariate law.

**The bias parameter is defined on the decision scale**, not the hazard scale:
$\gamma_{\mathrm{RMST}}$ is the shift in the target RMST induced by the unmeasured
confounder. **That is the entry's own recommendation and it is what makes the
sensitivity surface interpretable**; the hazard-scale parameterization is carried
as a comparator so section 2's translation failure is measured rather than
asserted.

**The tipping combination** of exposure and survival associations is a derived
estimand, reported as a set following CMP-21's treatment rather than as a point.

## 4. Data-generating mechanism, and what it makes invisible

Unanchored PAIC with an unmeasured prognostic confounder, survival outcome.

### Factors

| factor | levels | why |
|---|---|---|
| baseline hazard shape | constant; increasing; decreasing; bathtub | **section 2 consequence 2**, which is where the reinterpretation error flips sign |
| proportional hazards | holds; delayed; crossing | the entry's premise |
| confounder strength | 3 levels | the sensitivity axis |
| overlap | good, poor | the adjustment layer |
| censoring | administrative; heavier early | changes the window's information |
| **data availability on the comparator side** | subject-level; published curve only; reconstructed pseudo-IPD | **the design's central axis**, and the one the existing method cannot cross |
| reconstruction quality | fine at-risk table; coarse; none | imported from CMP-17's factors |

### What the mechanism makes true, and therefore what the study cannot see

- **Multi-endpoint agenda deferred.** Cumulative incidence under competing risks,
  cure fraction, recurrent-event burden and multistate occupancy are named by the
  entry and are **not** here; DIA-09 owns those estimands and this design would
  import them.
- Informative censoring is added only where plausible, not by default, following
  the entry's instruction. OUT-07 owns it.
- One unmeasured confounder. QBA-22 owns joint mechanisms.
- The subject-level arm is the existing method's home ground and is included so
  the comparison is fair; **its advantage there is expected and is not the
  result.**

## 5. Methods, including one that can win

| method | role |
|---|---|
| hazard-scale QBA, reinterpreted for RMST | current practice, and section 2 says it should fail |
| **RMST-scale bias model, subject-level** | Soutar et al.'s data-augmentation route on its own ground |
| **RMST-scale bias model, curve-based** | the extension to a published Kaplan-Meier curve with no reconstruction |
| **RMST-scale bias model, reconstructed pseudo-IPD** | the extension where reconstruction is unavoidable |
| reconstructed with a **distribution over reconstructions** | reconstruction uncertainty propagated jointly with the confounding parameters, which is the entry's own proposal |

**The comparator that can win is the curve-based arm.** If it matches the
subject-level route for RMST and landmark survival, then **reconstruction is
unnecessary for exactly the estimands the decision uses**, and the recommendation
is to stop reconstructing for them. That would be the most useful outcome
available here and it is registered as such.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and width of the RMST and landmark contrasts per method per cell,
with MCSE; **tipping-set recovery** against the known truth.

**The translation-error measure, which is section 2 made a number:** the difference
between the RMST distortion implied by reinterpreting a hazard-scale analysis and
the true RMST distortion, **reported by baseline shape**, so consequence 2's sign
flip is visible rather than averaged away.

**Reconstruction's cost**, as the difference in interval width between the
curve-based and reconstructed arms at matched settings. **That is a clean measure
of what a needless reconstruction costs** and it is available only because both
arms are here.

$n_{sim} = 2000$; the reconstruction-ensemble arm multiplies by its ensemble size,
set in P3.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Translation error of the reinterpreted hazard-scale analysis
against the true RMST distortion, across baseline shapes, under non-proportional
hazards.

**Decision rule.**

- Translation error large and **sign-varying across baseline shapes** confirms
  section 2 and establishes that the bias model must be specified on the decision
  scale, which is the entry's central recommendation.
- Translation error small and monotone refutes it: reinterpretation is adequate
  and no new bias model is needed.
- **The curve-versus-reconstruction comparison is reported in either branch**,
  because it answers a separate question and would change practice on its own.

## 8. Three controls, each of which can fail

**Null control.** With a constant baseline hazard and proportional hazards, the
hazard-to-RMST map is a known monotone function, so reinterpretation must be
accurate. **That is the one configuration where the refuting sentence is true, and
confirming it validates the translation machinery** before it is used to show
failure elsewhere.

**Second null control.** With zero confounder strength, every method must be
unbiased and every sensitivity curve flat. **A sloping curve at zero bias means
the QBA is manufacturing sensitivity**, the same cheap check QBA-13 uses.

**Positive control.** Bathtub baseline with crossing hazards and strong
confounding: reinterpretation must fail by more than three MCSEs. If it does not,
section 2's mechanism is unreachable and the study says so.

**Falsifier for the study's own headline.** The expected headline is that the bias
model must live on the decision scale. Its falsifier is the saturation in section
2 consequence 2: **if RMST is so insensitive to large hazard bias that the
decision never changes over the plausible confounding range, then the estimand is
robust and the parameterization question is moot for it.** That would be a
reassuring finding and the design must be able to reach it.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming practice treats reconstructed data as observed | The entry's own correction carried in the header | removed |
| Claiming differing follow-up invalidates a hazard ratio | The entry's correction carried; PH cells included | removed |
| Reconstruction used where it is unnecessary | Curve-based arm carried and its cost measured | removed |
| Comparing methods on the subject-level arm's home ground only | Data-availability is the central axis | removed |
| Translation error averaged across baseline shapes | Reported by shape, since the sign flips | removed |
| Multi-endpoint agenda | Deferred per the note; DIA-09 named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and the translation map | The true RMST distortion induced by each hazard-scale $\gamma$ under each baseline shape | **The primary outcome's comparison**, which is against a computed map | hours |
| **P2** curve-based estimability | That landmark survival and in-window RMST are recoverable from a published curve at realistic reporting resolution | **Whether the comparator that can win exists** | days |
| **P3** ensemble size | The reconstruction-ensemble size at which pooled inference stabilizes | The budget | hours |
| **P4** unit cost | Per-replicate cost across four arms plus the ensemble; total computed not typed | $n_{sim}$ | hours |

## 11. The case-study half

The queue records this as simulation **plus case study**: a published unanchored
PAIC reanalysis, with the sensitivity surface reported on the RMST scale and,
where the published curve permits, computed without reconstruction. **The
comparison of the two routes on real reported data is the part that would change
practice**, and the simulation cannot supply it.

## 12. Cost

Four arms plus a reconstruction ensemble at 2000 replicates. The ensemble is the
multiplier, measured in P3.

---

## Relationship to the rest of the queue

- **OUT-11** owns the least-false hazard ratio under non-proportionality and
  supplies the treatment section 2 consequence 3 imports.
- **CMP-17** owns reconstruction error and supplies this design's reconstruction
  factors; its finding that error concentrates in the tail bears directly on RMST.
- **DIA-09** owns the estimands deferred here.
- **DIA-14** and **QBA-22** own QBA scoring and joint composition.
- **MIS-02** owns censoring-weighted survival transport.
