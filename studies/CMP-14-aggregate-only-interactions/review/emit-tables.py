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

def emit(label: str, pattern: str, replacement: str) -> None:
    """Substitute one emitted sentence, and FAIL when the pattern matches nothing.

    ROUND 6 FOUND THIS SCRIPT SILENTLY DOING NOTHING. Its only substitution
    targeted a sentence the protocol rebuild had already deleted, so it matched
    zero times, wrote nothing, printed "already current", and the provenance
    claim named it as one of three links in a chain. A no-op that reports success
    is worse than a missing step, because the document says the step ran."""
    global changed
    text = PROT.read_text()
    # A LAMBDA, not a string: the replacements contain LaTeX, and re treats
    # a backslash in a replacement string as a group reference, so \\Gamma
    # raises 'bad escape' rather than inserting the text asked for.
    out, n = re.subn(pattern, lambda _m: replacement, text)
    if n == 0:
        raise SystemExit(
            f"emit-tables: the {label!r} pattern matched nothing in protocol.md. "
            "Either the sentence was renamed and this pattern must follow it, or "
            "the number is no longer emitted and this block must be removed. "
            "Silently emitting nothing is what this check exists to prevent.")
    if n > 1:
        raise SystemExit(f"emit-tables: {label!r} matched {n} times; ambiguous")
    if out != text:
        PROT.write_text(out)
        changed.append(label)


# --- the nuisance-prior inertness figures ------------------------------------
ns = DESIGN["nuisance_sensitivity"]
emit("nuisance-prior inertness",
     r"the worst moves are \*\*[^*]+\*\*",
     f"the worst moves are **{ns['coverage']:.4f} in\ncoverage, "
     f"{ns['contraction']:.4f} in contraction and {ns['surv_between']:.0f} in "
     f"`surv_between`**")

# --- the true values, which ADEMP requires and round 6 found unregistered ----
tv = DESIGN["true_values"]
emit("true values",
     r"\| \$\\Gamma_W\$ for the target, component 3 \| \*\*[\d.]+\*\* \|",
     f"| $\\Gamma_W$ for the target, component 3 | **{tv['gamma_w']}** |")
emit("E2 study intercept",
     r"\\operatorname\{logit\}\(0\.3\) = -?[\d.]+",
     f"\\operatorname{{logit}}(0.3) = {tv['e2_study_intercept']}")

print("rewritten:" if changed else "already current")
for c in changed:
    print(" ", c)
