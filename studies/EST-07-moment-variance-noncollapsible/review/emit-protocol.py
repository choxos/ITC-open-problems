#!/usr/bin/env python3
"""Generate protocol.md from results/registered-design.json.

WHY THIS EXISTS, AND WHY IT IS NOT A CONVENIENCE. CMP-14 spent thirteen rounds of
critique and roughly a third of its findings were one defect: a number typed into
the document rather than read from the code. Its fix was to type the number and
then assert it back, which catches drift but leaves a window in which a wrong
number is typed and asserted against a stale export.

Every MEASUREMENT is interpolated from the export at generation time, so the
failure mode is not "the document drifted" but "the document was regenerated",
which is visible in git.

ROUND 2 OF CRITIQUE FOUND THE LIMIT OF THAT GUARANTEE, and it is worth stating
plainly because it is the reason this file was rewritten. Interpolating every
NUMBER does nothing about the SENTENCES around them. Between rounds the code
changed a great deal: an estimand was withdrawn, the quadrature rule was replaced,
the perturbation interval was rebuilt twice, the binary covariate's law was
corrected, the resample count went from 50 to 800, and a runner and analysis were
written. This generator was not touched, so the document went on describing a
study that no longer existed, and all three reviewers independently found
contradictions inside it: prose calling a link conservative beside a table showing
otherwise, a floor "derived" by a chain that no longer yields it, a resample
criterion replaced two rewrites earlier, and software described as missing that
had been written.

The lesson is that a generated document is only as current as its generator, so
this file now carries the study's narrative and must be edited whenever the design
moves. The verifier asserts what it can, but no verifier catches a fluent sentence
about a study that is not this one.

    Rscript R/12-export.R
    python3 review/emit-protocol.py

THE PROTOCOL NAMES THIS FILE. Deleting it makes the protocol's provenance claim
false.
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
D = json.loads((ROOT / "results" / "registered-design.json").read_text())


def lv(x):
    """Render a level vector the way the design table reads it."""
    return ", ".join(str(v) for v in (x if isinstance(x, list) else [x]))


def build() -> str:
    d = D
    L = d["levels"]
    osl = d["omitted_share_by_link"]
    p1f = d["p1_forced_by"]
    pmin = round(100 * d["perturb_share"]["min"])
    pmax = round(100 * d["perturb_share"]["max"])

    p7 = {r["link"]: r for r in d.get("p7_by_link", [])}
    p7_rows = "\n".join(
        f"| `{k}` | {v['max_abs_gradient']:.3g} | "
        f"{'vanishes' if v['vanishes'] else 'does not vanish'} |"
        for k, v in p7.items())

    p5_rows = "\n".join(
        f"| {r['B']} | {r['coverage']} | {r['mean_width']} | {r['cov_diff']} |"
        for r in d.get("p5_by_b", []))

    p6 = d.get("p6_by_cell", [])
    p6_worst = max(p6, key=lambda r: r["share"]) if p6 else None
    gt = d.get("gate_terms", {})

    return f"""# Protocol: what target-moment uncertainty costs when the scale is non-collapsible

**Target problem.** EST-07 *Reported target moments are treated as known constants*.
Successor to MIS-03, which answered the same question under an identity link.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

**Registration status: NOT YET REGISTERED.** **This document is the design of
record.** Every number below is interpolated from
`results/registered-design.json` by `review/emit-protocol.py` and checked by
`review/verify-protocol.py`. `DESIGN.md` holds the original rationale and is
superseded on the points its own header lists; it is hand-written and cannot be
checked against the code, which is why it is not the authority.

**What exists.** The data-generating mechanism, both truths, the gradient
machinery, all six of the methods in the table below, the six probes set out in
section 2 plus the cost measurement in section 6, the runner
(`R/15-run.R`), the analysis with clustered Monte Carlo error (`R/16-analyze.R`),
and the export and verification harness. **What does not exist is the ML-NMR
arm.** No replicate of the registered grid has been run.

---

## 1. The claim, restated so it can be false

An analyst receives a published baseline table for a target trial: means, standard
deviations, an effect, a sample size. MAIC reweights the source until the weighted
covariate moments equal the reported ones. Every published variance estimator then
treats those reported moments as **known constants**.

