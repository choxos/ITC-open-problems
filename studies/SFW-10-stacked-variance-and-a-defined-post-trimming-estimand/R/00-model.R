## ---------------------------------------------------------------------------
## SFW-10: MAIC variance with the weight-estimation step, and the estimand that
## trimmed weights actually target.
##
## Stacked estimating equations theta = (a, p1, p0):
##   sum w_i (x_i - m_T) = 0,  w_i = exp(a'(x_i - m_T))
##   sum w_i A_i (y_i - p1) = 0,  sum w_i (1 - A_i)(y_i - p0) = 0
## The fixed-weight sandwich drops the first block. The term it omits is a
## covariance between the outcome and calibration scores whose sign depends on how
## the outcome aligns with the balancing covariates (DESIGN.md section 2), so the
## fixed-weight variance is not conservative by construction.
##
## Trimming caps the weights at a percentile. The capped weights no longer match
## the target moments, so the analysis estimates the effect in the population the
## capped weights induce, w_cap(x) f_S(x). That population's effect is computed
## here as a second truth.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261001L
P <- 3L; N_ARM <- 200L; DELTA <- -0.5; GAMMA <- 0.5
N_SIM <- 1000L
LEVELS <- list(shift = c(0.2, 0.5, 0.8), prev = c(0.1, 0.3), em = c(0, 0.5, 1),
               align = c("positive", "negative"), trim = c("none", "p99", "p95"))

build_grid <- function() {
  g <- expand.grid(shift = LEVELS$shift, prev = LEVELS$prev, em = LEVELS$em,
                   align = LEVELS$align, trim = LEVELS$trim, KEEP.OUT.ATTRS = FALSE,
                   stringsAsFactors = FALSE)
  g <- g[!(g$em == 0 & g$align == "negative"), ]
  g$cell <- seq_len(nrow(g)); g
}

## Modification of A by x1, positive or negative relative to the prognostic
## direction (all prognostic coefficients are +GAMMA).
em_coef <- function(cell) if (cell$align == "positive") cell$em else -cell$em
m_T <- function(cell) rep(cell$shift, P)
alpha_for <- function(cell) {
  ## control risk `prev` at the source covariate mean
  stats::qlogis(cell$prev)
}
eta <- function(X, A, cell) alpha_for(cell) + GAMMA * rowSums(X) + A * (DELTA + em_coef(cell) * X[, 1])

marg_logor <- function(X, w, cell) {
  p1 <- sum(w * stats::plogis(eta(X, 1, cell))) / sum(w)
  p0 <- sum(w * stats::plogis(eta(X, 0, cell))) / sum(w)
  stats::qlogis(p1) - stats::qlogis(p0)
}

tilt <- function(X, m) {
  Xc <- sweep(X, 2, m)
  f <- function(a) { z <- Xc %*% a; mx <- max(z); log(sum(exp(z - mx))) + mx }
  gr <- function(a) { z <- Xc %*% a; w <- exp(z - max(z)); colSums(Xc * as.vector(w)) / sum(w) }
  stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS", control = list(reltol = 1e-14))$par
}

cap_at <- function(w, trim) {
  if (trim == "none") return(w)
  q <- stats::quantile(w, if (trim == "p99") 0.99 else 0.95, names = FALSE)
  pmin(w, q)
}

## Truths from one large source draw per cell: the declared target, and the
## population induced by the capped population weights.
truths <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(4242L)
  XS <- matrix(stats::rnorm(4e5 * P), ncol = P)
  XT <- sweep(matrix(stats::rnorm(4e5 * P), ncol = P), 2, m_T(cell), "+")
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  a <- tilt(XS[1:1e5, ], m_T(cell))
  w <- as.vector(exp(sweep(XS, 2, m_T(cell)) %*% a))
  c(target = marg_logor(XT, rep(1, nrow(XT)), cell),
    induced = marg_logor(XS, cap_at(w, cell$trim), cell))
}

draw <- function(cell) {
  X <- matrix(stats::rnorm(2 * N_ARM * P), ncol = P); A <- rep(0:1, each = N_ARM)
  list(X = X, A = A, y = stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(X, A, cell))))
}

ee <- function(th, d, m) {
  Xc <- sweep(d$X, 2, m); w <- as.vector(exp(Xc %*% th[1:P]))
  cbind(Xc * w, w * d$A * (d$y - th[P + 1]), w * (1 - d$A) * (d$y - th[P + 2]))
}

fit <- function(cell, d) {
  m <- m_T(cell)
  a <- tilt(d$X, m)
  w0 <- as.vector(exp(sweep(d$X, 2, m) %*% a))
  w <- cap_at(w0, cell$trim)
  p1 <- sum(w * d$A * d$y) / sum(w * d$A); p0 <- sum(w * (1 - d$A) * d$y) / sum(w * (1 - d$A))
  if (p1 <= 0 || p1 >= 1 || p0 <= 0 || p0 >= 1) return(NULL)
  est <- stats::qlogis(p1) - stats::qlogis(p0)
  g <- c(1 / (p1 * (1 - p1)), -1 / (p0 * (1 - p0)))
  ## fixed-weight sandwich
  v1 <- sum(w^2 * d$A * (d$y - p1)^2) / sum(w * d$A)^2
  v0 <- sum(w^2 * (1 - d$A) * (d$y - p0)^2) / sum(w * (1 - d$A))^2
  se_fixed <- sqrt(g[1]^2 * v1 + g[2]^2 * v0)
  ## ESS-based conventional variance
  ess1 <- sum(w * d$A)^2 / sum(w^2 * d$A); ess0 <- sum(w * (1 - d$A))^2 / sum(w^2 * (1 - d$A))
  se_ess <- sqrt(1 / (ess1 * p1 * (1 - p1)) + 1 / (ess0 * p0 * (1 - p0)))
  out <- c(est = est, se_fixed = se_fixed, se_ess = se_ess, se_stack = NA, se_stack_hc1 = NA,
           ess = sum(w)^2 / sum(w^2))
  if (cell$trim == "none") {
    th <- c(a, p1, p0)
    U <- ee(th, d, m); Bm <- crossprod(U)
    Am <- numDeriv::jacobian(function(t) colSums(ee(t, d, m)), th)
    Ai <- solve(Am); V <- Ai %*% Bm %*% t(Ai)
    gg <- c(rep(0, P), g)
    v <- drop(t(gg) %*% V %*% gg); n <- nrow(d$X); k <- length(th)
    out[["se_stack"]] <- sqrt(v); out[["se_stack_hc1"]] <- sqrt(v * n / (n - k))
  }
  out
}
