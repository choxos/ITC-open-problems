# IDN-08 design: the benchmark's own untested assumption

**Status: design. Not registered.** Gated on data access; see section 10.
Written against `studies/DESIGN-STANDARD.md`.

**Bridge deletion has been done.** Beliveau et al. took two publicly available
connected networks, disconnected them several ways, compared the recovered
contrasts against the connected analysis, and released code. Rücker et al.
appraised a bridged comparison in a genuinely disconnected multiple myeloma network
by re-analyzing it with RCT-only component network meta-analysis against a
matching-based bridge. **So the exercise exists and this design does not claim
otherwise.**

What is missing is a curated public benchmark with factorial scenarios, full-IPD
gold standards and independent replication, **together with evidence that
performance on an artificially cut link transfers to a real gap.** Section 2 takes
that last clause as the study's centre, because it is the benchmark's own
assumption and nobody has tested it.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** in a real disconnected network a cross-gap contrast has
no direct or overidentifying evidence, so its bridging restriction cannot be tested
from that dataset and validation must be borrowed from connected networks; and
whether that borrowing transfers depends on the deleted link being representative,
in population and design, of the gap being bridged, which has not been shown.

**Refuting sentence:** *deletion recovery is a stable property of the method rather
than of the deleted link, so any cut link licenses the method for any gap.*

## 2. The mechanism: deletion recovery is a function of the cut, not only of the method

Deleting link $\ell$ from a connected network and reconstructing it produces an
error $e(\ell)$. **If $e(\ell)$ varies substantially across $\ell$ within one
network, then a benchmark reporting a single recovery figure is reporting an
average over cuts, and the real gap is one particular cut whose position in that
distribution is unknown.**

Two quantities determine where a cut sits, and both are measurable **before** the
recovery is computed:

- **population separation** across the induced gap: the divergence between the
  covariate distributions on either side;
- **design separation**: differences in era, backbone, outcome definition and
  follow-up across the gap.

**So the study's central object is the regression of $e(\ell)$ on those two
separations.** If it is strong, deletion benchmarks are informative **only when the
cut resembles the target gap**, and the deliverable is a rule for choosing cuts. If
it is flat, the refuting sentence holds and any cut will do, which would be a
genuinely reassuring result and would make existing benchmarks more valuable than
they currently claim to be.

**The real gap can then be located in that space.** A disconnected network's actual
gap has a measurable population and design separation, computed from published
summaries. **Whether it falls inside the range where recovery was good is
answerable**, and it converts "does this transfer?" from a philosophical objection
into a lookup.

**A separate and cheap finding is available regardless.** `additivity_test()` can
return $Q = 0$ on zero degrees of freedom, which is a vacuous pass. **Any
fit-based check reported in this benchmark states its degrees of freedom**, and the
frequency of vacuous passes across the curated networks is itself a result about
how often such checks reassure without testing anything.

## 3. Estimand, with its true value defined

**Primary.** The target-standardized cross-gap treatment contrast after deletion.

**The reference is the retained direct or full-network estimate**, which is **not**
truth: it carries its own uncertainty and its own modeling assumptions. **Every
comparison is uncertainty-aware**, as in DIA-17, and the design says so rather than
calling the connected estimate the answer.

**Estimand matching is a protocol requirement**: direct and reconstructed estimates
must share an estimand and target population, and removed evidence must be excluded
from fitting, **verified rather than intended**.

**$e(\ell)$ and the two separations are the derived estimands** whose relationship
is the primary outcome.

## 4. Design of the benchmark, and what it cannot see

**Factorial deletion.** Within each curated network, every deletable link is cut in
turn, subject to the reduced network still identifying the contrast, which is a
rank check per cut rather than a judgment.

### Factors

| factor | levels |
|---|---|
| deleted link | every identifiable cut in each network |
| population separation across the gap | measured, not assigned |
| design separation across the gap | measured, not assigned |
| bridging method | component NMA; matching-based; baseline-risk anchor |
| network | each curated dataset |

**Population and design separation are covariates, not factors**, because they are
properties of the cut rather than knobs. **That is why the analysis is a regression
rather than a comparison of cells**, and it is what the existing deletion studies
could not do with two networks.

### What it cannot see

- **Curation is the binding task**, and the catalog says so. Connected networks
  carrying the IPD and bridging covariates are scarce and none have been assembled
  into a public benchmark.
