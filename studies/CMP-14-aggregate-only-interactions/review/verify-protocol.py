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
    "The candidate statistic is post hoc in both of its forms")
# The candidate's forms must be NAMED, not counted. The previous version of this
# assertion required the phrase "in all three of its forms" while no third form
# was ever defined anywhere, so the guard was certifying a count the document
# could not support.
check("both forms of the candidate are named where the count is claimed",
      "`surv_between` and `surv_sd`, defined" in PROTOCOL,
      "the forms are counted but not named")

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
    f"`COVER_BAD = {DESIGN['cover_bad']:.2f}`",
    f"`COVER_TOL = {DESIGN['cover_tol']:.2f}`",
    f"`PRIOR_SD_NUISANCE = {DESIGN['prior_sd_nuisance']:.0f}`")
# ROUND 7: A THRESHOLD LIST IS NOT A DECISION RULE. The document named three
# cutoffs without saying which rule each governs or which side alarms, and with
# two rank summaries sharing one named threshold. Each is now a table row
# carrying its rule, its inequality and its value, and this checks all three.
_TH = table_after("| rule | alarms when | threshold | why that value |")
check("the threshold table is present", len(_TH) == 5, f"{len(_TH)} rows")
_want_th = [("contraction", "$\\ge$ `CONTRACT_OK`", f"{DESIGN['contract_ok']:.2f}"),
            ("target_ratio", "$<$ `EFF_RATIO_OK`", f"{DESIGN['eff_ratio_ok']:.2f}"),
            ("eff_rank", "$<$ the parameter count", "none"),
            ("rank_screen", "not estimable", "none"),
            ("source_survival", "$<$ `SOURCE_OK`", f"{DESIGN['source_ok']:.2f}")]
for i, (rule, direction, value) in enumerate(_want_th):
    if i >= len(_TH):
        break
    row = _TH[i]
    check(f"threshold row {rule} names its rule", f"`{rule}`" in row, f"{row!r}")
    check(f"threshold row {rule} states its alarm direction",
          direction in row, f"{row!r}")
    check(f"threshold row {rule} states its value", value in row, f"{row!r}")
# ROUND 8: THIS GUARD, WRITTEN IN ROUND 7, PINNED A FALSE CLAIM. It required the
# document to say EFF_RATIO_OK governs `target_ratio` only, and `eff_rank()`
# takes that constant as its eigenvalue cutoff in both callers, so the sentence
# the guard demanded was untrue. That is the EIGHTH assertion in this study to
# hold a wrong statement in place by requiring a phrase, and the first written in
# the same session that later had to withdraw it. The check now states the
# relationship that holds.
check("the shared cutoff is described as shared",
      "is the one \"likelihood outweighs prior\" cutoff and both rank summaries use it"
      in PROTOCOL,
      "the document still denies that eff_rank uses EFF_RATIO_OK")
check("the eff_rank warning is described as comparing to the parameter count",
      "compares that count to the parameter\ncount $p$" in RAW,
      "the eff_rank rule's own comparison is not stated")

# --- round 8's own numbers, bound to the export ------------------------------
_pc = DESIGN["pairs_close"]; _pd = DESIGN["pairs_close_same_display"]
check("the display-agreement count matches the export",
      f"**{_pd} of the\n{_pc}**" in RAW, f"export says {_pd} of {_pc}")
check("the worst pair's contractions match the export",
      f"**{DESIGN['pairs_worst_contractions'][0]} and "
      f"{DESIGN['pairs_worst_contractions'][1]}**" in PROTOCOL,
      f"export says {DESIGN['pairs_worst_contractions']}")
check("the document admits the worst pair does not display identically",
      DESIGN["pairs_worst_displays_same"] is False
      and "is not among them" in PROTOCOL,
      "the worst pair's display status is misstated")
check("both maximum coverage gaps are stated",
      f"**{DESIGN['pairs_close_same_display_max_cover_gap']}**" in PROTOCOL
      and f"**{DESIGN['pairs_close_max_cover_gap']}**" in PROTOCOL,
      "only one of the two readings is reported")
check("the effective-rank change under the comparator is stated",
      f"**{DESIGN['contraction_gap']['eff_rank_changed']} of the 72 scenarios change their count "
      f"and {DESIGN['contraction_gap']['eff_rank_warn_flips']} flip" in PROTOCOL,
      f"export says {DESIGN['contraction_gap'].get('eff_rank_changed')} changed, "
      f"{DESIGN['contraction_gap'].get('eff_rank_warn_flips')} flipped")
