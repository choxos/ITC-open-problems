## ---------------------------------------------------------------------------
## CMP-14: everything the protocol registers, in executable form.
##
## The previous study in this program shipped six protocol versions containing
## procedures no code could perform, because the document was written first and
## the code chased it. Here the registered grid, the estimands, the diagnostics
## and their thresholds all live in this file, and the protocol quotes it.
## R/09-smoke.R runs the whole pipeline before anything is reported.
## ---------------------------------------------------------------------------

## --- the model ---------------------------------------------------------------
## K binary components. A treatment is a subset indicator c in {0,1}^K, with
## additive effect c'delta and additive modification c'Gamma. For an individual
## with covariate x in study s on treatment t,
##
##   E[y] = alpha_s + c'delta + x * (beta + c'Gamma),  Var(y) = SIGMA^2.
##
## Four components is the smallest number that contains every information state
## the study distinguishes while leaving one component as an untouched control.
K_COMP <- 4L
SIGMA  <- 1.0        # residual SD, known; the study is about identification

DELTA_MAIN <- -0.5   # every component's main effect
BETA_PROG  <-  0.3   # prognostic covariate slope, common to all arms

## The causal, within-study effect modification. Nonzero and away from the
## zero-centered prior on purpose: CMU-02 found that the harm from a prior comes
## from its LOCATION, so a truth sitting at the prior mean would hide it.
GAMMA_W <- 0.40

## --- the design factors ------------------------------------------------------
##
## THE TARGET COMPONENT is component 3 in every scenario. Its information state
## is what varies; components 1, 2 and 4 are held in state A so the network is
## otherwise well identified and the target's behavior is not confounded with a
## globally weak design.
TARGET <- 3L

## The information states, which are different linear functionals of Gamma_3.
## Named here so a scenario's state is a registered label rather than a
## description of the arms someone typed.
##
##   own_ipd   A: component 3 has its own individual-data trial against placebo.
##                Within-study covariate variation identifies Gamma_3 causally.
##   additivity E: component 3 appears ONLY inside the combination 1+3, in an
##                individual-data trial that also has an arm for 1 alone. The
##                slope difference between those arms is exactly Gamma_3, so the
##                information is randomized and within-study; it simply has no
##                arm of its own. This state exists only in component networks.
##   ecological C: component 3 appears only in AGGREGATE studies. On an identity
##                link its interaction is identified solely by the contrast
##                between studies with different reported covariate means, which
##                nobody randomized.
##   absent    D: component 3 appears in no study at all. Its posterior is its
##                prior. Included as the positive control for the diagnostics:
##                any summary that cannot flag this one is not a summary.
STATES <- c("own_ipd", "additivity", "ecological", "absent")

## The between-study covariate spread, which is the strength of the ecological
## gradient. It has nothing to do with whether that gradient is confounded, and
## that is the point: it is the knob under which contraction improves.
SPREADS <- c(0.3, 0.6, 1.0, 1.4, 2.0, 3.0)

## The discordance between the causal within-study modification and the
## across-study association. Zero is the null control: at zero the ecological
## route is unconfounded and coverage must stay nominal, or any collapse
## observed elsewhere is a property of the geometry rather than of confounding.
DISCORD <- c(0.00, 0.15, 0.40)

## THE PATIENT BUDGET, not the arm size. Round 1 found the states carrying
## different totals: every arm was given `n` patients and `additivity` has twelve
## arms against ten, so it ran on 3,600 patients where the others ran on 3,000.
## Primary 2 then compared an evidence structure that also had 20% more data, and
## both this file and the protocol asserted the totals were equal.
##
## The budget is now fixed per state and divided among that state's arms, so a
## difference between states is a difference of structure alone.
TOTAL_N    <- c(1000L, 3000L, 10000L)

## Prior scale on the INTERACTION coefficients, which is the registered factor.
## Round 1 found `exact_fit` applying it to study intercepts, main effects and
## the prognostic slope as well, so every reported quantity could have been
## reflecting shrinkage of nuisance parameters whose true values are nonzero
## rather than the prior the study varies. The nuisance prior is now separate and
## deliberately weak: it is not a factor and it must not be doing work.
PRIOR_SD_NUISANCE <- 10.0

## Prior scale on the interaction coefficients. The tight end is not decoration.
## A first run of the grid without it found the ABSENT state covering the truth
## 100% of the time: the likelihood contributes literally nothing, the posterior
## is the prior, and a prior wide enough still contains a truth 0.40 away. The
## state that exists to be the diagnostics' positive control was therefore never
## a failure, so flagging it counted as a false alarm and the comparison was
## rigged against every diagnostic at once.
##
## At PRIOR_SD = 0.1 the truth sits four prior standard deviations out, which is
## the configuration CMU-02 found most damaging and where a prior-only posterior
## is confidently wrong. Including it is what makes the grid contain both kinds
## of prior-driven parameter: the harmless one and the harmful one. They differ
## only in where the prior sits, which is the quantity none of these diagnostics
## can see.
PRIOR_SD   <- c(0.1, 0.5, 1.0, 2.5)

