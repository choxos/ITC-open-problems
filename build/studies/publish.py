#!/usr/bin/env python3
"""Render a study's manuscript to the three published formats and register it.

Each study directory carries a `study.json` describing what it set out to answer
and what it found, and a Quarto manuscript. This renders the manuscript to
Markdown, PDF and OpenDocument, checks the outputs are real rather than merely
present, and writes `studies/index.json`, which `build/render_site.mjs` reads to
put a results section on the problem's page.

The checks matter more than they look. A Quarto render can succeed and still
produce a PDF with unresolved cross-references reading "?@fig-x", or an ODT
whose equations came through as literal dollar signs because a math construct
did not survive the OpenDocument writer. Both look fine to the build and wrong
to a reader, so both are tested for here.

Usage:
  python3 build/studies/publish.py --study EST-01-target-population
  python3 build/studies/publish.py --all
  python3 build/studies/publish.py --index-only
"""

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
STUDIES = os.path.join(ROOT, "studies")

FORMATS = {"gfm": ".md", "pdf": ".pdf", "odt": ".odt"}

REQUIRED = ("problem_id", "title", "status", "question")
# Only a completed study makes a claim, so only a completed study has to say
# what it found and what it did not.
REQUIRED_COMPLETE = ("answer", "findings", "not_answered", "design", "n_sim",
                     "date_completed")
STATUSES = ("designed", "running", "complete")


def studies():
    out = []
    for f in sorted(glob.glob(os.path.join(STUDIES, "*", "study.json"))):
        d = json.load(open(f, encoding="utf8"))
        d["_dir"] = os.path.dirname(f)
        d["_slug"] = os.path.basename(os.path.dirname(f))
        out.append(d)
    return out


def check_meta(d):
    why = [f"missing {k}" for k in REQUIRED if not d.get(k)]
    if d.get("status") not in STATUSES:
        why.append(f"status={d.get('status')!r} not in {STATUSES}")
    if d.get("status") == "complete":
        why += [f"missing {k}" for k in REQUIRED_COMPLETE if not d.get(k)]
    return why


def render(d):
    """Render manuscript.qmd to all three formats, into out/."""
    src = os.path.join(d["_dir"], "manuscript", "manuscript.qmd")
    if not os.path.exists(src):
        return [f"no manuscript at {os.path.relpath(src, ROOT)}"]
    out = os.path.join(d["_dir"], "out")
    os.makedirs(out, exist_ok=True)

    problems = []
    for fmt, ext in FORMATS.items():
        p = subprocess.run(
            ["quarto", "render", "manuscript.qmd", "--to", fmt],
            cwd=os.path.dirname(src), capture_output=True, text=True)
        if p.returncode != 0:
            problems.append(f"{fmt} render failed: "
                            f"{(p.stderr or p.stdout).strip()[-400:]}")
            continue
        produced = os.path.join(os.path.dirname(src), "manuscript" + ext)
        if not os.path.exists(produced):
            problems.append(f"{fmt}: quarto reported success but wrote no {ext}")
            continue
        shutil.move(produced, os.path.join(out, d["problem_id"] + ext))

    # The protocol and the review history are published artifacts, not repository
    # extras, so they are copied into out/ and served by the site. Linking them
    # only through GitHub makes them invisible whenever the repository is private,
    # which is exactly the situation in which "we published the reviews" would be
    # an empty claim.
    for name, dest in (("protocol.md", f"{d['problem_id']}-protocol.md"),
                       (os.path.join("review", "peer-review.md"),
                        f"{d['problem_id']}-peer-review.md")):
        src2 = os.path.join(d["_dir"], name)
        if os.path.exists(src2):
            shutil.copy2(src2, os.path.join(out, dest))

    # Figures travel with the Markdown, which references them relatively. The
    # PDF and ODT embed their own copies, so only the Markdown needs this.
    for cand in glob.glob(os.path.join(os.path.dirname(src),
                                       "manuscript_files", "figure-*")):
        dst = os.path.join(out, "figures")
        shutil.rmtree(dst, ignore_errors=True)
        shutil.copytree(cand, dst)
        md = os.path.join(out, d["problem_id"] + ".md")
        if os.path.exists(md):
            t = open(md, encoding="utf8").read()
            t = re.sub(r"manuscript_files/figure-[a-z]+/", "figures/", t)
            open(md, "w", encoding="utf8").write(t)

    return problems + verify(d, out)


