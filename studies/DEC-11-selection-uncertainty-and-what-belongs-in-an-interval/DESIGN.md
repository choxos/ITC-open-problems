# DEC-11 design: which uncertainties belong in the interval, and one that does and is missing

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog closes half of this entry itself. The estimated-weights component is
solved and evaluated: Chandler and Proskorovsky 2024 compared four families of
MAIC variance estimator across 108 scenarios and give guidance by overlap,
effective sample size and outcome type. **Adopting that guidance rather than
re-deriving it is the first instruction**, and this design does.

It also draws a line the field does not: numerical integration error is a
deterministic approximation error, so the fix is bounding and convergence
assessment rather than treatment as another variance component; and bridge
uncertainty is structural rather than sampling-based and belongs in separate
sensitivity or tipping analysis unless a defensible probability model supports
joint propagation. **This design accepts that taxonomy and tests the one
remaining component that is unambiguously sampling error and unambiguously
unpropagated: model selection carried out on the analyzed data.**

---

## 1. The claim, restated as something that can be false

**Proposition under test:** an interval computed after a selection step performed
on the analyzed data is too narrow; no ITC reporting convention requires selection
uncertainty to be accounted for; and the shortfall is material at the sample sizes
and covariate counts these analyses use.

**Refuting sentence:** *selection at these sample sizes is so unstable that the
selected model is nearly independent of the outcome data, so the conditioning is
weak and the reported interval is approximately correct despite the theory.*

**That refutation is not a joke.** COV-01's section 2 predicts screening is badly
underpowered, and a screening rule with near-zero power selects almost at random,
which is exactly the regime where selection conditioning bites least. **The two
studies therefore make opposite-signed predictions from the same fact**, and this
one is where they meet.

## 2. The mechanism: conditioning on a data-dependent event

Let $\hat M$ be the model selected from the analyzed data $D$ and $\hat\Delta_M$
the estimate under model $M$. The reported interval has nominal coverage for

$$P\big(\Delta \in \mathrm{CI}_{\hat M} \,\big|\, \hat M = M\big)$$

computed **as if $M$ were fixed**, while the quantity a reader wants is the
unconditional coverage over the joint law of $(\hat M, D)$. The shortfall is

$$P\big(\Delta \in \mathrm{CI}_{\hat M}\big) \;=\; \sum_M P(\hat M = M)\;P\big(\Delta \in \mathrm{CI}_M \,\big|\, \hat M = M\big),$$

and the conditional terms are **not** nominal because selection favors models
whose fitted interaction is large by chance. Three consequences:

1. **The shortfall grows with selection's dependence on the outcome.** A rule
   selecting on interaction significance conditions strongly; a rule selecting on
   covariate availability conditions not at all. **So the shortfall is a property
   of the rule, not of the analysis**, and a study that fixes one rule reports one
   point of a curve.
2. **It does not vanish as $n$ grows** unless selection becomes deterministic;
   at large $n$ the true modifiers are always selected and the conditioning
   disappears. **So the shortfall is largest at intermediate $n$**, which is a
   non-monotone prediction and one a design must be built to see.
3. **Resampling the whole procedure restores nominal coverage** if and only if
   the resample reproduces the selection step, which is the operational
   requirement and the one implementations skip.

**On the components that are not sampling error.** The design carries integration
error and bridge uncertainty **as separate reported objects**, not as variance:
integration error as a bound with a convergence assessment, bridge uncertainty as
a tipping analysis. **Reporting them beside the interval rather than inside it is
itself the deliverable**, and the study measures whether a reader can act on the
result, by checking whether the tipping point falls inside a plausible range.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal treatment effect, log odds ratio, at a
declared target.

**True value** by quadrature at an order fixed by P1.

**The estimand does not change with the selected model**, which is what makes
selection an inference problem rather than an estimand problem. That distinction
is stated because it is the one place this study could be confused with COV-14,
where different adjustment sets genuinely change what is estimated.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| selection rule | none (prespecified); availability-based; interaction significance; penalized | **section 2 consequence 1**: the shortfall is a property of the rule |
| source size | small, intermediate, large | **section 2 consequence 2**: the shortfall is non-monotone and this axis is the only way to see it |
| candidate covariates | 6, 13 | the reviewed field values, shared with COV-01 |
| true modifiers | 1, 3 | selection has to have something to find |
| overlap | good, poor | interacts with the weight-variance guidance being adopted |
| target-summary uncertainty | exact; $n_T = 300$ | **carried at two levels only**, because EST-07 and MIS-03 own it and re-running it here would be duplication |

### What the mechanism makes true, and therefore what the study cannot see

- **The weights-variance question is not re-opened.** Chandler and Proskorovsky's
  guidance is adopted: the ESS-weighted conventional estimator is used as the base
  variance and the sandwich is carried only where their guidance says it is safe.
  A study that re-derived this would be spending its budget on a closed question.
- Selection operates on a fixed candidate list. **Selection of the candidate list
  itself is upstream and invisible here**, and it is the larger real problem.
- Pseudo-IPD reconstruction uncertainty is **not** simulated. CMP-17 and OUT-13
  own it, and the catalog lists it as a separate unpropagated component; adding
  it would make the factorial uninterpretable, which the catalog's own note warns
  against.
- One outcome type, binary. Survival adds reconstruction and is excluded for the
  reason above.

## 5. Methods, including one that can win

