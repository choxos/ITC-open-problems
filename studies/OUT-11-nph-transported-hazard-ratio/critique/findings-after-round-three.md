# What round three changed

Three reviews: Sol on the whole protocol (`unsound`, 10 fatal, 13 serious), and Kimi split across
two payloads because of its input-size ceiling (both `needs-revision`). Every allegation below was
checked before it was accepted. Two were checked and are recorded as **confirmed by measurement**,
not by agreement.

## The bug

**Sol, fatal, and it invalidated the pilot.** The STC rows stored Gauss-Hermite weights in
`STC_NODES$w` and never used them. `rp_logH` took a plain `mean` over the abscissas.

Checked: equal weighting of 32 Gauss-Hermite nodes spans $-9.48$ to $+10.68$ and implies a
covariate standard deviation of **5.568** against a target of 1.000. On a test survival probability
it returns 0.4609 where both the correctly weighted quadrature and a 4,000,000-draw Monte Carlo
give 0.4753.

Consequences, all of them mine:

- Every STC number in the first pilot integrated over the wrong distribution.
- The "+0.383 non-collapsibility bias" that had been **registered as an anticipated mechanism** was
  an artifact. Registering a prediction is worth nothing if the code producing it is wrong, and a
  registered wrong prediction is worse than none, because it would have been reported as confirmed.
- The D1 threshold calibrated on that pilot was void.

After the fix, the mechanism is real but half the size: STC-PH bias at $\kappa_B=0$ is $+0.186$,
not $+0.383$, against $+0.021$ in the $\gamma=0$ control. STC-flex moved from $+0.15$ to about
$-0.05$ across cells.

A guard now makes the failure impossible to repeat: nodes and weights live in one object,
`marginalize()` is the only path, and `verify_quad()` asserts the rule reproduces the target mean
and standard deviation before any estimator runs.

## The handicap

**Sol, fatal.** Forcing STC through the same marginal log-cumulative-hazard graft as MAIC is invalid
under the registered DGM, because marginalization is nonlinear, so a ratio of marginal cumulative
hazards formed under the IPD baseline does not transport to a different baseline. Registered
$\gamma = 0.30$ with Weibull scales 12 against 14 activates the error by construction.

Accepted. MAIC keeps the graft, because that **is** MAIC and the approximation is its own
limitation, declared. STC now transports the conditional model and marginalizes last, which is what
its structural model supports. Each method gets the strongest valid transport its own structure
implies, which was Sol's prescribed fix.

Checking this turned up an error of my own: the covariate has **no effect under placebo** (verified:
placebo survival at $t=12$ is 0.4356 at $x = -2$, $0$ and $+2$). It is a pure effect modifier, not
the "prognostic covariate" the protocol claimed. That also makes the target baseline directly
identified from the aggregate placebo arm.

## The aggregate study was not aggregate

**Sol, fatal.** `flexsurvspline` was fitted directly to the aggregate study's individual records and
individuals were bootstrapped from it. Reconstructed pseudo-individual event times are legitimately
observable, since Kaplan-Meier curves are published and digitization is declared exact and out of
scope. Individual covariate values are not.

Fixed structurally rather than by discipline: `sim_network` computes the covariate summaries once at
generation time and then **deletes the column**. Any estimator reaching for an aggregate individual
covariate now fails loudly instead of quietly using information it could not have.

## The decision rule, found independently by both reviewers

**Sol fatal, Kimi B serious, converging on the same defect.** The excess-over-noise-floor metric
subtracts a floor computed from each estimator's own variance. As $\sigma$ grows, both the raw error
rate and the floor tend to 0.5, so excess tends to zero and an arbitrarily noisy estimator passes.
Kimi stated it exactly: it is a standardized-bias measure, decreasing in $\sigma$ at fixed bias, so
inflating variance hides bias. My claimed protection covered only the opposite direction.

The replacement was expected decision loss in months, judged against untuned constant-rule
baselines. **Measuring it killed that too**, and this one neither reviewer could have caught without
the numbers:

