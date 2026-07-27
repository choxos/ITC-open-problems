## The diagnostics under test.
##
## Each takes a fitted posterior and returns a number an analyst could read, plus
## whether it fires. They are computed exactly, because the posterior is exact:
## a power-scaled posterior here is another closed-form Gaussian rather than an
## importance-weighted resample, so nothing a diagnostic reports is contaminated
## by Monte Carlo error in the fit. That is the point of the Gaussian reduction.
##
## Raising a normal prior to the power alpha multiplies its precision by alpha,
## so a power-scaled posterior is `posterior(z, H, V, S0 / alpha)`. The same holds
## for the likelihood with V / alpha. This is exact, not an approximation to
## importance-sampled power-scaling, and it is what the importance-sampling
## implementations are approximating.

## Scalar summaries of a contrast under a fitted posterior.
cscalar <- function(fit, cvec) {
  list(m = sum(cvec * fit$m), sd = sqrt(as.numeric(crossprod(cvec, fit$S %*% cvec))))
}

## 1. Prior-to-posterior contraction on a contrast.
##
## 1 - posterior variance / prior variance. Zero means the data moved nothing.
diag_contraction <- function(fit, cvec, S0) {
  vpost <- as.numeric(crossprod(cvec, fit$S %*% cvec))
  vprior <- as.numeric(crossprod(cvec, S0 %*% cvec))
  1 - vpost / vprior
}

## 2. Power-scaling sensitivity, prior and likelihood.
##
## The distance between the base posterior and a power-scaled one, per unit of
## log alpha, computed distributionally rather than from the posterior mean.
##
## That detail is not cosmetic and an earlier version of this file got it wrong.
## In a conjugate Gaussian with a zero-centered prior, raising the prior to the
## power alpha and lowering the likelihood to the power 1/alpha give posteriors
## with EXACTLY the same mean: the precision is G + alpha P either way. A
## mean-shift sensitivity therefore reports identical prior and likelihood
## sensitivity by construction, and a rule of the form "prior sensitive and
## likelihood insensitive" can never fire. Measured with mean shift, the
## diagnostic had zero sensitivity everywhere, which would have been published as
## a property of the method rather than of the implementation.
##
## The posterior standard deviations do differ, so the two are distinguishable
## distributionally, which is how Kallioinen and colleagues define the diagnostic:
## a divergence between the base and power-scaled posteriors. They use cumulative
## Jensen-Shannon distance; the Hellinger distance used here is exact in closed
## form for Gaussians and is on the same [0, 1] scale, so the 0.05 threshold their
## default rule uses carries over.
h2_gauss <- function(a, b) {
  1 - sqrt(2 * a$sd * b$sd / (a$sd^2 + b$sd^2)) *
    exp(-0.25 * (a$m - b$m)^2 / (a$sd^2 + b$sd^2))
}

diag_powerscale <- function(z, H, V, S0, cvec, alpha = 1.25) {
  base <- cscalar(posterior(z, H, V, S0), cvec)
  d <- function(fit) sqrt(h2_gauss(fit, base)) / log(alpha)
  prior_sens <- mean(c(d(cscalar(posterior(z, H, V, S0 / alpha), cvec)),
                       d(cscalar(posterior(z, H, V, S0 * alpha), cvec))))
  lik_sens <- mean(c(d(cscalar(posterior(z, H, V / alpha, S0), cvec)),
                     d(cscalar(posterior(z, H, V * alpha, S0), cvec))))
  c(prior = prior_sens, likelihood = lik_sens)
}

