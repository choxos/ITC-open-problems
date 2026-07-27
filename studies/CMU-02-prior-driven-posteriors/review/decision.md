**Decision: published with Reviewer 1 standing at major revision and Reviewer 2 at minor, and
with the answer to CMU-02 narrowed twice under review.**

Not an acceptance. Reviewer 1 ends at major revision and this record does not overturn that.

## What is established

The **mechanism** does not depend on any threshold. Diagnostics in this family measure the
prior's influence on the posterior. With disconnected evidence, a tight prior centered at zero
and a true interaction four prior standard deviations away, coverage is near zero, and going
from 100 to 400 participants per arm makes the warning rate fall from 0.98 to 0.01 while the
answer stays wrong. More data lets the posterior contract, which every influence diagnostic
reads as reassurance. None of them compares the prior to anything outside itself.

The **measurement** is that at the thresholds examined these warnings coincide poorly with
realized interval misses: composite sensitivity 0.366 at a false-alarm rate of 0.158, and 0.127
outside two engineered geometries. The one sensitive rule fires on half the sound analyses.

A **correction to our own framing**, forced by review: used as continuous scores the same
statistics reach areas under the curve of 0.51 to 0.78, so the failure is a failure of
thresholds and not evidence that the statistics are uninformative. The word "structural" now
attaches only to the location-versus-influence argument, which no threshold repairs.

## What is not established

This is not calibration for detecting prior dominance. The reference standard is a realized
interval miss, a loss event, and a warning that correctly identifies a dominant prior in a cell
where the prior happens to be right is counted here as a false alarm. A non-circular reference
for dominance remains unfound: the obvious geometric one is algebraically identical to
contraction, which is why it was abandoned.

Nor is the software half of CMU-02 touched. Neither `multinma` nor `cpaic` is run, the Stan
validation named in the protocol was not performed, and the model is conjugate Gaussian.

## The process failure this study repeated

Both reviewers found that the round-one response claimed the target contrast formula had been
added when it had not. This is the third such occurrence in three studies. The guard added after
the previous study catches a rendered manuscript older than its source, but not this case, where
the source was never edited. The response letter now leads with the failure rather than the fix.

## Reviewer participation

Reviewer 1 (GPT-5.6 Sol, maximum reasoning effort) and Reviewer 2 (GLM-5.2 via Ollama) each
reviewed both rounds. Reviewer 1 moved from nine major comments to seven; Reviewer 2 from minor
revision to minor revision, judging twelve of sixteen round-one points fully resolved.
