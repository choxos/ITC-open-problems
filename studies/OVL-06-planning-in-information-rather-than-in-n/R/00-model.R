## ---------------------------------------------------------------------------
## OVL-06: can a planner predict the precision a MAIC will achieve?
##
## Three planning quantities, each computable from posited source and target laws
## before any data exist:
##   nominal     Var = 1/(n_A p1 (1-p1)) + 1/(n_C p0 (1-p0))
##   Kish ESS    the same with n_a replaced by n_a (E w)^2 / E w^2
##   influence   the stacked estimating-equation variance A^-1 B A^-T / n,
##               evaluated on a large draw from the posited laws
## Each is compared with the SD MAIC actually achieves at that n.
## Binary outcome, marginal log OR of A versus C in the target.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261008L
N_SIM <- 1000L; N_POP <- 100000L
LEVELS <- list(n = c(150L, 400L, 1000L), shift = c(0.2, 0.5, 0.8), dim = c(2L, 5L),
               alloc = c("1:1", "2:1"), prev = c(0.1, 0.3))

build_grid <- function() {
  g <- expand.grid(n = LEVELS$n, shift = LEVELS$shift, dim = LEVELS$dim, alloc = LEVELS$alloc,
                   prev = LEVELS$prev, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
## n is the total; 2:1 puts two thirds on A.
arm_sizes <- function(cell) { f <- if (cell$alloc == "1:1") 0.5 else 2 / 3
  c(A = round(cell$n * f), C = cell$n - round(cell$n * f)) }

gen <- function(nA, nC, cell) {
  d <- cell$dim; X <- matrix(stats::rnorm((nA + nC) * d), ncol = d); A <- rep(1:0, c(nA, nC))
  eta <- stats::qlogis(cell$prev) + 0.4 * rowSums(X) / sqrt(d) + A * (-0.5 + 0.4 * X[, 1])
  list(X = X, A = A, y = stats::rbinom(nA + nC, 1, stats::plogis(eta)))
}
## Target mean at Mahalanobis distance `shift` from the source, spread equally.
m_T <- function(cell) rep(cell$shift / sqrt(cell$dim), cell$dim)

tilt <- function(X, m) {
  Xc <- sweep(X, 2, m)
  f <- function(a) { z <- Xc %*% a; mx <- max(z); log(sum(exp(z - mx))) + mx }
  gr <- function(a) { z <- Xc %*% a; w <- exp(z - max(z)); colSums(Xc * as.vector(w)) / sum(w) }
  a <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS", control = list(reltol = 1e-14))$par
  list(a = a, w = as.vector(exp(Xc %*% a)))
}

maic <- function(s, m) {
  tw <- tilt(s$X, m); w <- tw$w
  p1 <- sum(w * s$A * s$y) / sum(w * s$A); p0 <- sum(w * (1 - s$A) * s$y) / sum(w * (1 - s$A))
  list(est = stats::qlogis(p1) - stats::qlogis(p0), a = tw$a, p1 = p1, p0 = p0, w = w)
}

## Stacked estimating equations per observation, theta = (a, p1, p0).
ee <- function(th, s, m) {
  k <- length(m); Xc <- sweep(s$X, 2, m); w <- as.vector(exp(Xc %*% th[1:k]))
  cbind(Xc * w, w * s$A * (s$y - th[k + 1]), w * (1 - s$A) * (s$y - th[k + 2]))
}

plan <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(500L + cell$cell)
  sz <- arm_sizes(cell); frac <- sz / sum(sz)
  big <- gen(round(N_POP * frac[["A"]]), round(N_POP * frac[["C"]]), cell)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  m <- m_T(cell); f <- maic(big, m); th <- c(f$a, f$p1, f$p0)
  U <- ee(th, big, m); N <- nrow(U)
  Am <- numDeriv::jacobian(function(t) colSums(ee(t, big, m)) / N, th); Bm <- crossprod(U) / N
  V <- solve(Am) %*% Bm %*% t(solve(Am))
  k <- length(m); g <- c(rep(0, k), 1 / (f$p1 * (1 - f$p1)), -1 / (f$p0 * (1 - f$p0)))
  v_if <- drop(t(g) %*% V %*% g) / sum(sz)
  essf <- function(a) { w <- f$w[big$A == a]; mean(w)^2 / mean(w^2) }
  v_nom <- 1 / (sz[["A"]] * f$p1 * (1 - f$p1)) + 1 / (sz[["C"]] * f$p0 * (1 - f$p0))
  v_ess <- 1 / (sz[["A"]] * essf(1) * f$p1 * (1 - f$p1)) + 1 / (sz[["C"]] * essf(0) * f$p0 * (1 - f$p0))
  c(se_nominal = sqrt(v_nom), se_kish = sqrt(v_ess), se_influence = sqrt(v_if))
}

one_rep <- function(cell) {
  sz <- arm_sizes(cell); s <- gen(sz[["A"]], sz[["C"]], cell)
  f <- tryCatch(maic(s, m_T(cell)), error = function(e) NULL)
  if (is.null(f) || !is.finite(f$est)) NA else f$est
}
