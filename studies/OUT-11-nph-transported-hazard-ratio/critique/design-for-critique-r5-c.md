# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART C OF 7: the seven estimator rows and the fairness of the comparison

You are reviewing a protocol revised four times. Round one returned `unsound`,
round two `unsound`, round three `unsound`, round four `unsound`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
`round4_resolution` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

## 7. E3: the estimators, and a specification that does not transport

### 7.1 What implementing the registered specification revealed

Version 2 registered the flexible ML-NMR arm as `aux_by = c(.study, .trt)`, following the OUT-11
catalog entry, which names that option as the way to relax proportional hazards. **It is correct
for the within-study fit and silently unable to transport.**

Stratifying the baseline hazard by study-arm makes each arm's spline a free parameter attached to a
study that observed that arm, with no rule connecting it to a population where the arm was never
given. Asked for a target-standardized prediction on the two-study network, `multinma` can only
return treatments whose auxiliary parameters exist in the named study: `aux = "S2"` returns PBO and
B, `aux = "S1"` returns PBO and A, and there is no call in which A and B are both standardized to
the target. The absolute values it does return are not merely imprecise but wrong, giving RMST of
3.3 and 4.6 months against a placebo of 14.7 on the same fit, and the package emits a note pointing
at `aux_regression` instead.

**The flexible arm is therefore `aux_regression = ~ .trt`**, which makes the spline coefficients a
regression on treatment so the *shape* of a treatment's hazard is a shared transportable function.
On a single check replicate it returned PBO 10.84, A 10.98, B 11.75 in the target population,
against a locked truth of $\Delta_{\text{RMST}} = 0.75$.

This is a reportable result and not merely an implementation note: the catalog entry recommends a
setting that cannot deliver the entry's own requested output, and the failure is silent in the
sense that the fit converges and returns numbers.

**The proportional arm was checked the same way and passes.** `aux_by = .study` returns all three
treatments in the target population at sane values, PBO 11.25, A 11.47 and B 11.35, with
$\hat R = 1.008$ and minimum ESS 456. On that check replicate, at $\kappa_B = 0.30$, it estimates
$\Delta_{\text{RMST}} = -0.12$ against a truth of $+0.75$, an error comparable to the
proportional MAIC rows. The ML-NMR row is not privileged by this design: its proportional variant
fails under non-proportionality exactly as the other proportional variants do, which is what makes
the column contrast worth reporting.

### 7.2 The seven estimator rows

Round 2 was right that version 2's PH-versus-flexible columns changed likelihood and baseline
representation as well as proportionality, so the column effect was uninterpretable outside
ML-NMR. Within each row, the likelihood, basis and evidence set are now identical and **only the
treatment-by-time terms are toggled**.

| | proportional | flexible |
|---|---|---|
| **weighting** | MAIC weights, weighted Royston-Parmar, treatment as a scalar log-HR | MAIC weights, weighted Royston-Parmar, treatment-specific spline coefficients |
| **outcome regression** | STC, Royston-Parmar, treatment as a scalar log-HR, marginalized over the target law | STC, Royston-Parmar, treatment-specific spline coefficients, marginalized |
| **ML-NMR** | `mspline`, `aux_by = .study` | `mspline`, `aux_regression = ~ .trt` |

Attributions, since round 2 was right that "by its own authors' recommendation" is unauditable
without them. Round 3 then showed that CrossRef resolution is not enough: version 3 cited
doi:10.2165/11538370-000000000-00000 for MAIC, which resolves with matching author, year and title
but is the **psoriasis application** paper, not the methods paper. A DOI that resolves is not a DOI
that supports the claim. Corrected: MAIC methods, Signorovitch et al. 2012, *Value in Health*
(doi:10.1016/j.jval.2012.05.004), with the 2010 application paper
(doi:10.2165/11538370-000000000-00000) cited alongside where the applied practice is meant; STC, Ishak et al. 2015 (doi:10.1007/s40273-015-0271-1);
ML-NMR, Phillippo et al. 2020 (doi:10.1111/rssa.12579); the anchored indirect contrast, Bucher et
al. 1997 (doi:10.1016/S0895-4356(97)00049-8); the flexible parametric basis, Royston and Parmar
2002 (doi:10.1002/sim.1203); the proportional-hazards test used for calibration, Grambsch and
Therneau 1994 (doi:10.1093/biomet/81.3.515).

