# HET-02 design: pseudo-contrasts that share a control arm and are entered as independent

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

CMP-12 owns multi-arm covariance in the two-stage **component** route. This entry
contains a second case that is sharper, has a documented real-world consequence, and
belongs to no other entry: **matched single-arm studies built against the same
comparator arm produce correlated pseudo-contrasts that published implementations
enter into the network likelihood as independent evidence**, and in a late-onset
Pompe disease network admitting them **reversed the direction of the headline
comparison.**

The catalog also corrects the framing that matters: **ML-NMR already solves this at
the network level** and has since 2020, with multi-arm studies carrying correlated
multivariate-normal random effects. **The open branch is weighting**, and ML-NMR is
the reference rather than the thing being replaced.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** a two-stage weighting workflow outputs separately
adjusted contrasts with only marginal standard errors, so it loses the covariance
induced by a shared common arm and the covariance induced by shared weight
estimation; **and the same covariance is lost with no multi-arm trial present**, when
several matched single-arm studies are built against one comparator arm.

**Refuting sentence:** *the induced correlation is small relative to the
between-study variance a network model already carries, so ignoring it changes
precision slightly and conclusions not at all.*

**The Pompe network is direct counter-evidence to that**, which is why the design
leads with the single-arm case.

## 2. The mechanism: the shared arm is counted once per pseudo-contrast

Let $m$ single-arm studies each be matched to the **same** comparator arm $C$ of one
randomized trial, giving pseudo-contrasts $d_k = \hat\mu_k - \hat\mu_C$. Then for
every pair,

$$\mathrm{Cov}(d_j, d_k) \;=\; \mathrm{Var}(\hat\mu_C) \;>\; 0 ,$$

and entering the $d_k$ as independent tells the synthesis it has $m$ independent
observations of $\mu_C$ when it has one. Three consequences:

1. **The comparator arm's information is multiplied by $m$.** The network's estimate
   of $\mu_C$ is pulled toward it with $m$ times its true weight, and every contrast
   involving $C$ inherits that. **With $m$ large this is not a precision nuance; it
   is a re-weighting of the evidence base**, which is how a headline direction
   reverses.
2. **It is worse than the multi-arm case.** A three-arm trial contributes two
   contrasts sharing one arm; $m$ matched single-arm studies contribute $m$. **So
   the defect grows with the practice that makes it attractive**, namely admitting
   more external single-arm evidence.
3. **Weight estimation adds a second covariance** through $\partial d_k / \partial
   w$, which is CMP-12's second term. **Here it compounds with the first**, and the
   two can be separated by holding weights at their full-sample values, which is the
   design's isolating arm.

**The consequence surfaces as distorted precision and as spurious or masked
inconsistency**, the catalog says, rather than as an obvious failure. **So the
design's outcomes include inconsistency inflation**, not only coverage: a network
that thinks it has $m$ independent readings of one arm will find the arm's true
variability inconsistent.

## 3. Estimand, with its true value defined

**Primary.** The target-population log treatment contrasts and **their joint
covariance**, with the covariance's truth being the Monte Carlo covariance of the
contrast estimators across replicates.

**Truth for the contrasts** by quadrature over the declared target law.

**Scoring a covariance method against coverage alone would let two errors cancel**,
so the covariance is scored directly, as in CMP-12.

## 4. Data-generating mechanism, and what it makes invisible

### Factors

| factor | levels | why |
|---|---|---|
| **matched single-arm studies sharing one comparator** | 0, 2, 5 | **section 2 consequence 1 and 2, the design's lead** |
| multi-arm IPD trials | none; one three-arm; one four-arm | the classical case |
| comparator arm size | small, large relative to the others | $\mathrm{Var}(\hat\mu_C)$, the covariance's magnitude |
| weight instability | stable; concentrated | consequence 3 |
| outcome correlation and variance imbalance across arms | equal; unequal | the entry's own factors |
| network size | small; with other evidence on the same contrasts | how much the mis-weighting matters to the pooled result |

### What the mechanism makes true, and therefore what the study cannot see

- **Consistency holds by construction**, so any inconsistency detected is induced by
  the covariance error rather than genuine. **That is what makes "spurious
  inconsistency" measurable** and it is also the limit: real networks have both.
- ML-NMR is the reference and is assumed correctly specified. **The study does not
  test ML-NMR**; it measures how far the weighting branch falls short of it.
- Matched single-arm studies are matched correctly, so their bias is not the issue.
  **The identification problems of single-arm matching are QBA's and OVL-01's**, and
  mixing them in would make the covariance result unattributable.
- One outcome type per arm of the design.

## 5. Methods, including one that can win

