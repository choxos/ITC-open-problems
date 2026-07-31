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

PREAMBLE = """You are reviewing a DRAFT PRE-REGISTRATION for a simulation study. Nothing has
been run yet beyond five probes, whose results the document reports. Your job is to find
defects while they are still free to fix.

This is the FIRST round of critique on this document. Its sibling study in this programme
took THIRTEEN rounds to converge and returned 181 fatal and serious findings, so assume
this one is wrong in several places.

TWO THINGS ARE DIFFERENT HERE AND YOU SHOULD TEST BOTH.

FIRST: NO NUMBER IN THIS DOCUMENT IS TYPED. Every figure is interpolated from
results/registered-design.json by review/emit-protocol.py, and a verifier asserts the
document is byte-identical to what that generator currently produces. The defect class
that dominated the sibling study, a number drifting from the code, cannot occur. So do
not spend effort hunting for stale numbers; hunt instead for a number that is generated
CORRECTLY while the sentence around it claims something the number does not support.
That is the failure this design leaves open and it is where you are most useful.

SECOND: THE PROBES ALREADY PRODUCED RESULTS, and the document leads with them. Those
results are asserted, not hypothesised. Check whether each stated consequence actually
follows from the measurement offered, and whether a measurement is being used to support
a claim about something it did not measure.

The categories this programme's rounds have actually found, in descending order:

1. A claim whose stated evidence does not support it: the measurement quoted is real but
   is a measurement of something else, or compared against the wrong reference quantity.
2. A claim revoked in one section and still operative in another, or in code.
3. A threshold or criterion asserted rather than derived from a measured noise floor.
4. A guard cited for a check that does not exist, or that cannot fail.
5. A registered analysis the software cannot actually perform as specified.

Return findings in this exact format, most severe first:

VERDICT: sound | needs-revision | unsound

### one-line title
SEVERITY: fatal | serious | minor
QUOTE: the sentence you are objecting to
PROBLEM: what is wrong
WHY IT MATTERS: the consequence
WOULD BE WRONG IF: the condition under which your finding is mistaken
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


# GLM, added for round 7 as a third independent reviewer. It runs through the
# same opencode backend as kimi, so it inherits that backend's payload ceiling:
# above roughly 40 KB the call returns zero bytes with exit status 0, which looks
# like "no findings" and is not. The split path already exists for grok and is
# what this uses; the reviewer is never trimmed, only split.
# ROUND 7: `opencode/glm-5.2` answered "Insufficient balance" and returned zero
# bytes, which the driver recorded as NOT OBTAINED. That is the right record and
# the wrong provider: the model is reachable through nvidia, which was verified
# with a one-line probe before this was changed. The opencode-go route is still
# dead and `opencode/...` still has no balance, so neither is a fallback.
def call_glm(prompt: str) -> tuple[str, str, int, float]:
    return run(["opencode", "run", "--pure", "-m", "nvidia/z-ai/glm-5.2",
                GROK_NO_TOOLS + prompt])


# kimi/opencode is out of quota for this study; see the module docstring.
REVIEWERS = {"codex": call_codex, "grok": call_grok, "glm": call_glm}


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

    # grok and glm take the whole document as text, no repository access. Two
    # text-only reviewers against one with repository access is deliberate: the
    # findings that only codex can make are the ones about code, and the findings
    # only the text readers make are the ones about what the document fails to
    # say. Round 6 produced both kinds and neither reviewer found the other's.
    jobs.append(("grok", "whole", PREAMBLE + "\n--- PROTOCOL ---\n" + protocol))
    jobs.append(("glm", "whole", PREAMBLE + "\n--- PROTOCOL ---\n" + protocol))

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
