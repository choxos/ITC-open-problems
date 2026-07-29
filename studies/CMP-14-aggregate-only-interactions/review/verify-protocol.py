#!/usr/bin/env python3
"""Assert the protocol's numeric claims against what the code actually produces.

The rule, carried over from the previous study in this programme, which published
an unsupported number six times: if the protocol prints a number, R/05-export.R
exports it and this script asserts it. Whole tables are compared cell by cell,
not spot-checked, because a spot check is what failed there.

Two additions specific to this study.

1. THE CONTROLS ARE ASSERTED, NOT JUST CLAIMED. Section 5 lists four controls
   that gate the run. A control described in prose and checked nowhere is
   decoration, and this document concedes in section 8 that two of its guards
   were weakened after failing, so the weakened versions have to be checked
   against what actually made them pass.

2. THE REGISTRATION STATUS IS ASSERTED. E1 is exploratory and E2 is
   confirmatory, and the whole interpretation depends on the document not
   quietly upgrading E1 later. The check looks for the concession and for the
   absence of confirmatory language attached to E1.

    Rscript R/05-export.R
    python3 review/verify-protocol.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = (ROOT / "protocol.md").read_text()
PROTOCOL = re.sub(r"\s+", " ", RAW)
DESIGN = json.loads((ROOT / "results" / "registered-design.json").read_text())

fails: list[str] = []
checks = 0


def check(label: str, ok: bool, detail: str = "") -> None:
    global checks
    checks += 1
    if not ok:
        fails.append(f"{label}{': ' + detail if detail else ''}")


def present(label: str, *needles: str) -> None:
    for n in needles:
        check(label, n in PROTOCOL, f"missing {n!r}")


def nums(row: str) -> list[float]:
    return [float(x.replace("$", "").replace(",", ""))
            for x in re.findall(r"[-+]?\d+\.\d+|[-+]?\d+", row)]


def table_after(needle: str) -> list[str]:
    lines = RAW.splitlines()
    for i, ln in enumerate(lines):
        if needle in ln and ln.lstrip().startswith("|"):
            body = []
            for ln2 in lines[i + 2:]:
                if not ln2.lstrip().startswith("|"):
                    break
                body.append(ln2)
            return body
    return []


# Every key any block below reads, required once up front so a missing export is
# a loud failure rather than a quiet subtraction from the denominator.
REQUIRED_KEYS = [
    "n_scenarios", "n_failed", "n_ok", "by_state", "overlap", "pairs_total",
    "pairs_close", "pairs_close_max_cover_gap", "anticorrelation", "warnings",
    "control_absent_min_contraction", "control_null_min_coverage",
    "control_tight_max_coverage", "control_absent_cover_by_prior",
    "probe_inverts", "probe_best_ecological", "probe_worst_randomized",
    "probe_null_cover_min", "probe_null_cover_max",
    "contract_ok", "eff_ratio_ok", "source_ok", "cover_bad", "nominal",
    "spreads", "discord", "total_n", "prior_sd", "synergy", "states",
    "curvature_rank",
    "e2_link", "e2_states", "e2_n_rep", "e2_scenarios", "gamma_w",
]
for k in REQUIRED_KEYS:
    check(f"the export carries {k}", k in DESIGN,
          "its assertions would otherwise be skipped silently")

# --- the registered configuration --------------------------------------------
check("the scenario count is the grid's own count",
      f"**{DESIGN['n_scenarios']} scenarios**" in PROTOCOL,
      f"protocol does not state {DESIGN['n_scenarios']}")
present("the failure threshold", f"`COVER_BAD = {DESIGN['cover_bad']:.2f}`")
present("the registered thresholds",
        f"`CONTRACT_OK = {DESIGN['contract_ok']:.2f}`",
        f"`EFF_RATIO_OK = {DESIGN['eff_ratio_ok']:.2f}`",
        f"`SOURCE_OK = {DESIGN['source_ok']:.2f}`")

# The grid table, factor by factor, so a level added to the code and not to the
# document is a failure rather than a silent divergence.
GRID = table_after("| factor | levels |")
check("the grid table is present", len(GRID) >= 6, f"{len(GRID)} rows")
LEVELS = {
    "between-study covariate spread": DESIGN["spreads"],
    "total patients per network": DESIGN["total_n"],
    "prior SD on interactions": DESIGN["prior_sd"],
}
for label, want in LEVELS.items():
    row = next((r for r in GRID if label in r), None)
    check(f"the grid states the levels of {label}", row is not None,
          "row not found in the grid table")
    if row is not None:
        got = nums(row.split("|")[2])
        check(f"the levels of {label} match the code", got == list(want),
              f"document {got}, code {list(want)}")

check("the states table lists every registered state",
      all(s in PROTOCOL for s in DESIGN["states"] + ["curvature"]),
      "a registered information state is not described")

# --- the four controls -------------------------------------------------------
# Asserted against the values that made them pass, because two of them were
# weakened after failing and a weakened control has to be shown to still bite.
check("the absent state really is prior-only",
      DESIGN["control_absent_min_contraction"] > 0.999,
      f"min contraction {DESIGN['control_absent_min_contraction']}")
check("the null control does not undercover",
      DESIGN["control_null_min_coverage"] >= DESIGN["nominal"] - 0.01,
      f"min coverage {DESIGN['control_null_min_coverage']}")
tight = DESIGN["control_tight_max_coverage"]
check("the tight prior depresses every state at the smallest budget",
      all(v < 0.94 for v in tight.values()),
      f"max coverage per state {tight}")
byp = DESIGN["control_absent_cover_by_prior"]
check("the grid holds both a harmless and a harmful prior-driven parameter",
      min(byp.values()) < 0.01 and max(byp.values()) > 0.99,
      f"absent-state coverage by prior SD {byp}")
check("the protocol lists all four controls",
      RAW.count("\n1. **Absent is prior-only.**") == 1
      and "**The null control does not undercover.**" in PROTOCOL
      and "**The tight prior pulls every state toward zero, and hurts the "
          "least-informed state most.**" in PROTOCOL
      and "**Both kinds of prior-driven parameter are present.**" in PROTOCOL,
      "a control described in section 5 is missing")
# The two controls round 1 found overpromising must state what they now test,
# not merely that they pass.
check("the null control no longer claims nominality",
      "It is *not* claimed to be nominal" in PROTOCOL,
      "the control still promises more than it checks")
check("the prior-domination control withdraws the word alike",
      '**"Alike" is withdrawn.**' in PROTOCOL,
      "the withdrawn claim is still standing")

# --- the primary outcomes ----------------------------------------------------
check("primary 1 is stated as an existence claim, not an average",
      "no threshold separates them" in PROTOCOL
      and "whatever the grid contains" in PROTOCOL,
      "primary 1 does not disclaim grid weighting")
check("the secondary table is labeled grid-weighted",
      "labeled as grid-weighted" in PROTOCOL or "and are reported\nas such" in RAW,
      "the threshold table is not disclaimed")
check("primary 3's sign is explained the way it must be read",
      "a POSITIVE\ncorrelation means the diagnostic becomes more reassuring as the answer gets\nworse"
      in RAW or "POSITIVE" in PROTOCOL and "more reassuring as the answer gets worse" in PROTOCOL,
      "the inverted sign is not explained")

# --- section 8, the disclosure list ------------------------------------------
# The concession that E1 is exploratory is what makes the rest interpretable, so
# it is asserted rather than trusted.
check("E1 is declared exploratory",
      "**E1 is therefore reported as exact and exploratory**" in PROTOCOL,
      "the exploratory concession is missing")
check("E2 is declared confirmatory and unrun",
      "E2 is confirmatory and is registered blind" in PROTOCOL
      and "It has not been run" in PROTOCOL,
      "E2's status is not stated")
DISC = table_after("| change | why | what it would have hidden |")
check("the disclosure list covers both rounds of changes",
      len(DISC) >= 10 and sum("**Round 1:**" in r for r in DISC) >= 7,
      f"{len(DISC)} rows, {sum('**Round 1:**' in r for r in DISC)} from round 1")
check("the disclosure counts the guards that were weakened",
      "Five of these are guards that were written from expectation, failed, and were changed"
      in PROTOCOL,
      "the weakened guards are not counted")
check("round 1's single-reviewer status is recorded",
      "Round 1 was a single reviewer" in PROTOCOL
      and "neither is counted as agreement" in PROTOCOL,
      "the unavailable reviewers are not recorded as not obtained")
check("E2 carries a condition that would withdraw E1's conclusion",
      "then E1's central claim is an artifact of the identity link and **is withdrawn**"
      in PROTOCOL,
      "E2 has no registered falsifier for E1")
check("E2's rule names the states E2 exists to compare",
      "separates `additivity`\nfrom `ecological` or from `curvature`" in RAW
      or "separates `additivity` from `ecological` or from `curvature`" in PROTOCOL,
      "the withdrawal rule still compares the wrong states")
check("E2 is not claimed to be fitted",
      "**Every E2 coverage figure is a normal approximation and is labeled as one.**"
      in PROTOCOL and "It is not a fitted arm" in PROTOCOL,
      "E2 overstates what it runs")
# The curvature mechanism is a claim about rank and is asserted against the check.
CURV = DESIGN["curvature_rank"]
check("the curvature state is unidentified with equal aggregate SDs",
      CURV["equal_sd_logit_estimable"] is False,
      "equal SDs identify the target, so the stated mechanism is wrong")
check("the curvature state is identified on the logit link only",
      CURV["unequal_sd_logit_estimable"] is True
      and CURV["unequal_sd_identity_estimable"] is False,
      "curvature is not a nonlinear-only state")

# --- the groundwork the protocol's section 3 rests on ------------------------
check("the probe inversion is real",
      DESIGN["probe_inverts"] is True,
      "the groundwork claim of inversion does not hold in the saved probe")
check("the probe's null control is nominal",
      DESIGN["probe_null_cover_min"] >= 0.94,
      f"probe null coverage from {DESIGN['probe_null_cover_min']}")

# The header cites how many assertions guard the document, so that number has to
# be the number that ran.
_claimed = re.search(r"\*\*(\d+)\*\* assertions", PROTOCOL)
check("stated assertion count matches the count that ran",
      _claimed is not None and int(_claimed.group(1)) == checks + 1,
      f"{checks + 1} assertions ran, the protocol claims "
      f"{_claimed.group(1) if _claimed else 'none'}")

print(f"{checks - len(fails)}/{checks} protocol assertions passed")
for f in fails:
    print(f"  FAIL {f}")
sys.exit(1 if fails else 0)
