## ---------------------------------------------------------------------------
## MAIC weights, the reported panel, and the geometric candidates.
##
## THE ALGEBRAIC FACT THIS STUDY IS ABOUT. Every member of the reported panel is a
## symmetric function of the weight vector: permute which unit carries which
## weight and the number does not move. So none of them can encode WHERE the
## supported region is. That is not an empirical claim and the study does not
## treat it as one; it is checked at numerical precision as a control, and a
## difference means the arms were not matched rather than that the algebra failed.
##
## The candidates that can win are the ones that read position as well as weight.
##
##   source("R/02-panel.R")
## ---------------------------------------------------------------------------

source("R/01-dgm.R")

## --- MAIC weights -----------------------------------------------------------
##
## Method of moments on the balancing function, which is the standard
## implementation: minimize sum(exp(h a)) - a' m_T, whose stationary point matches
## the weighted moments to the target's.
balancing <- function(x, omitted_moment) {
  d <- ncol(x)
  h <- cbind(x, x^2)
  if (identical(omitted_moment, "one_modifier_second_moment")) {
    ## Section 2 consequence 3: balance is reported on the moments that were
    ## matched, which is tautological. Dropping the modifier's second moment from
    ## the matched set is what leaves the cheap candidate something to see.
    h <- h[, -(d + 1L), drop = FALSE]
  }
  h
}

fit_weights <- function(h, m_T, maxit = 1000L) {
  obj <- function(a) {
    lp <- as.vector(h %*% a)
    lp <- lp - max(lp)
    sum(exp(lp)) - sum(a * m_T) * exp(-max(as.vector(h %*% a)))
  }
  ## The standard dual objective, in the numerically stable form: minimize
  ## log sum exp(h a) - a' m_T.
  f <- function(a) {
    lp <- as.vector(h %*% a)
    mx <- max(lp)
    (mx + log(sum(exp(lp - mx)))) - sum(a * m_T)
  }
  g <- function(a) {
    lp <- as.vector(h %*% a); mx <- max(lp)
    w <- exp(lp - mx); w <- w / sum(w)
    as.vector(crossprod(h, w)) - m_T
  }
  opt <- stats::optim(rep(0, ncol(h)), f, g, method = "BFGS",
                      control = list(maxit = maxit, reltol = 1e-12))
  lp <- as.vector(h %*% opt$par); lp <- lp - max(lp)
  w <- exp(lp)
  list(w = w / sum(w), par = opt$par, conv = opt$convergence,
       imbalance = max(abs(g(opt$par))))
}

## --- the reported panel: functions of the multiset alone ---------------------
##
## Each is invariant to permuting the assignment of weights to units, which is
## the whole complaint.
panel_multiset <- function(w) {
  w <- w / sum(w); n <- length(w)
  p <- w[w > 0]
  list(
    ess_kish   = 1 / sum(w^2),                       # (sum w)^2 / sum w^2 at sum w = 1
    ess_pct    = (1 / sum(w^2)) / n,
    entropy_eff = exp(-sum(p * log(p))) / n,
    max_weight = max(w),
    top_share  = sum(sort(w, decreasing = TRUE)[seq_len(max(1L, ceiling(0.05 * n)))])
  )
}

## The three competing ESS definitions, reported for their SPREAD rather than
## their discrimination. Two analyses of the same evidence reporting incomparable
## numbers is a separate defect from blindness to geometry, with a separate fix,
## and its size has never been quantified.
ess_definitions <- function(w) {
  w <- w / sum(w); n <- length(w)
  c(kish = 1 / sum(w^2),
    ## The variance-of-weights form, as it appears in several implementations.
    cv   = n / (1 + stats::var(w * n) / mean(w * n)^2),
    ## The entropy form.
    entropy = exp(-sum(w[w > 0] * log(w[w > 0]))))
}

## --- the candidates that read position --------------------------------------
##
## `balance_omitted` is the comparator registered as most likely to overturn the
## expected headline: it costs nothing and every implementation can already
## compute it.
diagnostics_geometric <- function(xs, w, xt, omitted_moment) {
  w <- w / sum(w)
  d <- ncol(xs)

  ## Standardized difference on a moment that was NOT matched. Under
  ## `omitted_moment = "none"` every moment is matched and this is tautologically
  ## near zero, which is itself the point: the cheap candidate only has something
  ## to see when something was left out.
  wm2 <- sum(w * xs[, 1]^2)
  tm2 <- mean(xt[, 1]^2)
  sd2 <- stats::sd(xt[, 1]^2)
  balance_omitted <- if (sd2 > 0) abs(wm2 - tm2) / sd2 else 0

  ## Region-specific ESS: the localized version of the panel. Computed on the
  ## target's upper decile of coordinate 1, the region a high-modification hole
  ## empties, using only what an analyst has.
  reg <- xs[, 1] >= stats::quantile(xt[, 1], 1 - HOLE_QUANTILE)
  ess_region <- if (sum(reg) > 0) {
    wr <- w[reg]
    if (sum(wr) > 0) (sum(wr)^2 / sum(wr^2)) else 0
  } else 0

  ## Convex-hull distance, approximated in the coordinate directions: how far the
  ## target's extreme quantiles sit outside the weighted source's realized range.
  ## A full hull in eight dimensions is not affordable per replicate and the
  ## coordinate version captures a wedge removed along one axis, which is the
  ## geometry this design creates.
  eff <- w > (1e-8 / length(w))
  hull_gap <- max(vapply(seq_len(d), function(j) {
    hi <- max(xs[eff, j]); lo <- min(xs[eff, j])
    max(stats::quantile(xt[, j], 0.99) - hi, lo - stats::quantile(xt[, j], 0.01), 0)
  }, 0))

  ## Sliced optimal-transport cost between the weighted source and the target.
  ## The sliced form is an approximation and is named as one: full multivariate
  ## optimal transport per replicate is not affordable, and the sliced version is
  ## a lower bound that still reads position.
  set.seed(11L)
  dirs <- matrix(stats::rnorm(20L * d), 20L, d)
  dirs <- dirs / sqrt(rowSums(dirs^2))
  ot <- mean(vapply(seq_len(nrow(dirs)), function(k) {
    a <- as.vector(xs %*% dirs[k, ]); b <- as.vector(xt %*% dirs[k, ])
    qs <- seq(0.05, 0.95, by = 0.05)
    wa <- wquantile(a, w, qs); qb <- stats::quantile(b, qs, names = FALSE)
    mean(abs(wa - qb))
  }, 0))

  list(balance_omitted = balance_omitted, ess_region = ess_region,
       hull_gap = hull_gap, ot_cost = ot)
}

## Weighted quantiles, needed by the sliced transport cost.
wquantile <- function(x, w, probs) {
  o <- order(x); x <- x[o]; w <- w[o] / sum(w)
  cw <- cumsum(w)
  vapply(probs, function(p) x[which.max(cw >= p)], 0)
}
