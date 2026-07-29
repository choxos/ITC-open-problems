# OUT-11: what a transported hazard ratio is a summary of

Draft design, for adversarial critique before anything is run.

## The problem, narrowed

The catalog entry for OUT-11 is marked **overstated**, and its own verification trail says why.
The source claimed target-standardized survival curves and RMST are outputs current software
does not produce. That is false: `multinma` has shipped survival likelihoods since 0.6.0,
`marginal_effects()` returns target-standardized RMST and survival-probability differences since
0.7.0, and auxiliary parameters can be stratified by treatment (`aux_by = c(.study, .trt)`) to
relax proportional hazards.

Two auditors also corrected the statement's framing, and the correction defines this study. A
**conditional** hazard ratio under a proportional-hazards model is constant by definition. What
is unstable is either the **marginal** hazard ratio, which is population-dependent and
time-varying through risk-set selection, or, under non-proportional hazards, a fitted Cox
coefficient, which is a **censoring- and event-weighted constant summary of a time-varying
contrast**.

So the residual, in the entry's own words, is the absence of "any simulation benchmark comparing
these estimators against proportional-hazards MAIC and STC under crossing hazards and
differential censoring". That is what this study builds.

## What would make this study worthless

Stating this first, because three ways of getting it wrong are all easy.

**Showing that proportional-hazards methods fail when hazards cross is arithmetic.** If the
shape difference is large enough, any PH summary is wrong by construction and the study
demonstrates its own data-generating mechanism. The non-proportionality must be calibrated to a
magnitude that a real analysis would plausibly fail to detect, and the design must include a
proportional-hazards cell where the PH methods should **win** on efficiency. If they do not win
there, the comparison is rigged and the study says so.

**Comparing a hazard ratio to an RMST difference is a category error.** They are different
quantities and one cannot be biased for the other. Every method here is therefore scored on a
**common estimand**: the target-population marginal RMST difference at a declared horizon.
A proportional-hazards MAIC can produce one, by integrating its fitted survival curves. The
question is not which quantity to report but how much error each modeling route puts into the
same number.

**Confounding the method family with the assumption.** "ML-NMR beats MAIC" and "a flexible
baseline beats a proportional one" are different claims, and a two-arm comparison cannot
separate them. The design crosses them.

## The estimand

Target population: the aggregate-study population of a designated target study, with covariate
distribution known through published means and standard deviations.

Primary: **RMST difference between B and A in the target population at horizon $\tau$**,

$$\Delta_{\text{RMST}}(\tau) = \int_0^\tau \bar S_B(t)\,dt - \int_0^\tau \bar S_A(t)\,dt,
\qquad \bar S_k(t) = \mathbb{E}_{x \sim \text{target}}\!\left[S_k(t \mid x)\right].$$

$\tau$ is declared as part of the estimand and set to a quantile of follow-up that every cell
supports, so it is never extrapolation.

Secondary: milestone survival difference $\bar S_B(t^*) - \bar S_A(t^*)$; the **true time-varying
marginal hazard ratio** $\bar h_B(t)/\bar h_A(t)$; and, for each method that reports one, the
constant hazard ratio it reports.

Truth is computed exactly, not simulated: with a Weibull conditional model the marginal survival
function is an expectation over the target covariate law, evaluated by Gauss-Hermite quadrature,
and the RMST integral to high precision. The same device as study 5, and for the same reason:
a truth estimated from a large sample carries Monte Carlo error into every bias.

## The data-generating mechanism

Individual $i$ in study $j$ on treatment $k$, Weibull, with treatment acting on **both** the
scale and the shape:

$$T \sim \text{Weibull}\!\left(\text{shape} = \nu_0 e^{\phi_k},\
\text{scale} = \exp\{\lambda_j + (d_k + \gamma_k x_1)\}\right)$$

$\phi_k \neq 0$ is what makes the hazards cross; $\phi_k = 0$ recovers proportional hazards
exactly, because a Weibull family with common shape and a shift in log-scale is a
proportional-hazards model. So the proportional-hazards cell is a special case of the same
mechanism rather than a separate one, and nothing about the comparison changes between them
except the parameter under test.

$\gamma_k$ carries effect modification, so population adjustment is necessary rather than
decorative.

**One** study contributes individual data and compares PBO with A. The rest are aggregate and
compare PBO with B, so B's effect modifier is identified only through between-study contrasts of
covariate means. That is the situation population adjustment exists for, and it is the same
asymmetry study 5 used.

Censoring is independent exponential, with rate set **per study**, which is what makes the
differential-censoring factor a manipulation of a nuisance rather than of the truth.

## The factor that carries the paper

Everything above is setup for one experiment.

**The censoring manipulation.** Hold the true survival functions, and therefore the true RMST
difference and the true time-varying hazard ratio, **exactly fixed**. Change only the censoring
distribution. Then:

- the true estimand does not move, by construction;
- the RMST difference at a supported horizon should not move, if a method is estimating it;
- a fitted constant hazard ratio **should** move, if the audit's characterization is right,
  because the weights it averages the time-varying contrast under are event- and
  censoring-determined.

If the transported hazard ratio moves by a decision-relevant amount when nothing about the
treatments has changed, that is the cleanest possible statement of the problem, it is
mechanistic rather than empirical, and it does not depend on any threshold this study chooses.
If it does not move, the entry's central warning is weaker than stated and this study says so.

## Methods compared, crossed rather than listed

| | proportional baseline | flexible baseline |
|---|---|---|
| **weighting** | PH MAIC, weighted Cox, robust SE, Bucher | MAIC with a flexible weighted parametric fit |
| **outcome regression** | PH STC, marginalized over the target law | flexible STC |
| **ML-NMR** | `aux_by = .study` | `aux_by = c(.study, .trt)` |

Every cell of that table produces the same target RMST difference, so the row effect isolates the
method family and the column effect isolates the proportional-hazards assumption. A comparison
that reports only the diagonal cannot tell the two apart, and the diagonal is what a naive
version of this benchmark would report.

A marginalized STC is used rather than the mean-profile version, because plugging target means
into a nonlinear model returns a conditional quantity at an average covariate profile and is a
known error; using it would make the comparison unfair in the proposal's favour.

## Design factors

| Factor | Levels | What it varies |
|---|---|---|
| non-proportionality $\phi_B$ | 0, moderate, strong | whether and how far the hazards cross |
| censoring | common light, common heavy, **differential** | the nuisance the fitted HR is weighted by |
| effect modification $\gamma$ | moderate, strong | how much adjustment is needed |
| population separation | near, far | how far the target sits from the IPD study |

Not all crossed: the censoring manipulation is run at fixed everything else, so its effect is
identified without confounding.

## Prespecified decision

The transported constant hazard ratio is fit for purpose if, across the censoring manipulation
with truth held fixed, the deployment-weighted range of the reported hazard ratio implies a
change in the target RMST difference smaller than the amount that would change a decision. That
threshold is declared before the run and derived from a consequence, not from taste.

## What this cannot settle

It is one covariate, one parametric family for the truth, and independent censoring. Weibull and
Gompertz cross in specific ways and a multistate mechanism would cross differently. It does not
address digitization error in reconstructing aggregate survival curves, which is a real and
separate source of error in every applied use of these methods.
