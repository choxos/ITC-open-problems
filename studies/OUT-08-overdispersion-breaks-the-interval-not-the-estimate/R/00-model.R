## ---------------------------------------------------------------------------
## OUT-08: count outcomes with overdispersion and structural zeros, transported by
## G-computation from an individual-data trial (A versus C) to a target.
##
## Counts: with probability pi(x) a patient is a structural zero; otherwise
## Y ~ NB(mean mu_a(x) T, size THETA), log mu_a(x) = ALPHA + G x + a (DELTA + B x).
## Structural-zero probability logit pi(x) = z_pop + ZX x, with the intercept z_pop
## differing between source and target.
##
## Two separable failures (DESIGN.md section 2):
##  - Overdispersion leaves the Poisson point estimate consistent and its
##    model-based SE too small; a sandwich repairs the interval.
##  - A structural-zero fraction that differs between populations changes the
##    target's absolute rate, which a count model without the mixture transports
##    wrongly. For the rate RATIO, (1 - pi) cancels unless the at-risk composition
##    interacts with effect modification: with B = 0 the ratio is exp(DELTA) in any
##    population, so the anchored ratio is protected and the absolute rate is not.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261007L
N_ARM <- 300L; ALPHA <- log(1.2); G <- 0.4; DELTA <- -0.4; ZX <- 0.8
M_T <- 0.5; FOLLOW <- 1
N_SIM <- 500L; G_POINTS <- 4000L
LEVELS <- list(theta = c(Inf, 2, 0.7), pi_s = c(0, 0.2), pi_t = c(0, 0.2, 0.4), b = c(0, 0.4))

## Two parts with orthogonal nulls. A: overdispersion, no structural zeros.
## B: structural zeros with Poisson counts, the zero fraction differing or not
## between populations. Crossing them would make the zero-inflated Poisson fit
## misspecified by the overdispersion and confound the two failures.
build_grid <- function() {
  a <- expand.grid(theta = LEVELS$theta, pi_s = 0, pi_t = 0, b = LEVELS$b, KEEP.OUT.ATTRS = FALSE)
  zp <- data.frame(pi_s = c(0.2, 0.2, 0.2, 0), pi_t = c(0.2, 0.4, 0, 0.2))
  b <- merge(merge(data.frame(theta = Inf), zp), data.frame(b = LEVELS$b))
  g <- rbind(transform(a, part = "A"), transform(b[, c("theta", "pi_s", "pi_t", "b")], part = "B"))
  g$cell <- seq_len(nrow(g)); g
}

z_int <- function(pi0) if (pi0 == 0) -Inf else stats::qlogis(pi0)
pi_x <- function(x, pi0) if (pi0 == 0) rep(0, length(x)) else stats::plogis(z_int(pi0) + ZX * x)

## Truths in the target, x ~ N(M_T, 1): marginal rates under A and C, their ratio.
truths <- function(cell) {
  gh <- statmod::gauss.quad.prob(80, "normal", mu = M_T, sigma = 1)
  r <- function(a) sum(gh$weights * (1 - pi_x(gh$nodes, cell$pi_t)) *
                        exp(ALPHA + G * gh$nodes + a * (DELTA + cell$b * gh$nodes)))
  c(rate_A = r(1), rate_C = r(0), log_rr = log(r(1) / r(0)))
}

draw <- function(cell) {
  x <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM)
  mu <- exp(ALPHA + G * x + A * (DELTA + cell$b * x)) * FOLLOW
  y <- if (is.infinite(cell$theta)) stats::rpois(length(mu), mu) else stats::rnbinom(length(mu), size = cell$theta, mu = mu)
  y[stats::runif(length(y)) < pi_x(x, cell$pi_s)] <- 0
  ## The target publication reports its control arm's proportion with no events.
  xt <- stats::rnorm(N_ARM, M_T); mut <- exp(ALPHA + G * xt) * FOLLOW
  yt <- if (is.infinite(cell$theta)) stats::rpois(N_ARM, mut) else stats::rnbinom(N_ARM, size = cell$theta, mu = mut)
  yt[stats::runif(N_ARM) < pi_x(xt, cell$pi_t)] <- 0
  structure(data.frame(x = x, A = A, y = y), p0_target = mean(yt == 0))
}

