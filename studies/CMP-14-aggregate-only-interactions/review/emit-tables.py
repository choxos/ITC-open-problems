#!/usr/bin/env python3
"""Generate the protocol's numeric tables from results/registered-design.json.

WHY THIS EXISTS. Round 2 found two of the control-justification numbers stale from
before the patient budget was equalized. Round 4 changed every one of them again
by matching the arm counts across states. Both times the verifier caught it, which
is the system working, and both times the repair was to retype numbers, which is
the operation that produced the staleness.

Prose numbers have to be typed. So they stop being prose: the quantities that keep
going stale are emitted as tables from the same export the verifier reads, and
`review/verify-protocol.py` then asserts the document against that export
independently. If this script and the verifier disagree, the verifier fails.

    Rscript R/05-export.R
    python3 review/emit-tables.py
    python3 review/verify-protocol.py
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESIGN = json.loads((ROOT / "results" / "registered-design.json").read_text())
PROT = ROOT / "protocol.md"


def replace_body(path: Path, header: str, rows: list[str]) -> bool:
    """Swap the body of the table whose HEADER row matches, leaving the header
    and the separator alone. Located by the header rather than by an offset from
    some anchor, because a hand-counted offset corrupted a table in the sibling
    study."""
    lines = path.read_text().splitlines()
    for i, ln in enumerate(lines):
        if ln.strip() == header.strip():
            j = i + 2                      # skip the |---| separator
            k = j
            while k < len(lines) and lines[k].lstrip().startswith("|"):
                k += 1
            if lines[j:k] == rows:
                return False
            lines[j:k] = rows
            path.write_text("\n".join(lines) + "\n")
            return True
    raise SystemExit(f"no table with header {header!r} in {path.name}")


changed: list[str] = []

# --- the control justifications ----------------------------------------------
tr = DESIGN["control_tight_recovery"]
tb = DESIGN["control_tight_bias"]
ov = DESIGN["control_null_over_range"]
sh = DESIGN["control_null_worst_shrinkage"]
by_prior = DESIGN["control_absent_cover_by_prior"]

rows = [
    f"| absent-state contraction, minimum "
    f"| {DESIGN['control_absent_min_contraction']:.4f} |",
    f"| null control, minimum coverage "
    f"| {DESIGN['control_null_min_coverage']:.4f} |",
    f"| null control, scenarios overcovering | {DESIGN['control_null_n_over']} |",
    f"| null control, overcoverage range | {ov[0]:.3f} to {ov[1]:.3f} |",
    f"| the shrinkage causing it: posterior SD against sampling SD "
    f"| {sh[0]:.3f} against {sh[1]:.3f} |",
]
rows += [f"| tight prior, coverage recovered at the largest budget, `{k}` "
         f"| {v:.3f} |" for k, v in sorted(tr.items())]
rows += [f"| tight prior, mean bias, `{k}` | {v:+.3f} |"
         for k, v in sorted(tb.items())]
rows.append("| absent state, coverage by prior SD | "
            + ", ".join(f"{k}: {v:.2f}" for k, v in sorted(by_prior.items()))
            + " |")
if replace_body(PROT, "| control quantity | value |", rows):
    changed.append("control justifications")

# --- the nuisance-prior sensitivity ------------------------------------------
ns = DESIGN["nuisance_sensitivity"]
p = PROT.read_text()
new = (f"largest movement in any\nregistered quantity across the whole grid is "
       f"**{ns['coverage']:.4f} in coverage, {ns['contraction']:.4f} in "
       f"contraction and\n{ns['share_within']:.4f} in the source survival "
       f"fraction**")
p2 = re.sub(
    r"largest movement in any\nregistered quantity across the whole grid is\s+"
    r"\*\*[^*]+\*\*", new, p)
if p2 != p:
    PROT.write_text(p2)
    changed.append("nuisance-prior sensitivity")

# --- the bias-spread sentence, third prose number to go stale ----------------
# Grok found "a spread of 0.165" not reproducing from the printed biases; it was
# left over from before the arm counts were matched. Rounds 2, 4 and 5 have each
# found a stale prose number, so this one stops being prose too.
_inf = {k: v for k, v in tb.items() if k != "absent"}
_spread = max(_inf.values()) - min(_inf.values())
p_txt = PROT.read_text()
_new = (f"the\n   magnitudes differ by {_spread:.3f} across the states that have "
        f"information, against a truth of\n   {DESIGN['gamma_w']:.2f}")
p2 = re.sub(r"the\n   magnitudes differ by [^,]+, against a truth of\n   [0-9.]+",
            _new, p_txt)
if p2 == p_txt:
    p2 = re.sub(r"the\n   magnitudes differ by more than a third of the truth",
                _new, p_txt)
if p2 != p_txt:
    PROT.write_text(p2)
    changed.append("bias-spread sentence")

print("rewritten:" if changed else "already current")
for c in changed:
    print(" ", c)
