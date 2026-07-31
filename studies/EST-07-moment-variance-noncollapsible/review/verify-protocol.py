#!/usr/bin/env python3
"""Assert the protocol against the code that produced it.

THIS VERIFIER HAS A DIFFERENT JOB FROM CMP-14'S, because the failure it exists to
catch is different. There, numbers were typed and the verifier compared each one
against the export; a third of thirteen rounds of findings were numbers that had
drifted. Here `review/emit-protocol.py` interpolates every number at generation
time, so drift of that kind is impossible.

What remains possible is worse and quieter:

  1. The document is STALE, generated from an earlier export. Regenerating and
     comparing catches it; nothing else does.
  2. A number is generated correctly and the SENTENCE AROUND IT says something
     else. No amount of interpolation helps, so the claims that carry meaning are
     asserted against the export directly.
  3. A file the document NAMES does not exist or does not do what is claimed.
     CMP-14 round 9 found a guard cited for a check that was never written, and
     an early draft here repeated it.
  4. The export itself is stale with respect to the code.

    Rscript R/12-export.R
    python3 review/emit-protocol.py
    python3 review/verify-protocol.py
"""
import importlib.util
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = (ROOT / "protocol.md").read_text()
PROTOCOL = re.sub(r"\s+", " ", RAW)
DESIGN_PATH = ROOT / "results" / "registered-design.json"
D = json.loads(DESIGN_PATH.read_text())

fails: list[str] = []
checks = 0


def check(label: str, ok: bool, detail: str = "") -> None:
    global checks
    checks += 1
    if not ok:
        fails.append(f"{label}{': ' + detail if detail else ''}")


# --- 4. the export must not predate the code ---------------------------------
# The exporter excludes itself for the reason CMP-14 settled on: it consumes
# artifacts rather than producing them. The generator is excluded too, since it
# reads the export and writes the document.
_excluded = {"12-export.R"}
_newest = max(f.stat().st_mtime for f in (ROOT / "R").iterdir()
              if f.is_file() and f.name not in _excluded)
if DESIGN_PATH.stat().st_mtime < _newest:
    raise SystemExit(
        "registered-design.json predates the code in R/, so every assertion "
        "below would be checked against a stale export. Run Rscript "
        "R/12-export.R first.")

# --- 3. the files the document names must exist ------------------------------
# DESIGN.md is no longer the authority, but the protocol still names it, so it
# must exist and must say so itself. A superseded file that does not announce it
# is worse than one that is simply absent.
_design = (ROOT / "DESIGN.md").read_text() if (ROOT / "DESIGN.md").exists() else ""
check("DESIGN.md announces that it is superseded",
      "SUPERSEDED IN PART" in _design,
      "the protocol demotes it but the file does not say so")
check("the protocol claims to be the design of record",
      "design of record" in PROTOCOL,
      "neither document claims authority")

for named in ("review/emit-protocol.py", "results/registered-design.json",
              "DESIGN.md"):
    check(f"the document's reference to {named} resolves",
          (ROOT / named).exists() and f"`{named}`" in PROTOCOL
          or (ROOT / named).exists() and named in PROTOCOL,
          "named in the protocol but absent from disk")

# --- 1. THE DOCUMENT MUST BE WHAT THE GENERATOR CURRENTLY PRODUCES -----------
# This is the assertion that replaces CMP-14's hundred number-by-number checks.
# If it passes, every figure in the document came from the current export by
# construction, and no per-number comparison can add anything.
_spec = importlib.util.spec_from_file_location(
    "emit_protocol", ROOT / "review" / "emit-protocol.py")
_emit = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_emit)
check("the protocol is exactly what the generator produces from this export",
      _emit.build() == RAW,
      "regenerate with python3 review/emit-protocol.py; the document is stale")

# --- 2. the claims that carry meaning, asserted against the export -----------
# Each of these is a SENTENCE that could be false while every number in it is
# correctly interpolated. Round 2 of critique showed that is the dominant failure
# mode here: the generator was not updated with the code, so fluent prose kept
# describing a study that no longer existed. These assertions target the claims
# whose truth changed.

# THE WITHDRAWN PREDICTION must stay withdrawn, and the document must not
# reintroduce a direction claim from P3.
check("the second prediction is disclosed as withdrawn",
      "has been withdrawn" in PROTOCOL,
      "the withdrawal is not stated")
check("no interval-direction claim is made from P3",
      "artifact of comparing gradients" in PROTOCOL
      and "anti-conservative" not in PROTOCOL,
      "a direction claim has come back")

# P6 FAILED ITS FLOOR. The document must say so, and must not say the opposite.
check("the cross-covariance probe's verdict matches the export",
      D["p6_ok"] is False
      and "the cross term is above the threshold and cannot be ignored"
          in PROTOCOL,
      f"p6_ok={D['p6_ok']}")
