#!/usr/bin/env python3
"""Repair the DOI and PMCID fields written by the earlier, broken PubMed parser.

The first version of search.py collected identifiers with art.iter("ArticleId"),
which walks the whole PubmedArticle subtree: ReferenceList included. The last
value won, so a large share of records carry the DOI and PMCID of the final work
they cite rather than their own. Titles, abstracts, PMIDs, journals and years
were never affected, so the hand-screening decisions remain valid and are left
exactly as they are.

This re-parses the cached efetch XML with the corrected rule and patches the two
record files in place, matching on PMID. Records that came from PMC rather than
PubMed were parsed from article-meta and are already correct; they are untouched.

Usage: python3 build/lit/repair_ids.py [--dry-run]
"""

import argparse
import json
import os
import shutil
import sys
from collections import Counter
from xml.etree import ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "documentation", "refs", "systematic")
CACHE = os.path.join(OUT, "_cache")
FILES = ("records.jsonl", "screened.jsonl")

# DOI -> PMCID, for the PMC-only records that carry no PMID to match on.
BY_DOI = {}


def norm_pmc(v):
    v = (v or "").strip()
    return ("PMC" + v) if v and not v.upper().startswith("PMC") else v


def parse_pubmed_cache(root, truth):
    for art, paths in (
            ("PubmedArticle", ("PubmedData/ArticleIdList/ArticleId",)),
            ("PubmedBookArticle", ("BookDocument/ArticleIdList/ArticleId",
                                   "PubmedBookData/ArticleIdList/ArticleId"))):
        for a in root.iter(art):
            ids = {}
            for p in paths:
                for i in a.findall(p):
                    t, v = i.get("IdType"), (i.text or "").strip()
                    if t and v and t not in ids:
                        ids[t] = v
            if ids.get("pubmed"):
                truth[ids["pubmed"]] = {"doi": ids.get("doi", "").lower(),
                                        "pmcid": norm_pmc(ids.get("pmc"))}


def parse_pmc_cache(root, truth):
    """PMC front matter, which the original parser already read correctly.

    Used only to fill a field PubMed itself leaves empty, never to overrule it,
    so the repair can add information but not lose any.
    """
    for art in list(root.iter("article")) + list(root.iter("book")):
        meta = art.find(".//article-meta")
        if meta is None:
            continue
        ids = {i.get("pub-id-type"): (i.text or "").strip()
               for i in meta.iter("article-id")}
        rec = {"doi": ids.get("doi", "").lower(),
               "pmcid": norm_pmc(ids.get("pmcid") or ids.get("pmc"))}
        if ids.get("pmid"):
            truth[ids["pmid"]] = rec
        if rec["doi"] and rec["pmcid"]:
            BY_DOI[rec["doi"]] = rec["pmcid"]


def truth_from_cache(kind):
    """PMID -> {doi, pmcid} from the cached XML, taken from the record itself."""
    truth, files = {}, sorted(f for f in os.listdir(CACHE)
                              if f.endswith(".xml") and f"_{kind}_" in f)
    for n, name in enumerate(files, 1):
        try:
            root = ET.parse(os.path.join(CACHE, name)).getroot()
        except ET.ParseError as e:
            print(f"  unparseable {name}: {e}", file=sys.stderr)
            continue
        (parse_pubmed_cache if kind == "pubmed" else parse_pmc_cache)(root, truth)
        print(f"  {kind} {n}/{len(files)} cached batches", end="\r", file=sys.stderr)
    print(file=sys.stderr)
    return truth


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    print("reading cached XML")
    truth = truth_from_cache("pubmed")
    backup = truth_from_cache("pmc")
    for pmid, t in truth.items():
        alt = backup.get(pmid)
        if alt:
            t["doi"] = t["doi"] or alt["doi"]
            t["pmcid"] = t["pmcid"] or alt["pmcid"]
    for pmid, t in backup.items():
        truth.setdefault(pmid, t)
    print(f"  {len(truth)} PMIDs with authoritative identifiers")

    tally = Counter()
    for name in FILES:
        path = os.path.join(OUT, name)
        if not os.path.exists(path):
            continue
        recs = [json.loads(l) for l in open(path, encoding="utf8")]
        changed, examples = 0, []
        for r in recs:
            t = truth.get(r.get("pmid") or "")
            if not t:
                # PMC-only record: its DOI came from article-meta and is sound,
                # so only the missing accession needs filling in.
                pmcid = BY_DOI.get((r.get("doi") or "").lower(), "")
                if pmcid and pmcid != r.get("pmcid"):
                    r["pmcid"] = pmcid
                    tally[f"{name}: pmcid filled from PMC"] += 1
                    changed += 1
                else:
                    tally[f"{name}: no cached record"] += 1
                continue
            before = (r.get("doi", ""), r.get("pmcid", ""))
            after = (t["doi"], t["pmcid"])
            if before == after:
                tally[f"{name}: already correct"] += 1
                continue
            if len(examples) < 5:
                examples.append((r["pmid"], before, after))
            r["doi"], r["pmcid"] = t["doi"], t["pmcid"]
            changed += 1
        tally[f"{name}: corrected"] = changed
        for pmid, b, a in examples:
            print(f"    {pmid}: {b} -> {a}")
        if args.dry_run:
            continue
        shutil.copyfile(path, path + ".broken")
        with open(path, "w", encoding="utf8") as fh:
            for r in recs:
                fh.write(json.dumps(r, ensure_ascii=False) + "\n")
        print(f"  {name}: {changed}/{len(recs)} corrected "
              f"(previous version kept as {name}.broken)")

    for k, v in sorted(tally.items()):
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
