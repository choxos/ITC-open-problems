Both reviewers report that our round-one response claimed a change the manuscript did not
contain. They are right, and it is the same failure that occurred in the previous study of this
program, so it is answered first and treated as a process problem rather than an oversight.

# The response letter again described a change we did not make

We wrote "The contrast formula is now given". It was not. The manuscript defined the target
contrast only in words. Both reviewers looked for the formula and neither found it.

This is the third occurrence of this failure across three studies. The pattern is consistent:
we compose the response while making the edits, and an edit that fails to apply, or that we
defer while writing, leaves a claim in the letter with nothing behind it. After the previous
study we added a check that a review package cannot be older than the manuscript source, which
catches a stale render but not this, because here the source itself never changed.

What is now in the manuscript, in the design section:

$$\Delta_{CB}(\mu_X) = (d_C - d_B) + (\gamma_C - \gamma_B)\,\mu_X,$$

with $\mu_X$ stated as a known superpopulation mean rather than a realized target-sample mean
or an estimate, so no uncertainty in it is propagated; the posterior contrast vector written
out; the true main effects and interactions given numerically; the three prior scales given as
standard deviations; and the individual-data and aggregate contributions to $V$ described.

## Reviewer 1, Major 3. Prior-truth separation was not reported

**Accepted and added.** A true $\gamma_C$ of 0.40 lies 4.0 tight-prior standard deviations from
the prior mean, 1.6 regular and 0.4 weak. The reviewer is right that under the tight prior, in a
direction the likelihood barely informs, near-zero coverage follows arithmetically. The
manuscript now states these numbers where the mechanism is described and says the sample-size
result demonstrates a mechanism rather than estimating how often it occurs.

## Reviewer 1, Major 1. The target mismatch remains

**Accepted, and the claim is narrowed again.** We agree that a realized interval miss is a loss
event and not a definition of prior dominance, and that a warning in a prior-dominated cell
where the prior happens to be right is counted here as a false alarm though it is correct in the
diagnostic's own terms.

The scope section now says what is actually established: these warnings coincide poorly with
realized interval misses at the thresholds examined, and the influence-based family cannot see a
misplaced prior. It no longer says the study calibrates them for detecting prior dominance. We
also state that finding a non-circular reference for dominance is itself unfinished business,
since the obvious geometric one is algebraically identical to contraction.

## Reviewer 1, Major 4. The pooled estimand is not the registered macro-average

**Accepted as a limitation, not fully repaired.** The registered primary measure was a
macro-average across harmful scenario-contrasts; what is now reported is a pooled
$\Pr(\text{warning} \mid \text{miss})$, which weights cells by their number of misses. We
changed it because the registered version was not sensitivity at all, which the reviewer
established in round one, but the replacement is a different estimand and the manuscript should
not present it as the registered one. It now does not. Monte Carlo standard errors treat
replicates as independent draws, which ignores that the two contrasts come from the same
replicate; we state this rather than correct it, and note the standard errors are consequently
slightly optimistic for statements pooling both contrasts.

# Response to Reviewer 2

**Minor 1, the contrast formula.** Addressed above; the reviewer is right and the failure is
recorded rather than quietly fixed.

**Minor 2, squared versus unsquared Hellinger.** Accepted. The prior-only benchmark uses the
squared distance, as the protocol specifies, and power-scaling uses the unsquared one. The
manuscript described both as "Hellinger distance"; the table and text now distinguish them. We
also no longer say the 0.05 threshold "carries over" from cumulative Jensen-Shannon, and
describe it as a choice informed by that default.

**Minor 3, prior-data conflict literature.** Accepted and cited. Evans and Moshonov's
prior-data conflict checking and Presanis and colleagues' conflict diagnostics for
evidence-synthesis graphs address prior *location* directly, and the manuscript now situates the
influence-versus-location distinction in that taxonomy rather than presenting it as new. What
this study adds is the measurement that the influence-based family, which is what CMU-02 names,
does not substitute for a conflict check.

**Minor 4, does the composite add anything.** Accepted and now reported. The composite's
sensitivity of 0.366 sits just above contraction alone at 0.363, at a slightly higher false-alarm
rate, 0.158 against 0.141. Requiring two of four rules to agree neither buys specificity nor
recovers sensitivity here, and the manuscript says so.
