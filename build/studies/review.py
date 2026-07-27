#!/usr/bin/env python3
"""Peer review for the study program, run like a journal rather than a checklist.

Two independent reviewers, two rounds, and the whole exchange published beside
the manuscript: reports, author responses, and what changed between rounds. A
review that nobody can read is an assertion that review happened.

The two reviewers are different model families on purpose. They fail in
different ways, and a criticism both raise independently is worth more than one
raised twice by the same model. Where a reviewer is unavailable that is recorded
in the published record as an unavailable reviewer, never quietly dropped: a
review record that hides a missing reviewer is worse than one that admits it.

Round 1 reviews the manuscript as first written. The author responds
point by point and revises. Round 2 reviews the revision **with the round-1
reports and the responses in front of it**, which is what makes it a second
round rather than a second first round: a reviewer can say the response is
inadequate.

Usage:
  python3 build/studies/review.py --study <slug> --round 1 --send
  python3 build/studies/review.py --study <slug> --round 2 --send
  python3 build/studies/review.py --study <slug> --publish
"""

import argparse
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
STUDIES = os.path.join(ROOT, "studies")

REVIEWERS = {
    "sol": {
        "name": "GPT-5.6 Sol (maximum reasoning effort)",
        "kind": "codex",
        "model": "gpt-5.6-sol",
        "effort": "max",
    },
    "glm": {
        "name": "GLM-5.2 (via Ollama)",
        "kind": "ollama",
        "model": "glm-5.2:cloud",
    },
    # Invited first and unreachable: billed as Ollama extra usage with an empty
    # balance. Kept in the record so the published history shows who was asked,
    # not only who answered, but not counted as a required reviewer.
    "kimi": {
        "name": "Kimi K3 (via Ollama)",
        "kind": "ollama",
        "model": "kimi-k3:cloud",
        "optional": True,
    },
}

RECOMMENDATIONS = ("accept", "minor-revision", "major-revision", "reject")

PROMPT = """You are peer reviewing a manuscript for a methodological journal in
evidence synthesis. Review it as you would for Statistics in Medicine or
Research Synthesis Methods.

Answer from the manuscript and your own knowledge of this literature. Do not use
tools, do not spawn sub-agents, do not load skills.

The manuscript reports a simulation study aimed at a specific open problem in a
public catalog. It is accompanied by a protocol that was registered before the
run. Both are given to you in full.

## What to review

**Does the study answer the problem it claims to answer?** The most common fatal
flaw in this area is a study that is internally sound and measures a
neighbouring question. Compare the aims to the stated problem.

**Is the finding built into the data-generating mechanism?** If the mechanism
makes the studied effect true by construction, the study demonstrates arithmetic.
Say which parameter choice does this, if any.

**Are the estimands right?** In population adjustment the usual errors are
conflating conditional with marginal effects, conflating a realized sample with
a superpopulation, and computing a truth for a different population than the
estimator targets.

**Is the comparison fair?** A status quo given a worse variance estimator than
the proposal is a rigged comparison.

**Are the conclusions supported by the numbers reported?** Check that every claim
in the abstract and discussion is licensed by a result in the paper, and that
Monte Carlo error is respected: a difference smaller than its Monte Carlo
standard error is not a finding.

**Are the stated limitations the real ones?** A limitations section that lists
easy limitations while omitting the one that threatens the conclusion is worse
than none.

**Citations.** Flag any work attributed to the wrong authors, any citation that
does not say what the manuscript claims, and any claim of novelty that ignores
existing work you know of.

Reward what is done well. A review that finds everything fatal is not a review.
Reserve `reject` for a study whose question or design cannot be repaired.

## Output

Reply with JSON only, no prose before or after.

{"recommendation":"accept|minor-revision|major-revision|reject",
 "summary":"three to five sentences: what the paper does and whether it succeeds",
 "strengths":["..."],
 "comments":[{"id":1,"severity":"major|minor","section":"...","comment":"...",
   "what_would_satisfy":"the specific change or evidence that would resolve this"}],
 "citation_problems":[{"cite":"...","problem":"..."}],
 "conclusions_supported":true,
 "unsupported_claims":["quote any claim the results do not license"]}
"""