## 3. Prior-only benchmark.
##
## Squared Hellinger distance between the posterior and the prior for the same
## contrast. Near zero means the posterior reproduces the prior. Also reported is
## the change in the decision probability Pr(contrast > 0), which is what a
## committee would actually read.
diag_prioronly <- function(fit, cvec, S0, m0 = rep(0, NP)) {
  a <- cscalar(fit, cvec)
  b <- list(m = sum(cvec * m0),
            sd = sqrt(as.numeric(crossprod(cvec, S0 %*% cvec))))
  h2 <- 1 - sqrt(2 * a$sd * b$sd / (a$sd^2 + b$sd^2)) *
    exp(-0.25 * (a$m - b$m)^2 / (a$sd^2 + b$sd^2))
  c(h2 = h2,
    dprob = abs(stats::pnorm(a$m / a$sd) - stats::pnorm(b$m / b$sd)))
}

## 4. Tight and loose refits.
##
## Halve and double every prior standard deviation and see how far the answer
## moves, in posterior standard deviations and in decision probability. This is
## the check an analyst can run today without any new theory.
diag_refit <- function(z, H, V, S0, cvec) {
  base <- cscalar(posterior(z, H, V, S0), cvec)
  tight <- cscalar(posterior(z, H, V, S0 * 0.25), cvec)      # SD x 0.5
  loose <- cscalar(posterior(z, H, V, S0 * 4), cvec)         # SD x 2
  c(move_sd = abs(loose$m - tight$m) / base$sd,
    move_dprob = abs(stats::pnorm(loose$m / loose$sd) -
                       stats::pnorm(tight$m / tight$sd)))
}

## 5. Structural estimability screen.
##
## Is the contrast in the row space of H? This is what an implementation can
## check without any prior at all, and it is the only one of these that is
## already standard practice. It answers a different question from the others:
## it detects exact nonidentification, not weak identification, so a contrast can
## pass it and still be entirely prior-driven.
diag_rank <- function(cvec, H, tol = 1e-8) {
  s <- svd(H)
  keep <- s$d > tol * max(s$d)
  resid <- cvec - s$v[, keep, drop = FALSE] %*%
    crossprod(s$v[, keep, drop = FALSE], cvec)
  sqrt(sum(resid^2)) <= 1e-6 * max(1, sqrt(sum(cvec^2)))
}

## Thresholds, fixed in the protocol before the run.
THRESH <- list(contraction = 0.20, h2 = 0.10, dprob = 0.05,
               prior_sens = 0.05, lik_sens = 0.05,
               refit_sd = 0.25, refit_dprob = 0.05)

## Everything for one contrast, plus the prespecified composite warning.
##
## The composite fires when at least two of four rules trigger. Requiring two
## rather than one is the design's attempt to buy specificity; whether it does is
## one of the things being measured.
evaluate <- function(z, H, V, S0, cvec) {
  fit <- posterior(z, H, V, S0)
  ct <- diag_contraction(fit, cvec, S0)
  ps <- diag_powerscale(z, H, V, S0, cvec)
  po <- diag_prioronly(fit, cvec, S0)
  rf <- diag_refit(z, H, V, S0, cvec)
  estimable <- diag_rank(cvec, H)

  r1 <- ct < THRESH$contraction
  r2 <- po[["h2"]] < THRESH$h2 && po[["dprob"]] < THRESH$dprob
  r3 <- ps[["prior"]] >= THRESH$prior_sens && ps[["likelihood"]] < THRESH$lik_sens
  r4 <- rf[["move_sd"]] > THRESH$refit_sd || rf[["move_dprob"]] > THRESH$refit_dprob
  n_fire <- sum(r1, r2, r3, r4)

  a <- cscalar(fit, cvec)
  data.frame(
    est = a$m, sd = a$sd,
    contraction = ct, prior_sens = ps[["prior"]], lik_sens = ps[["likelihood"]],
    h2 = po[["h2"]], dprob = po[["dprob"]],
    refit_sd = rf[["move_sd"]], refit_dprob = rf[["move_dprob"]],
    estimable = estimable,
    r_contraction = r1, r_prioronly = r2, r_powerscale = r3, r_refit = r4,
    n_fire = n_fire, composite = n_fire >= 2,
    stringsAsFactors = FALSE)
}
