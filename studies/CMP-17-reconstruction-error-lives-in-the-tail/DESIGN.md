# CMP-17 design: an exact likelihood evaluated on data whose provenance is a picture

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note is a scheduling instruction and this design accepts it: a
credible simulation and a non-decorative reanalysis both need a reconstruction
pipeline, which is why this is not a first study. **Section 2 predicts where the
error lands, and it is the place the estimands are most sensitive.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** component survival models condition on pseudo-IPD
reconstructed from digitized Kaplan-Meier curves and at-risk tables as if event
and censoring times were observed, with no reconstruction-error layer; the
existing ensemble machinery propagates subgroup-label ambiguity rather than
pixel-level curve reading or at-risk-table rounding; and the reported precision
overstates what the data support.

**Refuting sentence:** *reconstruction error averages out over a curve's many
points, so it perturbs the fitted survival function far less than sampling error
does and propagating it would change no interval materially.*

## 2. The mechanism: the error is worst where the estimand is most sensitive

The Guyot algorithm inverts the Kaplan-Meier estimator: given the digitized
survival curve and the reported at-risk numbers, it solves for the event and
censoring counts in each interval. In interval $j$ with at-risk count $n_j$ and
observed drop $\Delta S_j$, the implied event count is approximately

$$d_j \;\approx\; n_j \cdot \frac{\Delta S_j}{S_{j-1}} .$$

Three consequences, and the third is the design:

1. **At-risk numbers are reported rounded and at coarse times**, so $n_j$ carries
   an error of order 1. The induced error in $d_j$ is proportional to $\Delta
   S_j / S_{j-1}$, and the **relative** error in $d_j$ is of order $1/n_j$.
2. **$n_j$ shrinks along the curve.** So the relative reconstruction error grows
   monotonically with follow-up time, and is largest in the tail.
3. **RMST and late milestone survival are integrals weighted toward the tail**,
   which is exactly where the error is largest. **So the estimands that survive
   non-proportionality, and which OUT-11 and DIA-09 argue should be the default
   survival estimands, are the ones most exposed to reconstruction error.** That
   is not a coincidence to note in discussion; it is the study's central
   prediction.

**A fourth consequence, and it is why this error does not behave like the others
in this program:** the two arms are reconstructed from **different curves**, so
their errors are independent. Nothing cancels in the contrast. Most error sources
examined in this queue cancel to first order between arms (CMP-20's exposure
covariance, MOD-16's pooled matching, MOD-02's common prognostic
misspecification). **This one does not, and that alone makes it worth measuring
rather than assuming small.**

**And the exact-likelihood irony is real.** The implemented route rejects
event-count and person-time summaries as insufficient, demanding exact individual
survival contributions. **So the model is at its most demanding about data whose
provenance is a picture**, and the design measures whether that demand buys
anything once the provenance is modeled.

## 3. Estimand, with its true value defined

**Primary.** The target-population RMST difference at a declared horizon, and
milestone survival differences at early and late times, since section 2 predicts
they behave differently.

**True value** from the generating survival model by exact integration.

**Two derived estimands.** **Precision survival**: the ratio of the interval width
under propagation to the width under conditioning on one reconstruction, which the
catalog names as the number a decision maker needs. And **reconstruction error
itself**, the difference between reconstructed and true event times, reported by
follow-up quantile so section 2 consequence 2 is checked rather than assumed.

## 4. Data-generating mechanism, and what it makes invisible

The pipeline is simulated end to end: generate event data, **render** it as a
Kaplan-Meier figure with an at-risk table at realistic reporting resolution, then
reconstruct. Rendering rather than short-circuiting is what makes the pixel-level
error real rather than modeled.

### Factors

| factor | levels | why |
|---|---|---|
| at-risk table resolution | every 3 months; every 6 months; none | the dominant error source; "none" is the common oncology case and the worst |
| at-risk rounding | exact; rounded to nearest 1; nearest 5 | section 2 consequence 1 |
| figure resolution | vector; 300 dpi raster; 96 dpi raster | pixel-level curve reading |
| censoring marks | shown; absent | RESOLVE-IPD's own axis; absent forces the uniform-censoring assumption |
| sample size | 150, 400 per arm | $n_j$ in section 2 consequence 2 |
| follow-up maturity | 40%, 70% events | how far into the tail the estimand reaches |
| effect shape | proportional; delayed | whether the tail carries the signal |

### What the mechanism makes true, and therefore what the study cannot see

- **Digitization is simulated, not performed by a human with a mouse.** Real
  digitization error includes operator variability that no simulation reproduces,
  so the pixel-level component here is a lower bound and the paper must say so.
- Curves are single-arm survival functions without competing risks. DIA-09 owns
  competing risks, where the reconstruction problem is harder still.
- The reported at-risk table is internally consistent with the curve. Published
  tables sometimes are not, and an inconsistent table is a different and larger
  problem.
- One component network geometry, so the reconstruction error's effect on the
  bridge is measured at one topology only.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| single reconstruction | one Guyot run, treated as observed data | current practice |