They are estimates from {lv(L["nT"])} people. The question is what that costs.

**Prediction 1, stated so that it is about the right thing.** Under a
non-collapsible link the estimand
Delta(F_T) = g(int mu_1 dF_T) - g(int mu_0 dF_T) is a functional of the whole
target covariate law, not of its first two moments: two laws agreeing on every
reported moment can have different Delta.

Earlier drafts went straight from there to "so no variance indexed by the reported
moments can be correct". That is the same slide from identification to variance
that got the second prediction withdrawn, and a reviewer raised it twice. A method
that matches reported moments is not merely reporting the wrong WIDTH; it is
centered on a different QUANTITY, the moment-matched contrast rather than
Delta(F_T). The consequence is a bias, and the coverage deficit a bias produces
does not shrink as the target grows, because the gap between the two quantities is
not a sampling error.

So the prediction is: **reported-moment methods target the moment-matched
contrast, and their coverage of Delta(F_T) fails by an amount that persists as nT
grows.** That is what the two registered estimands separate and what the growth
ladder measures. It is falsified if coverage of the superpopulation estimand
approaches nominal along the ladder.

**A second prediction was registered and has been withdrawn.** It said the
sampling variance induced by estimated target moments is governed by the gradient
of the estimand along a parametric family of covariate laws, and that a mismatch
between that gradient and the estimator's gradient measures an error in the
reported variance. It does not. The superpopulation estimand is fixed across
replicates; a mismatch between those two gradients indicates identification bias,
not an incorrect variance. Probe P3 was built to test it and never could. P3 is
retained below as an **identification** probe, which is what it measures.

---

## 2. What the probes establish, before any replicate

### P1: the integration order, and a rule that was wrong rather than coarse

Registered order **{d["quad_order"]}**, forced by the `{p1f["link"]}` /
`{p1f["shape"]}` cell. Continuous shapes need orders
{d["continuous_order_range"]["min"]} to {d["continuous_order_range"]["max"]}.

The order was 48 for two rounds because the probe took its reference from the
highest order it ran, so "48 is stable" reduced to "48 agrees with 64". Two coarse
rules can agree and both be wrong. Against an independent reference, order 48
deviated by 3.03e-04, three times the registered tolerance of {d["quad_tol"]}.

The cause was not node count. The `mixed` shape makes one covariate binary with a
step function, and Gauss-Hermite rests on polynomial exactness, so it degraded to
roughly 1/n. The integral is now **split at the discontinuity**, whose location is
known exactly, and each side integrated with a rule that is exact for smooth
integrands. The binary covariate is integrated exactly rather than approximated.
The rule is validated against **independent Monte Carlo**, not against itself,
and the check RUNS inside P1 rather than being remembered from a console session:
on the {d["p1_mc_check"]["link"]}/{d["p1_mc_check"]["shape"]} cell at order
{d["p1_mc_check"]["order"]} the quadrature gives {d["p1_mc_check"]["quad"]} against
a Monte Carlo estimate of {d["p1_mc_check"]["mc"]} with standard error
{d["p1_mc_check"]["mc_se"]}, **{d["p1_mc_check"]["z"]} standard errors apart**. P1
stops and registers no order if they ever disagree by more than three.

The `mvnorm` law reduces to one dimension exactly, agreeing with the product rule
to {d["reduction_agreement"]}. The product rule is used only for the non-normal
shapes, at {d["nodes_product_3d"]:,} nodes for the {d["n_covariate"]} covariates
the design fixes. The `outside` arm carries a fourth covariate and is crossed with
`mvnorm` only, so it uses the exact reduction and never the product rule; the
{d["nodes_product_4d"]:,}-node figure is what the reduction avoids there, not a
count this study pays.

### P2: which cells are worth running

**{d["n_cells"]} of {d["n_cells_realized"]} realized cells** are run: those whose
omitted-variance share reaches {d["min_omitted_share"]:.4f}, plus a growth ladder
retained regardless of share.

