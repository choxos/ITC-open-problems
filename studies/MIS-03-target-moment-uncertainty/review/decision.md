**Decision: published with the reviewer's standing recommendation of major revision
attached, and with the confirmatory question recorded as open.**

This is not an acceptance. Reviewer 1's round-two recommendation is *major revision*, and
this record publishes the paper without overturning that.

## Why publish rather than withhold

Three parts of the work stand independently of the objection.

The **analytic content** does not depend on the simulation at all. The omitted variance
component is $(1-2\kappa)\mathrm{Var}_T\{\tau\}/n_T$ to first order, its sign is set by an
alignment that the usual inputs do not identify, and a correction adding only the positive
term is closer to the right variance than doing nothing only when $\kappa < 1/4$. Both of
those results arrived through review: the first from reviewer 1 in round one, the second in
round two, each correcting a claim the authors had made.

The **negative result** is worth reporting on its own account. The conventional sandwich
used throughout fails at poor overlap for every method compared, including in scenarios
containing no effect modification, and that failure is larger than the effect the study was
built to measure. It is consistent with @chandler2024 and it invalidates absolute-coverage
claims in that region, which the paper now says.

The **registered negative outcome** is itself informative. A prespecified analysis that
returns "uninformative" and says so is a more useful contribution to a catalog of open
problems than a study that quietly reinterprets its gates.

## What is not established

The registered coverage question is **not confirmatorily answered**. Every usable coverage
result comes from a post-run restriction that conditions on an observed outcome correlated
with all methods assessed. Labelling that exploratory is necessary but does not convert it
into confirmatory evidence, as the reviewer said.

The catalog entries MIS-03 and EST-07 therefore record this study as answering part of the
problem with the confirmatory question open, not as closing it.

## Required for a confirmatory answer

A fresh run under a new registration, with either an ex ante design restriction such as
expected effective sample size, or a source variance procedure validated in advance to pass
the negative controls across the intended design. Interior values of $\kappa$ are needed to
test the one-quarter threshold empirically. Non-normal, categorical and rounded covariates
are needed before any reporting recommendation generalizes.

## Reviewer participation, and their disagreement

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) reviewed both rounds and ends at **major
revision**. Reviewer 2 (GLM-5.2 via Ollama) joined after the manuscript had been revised
through both of Reviewer 1's rounds, because the originally invited second reviewer could
not be reached, and ends at **minor revision** judging the conclusions supported and all
sixteen prior points resolved. Reviewer 2 therefore read a later version than Reviewer 1
first saw, and the record says so rather than presenting the reports as contemporaneous.

Kimi K3 via Ollama was invited in both rounds and could not be reached: the model is billed
as extra usage and the account's extra-usage balance was empty, verified through the CLI,
the HTTP API and the python client, so an account state and not a client fault. The
invitation and the failure are both recorded.

The two reviewers agree on what is wrong and disagree on how much it matters. This decision
follows Reviewer 1 on the point that governs the catalog: the analytic contribution is
confirmatory of theory and stands on its own, and the coverage evidence is exploratory and
does not close MIS-03. Reviewer 2's lighter recommendation is recorded, not overridden
silently.
