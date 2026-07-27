#!/usr/bin/env python3
"""Get a simulation-study design from an external model, then attack it.

Two passes, because the first one is not trustworthy on its own.

The design pass sends the catalog entry in full, including its prior work and
its own proposed direction, and asks for an ADEMP protocol. That produces
something plausible. The critique pass sends the design back to a fresh context
with one instruction: find the ways this study answers a question nobody asked,
or produces a result that is a property of the data-generating mechanism rather
than of the methods. A simulation study is uniquely vulnerable to that failure,
because the DGM is chosen by the same person who wants a particular conclusion,
and nothing in the output announces it.

The critique is not advisory. Its findings go into the protocol as design
decisions or as declared limitations, and the protocol names which.

Every citation either model produces is treated as unverified. Both have been
observed inventing plausible attributions in this repository: on a smoke test
for this program the design model attributed network meta-interpolation to
Phillippo, whose work is ML-NMR, when NMI is Harari and colleagues.

Usage:
  python3 build/studies/design.py --problems MIS-03 EST-07 --slug MIS-03-target-moment-uncertainty
  python3 build/studies/design.py --critique --slug MIS-03-target-moment-uncertainty
"""

import argparse
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY = os.path.join(ROOT, "documentation", "audit", "registry", "problems.json")
OUT = os.path.join(ROOT, "documentation", "studies", "designs")

MODEL = "gpt-5.6-sol"
EFFORT = "max"

ENVIRONMENT = """
## What the study will be run in

R 4.6.0 on a laptop, 8 cores. Available and current: multinma 0.9.1.9002,
maicplus 0.1.2.9000, netmeta 3.6.1, flexsurv 2.3.2, survival 3.8.9, boot,
mvtnorm, data.table, dplyr, ggplot2, cmdstanr 0.9.0 with CmdStan 2.39.0.
`gemtc`, `MatchIt` and `simsurv` are NOT installed and should not be assumed;
name them only if they are genuinely necessary.

A seeded, resumable, parallel replicate harness already exists, as do ADEMP
performance measures with Monte Carlo standard errors for bias, empirical SE,
model SE, relative error in model SE, MSE, coverage, bias-eliminated coverage,
rejection rate and convergence. Do not design those; use them.

Budget: about a week of one person's time, and the run itself should finish
overnight at worst. A Bayesian method fitted by MCMC across a large factorial
design is the usual way this budget is blown. If ML-NMR is in the comparison,
say explicitly how many scenarios by replicates by chains that implies and
whether it fits, and offer a smaller design if it does not.
"""

