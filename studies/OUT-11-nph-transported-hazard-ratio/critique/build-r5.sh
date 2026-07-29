#!/bin/zsh
## Assemble the round-five critique payloads.
##
## SPLIT INTO SIX PARTS, NOT TWO. The second reviewer's input ceiling is not a
## stable size: it succeeded at 37.9 KB in round three and returned zero bytes at
## 37.4 KB in round four, below a size that had previously worked. Round four's
## first half was never reviewed as a result, which is why one of its fatals had
## to be found by the other reviewer alone. Each part here targets roughly 15 KB
## so the ceiling is not being probed at all.
##
## The whole-protocol payload is still built for the first reviewer, which has no
## such limit.
cd "$(dirname "$0")/.."

hdr() {
  cat <<HDR
# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART $1 OF 7: $2

You are reviewing a protocol revised four times. Round one returned \`unsound\`,
round two \`unsound\`, round three \`unsound\`, round four \`unsound\`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
\`round4_resolution\` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

HDR
}

## --- part A: the problem, the mechanism, the estimand ------------------------
{
  hdr A "the problem, the data-generating mechanism, and the estimand"
  sed -n '/^## 1\./,/^## 5\./p' protocol.md | sed '$d'
} > critique/design-for-critique-r5-a.md

## --- part B: E1 and E2, the two analytic experiments -------------------------
{
  hdr B "E1 and E2, the anchored contrast, rebuilt this round"
  sed -n '/^## 5\./,/^## 7\./p' protocol.md | sed '$d'
  cat <<'TAIL'

# THE ANCHORED LIMIT, VERBATIM

TAIL
  echo '```r'
  cat R/02b-anchored-limit.R
  echo '```'
} > critique/design-for-critique-r5-b.md

## --- part C: the estimators ---------------------------------------------------
{
  hdr C "the seven estimator rows and the fairness of the comparison"
  sed -n '/^## 7\./,/^## 8\./p' protocol.md | sed '$d'
} > critique/design-for-critique-r5-c.md

## --- part D: cells and Monte Carlo error --------------------------------------
{
  hdr D "the cell matrix and Monte Carlo error"
  sed -n '/^## 8\./,/^## 10\./p' protocol.md | sed '$d'
} > critique/design-for-critique-r5-d.md

## --- part E: the registered outcomes ------------------------------------------
{
  hdr E "the registered outcomes, and the decision rule that was withdrawn"
  sed -n '/^## 10\./,/^## 11\./p' protocol.md | sed '$d'
} > critique/design-for-critique-r5-e.md

## --- part F: scope and the change log ----------------------------------------
{
  hdr F "what this cannot settle, and the change log across five rounds"
  sed -n '/^## 11\./,/^## 14\./p' protocol.md | sed '$d'
} > critique/design-for-critique-r5-f.md

## --- part G: feasibility, measured, and the frozen run -----------------------
{
  hdr G "feasibility, the integration order, and the frozen run"
  sed -n '/^## 14\./,$p' protocol.md
  cat <<'TAIL'

# THE BUDGET, COMPUTED RATHER THAN TYPED, VERBATIM

Two of the last two rounds produced a fatal finding against a hand-written total
that did not follow from the unit costs beside it. This file is the response.

TAIL
  echo '```r'
  cat R/10-budget.R
  echo '```'
} > critique/design-for-critique-r5-g.md

## --- the whole thing, for the reviewer without a ceiling --------------------
{
  hdr "FULL" "the complete protocol"
  cat protocol.md
  cat <<'TAIL'

# LOCKED CONFIGURATION, VERBATIM

The protocol's parameter table is a transcription of this file, which the run
sources. It is included so the transcription can be checked.

TAIL
  echo '```r'
  cat R/00-config.R
  echo '```'
} > critique/design-for-critique-r5.md

for f in critique/design-for-critique-r5*.md; do
  printf '%-46s %6d bytes\n' "$f" "$(wc -c < $f)"
done