**Each method gets the strongest valid transport its own structure supports**, which is not the same
rule for all of them. Version 3 forced every frequentist row through one marginal
log-cumulative-hazard graft, and round 3 was right that this is invalid under the registered DGM and
that it handicapped STC before sampling began. Marginalization is nonlinear, so a ratio of
**marginal** cumulative hazards formed under the IPD study's baseline does not transport to a
different baseline; the registered $\gamma = 0.30$ with Weibull scales 12 against 14 activates the
error by construction.

**MAIC keeps the graft**, $\log H^{\text{tgt}}_A(t) = \log H^{\text{agd}}_{\text{PBO}}(t) +
[\log H^{\text{ipd}}_A(t) - \log H^{\text{ipd}}_{\text{PBO}}(t)]$, because a reweighted marginal
analysis is what MAIC produces and it has no conditional model to transport instead.

**Round 4 objected that this cannot support a method-family comparison**: scoring MAIC through a
transport the protocol itself calls invalid, while STC gets a valid one, could be measuring MAIC's
structural inability to deliver an *absolute* estimand rather than weighting against regression.
The objection is legitimate and it is answered by measurement rather than by caveat, because the
structural error is **exactly computable with no simulation** (`R/05b-graft-error.R`).

Give MAIC perfect weighting and perfect estimation so that only the graft remains. Under this
mechanism, matching the mean and variance of a normal covariate recovers the target law exactly, so
perfect weighting is attainable in the limit and the remainder is the graft alone:

| structural error in $\Delta_{\text{RMST}}(18)$, months | $\gamma = 0$ | $\gamma = 0.30$ |
|---|---:|---:|
| MAIC marginal graft, Weibull, $\kappa_A = 0$ | $1.1\times10^{-15}$ | $+0.0074$ |
| MAIC marginal graft, Weibull, $\kappa_A = 0.30$ | $8.9\times10^{-16}$ | $+0.0116$ |
| MAIC marginal graft, Gompertz, worst cell | $1.1\times10^{-15}$ | $+0.0061$ |
| STC conditional transport, every cell | $<4\times10^{-15}$ | $<4\times10^{-15}$ |

**The graft costs MAIC at most 0.0116 months**, which is 1.6% of MAIC-PH's measured 0.725-month
pilot bias and 2% of the 0.50-month decision threshold. It is exactly zero when $\gamma = 0$,
confirming that the covariate effect is its only driver. STC's conditional transport is exact to
machine precision in every cell, which the protocol previously asserted and now checks.

So the objection does not bite on this design: the across-row differences cannot be attributed to
the graft, because the graft is two orders of magnitude too small to produce them. The across-row
contrasts remain **descriptive** for the separate and unrelated reason given in section 10.1, that
the matched-flexibility premise was withdrawn in round 2.

**STC transports the conditional model and marginalizes last.** It fits the conditional outcome
model on the IPD, reads off the placebo covariate effect and the conditional treatment effect,
solves for the target baseline $c(t)$ such that the implied marginal placebo curve matches the
aggregate study's observed one, builds the target conditional curve for A, and integrates over the
target law once, at the end. The code does not assume the placebo covariate effect is zero even
though it is here, so the estimator stays correct if that changes.

B's curve comes from the aggregate study directly, and the aggregate-side model is fitted once per
replicate and shared across rows, which is the identical-evidence clause made operational rather
than asserted.

**The target law is a weighted quadrature rule, and a guard enforces it.** Round 3 found that
version 3's STC stored Gauss-Hermite weights and never used them, taking a plain mean over the
abscissas. Equal weighting of 32 Gauss-Hermite nodes spans $-9.48$ to $+10.68$ and implies a
covariate standard deviation of **5.568** against a target of 1.000; on a test survival probability
it returns 0.4609 where correct weighting and a 4,000,000-draw Monte Carlo both give 0.4753. Every
STC number in the version-3 pilot was integrating over the wrong distribution, including a bias that
had been registered as an anticipated mechanism and was an artifact. Nodes and weights now live in
one object, one function performs every marginalization, and `verify_quad()` asserts the rule
reproduces the target mean and standard deviation before any estimator runs.

**What the aggregate study makes observable, enforced structurally.** Round 3 found that version 3
fitted `flexsurvspline` directly to the aggregate study's individual records and bootstrapped
individuals from it, which evaluates a two-IPD analysis rather than an indirect comparison.
Reconstructed pseudo-individual event times are legitimately observable, since Kaplan-Meier curves
are published and digitization is declared exact and out of scope in section 12. Individual
**covariate** values are not: a published trial reports means and standard deviations. The
generator therefore computes the covariate summaries once and then **deletes the column**, so an
estimator reaching for an aggregate individual covariate fails loudly instead of quietly using
information it could not have. The aggregate data frame carries `study`, `trt`, `time` and `status`
and nothing else.

