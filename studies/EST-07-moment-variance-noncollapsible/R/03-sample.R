## ---------------------------------------------------------------------------
## One replicate: source IPD, and the target trial's REPORTED summaries.
##
## The anchored two-trial PAIC geometry. The source trial has individual data on
## treatments A and C; the target trial publishes covariate means and SDs plus
## its own B-versus-C effect, and nothing else. What the analyst never sees is
## the target's covariate correlations and its individual data, which is the
## whole subject of the study.
##
## `hidden` carries the quantities an analyst cannot have but the simulation
## knows, so bias against each estimand can be computed exactly rather than
## approximated. Nothing in `hidden` may reach an estimator; `R/04-maic.R` takes
## `source` and `target_reported` only, and the run script passes nothing else.
##
##   source("R/03-sample.R")
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
source("R/02-gradient.R")

## The matched moment set: means and SDs of each covariate, which is what a
## baseline table reports. `h(x)` is the balancing function MAIC matches on, so
## it is x and x^2; matching the second raw moment is matching the SD given the
## mean, and the two parameterizations differ only in bookkeeping.
##
## EXCEPT FOR A BINARY COVARIATE, WHERE x^2 = x IDENTICALLY. A naive `cbind(x,
## x^2)` then contains a duplicate column, the balancing problem is rank
## deficient, and the sandwich's Jacobian is singular: measured, rank 5 of 6, and
## every replicate in the `mixed` shape arm failed with `singular-jacobian`.
##
## This is a fact about MAIC and not only about this code. A binary covariate's
## mean determines its whole distribution, so there is no second moment to match,
## and an implementation that always forms two columns per covariate cannot fit
## the mixed-type case that most applied baseline tables contain. `binary_cols`
## is returned so the moment reconstruction uses the same index rather than
## rediscovering it.
binary_cols <- function(x)
  apply(x, 2, function(z) all(z %in% c(0, 1)))

## WHICH COVARIATES THE TARGET REPORTS.
##
## ROUND 1 OF CRITIQUE: the `outside` arm was supposed to put one effect modifier
## OUTSIDE the matched moment set, acting through a covariate the target does not
## report, so that no amount of moment matching can balance it. It did add a
## fourth covariate, and then `h_of()` matched all four and the target reported
## all four. The arm was identical to `inside` with one more matched modifier,
## which is the opposite of what it was registered to test.
##
## `reported_cols()` is the single place that says what a baseline table contains.
## The source keeps every covariate, because they all drive its outcomes and it
## has individual data; the target reports the first `n_rep` of them, and the
## unreported one is what makes the arm unbalanceable.
n_reported <- function(p, modifier_span)
  if (identical(modifier_span, "outside")) p - 1L else p

reported_cols <- function(x, modifier_span)
  seq_len(n_reported(ncol(x), modifier_span))

## The balancing function, over the REPORTED covariates only. MAIC cannot match a
## moment nobody published, so `h` must not contain one.
h_of <- function(x, modifier_span = "inside") {
  cols <- reported_cols(x, modifier_span)
  xr <- x[, cols, drop = FALSE]
  b <- binary_cols(xr)
  h <- cbind(xr, xr[, !b, drop = FALSE]^2)
  attr(h, "binary") <- b
  attr(h, "n_mean") <- ncol(xr)
  h
}

## The source and target populations differ by `OVERLAP_SMD` on every covariate,
## which is how the design fixes overlap at the moderate level of the Phillippo
## et al. 2020 grid rather than letting it drift with the other factors.
## `shape` HAS NO DEFAULT ON PURPOSE. The binary covariate under `mixed` needs a
## different latent shift from the continuous ones to realize the same overlap,
## so a caller that does not say which shape it means would silently get the
## wrong target population. Round 1 of critique found the mixed arm running at a
## realized SMD of 0.001 instead of 0.40; a default here is how that would come
## back.
population_means <- function(smd = OVERLAP_SMD, p = N_COVARIATE, shape) {
  if (missing(shape)) stop("population_means() needs the shape: the binary ",
                           "covariate's target mean depends on it")
  target <- rep(smd, p)
  ## Solved in R/01-dgm so the realized binary SMD equals the registered one.
  ## The continuous covariates keep the registered latent shift because for them
  ## the latent and realized scales coincide.
  if (identical(shape, "mixed")) target[1] <- BINARY_SHIFT
  list(source = rep(0, p), target = target)
}

