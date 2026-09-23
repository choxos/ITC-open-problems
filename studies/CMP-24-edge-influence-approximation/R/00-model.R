## ---------------------------------------------------------------------------
## CMP-24: cpaic's edge_influence() diagonal-weight influence against refitted
## references.
##
## Random networks of K studies over treatments A, B, C, D (two-arm, or with some
## three-arm studies), arm sizes 50 to 300, outcome SD 1; true effects against A
## (0, -0.2, -0.3, -0.4); random effects with SD TAU (correlation 0.5 within
## multi-arm studies). Target contrast D versus A.
## The approximation (cpaic at commit cf27b1a, R/diagnostics.R): rows are all
## pairwise comparisons, W = diag(1 / (seTE^2 + tau-hat^2)), influence of row j is
## a_j = m' (X'WX)^+ X'W; a study's influence is the sum of |a_j| over its rows.
## References, from the correctly specified model (basic contrasts with
## within-study covariance, tau^2 by REML): leave-one-study-out refits with tau
## re-estimated, scored by the change in the estimate and by variance importance
## 1 - Var(full) / Var(without the study).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261208L; N_SIM <- 500L; TRT <- c("A", "B", "C", "D"); EFF <- c(A = 0, B = -0.2, C = -0.3, D = -0.4)
build_grid <- function() { g <- expand.grid(multi = c("two-arm", "three-arm"), tau = c(0, 0.1, 0.3), K = c(8L, 16L), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g }
PAIRS <- utils::combn(TRT, 2, simplify = FALSE); TRIPLES <- utils::combn(TRT, 3, simplify = FALSE)
m_vec <- c(0, 0, 1)
xrow <- function(t1, t2) (TRT[-1] == t2) - (TRT[-1] == t1)

draw_network <- function(cell) {
  repeat {
    des <- lapply(seq_len(cell$K), function(i) if (cell$multi == "three-arm" && stats::runif(1) < 0.3) TRIPLES[[sample.int(4, 1)]] else PAIRS[[sample.int(6, 1)]])
    Xb <- do.call(rbind, lapply(des, function(t) do.call(rbind, lapply(t[-1], function(k) xrow(t[1], k)))))
    if (qr(Xb)$rank == 3) break }
  lapply(des, function(t) { n <- sample(50:300, length(t), replace = TRUE); s2 <- 2 / n       # arm-level variance of a mean difference share
    list(arms = t, s2 = s2) })
}
simulate_y <- function(net, tau) lapply(net, function(s) { k <- length(s$arms)
  re <- if (tau > 0) MASS::mvrnorm(1, rep(0, k - 1), tau^2 * (diag(0.5, k - 1) + 0.5)) else rep(0, k - 1)
  armv <- s$s2; mu <- EFF[s$arms[-1]] - EFF[s$arms[1]] + re
  V <- diag(armv[-1], k - 1) + armv[1]; y <- as.vector(mu + if (k > 2) MASS::mvrnorm(1, rep(0, k - 1), V) else stats::rnorm(1, 0, sqrt(V)))
  c(s, list(y = y, V = V)) })

## Correct model: GLS on basic contrasts with within-study covariance plus tau^2.
gls_fit <- function(studies, tau2) {
  P <- matrix(0, 3, 3); u <- numeric(3)
  for (s in studies) { X <- do.call(rbind, lapply(s$arms[-1], function(k) xrow(s$arms[1], k))); k <- length(s$arms)
    Vi <- solve(s$V + tau2 * (diag(0.5, k - 1) + 0.5)); P <- P + t(X) %*% Vi %*% X; u <- u + t(X) %*% Vi %*% s$y }
  b <- solve(P, u); list(est = sum(m_vec * b), var = drop(t(m_vec) %*% solve(P) %*% m_vec), P = P) }
reml_tau2 <- function(studies) { grid <- c(0, exp(seq(log(1e-4), log(1), length.out = 80)))
  ll <- vapply(grid, function(t2) { P <- matrix(0, 3, 3); u <- numeric(3); ld <- 0; q <- 0
    for (s in studies) { X <- do.call(rbind, lapply(s$arms[-1], function(k) xrow(s$arms[1], k))); k <- length(s$arms)
      Vs <- s$V + t2 * (diag(0.5, k - 1) + 0.5); Vi <- solve(Vs); P <- P + t(X) %*% Vi %*% X; u <- u + t(X) %*% Vi %*% s$y; ld <- ld + as.numeric(determinant(Vs)$modulus) }
    b <- solve(P, u); for (s in studies) { X <- do.call(rbind, lapply(s$arms[-1], function(k) xrow(s$arms[1], k))); k <- length(s$arms)
      r <- s$y - X %*% b; q <- q + drop(t(r) %*% solve(s$V + t2 * (diag(0.5, k - 1) + 0.5)) %*% r) }
    -0.5 * (ld + as.numeric(determinant(P)$modulus) + q) }, 0)
  grid[which.max(ll)] }
estimable <- function(studies) { X <- do.call(rbind, lapply(studies, function(s) do.call(rbind, lapply(s$arms[-1], function(k) xrow(s$arms[1], k)))))
  P <- crossprod(X); max(abs(m_vec %*% MASS::ginv(P) %*% P - m_vec)) < 1e-8 }

## cpaic's diagonal approximation, all pairwise rows with naive variances.
diag_influence <- function(studies, tau2) {
  rows <- do.call(rbind, lapply(seq_along(studies), function(i) { s <- studies[[i]]; pr <- utils::combn(seq_along(s$arms), 2)
    data.frame(study = i, a1 = pr[1, ], a2 = pr[2, ], v = s$s2[pr[1, ]] + s$s2[pr[2, ]]) }))
  X <- t(mapply(function(i, a1, a2) xrow(studies[[i]]$arms[a1], studies[[i]]$arms[a2]), rows$study, rows$a1, rows$a2))
  w <- 1 / (rows$v + tau2); infl <- as.numeric(m_vec %*% MASS::ginv(crossprod(X, w * X)) %*% t(w * X))
  tapply(abs(infl), rows$study, sum)
}

one_rep <- function(cell) {
  st <- simulate_y(draw_network(cell), cell$tau)
  t2 <- if (cell$tau == 0) 0 else reml_tau2(st); full <- gls_fit(st, t2)
  di <- diag_influence(st, t2)
  loso <- t(vapply(seq_along(st), function(i) { s <- st[-i]
    if (!estimable(s)) return(c(change = NA, importance = 1))
    t2i <- if (cell$tau == 0) 0 else reml_tau2(s); f <- gls_fit(s, t2i); c(change = abs(f$est - full$est), importance = 1 - full$var / f$var) }, numeric(2)))
  sp <- function(a, b) { ok <- is.finite(a) & is.finite(b); if (sum(ok) < 3 || stats::sd(a[ok]) == 0 || stats::sd(b[ok]) == 0) NA else stats::cor(a[ok], b[ok], method = "spearman") }
  zero <- di < 1e-8 * max(di)
  ## Exactness check: with two-arm studies, the correct model's hat row at the same
  ## tau-hat must reproduce the diagonal influences.
  exact_diff <- if (all(vapply(st, function(s) length(s$arms) == 2, TRUE))) {
    h <- vapply(seq_along(st), function(i) { s <- st[[i]]; x <- xrow(s$arms[1], s$arms[2]); abs(drop(m_vec %*% solve(full$P) %*% x) / (s$V[1, 1] + t2)) }, 0)
    max(abs(h - di)) } else NA
  data.frame(rho_importance = sp(di, loso[, "importance"]), rho_change = sp(di, loso[, "change"]),
             top_agree = which.max(di) == which.max(loso[, "importance"]),
             n_zero = sum(zero), zero_but_moves = sum(zero & loso[, "change"] > 1e-6, na.rm = TRUE), n_studies = length(st), tau_hat = sqrt(t2), exact_diff = exact_diff)
}