**MAIC weights** match the target's first and second moments by exponential tilt. Round 2 noted,
correctly, that with one covariate and equal variances in study and target, matching the mean alone
would transport a normal exactly, because an exponential tilt on $x$ shifts a normal's mean without
touching its variance. Both moments are matched anyway, because that is what an analyst does and
because this study should not quietly grant MAIC an exactness its applied use does not have.

**Weighted Cox with a Breslow baseline is retained as a seventh, separately labeled row, "MAIC as
practiced".** It is what applied MAIC actually does, it is nearly free to fit, and it is reported
and interpreted on its own rather than used to define the column effect.

**Flexibility is not claimed to be matched across rows.** Round 2 was right that equal internal
knot counts do not equate a Royston-Parmar restricted cubic spline on the log-cumulative-hazard
scale with an M-spline on the hazard scale. Each method uses its own recommended specification:
Royston-Parmar with 3 internal knots at quantiles of the uncensored event times and boundary knots
at the extremes; `multinma` M-splines with 3 internal knots at its own default placement. A
**complexity-sensitivity arm** repeats a prespecified subset at 2 and 5 internal knots for both
bases, and the comparison is interpreted only to the extent that arm supports it.

**Marginalized STC**, not the mean-profile plug-in, which returns a conditional quantity at an
average covariate profile.

**Uncertainty.** Nonparametric bootstrap over the full pipeline, resampling individuals within arm
within study and re-running weight estimation, model fitting and re-standardization, 500 resamples,
percentile intervals, for all four frequentist rows and the seventh row. Posterior draws for both
ML-NMR rows. The inner Monte Carlo error of a 500-resample percentile interval is reported rather
than assumed negligible.

**Priors**, registered: `normal(0, 10)` on intercepts and treatment effects, `normal(0, 2.5)` on
the covariate interaction, `half_normal(1)` on auxiliary parameters, `normal(0, 2.5)` on the
auxiliary regression. A prior-sensitivity arm halves and doubles the interaction and auxiliary
scales on a prespecified subset. Round 2 was right that version 2 registered none of this.

**Sampler policy**, registered, and revised because measuring it showed the first draft of the
policy was unmeetable. Round 2 was right that maximum $\hat R$ alone is not a policy. The
replacement was written as $\hat R < 1.01$ and bulk and tail ESS $\geq 400$ **on every monitored
parameter**, at 2 chains of 1,000 iterations. Probe fits then returned $\hat R$ of 1.011 to 1.015
and minimum ESS of 229 to 355, so essentially every fit in the run would have been declared a
failure and refit, which is a policy that reports nothing except its own threshold.

Two corrections, one of which was itself corrected. Version 2 moved to **four chains** on the
reasoning that chains run in parallel so four cost the same wall clock as two. **Round 3 asked
whether that had been measured, and measuring it showed it was false**: 166.9 s against 74.1 s per
fit, because four chains oversubscribe four performance cores. Four chains were also chosen to
satisfy an ESS floor applied to the global minimum over every monitored parameter, which is the
diagnostic the second correction rejects. **Two chains of 1,000 iterations are registered**
($N_{\text{chains}} = 2$ in `R/00-config.R`) and the derived estimand reaches ESS above 2,000 at
that setting, so nothing the study uses is short of draws.

The second correction stands: the ESS criterion binds on the **derived estimand**, the
target-standardized $\Delta_{\text{RMST}}(18)$ and the survival differences on the time grid, which
is what the study actually uses; the global minimum across all internal spline coefficients is
recorded for every fit and reported, but is not a pass criterion, because a weakly identified
nuisance coefficient failing to mix does not invalidate a well-mixed estimand.

Registered thresholds: $\hat R < 1.01$ and bulk and tail ESS $\geq 400$ on the derived estimand,
zero divergent transitions, no transition at maximum treedepth. A fit failing any criterion is
refit once at doubled iterations with `adapt_delta = 0.99`; a fit failing twice is **recorded as a
failure, not silently dropped**, and the primary analysis is repeated on the subset where every fit
met every criterion.

**Integration order is measured, not cited.** Version 2 cited IDN-05's finding that moving from 64
to 256 integration points flipped 8.3% of its verdicts and then chose 32, which is *below* the
order IDN-05 found insufficient; IDN-05 also recorded that 256 was not itself shown to be
converged, so it is not an accuracy reference either. Round 2 caught the citation and it was
right. The order is instead measured on this study's own network by `R/probe-integration.R`,
comparing the target-standardized RMST difference at 32, 64, 128 and 256 points, and the selected
order is registered in section 14 before the run.

