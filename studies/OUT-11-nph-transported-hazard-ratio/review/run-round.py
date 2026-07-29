#!/usr/bin/env python3
"""Run one round of adversarial pre-run critique across several external models.

Every previous round of this study was driven by hand, and the same three
failures kept recurring: `codex exec` hangs unless stdin is closed; the
opencode/kimi backend returns zero bytes with exit status 0 when the payload is
too large, which reads as "no findings"; and piping a reviewer through `tail`
silently discards the head of its answer. This driver encodes all three.

  python3 review/run-round.py --round 6
  python3 review/run-round.py --round 6 --only codex     # rerun one reviewer

Output goes to review/round<N>/, one file per reviewer part, plus a manifest
recording the exact command, byte counts and duration for each call. A part that
comes back empty or without a verdict line is retried once and then recorded as
NOT OBTAINED, never as agreement.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# The opencode/kimi backend returns 0 bytes with exit 0 above roughly 40 KB, so
# its parts are split well under that. Splitting beats trimming: a trimmed
# protocol produces confident findings about sections that were cut away.
KIMI_BUDGET = 32_000

PREAMBLE = """You are reviewing a PRE-REGISTRATION for a simulation study. Nothing has been
run yet. Your job is to find defects while they are still free to fix.

This document has survived five previous rounds of adversarial critique. Every round so far
returned `unsound`. Assume it is still wrong somewhere and that the remaining defects are the
subtle ones. The categories that previous rounds actually found, in descending order of
frequency:

1. A number printed in one section that contradicts the same quantity in another, or that was
   copied from code which has since been deleted or fixed.
2. A claim whose stated evidence does not support it: the measurement quoted is real, but it
   is a measurement of something else, or it is compared against the wrong reference quantity,
   or its sign or magnitude is misread.
3. A registered analysis that the software cannot actually perform as specified.
4. Something asserted in prose as though it had been measured, when nothing measured it.
5. Defects introduced while fixing the previous round. In each of the last three rounds this
   was the largest single category of fatal finding.

RULES.
- Quote the exact text you object to. A finding without a quote will be discarded.
- Say what would have to be true for your objection to be wrong. If you cannot, mark it
  speculative.
- Do not summarize the document back. Do not praise it. Do not restate its own caveats as
  findings; it declares many limitations itself and those are not defects.
- Arithmetic is worth checking directly. Two previous fatal findings were sums that did not
  reproduce from the terms printed beside them.

OUTPUT FORMAT, exactly:

VERDICT: sound | needs-revision | unsound

Then one block per finding, most severe first:

### <one-line title>
SEVERITY: fatal | serious | minor
QUOTE: "<the exact text you object to>"
PROBLEM: <what is wrong>
WHY IT MATTERS: <what registered claim or output this invalidates>
WOULD BE WRONG IF: <the condition under which your objection fails>

fatal   = invalidates a registered claim, or makes the run uninterpretable.
serious = the study is still worth running but a stated conclusion will not hold.
minor   = correct as written but misleading, imprecise, or unverifiable as stated.
"""


def split_protocol(text: str, budget: int) -> list[tuple[str, str]]:
    """Split at top-level section headers, packing sections up to `budget` bytes."""
    parts = re.split(r"(?m)^(?=## )", text)
    head, sections = parts[0], parts[1:]
    out: list[tuple[str, str]] = []
    buf, names = head, []
    for sec in sections:
        title = sec.splitlines()[0].lstrip("# ").strip()
        if buf and len(buf.encode()) + len(sec.encode()) > budget:
            out.append((", ".join(names) or "head", buf))
            buf, names = head, []
        buf += sec
        names.append(title.split(":")[0].split(",")[0][:28])
    if buf.strip():
        out.append((", ".join(names) or "head", buf))
    return out


def run(cmd: list[str], stdin_text: str | None = None, timeout: int = 3600):
    t0 = time.time()
    try:
        p = subprocess.run(cmd, input=stdin_text if stdin_text is not None else "",
                           capture_output=True, text=True, timeout=timeout, cwd=ROOT)
        return p.stdout, p.stderr, p.returncode, time.time() - t0
    except subprocess.TimeoutExpired:
        return "", f"TIMEOUT after {timeout}s", -1, time.time() - t0


def usable(out: str) -> bool:
    """Non-empty and carrying a verdict. Zero bytes must never read as assent."""
    return bool(out.strip()) and "VERDICT" in out.upper()


def call_codex(prompt: str) -> tuple[str, str, int, float]:
    # --ignore-rules stops the user's global manuscript-review skill from loading
    # and fanning out into sub-reviewers, which made a three-claim question take
    # over ten minutes. Stdin is closed by passing "" or `codex exec` waits on it.
    return run(["codex", "exec", "-m", "gpt-5.6-sol",
                "-c", "model_reasoning_effort=max", "-s", "read-only",
                "--skip-git-repo-check", "--ignore-rules", prompt])


def call_kimi(prompt: str) -> tuple[str, str, int, float]:
    return run(["opencode", "run", "--pure", "-m", "opencode-go/kimi-k3", prompt])


def call_grok(prompt: str) -> tuple[str, str, int, float]:
    return run(["grok", "-p", prompt, "--model", "grok-4.5", "--effort", "high",
                "--output-format", "plain", "--permission-mode", "plan"])


REVIEWERS = {"codex": call_codex, "kimi": call_kimi, "grok": call_grok}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--round", type=int, required=True)
    ap.add_argument("--only", default=None, help="comma-separated reviewer names")
    ap.add_argument("--parts", default=None, help="comma-separated part names to rerun")
    args = ap.parse_args()

    outdir = ROOT / "review" / f"round{args.round}"
    outdir.mkdir(parents=True, exist_ok=True)
    protocol = (ROOT / "protocol.md").read_text()

    jobs: list[tuple[str, str, str]] = []          # (reviewer, part name, prompt)

    # codex reads the repository itself, so it gets the whole document and is
    # told where the source is. It is the only reviewer that can check a claim
    # about the code against the code.
    whole = PREAMBLE + f"""
