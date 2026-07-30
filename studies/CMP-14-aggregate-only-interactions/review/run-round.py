#!/usr/bin/env python3
"""Run one round of adversarial pre-run critique across several external models.

Every previous round of this study was driven by hand, and the same three
failures kept recurring: `codex exec` hangs unless stdin is closed; the
opencode/kimi backend returns zero bytes with exit status 0 when the payload is
too large, which reads as "no findings"; and piping a reviewer through `tail`
silently discards the head of its answer. This driver encodes all three.

  python3 review/run-round.py --round 1
  python3 review/run-round.py --round 1 --only codex     # rerun one reviewer

KIMI IS DISABLED FOR THIS STUDY. The opencode/kimi-k3 backend has reached its
weekly quota, so it is removed from REVIEWERS rather than left in to fail. A
reviewer that cannot be reached is recorded as not obtained and is never counted
as agreement; removing it makes that explicit instead of leaving a NOT OBTAINED
file that a later reader might mistake for a silent reviewer.

Output goes to review/round<N>/, one file per reviewer part, plus a manifest
recording the exact command, byte counts and duration for each call. A part that
comes back empty or without a verdict line is retried once and then recorded as
NOT OBTAINED, never as agreement.
"""

from __future__ import annotations

import argparse
import hashlib
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

# A reviewer that times out on the whole document is not a reviewer that has no
# findings. Round 3's first codex attempt ran the full 3600 s on a 35 KB prompt
# and was killed, which the driver records as NOT OBTAINED; that is correct but
# it also loses the round. Any reviewer can now be retried in parts, and the
# parts are packed to this budget. Splitting beats trimming for the reason the
# kimi path documented: a trimmed protocol produces confident findings about
# sections that were cut away.
## Measured, not guessed. Grok returns a usable reply at 20 KB of protocol with
## high effort but returned 239 bytes on the 41 KB whole document and under 300
## bytes on each half at roughly 24 KB including the preamble. The preamble is
## about 4 KB, so a 14 KB part keeps the whole prompt near 18 KB, inside what was
## verified to work rather than at the edge of it.
SPLIT_BUDGET = 14_000

PREAMBLE = """You are reviewing a PRE-REGISTRATION for a simulation study. Nothing has been
run yet. Your job is to find defects while they are still free to fix.

This is the FIRST round of critique on this document. The previous study in this programme
took six rounds and its sixth still returned thirteen fatal findings, so assume this one is
wrong in several places. The categories that rounds of this programme have actually found, in
descending order of frequency:

1. A number printed in one section that contradicts the same quantity in another, or that was
   copied from code which has since been deleted or fixed.
2. A claim whose stated evidence does not support it: the measurement quoted is real, but it
   is a measurement of something else, or it is compared against the wrong reference quantity,
   or its sign or magnitude is misread.
3. A registered analysis that the software cannot actually perform as specified.
4. Something asserted in prose as though it had been measured, when nothing measured it.
5. A control or guard that was weakened after it failed, so that it now asserts something
   weaker than what it was written to check. This document discloses three such changes in
   its section 8; check whether the weakened versions still test anything.
6. An exploratory result presented with the authority of a confirmatory one. Section 8 of
   this document concedes that its first experiment was computed before the protocol was
   written. Check whether the rest of the document respects that concession.

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


# ROUND 5: grok returned 200 to 300 bytes on every part at every size, and the
# reason was not quota or length. Captured directly, its reply is a PLANNING
# preamble: "I'll review the full pre-registration against the code and export it
# claims to match..." and then nothing. `--permission-mode plan` puts it in a mode
# where it announces intent and then wants to read files, which it cannot do here,
# so it stops. The codex call has carried an explicit no-tools instruction since
# the sibling study needed one; grok's had no equivalent.
GROK_NO_TOOLS = """
ANSWER ENTIRELY FROM THE TEXT BELOW. You have no file access and no tools, so do not
plan to read anything, do not describe what you are about to do, and do not ask for the
repository. Produce the VERDICT line and the findings directly as your first output.
"""


def call_grok(prompt: str) -> tuple[str, str, int, float]:
    return run(["grok", "-p", GROK_NO_TOOLS + prompt, "--model", "grok-4.5",
                "--effort", "high", "--output-format", "plain"])


# kimi/opencode is out of quota for this study; see the module docstring.
REVIEWERS = {"codex": call_codex, "grok": call_grok}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--round", type=int, required=True)
    ap.add_argument("--only", default=None, help="comma-separated reviewer names")
    ap.add_argument("--parts", default=None, help="comma-separated part names to rerun")
    ap.add_argument("--no-split", action="store_true",
                    help="do not fall back to a split review on repeated failure")
    ap.add_argument("--split", action="store_true",
                    help="go straight to a split review, for a reviewer already "
                         "known to fail on the whole document")
    args = ap.parse_args()

    outdir = ROOT / "review" / f"round{args.round}"
    outdir.mkdir(parents=True, exist_ok=True)
    protocol = (ROOT / "protocol.md").read_text()
    # WHICH VERSION DID THIS REVIEWER SEE? The manifest recorded byte counts and
    # durations but nothing identifying the document, so a round run against a
    # protocol that was edited afterwards could not be told from one run against
    # the current text. That matters here: round 2 was sent before E2's results
    # were added, so some of its findings address a document that no longer
    # exists in that form, and a reader has to be able to establish that.
    doc_sha = hashlib.sha256(protocol.encode()).hexdigest()[:16]
    doc_bytes = len(protocol.encode())
    print(f"protocol sha256:{doc_sha} ({doc_bytes:,} bytes)", flush=True)

    jobs: list[tuple[str, str, str]] = []          # (reviewer, part name, prompt)

    # codex reads the repository itself, so it gets the whole document and is
    # told where the source is. It is the only reviewer that can check a claim
    # about the code against the code.
    whole = PREAMBLE + f"""