| estimator | weighted decision loss | bias at $\kappa_B=0.30$ |
|---|---:|---:|
| STC-flex | 0.0913 | $-0.043$ |
| STC-PH | 0.0915 | $-0.529$ |
| MAIC-flex | 0.0939 | $-0.046$ |
| MAIC-Cox | 0.1053 | $-0.724$ |
| MAIC-PH | 0.1054 | $-0.725$ |
| **always-recommend** | **0.0500** | n/a |
| never-recommend | 0.1667 | n/a |

**A constant rule that ignores the data beats every estimator.** Decision loss separates the methods
by 15% while bias separates them by a factor of seventeen. Worse, MAIC-PH scores best of all
estimators in the $\kappa_B=0.30$ margin cell precisely because its $-0.715$ bias pushes it below
the threshold, which is the right decision there for the wrong reason.

The cause is structural, not a bad loss function: per-replicate noise is 0.70 to 0.87 months while
the decision margins are 0.15 to 0.25. Kimi B flagged exactly this ratio.

**Resolution: decision quality cannot be the primary outcome of this study.** Estimation quality
becomes primary, compared **paired on the replicate**, which needs no threshold at all and therefore
disposes of Sol's separate objection that the 0.10 cutoff was tuned on the pilot. Decision loss
becomes a secondary appendix reported against both constant baselines, carrying the honest finding
that at trial-realistic sample sizes the choice of estimator moves the *estimate* by a factor of
seventeen and the *decision* by less than sampling noise.

## The non-proportionality was quarantined where the methods do not act

**Kimi A, serious, and I did not see it.** $\kappa_A = 0$ in every cell, so the IPD-side A-versus-PBO
contrast, which is the only contrast MAIC weighting or STC regression ever touches, is exactly
proportional everywhere. B's target curve comes from an aggregate-side fit shared across rows. So
all the time-variation lives in the arm neither frequentist method models, and the MAIC-versus-STC
comparison is never exercised under crossing hazards, which is the comparison the catalog entry
asks for.

Accepted. $\kappa_A$ becomes a design factor. With $\gamma$ shared, the B-versus-A contrast is
$\beta_B - \beta_A + (\kappa_B - \kappa_A)g(t)$ and still carries no covariate term, so the property
that made the mechanism clean survives.

## My own measurement was underpowered, and I said so before it was pointed out

Reported earlier this session as systematic: a monotone increase across integration orders in three
replicates. It was not decisive, because each order is a separate MCMC run and at the observed
posterior SD near 0.75 with ESS near 250, each mean carried a Monte Carlo standard error near 0.047
against order-to-order differences of 0.02 to 0.07.

The paired 8-replicate rerun confirms the caution was warranted: the 64-to-128 difference is
$+0.063$ in replicate 1 and $-0.007$ in replicate 2. The earlier monotone pattern was two draws of
noise. Sol and Kimi B both independently flagged that the 0.02 acceptance threshold sat below the
0.024 standard error of its own measurement, which would reject a converged order about 40% of the
time.

## Also accepted, and mechanical

- E1's $\gamma$ grid and variance ablation, and all of E2, move into the locked configuration
  (Sol, fatal): they were hard-coded defaults, so the registration was not executable from its text.
- `N_INT` is still `NA` and section 14 permitted cutting `N_REP` without specifying to what
  (Sol, fatal). Both freeze before any replicate runs.
- The integration acceptance rule becomes an uncertainty bound rather than a point difference, and
  256 must be shown converged rather than assumed (Sol, Kimi B).
- The prior-sensitivity and knot-complexity arms are absent from the runtime table (Kimi B): the
  same omission class that was a round-two fatal.
- The study is a partial benchmark and **OUT-11 remains open afterward**, stated plainly rather than
  implied (Sol).
- "Four chains cost the same wall clock" is false: measured 166.9 s against 74 s. Since the derived
  estimand reaches ESS above 2000, two chains suffice and the four-chain choice rested on the wrong
  ESS metric.
- The D1 cell mixture was irreconcilable between the 6-cell pilot and the 8-cell registered rule
  (Kimi B). Moot now that paired estimation quality is primary.

## Sampling pathology, found while measuring

Not from a reviewer. The flexible `aux_regression` fit threw **45 divergent transitions** on one
integration probe replicate, with global minimum ESS of 25. A registered zero-divergence policy
would send such replicates to refit routinely, so the refit budget and the escalation policy need
to be set from measured failure rates rather than from an assumed 10%.
