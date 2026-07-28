#!/usr/bin/env python3
"""Refuse to publish a manuscript whose inline R evaluated to nothing.

Round two of this study was sent to three reviewers with a sentence reading

    At the amendment level of 0.15 the rate is \\[, \\], whose interval

because `power-pooled.csv` had no row at drift 0.15, so `pp[pp$drift == 0.15, ]`
returned zero rows, `pc()` returned `character(0)`, and Quarto rendered nothing.
Two reviewers reported the blank independently. Nothing errored: a zero-length
inline result is a silent empty string, and every existing check passed, because
`verify-response.py` looks for text that should be PRESENT and this failure is
text that is ABSENT.

The generalizing fix is not another hand-written needle. It is this: after
rendering, scan the output for the shapes an empty inline result leaves behind.

    python3 review/verify-render.py [path/to/rendered.md]

Exit status is non-zero if anything is found, so it can gate a publish step.
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.dirname(HERE)
DEFAULT = os.path.join(STUDY, "out", "IDN-05.md")

# What an empty inline result looks like once Quarto has escaped the markdown
# around it. Each pattern is paired with the source shape that produces it.
EMPTY = [
    (r"\\\[\s*,\s*\\\]", "an interval printed from a zero-row lookup: [, ]"),
    (r"(?<!\*)\*\*\*\*(?!\*)", "a bolded value that rendered empty: ****"),
    (r"\[\s*,\s*\]", "an interval printed from a zero-row lookup: [, ]"),
    (r"\bNA\b(?!-)", "a literal NA reached the page"),
    (r"\bNaN\b", "a literal NaN reached the page"),
    (r"\bInf\b", "a literal Inf reached the page"),
    (r"character\(0\)", "a zero-length character vector was printed"),
    (r"numeric\(0\)", "a zero-length numeric vector was printed"),
    (r"\bNULL\b", "a NULL was printed"),
    # ` r pc(...)` left unrendered means the chunk never ran at all
    (r"`r\s", "an inline R expression was not evaluated"),
]

# Lines that legitimately contain a token above. Each needs a reason.
ALLOW = [
    # The limitations discuss missingness and the word NA does not appear there,
    # but keep the mechanism: an allowance must name the line, not the pattern.
]


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT
    if not os.path.exists(path):
        sys.exit(f"no rendered manuscript at {path}; run publish.py first")
    lines = open(path, encoding="utf8").read().split("\n")

    bad = []
    for n, line in enumerate(lines, 1):
        if any(a in line for a in ALLOW):
            continue
        for pat, why in EMPTY:
            if re.search(pat, line):
                bad.append((n, why, line.strip()[:120]))
                break

    print(f"scanned {len(lines)} lines of {os.path.relpath(path, STUDY)}")
    if not bad:
        print("no empty inline results")
        return 0
    print(f"\n{len(bad)} line(s) carry an empty or non-finite inline result:\n")
    for n, why, text in bad:
        print(f"  line {n}: {why}")
        print(f"    {text}")
    print("\nThis is the failure that shipped to three reviewers in round two.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
