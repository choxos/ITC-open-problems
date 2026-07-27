## The estimators.
##
## All of them maximize an integrated component ML-NMR likelihood. They differ in
## one thing: how the treatment-by-covariate interaction is parameterized, and
## therefore whether within-trial and across-trial information are forced to
## share a parameter.
##
## Study intercepts are profiled out analytically. For a Poisson log-linear model
## with a free intercept per study, the profile has a closed form: writing the
## linear predictor as alpha_s + r, the score for alpha_s gives
##
##   exp(alpha_s) = E_s / D_s,
##
## where E_s is the total events in study s and D_s the total of exp(r) weighted
## by cell size, with aggregate arms contributing their exactly integrated mean.
## Profiling leaves 3 to 7 slope parameters, which is what makes 192,000 datasets
## by four estimators affordable.

## Expand the cell-level data into the rows the likelihood needs.
##
## An IPD arm contributes two independent Poisson observations, one per covariate
## cell. An aggregate arm contributes one Poisson observation whose mean is the
## size-weighted sum over the same two cells. That difference is the entire
## distinction between the data types here.
prep <- function(dat) {
  list(
    ipd = {
      k <- dat$ipd
      if (!any(k)) NULL else data.frame(
        study = rep(dat$study[k], 2), p = rep(dat$p[k], 2),
        aA = rep(dat$aA[k], 2), aB = rep(dat$aB[k], 2),
        x = rep(c(0, 1), each = sum(k)),
        n = c(dat$n0[k], dat$n1[k]), y = c(dat$y0[k], dat$y1[k]))
    },
    agd = {
      k <- !dat$ipd
      if (!any(k)) NULL else list(
        study = dat$study[k], p = dat$p[k],
        aA = dat$aA[k], aB = dat$aB[k],
        n0 = dat$n0[k], n1 = dat$n1[k], y = dat$ytot[k])
    },
    n_study = max(dat$study)
  )
}

## Design matrices. Each model is linear in its parameters on the log-rate scale
## given the covariate value, so the linear predictor is a matrix product and the
## gradient below is exact.
##
##   shared : beta*z + aA*dA + aB*dB + aA*gA*(x - 0.5) + aB*gB*(x - 0.5)
##   split  : beta*z + aA*dA + aB*dB + aA*gWA*z + aB*gWB*z
##                                   + aA*gBA*(p - 0.5) + aB*gBB*(p - 0.5)
##   stage1 : beta*z + aA*gWA*z + aB*gWB*z            (intercept per study-arm)
##
## The shared model's interaction sits on the globally centered covariate, which
## is what current practice fits, and which algebraically forces gammaW = gammaB.
dmat <- function(x, p, aA, aB, model) {
  z <- x - p
  switch(model,
    shared = cbind(z, aA, aB, aA * (x - 0.5), aB * (x - 0.5)),
    split  = cbind(z, aA, aB, aA * z, aB * z, aA * (p - 0.5), aB * (p - 0.5)),
    stage1 = cbind(z, aA * z, aB * z),
    stage2 = cbind(z, aA, aB, aA * (p - 0.5), aB * (p - 0.5)),
    stop("unknown model: ", model))
}

PARNAMES <- list(
  shared = c("beta", "dA", "dB", "gA", "gB"),
  split  = c("beta", "dA", "dB", "gWA", "gWB", "gBA", "gBB"),
  stage1 = c("beta", "gWA", "gWB"),
  stage2 = c("beta", "dA", "dB", "gBA", "gBB")
)

