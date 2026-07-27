**Decision: published with both reviewers standing at major revision, and with the general
headline restricted to the specification simulated.**

This is not an acceptance. Both reviewers ended round two at *major revision* and this record
publishes the paper without overturning that.

## Why publish

The **algebra** stands independently of everything the reviewers disputed. For a binary
modifier with study-specific prevalence, a shared interaction on a globally centered covariate
is identically the sum of a within-trial and an across-trial term, so fitting one coefficient
imposes their equality rather than pooling information about them. That is a fact about the
parameterization.

The **simulation** is a calibrated stress test of what that restriction costs in the model
simulated: coverage falling from 93.8% to 17.2% as the two coefficients diverge, both
separated estimators holding inside the band, and separation costing about five per cent in
interval width for an order of magnitude less bias. Those numbers describe a fixed-effect
Poisson component model with one binary modifier, not component ML-NMR in general.

Two findings arrived that nobody asked for and are worth the record on their own: an
uncorrected twelve-cluster sandwich is badly anticonservative here, covering 75.4% to 92.4%
where the model is correctly specified; and where a component has no within-trial information
the three methods fail in three different ways, only one of which is to decline.

## What is not established

The **general headline about component ML-NMR** is not supported. The likelihood and nuisance
structures are not mapped onto the fixed- and random-effect specifications the implemented
method offers, and free study-by-treatment effects or priors can absorb or alter the very term
the identity isolates. Reviewer 1 pressed this in both rounds and it is right.

The **registered global analysis is uninformative**, and the regime split that produced a
usable answer was prompted by observing that failure. It uses a factor level fixed before the
run, which is a weaker objection than selection on results, but it is not prespecification.

The **mechanism claim** is not supported and fell narrowly short of its registered refutation
threshold. What the data show is that aggregate data are not necessary for the conflation but
do amplify it, so CMP-13 names an aggravating factor as the cause.

## The process failure this round exposed

Both reviewers independently found that the round-one response letter described changes the
manuscript did not contain. Some had genuinely not been made; one had been made in the results
and not the abstract, because the edit matched a differently wrapped copy of the paragraph and
silently did nothing; and the copy served to reviewers predated the source for that paragraph.

All six gaps are closed and the harness now refuses to send a review package whose rendered
manuscript is older than its source. The failure is recorded here rather than quietly repaired
because it cost a full review round, and because a response letter that misdescribes the
manuscript is a worse fault than the omission it conceals.

## Required before the general claim is made

A Bayesian evaluation against the implemented method with its actual priors and random-effect
options; a fresh registration whose gates anticipate the near-unidentified regime instead of
pooling it; paired Monte Carlo uncertainty for the network-structure contrast and for the
incremental effect of removing individual data; and non-additive or heterogeneous component
mechanisms to see whether the pattern amplifies.

## Reviewer participation

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) and Reviewer 2 (GLM-5.2 via Ollama) each
reviewed both rounds. Kimi K3 via Ollama was invited for the previous study and could not be
reached; it is not counted here. The two reviewers converged in round two after disagreeing in
round one, which is itself informative: Reviewer 2 moved from minor to major revision on
discovering the response-manuscript mismatch.
