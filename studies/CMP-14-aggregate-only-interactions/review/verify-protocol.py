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

# ROUND 9: THE EXPORTER IS NO LONGER EXCLUDED. It was, on the reasoning that it
# consumes artifacts rather than producing them; that stopped being true when it
# began COMPUTING values, the E2 overlap result and the true-values vector among
# them. Editing it after the JSON was written would have left a stale export that
# all assertions still ran against. R/05-export.R excludes ITSELF from the
# artifact check for the original reason, which is unaffected: rerunning it is
# what refreshes the JSON, so the JSON is always newer than the file that wrote
# it and this check costs one cheap rerun rather than a full experiment chain.
_newest_code = max(f.stat().st_mtime for f in (ROOT / "R").iterdir()
                   if f.is_file())
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
    "pairs_close_max_cover_gap", "e2_rules", "e2_any_state_separation", "curvature_rank",
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
      f"**{_pd} of E1's\n{_pc}**" in RAW, f"export says {_pd} of {_pc}")
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
# ROUND 9: THESE EXPECTATIONS WERE HARDCODED. The route taxonomy is the thesis's
# foundation and the verifier asserted the document against a constant written
# beside it, so a change in `R/08-routes.R` would have left both agreeing and
# both wrong. They now come from the run.
_want = [(lab, r["identity"], r["logit"])
         for lab, r in zip(("none", "means", "SDs", "risks"), DESIGN["routes"])]
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
      f"{DESIGN['e2_alias_gap_max']:g}" in PROTOCOL
      and DESIGN["e2_alias_gap_max"] < DESIGN["e2_alias_tol"],
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
      and DESIGN["e2_any_state_separation"] is False,
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
      f"**{DESIGN['nuisance_n_decisions']:,} hold a decision**" in PROTOCOL,
      f"export says {DESIGN['nuisance_n_decisions']}")
def _tex_int(n: int) -> str:
    """LaTeX thousands separator, e.g. 3456 -> 3{,}456."""
    return f"{n:,}".replace(",", "{,}")


_slots = DESIGN["n_scenarios"] * 7
check("the undefined slots are counted, not folded into the denominator",
      f"${_tex_int(_slots)} - {DESIGN['nuisance_n_undefined']} = "
      f"{_tex_int(DESIGN['nuisance_n_decisions'])}$" in PROTOCOL
      and DESIGN["nuisance_n_decisions"] + DESIGN["nuisance_n_undefined"] == _slots,
      f"{DESIGN['nuisance_n_decisions']} + {DESIGN['nuisance_n_undefined']} "
      f"against {_slots}")

# --- round 9: what the round-8 repairs left undone ---------------------------
check("the state-separation field is named for what it tests",
      "e2_any_state_separation" in DESIGN
      and "`any_state_separation` for what it tests" in PROTOCOL,
      "the software still names a withdrawal criterion it cannot apply")
# ROUND 10: THIS ASSERTION REWROTE THE DOCUMENT TO MAKE ITSELF PASS. It called
# PROTOCOL.replace("1.06e-15", <exported value>) and then tested that the
# exported value was present, so it succeeded by construction while the document
# said 1.06e-15 and the artifact said 1.05e-15. A guard that edits its own input
# is worse than a guard that pins a phrase: the phrase-pinning ones at least
# failed loudly when the document changed. Plain membership, no substitution.
check("E1's aliasing gaps come from a guard, not from prose",
      f"**{DESIGN['e1_alias_bias_gap']:.3g}**" in PROTOCOL
      and DESIGN["e1_alias_n_pointwise"] == DESIGN["n_scenarios"],
      f"export says {DESIGN['e1_alias_bias_gap']:.3g} and "
      f"{DESIGN['e1_alias_pointwise_gap']:.3g}")
# Its own pattern literal is skipped, or the guard reports itself forever.
# Comments are skipped too: the removed defect is documented above by quoting
# the call that caused it, and a guard that cannot tell code from prose would
# forbid describing what it forbids.
_self = [ln for ln in Path(__file__).read_text().splitlines()
         if "_PAT_SELF" not in ln and not ln.lstrip().startswith("#")]
_PAT_SELF = r"(?:PROTOCOL|RAW|CHANGES)\.replace\("
_subs = [ln for ln in _self if re.search(_PAT_SELF, ln)]
check("no assertion in this file rewrites its input before testing it",
      len(_subs) == 0,
      f"{len(_subs)} substitution(s): {_subs[:1]}")
