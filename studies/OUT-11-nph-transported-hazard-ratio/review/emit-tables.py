#!/usr/bin/env python3
"""Rewrite the document tables in place from results/registered-design.json.

Round 6 found the placebo arm built with a nonzero gamma in every analytic
calculation, so E1, E2 and the per-leg proportional-hazards powers all had to be
recomputed. That invalidated forty printed numbers across three documents at
once. Retyping forty numbers is precisely the operation that has produced three
of this study's fatal findings, so it is not done by hand.

Each table is rebuilt entirely from the export, including its label columns, so
a row cannot survive with a stale label attached to a fresh value. Run the
verifier afterwards: it parses the same tables independently and will still fail
if this script and the export disagree.

    Rscript R/09-export-design.R
    python3 review/emit-tables.py
    python3 review/verify-protocol.py
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESIGN = json.loads((ROOT / "results" / "registered-design.json").read_text())


def sci(x: float, digits: int = 2) -> str:
    """Match the documents' LaTeX style for very small numbers."""
    if x == 0:
        return "0"
    if abs(x) >= 1e-4:
        return f"{x:.4g}"
    m = f"{x:.{digits - 1}e}"
    mant, exp = m.split("e")
    return f"${mant}\\times10^{{{int(exp)}}}$"


def replace_body(path: Path, needle: str, rows: list[str]) -> bool:
    """Swap the body of the first table whose header contains `needle`."""
    lines = path.read_text().splitlines()
    for i, ln in enumerate(lines):
        if needle in ln and ln.lstrip().startswith("|"):
            j = i + 2
            k = j
            while k < len(lines) and lines[k].lstrip().startswith("|"):
                k += 1
            if lines[j:k] == rows:
                return False
            lines[j:k] = rows
            path.write_text("\n".join(lines) + "\n")
            return True
    raise SystemExit(f"no table containing {needle!r} in {path.name}")


changed = []

# --- E2, both tables ---------------------------------------------------------
e2 = ROOT / "results" / "e2-results.md"
if replace_body(e2, "worst coverage", [
        f"| {c['kappa_a']:.2f} | {c['kappa_b']:.2f} | {c['worst_abs_bias']:.4f} "
        f"| {c['worst_cover']:.3f} | {c['best_cover']:.3f} |"
        for c in DESIGN["e2_cells"]]):
    changed.append("e2-results.md bias/coverage")

# The detection table orders its cells by kappa_A then kappa_B, which is not the
# export's order; it is rebuilt in the document's own order.
disc = {(c["kappa_a"], c["kappa_b"]): c for c in DESIGN["e2_discriminate_cells"]}
order = sorted(disc, key=lambda k: (k[0], k[1]))
if replace_body(e2, "single-estimate SDs", [
        f"| {ka:.2f} | {kb:.2f} | {disc[(ka, kb)]['worst_shift_per_sd']:.3f} "
        f"| {disc[(ka, kb)]['max_detect']:.3f} |" for ka, kb in order]):
    changed.append("e2-results.md detection")

# --- E1, both tables ---------------------------------------------------------
e1 = ROOT / "results" / "e1-results.md"
LABEL = {"primary": "primary", "margin": "margin", "control": "control",
         "ipd-nph": "**ipd-nph**", "family": "family"}


def kap(row, key):
    v = row[key]
    return f"**{v:.2f}**" if row["arm"] == "ipd-nph" and v > 0 else f"{v:.2f}"


if replace_body(e1, "matched diagonal", [
        f"| {LABEL[r['arm']] if r['arm'] != 'family' else 'family (Gompertz)'} "
        f"| {kap(r, 'kappa_a')} | {kap(r, 'kappa_b')} | {sci(r['spread_pct'])} "
        f"| {sci(r['diag_pct'])} | {sci(r['leg_a'])} | {sci(r['leg_b'])} |"
        for r in DESIGN["e1_least_false"]]):
    changed.append("e1-results.md least-false")

if replace_body(e1, "matched-only range", [
        f"| {LABEL[r['arm']]} | {kap(r, 'kappa_a')} | {kap(r, 'kappa_b')} "
        f"| {r['truth']:.2f} | {r['lo']:.3f} | {r['hi']:.3f} "
        f"| {sci(r['range'])} | {sci(r['range_diag'])} |"
        for r in DESIGN["e1_d3"]]):
    changed.append("e1-results.md D3")

# --- the protocol's cell-properties table ------------------------------------
prot = ROOT / "protocol.md"
FAM = {"weibull": "Weibull", "gompertz": "Gompertz"}


def cp_row(c):
    fam = FAM[c["family"]]
    if c["arm"] in ("margin", "control", "ipd-nph"):
        fam = f"{fam} ({c['arm']})"
    cross = ("none | none" if c.get("cond_cross") is None
             else f"{c['cond_cross']:g} | {c['marg_cross']:g}")
    rng = f"{c['hr_min']:.3f} to {c['hr_max']:.3f}"
    if c["arm"] == "control":
        rng = f"**{rng}**"
    def bold(v):
        return f"**{v:.3f}**" if v >= 0.25 else f"{v:.3f}"
    return (f"| {fam} | {c['kappa_a']:.2f} | {c['kappa_b']:.2f} | {cross} "
            f"| {rng} | {c['at_risk_a']:.3f} / {c['at_risk_b']:.3f} "
            f"| {bold(c['ph_reject_leg_a'])} | {bold(c['ph_reject_leg_b'])} |")


