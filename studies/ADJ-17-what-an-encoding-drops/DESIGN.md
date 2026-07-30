# ADJ-17 design: measuring the loss you can see, and naming the one you cannot

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note is unusually blunt and the design accepts all of it: **do not run early; it
is interesting but speculative, computationally substantial, and incapable of resolving
the central unknown-modifier objection.**

**No prior work is identified for this problem in the reviewed sources**, so the entry
has no literature to extend. That makes the honest scope narrow, and section 2 says why
the narrowness is structural rather than a matter of effort.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** no learned population representation has been used inside an
indirect comparison; for an encoding to support valid transport the relevant conditional
treatment effect must be representable from it, with exchangeability, positivity and
measurement comparability still holding; and **no data-only objective can guarantee that
unknown effect modifiers survive compression.**

**Refuting sentence:** *reconstruction and interaction-preservation checks detect
modifier loss reliably enough that a learned encoding can be audited as well as a
declared mapping.*

**The auditability objection needs softening and the catalog says so**: a learned
encoding is harder to audit, **but transparent encoders, reconstruction checks,
interaction-preservation checks and external validation can reveal some losses.** The
word is *some*, and this design measures which.

## 2. The mechanism: the guarantee is impossible and the diagnostic is partial

An encoder $\phi$ maps covariates $x$ to a representation $z = \phi(x)$. Transport
through $z$ is valid only if the conditional effect is $z$-measurable:

$$\tau(x) \;=\; \tilde\tau(\phi(x)) \quad\text{for some } \tilde\tau .$$

Three consequences, and the first is a logical statement rather than an empirical one:

1. **No objective computed from the data can guarantee this for modifiers the analyst
   has not identified.** If $\tau$ depends on a direction the objective does not
   reward, compression discards it, and **nothing in the fitted output distinguishes
   "this direction did not matter" from "this direction was not rewarded."** So the
   central objection cannot be resolved by any encoder, which is why the note calls
   the study incapable of resolving it. **The design does not attempt to.**
2. **For *known* modifiers the loss is measurable**, by checking whether $\tilde\tau$
   fitted on $z$ reproduces $\tau(x)$. **That is the study's entire measurable
   scope**, and stating the boundary is more useful than blurring it.
3. **Reconstruction and interaction preservation are different checks and can
   disagree.** A representation can reconstruct $x$ well while collapsing the specific
   contrast $\tau$ depends on, if that contrast carries little variance;
   **reconstruction is a variance criterion and modification is not.** So a
   reconstruction check can pass while transport fails, and **that dissociation is
   directly testable** by constructing a modifier along a low-variance direction.

**Consequence 3 is the design's sharpest deliverable**, because reconstruction error
is the check anyone would reach for first.

## 3. Estimand, with its true value defined

**Primary.** The marginal target-population treatment effect, by quadrature at an order
fixed by P1.

**Two derived estimands.** **Interaction preservation**, the fraction of $\tau$'s
variation recoverable from $z$, with a known truth since the generator sets $\tau$; and
**reconstruction error**, so consequence 3's dissociation is measurable.

**Nothing is claimed about unknown modifiers**, per consequence 1, and the paper's
abstract states that limit rather than leaving a reader to infer it.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| representation dimension | 2, 5, 10, against 20 covariates | the compression |
| modifier sparsity | 1, 3 true modifiers | what must survive |
| **modifier direction's variance share** | high; **low** | **consequence 3's dissociation** |
| nonlinear heterogeneity | absent; present | whether a linear encoder suffices |
| measurement shift between source and target | absent; present | the harmonization case the entry is really about |
| target overlap | good, poor | the transport layer |

### What the mechanism makes true, and therefore what the study cannot see

- **Only known modifiers are measured.** Consequence 1 makes the unknown case
  unmeasurable in principle, and the design says so rather than simulating "unknown"
  modifiers, which would just be known ones the estimator was denied.
- The encoder is transparent by construction, which is favorable to the method. **A
  black-box encoder would be harder to audit and the results here are an upper bound
  on auditability.**
- No prior work exists to compare against, so **the declared human-readable
  harmonization mapping is the only baseline**, which is what the entry asks for.
- Computationally substantial, per the note, so the grid is small.