- **A cut link is not a real gap even when it resembles one.** The real gap arose
  because no trial was run; a cut link had one. Selection into which comparisons
  get run is a mechanism this design cannot reproduce, and it is stated rather than
  assumed away.
- Cross-method concordance is **triangulation, not validation**, and is labeled
  that way throughout, following the entry.
- Independent replication is not achievable here and is not claimed.

## 5. Methods

Component network meta-analysis, a matching-based bridge, and a baseline-risk
anchor, so the benchmark spans the routes actually used. **Both existing empirical
routes are registered as the starting point**: deletion-based recovery, and
cross-method concordance labeled as triangulation.

**The comparator that can win is the matching-based bridge**, which Rücker et al.
appraised against component NMA in a real disconnected network. If it recovers as
well across the cut space, the choice of bridge matters less than the choice of cut
and the deliverable is about cuts rather than methods.

## 6. Performance measures

Bias, interval coverage and decision agreement of the reconstructed contrast
against the retained estimate, uncertainty-aware; $e(\ell)$ per cut; **the
regression of $e(\ell)$ on population and design separation, with the two entered
separately** since they are conflated in every existing example.

**Degrees of freedom for every fit-based check**, and the rate of vacuous passes.

**The location of real gaps** from published disconnected networks in the
separation space, reported as a figure with the recovery surface behind it. **That
figure is the deliverable**: it tells an analyst whether a benchmark result applies
to their gap.

## 7. Decision rule, before any data is seen

- $e(\ell)$ strongly related to separation: **deletion benchmarks are conditional
  evidence**, and the deliverable is the separation-indexed recovery surface plus
  the rule that a benchmark must report where its cuts sit.
- $e(\ell)$ flat in separation: the refuting sentence holds, any cut licenses any
  gap, and existing benchmarks are stronger than they claim.
- Real gaps falling outside the range spanned by available cuts: **the honest
  conclusion is that no available benchmark speaks to them**, which is a
  publishable negative result and the one the field would least like.

## 8. Controls

**Null control.** Cutting a link whose contrast is also identified by two other
paths should give near-perfect recovery, because the bridge is barely doing
anything. A failure there is a pipeline fault.

**Second null control.** Cutting a link across zero population and zero design
separation should give recovery limited only by sampling error. **That is the
origin of the regression in section 2 and it anchors it.**

**Positive control.** Cutting the link with the largest separation available must
give materially worse recovery. **If it does not, the separation axis is inert in
these networks and the primary outcome has no signal**, which P2 checks before any
data is requested.

## 9. Threats

| threat | what was done | status |
|---|---|---|
| Claiming bridge deletion is undone | Both existing routes credited in the header | removed |
| A single recovery figure averaged over cuts | $e(\ell)$ reported per cut and regressed on separation | removed |
| Population and design separation conflated | Entered separately | removed |
| Connected estimate treated as truth | Uncertainty-aware throughout | removed |
| Cross-method concordance presented as validation | Labeled triangulation | removed |
| Vacuous fit-based passes | Degrees of freedom reported; their rate is an outcome | removed |
| A cut link standing for a gap that was never run | Stated as an irreducible limitation | disclosed |

## 10. The gate, and what can be done before it opens

| step | what it produces |
|---|---|
| **G1** protocol registration | This document, before datasets are sought |
| **G2** separation metrics | The two separation measures defined and computed on **published** disconnected networks, which needs no IPD, so the horizontal axis of the deliverable figure exists before any curation |
| **G3** curation survey | Which connected networks carry IPD and bridging covariates, and what permissions each requires |
| **G4** pipeline on simulated networks | Deletion, rank checking and reconstruction validated on simulated data where truth exists |

**G2 is worth doing on its own.** Locating real gaps in the separation space is a
result even with no recovery surface behind it, because it says how far a benchmark
would have to reach.

## 11. Relationship to the rest of the queue

- **DIA-16** owns a curated public suite for bridge-deletion validation with IPD
  and shares this design's gate; one curation effort serves both.
- **DIA-17** owns masked-IPD benchmarking and shares the data problem.
- **DIS-11** owns whether predictive criteria and population comparison can
  validate a bridge, which is the question this benchmark would answer empirically.
- **DIS-21** owns match acceptance thresholds against bridge bias, which the
  separation surface would calibrate.
- **CMP-26** owns the adversarial simulation module that runs without any of this
  data.