ROUND2_EXTRA = """
## This is round two

You are reviewing a REVISED manuscript. You are given the round-one reports from
both reviewers, the authors' point-by-point response, and the revised paper.

Judge the revision. For each round-one point that was addressed to you, say
whether the response is adequate. Authors are allowed to disagree with a
reviewer and say why; a reasoned refusal is a legitimate response and should be
judged on its reasoning, not on whether they complied. What is not legitimate is
a response that claims a change was made when the manuscript does not show it,
so check the text against the claim.

Add `"round1_resolution"` to your JSON: a list of
{"reviewer":"...","id":N,"resolved":"yes|partly|no","note":"..."} covering each
round-one major comment.
"""


def study_dir(slug):
    d = os.path.join(STUDIES, slug)
    if not os.path.isdir(d):
        sys.exit(f"no study at {d}")
    return d


def review_dir(slug):
    d = os.path.join(study_dir(slug), "review")
    os.makedirs(d, exist_ok=True)
    return d


def read(p, default=""):
    return open(p, encoding="utf8").read() if os.path.exists(p) else default


def strip_ansi(s):
    s = re.sub(r"\x1b\[[0-9;?]*[a-zA-Z]", "", s)
    s = re.sub(r"\x1b\][^\x07]*\x07", "", s)
    return re.sub(r"[⠀-⣿]", "", s)


def extract_json(text):
    depth, start = 0, None
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and start is not None:
                blob = text[start:i + 1]
                if '"recommendation"' in blob:
                    try:
                        return json.loads(blob)
                    except json.JSONDecodeError:
                        pass
                start = None
    return None


def build_package(slug, rnd):
    d = study_dir(slug)
    pid = json.load(open(os.path.join(d, "study.json"), encoding="utf8"))["problem_id"]
    parts = [
        "# MANUSCRIPT UNDER REVIEW", "",
        read(os.path.join(d, "out", f"{pid}.md"),
             "(manuscript not rendered; review the protocol only)"),
        "", "# REGISTERED PROTOCOL", "",
        read(os.path.join(d, "protocol.md")),
        "", "# PRESPECIFIED DECISION, AS EVALUATED", "",
        read(os.path.join(d, "results", "decision.md")),
    ]
    if rnd == 2:
        rd = review_dir(slug)
        prior = ["", "# ROUND ONE REPORTS", ""]
        for f in sorted(glob.glob(os.path.join(rd, "round1-*.json"))):
            who = os.path.basename(f)[7:-5]
            prior += [f"## Reviewer {who}", "",
                      json.dumps(json.load(open(f, encoding="utf8")),
                                 indent=1, ensure_ascii=False), ""]
        prior += ["", "# AUTHORS' RESPONSE TO ROUND ONE", "",
                  read(os.path.join(rd, "round1-response.md"),
                       "(no response recorded)")]
        parts += prior
    return "\n".join(parts)


def call_codex(cfg, prompt, timeout):
    p = subprocess.run(
        ["codex", "exec", "-m", cfg["model"],
         "-c", f"model_reasoning_effort={cfg['effort']}",
         "-s", "read-only", "--skip-git-repo-check", "--ignore-rules", prompt],
        capture_output=True, timeout=timeout, stdin=subprocess.DEVNULL)
    return p.stdout.decode("utf8", "ignore")