check("the pointwise check covers the whole E1 grid",
      f"pointwise to **{DESIGN['e1_alias_pointwise_gap']:.3g}**, **both over all "
      f"{DESIGN['e1_alias_n_pointwise']} E1 scenarios**" in PROTOCOL,
      f"export says {DESIGN['e1_alias_pointwise_gap']:.3g} over "
      f"{DESIGN['e1_alias_n_pointwise']}")
check("the route table is exported rather than hardcoded in this file",
      "routes" in DESIGN and len(DESIGN["routes"]) == 4,
      "the taxonomy is still asserted against a constant")
check("every E2 state row carries the candidate's standing",
      all(z.get("candidate_standing") == "post-hoc-candidate"
          for z in DESIGN["e2_by_state"].values()),
      "an E2 row reports a candidate value without its standing")
_reviewers = set(re.findall(r"^\| \d+ \| (\w+) \| [\w*-]+ \| \d+ \| \d+ \|$",
                           (ROOT / "CHANGES.md").read_text(), re.M))
check("the reviewer count in the header matches the table",
      f"between **{len(_reviewers)}** reviewers" in PROTOCOL,
      f"the table names {sorted(_reviewers)}")
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

# --- round 8's second reviewer: the bridge between the arms -------------------
check("the central negative result is scoped to the registered statistics",
      "or on the estimability screen\nseparates failing coverage" in RAW
      and "The candidate overlaps too and is not part of the claim" in PROTOCOL,
      "the post hoc candidate is inside the central claim")
check("the aliasing checks cover the same grid",
      DESIGN["e1_alias_n_bias"] == DESIGN["e1_alias_n_pointwise"] == DESIGN["n_scenarios"],
      f"bias over {DESIGN['e1_alias_n_bias']}, pointwise over "
      f"{DESIGN['e1_alias_n_pointwise']}, grid {DESIGN['n_scenarios']}")
check("primary 1 is answered, not only defined",
      "every statistic overlaps, on both arms" in PROTOCOL,
      "the outcomes section defines primary 1 without stating its answer")
check("the E2 overlap claim matches the export",
      DESIGN["e2_overlap_all"] is True
      and "**Every statistic overlaps on E2 as well**" in PROTOCOL,
      f"export says all-overlap is {DESIGN['e2_overlap_all']}")
_e2o = DESIGN["e2_overlap"][0]
check("the E2 comparison-set sizes match the export",
      f"**{_e2o['n_failed']} failing and {_e2o['n_nominal']} nominal**" in PROTOCOL,
      f"export says {_e2o['n_failed']} and {_e2o['n_nominal']}")
check("state separation is not called a withdrawal criterion for E1",
      "state separation is not E1's conclusion" in PROTOCOL,
      "the six comparisons are still presented as withdrawing a primary")
check("primary 2 states its measured gap rather than claiming arbitrariness",
      "**about that much**" in PROTOCOL
      and f"**On E1 that is {DESIGN['pairs_close_max_cover_gap']}**" in PROTOCOL,
      "primary 2 claims more than a finite maximum can support")
check("primary 2 says whether discordance is a matching key",
      "Discordance\nis deliberately NOT a matching key" in RAW,
      "the pairing rule leaves discordance unspecified")
check("the Laplace gap is not offered as a bound on non-Gaussianity",
      "bounds the choice of Gaussian; it does\n  not bound Gaussianity" in RAW,
      "the wrong reference quantity is offered as the caveat")
check("E1's own aliasing measurement is cited, not E2's",
      "E1's version is established separately" in PROTOCOL,
      "an E1 claim rests on an E2-only measurement")
check("synergy is described as interaction-shaped",
      "interaction-shaped rather than a main-effect offset" in PROTOCOL,
      "synergy is described as an add-on that could not alias")

# The 28 must be the cell count, not 72 minus 44, and the middle band's alarm
# rate must be what makes the false-alarm direction possible. Both were claimed
# in prose after round 8 and both are now computed.
_e2g = DESIGN["e2_grid"]
_sp = DESIGN["e2_departure_split"]
check("the aliased-scenario count is the sum of its cells",
      DESIGN["e2_n_aliased"] == sum(_sp.values())
      and f"${_sp['ecological']} + {_sp['curvature']} + {_sp['additivity']} = "
          f"{DESIGN['e2_n_aliased']}$" in PROTOCOL,
      f"export says {_sp}")