**THE LADDER IS EXEMPT FROM THE GATE, and prediction 1 is why.** The prediction
says the coverage deficit does not close as the target grows. The share falls as
the target grows, because the moment term scales with 1/nT while the source term
scales with 1/nS, so the gate drops the large-target cells first: exactly the ones
the prediction is about. A design that screens on the effect being large cannot
test a claim that the effect persists when it is small. The ladder holds every
other factor at its middle and walks the target size, and the analysis reports it
as the prediction-1 test rather than pooling it with the powered grid.

The floor is **solved from the criterion, not asserted to follow from it**.
Omitting a fraction f of the variance reports a standard error of sqrt(1-f) times
the truth, so coverage becomes 2*Phi(1.96*sqrt(1-f))-1. The smallest coverage
shift worth claiming is {d["min_coverage_shift"]}, which needs
f = {d["min_omitted_share"]:.4f}. An earlier floor of 0.04 was asserted to follow
from the same sentence and does not: it corresponds to a shift of 0.0048, one
Monte Carlo error rather than the two the criterion asks for.

**The denominator is the whole variance of the anchored contrast.** The gate
previously screened on the omitted variance over omitted-plus-source, leaving out
the target trial's own variance and its covariance with the reported moments, both
of which are in the interval. A floor solved from a coverage shift has to be
applied to a fraction of the total, or it screens on a different quantity than the
criterion names. Median terms across the realized grid: omitted {gt.get("v_omit")},
source {gt.get("v_src")}, target-trial {gt.get("v_bc")}, cross {gt.get("v_cross")}.

Shares by link (min, median, max):

| link | min | median | max |
|---|---|---|---|
| `identity` | {osl["identity"]["min"]} | {osl["identity"]["median"]} | {osl["identity"]["max"]} |
| `logit` | {osl["logit"]["min"]} | {osl["logit"]["median"]} | {osl["logit"]["max"]} |
| `cloglog` | {osl["cloglog"]["min"]} | {osl["cloglog"]["median"]} | {osl["cloglog"]["max"]} |

### P3: an identification probe, not a variance probe

P3 compares the estimand gradient with the estimator gradient in the estimator's
own coordinates, means and raw second moments. It was registered as a test of the
withdrawn second prediction and is retained only for what it does measure: whether
the two gradients agree, which is a statement about identification.

The identity link is the case where the answer is known. The gap shrinks
monotonically with source size, from {d["p3_identity_convergence"][0]["gap"]:.4g}
to {d["p3_identity_convergence"][-1]["gap"]:.4g}, which is what a correct
implementation does and a wrong one does not.

**No claim about interval direction is made from P3.** An earlier draft read a
link-specific direction off these ratios and reported it as a finding. It was an
artifact of comparing gradients taken in different coordinates, means and standard
deviations against means and raw second moments, with no Jacobian between them.

### P5: how many resamples the perturbation interval needs

Registered **B = {d["n_perturb"]}**, and this is the study's whole budget lever:
the perturbation arm is {pmin}% to {pmax}% of the cost.

Sizing it produced three answers and the first two were wrong. **50** came from a
probe watching the variance of the draws converge, a quantity that generates no
interval anywhere in the study once the arm reports percentile limits. **25** came
from a probe watching coverage converge while the interval was so over-wide that
coverage could not move, at 0.9933 against a nominal {d["nominal"]}; a criterion
evaluated on a saturated quantity passes everything.

**{d["n_perturb"]}** comes from measuring the corrected interval against an
independent B = 3200 reference, with the limits at every B read from nested
subsamples of one draw set so the comparison is paired:

| B | coverage | mean width | paired coverage difference |
|---|---|---|---|
{p5_rows}

An empirical quantile from few draws is biased **inward**, so a small B does not
merely add noise, it narrows every interval systematically. At B = 50 the arm
undercovers by more than three points from its own resampling budget alone, and
the study would have reported that as a property of the method.

**The selection rule, stated rather than implied.** A B is sufficient when two
conditions hold together: the paired coverage difference from the reference, plus
that difference's Monte Carlo error, is inside the {d["min_coverage_shift"]} shift
the study is willing to interpret; and the mean width is within 1% of the
reference width. The second condition exists because the first saturated once, on
an interval so over-wide that coverage could not move. **{d["n_perturb"]}** is the
smallest value in the grid meeting both.

