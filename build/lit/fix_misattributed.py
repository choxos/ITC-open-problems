#!/usr/bin/env python3
"""Re-derive the verdicts that a misattribution wrongly published as unsupported.

`build/adjudicate.mjs` collapses two axes into the published verdict: `status`
(is the problem open?) and `support` (was the claim correctly made and
attributed?). Its own comment says status leads and that support only overrides
"when the claim is so far off that publishing it as open would mislead". The code
did not do that. `support === 'misattributed'` sat above every status test, so a
source citing the wrong paper for a real problem published as `not-supported`.

Four entries carried that verdict, and not one auditor on any of them had voted
the problem closed:

  DIS-03  status open,             both auditors open
  MOD-02  status open,             both auditors open
  EST-03  status partially-solved, one open, one partially-solved
  OUT-12  status partially-solved, both partially-solved

The site's verdict key defines `not-supported` as a claim that could not be
substantiated. These four were substantiated; only the citation was wrong.

The rule is fixed in adjudicate.mjs so this cannot recur. This re-derives the
four verdicts from their own stored audit records under the corrected
precedence, rather than re-running the whole adjudication, because the auditor
opinions are what they always were and only the collapse was wrong.

DIS-03 gets a further correction from a source check rather than from the rule:
the reading's decisive evidence was itself misattributed, to the wrong paper by
the same authors. See the note in the code below.

Usage:
  python3 build/lit/fix_misattributed.py --dry-run
  python3 build/lit/fix_misattributed.py --write
"""

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY = os.path.join(ROOT, "documentation", "audit", "registry")

# The corrected collapse, matching adjudicate.mjs with `misattributed` removed.
def collapse(status, support):
    if status == "solved":
        return "resolved-since-report"
    if status == "not-a-problem":
        return "not-supported"
    if support == "unverifiable":
        return "unverifiable"
    if support == "contested" or status == "contested":
        return "unverifiable"
    if support == "overstated":
        return "overstated"
    if status == "partially-solved":
        return "partially-addressed"
    return "confirmed-open"


RATIONALE = {
    "confirmed-open":
        "Auditors agreed the problem is open and no counterevidence surfaced. "
        "The source attributed the claim to the wrong work, which is corrected "
        "in the entry; the problem itself stands.",
    "overstated":
        "Auditors judged the claim as stated too strong, and the source also "
        "attributed it to the wrong work. Both are corrected here; the "
        "underlying problem is real.",
    "partially-addressed":
        "Part of this problem is addressed by existing work and the entry names "
        "which part. The source additionally attributed the claim to the wrong "
        "work, which is corrected in the entry.",
}

# DIS-03 is not decided by the rule alone. The reading proposed reopening it on a
# quote from Chandler and Ishak, and a check against the manuscripts found the
# quote is not in the paper cited: it is in a different Chandler and Ishak paper,
# "Anchors Away" (arXiv:2606.20341v1, library id L0625), Appendix A.7. That paper
# does substantiate the narrow core, in disconnected single-arm evidence study
# effects are not separately identifiable from treatment effects, so a common
# conditional baseline is an identifying constraint rather than an observation.
# It also calls that assumption "highly restrictive" and recommends fixed study
# effects with hierarchical pooling, which is this entry's own proposed
# direction. A real problem whose remedy is already named is `overstated`, not
# `confirmed-open`.
OVERRIDE = {
    "DIS-03": ("overstated",
               "Auditors judged the problem open, and the source attributed it "
               "to the wrong work. Chandler and Ishak, Anchors Away "
               "(arXiv:2606.20341v1, appendix A.7), supplies the formal support "
               "the closure said was absent: in disconnected single-arm "
               "evidence, study-level effects are not separately identifiable "
               "from treatment effects, so a common conditional baseline risk "
               "is an identifying constraint and not a neutral anchor. The same "
               "paper calls that assumption highly restrictive and recommends "
               "fixed study effects with hierarchical pooling, which is this "
               "entry's own proposed direction, so the problem is real but its "
               "strong form is overstated.")}

DIS03_PRIOR = {
    "cite": "Chandler and Ishak 2026, Anchors Away (arXiv:2606.20341v1)",
    "doi_or_url": "https://arxiv.org/abs/2606.20341",
    "what_it_does": "states that in fully disconnected single-arm evidence "
                    "treatment effects are not separately identifiable from "
                    "study, population and design effects without additional "
                    "structural assumptions, so unanchored comparisons "
                    "typically require a common conditional baseline risk "
                    "across study populations; it calls that assumption highly "
                    "restrictive and unlikely to be plausible in most "
                    "applications, and recommends fixed study effects with "
                    "hierarchical pooling as a sensitivity analysis",
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    if not (a.write or a.dry_run):
        sys.exit("pass --write or --dry-run")

    problems = json.load(open(os.path.join(REGISTRY, "problems.json"),
                              encoding="utf8"))
    changed = []
    for p in problems:
        adj = (p.get("audit") or {}).get("adjudication") or {}
        if adj.get("support") != "misattributed":
            continue
        old = p["verdict"]
        want, why = OVERRIDE.get(
            p["id"], (collapse(adj.get("status"), adj.get("support")), None))
        if why is None:
            why = RATIONALE.get(want, p.get("verdict_rationale"))
        if old == want:
            continue
        if a.write:
            p["verdict"] = want
            p["verdict_rationale"] = why
            if p["id"] == "DIS-03":
                have = {(w.get("doi_or_url") or "").lower()
                        for w in p.get("prior_work") or []}
                if DIS03_PRIOR["doi_or_url"].lower() not in have:
                    p.setdefault("prior_work", []).insert(0, dict(DIS03_PRIOR))
            ru = p.setdefault("reading_update", {"applied": "full-text reading",
                                                 "changes": []})
            ru["changes"].append({
                "kind": "verdict-corrected",
                "what": f"{old} -> {want}",
                "evidence":
                    "The adjudication rule let a misattributed citation set the "
                    "published verdict to `not-supported`, though every auditor "
                    f"on this entry voted the problem "
                    f"`{adj.get('status')}`. A misattribution is a fault in the "
                    "provenance, not in the claim. The rule is corrected in "
                    "build/adjudicate.mjs and the verdict re-derived from this "
                    "entry's own audit record. " + (why or ""),
            })
        changed.append((p["id"], old, want, adj.get("status"),
                        adj.get("status_tally")))

    if a.write:
        json.dump(problems, open(os.path.join(REGISTRY, "problems.json"), "w",
                                 encoding="utf8"), indent=1, ensure_ascii=False)
    for i, old, new, st, tally in changed:
        print(f"  {i:8s} {old:15s} -> {new:20s} (audit status {st}, {tally})")
    print(f"\n{len(changed)} verdicts re-derived"
          + ("" if a.write else "   (dry run; nothing written)"))


if __name__ == "__main__":
    main()