## --- the parameter vector, with k doing MIS-03's job ------------------------
##
## `k` is the alignment between the two trials' effect modification. At k = 0
## only the source treatment is modified, so the omitted term is a pure positive
## variance; at k = 1 both are modified identically and the omitted covariance is
## negative, making the status-quo interval too wide rather than too narrow. The
## registered cancellation point is k = 1/4, and MIS-03 had no interior level to
## test, which is what left its recommendation silent between 1/4 and 1/2.
make_pars <- function(k, em_strength = 0.6, modifier_span = "inside",
                      p = N_COVARIATE) {
  beta_em <- numeric(p)
  beta_em[1] <- em_strength
  if (modifier_span == "outside") {
    ## One modifier OUTSIDE the matched moment set: it acts through a covariate
    ## the target does not report, so no amount of moment matching can balance
    ## it. MIS-03 has effect modification exactly in the span of the matched
    ## moments, so it is a variance result under correct identification and says
    ## nothing about the bias this arm creates.
    beta_em <- c(beta_em, em_strength)
  }
  list(alpha = -0.8, beta_prog = rep(c(0.4, 0.3, 0.2), length.out = length(beta_em)),
       tau0 = 0.5, beta_em = beta_em, k = k)
}

## --- one replicate ----------------------------------------------------------
sample_replicate <- function(nS, nT, k, link, shape, rho_true,
                             modifier_span = "inside", em_strength = 0.6,
                             smd = OVERLAP_SMD, baseline_shift = 0,
                             anchored = TRUE) {
  pars <- make_pars(k, em_strength, modifier_span)
  p <- length(pars$beta_em)
  pm <- population_means(smd, p, shape)
  sigma <- rep(1, p)

  ## SOURCE: individual data, randomized A versus C.
  xs <- covariate_law(shape, nS, pm$source, sigma, rho_true)
  As <- rbinom(nS, 1, 0.5)
  cms <- conditional_means(xs, pars, link)
  mus <- ifelse(As == 1, cms$mu1, cms$mu0)
  Ys <- draw_outcome(mus, link)

  ## TARGET: individual data are generated and then thrown away except for what
  ## a paper reports. The B-versus-C effect is the target trial's own estimate,
  ## and `k` sets how much of the source's modification it shares.
  xt <- covariate_law(shape, nT, pm$target, sigma, rho_true)
  pars_T <- pars
  pars_T$beta_em <- k * pars$beta_em
  ## The target trial's own baseline risk. Cancels in the anchored contrast and
  ## does not in the unanchored one, which is the whole reason anchoring exists.
  pars_T$alpha <- pars$alpha + baseline_shift
  Bt <- rbinom(nT, 1, 0.5)
  cmt <- conditional_means(xt, pars_T, link)
  mut <- ifelse(Bt == 1, cmt$mu1, cmt$mu0)
  Yt <- draw_outcome(mut, link)

  lf <- link_fns(link)
  theta_BC <- lf$g(mean(Yt[Bt == 1])) - lf$g(mean(Yt[Bt == 0]))
  ## THE TARGET TRIAL REPORTS ITS OWN STANDARD ERROR, and it is computed from the
  ## realized arm data rather than assumed. Round 1 of critique found the earlier
  ## version hard-coding p = 0.5 and equal arms, which understated the variance by
  ## 3.7 times on logit and 4.25 times on cloglog, measured against simulation.
  ## Every method shares this term, so every interval was too narrow for a reason
  ## having nothing to do with target-moment uncertainty.
  var_BC <- arm_contrast_var(Yt, Bt, link)

  list(
    ## The source keeps every covariate; `h` is built over the reported ones only.
    source = list(x = xs, h = h_of(xs, modifier_span), A = As, Y = Ys,
                  reported = reported_cols(xs, modifier_span)),
    ## Exactly what a baseline table gives: means, SDs, the effect, and n, for
    ## the covariates the target actually publishes. Under `outside` the last
    ## covariate appears nowhere here, which is the whole point of that arm.
    target_reported = local({
      cols <- reported_cols(xt, modifier_span)
      xr <- xt[, cols, drop = FALSE]
      b <- binary_cols(xr)
      list(mean = colMeans(xr), sd = apply(xr, 2, stats::sd),
           ## The reported moment vector matches h's structure exactly, including
           ## the dropped squares for binary covariates.
           m = c(colMeans(xr), colMeans(xr[, !b, drop = FALSE]^2)),
           binary = b, n_reported = length(cols),
           theta_BC = theta_BC, var_theta_BC = var_BC,
           ## WHAT AN UNANCHORED COMPARISON GETS: the target's treated arm alone,
           ## on the reported scale, with its own delta-method variance. There is
           ## no common comparator to difference against, so this single arm
           ## replaces `theta_BC` and carries far less variance than a two-arm
           ## contrast, which is why the moment term is a larger share of the
           ## total without an anchor.
           g_mu_B = lf$g(mean(Yt[Bt == 1])),
           var_g_mu_B = arm_mean_var(Yt[Bt == 1], link),
           nT = nT)
    }),
    ## Never passed to an estimator. Used only to compute truth.
    ## `k` and `modifier_span` join the oracle fields because the calibrated
    ## cross-covariance in R/14 is keyed on them. They identify the CELL, not the
    ## replicate, so carrying them leaks nothing a run configuration does not
    ## already know; the estimators that may read them are the oracle arms only.
    hidden = list(x = xt, pars = pars, pars_T = pars_T, rho_true = rho_true,
                  baseline_shift = baseline_shift, anchored = anchored,
                  shape = shape, link = link, sigma = sigma, k = k,
                  modifier_span = modifier_span, pop_mean_T = pm$target))
}

