## ---------------------------------------------------------------------------
## The joint law of exposure and covariate, solved so the three quantities in the
## identity take their registered values exactly.
##
## Within an arm the rate is lambda(x) = exp(const + k x), x ~ N(m, 1), so
## CV(lambda) = sqrt(exp(k^2) - 1). Exposure is lognormal given x,
##
##   log T = alpha + c (x - m) + e,   e ~ N(0, s^2),
##
## so CV(T) = sqrt(exp(c^2 + s^2) - 1) and, because log T and log lambda are
## jointly normal,
##
##   corr(T, lambda) = (exp(k c) - 1) / (CV(T) CV(lambda)).
##
## Setting that to rho gives c = log(1 + rho CV(T) CV(lambda)) / k, and then
## s^2 = log(1 + CV(T)^2) - c^2. The requested triple is attainable only if
## 1 + rho CV(T) CV(lambda) > 0 and s^2 >= 0. That is probe P2, and it is
## computed here rather than discovered by a generator silently projecting an
## unreachable correlation (DESIGN.md section 10).
##
## Two facts the fitting code relies on, both exact under this law:
##   E[T | x] is proportional to exp(c x), so the exposure-weighted covariate law
##   is N(m + c, 1);
##   E[T lambda] / (E[T] E[lambda]) = 1 + rho CV(T) CV(lambda).
## ---------------------------------------------------------------------------

source("R/00-config.R")

b_from_cv <- function(cv_lam) sqrt(log(1 + cv_lam^2))
cv_from_k <- function(k) sqrt(exp(k^2) - 1)

## Exposure law for one arm with rate slope k.
exposure_law <- function(rho, cv_t, k) {
  cv_lam <- cv_from_k(k)
  f <- 1 + rho * cv_t * cv_lam
  if (f <= 0) return(list(ok = FALSE, why = "1 + rho CV CV <= 0"))
  c <- if (k == 0) 0 else log(f) / k
  s2 <- log(1 + cv_t^2) - c^2
  if (s2 < -1e-12) return(list(ok = FALSE, why = "residual variance < 0", c = c))
  s2 <- max(s2, 0)
  list(ok = TRUE, c = c, s2 = s2, alpha = log(MEAN_T) - (c^2 + s2) / 2,
       factor = f, cv_lam = cv_lam, rho = rho, cv_t = cv_t)
}

## The whole cell's arm laws. Control arms have slope b; active arms b + gamma.
## A and B share one exposure mechanism, as do the two control arms, which is
## what lets the deployable arm borrow it from the individual-data study.
cell_laws <- function(cell) {
  b <- b_from_cv(cell$cv_lam)
  kC <- b; kT <- b + cell$gamma
  list(b = b, kC = kC, kT = kT,
       C = exposure_law(cell$rho0, cell$cv_t, kC),
       T = exposure_law(cell$rho0 + cell$drho, cell$cv_t, kT))
}

attainable <- function(cell) {
  L <- cell_laws(cell)
  isTRUE(L$C$ok) && isTRUE(L$T$ok)
}

## True target estimand: log marginal rate ratio of B versus C in the target
## population N(MEAN_TARGET, 1). Closed form for a log-linear rate and a normal
## covariate, so no integration order is needed.
truth <- function(cell) {
  b <- b_from_cv(cell$cv_lam); g <- cell$gamma
  D_B + g * MEAN_TARGET + ((b + g)^2 - b^2) * SD_X^2 / 2
}

## Predicted bias of the unweighted estimator, from section 2's identity. Only
## the aggregate study's arms enter: the individual-data likelihood uses each
## participant's own exposure and is exact.
predicted_bias <- function(cell) {
  L <- cell_laws(cell)
  log(L$T$factor) - log(L$C$factor)
}

draw_arm <- function(n, m, mu, d, k, law) {
  x <- stats::rnorm(n, m, SD_X)
  T <- exp(law$alpha + law$c * (x - m) + stats::rnorm(n, 0, sqrt(law$s2)))
  lam <- exp(mu + d + k * x)
  y <- stats::rpois(n, T * lam)
  list(x = x, T = T, y = y, lam = lam)
}

## One replicate: individual data for study 1, arm totals for study 2.
draw_network <- function(cell) {
  L <- cell_laws(cell); n <- cell$n_arm
  c1 <- draw_arm(n, MEAN_IPD, MU[["ipd"]], 0,   L$kC, L$C)
  a1 <- draw_arm(n, MEAN_IPD, MU[["ipd"]], D_A, L$kT, L$T)
  c2 <- draw_arm(n, MEAN_AGD, MU[["agd"]], 0,   L$kC, L$C)
  b2 <- draw_arm(n, MEAN_AGD, MU[["agd"]], D_B, L$kT, L$T)
  ## The realized per-arm factor E[T lambda] / (E[T] E[lambda]), so the identity
  ## is checked against the data rather than assumed (DESIGN.md section 6).
  rf <- function(a) mean(a$T * a$lam) / (mean(a$T) * mean(a$lam))
  ## Reported covariate summaries: each arm's own sample mean and SD, which is
  ## what a publication gives, and the exposure-weighted versions, which is what
  ## it would have to give for the likelihood to be exact. Population moments
  ## would ignore the arm's covariate sampling variation and make every method's
  ## Poisson standard error too small, which a pre-registration check found.
  wm <- function(a) sum(a$T * a$x) / sum(a$T)
  wv <- function(a) sum(a$T * (a$x - wm(a))^2) / sum(a$T)
  list(
    ipd = data.frame(x = c(c1$x, a1$x), T = c(c1$T, a1$T), y = c(c1$y, a1$y),
                     A = rep(0:1, each = n)),
    agd = data.frame(arm = c("C", "B"), Y = c(sum(c2$y), sum(b2$y)),
                     E = c(sum(c2$T), sum(b2$T)),
                     cv_T = c(stats::sd(c2$T) / mean(c2$T), stats::sd(b2$T) / mean(b2$T)),
                     x_mean = c(mean(c2$x), mean(b2$x)),
                     x_var = c(stats::var(c2$x), stats::var(b2$x)),
                     xw_mean = c(wm(c2), wm(b2)), xw_var = c(wv(c2), wv(b2)),
                     stringsAsFactors = FALSE),
    realized_bias = log(rf(b2)) - log(rf(c2)),
    laws = L)
}