def verify(d, out):
    """Check the rendered files say what the manuscript said."""
    bad = []
    md_path = os.path.join(out, d["problem_id"] + ".md")
    if os.path.exists(md_path):
        md = open(md_path, encoding="utf8").read()
        if "?@" in md:
            bad.append("markdown has unresolved cross-references (?@)")
        if len(md) < 2000:
            bad.append(f"markdown is only {len(md)} chars; render likely truncated")
        for img in re.findall(r"!\[[^\]]*\]\(([^)]+)\)", md):
            if not img.startswith(("http", "data:")) and \
                    not os.path.exists(os.path.join(out, img)):
                bad.append(f"markdown references missing image {img}")

    pdf = os.path.join(out, d["problem_id"] + ".pdf")
    if os.path.exists(pdf) and os.path.getsize(pdf) < 20000:
        bad.append(f"pdf is only {os.path.getsize(pdf)} bytes")

    odt = os.path.join(out, d["problem_id"] + ".odt")
    if os.path.exists(odt):
        try:
            with zipfile.ZipFile(odt) as z:
                names = z.namelist()
                body = z.read("content.xml").decode("utf8", "ignore")
            # A manuscript that states a model has display math. If none of it
            # became an ODF formula object, the equations shipped as literal
            # text and the file is not usable as a document.
            if not any(n.startswith("Formula") for n in names) and "$" in body:
                bad.append("odt has no formula objects but has literal $; "
                           "math did not convert")
        except zipfile.BadZipFile:
            bad.append("odt is not a valid zip")

    missing = [e for e in FORMATS.values()
               if not os.path.exists(os.path.join(out, d["problem_id"] + e))]
    if missing:
        bad.append(f"no output for {', '.join(missing)}")
    return bad


def write_index(ds):
    """The site's view of the program: one record per study, keyed by problem."""
    idx = {}
    for d in ds:
        out = os.path.join(d["_dir"], "out")
        have = {k: f"studies/{d['_slug']}/out/{d['problem_id']}{e}"
                for k, e in FORMATS.items()
                if os.path.exists(os.path.join(out, d["problem_id"] + e))}
        rec = {
            "slug": d["_slug"],
            "title": d["title"],
            "status": d["status"],
            "question": d["question"],
            "answer": d.get("answer"),
            "findings": d.get("findings") or [],
            "not_answered": d.get("not_answered"),
            "design": d.get("design"),
            "n_sim": d.get("n_sim"),
            "estimand": d.get("estimand"),
            "methods_compared": d.get("methods_compared") or [],
            "date_completed": d.get("date_completed"),
            "week": d.get("week"),
            "code": f"studies/{d['_slug']}",
            "protocol": (f"studies/{d['_slug']}/out/{d['problem_id']}-protocol.md"
                         if os.path.exists(os.path.join(d["_dir"], "protocol.md"))
                         else None),
            # The full peer-review exchange, published beside the paper. A study
            # that says it was reviewed without showing the reports is asking to
            # be taken on trust, which is the thing this catalog exists to avoid.
            "review": (f"studies/{d['_slug']}/out/{d['problem_id']}-peer-review.md"
                       if os.path.exists(os.path.join(d["_dir"], "review",
                                                      "peer-review.md"))
                       else None),
            "review_rounds": len(glob.glob(os.path.join(
                d["_dir"], "review", "round*-response.md"))),
            "downloads": have,
            "primary_problem": d["problem_id"],
            "secondary": False,
        }
        idx[d["problem_id"]] = rec
        # A study usually bears on more than the entry it was aimed at. Those
        # pages get the same record marked secondary, so the section can say
        # plainly that the study was designed for a different entry and answers
        # this one only in part. Leaving them off would hide a real answer from
        # the page a reader is most likely to be on.
        for other in d.get("also_bears_on") or []:
            idx[other] = dict(rec, secondary=True)
    json.dump(idx, open(os.path.join(STUDIES, "index.json"), "w", encoding="utf8"),
              indent=1, ensure_ascii=False)
    return idx


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--study")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--index-only", action="store_true")
    a = ap.parse_args()

    ds = studies()
    if not ds:
        sys.exit("no studies found under studies/*/study.json")

    fatal = False
    for d in ds:
        why = check_meta(d)
        if why:
            print(f"!! {d['_slug']}: {'; '.join(why)}")
            fatal = True
    if fatal:
        sys.exit(1)

    if not a.index_only:
        todo = [d for d in ds if a.all or d["_slug"] == a.study
                or d["problem_id"] == a.study]
        if not todo:
            sys.exit(f"no study matching {a.study!r}")
        for d in todo:
            if d["status"] == "designed":
                print(f"   {d['_slug']}: designed, no manuscript to render yet")
                continue
            print(f"   {d['_slug']}: rendering", flush=True)
            for w in render(d):
                print(f"!!   {w}")
                fatal = True

    idx = write_index(studies())
    print(f"\n{len(idx)} studies in studies/index.json")
    for pid, r in sorted(idx.items()):
        print(f"  {pid:8s} {r['status']:10s} "
              f"{'/'.join(sorted(r['downloads'])) or 'no downloads':16s} {r['title'][:48]}")
    if fatal:
        sys.exit(1)


if __name__ == "__main__":
    main()