## The delta-method variance of g(mean) for ONE arm, which is what an unanchored
## comparison differences against.
arm_mean_var <- function(y, link) {
  n <- length(y)
  if (n < 2L) return(NA_real_)
  m <- mean(y)
  v <- if (identical(link, "identity")) stats::var(y) / n else m * (1 - m) / n
  d <- switch(link, identity = 1,
              logit = 1 / (m * (1 - m)),
              cloglog = 1 / (m * log(m)),
              stop("unregistered link: ", link))
  d^2 * v
}

## The delta-method variance of an anchored two-arm contrast on the reported
## scale, from the arms as realized. A published trial reports an effect and an
## interval; this is that interval's variance, and computing it from the data is
## both what a trial does and the only way it can be right when the arm
## probabilities are whatever the DGM makes them.
arm_contrast_var <- function(Y, A, link) {
  n1 <- sum(A == 1); n0 <- sum(A == 0)
  if (n1 < 2 || n0 < 2) return(NA_real_)
  if (link == "identity")
    return(stats::var(Y[A == 1]) / n1 + stats::var(Y[A == 0]) / n0)
  p1 <- mean(Y[A == 1]); p0 <- mean(Y[A == 0])
  ## Guard the boundary: a zero or one arm proportion has no finite delta-method
  ## variance on either curved scale, and returning NA drops the replicate rather
  ## than reporting an interval of infinite or zero width.
  if (min(p1, p0) <= 0 || max(p1, p0) >= 1) return(NA_real_)
  dg <- switch(link,
    logit   = c(1 / (p1 * (1 - p1)), 1 / (p0 * (1 - p0))),
    cloglog = c(1 / (p1 * log(p1)),  1 / (p0 * log(p0))),
    stop("unregistered link: ", link))
  dg[1]^2 * p1 * (1 - p1) / n1 + dg[2]^2 * p0 * (1 - p0) / n0
}

## Outcome draws per link. The Weibull PH arm is generated on the survival scale
## and reduced to the cumulative hazard at the registered horizon, so `cloglog`
## is a genuine time-to-event arm rather than a relabeled binary one.
draw_outcome <- function(mu, link) switch(link,
  identity = mu + rnorm(length(mu)),
  logit    = rbinom(length(mu), 1, mu),
  ## `mu` is S(t0) under the conditional model; a Bernoulli at that survival
  ## probability is the event indicator at the horizon, which is what an
  ## anchored log-cumulative-hazard contrast is built from.
  cloglog  = rbinom(length(mu), 1, mu),
  stop("unregistered link: ", link))
