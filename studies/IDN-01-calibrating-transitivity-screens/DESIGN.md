# IDN-01 design: what each screen is blind to, and whether it would have licensed the abandonment

**Status: design. Not registered.** Probes in section 10 not run.
Written against `studies/DESIGN-STANDARD.md`.

The catalog's note sets the scope and it is right: **the impossibility claim
itself is not a novel study.** Transitivity, consistency and conditional
constancy restrict counterfactual quantities that are never jointly observed;
that is settled. What is worth running is calibration of the screens that do
exist, and section 2 shows the calibration has a structure that makes each
screen's blind spot constructible rather than merely acknowledged.

The entry also carries something no other entry in this queue does: **a
documented record of prespecified network meta-analyses abandoned on an
unquantified reading of the same assumption**, in one case after the models were
fitted and the results withheld. Section 11 makes that a scorable component.

---

## 1. The claim, restated as something that can be false

**Proposition under test:** each screen tests one observable implication; a
calibrated failure is evidence against at least one assumption without saying
which; no catalogue states which implications a population-adjusted comparison
should prespecify or what a failure triggers; and the go/no-go judgment that
governs whether the analysis happens at all rests on no stated criterion.

**Refuting sentence:** *the available screens, run together, have adequate power
against the violations that actually occur and agree on which mechanism failed,
so the missing object is a checklist rather than calibration.*

## 2. The mechanism: a screen has a blind spot that can be constructed

A screen is a function $T$ of the observed data. The restriction $R$ constrains
counterfactual contrasts in study-by-population cells that are never jointly
observed. Where $R \Rightarrow T$,

$$\neg T \;\Longrightarrow\; \neg R \qquad\text{but}\qquad T \;\not\Longrightarrow\; R .$$

Now decompose a violation into the part the screen can see and the part it
cannot. Write the violation as a vector $v$ in the space of study-level
discrepancies and let $P_T$ be the projection onto the directions $T$ responds to.
Then:

1. **A violation with $P_T v = 0$ is invisible to $T$, with power exactly equal to
   its size.** Not low power; **nominal** power. And such violations exist for
   every screen, because $T$ is a function of far fewer quantities than the
   restriction constrains.
2. **The blind spot is constructible**, so the design does not have to hope a grid
   contains one. For the dissimilarity screen, $P_T$ responds to differences in
   reported study-level characteristics across comparisons, so a violation in
   which effect modification differs across comparisons **while every reported
   characteristic matches** is exactly orthogonal to it. That configuration is
   easy to generate and impossible for that screen to detect.
3. **Different screens have different $P_T$, so their blind spots differ**, and
   the useful question is whether the union of the available screens covers the
   violations that matter. That is a coverage question with an answer, and it is
   this study's primary outcome.
4. **A screen's failure does not identify the mechanism** because several
   mechanisms project onto the same directions. **So "which mechanism failed" is
   itself a classification problem** and should be scored as one, which nothing
   currently does.

Spineli's empirical result is the backdrop and it is stark: in 209 real networks a
likely intransitivity prevailed in **all** of them, while statistical tests were
feasible in only 61% and often disagreed with the dissimilarity reading.
**Disagreement between screens is therefore the normal case, not the exception**,
and a calibration study that did not measure agreement would be reporting one
screen's opinion.

## 3. Estimand, with its true value defined

**Primary.** Whether the transport restriction is violated, and by which
mechanism, in a simulated network where both are known by construction.

**True value** is set by the generator: the restriction holds or does not, and the
mechanism is one of a declared list (omitted effect modification; effect
modification differing across comparisons; compensating inconsistency; population
drift).

**A screen's operating characteristics are the derived estimands:** size, power
against each mechanism, and mechanism-identification accuracy.

**A screen's blind-spot direction is a third estimand and it is computed, not
searched for.** For each screen, the violation direction minimizing detection
probability, obtained in P2 by construction rather than by scanning the grid.

## 4. Data-generating mechanism, and what it makes invisible

Networks built to match the **tracenma** database's geometry and reported-covariate
availability, so that the screens are calibrated on structures that occur rather
than on convenient ones. That database exists expressly to develop this
methodology and using it is cheaper and more credible than inventing networks.

### Factors