check("the departure split names each state's own count",
      f"It is {_sp['ecological']} `ecological` and {_sp['curvature']} `curvature`"
      in PROTOCOL,
      f"export says {_sp}")
check("the E2 grid total is the sum of its per-state counts",
      sum(DESIGN["e2_by_state_n"].values()) == DESIGN["e2_n_scenarios"],
      f"{DESIGN['e2_by_state_n']} against {DESIGN['e2_n_scenarios']}")
_wc = [w for w in DESIGN["warnings"] if w["rule"] == "contraction"][0]
check("the middle band's alarm rate explains the false-alarm direction",
      _wc["false_alarm_vs_not_failed"] > _wc["false_alarm"]
      and "71 of the 84" in PROTOCOL,
      f"old {_wc['false_alarm_vs_not_failed']}, new {_wc['false_alarm']}")
check("the strata are labeled with the arm they come from",
      "**on E1**, 0.2232 at discordance 0.15" in PROTOCOL,
      "the E1 strata could be read as an E2 registration")

check("primary 2's E1 numbers are labeled with their arm",
      f"**On E1 that is {DESIGN['pairs_close_max_cover_gap']}**" in PROTOCOL,
      "a primary-2 number is reported without an arm")
check("primary 2 on E2 is reported, not merely asserted to run",
      f"**{DESIGN['e2_pairs_close']}** is close, with a coverage gap of "
      f"**{DESIGN['e2_pairs_close_max_cover_gap']}**" in PROTOCOL,
      f"export says {DESIGN['e2_pairs_close']} of {DESIGN['e2_pairs_total']}")
check("the reproduction summary covers all three primaries",
      "**One of three reproduces, one is" in PROTOCOL,
      "section 9 does not say which primaries reproduce")
check("no passage still says the six comparisons withdraw E1's conclusion",
      "withdraw E1's conclusion" not in PROTOCOL,
      "the revoked criterion is still asserted somewhere")
check("the stated-once claim is stated as an aim, not a guarantee",
      "intended to be stated once" in PROTOCOL,
      "the document claims a property round 9 disproved")

# --- round 10: what round 9 left, all of it in the round-9 repairs -----------
_w2 = {x["rule"]: x for x in DESIGN["e2_warnings"]}
check("the secondary outcomes exist on E2, not only E1",
      len(_w2) == 5 and f"| {_w2['contraction']['youden']} |" in PROTOCOL,
      f"E2 warnings: {sorted(_w2)}")
check("the E2 secondary is reported with the sample it rests on",
      f"only {_w2['contraction']['n_nominal']} nominal scenarios" in PROTOCOL,
      "a false-alarm rate of zero is reported without its denominator")
check("primary 2 on E2 is called a computed number with the wrong pair",
      "That is a computed number, not a missing one" in PROTOCOL
      and f"**{DESIGN['e2_pairs_close_max_cover_gap']}**" in PROTOCOL,
      f"export says gap {DESIGN['e2_pairs_close_max_cover_gap']}")
check("the aliasing tolerance is the registered constant",
      f"`E2_ALIAS_TOL` of {DESIGN['e2_alias_tol']:g}" in PROTOCOL
      and DESIGN["e2_alias_gap_max"] < DESIGN["e2_alias_tol"],
      f"config says {DESIGN['e2_alias_tol']}")
check("the truth-table counterfactual is computed and matches the export",
      f"by up to **{DESIGN['truth_cf_max_coverage_change']}** and reclassifies "
      f"**{DESIGN['truth_cf_n_reclassified']} of\n{DESIGN['truth_cf_n_scenarios']}**" in RAW,
      f"export says {DESIGN['truth_cf_max_coverage_change']}, "
      f"{DESIGN['truth_cf_n_reclassified']}")
_lb = "at least that much"
check("primary 2's maximum is not presented as a lower bound",
      "about that much" in PROTOCOL
      and PROTOCOL.count(_lb) == 1
      and f'"{_lb}" was\nfalse by' in RAW,
      "a rounded maximum is claimed as a bound outside the withdrawal")

# --- round 11 -----------------------------------------------------------------
check("the covariate law is registered, not assumed",
      "The covariate is Normal within each study" in PROTOCOL
      and "64-point Gauss-Hermite quadrature" in PROTOCOL,
      "E2's aggregate integral rests on an unstated distribution")
check("section 9 carries the distributional conditioning",
      "conditional on normality" in PROTOCOL,
      "the covariate assumption is registered but not limited")
