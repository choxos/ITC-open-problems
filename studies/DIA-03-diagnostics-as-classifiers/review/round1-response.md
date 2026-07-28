# Response to round one

Three reviewers, `major-revision` from two and `minor-revision` from one. Nineteen
comments, thirteen of them major. Every change described below was checked against the
manuscript source and the analysis code before this letter was written, by a script that
greps for the specific text of each claimed change; that check is in the study directory
and all thirty-four items pass. This program has three times published a response
describing a change the manuscript did not contain, and the check exists because of it.

Two of the reviewers' findings changed a result, not only a sentence. They are first.

---

## 1. The load-bearing claim in section 3 was wrong (Sol 1, Kimi 2, GLM 3)

All three reviewers, independently, said that our statement

> The first and third depend on the realized outcomes; no function of $X$, the weights and
> a published baseline table has any information about $\varepsilon$

is false, and that it is false in two separate ways. They are right on both.

**The arm-imbalance term uses no outcome at all.** $L(f)$ applies the estimator's linear
functional to the prognostic index, a function of realized covariates, treatment assignment
and weights. Grouping it with outcome noise as "not knowable from covariates" was simply an
error. It is now scored like the other two components, and it turns out to be the channel
effective sample size reads *best*: AUROC 0.813, against 0.847 for noise and 0.653 for
transport. Reporting it strengthens the paper rather than weakening it, because it shows
that the two components the panel tracks are exactly the two that are functions of the
information the panel is built from.

**The noise channel's variance is a known function of the weights.** Sol and Kimi both
derived it; we verified it numerically before accepting it:

$$\mathrm{Var}\{L(\varepsilon) \mid X, A, w\} = \sigma^2(1/\mathrm{ESS}_A + 1/\mathrm{ESS}_C)$$

exactly, with arm-specific effective sample sizes. So an area under the curve of 0.847
against the noise event is close to arithmetic and we now say so in the text rather than
presenting it as a discovery. One qualification we have added because it is true and
matters: the *reported* pooled effective sample size is not that quantity.
$2\sigma^2/\mathrm{ESS}_{\text{pooled}}$ is about 0.54 of the correct value in a
representative cell, and correlates with the exact noise standard deviation at $-0.92$ on
the log scale rather than at $-1$. So it is a strong proxy, not an identity.

What survives is the comparison, and we have rewritten section 3 to make the argument turn
on it: nothing forces a weight-dispersion statistic to be uninformative about the gap
between a weighted source and a target, and in the well-specified stratum it reaches 0.946
against the transport component. What it cannot see is the part of the modifier structure
the weights never touched.

## 2. The calibration split was confounded (Sol 6)

Sol warned that a single odd-cell/even-cell split "may separate levels of a design factor
depending on cell enumeration". We checked, and in this design it did so perfectly: cells
are enumerated with the target dispersion ratio varying fastest, so **every** odd cell had
ratio 1.00 and **every** even cell had 1.25. The reported cross-cell calibration measured
transport across one factor and we called it transport in general.

Replaced by leave-one-factor-level-out: fourteen folds, each holding out every cell at one
level of one factor, balanced across everything else by construction. The numbers changed
and the conclusion changed with them. Effective sample size now has a median integrated
calibration error of 0.076 and a **worst-fold error of 0.197**, and the previous claim that
the overlap statistics calibrate much worse than the weight statistics (0.143 against 0.065)
was an artifact: on a balanced split they are 0.098 and 0.076.

The new result is better than the old one. The worst held-out level is the same for every
weight-dispersion statistic in the panel, and it is the cross-moment channel: a risk mapping
learned where a bias no baseline table can reveal is operating, applied where it is not, is
off by about twenty points of absolute risk. That is the substantive transportability
finding, and it is now the one the paper makes.

We have also stated the model form Sol asked for: a logistic regression on one transformed
diagnostic, minus the natural logarithm where a low value is the warning and the statistic
itself otherwise, one linear term, no splines.

