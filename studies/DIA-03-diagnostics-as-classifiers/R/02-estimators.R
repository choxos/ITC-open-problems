## The three estimators.
##
## All three transport an A versus C effect to the target population and anchor on
## C. They differ in how they adjust, and the study asks whether the diagnostics
## an analyst reports alongside them predict how far each one lands from the truth.
##
## The adjustment set is X1, X2, X3 for every estimator. That is the point: when
## the design switches the X4 modifier on, all three are misspecified in the same
## way, so no method is handed an advantage the others are denied.

## Solve the MAIC calibration equations
##
##   sum_i w_i(lambda) {h(X_i) - m_T} = 0,   w_i = exp(lambda' h(X_i)),
##
## through the equivalent convex objective sum_i exp(lambda' {h(X_i) - m_T}),
## whose gradient is the left side up to a positive factor.
fit_weights <- function(h, m_T, maxit = 500L) {
  hc <- sweep(h, 2, m_T, "-")
  obj <- function(l) {
    z <- as.vector(hc %*% l); mz <- max(z)
    mz + log(sum(exp(z - mz)))
  }
  gr <- function(l) {
    z <- as.vector(hc %*% l); p <- exp(z - max(z))
    as.vector(crossprod(hc, p) / sum(p))
  }
  o <- stats::optim(rep(0, ncol(h)), obj, gr, method = "BFGS",
                    control = list(maxit = maxit, reltol = 1e-12))

  ## Newton polish. Quasi-Newton stops on a relative change in the objective,
  ## which under poor overlap can happen while the calibration score is still
  ## around 1e-3: the weights are then not a MAIC solution, and in a pilot this
  ## discarded a tenth of the replicates in exactly the cells the study is about.
  ## Discarding the hardest replicates would bias every operating characteristic,
  ## so the fix is to solve the equations properly rather than to loosen the rule.
  ## The Hessian of the objective is the weighted covariance of the centered
  ## moments, which is available in closed form.
  lam <- o$par
  for (k in seq_len(50L)) {
    z <- as.vector(hc %*% lam)
    p <- exp(z - max(z)); p <- p / sum(p)
    g <- as.vector(crossprod(hc, p))
    if (max(abs(g)) < 1e-14) break
    H <- crossprod(hc, p * hc) - tcrossprod(g)
    step <- tryCatch(solve(H + diag(1e-12, ncol(H)), g), error = function(e) NULL)
    if (is.null(step) || any(!is.finite(step))) break
    lam <- lam - step
  }

  z <- as.vector(hc %*% lam)
  w <- exp(z - max(z))
  w <- w / mean(w)                       # scale is arbitrary and cancels below
  sdh <- pmax(apply(h, 2, stats::sd), 1e-8)
  list(lambda = lam, w = w, conv = o$convergence,
       max_imbalance = max(abs(colSums(w * hc)) / sum(w) / sdh))
}

## Sandwich variance for the weighted arm-mean difference, treating the weights as
## estimated rather than fixed. Stacking the calibration equations with the two
## weighted arm-mean equations gives an M-estimator in (lambda, mu_A, mu_C); the
## A-inverse B A-inverse form below is the standard robust variance for it, and is
## what maicplus and the TSD 18 code report.
maic_sandwich <- function(h, A, Y, w, m_T) {
  n <- nrow(h); p <- ncol(h)
  muA <- sum(w * A * Y) / sum(w * A)
  muC <- sum(w * (1 - A) * Y) / sum(w * (1 - A))
  hc <- sweep(h, 2, m_T, "-")
  u <- cbind(w * hc, A * w * (Y - muA), (1 - A) * w * (Y - muC))

  Am <- matrix(0, p + 2L, p + 2L)
  Am[1:p, 1:p]        <- crossprod(w * hc, h) / n
  Am[p + 1L, 1:p]     <- crossprod(A * w * (Y - muA), h) / n
  Am[p + 2L, 1:p]     <- crossprod((1 - A) * w * (Y - muC), h) / n
  Am[p + 1L, p + 1L]  <- -sum(A * w) / n
  Am[p + 2L, p + 2L]  <- -sum((1 - A) * w) / n

  Ai <- tryCatch(solve(Am), error = function(e) NULL)
  if (is.null(Ai)) return(list(est = muA - muC, var = NA_real_))
  cv <- c(rep(0, p), 1, -1)
  a <- as.vector(crossprod(cv, Ai))
  list(est = muA - muC, var = as.numeric(a %*% (crossprod(u) / n) %*% a) / n)
}