## Profiled negative log likelihood, and its exact gradient.
##
## `group` says what an intercept is free over: `study` for the main models,
## `arm` for stage 1, where a separate intercept per study-arm removes every
## across-arm and across-study contrast and leaves only the randomized
## within-arm covariate contrast to identify gammaW.
make_nll <- function(d, model, offset_ipd = NULL, offset_agd0 = NULL,
                     offset_agd1 = NULL, group = c("study", "arm"),
                     keep = NULL) {
  group <- match.arg(group)
  I <- d$ipd; A <- d$agd

  ## `keep` drops columns that carry no information in this dataset, so a
  ## component with no individual-data arm yields a smaller model rather than a
  ## rank-deficient one.
  sub <- function(M) if (is.null(M) || is.null(keep)) M else M[, keep, drop = FALSE]
  Mi <- sub(if (!is.null(I)) dmat(I$x, I$p, I$aA, I$aB, model) else NULL)
  Ma0 <- sub(if (!is.null(A)) dmat(0, A$p, A$aA, A$aB, model) else NULL)
  Ma1 <- sub(if (!is.null(A)) dmat(1, A$p, A$aA, A$aB, model) else NULL)

  oi  <- if (is.null(offset_ipd))  0 else offset_ipd
  oa0 <- if (is.null(offset_agd0)) 0 else offset_agd0
  oa1 <- if (is.null(offset_agd1)) 0 else offset_agd1

  ## Grouping key for the profiled intercept.
  gi <- if (is.null(I)) integer(0) else
    if (group == "study") I$study else as.integer(factor(paste(I$study, I$aA, I$aB)))
  ga <- if (is.null(A)) integer(0) else A$study
  lev <- sort(unique(c(gi, ga)))
  gi <- match(gi, lev); ga <- match(ga, lev)
  ng <- length(lev)

  ## Total events per group: fixed, so computed once.
  E <- numeric(ng)
  if (!is.null(I)) E <- E + as.vector(tapply(I$y, factor(gi, 1:ng), sum, default = 0))
  if (!is.null(A)) E <- E + as.vector(tapply(A$y,  factor(ga, 1:ng), sum, default = 0))

  function(theta, grad = FALSE) {
    ei <- if (is.null(I)) numeric(0) else I$n * exp(as.vector(Mi %*% theta) + oi)
    if (!is.null(A)) {
      e0 <- A$n0 * exp(as.vector(Ma0 %*% theta) + oa0)
      e1 <- A$n1 * exp(as.vector(Ma1 %*% theta) + oa1)
      R <- e0 + e1
    } else R <- numeric(0)

    D <- numeric(ng)
    if (!is.null(I)) D <- D + as.vector(tapply(ei, factor(gi, 1:ng), sum, default = 0))
    if (!is.null(A)) D <- D + as.vector(tapply(R,  factor(ga, 1:ng), sum, default = 0))
    if (any(!is.finite(D)) || any(D <= 0)) return(if (grad) rep(NA_real_, length(theta)) else NA_real_)

    ## Profiled log likelihood, constants dropped.
    ll <- -sum(E * log(D))
    if (!is.null(I)) ll <- ll + sum(I$y * (as.vector(Mi %*% theta) + oi))
    if (!is.null(A)) ll <- ll + sum(A$y * log(R))
    if (!grad) return(-ll)

    ## Gradient. d/dtheta of -sum(E log D) + data terms.
    w <- E / D
    g <- numeric(length(theta))
    if (!is.null(I)) {
      g <- g + as.vector(crossprod(Mi, I$y))
      g <- g - as.vector(crossprod(Mi, ei * w[gi]))
    }
    if (!is.null(A)) {
      dR <- Ma0 * e0 + Ma1 * e1                     # d R / d theta
      g <- g + as.vector(crossprod(dR, A$y / R))
      g <- g - as.vector(crossprod(dR, w[ga]))
    }
    -g
  }
}