## Whether additivity actually holds. In the violated arm the combination 1+3
## carries an extra interaction SYNERGY that the model has no term for, so the
## additivity route attributes it to Gamma_3. This prices state E's causal
## standing, which is conditional on an assumption rather than on randomization.
SYNERGY <- c(0.00, 0.20)

## --- the diagnostics under test ----------------------------------------------
##
## The first two are exactly what CMP-14 asks to be made default output. The
## third is the existing estimability screen, included because `cpaic` already
## ships it and a new summary has to beat what exists. The fourth is this
## study's proposed replacement, which costs nothing extra because it comes from
## the same information matrix.
##
## CMP-14 ASKS FOR TWO SUMMARIES AND THEY PRODUCE THREE RULES. The effective
## likelihood rank has a whole-model reading and a per-parameter one, and round 6
## found the exported table carrying the per-parameter numbers under the
## whole-model name while the whole-model count controlled no decision at all.
## Both are listed, under the names they are computed from.
DIAGNOSTICS <- c("contraction", "target_ratio", "eff_rank", "rank_screen",
                 "source_survival")

## Registered thresholds. Contraction below CONTRACT_OK means "the likelihood
## moved this parameter", which is how such a summary would be read; the value
## is the conventional halving of the prior SD. The effective rank counts
## directions where the likelihood outweighs the prior, so its natural threshold
## is 1 and the parameter-level version asks whether the target's own direction
## clears it. SOURCE_OK is the share of the target's marginal likelihood
## precision that must come from randomized within-study rows.
CONTRACT_OK  <- 0.50
EFF_RATIO_OK <- 1.00
SOURCE_OK    <- 0.50

## --- the outcome that defines a failure --------------------------------------
## A scenario is a FAILURE if the 95% interval for the causal estimand covers it
## less often than this. Registered before any scenario was evaluated.
COVER_BAD <- 0.90
NOMINAL   <- 0.95

## THE TOLERANCE AROUND NOMINAL, REGISTERED RATHER THAN SLIPPED IN.
##
## Round 2 found `NOMINAL - 0.01` written into four files as though it were
## nominal, while the null control's minimum is 0.9474 and the document claimed
## no scenario covers below nominal. It does: exact coverage of a Bayesian
## interval is not exactly 0.95 even with no misspecification, because the
## posterior SD and the sampling SD of its centre differ under any prior that
## contributes precision.
##
## The slack is therefore named, registered and used from here, so that "nominal"
## in this study means a stated interval rather than a threshold that moves by a
## hidden hundredth wherever it is convenient. A scenario is NOMINAL if its
## coverage lies within COVER_TOL of NOMINAL.
COVER_TOL <- 0.01

## --- E2, the nonlinear arm ---------------------------------------------------
##
## Round 1 found E2 registered as a fitted `multinma` arm whose sampler policy,
## refit rule, failure handling, grid, sample sizes and priors did not exist
## anywhere, while the protocol said they were "registered in R/00-config.R
## alongside the rest". They are registered here now, and E2 is no longer claimed
## to be fitted: it is an asymptotic calculation from the Fisher information of a
## logistic component model (R/06-nonlinear.R), which needs no sampler and
## therefore no sampler policy.
E2_LINK   <- "logit"
E2_STATES <- c("own_ipd", "additivity", "ecological", "curvature", "absent")

## The curvature state is identified by a contrast in covariate SDs, not means.
## Ratio 1.0 is the negative control: equal SDs must identify nothing, on either
## link, which is what makes the state nonlinear-only rather than merely weak.
E2_SD_RATIO <- c(1.0, 1.5, 3.0)

## A reduced factorial, because E2 exists to test whether E1's conclusion
## survives a nonlinear link rather than to re-map the whole surface. The levels
## kept are the ones E1 found the conclusion turns on: the between-study spread,
## the discordance, and the prior scale spanning tight to weak.
E2_SPREADS  <- c(0.6, 2.0)
E2_DISCORD  <- c(0.00, 0.40)
E2_TOTAL_N  <- c(3000L, 10000L)
E2_PRIOR_SD <- c(0.1, 1.0)
E2_SYNERGY  <- c(0.00, 0.20)

## The outcome prevalence the logistic model is centred on. Away from 0.5,
## because that is where the link is most curved and where an aggregate arm's
## dependence on the covariate variance is strongest; at exactly 0.5 the
## second-order term that carries the curvature route is smallest.
E2_BASE_P <- 0.30

## NEITHER DEPARTURE IS LIKELIHOOD MISSPECIFICATION. Round 6 established that
## discordance and synergy are each exactly a shift of the target coefficient:
## every row the departure touches is a row carrying the target, and every row
## carrying the target is touched, so the fitted model reproduces the true arm
## probabilities exactly at theta* = theta_true + shift on that one coordinate.
## The model is correct and the ESTIMAND is aliased. `evaluate_e2` asserts the
## reproduction per scenario rather than relying on the argument, and this is the
## tolerance it asserts against; the measured worst case is of order 1e-16, so the
## threshold is loose by four orders of magnitude and still cannot pass a real
## departure from aliasing.
E2_ALIAS_TOL <- 1e-12

SEED <- 20260729L