## MAIC. Returns the transported A versus C effect and the weights, which the
## diagnostics need.
##
## `moments` chooses what is calibrated. "both" matches the target's means AND
## standard deviations of the adjustment set, which is what an analyst does when
## the baseline table reports both and is the usual practice. "mean" matches means
## only.
##
## Both are run because a critique of this design pointed out, correctly, that
## forcing MAIC to calibrate second moments that are irrelevant to a linear
## effect-modification structure costs it effective sample size for nothing, and
## that scoring effective sample size under that handicap confounds the estimator
## with a modeling choice. Reporting both separates them.
est_maic <- function(rep_data, conv, moments = c("both", "mean")) {
  moments <- match.arg(moments)
  s <- rep_data$source
  h <- if (moments == "both") h_of(s$X) else s$X[, MATCHED, drop = FALSE]
  m <- if (moments == "both") rep_data$m_T else rep_data$target$mean[MATCHED]
  fw <- fit_weights(h, m)
  ok <- fw$conv == 0L && is.finite(fw$max_imbalance) &&
    fw$max_imbalance <= conv$max_imbalance
  if (!ok) return(list(ok = FALSE, why = "calibration", w = fw$w, fit = fw))
  sw <- maic_sandwich(h, s$A, s$Y, fw$w, m)
  w <- fw$w; A <- s$A
  list(ok = TRUE, est = sw$est, var = sw$var, w = w, fit = fw,
       ## What was actually calibrated, so the balance diagnostic is computed on
       ## the constraints this fit imposed and not on constraints it never had.
       h_used = h, m_used = m,
       lin = function(y) sum(w * A * y) / sum(w * A) -
         sum(w * (1 - A) * y) / sum(w * (1 - A)))
}

## STC. Source outcome model with the adjustment set centered at the reported
## target means, so the treatment coefficient is the effect at the target mean
## covariate vector. With an identity link that conditional effect is also the
## target-population marginal effect, which is why this study can use a linear
## model without the conditional-versus-marginal error that STC is criticized for
## on non-collapsible scales.
est_stc <- function(rep_data) {
  s <- rep_data$source
  Xc <- sweep(s$X[, MATCHED, drop = FALSE], 2,
              rep_data$target$mean[MATCHED], "-")
  d <- data.frame(Y = s$Y, A = s$A, Xc)
  names(d)[3:5] <- c("Z1", "Z2", "Z3")
  fit <- stats::lm(Y ~ A * (Z1 + Z2 + Z3), data = d)
  if (any(is.na(stats::coef(fit)))) return(list(ok = FALSE, why = "rank"))
  b <- stats::coef(fit)
  ## The treatment coefficient as an explicit linear functional of the outcome,
  ## a' = e_A' (M'M)^-1 M', so the error decomposition below can be applied to it.
  M <- stats::model.matrix(fit)
  e <- numeric(ncol(M)); e[match("A", colnames(M))] <- 1
  XtXi_e <- solve(crossprod(M), e)
  a <- as.vector(M %*% XtXi_e)
  ## Heteroskedasticity-consistent variance (HC3), not the model-based one.
  ##
  ## In the cells where the X1 X2 or X4 modifier is switched on, this mean model
  ## is misspecified: the omitted interaction makes the residual variance depend
  ## on treatment and covariates, so the ordinary least squares variance is
  ## invalid even for the pseudo-parameter the regression converges to. Giving
  ## MAIC a sandwich and STC the model-based variance would have been a rigged
  ## comparison, and a critique of the design said so before it was run.
  r <- stats::resid(fit)
  hii <- pmin(stats::hatvalues(fit), 1 - 1e-8)
  v <- sum(a^2 * (r / (1 - hii))^2)
  list(ok = TRUE, est = unname(b["A"]), var = v,
       var_ols = unname(stats::vcov(fit)["A", "A"]),
       r2 = summary(fit)$r.squared, fit = fit,
       lin = function(y) sum(a * y))
}

## No adjustment at all: the source arm-mean difference, carried across as if the
## populations were the same. The status quo comparator, and the thing every
## population adjustment is claiming to improve on.
est_unadj <- function(rep_data) {
  s <- rep_data$source
  A <- s$A
  yA <- s$Y[A == 1L]; yC <- s$Y[A == 0L]
  list(ok = TRUE, est = mean(yA) - mean(yC),
       var = stats::var(yA) / length(yA) + stats::var(yC) / length(yC),
       lin = function(y) mean(y[A == 1L]) - mean(y[A == 0L]))
}

## Exact decomposition of one replicate's error.
##
## All three estimators are linear in the outcome vector for a fixed design, so
## writing E[Y | X, A] = f(X) + A {d_A + g_A(X)} and applying the SAME linear
## functional to each piece splits the realized error into three terms that add up
## exactly, with no approximation and no large-sample argument:
##
##   err = theta_hat - theta_AC(T)
##       = [L(f) ]                      arm imbalance: what the estimator returns
##                                      when there is no treatment effect at all,
##                                      a chance term that randomization makes
##                                      mean-zero but not zero
##       + [L(A {d_A + g_A}) - theta_AC(T)]   transport error: the part covariate
##                                      adjustment exists to remove
##       + [L(Y) - L(E[Y | X, A])]      outcome noise.
##
## The transport term is the only one a covariate diagnostic could know about
## before seeing an outcome. Reporting the three separately is what lets the study
## distinguish a diagnostic that fails from a diagnostic that is being asked to
## predict something it has no information about.
decompose <- function(lin, rep_data, scen) {
  s <- rep_data$source
  fx <- f_prog(s$X)
  gx <- s$A * (D_A + g_A(s$X, scen$joint, scen$omit))
  c(arm_imbalance = lin(fx),
    transport = lin(gx) - rep_data$truth$theta_AC,
    noise = lin(s$Y) - lin(fx + gx))
}

## Convergence rules, fixed in the protocol before the run. A MAIC replicate
## counts as fitted only if the calibration equations were actually solved; an
## optimizer that reports success at a point where the moments are still
## unbalanced has not produced a MAIC fit, and counting it as one would let poor
## overlap masquerade as successful adjustment.
CONVERGENCE <- list(max_imbalance = 1e-6)