| **ensemble over labelings** | RESOLVE-IPD's machinery | what exists, propagating subgroup-label ambiguity |
| **ensemble over reading and rounding** | multiple reconstructions perturbing pixel reading and at-risk rounding, pooled | the extension the catalog asks for |
| **Bayesian measurement model** | pixel reading and rounding as explicit error distributions inside the posterior | the principled version |
| oracle IPD | the true event times | the ceiling, so the total cost of reconstruction is visible |

**The comparator that can win is the single reconstruction.** If its intervals
already cover nominally because reconstruction error is small relative to sampling
error, the refuting sentence holds and the recommendation is that propagation is
unnecessary. Registered as such.

**Ensemble and Bayesian arms are separated deliberately.** An ensemble propagates
by re-running; a measurement model propagates inside the posterior. **If they
agree, the cheap one is the recommendation**, and that comparison is worth more
than either alone.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias, coverage and width of the RMST and milestone contrasts per method, with
MCSE; **precision survival** from section 3; **reconstruction error by follow-up
quantile**, which tests section 2 consequence 2 directly.

**The registered mechanism check:** reconstruction error's relative magnitude
regressed on $1/n_j$ across intervals. Slope consistent with section 2 confirms
the mechanism; anything else means the error is dominated by pixel reading rather
than by rounding, which changes which fix matters.

Common random numbers across methods within a replicate, since they analyze the
same rendered figure; MCSE clustered on the replicate block. $n_{sim} = 1000$;
ensemble arms multiply by the ensemble size, priced in P4.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Coverage of the target-population RMST difference under
single reconstruction, at coarse at-risk resolution with mature follow-up, against
the propagating arms.

**Decision rule.**

- Single reconstruction undercovering while a propagating arm is nominal:
  propagation is established, and **precision survival is the reported headline
  number** because that is what a decision maker acts on.
- All arms nominal: the refuting sentence holds and the study says so.
- The propagating arms nominal only by being much wider than the oracle:
  reconstruction is costing real information, and **the cost is the result**
  rather than a nuisance.

## 8. Three controls, each of which can fail

**Null control.** With a vector figure, exact at-risk numbers at every event time
and visible censoring marks, reconstruction is essentially exact, so every method
must agree with the oracle to Monte Carlo error. **If they do not, the pipeline
has an error unrelated to reporting resolution** and nothing downstream is
attributable.

**Second null control.** With no effect and no modification, the reconstruction
errors in the two arms are independent and mean-zero, so the **contrast** must be
unbiased even where each arm's curve is misreconstructed. **That separates a bias
in the contrast from noise in the arms**, and section 2 consequence 4 predicts the
variance inflates while the bias does not.

**Positive control.** No at-risk table, 96 dpi raster, mature follow-up: single
reconstruction must show material error in the late milestone. If the worst
reporting the design can simulate is harmless, propagation is not needed and the
study reports that.

**Falsifier for the study's own headline.** The expected headline is that the
error concentrates in the tail. Its falsifier is the early milestone: if error
there is as large as in the tail, the mechanism is pixel reading rather than
at-risk rounding, and the recommendation changes from "report at-risk tables
finely" to "publish vector figures", which is a different ask of a different
party.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reconstruction short-circuited rather than performed | Figures rendered and re-read | removed |
| Error in arms confused with error in the contrast | Second null control isolates it | removed |
| Ensemble and measurement model conflated | Separate arms; agreement is a registered comparison | removed |
| Precision loss reported as a nuisance | Precision survival is a primary-level output | removed |
| Human digitization variability | Not simulated; results stated as a lower bound | disclosed |
| Inconsistent published at-risk tables | Out of scope, named | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** pipeline validation | That the render-and-reconstruct pipeline recovers the true event times under the null-control settings | **Everything.** A pipeline with its own bias would attribute that bias to reporting resolution | days |
| **P2** error budget | The analytic contribution of rounding and of pixel reading at each factor level, from section 2 | The grid; and which fix the study can speak to | days |
| **P3** ensemble size | The ensemble size at which pooled inference stabilizes, measured rather than assumed | The budget, which the ensemble multiplies | hours |
| **P4** unit cost | Per-replicate cost including reconstruction and the Bayesian arm; total computed not typed | $n_{sim}$ | hours |

## 11. The case-study half

The queue records this as simulation **plus case study**, and the reanalysis is
what makes it non-decorative: recompute a published component comparison with the
reconstruction propagated, and report **how much of its reported precision
survives**. That single number is what the catalog asks for and the simulation
cannot supply it, because it depends on that analysis's actual figures.

## 12. Cost

Reconstruction per replicate times the ensemble size times $n_{sim}$, plus a
Bayesian measurement model. The ensemble multiplier is the line this design would
most easily misprice and it is measured in P3.

---

## Relationship to the rest of the queue

- **OUT-13** owns reconstruction uncertainty from digitized curves in general;
  if it runs first, this study imports its error model rather than building one.
- **OUT-11** and **DIA-09** argue RMST and milestone survival should be the
  default estimands; section 2 says those are the most exposed, so the three
  results have to be read together.
- **CMP-18** owns time-varying component effects, which change how far into the
  tail the estimand reaches.
- **DEC-11** owns what belongs in an interval and lists reconstruction
  uncertainty as unpropagated.
- **CMU-03** notes that an SBC replicate drawn from the coded likelihood cannot
  see reconstruction error at all, which is the same blindness one level up.