| method | role |
|---|---|
| naive pairwise, marginal SEs | current two-stage practice |
| sandwich for weighted multi-arm contrasts | the analytic route, **not previously derived or benchmarked** |
| **multivariate bootstrap re-estimating weights** | the fix; resamples the trial once and recomputes all its contrasts |
| **arm-level MAIC-style estimator** | one weight set feeding a joint arm-level outcome model |
| ML-NMR | the reference that already carries the covariance |
| exclude the matched single-arm studies | the conservative option, which is what refusing them amounts to |

**The comparator that can win is exclusion.** `cmaic()` and `cstc()` currently refuse
multi-arm IPD studies outright, and if refusing correlated pseudo-contrasts costs
little precision in a realistic network, **the restriction is the right default** and
the deliverable is the evidence for keeping it. Registered as such, and it is the
same registration CMP-12 makes for the same reason.

## 6. Performance measures, MCSE, and $n_{sim}$

Covariance recovery against the Monte Carlo truth, as a ratio with a bootstrap MCSE;
**simultaneous interval coverage** across the contrast set, which is where the
covariance actually bites and which marginal coverage cannot show; **inconsistency
inflation**, the rate at which a consistency test fires in a consistent network;
**precision forfeited by exclusion**, so the winning comparator's cost is on the same
axis.

**The registered mechanism check:** the effective multiplicity of the comparator
arm, estimated as the ratio of its apparent to true information, against $m$.
**A slope of 1 confirms consequence 1** and gives an analyst a number they can
compute before fitting.

Common random numbers across methods; MCSE clustered on the replicate block.
$n_{sim} = 2000$; the bootstrap resample count is set by P3 and its own Monte Carlo
contribution reported.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Simultaneous coverage of the contrast set under naive pairwise
treatment, with five matched single-arm studies sharing one comparator arm and a
small comparator.

**Decision rule.**

- Simultaneous coverage materially below nominal, restored by the multivariate
  bootstrap: **confirmed**, and the deliverable is the joint covariance export plus
  the multiplicity warning.
- Coverage nominal throughout: **refuted**, and the refuting sentence stands.
- Coverage restored only by exclusion: **the current refusal is vindicated**, and
  the recommendation is to keep it and say why.

**Direction of the induced error is reported**, because consequence 1 predicts a
pull toward the over-counted arm and a symmetric widening would mean the mechanism
is something else.

## 8. Three controls, each of which can fail

**Null control.** With no shared arm, no multi-arm trial and stable weights, every
method must agree and be nominal. Failure is implementation.

**Second null control, and it isolates the two covariance sources.** With weights
held at their full-sample values, only the shared-arm term is active, so the
multivariate bootstrap and a shared-arm-only correction must agree. **That is what
makes the decomposition in consequence 3 credible.**

**Positive control.** Five matched single-arm studies against a small comparator
arm: the comparator's apparent information must exceed its true information by a
factor near five. **If it does not, consequence 1 is not operative and nothing
downstream follows.**

**Falsifier for the study's own headline.** The expected headline is that the
weighting branch needs a joint covariance. Its falsifier is ML-NMR: **if using it
instead is affordable in every cell where the covariance matters, the weighting
branch does not need extending and the recommendation is to switch methods**, which
is what the catalog's own framing points at and which MOD-09 measures the cost of.

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Claiming no one-stage arm-level estimator exists | ML-NMR credited in the header and used as the reference | removed |
| Duplicating CMP-12 | That study owns the component two-stage case; this owns the shared-comparator single-arm case | removed |
| Covariance method judged by marginal coverage | Scored directly against the Monte Carlo covariance; simultaneous coverage reported | removed |
| Single-arm matching's identification problems confounded | Matching correct by construction; owners named | removed |
| Spurious inconsistency indistinguishable from real | Consistency imposed | removed, scope named |
| Bootstrap Monte Carlo error ignored | Resample count set in P3; contribution reported | removed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** truths and covariance | Contrast truths and the analytic covariance per cell | The grid | hours |
| **P2** multiplicity reachability | The apparent-to-true information ratio at each $m$, analytically, before fitting | **Whether consequence 1 is detectable at realistic $m$** | hours |
| **P3** bootstrap resample count | The count at which the covariance estimate's own error is below a declared fraction | The budget; **the line this program has mispriced twice** | hours |
| **P4** unit cost | Per-replicate cost including the joint bootstrap and the ML-NMR reference | $n_{sim}$ | hours |

## 11. Cost

$n_{sim}$ times resamples times methods, with an ML-NMR reference fit per cell.
Priced in P3 and P4.

---

## Relationship to the rest of the queue

- **CMP-12** owns the component two-stage multi-arm case and shares the joint
  bootstrap machinery; if both run they share a generator.
- **MOD-09** measures whether switching to ML-NMR is affordable, which is this
  design's falsifier.
- **HET-04** owns node splitting, whose inconsistency test this design's covariance
  error inflates.
- **DIA-07** owns topology, which determines how many contrasts share an arm.
- **CMP-24** owns edge influence, which a wrong covariance would misrank.