---

## Point by point

**Sol 2, Kimi 1. Which contrast is scored.** Agreed and fixed. The primary reference is the
transported $A$ versus $C$ effect, the design section now says so in the first sentence
about the reference, and the reason is given: the anchored contrast carries the target
trial's sampling error, which no source-side diagnostic can observe. The anchored contrast is
now reported alongside every discrimination result and in its own operating-point table, and
the conclusions are unchanged (effective sample size 0.699 against 0.731).

**Sol 3. Findings built into the mechanism.** Partly agreed and now labeled. The noise result
is presented as an arithmetic check, per point 1. The dispersion factor lowering effective
sample size without bias in the well-specified stratum is stated as a designed property, not
a finding; it is the instrument that makes the study falsifiable, and the protocol already
says so. We do not agree that the omitted-modifier and cross-moment channels being invisible
to marginal balance statistics is "built in" in the objectionable sense: that a marginal
statistic cannot see a cross-moment is a mathematical fact about the diagnostics, and
demonstrating its consequence is the point of the study, not an artifact of it. What is
genuinely built in, and now stated, is *how often* those channels operate, which is why the
primary results are within strata.

**Sol 4. The proposal is not compared on equal information.** Agreed, and this is the
sharpest comment on our own contribution. $\widehat{b}$ uses source outcomes through an
interaction estimated in the sample whose error is being diagnosed, while the panel is
outcome-free. It is now labeled an outcome-model-assisted diagnostic wherever it appears, the
in-sample optimism is stated, and we say we did not cross-fit. We have also reported that the
plain balance check on unmatched covariates does about as well here (0.946 against 0.938),
and changed the recommendation accordingly: check balance on everything you measured, not
only on what you matched. That is a weaker claim than the one we set out to make and it is
the one the data support.

**Sol 5. "Does not classify" overstates.** Agreed on the framing. The verdict label is
registered and we have not changed it, but the abstract now states precisely what it means:
no evaluated fixed cutoff met a sensitivity and specificity pair chosen in advance. The
limitations say that those requirements were not derived from an elicited loss function, that
the statistics do carry information, and that a reader wanting a different operating point
can take one off the ROC curves. What the decision-curve analysis adds is that at the action
thresholds a cautious analyst would use, no available operating point beats scrutinizing
everything.

**Sol 7. Registered analyses missing from the paper.** Agreed and fixed. Discrimination
against arm imbalance, equal-cell-weight areas under the curve, material thresholds of 0.10
and 0.30, and the anchored contrast are now in one table. Per-cell non-fit rates are in the
tracked results. We have not added paired Monte Carlo intervals for the two AUROC
differences behind the mechanism claims; the bootstrap is cell-stratified and unpaired, and
constructing paired intervals properly is more work than the remaining claims can carry. We
say instead, in the mechanism section, that both differences are reported as point estimates
against a registered threshold.

**Sol 8. The material threshold is on the residual scale.** Agreed; this was an error. 0.20
is a fifth of the residual standard deviation, not of the marginal outcome standard
deviation, which contains the prognostic index and runs from 1.37 to 1.66 across the design.
Corrected, with the range reported, and the 0.10 and 0.30 analyses are now shown.

**Sol 9. The span across cells is predictive value, not calibration.** Agreed, and this
retracts something we had promoted. A first draft called the silent-cell span "a stronger
result" than the registered claim. It is not; both spans are variation in predictive value,
which moves with prevalence and case mix even when operating characteristics are stable. The
text now says that, says the registered test failed, and points to the leave-one-factor-out
calibration as the proper evidence on transportability.

**Sol 10. Decision-curve prose did not match the table.** Correct. Three rules exceed both
alternatives at an action threshold of 0.4, not one. Fixed, and the sentence now names them.

