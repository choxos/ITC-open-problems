# Prior-sensitivity diagnostics detect a weak likelihood, not a wrong
answer
Ahmad Sofi-Mahmudi
2026-07-29

# Abstract

A proper prior yields a proper posterior even along directions a
likelihood cannot identify, so a narrow credible interval in a
population-adjusted network can reflect the prior rather than the
evidence, and a clean $\hat R$ does not rule it out. Catalog entry
CMU-02 says the diagnostics that would expose this already exist and
have never been calibrated here.

We calibrate them. In a conjugate Gaussian network where the posterior
and every power-scaled posterior are exact, so that no diagnostic is
contaminated by Monte Carlo error, we measure sensitivity and
false-warning rate for prior-to-posterior contraction, a prior-only
benchmark, power-scaling sensitivity, a tight-and-loose prior refit, and
a composite of the four, against a reference defined by consequence:
whether the 95% credible interval misses the truth.

**At the thresholds the literature suggests, they fail.** Intervals
missed on 56,210 of 480,000 replicate-contrasts. Pairing each warning
with whether that replicate’s interval missed, the composite has
sensitivity 0.366 (Monte Carlo SE 0.002) at a false-alarm rate of 0.158.
Outside two engineered geometries where the likelihood was deliberately
made uninformative, sensitivity falls to 0.127. The only rule with
useful sensitivity, refitting under halved and doubled prior scales,
fires on 53% of the replicates whose intervals were fine.

**The statistics are not the problem; the thresholds are, and something
else is.** Used as continuous scores rather than as rules, the same
quantities discriminate moderately: area under the curve 0.511 to 0.781
for predicting a miss. So a better-calibrated threshold would do better,
and we do not claim otherwise.

**What no threshold can repair** is that these diagnostics measure the
prior’s *influence* and the harm here comes from the prior’s *location*.
With disconnected evidence, a tight prior centered at zero and a true
interaction of 0.40, coverage is 0.000 at 100 participants per arm with
the composite warning on 0.984 of replicates; at 400 per arm coverage is
0.000 and the warning rate is 0.011. More data lets the posterior
contract, which every one of these diagnostics reads as reassurance,
while none of them can see that the prior is centered in the wrong
place.

# The problem

Bayesian evidence synthesis in a population-adjusted network routinely
estimates quantities the data barely identify: an interaction informed
only by between-study variation, a contrast across a gap in the network,
a component effect appearing in few arms. A proper prior with finite
marginal likelihood produces a proper posterior along every one of those
directions. The output is formatted identically to an estimate the data
determined.

