# ADJ-10 design: how many environments before discovered structure is stable

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The note fixes both the priority and the framing: this is secondary and should follow
work on prespecified modifiers and support, **because discovery cannot repair
unidentified transport bias.** A design that presented discovery as a fix would be
answering a question the entry rules out.

**The study-aware machinery exists.** Multi-Study Causal Forest is built to borrow
individual data across studies when the sources of heterogeneity differ. **What is not
done is aggregating the fitted conditional effect to an external target inside an
indirect comparison**, which needs the target distribution, overlap and a transport
argument the forest does not supply.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** neither multi-study causal forests nor causal discovery
selects a causally sufficient transport adjustment set, resolves unmeasured transport
bias, or stays reliable with sparse events and few informative environments, so both
remain hypothesis-generation aids.

**Refuting sentence:** *with the trial counts and event rates evidence networks
supply, discovered modifier sets are stable enough and the aggregated conditional
effect accurate enough that discovery is a usable component rather than a hypothesis
generator.*

## 2. The mechanism: the identifying signal is the number of environments

**For discovery.** Cross-study structure is identified by variation across
environments, so the effective sample size for structure learning is the **number of
distinct study populations**, not the number of patients. Evidence networks supply
few. **So a forest fitted to 20,000 pooled patients across 6 trials has 6 observations
of the thing that identifies cross-study structure**, and its apparent precision comes
from the wrong denominator.

**For confounding.** Discovered heterogeneity can reflect between-study differences
rather than modification, and **neither method distinguishes a causal interaction from
one induced by an unadjusted study-level factor.** Randomization within trials orients
the treatment edge but says nothing about which covariate-outcome edges are causal
across studies.

**For aggregation.** The fitted conditional effect $\hat\tau(x)$ must be integrated
over the target law:

$$\hat\Delta(F_T) = \int \hat\tau(x)\,dF_T(x),$$

and where $F_T$ places mass outside the source support, $\hat\tau$ there is the
forest's extrapolation, which for a tree ensemble is the nearest-leaf value.
**Cross-fitting does not repair that**, and ADJ-04 and MOD-10 make the same point for
BART and Gaussian processes.

**Three consequences that structure the design:**

1. **Stability should scale with the number of trials, not with total sample size.**
   That is a falsifiable prediction and it is the design's central manipulation:
   vary trials and patients-per-trial in opposite directions at fixed total.
2. **Study-level confounding should produce false discoveries that do not diminish
   with sample size**, unlike sampling noise. **So the false-discovery curve against
   $n$ separates the two sources.**
3. **The aggregated effect's error decomposes into discovery error and extrapolation
   error**, and holding the discovered set at the truth isolates the second.

## 3. Estimand, with its true value defined

**Primary.** The marginal treatment effect in an external target population, by
quadrature over the declared target with the true conditional effect, at an order
fixed by P1.

**Two derived estimands.** **Modifier-selection stability**, the probability the same
set is recovered on independent replicates; and **false discovery of non-causal
interactions**, defined against the generating structure, which distinguishes a true
modifier from one induced by a study-level factor.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **number of trials** | 3, 6, 12 | **consequence 1's identifying axis** |
| **patients per trial** | varied inversely at fixed total | so trials and total sample size are separable |
| events per arm | low, moderate | sparsity, where forests degrade |
| modifier sparsity | 1, 3 true modifiers among 10 candidates | discovery's task |
| nonlinear interaction | absent; threshold | where flexibility should pay |
| **study-level confounding** | absent; present | **consequence 2** |
| target overlap | good, poor | consequence 3's extrapolation |

### What the mechanism makes true, and therefore what the study cannot see

- **Discovery is evaluated as a hypothesis generator**, per the entry, and no arm
  feeds a discovered set into a final analysis as if it were prespecified. **Doing so
  would evaluate a practice the entry says is invalid.**
- Causal discovery on a treatment network is named by the entry as unattempted and is
  **not attempted here**: it returns observationally equivalent graphs with different
  transport implications, and evaluating a graph-selection procedure needs a different
  design.
- The true structure is known. An analyst's is not, and **the study measures distance
  from a truth they cannot see**, as QBA-26 does for a different diagnostic.
- Aggregation requires overlap and a transport argument the forest does not supply;
  **those are supplied by the design**, which is favorable to the method.

## 5. Methods, including one that can win