| factor | levels | why |
|---|---|---|
| violation mechanism | none; omitted modifier; modification differing across comparisons; compensating inconsistency; population drift over calendar time | section 2 consequence 4 |
| violation magnitude | 0, small, moderate, large | the power curve |
| **alignment with each screen's projection** | aligned; orthogonal | **section 2 consequence 1**, the design's central manipulation |
| network size | small (where conditional constancy does most of the identifying work); large | the catalog's point that the residual-heterogeneity route needs a large network, which is not the setting where it is needed |
| covariate reporting completeness | full; the tracenma empirical distribution; sparse | **whether the screen is runnable at all**, which the catalog says nothing governs |
| overlap | good, poor | the PAIC layer |

### What the mechanism makes true, and therefore what the study cannot see

- Every violation is of a declared type. **Violations outside the declared list
  are as invisible to this study as they are to the screens**, and that limit is
  the same limit the impossibility result describes. The study measures coverage
  of a named set, not of all possible violations, and its abstract must say so.
- Reported study-level characteristics are the ones tracenma records. A screen
  that would work on an unreported characteristic is not evaluated, which is
  favorable to no screen in particular but understates what better reporting
  could buy. **COV-01's minimum reporting sets are the fix and this study
  supplies the evidence for asking.**
- Compensating inconsistency is generated explicitly, so a network can be
  consistent and intransitive at once. That is the case the consistency-based
  screens, the most-used device in practice, are structurally unable to catch.
- The go/no-go component in section 11 uses real evidence bases and is
  observational; it cannot establish what the right decision was, only whether a
  stated criterion would have reached it.

## 5. Methods, including one that can win

| screen | specification | role |
|---|---|---|
| dissimilarity and clustering | Spineli et al. 2025, on reported study-level characteristics | the prespecifiable screen that exists |
| consistency tests | node-splitting, design-by-treatment interaction | the most-used device in practice (34% to 47% of reviews) |
| residual heterogeneity | Phillippo et al. 2023's route | the PAIC-specific check, restricted to networks large enough |
| **held-out contrast prediction** | fit without one contrast, predict it, compare | the falsification device the catalog says PAIC lacks |
| **transported control-arm check** | predict the target's control arm and compare with observed | the same, on an absolute scale |
| union rule | any screen fires | section 2 consequence 3 |

**The comparator that can win is the consistency test.** It is what practice
actually uses, and if it has adequate power against the violations that matter
then the field's habit is defensible and the recommendation is a threshold rather
than a new screen. Registered as such, and section 2 predicts it fails
specifically against compensating inconsistency, which is a sharp and falsifiable
prediction.

## 6. Performance measures, MCSE, and $n_{sim}$

Size and power per screen per mechanism per alignment; **mechanism-identification
accuracy** as a multiclass classification, with a confusion matrix rather than an
accuracy figure, since which mechanism gets mistaken for which is the actionable
content; **feasibility rate**, the fraction of networks where each screen can be
run at all, which Spineli found was only 61% for statistical tests; and
**pairwise agreement between screens**, since disagreement is the empirical norm.

**The union rule's size is reported.** Six screens each at 5% do not give a 5%
rule, and a checklist assembled without that calculation would license abandoning
analyses at a rate nobody intended.

$n_{sim} = 4000$ networks per cell, derived from resolving a size of 0.05 to
within 0.007 and a power difference of 0.10.

## 7. Primary outcome and decision rule, before the run

**Primary outcome.** Power of each screen, and of the union rule, against each
mechanism at moderate magnitude, separately in the aligned and orthogonal
alignments.

**Decision rule.**

- Every mechanism detected at power $\geq 0.80$ by at least one screen at
  controlled union size: the screens **cover** the declared violation set, and the
  deliverable is the prespecification catalogue the catalog says is missing,
  naming which screen covers which mechanism.
- A mechanism with no screen above nominal power in the orthogonal alignment:
  **the blind spot is demonstrated concretely**, and the deliverable includes the
  statement that for that mechanism a screen cannot substitute for an explicit
  bias function, which is the catalog's own fallback.
- Screens detecting but misclassifying the mechanism: the deliverable is the
  confusion matrix and the explicit statement that a failure triggers
  investigation rather than a specific repair.

**Passing is reported with the sentence the catalog requires**, that passing does
not establish transportability, and that sentence is part of the registered
output rather than a discussion point.

## 8. Three controls, each of which can fail