You may read files under {ROOT} (read-only). The implementation is in R/, the numbers the
document quotes are exported to results/registered-design.json by R/09-export-design.R, and
review/verify-protocol.py asserts the document against that file. Check claims about the code
against the code. Do not spawn sub-agents and do not load skills.

--- PROTOCOL ---
""" + protocol
    jobs.append(("codex", "whole", whole))

    # grok takes the whole document as text, no repository access.
    jobs.append(("grok", "whole", PREAMBLE + "\n--- PROTOCOL ---\n" + protocol))

    # kimi is split, because above roughly 40 KB it returns nothing at all.
    for i, (name, chunk) in enumerate(split_protocol(protocol, KIMI_BUDGET), 1):
        jobs.append(("kimi", f"part{i}",
                     PREAMBLE + f"""
You are given PART {i} of a longer protocol, containing: {name}. Sections not shown here
exist. Do not report that something is missing unless the text you were given claims to
define it. Internal contradictions WITHIN this part, and arithmetic, are what you can check.

--- PROTOCOL, PART {i} ---
""" + chunk))

    want_r = set(args.only.split(",")) if args.only else set(REVIEWERS)
    want_p = set(args.parts.split(",")) if args.parts else None
    manifest = []
    for reviewer, part, prompt in jobs:
        if reviewer not in want_r or (want_p and part not in want_p):
            continue
        tag = f"{reviewer}-{part}"
        print(f"[{tag}] sending {len(prompt.encode()):,} bytes ...", flush=True)
        out, err, rc, secs = REVIEWERS[reviewer](prompt)
        if not usable(out):
            print(f"[{tag}] unusable ({len(out.encode())} bytes, rc {rc}); retrying once",
                  flush=True)
            out, err, rc, secs2 = REVIEWERS[reviewer](prompt)
            secs += secs2
        ok = usable(out)
        # Never clobber an earlier reply. Re-running one reviewer against a
        # revised document produces a DIFFERENT review, and the second codex
        # pass of round 6 overwrote the first, which had already been read but
        # would otherwise have been lost. Earlier replies rotate to -2, -3, ...
        dest = outdir / f"{tag}.md"
        if dest.exists():
            n = 2
            while (outdir / f"{tag}-{n}.md").exists():
                n += 1
            dest.rename(outdir / f"{tag}-{n}.md")
            print(f"[{tag}] previous reply kept as {tag}-{n}.md", flush=True)
        dest.write_text(
            out if ok else f"NOT OBTAINED\nrc={rc}\nbytes={len(out.encode())}\n\n"
                           f"--- stdout ---\n{out}\n--- stderr ---\n{err[-4000:]}\n")
        manifest.append(dict(reviewer=reviewer, part=part, ok=ok, rc=rc,
                             prompt_bytes=len(prompt.encode()),
                             reply_bytes=len(out.encode()), secs=round(secs, 1)))
        print(f"[{tag}] {'ok' if ok else 'NOT OBTAINED'} "
              f"{len(out.encode()):,} bytes in {secs:.0f}s", flush=True)
        (outdir / "manifest.json").write_text(json.dumps(manifest, indent=2))

    got = sum(1 for m in manifest if m["ok"])
    print(f"\n{got}/{len(manifest)} parts obtained; not-obtained parts are recorded "
          f"as such and must not be counted as agreement")


if __name__ == "__main__":
    main()