check("primary 2 on E2 says its close pair carries no confounding",
      DESIGN["e2_pairs_close_n_confounded"] == 0
      and "**But its\ndiscordance is zero**" in RAW
      and "no close confounded\npair**" in RAW,
      f"export says {DESIGN['e2_pairs_close_n_confounded']} confounded close pairs")
check("E1 does have close confounded pairs, so the contrast is real there",
      DESIGN["e1_pairs_close_n_confounded"] > 0,
      "E1's primary 2 also rests on unconfounded pairs")
check("the reproduction summary says primary 2 cannot be asked on E2",
      "one is\n  unanswerable on E2's grid" in RAW,
      "the summary still claims primary 2 fails to reproduce")
_ss = [x for x in DESIGN["e2_warnings"] if x["rule"] == "source_survival"][0]
check("the candidate's E2 denominator is distinguished from the others'",
      f"**the\ncandidate rests on {_ss['n_failed']} failing**" in RAW,
      f"export says {_ss['n_failed']} failing for the candidate")
check("the E2 secondary table carries standing on every row",
      "| `source_survival` | **post hoc** |" in PROTOCOL
      and "| rule | standing | E1 Youden |" in PROTOCOL,
      "the candidate row is packaged like a registered summary")
# The table is parsed later in this file; the round count is needed here, so it
# is read from CHANGES.md directly rather than reordering the checks.
_max_round = max(int(m) for m in re.findall(
    r"^\| (\d+) \| \w+ \| [\w*-]+ \| \d+ \| \d+ \|$",
    (ROOT / "CHANGES.md").read_text(), re.M))
check("the reviewer-provenance sentence is current",
      f"reviewed in\nrounds 8 through {_max_round}" in RAW,
      f"the account of who reviewed when is stale ({_max_round} rounds recorded)")

check("primary 1's structural leg is named as such",
      "half structural, and saying exactly how narrows the claim" in PROTOCOL
      and "no nominal scenario is\never non-estimable**" in RAW,
      "rank_screen's leg is presented as evidence")
check("the E2 secondary claim is scoped to the rules it holds for",
      "the three CMP-14 summaries perform far better" in PROTOCOL
      and "The candidate improves far less" in PROTOCOL,
      "a blanket superiority claim the table contradicts")
check("the strata agreement is called measured, not asserted",
      "That agreement is **measured**" in PROTOCOL,
      "a measurement is described as an assertion")
_e2n = DESIGN["e2_n_scenarios"]
_w0 = DESIGN["e2_warnings"][0]
check("E2's three classes are accounted for and sum to its grid",
      f"{_w0['n_failed']} failing, {_w0['n_nominal']} nominal and {_w0['n_neither']} neither"
      in PROTOCOL
      and _w0["n_failed"] + _w0["n_nominal"] + _w0["n_neither"] == _e2n,
      f"{_w0['n_failed']}+{_w0['n_nominal']}+{_w0['n_neither']} against {_e2n}")

# --- round 12: the secondary table, cell by cell -----------------------------
# ROUND 12 FOUND A STALE E1 YOUDEN IN THIS TABLE, and it reversed the sentence
# beside it. The E1 column had been typed while only the E2 column was asserted,
# which is the same one-side-only shape as the route table's hardcoded rows.
# Every cell of both columns is checked now.
_E1W = {x["rule"]: x for x in DESIGN["warnings"]}
_E2W = {x["rule"]: x for x in DESIGN["e2_warnings"]}
_SEC = table_after("| rule | standing | E1 Youden | E2 Youden | E2 sensitivity | E2 false alarm |")
check("the secondary table has one row per registered rule",
      len(_SEC) == len(DESIGN["diagnostics"]), f"{len(_SEC)} rows")
for _row in _SEC:
    _c = [x.strip() for x in _row.split("|")]
    _r = _c[1].strip("`")
    check(f"secondary row {_r} matches the export",
          _r in _E1W and _c[3] == str(_E1W[_r]["youden"])
          and _c[4] == str(_E2W[_r]["youden"])
          and _c[5] == str(_E2W[_r]["sensitivity"])
          and _c[6].split()[0] == str(_E2W[_r]["false_alarm"]),
          f"row {_c[1:7]} against E1 {_E1W.get(_r, {}).get('youden')} "
          f"E2 {_E2W.get(_r, {}).get('youden')}")
check("the candidate's cross-arm direction matches the export",
      (_E2W["source_survival"]["youden"] > _E1W["source_survival"]["youden"])
      == ("The candidate improves far less" in PROTOCOL),
      f"E1 {_E1W['source_survival']['youden']}, E2 {_E2W['source_survival']['youden']}")
