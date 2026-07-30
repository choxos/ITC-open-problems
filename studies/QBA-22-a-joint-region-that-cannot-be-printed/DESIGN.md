# QBA-22 design: the robustness statement that is necessary and unprintable

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

This entry contains two problems and the second is the one nobody is working on.

The first, non-additivity, already has evidence and machinery. Ackerman et al.
2024 measured a super-additive interaction between misclassified progression
events and irregular assessment times. Brendel, Torres and Arah adjust
confounding, selection and misclassification **simultaneously**, with a CRAN
implementation. **So the PAIC-specific gap is composition with the
population-adjustment step, not multiple-bias composition itself.**

The second is stated in the entry and is unusual: **the joint robustness statement
this entry shows to be necessary is one that cannot be printed.** Threshold
machinery derives a decision-invariant region in as many dimensions as there are
perturbed quantities, and Phillippo et al. 2018 say plainly that the obstruction
above two or three dimensions is display and interpretation rather than
derivation. Candidate low-dimensional summaries have **not been proposed,
evaluated or standardized.**

Section 2 takes the second problem as the study's centre.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** total bias is non-additive on nonlinear estimand
scales, so one-at-a-time curves cannot establish joint robustness; sequential
corrections are order-dependent when mechanisms interact, yet sequential
correction is what practice does; and the joint decision-invariant region has no
reportable form.

**Refuting sentence:** *a small set of one-dimensional threshold intervals
conveys the joint region's decision-relevant content adequately, so the reporting
problem is presentational rather than substantive.*

## 2. The mechanism, and the summaries it suggests

Let $\gamma \in \mathbb{R}^p$ collect the bias parameters and let $D(\gamma) =
\mathbb{1}\{\Delta^\star(\gamma) > \tau\}$ be the decision. The
**decision-invariant region** is

$$\mathcal{R} \;=\; \{\gamma : D(\gamma) = D(0)\},$$

a subset of $\mathbb{R}^p$. Two facts, and then the design.

**Non-additivity.** $\Delta^\star$ is a nonlinear functional of $\gamma$ because
marginalization and the link are nonlinear, so $\mathcal{R}$ is not a box and its
one-dimensional sections through the origin, which are exactly what one-at-a-time
curves report, do not determine it. **A set of $p$ intervals describes a cross,
not a region**, and the cross can be entirely inside $\mathcal{R}$ while most of
the box it spans is outside.

**Three candidate scalar summaries**, each with a different meaning, none
evaluated:

1. **Minimum-norm violation vector**: $\min\{\|\gamma\|_M : D(\gamma) \neq D(0)\}$
   under a declared metric $M$. The smallest departure that flips the decision.
   **Interpretable, but it depends entirely on $M$**, which encodes how bias
   magnitudes in different mechanisms compare, and nothing in the data informs it.
2. **Inradius**: the radius of the largest ball inside $\mathcal{R}$ centred at the
   origin. Metric-dependent in the same way, but insensitive to the region's shape
   away from the worst direction.
3. **Plausible-set preservation fraction**: the share of a prespecified plausible
   bias set $\mathcal{P}$ that lies inside $\mathcal{R}$. **This one does not need a
   metric**; it needs an elicited $\mathcal{P}$, which is what a QBA elicits
   anyway. **That makes it the most deployable candidate and the one this design
   expects to recommend**, which is exactly why it must be tested hardest.

**These three can be ranked empirically**, by how well each predicts the thing a
committee cares about: whether the decision is in fact wrong. **That is a
classifier question and it is the study's primary outcome.** No previous work has
posed it, because no previous work has needed a summary of a region it could not
draw.

**Order-dependence is a separate, cheap check.** Sequential correction applies
corrections in some order; if mechanisms interact, permuting the order changes the
answer. **The spread across permutations is directly measurable and has never been
reported**, and it is what tells an analyst whether their current practice is even
well defined.

## 3. Estimand, with its true value defined

**Primary.** The target-population marginal risk ratio and RMST difference, by
quadrature and exact integration at orders fixed by P1.

**The region $\mathcal{R}$ is a derived estimand with a computable truth**,
obtained by evaluating $D(\gamma)$ on a grid dense enough that P2 shows its
boundary is resolved.

**Whether the decision is wrong at the true $\gamma$** is the classification truth
against which the three summaries are scored.

## 4. Data-generating mechanism, and what it makes invisible

Unanchored PAIC with three bias mechanisms, following the entry's own list:
effect-modifier imbalance, omitted confounding, outcome misclassification.

### Factors

| factor | levels | why |
|---|---|---|
| number of mechanisms active | 2, 3 | $p$, and it is what makes the region undrawable |
| dependence among bias parameters | positive; negative; independent | the entry's own axis, and it changes $\mathcal{R}$'s shape |
| bias magnitudes | reinforcing; cancelling | so the cross-versus-region gap is reachable |
| estimand scale | risk ratio; RMST | nonlinearity differs, and RMST's is an integral |
| overlap | good, poor | the adjustment layer |
| plausible set $\mathcal{P}$ | narrow; wide; miscentred | the third summary's input, treated as a factor rather than fixed |

### What the mechanism makes true, and therefore what the study cannot see

- **The dependence structure among non-identified bias parameters is elicited, not
  estimated**, and neither the source IPD nor the aggregate comparator can inform
  it. The entry says so. **Every result is conditional on the elicited structure**
  and is reported as a function of it.
- Attribution shares, Shapley or otherwise, **describe a chosen model rather than
  recovering an underlying quantity.** They are computed and reported as
  descriptive allocations conditional on the assumed bias model, with the fixed
  parameter vector or averaging distribution stated, exactly as the entry
  instructs. **They are not offered as the summary**, because they answer a
  different question from the three in section 2.
