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
# correctly interpolated. That is the only class of numeric defect this design
# leaves open, so it is where the assertions go.

_p3 = D["p3_by_link"]
check("the document claims the direction differs by link only if it does",
      (_p3["logit"]["direction"] != _p3["cloglog"]["direction"])
      == ("direction differs by link" in PROTOCOL),
      f"logit {_p3['logit']['direction']}, cloglog {_p3['cloglog']['direction']}")
check("anti-conservative is claimed only where the ratio exceeds one",
      all((v["v_ratio_min"] > 1) == (v["direction"] == "anti-conservative")
          for v in _p3.values()),
      f"{[(k, v['direction'], v['v_ratio_min']) for k, v in _p3.items()]}")
check("conservative is claimed only where the ratio is below one",
      all((v["v_ratio_max"] < 1) == (v["direction"] == "conservative")
          for v in _p3.values()),
      f"{[(k, v['direction'], v['v_ratio_max']) for k, v in _p3.items()]}")

check("the identity-link convergence claim matches the measurement",
      D["p3_identity_ok"] is True
      and "A wrong implementation produces a gap that does not move" in PROTOCOL,
      "the document claims convergence the probe did not find")
_conv = D["p3_identity_convergence"]
check("the convergence is monotone, as the claim requires",
      all(_conv[i]["gap"] > _conv[i + 1]["gap"] for i in range(len(_conv) - 1)),
      f"{[round(c['gap'], 5) for c in _conv]}")

check("the headline is claimed to survive only if the probe says so",
      D["p3_headline_survives"] is True,
      "the document leads with a headline P3 refuted")

# The source-size claim: the document says pinning it made the primary arm
# undetectable. That is only true if the source size is now a factor AND the
# logit arm's maximum share clears the floor.
check("the source size is a factor, as the document says it became",
      len(D["levels"]["nS"]) > 1,
      f"nS levels: {D['levels']['nS']}")
check("the logit arm clears the floor, which is what made the fix necessary",
      D["omitted_share_by_link"]["logit"]["max"] >= D["min_omitted_share"],
      f"logit max {D['omitted_share_by_link']['logit']['max']} against floor "
      f"{D['min_omitted_share']}")

# The cost claim: a saving is claimed, so the two figures must differ in the
# direction claimed and the arithmetic must hold.
check("the claimed saving follows from the two measured costs",
      abs(D["budget_saving_pct"]
          - 100 * (1 - D["core_hours"] / D["core_hours_at_typed_200"])) < 0.1,
      f"{D['budget_saving_pct']}% against "
      f"{D['core_hours']} and {D['core_hours_at_typed_200']}")
check("the measured cost is reported at the registered resample count",
      D["core_hours_n_perturb"] == D["n_perturb"],
      f"measured at {D['core_hours_n_perturb']}, registered {D['n_perturb']}")
check("the registered resample count is the one the probe derived",
      D["n_perturb"] == D["n_perturb_needed"],
      f"registered {D['n_perturb']}, derived {D['n_perturb_needed']}")

# The grid claim.
check("the run grid is a subset of the realized grid",
      D["n_cells"] <= D["n_cells_realized"],
      f"{D['n_cells']} of {D['n_cells_realized']}")
check("the quadrature order is the largest any cell needed",
      D["quad_order"] == max(c["stable_order"] for c in D["p1_by_cell"]
                             if c["stable_order"] is not None),
      f"registered {D['quad_order']}")
check("the order is attributed to the cell that actually forced it",
      D["p1_forced_by"]["order"] == D["quad_order"],
      f"attributed to {D['p1_forced_by']}")

# --- the registration status must not have been quietly upgraded -------------
check("the document still says it is not registered",
      "NOT YET REGISTERED" in PROTOCOL,
      "a draft has been described as a registration")

print(f"{checks - len(fails)}/{checks} protocol assertions passed")
for f in fails:
    print(f"  FAIL {f}")
sys.exit(1 if fails else 0)