_ovs = [o for o in DESIGN["overlap"] if o["statistic"] == "surv_between"][0]
_wrs = [w for w in DESIGN["warnings"] if w["rule"] == "source_survival"][0]
check("the undefined-survival exclusions match the export",
      f"on {_ovs['n_compared']} scenarios with **{_ovs['n_undefined']}** excluded" in PROTOCOL
      and f"**{_wrs['n_undefined']}** excluded" in PROTOCOL,
      f"export says {_ovs['n_undefined']} and {_wrs['n_undefined']}")
check("no reported statistic silently substitutes a value for an undefined one",
      all("n_undefined" in o for o in DESIGN["overlap"])
      and all("n_undefined" in w for w in DESIGN["warnings"]),
      "an outcome does not report how many rows it dropped")
check("the E2 candidate outputs carry a standing",
      DESIGN["e2_candidate_standing"] == "post-hoc-candidate"
      and all("standing" in r for r in DESIGN["e2_rules"]),
      "an E2 candidate output is exported without its standing")

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
# THIS ASSERTION USED TO REQUIRE THE RESTRICTION IT NOW FORBIDS. It demanded the
# phrase "only where the model is correctly specified", which round 6 showed was
# a restriction resting on a premise that never held: both departures are exactly
# a shift of the target coefficient, so nothing in E2 is misspecified. That makes
# three guards in this study that pinned a wrong claim in place. The check now
# asserts the aliasing result and its measured evidence instead.
check("E2 reports coverage on every scenario",
      f"coverage is reported on all {DESIGN['e2_n_scenarios']} scenarios"
      in PROTOCOL and DESIGN["e2_n_covered"] == DESIGN["e2_n_scenarios"],
      f"{DESIGN['e2_n_covered']} of {DESIGN['e2_n_scenarios']} carry coverage")
check("the aliased-scenario count matches the export",
      f"**{DESIGN['e2_n_aliased']} scenarios gain a coverage figure" in PROTOCOL,
      f"export says {DESIGN['e2_n_aliased']}")
check("the measured aliasing gap is stated and is within tolerance",
      f"{DESIGN['e2_alias_gap_max']:g}" in PROTOCOL.replace("e-16", "e-16")
      and DESIGN["e2_alias_gap_max"] < 1e-12,
      f"export says {DESIGN['e2_alias_gap_max']:g}")
check("the aliasing assertion is pointwise, not on the arm mean",
      "pointwise in the covariate" in PROTOCOL,
      "an arm-mean check would not cover the individual-data rows")