def call_ollama(cfg, prompt, timeout):
    """Talk to the local Ollama daemon over HTTP.

    The CLI works too but interleaves ANSI spinner frames with the response, so
    a long report arrives wrapped in tens of kilobytes of escape codes. The HTTP
    endpoint returns the message directly. The CLI path is kept as a fallback
    because the daemon is not always running.
    """
    import urllib.error
    import urllib.request

    body = json.dumps({"model": cfg["model"], "stream": False,
                       "messages": [{"role": "user", "content": prompt}]}).encode()
    req = urllib.request.Request("http://localhost:11434/api/chat", data=body,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.load(r).get("message", {}).get("content", "")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf8", "ignore")
        if e.code == 402 or "extra usage" in detail:
            raise RuntimeError(
                "Ollama returned 402 Payment Required: this model is billed as "
                "extra usage only and the account's extra-usage balance is empty. "
                "Add credit or enable auto reload at https://ollama.com/settings, "
                "then re-run this command. Verified through all three access "
                "paths (CLI, HTTP API, python client), so this is account "
                "billing and not a client problem.") from None
        raise RuntimeError(f"ollama HTTP {e.code}: {detail[:300]}") from None
    except urllib.error.URLError:
        # Daemon not reachable: fall back to the CLI.
        p = subprocess.run(["ollama", "run", cfg["model"]],
                           input=prompt.encode("utf8"), capture_output=True,
                           timeout=timeout)
        out = strip_ansi(p.stdout.decode("utf8", "ignore"))
        err = strip_ansi(p.stderr.decode("utf8", "ignore"))
        if "extra usage" in err or "extra usage" in out:
            raise RuntimeError(
                "Ollama returned 402 Payment Required: extra-usage balance is "
                "empty. Add credit at https://ollama.com/settings.") from None
        if p.returncode != 0 and not out.strip():
            raise RuntimeError(err.strip()[:400] or "ollama failed") from None
        return out


def send_one(slug, rnd, key, package, timeout=5400):
    cfg = REVIEWERS[key]
    prompt = PROMPT + (ROUND2_EXTRA if rnd == 2 else "") + "\n\nPACKAGE:\n\n" + package
    rd = review_dir(slug)
    open(os.path.join(rd, f"round{rnd}-{key}-prompt.txt"), "w",
         encoding="utf8").write(prompt)
    try:
        out = (call_codex if cfg["kind"] == "codex" else call_ollama)(cfg, prompt, timeout)
    except Exception as e:
        # Recorded, not hidden. The published record has to show that a reviewer
        # was invited and could not be reached, with the reason.
        rec = {"reviewer": key, "name": cfg["name"], "round": rnd,
               "status": "unavailable", "reason": str(e)}
        json.dump(rec, open(os.path.join(rd, f"round{rnd}-{key}-unavailable.json"),
                            "w", encoding="utf8"), indent=1, ensure_ascii=False)
        return key, None, f"UNAVAILABLE: {str(e)[:160]}"
    open(os.path.join(rd, f"round{rnd}-{key}-raw.txt"), "w", encoding="utf8").write(out)
    d = extract_json(out)
    if not d:
        return key, None, "no JSON in output"
    if d.get("recommendation") not in RECOMMENDATIONS:
        return key, None, f"bad recommendation {d.get('recommendation')!r}"
    d["reviewer"] = key
    d["name"] = cfg["name"]
    d["round"] = rnd
    json.dump(d, open(os.path.join(rd, f"round{rnd}-{key}.json"), "w",
                      encoding="utf8"), indent=1, ensure_ascii=False)
    n_major = sum(1 for c in d.get("comments", []) if c.get("severity") == "major")
    return key, d, f"{d['recommendation']}, {n_major} major comments"


def send(slug, rnd, reviewers):
    package = build_package(slug, rnd)
    print(f"round {rnd}: package is {len(package):,} characters, "
          f"{len(reviewers)} reviewers", flush=True)
    with ThreadPoolExecutor(max_workers=len(reviewers)) as pool:
        for key, _, note in pool.map(lambda k: send_one(slug, rnd, k, package),
                                     reviewers):
            print(f"  {key}: {note}", flush=True)


SEV = {"major": "Major", "minor": "Minor"}


def publish(slug):
    """Assemble the full review history into one published document."""
    rd = review_dir(slug)
    d = study_dir(slug)
    meta = json.load(open(os.path.join(d, "study.json"), encoding="utf8"))

    L = [f"# Peer review: {meta['title']}", "",
         f"Study aimed at catalog problem **{meta['problem_id']}**"
         + (f", also bearing on {', '.join(meta.get('also_bears_on') or [])}"
            if meta.get("also_bears_on") else "") + ".", "",
         "Two independent reviewers, two rounds. Reports, author responses and the",
         "editorial decision are reproduced in full and unedited. Reviewers were",
         "given the manuscript, the protocol registered before the run, and the",
         "prespecified decision as evaluated; in round two they additionally saw",
         "round one's reports and the authors' response.", "",
         "## Reviewers", "",
         "| | Reviewer | Round 1 | Round 2 |", "| --- | --- | --- | --- |"]

    def state(key, rnd):
        p = os.path.join(rd, f"round{rnd}-{key}.json")
        if os.path.exists(p):
            return json.load(open(p, encoding="utf8")).get("recommendation", "?")
        u = os.path.join(rd, f"round{rnd}-{key}-unavailable.json")
        if os.path.exists(u):
            return "unavailable"
        return "not run"

    n = 0
    for key, cfg in REVIEWERS.items():
        if cfg.get("optional"):
            continue
        n += 1
        L.append(f"| R{n} | {cfg['name']} | {state(key, 1)} | {state(key, 2)} |")
    for key, cfg in REVIEWERS.items():
        if not cfg.get("optional"):
            continue
        L.append(f"| invited | {cfg['name']} | {state(key, 1)} | {state(key, 2)} |")
    L.append("")

    for rnd in (1, 2):
        got = False
        for key, cfg in REVIEWERS.items():
            p = os.path.join(rd, f"round{rnd}-{key}.json")
            u = os.path.join(rd, f"round{rnd}-{key}-unavailable.json")
            if os.path.exists(p):
                got = True
            elif os.path.exists(u):
                got = True
        if not got:
            continue
        L += [f"## Round {rnd}", ""]
        for i, (key, cfg) in enumerate(REVIEWERS.items(), 1):
            p = os.path.join(rd, f"round{rnd}-{key}.json")
            u = os.path.join(rd, f"round{rnd}-{key}-unavailable.json")
            L += [f"### Reviewer {i}: {cfg['name']}", ""]
            if os.path.exists(u):
                r = json.load(open(u, encoding="utf8"))
                L += ["**Unavailable.** This reviewer was invited and could not be",
                      f"reached. Reason recorded at the time: {r['reason']}", "",
                      "The review is not counted as favorable or unfavorable; it did",
                      "not happen, and this record says so.", ""]
                continue
            if not os.path.exists(p):
                L += ["*Not run.*", ""]
                continue
            r = json.load(open(p, encoding="utf8"))
            L += [f"**Recommendation: {r['recommendation']}**", "",
                  r.get("summary", ""), ""]
            if r.get("strengths"):
                L += ["**Strengths.**", ""] + [f"- {x}" for x in r["strengths"]] + [""]
            if r.get("comments"):
                L += ["**Comments.**", ""]
                for c in r["comments"]:
                    L += [f"**{SEV.get(c.get('severity'), c.get('severity'))} "
                          f"{c.get('id')}** ({c.get('section', 'general')}). "
                          f"{c.get('comment')}", "",
                          f"*What would satisfy this:* {c.get('what_would_satisfy','')}",
                          ""]
            if r.get("citation_problems"):
                L += ["**Citation problems.**", ""] + [
                    f"- {c.get('cite')}: {c.get('problem')}"
                    for c in r["citation_problems"]] + [""]
            if r.get("unsupported_claims"):
                L += ["**Claims the reviewer judged unsupported.**", ""] + [
                    f"- {x}" for x in r["unsupported_claims"]] + [""]
            if r.get("round1_resolution"):
                L += ["**Judgement on round one.**", "",
                      "| round-1 point | resolved | note |", "| --- | --- | --- |"]
                for x in r["round1_resolution"]:
                    L.append(f"| {x.get('reviewer')} {x.get('id')} | "
                             f"{x.get('resolved')} | {x.get('note')} |")
                L.append("")
        resp = read(os.path.join(rd, f"round{rnd}-response.md"))
        if resp:
            L += [f"## Authors' response to round {rnd}", "", resp, ""]

    dec = read(os.path.join(rd, "decision.md"))
    if dec:
        L += ["## Editorial decision", "", dec, ""]

    out = os.path.join(rd, "peer-review.md")
    open(out, "w", encoding="utf8").write("\n".join(L) + "\n")
    print(f"wrote {os.path.relpath(out, ROOT)} ({len(L)} lines)")
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--study", required=True)
    ap.add_argument("--round", type=int, choices=(1, 2))
    ap.add_argument("--send", action="store_true")
    ap.add_argument("--publish", action="store_true")
    ap.add_argument("--reviewers", nargs="+",
                    default=[k for k, v in REVIEWERS.items() if not v.get("optional")])
    a = ap.parse_args()
    if a.send:
        if not a.round:
            sys.exit("--send needs --round")
        send(a.study, a.round, a.reviewers)
    elif a.publish:
        publish(a.study)
    else:
        sys.exit("pass --send or --publish")


if __name__ == "__main__":
    main()
