#!/usr/bin/env python3
"""Assert the protocol against what the code produces.

REBUILT WITH THE PROTOCOL. The previous version had accumulated assertions about
wording that five rounds of edits had superseded, so it was checking a document
that no longer existed while passing on one that did. That is the same
layered-edit defect the protocol itself had, in the file whose job is to catch it.

Two guards that came out of round 5 and are kept:

  * This script REFUSES TO RUN when the export is older than the code. Without
    that, R/05-export.R stopping on an error leaves the previous export in place
    and every assertion below is checked against it. That happened: a clean
    125/125 printed against an export the exporter had just declined to refresh.

  * Numbers the document prints are compared against the export cell by cell, not
    spot-checked. Rounds 2, 4 and 5 each found a printed number that no longer
    followed from the code, and each time the repair was retyping it.

    Rscript R/05-export.R
    python3 review/emit-tables.py
    python3 review/verify-protocol.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = (ROOT / "protocol.md").read_text()
PROTOCOL = re.sub(r"\s+", " ", RAW)
# Normalized like PROTOCOL: the history is hard-wrapped too, so a phrase that
# reads as one sentence is split by a newline in the file.
CHANGES = re.sub(r"\s+", " ", (ROOT / "CHANGES.md").read_text())
DESIGN_PATH = ROOT / "results" / "registered-design.json"
DESIGN = json.loads(DESIGN_PATH.read_text())

# The exporter is excluded for the same reason R/05-export.R excludes itself: it
# consumes artifacts rather than producing them.
_newest_code = max(f.stat().st_mtime for f in (ROOT / "R").iterdir()
                   if f.is_file() and f.name != "05-export.R")
if DESIGN_PATH.stat().st_mtime < _newest_code:
    raise SystemExit(
        "registered-design.json predates the code in R/, so every assertion below "
        "would be checked against a stale export. Run Rscript R/05-export.R first.")

fails: list[str] = []
checks = 0


def check(label: str, ok: bool, detail: str = "") -> None:
    global checks
    checks += 1
    if not ok:
        fails.append(f"{label}{': ' + detail if detail else ''}")


def has(label: str, *needles: str) -> None:
    for n in needles:
        check(label, n in PROTOCOL, f"missing {n!r}")


def table_after(header: str) -> list[str]:
    lines = RAW.splitlines()
    for i, ln in enumerate(lines):
        if ln.strip() == header.strip():
            body = []
            for ln2 in lines[i + 2:]:
                if not ln2.lstrip().startswith("|"):
                    break
                body.append(ln2)
            return body
    return []


# --- the export must carry everything any block below reads ------------------
REQUIRED = [
    "n_scenarios", "n_failed", "overlap", "pairs_close",
    "pairs_close_max_cover_gap", "e2_rules", "e2_withdraw_e1", "curvature_rank",
    "control_tight_bias", "control_tight_recovery", "control_null_over_range",
    "control_null_worst_shrinkage", "control_absent_cover_by_prior",
    "nuisance_sensitivity", "states", "e2_states", "spreads", "discord",
    "total_n", "prior_sd", "synergy", "cover_bad", "nominal", "cover_tol",
    "contract_ok", "eff_ratio_ok", "source_ok", "gamma_w", "k_comp",
    "prior_sd_nuisance", "e2_base_p",
]
for k in REQUIRED:
    check(f"the export carries {k}", k in DESIGN,
          "its assertions would otherwise be skipped silently")

# --- section 1: nothing is confirmatory, and it is said first ----------------
check("registration status comes before anything else",
      RAW.index("## 1. Registration status") < RAW.index("## 2. The model"),
      "the status section is not first")
has("nothing is confirmatory",
    "Nothing in this study is confirmatory",
    "**E1 is exact and exploratory.**",
    "**Every part of E2 is exploratory.**",
    "The candidate statistic is post hoc in all three of its forms")

# --- the grid, factor by factor ----------------------------------------------
check("the scenario count is the grid's own",
      f"**{DESIGN['n_scenarios']} scenarios**" in PROTOCOL,
      f"missing {DESIGN['n_scenarios']}")
GRID = table_after("| factor | levels |")
check("the grid table is present", len(GRID) >= 6, f"{len(GRID)} rows")
for label, want in [("covariate spread", DESIGN["spreads"]),
                    ("total patients", DESIGN["total_n"]),
                    ("prior SD on interactions", DESIGN["prior_sd"])]:
    row = next((r for r in GRID if label in r), None)
    check(f"the grid states {label}", row is not None, "row not found")
    if row is not None:
        got = [float(x) for x in re.findall(r"\d+\.?\d*", row.split("|")[2])]
        check(f"the levels of {label} match the code", got == [float(x) for x in want],
              f"document {got}, code {list(want)}")

has("the registered thresholds",
    f"`CONTRACT_OK = {DESIGN['contract_ok']:.2f}`",
    f"`EFF_RATIO_OK = {DESIGN['eff_ratio_ok']:.2f}`",
    f"`SOURCE_OK = {DESIGN['source_ok']:.2f}`",
    f"`COVER_BAD = {DESIGN['cover_bad']:.2f}`",
    f"`COVER_TOL = {DESIGN['cover_tol']:.2f}`",
    f"`PRIOR_SD_NUISANCE = {DESIGN['prior_sd_nuisance']:.0f}`")

# --- the route table, asserted against the run -------------------------------
RT = table_after("| between-study difference | identity link | logit link |")
check("the route table has four rows", len(RT) == 4, f"{len(RT)} rows")
_want = [("none", False, False), ("means", True, True),
         ("SDs", False, True), ("risks", False, True)]
for i, (lab, ident, logit) in enumerate(_want):
    if i >= len(RT):
        break
    row = RT[i]
    check(f"route row {lab} names itself", lab in row, f"{row!r}")
    check(f"route row {lab} states the identity link",
          ("not estimable" in row.split("|")[2]) != ident, f"{row!r}")
    check(f"route row {lab} states the logit link",
          ("not estimable" in row.split("|")[3]) != logit, f"{row!r}")
check("the curvature restriction is registered, not assumed",
      "requires equal target-study baselines, and that restriction is" in PROTOCOL,
      "the restriction is not stated as registered")
CR = DESIGN["curvature_rank"]
check("the equal-SD claim holds under its restriction",
      CR["equal_sd_logit_estimable"] is False,
      "equal SDs identify the target even with equal baselines")
check("and fails without it",
      CR.get("unequal_baseline_equal_sd_estimable") is True,
      "unequal baselines do not identify the target, so the finding is wrong")

# --- primary outcomes, against the run ---------------------------------------
_ov = {o["statistic"]: o for o in DESIGN["overlap"]}
check("every diagnostic is analyzed in primary 1", len(_ov) == 5,
      f"{sorted(_ov)}")
check("every diagnostic overlaps", all(o["overlaps"] for o in _ov.values()),
      f"{[(k, v['overlaps']) for k, v in _ov.items()]}")
check("primary 1 is an existence claim",
      "no threshold separates them" in PROTOCOL
      and "no weighting can move" in PROTOCOL,
      "primary 1 does not disclaim grid weighting")
check("primary 3's sign is explained the way it must be read",
      "a POSITIVE correlation means the diagnostic becomes more reassuring as the "
      "answer gets worse" in PROTOCOL,
      "the inverted sign is not explained")
check("the secondary table is labeled grid-weighted",
      "grid-weighted" in PROTOCOL, "the threshold table is not disclaimed")

# --- E2 -----------------------------------------------------------------------
check("E2 is not claimed to be fitted",
      "Asymptotic, **not fitted**" in PROTOCOL
      and "no sampler policy exists" in PROTOCOL,
      "E2 overstates what it runs")
check("E2 coverage is scoped to correct specification",
      "only where the model is correctly specified" in PROTOCOL,
      "misspecified coverage is not scoped out")
check("E2's contraction is described as Laplace",
      "contraction of a Laplace approximation" in PROTOCOL,
      "the approximation is not stated")
check("no E2 separation rule fires",
      all(r["separates"] is False for r in DESIGN["e2_rules"])
      and DESIGN["e2_withdraw_e1"] is False,
      f"{DESIGN['e2_rules']}")

# --- the candidate statistic --------------------------------------------------
check("the candidate is not called a share",
      "not a share and asking for one is ill-posed" in PROTOCOL,
      "the statistic is still presented as a share")
check("the candidate's threshold is not called conventional",
      "**`SOURCE_OK` cannot be**" in PROTOCOL,
      "a novel threshold is presented as convention")
check("every precision is prior-free",
      "Every precision here is prior-free" in PROTOCOL,
      "the prior contamination fix is not stated")

# --- the estimand -------------------------------------------------------------
check("the estimand is not presented as a model parameter",
      "not a separate model parameter" in PROTOCOL
      and "carries **one** $\\Gamma$ per" in PROTOCOL,
      "the estimand still implies the model splits within from between")

# --- the history is complete and elsewhere ------------------------------------
check("the change history is a separate document",
      "Change history is in [`CHANGES.md`](CHANGES.md), not here" in PROTOCOL,
      "the history is not separated")
for needle in ("Rounds 1 to 4 used one reviewer",
               "**Round 5 was the first independent review**",
               "Seven topics were raised independently by both reviewers",
               "A reviewer that fails is not a reviewer that agrees",
               "Three numbers that went stale"):
    check(f"the history records: {needle}", needle in CHANGES, "missing")
check("the history keeps the full disclosure list",
      "Every design choice changed after seeing a number" in CHANGES,
      "the disclosure list was lost in the split")

# --- the header's assertion count must be the count that ran ------------------
_claimed = re.search(r"\*\*(\d+)\*\* assertions", PROTOCOL)
check("stated assertion count matches the count that ran",
      _claimed is not None and int(_claimed.group(1)) == checks + 1,
      f"{checks + 1} ran, protocol claims "
      f"{_claimed.group(1) if _claimed else 'none'}")

print(f"{checks - len(fails)}/{checks} protocol assertions passed")
for f in fails:
    print(f"  FAIL {f}")
sys.exit(1 if fails else 0)