check("rank_screen's structural zero is marked as such",
      "structurally zero, not a measured specificity" in PROTOCOL
      and _E2W["rank_screen"]["false_alarm"] == 0,
      "a definitional zero sits beside measured ones unmarked")
check("the rank_screen leg is called half structural, not unfalsifiable",
      "half structural" in PROTOCOL
      and "the grid cannot falsify that leg" not in PROTOCOL,
      "the leg is still claimed to be unfalsifiable")
check("the mean-and-SD claim is scoped to the registered family",
      "given the Normal within-study law registered below" in PROTOCOL,
      "the withdrawn wording is still the operative sentence")
_CAND_FIELDS = ("e2_curvature_surv", "e2_ecological_surv", "e2_surv_sd_curvature",
                "e2_surv_sd_ecological", "e2_surv_sd_separates")
check("every exported E2 candidate measurement carries its standing",
      all(DESIGN[k]["standing"] == "post-hoc-candidate" for k in _CAND_FIELDS),
      "a candidate measurement is exported bare")
# ROUND 13: THE GUARANTEE MUST HOLD IN THE SOURCE ARTIFACT, NOT ONLY THE EXPORT.
# Round 12 wrapped these values on their way into the JSON while
# results/e2-verdict.rds kept bare fields beside one detached standing, and this
# file read only the wrapped copy, so 221 assertions passed over it. The standing
# now travels with the value from the artifact that computes it, and this checks
# that the export did not add it.
check("the standing comes from the verdict artifact, not from the exporter",
      "._cand" not in (ROOT / "R" / "05-export.R").read_text()
      and 'cand <- function(x) list(standing = STANDING[["source_survival"]]'
          in (ROOT / "R" / "07-run-e2.R").read_text(),
      "the exporter is still labeling values the verdict left bare")

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
# ROUND 13: THIS LIST STOPPED AT TWELVE, having already once stopped at seven.
# The same guard has now failed to grow with the study twice, so it derives its
# word list instead of enumerating one.
def _word(n: int) -> str:
    _ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight",
             "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
             "sixteen", "seventeen", "eighteen", "nineteen"]
    _tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy",
             "eighty", "ninety"]
    if n < len(_ones):
        return _ones[n]
    if n < 100:
        return _tens[n // 10] + ("-" + _ones[n % 10] if n % 10 else "")
    raise ValueError(f"no word form registered for {n} rounds")
# Round 10 is two digits; the original pattern matched one and silently
# dropped the row, so the total went stale the moment the study reached ten
# rounds. A guard that stops seeing new data is a guard that stops working.
_rows = re.findall(r"^\| (\d+) \| (\w+) \| [\w*-]+ \| (\d+) \| (\d+) \|$",
                   (ROOT / "CHANGES.md").read_text(), re.M)
# ROUND 12: A MARKDOWN VERDICT ALMOST DROPPED A ROW. The verdict field was
# matched as [\w-]+, and round 12's "**sound**" does not match it, so the row
# would have vanished from the total silently. It contributed 0 + 0 so nothing
# moved, which is exactly how this class of defect survives. That is the third
# guard in this study whose own pattern stopped growing with the data: the
# number-word list stopped at seven, the round number matched one digit, and now
# the verdict could not contain emphasis. The parser now counts its own rows
# against the table's line count.
_tbl_lines = [l for l in (ROOT / "CHANGES.md").read_text().splitlines()
              if re.match(r"^\| \d+ \| \w+ \|", l)]
check("the reviewer table parses every row it contains",
      len(_rows) == len(_tbl_lines) and len(_rows) >= 6,
      f"parsed {len(_rows)} of {len(_tbl_lines)} rows")
_total = sum(int(f) + int(s) for _, _, f, s in _rows)
_rounds = len({r[0] for r in _rows})
check("the history's finding total is the table's sum",
      f"returned **{_total} fatal and serious findings**" in CHANGES,
      f"the table sums to {_total}")
check("the protocol's finding total is the same number",
      f"**{_total}** fatal and serious findings" in PROTOCOL,
      f"the table sums to {_total}")
check("both documents agree on the round count",
      f"{_word(_rounds)} rounds of critique returned" in PROTOCOL.lower(),
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
      f"{_WORDS[DESIGN['control_null_n_over']]} scenarios overcover at "
      f"{_no[0]:.3f} to {_no[1]:.3f}" in CHANGES,
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