### P6: a covariance no published method carries, and it is too large to drop

The reported target moments and the target trial's own effect are computed from
**the same participants**, so the anchored contrast carries a cross term
-2 Cov(theta_AC, theta_BC) that every published estimator drops.

**A WORD USED TWO WAYS, corrected.** For the cell gate, "clearing the floor" means
the omitted variance is LARGE enough that dropping it would move coverage, so the
cell is worth running. For this probe the same comparison means the opposite
thing: a cross term above the floor is a term too large to ignore. Three reviewers
read the old sentence as self-contradictory and they were right. The comparison is
therefore stated without that word.

The worst cell reaches **{d["p6_worst_share"]}** including Monte Carlo error
against the {d["min_omitted_share"]:.4f} threshold, so **the cross term is above
the threshold and cannot be ignored**.{
"" if d.get("p6_ok") is False else " (P6's stored verdict disagrees with this sentence; regenerate.)"}
The term is largest on the identity link when the target shares the source's
modification in full.

An earlier draft added that the share "does not shrink as the target grows,
because both sides of the ratio scale with 1/nT". That was true when the
denominator was the omitted plus source variance and is **not** true now: the
denominator is the whole variance of the contrast, whose source component scales
with 1/nS rather than 1/nT. The share does move with the target size, and the
growth ladder below is what measures it.

So it is carried rather than argued away. `R/14-calibrate-xcov.R` calibrates it per
target cell and the `maic_xcov` arm supplies it, which is what lets a coverage
deficit be attributed: the difference from `maic_entropy` is the cross term, and
what remains is what identification has to explain.

### P7: the null control, in the only form that is true

A control was registered saying that with no effect modification the omitted
variance is exactly zero at every target size **and on every scale**, so that a
violation would indicate a defect in the source variance.

**That is false on both curved links**, and a correct implementation would have
failed it. With beta_EM = 0 the conditional contrast is constant in the
covariates, but the marginal contrast still depends on the target law through the
prognostic term. That is non-collapsibility itself.

| link | max abs gradient at beta_EM = 0 | |
|---|---|---|
{p7_rows}

**These are gradient magnitudes, not variances**, and the distinction matters
after the second prediction was withdrawn for exactly that kind of slide. What the
table shows is that d Delta / d m does not vanish on the curved links. The omitted
variance is J' Omega J / nT, which is a positive definite form in that gradient, so
a gradient bounded away from zero implies an omitted variance bounded away from
zero; the table establishes the premise and not the quantity itself.

The control now reads: the gradient vanishes on the **collapsible** link and on no
other. A nonzero identity gradient is an implementation defect; nonzero curved
gradients are the subject of the study. This is also a finding rather than a
repair, and it is not what the catalog entry expects: on a curved link,
target-moment uncertainty does not need effect modification to bite.

---

## 3. Estimand

Two, and **both are computed on every replicate** by `R/15-run.R`:

- **superpopulation**: Delta(F_T) in the target superpopulation;
- **finite_target**: the same contrast in the target sample actually drawn.

Reporting both is what separates an interval that is too narrow from an interval
aimed at a different quantity. Reporting one cannot distinguish them.

The contrast is anchored: theta_AC(m_hat) - theta_BC_hat, on the link's own scale.

---

## 4. Design

Held fixed: {d["n_covariate"]} covariates ({d["n_covariate"] + 1} in the `outside`
arm, which is crossed with `mvnorm` only), overlap at a standardized difference of
{d["overlap_smd"]} on **every** covariate, and a true covariate correlation of 0.3.

| factor | levels |
|---|---|
| link | {lv(L["link"])} |
| target size nT | {lv(L["nT"])} |
| source size nS | {lv(L["nS"])} |
| alignment k | {lv(L["k"])} |
| covariate shape | {lv(L["shape"])} |
| assumed correlation | {lv(L["corr_assumed"])} |
| modifier span | {lv(L["modifier_span"])} |
| anchored | {lv(L["anchored"])} |
| target baseline shift | {lv(L["baseline_shift"])} |