# THE WORD "CLEAR" MUST NOT BE USED FOR THIS PROBE. It means "large enough to be
# worth running" at the cell gate and would mean the opposite here, which three
# reviewers independently read as a contradiction.
_p6_section = PROTOCOL.split("### P6")[1].split("### P7")[0] if "### P6" in PROTOCOL else ""
# The one permitted use is the sentence that explains the two meanings.
_p6_rest = _p6_section.split("A WORD USED TWO WAYS")[0] + \
           _p6_section.split("stated without that word.")[-1]
check("P6 does not reuse the gate's word for the opposite comparison",
      "clear" not in _p6_rest,
      "the ambiguous phrasing has come back")
check("the worst cross-covariance share really is above the floor",
      D["p6_worst_share"] > D["min_omitted_share"],
      f"{D['p6_worst_share']} against {D['min_omitted_share']}")
check("the arm that carries the cross term is named",
      "maic_xcov" in PROTOCOL, "P6 fails but no arm carries it")

# P7: the null control holds only on the collapsible link, and the document must
# report exactly that pattern.
if "p7_by_link" in D:
    _p7 = {r["link"]: r for r in D["p7_by_link"]}
    check("the null control vanishes on the identity link and no other",
          _p7["identity"]["vanishes"] is True
          and all(v["vanishes"] is False
                  for k, v in _p7.items() if k != "identity"),
          f"{[(k, v['vanishes']) for k, v in _p7.items()]}")
    check("the document says the old every-scale control was false",
          "That is false on both curved links" in PROTOCOL,
          "the withdrawn control is not disclosed")

# THE RESAMPLE COUNT must be the one the probe derived, and the document must
# describe the measurement that derived it rather than an earlier one.
check("the registered resample count is the one the probe derived",
      D["n_perturb"] == D["n_perturb_needed"],
      f"registered {D['n_perturb']}, derived {D['n_perturb_needed']}")
check("the measured cost is reported at the registered resample count",
      D["core_hours_n_perturb"] == D["n_perturb"],
      f"measured at {D['core_hours_n_perturb']}, registered {D['n_perturb']}")
check("the perturbation sizing is described by coverage and width, not variance",
      "biased **inward**" in PROTOCOL and "variance of the draws" in PROTOCOL,
      "the obsolete criterion is still described as current")

# THE COST WENT UP. A document that calls that a saving is telling the reader the
# opposite of what happened.
check("the cost change is reported in the direction it actually moved",
      D["budget_change_pct"] > 0 and "cost rose by" in PROTOCOL
      and "saving" not in PROTOCOL.split("An earlier draft")[0],
      f"change {D.get('budget_change_pct')}%")

# THE FLOOR must be the solved one, and the gate must screen on the whole
# variance rather than a part of it.
check("the floor is the one solved from the registered coverage shift",
      abs(D["min_omitted_share"] - 0.0791) < 0.001
      and "solved from the criterion" in PROTOCOL,
      f"floor {D['min_omitted_share']}")
check("the gate's denominator includes the target-trial and cross terms",
      "gate_terms" in D and "whole variance of the anchored contrast" in PROTOCOL,
      "the gate still screens on a partial denominator")

# THE QUADRATURE ORDER must be the largest any cell needed, and the document must
# not claim the product rule is paid at four covariates.
check("the quadrature order is the largest any cell needed",
      D["quad_order"] == max(c["stable_order"] for c in D["p1_by_cell"]
                             if c["stable_order"] is not None),
      f"registered {D['quad_order']}")
check("the order is attributed to the cell that actually forced it",
      D["p1_forced_by"]["order"] == D["quad_order"],
      f"attributed to {D['p1_forced_by']}")
check("the four-covariate node count is named as avoided, not paid",
      "not a count this study pays" in PROTOCOL,
      "the document implies it pays the four-dimensional product rule")

# BOTH ESTIMANDS must be declared and both must actually be computed.
check("both estimands are declared",
      set(D["estimands"]) == {"superpopulation", "finite_target"},
      f"{D['estimands']}")
_run = (ROOT / "R" / "15-run.R").read_text()
check("the finite-target estimand has a caller in the runner",
      "truth_anchored_finite" in _run and "covered_finite" in _run,
      "the document promises an estimand the runner does not compute")

# THE SOFTWARE CLAIM must match what is on disk.
for _f in ("R/15-run.R", "R/16-analyze.R"):
    check(f"the runner/analysis the document claims exists: {_f}",
          (ROOT / _f).exists(), "named but absent")
check("the missing ML-NMR arm is disclosed",
      "No ML-NMR arm" in PROTOCOL, "a scope limit has gone unstated")

# The grid claim.
check("the run grid is a subset of the realized grid",
      D["n_cells"] <= D["n_cells_realized"],
      f"{D['n_cells']} of {D['n_cells_realized']}")

# --- the registration status must not have been quietly upgraded -------------
check("the document still says it is not registered",
      "NOT YET REGISTERED" in PROTOCOL,
      "a draft has been described as a registration")

print(f"{checks - len(fails)}/{checks} protocol assertions passed")
for f in fails:
    print(f"  FAIL {f}")
sys.exit(1 if fails else 0)
