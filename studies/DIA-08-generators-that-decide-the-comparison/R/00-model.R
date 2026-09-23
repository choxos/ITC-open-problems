## ---------------------------------------------------------------------------
## DIA-08: does the generator's effect-modification structure decide which
## population-adjustment method wins?
##
## Anchored pairwise comparison. AC trial with individual data (300 per arm),
## x1, x2 with mean 0 and SD 1; BC trial in the target population, 300 per arm,
## covariate means (m, m), SD 1, reporting means, SDs and arm event counts.
## Binary outcome, logit p = -0.5 + 0.5 (x1 + x2) + treatment term.
## A's conditional effect tau_A(x) by departure (B's is constant, -0.8, since the
## B-C contrast is observed in the target):
##   linear       -0.6 + 0.4 x1 + 0.4 x2              (shared linear, the reference)
##   threshold    -0.6 + 0.8 1(x1 > 0.5) + 0.4 x2
##   interaction  -0.6 + 0.4 x1 + 0.4 x2 + 0.4 x1 x2
##   quadratic    -0.6 + 0.4 x1 + 0.4 x2 + 0.3 x1^2
##   none         -0.6                                   (zero modification control)
## Covariate law normal, or standardized Gamma(2) (same means and SDs) for the
## covariate-half falsifier. Reported moments are identical across departures.
## Estimand: marginal log OR, B versus A, in the target.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261015L
N_ARM <- 300L; TAU_B <- -0.8; G_POINTS <- 2000L; N_SIM <- 2000L
build_grid <- function() {
  g <- rbind(expand.grid(departure = c("linear", "threshold", "interaction", "quadratic"), m = c(0.3, 0.8, 1.2), law = "normal",
                         KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE),
             data.frame(departure = "linear", m = c(0.3, 0.8, 1.2), law = "skewed"),
             data.frame(departure = "none", m = 0.8, law = "normal"))
  g$cell <- seq_len(nrow(g)); g
}
tau_a <- function(x1, x2, dep) switch(dep, linear = -0.6 + 0.4 * x1 + 0.4 * x2,
  threshold = -0.6 + 0.8 * (x1 > 0.5) + 0.4 * x2, interaction = -0.6 + 0.4 * x1 + 0.4 * x2 + 0.4 * x1 * x2,
  quadratic = -0.6 + 0.4 * x1 + 0.4 * x2 + 0.3 * x1^2, none = -0.6 + 0 * x1)
rx <- function(n, law, m) if (law == "normal") stats::rnorm(n, m) else m + (stats::rgamma(n, 2) - 2) / sqrt(2)
prog <- function(x1, x2) -0.5 + 0.5 * (x1 + x2)

truth <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(99); n <- 2e6; x1 <- rx(n, cell$law, cell$m); x2 <- rx(n, cell$law, cell$m)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  p0 <- mean(stats::plogis(prog(x1, x2)))
  dA <- stats::qlogis(mean(stats::plogis(prog(x1, x2) + tau_a(x1, x2, cell$departure)))) - stats::qlogis(p0)
  dB <- stats::qlogis(mean(stats::plogis(prog(x1, x2) + TAU_B))) - stats::qlogis(p0)
  dB - dA
}

draw <- function(cell) {
  n <- 2 * N_ARM; A <- rep(0:1, each = N_ARM)
  x1 <- rx(n, cell$law, 0); x2 <- rx(n, cell$law, 0)
  ipd <- data.frame(x1 = x1, x2 = x2, A = A, y = stats::rbinom(n, 1, stats::plogis(prog(x1, x2) + A * tau_a(x1, x2, cell$departure))))
  t1 <- rx(n, cell$law, cell$m); t2 <- rx(n, cell$law, cell$m)
  yb <- stats::rbinom(n, 1, stats::plogis(prog(t1, t2) + A * TAU_B))
  list(ipd = ipd, agd = list(m = c(mean(t1), mean(t2)), s = c(stats::sd(t1), stats::sd(t2)),
       e1 = sum(yb[A == 1]), e0 = sum(yb[A == 0]), n = N_ARM))
}

tilt <- function(X, m) { Xc <- sweep(X, 2, m)
  o <- stats::optim(rep(0, ncol(X)), function(a) sum(exp(Xc %*% a)), function(a) colSums(Xc * as.vector(exp(Xc %*% a))),
                    method = "BFGS", control = list(maxit = 500))
  as.vector(exp(Xc %*% o$par)) }
wlogor <- function(d, w) { f <- suppressWarnings(stats::glm(y ~ A, family = stats::binomial(), data = d, weights = w))
  c(stats::coef(f)[["A"]], sqrt(sandwich::sandwich(f)["A", "A"])) }

## G-computation over a pseudo-population drawn from independent normals with the
## reported means and SDs, as analysts do; delta-method SE.
gcomp <- function(f, Z) {
  tt <- stats::delete.response(stats::terms(f)); b <- stats::coef(f)
  M1 <- stats::model.matrix(tt, transform(Z, A = 1)); M0 <- stats::model.matrix(tt, transform(Z, A = 0))
  p1 <- stats::plogis(M1 %*% b); p0 <- stats::plogis(M0 %*% b); q1 <- mean(p1); q0 <- mean(p0)
  g <- colMeans(M1 * as.vector(p1 * (1 - p1))) / (q1 * (1 - q1)) - colMeans(M0 * as.vector(p0 * (1 - p0))) / (q0 * (1 - q0))
  c(stats::qlogis(q1) - stats::qlogis(q0), sqrt(drop(t(g) %*% stats::vcov(f) %*% g)))
}
U <- NULL
pseudo <- function(a) { if (is.null(U)) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(5); U <<- matrix(stats::rnorm(2 * G_POINTS), ncol = 2); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv) }
  data.frame(x1 = a$m[1] + a$s[1] * U[, 1], x2 = a$m[2] + a$s[2] * U[, 2]) }

fit_all <- function(dd) {
  d <- dd$ipd; a <- dd$agd
  dbc <- stats::qlogis(a$e1 / a$n) - stats::qlogis(a$e0 / a$n)
  vbc <- 1 / a$e1 + 1 / (a$n - a$e1) + 1 / a$e0 + 1 / (a$n - a$e0)
  X <- cbind(d$x1, d$x2)
  s2 <- a$s^2 * (a$n * 2 - 1) / (a$n * 2) + a$m^2
  ac <- list(unadjusted = wlogor(d, rep(1, nrow(d))),
             maic_means = wlogor(d, tilt(X, a$m)),
             maic_means_sds = wlogor(d, tilt(cbind(X, X^2), c(a$m, s2))),
             stc_linear = gcomp(suppressWarnings(stats::glm(y ~ A * (x1 + x2), family = stats::binomial(), data = d)), pseudo(a)),
             stc_flexible = gcomp(suppressWarnings(stats::glm(y ~ A * (x1 + x2 + I(x1^2) + I(x2^2) + x1:x2), family = stats::binomial(), data = d)), pseudo(a)))
  do.call(rbind, lapply(names(ac), function(k) data.frame(method = k, est = dbc - ac[[k]][1], se = sqrt(vbc + ac[[k]][2]^2))))
}