## Zero-inflated Poisson by maximum likelihood: count part log mu = X b, zero
## part logit pi = c0 + c1 x.
zip_fit <- function(d) {
  X <- cbind(1, d$x, d$A, d$A * d$x)
  nll <- function(p) {
    mu <- exp(X %*% p[1:4]); pz <- stats::plogis(p[5] + p[6] * d$x)
    l0 <- log(pz + (1 - pz) * exp(-mu)); l1 <- log(1 - pz) + stats::dpois(d$y, mu, log = TRUE)
    -sum(ifelse(d$y == 0, l0, l1))
  }
  st <- c(stats::coef(stats::glm(y ~ x * A, family = stats::poisson(), data = d)), -1, 0)
  o <- stats::optim(st, nll, method = "BFGS", hessian = TRUE, control = list(maxit = 500))
  list(par = o$par, V = tryCatch(solve(o$hessian), error = function(e) NULL))
}

ZT <- NULL
tgt <- function() { if (is.null(ZT)) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(3); ZT <<- stats::rnorm(G_POINTS, M_T); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv) }; ZT }

## G-computation of the target log rate ratio and log rate of A, with a delta-method
## SE from a coefficient covariance V.
gcomp_count <- function(b, V, zero = NULL) {
  z <- tgt()
  M1 <- cbind(1, z, 1, z); M0 <- cbind(1, z, 0, 0)
  w <- if (is.null(zero)) rep(1, length(z)) else 1 - stats::plogis(zero[1] + zero[2] * z)
  r1 <- mean(w * exp(M1 %*% b)); r0 <- mean(w * exp(M0 %*% b))
  g1 <- colMeans(M1 * as.vector(w * exp(M1 %*% b))) / r1; g0 <- colMeans(M0 * as.vector(w * exp(M0 %*% b))) / r0
  k <- length(b)
  if (!is.null(zero)) {
    ## derivative of log r_a wrt the zero-part coefficients
    dz <- function(M) { e <- as.vector(exp(M %*% b)); pz <- stats::plogis(zero[1] + zero[2] * z)
      c(mean(-pz * (1 - pz) * e), mean(-pz * (1 - pz) * z * e)) }
    g1 <- c(g1, dz(M1) / r1); g0 <- c(g0, dz(M0) / r0)
  }
  gl <- g1 - g0
  c(log_rr = log(r1 / r0), se_rr = if (is.null(V)) NA else sqrt(drop(t(gl) %*% V %*% gl)),
    log_rate_A = log(r1), se_rate_A = if (is.null(V)) NA else sqrt(drop(t(g1) %*% V %*% g1)))
}

fit_all <- function(d) {
  fp <- stats::glm(y ~ x * A, family = stats::poisson(), data = d)
  out <- list(poisson = gcomp_count(stats::coef(fp), stats::vcov(fp)),
              poisson_sandwich = gcomp_count(stats::coef(fp), sandwich::sandwich(fp)))
  fn <- tryCatch(MASS::glm.nb(y ~ x * A, data = d), error = function(e) NULL)
  out$negbin <- if (is.null(fn)) rep(NA, 4) else gcomp_count(stats::coef(fn), stats::vcov(fn))
  zf <- tryCatch(zip_fit(d), error = function(e) NULL)
  out$zip <- if (is.null(zf)) rep(NA, 4) else gcomp_count(zf$par[1:4], zf$V, zero = zf$par[5:6])
  ## Zero part recalibrated to the target's reported zero proportion in its control
  ## arm: shift the zero-part intercept until the model reproduces it.
  out$zip_calibrated <- if (is.null(zf)) rep(NA, 4) else {
    z <- tgt(); mu0 <- exp(zf$par[1] + zf$par[2] * z)
    p0 <- attr(d, "p0_target")
    f <- function(c0) mean(stats::plogis(c0 + zf$par[6] * z) + (1 - stats::plogis(c0 + zf$par[6] * z)) * exp(-mu0)) - p0
    c0 <- tryCatch(stats::uniroot(f, c(-15, 10))$root, error = function(e) -15)
    gcomp_count(zf$par[1:4], zf$V, zero = c(c0, zf$par[6]))
  }
  do.call(rbind, lapply(names(out), function(m) data.frame(method = m, t(out[[m]]))))
}
