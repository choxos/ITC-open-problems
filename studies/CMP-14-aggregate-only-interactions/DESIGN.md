# DESIGN: superseded by protocol.md

This file was the pre-registration sketch, written before the protocol and before any round of
critique. **It is kept for provenance and is no longer maintained.** Several things it says are
now known to be wrong, and correcting it in place would destroy the record of what was believed
when.

Read [`protocol.md`](protocol.md) instead. What this file got wrong, and where the corrections
live:

| this file said | what is true | where |
|---|---|---|
| the curvature state is "a single aggregate study on a nonlinear link" | one aggregate arm gives one proportion for two unknown target parameters, so it identifies nothing. The state needs two aggregate studies at the same covariate mean with different covariate SDs | protocol §2, §7; `R/06-nonlinear.R` |
| E2 would be fitted with `multinma` at 24 scenarios and 200 replicates | E2 is an asymptotic calculation from the Fisher information. No model is sampled and no sampler policy exists, because none is needed | protocol §7; `R/07-run-e2.R` |
| "the prior scale" as a single design factor | the registered factor is the prior on the **interactions**; nuisance coefficients carry a fixed weak prior, and applying one scale to everything confounded the factor with nuisance shrinkage | protocol §5 |
| each state built with the same arm size | the same arm size is not the same evidence budget: `additivity` has twelve arms against the others' ten and ran on 20% more patients | protocol §2 |
| "contraction is a function of the design alone, computable before a single patient is enrolled" | it depends on the realized covariate design; what is true is that it never depends on the outcomes | protocol §5 |

The one thing this file got right and worth keeping is the reason the study exists: the two
summaries CMP-14 asks for cleanly separate "no likelihood information" from "some", and do not
separate randomized information from confounded information at all.
