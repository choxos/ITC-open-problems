#!/usr/bin/env python3
"""Check the protocol's numeric claims against what the code actually registers.

This program has published an artifact carrying an unsupported number six times,
and every durable fix has worked the same way: remove a place where a
human-typed number can enter, rather than add another human-performed check.

The sixth was the worst and is why this file was rewritten. Version 4's section
10.3 printed a pilot table whose two STC columns held the values produced BEFORE
the Gauss-Hermite weighting defect was fixed: twelve numbers from deleted code,
every STC-flex entry with the wrong sign, and one of them ($-0.028$ against a
true $-0.176$) carrying an entire claimed finding that does not exist. The old
version of this script did not catch it because it asserted only the scalars and
solved beta_B values that an uncommitted one-liner happened to export.

The rule now: if the protocol prints a number, R/09-export-design.R exports it
and this script asserts it. Whole TABLES are parsed and compared cell by cell,
not spot-checked, because a spot check is what failed.

    Rscript R/09-export-design.R
    python3 review/verify-protocol.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = (ROOT / "protocol.md").read_text()
# Prose is hard-wrapped, so a phrase that reads as one sentence is split by a
# newline in the file. Matching the raw text produced two false failures on the
# first run; every content check therefore runs against a whitespace-normalized
# copy. Table and style checks that care about line shape still use RAW.
PROTOCOL = re.sub(r"\s+", " ", RAW)
DESIGN = json.loads((ROOT / "results" / "registered-design.json").read_text())

fails: list[str] = []
checks = 0

# THE OPTIONAL-KEY GUARDS BELOW ARE NOT ALLOWED TO REDUCE THE DENOMINATOR.
#
# Round 6 found that every `if key in DESIGN:` block silently skipped when the
# export lacked the key, so a missing artifact removed both the number and its
# assertions and this script still printed a clean pass. It had already happened:
# `results/dgm-verification.rds` was absent while the header advertised 253 of
# 253 passing, and the count in the header moved with it, so nothing looked
# wrong.
#
# Every key any conditional block reads is listed here and required once, up
# front. A key that goes missing is now one loud failure rather than a quiet
# subtraction, and the assertion count stays fixed so the header check catches
# the shrinkage too.
REQUIRED_KEYS = [
    "e1_d3_worst_flip", "e2_max_shift_per_sd", "e2_cover_limit_min",
    "pool_shift_weibull", "anchor_err_pbo", "anchor_truth", "anchor",
    "anchor_order_agreement", "cell_properties", "ph_n_rep",
    "e1_least_false", "e1_d3", "e1_factorial", "e2_cells",
    "e2_discriminate_cells", "budget", "cost", "sens_cells", "sens_settings",
    "sens_n", "sens_n_per_cell", "n_mcse_rep", "n_knots", "dgm_placebo_flat",
]


def check(label: str, ok: bool, detail: str = "") -> None:
    global checks
    checks += 1
    if not ok:
        fails.append(f"{label}{': ' + detail if detail else ''}")


for _k in REQUIRED_KEYS:
    check(f"the export carries {_k}", _k in DESIGN,
          "its assertions would otherwise be skipped silently")


def present(label: str, *needles: str) -> None:
    """Every needle must appear somewhere in the protocol."""
    for n in needles:
        check(label, n in PROTOCOL, f"missing {n!r}")


def absent(label: str, pattern: str, text: str | None = None) -> None:
    m = re.search(pattern, PROTOCOL if text is None else text)
    check(label, m is None, f"found {m.group(0)!r}" if m else "")


def nums(row: str) -> list[float]:
    """Every signed decimal in a markdown table row, in order."""
    return [float(x.replace("$", "").replace("{,}", "").replace(",", ""))
            for x in re.findall(r"[-+−]?\d+\.\d+|[-+−]?\d+", row)]


def near(a: float, b: float, tol: float = 5e-4) -> bool:
    return abs(a - b) <= tol


def table_around(anchor: str) -> list[str]:
    """Body rows of the table containing `anchor`, found by walking OUT to its
    edges. Tables with an empty header row cannot be located by a header needle,
    and a hand-counted offset from the anchor is the thing that corrupted the
    totals table once already."""
    lines = RAW.splitlines()
    i = next((k for k, ln in enumerate(lines) if anchor in ln
              and ln.lstrip().startswith("|")), None)
    if i is None:
        return []
    lo = i
    while lo > 0 and lines[lo - 1].lstrip().startswith("|") \
            and not re.fullmatch(r"\|[-|: ]+\|", lines[lo - 1]):
        lo -= 1
    hi = i + 1
    while hi < len(lines) and lines[hi].lstrip().startswith("|"):
        hi += 1
    return lines[lo:hi]


def table_after(header_needle: str) -> list[str]:
    """Body rows of the first markdown table whose header row contains the needle."""
    lines = RAW.splitlines()
    for i, ln in enumerate(lines):
        if header_needle in ln and ln.lstrip().startswith("|"):
            body = []
            for ln2 in lines[i + 2:]:            # skip the |---| separator
                if not ln2.lstrip().startswith("|"):
                    break
                body.append(ln2)
            return body
    return []


# --- the cell matrix ---------------------------------------------------------
# Each solved beta_B must appear in the protocol, to four decimals, with a
# minus sign written as the document writes it.
for c in DESIGN["cells"]:
    bb = f"{c['beta_b']:.4f}".replace("-", "")
    present(f"beta_B for {c['arm']}/{c['family']}/k={c['kappa_b']}", bb)

_WORDS = {8: "Eight", 9: "Nine", 10: "Ten", 11: "Eleven", 12: "Twelve",
          13: "Thirteen", 14: "Fourteen", 15: "Fifteen", 16: "Sixteen"}
_n = DESIGN["n_cell_rows"]
check(
    "cell count",
    f"{_n} cells" in PROTOCOL or f"{_WORDS.get(_n, '')} cells" in PROTOCOL
    or f"{_n} cell-by-censoring" in PROTOCOL,
    f"protocol does not state the registered cell count ({_n})",
)
present("replicate total", f"{DESIGN['n_replicates']}")
present("replicates per cell", f"{DESIGN['n_rep']} replicates")

# --- scalar parameters -------------------------------------------------------
present("tau", f"$\\tau = {DESIGN['tau']}$")
present("sample sizes", f"{DESIGN['n_ipd']} / {DESIGN['n_agd']}")
present("covariate means", f"{DESIGN['mu_ipd']:.2f} / {DESIGN['mu_tgt']:.2f}")
present("beta_A", f"{DESIGN['beta_a']:.2f}".replace("-", ""))
present("gamma", f"{DESIGN['gamma']:.2f}")
present("decision threshold", f"{DESIGN['threshold']:.2f}")
present("integration order", f"{DESIGN['n_int']}")

for d in sorted({c["target_delta"] for c in DESIGN["cells"]}):
    present("registered margin", f"{d:.2f}")

# --- THE PILOT TABLE, cell by cell ------------------------------------------
# This is the check that version 4 needed and did not have. The protocol's
# section 10.3 table is parsed and every value compared against the pilot object
# the code actually saved. Row order and column order are both asserted.
_PILOT_COLS = ["MAIC-PH", "MAIC-flex", "STC-PH", "STC-flex", "MAIC-Cox"]
_pilot_rows = table_after("| cell (truth) |")
if not _pilot_rows:
    check("pilot table present", False, "no table with header '| cell (truth) |'")
else:
    exported = DESIGN.get("pilot_bias", {})
    check("pilot table row count", len(_pilot_rows) == len(exported),
          f"protocol has {len(_pilot_rows)} rows, code exports {len(exported)}")
    for row, (cell, vals) in zip(_pilot_rows, exported.items()):
        got = nums(row)
        # Drop the leading label numbers (kappa/gamma/truth) by taking the last
        # five, which are the five estimator columns.
        got = got[-len(_PILOT_COLS):]
        want = [vals[c] for c in _PILOT_COLS]
        for name, g, w in zip(_PILOT_COLS, got, want):
            check("pilot bias value", abs(g - w) < 5e-4,
                  f"{cell}/{name}: protocol {g:+.3f}, code {w:+.3f}")

# The withdrawn artifact values must not reappear anywhere in the document.
for bad in ["+0.383", "+0.397", "+0.143", "+0.148", "+0.151", "+0.136",
            "$-0.424$", "$-0.416$", "$+0.089$", "$+0.009$"]:
    absent("pre-fix STC value resurrected", re.escape(bad))

# --- the decision-loss table -------------------------------------------------
_loss_rows = table_after("| estimator | weighted decision loss |")
if _loss_rows:
    want = DESIGN.get("pilot_decision_loss", {})
    seen = 0
    for row in _loss_rows:
        for est, v in want.items():
            if est in row:
                got = nums(row)
                check("decision loss value",
                      any(abs(g - v) < 5e-4 for g in got),
                      f"{est}: protocol {got}, code {v:.4f}")
                seen += 1
    check("decision loss rows", seen == len(want),
          f"matched {seen} of {len(want)} estimator rows")
    present("always-recommend baseline", f"{DESIGN['pilot_loss_always']:.4f}")
    present("never-recommend baseline", f"{DESIGN['pilot_loss_never']:.4f}")

# --- E1 and E2 headline numbers ---------------------------------------------
if "e1_d3_worst_flip" in DESIGN:
    present("D3 flip cells",
            f"{DESIGN['e1_d3_flip_cells']} of {DESIGN['e1_d3_n_cells']}")
    present("D3 worst flip fraction", f"{DESIGN['e1_d3_worst_flip']:.4f}")
    present("D3 worst flip count", f"{DESIGN['e1_d3_worst_flip_n']} of 16")
    present("D3 big-range-no-flip counterexample",
            f"{DESIGN['e1_d3_big_range_no_flip']:.4f}")
    check("D3 verdict stated",
          ("D3 fails" in PROTOCOL) == (not DESIGN["e1_d3_pass"]),
          f"code says pass={DESIGN['e1_d3_pass']}, protocol text disagrees")
    # Round 5: the statistic must not be a range judged against a level threshold.
    absent("D3 range compared to the reimbursement threshold",
           r"range is (\*\*)?[\d.]+ months(\*\*)? against the 0\.50-month")
if "e2_max_shift_per_sd" in DESIGN:
    present("E2 shift per SD", f"{DESIGN['e2_max_shift_per_sd']:.3f}")
    present("E2 detection probability",
            f"{100 * DESIGN['e2_max_detect']:.1f}%")
    present("E2 worst bias vs the E1 limit", f"{DESIGN['e2_worst_abs_bias']:.4f}")
    present("E2 coverage of the E1 limit",
            f"{DESIGN['e2_cover_limit_min']:.3f}",
            f"{DESIGN['e2_cover_limit_max']:.3f}")

# --- claims that must not survive from earlier versions ----------------------
present("flexible arm transports", "aux_regression = ~ .trt")
present("aux_by failure documented", "unable to transport")
absent("stale replicate SD", r"per-replicate SD near 0\.35")
absent("stale integration order", r"[Tt]he run uses .{0,40}32 integration points")
absent("stale three-study network", r"[Tt]hree studies contribute aggregate data")
absent("unresolved placeholder", r"XX[A-Z]+XX|TODO|FIXME|\bTBD\b")
# Round 4: the direct head-to-head framing is withdrawn. It may be DESCRIBED as
# withdrawn, but must not be asserted as what E1 and E2 measure.
absent("head-to-head framing still asserted",
       r"Both evaluate the hazard ratio that a \*\*head-to-head")

# --- style constraints, which apply to published prose -----------------------
absent("em or en dash", r"[—–]", RAW)
absent("spaced hyphen as dash", r"[a-z,\)] - [a-z\(]", RAW)
absent(
    "British spelling",
    r"\b(behaviour|standardis\w*|modelling|colour|analyse[sd]?|"
    r"parameteris\w*|marginalis\w*|normalis\w*|favour|labelled|randomisation)\b",
)

# --- internal consistency ----------------------------------------------------
# Round 5: mean ABSOLUTE cell bias has a Monte Carlo floor larger than the
# effects it must resolve. The protocol must state the floor and the correction.
check("bias Monte Carlo floor stated",
      "0.095" in PROTOCOL and "corrected for its own Monte Carlo floor" in PROTOCOL,
      "the mean-absolute-bias noise floor or its correction is missing")
# Round 5: E2's variance-estimator choice must be shown not to drive coverage.
if "e2_cover_limit_min" in DESIGN:
    check("E2 variance estimator checked",
          "robust sandwich" in PROTOCOL,
          "E2 does not report the robust-variance comparison")

present("measured planning SD",
        f"{DESIGN['planning_sd']} is the registered planning value")
present("noise floor stated", f"{round(100 * DESIGN['noise_floor'])}%")

for fatal in [
    "Censoring absent from the cell matrix",
    "DGM not numerically locked",
    "does not justify a 0.5-month bias tolerance",
]:
    present("round-2 fatal recorded", fatal)

# --- cross-section numeric consistency -------------------------------------
# Round 4 found contradictions that every earlier check missed, all introduced by
# editing one section and not another. Any replicate or resample count appearing
# anywhere in the document must be the one the code exports.
_n_rep, _n_boot = DESIGN["n_rep"], DESIGN.get("n_boot")
for bad in re.findall(r"(\d+) replicates each", PROTOCOL):
    check("replicates-per-cell consistency", int(bad) == _n_rep,
          f"section says {bad} replicates each, code exports {_n_rep}")
for bad in re.findall(r"\*\*(\d+)\s*\n?replicates\*\*", PROTOCOL):
    check("replicate-total consistency", int(bad) == DESIGN["n_replicates"],
          f"section says {bad} total, code exports {DESIGN['n_replicates']}")
if _n_boot:
    for bad in re.findall(r"(\d+) resamples", PROTOCOL):
        check("bootstrap consistency", int(bad) == _n_boot,
              f"section says {bad} resamples, code exports {_n_boot}")

check("kappa_A not printed as a constant",
      not re.search(r"\$\\kappa_A\$[^|]*\|\s*0(\.00)?\s*\|", PROTOCOL)
      or "design factor" in PROTOCOL,
      "locked table prints kappa_A as a fixed 0")

# The chain count is registered in config and was CHANGED after measurement
# disproved the argument for the old value. Version 4 changed the config and left
# section 7.1 still arguing for four chains, which is the same class of defect as
# the D1 resurrection: an edit applied to one place and not another.
check("chain count matches config",
      f"{DESIGN['n_chains']} chains of {DESIGN['n_iter']:,} iterations".replace(",", ",")
      in PROTOCOL or f"{DESIGN['n_chains']} chains" in PROTOCOL,
      f"protocol does not register {DESIGN['n_chains']} chains")
absent("stale four-chain argument",
       r"[Ff]our chains cost the same wall clock(?!.{0,200}[Ff]alse)")

# The DGM verifiers. The protocol quotes each to four figures; they are the
# reason the rebuilt parameterization is trusted, so a stale one would be worse
# than an absent one.
def sci(x: float) -> list[str]:
    """The ways this document writes a small number, e.g. 4.406e-16."""
    m, e = f"{x:.4g}".split("e") if "e" in f"{x:.4g}" else (f"{x:.4g}", None)
    if e is None:
        return [m]
    ee = int(e)
    return [f"{m}e{ee}", f"{m}e-{abs(ee)}" if ee < 0 else f"{m}e{ee}",
            f"{m}\\times10^{{{ee}}}", f"{m} \\times 10^{{{ee}}}"]


for key, label in [("verify_invariance", "baseline invariance"),
                   ("verify_kappa_isolates", "kappa isolation"),
                   ("verify_cox_limit", "Cox limit check")]:
    if key in DESIGN:
        check(f"DGM verifier {label}",
              any(s in PROTOCOL for s in sci(DESIGN[key])),
              f"none of {sci(DESIGN[key])} appears in the protocol")

# The placebo-flatness verifier had been written and never called, so the
# property that eighteen call sites got wrong was checked by nothing.
check("the placebo arm is verified flat, not asserted flat",
      DESIGN["dgm_placebo_flat"] == 0
      and "spread of placebo survival across them is **exactly 0**" in PROTOCOL,
      f"exported {DESIGN['dgm_placebo_flat']}")

# The header's version number and per-round fatal counts are derived from the
# change log, not typed. Version 5 shipped with a header still claiming to be the
# fourth version after three rounds, because nothing connected the two.
ORDINAL = {1: "first", 2: "second", 3: "third", 4: "fourth", 5: "fifth",
           6: "sixth", 7: "seventh", 8: "eighth", 9: "ninth", 10: "tenth"}
CARDINAL = {1: "One", 2: "Two", 3: "Three", 4: "Four", 5: "Five", 6: "Six",
            7: "Seven", 8: "Eight", 9: "Nine", 10: "Ten"}
_lines = RAW.splitlines()
# Matches every change-log round header, not only the one marked "this version".
# The old pattern required that marker on all of them, so relabeling a superseded
# round dropped it from the parse and its fatal count silently merged into the
# round above: [3, 6, 8, 5] became [3, 6, 13, 0] with no complaint about the
# missing block, only about the totals.
_starts = [(i, int(m.group(1))) for i, ln in enumerate(_lines)
           if (m := re.match(r"^Round (\d)[,.]", ln))]
if _starts:
    rounds = max(n for _, n in _starts)
    # "this version" belongs to exactly one round, the newest. Version 5 shipped
    # with a header claiming to be the fourth version after three rounds because
    # nothing connected the two; this connects them from the other direction too.
    _tv = [n for i, n in _starts if "this version" in _lines[i]]
    check("exactly one change-log round is marked as this version",
          _tv == [rounds], f"marked: {_tv}, newest round is {rounds}")
    check("header version follows the change log",
          f"This is the **{ORDINAL[rounds + 1]}** version." in PROTOCOL,
          f"{rounds} critique rounds are logged, so this is version {rounds + 1}")
    check("header round count follows the change log",
          f"{CARDINAL[rounds]} rounds of adversarial pre-run critique preceded it"
          in PROTOCOL,
          f"the change log records {rounds} rounds")
    # Per-round fatal counts, counted from the severity column of each round's
    # table rather than remembered.
    bounds = [i for i, _ in _starts] + [len(_lines)]
    fatals = {}
    for (i, n), j in zip(_starts, bounds[1:]):
        fatals[n] = sum(1 for b in _lines[i:j]
                        if b.startswith("|") and re.search(r"\|\s*\*\*fatal\*\*\s*\|", b))
    printed = re.search(r"Rounds 2 through (\d) returned ([^.]+?)\s*fatal findings",
                        PROTOCOL)
    check("per-round fatal counts are stated", printed is not None,
          "the header does not state per-round fatal counts")
    if printed:
        want = [fatals.get(n, 0) for n in range(2, int(printed.group(1)) + 1)]
        got = [int(x) for x in re.findall(r"\d+", printed.group(2))]
        check("per-round fatal counts follow the change log", got == want,
              f"header prints {got}, change-log tables contain {want}")
    # The count the header prints is checked against the count actually run, at
    # the bottom of this file where that number is finally known.

# Round 5's flexible-arm finding: aux_regression pools the baseline across
# studies. The protocol must state both the software limitation and the measured
# reason it does not bite here, and must not claim the latter without the former.
if "pool_shift_weibull" in DESIGN:
    present("pooling shift Weibull", f"{DESIGN['pool_shift_weibull']:.6f}")
    present("pooling shift Gompertz", f"{DESIGN['pool_shift_gompertz']:.6f}")
    check("baseline pooling limitation declared",
          "silently ignored" in PROTOCOL and "baseline *shape*" in PROTOCOL,
          "the aux_regression pooling finding or its scope limit is missing")

# Round 5's anchoring check: the flexible arm's ABSOLUTE curves are biased and
# the contrast is not. The protocol must state the placebo error and must forbid
# absolute-scale claims for that arm, since that is the whole consequence.
if "anchor_err_pbo" in DESIGN:
    present("anchoring placebo error", f"{DESIGN['anchor_err_pbo']:.3f}".lstrip("+"))
    check("absolute-scale claims forbidden for the flexible arm",
          "No absolute-scale claim about the flexible ML-NMR arm is made" in PROTOCOL,
          "the anchoring finding is reported without its consequence")

# The truth this is measured against is now computed from the DGM and exported,
# not typed. It used to be three literals in the exporter, which checked nothing.
if "anchor_truth" in DESIGN:
    for key, value in DESIGN["anchor_truth"].items():
        present(f"anchoring truth {key}", f"{value:.3f}")
    present("anchoring wrong-anchor attractor", f"{DESIGN['anchor_wrong_target']:.3f}")

# The large-sample arm. Every row of the arm-size table must reproduce from the
# measurement, and a new exported dataset forces a new printed row.
if "anchor" in DESIGN:
    rows = table_after("arms per study")
    check("anchoring table has one row per measured arm size",
          len(rows) == len(DESIGN["anchor"]),
          f"{len(rows)} printed rows against {len(DESIGN['anchor'])} measured datasets")
    for row, (key, a) in zip(rows, DESIGN["anchor"].items()):
        got = nums(row)
        want = [a["n_int"], a["n_mult"], a["n_ipd"], a["n_agd"], a["n"],
                a["err_pbo"], a["mcse_pbo"], a["err_a"], a["err_b"],
                a["err_diff"], a["mcse_diff"]]
        check(f"anchoring row {key} reproduces the measurement",
              len(got) == len(want)
              and all(abs(x - y) < 5e-4 for x, y in zip(got, want)),
              f"printed {got} against measured {want}")
if "anchor_order_agreement" in DESIGN:
    present("integration-order agreement on the anchoring check",
            f"{DESIGN['anchor_order_agreement']['worst_abs']:.3f}")

# The structural-against-finite-sample block that stood here is deleted, not
# disabled. It decomposed an absolute-scale bias that the round-6 placebo
# correction showed did not exist: the same fitted values are within a fifth of
# a month of the registered truth, and the residual changes sign between the two
# arm sizes, so there is no decay rate to estimate. Keeping the machinery would
# invite the numbers back.

# Every file the document points at must exist. A protocol that cites a script
# as the evidence for a claim is only as good as the script being there.
_referenced = sorted(set(re.findall(r"`((?:R|review|results)/[\w./-]+)`", PROTOCOL)))
_missing = [f for f in _referenced if not (ROOT / f).exists()]
check("every referenced file exists", not _missing,
      f"{len(_referenced)} referenced, missing: {', '.join(_missing)}")

# The registered sampler policy, and the fact that its tail criterion was inert
# for five versions. Both the fix and the disclosure are asserted, because a
# silently repaired no-op is the same defect class as the original.
check("sampler policy states all five criteria",
      all(s in PROTOCOL for s in ["bulk and tail ESS", "divergent transitions",
                                  "maximum treedepth", r"\hat R < 1.01"]),
      "the registered sampler policy is incomplete")
check("the inert tail criterion is disclosed",
      "had never been evaluated" in PROTOCOL and "tested one statistic twice" in PROTOCOL,
      "the tail-ESS defect is fixed in code but not recorded in the protocol")
check("the pass rule fails closed",
      "passes everything" in PROTOCOL,
      "the protocol does not say what happens when a criterion's input is missing")
check("the pipeline is run before the run",
      "executed end to end before the run" in PROTOCOL
      and "produces no reportable number" in PROTOCOL,
      "the smoke test is not registered, or is not marked as producing no result")

# --- the coverage pool ------------------------------------------------------
# Round 6 found 14 conditions and 560 replicates still live in section 9 and in
# section 10's prose after round 5 had corrected only the table. Two counts in
# one document leave the pool selectable once results are seen.
_pool_n = DESIGN["n_cell_rows"] * DESIGN["n_rep"]
check("coverage pool matches the frozen matrix",
      f"**{DESIGN['n_cell_rows']} cell-by-censoring conditions at {DESIGN['n_rep']} "
      f"replicates is {_pool_n} replicates per estimator.**" in PROTOCOL,
      f"section 9 does not state {DESIGN['n_cell_rows']} conditions / {_pool_n}")
_pool_se = round((0.95 * 0.05 / _pool_n) ** 0.5, 4)
check("pooled coverage standard error reproduces",
      f"**{_pool_se}**" in PROTOCOL,
      f"sqrt(.95*.05/{_pool_n}) = {_pool_se} is not what the protocol prints")
check("exactly one coverage pool is registered",
      "**The registered pool is all "
      f"{DESIGN['n_cell_rows']} conditions.**" in PROTOCOL,
      "no single pool is declared, so a subset can be chosen after the run")
for stale in ["14 cell-by-censoring conditions", "six primary cells"]:
    for m in re.finditer(re.escape(stale), PROTOCOL):
        window = PROTOCOL[max(0, m.start() - 260):m.start()]
        check(f"stale pool count {stale!r} is marked as superseded",
              any(w in window for w in ("Version 5", "Version 4", "version 4",
                                        "version 5", "round 5", "Round 5")),
              "it reads as a current claim")

# Section 8's cell-properties table, computed from the registered design rather
# than read from a saved file that nothing regenerates.
if "cell_properties" in DESIGN:
    rows = table_after("PH rejects, leg A")
    check("cell-properties table has one row per cell",
          len(rows) == len(DESIGN["cell_properties"]),
          f"{len(rows)} rows against {len(DESIGN['cell_properties'])} computed")
    for row, c in zip(rows, DESIGN["cell_properties"]):
        got = nums(row)
        want = [c["kappa_a"], c["kappa_b"]]
        if c.get("cond_cross") is not None:
            want += [c["cond_cross"], c["marg_cross"]]
        want += [c["hr_min"], c["hr_max"], c["at_risk_a"], c["at_risk_b"],
                 c["ph_reject_leg_a"], c["ph_reject_leg_b"]]
        check(f"cell-properties row {c['arm']}/{c['family']}/{c['kappa_b']} "
              f"reproduces",
              len(got) == len(want) and all(abs(x - y) < 5e-4
                                            for x, y in zip(got, want)),
              f"printed {got} against computed {want}")
if "ph_n_rep" in DESIGN:
    present("PH power replicate count", f"**{DESIGN['ph_n_rep']:,}**")
    present("PH power worst standard error", f"{DESIGN['ph_worst_se']:.4f}")
    check("the withdrawn direct-trial PH rate is gone from section 8",
          "nothing regenerated" in PROTOCOL,
          "the stale cell-properties source is not recorded")

# The arm-differential quadrature error. The registered contrast is WITHIN the
# ML-NMR row, and the two arms' errors have opposite sign, so they add there.
if "integration_512" in DESIGN:
    rows = table_after(r"\hat\Delta_{512}")
    have = [k for k in ["flex", "ph", "differential"]
            if k in DESIGN["integration_512"]]
    check("arm-differential table has one row per measured arm",
          len(rows) == len(have), f"{len(rows)} rows against {len(have)} measured")
    for row, key in zip(rows, have):
        a = DESIGN["integration_512"][key]
        got = nums(row)
        want = [a["n"], a["mean"], a["se"], a["t"]]
        check(f"arm-differential row {key} reproduces",
              len(got) == len(want) and all(abs(x - y) < 5e-5
                                            for x, y in zip(got, want)),
              f"printed {got} against measured {want}")
    # The opposite-sign reading held at five and six paired replicates and not at
    # the registered eight. The document must carry the withdrawal, not the
    # claim, and must not quietly drop both.
    check("the withdrawn opposite-sign reading is recorded as withdrawn",
          "at eight they do not" in PROTOCOL
          and "The opposite-sign reading that earlier versions of this section "
              "built on is withdrawn." in PROTOCOL,
          "the protocol neither states nor withdraws the opposite-sign claim")
if "integration_512_bound" in DESIGN:
    b = DESIGN["integration_512_bound"]
    present("ML-NMR within-row withdrawal bound", f"{b:.3f}")
    check("the ML-NMR within-row bound is registered as a withdrawal",
          "ranking `MLNMR-flex`" in PROTOCOL and "withdrawn in advance" in PROTOCOL,
          "the bound is printed but nothing is withdrawn against it")
    pct = round(100 * b / DESIGN["threshold"])
    check("the bound's share of the decision threshold reproduces",
          f"{pct}% of the 0.50-month decision threshold" in PROTOCOL,
          f"{b}/{DESIGN['threshold']} = {pct}%")

# Round 6: the version-5 bias correction left a residual floor about the size of
# the effects it had to resolve. The registered statistic moved to the squared
# scale, where the correction is exact. The document must carry the constant, the
# residual floor it implies, and the fact that the statistic may go negative.
check("the residual floor of the old correction is stated",
      "0.3431 se" in PROTOCOL and "0.0407 months" in PROTOCOL,
      "the protocol does not state what version 5's correction left behind")
check("the registered bias statistic is on the squared scale",
      "**The registered statistic is therefore on the squared scale, where the "
      "correction is exact.**" in PROTOCOL,
      "the squared-scale registration is missing")
check("the statistic is allowed to go negative",
      "**It can come out negative**" in PROTOCOL,
      "truncation at zero is what reintroduced the floor; that must be stated")
check("the back-transform is not the registered quantity",
      "labeled as a back-transform, never as the registered quantity" in PROTOCOL,
      "the square root is printed without being marked as descriptive")
check("outcome 1's resolution limit is declared",
      "limited by the number of cells, not replicates" in PROTOCOL,
      "the per-cell aggregate is presented as if replicate pairing helped it")

# Round 6: every registered outcome must have its own paired contrast, and the
# absolute-error contrast that version 5 reported as primary must be labeled.
check('each registered outcome has its own paired contrast',
      'Each registered comparison is tested as a paired difference on each '
      'registered outcome' in PROTOCOL,
      'the paired machinery is still described as testing one quantity')
check('the absolute-error contrast is marked descriptive',
      'it is labeled descriptive and is not' in PROTOCOL,
      'the mean-absolute-error contrast is not distinguished from the four outcomes')

# Round 6: MAIC and STC used the true target moments while ML-NMR used the
# realized ones, so target-summary noise entered only the ML-NMR rows. The
# resolution changed the study scope, so the document must say so.
check('every method receives the same target summaries',
      'supplied identically to every' in PROTOCOL
      and 'PUBLISHED moments' in PROTOCOL,
      'the target-summary asymmetry is not resolved in the document')
check('the truth is still the true target law',
      '**The truth is still evaluated at the true target law**' in PROTOCOL,
      'the estimand is not pinned after the summaries changed')
check('the scope change is recorded as one',
      'That is a change of scope from version 5 and is recorded as one.' in PROTOCOL,
      'target-summary error moved into scope silently')

# Round 6: the refit cap was budgeted but unenforceable under mclapply, and the
# rule it described would have discarded valid fits to hold a schedule number.
check('the refit cap is a budget assumption, not a policy',
      '20% is a budget assumption, not a policy that fires' in PROTOCOL,
      'the unenforceable cap rule is still registered')
check('no fit is reclassified to protect the budget',
      'No fit is ever reclassified to protect the budget.' in PROTOCOL,
      'the analysis set can still be selected by a budget number')
# The sampler policy now binds on the survival differences too.
check('the sampler policy covers the survival differences',
      'binds on the survival differences too' in PROTOCOL
      or 'survival differences on the time grid' in PROTOCOL,
      'the policy is described as RMST-only')

check("the survival-difference diagnostics are per registered time",
      "per **registered time**" in PROTOCOL,
      "the policy does not say it binds at every time")
check('a missing survival prediction fails the fit',
      'is missing or non-finite **fails**' in PROTOCOL,
      'a failed survival prediction can still pass')
check('the frequentist time-grid error is recorded',
      '6.0033 and 11.9565' in PROTOCOL,
      'the grid snap is fixed in code but not recorded')

# Round 6: the common Cox projection was registered and applied to nothing.
check('the common Cox projection is implemented',
      'cox_project` feeds it a **fitted** curve pair' in PROTOCOL,
      'the functional is registered but not shown to be implemented')
check('the projection is validated against the analytic value',
      '8\\times10^{-5}' in PROTOCOL,
      'no agreement figure between the projection and the analytic limit')
check('the projection regime is pinned',
      'pinned to the balanced condition' in PROTOCOL,
      'the projection regime is not fixed, so the summary is not comparable')

# Round 6: the common-random-numbers fix made the 840 rows 400 clusters, so
# every independence-based standard error in the document is a reference point
# and not the registered one.
check('the clustering consequence is stated',
      '400 (parameter cell, replicate) blocks' in PROTOCOL,
      'the document still treats the 840 rows as independent')
check('the registered interval is the clustered one',
      'the registered interval is the cluster-robust one' in PROTOCOL,
      'no interval is declared registered after the clustering change')
check('the independent figures are marked as reference only',
      'not** the quantity any verdict is read from' in PROTOCOL,
      'the independent-sampling arithmetic can still be read as a verdict')

# --- the results documents ---------------------------------------------------
# Until now only protocol.md was guarded. results/e1-results.md and
# results/e2-results.md carry per-cell tables, they are what the manuscript will
# draw on, and nothing checked them. The first pass of this block found two
# defects: the E2 coverage column reported each cell's BEST coverage beside its
# WORST bias, and one detection probability was hand-rounded from 0.1025 to
# 0.103. Three of this study's fatal findings were stale or hand-copied tables.
def doc(name: str) -> tuple[str, str]:
    p = ROOT / "results" / name
    raw = p.read_text() if p.exists() else ""
    return raw, re.sub(r"\s+", " ", raw)


def table_rows_in(raw: str, header_needle: str) -> list[str]:
    lines = raw.splitlines()
    for i, ln in enumerate(lines):
        if header_needle in ln and ln.lstrip().startswith("|"):
            body = []
            for ln2 in lines[i + 2:]:
                if not ln2.lstrip().startswith("|"):
                    break
                body.append(ln2)
            return body
    return []


def check_cell_table(label: str, raw: str, needle: str, cells: list,
                     fields: list[str], tol: float) -> None:
    """Assert a per-cell markdown table against exported cells.

    Rows are matched on the (kappa_A, kappa_B) they print, not on position: the
    two E2 tables order their cells differently and a positional check reported
    four spurious failures for that reason alone.
    """
    rows = table_rows_in(raw, needle)
    check(f"{label} has one row per cell", len(rows) == len(cells),
          f"{len(rows)} rows against {len(cells)} cells")
    by_key = {(round(c["kappa_a"], 4), round(c["kappa_b"], 4)): c for c in cells}
    seen = set()
    for row in rows:
        got = nums(row)
        if len(got) < 2:
            check(f"{label} row is parseable", False, row.strip())
            continue
        key = (round(got[0], 4), round(got[1], 4))
        c = by_key.get(key)
        if c is None:
            check(f"{label} row ({key[0]}, {key[1]}) is a measured cell", False,
                  f"no exported cell with those kappas")
            continue
        seen.add(key)
        want = [c["kappa_a"], c["kappa_b"]] + [c[f] for f in fields]
        check(f"{label} cell ({key[0]}, {key[1]}) reproduces",
              len(got) == len(want) and all(abs(x - y) < tol
                                            for x, y in zip(got, want)),
              f"printed {got} against measured {want}")
    check(f"{label} prints every measured cell", seen == set(by_key),
          f"missing {sorted(set(by_key) - seen)}")


E2_RAW, E2 = doc("e2-results.md")
check("E2 results document exists", bool(E2_RAW))
if E2_RAW and "e2_cells" in DESIGN:
    check_cell_table("E2 bias/coverage table", E2_RAW, "worst coverage",
                     DESIGN["e2_cells"], ["worst_abs_bias", "worst_cover",
                                          "best_cover"], 5e-5)
    check("the worst-beside-best pairing is recorded, not silently fixed",
          "opposite extremes" in E2,
          "the coverage column changed meaning with no note saying so")

if E2_RAW and "e2_discriminate_cells" in DESIGN:
    check_cell_table("E2 detection table", E2_RAW, "single-estimate SDs",
                     DESIGN["e2_discriminate_cells"],
                     ["worst_shift_per_sd", "max_detect"], 5e-4)

E1_RAW, E1 = doc("e1-results.md")
check("E1 results document exists", bool(E1_RAW))


SCI_TEX = re.compile(r"\$?\s*(-?\d+(?:\.\d+)?)\s*\\times\s*10\^\{(-?\d+)\}\s*\$?")


def nums_at_printed_precision(row: str) -> list[tuple[float, int | None]]:
    """Numbers in a markdown row, each with the decimal places it was printed to.

    E1's tables span 1e-10 to 37, so a fixed tolerance cannot work: a value
    printed as 0.077 and computed as 0.07668 agrees exactly at the precision
    shown, while 0.782 against 0.781483 does not. LaTeX scientific notation is
    folded to a float first, since it otherwise reads as three separate numbers.
    """
    row = SCI_TEX.sub(lambda m: f" {float(m.group(1)) * 10 ** int(m.group(2)):.12e} ",
                      row)
    out: list[tuple[float, int | None]] = []
    for tok in re.findall(r"[-+−]?\d+\.\d+[eE][-+]?\d+|[-+−]?\d+\.\d+|[-+−]?\d+",
                          row.replace("{,}", "").replace(",", "")):
        t = tok.replace("−", "-")
        if "e" in t or "E" in t:
            out.append((float(t), None))          # compare on significant figures
        else:
            out.append((float(t), len(t.split(".")[1]) if "." in t else 0))
    return out


def check_keyed_table(label: str, raw: str, needle: str, rows_exp: list,
                      fields: list[str]) -> None:
    """Assert a per-row table, comparing each cell at the precision it prints."""
    rows = table_rows_in(raw, needle)
    check(f"{label} has one row per computed row", len(rows) == len(rows_exp),
          f"{len(rows)} printed against {len(rows_exp)} computed")
    for row, e in zip(rows, rows_exp):
        got = nums_at_printed_precision(row)
        want = [e["kappa_a"], e["kappa_b"]] + [e[f] for f in fields]
        name = row.strip("| ").split("|")[0].strip().strip("*") or "?"
        if len(got) != len(want):
            check(f"{label} row {name} has the expected columns", False,
                  f"{len(got)} numbers printed, {len(want)} computed")
            continue
        bad = []
        for (printed, dec), computed in zip(got, want):
            if dec is None:                        # 2 significant figures shown
                ok_cell = abs(printed - computed) <= 0.05 * abs(computed)
            else:
                ok_cell = abs(printed - computed) <= 0.51 * 10 ** (-dec)
            if not ok_cell:
                bad.append(f"{printed} vs {computed}")
        check(f"{label} row {name} reproduces at the precision printed",
              not bad, "; ".join(bad))


if E1_RAW and "e1_least_false" in DESIGN:
    check_keyed_table("E1 least-false table", E1_RAW, "matched diagonal",
                      DESIGN["e1_least_false"],
                      ["spread_pct", "diag_pct", "leg_a", "leg_b"])
if E1_RAW and "e1_d3" in DESIGN:
    # The first pass of this check found four `max` values printed 0.001 high,
    # rounded up by hand where the computed value rounds down: 0.782 for
    # 0.781483, 0.802 for 0.801492, 1.319 for 1.318457 and 0.778 for 0.777500.
    check_keyed_table("E1 D3 table", E1_RAW, "matched-only range",
                      DESIGN["e1_d3"],
                      ["truth", "lo", "hi", "range", "range_diag"])
if E1_RAW and "e1_factorial" in DESIGN:
    check("E1 factorial grid is complete", len(DESIGN["e1_factorial"]) == 24,
          f"{len(DESIGN['e1_factorial'])} rows")

if E2_RAW:
    for key, fmt in [("e2_worst_abs_bias", "{:.4f}"), ("e2_worst_bias_t", "{:.2f}"),
                     ("e2_cover_limit_min", "{:.3f}"), ("e2_cover_limit_max", "{:.3f}"),
                     ("e2_cover_robust_min", "{:.3f}"),
                     ("e2_cover_robust_max", "{:.3f}"),
                     ("e2_se_ratio_mean", "{:.4f}"), ("e2_sd_single_min", "{:.3f}"),
                     ("e2_sd_single_max", "{:.3f}"), ("e2_max_detect", "{:.3f}"),
                     ("e2_shift_crossed", "{:.3f}"), ("e2_shift_matched", "{:.3f}")]:
        if key in DESIGN:
            v = fmt.format(DESIGN[key])
            check(f"E2 document states {key}", v in E2, f"missing {v!r}")
    check("E2 states its regime-pair count",
          str(DESIGN["e2_n_regime_pairs"]) in E2,
          f"missing {DESIGN['e2_n_regime_pairs']} regime pairs")
    check("E2 does not claim coverage of the estimand",
          "coverage of a least-false parameter, not of the estimand" in E2,
          "E2's coverage figures are not disclaimed as coverage of the limit")

# --- the budget, which the verifier had never checked at all ------------------
# Two fatal findings in this protocol have been budget arithmetic, and a third in
# round 6 found the sensitivity arms priced at roughly half their minimum. This
# script asserted none of it: R/10-budget.R computed the numbers, the exporter
# wrote them, and nothing compared them with what section 14 prints. Every figure
# in the three runtime tables is now read out of the document and matched.
B = DESIGN["budget"]
RUN_TBL = table_after("distinct parameter cells")
# The totals table has an empty header row, so it cannot be found by a header
# needle; it is located by the one label that appears in no other table.
TOT_TBL = [ln for ln in RAW.splitlines()
           if ln.startswith("| refit escalation, at the")]
if TOT_TBL:
    _i = RAW.splitlines().index(TOT_TBL[0])
    _all = RAW.splitlines()
    _j = _i
    while _j > 0 and _all[_j - 1].lstrip().startswith("|"):
        _j -= 1
    _k = _i + 1
    while _k < len(_all) and _all[_k].lstrip().startswith("|"):
        _k += 1
    TOT_TBL = [ln for ln in _all[_j:_k] if not re.fullmatch(r"\|[-|: ]+\|", ln)]


def row_value(rows: list[str], label: str) -> float | None:
    """First number in the SECOND cell of the first row whose first cell matches."""
    for r in rows:
        cells = [c.strip() for c in r.strip().strip("|").split("|")]
        if len(cells) > 1 and label in cells[0]:
            v = nums(cells[1])
            return v[0] if v else None
    return None


for label, key in [("Stan pass", "stan_h"), ("frequentist pass", "boot_h"),
                   ("main run", "main_total_h")]:
    got = row_value(RUN_TBL, label)
    check(f"frozen-run table states {key}", got is not None and near(got, B[key]),
          f"document {got}, budget {B[key]}")

check("frozen-run table states the replicate total",
      f"**{B['n_replicates']} replicates**" in PROTOCOL,
      f"missing {B['n_replicates']}")
check("frozen-run table states the resample count",
      f"**{B['n_boot']} resamples**" in PROTOCOL, f"missing {B['n_boot']}")
check("frozen-run table states the integration order",
      f"**{B['n_int']}**" in PROTOCOL, f"missing {B['n_int']}")

for label, key in [("main run", "main_total_h"), ("sensitivity arms", "arms_total_h"),
                   ("refit escalation", "refit_cap_h"), ("**total**", "grand_total_h")]:
    got = row_value(TOT_TBL, label)
    check(f"total table states {key}", got is not None and near(got, B[key]),
          f"document {got}, budget {B[key]}")

# EVERY LABEL APPEARS EXACTLY ONCE, AND THE TABLE IS EXACTLY FOUR ROWS.
# `row_value` returns the first match, so a table that had grown two duplicate
# "main run" rows passed every value assertion above while being visibly broken;
# an emitter with a hand-counted row offset did exactly that. A value check is
# not a shape check.
_labels = [r.strip().strip("|").split("|")[0].strip() for r in TOT_TBL]
check("the total table has one row per line item", len(TOT_TBL) == 4,
      f"{len(TOT_TBL)} rows: {_labels}")
check("no line item is duplicated in the total table",
      len(set(_labels)) == len(_labels), f"{_labels}")

# THE COLUMN MUST ADD UP AS PRINTED. Round 6 found 10.6 + 6.1 + 6.1 printed
# against a total of 22.9: components rounded for display, total rounded from the
# unrounded sum. A reader who checks a registered budget by adding its own column
# is doing the right thing and must not be punished for it.
_parts = [row_value(TOT_TBL, k) for k in
          ("main run", "sensitivity arms", "refit escalation")]
_tot = row_value(TOT_TBL, "**total**")
check("the total table's own column adds up",
      all(p is not None for p in _parts) and _tot is not None
      and near(sum(_parts), _tot),
      f"{_parts} sums to {sum(p for p in _parts if p is not None)}, printed {_tot}")

# --- the sensitivity program --------------------------------------------------
SENS_TBL = table_after("reruns bootstrap")
SENS_SET = DESIGN["budget"]["sens_table"]
check("the sensitivity table has one row per registered fit set",
      len(SENS_TBL) == len(SENS_SET) + 1,       # + the total row
      f"{len(SENS_TBL)} rows against {len(SENS_SET)} settings plus a total")
for i, s in enumerate(SENS_SET):
    if i >= len(SENS_TBL):
        break
    cells = [c.strip() for c in SENS_TBL[i].strip("|").split("|")]
    check(f"sensitivity row {s['setting']} names its arm", cells[0] == s["arm"],
          f"document {cells[0]!r}, registered {s['arm']!r}")
    check(f"sensitivity row {s['setting']} names its setting",
          cells[1] == f"`{s['setting']}`", f"document {cells[1]!r}")
    check(f"sensitivity row {s['setting']} states n_int",
          nums(cells[2]) == [s["n_int"]], f"document {cells[2]!r}")
    check(f"sensitivity row {s['setting']} states its knot count",
          nums(cells[4]) == [s["n_knots"]], f"document {cells[4]!r}")
    check(f"sensitivity row {s['setting']} states whether it reruns the bootstrap",
          ("yes" in cells[5]) == bool(s["freq"]), f"document {cells[5]!r}")
    check(f"sensitivity row {s['setting']} states its cost",
          near(nums(cells[6])[0], s["hours"]),
          f"document {cells[6]!r}, budget {s['hours']}")
_sens_tot = nums(SENS_TBL[-1])[-1] if SENS_TBL else None
check("the sensitivity table's own column adds up",
      _sens_tot is not None and near(sum(s["hours"] for s in SENS_SET), _sens_tot),
      f"rows sum to {sum(s['hours'] for s in SENS_SET)}, printed {_sens_tot}")
check("the sensitivity total matches the total table",
      _sens_tot is not None and near(_sens_tot, B["arms_total_h"]),
      f"arms table {_sens_tot}, total table {B['arms_total_h']}")

# The subset is named rather than described. Round 6 found "two primary cells"
# with no identifiers anywhere in the protocol or the code.
SUB_TBL = table_after("why this one")
check("the sensitivity subset names its cells",
      len(SUB_TBL) == len(DESIGN["sens_cells"]),
      f"{len(SUB_TBL)} rows against {len(DESIGN['sens_cells'])} registered cells")
for i, c in enumerate(DESIGN["sens_cells"]):
    if i >= len(SUB_TBL):
        break
    cells = [x.strip() for x in SUB_TBL[i].strip("|").split("|")]
    check(f"sensitivity cell {i} states kappa_A", near(nums(cells[1])[0], c["kappa_a"]),
          f"document {cells[1]!r}, registered {c['kappa_a']}")
    check(f"sensitivity cell {i} states kappa_B", near(nums(cells[2])[0], c["kappa_b"]),
          f"document {cells[2]!r}, registered {c['kappa_b']}")
check("the sensitivity replicate count is registered",
      f"**{DESIGN['sens_n_per_cell']} replicates per cell, "
      f"{DESIGN['sens_n']} in total**" in PROTOCOL,
      f"missing {DESIGN['sens_n_per_cell']}/{DESIGN['sens_n']}")
check("the sensitivity arms are paired with the production replicates",
      "sens_replicate` calls the same `sim_for(cell, rep_id)` as the main run"
      in PROTOCOL,
      "nothing states the arms reuse the production networks")
check("the knot arm reruns the bootstrap at the full resample count",
      "**full 500 resamples**" in PROTOCOL,
      "the frequentist half of the knot arm is not stated to run at full length")

# The 512-point rule was two branches that did not partition the outcome space.
check("the 512-point rule has an inconclusive branch",
      "**Inconclusive**, and reported as such" in PROTOCOL,
      "an interval crossing zero but wider than 0.02 still has no registered action")
check("the 512-point rule defines the magnitude of an interval",
      "M = \\max(|L|, |U|)" in PROTOCOL or "\\max(|L|, |U|)" in PROTOCOL,
      '"its magnitude" is still undefined for an interval')

# --- D3 at the alternative thresholds, computed rather than argued ------------
THR_TBL = table_after("worst flip fraction |")
check("the D3 threshold table has three rows", len(THR_TBL) == 3,
      f"{len(THR_TBL)} rows")
for i, (cells_k, worst_k) in enumerate([
        ("e1_d3_flip_cells_040", "e1_d3_worst_flip_040"),
        ("e1_d3_flip_cells", "e1_d3_worst_flip"),
        ("e1_d3_flip_cells_060", "e1_d3_worst_flip_060")]):
    if i >= len(THR_TBL):
        break
    v = nums(THR_TBL[i])
    check(f"D3 threshold row {i} states its flip count",
          len(v) >= 3 and v[1] == DESIGN[cells_k],
          f"document {v}, export {DESIGN[cells_k]}")
    check(f"D3 threshold row {i} states its worst flip fraction",
          len(v) >= 4 and near(v[-1], DESIGN[worst_k]),
          f"document {v}, export {DESIGN[worst_k]}")
# The withdrawn wording is quoted once, inside the paragraph that withdraws it.
# A bare `absent` check would fire on that quotation, and deleting the quotation
# to satisfy it is how a change log stops recording what changed.
_flip4 = re.findall(r'.{0,4}the same four cells still flip.{0,4}', PROTOCOL)
check("the four-cell invariance claim survives only as a quotation",
      len(_flip4) == 1 and '"' in _flip4[0].split("flip")[1],
      f"{len(_flip4)} occurrences: {_flip4}")
check("D3's threshold sensitivity keeps the verdict, not the count",
      "What survives is the verdict, not the count" in PROTOCOL,
      "the flip count is still presented as the invariant quantity")

# --- D3's numerical error, and the bound that replaced the borrowed one -------
CONV_TBL = table_around("largest movement under refinement")
_mant = DESIGN["d3_conv_worst_move"] * 1e4
check("the convergence table states the worst movement",
      any(f"${_mant:.1f}\\times10^{{-4}}$" in r for r in CONV_TBL),
      f"no row carries {_mant:.1f}e-4; rows: {CONV_TBL}")
check("the convergence table states the closest margin",
      any(f"{DESIGN['d3_conv_margin']:.4f}" in r for r in CONV_TBL),
      f"no row carries {DESIGN['d3_conv_margin']}")
check("the convergence table states the per-cell ratio",
      any(f"**{DESIGN['d3_conv_ratio_cell']} times**" in r for r in CONV_TBL),
      f"no row carries {DESIGN['d3_conv_ratio_cell']}")
check("the flip verdict is stable under refinement",
      DESIGN["d3_conv_stable"] is True
      and DESIGN["d3_conv_flips_base"] == DESIGN["d3_conv_flips_fine"],
      f"{DESIGN['d3_conv_flips_base']} against {DESIGN['d3_conv_flips_fine']}")
_ccb = re.findall(r".{0,3}quadrature error, which the control cell bounds.{0,60}",
                  PROTOCOL)
check("the control-cell bound survives only as a quotation",
      len(_ccb) == 1 and '"' in _ccb[0].split("bounds")[1],
      f"{len(_ccb)} occurrences: {_ccb}")
check("the borrowed bound is withdrawn in the text",
      "overstated the certainty by" in PROTOCOL,
      "nothing records that the control-cell bound was the wrong quantity")

# --- the ML-NMR within-row confound, declared rather than defended ------------
check("no pooling-matched proportional specification was found",
      DESIGN["pooled_ph_usable"] == []
      and DESIGN["pooled_ph_rejected"] == len(DESIGN["pooled_ph_tried"]),
      f"usable: {DESIGN['pooled_ph_usable']}")
check("both candidate specifications are named in the protocol",
      all(spec in PROTOCOL for spec in
          ("`aux_regression = ~ 1`", "`aux_by = c(.pool)`")),
      "the rejected candidates are not identified")
check("the within-row ML-NMR claim is downgraded to a joint effect",
      "attributable to the two jointly and not to proportionality alone"
      in PROTOCOL,
      "the within-row contrast is still claimed to isolate proportionality")
absent("the withdrawn claim that the within-row contrast isolates proportionality",
       r"the primary within-row ML-NMR contrast does isolate\s+proportionality"
       r"(?![\s\S]{0,400}does not follow)")

# --- diagnostics that section 7.2 registers and round 6 found unrecorded ------
check("effective degrees of freedom are recorded per replicate",
      "p_{\\text{WAIC}}$, the summed posterior variance" in PROTOCOL,
      "the registered flexibility diagnostic has no stated definition")
check("the bootstrap endpoint Monte Carlo error is computed before the draws go",
      f"`N_MCSE_REP = {DESIGN['n_mcse_rep']}`" in PROTOCOL,
      "the registered inner Monte Carlo error has no stated method")
check("the knot count reaches both bases from one place",
      "`N_KNOTS` in `R/00-config.R` and reaches both bases from there" in PROTOCOL,
      'the "for both bases" claim is not enforced by construction')

# The header cites how many assertions guard the document, so that number has to
# be the number that ran. `checks + 1` counts this check itself, so the figure in
# the header is the same figure this script prints on its last line.
_claimed = re.search(r"\*\*(\d+)\*\* assertions", PROTOCOL)
check("stated assertion count matches the count that ran",
      _claimed is not None and int(_claimed.group(1)) == checks + 1,
      f"{checks + 1} assertions ran, the protocol claims "
      f"{_claimed.group(1) if _claimed else 'none'}")

print(f"{checks - len(fails)}/{checks} protocol assertions passed")
for f in fails:
    print(f"  FAIL {f}")
sys.exit(1 if fails else 0)
