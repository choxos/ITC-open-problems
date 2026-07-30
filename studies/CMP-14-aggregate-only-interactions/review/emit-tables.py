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

# The rebuilt protocol prints no control-justification table: those numbers were
# the ones that kept going stale, and the rebuild removed them from the document
# rather than regenerating them into it. What remains emitted is the one prose
# number the document still carries.
# --- the nuisance-prior sensitivity ------------------------------------------
ns = DESIGN["nuisance_sensitivity"]
p = PROT.read_text()
new = (f"largest movement in any\nregistered quantity across the whole grid is "
       f"**{ns['coverage']:.4f} in coverage, {ns['contraction']:.4f} in "
       f"contraction and\n{ns['surv_between']:.4f} in the source survival "
       f"fraction**")
p2 = re.sub(
    r"largest movement in any\nregistered quantity across the whole grid is\s+"
    r"\*\*[^*]+\*\*", new, p)
if p2 != p:
    PROT.write_text(p2)
    changed.append("nuisance-prior sensitivity")

print("rewritten:" if changed else "already current")
for c in changed:
    print(" ", c)