## Fit by maximum likelihood with analytic gradients and deterministic restarts.
##
## Restarts are fixed rather than random so a replicate gives the same answer on
## re-run, which the harness's seeding otherwise guarantees and this would break.
fit_ml <- function(nll, npar, starts = NULL) {
  if (is.null(starts)) {
    starts <- list(rep(0, npar), rep(0.2, npar), rep(-0.2, npar))
  }
  best <- NULL
  for (s0 in starts) {
    o <- tryCatch(stats::nlminb(s0, function(th) nll(th, FALSE),
                                function(th) nll(th, TRUE),
                                control = list(iter.max = 300, eval.max = 500)),
                  error = function(e) NULL)
    if (is.null(o) || !is.finite(o$objective)) next
    if (is.null(best) || o$objective < best$objective) best <- o
  }
  if (is.null(best)) return(NULL)

  ## Polish with Newton steps on the analytic gradient.
  ##
  ## The protocol declares a replicate unconverged if the maximum absolute score
  ## exceeds 1e-6. nlminb routinely stops around 1e-3, which is numerically a
  ## fine optimum here (the information eigenvalues are of order 100, so 1e-3 of
  ## score is 1e-5 of parameter) but would fail the stated rule on essentially
  ## every replicate. Rather than loosen a rule that was fixed in advance, the
  ## optimum is polished until it actually meets it. Steps are halved if they do
  ## not improve the objective, so this cannot walk away from a good point.
  par <- best$par; obj <- best$objective
  for (it in 1:25) {
    g <- nll(par, TRUE)
    if (max(abs(g)) <= 1e-10) break
    H <- obs_info(nll, par)
    step <- tryCatch(solve(H, g), error = function(e) NULL)
    if (is.null(step) || any(!is.finite(step))) break
    ok <- FALSE
    for (s in c(1, 0.5, 0.25, 0.125)) {
      cand <- par - s * step
      o <- nll(cand, FALSE)
      if (is.finite(o) && o <= obj + 1e-10) { par <- cand; obj <- o; ok <- TRUE; break }
    }
    if (!ok) break
  }

  g <- nll(par, TRUE)
  ## An optimizer's own convergence code is not enough: nlminb reports success at
  ## points where the score is still large. The score is the thing that defines a
  ## maximum, so it is what gets checked.
  list(par = par, objective = obj, code = best$convergence,
       max_score = max(abs(g)))
}

## Observed information from the profiled log likelihood, by central differences
## on the analytic gradient. Cheaper and more accurate than differencing the
## objective twice.
obs_info <- function(nll, theta, h = 1e-5) {
  k <- length(theta)
  H <- matrix(0, k, k)
  for (j in seq_len(k)) {
    tp <- theta; tp[j] <- tp[j] + h
    tm <- theta; tm[j] <- tm[j] - h
    H[, j] <- (nll(tp, TRUE) - nll(tm, TRUE)) / (2 * h)
  }
  (H + t(H)) / 2
}

CONV <- list(max_score = 1e-6, max_abs_par = 5, min_eig = 1e-8, max_cond = 1e10)

## Turn a fit plus its information matrix into estimates and Wald intervals,
## refusing to report anything that fails the declared convergence rules.
wald <- function(fit, H, names, z = stats::qnorm(0.975)) {
  if (is.null(fit)) return(NULL)
  if (fit$max_score > CONV$max_score) return(NULL)
  if (max(abs(fit$par)) > CONV$max_abs_par) return(NULL)
  ev <- tryCatch(eigen(H, symmetric = TRUE, only.values = TRUE)$values,
                 error = function(e) NULL)
  if (is.null(ev) || min(ev) <= CONV$min_eig ||
      max(ev) / max(min(ev), .Machine$double.eps) > CONV$max_cond) return(NULL)
  V <- tryCatch(solve(H), error = function(e) NULL)
  if (is.null(V) || any(!is.finite(diag(V))) || any(diag(V) <= 0)) return(NULL)
  se <- sqrt(diag(V))
  stats::setNames(data.frame(est = fit$par, se = se,
                             lower = fit$par - z * se, upper = fit$par + z * se,
                             par = names, stringsAsFactors = FALSE),
                  c("est", "se", "lower", "upper", "par"))
}