if replace_body(prot, "PH rejects, leg A",
                [cp_row(c) for c in DESIGN["cell_properties"]]):
    changed.append("protocol.md cell properties")

# --- the arm-differential quadrature table -----------------------------------
# This one moves every time the probe finishes a replicate, which is exactly the
# situation hand-editing gets wrong.
i5 = DESIGN.get("integration_512")
if i5:
    LAB = {"flex": "ML-NMR flexible", "ph": "ML-NMR proportional",
           "differential": "**difference, paired**"}
    if replace_body(prot, r"\hat\Delta_{512}", [
            f"| {LAB[k]} | {v['n']} | ${v['mean']:+.4f}$ | {v['se']:.4f} "
            f"| ${v['t']:+.2f}$ |"
            for k, v in i5.items() if k in LAB]):
        changed.append("protocol.md arm-differential")

# --- the sensitivity program's two tables ------------------------------------
# Round 6 found the arms registered with no cells named and priced at roughly
# half their minimum cost. Both tables are now generated from the same objects
# R/07-run.R iterates and R/10-budget.R multiplies, so neither the subset nor the
# per-setting cost can be typed independently of what actually runs.
sc = DESIGN["sens_cells"]
if replace_body(prot, "why this one", [
        f"| {c['arm']}, {c['cens']} | {c['kappa_a']:.0f} "
        f"| {'**0.30**' if c['kappa_b'] > 0 else '0'} | "
        + ("the most non-proportional target contrast in the design, where "
           "spline flexibility, integration order and the auxiliary priors all "
           "have the most to do" if c["kappa_b"] > 0 else
           "the proportional target contrast at the same margin: the null case "
           "for all three arms, which separates \"the setting matters\" from "
           "\"the setting matters for non-proportionality\"") + " |"
        for c in sc]):
    changed.append("protocol.md sensitivity subset")

ss = DESIGN["budget"]["sens_table"]
rows = [f"| {s['arm']} | `{s['setting']}` | {s['n_int']} | {s['prior_mult']:g} "
        f"| {s['n_knots']} | {'**yes**' if s['freq'] else 'no'} "
        f"| {s['hours']:.1f} h |" for s in ss]
rows.append(
    f"| **total** | | | | | | **{sum(s['hours'] for s in ss):.1f} h** |")
if replace_body(prot, "reruns bootstrap", rows):
    changed.append("protocol.md sensitivity settings")

# --- D3 at the alternative thresholds ----------------------------------------
# Version 5 asserted this table's content from a range argument that does not
# support a flip count. It is computed now, so it is emitted now.
if replace_body(prot, "worst flip fraction |", [
        f"| 0.40 | {DESIGN['e1_d3_flip_cells_040']} of {DESIGN['e1_d3_n_cells']} "
        f"| {DESIGN['e1_d3_worst_flip_040']:.4f} |",
        f"| **{DESIGN['threshold']:.2f}**, registered "
        f"| **{DESIGN['e1_d3_flip_cells']} of {DESIGN['e1_d3_n_cells']}** "
        f"| **{DESIGN['e1_d3_worst_flip']:.4f}** |",
        f"| 0.60 | {DESIGN['e1_d3_flip_cells_060']} of {DESIGN['e1_d3_n_cells']} "
        f"| {DESIGN['e1_d3_worst_flip_060']:.4f} |"]):
    changed.append("protocol.md D3 thresholds")

# --- the grand total, which was typed and therefore drifted ------------------
# It has an empty header row, so it is located by its one unique label rather
# than by a header needle.
# The body is delimited by walking OUT from the anchor row to the table's own
# edges. A hand-counted offset from the anchor is what this script exists to
# avoid, and a first attempt at one duplicated a row three times and swallowed
# the paragraph below the table.
B = DESIGN["budget"]
lines = prot.read_text().splitlines()
anchor = next((i for i, ln in enumerate(lines)
               if ln.startswith("| refit escalation, at the")), None)
if anchor is None:
    raise SystemExit("no grand-total table in protocol.md")
lo = anchor
while lo > 0 and lines[lo - 1].lstrip().startswith("|") \
        and not re.fullmatch(r"\|[-|: ]+\|", lines[lo - 1]):
    lo -= 1
hi = anchor + 1
while hi < len(lines) and lines[hi].lstrip().startswith("|"):
    hi += 1
rows = [f"| main run | {B['main_total_h']:.1f} h |",
        f"| sensitivity arms | {B['arms_total_h']:.1f} h |",
        f"| refit escalation, at the 20% budget assumption "
        f"| {B['refit_cap_h']:.1f} h |",
        f"| **total** | **{B['grand_total_h']:.1f} h** |"]
if lines[lo:hi] != rows:
    lines[lo:hi] = rows
    prot.write_text("\n".join(lines) + "\n")
    changed.append("protocol.md grand total")

print("rewritten:" if changed else "already current")
for c in changed:
    print(" ", c)
