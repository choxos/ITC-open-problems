## ---------------------------------------------------------------------------
## OVL-01: unsupported target mass matters only where the effect is modified.
##
## Source trial A versus C, 300 per arm, x1, x2 ~ N(0, 1) with x1 truncated to
## x1 <= C_TRUNC (support absent above it). Target x ~ N(0.4, I), known law.
## Continuous outcome y = 0.5 (x1 + x2) + A tau(x) + e, e ~ N(0, 1), with
## tau(x) = -0.5 + b {w1 g(x1) + w2 g(x2)}, g(x) = x + HINGE (x - 1)_+ ("bent")
## or g(x) = x ("linear"). Alignment sets (w1, w2): orthogonal (0, 1), partial
## (0.5, 0.5), full (1, 0). The covariate laws do not depend on alignment or
## shape, so every covariate-and-weight diagnostic has the same distribution
## across them (DESIGN.md section 2, consequence 3).
##
## Estimand: E_T tau(x), the target mean difference over the whole target law.
## Restricted estimand: E_T[tau | x1 <= C_TRUNC], what trimming targets.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261013L
N_ARM <- 300L; M_T <- 0.4; HINGE <- 3; KNOT <- 1; DELTA0 <- -0.5
MATERIAL <- 0.2; N_SIM <- 1000L; G_POINTS <- 4000L
ALIGN <- list(orthogonal = c(0, 1), partial = c(0.5, 0.5), full = c(1, 0))
LEVELS <- list(c_trunc = c(Inf, 1.5, 1.0), align = names(ALIGN), shape = c("linear", "bent"), b = c(0.3, 0.6))

build_grid <- function() {
  g <- expand.grid(c_trunc = LEVELS$c_trunc, align = LEVELS$align, shape = LEVELS$shape, b = LEVELS$b,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

gfun <- function(x, shape) if (shape == "bent") x + HINGE * pmax(x - KNOT, 0) else x
tau <- function(x1, x2, cell) { w <- ALIGN[[cell$align]]
  DELTA0 + cell$b * (w[1] * gfun(x1, cell$shape) + w[2] * gfun(x2, cell$shape)) }

## E[g(x)] for x ~ N(M_T, 1), optionally truncated to x <= u.
eg <- function(shape, u = Inf) {
  f <- function(x) gfun(x, shape) * stats::dnorm(x, M_T)
  stats::integrate(f, -Inf, u)$value / stats::pnorm(u, M_T)
}
truth <- function(cell) { w <- ALIGN[[cell$align]]; DELTA0 + cell$b * (w[1] * eg(cell$shape) + w[2] * eg(cell$shape)) }
truth_restricted <- function(cell) { w <- ALIGN[[cell$align]]
  DELTA0 + cell$b * (w[1] * eg(cell$shape, cell$c_trunc) + w[2] * eg(cell$shape)) }

rtrunc <- function(n, u) { if (is.infinite(u)) return(stats::rnorm(n))
  stats::qnorm(stats::runif(n) * stats::pnorm(u)) }

draw <- function(cell) {
  n <- 2 * N_ARM; x1 <- rtrunc(n, cell$c_trunc); x2 <- stats::rnorm(n); A <- rep(0:1, each = N_ARM)
  data.frame(x1 = x1, x2 = x2, A = A, y = 0.5 * (x1 + x2) + A * tau(x1, x2, cell) + stats::rnorm(n))
}

ZT <- NULL
target_draws <- function() { if (is.null(ZT)) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(11); ZT <<- data.frame(x1 = stats::rnorm(G_POINTS, M_T), x2 = stats::rnorm(G_POINTS, M_T))
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv) }; ZT }

## E[(x - m)_+] and E[(m - x)_+] for x ~ N(M_T, 1).
above <- function(m) { z <- M_T - m; z * stats::pnorm(z) + stats::dnorm(z) }
below <- function(m) { z <- m - M_T; z * stats::pnorm(z) + stats::dnorm(z) }

fit_all <- function(d) {
  ## MAIC on the target means, weights shared by both arms; robust SE.
  X <- cbind(d$x1 - M_T, d$x2 - M_T)
  o <- stats::optim(c(0, 0), function(a) sum(exp(X %*% a)), function(a) colSums(X * as.vector(exp(X %*% a))), method = "BFGS")
  w <- as.vector(exp(X %*% o$par)); ess <- sum(w)^2 / sum(w^2)
  fm <- stats::lm(y ~ A, data = d, weights = w)
  maic <- c(stats::coef(fm)[["A"]], sqrt(sandwich::vcovHC(fm, "HC0")["A", "A"]))
  ## G-computation with natural-spline modification: correct within the observed
  ## range, linear beyond it.
  f <- stats::lm(y ~ A * (splines::ns(x1, 3) + splines::ns(x2, 3)), data = d)
  tt <- stats::delete.response(stats::terms(f)); Z <- target_draws()
  gc <- function(Zs) { M1 <- stats::model.matrix(tt, transform(Zs, A = 1)); M0 <- stats::model.matrix(tt, transform(Zs, A = 0))
    gr <- colMeans(M1 - M0); c(sum(gr * stats::coef(f)), sqrt(drop(t(gr) %*% stats::vcov(f) %*% gr))) }
  lo <- unname(apply(d[, c("x1", "x2")], 2, min)); hi <- unname(apply(d[, c("x1", "x2")], 2, max))
  inside <- Z$x1 >= lo[1] & Z$x1 <= hi[1] & Z$x2 >= lo[2] & Z$x2 <= hi[2]
  gfull <- gc(Z); gtrim <- gc(Z[inside, ])
  ## Linear-interaction fit for the alignment-aware score.
  bl <- stats::coef(stats::lm(y ~ A * (x1 + x2), data = d))[c("A:x1", "A:x2")]
  unsup <- 1 - (stats::pnorm(hi[1], M_T) - stats::pnorm(lo[1], M_T)) * (stats::pnorm(hi[2], M_T) - stats::pnorm(lo[2], M_T))
  ext <- c(above(hi[1]) + below(lo[1]), above(hi[2]) + below(lo[2]))
  c(maic_est = maic[1], maic_se = maic[2], gc_est = gfull[1], gc_se = gfull[2], trim_est = gtrim[1], trim_se = gtrim[2],
    ess_frac = ess / nrow(d), unsup_mass = unsup, max_w_share = max(w) / sum(w),
    align_score = sum(abs(bl) * ext))
}