**Sol 11. Conditioning on convergence removes the cases where balance can warn.** Agreed and
this is a real narrowing of our claim. The finding is now stated as: among analyses that
converged, the matched-moment balance statistic is redundant by construction, and reporting
it as evidence the adjustment worked is reporting that the solver terminated. Whether it is
useful as a convergence check is a different question this design cannot answer, and we say
so. The non-fit rate is reported separately.

**Sol 12, Kimi citations. Practice and novelty under-evidenced.** Agreed in substance. The
introduction now attributes the reporting conventions to the NICE DSU guidance
[@phillippo2018] and, for the overlap statistics, to the transportability literature
[@stuart2011; @tipton2014]; describes the ISPOR abstract as a region found in a different
setting that is now quoted informally rather than as a published rule; and states plainly
that **we have not surveyed how appraisal committees use these numbers and make no claim
about it.** Kish is now cited for the effective sample size and the identity, which is
standard survey-weighting arithmetic and not ours. The protocol adds a note on which
thresholds have a primary source and which are conventions in circulation without one. We
have not produced a reproducible literature-search account; the audit that produced the
open problem is published with the catalog, and we point to it rather than restating it.

**Sol 13. Limitations under-rank the real threats.** Agreed and rewritten around them: the
transport component is a realized effect-modifier component and not isolated systematic
bias; the proposal receives outcome information the panel does not; the anchored contrast is
secondary; and the operating characteristics are properties of the declared distribution,
not of the diagnostics.

**Sol 14, Kimi 8. Internal inconsistencies.** Fixed. The protocol's arithmetic now reads
$128 \times 4000 \times 4$ and its linearity statement says four estimators.

**Sol 15 (replicate count), within Sol 14's group.** Agreed and added: the 4000 figure was
derived at an assumed prevalence of 0.10, and at 1% the same formula gives about 0.045, so
the least informative cells are estimated far less precisely than the headline. The primary
measure is a cell-weighted ratio whose Monte Carlo error comes from the delta method, which
is an order of magnitude smaller; the protocol now says both things.

**GLM 1, Kimi 5. The abstract's numbers appeared in no table.** Correct and fixed; the
stratum-by-component table is new. It also answers Kimi's question about which panel member
reaches 0.851.

**GLM 2. The abstract framed a missed claim as a positive result.** Agreed. The abstract now
says two of four registered mechanism claims failed, including one of our own proposals.

**GLM 4. Morris et al. missing from the manuscript's references.** Fixed.

**GLM 5, Kimi 7. Coverage of the primary estimator missing.** Fixed; all four estimators are
in a coverage table. MAIC covers at 0.748 on the transported effect over a design containing
a great deal of deliberate misspecification.

**Kimi 3. "Removes the dependence entirely" overstates.** Agreed. Within-stratum reporting
removes the dependence on the misspecification frequencies only; the design points, the
levels and equal weighting inside a stratum are still ours. The limitations now say this and
name what remains.

**Kimi 4. The non-fit bracket was arithmetically unclear.** Fixed: the bracket is over the
whole design with cells weighted equally, not within the omitted-modifier stratum, and it
moves the figure by under a percentage point because MAIC converged on 99.3%.

**Kimi 6. Identical rows for pre-weighting imbalance and Mahalanobis distance.** Not a
table-generation error. In this mechanism the target mean is displaced by the same amount in
every covariate, so the maximum standardized difference and the Mahalanobis distance are
near-monotone functions of each other and agree to three decimals. It is a property of the
design and a limitation of it: a design with differential displacement would separate them.

**Kimi 9. The 50% effective-sample-size rule is labeled published without a citation.**
Agreed; relabeled as a convention in circulation, with the protocol note above.

---

## What we did not do

We did not add heteroskedastic errors, nonlinear or multiple omitted modifiers, uncertain
target moments, or additional estimator families (Sol 3, Sol 4, Sol 12). Each is a real
extension and each is a different study; the limitations name them. We did not cross-fit the
proposed diagnostic. We did not construct paired Monte Carlo intervals for the two mechanism
differences. We did not survey appraisal practice, and we now say we did not rather than
implying we had.