**Null control.** With no violation, every screen must have size at its nominal
level and the union rule's size must match the calculated value. **Size is the one
thing a screen must get right before its power is worth reporting**, and Spineli's
finding that tests often disagree suggests at least one of them does not.

**Second null control.** In the orthogonal alignment at **large** violation
magnitude, the targeted screen's power must be statistically indistinguishable
from its size. **Section 2 says exactly nominal, not merely low**, and that is a
sharper prediction than "reduced power"; if power rises with magnitude in the
orthogonal direction, the projection argument is wrong and the blind spots have
not been constructed.

**Positive control.** In the aligned alignment at large magnitude, each screen
must reach high power against its own mechanism. A screen that cannot detect the
violation it was designed for is misimplemented.

**Falsifier for the study's own headline.** The expected headline is that the
available screens leave constructible blind spots. Its falsifier is the union
rule: if the union covers every mechanism at controlled size, the blind spots do
not survive combination and the practical conclusion is a checklist after all.
**That is the better outcome for the field and the design must be able to reach
it.**

## 9. Threats, and what happened to each

| threat | what was done | status |
|---|---|---|
| Restating the impossibility result as a study | Scope is calibration; the result is cited, not re-derived | removed |
| Blind spots hoped for rather than constructed | Computed in P2 by projection | removed |
| Union of screens presented without its size | Union size calculated and reported | removed |
| Screens calibrated on convenient networks | tracenma geometry and reporting distribution used | removed |
| Feasibility ignored, so screens are scored only where they run | Feasibility rate is a reported measure | removed |
| "Which mechanism failed" reported as accuracy | Confusion matrix | removed |
| Violations outside the declared list | Stated as the study's own blind spot, mirroring the screens' | disclosed |

## 10. Probes required before this becomes a protocol

| probe | computes | could change | cost |
|---|---|---|---|
| **P1** tracenma extraction | Network geometries and reported-covariate availability distributions from the 217 datasets | The generator's realism | days |
| **P2** blind-spot construction | For each screen, the violation direction with minimal detection probability, by projection | **The alignment factor.** Without it the orthogonal level is a guess and the second null control cannot be interpreted | days |
| **P3** screen implementations | That each screen reproduces its source paper's behavior on that paper's own example | Whether a screen is a comparator or a confound | days |
| **P4** unit cost | Per-network cost across six screens at $n_{sim} = 4000$; total computed not typed | $n_{sim}$ | hours |

## 11. The go/no-go component, and why it is not optional

The entry documents prespecified network meta-analyses abandoned because effect-
modifier similarity could not be assessed: three 2017 Cochrane reviews from one
group on an identical protocol, one after the models were fitted and inconsistency
detected, and two hepatocellular carcinoma reviews, one across a connected
18-trial evidence base, while other teams synthesize and rank the same
interventions. In one case the Cochrane Central Editorial Unit required the phrase
"attempted network meta-analysis" to be removed from the title.

**Once the screens are calibrated, those decisions become scorable for the first
time.** The component applies the calibrated screens to the evidence bases of the
abandoned reviews, so far as their reported covariates permit, and reports:

- whether each screen would have fired, and at what magnitude;
- whether the screen was **runnable at all** given what those trials reported,
  which is the catalog's separate and unaddressed question of what an analyst owes
  when a screen cannot be run;
- whether the go and no-go decisions on the same interventions by different teams
  are consistent with any single calibrated criterion.

**This is observational and cannot establish what the right decision was.** It can
establish whether the decisions were consistent with each other, which is the
weaker claim the record actually supports and the one worth making.

## 12. Cost

Dominated by $n_{sim}$ times six screens, most of which are cheap; the
residual-heterogeneity and held-out-prediction screens require model fits and set
the budget. Priced in P4.

---

## Relationship to the rest of the queue

- **IDN-07** owns when a held-out-trial discrepancy falsifies, which is the
  threshold for one of this study's screens.
- **IDN-09** owns negative controls for ITC, another falsification device on the
  same list.
- **IDN-10** owns transported control-arm calibration, which is one screen here
  and a study in its own right.
- **DIS-11** and **DIA-16** own bridge validation and deletion.
- **DIA-18** owns constancy across calendar time, which is one of this design's
  violation mechanisms.
- **COV-01** owns minimum covariate reporting, which is what would make these
  screens runnable more often.