- Three mechanisms only. Higher $p$ makes the region harder to summarize, which
  strengthens the case for a scalar, but the grid cost grows exponentially and P2
  fixes where that stops.
- The existing multiple-bias machinery is **composed with**, not rebuilt. If it
  cannot be made to operate on a weighted or standardized PAIC estimator, that is
  a finding and P3 establishes it before registration.

## 5. Methods, including one that can win

| method | role |
|---|---|
| one-at-a-time curves | current practice, and the thing under test |
| sequential correction, all orders | the other current practice, with its permutation spread measured |
| **simultaneous adjustment composed with PAIC** | the existing machinery ported |
| full joint region | the reference, computed on a grid |
| the three scalar summaries | the deliverable |

**The comparator that can win is the set of one-at-a-time curves.** If the cross
they describe predicts decision failure as well as any region summary, the
refuting sentence holds and the reporting problem is presentational. Registered as
such, and section 2 gives a specific reason it might: the worst direction is often
a coordinate direction, in which case the cross contains the binding constraint.

## 6. Performance measures, MCSE, and $n_{sim}$

**The three summaries scored as classifiers of decision error**, with AUROC,
calibration and decision curves, following DIA-03's machinery.

**The cross-versus-region gap:** the volume fraction of the box spanned by the
one-at-a-time intervals that lies outside $\mathcal{R}$. **A single number that
says how misleading the current report is**, and it has never been computed.

**Order-dependence:** the spread of the corrected estimate across all permutations
of sequential correction, reported as a range on the estimand scale.

**Non-additivity:** observed joint bias against the sum of marginals, and the
interaction term against its analytic value.

$n_{sim} = 2000$ per cell; the region grid is deterministic per cell and its
resolution is set by P2, with its own approximation error reported rather than
assumed negligible.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** AUROC of the plausible-set preservation fraction against
decision error, compared with the one-at-a-time cross, at three active mechanisms
with dependent bias parameters.

**Decision rule.**

- A summary materially better than the cross, and stable across the plausible-set
  factor: **that summary is the deliverable**, together with the reporting
  convention the entry says does not exist.
- No summary better than the cross: the refuting sentence holds and one-at-a-time
  reporting is defensible, which would be a useful and currently unsupported
  reassurance.
- A summary better only when $\mathcal{P}$ is well centred: **the summary inherits
  the elicitation's failure mode**, which is DIA-14's factorization applied here,
  and it is reported as a conditional recommendation rather than a general one.

**The cross-versus-region volume fraction is reported in every branch**, because
it quantifies the current practice's blind spot independently of what replaces it.

## 8. Three controls, each of which can fail

**Null control.** On a linear estimand scale with independent bias parameters and
no interaction, $\mathcal{R}$ **is** a box, the cross determines it exactly, and
every summary must agree. **This is algebraic and it is the check that the region
machinery is computing what section 2 says.**

**Second null control.** With one mechanism active, $p = 1$, every summary reduces
to the existing threshold interval and must reproduce `nmathresh`-style output.
**Reproducing the published one-dimensional case is what licenses the
multidimensional extension**, and it is cheap.

**Positive control.** Three mechanisms, dependent parameters, RMST scale,
cancelling magnitudes: the cross must lie inside $\mathcal{R}$ while a
substantial share of the spanned box lies outside. **If that configuration cannot
be produced, the reporting problem is not reachable and the study says so.**

**Falsifier for the study's own headline.** The expected headline is that a scalar
summary is both possible and better. Its falsifier is metric dependence: **if the
minimum-norm and inradius summaries change their ranking under a different but
equally defensible metric $M$, then those two are not summaries of the region but
of the metric**, and only the plausible-set fraction survives. **Two metrics are
therefore run, declared in advance**, and the comparison is registered.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Reinventing multiple-bias machinery that exists on CRAN | Composed with the PAIC step; P3 checks it can be | removed |
| Claiming non-additivity without evidence | Ackerman et al. cited; the interaction term is measured against its analytic value | removed |
| A scalar summary that is really a summary of the chosen metric | Two metrics run; the falsifier tests ranking stability | removed |
| Shapley attribution offered as the answer | Reported as a descriptive allocation with its conditioning stated, per the entry | removed |
| Region grid resolution assumed adequate | Set and its error reported in P2 | removed |
| Dependence structure treated as estimable | Stated as elicited; results reported as a function of it | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths | Estimand truths and the analytic marginal and interaction bias terms | The grid | days |
| **P2** region resolution | The grid density at which $\mathcal{R}$'s boundary and the volume fraction are stable, and the largest $p$ affordable | **The number of mechanisms.** A region computed on too coarse a grid gives a volume fraction that is an artifact of the grid | days |
| **P3** composition feasibility | Whether the existing simultaneous-adjustment machinery can be made to operate on a weighted or standardized PAIC estimator | **Whether the port arm exists**, which is the entry's stated gap | days |
| **P4** unit cost | Region grid times $n_{sim}$ times cells; total computed not typed | Everything | hours |

## 11. Cost

The region grid is $O(k^p)$ per cell and multiplies $n_{sim}$. **That exponential
is the term this design would most easily misprice**, and P2 fixes both $k$ and
the largest affordable $p$ before registration rather than during the run.

---

## Relationship to the rest of the queue

- **DIA-13** crosses bias mechanisms with the primary data-generating factors;
  this design owns composition and the reporting form. They share a generator and
  DIA-13's cell-selection rule should use this study's interaction terms.
- **DIA-14** owns QBA scored as a classifier and supplies the scoring machinery.
- **CMP-21** finds the same composition structure for one parameter entering
  three layers of a component model.
- **QBA-25** owns decision QBA and tipping surfaces, which is where a standardized
  region summary would be used.
- **QBA-11** owns what double robustness does not cover.