DESIGN_PROMPT = """You design a simulation study that will be run, published, and
attached to a public catalog entry as the answer to a stated open problem.

Answer from the payload and your own knowledge of this literature. Do not use
tools, do not spawn sub-agents, do not load skills.

## What you are given

One or more entries from an audited catalog of open problems in
population-adjusted indirect comparisons. Each entry states the problem, why it
is open, what has already been tried with citations, and what the catalog thinks
the research direction is. These entries have been through full-text review and
external audit; where an entry says a part of the problem is already solved and
names the work that solved it, believe it and do not redesign that part.

The FIRST entry is the target. Any others are related entries the same study
might also bear on; say at the end which of them it answers, partly answers, or
does not touch.
{ENVIRONMENT}
## What to produce

An ADEMP protocol, following Morris, White and Crowther (2019). Be specific
enough that someone else could implement it without asking you a question.

**Aims.** State the question as something with a numerical answer. "Investigate
the impact of X" is not a question. "By how much does interval coverage fall
below nominal when X is conditioned on, at aggregate sample sizes between 200 and
2000, and does correction Y restore it" is.

**Data-generating mechanisms.** Give the full generative model: covariate
distributions with their parameters, the outcome model with its coefficients on a
named scale, the treatment effect structure, and the effect-modification
structure. Give actual numbers, not symbols. Say which quantities are varied
across scenarios, at which levels, and why those levels are the realistic ones;
anchor to published applied values where you can. State whether the design is
fully factorial and how many scenarios result.

Say what the mechanism deliberately makes true, and therefore what the study
cannot detect. If covariates are generated multivariate normal, the study says
nothing about skewed covariates, and that belongs in the protocol rather than in
a reviewer's report.

**Estimands.** Name the target quantity precisely: which population, which scale,
marginal or conditional, and for a superpopulation or the realized sample. This
distinction is usually where studies in this area go wrong. Say how the true
value is computed; if it needs a large-sample Monte Carlo evaluation rather than
a closed form, say how large and why that is enough.

**Methods.** The estimators compared, each with the exact variance estimator and
interval construction, since that is often the thing under test. Include the
naive or current-practice comparator, because a study with no status quo in it
cannot say anything is worse than what people already do. Say what constitutes
non-convergence for each.

**Performance measures.** Which ones, and which is the primary. Give the number
of replicates and DERIVE it from a target Monte Carlo standard error on the
primary measure; show the arithmetic.

**The decision rule, written before the results exist.** State what result would
count as showing the problem is real, what would count as showing it is not, and
what result would be uninformative. Give the numerical thresholds.

## What to be careful about

Name the ways this design could produce a misleading answer, and what you did
about each. Be concrete about the one that matters most here: a simulation whose
DGM is built to make the studied effect appear will make it appear.

## Output

Reply with JSON only, no prose before or after.

{{"title":"...","question":"...","aims":"...",
 "dgm":{{"covariates":"...","outcome_model":"...","treatment_effect":"...",
        "effect_modification":"...","factors":[{{"name":"...","levels":["..."],
        "rationale":"..."}}],"n_scenarios":24,"deliberately_true":"...",
        "cannot_detect":"..."}},
 "estimands":[{{"name":"...","definition":"...","true_value_computation":"..."}}],
 "methods":[{{"name":"...","point_estimator":"...","variance_estimator":"...",
        "interval":"...","is_status_quo":false,"nonconvergence":"...",
        "implementation":"..."}}],
 "performance":{{"primary":"...","secondary":["..."],
        "n_rep":2000,"n_rep_derivation":"..."}},
 "decision_rule":{{"problem_is_real_if":"...","problem_is_not_real_if":"...",
        "uninformative_if":"..."}},
 "threats":[{{"threat":"...","mitigation":"..."}}],
 "runtime_estimate":"...",
 "bears_on":[{{"id":"...","relation":"answers|answers-part|does-not-touch",
        "what":"..."}}],
 "citations":[{{"cite":"...","doi_or_url":"...","used_for":"..."}}]}}

PAYLOAD:
"""

CRITIQUE_PROMPT = """You are reviewing a simulation-study protocol before it is
run. Your job is to find what is wrong with it, not to improve its presentation.

Answer from the payload and your own knowledge of this literature. Do not use
tools, do not spawn sub-agents, do not load skills.

You are given the open problem the study is meant to settle, and the proposed
design. Assume the design was written by someone competent who wants a
particular conclusion, because that is the usual situation.

Attack it on these axes, in this order of importance.

1. **Does the study answer the stated problem, or a neighbouring one?** This is
   the most common fatal flaw and the hardest to see. A study can be internally
   flawless and measure something the catalog entry did not ask about. Compare
   the aims to the problem statement word by word.

2. **Is the finding built into the data-generating mechanism?** If the DGM makes
   the studied effect true by construction, the study demonstrates arithmetic
   rather than a property of the methods. Say precisely which parameter choice
   does this, if any.

3. **Is the estimand right, and is the true value right?** In population
   adjustment the usual errors are conflating a conditional with a marginal
   effect, conflating the realized target sample with the target superpopulation,
   and computing a "true value" that is the truth for a different population than
   the estimator targets. Check each.

4. **Is the comparison fair?** A status quo method given a worse variance
   estimator than the proposed one is a rigged comparison. Check that each method
   gets the treatment its own authors recommend.

5. **Would the decision rule actually fire?** Check the thresholds against what
   the design can resolve given its replicate count and Monte Carlo error. A rule
   that cannot be triggered by any realistic result is not a rule.

6. **Feasibility.** Is the runtime estimate honest?

Also check every citation. If a work is attributed to the wrong authors, or does
not say what the design claims, say so; that error has occurred repeatedly in
this area and is not caught by anything downstream.

For each finding give a severity:
  fatal      the study would not answer the problem; must be fixed before running
  serious    the answer would be materially wrong or misread
  minor      worth fixing, does not threaten the conclusion
  limitation not fixable within this design; must be stated in the protocol

Be willing to say the design is sound on an axis. A critique that finds
something fatal on every axis is not a critique.

## Output

Reply with JSON only, no prose before or after.

{"verdict":"sound|needs-revision|unsound",
 "summary":"three or four sentences",
 "findings":[{"axis":"answers-problem|dgm-builds-in-finding|estimand|fair-comparison|decision-rule|feasibility|citation",
   "severity":"fatal|serious|minor|limitation","what":"...","fix":"..."}],
 "citation_problems":[{"cite":"...","problem":"..."}],
 "what_is_sound":["..."]}

PAYLOAD:
"""


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
                try:
                    return json.loads(blob)
                except json.JSONDecodeError:
                    pass
                start = None
    return None