Convergence diagnostics do not help, because they interrogate the
sampler rather than the likelihood’s contribution. CMU-02 states the
position precisely: the diagnostics that would expose the problem exist
as general Bayesian workflow tools, power-scaling sensitivity
([1](#ref-kallioinen2024)) with `priorsense` on CRAN and `multinma`’s
prior-versus-posterior comparison, and what is missing is their
application to these models. The entry adds the reason it matters:
**prior dominance grows with scenario severity, so a single check on one
benign dataset says nothing about the cases that matter.**

That is an operating-characteristics question, and this study answers
it.

# Design

The protocol was registered before the run at
`studies/CMU-02-prior-driven-posteriors/protocol.md`. Reporting follows
ADEMP ([2](#ref-morris2019)).

## Why the model is exact rather than sampled

Every piece of evidence reduces without loss to a normal observation of
a linear function of the treatment parameters, so with
$z \sim N(H\theta, V)$ and $\theta \sim N(m_0, S_0)$,

<span id="eq-post">$$S = (H^\top V^{-1} H + S_0^{-1})^{-1}, \qquad m = S(H^\top V^{-1} z + S_0^{-1} m_0). \qquad(1)$$</span>

This is deliberate. The study evaluates diagnostics that detect when a
posterior is held up by its prior. Were the posterior itself a Monte
Carlo approximation, every diagnostic would carry sampling noise of
unknown size and a failure to detect could not be separated from a
failure to converge. With
<a href="#eq-post" class="quarto-xref">Equation 1</a> a failure belongs
to the diagnostic. Power-scaling is exact for the same reason: raising a
normal prior to the power $\alpha$ multiplies its precision by $\alpha$,
so a power-scaled posterior is another closed-form Gaussian rather than
an importance-weighted resample.

Parameters are $\theta = (d_B, d_C, d_D, \gamma_B, \gamma_C, \gamma_D)$
with A as reference, where $\gamma_t$ is the change in the conditional
treatment effect per standard deviation of the covariate. Between-trial
heterogeneity is 0.10, treated as known.

## Factors

| Factor | Levels |
|----|----|
| Evidence about treatment C | within-IPD, AgD-wide, AgD-narrow, AgD-flat, disconnected |
| Participants per arm | 100, 400 |
| True $\gamma_C$ | 0, 0.40 |
| Prior scale | tight, regular, weak |
| Target population mean covariate | 0, 0.75 |

120 scenarios, 2000 replicates, two contrasts: the interaction
$\gamma_C$ and the target-population marginal C versus B mean difference
a committee would read,

<span id="eq-delta">$$\Delta_{CB}(\mu_X) = (d_C - d_B) + (\gamma_C - \gamma_B)\,\mu_X, \qquad(2)$$</span>

where $\mu_X$ is a **known superpopulation** mean, not a realized
target-sample mean and not an estimate, so no uncertainty in it is
propagated. Under the identity link this is exact and needs no Monte
Carlo evaluation. The posterior contrast vector is
$c = (-1, 1, 0, -\mu_X, \mu_X, 0)$ on
$(d_B, d_C, d_D, \gamma_B, \gamma_C, \gamma_D)$.

Numerical values, which an earlier version left to the code: true main
effects $d_B = 0.30$, $d_C = 0.40$, $d_D = 0.35$; true interactions
$\gamma_B = 0.20$, $\gamma_D = 0.10$, with $\gamma_C$ a factor. Priors
are independent and zero-centered with standard deviations
$(0.20, 0.10)$ for main effects and interactions under **tight**,
$(0.50, 0.25)$ under **regular** and $(2.00, 1.00)$ under **weak**.
Individual-data trials contribute the exact ordinary-least-squares
covariance of their treatment and treatment-by-covariate coefficients
for a 1:1 randomized design with the covariate standard normal within
trial; aggregate arms contribute a single adjusted contrast with
variance $2/n + \tau^2$. The evidence matrices $H$ and $V$ for each
geometry are constructed in `R/01-model.R`.

**Prior-truth separation matters for reading the results and is stated
here rather than left implicit.** A true $\gamma_C$ of 0.40 sits 4.0
tight-prior standard deviations from the prior mean, 1.6 regular ones
and 0.4 weak ones. Under the tight prior in a direction the likelihood
barely informs, poor coverage follows arithmetically; peer review was
right to ask for this number, and the sample-size result in
<a href="#sec-why" class="quarto-xref">Section 3.2</a> should be read as
demonstrating a mechanism rather than estimating how often it occurs.

**AgD-flat and AgD-narrow are positive controls**, engineered so the
likelihood carries almost no information about the interaction. A
diagnostic that fails there has failed at its easiest task; one that
fires there has done nothing impressive. Neither is evidence that such
structures are common, and results are reported with and without them.

$\gamma_C = 0$ matters because the zero-centered prior is then
accidentally correct: a prior-driven analysis is right for the wrong
reason, and silence must not be credited.

## The reference standard is a consequence, not a geometry

The design as first proposed defined “prior-driven” by the share of
posterior variance in directions where likelihood precision is at most a
quarter of prior precision, and evaluated the diagnostics against it.
That is circular: for a contrast aligned with one eigen-direction,
contraction is exactly $\lambda/(1+\lambda)$, so the reference cut
$\lambda \le 0.25$ **is** the diagnostic cut contraction $< 0.20$.
Sensitivity of contraction against it would have been an algebraic
identity reported as diagnostic accuracy. Review of the design caught
this.

The reference is therefore what goes wrong: a 95% credible interval that
misses the truth. A scenario is **harmful** when coverage falls below
0.90. No diagnostic’s definition determines that.

## Diagnostics

| Diagnostic | Fires when |
|----|----|
| Contraction | $1 - \mathrm{Var}_{\text{post}}/\mathrm{Var}_{\text{prior}} < 0.20$ |
| Prior-only benchmark | **squared** Hellinger distance to the prior $< 0.10$ and decision-probability change $< 0.05$ |
| Power-scaling | prior sensitivity $\ge 0.05$ and likelihood sensitivity $< 0.05$ |
| Tight and loose refit | posterior mean moves $> 0.25$ posterior SD, or decision probability by $> 0.05$ |
| **Composite** | at least two of the four fire |

Power-scaling is measured **distributionally**, as the (unsquared)
Hellinger distance between base and power-scaled posteriors per unit
$\log\alpha$. The prior-only benchmark uses the **squared** Hellinger
distance, as the protocol specifies; the two are on different scales and
an earlier draft described both as “Hellinger distance”, which peer
review flagged. A first implementation used the shift in the posterior
*mean*, and that cannot work: in a conjugate Gaussian with a
zero-centered prior, raising the prior to $\alpha$ and lowering the
likelihood to $1/\alpha$ give posteriors with identical means, so prior
and likelihood sensitivity are equal by construction and a rule of the
form “prior sensitive, likelihood insensitive” can never fire. Measured
that way the diagnostic had sensitivity 0.000 everywhere, which would
have been published as a property of the method rather than of our code.
The standard deviations do differ, which is why
([1](#ref-kallioinen2024)) define the diagnostic as a divergence between
the two posteriors. They use cumulative Jensen-Shannon distance; a
numerical threshold does not transfer between that and Hellinger merely
because both are bounded, so the 0.05 used here should be read as a
choice informed by their default rather than as their threshold.

The bare posterior is labelled the **no-diagnostic baseline**, not
“current practice”: `multinma` ships a prior-versus-posterior plot, so
what is measured here is what an *automated* warning could achieve, not
what a careful analyst reviewing plots would.

# Results

Intervals missed on 56,210 of 480,000 replicate-contrasts. 34 of 240
scenario-contrasts are harmful by the prespecified definition, 18 of
them outside the engineered positive controls, so the gate against
estimating sensitivity only where failure was manufactured is passed.

**Operating characteristics are computed per replicate**, pairing each
warning with whether that replicate’s own interval missed. An earlier
version called a scenario detected when a rule fired on a majority of
its replicates and averaged over scenarios; peer review established that
this is not sensitivity for flagging analyses whose intervals miss, that
it discards the within-replicate pairing, and that its uncertainty
treated fixed factorial design points as a binomial sample. Replicates
are Monte Carlo draws, so both the pairing and the Monte Carlo error are
well defined at that level.

<div id="tbl-oc">

Table 1: Operating characteristics per replicate. Sensitivity is the
share of replicates whose interval missed on which the rule fired; the
false-alarm rate is the share of replicates whose interval covered on
which it fired. Monte Carlo standard errors in brackets.

<div class="cell-output-display">

| Rule | Sensitivity | False alarm | Sensitivity, controls excluded | False alarm, controls excluded |
|:---|---:|---:|---:|---:|
| Contraction | 0.363 (0.002) | 0.141 (0.001) | 0.122 | 0.016 |
| Prior-only benchmark | 0.209 (0.002) | 0.128 (0.001) | 0.017 | 0.024 |
| Power-scaling | 0.209 (0.002) | 0.130 (0.001) | 0.007 | 0.003 |
| Tight and loose refit | 0.698 (0.002) | 0.526 (0.001) | 0.830 | 0.531 |
| Composite (2 of 4) | 0.366 (0.002) | 0.158 (0.001) | 0.127 | 0.025 |

</div>

</div>

<div id="fig-cov">

![](../results/figures/fig1-coverage-vs-warning.png)

Figure 1: Do the warnings land on the analyses that are wrong?

</div>

The prespecified verdict is **diagnostics fail at the thresholds the
literature suggests**. Two patterns produce it.

**The sensitive rule is not specific.** Refitting under halved and
doubled prior scales catches 0.830 of misses outside the controls and
fires on 53% of covered replicates too. A warning attached to half of
all sound analyses is not actionable; it is a warning that the model has
a prior.

**The specific rules are not sensitive.** Contraction, the prior-only
benchmark and power-scaling keep false alarms low and catch almost
nothing outside the engineered geometries. Requiring two of four to
agree, intended to buy specificity, inherits the low sensitivity instead
of repairing it.

## The statistics discriminate; the thresholds do not

<div id="tbl-auc">

Table 2: Threshold-free discrimination: area under the curve for
predicting that a replicate’s interval missed, using each statistic as a
continuous score.

<div class="cell-output-display">

| Statistic   | AUC, all scenarios | AUC, controls excluded |
|:------------|-------------------:|-----------------------:|
| contraction |              0.711 |                  0.749 |
| prior_sens  |              0.766 |                  0.781 |
| lik_sens    |              0.505 |                  0.627 |
| h2          |              0.578 |                  0.511 |
| refit_sd    |              0.653 |                  0.762 |

</div>

</div>

This matters for what may be concluded. Used as continuous scores the
same quantities reach areas under the curve of 0.511 to 0.781 outside
the controls, which is moderate discrimination, not none. **The failure
reported above is a failure of the prespecified thresholds, not a
demonstration that the statistics are uninformative**, and a
better-calibrated rule would do better. We do not claim otherwise, and
an earlier draft that called the failure structural on the strength of
one operating point per rule overstated it.

## What no threshold repairs

<div id="fig-mech">

![](../results/figures/fig3-mechanism.png)

Figure 2: Where the diagnostics go quiet while the answer stays wrong.

</div>

Every diagnostic here asks a version of *is the likelihood weak relative
to the prior*. The harm asks *is the answer wrong*, and the two separate
exactly where it matters most.

Take disconnected evidence with a tight prior centered at zero and a
true interaction of 0.40. At 100 participants per arm, coverage of the
interaction is 0.000 and the composite warns on 0.984 of replicates. At
400 per arm, coverage is 0.000 and the warning rate is 0.011.

**More data makes the warning quieter while leaving the answer wrong.**
The extra data lets the posterior contract, which contraction, the
prior-only benchmark and power-scaling all read as reassurance. None of
them compares the prior to anything outside itself, so none can see that
it is centered in the wrong place. This is the sense in which a prior
can only be understood alongside its likelihood ([3](#ref-gelman2017)):
a diagnostic that examines the prior’s *influence* is silent about the
prior’s *location*, and no recalibration of a threshold on an influence
statistic changes that.

The distinction is not new and the manuscript should not imply it is.
Prior-data conflict checking ([4](#ref-evans2006)) and conflict
diagnostics for evidence-synthesis graphs ([5](#ref-presanis2013))
address prior *location* directly, by asking whether the prior and the
likelihood are compatible rather than how much the prior contributes.
What this study adds is the measurement that the influence-based family,
which is what `priorsense` and the prior-versus-posterior plot supply
and what CMU-02 names, does not substitute for a conflict check in these
networks. A conflict diagnostic is a different instrument and is not
evaluated here.

Where the prior is accidentally correct, at $\gamma_C = 0$, the
composite fires on 0.190 of covered replicates against 0.119 where it is
wrong. Those firings are not errors in the diagnostic’s own terms, since
the prior really is doing the work; they are counted as false alarms
here because the reference is harm, and that mismatch is a real
limitation of the reference rather than of the diagnostic.

## Measures that were registered and are now reported

An earlier draft omitted several prespecified outputs, which peer review
identified.

**The structural rank screen** fires on 0.150 of replicates overall,
0.175 among misses and 0.147 among covered. It fires only where a
contrast genuinely lies outside the row space of the evidence, which
happens only in the AgD-flat geometry, and it never fires elsewhere. It
is the one rule here with no false alarms at all, and it is also the one
that answers the narrowest question: exact nonidentification, not weak
identification. It cannot see the disconnected failures above, where the
contrast is estimable and the answer is still wrong.

**Confident decisions on the wrong side of zero** occur on 0.016 of
replicates overall and 0.085 among those whose interval missed.

**The composite adds almost nothing over its best component.** Its
sensitivity of 0.366 sits just above contraction alone at 0.363, at a
slightly higher false-alarm rate, 0.158 against 0.141. Requiring two of
four rules to agree neither buys specificity nor recovers sensitivity
here.

**The verdict does not depend on the amended diagnostic.** Power-scaling
was reimplemented after a first run, and it contributes to the
composite, so the composite recomputed with that component removed
entirely gives sensitivity 0.365 and false alarm 0.146, against 0.366
and 0.158 with it.

# What this answers, and what it does not

**Answers, in part, and less than an earlier draft claimed.** CMU-02
asks for these diagnostics to be applied to population-adjusted models
and evaluated conditional on scenario severity. What is established here
is narrower: in a conjugate Gaussian network with graded evidence
structures, these warnings coincide poorly with realized interval misses
at the thresholds examined, and the influence-based family cannot see a
misplaced prior. That is not the same as calibrating them for detecting
prior dominance, which would need a reference for dominance that is not
one of the diagnostics; finding such a reference is itself unfinished
business, since the obvious geometric one is algebraically identical to
contraction. An analyst who runs them and sees nothing has learned that
the likelihood is not obviously weak, which is a much smaller claim than
that the answer is trustworthy.

**Does not answer.** The reference standard is undercoverage, not prior
dominance, and those are not the same thing: a diagnostic that correctly
detects a dominant prior in a cell where the prior happens to be right
is counted here as a false alarm. That mismatch was chosen deliberately,
because the geometric alternative was algebraically identical to one of
the diagnostics, but it means these numbers answer “do the warnings
predict wrong answers” rather than “do the warnings detect prior
dominance”.

Only one form of prior misspecification is examined, a zero-centered
prior against a nonzero truth, at three scales. A diffuse but
miscentered prior is untested, though the argument in
<a href="#sec-why" class="quarto-xref">Section 3.2</a> would apply to it
too. Only automated thresholds are evaluated, and those thresholds come
from the source literature for power-scaling and are our own choices for
the others; a plot read by an experienced analyst is a different
instrument. The harm threshold of 0.90 coverage is prespecified but its
sensitivity to that choice is not explored.

The other half of CMU-02, wiring these into released software, is
untouched; neither `multinma` nor `cpaic` is run. The Stan validation of
the Gaussian reduction named in the protocol was not run. The model is
conjugate Gaussian with an identity link, a correctly specified linear
mean and known variances, so nothing here transfers directly to a
non-conjugate posterior where the diagnostics behave differently and
MCMC error enters. Only automated thresholds are evaluated; a plot read
by an experienced analyst is a different instrument and may do better.
Thresholds are those the source literature suggests and were not tuned,
so a better-calibrated rule may exist, though the structural argument in
<a href="#sec-why" class="quarto-xref">Section 3.2</a> suggests
re-tuning cannot fix the failure it describes.

It bears on **CMP-14** only for the generic case of an interaction
informed by aggregate data alone. CMP-14 concerns component models and
this design has treatment-specific parameters, so the component-specific
part is untouched. An earlier draft claimed IDN-06 as well; that is
withdrawn, because this design contains no within-study versus
between-study discrepancy at all.

# Peer review

Reviewed in two rounds by two independent reviewers. Reports, responses
and the editorial decision are published in full at
`studies/CMU-02-prior-driven-posteriors/review/peer-review.md`.

# Reproducibility

R: R version 4.6.0 (2026-04-24) Platform: aarch64-apple-darwin23 Running
under: macOS Tahoe 26.5

## Packages

| package | version |
|---------|---------|
| base    | 4.6.0   |
| stats   | 4.6.0   |
| Matrix  | 1.7.5   |
| future  | 1.70.0  |
| furrr   | 0.4.0   |

## Run

- **study**: CMU-02 prior-driven posteriors
- **scenarios**: 120
- **replicates_per_scenario**: 2000
- **total**: 240000
- **master_seed**: 20260729

``` bash
Rscript R/03-run.R
Rscript R/04-analyze.R
Rscript R/05-figures.R
```

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-kallioinen2024" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Noa Kallioinen, Topi Paananen,
Paul-Christian Bürkner, Aki Vehtari. Detecting and diagnosing prior and
likelihood sensitivity with power-scaling \[Internet\]. 2024. Available
from: <https://arxiv.org/abs/2107.14054></span>

</div>

<div id="ref-morris2019" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">Tim P. Morris, Ian R. White,
Michael J. Crowther. Using simulation studies to evaluate statistical
methods. Statistics in Medicine. 2019;38(11):2074–102.
doi:[10.1002/sim.8086](https://doi.org/10.1002/sim.8086)</span>

</div>

<div id="ref-gelman2017" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">Andrew Gelman, Daniel Simpson,
Michael Betancourt. The prior can often only be understood in the
context of the likelihood. Entropy. 2017;19(10):555.
doi:[10.3390/e19100555](https://doi.org/10.3390/e19100555)</span>

</div>

<div id="ref-evans2006" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">Michael Evans, Hadas Moshonov.
Checking for prior-data conflict. Bayesian Analysis. 2006;1(4):893–914.
doi:[10.1214/06-BA129](https://doi.org/10.1214/06-BA129)</span>

</div>

<div id="ref-presanis2013" class="csl-entry">

<span class="csl-left-margin">5.
</span><span class="csl-right-inline">Anne M. Presanis, David Ohlssen,
David J. Spiegelhalter, Daniela De Angelis. Conflict diagnostics in
directed acyclic graphs, with applications in bayesian evidence
synthesis. Statistical Science. 2013;28(3):376–97.
doi:[10.1214/13-STS426](https://doi.org/10.1214/13-STS426)</span>

</div>

</div>
