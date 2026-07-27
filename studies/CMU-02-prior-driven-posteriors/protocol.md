# Protocol: do prior-sensitivity diagnostics catch the analyses that are actually wrong?

**Target problem.** CMU-02 *Priors, not data, can drive posteriors in weakly identified
models*. Bears in part on CMP-14 *Aggregate-data-only interactions may be prior-driven*.

**Status.** Registered before any result was seen; the commit that adds this file is the
timestamp. Section 9 records amendments.

**Reporting standard.** ADEMP (Morris, White and Crowther 2019,
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086)).

---

## 1. The problem

In a population-adjusted network a proper prior with finite marginal likelihood yields a
proper posterior even along directions the likelihood cannot identify. A narrow credible
interval can therefore reflect the prior rather than the evidence, and a clean $\hat R$ does
not rule it out, because convergence diagnostics interrogate the sampler and not the
likelihood's contribution.

CMU-02 states that the diagnostics which would expose this already exist as general Bayesian
workflow tools: power-scaling sensitivity (Kallioinen, Paananen, Bürkner and Vehtari,
[arXiv:2107.14054](https://arxiv.org/abs/2107.14054), with `priorsense` on CRAN) and
`multinma`'s prior-versus-posterior comparison. What is missing is their application here,
and the entry adds the reason it matters: **prior dominance grows with scenario severity, so
a single check on one benign dataset says nothing about the cases that matter.**

This study supplies the operating characteristics: across a graded set of evidence
structures, do these diagnostics flag the analyses that are actually wrong, and how often do
they cry wolf?

## 2. Aims

1. Measure sensitivity and false-warning rate of five diagnostics and a composite rule, for
   flagging analyses whose intervals miss the truth.
2. Locate where each works and where it does not.
3. Establish whether a diagnostic can be relied on unattended, or only as a prompt for
   human review.

## 3. Design and why it is exact rather than sampled

Every piece of evidence reduces without loss to a normal observation of a linear function of
the treatment parameters, so with $z \sim N(H\theta, V)$ and $\theta \sim N(m_0, S_0)$ the
posterior is closed form:

$$S = (H^\top V^{-1} H + S_0^{-1})^{-1}, \qquad m = S(H^\top V^{-1} z + S_0^{-1} m_0).$$

This is deliberate. The study evaluates diagnostics that detect when a posterior is held up
by its prior. If the posterior were itself a Monte Carlo approximation, every diagnostic
would carry sampling noise of unknown size and a failure to detect could not be separated
from a failure to converge. With an exact posterior, a failure belongs to the diagnostic.
Power-scaling is likewise exact here: raising a normal prior to the power $\alpha$ multiplies
its precision by $\alpha$, so a power-scaled posterior is another closed-form Gaussian rather
than an importance-weighted resample. A Stan fit of the same model on a subset checks the
reduction is faithful.

Parameters are $\theta = (d_B, d_C, d_D, \gamma_B, \gamma_C, \gamma_D)$ with A as reference.
Outcomes are continuous with unit residual variance; $\gamma_t$ is the change in the
conditional treatment effect per one standard deviation of $X$. Between-trial heterogeneity
of active effects has standard deviation 0.10, treated as known.

### Factors

| Factor | Levels |
|---|---|
| Evidence about C | within-IPD, AgD-wide, AgD-narrow, AgD-flat, disconnected |
| Participants per arm | 100, 400 |
| True $\gamma_C$ | 0, 0.40 |
| Prior scale | tight, regular, weak |
| Target population mean $X$ | 0, 0.75 |

Fully factorial: **120 scenarios**, 2000 replicates each.

**AgD-flat and AgD-narrow are positive controls.** They are engineered so the likelihood
carries almost no information about the interaction. A diagnostic that fails there has failed
at its easiest task, and a diagnostic that fires there has done nothing impressive. Neither
is evidence that such evidence structures are common in practice, and the review of this
design was right that presenting them that way would build the conclusion in.

$\gamma_C = 0$ matters because the zero-centered prior is then accidentally correct. A
prior-driven analysis gets the right answer for the wrong reason, and a diagnostic must not
be credited for staying silent.

### What the mechanism makes true, and therefore what the study cannot see

Treatment-specific parameters, not component effects. **No within-study versus between-study
discrepancy exists at all**, so this study says nothing about ecological conflation; that is
study 2 of this program. Normal outcomes, identity link, correctly specified linear mean,
known heterogeneity and residual variance, no covariate measurement error, no integration
misspecification. A likelihood can strongly identify the wrong quantity under
misspecification and none of these diagnostics would warn about it.

## 4. The reference standard: a consequence, not a geometry

The design as first proposed defined "prior-driven" by a weak-direction variance share $W_c$,
the share of posterior variance in directions where likelihood precision is at most a quarter
of prior precision, and evaluated the diagnostics against it.

That is circular. For a contrast aligned with one eigen-direction, contraction is exactly
$\lambda/(1+\lambda)$, so the reference cut $\lambda \le 0.25$ **is** the diagnostic cut
contraction $< 0.20$. Sensitivity of contraction against that reference would have been an
algebraic identity reported as diagnostic accuracy. Peer review of the design caught this.

The reference is therefore what goes wrong:

- **miss**: the 95% credible interval does not contain the true value;
- **wrong**: the posterior puts at least 95% of its mass on the wrong side of zero.

A scenario is **harmful** when coverage falls below 0.90. No diagnostic's definition
determines either. $W_c$ is retained as a descriptive covariate and is never a gold standard.

## 5. Diagnostics under test

| Diagnostic | Fires when |
|---|---|
| Structural rank screen | the contrast is not in the row space of $H$ |
| Prior-to-posterior contraction | $1 - \mathrm{Var}_{\text{post}}/\mathrm{Var}_{\text{prior}} < 0.20$ |
| Prior-only benchmark | squared Hellinger distance to the prior $< 0.10$ and decision-probability change $< 0.05$ |
| Power-scaling sensitivity | prior sensitivity $\ge 0.05$ and likelihood sensitivity $< 0.05$ |
| Tight and loose refit | posterior mean moves more than 0.25 posterior SD, or decision probability by more than 0.05 |
| **Composite** | at least two of the last four fire |

The bare posterior with no diagnostic is the **no-diagnostic baseline**, and is labelled as
such rather than as "current practice": `multinma` ships a prior-versus-posterior plot and the
unreleased `cpaic` ships several structural screens, so calling a stripped workflow current
practice would exaggerate the improvement. What is measured here is what an *automated*
warning could achieve, not what a careful analyst reviewing plots would.

## 6. Performance measures

Primary: macro-averaged sensitivity of the composite across harmful scenarios, and its
false-warning rate across scenarios with coverage at or above 0.94. Both are required; a
sensitivity reported without its false-warning rate is not an operating characteristic.

Secondary: the same for each diagnostic alone; coverage; interval width; the decision-error
rate; and the relationship between each diagnostic and $W_c$, reported descriptively.

**2000 replicates** per scenario. Coverage has Monte Carlo SE 0.0049 at nominal. Sensitivity
is computed over replicates within harmful scenarios, so its precision depends on how many
such scenarios exist; that count is reported rather than assumed.

## 7. Decision rule, fixed in advance

**Diagnostics work.** Macro-averaged sensitivity of the composite is at least 0.80 and its
false-warning rate at most 0.20, both with Monte Carlo 95% intervals excluding the threshold.

**Diagnostics fail.** Sensitivity at most 0.50, or false-warning rate at least 0.50, with
Monte Carlo intervals excluding those thresholds.

**Partial.** Neither: the composite discriminates but not well enough to be relied on
unattended. Report per-diagnostic operating characteristics and the region in which each
works.

These are symmetric, after review found the proposed pair required one successful comparison
anywhere for a positive verdict and every comparison to be negligible for a negative one.

**Uninformative** if fewer than four harmful scenarios exist outside the positive controls,
so sensitivity would be estimated only where the failure was engineered; or if the exact
posterior disagrees with a Stan fit of the same model beyond Monte Carlo error on the
validation subset, meaning the Gaussian reduction is wrong.

## 8. Scope

This **answers CMU-02 in part**: it supplies operating characteristics for the diagnostics
the entry names, in a conjugate Gaussian network, which is the calibration CMU-02 says is
missing. It does **not** wire them into released software, which is the entry's other half,
and it does not run `multinma` or `cpaic`.

It bears on **CMP-14** only for the generic case of an interaction informed by aggregate data
alone. CMP-14 is about component models and this design has treatment-specific parameters, so
the component-specific part is untouched.

It does **not** bear on IDN-06, which was in an earlier draft of this protocol and is removed:
that problem is about conflating within-study and between-study effect modification, and this
design contains no such discrepancy.

## 9. Amendments

Four changes were made after an adversarial review of the design and before the run, each
recorded above where it applies: the reference standard was changed from the weak-direction
share to a consequence, because the former was algebraically identical to one of the
diagnostics being evaluated; the decision rule was made symmetric; the two engineered
geometries were relabelled positive controls; and IDN-06 was dropped from the claims with
CMP-14 restricted. No change was made after any result was seen.