# This assertion used to require the protocol to SAY "contraction of a Laplace
# approximation", so the verifier was enforcing the mislabel: correcting the
# document would have failed the check and the failure would have looked like a
# regression. A guard that pins a wrong description in place is worse than no
# guard, and it is the second one in this study to behave that way. It now
# requires the approximation to be named, whichever name is right; the assertions
# near the end of this file check that the name is the correct one.
check("E2's contraction names the approximation it uses",
      "normal approximation whose covariance is" in PROTOCOL,
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
# ROUND 6: THE BLANKET CLAIM WAS FALSE OF ONE DIAGNOSTIC. "Every precision here
# is prior-free" scoped all of section 5, but `contraction` is a posterior SD
# over a prior SD and uses (I + P0)^{-1} by construction. The claim now scopes
# the ratios and states the exception, and this checks both halves.
check("the prior-free claim is scoped to the ratios",
      "Every precision *entering the ratios* is prior-free" in PROTOCOL,
      "the prior contamination fix is not stated")
check("contraction is excepted from the prior-free claim",
      "**`contraction` is the exception and is not a prior-free quantity**"
      in PROTOCOL,
      "contraction is still covered by a claim that is false of it")

# --- the estimand -------------------------------------------------------------
check("the estimand is not presented as a model parameter",
      "not a separate model parameter" in PROTOCOL
      and "carries **one** $\\Gamma$ per" in PROTOCOL,
      "the estimand still implies the model splits within from between")

# --- ROUND 8 SELF-AUDIT: ROUND 7'S OWN REPAIRS -------------------------------
# Round 7's worst finding was a table added in round 6 whose values were TYPED
# rather than read from the code, and which stated a data-generating truth the
# simulation had never used. Six of round 7's own additions were exported and
# asserted by nothing, and one was not exported at all, which is the same disease
# one round later. Each is now bound to the export.

check("primary 2's tolerance is the registered one",
      f"`PAIRS_CLOSE_TOL = {DESIGN['pairs_close_tol']:.2f}`" in PROTOCOL,
      f"config says {DESIGN['pairs_close_tol']}")

# The true values, every entry, against theta_true() as the exporter read it.
_tv = DESIGN["true_values"]
check("the interactions are all one value, as the table claims",
      _tv["gamma_all_equal"] is True, f"gamma = {_tv['gamma']}")
check("the stated interaction value is the exported one",
      f"target and background alike | **{_tv['gamma_target']}** |" in PROTOCOL,
      f"export says {_tv['gamma_target']}")
check("the stated main effect is the exported one",
      f"| $-{abs(_tv['delta_main'])}$ |" in PROTOCOL,
      f"export says {_tv['delta_main']}")
check("the stated prognostic slope is the exported one",
      f"the prognostic slope | {_tv['beta_prog']} |" in PROTOCOL,
      f"export says {_tv['beta_prog']}")
check("the stated E2 intercept is the exported one",
      f"= {_tv['e2_study_intercept']}$ |" in PROTOCOL,
      f"export says {_tv['e2_study_intercept']}")
check("sigma is registered as known",
      _tv["sigma_known"] is True and "$\\sigma^2$ is fixed and known" in PROTOCOL,
      "the document does not register sigma as known")

# The arm map. The document's table was hand-written; these bind every cell of it
# to what R/06-nonlinear.R actually built, including `absent`, which was missing
# from the table until round 7 and is the state whose geometry is least obvious.
_am = DESIGN["arm_map"]
_bg = sorted({r["arms"] for r in _am if r["role"] == "background"})
check("the background arms in the document are the ones built",
      all(f"`{a}`" in PROTOCOL for a in _bg), f"built {_bg}")
check("every background study supplies IPD and carries no target",
      all(r["ipd"] and not r["carries_target"]
          for r in _am if r["role"] == "background"),
      "a background study leaks the target or is aggregate")
for _st, _cell in [("own_ipd", "IPD, `PBO, 1, 3`"),
                   ("additivity", "IPD, `PBO, 1, 1+3`"),
                   ("absent", "IPD, `PBO, 1, 2`")]:
    _rows = [r for r in _am if r["state"] == _st and r["role"] == "target"]
    check(f"the {_st} target arms in the document match the build",
          _cell in PROTOCOL and all(r["arms"] == _cell.split("`")[1]
                                    for r in _rows) and len(_rows) == 2,
          f"built {[r['arms'] for r in _rows]}")
check("the aggregate-only states are aggregate on the target in the build",
      all(not r["ipd"] for r in _am
          if r["state"] in ("ecological", "curvature") and r["role"] == "target"),
      "an aggregate-only state supplies target IPD")
_WORDS = ["zero", "one", "two", "three", "four", "five", "six", "seven",
          "eight", "nine", "ten", "eleven", "twelve"]
_nbg = DESIGN["arm_map_n_background_arms"] // len(DESIGN["e2_states"])
check("the document states the background arm count the build produced",
      f"two arms each, {_WORDS[_nbg]} arms in" in PROTOCOL,
      f"build gives {_nbg}")

# E2's primary 3, which round 7 added because the single pooled rho was E1's.
_a2 = DESIGN["e2_anticorrelation_pooled"]
_a1 = DESIGN["anticorrelation_pooled"]
check("the E2 primary-3 row matches the export",
      f"| **E2** | {_a2['n_scenarios']} | "
      f"**{_a2['rho_contraction_vs_coverage']:.4f}** |" in PROTOCOL,
      f"export says n={_a2['n_scenarios']}, rho={_a2['rho_contraction_vs_coverage']}")
check("the E1 primary-3 row matches the export",
      f"| {_a1['n_scenarios']} | **{_a1['rho_contraction_vs_coverage']:.4f}** |"
      in PROTOCOL,
      f"export says n={_a1['n_scenarios']}, rho={_a1['rho_contraction_vs_coverage']}")
check("the document says the two arms disagree, since they do",
      (_a1["contraction_inverted"] != _a2["contraction_inverted"])
      == ("**The two arms disagree" in PROTOCOL),
      "the disagreement claim does not match the exported signs")

# The nuisance-prior rule, which round 7 rewrote to compare decisions.
_nf = DESIGN["nuisance_flips"]
check("the decision count is the exported one",
      f"**{DESIGN['nuisance_n_decisions']:,}** binary" in PROTOCOL,
      f"export says {DESIGN['nuisance_n_decisions']}")
check("the flip counts are the exported ones",
      f"**{_nf['lo']} flip at scale 3 and {_nf['hi']} at scale 30.**" in PROTOCOL,
      f"export says {_nf}")
check("the inertness claim is only made because nothing flipped",
      (_nf["lo"] == 0 and _nf["hi"] == 0)
      == ("moves nothing this study decides on" in PROTOCOL),
      "the claim survives a nonzero flip count")

# The standing field, which round 7 added so a post hoc row carries its status.
check("every reported statistic carries a standing",
      all("standing" in o for o in DESIGN["overlap"])
      and all("standing" in w for w in DESIGN["warnings"]),
      "a row is exported without its standing")
check("the candidate is marked post hoc in the exported rows",
      all(o["standing"] == "post-hoc-candidate"
          for o in DESIGN["overlap"] if o["statistic"] == "surv_between")
      and all(w["standing"] == "post-hoc-candidate"
              for w in DESIGN["warnings"] if w["rule"] == "source_survival"),
      "the candidate is packaged as a registered summary")
check("the CMP-14 summaries are marked as such",
      {o["standing"] for o in DESIGN["overlap"]
       if o["statistic"] in ("contraction", "target_ratio", "eff_rank")}
      == {"cmp14-summary"},
      "a CMP-14 summary carries the wrong standing")

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

# THE HEADLINE FINDING COUNT MUST BE THE TABLE'S OWN SUM. It said 45 while the
# table summed to 85, with no stated deduplication, so the document's provenance
# claim did not survive its own arithmetic. The total is now computed from the
# table in both files rather than typed into either.
_rows = re.findall(r"^\| (\d) \| (\w+) \| [\w-]+ \| (\d+) \| (\d+) \|$",
                   (ROOT / "CHANGES.md").read_text(), re.M)
check("the reviewer table parses", len(_rows) >= 6, f"{len(_rows)} rows")
_total = sum(int(f) + int(s) for _, _, f, s in _rows)
_rounds = len({r[0] for r in _rows})
check("the history's finding total is the table's sum",
      f"returned **{_total} fatal and serious findings**" in CHANGES,
      f"the table sums to {_total}")
check("the protocol's finding total is the same number",
      f"**{_total}** fatal and serious findings" in PROTOCOL,
      f"the table sums to {_total}")
check("both documents agree on the round count",
      f"{['','one','two','three','four','five','six','seven'][_rounds]} rounds "
      f"of critique returned" in PROTOCOL.lower(),
      f"the table covers {_rounds} rounds")
check("the total is labeled as counted-as-returned, not deduplicated",
      "counted as returned rather than" in PROTOCOL,
      "a raw sum is presented as a count of distinct defects")

# THE HISTORY'S NUMBERS WENT STALE BECAUSE NOTHING ASSERTED THEM. The protocol's
# figures were checked cell by cell against the export and the history's were
# not, so three control justifications in CHANGES.md still described the
# pre-arm-geometry run. A justification nobody can reproduce is not one.
_tr = DESIGN["control_tight_recovery"]
check("the history's tight-prior recovery figures match the export",
      all(f"{v:.3f} in `{k}`" in CHANGES for k, v in _tr.items()),
      f"export says {_tr}")
_tb = DESIGN["control_tight_bias"]
_informed = {k: v for k, v in _tb.items() if k != "absent"}
check("the history's tight-prior bias figures match the export",
      all(f"$-{abs(v):.3f}$ in `{k}`" in CHANGES for k, v in _informed.items()),
      f"export says {_informed}")
check("the history's bias spread matches the export",
      f"a spread of {max(_informed.values()) - min(_informed.values()):.3f}"
      in CHANGES,
      f"export spread {max(_informed.values()) - min(_informed.values()):.3f}")
_no = DESIGN["control_null_over_range"]
check("the history's overcoverage count and range match the export",
      f"{DESIGN['control_null_n_over']} scenarios overcover at "
      f"{_no[0]:.3f} to {_no[1]:.3f}" in CHANGES.replace("four", "4"),
      f"export says {DESIGN['control_null_n_over']} at {_no}")

# --- the contraction gap, which used to be an admission -----------------------
# The protocol called E2's contraction a Laplace approximation and then said the
# gap was bounded by nothing measured here. Both are now wrong to say, so both
# are asserted against: the label must not have come back, and the four numbers
# must match the export.
_cg = DESIGN["contraction_gap"]
check("the Laplace mislabel has not returned",
      "contraction of a Laplace approximation" not in PROTOCOL,
      "the protocol calls the quantity a Laplace approximation again")
# ROUND 7: THIS GUARD REQUIRED THE FORMULA THE CODE HAD STOPPED USING. It asked
# for I(theta_true) + P0 while `evaluate_e2` evaluates at theta*, so the sixth
# phrase-pinning assertion in this study was holding a stale formula in place.
check("the protocol names the quantity actually computed",
      "I(\\theta^{*}) + P_0" in PROTOCOL
      and "at the parameter the data come\nfrom" in RAW,
      "the normal-approximation covariance is not stated at theta*")
check("the stale theta_true covariance formula is gone as a standing claim",
      "$(I(\\theta_{\\text{true}}) + P_0)^{-1}$**" not in PROTOCOL,
      "the withdrawn formula is still asserted")
check("the unmeasured-gap admission is gone",
      "bounded by nothing measured here" not in PROTOCOL,
      "the admission survived the measurement that replaced it")
check("contraction-gap scenario count matches the export",
      f"all {_cg['n_scenarios']} scenarios" in PROTOCOL,
      f"export says {_cg['n_scenarios']}")
check("the contraction gap covers the whole E2 grid",
      _cg["n_scenarios"] == DESIGN["e2_n_scenarios"],
      f"gap ran on {_cg['n_scenarios']} of {DESIGN['e2_n_scenarios']} scenarios")
check("contraction-gap maximum absolute difference matches the export",
      f"{_cg['max_abs']:.4f}" in PROTOCOL, f"export says {_cg['max_abs']:.4f}")
check("contraction-gap median matches the export",
      f"{_cg['median_abs']:.5f}" in PROTOCOL,
      f"export says {_cg['median_abs']:.5f}")
check("contraction-gap maximum relative difference matches the export",
      f"{_cg['max_rel_pct']:.2f}%" in PROTOCOL,
      f"export says {_cg['max_rel_pct']:.2f}%")

# --- placebo prevalence, and the intercept-versus-prevalence distinction ------
# The document said placebo arms sit at prevalence 0.3, which is true nowhere:
# alpha is set so the CONDITIONAL risk at x = 0 is 0.3, and the arm-level value
# integrates the covariate distribution through expit. The consequence is that
# the curvature state's equal-baseline restriction holds on intercepts and fails
# on prevalences, so the document has to say which.
#
# The withdrawn wording is quoted in the sentence that withdraws it, so a plain
# "not in PROTOCOL" test fails on the correction itself; that shape of guard has
# now enforced a wrong claim twice in this study. This one instead requires the
# phrase to appear exactly once and only inside the withdrawal, which still
# catches it being reinstated as a standing claim.
_flat = " ".join(PROTOCOL.split())
_withdrawn = "placebo arms sit at prevalence 0.3"
check("the withdrawn placebo-prevalence claim survives only as a withdrawal",
      _flat.count(_withdrawn) == 1
      and f"An earlier version of this document said {_withdrawn}, which is "
          "true nowhere" in _flat,
      "the withdrawn claim appears outside the sentence that withdraws it")
check("the document states the conditional risk at x = 0",
      f"conditional placebo risk at $x = 0$ is {DESIGN['e2_base_p']}" in PROTOCOL,
      "the conditional-risk definition is missing or does not match E2_BASE_P")
check("the arm-prevalence range matches the export",
      f"{DESIGN['pbo_prev_min']:.4f} to {DESIGN['pbo_prev_max']:.4f}" in PROTOCOL,
      f"export says {DESIGN['pbo_prev_min']:.4f} to {DESIGN['pbo_prev_max']:.4f}")
check("the curvature target prevalences match the export",
      "{:.4f} against {:.4f}".format(*DESIGN["curv_pbo_prev"]) in PROTOCOL,
      "export says {:.4f} against {:.4f}".format(*DESIGN["curv_pbo_prev"]))
check("the exported arm prevalences bracket the curvature pair",
      DESIGN["pbo_prev_min"] <= min(DESIGN["curv_pbo_prev"])
      and max(DESIGN["curv_pbo_prev"]) <= DESIGN["pbo_prev_max"],
      "the curvature values are outside the range the same run reported")
check("no exported placebo arm prevalence equals the conditional risk",
      DESIGN["pbo_prev_min"] != DESIGN["e2_base_p"]
      and DESIGN["pbo_prev_max"] != DESIGN["e2_base_p"],
      "an arm sits at E2_BASE_P, so the distinction the section draws is empty")
check("the document says baseline means the intercept",
      "means the study intercept" in PROTOCOL,
      "the intercept-versus-prevalence distinction is not drawn")

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
