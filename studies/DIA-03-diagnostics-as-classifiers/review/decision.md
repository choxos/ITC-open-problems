**Decision: published with Reviewer 1 standing at major revision, Reviewers 2 and 3 at minor,
and with the paper's central claim narrowed and retitled under review.**

Not an acceptance. Sol ends at major revision and this record does not overturn that. Ten of
his sixteen round-one points close as "partly", and the residue is real: fold-level
uncertainty for the calibration analysis, paired Monte Carlo intervals for the two mechanism
differences, a reproducible literature-search account, and richer functional forms for the
risk mapping are all absent.

## What is established

Two facts are settled by algebra and the run only checks the implementation.
$\mathrm{ESS}/n = 1/(1 + \mathrm{CV}^2(w))$ exactly, and area under the ROC curve is
invariant to monotone transformation, so within a fixed source size effective sample size,
the same figure as a percentage and the coefficient of variation of the weights have
identical discrimination; they agreed to 0.0e+00. The post-weighting standardized difference
on the matched moments is zero at the solution of the calibration equations; it never
exceeded 1.4e-14, and its apparent area of 0.550 is discrimination of floating-point
residual. Of the panel a submission reports, one number carries the weight-dispersion
information and one carries none.

The **measurement** is that no evaluated fixed cutoff met the registered requirement of
sensitivity 0.80 at specificity 0.50 in every misspecification stratum. Effective sample
size below 35 catches between a quarter and a third of material errors, 0.309 in the stratum
where a modifier is omitted and the omission is diagnosable in principle. On a
decision-curve basis every rule in the panel is beaten by scrutinizing every analysis up to
an action threshold of 0.3.

The **mechanism**, at the level of a single analysis, is that effective sample size reads
the two error components that are functions of the covariates, the assignment and the
weights, at 0.847 and 0.813, and the effect-modifier component that adjustment exists to
remove at 0.653.

## What review changed

**The load-bearing claim of the first draft was wrong, and all three reviewers found it
independently.** We had written that only the transport component is knowable from
covariates. The arm-imbalance component uses no outcome at all, and the noise component's
conditional variance is exactly $\sigma^2(1/\mathrm{ESS}_A + 1/\mathrm{ESS}_C)$, so a
weight statistic is its natural summary rather than merely correlated with it. Both were
verified numerically before being accepted. The arm-imbalance component is now scored and
the noise result is presented as an arithmetic check.

**The calibration analysis was confounded.** Cells are enumerated with the target dispersion
ratio varying fastest, so training on odd-numbered cells and testing on even ones put every
ratio-1.00 cell in training and every 1.25 cell in test. Sol predicted this failure mode
before checking it. Leave-one-factor-level-out replaced it, one earlier finding was withdrawn
as an artifact, and the replacement is sharper: the worst held-out level is the same for
every weight statistic in the panel, the cross-moment channel, where a risk mapping learned
elsewhere is off by about twenty points of absolute risk.

**The title claimed more than the results support.** The realized transport component of one
replicate is not systematic bias. Scored against systematic bias with the design cell as the
unit, effective sample size reaches 0.808 rather than 0.653. That analysis does not rescue
the panel either, since the statistic that is identically zero reaches 0.708 on it, but it
does mean the variance-versus-bias dichotomy asserted in the first title was not established.
The title now claims only the replicate-level result, which is the level at which a
diagnostic is read.

**Our own proposal was demoted, then partly restored, and both moves are in the record.** It
uses source outcomes while the panel does not, so it is labeled outcome-model-assisted and
the in-sample optimism is disclosed. It missed its registered bar. Inside the
omitted-modifier stratum the plain balance check on unmatched covariates beats it; across the
diagnosable set, which includes cells where the unmatched covariate is harmless, it wins.
The surviving recommendation is narrower than the registered claim and wider than the
retraction we first offered.

Also corrected: the material threshold is a fifth of the residual and not the outcome
standard deviation; the silent-cell span is variation in predictive value and not a form of
the registered transportability claim; the matched-moment result holds only among analyses
that converged; and the practice and novelty claims are attributed to the DSU guidance, to
Kish and to the transportability literature, with an explicit statement that appraisal
practice was not surveyed.

## The process failure, fourth occurrence

The round-one response described the knowability claim as retracted while the abstract still
contained it. The check written after study 2, and run before that letter, passed
thirty-four of thirty-four items: it verified that every new statement was present and never
that any retracted statement was absent. Kimi then found two further survivals in the
introduction and the protocol, sections the check did not read, and the pattern that failed
first was literal enough to break on a reflowed paragraph, which is how the study-2 check
passed while the manuscript went unchanged.

The check now has a negative half, normalizes whitespace before matching, and reads the
manuscript source, the rendered output, the protocol and the analysis code. It is published
in the study directory rather than described. Forty-seven of forty-seven pass on the text as
published. That is the fourth revision of a control that has failed four times, and the
honest thing to say is that it has not yet gone a round without being caught by a reviewer
rather than by itself.

## What this does not close

DIA-03's second half is untouched: no PSIS-LOO at any hierarchical level, and grouped
study-level leave-one-out is no more implemented here than in the packages. DIA-06 is
answered only in part, for two estimator families out of five. The outcome is continuous with
an identity link, which is what buys the exact error decomposition and rules out anything
about non-collapsible effect measures or time-to-event outcomes. The deployment weights are a
declared judgment that nothing in this program measured, and the design points, levels and
equal weighting inside a stratum remain ours.