| method | role |
|---|---|
| prespecified STC or ML-NMR with the true modifier set | the ceiling |
| **multi-study causal forest, aggregated to the target** | the extension the entry names |
| single-study causal forest on pooled data | the naive version, to show what study-awareness buys |
| forest with the discovered set fed into a prespecified model | **the practice under test**, carried to measure it rather than to endorse it |
| forest with the true set supplied | isolates consequence 3's extrapolation error |

**The comparator that can win is the prespecified model.** The entry's own position is
that discovery cannot repair transport bias, so **the prespecified arm should
dominate**, and the study's value is quantifying how many trials and events would be
needed before that stops being true. Registered as such, and a discovery arm winning
would be the surprise.

## 6. Performance measures, MCSE, and $n_{sim}$

Bias and coverage of the target effect per method per cell, with MCSE;
**selection stability**; **false discovery rate of non-causal interactions**, split by
whether the false discovery is driven by sampling noise or by study-level confounding.

**The registered stability check:** stability regressed on the number of trials and on
total sample size separately. **Consequence 1 predicts the first coefficient dominates**,
and if total sample size drives stability the identifying-signal argument is wrong.

**The decomposition:** aggregated error with the discovered set against with the true
set, which separates discovery error from extrapolation error per consequence 3.

$n_{sim} = 1000$ per cell; forests are fitted per replicate and their cost is measured
in P3.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Modifier-selection stability against the number of trials at
fixed total sample size, with study-level confounding present.

**Decision rule.**

- Stability rising with trials and flat in total sample size: **consequence 1 is
  confirmed**, and the deliverable is a statement of how many environments are needed
  before discovered structure is worth reporting as a hypothesis.
- Stability rising with total sample size: the identifying-signal argument is wrong
  and the study reports that rather than keeping it.
- **The false-discovery split is reported in either branch**, because a discovery
  driven by study-level confounding is a different failure from one driven by noise
  and only one of them shrinks with data.

## 8. Three controls, each of which can fail

**Null control.** With no true modifiers and no study-level confounding, discovery
must return the empty set at approximately its nominal false-discovery rate, and every
method must be unbiased. **A forest that discovers modifiers in a null world is
disqualified before its stability is interesting.**

**Second null control.** With the true set supplied and good overlap, the aggregated
forest must match the prespecified model to Monte Carlo error. **That isolates
aggregation from discovery**, and a gap there means the standardization step rather
than the learner is at fault.

**Positive control.** Three trials with study-level confounding and low events:
selection stability must be poor and false discoveries frequent. **If discovery is
stable at three trials, the identifying-signal concern is unreachable** and the entry's
premise fails.

**Falsifier for the study's own headline.** The expected headline is that discovery is
a hypothesis generator at achievable trial counts. Its falsifier is the 12-trial cell:
**if stability and false-discovery rates are acceptable there, then networks of that
size can support discovery**, and the recommendation becomes conditional on network
size rather than categorical.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Presenting discovery as repairing transport bias | Excluded by the note; the prespecified arm is registered to win | removed |
| A discovered set used as if prespecified | Carried as the practice under test, not endorsed | removed |
| Trials and total sample size confounded | Varied inversely at fixed total | removed |
| Causal discovery on a network | Not attempted; the entry names it unattempted and it needs its own design | disclosed |
| Aggregation given overlap and transport the forest lacks | Supplied by the design; favorable to the method and stated | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truth and quadrature order | The target effect's truth per cell | The definition of truth | hours |
| **P2** confounding construction | Study-level factors that induce apparent modification without being modifiers | **Consequence 2's factor**, which is the design's second axis | days |
| **P3** forest cost and tuning | Per-replicate cost and a fixed tuning protocol declared in advance | The budget and the fairness of the flexible arm | days |
| **P4** unit cost | Total, computed not typed | $n_{sim}$ | hours |

## 11. Cost

Forest fits per replicate at 1000 replicates across a seven-factor grid; wide and
moderately deep. Priced in P3 and P4.

---

## Relationship to the rest of the queue

- **COV-01** owns prespecified modifier selection and is the work this should follow.
- **OVL-01** and **OVL-03** own support, the other prerequisite the note names.
- **MOD-10** owns flexible interaction surfaces inside network synthesis and shares
  the extrapolation argument.
- **MOD-02** owns adversarial surfaces and flexible learners in PAIC generally.
- **IDN-01** owns transitivity screens, which is where a discovered structure would
  have to be checked.
