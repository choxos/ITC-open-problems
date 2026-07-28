#!/usr/bin/env python3
"""Check a response letter against the manuscript before the letter is sent.

This program has published a response describing a change the manuscript did not
contain four times across four studies. The first three were changes that were
never made. The fourth was different and is the reason this file has two halves:
the round-one check verified that every NEW statement was present, passed
thirty-four of thirty-four, and did not notice that the retracted claim was still
sitting in the abstract. A corrected section and an uncorrected abstract both
counted as success.

So there are two lists. POSITIVE is what must now appear. NEGATIVE is what must
now be gone. A response letter is not written until both pass.

  python3 review/verify-response.py
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
STUDY = os.path.dirname(HERE)


def flat(s):
    """Collapse whitespace so a check cannot fail on a line break.

    Study 2 of this program had an edit silently match nothing because a
    paragraph was wrapped differently from the pattern looking for it, and the
    check that should have caught it failed for the same reason. Prose that has
    been reflowed is the same prose.
    """
    return re.sub(r"\s+", " ", s)


def read(*p):
    return flat(open(os.path.join(STUDY, *p), encoding="utf8").read())


QMD = read("manuscript", "manuscript.qmd")
MD = read("out", "DIA-03.md")
PROTO = read("protocol.md")
ANALYSIS = read("R", "05-analyze.R")

POSITIVE = [
    # round one
    ("arm imbalance uses no outcome", QMD, "The arm-imbalance term uses no outcome at all"),
    ("arm imbalance scored", ANALYSIS, "auc_arm = wauc(s, M$big_arm"),
    ("arm imbalance in output", MD, "vs arm imbalance"),
    ("noise variance identity", QMD, r"\mathrm{ESS}_A"),
    ("what is scored, stated", QMD, "not in the anchored $A$ versus $B$ contrast"),
    ("anchored contrast reported", ANALYSIS, "anchored-operating-points.csv"),
    ("proposal labelled outcome-assisted", QMD, "outcome-model-assisted"),
    ("verdict restated as cutoffs", QMD, "no evaluated fixed cutoff met the registered operating"),
    ("calibration model form stated", QMD, "with a single\nlinear term and no splines"),
    ("split defect disclosed", QMD, "every odd cell had ratio 1.00 and every even cell"),
    ("leave-one-factor-level-out", ANALYSIS, "FOLDS <- do.call"),
    ("residual SD correction", QMD, "0.20 is a fifth of the **residual** standard deviation"),
    ("predictive-value downgrade", QMD, "Both spans are variation in **predictive value**"),
    ("matched-moment claim bounded", QMD, "conditional on\naccepting a solution to the calibration equations"),
    ("practice claim softened", QMD, "We have not surveyed how\nappraisal committees actually use these numbers"),
    ("DSU guidance cited", QMD, "@phillippo2018"),
    ("Kish cited", QMD, "@kish1965"),
    ("transportability literature cited", QMD, "@stuart2011; @tipton2014"),
    ("ADEMP cited in manuscript", QMD, "@morris2019"),
    ("protocol estimator count", PROTO, r"128 \times 4000 \times 4 = 2{,}048{,}000"),
    ("protocol linearity line", PROTO, "All four estimators are"),
    ("replicate-count caveats", PROTO, "at 1% prevalence the same formula"),
    ("threshold provenance note", PROTO, "Only the balance cuts of"),
    ("coverage reported", MD, "MAIC, means and SDs"),
    ("extensions named", QMD, "Extensions this study does not attempt"),
    ("mechanism gaps are point estimates", QMD, "point estimates against a registered threshold"),
    # round two
    ("systematic-bias section", QMD, "## Systematic bias, with the cell as the unit"),
    ("systematic-bias analysis", ANALYSIS, "cell_sys <- do.call"),
    ("systematic-bias table rendered", MD, "AUROC vs systematic bias"),
    ("retitled", QMD, "tracks the error an analysis got by chance"),
    ("dichotomy withdrawn", QMD, "went further\nthan these results support and has been withdrawn"),
    ("tables reconciled", QMD, "Both are correct for what\nthey are; neither is the other"),
    ("functional-form caution", QMD, "the wrong functional form in the held-out setting"),
    ("abstract rewritten", QMD, "Two of the three pieces are functions of covariates"),
    ("claim-4 comparator named", QMD, "compares our statistic against effective sample size as a percentage"),
    ("decision-curve alias explained", QMD, "is not a fourth statistic"),
    ("protocol calibration method updated", PROTO, "leave-one-factor-level-out over"),
]

NEGATIVE = [
    ("'only piece a covariate diagnostic could know'", QMD, "only piece a covariate"),
    ("the same, in the rendered manuscript", MD, "only piece a covariate"),
    ("'is a variance statistic, and it is being read'", QMD, "is a variance statistic, and it is being"),
    ("'no function of $X$, the weights ...'", QMD, "no function of $X$, the weights and a published"),
    ("the withdrawn title", MD, "is a variance statistic being read as a bias warning"),
    ("'a stronger result than the one registered'", QMD, "stronger result than the one registered"),
    # round two: the same failure again, in sections the round-one check did not read
    ("'removes the dependence ... entirely' in the introduction", QMD, "chosen frequencies entirely"),
    ("protocol still describing the replicate split", PROTO, "fitted on odd-numbered replicates"),
    ("caption claiming claim-4 numbers are in the stratum table", QMD, "This is where the two numbers behind mechanism claim 4 live"),
    ("the confounded odd/even cell split, in code", ANALYSIS, 'split_by = c("cell", "replicate")'),
]


def main():
    bad = 0
    print("must be present:")
    for name, hay, needle in POSITIVE:
        ok = flat(needle) in hay
        bad += not ok
        print(f"  {'ok     ' if ok else 'MISSING'}  {name}")
    print("\nmust be gone:")
    for name, hay, needle in NEGATIVE:
        ok = flat(needle) not in hay
        bad += not ok
        print(f"  {'ok     ' if ok else 'PRESENT'}  {name}")
    print(f"\n{len(POSITIVE) + len(NEGATIVE) - bad} of "
          f"{len(POSITIVE) + len(NEGATIVE)} pass")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
