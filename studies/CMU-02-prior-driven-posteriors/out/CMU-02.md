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

**They fail.** Across 34 harmful scenarios the composite has sensitivity
0.324 (Monte Carlo SE 0.080) at a false-warning rate of 0.170. Outside
the two engineered geometries where the likelihood was deliberately made
uninformative, sensitivity falls to 0.111: roughly one harmful analysis
in nine is flagged. The only rule with high sensitivity, refitting under
halved and doubled prior scales, fires on 51% of the clean scenarios
too.

The reason is structural rather than a matter of tuning. **These
diagnostics detect a weak likelihood; the harm here comes from a tight
prior that is wrong.** In the worst cells, coverage is zero and the
composite warns on 0.000 of replicates, and increasing the sample size
makes the warning quieter while the answer stays just as wrong.

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
a committee would read.

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
| Prior-only benchmark | Hellinger distance to the prior $< 0.10$ and decision-probability change $< 0.05$ |
| Power-scaling | prior sensitivity $\ge 0.05$ and likelihood sensitivity $< 0.05$ |
| Tight and loose refit | posterior mean moves $> 0.25$ posterior SD, or decision probability by $> 0.05$ |
| **Composite** | at least two of the four fire |

Power-scaling is measured **distributionally**, as the Hellinger
distance between base and power-scaled posteriors per unit $\log\alpha$.
A first implementation used the shift in the posterior *mean*, and that
cannot work: in a conjugate Gaussian with a zero-centered prior, raising
the prior to $\alpha$ and lowering the likelihood to $1/\alpha$ give
posteriors with identical means, so prior and likelihood sensitivity are
equal by construction and a rule of the form “prior sensitive,
likelihood insensitive” can never fire. Measured that way the diagnostic
had sensitivity 0.000 everywhere, which would have been published as a
property of the method rather than of our code. The standard deviations
do differ, which is why ([1](#ref-kallioinen2024)) define the diagnostic
as a divergence between the two posteriors.

The bare posterior is labelled the **no-diagnostic baseline**, not
“current practice”: `multinma` ships a prior-versus-posterior plot, so
what is measured here is what an *automated* warning could achieve, not
what a careful analyst reviewing plots would.

# Results

34 of 240 scenario-contrasts are harmful, of which 18 lie outside the
engineered positive controls, so the gate on estimating sensitivity only
where failure was manufactured is passed.

<div id="tbl-oc">

Table 1: Operating characteristics. Sensitivity is the share of harmful
scenarios in which the rule fires on a majority of replicates; the
false-warning rate is the same among scenarios covering at or above 94%.
Monte Carlo standard errors in brackets.

<div class="cell-output-display">

| Rule | Sensitivity | False-warning rate | Sensitivity, controls excluded | False warning, controls excluded |
|:---|---:|---:|---:|---:|
| Contraction | 0.324 (0.080) | 0.149 (0.026) | 0.111 | 0.018 |
| Prior-only benchmark | 0.118 (0.055) | 0.117 (0.023) | 0.000 | 0.000 |
| Power-scaling | 0.176 (0.065) | 0.144 (0.026) | 0.000 | 0.000 |
| Tight and loose refit | 0.882 (0.055) | 0.548 (0.036) | 1.000 | 0.509 |
| Composite (2 of 4) | 0.324 (0.080) | 0.170 (0.027) | 0.111 | 0.018 |

</div>

</div>

<div id="fig-cov">

![](../results/figures/fig1-coverage-vs-warning.png)

Figure 1: Do the warnings land on the analyses that are wrong?

</div>

<div id="fig-oc">

![](../results/figures/fig2-operating-characteristics.png)

Figure 2: Operating characteristics. The dotted line is chance.

</div>

The prespecified conclusion is **diagnostics fail**: the composite’s
sensitivity is 0.324 with a Monte Carlo 95% interval reaching 0.481,
below the 0.50 threshold the protocol set for that verdict.

Two patterns underlie it.

**The sensitive rule is not specific.** Refitting under halved and
doubled prior scales catches every harmful scenario outside the
controls, and also fires on 51% of clean ones. A warning that
accompanies half of all correct analyses is not actionable; it is a
warning that the model has a prior.

**The specific rules are not sensitive.** Contraction, the prior-only
benchmark and power-scaling each keep false warnings low and catch
almost nothing outside the engineered geometries. Requiring two of four
to agree, which the design intended as a way to buy specificity,
inherits the low sensitivity rather than repairing it.

## Why: the diagnostics answer a different question

<div id="fig-mech">

![](../results/figures/fig3-mechanism.png)

Figure 3: Where the diagnostics go quiet while the answer stays wrong.

</div>

Every diagnostic here asks a version of *is the likelihood weak relative
to the prior*. The harm being measured is *is the answer wrong*, and the
two come apart exactly where it matters.

The clearest case is disconnected evidence with a tight prior and a true
interaction of 0.40 against a prior centered at zero. Coverage is 0.940
at best, meaning the interval essentially never contains the truth. At
100 participants per arm the composite warns on 0.984 of replicates. At
400 it warns on 0.012.

**More data makes the warning quieter while leaving the answer just as
wrong.** The extra data lets the posterior contract, which is precisely
what contraction, the prior-only benchmark and power-scaling read as
reassurance. None of them can see that the prior is centered in the
wrong place, because none of them compares the prior to anything outside
itself. This is the sense in which a prior can only be understood
alongside the likelihood it is paired with ([3](#ref-gelman2017)): a
diagnostic that examines the prior’s *influence* is silent about the
prior’s *location*.

Where the prior is accidentally correct, at $\gamma_C = 0$, coverage
runs 0.908 to 1.000 and the composite fires in 18% of scenarios. The
analyses are right for the wrong reason and mostly unflagged, which is
the same blindness seen from the other side.

# What this answers, and what it does not

**Answers, in part.** CMU-02 asks for these diagnostics to be applied to
population-adjusted models and evaluated conditional on scenario
severity rather than at one benign dataset. In a conjugate Gaussian
network with graded evidence structures, the answer is that they
discriminate poorly against the consequence that matters, and that the
reason is structural: they measure prior influence, not prior
correctness. An analyst who runs them and sees nothing has learned that
the likelihood is not obviously weak, which is a much smaller claim than
that the answer is trustworthy.

**Does not answer.** The other half of CMU-02, wiring these into
released software, is untouched; neither `multinma` nor `cpaic` is run.
The model is conjugate Gaussian with an identity link, a correctly
specified linear mean and known variances, so nothing here transfers
directly to a non-conjugate posterior where the diagnostics behave
differently and MCMC error enters. Only automated thresholds are
evaluated; a plot read by an experienced analyst is a different
instrument and may do better. Thresholds are those the source literature
suggests and were not tuned, so a better-calibrated rule may exist,
though the structural argument in
<a href="#sec-why" class="quarto-xref">Section 3.1</a> suggests
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

</div>