You may read files under {ROOT} (read-only). The implementation is in R/, the numbers the
implementation is in R/, and results/e1.rds plus results/e1-analysis.rds hold what the first
experiment produced. Check claims about the code against the code, and check that the numbers
the document quotes are the numbers the code produces. Do not spawn sub-agents and do not
load skills.

--- PROTOCOL ---
""" + protocol
    jobs.append(("codex", "whole", whole))

    # grok takes the whole document as text, no repository access.
    jobs.append(("grok", "whole", PREAMBLE + "\n--- PROTOCOL ---\n" + protocol))

    want_r = set(args.only.split(",")) if args.only else set(REVIEWERS)
    want_p = set(args.parts.split(",")) if args.parts else None
    manifest = []
    for reviewer, part, prompt in jobs:
        if reviewer not in want_r or (want_p and part not in want_p):
            continue
        tag = f"{reviewer}-{part}"
        print(f"[{tag}] sending {len(prompt.encode()):,} bytes ...", flush=True)
        if args.split and part == "whole":
            out, err, rc, secs = "", "", 1, 0.0     # force the split path below
        else:
            out, err, rc, secs = REVIEWERS[reviewer](prompt)
        if not usable(out) and not args.split:
            print(f"[{tag}] unusable ({len(out.encode())} bytes, rc {rc}); retrying once",
                  flush=True)
            out, err, rc, secs2 = REVIEWERS[reviewer](prompt)
            secs += secs2
        if not usable(out) and part == "whole" and not args.no_split:
            # Second failure on the whole document: fall back to parts. The
            # findings are weaker, because a part cannot see a contradiction with
            # a section it was not shown, and that limitation is recorded in the
            # manifest rather than left for a reader to infer.
            chunks = split_protocol(protocol, SPLIT_BUDGET)
            why = ("forced by --split" if args.split
                   else "whole-document review failed twice")
            print(f"[{tag}] {why}; splitting into {len(chunks)} parts", flush=True)
            pieces = []
            for i, (name, chunk) in enumerate(chunks, 1):
                sub = PREAMBLE + f"""
You are given PART {i} of {len(chunks)} of a longer protocol, containing: {name}. Sections not
shown here exist. Do not report that something is missing unless the text you were given claims
to define it. Internal contradictions WITHIN this part, and arithmetic, are what you can check.

--- PROTOCOL, PART {i} ---
""" + chunk
                o, e, r, sc = REVIEWERS[reviewer](sub)
                secs += sc
                print(f"[{tag}] part {i}/{len(chunks)}: "
                      f"{'ok' if usable(o) else 'NOT OBTAINED'} "
                      f"{len(o.encode()):,} bytes", flush=True)
                if usable(o):
                    pieces.append(f"\n\n<!-- PART {i}: {name} -->\n{o}")
            if pieces:
                out = ("VERDICT: needs-revision\n\n<!-- ASSEMBLED FROM "
                       f"{len(pieces)} OF {len(chunks)} PARTS after the whole-document "
                       "review timed out twice. A part cannot see a contradiction with a "
                       "section it was not shown, so cross-section findings are weaker "
                       "in this round than in one reviewed whole. -->\n"
                       + "".join(pieces))
                rc = 0
            split_used = True
        else:
            split_used = False
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
                             protocol_sha256=doc_sha, protocol_bytes=doc_bytes,
                             split_fallback=split_used,
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