| method | specification | role |
|---|---|---|
| conditional interval | selection then interval, as reported today | the status quo |
| resampled whole procedure | selection re-run inside every bootstrap replicate | the fix that should work |
| sample splitting | select on one half, estimate on the other | the fix that costs precision |
| selective inference | conditional interval adjusted for the selection event | the fix that is exact where it applies |
| model averaging | average over the candidate models with data-driven weights | the fix that avoids selecting |

**The comparator that can win is the conditional interval.** If it is nominal
across the grid, section 1's refuting sentence holds and the recommendation is
that at these sample sizes the theory does not bite. Registered as such, and
COV-01's power result is the reason it might.

**The decomposition is reported for every method:** the interval's width
attributable to sampling, and beside it the integration bound and the bridge
tipping range as separate objects. **The catalog asks for a decomposition
separating sampling from prior and structural contributions and nothing supplies
one**; producing it is the study's second deliverable and it is a reporting
format, not an estimator.

## 6. Performance measures, MCSE, and $n_{sim}$

Unconditional coverage of the target effect, which is the quantity in section 2
and the one nobody reports; conditional coverage given each selected model, which
is what is reported today, so the gap between them is visible; interval width;
selection frequencies.

**Precision cost is reported beside every fix**, since sample splitting and
model averaging buy coverage with width and a fix that is nominal and useless is
not a fix.

**The registered non-monotonicity check:** unconditional coverage against source
size must be U-shaped if section 2 consequence 2 holds. A monotone relationship
would mean the mechanism is not what drives the shortfall.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 4000$ per cell, because a coverage shortfall of 2 points must be
resolvable and a 0.005 MCSE does not resolve it against a 0.95 target with
confidence.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Unconditional coverage of the 95% interval under the
significance-screening rule at intermediate source size, against nominal.

**Decision rule.**

- Coverage below 93.5% under screening while the resampled-procedure arm is in
  band **confirms** the problem and identifies the fix.
- Coverage in band under every rule **refutes** it at these sample sizes and the
  study says so, citing COV-01's power result as the explanation rather than
  inventing one.
- Coverage below band under **every** method including the fixes means something
  other than selection is wrong, most likely the adopted variance guidance in an
  overlap regime it does not cover, and the study reports that rather than
  attributing it to selection.

## 8. Three controls, each of which can fail

**Null control.** With a prespecified model and no selection, every method must be
nominal. **This is also the check that the adopted weights-variance guidance is
being applied correctly**, and a failure here means the study's base variance is
wrong and nothing downstream is interpretable. MIS-03's registered analysis died
at exactly this point, on a sandwich that undercovered by up to 7 points at poor
overlap in cells where the effect under study was exactly zero.

**Second null control.** With availability-based selection, which uses no outcome
information, section 2 consequence 1 makes the conditioning **exactly absent**, so
the conditional interval must be nominal. **This separates "selection" from
"selection on the outcome", which is the distinction the whole mechanism rests
on.**

**Positive control.** At intermediate size with significance screening and 13
candidates, the conditional interval must undercover by at least 2 points. If it
does not, the effect is unreachable at realistic settings and that is the answer.

**Falsifier for the study's own headline.** The expected headline is that
selection uncertainty must be propagated. Its falsifier is COV-01's prediction
that screening is nearly powerless, which would make the conditioning weak. **The
two studies are registered as making opposite predictions and whichever way this
resolves, one of them is wrong**, which is worth more than either being confirmed
alone.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Re-deriving the closed weights-variance question | Published guidance adopted; used as the base variance | removed |
| Every uncertainty source at once, giving an uninterpretable factorial | Narrowed to selection; reconstruction and bridge excluded with owners named | removed |
| Integration error treated as a variance component | Reported as a bound with convergence assessment, beside the interval | removed |
| Bridge uncertainty merged into the interval | Reported as a tipping range | removed |
| Only conditional coverage reported, hiding the gap | Both reported | removed |
| A fix that is nominal and useless | Width reported beside coverage | removed |
| Candidate-list selection, the larger problem | Out of scope, stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target marginal truth per cell | The definition of truth | minutes |
| **P2** base-variance validation | That the adopted ESS-weighted estimator is nominal in the no-selection control at every overlap level in the grid | **The overlap levels.** If the base variance fails at poor overlap, that cell must be dropped before the run rather than discovered after, which is precisely what left MIS-03's registered analysis uninformative | hours |
| **P3** shortfall reachability | The analytic or pilot shortfall at each rule and size, so the U-shape is resolvable at $n_{sim}$ | $n_{sim}$ and the size levels | hours |
| **P4** unit cost | Per-replicate cost including the resampled procedure and sample splitting; total computed not typed | $n_{sim}$ | hours |

**P2 is the probe MIS-03 needed and did not have.** Its whole registered analysis
returned uninformative because a gate required the reference interval to be
nominal and it was not.

## 11. Cost

$n_{sim} = 4000$ times the resample count for the propagating arms. Priced in P4;
no total quoted.

---

## Relationship to the rest of the queue

- **COV-01** owns the selection rules whose uncertainty this study propagates,
  and makes the opposite prediction about screening's power. They should be read
  and, if possible, run together.
- **EST-07** and **MIS-03** own target-summary uncertainty, carried here at two
  levels only.
- **CMP-17** and **OUT-13** own pseudo-IPD reconstruction uncertainty.
- **MIS-04** owns model and bridge selection uncertainty entering the interval,
  which is the structural half this design deliberately reports separately.
- **QBA-23** owns propagating every layer without prohibitive cost, which is the
  question this study's decomposition format serves.