def call(prompt, payload, tag, slug, timeout=5400):
    os.makedirs(OUT, exist_ok=True)
    full = prompt + json.dumps(payload, ensure_ascii=False, indent=1)
    open(os.path.join(OUT, f"{slug}-{tag}-prompt.txt"), "w", encoding="utf8").write(full)
    cmd = ["codex", "exec", "-m", MODEL, "-c", f"model_reasoning_effort={EFFORT}",
           "-s", "read-only", "--skip-git-repo-check", "--ignore-rules", full]
    print(f"  {MODEL} at {EFFORT} effort, {tag} pass ...", flush=True)
    p = subprocess.run(cmd, capture_output=True, timeout=timeout,
                       stdin=subprocess.DEVNULL)
    out = p.stdout.decode("utf8", "ignore")
    open(os.path.join(OUT, f"{slug}-{tag}-raw.txt"), "w", encoding="utf8").write(out)
    d = extract_json(out)
    if not d:
        sys.exit(f"no JSON in {tag} output; see {OUT}/{slug}-{tag}-raw.txt")
    json.dump(d, open(os.path.join(OUT, f"{slug}-{tag}.json"), "w", encoding="utf8"),
              indent=1, ensure_ascii=False)
    return d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--problems", nargs="+")
    ap.add_argument("--slug", required=True)
    ap.add_argument("--critique", action="store_true")
    a = ap.parse_args()

    P = {p["id"]: p for p in json.load(open(REGISTRY, encoding="utf8"))}

    if a.critique:
        design = json.load(open(os.path.join(OUT, f"{a.slug}-design.json"),
                                encoding="utf8"))
        ids = json.load(open(os.path.join(OUT, f"{a.slug}-problems.json"),
                             encoding="utf8"))
        d = call(CRITIQUE_PROMPT,
                 {"problems": [P[i] for i in ids], "proposed_design": design},
                 "critique", a.slug)
        print(f"\nverdict: {d.get('verdict')}")
        print(d.get("summary", ""))
        for f in d.get("findings", []):
            print(f"\n  [{f.get('severity','?').upper()}] {f.get('axis')}")
            print(f"    {f.get('what')}")
            print(f"    fix: {f.get('fix')}")
        for c in d.get("citation_problems", []):
            print(f"\n  [CITATION] {c.get('cite')}: {c.get('problem')}")
        return

    if not a.problems:
        sys.exit("pass --problems")
    missing = [i for i in a.problems if i not in P]
    if missing:
        sys.exit(f"not in registry: {missing}")
    os.makedirs(OUT, exist_ok=True)
    json.dump(a.problems, open(os.path.join(OUT, f"{a.slug}-problems.json"), "w",
                               encoding="utf8"))
    d = call(DESIGN_PROMPT.replace("{ENVIRONMENT}", ENVIRONMENT),
             {"target": P[a.problems[0]],
              "related": [P[i] for i in a.problems[1:]]},
             "design", a.slug)
    print(f"\ntitle: {d.get('title')}")
    print(f"question: {d.get('question')}")
    print(f"scenarios: {d.get('dgm', {}).get('n_scenarios')}, "
          f"n_rep: {d.get('performance', {}).get('n_rep')}")
    print(f"runtime: {d.get('runtime_estimate')}")
    for m in d.get("methods", []):
        print(f"  method: {m.get('name')}"
              + ("  [status quo]" if m.get("is_status_quo") else ""))


if __name__ == "__main__":
    main()