## 5. Methods, including one that can win

| method | role |
|---|---|
| **declared human-readable harmonization mapping** | the baseline the entry says must be beaten before an opaque encoding is accepted |
| linear encoder with a reconstruction objective | the naive learned version |
| encoder with a treatment-effect-preserving objective | the version that rewards what matters |
| no encoding, full covariate vector | the ceiling where dimension permits |

**The comparator that can win is the declared mapping.** The entry's own instruction is
to compare against it **before** accepting an opaque encoding in a submission, so it is
the incumbent and the burden is on the learned encoding. **Registered as such, and this
is the design most likely in the queue to return a negative result.**

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target effect per method per cell, with MCSE;
**interaction preservation**; **reconstruction error**; and **their dissociation**,
reported as the joint distribution rather than as two margins, since consequence 3 is
about their disagreement.

**A stated sufficiency condition is required of every encoder arm**: which heterogeneity
the encoding must retain, declared before fitting. **An encoder without one is not
evaluated**, because there is nothing to score it against, and the entry asks for the
condition to be stated.

$n_{sim} = 500$ per cell, low because encoders are fitted per replicate.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Bias of the target effect under a reconstruction-objective encoder
when the modifier lies along a **low-variance** direction, against the declared mapping.

**Decision rule.**

- Material bias there while reconstruction error is small: **consequence 3 is
  confirmed**, and the deliverable is that reconstruction checks do not certify
  transport and interaction preservation must be reported.
- No bias: the reconstruction objective retains what matters at these configurations
  and the refuting sentence holds for known modifiers.
- **The declared mapping's performance is reported in either branch**, because the
  entry's recommendation is comparative and the baseline is the point.

## 8. Three controls, each of which can fail

**Null control.** With no effect modification, any encoding transports correctly
because there is nothing to preserve. **Every method must be unbiased**, and a bias
there means the encoder is corrupting the prognostic structure rather than the modifier
structure.

**Second null control.** With representation dimension equal to the covariate count,
there is no compression, so every encoder must match the full-vector arm. **Exact, and
it checks the encoder is not losing information it was not asked to lose.**

**Positive control.** One modifier along the lowest-variance direction with a
2-dimensional representation: reconstruction error must be small **and** the target
effect must be badly biased. **Both halves are required**, since the dissociation is
the finding and either alone is not.

**Falsifier for the study's own headline.** The expected headline is that learned
encodings drop what matters and reconstruction cannot tell. Its falsifier is the
effect-preserving objective: **if rewarding treatment-effect variation retains the
modifier reliably, then the problem is the objective rather than the compression**, and
the recommendation becomes an objective specification instead of a warning.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming to resolve the unknown-modifier objection | Consequence 1 states it cannot be; the abstract says so | removed |
| "Unknown" modifiers simulated as known ones withheld | Not attempted; the scope is known modifiers | removed |
| Asserting opacity rather than measuring it | Reconstruction and interaction-preservation checks scored | removed |
| An encoder evaluated without a stated sufficiency condition | Required; unstated encoders are not evaluated | removed |
| No baseline | The declared mapping is the incumbent and the registered winner | removed |
| Black-box encoders | Transparent only; results stated as an upper bound on auditability | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target effect's truth per cell | The definition of truth | hours |
| **P2** low-variance modifier construction | Covariate laws where a modifier lies along a direction carrying little variance, verified | **Consequence 3's manipulation**, which is the design's core | days |
| **P3** encoder tuning protocol | A fixed protocol declared before any result | The fairness of the learned arms | hours |
| **P4** unit cost | Per-replicate cost with encoder fitting; total computed not typed | $n_{sim}$ | hours |

## 11. Cost

Encoder fitting per replicate at 500 replicates; **computationally substantial per the
note, and the grid is kept small for that reason.**

---

## Relationship to the rest of the queue

- **COV-09** owns measurement non-equivalence, which is the harmonization problem this
  encoding is proposed for, and its nonidentification result bounds what any encoder
  can achieve.
- **COV-01** owns modifier selection; an encoding is a selection made by an objective
  rather than by an analyst.
- **ADJ-10** owns discovery and shares the point that a data-only procedure cannot
  certify transport.
- **OVL-01** owns support, which an encoding changes without announcing.