**The last two factors were added after the probe phase and they change what the
study is.** `anchored` is crossed with the whole core rather than varied around a
middle, because the two settings differ by an order of magnitude in what the
moment term is a share of. The target's baseline risk exists because the DGM
previously gave source and target the same intercept, so their control arms were
identical, the anchored contrast differenced away a quantity that was already
equal, and the two estimands coincided exactly. Anchoring exists precisely because
trials differ in baseline risk, and without a shift the unanchored arm would carry
none of its real risk.

**Every cell the gate can place above the floor is unanchored**, and the
classification accounts for the fact that each share is itself measured with
error. Re-measuring one borderline cell six times independently gave shares from
0.0368 to 0.0675, a standard deviation of 0.0118, so a gate treating shares as
exact was assigning cells near the floor by chance. Each cell's share now carries
a bootstrap standard error and cells fall into three classes:
{", ".join(f"{v} {k}" for k, v in d.get("cell_classes", {}).items())}.

The split is not a close call. Of the
{sum(d.get("clear_cells_by_arm", {}).values())} cells placed clearly above the
floor, {" and ".join(f"{v} are {k}" for k, v in d.get("clear_cells_by_arm", {}).items())};
**every anchored cell in the realized grid falls clearly below it, and not one is
even borderline.** Borderline cells are run rather than dropped, because running a
weak cell costs compute while dropping a strong one costs the finding, and they
are flagged so no claim about the boundary rests on them.
Median share of the interval's variance carried by the moment term, by link:

| link | unanchored | anchored |
|---|---|---|
| `identity` | 0.3612 | 0.0395 |
| `cloglog` | 0.1570 | 0.0100 |
| `logit` | 0.0961 | 0.0079 |

So the effect the catalog entry names is material without an anchor and immaterial
with one, on the curved links as well as the collapsible one. In an anchored
comparison the target trial's own effect carries a median
{d.get("anchored_decomposition", {}).get("target_trial")} of the interval's
variance, taken as the median of WITHIN-CELL shares across the
{d.get("anchored_decomposition", {}).get("n_cells")} anchored cells rather than as
a ratio of medians over the whole grid, which is what an earlier draft reported.
The moment term's median share ranges from
{min(v for v in [osl[k]["median"] for k in osl]):.4g} to
{max(v for v in [osl[k]["median"] for k in osl]):.4g} across links. An earlier
draft rounded that to "about 1%", which understates the identity arm. That is the
study's first result and it came out of the probe phase, before any replicate was
run.

**The overlap is realized, not merely registered.** The `mixed` arm ran at a
standardized difference of 0.001 on its binary covariate against the registered
{d["overlap_smd"]}, because the sampler thresholded the centered draw and gave the
same prevalence in both populations, and because a second implementation of the
same law meant the truth was integrated over a law the sampler never drew. Since
that covariate carries the effect modification, the arm tested nothing. There is
now one definition of the law, a cut that is the same constant in both
populations, and a latent shift solved so the realized difference is the
registered one.

**The `outside` arm is outside.** It was registered to place one modifier beyond
the matched moment set, and the balancing function matched it and the target
reported it, making the arm identical to `inside` with one more matched modifier.
The reported set is now the single place that defines what a baseline table
contains, and the balancing function, moment vector, borrowed correlation and STC
model all follow it.

Cells by source size: {", ".join(f"{k}: {v}" for k, v in d["cells_by_source"].items())}.

---

## 5. Methods

| method | what it does |
|---|---|
| `maic_fixed` | status quo: reported moments treated as constants |
| `maic_entropy` | adds the moment term, the ported asymptotic variance |
| `maic_oracle` | the same with the target's **population** correlation supplied |
| `maic_xcov` | adds the cross term P6 found no method carries |
| `maic_perturb` | percentile interval from resampling, B = {d["n_perturb"]} |
| `stc` | conditional outcome model, marginalized over the reported law |

`maic_fixed`, `maic_entropy`, `maic_oracle` and `maic_xcov` come off **one** fit
and share a point estimate, so contrasts among them are comparisons of intervals
and nothing else.

