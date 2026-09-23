## ---------------------------------------------------------------------------
## OUT-06: does the change-versus-endpoint choice interact with population
## adjustment?
##
## Baseline Y0 is measured before treatment, so Y0(1) = Y0(0) = Y0 and for any
## target law F_T,
##   E_T[Y1(b) - Y1(a)] = E_T[(Y1 - Y0)(b) - (Y1 - Y0)(a)].
## The target follow-up contrast and the target change contrast are the same
## number whatever the adjustment. What can differ is an estimator:
##   - G-computation with Y0 in a linear outcome model gives identical treatment
##     and treatment-by-Y0 coefficients whether the outcome is Y1 or Y1 - Y0, so
##     the individual-data side agrees to machine precision; in an anchored
##     comparison the published aggregate contrasts still differ by that trial's
##     chance baseline imbalance, which is zero in expectation;
##   - weighting with one weight function for both arms leaves a between-arm
##     difference in weighted Y0 that is zero in expectation, so the two agree in
##     expectation and differ in variance;
##   - a comparison that does not adjust for Y0 across populations (unanchored and
##     unmatched) differs by exactly the baseline gap, bias (b - 1) shift for the
##     change score against b shift for the endpoint, independent of any
##     baseline-by-treatment interaction.
## DESIGN.md predicts divergence from the product of that interaction and the
## baseline shift. The grid tests it.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260925L
N_ARM <- 300L
DELTA_A <- -0.4; DELTA_B <- -0.2
N_SIM <- 1000L

LEVELS <- list(design = c("anchored", "unanchored"), shift = c(0, 0.5, 1),
               beta = c(0, 0.3), b = c(0.4, 0.8))

build_grid <- function() {
  g <- expand.grid(design = LEVELS$design, shift = LEVELS$shift, beta = LEVELS$beta,
                   b = LEVELS$b, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Y0 ~ N(mu, 1); Y1 = b Y0 + delta_t + beta_t Y0 + e, e ~ N(0, 1 - b^2), so
## corr(Y0, Y1) = b in the control arm. A is modified by baseline, B is not.
gen <- function(n, mu, t, cell) {
  y0 <- stats::rnorm(n, mu)
  d <- c(C = 0, A = DELTA_A, B = DELTA_B)[[t]]
  be <- if (t == "A") cell$beta else 0
  y1 <- cell$b * y0 + d + be * y0 + stats::rnorm(n, 0, sqrt(1 - cell$b^2))
  data.frame(y0 = y0, y1 = y1)
}

## Estimand: E_T[Y1(B) - Y1(A)] with Y0 ~ N(shift, 1) in the target.
truth <- function(cell) DELTA_B - DELTA_A - cell$beta * cell$shift

draw <- function(cell) {
  list(A = gen(N_ARM, 0, "A", cell), C = gen(N_ARM, 0, "C", cell),
       B = gen(N_ARM, cell$shift, "B", cell), D = gen(N_ARM, cell$shift, "C", cell))
}

w_match <- function(x, target) {
  xc <- x - target
  a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20), tol = 1e-12)$root
  exp(a * xc)
}
wm <- function(y, w) sum(w * y) / sum(w)

## Every method in both representations. rep = "end" uses Y1, "chg" uses Y1 - Y0.
fit_all <- function(cell, d) {
  anch <- cell$design == "anchored"
  out <- r_ <- function(v) v
  ## aggregate side, as published: arm means of Y1 and of Y1 - Y0
  agg <- function(rep) {
    f <- function(z) if (rep == "end") mean(z$y1) else mean(z$y1 - z$y0)
    if (anch) f(d$B) - f(d$D) else f(d$B)
  }
  ind <- rbind(cbind(d$A, A = 1), cbind(d$C, A = 0))
  if (!anch) ind <- ind[ind$A == 1, ]
  target_y0 <- if (anch) mean(c(d$B$y0, d$D$y0)) else mean(d$B$y0)
  src <- function(w, rep) {
    y <- if (rep == "end") ind$y1 else ind$y1 - ind$y0
    if (anch) wm(y[ind$A == 1], w[ind$A == 1]) - wm(y[ind$A == 0], w[ind$A == 0])
    else wm(y, w)
  }
  wn <- rep(1, nrow(ind)); wp <- w_match(ind$y0, target_y0)
  gc <- function(rep) {
    y <- if (rep == "end") ind$y1 else ind$y1 - ind$y0
    if (anch) {
      f <- stats::lm(y ~ y0 * A, data = cbind(ind[, c("y0", "A")], y = y))
      cf <- stats::coef(f)
      cf[["A"]] + cf[["y0:A"]] * target_y0
    } else {
      f <- stats::lm(y ~ y0, data = cbind(ind["y0"], y = y))
      sum(stats::coef(f) * c(1, target_y0))
    }
  }
  res <- list()
  for (rep in c("end", "chg")) {
    a <- agg(rep)
    res[[paste0("naive_", rep)]] <- a - src(wn, rep)
    res[[paste0("maic_", rep)]] <- a - src(wp, rep)
    res[[paste0("gcomp_", rep)]] <- a - gc(rep)
  }
  unlist(res)
}