**`maic_perturb` is not in that set and is not in the paired test.** It resamples
the source, refits per draw, and reports percentile limits, so it has no standard
error and its interval is not centered on the shared estimate. Against the others
it is a comparison of procedures. It is reported in the same table and tested
separately.

The oracle arm supplies the target **population** correlation, measured from the
law the sampler uses. It previously supplied the correlation of the latent
Gaussian, which survives to the covariates only under `mvnorm`: dichotomization
attenuates it to about 0.238 against a supplied 0.30. An arm that exists to
isolate the correlation component was injecting a correlation the target does not
have.

**What the entropy arm can settle.** If it reaches the registered coverage band
across the grid, the moment term suffices *in these conditions* and the study
reports that as a negative result about its own prediction. If it closes part of
the deficit and not all, the split is the contribution, and `maic_xcov` and
`maic_oracle` say how much of the residual is the cross term and the correlation
rather than identification. Neither branch settles the catalog's porting claim in
general, and the analysis will not report it as if it did.

---

## 6. Replicates, error and cost

**The registered coverage band is {d["cover_band"][0]} to {d["cover_band"][1]}**,
**derived rather than typed**: its half-width is the multiple of the delivered
Monte Carlo error, {d["coverage_mcse_at_n"]}, at which the expected number of
spurious band failures across all {d["n_cells"]} cells stays inside a registered
budget of {d.get("false_failure_budget")}. A larger grid therefore earns a wider
band instead of quietly admitting more false rejections. It is a tolerance for
Monte Carlo noise and not a claim that 0.936 coverage is acceptable in practice.
It is two-sided: an interval that is too wide fails it exactly as an interval that is
too narrow does, because reporting only undercoverage would let a conservative
method pass as correct.

{d["n_rep"]} replicates per cell. The coverage Monte Carlo error the design
**targets** is {d["coverage_mcse_target"]}; the error {d["n_rep"]} replicates
actually **deliver** is {d["coverage_mcse_at_n"]}, and that is the figure any
claim about resolving a coverage difference is judged against.

Common random numbers block `{lv(d["crn_blocks"])}`, so cells differing only in
the assumed correlation see identical data. Monte Carlo error for every method
contrast is therefore computed from the **per-replicate difference**, not from an
independence formula, which would overstate the error of a paired contrast.

Measured cost: **{d["core_hours"]} core-hours** for the MAIC and STC arms, at
B = {d["core_hours_n_perturb"]}, which is the registered value rather than a
different one scaled. The perturbation arm is {pmin}% to {pmax}% of it.

**The cost rose by {d.get("budget_change_pct")}%** against the {d["core_hours_at_typed_200"]}
core-hours measured when B was typed at 200 and the grid was smaller. Sizing B
honestly took it to {d["n_perturb"]}, and the corrected `mixed` arm added cells.
An earlier draft reported this as a saving.

---

## 7. What this cannot settle

- **No ML-NMR arm.** It is the method most likely to be correct here, and its
  absence is a scope limit, not an oversight resolved elsewhere.
- **One overlap level and one true correlation.** Both are fixed at
  {d["overlap_smd"]} and 0.3.
- **Normal-law reconstruction.** Every method reconstructs the target law from
  moments assuming a Gaussian copula; the `lognormal` and `mixed` arms vary the
  truth away from that, but the reconstruction itself is never varied.
- **The cross term is supplied by an oracle.** `maic_xcov` shows what carrying it
  would buy. No analyst can compute it from a published baseline table, so it is
  a decomposition, not a recommendation.
- **The dropped cells.** {d["n_cells_realized"] - d["n_cells"]} of
  {d["n_cells_realized"]} cells fall below the floor and are not run. The study
  therefore says nothing about most conditions where the omitted variance is
  small, **with one deliberate exception**: the growth ladder is retained below
  the floor precisely so that the persistence claim can be tested where the effect
  is small by construction. An earlier draft of this section revoked the ladder's
  purpose two sections after registering it.
"""


if __name__ == "__main__":
    out = ROOT / "protocol.md"
    text = build()
    out.write_text(text)
    print(f"rewritten: {out.name} ({len(text):,} bytes)")
